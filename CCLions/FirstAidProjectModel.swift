//
//  FirstAidProjectModel.swift
//  CCLions
//
//  Created by 李冬 on 6/8/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyDrop
import SwiftyJSON
import YYCache

let FIRST_AID_PROJECT_REFRESH_DATA_SUCCESS   = "FIRST_AID_PROJECT_REFRESH_DATA_SUCCESS"
let FIRST_AID_PROJECT_REFRESH_DATA_FINISH    = "FIRST_AID_PROJECT_REFRESH_DATA_FINISH"
let FIRST_AID_PROJECT_LOAD_MORE_DATA_SUCCESS = "FIRST_AID_PROJECT_LOAD_MORE_DATA_SUCCESS"
let FIRST_AID_PROJECT_LOAD_MORE_DATA_FINISH  = "FIRST_AID_PROJECT_LOAD_MORE_DATA_FINISH"

let FIRST_AID_PROJECT_GET_DATAARRAY_FROM_DISK_CACHE_SUCCESS  = "FIRST_AID_PROJECT_GET_DATAARRAY_FROM_DISK_CACHE_SUCCESS"

class FirstAidProjectModel: SuperModel {
    let project_type = ProjectType.FirstAid.rawValue
    var dataArray: [Project]!
    // 已展示的最后一条数据的id
    var lastId = Int.max
    
    // 单例
    class func shareInstance() -> FirstAidProjectModel {
        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var single: FirstAidProjectModel?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = FirstAidProjectModel()
            Singleton.single?.dataArray = [Project]()
            }
        )
        return Singleton.single!
    }
    
    // refresh
    // 下拉刷新
    // */
    func headerRefresh() -> Void {
        self.lastId = Int.max
        print("正在下拉刷新")
        let paras = [
            "lastId": self.lastId,
            "project_type": self.project_type
        ]
        NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_PROJECT_PAGE.rawValue, paras: paras) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                // self.postNotification(FIRST_AID_PROJECT_REFRESH_DATA_FINISH)
                self.getDiskCache()
            case NetworkResponseState.SUCCESS.rawValue:
                let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
                let data = JSON(dataString).arrayValue
                if data.count != 0 {
                    self.dataArray.removeAll()
                    for item in data {
                        let project = Util.getProjectFromJson(item)
                        self.dataArray.append(project)
                    }
                    // 重新加载TableView数据
                    self.postNotification(FIRST_AID_PROJECT_REFRESH_DATA_SUCCESS)
                    self.lastId = (self.dataArray.last?.id)!
                    self.updateDiskCache()
                } else {
                    self.postNotification(FIRST_AID_PROJECT_REFRESH_DATA_FINISH)
                }
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
                // self.postNotification(FIRST_AID_PROJECT_REFRESH_DATA_FINISH)
                self.getDiskCache()
            default:
                break
            }
        }
    }
    
    /**
     上拉加载更多
     */
    func footerLoadMore() -> Void {
        print("正在加载更多")
        let paras = [
            "lastId": self.lastId,
            "project_type": self.project_type
        ]
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_PROJECT_PAGE.rawValue, paras: paras) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                self.postNotification(FIRST_AID_PROJECT_LOAD_MORE_DATA_FINISH)
            case NetworkResponseState.SUCCESS.rawValue:
                let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
                let data = JSON(dataString).arrayValue
                if data.count != 0 {
                    for item in data {
                        let project = Util.getProjectFromJson(item)
                        self.dataArray.append(project)
                    }
                    // 重新加载TableView数据
                    self.postNotification(FIRST_AID_PROJECT_LOAD_MORE_DATA_SUCCESS)
                    self.lastId = (self.dataArray.last?.id)!
                } else {
                    self.postNotification(FIRST_AID_PROJECT_LOAD_MORE_DATA_FINISH)
                }
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
                self.postNotification(FIRST_AID_PROJECT_LOAD_MORE_DATA_FINISH)
            default:
                break
            }
        }
    }
    
    /**
     更新本地缓存
     */
    func updateDiskCache() -> Void {
        let cache = YYCache(name: FIRST_AID_PROJECT_CACHE)
        cache?.diskCache.setObject(self.dataArray, forKey: FIRST_AID_PROJECT_DATAARRAY)
    }
    
    /**
     从缓存中加载数据
     */
    func getDiskCache() -> Void {
        let cache = YYCache(name: FIRST_AID_PROJECT_CACHE)
        let array = cache?.diskCache.objectForKey(FIRST_AID_PROJECT_DATAARRAY) as? [Project]
        if array != nil {
            print(array?.count)
            self.dataArray = array
            self.postNotification(FIRST_AID_PROJECT_GET_DATAARRAY_FROM_DISK_CACHE_SUCCESS)
        } else {
            self.postNotification(FIRST_AID_PROJECT_REFRESH_DATA_FINISH)
        }
    }
}