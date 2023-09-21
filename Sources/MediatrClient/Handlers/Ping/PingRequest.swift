//
//  PingRequest.swift
//
//
//  Created by Olaf on 21/09/2023.
//

import Foundation
import Mediatr

struct PingRequest: MediatrRequest {
	typealias Response = PingResponse
	let message: String
}
