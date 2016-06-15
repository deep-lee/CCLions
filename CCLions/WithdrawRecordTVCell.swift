//
//  WithdrawRecordTVCell.swift
//  CCLions
//
//  Created by 李冬 on 16/6/15.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

class WithdrawRecordTVCell: UITableViewCell {

    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelMoney: UILabel!
    @IBOutlet var labelWithdrawApplication: UILabel!
    @IBOutlet var labelWithdrawStatus: UILabel!
    @IBOutlet var labelFeedBack: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setParas(withdraw: WithdrawSelf) -> Void {
        self.labelTitle.text = withdraw.title
        self.labelMoney.text = "\(withdraw.amount)"
        self.labelWithdrawApplication.text = withdraw.application
        self.labelWithdrawStatus.text = Util.getWithdrawStatusString(withdraw.status!)
        self.labelFeedBack.text = withdraw.message!.isEmpty ? "暂无消息" : withdraw.message!
    }
    
}
