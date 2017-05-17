//
//  TwitchCollectorService.swift
//  learning
//
//  Created by Pivotal on 5/16/17.
//  Copyright © 2017 Pivotal. All rights reserved.
//

import Foundation

internal class TwitchCollectorService {
    let urlSession: URLSessionProtocol
    
    init(urlSession: URLSessionProtocol) {
        self.urlSession = urlSession
    }

    func emotes(channelName: String, success successCallback: @escaping (Array<Emote>) -> Void, error errorCallback: @escaping (Error) -> Void) {
        self.urlSession.dataTask(with: URL(string: "http://twitch.cfapps.io/channelName/emotes")!) { (data, response, error) in
                    if let unwrappedError = error {
                        errorCallback(unwrappedError)
                        return
                    }

                    guard let unwrappedData = data,
                          let json = (try? JSONSerialization.jsonObject(with: unwrappedData)) as? Dictionary<String, Dictionary<String, Any>> else {
                        errorCallback(TwitchCollectorError.unexpectedResponse)
                        return
                    }

                    let result = json.flatMap { (key: String, value: Dictionary<String, Any>) -> Emote? in
                        guard let url = value["url"] as? String,
                               let count = value["count"] as? Int else {
                            return nil
                        }

                        return Emote(name: key, url: url, count: count)
                    }
                    successCallback(result)
                }
                .resume()
    }
}

enum TwitchCollectorError: Error {
    case unexpectedResponse
}

struct Emote: Equatable {
    var name: String
    var url: String
    var count: Int

    public static func ==(lhs: Emote, rhs: Emote) -> Bool {
        return lhs.name == rhs.name && lhs.url == rhs.url && lhs.count == rhs.count
    }
}
