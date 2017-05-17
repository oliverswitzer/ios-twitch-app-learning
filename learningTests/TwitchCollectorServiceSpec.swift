//
//  TwitchCollectorServiceSpec.swift
//  learning
//
//  Created by Pivotal on 5/16/17.
//  Copyright © 2017 Pivotal. All rights reserved.
//

import Quick
import Nimble

@testable import learning

class TwitchCollectorServiceSpec: QuickSpec {
    override func spec() {
        var subject: TwitchCollectorService!
        var urlSession: MockUrlSession!
        
        beforeEach {
            urlSession = MockUrlSession()
            
            subject = TwitchCollectorService(urlSession: urlSession)
        }
        
        describe("emotes") {
            var emotesReceived: Array<Emote>?
            var errorReceived: Error?
            
            beforeEach {
                urlSession.dataTaskToReturn = MockDataTask()
                
                subject.emotes(channelName: "channelName",
                               success: { (emotes: Array<Emote>) in
                                emotesReceived = emotes
                },
                               error: { (error: Error) in
                                errorReceived = error
                })
            }
            
            it("should make a GET request to channelName/emotes") {
                expect(urlSession.numberOfDataTaskCalls).to(equal(1))
                expect(urlSession.url).to(equal(URL(string: "http://twitch.cfapps.io/channelName/emotes")!))
                expect(urlSession.dataTaskToReturn?.numberOfResumeCalls).to(equal(1))
            }
            
            context("on success") {
                beforeEach {
                    urlSession.completionHandler!(CannedResponseUtil.getJsonData(fromFile: "emotes"), HTTPURLResponse(url: URL(string: "http://twitch.cfapps.io/channelName/emotes")!, statusCode: 200, httpVersion: "2.2", headerFields: [:]), nil)
                }

                it("should return the emotes") {
                    expect(emotesReceived).to(contain(Emote(name: "PogChamp", url: "https://static-cdn.jtvnw.net/emoticons/v1/88/3.0", count: 12)))
                    expect(emotesReceived).to(contain(Emote(name: "Kappa", url: "https://static-cdn.jtvnw.net/emoticons/v1/25/3.0", count: 11)))
                    expect(emotesReceived).to(contain(Emote(name: "NotLikeThis", url: "https://static-cdn.jtvnw.net/emoticons/v1/58765/3.0", count: 2)))
                }
            }

            context("on error") {
                beforeEach {
                    urlSession.completionHandler!(nil, nil, TestError.genericError)
                }

                it("returns the error from UrlSession") {
                    expect(errorReceived).to(matchError(TestError.genericError))
                }
            }

            context("when data is nil") {
                beforeEach {
                    urlSession.completionHandler!(nil, nil, nil)
                }

                it("returns unexpected response error") {
                    expect(errorReceived).to(matchError(TwitchCollectorError.unexpectedResponse))
                }
            }

            context("when data is not in expected format") {
                beforeEach {
                    urlSession.completionHandler!("I am not JSON".data(using: .utf8), nil, nil)
                }

                it("returns unexpected response error") {
                    expect(errorReceived).to(matchError(TwitchCollectorError.unexpectedResponse))
                }
            }
        }
    }
}

enum TestError: Error {
    case genericError
}

class MockUrlSession: URLSessionProtocol {
    var url: URL?
    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    var numberOfDataTaskCalls = 0
    
    var dataTaskToReturn: MockDataTask?
    
    public func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        self.url = url
        self.completionHandler = completionHandler
        self.numberOfDataTaskCalls += 1
        
        return dataTaskToReturn!
    }
}

class MockDataTask: URLSessionDataTaskProtocol {
    var numberOfResumeCalls = 0
    
    func resume() {
        numberOfResumeCalls += 1
    }
}
