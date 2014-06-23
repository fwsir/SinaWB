//
//  WriteCRController.m
//  SinaWB
//
//  Created by Alex Li on 6/18/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import "WriteCRController.h"
#import "OAuthController.h"
#import "ViewController.h"

@interface WriteCRController ()

@end

@implementation WriteCRController
{
    BOOL IsNeedClear;
}

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
    
    [self.myTextView setTextColor:[UIColor lightGrayColor]];
    if (self.isComment) {
        self.myNavItem.title = @"发表评论";
        self.myTextView.text = @"评论点啥呢?";
    }
    else {
        self.myNavItem.title = @"转发微博";
        self.myTextView.text = @"转发点啥呢?";
    }
    IsNeedClear = YES;
    self.myTextView.delegate = self;
    [self.sendButton setEnabled:NO];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (IsNeedClear) {
        self.myTextView.text = @"";
        [self.myTextView setTextColor:[UIColor blackColor]];
        IsNeedClear = NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (1 == range.length) {
        return YES;
    }
    
    if ([@"\n" isEqualToString:text]) {
        [self.myTextView resignFirstResponder];
        return NO;
    }
    else if ([textView.text length] < 140) {
        return YES;
    }
    return NO;
}


- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        [self.sendButton setEnabled:NO];
    }
    else {
        [self.sendButton setEnabled:YES];
    }
    
}

- (void)dissMissController
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [self.view.window.layer addAnimation:animation forKey:@"WriteCRAnimation"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sentBackAction:(id)sender
{
    [self dissMissController];
}

- (IBAction)sentTextAction:(id)sender
{
    NSString *params;
    NSString *strUrl;
    if (self.isComment)
    {
        params = [NSString stringWithFormat:@"access_token=%@&comment=%@&id=%@", self.accessToken, self.myTextView.text, self.weiboID];
        strUrl = HuiFuUrl;
    }
    else {
        params = [NSString stringWithFormat:@"access_token=%@&status=%@&id=%@", self.accessToken, self.myTextView.text, self.weiboID];
        strUrl = RepostUrl;
    }
    
    NSMutableData *postData = [[NSMutableData alloc] init];
    [postData appendData:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:3.0];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
   
    [self dissMissController];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [[NSMutableData alloc] init];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)theconnection
{
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
    
    NSString *date = [dict objectForKey:@"created_at"];
    if(date)
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发送成功！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发送失败！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    
    [self.connection cancel];
}

-(void)connection:(NSURLConnection *)theconnection didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发送失败！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [self.connection cancel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
