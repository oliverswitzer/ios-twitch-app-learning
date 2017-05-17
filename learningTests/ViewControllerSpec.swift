//
//  ViewControllerSpec.swift
//  learning
//
//  Created by Pivotal on 5/17/17.
//  Copyright © 2017 Pivotal. All rights reserved.
//

import Quick
import Nimble
@testable import learning

class ViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: ViewController!
        var service: MockTwitchCollectorService!
        
        beforeEach {
            service = MockTwitchCollectorService()

            subject = ViewController(service: service)
            _ = subject.view
        }
        
        it("should load the view outlets") {
            expect(subject.tableView).toNot(beNil())
            expect(subject.channelTextField).toNot(beNil())
        }

        context("when the use enters a channel name and hits enter") {
            beforeEach {
                subject.channelTextField.text = "channelName"
                subject.channelTextField.simulateReturn()
            }

            it("should fetch emotes") {
                expect(service.numberOfEmotesCalls) == 1
                expect(service.channelName) == "channelName"
            }

            context("on success") {
                beforeEach {
                    let emotes = [
                            Emote(name: "Kappa", url: "url-string", count: 23),
                            Emote(name: "FeelsBadMan", url: "url-string-2", count: 1),
                            Emote(name: "FeelsGoodMan", url: "url-string-3", count: 12)
                    ]
                    service.successCallback?(emotes)
                }

                it("should display the emote names with counts in the table view") {
                    expect(subject.tableView.visibleCells).to(haveCount(3))
                    expect(subject.tableView.visibleCells[0].textLabel?.text) == "Kappa 23"
                    expect(subject.tableView.visibleCells[1].textLabel?.text) == "FeelsGoodMan 12"
                    expect(subject.tableView.visibleCells[2].textLabel?.text) == "FeelsBadMan 1"
                }
            }
        }
    }
}

fileprivate class MockTwitchCollectorService: TwitchCollectorService {
    var numberOfEmotesCalls: Int = 0
    var channelName: String?
    var successCallback: ((Array<Emote>) -> Void)?
    var errorCallback: ((Error) -> Void)?

    func emotes(channelName: String,
                success successCallback: @escaping (Array<Emote>) -> Void,
                error errorCallback: @escaping (Error) -> Void) {
        numberOfEmotesCalls += 1
        self.channelName = channelName
        self.successCallback = successCallback
        self.errorCallback = errorCallback
    }
}

extension UITextField {
    func simulateReturn() {
        _ = self.delegate?.textFieldShouldReturn?(self)
    }
}