//
//  HttpRequest.swift
//  CCLions
//
//  Created by Joseph on 16/4/10.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation

enum RequestAddress: String {
    case HTTP_LOGIN                              = "login.php"
    case HTTP_REGISTER                           = "register.php"
    case HTTP_PROJECT_PAGE                       = "project_page.php"
    case HTTP_UPLOAD_HEADER_IMAGE                = "accept_image_iOS.php"
    case HTTP_COMPLETE_USER_INFO                 = "complete_user_info.php"
    case HTTP_GET_COMPANY_OF_USER                = "company_of_user.php"
    case HTTP_UPLOAD_COMPANY_SHOW_IMAGE          = "accept_multi_company_image.php"
    case HTTP_ADD_COMPANY                        = "add_company.php"
    case HTTP_CHECK_WHETHER_HAS_CAMPANY          = "check_user_wether_has_company.php"
    case HTTP_UPDATE_COMPANY_INFO                = "update_company_info.php"
    case HTTP_ACCEPT_ACTIVITY_IMAGE              = "accept_activity_image_iOS.php"
    case HTTP_ACCEPT_ACTIVITY_VIDEO              = "accept_activity_video.php"
    case HTTP_ADD_ACTIVITY                       = "publish_project.php"
    case HTTP_GET_LOCAL_COMPANY                  = "get_local_company.php"
    case HTTP_ACCEPT_COMPANY_IMAGE_iOS           = "accept_company_image_iOS.php"
    case HTTP_UPDATE_COMPANY_HITS                = "update_company_hits.php"
    case HTTP_GET_HOT_INDUSTRY                   = "get_hot_industry.php"
    case HTTP_GET_HOT_COMPANY                    = "get_hot_company.php"
    case HTTP_SEARCH_COMPANY_WITH_TEXT           = "search_company_with_text.php"
    case HTTP_GET_HOT_INDUSTRY_COMPANY           = "get_hot_industry_company.php"
    case HTTP_SEARCH_PROJECT                     = "search_project.php"
    case HTTP_ADD_FAV                            = "add_fav.php"
    case HTTP_GET_USER_INFO_WITH_ID              = "get_user_info_with_id.php"
    case HTTP_UPLOAD_MULTI_AUTHENTICATION_IMAGES = "accept_multi_authentication_image.php"
    case HTTP_ADD_AUTHENTICATION                 = "add_authentication.php"
    case HTTP_GET_PROJECT_DONATION_RECORD_AMOUNT = "get_project_donation_record_amount.php"
    case HTTP_GET_PROJECT_WITHDRAW_RECORD_AMOUNT = "get_project_withdraw_record_amount.php"
    case HTTP_GET_PROJECT_COMMENT_RECORD_AMOUNT  = "get_project_comment_record_amount.php"
    case HTTP_DONATION_RECORD_BY_PAGE            = "donation_record_by_page.php"
    case HTTP_WITHDRAW_RECORD_BY_PAGE            = "withdraw_record_by_page.php"
    case HTTP_COMMENT_RECORD_BY_PAGE             = "comment_record_by_page.php"
    case HTTP_HAS_USER_LOVED_PROJECT             = "has_user_love_project.php"
    case HTTP_DELETE_FAV                         = "delete_fav.php"
    case HTTP_ADD_COMMENT                        = "add_comment.php"
    case HTTP_GET_DONATION_SUGGEST_MONEY         = "get_donation_suggest_money.php"
    case HTTP_SEARCH_COMPANY_WITH_COMPANYNAME    = "search_company_with_companyname.php"
    case HTTP_GET_SUPPORTED_PROJECT              = "get_supported_project.php"
    case HTTP_GET_MY_LAUNCHED_PROJECT            = "get_my_launched_project.php"
    case HTTP_ACCEPT_MULTI_WITHDRAW_IMAGE        = "accept_multi_withdraw_image.php"
    case HTTP_ADD_WITHDRAW                       = "add_withdraw.php"
    case HTTP_WITHDRAW_SELF_BY_ROW               = "withdraw_self_by_row.php"
    case HTTP_UPDATE_USER_PSW                    = "update_user_psw.php"
    case HTTP_FORGET_PSW                         = "forget_psw.php"
    case HTTP_CHECK_USER_COMPANY_NEW_IN_VERFY    = "check_user_company_new_in_verfy.php"
    case HTTP_ADD_PUSH_CLIENT                    = "add_push_client.php"
    case HTTP_DELETE_PUSH_CLIENT                 = "delete_push_client.php"

}

class HttpRequest {
    static let HTTP_ADDRESS                      = "http://182.92.158.167/Sunshine_server/"
}