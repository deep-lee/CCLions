//
//  WithdrawModel.swift
//  CCLions
//
//  Created by 李冬 on 16/6/15.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyDrop
import SwiftyJSON

let WITHDRAW_UPLOAD_PROVE_IMAGES_SUCCESS = "WITHDRAW_UPLOAD_PROVE_IMAGES_SUCCESS"
let WITHDRAW_IMAGES_ADDRESS = "WITHDRAW_IMAGES_ADDRESS"
let ADD_WITHDRAW_SUCCESS = "ADD_WITHDRAW_SUCCESS"

class WithdrawModel: SuperModel {
    // 单例
    class func shareInstance() -> WithdrawModel {
        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var single: WithdrawModel?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = WithdrawModel()
            }
        )
        return Singleton.single!
    }
    
    func requestUploadProvePhotos(imageArray: [UIImage]) -> Void {
        SVProgressHUD.show()
        NetworkUtil.shareInstance().uploadMultiImage(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ACCEPT_MULTI_WITHDRAW_IMAGE.rawValue, array: imageArray) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                SVProgressHUD.dismiss()
            case NetworkResponseState.SUCCESS.rawValue:
                // 上传图片成功
                let photoAddress = response.objectForKey(NETWORK_SUCCESS_DATA) as! String
                let dic = NSMutableDictionary()
                dic.setValue(photoAddress, forKey: WITHDRAW_IMAGES_ADDRESS)
                self.postNotificationWithName(WITHDRAW_UPLOAD_PROVE_IMAGES_SUCCESS, object: dic)
                
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
    
    func requestAddWithdraw(paras: NSDictionary) -> Void {
        NetworkUtil.shareInstance().requestWithUrlWithReturnString(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ADD_WITHDRAW.rawValue, paras: paras as! [String : AnyObject]) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                SVProgressHUD.dismiss()
            case NetworkResponseState.SUCCESS.rawValue:
                // 发起认证请求成功
                self.postNotification(ADD_WITHDRAW_SUCCESS);
                SVProgressHUD.dismiss()
            case NetworkResponseState.FAIL.rawValue:
                // 发起认证请求失败
                Drop.down(Tips.ADD_WITHDRAW_FAIL, state: DropState.Error)
                SVProgressHUD.dismiss()
            default:
                break
            }
        }
    }
}