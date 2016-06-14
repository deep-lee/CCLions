//
//  SupportedProjectTVC.swift
//  CCLions
//
//  Created by 李冬 on 6/13/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SupportedProjectTVC: UITableViewController, IndicatorInfoProvider {
    
    var itemInfo = IndicatorInfo(title: "View")
    
    var model: SupportProjectModel!
    
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
        model = SupportProjectModel.shareInstance()
        self.tableView.registerNib(UINib(nibName: "SupportedProjectTVCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: CELL_REUSE)
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor(hex: "fcfcfc")
        // 加入下拉刷新和上拉加载
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(SupportedProjectTVC.refreshAction))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(SupportedProjectTVC.loadMoreAction))
        tableView.separatorStyle = .None
        
        // 初始在下拉刷新状态
        // tableView.mj_header.state = MJRefreshState.Refreshing
        self.refreshAction()
    }
    
    /**
     初始化model通知
     */
    func initNotification() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SupportedProjectTVC.refreshSupportedProjectSuccessNotiCallBack(_:)), name: SUPPORTED_PROJECT_REFRESH_DATA_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SupportedProjectTVC.refreshSupportedProjectFinishNotiCallBack(_:)), name: SUPPORTED_PROJECT_REFRESH_DATA_FINISH, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SupportedProjectTVC.loadMoreSupportedProjectSuccessNotiCallBack(_:)), name: SUPPORTED_PROJECT_LOAD_MORE_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SupportedProjectTVC.loadMoreSupportedProjectFinishNotiCallBack(_:)), name: SUPPORTED_PROJECT_LOAD_MORE_FINISH, object: nil)
    }
    
    func refreshAction() -> Void {
        model.requestSupportedProject()
    }
    
    func loadMoreAction() -> Void {
        model.loadMoreSupportedProject()
    }
    
    func refreshSupportedProjectSuccessNotiCallBack(noti: NSNotification) -> Void {
        tableView.mj_header.state = MJRefreshState.Idle
        tableView.reloadData()
    }
    
    func refreshSupportedProjectFinishNotiCallBack(noti: NSNotification) -> Void {
        tableView.mj_header.state = MJRefreshState.Idle
    }
    
    func loadMoreSupportedProjectSuccessNotiCallBack(noti: NSNotification) -> Void {
        tableView.mj_footer.state = MJRefreshState.Idle
        tableView.reloadData()
    }
    
    func loadMoreSupportedProjectFinishNotiCallBack(noti: NSNotification) -> Void {
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
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_REUSE, forIndexPath: indexPath) as! SupportedProjectTVCell

        // Configure the cell...
        cell.setParas(model.dataArray[indexPath.row])
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return HEIGHT_FOR_SUPPORTED_PROJECT_CELL
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

}
