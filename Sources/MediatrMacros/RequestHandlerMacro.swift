import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RequestHandlerMacro: ExtensionMacro {

	public static func expansion(
		of node: SwiftSyntax.AttributeSyntax,
		attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
		providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
		conformingTo protocols: [SwiftSyntax.TypeSyntax],
		in context: some SwiftSyntaxMacros.MacroExpansionContext
	) throws -> [SwiftSyntax.ExtensionDeclSyntax] {

		let tokens = node.arguments!.tokens(viewMode: .all).compactMap({ $0 })
		let inputType = tokens[0].text
		let outputType = tokens[4].text
		let handlerType = tokens[8].text

		return [
			ExtensionDeclSyntax(
				extendedType: type,
				memberBlock: MemberBlockSyntax(
					membersBuilder: {
						MemberBlockItemListSyntax(
							itemsBuilder: {
								MemberBlockItemSyntax(
									decl: FunctionDeclSyntax(
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
							}
						)
					}
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
