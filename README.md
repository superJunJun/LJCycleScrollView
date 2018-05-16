# LJCycleScrollView
自定义两种轮播图的实现方式+自定义UIPageControl
# 具体实现
-------------------------------------------------------------
第一种UIScrollView添加三张UIImageView，一直显示中间视图，变化源数据。

第二种 使用UICollectionView，保持行数为DataArray.count+2，UICollectionView有自己的复用回收机制，不需要我们担心
