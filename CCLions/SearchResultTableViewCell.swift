//
//  SearchResultTableViewCell.swift
//  CCLions
//
//  Created by 李冬 on 16/5/1.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
	@IBOutlet var compamyLogoImageView: UIImageView!
	@IBOutlet var companyNameLabel: UILabel!
	@IBOutlet var companyBusinessLabel: UILabel!
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}
}
