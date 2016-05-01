//
//  HttpRequest.swift
//  CCLions
//
//  Created by Joseph on 16/4/10.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation

enum RequestAddress: String {
	case HTTP_LOGIN = "login.php"
	case HTTP_REGISTER = "register.php"
	case HTTP_PROJECT_PAGE = "project_page.php"
	case HTTP_UPLOAD_HEADER_IMAGE = "accept_image_iOS.php"
	case HTTP_COMPLETE_USER_INFO = "complete_user_info.php"
	case HTTP_GET_COMPANY_OF_USER = "company_of_user.php"
	case HTTP_UPLOAD_COMPANY_SHOW_IMAGE = "accept_multi_image.php"
	case HTTP_ADD_COMPANY = "add_company.php"
	case HTTP_CHECK_WHETHER_HAS_CAMPANY = "check_user_wether_has_company.php"
	case HTTP_UPDATE_COMPANY_INFO = "update_company_info.php"
	case HTTP_ACCEPT_ACTIVITY_IMAGE = "accept_activity_image_iOS.php"
	case HTTP_ACCEPT_ACTIVITY_VIDEO = "accept_activity_video.php"
	case HTTP_ADD_ACTIVITY = "publish_project.php"
	case HTTP_GET_LOCAL_COMPANY = "get_local_company.php"
	case HTTP_ACCEPT_COMPANY_IMAGE_iOS = "accept_company_image_iOS.php"
	case HTTP_UPDATE_COMPANY_HITS = "update_company_hits.php"
	case HTTP_GET_HOT_INDUSTRY = "get_hot_industry.php"
	case HTTP_GET_HOT_COMPANY = "get_hot_company.php"
	case HTTP_SEARCH_COMPANY_WITH_TEXT = "search_company_with_text.php"
	case HTTP_GET_HOT_INDUSTRY_COMPANY = "get_hot_industry_company.php"
	case HTTP_SEARCH_PROJECT = "search_project.php"
}

class HttpRequest {
	static let HTTP_ADDRESS = "http://182.92.158.167/Sunshine_server/"
}