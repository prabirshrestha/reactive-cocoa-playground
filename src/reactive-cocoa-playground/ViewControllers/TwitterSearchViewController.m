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

@interface TwitterSearchViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datasource;

@property (strong, nonatomic) Api *api;
@property (strong, nonatomic) WBNoticeView *currentNoticeView;

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
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        
        RACSubscribable *request = [self.api
                                    requestJSONWithMethod:@"GET"
                                    path:@"http://search.twitter.com/search.json"
                                    parameters:@{ @"q": @"#twitterapi"}];
        
        [request
         subscribeNext:^(id JSON) {
             if(self.currentNoticeView) {
                 [self.currentNoticeView dismissNotice];
             }
//             [self.datasource removeAllObjects];
//             [self.tableView reloadData];
             for (id result in [JSON objectForKey:@"results"]) {
                 NSString *text = [result objectForKey:@"text"];
                 [self.tableView beginUpdates];
                 [self.datasource insertObject:text atIndex:0];
                 [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                 [self.tableView endUpdates];
             }
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
         }
         completed:^{
             [self.tableView.pullToRefreshView stopAnimating];
         }];
        
    }];
    
    [self.tableView.pullToRefreshView triggerRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
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
