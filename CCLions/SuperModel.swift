//
//  SuperModel.swift
//  CCLions
//
//  Created by Joseph on 16/5/20.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
class SuperModel: NSObject {
    func postNotification(name: String) -> Void {
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil);
    }
}
