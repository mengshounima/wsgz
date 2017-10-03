//
//  topicDetailVC.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/5/8.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "topicDetailVC.h"
#import "replyCell.h"
#import "HcCustomKeyboard.h"

@interface topicDetailVC ()<UITableViewDelegate,UITableViewDataSource,HcCustomKeyboardDelegate>

@property (nonatomic,copy) NSMutableArray *replyArr;
@property (nonatomic,strong) UITableView *replyTableView;

@end

@implementation topicDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"话题详情";
    [self setupSubViews];
    [self getListData];
    
    [[HcCustomKeyboard customKeyboard] textViewShowView:self customKeyboardDelegate:self];
}

-(void)setupSubViews{
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteTopic:)];
    UILabel *titleLabel = [[UILabel alloc] init];

    NSString *titleStr =  [_detailDic objectForKey:@"title"];
    if (!ISNULLSTR(titleStr)) {
        titleLabel.text = titleStr;
    }
    titleLabel.font = [UIFont systemFontOfSize:18];
    CGSize titlesize = [self sizeWithText:titleStr font:titleLabel.font maxSize:CGSizeMake(SCREEN_WIDTH-20, MAXFLOAT)];
    titleLabel.frame = CGRectMake(10, 84, titlesize.width, titlesize.height);
    
    
    // UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 84, SCREEN_WIDTH-20, 30)];

    
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    //titleLabel.adjustsFontSizeToFitWidth = YES;
    //[titleLabel sizeToFit];

    [self.view addSubview:titleLabel];
    
    float Y = CGRectGetMaxY(titleLabel.frame);
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.font = [UIFont systemFontOfSize:14];
    NSString *contentStr = [_detailDic objectForKey:@"content"];
    if (!ISNULLSTR(contentStr)) {
         NSString *contentStr = contentStr;
    }
   
    contentLabel.text = contentStr;
    contentLabel.numberOfLines = 0;
    
    CGSize size = [self sizeWithText:contentStr font:contentLabel.font maxSize:CGSizeMake(SCREEN_WIDTH-20, MAXFLOAT)];
    contentLabel.frame = CGRectMake(10, Y+10, size.width, size.height);
    [self.view addSubview:contentLabel];
    
     Y = CGRectGetMaxY(contentLabel.frame);
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-160, Y+10, 60, 20)];
    nameLabel.font = [UIFont systemFontOfSize:11];
    nameLabel.textColor = [UIColor lightGrayColor];
    [self.view addSubview:nameLabel];
    NSString *nameStr = [_detailDic objectForKey:@"name"];
    if (!ISNULLSTR(nameStr)) {
        nameLabel.text = nameStr ;
    }
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, Y+10, 80, 20)];
    dateLabel.font = [UIFont systemFontOfSize:11];
    dateLabel.textAlignment =NSTextAlignmentRight;
    dateLabel.textColor = [UIColor lightGrayColor];
    [self.view addSubview:dateLabel];
    //时间戳转日期
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    dateformater.dateFormat = [NSString stringWithFormat:@"yyyy-MM-dd"];
    NSNumber *IntervalNum =  [_detailDic objectForKey:@"create_time"];
    if (!ISNULL(IntervalNum)) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:(IntervalNum.integerValue)/1000];
        dateLabel.text = [dateformater stringFromDate:date];
    }
    
    Y = CGRectGetMaxY(dateLabel.frame);
    _replyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, Y, SCREEN_WIDTH, SCREEN_HEIGHT-Y-50) style:UITableViewStylePlain];
    _replyTableView.delegate = self;
    _replyTableView.dataSource = self;
    _replyTableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_replyTableView];
    
}
//-(void)deleteTopic:(UIBarButtonItem *)button{
//    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
//    [param setObject:[_detailDic objectForKey:@"id"] forKey:@"topic.PId"];
//    [param setObject:textViewGet.text forKey:@"topic.content"];
//    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"topic.createUser"];
//    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
//    [MBProgressHUD showMessage:@"发送中"];
//    
//    [[HttpClient httpClient] requestWithPath:@"/saveTopic.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        [MBProgressHUD hideHUD];
//        NSNumber *result = [responseObject objectForKey:@"success"];
//        if (result.boolValue) {
//            [MBProgressHUD showSuccess:@"发送成功"];
//            [self getListData];
//        }
//        else
//        {
//            [MBProgressHUD showError:[responseObject objectForKey:@"message"]];
//        }
//        
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        [MBProgressHUD showError:error.userInfo[@"name"]];;
//        [MBProgressHUD hideHUD];
//    }];
//
//}

//点击发送代理方法
-(void)talkBtnClick:(UITextView *)textViewGet{
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:[_detailDic objectForKey:@"id"] forKey:@"topic.PId"];
    [param setObject:textViewGet.text forKey:@"topic.content"];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"topic.createUser"];
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    
    [SVProgressHUD show];
    [[HttpClient httpClient] requestWithPath:@"/saveTopic.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSNumber *result = [responseObject objectForKey:@"success"];
        if (result.boolValue) {
            [SVProgressHUD showSuccessWithStatus:@"发送成功"];
            [self getListData];
                   }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
    }];
 
    
}
-(void)getListData
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:[_detailDic objectForKey:@"id"] forKey:@"topic.id"];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"sysUserId"];
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    
    [SVProgressHUD show];
    [[HttpClient httpClient] requestWithPath:@"/queryAllReply.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSNumber *result = [responseObject objectForKey:@"success"];
        if (result.boolValue) {
            [SVProgressHUD dismiss];
            NSDictionary *data = [responseObject objectForKey:@"data"];
            _replyArr = [[NSMutableArray alloc] initWithArray:[data objectForKey:@"replys"]];
            if (_replyArr.count>0) {
                [_replyTableView reloadData];
            }
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];;
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    replyCell *cell = (replyCell *)[self tableView:_replyTableView cellForRowAtIndexPath:indexPath];
    
    return cell.frame.size.height;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     return  _replyArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"replyCell";
    replyCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell = [[replyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    [cell updateWithReplyDic:_replyArr[indexPath.row]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}


#pragma mark - 计算文本尺寸
- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize: (CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}


@end
