//
//  Endpoint.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

typealias URLValues = [String: String]

struct Endpoint<T: Decodable> {
    private let host = "circleci.com"
    private let prefix = "/api/v1.1"
    private let scheme = "https"

    let httpMethod: HTTPMethod
    let url: URL
    
    static func cancel(build: Build) -> Endpoint<Build> {
        return Endpoint<Build>(httpMethod: .post, data: build, action: "cancel")
    }
    
    static func follow(project: Project) -> Endpoint<Project> {
        return Endpoint<Project>(httpMethod: .post, data: project, action: "follow")
    }
    
    static func get(build: Build) -> Endpoint<Build> {
        return Endpoint<Build>(httpMethod: .get, data: build)
    }
    
    static func artifacts(build: Build) -> Endpoint<[Artifact]> {
        return Endpoint<[Artifact]>(httpMethod: .get, data: build, action: "artifacts")
    }
    
    static var me: Endpoint<User> {
        return Endpoint<User>(httpMethod: .get, action: "me")
    }
    
    static var projects: Endpoint<[Project]> {
        return Endpoint<[Project]>(httpMethod: .get, action: "projects")
    }
    
    static func builds(project: Project, offset: Int = 0, limit: Int = 30) -> Endpoint<[Build]> {
        return Endpoint<[Build]>(
            httpMethod: .get,
            data: project,
            parameters: [ "limit": String(limit), "offset": String(offset) ])
    }
    
    static var recent: Endpoint<[Build]> {
        return recent(offset: 0)
    }
    
    static func recent(offset: Int, limit: Int = 30) -> Endpoint<[Build]> {
        return Endpoint<[Build]>(
            httpMethod: .get,
            action: "recent-builds",
            parameters: [ "limit": String(limit), "offset": String(offset) ])
    }
    
    static func retry(build: Build) -> Endpoint<Build> {
        return Endpoint<Build>(httpMethod: .post, data: build, action: "retry")
    }
    
    init(
        httpMethod: HTTPMethod,
        data: EndpointConvertable? = nil,
        action: String? = nil,
        parameters: URLValues? = nil) {
        var path = ""
        if let apiPath = data?.apiPath {
            path = apiPath
        }
        if let action = action {
            path += "/\(action)"
        }
        self.httpMethod = httpMethod
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = prefix + path
        if let parameters = parameters {
            components.queryItems = parameters.map {
                URLQueryItem(name: $0.0, value: $0.1)
            }
        }
        url = components.url!
    }

    func urlRequest(with token: String?) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = httpMethod.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if
            let token = token,
            let credential = "\(token):".data(using: .utf8)?.base64EncodedString() {
            req.setValue("Basic: \(credential)", forHTTPHeaderField: "Authorization")
        }
        return req
    }
}