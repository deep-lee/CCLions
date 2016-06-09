//
//  NetworkUtil.swift
//  CCLions
//
//  Created by 李冬 on 5/11/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias NetworkResponse = (response: NSMutableDictionary) -> Void

enum NetworkResponseState: Int {
    case CONNECT_FAIL = 0
    case SUCCESS = 1
    case FAIL = 2
}

let NETWORK_STATE = "network_state"
let NETWORK_FAIL_TYPE = "type"
let NETWORK_SUCCESS_DATA = "data"

class NetworkUtil: NSObject {
    // 单例
    class func shareInstance() -> NetworkUtil {
        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var single: NetworkUtil?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = NetworkUtil()
            }
        )
        return Singleton.single!
    }
    
    /**
     网络请求，返回为字典
     
     - parameter url:             请求URL
     - parameter paras:           请求参数
     - parameter networkResponse: 返回回调
     */
    func requestWithUrlWithReturnDictionary(url: String, paras: [String: AnyObject], networkResponse: NetworkResponse) -> Void {
        Alamofire.request(.POST, url, parameters: paras)
            .responseJSON { (response) in
                // 返回不为空
                let dic = NSMutableDictionary()
                if let value = response.result.value {
                    print(value)
                    // 解析json
                    let json = JSON(value)
                    let code = json["code"].intValue
                    if code == 200 { // 成功
                        let data = json["data"].dictionaryObject
                        print(data)
                        dic.setValue(NetworkResponseState.SUCCESS.rawValue, forKey: NETWORK_STATE)
                        dic.setValue(data!, forKey: NETWORK_SUCCESS_DATA)
                    } else { // 失败
                        let type = json["type"].intValue
                        dic.setValue(NetworkResponseState.FAIL.rawValue, forKey: NETWORK_STATE)
                        dic.setValue(type, forKey: NETWORK_FAIL_TYPE)
                    }
                } else { // 返回为空，网络连接失败
                    dic.setValue(NetworkResponseState.CONNECT_FAIL.rawValue, forKey: NETWORK_STATE)
                }
                
                networkResponse(response: dic)
        }
    }
    
    /**
     网络请求，返回数组
     
     - parameter url:             请求URL
     - parameter paras:           请求参数
     - parameter networkResponse: 返回回调
     */
    func requestWithUrlWithReturnArray(url: String, paras: [String: AnyObject], networkResponse: NetworkResponse) -> Void {
        Alamofire.request(.POST, url, parameters: paras)
            .responseJSON { (response) in
                // 返回不为空
                let dic = NSMutableDictionary()
                if let value = response.result.value {
                    print(value)
                    // 解析json
                    let json = JSON(value)
                    let code = json["code"].intValue
                    if code == 200 { // 成功
                        let data = json["data"].arrayObject
                        print(data)
                        dic.setValue(NetworkResponseState.SUCCESS.rawValue, forKey: NETWORK_STATE)
                        dic.setValue(data == nil ? NSArray() : data, forKey: NETWORK_SUCCESS_DATA)
                    } else { // 失败
                        let type = json["type"].intValue
                        dic.setValue(NetworkResponseState.FAIL.rawValue, forKey: NETWORK_STATE)
                        dic.setValue(type, forKey: NETWORK_FAIL_TYPE)
                    }
                } else { // 返回为空，网络连接失败
                    dic.setValue(NetworkResponseState.CONNECT_FAIL.rawValue, forKey: NETWORK_STATE)
                }
                
                networkResponse(response: dic)
        }
    }
    
    /**
     网络请求返回字符串
     
     - parameter url:             请求URL
     - parameter paras:           请求参数
     - parameter networkResponse: 返回回调
     */
    func requestWithUrlWithReturnString(url: String, paras: [String: AnyObject], networkResponse: NetworkResponse) -> Void {
        Alamofire.request(.POST, url, parameters: paras)
            .responseJSON { (response) in
                // 返回不为空
                let dic = NSMutableDictionary()
                if let value = response.result.value {
                    print(value)
                    // 解析json
                    let json = JSON(value)
                    let code = json["code"].intValue
                    if code == 200 { // 成功
                        let data = json["data"].stringValue
                        print(data)
                        dic.setValue(NetworkResponseState.SUCCESS.rawValue, forKey: NETWORK_STATE)
                        dic.setValue(data, forKey: NETWORK_SUCCESS_DATA)
                    } else { // 失败
                        let type = json["type"].intValue
                        dic.setValue(NetworkResponseState.FAIL.rawValue, forKey: NETWORK_STATE)
                        dic.setValue(type, forKey: NETWORK_FAIL_TYPE)
                    }
                } else { // 返回为空，网络连接失败
                    dic.setValue(NetworkResponseState.CONNECT_FAIL.rawValue, forKey: NETWORK_STATE)
                }
                
                networkResponse(response: dic)
        }
    }
    
    /**
     上传多张图片
     
     - parameter url:             请求URL
     - parameter array:           图片数组
     - parameter networkResponse: 返回回调
     */
    func uploadMultiImage(url: String, array: [UIImage], networkResponse: NetworkResponse) -> Void {
        Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
            var index = 0
            for image in array {
                multipartFormData.appendBodyPart(data: UIImageJPEGRepresentation(image, 0.5)!, name: "file\(index)", fileName: "file\(index)", mimeType: "image/jpeg")
                index += 1
            }
        }) { (encodingResult) in
            let dic = NSMutableDictionary()
            switch encodingResult {
            case .Success(let upload, _, _):
                upload.responseJSON { response in
                    if let value = response.result.value {
                        let json = JSON(value)
                        let code = json["code"].intValue
                        if code == 200 {
                            let data = json["data"].stringValue
                            dic.setValue(NetworkResponseState.SUCCESS.rawValue, forKey: NETWORK_STATE)
                            dic.setValue(data, forKey: NETWORK_SUCCESS_DATA)
                            print(data)
                            networkResponse(response: dic)
                        } else {
                            let type = json["type"].intValue
                            dic.setValue(NetworkResponseState.FAIL.rawValue, forKey: NETWORK_STATE)
                            dic.setValue(type, forKey: NETWORK_FAIL_TYPE)
                            networkResponse(response: dic)
                        }
                    } else {
                        dic.setValue(NetworkResponseState.FAIL.rawValue, forKey: NETWORK_STATE)
                        networkResponse(response: dic)
                    }
                }
            case .Failure(_):
                dic.setValue(NetworkResponseState.CONNECT_FAIL.rawValue, forKey: NETWORK_STATE)
                networkResponse(response: dic)
            }
        }
    }
    
    /**
     上传单张照片
     
     - parameter url:             请求URL
     - parameter image:           上传的照片
     - parameter networkResponse: 回调
     */
    func uploadSingleImage(url: String, image: UIImage, networkResponse: NetworkResponse) -> Void {
        Alamofire.upload(.POST, url, data: UIImageJPEGRepresentation(image, 0.5)!)
            .responseJSON(completionHandler: { (response) in
                let dic = NSMutableDictionary()
                if let value = response.result.value {
                    print(value)
                    // 解析JSON
                    let json = JSON(value)
                    let code = json["code"].intValue
                    if code == 200 { // 上传成功
                        let data = json["data"].stringValue
                        dic.setValue(NetworkResponseState.SUCCESS.rawValue, forKey: NETWORK_STATE)
                        dic.setValue(data, forKey: NETWORK_SUCCESS_DATA)
                        print("上传图片地址：" + data)
                        networkResponse(response: dic)
                    } else { // 上传失败
                        dic.setValue(NetworkResponseState.FAIL.rawValue, forKey: NETWORK_STATE)
                        networkResponse(response: dic)
                    }
                } else { // 返回为空，说明网络连接失败
                    dic.setValue(NetworkResponseState.CONNECT_FAIL.rawValue, forKey: NETWORK_STATE)
                    networkResponse(response: dic)
                }
            })
    }
}