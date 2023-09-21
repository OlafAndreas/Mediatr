//
//  EditUserRequest.swift
//
//
//  Created by Olaf on 21/09/2023.
//

import Foundation
import Mediatr

public struct EditUserRequest: MediatrRequest {
	public typealias Response = EditUserResponse
	let email: String
}
