//
//  HomeController.h
//  SinaWB
//
//  Created by Alex Li on 5/29/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface HomeController : UITableViewController <EGORefreshTableHeaderDelegate>

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSArray *statuses;
@property (strong, nonatomic) UIActivityIndicatorView *activity;

@end
