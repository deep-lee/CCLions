//
//  NaturalDisasterTVC.swift
//  CCLions
//
//  Created by 李冬 on 6/8/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class NaturalDisasterProjectTVC: UITableViewController, IndicatorInfoProvider {

    var itemInfo = IndicatorInfo(title: "View")
    var model: NaturalDisasterProjectModel!
    
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
    }
    
    func initView() -> Void {
        model = NaturalDisasterProjectModel.shareInstance()
        initNotification()
        tableView.registerNib(UINib(nibName: "ProjectShowTVCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: CELL_REUSE)
        tableView.separatorStyle = .None
        // 加入下拉刷新和上拉加载
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(NaturalDisasterProjectTVC.refreshAction))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(NaturalDisasterProjectTVC.loadMoreAction))
        
        // 初始在下拉刷新状态
        // tableView.mj_header.state = MJRefreshState.Refreshing
        self.refreshAction()
    }
    
    /**
     初始化model通知
     */
    func initNotification() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NaturalDisasterProjectTVC.refreshDataSuccessNoti(_:)), name: NATURAL_DISASTER_PROJECT_REFRESH_DATA_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NaturalDisasterProjectTVC.refreshDataFinishNoti(_:)), name: NATURAL_DISASTER_PROJECT_REFRESH_DATA_FINISH, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NaturalDisasterProjectTVC.loadMoreDataSuccessNoti(_:)), name: NATURAL_DISASTER_PROJECT_LOAD_MORE_DATA_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NaturalDisasterProjectTVC.loadMoreDataFinishNoti(_:)), name: NATURAL_DISASTER_PROJECT_LOAD_MORE_DATA_FINISH, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NaturalDisasterProjectTVC.loadDataArrayFromDiskCacheNotiCallBack(_:)), name: NATURAL_PROJECT_GET_DATAARRAY_FROM_DISK_CACHE_SUCCESS, object: nil)
    }
    
    // Mark Notification
    /**
     刷新数据成功通知
     
     - parameter noti: 通知
     */
    func refreshDataSuccessNoti(noti: NSNotification) -> Void {
        tableView.mj_header.state = MJRefreshState.Idle
        tableView.reloadData()
    }
    
    /**
     刷新数据（失败）完成
     
     - parameter noti: 通知
     */
    func refreshDataFinishNoti(noti: NSNotification) -> Void {
        tableView.mj_header.state = MJRefreshState.Idle
    }
    
    /**
     加载更多的数据成功
     
     - parameter noti: 通知
     */
    func loadMoreDataSuccessNoti(noti: NSNotification) -> Void {
        tableView.mj_footer.state = MJRefreshState.Idle
        tableView.reloadData()
    }
    
    /**
     加载更多数据结束
     
     - parameter noti: 通知
     */
    func loadMoreDataFinishNoti(noti: NSNotification) -> Void {
        tableView.mj_footer.state = MJRefreshState.Idle
    }
    
    /**
     从DiskCache加载数据成功
     
     - parameter noti: 通知
     */
    func loadDataArrayFromDiskCacheNotiCallBack(noti: NSNotification) -> Void {
        tableView.mj_header.state = MJRefreshState.Idle
        tableView.reloadData()
    }
    
    func refreshAction() -> Void {
        self.model.headerRefresh()
    }
    
    func loadMoreAction() -> Void {
        self.model.footerLoadMore()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return model.dataArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_REUSE, forIndexPath: indexPath) as! ProjectShowTVCell
        let project = self.model.dataArray[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.setParas(project)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return MAIN_CELL_HEIGHT
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ProjectShowTVCell
        let image = cell.imageViewShow.image
        self.goToProjectDetailsVC(model.dataArray[indexPath.row], image: image!)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
