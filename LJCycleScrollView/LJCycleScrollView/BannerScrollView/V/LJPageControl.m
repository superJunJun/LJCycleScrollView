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
        [self setValue:[UIImage imageNamed:@"white"] forKeyPath:@"_pageImage"];
        [self setValue:[UIImage imageNamed:@"red"] forKeyPath:@"_currentPageImage"];
    }
    return self;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [super setCurrentPage:currentPage];
    
    for (UIImageView *imageView in self.subviews) {
        NSInteger index = [self.subviews indexOfObject:imageView];
        if (index == currentPage) {
            [self setValue:[UIImage imageNamed:@"red"] forKeyPath:@"_currentPageImage"];
        }else {
            [self setValue:[UIImage imageNamed:@"white"] forKeyPath:@"_pageImage"];
        }
        CGPoint center = imageView.center;
        [UIView animateWithDuration:0.1 animations:^{
            [imageView sizeToFit];
            imageView.center = center;
        }];
    }
}

@end
