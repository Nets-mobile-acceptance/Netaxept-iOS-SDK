//  MIT License
//
//  Copyright (c) 2019 Lukas Dagne
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

public typealias DataTaskResponse = (data: Data?, urlResponse: URLResponse?, error: Error?)

/// Properties required for JSON decoding.
public protocol JSONDecodeDelegate {
    var jsonDecoder: JSONDecoder { get }
    var decodeQueue: DispatchQueue { get }
    var callbackQueue: DispatchQueue { get }
}

/// Abstract error type of `URLSession` `dataTask` operation. Initializable from
/// bad request (failing to encode/decode) and bad response (e.g. error status code).
///
/// JSON fetch operation requires this error type to support generic decoding with
/// _custom_ error types. Use `AnyFetchError` for non-custom error type.
///
public protocol DataTaskError: Error {
    /// Return the error case associated with `badRequest` common error type.
    /// The error type `BadRequest` is consisted of common error cases
    /// e.g. encode/decode error
    /// - Parameter badRequest: Instance of `BadRequest` common error type
    /// - Parameter rawResponse: Raw response (if any) typically for logging
    init(badRequest: BadRequest, rawResponse: DataTaskResponse?)
    
    /// Return the error evaluated from given response.
    /// Return `nil` if the response represents success.
    /// - Parameter rawResponse: The raw data task response
    init?(from rawResponse: DataTaskResponse)

    /// Return presentable error description. 
    var errorMessage: String { get }
}

// MARK: - URLSession

public extension URLSession {
    /// Fetch JSON executing given `request`. Set `shouldRetainDecoder` to **true**
    /// if the session should keep decoder and operation queues in memory. Default is **false**,
    /// i.e. response is ignored if the _delegate_ is deallocated at network callback.
    ///
    func fetchJson<Response: Decodable, Error: DataTaskError>(
        with request: URLRequest,
        decodeDelegate delegate: JSONDecodeDelegate,
        shouldRetainDecoder: Bool = false,
        callback _callback: @escaping (Result<Response, Error>) -> Void) {
        
        weak var jsonDecoder = delegate.jsonDecoder
        weak var decodeQueue = delegate.decodeQueue
        weak var callbackQueue = delegate.callbackQueue

        /// Retain decode properties accordingly
        var retained: (decoder: JSONDecoder?, DispatchQueue?, DispatchQueue?)
        if shouldRetainDecoder {
            retained = (delegate.jsonDecoder, delegate.decodeQueue, delegate.callbackQueue)
        }

        let callback: (Result<Response, Error>) -> Void = { result in
            callbackQueue?.async { _callback(result) }
        }

        dataTask(with: request) {
            let response = ($0, $1, $2)
            decodeQueue?.async {
                let decoder = retained.decoder ?? jsonDecoder
                decoder?.decode(response, callback: callback)
            }
        }.resume()
    }
    
    /// Make the given `request` and callback (with error if any)
    /// Use `fetchJson` instead if JSON response is expected.
    ///
    func makeRequest<Error: DataTaskError>(
        _ request: URLRequest,
        callbackQueue: DispatchQueue,
        callback: @escaping (Error?) -> Void) {

        dataTask(with: request) {
            let response = ($0, $1, $2)
            callbackQueue.async {
                let error = Error(from: response)
                if let error = error {
                    errorLog(.urlSession, error.errorMessage)
                }
                callback(error)
            }
        }.resume()
    }
}

// MARK: - JSONDecoder

public extension JSONDecoder {
    func decode<Response: Decodable, Error: DataTaskError>(
        _ response: DataTaskResponse,
        callback: @escaping (Result<Response, Error>) -> Void) {

        if let error = Error(from: response) {
            errorLog(.urlSession, error.errorMessage)
            callback(.failure(error))
            return
        }

        guard let json = response.data else {
            let error = Error(badRequest: .noData, rawResponse: response)
            errorLog(.urlSession, error.errorMessage)
            callback(.failure(error))
            return
        }

        do {
            let decoded = try decode(Response.self, from: json)
            callback(.success(decoded))
        } catch let error {
            let decodeError = Error(badRequest: .decode(error), rawResponse: response)
            errorLog(.jsonDecoder, "\(error)")
            callback(.failure(decodeError))
        }
    }
}

// MARK: - HTTP Methods

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Network Error

/// Unmatching coding types or network issues
public enum BadRequest: Error, CustomStringConvertible {
    case encode(Error)
    case decode(Error)
    case noData
    case noURLResponse(Error?)

    public var description: String {
        guard case BadRequest.noURLResponse(let error) = self else {
            return localizedDescription
        }
        return error?.localizedDescription ?? localizedDescription
    }
}

// MARK: Helpers

extension URLRequest {
    init(for url: URL, method: HTTPMethod, headers: [String : String]) {
        self.init(url: url)
        httpMethod = method.rawValue
        headers.forEach { key, value in
            setValue(value, forHTTPHeaderField: key)
        }
    }
}

public extension URL {
    func appending(path: String) -> URL? {
        var path = path
        if path.first == "/" { path.removeFirst() }
        guard let url = URL(string: path, relativeTo: self) else {
            return nil
        }
        return url
    }
}

public extension DataTaskError {
    static func describe(_ rawResponse: DataTaskResponse?) -> String {
        guard let rawResponse = rawResponse else { return "none" }
        var description: String = ""
        description += "\n\n-- error: \(rawResponse.error?.localizedDescription ?? "…")"
        description += "\n\n-- data: \(rawResponse.data == nil ? "…" : rawResponse.data!.htmlString ?? " -- data-unknown -\n \(rawResponse.data!)")"
        description += "\n\n-- urlResponse: \(rawResponse.urlResponse?.description ?? "…")"
        return description
    }
}

public extension Data {
    var htmlString: String? {
        do {
            return try NSAttributedString(data: self, options: [
                .documentType : NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ], documentAttributes: nil).string
        } catch _ {
            return String(data: self, encoding: .utf8)
        }
    }
}

// MARK: Common Error Type

/// Any data-fetch failure (bad request or error status code: ~= 200...299).
/// Use custom error types with more specific cases for better error handling.
///
public enum AnyFetchError: DataTaskError, CustomStringConvertible {
    case badRequest(BadRequest)
    case statusCode(Int, rawResponse: DataTaskResponse)

    // MARK: DataTaskError

    public init(badRequest: BadRequest, rawResponse: DataTaskResponse?) {
        self = .badRequest(badRequest)
    }

    public init?(from rawResponse: DataTaskResponse) {
        guard let urlResponse = rawResponse.urlResponse as? HTTPURLResponse else {
            self = .badRequest(.noURLResponse(rawResponse.error))
            return
        }
        guard 200...299 ~= urlResponse.statusCode else {
            self = .statusCode(urlResponse.statusCode, rawResponse: rawResponse)
            return
        }
        return nil
    }

    public var errorMessage: String {
        switch self {
        case .badRequest(let error):
            return error.description
        case let .statusCode(code, rawResponse: response):
            return (response.data?.htmlString ?? "\(code) \(response.error?.localizedDescription ?? "(no message)")")
        }
    }

    public var description: String {
        return errorMessage
    }
}

// MARK: Logging

import os.log

@available(iOS 10.0, *)
public extension OSLog {
    static let urlSession = OSLog(subsystem: "com.urlSession", category: "URLSession")
    static let jsonDecoder = OSLog(subsystem: "com.jsonDecoder", category: "JSONDecoder")
}

public enum Log {
    case urlSession, jsonDecoder

    @available(iOS 10.0, *)
    var osLog: OSLog {
        switch self {
        case .urlSession: return OSLog(subsystem: "com.urlSession", category: "URLSession")
        case .jsonDecoder: return OSLog(subsystem: "com.jsonDecoder", category: "JSONDecoder")
        }
    }
}

@inline(__always) public func debugLog(_ log: Log, _ message: String) {
    if #available(iOS 10.0, *) {
        os_log("%{public}s", log: log.osLog, type: .debug, "✅ \(message)")
    }
}

@inline(__always) public func errorLog(_ log: Log, _ message: String) {
    if #available(iOS 10.0, *) {
        os_log("%{public}s", log: log.osLog, type: .error, "❌ \(message)\n\n")
    }
}
