import Mediatr
import SwiftUI

struct ExampleView: View {

	@EnvironmentObject var mediatr: ExampleMediatr

	var body: some View {
		Text("Hello, world")
	}
}

@requestHandlers([HandlerMapping(requestType: EditUserRequest.self, responseType: EditUserResponse.self, handlerType: FakeEditUserHandler.self, modifier: .override)])
class FakeMediatr: ExampleMediatr {}

public final class FakeEditUserHandler: MediatrRequestHandler {
	public init() {}

	public func handle(request: EditUserRequest) async throws -> EditUserRequest.Response {
		return .init(success: true)
	}
}

let mediatr: ExampleMediatr = ExampleMediatr()
