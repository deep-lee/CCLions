//
//  CompanyMapCalloutView.m
//  CCLions
//
//  Created by 李冬 on 6/10/16.
//  Copyright © 2016 李冬. All rights reserved.
//

#import "CompanyMapCalloutView.h"
#import <MAMapKit/MAMapKit.h>

#define kPortraitMargin     5
#define kPortraitWidth      70
#define kPortraitHeight     50

#define kTitleWidth         120
#define kTitleHeight        20
#define kArrorHeight        10

@interface CompanyMapCalloutView ()

@property (nonatomic, strong) UILabel *labelCompanyName;
@property (nonatomic, strong) UILabel *labelCompanyAddress;
@property (nonatomic, strong) UIButton *buttonDetails;

@end

@implementation CompanyMapCalloutView

@synthesize companyAddress;
@synthesize companyName;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.labelCompanyName = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin, kPortraitMargin, kPortraitWidth, kPortraitHeight)];
    self.labelCompanyName.font = [UIFont systemFontOfSize:14.0];
    self.labelCompanyName.textColor = [UIColor whiteColor];
    [self addSubview:self.labelCompanyName];
    
    self.labelCompanyAddress = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin, kPortraitMargin + kPortraitHeight + kPortraitMargin, kPortraitWidth, kPortraitHeight)];
    
    self.buttonDetails = [[UIButton alloc] initWithFrame:CGRectMake(kPortraitMargin * 2 + kPortraitWidth, kPortraitMargin, kPortraitWidth, kPortraitHeight)];
    [self.buttonDetails setImage:[UIImage imageNamed:@"icon-company-map-details"] forState:UIControlStateNormal];
    [self addSubview:self.buttonDetails];
}

- (void)drawRect:(CGRect)rect
{
    
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
}

- (void)drawInContext:(CGContextRef)context
{
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8].CGColor);
    
    [self getDrawPath:context];
    CGContextFillPath(context);
    
}

- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    
    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

@end
