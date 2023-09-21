# Mediatr.swift

This is a simple POC to examine what we might achieve by using [Swift Macros](https://developer.apple.com/documentation/swift/macros), this package will provide a simple implementation of a Mediatr which requires *almost* no boilerplate code from your part.

### @mediatrMacro()
This macro will make sure to add some of the required code to your mediatr type. This macro should be placed on your base meditr type, especially if you're using a class and you're thinking about inheriting from the base class to create a fake mediatr for example.
[See code](https://github.com/OlafAndreas/Mediatr/blob/main/Sources/MediatrMacros/MediatrMacro.swift)

### @requestHandlers( ... )
This will do some magic for you, it will make sure to create code that will register(runtime) any handlers you define within this macro. It will also create concrete implementations of the `send(request:)` function for each of your Requset/Response/Handler mappings. This macro can be used on your base class, but also on any other classes you'll use to extend the base class. Handy to override any previously added `send(request:)` functions in your base class.
[See code](https://github.com/OlafAndreas/Mediatr/blob/main/Sources/MediatrMacros/RequestHandlerMacro.swift)

## Installation

#### SPM - main branch
Just add `https://github.com/OlafAndreas/Mediatr` to your *Project -> Package Dependencies* or Package.swift as a dependency.
There is currently no release, just use main branch for testing for now :)


## Example usage

The current implementation of the Mediatr only supports simple request/response handling, you should have some sort of `Request -> Response` models defined. I'm usin `Ping -> Pong` as an example, which can be seen in the [MediatrClient folder](https://github.com/OlafAndreas/Mediatr/tree/main/Sources/MediatrClient) in this repository.

Simplest form
```swift
struct Ping: MediatrRequest {
	typealias Response = Pong
	let message: String
}

struct Pong: {
	let message: String
}

struct PingHandler: MediatrRequestHandler {
	func handle(request: Ping) async throws -> Ping.Response {
		return Ping.Response(message: "Pong")
	}
}

@mediatrMacro()
@requestHandlers([
	HandlerMapping(
		requestType: PingRequest.self, 
		responseType: PingResponse.self, 
		handlerType: PingRequestHandler.self, 
		lifetime: .singleton
	)
])
class MyMediatr: Mediatr {}

let mediatr = MyMediatr()

Task { @MainActor in
	let pong = try await mediatr.send(request: Ping(message: "Ping?"))
	print(pong.message) // Pong!
}

// Faking the mediatr / handler

struct FakePingHandler: MediatrRequestHandler {
	func handle(request: Ping) async throws -> Ping.Response {
		throw NSError(domain: "my-error-domain", code: 42)
	}
}

@requestHandlers([
	HandlerMapping(
		requestType: PingRequest.self, 
		responseType: PingResponse.self, 
		handlerType: FakePingRequestHandler.self, 
		lifetime: .singleton,
		modifier: .override
	)
])
class FakeMediatr: MyMediatr {}

let mediatr: MyMediatr = FakeMediatr()

Task { @MainActor in
	do {
		let pong = try await mediatr.send(request: Ping(message: "Ping?"))
	} catch {
		print(error.localizedDescription) // The operation couldn’t be completed. (my-error-domain error 42.)
	}
}
```
----
#### Disclaimer
Since this project is a POC-WIP-Experiment, I would never recommend anyone using this code in production. **Do not use this in production**.
