//
//  MainViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/2/13.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyDrop
import SwiftyJSON
import Alamofire
import SDWebImage

class MainViewController: UIViewController {
    @IBOutlet weak var activityShowTableView: UITableView!
    var dataArray: [Project]!
    // 已展示的最后一条数据的id
    var lastId = Int.max
    
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
        
        self.dataArray = [Project]()
        // 加入下拉刷新和上拉加载
        activityShowTableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(MainViewController.headerRefresh))
        activityShowTableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(MainViewController.footerLoadMore))
        
        // 初始在下拉刷新状态
        activityShowTableView.mj_header.state = MJRefreshState.Refreshing
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
    
    /**
     下拉刷新
     */
    func headerRefresh() -> Void {
        self.lastId = Int.max
        print("正在下拉刷新")
        let paras = [
            "lastId" : self.lastId
        ]
        
        print(paras)
        
        Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_PROJECT_PAGE.rawValue, parameters: paras)
        .responseJSON { (response) in
            // 返回不为空
            if let value = response.result.value {
                // 解析json
                let json = JSON(value)
                let code = json["code"].intValue
                
                print(json)
                if code == 200 { // 请求成功
                    let data = json["data"].arrayValue
                    if data.count != 0 {
                        self.dataArray.removeAll()
                        for item in data {
                            let project = Project(id: item["id"].intValue, title: item["title"].stringValue, time: item["time"].stringValue, launcher_id: item["launcher_id"].intValue, favorite: item["favorite"].intValue, cover_image: item["cover_image"].stringValue, details_page: item["details_page"].stringValue, create_time: item["create_time"].stringValue, name: item["name"].stringValue)
                            
                            self.dataArray.append(project)
                        }
                        
                        // 重新加载TableView数据
                        self.activityShowTableView.reloadData()
                        self.lastId = (self.dataArray.last?.id)!
                    }
                }
            } else {
                // 显示错误信息
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
            }
            
            self.activityShowTableView.mj_header.state = MJRefreshState.Idle
        }
    }
    
    func footerLoadMore() -> Void {
        print("正在加载更多")
        let paras = [
            "lastId" : self.lastId
        ]
        
        Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_PROJECT_PAGE.rawValue, parameters: paras)
            .responseJSON { (response) in
                // 返回不为空
                if let value = response.result.value {
                    // 解析json
                    let json = JSON(value)
                    let code = json["code"].intValue
                    
                    print(json)
                    if code == 200 { // 请求成功
                        let data = json["data"].arrayValue
                        if data.count != 0 {
                            for item in data {
                                let project = Project(id: item["id"].intValue, title: item["title"].stringValue, time: item["time"].stringValue, launcher_id: item["launcher_id"].intValue, favorite: item["favorite"].intValue, cover_image: item["cover_image"].stringValue, details_page: item["details_page"].stringValue, create_time: item["create_time"].stringValue, name: item["name"].stringValue)
                                
                                self.dataArray.append(project)
                                let path = NSIndexPath(forRow: self.dataArray.count, inSection: 0)
                                self.activityShowTableView.insertRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Right)
                            }
                            
                            // 重新加载TableView数据
                            self.lastId = (self.dataArray.last?.id)!
                        }
                    }
                } else {
                    // 显示错误信息
                    Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                }
                
                self.activityShowTableView.mj_footer.state = MJRefreshState.Idle
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

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MainShowCell") as! ActivityShowTableViewCell
        let project = self.dataArray[indexPath.row]
        cell.showIamgeView.sd_setImageWithURL(NSURL(string: project.cover_image))
        cell.activityTimeLabel.text = project.time
        cell.activityLauncherLabel.text = project.name
        cell.favLabel.text = "\(project.favorite)"
        
        return cell
    }
    
    /**
     给cell添加动画
     
     */
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity,200,
                                                       50, 0)
        cell.layer.transform = rotationTransform
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            cell.layer.transform = CATransform3DIdentity
            }, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let projectDetailsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectDetailsViewController") as! ProjectDetailsViewController
        projectDetailsViewController.project = self.dataArray[indexPath.row]
        self.navigationController?.pushViewController(projectDetailsViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 310
    }
}
