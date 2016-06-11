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

#define UIColorFromHex(s)   [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]

#define DETAILS_BUTTON_CLICKED                              @"DETAILS_BUTTON_CLICKED"
#define COMOPANY_NAME                                       @"COMOPANY_NAME"

@interface CompanyMapCalloutView ()

@property (nonatomic, strong) UILabel *labelCompanyName;
@property (nonatomic, strong) UILabel *labelCompanyAddress;
@property (nonatomic, strong) UIButton *buttonDetails;

@end

@implementation CompanyMapCalloutView

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
    self.labelCompanyName = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin * 2, kPortraitMargin, kTitleWidth, kTitleHeight)];
    self.labelCompanyName.font = [UIFont systemFontOfSize:14.0];
    self.labelCompanyName.textColor = [UIColor whiteColor];
    [self addSubview:self.labelCompanyName];
    
    self.labelCompanyAddress = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin * 2, kPortraitMargin * 2 + kTitleHeight, kTitleWidth, kTitleHeight)];
    self.labelCompanyAddress.font = [UIFont systemFontOfSize:14.0];
    self.labelCompanyAddress.textColor = [UIColor whiteColor];
    [self addSubview:self.labelCompanyAddress];
    
    self.buttonDetails = [[UIButton alloc] initWithFrame:CGRectMake(kPortraitMargin * 2 + kTitleWidth, kPortraitMargin, kPortraitWidth, kPortraitHeight)];
//    [self.buttonDetails setImage:[UIImage imageNamed:@"icon-company-map-details"] forState:UIControlStateNormal];
    [self.buttonDetails setTitle:@"详情" forState:UIControlStateNormal];
    self.buttonDetails.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.buttonDetails setTitleColor:UIColorFromHex(0x0395D8) forState:UIControlStateNormal];
    [self.buttonDetails setTitleColor:UIColorFromHex(0xffffff) forState:UIControlStateFocused];
    [self.buttonDetails setTitleColor:UIColorFromHex(0xffffff) forState:UIControlStateHighlighted];
    [self.buttonDetails addTarget:self action:@selector(detailsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.buttonDetails];
}

- (void)drawRect:(CGRect)rect
{
    
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = UIColorFromHex(0x333333).CGColor;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
}

- (void)drawInContext:(CGContextRef)context
{
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, UIColorFromHex(0x333333).CGColor);
    
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

- (void)setCompanyAddress:(NSString *)companyAddress {
    _companyAddress = companyAddress;
    self.labelCompanyAddress.text = companyAddress;
}

- (void)setCompanyName:(NSString *)companyName {
    _companyName = companyName;
    self.labelCompanyName.text = companyName;
}

- (void)detailsButtonAction:(NSObject *)sender {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.labelCompanyName.text forKey:COMOPANY_NAME];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DETAILS_BUTTON_CLICKED object:dic userInfo:nil];
}

@end
