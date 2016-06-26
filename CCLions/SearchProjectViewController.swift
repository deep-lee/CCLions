//
//  SearchProjectViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/5/1.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyDrop
import SwiftyJSON

class SearchProjectViewController: UIViewController {
	var dataArray: [Project]!

	@IBOutlet var mTableView: UITableView!
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
        initView()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    
    func initView() -> Void {
        mTableView.registerNib(UINib(nibName: "ProjectShowTVCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: CELL_REUSE)
        mTableView.separatorStyle = .None
        mTableView.backgroundColor = UIColor(hex: "fcfcfc")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
    }
}

extension SearchProjectViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataArray.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_REUSE, forIndexPath: indexPath) as! ProjectShowTVCell
        let project = self.dataArray[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.setParas(project)
        return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ProjectShowTVCell
        let image = cell.imageViewShow.image
        self.goToProjectDetailsVC(self.dataArray[indexPath.row], image: image!)
	}

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return MAIN_CELL_HEIGHT
	}
}
