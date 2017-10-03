//
//  NoticeDetailVC.m
//  FiveWaterWork
//
//  Created by aiteyuan on 16/1/28.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "NoticeDetailVC.h"
#import "NoticeCell.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"
#import "MJPhotoBrowser.h"

static NSString *const KcellIdentifier = @"cellIdentifier";

@interface NoticeDetailVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UILabel *titleLable;

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong) NSArray *picArray;

@end

@implementation NoticeDetailVC

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initview];
}

-(void)initview
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"公告详情";
    _titleLable = [[UILabel alloc] init];
    _titleLable.text = _detailContentDic[@"title"];
    _titleLable.preferredMaxLayoutWidth = SCREEN_WIDTH-20;
    _titleLable.font = [UIFont systemFontOfSize:16];
    _titleLable.numberOfLines = 0;
    [self.view addSubview:_titleLable];
    [_titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide).offset(10);
        make.centerX.equalTo(self.view);
    }];
    
    //日期
    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.font = [UIFont systemFontOfSize:13];
    dateLabel.text = [_detailContentDic objectForKey:@"createDate"];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.textColor = [UIColor lightGrayColor];
    [self.view addSubview:dateLabel];
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLable.mas_bottom).offset(10);
        make.centerX.equalTo(_titleLable);
    }];
    
    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@1);
        make.left.right.equalTo(self.view);
        make.top.equalTo(dateLabel.mas_bottom).offset(10);
    }];
    
    _tableview = [[UITableView alloc] init];
    _tableview.showsVerticalScrollIndicator = NO;
    _tableview.tableFooterView = [[UIView alloc] init];
    _tableview.estimatedRowHeight = SCREEN_WIDTH*0.7;
    [self.view addSubview:_tableview];
    [_tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineV.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    [_tableview registerClass:[NoticeCell class] forCellReuseIdentifier:KcellIdentifier];
    _tableview.dataSource = self;
    _tableview.delegate = self;
}

#pragma mark - Tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *picStr =_detailContentDic[@"pic"];
    if (![picStr isEqual:[NSNull null]]) {
        _picArray = [picStr componentsSeparatedByString:@","];
        return _picArray.count;
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:KcellIdentifier forIndexPath:indexPath];
    NSString *picPath = [NSString stringWithFormat:@"%@%@",BASEURlSTR,_picArray[indexPath.row]];
    [cell.imageV sd_setImageWithURL:[NSURL URLWithString:picPath]];
    return cell;
}

#pragma mark - Tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:1];
    MJPhoto *photo = [[MJPhoto alloc] init];
    
    NoticeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    photo.image = cell.imageV.image;
    photo.srcImageView = cell.imageV;
    [photos addObject:photo];
    
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0;
    browser.photos = photos;
    [browser show];
}

@end
