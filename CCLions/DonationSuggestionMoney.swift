//
//  DonationSuggestionMoney.swift
//  CCLions
//
//  Created by 李冬 on 6/9/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation

class DonationSuggestionMoney: NSObject {
    var id: Int?
    var amount: Int?
    var create_time: String?
    
    init(id: Int?, amount: Int?, create_time: String?) {
        self.id = id
        self.amount = amount
        self.create_time = create_time
    }
}