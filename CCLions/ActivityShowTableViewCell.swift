//
//  ActivityShowTableViewCell.swift
//  CCLions
//
//  Created by Joseph on 16/4/10.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

class ActivityShowTableViewCell: UITableViewCell {

    // 封面展示照片
    @IBOutlet weak var showIamgeView: UIImageView!
    // 活动时间
    @IBOutlet weak var activityTimeLabel: UILabel!
    // 活动发起人
    @IBOutlet weak var activityLauncherLabel: UILabel!
    // 点赞数
    @IBOutlet weak var favLabel: UILabel!
    // 点赞照片，用于点击
    @IBOutlet weak var favImageView: UIImageView!
    // 评论照片，用于点击
    @IBOutlet weak var commentImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
