//
//  CommentController.h
//  SinaWB
//
//  Created by Alex Li on 6/16/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSArray *comments;
@property (strong, nonatomic) NSArray *reposts;
@property (strong, nonatomic) NSString *weiboID;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;


@end
