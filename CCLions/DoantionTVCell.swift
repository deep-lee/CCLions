//
//  DoantionTVCell.swift
//  CCLions
//
//  Created by 李冬 on 6/9/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit

let DONATION_CELL_SUPPORT_BUTTON_CLICKED = "DONATION_CELL_SUPPORT_BUTTON_CLICKED"

let AMOUNT = "AMOUNT"

class DoantionTVCell: UITableViewCell {

    @IBOutlet var labelMoney: UILabel!
    @IBOutlet var buttonSupport: UIButton!
    
    var suggest: DonationSuggestionMoney?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setParas(suggest: DonationSuggestionMoney) -> Void {
        self.suggest = suggest
        self.labelMoney.text = "\(suggest.amount!)"
    }
    
    @IBAction func supportAction(sender: AnyObject) {
        let dic = NSMutableDictionary()
        dic.setValue(self.suggest?.amount, forKey: AMOUNT)
        NSNotificationCenter.defaultCenter().postNotificationName(DONATION_CELL_SUPPORT_BUTTON_CLICKED, object: dic, userInfo: nil)
    }
}
