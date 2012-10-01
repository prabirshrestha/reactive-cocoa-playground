//
//  AFNetworkingViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 9/30/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "AFNetworkingViewController.h"
#include <ReactiveCocoa.h>
#include <AFNetworking.h>

@interface AFNetworkingViewController ()

@end

@implementation AFNetworkingViewController {
    AFHTTPClient *client;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    client = [[AFHTTPClient alloc]init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.textView.text = nil;
    
    [[self
     requestWithMethod:@"GET"
     path:@"https://graph.facebook.com/4"
     parameters:nil]
     subscribeNext:^(NSString *x) {
         self.textView.text = x;
     } error:^(NSError *error) {
         self.textView.text = error.description;
     } completed:^{
         NSLog(@"completd");
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

# pragma mark - AFNetworking RAC helper

- (RACSubscribable*)requestWithMethod:(NSString*)method
                                 path:(NSString*)path
                           parameters:(NSDictionary *)parameters {
    
    RACAsyncSubject *subject = [RACAsyncSubject subject];
	NSURLRequest *request = [client requestWithMethod:method path:path parameters:parameters];
	AFHTTPRequestOperation *operation =
    [client
     HTTPRequestOperationWithRequest:request
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
		[subject sendNext:operation.responseString];
		[subject sendCompleted];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[subject sendError:error];
     }];
    
    [operation start];
    
    return subject;
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
@end
