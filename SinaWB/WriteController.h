//
//  WriteController.h
//  SinaWB
//
//  Created by Alex Li on 6/13/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WriteController : UIViewController <UITextViewDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSURLConnection *connection;

@end
