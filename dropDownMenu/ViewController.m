//
//  ViewController.m
//  dropDownMenu
//
//  Created by CaiMao－yyw on 16/5/20.
//  Copyright © 2016年 CaiMao－yyw. All rights reserved.
//

#import "ViewController.h"
#import "YWDropMenuView.h"

@interface ViewController ()<YWDropMenuViewDatasource, YWDropMenuViewDelegate>


@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, assign) NSInteger currentData1Index;
@property (nonatomic, assign) NSInteger currentData2Index;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _currentData1Index = 0;
    _currentData2Index = 0;

    NSArray *titleArray1 = [NSMutableArray arrayWithObjects: @"按佣金从高到低", @"按佣金从低到高", @"按开户业务由多到少", @"按开户业务由少到多", nil];
    NSArray *titleArray2 = [NSMutableArray arrayWithObjects: @"全部", @"财猫外汇", @"火币比特比", @"财猫A股", @"财猫贵金属", @"财猫", nil];
    self.titleArray = @[titleArray1, titleArray2];

    YWDropMenuView *dropMenu = [[YWDropMenuView alloc] initWithOrigin:CGPointMake(0, 44) andHeight:44];
    dropMenu.delegate = self;
    dropMenu.dataSource = self;
    [self.view addSubview:dropMenu];


}


#pragma mark ---  YWDropMenuViewDatasource代里

- (NSInteger)numberOfColumnsInMenu:(YWDropMenuView *)menu {

    return self.titleArray.count;
}

- (NSInteger)menu:(YWDropMenuView *)dropMenu numberOfRowsInColumn:(NSInteger)column {

    if (column==0) {
        return [self.titleArray[0] count];
    } else if (column==1){
        return [self.titleArray[1] count];
    }else {
        return 0;
    }
}

- (NSString *)menu:(YWDropMenuView *)menu titleForColumn:(NSInteger)column {

    switch (column) {
        case 0: return @"列表排序";
            break;
        case 1: return @"筛选";
            break;
        default:
            return nil;
            break;
    }
}

-(NSInteger)currentSelectedRow:(NSInteger)column{

    if (column==0) {
        return _currentData1Index;
    }else {
        return _currentData2Index;
    }
}

- (NSString *)menu:(YWDropMenuView *)menu titleForRowAtIndexPath:(YWIndexPath *)indexPath {

    if (indexPath.column == 0) {
        return self.titleArray[0][indexPath.row];
    } else  {
        return self.titleArray[1][indexPath.row];
    }
}

- (void)menu:(YWDropMenuView *)menu didSelectRowAtIndexPath:(YWIndexPath *)indexPath {

    if (indexPath.column == 0) {
        _currentData1Index = indexPath.row;
    } else {
        _currentData2Index = indexPath.row;
    }


}

@end
