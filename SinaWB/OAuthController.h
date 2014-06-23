//
//  OAuthController.h
//  SinaWB
//
//  Created by Alex Li on 5/29/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OAuthController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) UIManagedDocument *database;
@property (assign, nonatomic) BOOL isBack;
@property (assign, nonatomic) BOOL isSecond;

+ (NSString *)getAccessToken;
+ (BOOL) getBool;

@end