//
//  AdImageCollctionCell.h
//  LJCycleScrollView
//
//  Created by lijun on 2018/4/2.
//  Copyright © 2018年 lijun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LJAdImageInfo.h"

@interface AdImageCollctionCell : UICollectionViewCell

- (void)updataCellWithModel:(LJAdImageInfo *)info atIndex:(NSUInteger)index;

@end
