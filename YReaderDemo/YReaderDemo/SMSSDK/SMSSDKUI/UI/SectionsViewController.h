

#import <UIKit/UIKit.h>

@class SMSSDKCountryAndAreaCode;
@protocol SecondViewControllerDelegate;

@interface SectionsViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate>
{
    UITableView *table;
    UISearchBar *search;
    NSDictionary *allNames;
    NSMutableDictionary *names;
    NSMutableArray  *keys;    
    
    BOOL    isSearching;
}

@property (nonatomic, strong)  UITableView *table;
@property (nonatomic, strong)  UISearchBar *search;
@property (nonatomic, strong) NSDictionary *allNames;
@property (nonatomic, strong) NSMutableDictionary *names;
@property (nonatomic, strong) NSMutableArray *keys;

@property (nonatomic, strong) id <SecondViewControllerDelegate> delegate;
@property(nonatomic,strong)  UIToolbar* toolBar;

- (void)resetSearch;
- (void)handleSearchForTerm:(NSString *)searchTerm;
-(void)setAreaArray:(NSMutableArray*)array;

@end

@protocol SecondViewControllerDelegate <NSObject>
- (void)setSecondData:(SMSSDKCountryAndAreaCode *)data;
@end


