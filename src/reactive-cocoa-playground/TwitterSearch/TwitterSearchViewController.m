//
//  TwitterSearchViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 11/10/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "TwitterSearchViewController.h"
#import "TwitterSearchTableViewCell.h"
#import "Api.h"
#import <ReactiveCocoa.h>
#import <SVPullToRefresh.h>
#import <WBNoticeView.h>
#import <WBErrorNoticeView.h>
#import <EGOCache.h>
#import "EXTScope.h"

#define CACHEKEY_TWITTER @"twitter"

@interface TwitterSearchViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datasource;

@property (strong, nonatomic) Api *api;
@property (strong, nonatomic) WBNoticeView *currentNoticeView;

@property (assign, nonatomic) BOOL searching;

@end

@implementation TwitterSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(!self) return nil;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.api = [[Api alloc] init];
    
    self.datasource = [NSMutableArray array];
    
    RACSignal *searching = RACAble(self.searching);
    RACSignal *notSearching = [searching map:^id(id x) {
        return @(![x boolValue]);
    }];
    
    RACCommand *searchTweetsOnline = [RACCommand commandWithCanExecuteSignal:notSearching block:nil];
    
    RACSubject *receivedNewTweets = [RACSubject subject];
    [[receivedNewTweets
     deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id x) {
         [self.datasource removeAllObjects];
         
         for (id result in [x objectForKey:@"results"]) {
             NSString *text = [result objectForKey:@"text"];
             //             [self.tableView beginUpdates];
             [self.datasource insertObject:text atIndex:0];
             //             [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
             //             [self.tableView endUpdates];
         }
         
         [self.tableView reloadData];
     }];
    
    RACSubject *saveToCache = [RACSubject subject];
    [saveToCache subscribeNext:^(id x) {
        [[EGOCache currentCache] setData:x forKey:CACHEKEY_TWITTER withTimeoutInterval:30]; // 30 seconds
    }];
    
    [searchTweetsOnline subscribeNext:^(id x) {
        RACSignal *request = [self.api
                              requestJSONWithMethod:@"GET"
                              path:@"http://search.twitter.com/search.json"
                              parameters:@{@"q": @"#twitterapi"}];
        
        [request
         subscribeNext:^(id x) {
            [self.currentNoticeView dismissNotice];
            
            [receivedNewTweets sendNext:x[0]];
            [saveToCache sendNext:x[1]];
         }
         error:^(NSError *error) {
             [self.currentNoticeView dismissNotice];
             
             WBNoticeView *noticeView =
             [WBErrorNoticeView
              errorNoticeInView:self.view
              title:@"Network Error"
              message:@"Check your network connection"];
              noticeView.sticky = YES;
             [noticeView show];
             
             self.currentNoticeView = noticeView;
             [self.tableView.pullToRefreshView stopAnimating];
         }
         completed:^{
             self.searching = NO;
             [self.tableView.pullToRefreshView stopAnimating];
         }];
    }];
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [searchTweetsOnline sendNext:nil];
    }];
    
    NSData *cachedData = [[EGOCache currentCache] dataForKey:CACHEKEY_TWITTER];
    if(cachedData == nil) {
        [self.tableView triggerPullToRefresh];
    } else {
        NSError *error = nil;
        id JSON = [NSJSONSerialization JSONObjectWithData:cachedData options:kNilOptions error:&error];
        if(!error) {
            [receivedNewTweets sendNext:JSON]; // send notification that we have received tweets
        }
    }
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
    self.datasource = nil;
    self.api = nil;
    self.currentNoticeView = nil;
}

# pragma mark - table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TwitterSearchCellIdentifier";
    
    TwitterSearchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[TwitterSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    [cell listenForChanges];
    cell.tweet = [self.datasource objectAtIndex:indexPath.row];
    
    return cell;
    
}

@end
