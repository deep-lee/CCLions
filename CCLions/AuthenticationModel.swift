//
//  AuthenticationModel.swift
//  CCLions
//
//  Created by 李冬 on 6/2/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import AssetsLibrary
import MobileCoreServices
import Alamofire
import SwiftyDrop
import SwiftyJSON

let ADD_AUTHENTICATION_SUCCESS = "ADD_AUTHENTICATION_SUCCESS"

class AuthenticationModel: SuperModel {
    // 单例
    class func shareInstance() -> AuthenticationModel {
        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var single: AuthenticationModel?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = AuthenticationModel()
            }
        )
        return Singleton.single!
    }
    
    func requestAuthentication(array: [UIImage]) -> Void {
        print(array)
        SVProgressHUD.show()
        NetworkUtil.shareInstance().uploadMultiImage(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_UPLOAD_MULTI_AUTHENTICATION_IMAGES.rawValue, array: array) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                SVProgressHUD.dismiss()
            case NetworkResponseState.SUCCESS.rawValue:
                // 上传图片成功
                let photoAddress = response.objectForKey(NETWORK_SUCCESS_DATA) as! String
                let paras = [
                    "user_id": "\(Util.getLoginedUser()!.id)",
                    "photo_address": photoAddress
                ]
                self.requestAddAuthentication(paras)
            // 请求写入到数据库
            case NetworkResponseState.FAIL.rawValue:
                // 上传图片失败
                Drop.down(Tips.UPLOAD_IMAGE_FAIL, state: DropState.Error)
                SVProgressHUD.dismiss()
            default:
                break
            }
        }
    }
    
    /**
     发起身份认证请求
     
     - parameter dic: 请求参数
     */
    func requestAddAuthentication(dic: NSDictionary) -> Void {
        NetworkUtil.shareInstance().requestWithUrlWithReturnString(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ADD_AUTHENTICATION.rawValue, paras: dic as! [String : AnyObject]) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                SVProgressHUD.dismiss()
            case NetworkResponseState.SUCCESS.rawValue:
                // 发起认证请求成功
                self.postNotification(ADD_AUTHENTICATION_SUCCESS);
                SVProgressHUD.dismiss()
            case NetworkResponseState.FAIL.rawValue:
                // 发起认证请求失败
                Drop.down(Tips.ADD_AUTHENTICATION_FAIL, state: DropState.Error)
                SVProgressHUD.dismiss()
            default:
                break
            }
        }
    }
}
