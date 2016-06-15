//
//  LaunchedProjectTVCell.swift
//  CCLions
//
//  Created by 李冬 on 16/6/15.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

protocol LaunchedProjectTVCellDelegate {
    func withdrawAction(project: Project)
}

class LaunchedProjectTVCell: UITableViewCell {

    @IBOutlet var labelLauncher: UILabel!
    @IBOutlet var labelFav: UILabel!
    @IBOutlet var imageViewShow: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelHasRaisedAmount: UILabel!
    @IBOutlet var labelWithdrawableAmount: UILabel!
    
    var project: Project!
    var delegate: LaunchedProjectTVCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func withdrawAction(sender: AnyObject) {
        delegate.withdrawAction(self.project)
    }
    
    func setParas(project: Project) -> Void {
        self.project = project
        self.imageViewShow.sd_setImageWithURL(NSURL(string: project.cover_image))
        self.imageViewShow.clipsToBounds = true
        self.labelTitle.text = project.title
        self.labelLauncher.text = project.name
        self.labelFav.text = "\(project.favorite!)"
        self.labelHasRaisedAmount.text = "已募集金额：¥\(project.has_raised_amount)"
        self.labelWithdrawableAmount.text = "可提款金额：¥\(project.has_raised_amount - project.withdraw_amount)"
    }
}
