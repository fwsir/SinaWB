//
//  SinaCell.h
//  SinaWB
//
//  Created by Devil on 14-6-1.
//  Copyright (c) 2014年 Alex Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSTwitterCoreTextView;
@interface SinaCell : UITableViewCell

@property (nonatomic, strong) UIView *sourceView;               //总容器
@property (nonatomic, strong) UIImageView *userImageView;       //头像
@property (nonatomic, strong) UILabel *userNameLabel;           //用户名
@property (nonatomic, strong) UILabel *timeLabel;               //时间
@property (nonatomic, strong) UILabel *sourceLabel;             //来源
@property (nonatomic, strong) JSTwitterCoreTextView *textView;  //内容
@property (nonatomic, strong) UIView *picUrlsView;              //缩略图
@property (nonatomic, strong) UIView *retweetedView;            //转发容器
@property (nonatomic, strong) JSTwitterCoreTextView *retweetedTextView;  //转发内容
@property (nonatomic, strong) UIView *retweetedPicUrlsView;     //转发内容缩略图
@property (nonatomic, strong) UIButton *commentCountButton;     //评论数
@property (nonatomic, strong) UIButton *repostCountButton;      //转发数

// 设置内容
- (void)setContent:(NSMutableDictionary *)dict;

// 算出高度
+ (int)heightWith:(NSMutableDictionary *)dict;

// 更具内容图片算出高度
+ (int)heightText:(NSString *)text withpicArray:(NSArray *)picArray;

+ (NSString *)formatSinaTime:(NSString *)createAt;

@end
