//
//  WriteCRController.h
//  SinaWB
//
//  Created by Alex Li on 6/18/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WriteCRController : UIViewController <UITextViewDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property (weak, nonatomic) IBOutlet UINavigationItem *myNavItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (assign, nonatomic) BOOL isComment;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *weiboID;
@property (strong, nonatomic) NSString *commentID;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *responseData;

@end
