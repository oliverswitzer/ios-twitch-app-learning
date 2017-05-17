//
// Created by Pivotal on 5/17/17.
// Copyright (c) 2017 Pivotal. All rights reserved.
//

import Foundation

protocol Dispatcher {
    func async(_ closure: @escaping () -> Swift.Void)
}

class MainDispatcher: Dispatcher {
    func async(_ closure: @escaping () -> Void) {
        DispatchQueue.main.async(execute: closure)
    }
}