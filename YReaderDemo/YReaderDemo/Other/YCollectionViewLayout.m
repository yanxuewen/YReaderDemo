//
//  YCollectionViewLayout.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/8.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YCollectionViewLayout.h"
#import <UIKit/UIKit.h>

@interface YCollectionViewLayout ()

@property (assign, nonatomic) YLayoutStyle style;
@property (strong, nonatomic) NSMutableArray *layoutAttrArr;

@property (assign, nonatomic) CGFloat maxHeight;

@end

@implementation YCollectionViewLayout

- (instancetype)initWithStyle:(YLayoutStyle)style {
    self = [super init];
    if (self) {
        self.style = style;
    }
    return self;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.width, _maxHeight);
}

- (void)prepareLayout {
    [super prepareLayout];
    if (self.style == YLayoutStyleTag) {
        [self setupTagViewLayout];
    } else if (self.style == YLayoutStyleRecommend) {
        [self setupRecommendViewLayout];
    }
}

- (void)setupTagViewLayout {
    _layoutAttrArr = @[].mutableCopy;
    CGFloat x = self.minimumInteritemSpacing;
    CGFloat y = self.minimumLineSpacing;
    for (NSInteger i = 0; i < self.dataArr.count; i++) {
        UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        NSString *tag = _dataArr[i];
        CGSize size = [tag boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
        size.width += 18;
        size.height += 5;
        if (x + size.width + self.minimumInteritemSpacing > self.collectionView.width) {
            x = self.minimumInteritemSpacing;
            y += size.height + self.minimumLineSpacing;
        }
        attr.frame = CGRectMake(x, y, size.width, size.height);
        x += attr.frame.size.width + self.minimumInteritemSpacing;
        _maxHeight = y + size.height + self.minimumLineSpacing;
        [_layoutAttrArr addObject:attr];
        
    }
}

- (void)setupRecommendViewLayout {
    _layoutAttrArr = @[].mutableCopy;
    [_layoutAttrArr addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
    self.headerReferenceSize = CGSizeMake(self.collectionView.width, 44);
    CGFloat ratio = 45/36.0;
    NSInteger maxBooks = kScreenWidth > 400 ? 5 : 4;
    CGFloat space = kScreenWidth > 350 ? 25 : 20;
    CGFloat width = (self.collectionView.width - (maxBooks + 1) * space) / maxBooks;
    CGFloat x = space;
    CGFloat y = self.headerReferenceSize.height;
    for (NSInteger i = 0; i < MIN(self.dataArr.count, maxBooks) ; i++) {
        UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        NSString *book = _dataArr[i];
        CGSize size = [book boundingRectWithSize:CGSizeMake(width-2, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12]} context:nil].size;
        size.height += width * ratio + 5;
        
        attr.frame = CGRectMake(x, y, width, size.height);
        x += attr.frame.size.width + space;
        if (y + size.height > _maxHeight) {
            _maxHeight = y + size.height;
        }
        [_layoutAttrArr addObject:attr];
    }
    
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    return _layoutAttrArr;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    return attr;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    attr.frame = CGRectMake(0, 0, self.collectionView.width, 44);
    return attr;
}

@end
