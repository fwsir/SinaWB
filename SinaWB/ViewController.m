//
//  ViewController.m
//  SinaWB
//
//  Created by Alex Li on 5/29/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "OAuthController.h"

@interface ViewController ()

@end

@implementation ViewController

static NSString *accessToken;
static UIManagedDocument *sharedDatabase;

+ (NSString *)getAccessToken
{
    return  accessToken;
}

+ (UIManagedDocument *)getDocument
{
    return sharedDatabase;
}

- (BOOL)setupWithDocument:(UIManagedDocument *)document
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Access_Token"];
    NSArray *match = [document.managedObjectContext executeFetchRequest:request error:NULL];
    
    //NSLog(@"结果是：%@", match);
    
    if (match.count) {
        accessToken = [[match lastObject] valueForKey:@"token"];
        return YES;
    }
    return NO;
}

- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[sharedDatabase.fileURL path]]) {
        [sharedDatabase saveToURL:sharedDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if ([self setupWithDocument:sharedDatabase]) {
                [self performSegueWithIdentifier:@"mainPage" sender:nil];
            }
            else {
                [self performSegueWithIdentifier:@"loginPage" sender:nil];
            }
        }];
    } else if (sharedDatabase.documentState == UIDocumentStateClosed) {
        [sharedDatabase openWithCompletionHandler:^(BOOL success) {
            if ([self setupWithDocument:sharedDatabase]) {
                [self performSegueWithIdentifier:@"mainPage" sender:nil];
            }
            else {
                [self performSegueWithIdentifier:@"loginPage" sender:nil];
            }
        }];
    } else if (sharedDatabase.documentState == UIDocumentStateNormal) {
        if ([self setupWithDocument:sharedDatabase]) {
            [self performSegueWithIdentifier:@"mainPage" sender:nil];
        }
        else {
            [self performSegueWithIdentifier:@"loginPage" sender:nil];
        }
    }
}

- (void)setDatabase:(UIManagedDocument *)database
{
    if (_database != database) {
        _database = database;
        sharedDatabase = database;
        [self useDocument];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_database) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"AccessDatabase"];
        self.database = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"loginPage"])
    {
        // [segue.destinationViewController setAccessDatabase:self.accessDatabase];
        [segue.destinationViewController setIsSecond:YES];
    } else if([segue.identifier isEqualToString:@"mainPage"]) {
        //设置标记
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
