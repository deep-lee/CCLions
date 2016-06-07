//
//  ProjectCommentRecordTVCell.swift
//  CCLions
//
//  Created by 李冬 on 6/7/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit

class ProjectCommentRecordTVCell: UITableViewCell {

    @IBOutlet var imageViewShow: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var labelContent: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setParas(comment: Comment) -> Void {
        self.imageViewShow.sd_setImageWithURL(NSURL(string: comment.header!))
        self.labelName.text = comment.name
        self.labelTime.text = Util.getTimeFromString(comment.create_time!)
        self.labelContent.text = comment.content
    }
}
