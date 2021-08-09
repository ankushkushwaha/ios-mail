//
//  Session.swift
//  ProtonCore-Networking - Created on 6/24/21.
//
//  Copyright (c) 2021 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import TrustKit

public typealias ResponseCompletion = (_ task: URLSessionDataTask?, _ response: Any?, _ error: NSError?) -> Void
public typealias DownloadCompletion = (_ response: URLResponse?, _ url: URL?, _ error: NSError?) -> Void

public protocol Session {
    func generate(with method: HTTPMethod, urlString: String, parameters: Any?) throws -> SessionRequest
    
    func request(with request: SessionRequest, completion: @escaping ResponseCompletion) throws
    
    func upload(with request: SessionRequest,
                keyPacket: Data, dataPacket: Data, signature: Data?,
                completion: @escaping ResponseCompletion) throws
    
    func download(with request: SessionRequest,
                  destinationDirectoryURL: URL,
                  completion: @escaping DownloadCompletion) throws
    
    func setChallenge(noTrustKit: Bool, trustKit: TrustKit?)
}

extension Session {
    public func generate(with method: HTTPMethod, urlString: String, parameters: Any? = nil) throws -> SessionRequest {
        return SessionRequest.init(parameters: parameters,
                                   urlString: urlString,
                                   method: method)
    }
}

public class SessionRequest {
    public init(parameters: Any?, urlString: String, method: HTTPMethod) {
        self.parameters = parameters
        self.method = method
        self.urlString = urlString
    }
    public var request: URLRequest?
    let parameters: Any?
    let urlString: String
    let method: HTTPMethod
    
    private var headers: [String: String] = [:]
    public func setValue(header: String, _ value: String?) {
        self.headers[header] = value
    }
    // must call after the request be set
    public func updateHeader() {
        for (header, value) in self.headers {
            self.request?.setValue(value, forHTTPHeaderField: header)
        }
    }
}