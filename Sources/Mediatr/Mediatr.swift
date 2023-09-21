// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public enum BehaviorType: String {
	case none = ""
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
	var handlers: [HandlerRegistration] { get set }
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

@attached(member, names: named(init(handlers:)), named(handlers), named(getHandler()), named(register(handlerType:lifetime:)))
public macro mediatrMacro() = #externalMacro(module: "MediatrMacros", type: "MediatrMacro")

@attached(member, names: named(send(request:)))
public macro requestHandler<Request, Response, Handler>(_ requestType: Request.Type, _ responseType: Response.Type, _ handlerType: Handler.Type, _ behaviorType: BehaviorType = .none) = #externalMacro(module: "MediatrMacros", type: "RequestHandlerMacro")
