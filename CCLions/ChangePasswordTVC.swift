//
//  ChangePasswordTVC.swift
//  CCLions
//
//  Created by 李冬 on 16/6/16.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyDrop

class ChangePasswordTVC: UITableViewController {

    @IBOutlet var buttonVerCode: UIButton!
    @IBOutlet var textFieldVerCode: UITextField!
    @IBOutlet var labelPhone: UILabel!
    @IBOutlet var buttonSure: UIButton!
    @IBOutlet var textFieldNewPsw: UITextField!
    
    var user: User!
    var model: ChangePasswordModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        initView()
        initNoti()
    }
    
    func initView() -> Void {
        user = Util.getLoginedUser()
        model = ChangePasswordModel()
        buttonSure.layer.cornerRadius = 6
        buttonSure.layer.masksToBounds = true
        buttonVerCode.layer.cornerRadius = 5
        buttonVerCode.layer.masksToBounds = true
        labelPhone.text = user.username
    }
    
    func initNoti() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChangePasswordTVC.updatePswSuccessNotiCallBack(_:)), name: CHANGE_PASSWORD_SUCCESS, object: nil)
    }
    
    func updatePswSuccessNotiCallBack(noti: NSNotification) -> Void {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isCompleted() -> Bool {
        if textFieldNewPsw.hasText() && textFieldVerCode.hasText() {
            return true
        }
        
        return false
    }

    @IBAction func verCodeAction(sender: AnyObject) {
        model.getVerCode(user.username)
    }
    @IBAction func sureAction(sender: AnyObject) {
        if !isCompleted() {
            Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
            return
        }
        
        model.updatePsw(user.username, newPsw: textFieldNewPsw.text!, id: user.id, verCode: textFieldVerCode.text!)
    }

}
