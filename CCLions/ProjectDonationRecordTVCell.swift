//
//  ProjectDonationRecordTVCell.swift
//  CCLions
//
//  Created by 李冬 on 6/7/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit

class ProjectDonationRecordTVCell: UITableViewCell {

	@IBOutlet var imageViewHeader: UIImageView!
	@IBOutlet var labelUserName: UILabel!
	@IBOutlet var labelDonarionAmount: UILabel!
	@IBOutlet var labelMoneyApplication: UILabel!
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}

    func setParas(donation: Donation) -> Void {
        self.imageViewHeader.sd_setImageWithURL(NSURL(string: donation.header!))
        self.labelUserName.text = donation.name
        self.labelDonarionAmount.text = "￥\(donation.amount!)"
        self.labelMoneyApplication.text = donation.application!.isEmpty ? "暂未使用" : donation.application
    }
}
