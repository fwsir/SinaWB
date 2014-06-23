//
//  CommentCell.h
//  SinaWB
//
//  Created by Alex Li on 6/17/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;         //xib 上面画出来的Label
//@property (strong, nonatomic) UILabel *commentLabel;              //code 编出来的Label

- (void)contentSettingWithDict:(NSDictionary *)dict;
+ (int)heightForText:(NSString *)str;

@end
