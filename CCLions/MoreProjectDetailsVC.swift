//
//  MoreProjectDetailsVC.swift
//  CCLions
//
//  Created by 李冬 on 6/3/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import Eureka

class MoreProjectDetailsVC: UIViewController {
    
    var moreProjectDetailsView: MoreProjectDetailsView?
    var project: Project?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initView()
    }
    
    func initView() -> Void {
        self.initWeight()
        moreProjectDetailsView = MoreProjectDetailsView(frame: self.view.frame)
        self.view.addSubview(moreProjectDetailsView!)
        moreProjectDetailsView?.setParas(self.project!)
    }
    
    func initWeight() -> Void {
        self.title = "更多信息"
    }
    
    func setParas(project: Project) -> Void {
        self.project = project
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
