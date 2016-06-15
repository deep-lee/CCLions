//
//  WithdrawTVC.swift
//  CCLions
//
//  Created by 李冬 on 16/6/15.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyDrop

class WithdrawTVC: UITableViewController {
    
    var project: Project!
    var selectedPhotos: [UIImage] = [UIImage]()
    var model: WithdrawModel!

    @IBOutlet var labelProjectTitle: UILabel!
    @IBOutlet var labelWithdrawableAmount: UILabel!
    @IBOutlet var labelPhotos: UILabel!
    @IBOutlet var textFieldWithdrawAmount: UITextField!
    @IBOutlet var textFieldWithdrawApplication: UITextField!
    @IBOutlet var textFieldContact: UITextField!
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
        self.model = WithdrawModel.shareInstance()
        self.labelProjectTitle.text = project.title
        self.labelWithdrawableAmount.text = "¥\(project.has_raised_amount - project.withdraw_amount)"
        self.labelPhotos.text = "已选择0张照片"
    }
    
    func initNoti() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WithdrawTVC.withdrawUploadProveImagesSuccessNotiCallBack(_:)), name: WITHDRAW_UPLOAD_PROVE_IMAGES_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WithdrawTVC.addWithdrawSuccessNotiCallBack(_:)), name: ADD_WITHDRAW_SUCCESS, object: nil)
    }
    
    func withdrawUploadProveImagesSuccessNotiCallBack(noti: NSNotification) -> Void {
        let dic = noti.object as! NSDictionary
        let photoAddress = dic.objectForKey(WITHDRAW_IMAGES_ADDRESS) as! String
        let paras = getParas()
        paras.setValue(photoAddress, forKey: "prove")
        
        model.requestAddWithdraw(paras)
    }
    
    func addWithdrawSuccessNotiCallBack(noti: NSNotification) -> Void {
        Drop.down(Tips.ADD_WITHDRAW_SUCCESS, state: DropState.Success)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func getParas() -> NSDictionary {
        let paras = NSMutableDictionary()
        paras.setValue(Util.getLoginedUser()!.id, forKey: "user_id")
        paras.setValue(self.project.id, forKey: "project_id")
        paras.setValue(textFieldWithdrawAmount.text, forKey: "amount")
        paras.setValue(textFieldWithdrawApplication.text, forKey: "application")
        paras.setValue(textFieldContact.text, forKey: "contact")
        
        return paras
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkComplete() -> Bool {
        if textFieldWithdrawAmount.hasText() && textFieldWithdrawApplication.hasText() && textFieldContact.hasText() && self.selectedPhotos.count > 0 {
            return true
        }
        
        return false
    }
    
    @IBAction func commit(sender: AnyObject) {
        if !checkComplete() {
            Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
            return
        }
        
        // 判断是否有足够的余额
        if (project.has_raised_amount - project.withdraw_amount) < Int(textFieldWithdrawAmount.text!)! {
            Drop.down(Tips.WITHDRAW_NO_ENOUGH_MONEY, state: DropState.Warning)
            return
        }
        
        model.requestUploadProvePhotos(self.selectedPhotos)
        
    }
    
    func selectProvePhotos(row: Int) -> Void {
        let selectMultiPhotoCollectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SelectMultiPhotoCollectionViewController") as! SelectMultiPhotoCollectionViewController
        selectMultiPhotoCollectionViewController.title = "证明材料"
        selectMultiPhotoCollectionViewController.dataArray = self.selectedPhotos
        selectMultiPhotoCollectionViewController.setClosure(selectMultiPhotoCallBack)
        self.navigationController?.pushViewController(selectMultiPhotoCollectionViewController, animated: true)
    }
    
    func selectMultiPhotoCallBack(var dataArray: [UIImage]) -> Void {
        dataArray.removeLast()
        self.selectedPhotos = dataArray
        self.labelPhotos.text = "已选择\(self.selectedPhotos.count)张照片"
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 4 {
            self.selectProvePhotos(indexPath.row)
        }
    }
}
