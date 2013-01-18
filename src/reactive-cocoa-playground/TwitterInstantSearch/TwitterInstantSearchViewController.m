//
//  TwitterInstantSearchViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 1/18/13.
//  Copyright (c) 2013 Prabir Shrestha. All rights reserved.
//

#import "TwitterInstantSearchViewController.h"
#import "Api.h"
#import "TwitterInstantSearchModel.h"
#import <BlocksKit.h>
#import <ReactiveCocoa.h>

@interface TwitterInstantSearchViewController () {
    Api *api;
}

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITextView *recentList;
@property (weak, nonatomic) IBOutlet UITextView *searchResults;

@end

@implementation TwitterInstantSearchViewController

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
    api = [[Api alloc] init];
    
    [self.view whenTapped:^{
        [self.view endEditing:YES];
    }];
    
    [[[[[[[[[self.searchTextField
     rac_textSignal]
     filter:^BOOL(NSString *value) {
         return value.length > 2;
     }]
     doNext:^(NSString *x) {
         NSLog(@"[%@] Text Changed: %@", [NSThread currentThread], x);
     }]
     throttle: .6]
     doNext:^(id x) {
         NSLog(@"[%@] Throttle Changed: %@", [NSThread currentThread], x);
     }]
     doNext:^(NSString *x) {
         self.recentList.text = [NSString stringWithFormat:@"%@ \n%@", self.recentList.text, x];
     }]
     subscribeOn:[RACScheduler mainThreadScheduler]]
     flattenMap:^RACStream *(id value) {
         return [self searchTwitter:value];
     }]
     subscribeNext:^(NSArray *x) {
         // how do i flatten the array to single items? subscribeNext:^(TwitterInstantSearchModel *x)
         self.searchResults.text = [NSString stringWithFormat:@"%@ \n%@", self.searchResults.text, x];
         NSLog(@"%@", x);
     }];
}

- (RACSignal*) searchTwitter:(NSString*)searchText {
    return [[[api
            requestJSONWithMethod:@"GET"
            path:@"https://search.twitter.com/search.json"
            parameters:@{@"q": searchText}]
            map:^id(id value) {
                return [value[0] objectForKey:@"results"];
            }]
            map:^id(id value) {
                return [value map:^id(id value) {
                    TwitterInstantSearchModel *model = [[TwitterInstantSearchModel alloc] initWithDictionary:value];
                    return model;
                }];
            }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setSearchTextField:nil];
    [self setRecentList:nil];
    [self setSearchResults:nil];
    [super viewDidUnload];
}

@end
