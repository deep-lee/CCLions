//
//  CompanyMapCalloutView.h
//  CCLions
//
//  Created by 李冬 on 6/10/16.
//  Copyright © 2016 李冬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompanyMapCalloutView : UIView

@property (nonatomic, copy) NSString *companyName;                    // 公司名称

@property (nonatomic, copy) NSString *companyAddress;                 // 公司地址

- (void)setCompanyAddress:(NSString *)companyAddress;
- (void)setCompanyName:(NSString *)companyName;
- (void)hideDetailsButton;
- (void)showDetailsButton;

@end
