//
//  DonateVC.swift
//  CCLions
//
//  Created by 李冬 on 6/6/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import SnapKit

class DonateVC: UIViewController {
    
    @IBOutlet var mTableView: UITableView!
    var viewTop: SupportProgressView!
    var project: Project!
    
    var model: DonationModel!
    
    var commonFlowView: CommonFlowView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
        initNoti()
        initView()
	}
    
    func initView() -> Void {
        
        model = DonationModel.shareInstance()
        
        let headerView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDH, 120))
        viewTop = SupportProgressView(frame: CGRectZero)
        headerView.addSubview(viewTop)
        viewTop.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(120)
        }
        viewTop.setParas(project)
        
        commonFlowView = CommonFlowView(frame: CGRectZero)
        self.view.addSubview(commonFlowView)
        commonFlowView.snp_makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(64)
        }
        commonFlowView.hideCommentBtn()
        commonFlowView.hideSupportBtn()
        commonFlowView.delegate = self
        self.mTableView.tableHeaderView = headerView
        self.mTableView.registerNib(UINib(nibName: "DoantionTVCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: CELL_REUSE)
        
        model.getAllDonationSuggestMoney()
    }

    func initNoti() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DonateVC.getSuggestDonationMoenySuccessNotiCallBack(_:)), name: Donation_GET_SUGGEST_MONEY_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DonateVC.getSuggestDonationMoneyFailNotiCallBack(_:)), name: Donation_GET_SUGGEST_MONEY_FAIL, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DonateVC.donationCellSupportButtonClickedNotiCallBack(_:)), name: DONATION_CELL_SUPPORT_BUTTON_CLICKED, object: nil)
    }
    
    func getSuggestDonationMoenySuccessNotiCallBack(noti: NSNotification) -> Void {
        self.mTableView.reloadData()
    }
    
    func getSuggestDonationMoneyFailNotiCallBack(noti: NSNotification) -> Void {
        model.dataArray = ARRAY_DEFAULT_SUGGEST_DONATION_MONEY
        self.mTableView.reloadData()
    }
    
    func donationCellSupportButtonClickedNotiCallBack(noti: NSNotification) -> Void {
        let dic = noti.object as! NSDictionary
        let amount = dic.objectForKey(AMOUNT)?.integerValue
        // 进入到支付界面
        print(amount)
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

extension DonateVC: CommonFlowViewDelegate {
    func buttonBackClicked() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func buttonCommentClicked() {
        
    }
    
    func buttonSupportClicked() {
        
    }
}

extension DonateVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_REUSE, forIndexPath: indexPath) as! DoantionTVCell
        cell.setParas(model.dataArray[indexPath.row])
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return DONATION_AMOUNT_SUGGEST_CELL_HEIGHT
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}