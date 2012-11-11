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
    
    RACSubscribable *searching = RACAble(self.searching);
    RACSubscribable *notSearching = [searching select:^id(id x) {
        return @(![x boolValue]);
    }];
    
    // command for searching tweets online
    // search tweet is enabled only when we are not already searching
    RACAsyncCommand *searchTweetsOnline =
        [RACAsyncCommand commandWithCanExecuteSubscribable:notSearching block:nil];
    
    // update ui when new tweets arrive
    RACSubject *receivedNewTweets = [RACSubject subject];
    [[receivedNewTweets
     deliverOn:[RACScheduler mainQueueScheduler]]
     subscribeNext:^(id JSON) {
         [self.datasource removeAllObjects];
         [self.tableView reloadData];
         for (id result in [JSON objectForKey:@"results"]) {
             NSString *text = [result objectForKey:@"text"];
             [self.tableView beginUpdates];
             [self.datasource insertObject:text atIndex:0];
             [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
             [self.tableView endUpdates];
         }
     }];
    
    // update cache
    RACAsyncCommand *saveToCache = [RACAsyncCommand commandWithBlock:nil];
    [saveToCache
     subscribeNext:^(NSData *x) {
         [[EGOCache currentCache] setData:x forKey:CACHEKEY_TWITTER withTimeoutInterval:30]; // 30 seconds
     }];
    
    [searchTweetsOnline
     subscribeNext:^(id x) {
         RACSubscribable *request =
            [self.api
             requestJSONWithMethod:@"GET"
             path:@"http://search.twitter.com/search.json"
             parameters:@{ @"q": @"#twitterapi"}];

         [request
          subscribeNext:^(id xs) {
              if(self.currentNoticeView) {
                  [self.currentNoticeView dismissNotice];
              }              
              [receivedNewTweets sendNext:xs[0]]; // send notification that new tweets have been received
              [saveToCache sendNext:xs[1]]; // notify we need to update the cache with new tweets
          }
          error:^(NSError *error) {
              if(self.currentNoticeView) {
                  [self.currentNoticeView dismissNotice];
              }
              
              WBNoticeView *noticeView =
              [WBErrorNoticeView
               errorNoticeInView:self.view
               title:@"Network Error"
               message:@"Check your network connection"];
              noticeView.sticky = YES;
              [noticeView show];
              
              self.currentNoticeView = noticeView;
              [self.tableView.pullToRefreshView stopAnimating];
              self.searching = NO;
          }
          completed:^{
              self.searching = NO;
              [self.tableView.pullToRefreshView stopAnimating];
          }];
     }];
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [searchTweetsOnline sendNext:nil];
    }];
    
    self.searching = NO;
    
    NSData *cachedData = [[EGOCache currentCache] dataForKey:CACHEKEY_TWITTER];
    if(cachedData == nil) {
        [self.tableView.pullToRefreshView triggerRefresh];
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
