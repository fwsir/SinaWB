//
//  FriendsController.m
//  SinaWB
//
//  Created by Alex Li on 6/12/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import "FriendsController.h"
#import "OAuthController.h"
#import "ViewController.h"
#import "UIImageView+WebCache.h"

@interface FriendsController ()

@end

@implementation FriendsController
{
    //NSMutableArray *images;
}

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (![OAuthController getBool]) {
        self.accessToken = [ViewController getAccessToken];
    }
    else {
        self.accessToken = [OAuthController getAccessToken];
    }
    
    //images = [NSMutableArray array];
    
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activity setColor:[UIColor grayColor]];
    [self.activity setCenter:CGPointMake(160, 160)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"friendsCell"];
    [self.tableView addSubview:self.activity];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.0) {
        [self.navigationController.view setBackgroundColor:[UIColor whiteColor]];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self.activity startAnimating];
    [self initialDownloadData];
}

- (void)initialDownloadData
{
    dispatch_queue_t downloadQ = dispatch_queue_create("downloadFollower", NULL);
    dispatch_async(downloadQ, ^{
        NSString *url = [NSString stringWithFormat:@"%@?screen_name=fwsir&access_token=%@", FollowersUrl, self.accessToken];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
        self.users = [dict objectForKey:@"users"];
        
        // 反应有点慢，图片加载过多
        /*for (NSDictionary *dict in self.users) {
            NSString *urlStr = [dict objectForKey:@"profile_image_url"];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]]];
            [images addObject:image];
        }*/
        
        dispatch_async(dispatch_get_main_queue(), ^{
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.users count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendsCell" forIndexPath:indexPath];
    
    NSDictionary *dict = [self.users objectAtIndex:indexPath.row];
    NSString *screenName = [dict objectForKey:@"screen_name"];
    NSString *description = [dict objectForKey:@"description"];
    NSString *imageUrl = [dict objectForKey:@"profile_image_url"];
    
    // 这种方法，图片加载过多，网络不好时延迟较大。
    //[cell.imageView setImage:[images objectAtIndex:indexPath.row]];
    
    // 这种方法，界面会卡顿。
    // [cell.imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]]];
    
    // 这种方法，文字会先于图片显示。
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
    cell.textLabel.text = screenName;
    cell.detailTextLabel.text = description;

    
    return cell;
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
