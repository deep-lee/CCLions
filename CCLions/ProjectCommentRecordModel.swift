//
//  ProjectCommentRecordModel.swift
//  CCLions
//
//  Created by 李冬 on 6/7/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation
import SwiftyDrop
import SwiftyJSON

let PROJECT_COMMENT_REFRESH_DATA_SUCCESS   = "PROJECT_COMMENT_REFRESH_DATA_SUCCESS"
let PROJECT_COMMENT_REFRESH_DATA_FINISH    = "PROJECT_COMMENT_REFRESH_DATA_FINISH"
let PROJECT_COMMENT_LOAD_MORE_DATA_SUCCESS = "PROJECT_COMMENT_LOAD_MORE_DATA_SUCCESS"
let PROJECT_COMMENT_LOAD_MORE_DATA_FINISH  = "PROJECT_COMMENT_LOAD_MORE_DATA_FINISH"
let PROJECT_COMMENT_ADD_COMMENT_FAIL       = "PROJECT_COMMENT_ADD_COMMENT_FAIL"
let PROJECT_COMMENT_ADD_COMMENT_SUCCESS    = "PROJECT_COMMENT_ADD_COMMENT_SUCCESS"

class ProjectCommentRecordModel: SuperModel {
    var dataArray: [Comment]!
    var lastId = Int.max // 已展示的最后一条数据的id
    var project_id: Int!
    // 单例
    class func shareInstance() -> ProjectCommentRecordModel {
        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var single: ProjectCommentRecordModel?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = ProjectCommentRecordModel()
            Singleton.single?.dataArray = [Comment]()
            }
        )
        return Singleton.single!
    }
    
    func refresh() -> Void {
        self.lastId = Int.max
        let paras = [
            "lastId": self.lastId,
            "project_id": self.project_id
        ]
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_COMMENT_RECORD_BY_PAGE.rawValue, paras: paras) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                self.postNotification(PROJECT_COMMENT_REFRESH_DATA_FINISH)
            case NetworkResponseState.SUCCESS.rawValue:
                let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
                let data = JSON(dataString).arrayValue
                if data.count != 0 {
                    self.dataArray.removeAll()
                    for item in data {
                        let comment = Util.getCommentFromJson(item)
                        self.dataArray.append(comment)
                    }
                    // 重新加载TableView数据
                    print(self.dataArray)
                    self.postNotification(PROJECT_COMMENT_REFRESH_DATA_SUCCESS)
                    print(self.dataArray.last?.id)
                    self.lastId = (self.dataArray.last?.id)!
                } else {
                    self.postNotification(PROJECT_COMMENT_REFRESH_DATA_FINISH)
                }
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
                self.postNotification(PROJECT_COMMENT_REFRESH_DATA_FINISH)
            default:
                break
            }
        }
    }
    
    func loadMore() -> Void {
        let paras = [
            "lastId": self.lastId,
            "project_id": self.project_id
        ]
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_COMMENT_RECORD_BY_PAGE.rawValue, paras: paras) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                self.postNotification(PROJECT_COMMENT_LOAD_MORE_DATA_FINISH)
            case NetworkResponseState.SUCCESS.rawValue:
                let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
                let data = JSON(dataString).arrayValue
                if data.count != 0 {
                    self.dataArray.removeAll()
                    for item in data {
                        let comment = Util.getCommentFromJson(item)
                        self.dataArray.append(comment)
                    }
                    // 重新加载TableView数据
                    self.postNotification(PROJECT_COMMENT_LOAD_MORE_DATA_SUCCESS)
                    self.lastId = (self.dataArray.last?.id)!
                } else {
                    self.postNotification(PROJECT_COMMENT_LOAD_MORE_DATA_FINISH)
                }
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
                self.postNotification(PROJECT_COMMENT_LOAD_MORE_DATA_FINISH)
            default:
                break
            }
        }
    }
    
    /**
     添加评论
     
     - parameter paras: 请求参数
     */
    func addComment(paras: [String: AnyObject]) -> Void {
        
        SVProgressHUD.show()
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnString(
        HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ADD_COMMENT.rawValue,
        paras: paras) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                self.postNotification(PROJECT_COMMENT_ADD_COMMENT_FAIL)
            case NetworkResponseState.SUCCESS.rawValue:
                self.postNotification(PROJECT_COMMENT_ADD_COMMENT_SUCCESS)
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.ADD_COMMENT_FAIL, state: DropState.Error)
                self.postNotification(PROJECT_COMMENT_ADD_COMMENT_FAIL)
            default:
                break
            }
            
            SVProgressHUD.dismiss()
        }
    }
}