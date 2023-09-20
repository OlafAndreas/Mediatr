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

public final class EditUserHandler: MediatrRequestHandler {
	public init() {}

	public func handle(request: EditUser) async throws -> EditUser.Response {
		return EditUser.Response(success: true)
	}
}

@mediatrMacro()
@requestHandler(Ping.self, Pong.self, PingHandler.self)
@requestHandler(EditUser.self, EditUserResponse.self, EditUserHandler.self)
public class MyMediatr: Mediatr {
	public var handlers: [HandlerRegistration] = []
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
