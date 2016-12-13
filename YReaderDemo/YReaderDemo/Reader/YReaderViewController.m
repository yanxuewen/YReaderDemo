//
//  YReaderViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/11.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YReaderViewController.h"
#import "YReadPageViewController.h"
#import "YReaderManager.h"
#import "YNetworkManager.h"

@interface YReaderViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) YReaderManager *readerManager;
@property (strong, nonatomic) YNetworkManager *netManager;
@property (assign, nonatomic) NSUInteger chapter;
@property (assign, nonatomic) NSUInteger page;
@property (assign, nonatomic) NSUInteger nextChpater;
@property (assign, nonatomic) NSUInteger nextPage;

@end

@implementation YReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.view.backgroundColor = [UIColor clearColor];
//    [self setupPageViewController];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _netManager = [YNetworkManager shareManager];
        _readerManager = [YReaderManager shareReaderManager];
        [_readerManager updateReadingBook:_readingBook];
        if (_readerManager.record.selectSummary) {
            [self getBookChaptersLink];
        } else {
            [self getBookSummary];
        }
    });
    
    
}

- (void)getBookSummary {
    __weak typeof(self) wself = self;
    [_netManager getWithAPIType:YAPITypeBookSummary parameter:_readingBook.idField success:^(id response) {
        NSArray *arr = (NSArray *)response;
        if (arr.count > 0) {
            YBookSummaryModel *selectSummary = nil;
            for (YBookSummaryModel *summary in arr) {
                if (![summary.source isEqualToString:@"zhuishuvip"]) {
                    selectSummary = summary;
                    break;
                }
            }
            if (selectSummary) {
                wself.readerManager.record.selectSummary = selectSummary;
                [wself getBookChaptersLink];
            } else {
                DDLogWarn(@"本书没有免费来源 %@",wself.readingBook);
            }
        } else {
            DDLogWarn(@"本书没有来源 %@",wself.readingBook);
        }
    } failure:^(NSError *error) {
        DDLogWarn(@"get Book Summary failure %@",wself.readingBook);
    }];
    
}

- (void)getBookChaptersLink {
    __weak typeof(self) wself = self;
    [_netManager getWithAPIType:YAPITypeChaptersLink parameter:_readerManager.record.selectSummary.idField success:^(id response) {
        NSArray *arr = (NSArray *)response;
        if (arr.count > 0) {
            wself.readerManager.record.chaptersLink = arr;
            [wself.readerManager updateReadingBookChaptersContent];
            [wself getChapterContentWith:0];
        } else {
            DDLogWarn(@"本书该来源没有下载地址 %@",wself.readerManager.record.selectSummary);
        }
    } failure:^(NSError *error) {
        DDLogWarn(@"get Book Chapters Link failure %@",wself.readerManager.record.selectSummary);
    }];
}

- (void)getChapterContentWith:(NSUInteger)chapter {
    __weak typeof(self) wself = self;
    YChapterContentModel *chapterM = nil;
    if (chapter < self.readerManager.chaptersArr.count) {
        chapterM = self.readerManager.chaptersArr[chapter];
    } else {
        DDLogWarn(@"get Chapter Content  chapter(%zi) < self.readerManager.chaptersArr.count(%zi)",chapter,self.readerManager.chaptersArr.count);
        return;
    }
    
    [_netManager getWithAPIType:YAPITypeChapterContent parameter:chapterM.link success:^(id response) {
        chapterM.body = ((YChapterContentModel *)response).body;
        [chapterM updateContentPaging];
        [wself setupPageViewController];
        
    } failure:^(NSError *error) {
        DDLogWarn(@"get Chapter Content failure %@",chapterM);
    }];
}



- (void)setupPageViewController {
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    _pageViewController.view.frame = self.view.bounds;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    _page = 0;
    _chapter = 0;
    [_pageViewController setViewControllers:@[[self readPageViewWithChapter:0 page:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (YReadPageViewController *)readPageViewWithChapter:(NSUInteger)chapter page:(NSUInteger)page {
    YReadPageViewController *readPageVC = [[YReadPageViewController alloc] init];
    readPageVC.page = page;
    readPageVC.chapter = chapter;
    YChapterContentModel *chapterM = _readerManager.chaptersArr[chapter];
    if (chapter != _chapter) {
        [chapterM updateContentPaging];
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
        return nil;
    }
    
    if (_page > 0) {
        _nextPage = _page - 1;
    } else {
        _nextChpater = _chapter - 1;
        _nextPage = [_readerManager.chaptersArr[_nextChpater] pageCount] - 1;
    }
    
    return [self readPageViewWithChapter:_nextChpater page:_nextPage];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (_chapter == _readerManager.chaptersArr.count - 1 && _page == [_readerManager.chaptersArr.lastObject pageCount] - 1) {
        DDLogInfo(@"已经是最后一页");
        return nil;
    }
    
    if (_page == [_readerManager.chaptersArr[_chapter] pageCount] - 1) {
        _nextPage = 0;
        _nextChpater++;
    } else {
        _nextPage++;
    }
    
    return [self readPageViewWithChapter:_nextChpater page:_nextPage];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    NSLog(@"%s",__func__);
    _chapter = _nextChpater;
    _page = _nextPage;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    NSLog(@"%s  completed:%zi",__func__,completed);
    if (!completed) {
        YReadPageViewController *readerPageVC = (YReadPageViewController *)previousViewControllers.firstObject;
        _page = readerPageVC.page;
        _chapter = readerPageVC.chapter;
    }
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
