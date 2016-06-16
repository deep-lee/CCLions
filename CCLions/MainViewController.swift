//
//  MainViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/2/13.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
import XLPagerTabStrip

class MainViewController: TwitterPagerTabStripViewController {
	var searchView: SearhView!
    var isReload = false
    var isSearching = false
    var model: MainVCModel!
    
	override func viewDidLoad() {
        super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.initView()
        initNoti()
        
        // #Mark 防止自动调整ScrollView内边距导致ScrollView上面出现空白
        self.automaticallyAdjustsScrollViewInsets = false
	}
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = CCLionProjectTVC(style: .Plain, itemInfo: "狮子会")
        let child_2 = PoorProjectTVC(style: .Plain, itemInfo: "贫困")
        let child_3 = MedicalProjectTVC(style: .Plain, itemInfo: "医疗")
        let child_4 = NaturalDisasterProjectTVC(style: .Plain, itemInfo: "自然灾害")
        let child_5 = EducationProjectTVC(style: .Plain, itemInfo: "教育")
        let child_6 = FirstAidProjectTVC(style: .Plain, itemInfo: "急救")
        let child_7 = OtherProjectTVC(style: .Plain, itemInfo: "其他")
        
        guard isReload else {
            return [child_1, child_2, child_3, child_4, child_5, child_6, child_7]
        }
        
        var childViewControllers = [child_1, child_2, child_3, child_4, child_5, child_6, child_7]
        
        for (index, _) in childViewControllers.enumerate(){
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index{
                swap(&childViewControllers[index], &childViewControllers[n])
            }
        }
        let nItems = 1 + (rand() % 7)
        return Array(childViewControllers.prefix(Int(nItems)))
    }

	/**
	 初始化界面
	 */
	func initView() -> Void {
        model = MainVCModel.shareInstance()
        self.initSearchView()
        MainVCModel.shareInstance().updateLoginedUserInfo()
	}
    
    func initSearchView() -> Void{
        self.searchView = SearhView(frame: CGRectMake(0, 0, SCREEN_WIDH, 44))
        self.searchView.searchTextFieldEndCallBack = searchViewDidEndOnExit
        self.searchView.buttonCallBack = searchBackCallBack
        self.navigationController?.navigationBar.addSubview(self.searchView)
        self.searchView.hidden = true
    }

    func initNoti() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.goToSearchRecultVC(_:)), name: GO_TO_SEARCH_PROJECT, object: nil)
    }
    
    func goToSearchRecultVC(noti: NSNotification) -> Void {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SearchProjectViewController") as! SearchProjectViewController
        vc.dataArray = model.searchResult
        vc.title = self.searchView.getInputText()
        self.searchView.clearInput()
        self.searchView.hidden = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.setNavigationBarItem()
        self.navigationController?.navigationBar.hidden = false
	}

	@IBAction func leftMenu(sender: AnyObject) {
		slideMenuController()?.toggleLeft()
	}
    
    @IBAction func searchAction(sender: AnyObject) {
        if isSearching {
            self.searchView.clearInput()
            self.searchView.hidden = true
        } else {
             self.searchView.hidden = false
            self.searchView.searchTextField.becomeFirstResponder()
        }
    }
    
    func searchViewDidEndOnExit() -> Void {
        model.requestSearchWithText(self.searchView.getInputText())
    }
    
    func searchBackCallBack() -> Void {
        self.searchView.clearInput()
        self.searchView.hidden = true
        self.isSearching = false
    }
}

