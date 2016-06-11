//
//  CustomCalloutView.m
//  CCLions
//
//  Created by 李冬 on 6/10/16.
//  Copyright © 2016 李冬. All rights reserved.
//

#import "CustomCalloutView.h"
#import <MAMapKit/MAMapKit.h>

#define kPortraitMargin     5
#define kPortraitWidth      70
#define kPortraitHeight     50

#define kTitleWidth         120
#define kTitleHeight        20

#define UIColorFromHex(s)   [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]

#define SELECT_COMPANY_POSITION_BUTTON_CLICKED              @"SELECT_COMPANY_POSITION_BUTTON_CLICKED"
#define POSITION_LATITUDE                                   @"POSITION_LATITUDE"
#define POSITION_LONGITUDE                                  @"POSITION_LONGITUDE"
#define POSITION_TITLE                                      @"POSITION_TITLE"

typedef void (^SelectButtonClickBlock)(NSString *,NSString *);

@interface CustomCalloutView ()

@property (nonatomic, strong) UIImageView *portraitView;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *buttonSelect;

@end

@implementation CustomCalloutView

#define kArrorHeight        10

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    // 添加图片，即商户图
//    self.portraitView = [[UIImageView alloc] initWithFrame:CGRectMake(kPortraitMargin, kPortraitMargin, kPortraitWidth, kPortraitHeight)];
//    
//    self.portraitView.backgroundColor = [UIColor blackColor];
//    [self addSubview:self.portraitView];
    
    // 添加标题，即商户名
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin * 2, kPortraitMargin, kTitleWidth, kTitleHeight)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = @"titletitletitletitle";
    [self addSubview:self.titleLabel];
    
    // 添加副标题，即商户地址
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin * 2, kPortraitMargin * 2 + kTitleHeight, kTitleWidth, kTitleHeight)];
    self.subtitleLabel.font = [UIFont systemFontOfSize:12];
    self.subtitleLabel.textColor = [UIColor lightGrayColor];
    self.subtitleLabel.text = @"subtitleLabelsubtitleLabelsubtitleLabel";
    [self addSubview:self.subtitleLabel];
    
    // 选择按钮
    self.buttonSelect = [[UIButton alloc] initWithFrame:CGRectMake(kPortraitMargin * 2 + kTitleWidth, kPortraitMargin, kPortraitWidth, kPortraitHeight)];
    self.buttonSelect.backgroundColor = [UIColor clearColor];
    [self.buttonSelect setTitle:@"选择" forState:UIControlStateNormal];
    self.buttonSelect.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.buttonSelect setTitleColor:UIColorFromHex(0x0395D8) forState:UIControlStateNormal];
    [self.buttonSelect setTitleColor:UIColorFromHex(0xffffff) forState:UIControlStateFocused];
    [self.buttonSelect setTitleColor:UIColorFromHex(0xffffff) forState:UIControlStateHighlighted];
    [self.buttonSelect addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.buttonSelect];
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

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle
{
    self.subtitleLabel.text = subtitle;
}

- (void)setImage:(UIImage *)image
{
    self.portraitView.image = image;
}

- (void)selectButtonAction:(NSObject *)sender {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.titleLabel.text forKey:POSITION_TITLE];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SELECT_COMPANY_POSITION_BUTTON_CLICKED object:dic userInfo:nil];
}

@end
