//
//  ExampleMediatr.swift
//
//
//  Created by Olaf on 21/09/2023.
//

import Foundation
import Mediatr

@mediatrMacro()
@requestHandlers([
	HandlerMapping(requestType: PingRequest.self, responseType: PingResponse.self, handlerType: PingRequestHandler.self, lifetime: .singleton),
	HandlerMapping(requestType: EditUserRequest.self, responseType: EditUserResponse.self, handlerType: EditUserRequestHandler.self, lifetime: .transient)
])
public class ExampleMediatr: Mediatr, ObservableObject {}


