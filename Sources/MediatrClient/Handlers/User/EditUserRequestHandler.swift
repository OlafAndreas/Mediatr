//
//  EditUserRequestHandler.swift
//
//
//  Created by Olaf on 21/09/2023.
//

import Foundation
import Mediatr

struct EditUserRequestHandler: MediatrRequestHandler {

	public func handle(request: EditUserRequest) async throws -> EditUserRequest.Response {
		return EditUserRequest.Response(success: true)
	}
}
