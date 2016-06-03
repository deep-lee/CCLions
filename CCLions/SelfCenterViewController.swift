//
//  SelfCenterViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/5.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftyDrop

class SelfCenterViewController: UIViewController {
    var dataArray = ["个人信息", "公司信息"]
    var user: User!
    
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initView()
    }
    
    /**
     初始化界面
     */
    func initView() -> Void {
        self.user = Util.getLoginedUser()
        self.headerImageView.sd_setImageWithURL(NSURL(string: self.user.header)) { (image, error, cacheType, url) in
            self.headerImageView.image = image.imageWithCornerRadius(self.headerImageView.bounds.size.width / 2)
        }
        self.nameLabel.text = self.user.name
        
        // 判断当前用户的类型，如果当前不是狮子会会员，就不显示公司信息，显示身份认证状态
        if user.user_type == UserType.NonVip.rawValue {
            self.dataArray.removeLast()
            self.dataArray.append("身份认证")
        }
        self.mTableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(SelfCenterViewController.refresh))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
    }
    
    @IBAction func leftMenu(sender: AnyObject) {
        slideMenuController()?.toggleLeft()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func goToEditSelfProfileViewController() {
        print("前往个人资料")
        let editSelfProfileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditSelfProfileViewController") as! EditSelfProfileViewController
        self.navigationController?.pushViewController(editSelfProfileViewController, animated: true)
    }
    
    func checkCompanyInfo() {
        // 判断当前用户是否有已经添加了公司信息
        SVProgressHUD.showWithStatus(Tips.LOADING)
        let paras = [
            "user_id": Util.getLoginedUser()!.id
        ]
        Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_COMPANY_OF_USER.rawValue, parameters: paras)
            .responseJSON { (response) in
                if let value = response.result.value {
                    print(value)
                    let json = JSON(value)
                    let code = json["code"].intValue
                    if code == 200 { // 添加了公司信息
                        
                        let data = json["data"]
                        let company = Company(id: data["id"].intValue, user_id: data["user_id"].intValue, company_name: data["company_name"].stringValue, address_longitude: data["address_longitude"].stringValue, address_latitude: data["address_latitude"].stringValue, business_scope: data["business_scope"].stringValue, industry: data["industry"].intValue, show_photo: data["show_photo"].stringValue, introduction: data["introduction"].stringValue, contact: data["contact"].stringValue, create_time: data["create_time"].stringValue, update_time: data["update_time"].stringValue, company_logo: data["company_logo"].stringValue, hits: data["hits"].intValue)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.goToEditCompanyInfoVC(company)
                        })
                    } else if code == 201 {
                        let type = json["type"].intValue
                        if type == 102 { // 没有添加公司信息
                            dispatch_async(dispatch_get_main_queue(), {
                                self.goToAddCompanyInfoVC()
                            })
                        } else {
                            Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                        }
                    }
                } else {
                    Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                }
                
                SVProgressHUD.dismiss()
        }
    }
    
    func goToAddCompanyInfoVC() -> Void {
        let addCompanyViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AddCompanyViewController") as! AddCompanyViewController
        addCompanyViewController.title = "添加公司"
        self.navigationController?.pushViewController(addCompanyViewController, animated: true)
    }
    
    func goToEditCompanyInfoVC(company: Company) -> Void {
        let companyInfoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CompanyInfoViewController") as! CompanyInfoViewController
        companyInfoViewController.company = company
        self.navigationController?.pushViewController(companyInfoViewController, animated: true)
    }
    
    /**
     获取当前用户的身份认证状态
     
     - returns: <#return value description#>
     */
    func getUserAuthenticationType() -> String {
        var status: String!
        switch user.authentication_status {
        case UserAuthenticationStatus.NotAuthentication.rawValue:
            status = "未认证"
        case UserAuthenticationStatus.InAuthentication.rawValue:
            status = "认证中"
        case UserAuthenticationStatus.FailAuthentication.rawValue:
            status = "认证失败"
        case UserAuthenticationStatus.SuccessAuthentication.rawValue:
            status = "已通过认证"
        default:
            status = "Error"
        }
        return status
    }
    
    func goToAuthenVC() -> Void {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("AuthenticationVC")
        vc?.title = "身份认证"
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func refresh() -> Void {
        user = Util.getLoginedUser()
        self.headerImageView.sd_setImageWithURL(NSURL(string: self.user.header)) { (image, error, cacheType, url) in
            self.headerImageView.image = image.imageWithCornerRadius(self.headerImageView.bounds.size.width / 2)
        }
        self.nameLabel.text = user.name
        if user.user_type == UserType.NonVip.rawValue {
            let indexPath = NSIndexPath(forRow: 1, inSection: 0);
            let cell = mTableView.cellForRowAtIndexPath(indexPath)
            cell!.detailTextLabel?.text = getUserAuthenticationType()
        }
        
        mTableView.mj_header.state = MJRefreshState.Idle
    }
}

extension SelfCenterViewController: UITabBarDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SelfCenterCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = dataArray[indexPath.row]
        if indexPath.row == 1 && user.user_type == UserType.NonVip.rawValue {
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.detailTextLabel?.text = self.getUserAuthenticationType()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            self.goToEditSelfProfileViewController()
        case 1:
            if user.user_type == UserType.CCLionVip.rawValue {
                self.checkCompanyInfo()
            } else {
                self.goToAuthenVC()
            }
        default:
            return
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
