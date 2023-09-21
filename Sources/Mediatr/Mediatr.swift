// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public enum Modifier: String {
	case `internal` = "internal"
	case override = "override"
}

public protocol MediatrRequest {
	associatedtype Response
}
public protocol MediatrRequestHandler {
	associatedtype Request: MediatrRequest
	init()
	func handle(request: Request) async throws -> Request.Response
}

public protocol Mediatr {
	init(handlers: [HandlerRegistration])
	var handlers: [HandlerRegistration] { get set }
	func register<T: MediatrRequestHandler>(handlerType: T.Type, lifetime: Lifetime)
}

public enum Lifetime {
	case transient
	case singleton
}

public struct HandlerRegistration {
	public let handlerType: any MediatrRequestHandler.Type
	public let lifetime: Lifetime
	public let instance: (any MediatrRequestHandler)?

	public init(handlerType: any MediatrRequestHandler.Type, lifetime: Lifetime, instance: (any MediatrRequestHandler)? = nil) {
		self.handlerType = handlerType
		self.lifetime = lifetime
		self.instance = instance
	}
}

public struct HandlerMapping {
	public let requestType: any MediatrRequest.Type
	public let responseType: Any.Type
	public let handlerType: any MediatrRequestHandler.Type
	public let lifetime: Lifetime
	public let modifier: Modifier

	public init(
		requestType: any MediatrRequest.Type,
		responseType: Any.Type,
		handlerType: any MediatrRequestHandler.Type,
		lifetime: Lifetime = .transient,
		modifier: Modifier = .internal
	) {
		self.requestType = requestType
		self.responseType = responseType
		self.handlerType = handlerType
		self.lifetime = lifetime
		self.modifier = modifier
	}
}

@attached(member, names: named(init(handlers:)), named(send(request:)))
public macro requestHandlers(_ mapping: [HandlerMapping]) = #externalMacro(module: "MediatrMacros", type: "RequestHandlersMacro")

@attached(member, names: named(init(handlers:)), named(handlers), named(getHandler()), named(register(handlerType:lifetime:)))
public macro mediatrMacro() = #externalMacro(module: "MediatrMacros", type: "MediatrMacro")
