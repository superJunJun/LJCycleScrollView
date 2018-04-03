//
//  LJPageControl.m
//  LJCycleScrollView
//
//  Created by lijun on 2018/4/3.
//  Copyright © 2018年 lijun. All rights reserved.
//

#import "LJPageControl.h"

@implementation LJPageControl

-(instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
       
        //        pageControl.transform=CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
        self.currentPageIndicatorTintColor = [UIColor redColor];
        [self addTarget:self action:@selector(pagecontrrolClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [super setCurrentPage:currentPage];
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:-20 options:UIViewAnimationOptionCurveLinear animations:^{
        self.backgroundColor = [UIColor whiteColor];
        self.transform = CGAffineTransformMakeScale(1.4, 1.4);
    } completion:nil];
}

- (void)layoutSubviews {
    self
}

@end
