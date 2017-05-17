//
//  TwitchCollectorService.swift
//  learning
//
//  Created by Pivotal on 5/16/17.
//  Copyright © 2017 Pivotal. All rights reserved.
//

import Foundation

protocol TwitchCollectorService {
    func emotes(channelName: String,
                success successCallback: @escaping (Array<Emote>) -> Void,
                error errorCallback: @escaping (Error) -> Void)
}

class TwitchCollectorServiceImpl: TwitchCollectorService {
    let urlSession: URLSessionProtocol
    let mainDispatcher: Dispatcher
    
    init(urlSession: URLSessionProtocol, mainDispatcher: Dispatcher) {
        self.urlSession = urlSession
        self.mainDispatcher = mainDispatcher
    }

    func emotes(channelName: String,
                success successCallback: @escaping (Array<Emote>) -> Void,
                error errorCallback: @escaping (Error) -> Void) {
        var host = "http://twitch.cfapps.io"
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("USE_LOCALHOST") {
            host = "http://localhost:8082"
        }
#endif
        self.urlSession.dataTask(with: URL(string: "\(host)/\(channelName)/emotes")!) { (data, response, error) in
                    if let unwrappedError = error {
                        self.mainDispatcher.async {
                            errorCallback(unwrappedError)
                        }
                        return
                    }

                    guard let unwrappedData = data,
                          let json = (try? JSONSerialization.jsonObject(with: unwrappedData)) as? Dictionary<String, Dictionary<String, Any>> else {
                        self.mainDispatcher.async {
                            errorCallback(TwitchCollectorError.unexpectedResponse)
                        }
                        return
                    }

                    let result = json.flatMap { (key: String, value: Dictionary<String, Any>) -> Emote? in
                        guard let url = value["url"] as? String,
                               let count = value["count"] as? Int else {
                            return nil
                        }

                        return Emote(name: key, url: url, count: count)
                    }
                    self.mainDispatcher.async {
                        successCallback(result)
                    }
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
