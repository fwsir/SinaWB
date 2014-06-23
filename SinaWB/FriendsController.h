//
//  FriendsController.h
//  SinaWB
//
//  Created by Alex Li on 6/12/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsController : UITableViewController

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) UIActivityIndicatorView *activity;

@end
