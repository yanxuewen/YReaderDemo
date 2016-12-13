//
//  YReaderViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/11.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YReaderViewController.h"
#import "YReadPageViewController.h"
#import "YTestViewController.h"
#import "YBottomButton.h"

@interface YReaderViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) UIPageViewController *pageViewController;

@end

@implementation YReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    [self setupPageViewController];
}

- (void)setupPageViewController {
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    _pageViewController.view.frame = self.view.bounds;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
    [_pageViewController setViewControllers:@[[self readPageViewWithChapter:0 page:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (YTestViewController *)readPageViewWithChapter:(NSUInteger)chapter page:(NSUInteger)page {
    YTestViewController *readPageVC = [[YTestViewController alloc] init];
    
    return readPageVC;
}

- (void)setupUI {
    NSArray *imgArr = @[@"night_mode",@"feedback",@"directory",@"preview_btn",@"reading_setting"];
    NSArray *titleArr = @[@"夜间",@"反馈",@"目录",@"缓存",@"设置"];
    for (NSInteger i = 0; i < imgArr.count; i++) {
        YBottomButton *btn = [YBottomButton bottonWith:titleArr[i] imageName:imgArr[i] tag:i];
        [self.bottomView addSubview:btn];
    }
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    return [self readPageViewWithChapter:0 page:0];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    return [self readPageViewWithChapter:0 page:0];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    NSLog(@"%s",__func__);
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    NSLog(@"%s",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
