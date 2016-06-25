//
//  SlideViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/5.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyDrop
import SwiftyJSON

enum LeftMenu: Int {
	case Main = 0
	case CompanyMap
	// case AddActivity
	case SelfCenter
	case SearchCompany
	case Setting
}

protocol LeftMenuProtocol: class {
	func changeViewController(menu: LeftMenu)
}

class SlideViewController: UIViewController {
	var mainViewController: UIViewController!
	var selfCenterViewController: UIViewController!
	var addActivityViewController: UIViewController!
	var comppanyMapViewController: UIViewController!
	var companySearchViewController: UIViewController!
	var settingViewController: UIViewController!

	var dataArray: [(String, String)] = []
	var user: User!

	@IBOutlet weak var headerImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var buttonLogin: UIButton!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		initData()

		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		self.selfCenterViewController = storyboard.instantiateViewControllerWithIdentifier("SelfCenterViewControllerNvc")

		self.addActivityViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AddActivityNvc")
		self.comppanyMapViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CompanyMapViewControllerNvc")
		self.companySearchViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchCompanyViewControllerNvc")
		self.settingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SettingTableViewControllerNVC")

		self.updateUserInfo()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func initData() {
		dataArray.append(("icon-activity", "活动主页"))
		dataArray.append(("icon-global", "商家地图"))
		// dataArray.append(("icon-activity", "添加活动"))
		dataArray.append(("icon-selfcenter", "个人中心"))
		dataArray.append(("icon-searchcompany", "搜索企业"))
		dataArray.append(("icon-setting", "设置"))
//		dataArray.append(("icon-feedback", "反馈"))
//		dataArray.append(("icon-about", "关于"))
	}
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUserInfo()
    }
    
    /**
     更新用户信息
     */
    func updateUserInfo() -> Void {
        self.user = Util.getLoginedUser()
        if user != nil {
            self.headerImageView.hidden = false
            self.nameLabel.hidden = false
            self.buttonLogin.hidden = true
            self.headerImageView.sd_setImageWithURL(NSURL(string: self.user.header)) { (image, error, cacheType, url) in
                self.headerImageView.image = image.imageWithCornerRadius(self.headerImageView.bounds.size.width / 2)
            }
            self.nameLabel.text = self.user.name
        } else {
            self.headerImageView.hidden = true
            self.nameLabel.hidden = true
            self.buttonLogin.hidden = false
        }
    }

    @IBAction func loginAction(sender: AnyObject) {
        self.goToLoginVC()
    }
    
    func goToLoginVC() -> Void {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController")
        self.presentViewController(vc!, animated: true) {
        }
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

extension SlideViewController: UITableViewDelegate, UITableViewDataSource, LeftMenuProtocol {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataArray.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("SlideTableVIewCell", forIndexPath: indexPath)

		let iconImageView = cell.viewWithTag(1) as! UIImageView
		let detailsLabel = cell.viewWithTag(2) as! UILabel
		iconImageView.image = UIImage(named: dataArray[indexPath.row].0)
		detailsLabel.text = dataArray[indexPath.row].1

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		changeViewController(LeftMenu(rawValue: indexPath.row)!)
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	/**
	 检查用户是否有权限发起项目
	 */
	func checkLaunchProject() -> Void {
		// 判断当前用户是否有已经添加了公司信息
		SVProgressHUD.showWithStatus(Tips.LOADING)
        
        // 首先检查当前用户是否登录
        if !Util.hasUserLogined() {
            // 没有登录的话就进入到登录界面
            self.goToLoginVC()
        } else {
            // 如果当前有用户登录
            // 首先检查用户类型
            // 如果是普通用户，那么检查用户是否已经通过的身份认证
            let user = Util.getLoginedUser()
            if user?.user_type == UserType.NonVip.rawValue {
                // 如果是通过了认证的话，就进入添加项目界面
                if user?.authentication_status == UserAuthenticationStatus.SuccessAuthentication.rawValue {
                    self.slideMenuController()?.changeMainViewController(self.addActivityViewController, close: true)
                } else {
                    Drop.down(Tips.AUTHENTICATION_FIRST)
                }
            } else if user?.user_type == UserType.CCLionVip.rawValue {
                // 如果是狮子会会员
                // 首先判断用户是否绑定了公司
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
                                self.slideMenuController()?.changeMainViewController(self.addActivityViewController, close: true)
                            } else if code == 201 {
                                let type = json["type"].intValue
                                if type == 102 { // 没有添加公司信息
                                    Drop.down(Tips.ADD_PROJECT_NO_AUTHORIZATION, state: DropState.Error)
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
        }
        
		
	}
    
    /**
     检查点击个人中心
     */
    func checkSelfCenter() -> Void {
        // 判断当前用户是否登录了
        if !Util.hasUserLogined() {
            // 没有用户登录
            self.goToLoginVC()
        } else {
            self.slideMenuController()?.changeMainViewController(self.selfCenterViewController, close: true)
        }
    }

	/**
	 切换ViewController

	 - parameter menu: 切换的menu
	 */
	func changeViewController(menu: LeftMenu) {
		switch menu {
		case .Main:
			self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)

		case .SelfCenter:
			self.checkSelfCenter()
//
//		case .AddActivity:
//			self.checkLaunchProject()

		case .CompanyMap:
			self.slideMenuController()?.changeMainViewController(self.comppanyMapViewController, close: true)

		case .SearchCompany:
			self.slideMenuController()?.changeMainViewController(self.companySearchViewController, close: true)

		case .Setting:
			self.slideMenuController()?.changeMainViewController(self.settingViewController, close: true)
		}
	}
}
