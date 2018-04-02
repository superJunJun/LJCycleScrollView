//
//  AdCollectionView.m
//  LJCycleScrollView
//
//  Created by lijun on 2018/4/2.
//  Copyright © 2018年 lijun. All rights reserved.
//

#import "AdCollectionView.h"
#import "AdImageCollctionCell.h"

@interface AdCollectionView()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
/**当前滚动的位置*/
@property (nonatomic, assign)  NSInteger currentIndex;
/**上次滚动的位置*/
@property (nonatomic, assign)  NSInteger lastIndex;

/**新构造的model数组*/
@property (nonatomic, strong) NSMutableArray *AdImageDataArray2;

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
        _AdImageDataArray2 = [NSMutableArray new];
    }
    return self;
}

- (void)setUpCycle {
    [self addSubview:self.collectionView];
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


#pragma mark 构造新的图片数组

- (void)setAdImageDataArray:(NSMutableArray *)adImageDataArray {
    if (_adImageDataArray != adImageDataArray) {
        _adImageDataArray = adImageDataArray;
        if (adImageDataArray) {
            LJAdImageInfo *infoLast = adImageDataArray.lastObject;
            LJAdImageInfo *infoFirst = adImageDataArray.firstObject;

            [adImageDataArray insertObject:infoLast atIndex:0];
            [adImageDataArray addObject:infoFirst];
            _AdImageDataArray2 = adImageDataArray;
        }
        [self.collectionView reloadData];
        
//        [self settimer];
    }
}

#pragma mark - UICollectionViewDataSource
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
- (void)startScrollAutomtically
{
    NSInteger currentIndex = self.currentIndex + 1;
    currentIndex = (currentIndex == self.AdImageDataArray2.count) ? 1 : currentIndex;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentIndex inSection:0];
    BOOL isNeedAnim = self.automaticallyScrollDuration <= 0.3 ? NO : YES;
    [self scrollToIndexPath:indexPath animated:isNeedAnim];
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    if (self.AdImageDataArray2.count > indexPath.row)
    {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    
    //默认滚动到第一张图片
    if (self.collectionView.contentOffset.x == 0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        [self scrollToIndexPath:indexPath animated:NO];
        self.currentIndex = 1;
    }
}

#pragma mark 代理方法

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AdImageCollctionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([AdImageCollctionCell class]) forIndexPath:indexPath];
    LJAdImageInfo *imageInfo = self.adImageDataArray[indexPath.row];
    [cell updataCellWithModel:imageInfo atIndex:indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.AdImageDataArray2.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = self.frame.size.width;
    NSInteger index = (scrollView.contentOffset.x + width * 0.5) / width;
    //当滚动到最后一张图片时，继续滚向后动跳到第一张
    if (index == self.adImageDataArray.count + 1)
    {
        self.currentIndex = 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        [self scrollToIndexPath:indexPath animated:NO];
        return;
    }
    
    //当滚动到第一张图片时，继续向前滚动跳到最后一张
    if (scrollView.contentOffset.x < width * 0.5)
    {
        self.currentIndex = self.adImageDataArray.count;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        [self scrollToIndexPath:indexPath animated:NO];
        return;
    }
    
    //避免多次调用currentIndex的setter方法
    if (self.currentIndex != self.lastIndex)
    {
        self.currentIndex = index;
    }
    self.lastIndex = index;
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
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        self.bannerTimer = timer;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.frame.size;
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    
    if (_currentIndex < self.adImageDataArray.count + 1)
    {
        //        NSLog(@"%zd",currentIndex);
        NSInteger index = _currentIndex > 0 ? _currentIndex - 1 : 0;
//        self.pageControlView.currentPage = index;
//
//        self.titleLabel.hidden = !self.titles.count;
//        if (self.titles.count > index)
//        {
//            self.titleLabel.text = self.titles[index];
//        }
        
        return;
    }
    
}

- (void)setadImageDataArray:(NSArray *)adImageDataArray
{
    _adImageDataArray = adImageDataArray;
    
    [self.collectionView reloadData];
//    self.pageControlView.hidden = !_adImageDataArray.count;
//    self.pageControlView.numberOfPages = _adImageDataArray.count;
}

//- (ADPageControlView *)pageControlView
//{
//    if (!_pageControlView) {
//        _pageControlView = [ADPageControlView pageControlViewWithFrame:CGRectZero];
//        [self addSubview:_pageControlView];
//    }
//    return _pageControlView;
//}

//- (UILabel *)titleLabel
//{
//    if (!_titleLabel)
//    {
//        _titleLabel = [[UILabel alloc] init];
//        [self addSubview:_titleLabel];
//    }
//    return _titleLabel;
//}

@end
