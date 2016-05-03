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
	case AddActivity
	case SelfCenter
	case SearchCompany
	case Setting
	case Feedback
	case About
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

	var dataArray: [(String, String)] = []
    var user: User!

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		initData()

		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		self.selfCenterViewController = storyboard.instantiateViewControllerWithIdentifier("SelfCenterViewControllerNvc")

		self.addActivityViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AddActivityNvc")
        self.comppanyMapViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CompanyMapViewControllerNvc")
        self.companySearchViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchCompanyViewControllerNvc")
        
        self.user = Util.getLoginedUser()
        self.headerImageView.sd_setImageWithURL(NSURL(string: self.user.header), placeholderImage: UIImage(named: "icon-default-header"))
        self.nameLabel.text = self.user.name
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func initData() {
		dataArray.append(("icon-activity", "活动主页"))
		dataArray.append(("icon-global", "商家地图"))
		dataArray.append(("icon-activity", "添加活动"))
		dataArray.append(("icon-selfcenter", "个人中心"))
		dataArray.append(("icon-searchcompany", "搜索企业"))
		dataArray.append(("icon-setting", "设置"))
		dataArray.append(("icon-feedback", "反馈"))
		dataArray.append(("icon-about", "关于"))
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
        SVProgressHUD.show()
        let paras = [
            "user_id": "\(Util.getLoginedUser()?.id)"
        ]
        
        Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_CHECK_WHETHER_HAS_CAMPANY.rawValue, parameters: paras)
        .responseJSON { (response) in
            if let value = response.result.value {
                let json = JSON(value)
                let code = json["code"].intValue
                if code == 200 {
                    let data = json["data"].intValue
                    if data == 0 {
                        // 没有公司
                        Drop.down(Tips.ADD_PROJECT_NO_AUTHORIZATION, state: DropState.Warning)
                    } else if data == 1 {
                        // 有公司
                        self.slideMenuController()?.changeMainViewController(self.addActivityViewController, close: true)
                    }
                } else {
                    Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                }
            } else {
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
            }
            
            SVProgressHUD.dismiss()
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
			self.checkLaunchProject()

		case .AddActivity:
			self.slideMenuController()?.changeMainViewController(self.addActivityViewController, close: true)
            
        case .CompanyMap:
            self.slideMenuController()?.changeMainViewController(self.comppanyMapViewController, close: true)
            
        case .SearchCompany:
            self.slideMenuController()?.changeMainViewController(self.companySearchViewController, close: true)

		default:
			return
		}
	}
}
