//
//  LaunchedProjectTVC.swift
//  CCLions
//
//  Created by 李冬 on 6/13/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class LaunchedProjectTVC: UITableViewController, IndicatorInfoProvider {

    var itemInfo = IndicatorInfo(title: "View")
    var model: LaunchedProjectModel!
    
    init(style: UITableViewStyle, itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        initView()
        initNotification()
    }

    func initView() -> Void {
        model = LaunchedProjectModel.shareInstance()
        self.tableView.registerNib(UINib(nibName: "LaunchedProjectTVCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: CELL_REUSE)
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor(hex: "fcfcfc")
        // 加入下拉刷新和上拉加载
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(LaunchedProjectTVC.refreshAction))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(LaunchedProjectTVC.loadMoreAction))
        tableView.separatorStyle = .None
        
        // 初始在下拉刷新状态
        // tableView.mj_header.state = MJRefreshState.Refreshing
        self.refreshAction()
    }
    
    /**
     初始化model通知
     */
    func initNotification() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LaunchedProjectTVC.refreshLAUNCHEDProjectSuccessNotiCallBack(_:)), name: LAUNCHED_PROJECT_REFRESH_DATA_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LaunchedProjectTVC.refreshLAUNCHEDProjectFinishNotiCallBack(_:)), name: LAUNCHED_PROJECT_REFRESH_DATA_FINISH, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LaunchedProjectTVC.loadMoreLAUNCHEDProjectSuccessNotiCallBack(_:)), name: LAUNCHED_PROJECT_LOAD_MORE_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LaunchedProjectTVC.loadMoreLAUNCHEDProjectFinishNotiCallBack(_:)), name: LAUNCHED_PROJECT_LOAD_MORE_FINISH, object: nil)
    }
    
    func refreshAction() -> Void {
        model.requestLAUNCHEDProject()
    }
    
    func loadMoreAction() -> Void {
        model.loadMoreLAUNCHEDProject()
    }
    
    func refreshLAUNCHEDProjectSuccessNotiCallBack(noti: NSNotification) -> Void {
        tableView.mj_header.state = MJRefreshState.Idle
        tableView.reloadData()
    }
    
    func refreshLAUNCHEDProjectFinishNotiCallBack(noti: NSNotification) -> Void {
        tableView.mj_header.state = MJRefreshState.Idle
    }
    
    func loadMoreLAUNCHEDProjectSuccessNotiCallBack(noti: NSNotification) -> Void {
        tableView.mj_footer.state = MJRefreshState.Idle
        tableView.reloadData()
    }
    
    func loadMoreLAUNCHEDProjectFinishNotiCallBack(noti: NSNotification) -> Void {
        tableView.mj_footer.state = MJRefreshState.Idle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return model.dataArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_REUSE, forIndexPath: indexPath) as! LaunchedProjectTVCell
        
        // Configure the cell...
        cell.setParas(model.dataArray[indexPath.row])
        cell.delegate = self
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return HEIGHT_FOR_LAUNCHED_PROJECT_CELL
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func goToWithdrawTVC(project: Project) -> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateViewControllerWithIdentifier("WithdrawTVC") as! WithdrawTVC
        vc.project = project
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension LaunchedProjectTVC: LaunchedProjectTVCellDelegate {
    func withdrawAction(project: Project) {
        goToWithdrawTVC(project)
    }
}
