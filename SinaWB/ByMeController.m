//
//  ByMeController.m
//  SinaWB
//
//  Created by Alex Li on 6/16/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import "ByMeController.h"
#import "CommentController.h"
#import "SinaCell.h"
#import "OAuthController.h"
#import "ViewController.h"

@interface ByMeController ()
{
    BOOL reloading;
    BOOL getResult;
    EGORefreshTableHeaderView *refreshView;
}

@end

@implementation ByMeController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([OAuthController getBool]) {
        _accessToken = [OAuthController getAccessToken];
    }
    else {
        _accessToken = [ViewController getAccessToken];
    }
    
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_activity setColor:[UIColor grayColor]];
    [_activity setCenter:CGPointMake(160, 160)];
    
    [self.tableView addSubview:_activity];
    [self.tableView registerClass:[SinaCell class] forCellReuseIdentifier:@"WeiboCell"];
    [_activity startAnimating];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
        [self.navigationController.view setBackgroundColor:[UIColor whiteColor]];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (refreshView == nil) {
        refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0-self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
    }
    [refreshView setDelegate:self];
    [self.tableView addSubview:refreshView];
    
    [refreshView refreshLastUpdatedDate];
    [self initialDownload];
}

- (void)initialDownload
{
    dispatch_queue_t downloadQ = dispatch_queue_create("UserWeibo", NULL);
    dispatch_async(downloadQ, ^{
        NSString *str = [NSString stringWithFormat:@"%@?access_token=%@&screen_name=fwsir", UserWeibo, _accessToken];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
        NSDictionary *timeline = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
        self.statuses = [timeline objectForKey:@"statuses"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [_activity stopAnimating];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.statuses count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SinaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeiboCell" forIndexPath:indexPath];
    
    [cell setContent:[self.statuses objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = [SinaCell heightWith:[self.statuses objectAtIndex:indexPath.row]];
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentController"];
    NSString *weiboID = [[self.statuses objectAtIndex:indexPath.row] objectForKey:@"id"];
    [controller setWeiboID:weiboID];
    //[self.navigationController pushViewController:controller animated:YES];
    
    
    // 修改动画  动画方式一
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionFade;
    animation.subtype = kCATransitionFromRight;
    [self.view.window.layer addAnimation:animation forKey:@"CommentAnimation"];
    [self presentViewController:controller animated:NO completion:nil];
    
    
    // 修改动画 动画方式二
    /*[UIView beginAnimations:@"CommentAnimation" context:NULL];
     [UIView setAnimationDuration:1.0];
     [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
     [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
     [self presentViewController:controller animated:NO completion:nil];
     [UIView commitAnimations];*/
    
    // 修改动画 动画方式二  写法二
    /*[UIView transitionWithView:self.view
     duration:0.3
     options:UIViewAnimationOptionTransitionFlipFromLeft
     animations:^{
     [self presentViewController:controller animated:NO completion:nil];
     }
     completion:nil];*/
}


- (void)downloadData
{
    NSString *str = [NSString stringWithFormat:@"%@?access_token=%@&screen_name=fwsir", UserWeibo, _accessToken];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
    if (data != nil)
    {
        NSDictionary *timeLine = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
        getResult = YES;
        self.statuses = [timeLine objectForKey:@"statuses"];
    }
    else
        getResult = NO;

}

- (void)reloadTableViewDataSource
{
    reloading = YES;
    [self downloadData];
}

- (void)doneLoadingTableViewData
{
    reloading = NO;
    if (getResult)
    {
        [self.tableView reloadData];
        [refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取数据失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [refreshView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    reloading = YES;
    [NSThread detachNewThreadSelector:@selector(reloadTableViewDataSource) toTarget:self withObject:nil];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return reloading;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
