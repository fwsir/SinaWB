//
//  SinaCell.m
//  SinaWB
//
//  Created by Devil on 14-6-1.
//  Copyright (c) 2014年 Alex Li. All rights reserved.
//

#import "SinaCell.h"
#import "JSTwitterCoreTextView.h"
#import "UIImageView+WebCache.h"

@implementation SinaCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self createView];
    }
    return self;
}

- (void)createView
{
    // 总容器
    _sourceView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 310, 0)];
    _sourceView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_sourceView];
    
    // 头像
    _userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
    [_sourceView addSubview:_userImageView];
    
    
    // 用户昵称
    _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5+40+10, 5, 200, 20)];
    _userNameLabel.backgroundColor = [UIColor clearColor];
    _userNameLabel.font = [UIFont systemFontOfSize:15];
    _userNameLabel.textColor = [UIColor blackColor];
    [_sourceView addSubview:_userNameLabel];
    
    // 时间
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5+40+10, 5, 80, 20)];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor orangeColor];
    [_sourceView addSubview:_timeLabel];
    
    // 来源
    _sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 40+5, 300, 0)];
    _sourceLabel.font = [UIFont systemFontOfSize:12];
    _sourceLabel.backgroundColor = [UIColor clearColor];
    _sourceLabel.textColor = [UIColor blackColor];
    [_sourceView addSubview:_sourceLabel];
    
    // 内容
    _textView = [[JSTwitterCoreTextView alloc] initWithFrame:CGRectMake(5, 0, 300, 10)];
    [_textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_textView setFontName:@"Helvetica"];
    [_textView setFontSize:16.0];
    [_textView setHighlightColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0]];
    [_textView setBackgroundColor:[UIColor clearColor]];
    [_textView setPaddingLeft:0.0];
    [_textView setPaddingTop:0.0];
    [_sourceView addSubview:_textView];
    
    // 缩略图
    _picUrlsView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 300, 0)];
    _picUrlsView.backgroundColor = [UIColor clearColor];
    [_sourceView addSubview: _picUrlsView];
    
    // 转发内容容器
    _retweetedView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 300, 0)];
    _retweetedView.backgroundColor = [UIColor clearColor];
    _retweetedView.layer.borderColor = [UIColor grayColor].CGColor;
    _retweetedView.layer.borderWidth = 0.5;
    [_sourceView addSubview:_retweetedView];
    
    // 转发内容
    _retweetedTextView = [[JSTwitterCoreTextView alloc] initWithFrame:CGRectMake(0, 5, 300, 0)];
    [_retweetedTextView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_retweetedTextView setFontName:@"Helvetica"];
    [_retweetedTextView setFontSize:16.0];
    [_retweetedTextView setHighlightColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0]];
    [_retweetedTextView setBackgroundColor:[UIColor clearColor]];
    [_retweetedTextView setPaddingTop:0.0];
    [_retweetedTextView setPaddingLeft:0.0];
    [_retweetedView addSubview:_retweetedTextView];
    
    _retweetedPicUrlsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 0)];
    [_retweetedPicUrlsView setBackgroundColor:[UIColor clearColor]];
    [_retweetedView addSubview:_retweetedPicUrlsView];
    
    _repostCountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _commentCountButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_repostCountButton setImage:[UIImage imageNamed:@"timeline_retweet_count_icon@2x"]
                        forState:UIControlStateNormal];
    [_commentCountButton setImage:[UIImage imageNamed:@"timeline_comment_count_icon"]
                         forState:UIControlStateNormal];
    [_sourceView addSubview:_repostCountButton];
    [_sourceView addSubview:_commentCountButton];
}


- (void)setContent:(NSMutableDictionary *)dict
{
    //头像
    //NSDictionary *user = [dict valueForKey:@"user"];
    //NSLog(@"%@", user);
    //NSLog(@"%@", [dict valueForKeyPath:@"user.screen_name"]);
  
    NSString *photoStr = [[dict valueForKey:@"user"] valueForKey:@"profile_image_url"];
    NSString *userNameStr = [dict valueForKeyPath:@"user.screen_name"];
    NSString *timeStr = [dict valueForKey:@"created_at"];
    timeStr = [SinaCell formatSinaTime:timeStr];
    
    NSString *sourceStr = [dict valueForKey:@"source"];
    sourceStr = [sourceStr stringByReplacingOccurrencesOfString:@"</a>" withString:@""];
    sourceStr = [sourceStr substringFromIndex:[sourceStr rangeOfString:@">"].location+1];
    
    NSString *textStr = [dict valueForKey:@"text"];
    NSArray *picUrls = [dict valueForKey:@"pic_urls"];
    
    NSString *retweetedTextStr = nil;
    NSArray *retweetedPicUrls = nil;
    
    if ([dict valueForKey:@"retweeted_status"]) {
        retweetedTextStr = [NSString stringWithFormat:@"%@:", [dict valueForKeyPath:@"retweeted_status.user.screen_name"]];
        retweetedTextStr = [retweetedTextStr stringByAppendingString:[dict valueForKeyPath:@"retweeted_status.text"]];
        retweetedPicUrls = [dict valueForKeyPath:@"retweeted_status.pic_urls"];
    }
    
    int iTop = 5;
    
    // 进行各个View的高度设置。
    _userImageView.frame = CGRectMake(5, iTop, 40, 40);
    [_userImageView setImageWithURL:[NSURL URLWithString:photoStr] placeholderImage:nil];
    
    // 昵称
    NSDictionary *uAttribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
    CGSize uSize = [userNameStr boundingRectWithSize:CGSizeMake(200, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:uAttribute context:nil].size;
    [_userNameLabel setFrame:CGRectMake(40+5+10, iTop, uSize.width, 20)];
    [_userNameLabel setText:userNameStr];

    
    // 时间
    iTop += 20;
    NSDictionary *tAttribute = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
    CGSize tSize = [timeStr boundingRectWithSize:CGSizeMake(200, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:tAttribute context:nil].size;
    [_timeLabel setFrame:CGRectMake(40+5+10, iTop, tSize.width, 20)];
    [_timeLabel setText:timeStr];
    
    // 来源
    NSDictionary *sAttribute = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
    CGSize sSize = [sourceStr boundingRectWithSize:CGSizeMake(200, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:sAttribute context:nil].size;
    [_sourceLabel setFrame:CGRectMake(_timeLabel.frame.origin.x+_timeLabel.frame.size.width+5, iTop, sSize.width, 20)];
    [_sourceLabel setText:sourceStr];
    
    iTop += 20 + 10;
    iTop = [self addText:textStr addPicUrls:picUrls withITop:iTop withTextView:_textView withType:0];
    
    // 转发容器
    if (retweetedTextStr) {
        ///////////////////////////   这里的 withITop
        int rH = [self addText:retweetedTextStr addPicUrls:retweetedPicUrls withITop:5 withTextView:_retweetedTextView withType:1];
        [_retweetedView setFrame:CGRectMake(5, iTop, 300, rH)];
        //NSLog(@"Here is %@", retweetedTextStr);
        iTop += rH;
    }else {
        // 清空数据
        [self addText:@"" addPicUrls:nil withITop:5 withTextView:_retweetedTextView withType:1];
        [_retweetedView setFrame:CGRectMake(5, iTop, 300, 0)];
    }
    iTop += 10;
    //  转发与评论
    NSString *commentCount = [dict valueForKey:@"comments_count"];
    NSString *retweetCount = [dict valueForKey:@"reposts_count"];
    
    
#warning   Button没有type的话 上面的文字不显示
    [_commentCountButton.titleLabel setTextColor:[UIColor blackColor]];
    [_repostCountButton.titleLabel setTextColor:[UIColor blackColor]];
    [_commentCountButton setTitle:[NSString stringWithFormat:@"  %@", commentCount]
                         forState:UIControlStateNormal];
    [_repostCountButton setTitle:[NSString stringWithFormat:@"  %@", retweetCount]
                        forState:UIControlStateNormal];
    [_repostCountButton setFrame:CGRectMake(40, iTop, 60, 20)];
    [_commentCountButton setFrame:CGRectMake(200, iTop, 60, 20)];
    
    iTop += 10;
    //iTop += 10;
    
    [_sourceView setFrame:CGRectMake(5, 5, 310, iTop)];
}

- (int)addText:(NSString *)textStr addPicUrls:(NSArray *)picUrls withITop:(int)iTop withTextView:(JSTwitterCoreTextView *)textView withType:(int)type
{
    // 内容
    CGFloat height = [JSCoreTextView measureFrameHeightForText:textStr
                                                      fontName:@"Helvetica"
                                                      fontSize:16.0
                                            constrainedToWidth:300-(0.0*2)
                                                    paddingTop:0.0
                                                   paddingLeft:0.0];
    [textView setFrame:CGRectMake(5, iTop, 300, height)];
    [textView setText:textStr];
    
    iTop += height+10;
    
    // 缩略图
    int x = 0;
    int num = (int)(picUrls.count+2)/3;
    int hightImage = (300-6)/3;
    
    UIView *picView = nil;
    if (type == 0) {
        picView = _picUrlsView;
    }else {
        picView = _retweetedPicUrlsView;
    }
    
    // 避免重用
    for (UIView *subView in picView.subviews) {
        [subView removeFromSuperview];
    }
    
    if (picUrls && picUrls.count != 0) {
        if (type)
            picView.frame = CGRectMake(0, iTop, 300, iTop);
        else
            picView.frame = CGRectMake(5, iTop, 300, iTop);
        // 算出高度
        iTop += (num*(hightImage+3));
        
        for (int i = 0; i < picUrls.count; ++i) {
            NSString *strUrl = [[picUrls objectAtIndex:i] valueForKey:@"thumbnail_pic"];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, (i/3)*(hightImage+3), hightImage, hightImage)];
            imageView.clipsToBounds = YES;
            imageView.userInteractionEnabled = YES;
            [imageView setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
            
            x += hightImage+3;
            if ((i+1)%3 == 0) {
                x = 0;
            }
            [picView addSubview:imageView];
        }
    }
    
    
    
    return iTop;
}


#pragma mark - ============== Get Height ================
+ (int)heightText:(NSString *)text withpicArray:(NSArray *)picArray
{
    int height = [JSCoreTextView measureFrameHeightForText:text
                                                  fontName:@"Helvetica"
                                                  fontSize:16.0
                                        constrainedToWidth:300-(0.0*2)
                                                paddingTop:0.0
                                               paddingLeft:0.0];
    height += 10;
    
    int num = (int)(picArray.count+2)/3;
    int hightImage = (300-6)/3;
    if (picArray && picArray.count!=0) {
        height += (num * (hightImage+3));
    }
    
    //NSLog(@"%d", height);
    
    return height+20;
}


+ (int)heightWith:(NSMutableDictionary *)dict
{
    int iTop = 5;
    iTop += 40;
    iTop += 10;
    iTop += 10;
    iTop += 10;
    
    iTop += [self heightText:[dict valueForKey:@"text"] withpicArray:[dict valueForKey:@"pic_urls"]];
    
    if ([dict valueForKey:@"retweeted_status"]) {
        iTop += [self heightText:[dict valueForKeyPath:@"retweeted_status.text"] withpicArray:[dict valueForKeyPath:@"retweeted_status.pic_urls"]];
    }
    
    return iTop;
}


#pragma mark - ============== Get Time ================
+ (NSString *)formatSinaTime:(NSString *)createAt
{
    NSDateFormatter *formatterSina = [[NSDateFormatter alloc] init];
    formatterSina.dateFormat = @"EEE MMM d HH:mm:ss Z yyyy";
    formatterSina.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSString *resultStr;
    NSDate *dateSource = [formatterSina dateFromString:createAt];
    NSDate *now = [NSDate date];
    
    NSDateFormatter *fOne = [[NSDateFormatter alloc] init];
    fOne.dateFormat = @"yyyy";
    
    NSDateFormatter *fTwo = [[NSDateFormatter alloc] init];
    fTwo.dateFormat = @"MM-dd";
    
    NSDateFormatter *fThree = [[NSDateFormatter alloc] init];
    fThree.dateFormat = @"yyyy-MM-dd";
    
    NSDateFormatter *fFour = [[NSDateFormatter alloc] init];
    fFour.dateFormat = @"HH:mm";
    
    NSString *strNowYear = [fOne stringFromDate:now];
    NSString *strDateYear = [fOne stringFromDate:dateSource];
    
    if ([strNowYear isEqualToString:strDateYear]) {
        NSString *strNowDay = [fTwo stringFromDate:now];
        NSString *strDateDay = [fTwo stringFromDate:dateSource];
        
        if ([strNowDay isEqualToString:strDateDay]) {
            NSTimeInterval seconds = [now timeIntervalSinceDate:dateSource];
            int hour = (int)seconds/3600;
            if (hour == 0) {
                int min = (int)seconds/60;
                if (min <= 1) {
                    resultStr = @"刚刚";
                }
                else {
                    resultStr = [NSString stringWithFormat:@"%d分钟前", min];
                }
            }
            else {
                resultStr = [fFour stringFromDate:dateSource];
            }
        }
        else
        {
            NSTimeInterval secondsPerDay = 24*60*60;
            NSDate *yearsterDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-secondsPerDay];
            NSString *yearsterDay = [fTwo stringFromDate:yearsterDate];
            if ([strDateDay isEqualToString:yearsterDay]) {
                resultStr = @"昨天";
            }
            else {
                resultStr = strDateDay;
            }
        }
    }
    else {
        resultStr = [fThree stringFromDate:dateSource];
    }
    
    return resultStr;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
