import Mediatr

public struct Ping: MediatrRequest {
	public typealias Response = Pong
	let message: String
}

public struct Pong {
	let message: String
}

public final class PingHandler: MediatrRequestHandler {

	public init() {}

	public func handle(request: Ping) async throws -> Ping.Response {
		return Pong(message: "Pong!")
	}
}

public struct EditUser: MediatrRequest {
	public typealias Response = EditUserResponse
	let email: String
}

public struct EditUserResponse {
	let success: Bool
}

public class EditUserHandler: MediatrRequestHandler {
	public required init() {}

	public func handle(request: EditUser) async throws -> EditUser.Response {
		return EditUser.Response(success: true)
	}
}

@mediatrMacro()
@requestHandlers([
	HandlerMapping(requestType: Ping.self, responseType: Pong.self, handlerType: PingHandler.self, lifetime: .singleton),
	HandlerMapping(requestType: EditUser.self, responseType: EditUserResponse.self, handlerType: EditUserHandler.self, lifetime: .transient)
])
public class MyMediatr: Mediatr {}

public final class FakeEditUserHandler: MediatrRequestHandler {
	public init() {}

	public func handle(request: EditUser) async throws -> EditUser.Response {
		return .init(success: true)
	}
}

class FakeMediar: MyMediatr {

	required init(handlers: [HandlerRegistration] = []) {
		super.init(handlers: [])
		register(handlerType: FakeEditUserHandler.self, lifetime: .singleton)
	}

	override func send(request: EditUser) async throws -> EditUserResponse {
		let handler: FakeEditUserHandler = getHandler()
		return try await handler.handle(request: request)
	}
}

let mediatr = MyMediatr()

mediatr.register(handlerType: PingHandler.self, lifetime: .singleton)
mediatr.register(handlerType: EditUserHandler.self, lifetime: .singleton)

Task {
	let ping = Ping(message: "Ping?")
	let pong = try await mediatr.send(request: ping)
	print(pong.message)

	let editUser = EditUser(email: "pew@gmail.com")
	let success = try await mediatr.send(request: editUser).success
	print(success)
}
