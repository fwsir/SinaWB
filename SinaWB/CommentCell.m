//
//  CommentCell.m
//  SinaWB
//
//  Created by Alex Li on 6/17/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import "CommentCell.h"
#import "SinaCell.h"
#import "UIImageView+WebCache.h"

@implementation CommentCell

- (void)contentSettingWithDict:(NSDictionary *)dict
{
    NSString *str = [dict valueForKeyPath:@"user.profile_image_url"];
    [self.headImage setImageWithURL:[NSURL URLWithString:str]];
    [self.nameLabel setText:[dict valueForKeyPath:@"user.screen_name"]];
    [self.timeLabel setText:[SinaCell formatSinaTime:[dict valueForKey:@"created_at"]]];
    
    [self.commentLabel setText:[dict valueForKey:@"text"]];
    
    //NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
    //CGSize size = [self.commentLabel.text boundingRectWithSize:CGSizeMake(250, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    
    [self.commentLabel setFont:[UIFont systemFontOfSize:15]];
    [self.commentLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.commentLabel setNumberOfLines:0];
    //[self.commentLabel setFrame:CGRectMake(53, 51, 250, size.height)];
    
    //[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, size.height+60)];
}

+ (int)heightForText:(NSString *)str
{
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
    CGSize size = [str boundingRectWithSize:CGSizeMake(250, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    
    return size.height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
