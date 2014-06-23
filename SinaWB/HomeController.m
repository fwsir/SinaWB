//
//  HomeController.m
//  SinaWB
//
//  Created by Alex Li on 5/29/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import "HomeController.h"
#import "ViewController.h"
#import "OAuthController.h"
#import "DetailController.h"
#import "WriteController.h"
#import "CommentController.h"
#import "SinaCell.h"

@interface HomeController ()
{
    BOOL reloading;
    BOOL getResult;
    EGORefreshTableHeaderView *refreshView;
}

@end

@implementation HomeController

static NSString *CellIdentifier = @"SinaCell";

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
    
    
    if (![OAuthController getBool]) {
        self.accessToken = [ViewController getAccessToken];
    }
    else
    {
        self.accessToken = [OAuthController getAccessToken];
    }
    
    getResult = NO;
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activity setColor:[UIColor grayColor]];
    [self.activity setCenter:CGPointMake(160, 160)];
    [self.tableView registerClass:[SinaCell class] forCellReuseIdentifier:CellIdentifier];
    [self.tableView addSubview:self.activity];
    
    // 解决下拉刷新后 TableView位置偏移的问题。
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        [self.navigationController.view setBackgroundColor:[UIColor whiteColor]];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (refreshView == nil){
        refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0-self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    }
    [refreshView setDelegate:self];
    [self.tableView addSubview:refreshView];
    [self.activity startAnimating];
    
    [refreshView refreshLastUpdatedDate];
    [self initialDownloadData];
}

- (void)downloadData
{
    NSString *url = [NSString stringWithFormat:@"%@?access_token=%@", Homeweibo, self.accessToken];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        
    if (data != nil)
    {
        NSDictionary *timeLine = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
        getResult = YES;
        self.statuses = [timeLine valueForKey:@"statuses"];
    }
    else
        getResult = NO;
}

- (void)initialDownloadData
{
    dispatch_queue_t downloadQ = dispatch_queue_create("downloadHome", NULL);
    dispatch_async(downloadQ, ^{
        //reloading = YES;
        NSString *url = [NSString stringWithFormat:@"%@?access_token=%@", Homeweibo, self.accessToken];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        
        //NSLog(@"%@\n%@", url, data);
        NSDictionary *timeLine = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
        self.statuses = [timeLine valueForKey:@"statuses"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.navigationItem.leftBarButtonItem = sender;
            [self.tableView reloadData];
            [self.activity stopAnimating];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark    TableView Data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int iTop = [SinaCell heightWith:[_statuses objectAtIndex:indexPath.row]];
    
    return iTop;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_statuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SinaCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setContent:[_statuses objectAtIndex:indexPath.row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentController"];
    NSString *weiboID = [[self.statuses objectAtIndex:indexPath.row] objectForKey:@"id"];
    [controller setWeiboID:weiboID];
    //[self.navigationController pushViewController:controller animated:YES];
    
    
    // 修改动画  动画方式一
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
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


#pragma mark -
#pragma mark    下拉刷新功能

- (void)reloadTableViewDataSource
{
    reloading = YES;
    [self downloadData];
}

- (void)doneLoadingTableViewData
{
    reloading = NO;
    if (getResult) {
        [self.tableView reloadData];
    } else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取数据失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[refreshView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[refreshView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    //[self reloadTableViewDataSource];
    reloading = YES;
    
    // 这里的问题：当第一个函数的耗时超过 3.0s 时，执行第二个函数则不能正确的得到数据。
    [NSThread detachNewThreadSelector:@selector(reloadTableViewDataSource) toTarget:self withObject:nil];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return reloading; // should return if data source model is reloading
	
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
