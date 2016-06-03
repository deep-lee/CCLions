//
//  AddCompanyViewController.swift
//  CCLions
//
//  Created by 李冬 on 16/4/22.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyDrop
import SwiftyJSON
import Alamofire

class AddCompanyViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    var dataArray: [(String, String)]!
    var selectedPhotoArray: [String]!
    var selectedIndustry = -1
    var selectedPhotos: [UIImage] = [UIImage]()
    var selectedAnnotation: MAPointAnnotation?
    var selectedLogoImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     初始化数据
     */
    func initData() {
        self.selectedPhotoArray = [String]()
        self.dataArray = [(String, String)]()
        self.dataArray.append(("公司名称", ""))
        self.dataArray.append(("公司地址", ""))
        self.dataArray.append(("经营范围", ""))
        self.dataArray.append(("所属行业", ""))
        self.dataArray.append(("简介", ""))
        self.dataArray.append(("联系方式", ""))
        self.dataArray.append(("展示照片", ""))
        self.dataArray.append(("公司Logo", ""))
    }
    
    func goToEditTextFieldVC(row: Int) -> Void {
        let editTextFieldViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditTextFieldViewController") as! EditTextFieldViewController
        editTextFieldViewController.title = self.dataArray[row].0
        editTextFieldViewController.contentString = self.dataArray[row].1
        editTextFieldViewController.row = row
        editTextFieldViewController.setClosure(editFieldCallBack)
        self.navigationController?.pushViewController(editTextFieldViewController, animated: true)
    }
    
    func editFieldCallBack(string: String, row: Int) -> Void {
        print("接收到了回调")
        print(string + " \(row)")
        self.dataArray[row].1 = string
        self.tableView.reloadData()
    }
    
    func goToEditSelectDataVC(row: Int) -> Void {
        let editSelectDataViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditSelectDataViewController") as! EditSelectDataViewController
        editSelectDataViewController.title = self.dataArray[row].0
        editSelectDataViewController.dataArray = Util.INDUSTRY
        editSelectDataViewController.selectedIndex = self.selectedIndustry
        editSelectDataViewController.row = row
        editSelectDataViewController.setClosure(editSelectDataCallBack)
        self.navigationController?.pushViewController(editSelectDataViewController, animated: true)
    }
    
    func editSelectDataCallBack(row: Int, selectedRow: Int) -> Void {
        if row == 3 {
            self.selectedIndustry = selectedRow
            self.dataArray[3].1 = Util.INDUSTRY[selectedRow]
            self.tableView.reloadData()
        }
    }
    
    func goToEditTextViewVC(row: Int) -> Void {
        let editTextViewViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EditTextViewViewController") as! EditTextViewViewController
        editTextViewViewController.row = row
        editTextViewViewController.contentString = self.dataArray[row].1
        editTextViewViewController.setClosure(editTextViewCallBack)
        editTextViewViewController.title = self.dataArray[row].0
        self.navigationController?.pushViewController(editTextViewViewController, animated: true)
    }
    
    func editTextViewCallBack(string: String, row: Int) -> Void {
        if row == 4 {
            self.dataArray[row].1 = string
            self.tableView.reloadData()
        }
    }
    
    func goToSelectMultiPhotoVC(row: Int) -> Void {
        let selectMultiPhotoCollectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SelectMultiPhotoCollectionViewController") as! SelectMultiPhotoCollectionViewController
        selectMultiPhotoCollectionViewController.title = self.dataArray[row].0
        selectMultiPhotoCollectionViewController.dataArray = self.selectedPhotos
        selectMultiPhotoCollectionViewController.setClosure(selectMultiPhotoCallBack)
        self.navigationController?.pushViewController(selectMultiPhotoCollectionViewController, animated: true)
    }
    
    func selectMultiPhotoCallBack(var dataArray: [UIImage]) -> Void {
        print("调用了 ")
        dataArray.removeLast()
        self.selectedPhotos = dataArray
        self.dataArray[6].1 = "已选择\(self.selectedPhotos.count)张照片"
        self.tableView.reloadData()
    }
    
    func goToPickPositionVC(row: Int) -> Void {
        let pickPositionVC = PickPositionOnMapViewController()
        pickPositionVC.title = self.dataArray[row].0
        pickPositionVC.row = row
        pickPositionVC.setClosure(pickPositionCallBack)
        self.navigationController?.pushViewController(pickPositionVC, animated: true)
    }
    
    func pickPositionCallBack(row: Int, annotation: MAPointAnnotation) -> Void {
        self.dataArray[row].1 = annotation.title
        self.selectedAnnotation = annotation
        self.tableView.reloadData()
    }
    
    func goToSelectLogoVC(row: Int) -> Void {
        let selectCompanyLogoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SelectCompanyLogoViewController") as! SelectCompanyLogoViewController
        selectCompanyLogoViewController.title = self.dataArray[row].0
        if self.selectedLogoImage != nil {
            selectCompanyLogoViewController.logoImageView.image = self.selectedLogoImage
        }
        selectCompanyLogoViewController.setClosure(selectLogoCallBack)
        selectCompanyLogoViewController.row = row
        self.navigationController?.pushViewController(selectCompanyLogoViewController, animated: true)
    }
    
    func selectLogoCallBack(row: Int, headerChanged: Bool, logoImage: UIImage?) -> Void {
        if headerChanged {
            self.selectedLogoImage = logoImage
            self.dataArray[row].1 = "已选择Logo"
            self.tableView.reloadData()
        }
    }
    
    /**
     保存事件
     
     - parameter sender: 消息传递者
     */
    @IBAction func save(sender: AnyObject) {
        // 首先检查资料是否填写完整
        if !checkCompleted() {
            Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
            return
        }
        SVProgressHUD.showWithStatus(Tips.ADDING_COMPANY)
        // 资料填写完整后，首先上传展示照片
        Alamofire.upload(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_UPLOAD_COMPANY_SHOW_IMAGE.rawValue, multipartFormData: { multipartFormData in
            var index = 0
            for image in self.selectedPhotos {
                multipartFormData.appendBodyPart(data: UIImageJPEGRepresentation(image, 0.5)!, name: "file\(index)", fileName: "file\(index)", mimeType: "image/jpeg")
                index += 1
            }
        }) { (encodingResult) in
            switch encodingResult {
            case .Success(let upload, _, _):
                upload.responseJSON { response in
                    if let value = response.result.value {
                        let json = JSON(value)
                        let code = json["code"].intValue
                        if code == 200 {
                            let data = json["data"].stringValue
                            print("收到的图片地址为：" + data)
                            // 上传公司logo
                            self.uploadCompanyLogo(data)
                        } else {
                            Drop.down(Tips.UPLOAD_PHOTO_FAIL, state: DropState.Error)
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                        SVProgressHUD.dismiss()
                    }
                }
            case .Failure(_):
                Drop.down(Tips.UPLOAD_PHOTO_FAIL, state: DropState.Error)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    /**
     上传公司logo
     
     - parameter photoAddress: 公司展示照片地址
     */
    func uploadCompanyLogo(photoAddress: String) -> Void {
        Alamofire.upload(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ACCEPT_COMPANY_IMAGE_iOS.rawValue, data: UIImageJPEGRepresentation(self.selectedLogoImage!, 0.5)!)
            .responseJSON { (response) in
                if let value = response.result.value {
                    let json = JSON(value)
                    let code = json["code"].intValue
                    if code == 200 {
                        let logoAddress = HttpRequest.HTTP_ADDRESS + json["data"].stringValue
                        // 发起请求
                        self.requestNewCompany(photoAddress, logoAddress: logoAddress)
                    } else {
                        Drop.down(Tips.UPLOAD_PHOTO_FAIL, state: DropState.Error)
                        SVProgressHUD.dismiss()
                    }
                } else {
                    Drop.down(Tips.UPLOAD_PHOTO_FAIL, state: DropState.Error)
                    SVProgressHUD.dismiss()
                }
        }
    }
    
    func requestNewCompany(photoAddress: String, logoAddress: String) -> Void {
        let paras: [String: AnyObject] = [
            "user_id": (Util.getLoginedUser()?.id)!,
            "company_name": self.dataArray[0].1,
            "address_longitude": (self.selectedAnnotation?.coordinate.longitude)!,
            "address_latitude": (self.selectedAnnotation?.coordinate.latitude)!,
            "business_scope": self.dataArray[2].1,
            "industry": self.selectedIndustry,
            "show_photo": photoAddress,
            "create_time": NSDate(),
            "introduction": self.dataArray[4].1,
            "contact": self.dataArray[5].1,
            "company_logo": logoAddress
        ]
        
        Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ADD_COMPANY.rawValue, parameters: paras)
            .responseJSON { (response) in
                if let value = response.result.value {
                    let json = JSON(value)
                    let code = json["code"].intValue
                    if code == 200 {
                        // 添加公司成功
                        Drop.down(Tips.ADD_COMPANY_SUCCESS, state: DropState.Success)
                        self.navigationController?.popViewControllerAnimated(true)
                        SVProgressHUD.dismiss()
                    } else {
                        Drop.down(Tips.ADD_COMPANY_ERROR, state: DropState.Error)
                        SVProgressHUD.dismiss()
                    }
                } else {
                    Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                    SVProgressHUD.dismiss()
                }
        }
    }
    
    /**
     检查资料是否填写完整
     
     - returns:
     */
    func checkCompleted() -> Bool {
        for item in self.dataArray {
            if item.1 == "" {
                return false
            }
        }
        
        if self.selectedPhotos.count == 0 {
            return false
        }
        
        return true
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

extension AddCompanyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddCompanyTableViewCell", forIndexPath: indexPath)
        let dataItem = self.dataArray[indexPath.row]
        cell.textLabel?.text = dataItem.0
        cell.detailTextLabel?.text = dataItem.1
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0, 2, 5:
            self.goToEditTextFieldVC(indexPath.row)
        case 1:
            self.goToPickPositionVC(indexPath.row)
        case 3:
            self.goToEditSelectDataVC(indexPath.row)
        case 4:
            self.goToEditTextViewVC(indexPath.row)
        case 6:
            self.goToSelectMultiPhotoVC(indexPath.row)
        case 7:
            self.goToSelectLogoVC(indexPath.row)
        default:
            return
        }
    }
}
