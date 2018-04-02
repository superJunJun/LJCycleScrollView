//
//  LJAdImageView.h
//  LJCycleScrollView
//
//  Created by lijun on 2018/4/2.
//  Copyright © 2018年 lijun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJAdImageView : UIView

@property (nonatomic, strong) UIScrollView  *adScrollView;
@property (nonatomic, strong) UIPageControl *adPageControl;
@property (nonatomic, strong) NSMutableArray *adImageDataArray;

@property (weak, nonatomic) NSTimer *bannerTimer;

@end
