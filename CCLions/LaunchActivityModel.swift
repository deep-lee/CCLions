//
//  LaunchActivityModel.swift
//  CCLions
//
//  Created by Joseph on 16/6/3.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
import AssetsLibrary
import MobileCoreServices
import Alamofire
import SwiftyDrop
import SwiftyJSON

let ADD_ACTIVITY_SUCCESS = "ADD_ACTIVITY_SUCCESS"

class LaunchActivityModel: SuperModel {
    // 单例
    class func shareInstance() -> LaunchActivityModel {
        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var single: LaunchActivityModel?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = LaunchActivityModel()
            }
        )
        return Singleton.single!
    }
    
    func uploadCoverImage(dic: NSMutableDictionary, coverImage: UIImage, idCardImage: UIImage?) -> Void {
        // 首先上传封面照片
        NetworkUtil.shareInstance().uploadSingleImage(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ACCEPT_ACTIVITY_IMAGE.rawValue, image: coverImage) { (response) in
            
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                SVProgressHUD.dismiss()
            case NetworkResponseState.SUCCESS.rawValue:
                // 上传图片成功
                let photoAddress = response.objectForKey(NETWORK_SUCCESS_DATA) as! String
                dic.setValue(photoAddress, forKey: "cover_image")
                if idCardImage != nil {
                    // 上传身份证照片
                    self.uploadIdCardImage(dic, idCardImage: idCardImage!)
                } else {
                    // 为自己发布的项目，直接发布
                    self.requestPublishActivity(dic)
                }
            case NetworkResponseState.FAIL.rawValue:
                // 上传图片失败
                Drop.down(Tips.UPLOAD_IMAGE_FAIL, state: DropState.Error)
                SVProgressHUD.dismiss()
            default:
                break
            }
        }
    }
    
    func uploadIdCardImage(dic: NSMutableDictionary, idCardImage: UIImage) -> Void {
        NetworkUtil.shareInstance().uploadSingleImage(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ACCEPT_ACTIVITY_IMAGE.rawValue, image: idCardImage) { (response) in
            
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                SVProgressHUD.dismiss()
            case NetworkResponseState.SUCCESS.rawValue:
                // 上传图片成功
                let photoAddress = response.objectForKey(NETWORK_SUCCESS_DATA) as! String
                dic.setValue(photoAddress, forKey: "aided_person_id_card_photo")
                
                // 请求发布项目
                self.requestPublishActivity(dic)
                
            case NetworkResponseState.FAIL.rawValue:
                // 上传图片失败
                Drop.down(Tips.UPLOAD_IMAGE_FAIL, state: DropState.Error)
                SVProgressHUD.dismiss()
            default:
                break
            }
        }
    }
    
    func requestPublishActivity(dic: NSDictionary) -> Void {
        print(dic)
        NetworkUtil.shareInstance().requestWithUrlWithReturnString(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ADD_ACTIVITY.rawValue, paras: dic as! [String: AnyObject]) { (response) in
            
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                SVProgressHUD.dismiss()
            case NetworkResponseState.SUCCESS.rawValue:
                // 发起认证请求成功
                self.postNotification(ADD_ACTIVITY_SUCCESS);
                SVProgressHUD.dismiss()
            case NetworkResponseState.FAIL.rawValue:
                // 发起认证请求失败
                Drop.down(Tips.ADD_ACTIVITY_FAIL, state: DropState.Error)
                SVProgressHUD.dismiss()
            default:
                break
            }
            
        }
    }
}