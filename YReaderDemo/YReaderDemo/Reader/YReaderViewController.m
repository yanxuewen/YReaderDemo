//
//  YReaderViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/11.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YReaderViewController.h"
#import "YReadPageViewController.h"
#import "YDirectoryViewController.h"
#import "YPageBackViewController.h"
#import "YMenuViewController.h"
#import "YReaderManager.h"
#import "YNetworkManager.h"
#import "YReaderSettings.h"
#import "YSummaryViewController.h"

@interface YReaderViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) YReaderManager *readerManager;
@property (strong, nonatomic) YNetworkManager *netManager;
@property (assign, nonatomic) NSUInteger chapter;
@property (assign, nonatomic) NSUInteger page;
@property (strong, nonatomic) YMenuViewController *menuView;

@property (strong, nonatomic) YDirectoryViewController *directoryVC;
@property (strong, nonatomic) YSummaryViewController *summaryVC;
@property (assign, nonatomic) BOOL isPageBefore;//记录向前/后翻页,改变章节时用,
@property (strong, nonatomic) YReaderSettings *settings;
@property (assign, nonatomic) BOOL isPageCurlStyle;

@end

@implementation YReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _netManager = [YNetworkManager shareManager];
    _readerManager = [YReaderManager shareReaderManager];
    _settings = [YReaderSettings shareReaderSettings];
    [self readerSettingsUpdate];
    __weak typeof(self) wself = self;
    
    [YProgressHUD showLoadingHUD];
    self.view.userInteractionEnabled = NO;
    [[YProgressHUD shareProgressHUD] setCancelAction:^{
        [wself.readerManager cancelLoadReadingBook];
    }];
    
    self.readerManager.cancelLoadingCompletion = ^ {
        [YProgressHUD hideLoadingHUD];
        [wself.readerManager closeReadingBook];
        [wself dismissViewControllerAnimated:YES completion:nil];
    };
    
    [_readerManager updateReadingBook:_readingBook completion:^{
        wself.view.userInteractionEnabled = YES;
        [wself setupPageViewController];
        [YProgressHUD hideLoadingHUD];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.readerManager updateBookChaptersLink];
        });
    } failure:^(NSString *msg) {
        DDLogWarn(@"updateReadingBook error msg %@",msg);
        [YProgressHUD showErrorHUDWith:msg];
        [wself.readerManager closeReadingBook];
        [wself dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self setupMenuView];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        
        [wself.menuView showMenuView];
        [wself.readerManager updateReadingChapter:wself.chapter page:wself.page];
    }]];
    
    //Enter Background Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - menu view
- (void)setupMenuView {
    __weak typeof(self) wself = self;
    self.menuView = [[YMenuViewController alloc] init];
    self.menuView.view.frame = self.view.bounds;
    [self.view addSubview:self.menuView.view];
    self.menuView.view.hidden = YES;
    self.menuView.menuTapAction = ^(NSInteger tag) {
        switch (tag) {
            case 100: {          //换源
                [wself presentViewController:wself.summaryVC animated:YES completion:nil];
            }
                break;
            case 101:           //播放
                
                break;
            case 102: {          //关闭
                [wself dismissViewControllerAnimated:YES completion:^{
                    [wself.readerManager updateReadingChapter:wself.chapter page:wself.page];
                    [wself.readerManager closeReadingBook];
                }];
            }
                break;
            case 202: {          //目录
                [wself presentViewController:wself.directoryVC animated:YES completion:nil];
            }
                break;
            default:
                break;
        }
    };
}

- (void)setupPageViewController {
    if (_pageViewController) {
        [_pageViewController.view removeFromSuperview];
        [_pageViewController removeFromParentViewController];
        _pageViewController = nil;
    }
    
    UIPageViewControllerTransitionStyle style= _isPageCurlStyle ? UIPageViewControllerTransitionStylePageCurl : UIPageViewControllerTransitionStyleScroll;
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:style navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    if (_isPageCurlStyle) {
        _pageViewController.doubleSided = YES;
    }
    _pageViewController.view.frame = self.view.bounds;
    [self addChildViewController:_pageViewController];
    [self.view insertSubview:_pageViewController.view belowSubview:self.menuView.view];
    _page = _readerManager.record.readingPage;
    _chapter = _readerManager.record.readingChapter;
    __weak typeof(self) wself = self;
    [_pageViewController setViewControllers:@[[self readPageViewWithChapter:_chapter page:_page]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        if (finished && !wself.isPageCurlStyle) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.pageViewController setViewControllers:@[[wself readPageViewWithChapter:wself.chapter page:wself.page]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            });
        }
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.readerManager autoLoadNextChapters:self.chapter+1];
    });
}

- (void)readerSettingsUpdate {
    __weak typeof(self) wself = self;
    [[YReaderSettings shareReaderSettings] setRefreshReaderView:^{
        [wself updateReaderChapter:wself.chapter page:wself.page];
    }];
    [[YReaderSettings shareReaderSettings] setRefreshPageStyle:^{
        wself.isPageCurlStyle = wself.settings.pageStyle == YTurnPageStylePageCurl;
        [wself setupPageViewController];
    }];
    _isPageCurlStyle = _settings.pageStyle == YTurnPageStylePageCurl;
}

#pragma mark - 更新章节
- (void)updateReaderChapter:(NSUInteger)chapter page:(NSUInteger)page{
    if (chapter >= self.readerManager.chaptersArr.count) {
        DDLogError(@"updateReaderChapter chapter >= self.readerManager.chaptersArr.count  \n readerManager:%@",self.readerManager);
        return;
    }
    YChapterContentModel *chapterM = self.readerManager.chaptersArr[chapter];
    if (chapterM.isLoad) {
        [chapterM updateContentPaging];
        [self reloadReaderPageViewControllerWith:chapter page:page];
    } else {
        __weak typeof(self) wself = self;
        [YProgressHUD showLoadingHUD];
        [[YProgressHUD shareProgressHUD] setCancelAction:^{
            [wself.readerManager cancelGetChapterContent];
        }];
        self.view.userInteractionEnabled = NO;
        [self.readerManager getChapterContentWith:chapter completion:^{
            wself.view.userInteractionEnabled = YES;
            [YProgressHUD hideLoadingHUD];
            [wself reloadReaderPageViewControllerWith:chapter page:page];
        } failure:^(NSString *msg) {
            wself.view.userInteractionEnabled = YES;
            [YProgressHUD hideLoadingHUD];
            [YProgressHUD showErrorHUDWith:msg];
        }];
        self.readerManager.cancelGetChapterCompletion = ^ {
            wself.view.userInteractionEnabled = YES;
            [YProgressHUD hideLoadingHUD];
        };
    }
    
}

- (void)reloadReaderPageViewControllerWith:(NSUInteger)chapter page:(NSUInteger)page {
    YChapterContentModel *chapterM = self.readerManager.chaptersArr[chapter];
    if (_isPageBefore || page >= chapterM.pageCount) {
        page = chapterM.pageCount - 1;
    }
    self.chapter = chapter;
    self.page = page;
    __weak typeof(self) wself = self;
    [self.pageViewController setViewControllers:@[[self readPageViewWithChapter:self.chapter page:self.page]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
        if (finished && !wself.isPageCurlStyle) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.pageViewController setViewControllers:@[[wself readPageViewWithChapter:wself.chapter page:wself.page]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            });
        }
    }];
    [self.readerManager updateReadingChapter:chapter page:page];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.readerManager autoLoadNextChapters:self.chapter+1];
    });
}

- (YReadPageViewController *)readPageViewWithChapter:(NSUInteger)chapter page:(NSUInteger)page {
    YReadPageViewController *readPageVC = [[YReadPageViewController alloc] init];
    readPageVC.page = page;
    readPageVC.chapter = chapter;
    YChapterContentModel *chapterM = _readerManager.chaptersArr[chapter];
    if (chapter != _chapter) {
        [chapterM updateContentPaging];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.readerManager autoLoadNextChapters:chapter+1];
        });
    }
    readPageVC.pageContent = [chapterM getStringWith:page];
    readPageVC.totalPage = chapterM.pageCount;
    readPageVC.booktitle = chapterM.title;
    return readPageVC;
}

#pragma mark - pageViewController delegate
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    if ( _chapter == 0 && _page == 0) {
        DDLogInfo(@"已经是第一页");
        [YProgressHUD showErrorHUDWith:@"已经是第一页"];
        return nil;
    }
    
    YReadPageViewController *pageVC = (YReadPageViewController *)viewController;
    NSUInteger page = pageVC.page;
    NSUInteger chapter = pageVC.chapter;
    if (_isPageCurlStyle) {
        page = _page;
        chapter = _chapter;
    }
    if (page > 0) {
        page = page - 1;
    } else {
        chapter = chapter - 1;
        YChapterContentModel *chapterM = _readerManager.chaptersArr[chapter];
        if (chapterM.pageCount == 0) {
            [chapterM updateContentPaging];
        }
        page = chapterM.pageCount - 1;
    }
    
    return [self readPageViewWithChapter:chapter page:page];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (_chapter == _readerManager.chaptersArr.count - 1 && _page == [_readerManager.chaptersArr.lastObject pageCount] - 1) {
        DDLogInfo(@"已经是最后一页");
        [YProgressHUD showErrorHUDWith:@"已经是最后一页"];
        return nil;
    }
    
//    if ([viewController isKindOfClass:[YReadPageViewController class]]) {
//        YPageBackViewController *backVC = [[YPageBackViewController alloc] init];
//        [backVC updateBackViewWith:viewController.view];
//        return backVC;//翻页背面,但效果没写好,先这样
//    }
    
    YReadPageViewController *pageVC = (YReadPageViewController *)viewController;
    NSUInteger page = pageVC.page;
    NSUInteger chapter = pageVC.chapter;
    if (_isPageCurlStyle) {
        page = _page;
        chapter = _chapter;
    }
    if (page >= [_readerManager.chaptersArr[chapter] pageCount] - 1) {
        page = 0;
        chapter = chapter + 1;
    } else {
        page = page + 1;
    }
    
    return [self readPageViewWithChapter:chapter page:page];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    NSLog(@"%s",__func__);
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    NSLog(@"%s  completed:%zi",__func__,completed);
    
    if (!completed) {
        YReadPageViewController *readerPageVC = (YReadPageViewController *)previousViewControllers.firstObject;
        _page = readerPageVC.page;
        _chapter = readerPageVC.chapter;
    } else {
        YReadPageViewController *previousPageVC = (YReadPageViewController *)previousViewControllers.firstObject;
        YReadPageViewController *readPageVC = (YReadPageViewController *)pageViewController.viewControllers.firstObject;
        if (readPageVC.chapter > previousPageVC.chapter || (readPageVC.chapter == previousPageVC.chapter && readPageVC.page > previousPageVC.page)) {
            _isPageBefore = NO;
        } else {
            _isPageBefore = YES;;
        }
        _page = readPageVC.page;
        _chapter = readPageVC.chapter;
        YChapterContentModel *chapterM = self.readerManager.chaptersArr[self.chapter];
        if (!chapterM.isLoad) {
            [self updateReaderChapter:self.chapter page:self.page];
        }
    }
}

- (void)appDidEnterBackgroundNotification:(NSNotification *)noti {
    NSLog(@"%s",__func__);
    [self.readerManager updateReadingChapter:_chapter page:_page];
}

#pragma mark - 选择章节页面
- (YDirectoryViewController *)directoryVC {
    if (!_directoryVC) {
        _directoryVC = [[YDirectoryViewController alloc] init];
        __weak typeof(self) wself = self;
        _directoryVC.selectChapter = ^(NSUInteger chapter) {
            wself.isPageBefore = NO;
            [wself updateReaderChapter:chapter page:0];
        };
    }
    _directoryVC.chaptersArr = self.readerManager.chaptersArr;
    _directoryVC.readingChapter = self.chapter;
    return _directoryVC;
}

#pragma mark - 更新来源
- (YSummaryViewController *)summaryVC {
    if (!_summaryVC) {
        _summaryVC = [[YSummaryViewController alloc] init];
        __weak typeof(self) wself = self;
        _summaryVC.updateSelectSummary = ^(YBookSummaryModel *summary){
            [wself updateReaderBookSummary:summary];
        };
    }
    _summaryVC.bookM = self.readingBook;
    _summaryVC.summaryM = self.readerManager.selectSummary;
    return _summaryVC;
}

- (void)updateReaderBookSummary:(YBookSummaryModel *)summaryM {
    __weak typeof(self) wself = self;
    [YProgressHUD showLoadingHUD];
    self.view.userInteractionEnabled = NO;
    [[YProgressHUD shareProgressHUD] setCancelAction:^{
        [wself.readerManager cancelLoadReadingBook];
    }];
    
    self.readerManager.cancelLoadingCompletion = ^ {
        [YProgressHUD hideLoadingHUD];
        [wself.readerManager closeReadingBook];
        [wself dismissViewControllerAnimated:YES completion:nil];
    };
    
    [self.readerManager updateBookSummary:summaryM completion:^{
        [YProgressHUD hideLoadingHUD];
        wself.view.userInteractionEnabled = YES;
        [wself updateReaderChapter:wself.readerManager.record.readingChapter page:wself.readerManager.record.readingPage];
        [wself.readerManager updateReadingChapter:wself.chapter page:wself.page];
    } failure:^(NSString *msg) {
        [YProgressHUD hideLoadingHUD];
        [YProgressHUD showErrorHUDWith:msg];
        [wself.readerManager closeReadingBook];
        [wself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
