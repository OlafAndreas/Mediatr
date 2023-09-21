//
//  PingRequestHandler.swift
//
//
//  Created by Olaf on 21/09/2023.
//

import Foundation
import Mediatr

struct PingRequestHandler: MediatrRequestHandler {

	func handle(request: PingRequest) async throws -> PingRequest.Response {
		return PingRequest.Response(message: "Pong!")
	}
}
