//
//  OAuthController.m
//  SinaWB
//
//  Created by Alex Li on 5/29/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import "OAuthController.h"
#import <CoreData/CoreData.h>
#import "ViewController.h"

@interface OAuthController ()

@end

@implementation OAuthController

static BOOL isME;
static NSString *accessToken;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

+ (BOOL)getBool
{
    return isME;
}

+ (NSString *)getAccessToken
{
    return accessToken;
}

- (void)requestAccess
{
    NSURL *url = [NSURL URLWithString:OAuthUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView setDelegate:self];
    [self.webView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *url = webView.request.URL.absoluteString;
    NSRange range = NSMakeRange(55, 32);
    accessToken = [url substringWithRange:range];
    
    if ([accessToken characterAtIndex:1] == '.') {
        NSManagedObject *token = [NSEntityDescription insertNewObjectForEntityForName:@"Access_Token" inManagedObjectContext:self.database.managedObjectContext];
        [token setValue:accessToken forKey:@"token"];
        
        //NSLog(@"%@", [token valueForKey:@"token"]);
        [self performSegueWithIdentifier:@"showMainPage" sender:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isME = self.isSecond;
    self.database = [ViewController getDocument];
    [self requestAccess];
}

- (void)setDatabase:(UIManagedDocument *)database
{
    if (_database != database) {
        _database = database;
        [self useDocument];
    }
}

- (BOOL)setupWithDocument:(UIManagedDocument *)document
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Access_Token"];
    
    NSArray *match = [document.managedObjectContext executeFetchRequest:request error:NULL];
    if (match.count) {
        accessToken = [[match lastObject] valueForKey:@"token"];
        return YES;
    }
    return NO;
}

- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.database.fileURL path]]) {
        [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if(![self setupWithDocument:self.database])
            {
                //the database is empty
                [self requestAccess];
            }
            else {
                [self performSegueWithIdentifier:@"showMainPage" sender:nil];
            }
        }];
    } else if(self.database.documentState == UIDocumentStateClosed){
        [self.database openWithCompletionHandler:^(BOOL success){
            if(![self setupWithDocument:self.database])
            {
                //the database is empty
                [self requestAccess];
            }
            else {
                [self performSegueWithIdentifier:@"showMainPage" sender:nil];
            }
        }];
    } else if(self.database.documentState == UIDocumentStateNormal){
        if(![self setupWithDocument:self.database])
        {
            //the database is empty
            [self requestAccess];
        }
        else {
            [self performSegueWithIdentifier:@"showMainPage" sender:nil];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    self.isBack = YES;
}


@end
