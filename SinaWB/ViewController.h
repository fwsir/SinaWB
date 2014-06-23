//
//  ViewController.h
//  SinaWB
//
//  Created by Alex Li on 5/29/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) UIManagedDocument *database;

+ (NSString *)getAccessToken;
+ (UIManagedDocument *)getDocument;

@end
