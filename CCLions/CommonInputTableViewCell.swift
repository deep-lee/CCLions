//
//  CommonInputTableViewCell.swift
//  CCLions
//
//  Created by Joseph on 16/4/9.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

class CommonInputTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
