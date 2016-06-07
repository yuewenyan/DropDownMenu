//
//  YWDropMenuView.h
//  dropDownMenu
//
//  Created by CaiMao－yyw on 16/5/27.
//  Copyright © 2016年 CaiMao－yyw. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YWIndexPath : NSObject

@property (nonatomic, assign) NSInteger column;   ///< 组
@property (nonatomic, assign) NSInteger row;      ///< 行

/**
 *  初始化组和行
 *
 *  @param column 组
 *  @param row    行
 *
 *  @return   YWIndexPath
 */
- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row;
+ (instancetype)indexPathWithColumn:(NSInteger)col row:(NSInteger)row; // 同上

@end



@class YWDropMenuView;

@protocol YWDropMenuViewDatasource <NSObject>

@optional

/**
 *  menu有几组选择
 */
- (NSInteger)numberOfColumnsInMenu:(YWDropMenuView *)dropMenu;

/**
 *  每一组有多少个选项
 */
- (NSInteger)menu:(YWDropMenuView *)dropMenu numberOfRowsInColumn:(NSInteger)column;

/**
 *  每一个组的标题
 */
- (NSString *)menu:(YWDropMenuView *)menu titleForColumn:(NSInteger)column;

/**
 *  在对应的组里每一行的标题
 */
- (NSString *)menu:(YWDropMenuView *)menu titleForRowAtIndexPath:(YWIndexPath *)indexPath;

/**
 *  当前对应每一组的选择的index
 */
- (NSInteger)currentSelectedRow:(NSInteger)column;

@end

@class YWDropMenuView;

@protocol YWDropMenuViewDelegate <NSObject>

@optional
/**
 *  选中某一组某一行之后的操作
 */
- (void)menu:(YWDropMenuView *)menu didSelectRowAtIndexPath:(YWIndexPath *)indexPath;

@end


@interface YWDropMenuView : UIView


@property (nonatomic, weak) id<YWDropMenuViewDelegate> delegate;
@property (nonatomic, weak) id<YWDropMenuViewDatasource> dataSource;

@property (nonatomic, strong) UIColor *indicatorColor;  ///< 标题右侧三角颜色
@property (nonatomic, strong) UIColor *textColor;      ///< 字体颜色
@property (nonatomic, strong) UIColor *separatorColor;   ///< 分割线颜色

/**
 *  初始化创建
 *
 *  @param origin 左上角坐标
 *  @param height 行高
 *
 *  @return menu
 */
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height;

@end
