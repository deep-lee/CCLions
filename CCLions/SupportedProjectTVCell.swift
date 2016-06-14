//
//  SupportedProjectTVCell.swift
//  CCLions
//
//  Created by 李冬 on 6/14/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit

class SupportedProjectTVCell: UITableViewCell {

    @IBOutlet var labelLauncher: UILabel!
    @IBOutlet var labelFav: UILabel!
    @IBOutlet var imageViewShow: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelAmount: UILabel!
    @IBOutlet var labelApplication: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setParas(supportedProject: SupportedProject) -> Void {
        self.labelLauncher.text = supportedProject.name
        self.labelFav.text = "\(supportedProject.favorite)"
        self.imageViewShow.sd_setImageWithURL(NSURL(string: supportedProject.cover_image))
        self.imageViewShow.clipsToBounds = true
        self.labelTitle.text = supportedProject.title
        self.labelAmount.text = "¥\(supportedProject.amount)"
        self.labelApplication.text = supportedProject.application.isEmpty ? "暂未使用" : supportedProject.application
    }
    
}
