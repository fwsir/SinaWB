//
//  WriteController.m
//  SinaWB
//
//  Created by Alex Li on 6/13/14.
//  Copyright (c) 2014 Alex Li. All rights reserved.
//

#import "WriteController.h"
#import "OAuthController.h"
#import "ViewController.h"

@interface WriteController ()

@end

@implementation WriteController
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
        _accessToken = [OAuthController getAccessToken];
    }
    else {
        _accessToken = [ViewController getAccessToken];
    }
    self.myTextView.delegate = self;
    [self.myTextView setTextColor:[UIColor lightGrayColor]];
    [self.sendButton setEnabled:NO];
    IsNeedClear = YES;
    //self.myTextView.layer.borderColor = [UIColor grayColor].CGColor;
    //self.myTextView.layer.borderWidth = 1.0;
    //self.myTextView.layer.cornerRadius = 0.5;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if ([text isEqualToString:@"\n"])
    {
        [_myTextView resignFirstResponder];
        return NO;
    }
    else if ([textView.text length] < 140) {
        
        return YES;
    }
    
    return NO;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if ([textView.text length] == 0)
    {
        [self.sendButton setEnabled:NO];
    }
    else {
        [self.sendButton setEnabled:YES];
    }
}

- (IBAction)cancelSend:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendWeibo:(id)sender
{
    //NSLog(@"%@", self.accessToken);
    NSString *params = [NSString stringWithFormat:@"&access_token=%@&status=%@", _accessToken, self.myTextView.text];
    NSMutableData *postData = [[NSMutableData alloc] init];
    [postData appendData:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:UpdateUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:3.0];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}



#pragma mark -
#pragma mark NSURLConnection Data Delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [[NSMutableData alloc] initWithLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:NULL];
    
    //NSLog(@"%@", dict);
    NSString *date = [dict objectForKey:@"created_at"];
    if (date) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Weibo"
                                                        message:@"Send Success."
                                                       delegate:self
                                              cancelButtonTitle:@"YES"
                                              otherButtonTitles:nil, nil];
        [alert show];
        //[self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Weibo"
                                                        message:@"Send Failed."
                                                       delegate:self
                                              cancelButtonTitle:@"YES"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    [connection cancel];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Weibo"
                                                    message:@"Send Failed With Error."
                                                   delegate:self
                                          cancelButtonTitle:@"YES"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [connection cancel];
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
