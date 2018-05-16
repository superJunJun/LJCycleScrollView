//
//  LJAdImageView.m
//  LJCycleScrollView
//
//  Created by lijun on 2018/4/2.
//  Copyright © 2018年 lijun. All rights reserved.
//

#import "LJAdImageView.h"
#import "LJAdImageInfo.h"
#import "LJPageControl.h"

#define  pageControlHeight      _scrollviewHeight / 4.5

@interface LJAdImageView()<UIScrollViewDelegate>
{
    NSInteger _scrollviewHeight;
    NSMutableArray *_imageViewArr;
}

@property (nonatomic, assign) NSUInteger currentImageIndex;

@property (nonatomic, strong) UIScrollView  *adScrollView;

@property (nonatomic, strong) LJPageControl *adPageControl;

@property (nonatomic, weak) NSTimer *bannerTimer;

@end

@implementation LJAdImageView

- (instancetype)init
{
    if(self = [super init])
    {
        _scrollviewHeight = AdaptH(130);
        self.adImageDataArray = @[].mutableCopy;
        
        UIScrollView *adScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KSCREEWIDTH, _scrollviewHeight)];
        adScrollView.backgroundColor = [UIColor clearColor];
        adScrollView.contentSize = CGSizeMake(KSCREEWIDTH * 3, _scrollviewHeight);
        adScrollView.contentOffset = CGPointMake(KSCREEWIDTH, 0);
        adScrollView.pagingEnabled = YES;
        adScrollView.scrollEnabled = YES;
        adScrollView.bounces = NO;
        adScrollView.showsHorizontalScrollIndicator = NO;
        adScrollView.delegate = self;
        [self addSubview:adScrollView];
        self.adScrollView = adScrollView;
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
//        [adScrollView addGestureRecognizer:tap];
        
        _imageViewArr = @[].mutableCopy;
        for (int i = 0; i < 3; i++) {
            UIImageView *adImageView = [UIImageView new];
            adImageView.image = [UIImage imageNamed:@"home_banner_default"];
            adImageView.frame = CGRectMake(KSCREEWIDTH * i,0, KSCREEWIDTH, _scrollviewHeight);
            [self.adScrollView addSubview:adImageView];
            [_imageViewArr addObject:adImageView];
        }
        
        LJPageControl *pageControl = [[LJPageControl alloc]initWithFrame:CGRectMake(0, _scrollviewHeight - pageControlHeight, KSCREEWIDTH, pageControlHeight)];
        [pageControl addTarget:self action:@selector(pagecontrrolClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pageControl];
        self.adPageControl = pageControl;
    }
    return self;
}

- (void)setAdImageDataArray:(NSMutableArray *)adImageDataArray {
    if (adImageDataArray.count > 0) {
        
        NSMutableArray *adImageInfoArr = [self analysisData:adImageDataArray];
        [self resetPageControl:adImageInfoArr.count];
        
        _adImageDataArray = @[].mutableCopy;
        _adImageDataArray = adImageInfoArr;
        [self fixArray:adImageDataArray];
    }
}
- (void)resetPageControl:(NSInteger )count {
    _adPageControl.numberOfPages = count;
    CGSize pointSize = [_adPageControl sizeForNumberOfPages:count];
    _adPageControl.size = pointSize;
    _adPageControl.center = CGPointMake(KSCREEWIDTH / 2.0, (_scrollviewHeight - pageControlHeight) + pageControlHeight / 2);
}

- (NSMutableArray *)analysisData:(NSMutableArray *)dataArr {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *news in dataArr) {
        LJAdImageInfo *imageModel = [LJAdImageInfo yy_modelWithJSON:news];
        [tempArray addObject:imageModel];
    }
    return tempArray;
}

- (void)fixArray:(NSArray *)adImageViewArr{
    
    NSMutableArray *tempArr = [adImageViewArr mutableCopy];
    if (tempArr.count == 1) {
        UIImageView *imageView1 = _imageViewArr[1];
        LJAdImageInfo *centerImageInfo = _adImageDataArray[0];
        [imageView1 sd_setImageWithURL:[NSURL URLWithString:centerImageInfo.imgPath] placeholderImage:[UIImage imageNamed:@"home_banner_default"]];
    }else {
        [self ReloadImage];
        [self settimer];
    }
    
}
- (void)pagecontrrolClick:(UIPageControl *)sender{
    NSInteger page = sender.currentPage;
    [self.adScrollView setContentOffset:CGPointMake(KSCREEWIDTH * page, 0) animated:YES];
}

#pragma mark  - ScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //调用重新加载图片的方法
    
    [self ReloadImage];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    NSLog(@"开始拖动");
    [_bannerTimer invalidate];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    NSLog(@"拖动结束");
    [self settimer];
}

-(void)ReloadImage{
    
    NSInteger sourceArrCount = self.adImageDataArray.count;
    CGPoint offset=[_adScrollView contentOffset];//内容视图的位置
    if (offset.x>KSCREEWIDTH) {//右滑
        _currentImageIndex=(_currentImageIndex + 1)% sourceArrCount;
    }
    if (offset.x < KSCREEWIDTH) {//左滑
        _currentImageIndex=(_currentImageIndex +(sourceArrCount-1))%sourceArrCount;
    }
    
    [self reloadImages];
}

- (void)reloadImages {
    NSInteger sourceArrCount = self.adImageDataArray.count;
    UIImageView *leftImageView = _imageViewArr[0];
    UIImageView *centerImageView = _imageViewArr[1];
    UIImageView *rightImageView = _imageViewArr[2];
    NSInteger leftImageIndex = (_currentImageIndex + sourceArrCount -1) % sourceArrCount;
    NSInteger rightImageIndex = (_currentImageIndex +1)%sourceArrCount;
    
    LJAdImageInfo *centerImageInfo = _adImageDataArray[_currentImageIndex];
    [centerImageView sd_setImageWithURL:[NSURL URLWithString:centerImageInfo.imgPath] placeholderImage:[UIImage imageNamed:@"home_banner_default"]];
    //移动到中间
    [_adScrollView setContentOffset:CGPointMake(KSCREEWIDTH,0)];
    _adPageControl.currentPage=_currentImageIndex;
    
    
    LJAdImageInfo *leftImageInfo = _adImageDataArray[leftImageIndex];
    [leftImageView sd_setImageWithURL:[NSURL URLWithString:leftImageInfo.imgPath] placeholderImage:[UIImage imageNamed:@"home_banner_default"]];
    
    LJAdImageInfo *rightImageInfo = _adImageDataArray[rightImageIndex];
    [rightImageView sd_setImageWithURL:[NSURL URLWithString:rightImageInfo.imgPath] placeholderImage:[UIImage imageNamed:@"home_banner_default"]];
}

-(void)settimer{
    if ([_bannerTimer isValid]) {
        [_bannerTimer invalidate];
    }
    _bannerTimer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timechanged)userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop]addTimer:_bannerTimer forMode:NSRunLoopCommonModes];
}

-(void)timechanged{
    
    [_adScrollView setContentOffset:CGPointMake(self.adScrollView.contentOffset.x + KSCREEWIDTH, 0) animated:YES] ;
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSInteger sourceArrCount = self.adImageDataArray.count;
    _currentImageIndex = (_currentImageIndex + 1) % sourceArrCount;;
   
    [self reloadImages];
}


//#pragma mark - tap 路由跳转
- (void)tap {
//    NSDictionary *searchDic = @{@"recName":recName, @"fullPartMark":@(1)};
//    NSString *url = [NSString stringWithFormat:@"RouteOne://push/ASGStudenPartTimeJobController?searchDic=%@&isPartTimeJob=%@",searchDic,@(self.isPartTimeJob)];
//    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];

    
}

@end
