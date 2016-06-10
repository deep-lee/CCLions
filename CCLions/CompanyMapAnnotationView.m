//
//  CompanyMapAnnotationView.m
//  CCLions
//
//  Created by 李冬 on 6/10/16.
//  Copyright © 2016 李冬. All rights reserved.
//

#import "CompanyMapAnnotationView.h"

#define kCalloutWidth       200.0
#define kCalloutHeight      70.0

@interface CompanyMapAnnotationView ()

@property (nonatomic, strong, readwrite) CompanyMapCalloutView *calloutView;

@end

@implementation CompanyMapAnnotationView


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    if (selected)
    {
        if (self.calloutView == nil)
        {
            self.calloutView = [[CompanyMapCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
        }
        
        self.calloutView.companyName = self.annotation.title;
        self.calloutView.companyAddress = self.annotation.subtitle;
        
        [self addSubview:self.calloutView];
    }
    else
    {
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
