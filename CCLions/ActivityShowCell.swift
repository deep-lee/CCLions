//
//  ActivityShowCell.swift
//  CCLions
//
//  Created by Joseph on 16/5/12.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

class ActivityShowCell: UITableViewCell {
	@IBOutlet var _imageViewShow: UIImageView!
	@IBOutlet var _labelTime: UILabel!
	@IBOutlet var _labelLauncher: UILabel!
	@IBOutlet var _labelFavNum: UILabel!
	@IBOutlet var _labelCommentNum: UILabel!

	var _project: Project?

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}

	func setParas(project: Project) -> Void {
		_project = project
		// _imageViewShow.sd_setImageWithURL(NSURL(string: (_project?.cover_image)!))
	}

}
