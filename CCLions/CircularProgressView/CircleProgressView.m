//
//  CircleProgressView.m
//  CircularProgressControl
//
//  Created by Carlos Eduardo Arantes Ferreira on 22/11/14.
//  Copyright (c) 2014 Mobistart. All rights reserved.
//

#import "CircleProgressView.h"
#import "CircleShapeLayer.h"

@interface CircleProgressView()

@property (nonatomic, strong) CircleShapeLayer *progressLayer;
@property (strong, nonatomic) UILabel *progressLabel;

@end

@implementation CircleProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)awakeFromNib {
    [self setupViews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressLayer.frame = self.bounds;
    
    [self.progressLabel sizeToFit];
    self.progressLabel.center = CGPointMake(self.center.x - self.frame.origin.x, self.center.y- self.frame.origin.y);
}

- (void)updateConstraints {
    [super updateConstraints];
}

- (UILabel *)progressLabel
{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _progressLabel.numberOfLines = 2;
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.backgroundColor = [UIColor clearColor];
        _progressLabel.textColor = [UIColor whiteColor];
        
        [self addSubview:_progressLabel];
    }
    
    return _progressLabel;
}

- (double)percent {
    return self.progressLayer.percent;
}

- (NSInteger)passedCount {
    return self.progressLayer.passedCount;
}

- (void)setTotalCount:(CGFloat)totalCount {
    self.progressLayer.totalCount = totalCount;
}

- (void)setPCount:(CGFloat)pCount {
    _pCount = pCount;
    self.progressLayer.passedCount = pCount;
    // self.progressLabel.attributedText = [self formatProgressStringFromTimeInterval:elapsedTime];
}

- (void)setTextShow:(NSString *)textShow {
    _textShow = textShow;
    self.progressLabel.text = _textShow;
    self.progressLabel.font = [UIFont systemFontOfSize:14];
}

#pragma mark - Private Methods

- (void)setupViews {
    
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = false;
    
    //add Progress layer
    self.progressLayer = [[CircleShapeLayer alloc] init];
    self.progressLayer.frame = self.bounds;
    self.progressLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.progressLayer];
    
}

- (void)setTintColor:(UIColor *)tintColor {
    self.progressLayer.progressColor = tintColor;
    self.progressLabel.textColor = tintColor;
}

@end
