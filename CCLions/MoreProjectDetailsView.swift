//
//  MoreProjectDetailsView.swift
//  CCLions
//
//  Created by Joseph on 16/6/4.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SnapKit

let GO_TO_PROJECT_DONATION_RECORD_VC = "GO_TO_PROJECT_DONATION_RECORD_VC"
let PROJECT_ID = "PROJECT_ID"

protocol MoreProjectDetailsViewDelegate {
    func donationRecordSelected(project_id: Int)
    func withdrawRecordSelected(project_id: Int)
    func commentRecordSelected(project_id: Int)
}

class MoreProjectDetailsView: UIView {
    
    var delegate: MoreProjectDetailsViewDelegate?

	var labelLeftTime: UILabel!
	var circleProgressView: CircleProgressView!
	var project: Project?
	var mTableView: UITableView!
	var dataArray: [String]!
	var buttonGoToDonate: UIButton!
	var buttonReport: UIButton!
	var curIndexPath: NSIndexPath!

	override init(frame: CGRect) {
		super.init(frame: frame)
		initView()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func initView() -> Void {
		self.dataArray = [String]()

		mTableView = UITableView(frame: self.frame, style: UITableViewStyle.Grouped)
		mTableView.delegate = self
		mTableView.dataSource = self

		let headerView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDH, 250))
		headerView.backgroundColor = UIColor(hex: "33495d")

		labelLeftTime = UILabel()
		headerView.addSubview(labelLeftTime)
		labelLeftTime.snp_makeConstraints { (make) in
			make.top.equalTo(labelLeftTime.superview!).offset(20)
			make.centerX.equalTo(labelLeftTime.superview!)
		}
		labelLeftTime.textColor = UIColor.whiteColor()
		labelLeftTime.font = UIFont.systemFontOfSize(14)

		circleProgressView = CircleProgressView(frame: CGRectZero)
		headerView.addSubview(circleProgressView)
		circleProgressView.snp_makeConstraints { (make) in
			make.width.height.equalTo(150)
			make.centerX.equalTo(circleProgressView.superview!)
			make.top.equalTo(labelLeftTime.snp_bottom).offset(30)
		}
		mTableView.tableHeaderView = headerView

		// footerview
		let footerView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDH, 200))
		self.buttonGoToDonate = UIButton(frame: CGRectZero)
		footerView.addSubview(self.buttonGoToDonate)
		self.buttonGoToDonate.snp_makeConstraints { (make) in
			make.left.top.equalTo(20)
			make.right.equalTo(-20)
			make.height.equalTo(40)
		}

		self.buttonGoToDonate.setTitle("我要捐款", forState: UIControlState.Normal)
		self.buttonGoToDonate.backgroundColor = UIColor(hex: "33495d")
		buttonGoToDonate.layer.masksToBounds = true
		buttonGoToDonate.layer.cornerRadius = 5
		buttonGoToDonate.titleLabel?.font = UIFont.systemFontOfSize(15.0)

		buttonReport = UIButton(frame: CGRectZero)
		footerView.addSubview(buttonReport)
		buttonReport.snp_makeConstraints { (make) in
			make.left.equalTo(20)
			make.top.equalTo(buttonGoToDonate.snp_bottom).offset(20)
			make.right.equalTo(-20)
		}
		buttonReport.setTitle("对项目有疑问？举报", forState: UIControlState.Normal)
		buttonReport.setTitleColor(UIColor(hex: "33495d"), forState: UIControlState.Normal)
		buttonReport.titleLabel?.font = UIFont.systemFontOfSize(14.0)

		mTableView.tableFooterView = footerView

		self.addSubview(mTableView)
	}

	func initDataArray() -> Void {
		if self.project?.sponsorship_company_id != 0 { // 有冠名的企业
			self.dataArray.append("冠名企业")
		}

		self.dataArray.append("捐助记录")
		self.dataArray.append("提款记录")
		self.dataArray.append("评论")

		mTableView.reloadData()
	}

	func setParas(project: Project) -> Void {
		self.project = project;
		updateView()
	}

	func updateView() -> Void {
		circleProgressView.totalCount = CGFloat((self.project?.fundraising_amount)!)
		circleProgressView.pCount = CGFloat((self.project?.has_raised_amount)!)
		circleProgressView.textShow = "求助金额：\(self.project!.fundraising_amount!)\n已募集金额：\(self.project!.has_raised_amount!)"
		labelLeftTime.text = "剩余求助时间：\(self.project!.left_time)天"
		initDataArray()
	}

	func setDonationRecordAmount(amount: String) -> Void {
		var indexPath: NSIndexPath!
		if self.project?.sponsorship_company_id != 0 {
			// 有企业冠名
			indexPath = NSIndexPath(forRow: 1, inSection: 0)
		} else {
			// 没有企业冠名
			indexPath = NSIndexPath(forRow: 0, inSection: 0)
		}

		let cell = mTableView.cellForRowAtIndexPath(indexPath)
		cell?.detailTextLabel?.text = amount + "条"
	}

	func setWithdrawRecordAmount(amount: String) -> Void {
		var indexPath: NSIndexPath!
		if self.project?.sponsorship_company_id != 0 {
			// 有企业冠名
			indexPath = NSIndexPath(forRow: 2, inSection: 0)
		} else {
			// 没有企业冠名
			indexPath = NSIndexPath(forRow: 1, inSection: 0)
		}

		let cell = mTableView.cellForRowAtIndexPath(indexPath)
		cell?.detailTextLabel?.text = amount + "条"
	}

	func setCommentRecordAmount(amount: String) -> Void {
		var indexPath: NSIndexPath!
		if self.project?.sponsorship_company_id != 0 {
			// 有企业冠名
			indexPath = NSIndexPath(forRow: 3, inSection: 0)
		} else {
			// 没有企业冠名
			indexPath = NSIndexPath(forRow: 2, inSection: 0)
		}

		let cell = mTableView.cellForRowAtIndexPath(indexPath)
		cell?.detailTextLabel?.text = amount + "条"
	}
}

extension MoreProjectDetailsView: UITableViewDelegate, UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataArray.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: CELL_REUSE)
		cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
		cell.textLabel?.text = self.dataArray[indexPath.row]
		cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		curIndexPath = indexPath
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.project?.sponsorship_company_id != 0 {
            // 有企业冠名
            switch indexPath.row {
            case 1:
                delegate?.donationRecordSelected((self.project?.id)!)
            case 2:
                delegate?.withdrawRecordSelected((self.project?.id)!)
            case 3:
                delegate?.commentRecordSelected((self.project?.id)!)
            default:
                break
            }
        } else {
            // 没有冠名
            switch indexPath.row {
            case 0:
                delegate?.donationRecordSelected((self.project?.id)!)
            case 1:
                delegate?.withdrawRecordSelected((self.project?.id)!)
            case 2:
                delegate?.commentRecordSelected((self.project?.id)!)
            default:
                break
            }
        }
        
	}
}
