//
//  ViewController.m
//  LJCycleScrollView
//
//  Created by lijun on 2018/4/2.
//  Copyright © 2018年 lijun. All rights reserved.
//

#import "ViewController.h"
#import "LJAdImageView.h"
#import "LJAdImageInfo.h"
#import "AdCollectionView.h"

@interface ViewController ()

@property (nonatomic, strong) LJAdImageView *adScrollView;
@property (nonatomic, strong) AdCollectionView *adCollectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self creatScrollCycleUI];
//    [self creatColectionCycleUI];
    [self loadData];
    
}

- (void)creatScrollCycleUI {
    self.view.backgroundColor = [UIColor grayColor];

    self.adScrollView = [[LJAdImageView alloc]init];
    self.adScrollView.frame = CGRectMake(0, 100, KSCREEWIDTH, AdaptH(130));
    [self.view addSubview:self.adScrollView];
}

- (void)creatColectionCycleUI {
    
    self.adCollectionView = [[AdCollectionView alloc]initWithFrame:CGRectMake(0, 330, KSCREEWIDTH, AdaptH(130))];
    [self.view addSubview:self.adCollectionView];
}

- (void)loadData {
    NSString *urlString = @"http://asgapi.99zmall.com/asg/mobile/banner/list.action";
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/xml", @"text/xml",@"text/plain",@"application/json",@"text/html",nil];
    
    [manager POST:urlString parameters:@{@"identify":@(0)} progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers
            error:nil];
        NSLog(@"返回结果：%@*************************************", data);
        if (data) {
            NSDictionary *contentDic = [data objectForKey:@"contents"];
            NSArray *banner_list = [contentDic objectForKey:@"rows"];
//            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
            
            self.adScrollView.adImageDataArray = banner_list.mutableCopy;
            self.adCollectionView.adImageDataArray = banner_list.mutableCopy;

//            for (NSDictionary *news in banner_list) {
//                LJAdImageInfo *imageModel = [LJAdImageInfo yy_modelWithJSON:news];
//                [tempArray addObject:imageModel];
//            }
//            self.adScrollView.adImageDataArray = tempArray;
//            self.adCollectionView.adImageDataArray = tempArray;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

@end
