//
//  CustomAnnotationView.h
//  CCLions
//
//  Created by 李冬 on 6/10/16.
//  Copyright © 2016 李冬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "CustomCalloutView.h"

@interface CustomAnnotationView : MAAnnotationView

@property (nonatomic, readonly) CustomCalloutView *calloutView;

@end
