//
//  YWDropMenuView.h
//  dropDownMenu
//
//  Created by CaiMao－yyw on 16/5/27.
//  Copyright © 2016年 CaiMao－yyw. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YWIndexPath : NSObject

@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row;

+ (instancetype)indexPathWithColumn:(NSInteger)col row:(NSInteger)row;

@end



@class YWDropMenuView;

@protocol YWDropMenuViewDatasource <NSObject>

@optional
- (NSInteger)numberOfColumnsInMenu:(YWDropMenuView *)dropMenu;

- (NSInteger)menu:(YWDropMenuView *)dropMenu numberOfRowsInColumn:(NSInteger)column;

- (NSString *)menu:(YWDropMenuView *)menu titleForColumn:(NSInteger)column;

- (NSString *)menu:(YWDropMenuView *)menu titleForRowAtIndexPath:(YWIndexPath *)indexPath;

- (NSInteger)currentSelectedRow:(NSInteger)column;

@end

@class YWDropMenuView;
@protocol YWDropMenuViewDelegate <NSObject>

@optional
- (void)menu:(YWDropMenuView *)menu didSelectRowAtIndexPath:(YWIndexPath *)indexPath;

@end


@interface YWDropMenuView : UIView


@property (nonatomic, weak) id<YWDropMenuViewDelegate> delegate;
@property (nonatomic, weak) id<YWDropMenuViewDatasource> dataSource;

@property (nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *separatorColor;

- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height;

@end



























