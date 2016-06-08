//
//  ProjectShowTVCell.swift
//  CCLions
//
//  Created by 李冬 on 6/7/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import QuartzCore

class ProjectShowTVCell: UITableViewCell {

    @IBOutlet var imageViewShow: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelname: UILabel!
    @IBOutlet var labelFavNum: UILabel!
    
    var layerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setParas(project: Project) -> Void {
        self.imageViewShow.sd_setImageWithURL(NSURL(string: project.cover_image))
        self.imageViewShow.clipsToBounds = true
        self.labelTitle.text = project.title
        self.labelname.text = project.name
        self.labelFavNum.text = "\(project.favorite!)"
    }
}
