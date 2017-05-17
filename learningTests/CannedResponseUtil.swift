//
// Created by Pivotal on 5/16/17.
// Copyright (c) 2017 Pivotal. All rights reserved.
//

import Foundation

class CannedResponseUtil {
    class func getJsonData(fromFile path: String) -> Data {
        guard let url = Bundle(for: self).url(forResource: path, withExtension: "json") else {
            fatalError("path to file invalid")
        }
        return try! Data(contentsOf:url)
    }
}
