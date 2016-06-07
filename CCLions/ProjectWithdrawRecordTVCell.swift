//
//  ProjectWithdrawRecordTVCell.swift
//  CCLions
//
//  Created by 李冬 on 6/7/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit

class ProjectWithdrawRecordTVCell: UITableViewCell {

    @IBOutlet var imageViewShow: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelMoneyAmount: UILabel!
    @IBOutlet var labelApplication: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setParas(withdraw: Withdraw) -> Void {
        self.imageViewShow.sd_setImageWithURL(NSURL(string: withdraw.header!))
        self.labelName.text = withdraw.name
        self.labelMoneyAmount.text = "￥\(withdraw.amount!)"
        self.labelApplication.text = withdraw.application
    }

}
