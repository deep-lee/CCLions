//
//  ProjectDetailsViewController.swift
//  CCLions
//
//  Created by Joseph on 16/4/11.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit

class ProjectDetailsViewController: UIViewController {
    
    var project: Project!

    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.webView.delegate = self
        self.initWeight()
        self.loadWebPageWithString(project.details_page)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     初始化导航栏
     */
    func initWeight() -> Void {
        self.title = project.title
    }
    
    /**
     WebView加载活动详情URL
     
     - parameter urlString: 活动详情URL地址
     */
    func loadWebPageWithString(urlString: String) -> Void {
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
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

extension ProjectDetailsViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(webView: UIWebView) {
        SVProgressHUD.showWithStatus("正在加载...")
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
}
