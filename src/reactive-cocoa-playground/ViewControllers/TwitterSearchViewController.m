//
//  TwitterSearchViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 11/10/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "TwitterSearchViewController.h"
#import "Api.h"
#import <ReactiveCocoa.h>
#import <SVPullToRefresh.h>

@interface TwitterSearchViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datasource;
@property (strong, nonatomic) Api *api;

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
             for (id result in [JSON objectForKey:@"results"]) {
                 NSLog(@"%@", result);
             }
         }
         error:^(NSError *error) {
             [self.tableView.pullToRefreshView stopAnimating];
         }
         completed:^{
             [self.tableView.pullToRefreshView stopAnimating];
         }];
    }];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

# pragma mark - table view delegate

@end
