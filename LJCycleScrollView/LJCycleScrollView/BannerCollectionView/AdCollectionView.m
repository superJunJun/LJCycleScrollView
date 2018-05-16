//
//  AdCollectionView.m
//  LJCycleScrollView
//
//  Created by lijun on 2018/4/2.
//  Copyright © 2018年 lijun. All rights reserved.
//

#import "AdCollectionView.h"
#import "AdImageCollctionCell.h"
#import "LJPageControl.h"

#define  scrollviewHeight       AdaptH(130)
#define  pageControlHeight      scrollviewHeight / 4.5

@interface AdCollectionView()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
/**当前滚动的位置*/
@property (nonatomic, assign)  NSInteger currentIndex;
///**上次滚动的位置*/
//@property (nonatomic, assign)  NSInteger lastIndex;

/**新构造的model数组*/
@property (nonatomic, strong) NSMutableArray *adImageDataArrayFixed;

@property (nonatomic, strong) LJPageControl *adPageControl;

@end

@implementation AdCollectionView

- (instancetype)init {
    if (self = [super init]) {
        [self setUpCycle];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUpCycle];
        _adImageDataArray = [NSMutableArray new];
        _adImageDataArrayFixed = [NSMutableArray new];
    }
    return self;
}

- (void)setUpCycle {
    [self addSubview:self.collectionView];
    
    [self addSubview:self.adPageControl];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = CGSizeMake(KSCREEWIDTH, AdaptH(130));
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, KSCREEWIDTH, AdaptH(130)) collectionViewLayout:layout];
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[AdImageCollctionCell class] forCellWithReuseIdentifier:NSStringFromClass([AdImageCollctionCell class])];
        
    }
    return _collectionView;
}

- (LJPageControl *)adPageControl
{
    if (!_adPageControl) {
        _adPageControl = [[LJPageControl alloc]initWithFrame:CGRectMake(0, scrollviewHeight - pageControlHeight, KSCREEWIDTH, pageControlHeight)];
    }
    return _adPageControl;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    
//    //默认滚动到第一张图片
//    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
//    [self scrollToIndexPath:indexPath animated:NO];
}
#pragma mark 构造新的图片数组

- (void)setAdImageDataArray:(NSMutableArray *)adImageDataArray {
    if (_adImageDataArray != adImageDataArray) {
        
        NSMutableArray *adImageInfoArr = [self analysisData:adImageDataArray];
        _adImageDataArray = adImageInfoArr;
        
        self.adPageControl.numberOfPages = _adImageDataArray.count;
        [self fixNewImageDataArr];
        self.currentIndex = 1;
        [self.collectionView reloadData];
        [self scrollToIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO];
    }
}

- (NSMutableArray *)analysisData:(NSMutableArray *)dataArr {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *news in dataArr) {
        LJAdImageInfo *imageModel = [LJAdImageInfo yy_modelWithJSON:news];
        [tempArray addObject:imageModel];
    }
    return tempArray;
}

- (void)fixNewImageDataArr {
    LJAdImageInfo *infoLast = _adImageDataArray.lastObject;
    LJAdImageInfo *infoFirst = _adImageDataArray.firstObject;
    
    NSMutableArray *tempArr = _adImageDataArray.mutableCopy;
    [tempArr insertObject:infoLast atIndex:0];
    [tempArr addObject:infoFirst];
    _adImageDataArrayFixed = tempArr;
}

#pragma mark 自动滚动时间设置
- (void)setAutomaticallyScrollDuration:(NSTimeInterval)automaticallyScrollDuration
{
    _automaticallyScrollDuration = automaticallyScrollDuration;
    if (_automaticallyScrollDuration > 0)
    {
        [self.bannerTimer invalidate];
        self.bannerTimer = nil;
        NSTimer *timer = [NSTimer timerWithTimeInterval:self.automaticallyScrollDuration target:self selector:@selector(startScrollAutomtically) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        self.bannerTimer = timer;
    }
    else
    {
        [self.bannerTimer invalidate];
    }
}

#pragma mark 自动滚动
- (void)startScrollAutomtically {
    NSInteger currentIndex = self.currentIndex + 1;
    currentIndex = (currentIndex == _adImageDataArrayFixed.count) ? 1 : currentIndex;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentIndex inSection:0];
    BOOL isNeedAnim = self.automaticallyScrollDuration <= 0.3 ? NO : YES;
    [self scrollToIndexPath:indexPath animated:isNeedAnim];
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    if (indexPath.row < _adImageDataArrayFixed.count)
    {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
    }
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AdImageCollctionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([AdImageCollctionCell class]) forIndexPath:indexPath];
    LJAdImageInfo *imageInfo = _adImageDataArrayFixed[indexPath.row];
    [cell updataCellWithModel:imageInfo atIndex:indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _adImageDataArrayFixed.count;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
//    CGFloat width = self.frame.size.width;
    NSInteger index = scrollView.contentOffset.x / KSCREEWIDTH;
    //当滚动到最后一张图片时，继续滚向后动跳到第一张
    if (index == self.adImageDataArray.count + 1)
    {
        self.currentIndex = 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        [self scrollToIndexPath:indexPath animated:NO];
        return;
    } else if (index == 0)
    {//当滚动到第一张图片时，继续向前滚动跳到最后一张
        self.currentIndex = self.adImageDataArray.count;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        [self scrollToIndexPath:indexPath animated:NO];
        return;
    } else {
        self.currentIndex = index;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([self.delegate respondsToSelector:@selector(carouselView:didSelectItemAtIndex:)])
//    {
//        [self.delegate carouselView:self didSelectItemAtIndex:self.currentIndex];
//    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //关闭自动滚动
    [self.bannerTimer invalidate];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.automaticallyScrollDuration > 0)
    {
        [self.bannerTimer invalidate];
        self.bannerTimer = nil;
        NSTimer *timer = [NSTimer timerWithTimeInterval:self.automaticallyScrollDuration target:self selector:@selector(startScrollAutomtically) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.bannerTimer = timer;
    }
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return self.frame.size;
//}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    
    if (_currentIndex < self.adImageDataArrayFixed.count)
    {
        NSInteger index = _currentIndex > 0 ? _currentIndex - 1 : _adImageDataArray.count - 1;
        self.adPageControl.currentPage = index;
        
        return;
    }
    
}


@end
