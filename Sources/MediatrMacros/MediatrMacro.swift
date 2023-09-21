import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MediatrMacro: MemberMacro {
	
	public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
		return [
			DeclSyntax(
				stringLiteral: "public var handlers: [HandlerRegistration] = []"
			),
			DeclSyntax(
				stringLiteral: "public init(handlers: [HandlerRegistration] = []) { self.handlers = handlers }"
			),
			DeclSyntax(
				getHandlerSyntax()
			),
			DeclSyntax(
				getRegisterSyntax()
			)
		]
	}

	private static func getRegisterSyntax() -> FunctionDeclSyntax {
		return FunctionDeclSyntax(
			name: .stringSegment("register"),
			genericParameterClause: GenericParameterClauseSyntax(
			 stringLiteral: "<T: MediatrRequestHandler>"
			),
			signature: FunctionSignatureSyntax(
			 parameterClause: FunctionParameterClauseSyntax(
				 parameters: FunctionParameterListSyntax([
					 FunctionParameterSyntax(
						 stringLiteral: "handlerType: T.Type, lifetime: Lifetime"
					 )
				 ])
			 )
			),
			body: CodeBlockSyntax(
			 statements: CodeBlockItemListSyntax([
				 CodeBlockItemSyntax(stringLiteral: registerBody)
			 ])
			)
		)
	}

	private static func getHandlerSyntax() -> FunctionDeclSyntax {
		return FunctionDeclSyntax(
			name: .stringSegment("getHandler"),
			genericParameterClause: GenericParameterClauseSyntax(
				stringLiteral: "<T: MediatrRequestHandler>"
			),
			signature: FunctionSignatureSyntax(
				parameterClause: FunctionParameterClauseSyntax(
					parameters: FunctionParameterListSyntax([])
				),
				returnClause: ReturnClauseSyntax(
					type: IdentifierTypeSyntax(
						name: .stringSegment("T", trailingTrivia: .space)
					)
				)
			),
			body: CodeBlockSyntax(
				statements: CodeBlockItemListSyntax([
					CodeBlockItemSyntax(stringLiteral: getHandlerBody)
				])
			)
		)
	}

	private static let registerBody = """
 let registration = HandlerRegistration(handlerType: handlerType, lifetime: lifetime)
 self.handlers.append(registration)
 """

	private static let getHandlerBody = """
		guard let index = handlers.firstIndex(where: { $0.handlerType is T.Type }) else {
			fatalError()
		}

		let registration = handlers[index]

		switch registration.lifetime {
		case .transient:
			return registration.handlerType.init() as! T
		case .singleton:
			if let instance = registration.instance {
				return instance as! T
			}

			let newInstance = registration.handlerType.init()

			let newRegistration = HandlerRegistration(
				handlerType: registration.handlerType,
				lifetime: registration.lifetime,
				instance: newInstance
			)

			handlers[index] = newRegistration

			return newInstance as! T
		}
"""
}
