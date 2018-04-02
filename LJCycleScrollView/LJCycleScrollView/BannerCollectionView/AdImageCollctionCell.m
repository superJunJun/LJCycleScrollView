//
//  AdImageCollctionCell.m
//  LJCycleScrollView
//
//  Created by lijun on 2018/4/2.
//  Copyright © 2018年 lijun. All rights reserved.
//

#import "AdImageCollctionCell.h"

@interface AdImageCollctionCell()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLable;
@end

@implementation AdImageCollctionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUpSubView];
    }
    return self;
}

- (void)setUpSubView
{
    self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.imageView];
    
    self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 100, 100, 30)];
    [self.contentView addSubview:self.titleLable];
}

- (void)updataCellWithModel:(LJAdImageInfo *)info atIndex:(NSUInteger)index {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:info.imgPath] placeholderImage:[UIImage imageNamed:@"home_banner_default"]];

}

@end
