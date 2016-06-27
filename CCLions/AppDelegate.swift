//
//  AppDelegate.swift
//  CCLions
//
//  Created by 李冬 on 16/2/12.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import CoreData
import SlideMenuControllerSwift
import IQKeyboardManagerSwift
import MapKit
//import Fabric
//import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GeTuiSdkDelegate {
	var window: UIWindow?
	let SMS_APP_KEY = "12ab781ef0456"
	let SMS_APP_SECRET = "4d41c4165cab290613996495b1d76988"

	private func createMenuView() {
		// create viewController code...
		let storyboard = UIStoryboard(name: "Main", bundle: nil)

		let leftViewController = storyboard.instantiateViewControllerWithIdentifier("SlideViewController") as! SlideViewController

		let nvc: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("MainNavagationController") as! UINavigationController
		nvc.navigationBar.barTintColor = UIColor(hex: "0395d8")
		leftViewController.mainViewController = nvc

		let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
		slideMenuController.automaticallyAdjustsScrollViewInsets = true
		self.window?.rootViewController = slideMenuController
		self.window?.makeKeyAndVisible()
	}
    
//    func registerPushForIOS8() -> Void {
//        let types: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
//        let acceptAction = UIMutableUserNotificationAction()
//        acceptAction.identifier = "ACCEPT_IDENTIFIER"
//        acceptAction.title = "Accept"
//        acceptAction.activationMode = UIUserNotificationActivationMode.Foreground
//        acceptAction.destructive = false
//        acceptAction.authenticationRequired = false
//        
//        let inviteCategory = UIMutableUserNotificationCategory()
//        inviteCategory.identifier = "INVITE_CATEGORY"
//        inviteCategory.setActions([acceptAction], forContext: UIUserNotificationActionContext.Default)
//        inviteCategory.setActions([acceptAction], forContext: UIUserNotificationActionContext.Minimal)
//        
//        let categories = NSSet(object: inviteCategory)
//        
//        let mySettings = UIUserNotificationSettings(forTypes: types, categories: categories as? Set<UIUserNotificationCategory>)
//        
//        UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
//        UIApplication.sharedApplication().registerForRemoteNotifications()
//    }

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.

		// Flurry 统计初始化
		Flurry.startSession(Util.FLURRY_API_KEY)

//		Fabric.with([Crashlytics.self])

		// 短信验证码接口
		SMSSDK.registerApp(SMS_APP_KEY, withSecret: SMS_APP_SECRET)
        
        // 友盟分享
        UMSocialData.openLog(true)
        UMSocialData.setAppKey(SHARE_SDK_APP_KEY)
        UMSocialWechatHandler.setWXAppId(WECHAT_APP_ID, appSecret: WECHAT_APP_KEY, url: "http://www.umeng.com/social")
        UMSocialSinaSSOHandler.openNewSinaSSOWithAppKey(SINA_WEIBO_APP_KEY, secret: SINA_WEIBO_APP_SECRET, redirectURL: "http://sns.whalecloud.com/sina2/callback")
        
        // 通过 appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
        GeTuiSdk.startSdkWithAppId(kGtAppId, appKey: kGtAppKey, appSecret: kGtAppSecret, delegate: self);
        
        // 注册Apns
        self.registerUserNotification(application);
        
//        // 信鸽推送
//        XGPush.startApp(XINGE_APP_ID, appKey: XINGE_APP_KEY)
//        XGPush.handleLaunching(launchOptions)
//        XGSetting.getInstance().enableDebug(true)
//        self.registerPushForIOS8()

		IQKeyboardManager.sharedManager().enable = true
        
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let flag = Util.hasUserLogined() ? true : false
		if flag {
			// 用户已经登录的情况下，需要判断当前登录的用户资料是否已经填写完整
			if Util.getLoginedUser()?.name == nil || Util.getLoginedUser()?.name == "" {
				// 进入到资料填写界面
				let completeUserInfo = storyboard.instantiateViewControllerWithIdentifier("EditSelfProfileViewController") as! EditSelfProfileViewController
				completeUserInfo.flag = false
				let nvc = UINavigationController(rootViewController: completeUserInfo)
				nvc.navigationBar.barTintColor = UIColor(hex: "0395d8")
				let dic = [
					NSForegroundColorAttributeName: UIColor.whiteColor()
				]
				nvc.navigationBar.titleTextAttributes = dic
				nvc.navigationBar.tintColor = UIColor.whiteColor()
				self.window?.rootViewController = nvc
			} else { // 用户的资料已经填写完整了
				let leftViewController = storyboard.instantiateViewControllerWithIdentifier("SlideViewController") as! SlideViewController

				let nvc: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("MainNavagationController") as! UINavigationController
				nvc.navigationBar.barTintColor = UIColor(hex: "0395d8")
				leftViewController.mainViewController = nvc

				let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
				slideMenuController.automaticallyAdjustsScrollViewInsets = true
				self.window?.rootViewController = slideMenuController
			}
		} else {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            self.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
			let leftViewController = storyboard.instantiateViewControllerWithIdentifier("SlideViewController") as! SlideViewController

			let nvc: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("MainNavagationController") as! UINavigationController
			nvc.navigationBar.barTintColor = UIColor(hex: "0395d8")
			leftViewController.mainViewController = nvc

			let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
			slideMenuController.automaticallyAdjustsScrollViewInsets = true
			self.window?.rootViewController = slideMenuController
		}
		self.window?.makeKeyAndVisible()

		return true
	}
    
    // MARK: - 用户通知(推送) _自定义方法
    
    /** 注册用户通知(推送) */
    func registerUserNotification(application: UIApplication) {
        let result = UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch)
        if (result != NSComparisonResult.OrderedAscending) {
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
            let userSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(userSettings)
        } else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes([.Alert, .Sound, .Badge])
        }
    }
    
    // MARK: - 远程通知(推送)回调
    
    /** 远程通知注册成功委托 */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var token = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"));
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        // [3]:向个推服务器注册deviceToken
        GeTuiSdk.registerDeviceToken(token);
        
        NSLog("\n>>>[DeviceToken Success]:%@\n\n",token);
    }
    
    /** 远程通知注册失败委托 */
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog("\n>>>[DeviceToken Error]:%@\n\n",error.description);
    }
    
    // MARK: - APP运行中接收到通知(推送)处理
    
    /** APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台) */
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        application.applicationIconBadgeNumber = 0;        // 标签
        
        NSLog("\n>>>[Receive RemoteNotification]:%@\n\n",userInfo);
    }
    
    // MARK: - GeTuiSdkDelegate
    
    /** SDK启动成功返回cid */
    func GeTuiSdkDidRegisterClient(clientId: String!) {
        // [4-EXT-1]: 个推SDK已注册，返回clientId
        NSLog("\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
    }
    
    /** SDK遇到错误回调 */
    func GeTuiSdkDidOccurError(error: NSError!) {
        // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
        NSLog("\n>>>[GeTuiSdk error]:%@\n\n", error.localizedDescription);
    }
    
    /** SDK收到sendMessage消息回调 */
    func GeTuiSdkDidSendMessage(messageId: String!, result: Int32) {
        // [4-EXT]:发送上行消息结果反馈
        let msg:String = "sendmessage=\(messageId),result=\(result)";
        NSLog("\n>>>[GeTuiSdk DidSendMessage]:%@\n\n",msg);
    }
    
//    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        
//        XGPush.setAccount("test")
//        
//        let deviceTokenStr = XGPush.registerDevice(deviceToken)
//        
//        print("DeviceToken: " + deviceTokenStr)
//    }
//    
//    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
//        print(error)
//    }
//    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        XGPush.handleReceiveNotification(userInfo)
//    }

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		// Saves changes in the application's managed object context before the application terminates.
		self.saveContext()
	}

	// MARK: - Core Data stack

	lazy var applicationDocumentsDirectory: NSURL = {
		// The directory the application uses to store the Core Data store file. This code uses a directory named "com.deep.lee.CCLions" in the application's documents Application Support directory.
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls[urls.count - 1]
	}()

	lazy var managedObjectModel: NSManagedObjectModel = {
		// The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
		let modelURL = NSBundle.mainBundle().URLForResource("CCLions", withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()

	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		// The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
		// Create the coordinator and store
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
		var failureReason = "There was an error creating or loading the application's saved data."
		do {
			try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
		} catch {
			// Report any error we got.
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
			dict[NSLocalizedFailureReasonErrorKey] = failureReason

			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			// Replace this with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
			abort()
		}

		return coordinator
	}()

	lazy var managedObjectContext: NSManagedObjectContext = {
		// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()

	// MARK: - Core Data Saving support

	func saveContext() {
		if managedObjectContext.hasChanges {
			do {
				try managedObjectContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
				abort()
			}
		}
	}
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let result = UMSocialSnsService.handleOpenURL(url)
        
        return result
    }
}

