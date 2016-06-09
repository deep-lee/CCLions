//
//  DonationModel.swift
//  CCLions
//
//  Created by 李冬 on 6/9/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyDrop
import SwiftyJSON

let Donation_GET_SUGGEST_MONEY_SUCCESS = "Donation_GET_SUGGEST_MONEY_SUCCESS"
let Donation_GET_SUGGEST_MONEY_FAIL    = "Donation_GET_SUGGEST_MONEY_FAIL"

class DonationModel: SuperModel {
    var dataArray: [DonationSuggestionMoney]!
    // 单例
    class func shareInstance() -> DonationModel {
        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var single: DonationModel?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = DonationModel()
            Singleton.single?.dataArray = [DonationSuggestionMoney]()
            }
        )
        return Singleton.single!
    }
    
    func getAllDonationSuggestMoney() -> Void {
        SVProgressHUD.show()
        NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_DONATION_SUGGEST_MONEY.rawValue, paras: [:]) { (response) in
            print(response)
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                self.postNotification(Donation_GET_SUGGEST_MONEY_FAIL)
            case NetworkResponseState.SUCCESS.rawValue:
                let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
                let data = JSON(dataString).arrayValue
                if data.count != 0 {
                    self.dataArray.removeAll()
                    for item in data {
                        let suggest = Util.getDonationSuggestMoneyFromJson(item)
                        self.dataArray.append(suggest)
                    }
                    // 重新加载TableView数据
                    self.postNotification(Donation_GET_SUGGEST_MONEY_SUCCESS)
                    
                } else {
                    self.postNotification(Donation_GET_SUGGEST_MONEY_FAIL)
                }
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
                self.postNotification(Donation_GET_SUGGEST_MONEY_FAIL)
            default:
                break
            }
            
            SVProgressHUD.dismiss()
        }
    }
}