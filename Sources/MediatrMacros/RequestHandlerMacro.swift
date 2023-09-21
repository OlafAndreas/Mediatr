import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RequestHandlersMacro: MemberMacro {

	struct ArgumentExpression {
		let members: [ArgumentExpressionType: String]

		init(_ labelListSyntax: LabeledExprListSyntax) {
			var temp: [ArgumentExpressionType: String] = [:]
			labelListSyntax
				.compactMap({ $0.as(LabeledExprSyntax.self) })
				.forEach({ labeledExpression in
					let type = labeledExpression.label?.text ?? "UNKNOWN_TYPE"

					let memberReference = labeledExpression.expression
						.as(MemberAccessExprSyntax.self)

					let value = memberReference?.base?.as(DeclReferenceExprSyntax.self)?.baseName.text ?? memberReference?.declName.baseName.text

					temp.updateValue(value ?? "UNKNOWN_VALUE", forKey: ArgumentExpressionType(rawValue: type)!)
				})
			self.members = temp
		}

		var modifier: String {
			members[.modifier] ?? "internal"
		}

		var lifetime: String {
			members[.lifetime] ?? "transient"
		}

		func getRegisterFunctionCallSyntax() -> FunctionCallExprSyntax {
			return FunctionCallExprSyntax(
				calledExpression: DeclReferenceExprSyntax(
					baseName: .stringSegment("register")
				),
				leftParen: .leftParenToken(),
				arguments: LabeledExprListSyntax(arrayLiteral:
					LabeledExprSyntax(
						label: "handlerType",
						colon: .colonToken(),
						expression: MemberAccessExprSyntax(
							base: DeclReferenceExprSyntax(
								baseName: .stringSegment(members[.handlerType]!)
							),
							declName: DeclReferenceExprSyntax(
								baseName: .stringSegment("self")
							)
						),
						trailingComma: .commaToken()
					),
					LabeledExprSyntax(
						label: "lifetime",
						expression: MemberAccessExprSyntax(
							base: DeclReferenceExprSyntax(
								baseName: .stringSegment("Lifetime")
							),
							declName: DeclReferenceExprSyntax(
								baseName: .stringSegment(lifetime)
							)
						)
					)
				),
				rightParen: .rightParenToken()
			)
		}

		func getSendFunctionDeclSyntax() -> FunctionDeclSyntax {
			let requestType = members[.requestType] ?? "UNKNOWN_REQUEST_TYPE"
			let responseType = members[.responseType] ?? "UNKNOWN_RESPONSE_TYPE"
			let handlerType = members[.handlerType] ?? "UNKNOWN_HANDLER_TYPE"

			return FunctionDeclSyntax(
				modifiers: DeclModifierListSyntax(
					arrayLiteral: DeclModifierSyntax(
						name: .stringSegment(modifier),
						trailingTrivia: .space
					)
				),
				name: .stringSegment("send"),
				signature: FunctionSignatureSyntax(
					parameterClause: FunctionParameterClauseSyntax(
						parameters: FunctionParameterListSyntax([
							FunctionParameterSyntax(
								firstName: .stringSegment("request"),
								type: IdentifierTypeSyntax(
									name: .stringSegment(requestType)
								)
							)
						])
					),
					effectSpecifiers: FunctionEffectSpecifiersSyntax(
						asyncSpecifier: .stringSegment("async", trailingTrivia: .space),
						throwsSpecifier: .stringSegment("throws", trailingTrivia: .space)
					),
					returnClause: ReturnClauseSyntax(
						type: IdentifierTypeSyntax(
							name: .stringSegment(responseType, trailingTrivia: .space)
						)
					)
				),
				body: CodeBlockSyntax(
					statements: CodeBlockItemListSyntax([
						CodeBlockItemSyntax(stringLiteral: "let handler: \(handlerType) = getHandler()"),
						CodeBlockItemSyntax(stringLiteral: "return try await handler.handle(request: request)")
					])
				)
			)
		}
	}

	enum ArgumentExpressionType: String {
		case requestType
		case responseType
		case handlerType
		case lifetime
		case modifier
	}

	public static func expansion(
		of node: SwiftSyntax.AttributeSyntax,
		providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
		in context: some SwiftSyntaxMacros.MacroExpansionContext
	) throws -> [SwiftSyntax.DeclSyntax] {

		let elements = node.arguments!
			.as(LabeledExprListSyntax.self)!.first!
			.as(LabeledExprSyntax.self)!.expression
			.as(ArrayExprSyntax.self)!.elements

		var registerDeclarations: [CodeBlockItemSyntax] = [
			CodeBlockItemSyntax(
				stringLiteral: "self.handlers = handlers"
			)
		]
		var sendDeclarations: [DeclSyntax] = []

		elements.forEach { element in
			let labeledListSyntax = element.expression
				.as(FunctionCallExprSyntax.self)!.arguments
				.as(LabeledExprListSyntax.self)!

			let argumentExpression = ArgumentExpression(labeledListSyntax)

			let registerBlockItem = CodeBlockItemSyntax(item:
					.expr(
						ExprSyntax(argumentExpression.getRegisterFunctionCallSyntax())
					)
			)
			registerDeclarations.append(registerBlockItem)

			let sendDeclaration = DeclSyntax(argumentExpression.getSendFunctionDeclSyntax())
			sendDeclarations.append(sendDeclaration)
		}

		return [
			DeclSyntax(
				InitializerDeclSyntax(
					modifiers: DeclModifierListSyntax(
						arrayLiteral: DeclModifierSyntax(
							name: .stringSegment("public ")
						),
						DeclModifierSyntax(name: .stringSegment("required "))
					),
					signature: FunctionSignatureSyntax(
						parameterClause: FunctionParameterClauseSyntax(
							parameters: FunctionParameterListSyntax(
								arrayLiteral: FunctionParameterSyntax(
									stringLiteral: "handlers: [HandlerRegistration] = []"
								)
							)
						)
					),
					body: CodeBlockSyntax(
						statements: CodeBlockItemListSyntax(registerDeclarations)
					)
				)
			)
		] + sendDeclarations
	}
}

@main
struct MediatrPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
			RequestHandlersMacro.self,
			MediatrMacro.self
    ]
}
