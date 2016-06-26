//
//  UIViewController+Extension.swift
//  CCLions
//
//  Created by 李冬 on 6/8/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation

extension UIViewController {
    func goToProjectDetailsVC(project: Project, image: UIImage) -> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateViewControllerWithIdentifier("ProjectDetailsViewController") as! ProjectDetailsViewController
        vc.project = project
        vc.cover_image = image
        self.navigationController?.pushViewController(vc, animated: true)
    }
}