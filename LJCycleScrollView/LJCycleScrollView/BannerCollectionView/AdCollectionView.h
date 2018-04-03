//
//  AdCollectionView.h
//  LJCycleScrollView
//
//  Created by lijun on 2018/4/2.
//  Copyright © 2018年 lijun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LJPageControl.h"

@interface AdCollectionView : UIView

@property (nonatomic, strong) NSMutableArray *adImageDataArray;
@property (weak, nonatomic) NSTimer *bannerTimer;
@property (nonatomic, assign)  NSTimeInterval automaticallyScrollDuration;

@end
