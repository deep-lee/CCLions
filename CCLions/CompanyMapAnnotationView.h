//
//  CompanyMapAnnotationView.h
//  CCLions
//
//  Created by 李冬 on 6/10/16.
//  Copyright © 2016 李冬. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import <MAMapKit/MAMapKit.h>
#import "CompanyMapCalloutView.h"

@interface CompanyMapAnnotationView : MAAnnotationView

@property (nonatomic, readonly) CompanyMapCalloutView *calloutView;

@end
