//
//  CommentController.m
//  SinaWB
//
//  Created by Alex Li on 6/16/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import "CommentController.h"
#import "OAuthController.h"
#import "ViewController.h"
#import "WriteCRController.h"
#import "CommentCell.h"
#import "UIImageView+WebCache.h"

@interface CommentController ()

@end

@implementation CommentController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([OAuthController getBool]) {
        self.accessToken = [OAuthController getAccessToken];
    }
    else {
        self.accessToken = [ViewController getAccessToken];
    }
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.indicator setColor:[UIColor grayColor]];
    [self.indicator setCenter:CGPointMake(160, 160)];
    [self.tableView addSubview:self.indicator];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentCell" bundle:nil] forCellReuseIdentifier:@"CommentCell"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self downloadCommentsAndReposts];
}

- (void)downloadCommentsAndReposts
{
    [self.indicator startAnimating];
    dispatch_queue_t commentQ = dispatch_queue_create("Comments", NULL);
    dispatch_async(commentQ, ^{
        
        NSString *str = nil;
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            str = [NSString stringWithFormat:@"%@?access_token=%@&id=%@", CommentsByID, self.accessToken, self.weiboID];
        }
        else {
            str = [NSString stringWithFormat:@"%@?access_token=%@&id=%@", RepostsByID, self.accessToken, self.weiboID];
        }
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
        
        if (self.segmentedControl.selectedSegmentIndex == 0)
        {
            self.comments = [dict objectForKey:@"comments"];
        }
        else {
            self.comments = [dict objectForKey:@"reposts"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.indicator stopAnimating];
        });
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    
    NSDictionary *dict = [self.comments objectAtIndex:indexPath.row];
    [cell contentSettingWithDict:dict];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [[self.comments objectAtIndex:indexPath.row] objectForKey:@"text"];
    int height = [CommentCell heightForText:text];
    
    return height+60;
}

- (IBAction)segmentValueChanged:(id)sender
{
    [self downloadCommentsAndReposts];
}

- (IBAction)backToController:(id)sender
{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.type = kCATransitionFade;
    animation.subtype = kCATransitionFromLeft;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    [self.view.window.layer addAnimation:animation forKey:@"CommentAnimation"];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)segueCRAction:(id)sender
{
    NSString *title = [sender titleForState:UIControlStateNormal];
    WriteCRController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"WriteCR"];
    [controller setWeiboID:self.weiboID];
    
    if ([title isEqualToString:@"评论"]) {
        [controller setIsComment:YES];
    }
    else {
        [controller setIsComment:NO];
    }
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromRight];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [self.view.window.layer addAnimation:animation forKey:@"WriteCRAnimation"];
    
    [self presentViewController:controller animated:NO completion:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
