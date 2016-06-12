//
//  CompanyMapModel.swift
//  CCLions
//
//  Created by 李冬 on 6/12/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation
import MapKit
import SwiftyDrop
import SwiftyJSON

let COMPANY_MAP_SEARCH_COMPANY_SUCCESS = "COMPANY_MAP_SEARCH_COMPANY_SUCCESS"
let COMPANY_MAP_SEARCH_COMPANY_FINISH = "COMPANY_MAP_SEARCH_COMPANY_FINISH"

class CompanyMapModel: SuperModel {
    
    var companyArray: [Company]!
    var annotationArray: [MAAnnotation]!
    
    // 单例
    class func shareInstance() -> CompanyMapModel {
        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var single: CompanyMapModel?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = CompanyMapModel()
            Singleton.single?.companyArray = [Company]()
            Singleton.single?.annotationArray = [MAAnnotation]()
            }
        )
        return Singleton.single!
    }
    
    func searchCompanyWithCompanyName(name: String) -> Void {
        SVProgressHUD.show()
        NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_SEARCH_COMPANY_WITH_COMPANYNAME.rawValue, paras: ["search": name]) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                self.postNotification(COMPANY_MAP_SEARCH_COMPANY_FINISH)
            case NetworkResponseState.SUCCESS.rawValue:
                let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
                let data = JSON(dataString).arrayValue
                if data.count != 0 {
                    self.companyArray.removeAll()
                    self.annotationArray.removeAll()
                    for item in data {
                        let company = Util.getCompanyFromJson(item)
                        let annotation = Util.getAnnotationFromComapny(company)
                        self.companyArray.append(company)
                        self.annotationArray.append(annotation)
                    }
                    // 重新加载TableView数据
                    self.postNotification(COMPANY_MAP_SEARCH_COMPANY_SUCCESS)
                } else {
                    Drop.down(Tips.SEARCH_NO_RESULT, state: DropState.Warning)
                    self.postNotification(COMPANY_MAP_SEARCH_COMPANY_FINISH)
                }
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.SEARCH_COMPANY_FAIL, state: DropState.Error)
                self.postNotification(COMPANY_MAP_SEARCH_COMPANY_FINISH)
            default:
                break
            }
            
            SVProgressHUD.dismiss()
        }
    }
}