import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RequestHandlerMacro: MemberMacro {
	
	public static func expansion(
		of node: SwiftSyntax.AttributeSyntax,
		providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
		in context: some SwiftSyntaxMacros.MacroExpansionContext
	) throws -> [SwiftSyntax.DeclSyntax] {

		let tokens = node.arguments!.tokens(viewMode: .all).compactMap({ $0 })
		let inputType = tokens[0].text
		let outputType = tokens[4].text
		let handlerType = tokens[8].text
		let behaviorType: String
		if tokens.count >= 15 {
			 behaviorType = tokens[14].text
		} else {
			behaviorType = ""
		}

		return [
			DeclSyntax(
				FunctionDeclSyntax(
					modifiers: DeclModifierListSyntax(
						arrayLiteral: DeclModifierSyntax(
							name: .stringSegment(behaviorType),
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
										name: .stringSegment(inputType)
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
								name: .stringSegment(outputType, trailingTrivia: .space)
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
			)
		]
	}
}

@main
struct MediatrPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
			RequestHandlerMacro.self,
			MediatrMacro.self
    ]
}
