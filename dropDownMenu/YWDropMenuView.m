//
//  YWDropMenuView.m
//  dropDownMenu
//
//  Created by yanyuewen on 16/5/27.
//  Copyright © 2016年 yanyuewen. All rights reserved.
//

#import "YWDropMenuView.h"

#define SCREENSIZE   [UIScreen mainScreen].bounds.size
#define BackColor    [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0]
#define SelectColor  [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0]
#define strFontSize     14.0
#define textFont     [UIFont systemFontOfSize:strFontSize]
#pragma mark --  自定义 YWIndexPath

@interface YWIndexPath ()
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

@implementation YWIndexPath

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        self.column = column;
        self.row = row;
    }
    return self;
}

+ (YWIndexPath *)indexPathWithColumn:(NSInteger)column row:(NSInteger)row {

    return  [[self alloc] initWithColumn:column row:row];
}

@end


#pragma mark -- NSString 分类Size

@interface NSString (Size)

- (CGSize)textSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end

@implementation NSString (Size)

/**
 *  根据font计算size
 */
- (CGSize)textSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {

    CGSize textSize;
    if (CGSizeEqualToSize(size, CGSizeZero)) {

        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        textSize = [self sizeWithAttributes:attributes];
    }
    else {

        NSStringDrawingOptions option = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        //NSStringDrawingTruncatesLastVisibleLine如果文本内容超出指定的矩形限制，文本将被截去并在最后一个字符后加上省略号。 如果指定了NSStringDrawingUsesLineFragmentOrigin选项，则该选项被忽略 NSStringDrawingUsesFontLeading计算行高时使用行间距。（字体大小+行间距=行高）
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        CGRect rect = [self boundingRectWithSize:size options:option attributes:attributes context:nil];
        textSize = rect.size;
    }
    return textSize;
}

@end


//#pragma mark --  YWTableViewCell  自定义tableViewCell
//
//@interface YWTableViewCell : UITableViewCell
//
//@property(nonatomic,readonly) UILabel *titleLB;
//@property(nonatomic,strong) UIImageView *accessoryIMG;
//
//-(void)setCellText:(NSString *)text align:(NSString*)align;
//
//@end
//
//@implementation YWTableViewCell
//
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        // Initialization code
//        _titleLB = [[UILabel alloc] init];
//        _titleLB.textAlignment = NSTextAlignmentCenter;
//        _titleLB.font = textFont;
//        [self addSubview:_titleLB];
//    }
//    return self;
//}
//
//-(void)setCellText:(NSString *)text align:(NSString*)align{
//
//    _titleLB.text = text;
//    // 只取宽度
//    CGSize textSize = [text textSizeWithFont:textFont constrainedToSize:CGSizeMake(MAXFLOAT, 14) lineBreakMode:NSLineBreakByWordWrapping];
//    //    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(MAXFLOAT, 14)];
//
//    CGFloat marginX = 20;
//
//    if (![@"left" isEqualToString:align]) {
//        marginX = (self.frame.size.width-textSize.width)/2;
//    }
//
//    _titleLB.frame = CGRectMake(marginX, 0, textSize.width, self.frame.size.height);
//
//    if(_accessoryIMG){
//        _accessoryIMG.frame = CGRectMake(_titleLB.frame.origin.x+_titleLB.frame.size.width+20, (self.frame.size.height-12)/2, 16, 12);
//    }
//}
//
//-(void)setCellAccessoryView:(UIImageView *)accessoryImg{
//
//    if (_accessoryIMG) {
//        [_accessoryIMG removeFromSuperview];
//    }
//
//    _accessoryIMG = accessoryImg;
//
//    _accessoryIMG.frame = CGRectMake(_titleLB.frame.origin.x+_titleLB.frame.size.width+10, (self.frame.size.height-12)/2, 16, 12);
//
//    [self addSubview:_accessoryIMG];
//}
//
//@end


#pragma mark -- 下拉菜单

@interface YWDropMenuView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *dropTableView;             ///< 点击菜单显示的tableView
@property (nonatomic, strong) UIView *backGroundView;                 ///< 背景图层
@property (nonatomic, assign) BOOL show;                              ///< 是否显示
@property (nonatomic, assign) BOOL hadSelected;                       ///< 是否选中
@property (nonatomic, assign) NSInteger currentSelectedMenudIndex;    ///< 当前选中的menu
@property (nonatomic, assign) CGPoint origin;         ///< 位置

@property (nonatomic, assign) NSInteger numOfMenu;    ///< menu个数
@property (nonatomic, assign) NSInteger selectedRow;  ///< 选中的行


@property (nonatomic, strong) UIView *bottomShadow;   ///< menu底部分割线
@property (nonatomic, copy) NSArray *titles;          ///< 标题
@property (nonatomic, copy) NSArray *indicators;      ///< 指标
@property (nonatomic, copy) NSArray *bgLayers;        ///< 背景

@end

@implementation YWDropMenuView

//-----------------------------------------------------------------------------------------------
- (UIColor *)indicatorColor { // 右侧三角颜色                                             //-------
    if (!_indicatorColor) {                                                             //-------
        _indicatorColor = [UIColor colorWithRed:37/255.0f green:37/255.0f blue:37/255.0f alpha:1.0];                                         //-------
    }                                                                                   //-------
    return _indicatorColor;                                                             //-------
}                                                                                       //-------
                                                                                        //-------
- (UIColor *)textColor {// 标题颜色                                                      //-------
    if (!_textColor) {                                                                  //-------
        _textColor = [UIColor colorWithRed:37/255.0f green:37/255.0f blue:37/255.0f alpha:1.0];                                              //-------
    }                                                                                   //-------
    return _textColor;                                                                  //-------
}                                                                                       //-------
                                                                                        //-------
- (UIColor *)separatorColor {// 分割线颜色                                                //-------
    if (!_separatorColor) {                                                             //-------
        _separatorColor = [UIColor clearColor];                                         //-------
    }                                                                                   //-------
    return _separatorColor;                                                             //-------
}                                                                                       //-------
                                                                                        //-------
- (NSString *)titleForRowAtIndexPath:(YWIndexPath *)indexPath {                         //-------
                                                                                        //-------
    return [self.dataSource menu:self titleForRowAtIndexPath:indexPath];                //-------
}                                                                                       //-------
//-----------------------------------------------------------------------------------------------

/**
 *  初始化
 *  @param origin 起始点（左上角坐标)
 *  @param height 高度
 */
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height {

    _show = NO;
    _hadSelected = NO;
    _currentSelectedMenudIndex = -1;
    _origin = origin;

    self = [super initWithFrame:CGRectMake(origin.x, origin.y, SCREENSIZE.width, height)];
    if (self) {
//  1.0 初始化下拉tableVeiw
        _dropTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.size.width, self.frame.origin.y + self.frame.size.height, 0, 0) style:UITableViewStyleGrouped];
        _dropTableView.rowHeight = 50;
        _dropTableView.separatorColor = [UIColor colorWithRed:225.f/255.0f green:225.f/255.0f blue:225.f/255.0f alpha:1.0];
        _dropTableView.dataSource = self;
        _dropTableView.delegate = self;
        self.autoresizesSubviews = NO;

//  自身点击
        self.backgroundColor = [UIColor colorWithRed:225.0f/255.0f green:222.0f/255.0f blue:222.0f/255.0f alpha:1.0];
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
        [self addGestureRecognizer:tapGesture];

//  暗调背景 初始化 、添加点击
        UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        backGroundView.opaque = NO;
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [backGroundView addGestureRecognizer:gesture];
        self.backGroundView = backGroundView;

//   在底部加一条分割线
        _bottomShadow = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [self addSubview:_bottomShadow];
    }
    return self;
}

/**
 *  数据设定
 */
- (void)setDataSource:(id<YWDropMenuViewDatasource>)dataSource {

    _dataSource = dataSource;

    //configure menuView
    if ([_dataSource respondsToSelector:@selector(numberOfColumnsInMenu:)]) {
        _numOfMenu = [_dataSource numberOfColumnsInMenu:self];
    } else {
        _numOfMenu = 1;
    }

    CGFloat textLayerInterval = self.frame.size.width / ( _numOfMenu * 2);

    CGFloat separatorLineInterval = self.frame.size.width / _numOfMenu;

    CGFloat bgLayerInterval = self.frame.size.width / _numOfMenu;

    NSMutableArray *tempTitles = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempIndicators = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempBgLayers = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];

    for (int i = 0; i < _numOfMenu; i++) {
    //bgLayer
        CGPoint bgLayerPosition = CGPointMake((i+0.5)*bgLayerInterval, self.frame.size.height/2);
        CALayer *bgLayer = [self createBgLayerWithColor:BackColor andPosition:bgLayerPosition];
        [self.layer addSublayer:bgLayer];
        [tempBgLayers addObject:bgLayer];
    //title
        CGPoint titlePosition = CGPointMake( (i * 2 + 1) * textLayerInterval , self.frame.size.height / 2);
        NSString *titleString = [_dataSource menu:self titleForColumn:i];
        CATextLayer *title = [self createTextLayerWithNSString:titleString withColor:self.textColor andPosition:titlePosition];
        [self.layer addSublayer:title];
        [tempTitles addObject:title];
    //indicator
        CAShapeLayer *indicator = [self createIndicatorWithColor:self.indicatorColor andPosition:CGPointMake(titlePosition.x + title.bounds.size.width / 2 + 8, self.frame.size.height / 2)];
        [self.layer addSublayer:indicator];
        [tempIndicators addObject:indicator];

    //separator menu分割线
        if (i != _numOfMenu - 1) {
            CGPoint separatorPosition = CGPointMake((i + 1) * separatorLineInterval, self.frame.size.height/2);
            CAShapeLayer *separator = [self createSeparatorLineWithColor:self.separatorColor andPosition:separatorPosition];
            [self.layer addSublayer:separator];
        }
    }

    _bottomShadow.backgroundColor = self.separatorColor;

    _titles = [tempTitles copy];
    _indicators = [tempIndicators copy];
    _bgLayers = [tempBgLayers copy];

    if ([_dropTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_dropTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }

    if ([_dropTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_dropTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }

}


#pragma mark - gesture handle
/**
 *  menu点击
 */
- (void)menuTapped:(UITapGestureRecognizer *)paramSender {

    CGPoint touchPoint = [paramSender locationInView:self];
    //calculate index
    NSInteger tapIndex = touchPoint.x / (self.frame.size.width / _numOfMenu);

    for (int i = 0; i < _numOfMenu; i++) {
        if (i != tapIndex) {
            [self animateIndicator:_indicators[i] Forward:NO complete:^{
                [self animateTitle:_titles[i] show:NO complete:^{

                }];
            }];
            [(CALayer *)self.bgLayers[i] setBackgroundColor:BackColor.CGColor];
        }
    }

    if (tapIndex == _currentSelectedMenudIndex && _show) {

        [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:self.backGroundView dropTableView:_dropTableView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
            _currentSelectedMenudIndex = tapIndex;
            _show = NO;
        }];

        [(CALayer *)self.bgLayers[tapIndex] setBackgroundColor:BackColor.CGColor];
    } else {

        _hadSelected = NO;

        _currentSelectedMenudIndex = tapIndex;

        if ([_dataSource respondsToSelector:@selector(currentSelectedRow:)]) {

            _selectedRow = [_dataSource currentSelectedRow:_currentSelectedMenudIndex];
        }

        [_dropTableView reloadData];

        [self animateIdicator:_indicators[tapIndex] background:_backGroundView dropTableView:_dropTableView title:_titles[tapIndex] forward:YES complecte:^{
            _show = YES;
        }];
        [(CALayer *)self.bgLayers[tapIndex] setBackgroundColor:SelectColor.CGColor];
    }

}

/**
 *  背景图层点击
 */
- (void)backgroundTapped:(UITapGestureRecognizer *)paramSender{

    [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView dropTableView:_dropTableView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
        _show = NO;
    }];

    [(CALayer *)self.bgLayers[_currentSelectedMenudIndex] setBackgroundColor:BackColor.CGColor];
}

#pragma mark -- 动画

- (void)animateTitle:(CATextLayer *)title show:(BOOL)show complete:(void(^)())complete {
    CGSize size = [self calculateTitleSizeWithString:title.string];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
    title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    complete();
}

- (void)animateIdicator:(CAShapeLayer *)indicator background:(UIView *)background dropTableView:(UITableView *)dropTableView title:(CATextLayer *)title forward:(BOOL)forward complecte:(void(^)())complete{

    [self animateIndicator:indicator Forward:forward complete:^{
        [self animateTitle:title show:forward complete:^{
            [self animateBackGroundView:background show:forward complete:^{
                [self animateDropTableView:dropTableView show:forward complete:^{
                }];
            }];
        }];
    }];

    complete();
}



- (void)animateIdicator:(CAShapeLayer *)indicator background:(UIView *)background collectionView:(UICollectionView *)collectionView title:(CATextLayer *)title forward:(BOOL)forward complecte:(void(^)())complete{

    [self animateIndicator:indicator Forward:forward complete:^{
        [self animateTitle:title show:forward complete:^{
            [self animateBackGroundView:background show:forward complete:^{


            }];
        }];
    }];

    complete();
}

#pragma mark - animation method
- (void)animateIndicator:(CAShapeLayer *)indicator Forward:(BOOL)forward complete:(void(^)())complete {
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];

    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = forward ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];

    if (!anim.removedOnCompletion) {
        [indicator addAnimation:anim forKey:anim.keyPath];
    } else {
        [indicator addAnimation:anim forKey:anim.keyPath];
        [indicator setValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }

    [CATransaction commit];

    complete();
}

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete {
    if (show) {
        [self.superview addSubview:view];
        [view.superview addSubview:self];

        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    complete();
}


/**
 *动画显示下拉菜单
 */
- (void)animateDropTableView:(UITableView *)dropTableView show:(BOOL)show complete:(void(^)())complete {


    if (show) {

        if (dropTableView) {

            dropTableView.frame = CGRectMake(_origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, ([dropTableView numberOfRowsInSection:0] > 6) ? (6 * dropTableView.rowHeight) : ([dropTableView numberOfRowsInSection:0] * dropTableView.rowHeight));
            [self.superview addSubview:dropTableView];
        }

//        if([self.dataSource haveRightTableViewInColumn:_currentSelectedMenudIndex]){
//            if (rightTableView) {
//
//                rightTableView.frame = CGRectMake(_origin.x+leftTableView.frame.size.width, self.frame.origin.y + self.frame.size.height, self.frame.size.width*(1-ratio), 0);
//
//                [self.superview addSubview:rightTableView];
//
//                rightTableViewHeight = ([rightTableView numberOfRowsInSection:0] > 5) ? (5 * rightTableView.rowHeight) : ([rightTableView numberOfRowsInSection:0] * rightTableView.rowHeight);
//            }
//        }

//        CGFloat tableViewHeight = MAX(leftTableViewHeight, rightTableViewHeight);
//
//        [UIView animateWithDuration:0.2 animations:^{
//            if (leftTableView) {
//                leftTableView.frame = CGRectMake(_origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width*ratio, tableViewHeight);
//            }
//            if (rightTableView) {
//                rightTableView.frame = CGRectMake(_origin.x+leftTableView.frame.size.width, self.frame.origin.y + self.frame.size.height, self.frame.size.width*(1-ratio), tableViewHeight);
//            }
//        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{

            if (dropTableView) {
                dropTableView.frame = CGRectMake(_origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
            }

        } completion:^(BOOL finished) {

            if (dropTableView) {
                [dropTableView removeFromSuperview];
            }

        }];
    }
    complete();
}


#pragma mark - init support
- (CALayer *)createBgLayerWithColor:(UIColor *)color andPosition:(CGPoint)position {
    CALayer *layer = [CALayer layer];

    layer.position = position;
    layer.bounds = CGRectMake(0, 0, self.frame.size.width/self.numOfMenu, self.frame.size.height-1);
    layer.backgroundColor = color.CGColor;

    return layer;
}

- (CAShapeLayer *)createIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];

    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(8, 0)];
    [path addLineToPoint:CGPointMake(4, 5)];
    [path closePath];

    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.fillColor = color.CGColor;

    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);

    CGPathRelease(bound);

    layer.position = point;

    return layer;
}

- (CAShapeLayer *)createSeparatorLineWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];

    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(160,0)];
    [path addLineToPoint:CGPointMake(160, self.frame.size.height)];

    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.strokeColor = color.CGColor;

    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);

    CGPathRelease(bound);

    layer.position = point;

    return layer;
}

- (CATextLayer *)createTextLayerWithNSString:(NSString *)string withColor:(UIColor *)color andPosition:(CGPoint)point {

    CGSize size = [self calculateTitleSizeWithString:string];

    CATextLayer *layer = [CATextLayer new];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
    layer.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    layer.string = string;
    layer.fontSize = strFontSize;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.foregroundColor = color.CGColor;

    layer.contentsScale = [[UIScreen mainScreen] scale];

    layer.position = point;

    return layer;
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string
{
    NSDictionary *dic = @{NSFontAttributeName: textFont};
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size;
}

#pragma mark - table datasource 代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSAssert(self.dataSource != nil, @"menu's dataSource shouldn't be nil");
    if ([self.dataSource respondsToSelector:@selector(menu:numberOfRowsInColumn:)]) {
        return [self.dataSource menu:self numberOfRowsInColumn:self.currentSelectedMenudIndex];
    } else {
        NSAssert(0 == 1, @"required method of dataSource protocol should be implemented");
        return 0;
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DropDownMenuCell"];

    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = BackColor;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = self.textColor;
    titleLabel.tag = 1;
    titleLabel.font = textFont;

    CGSize textSize;

    if ([self.dataSource respondsToSelector:@selector(menu:titleForRowAtIndexPath:)]) {

        titleLabel.text = [self.dataSource menu:self titleForRowAtIndexPath:[YWIndexPath indexPathWithColumn:self.currentSelectedMenudIndex row:indexPath.row]];
        // 只取宽度
        textSize = [titleLabel.text textSizeWithFont:textFont constrainedToSize:CGSizeMake(MAXFLOAT, 14) lineBreakMode:NSLineBreakByWordWrapping];

    }
    CGFloat marginX = (self.frame.size.width - textSize.width)/2;

    titleLabel.frame = CGRectMake(marginX, 0, textSize.width, cell.frame.size.height);

    cell.backgroundColor = [UIColor whiteColor];

    cell.textLabel.font = textFont;

    cell.separatorInset = UIEdgeInsetsZero;


    UIImageView *accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Check"]];
    if (!_hadSelected && _selectedRow == indexPath.row) {

        titleLabel.textColor = [UIColor colorWithRed:14.0f/255.0f green:111.0f/255.0f blue:222.0f/255.0f alpha:1.0];

        cell.backgroundColor = BackColor;

        accessoryImageView.frame = CGRectMake(titleLabel.frame.origin.x+titleLabel.frame.size.width+10, (self.frame.size.height-12)/2, 16, 12);

        [cell addSubview:accessoryImageView];
    }

    [cell addSubview:titleLabel];


    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.delegate || [self.delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {


        [self confiMenuWithSelectRow:indexPath.row];

        [self.delegate menu:self didSelectRowAtIndexPath:[YWIndexPath indexPathWithColumn:self.currentSelectedMenudIndex row:indexPath.row]];

        if (!_hadSelected) {
            _hadSelected = YES;
            [_dropTableView reloadData];
            NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:_selectedRow inSection:0];

            [_dropTableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }

        [_dropTableView reloadData];

    } else {
        //TODO: delegate is nil
    }
}

/**
 *  根据当前选中的行改变标题
 */
- (void)confiMenuWithSelectRow:(NSInteger)row {

    CATextLayer *title = (CATextLayer *)_titles[_currentSelectedMenudIndex];
    title.string = [self.dataSource menu:self titleForRowAtIndexPath:[YWIndexPath indexPathWithColumn:self.currentSelectedMenudIndex row:row]];

    [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView dropTableView:_dropTableView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
        _show = NO;
    }];
    [(CALayer *)self.bgLayers[_currentSelectedMenudIndex] setBackgroundColor:BackColor.CGColor];

    CAShapeLayer *indicator = (CAShapeLayer *)_indicators[_currentSelectedMenudIndex];
    indicator.position = CGPointMake(title.position.x + title.frame.size.width / 2 + 8, indicator.position.y);

}


@end
