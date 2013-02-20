//
//  TableOnlyViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 1/18/13.
//  Copyright (c) 2013 Prabir Shrestha. All rights reserved.
//

#import "TableOnlyViewController.h"
#import <ReactiveCocoa.h>
#import <BlocksKit.h>
#import <SVPullToRefresh.h>

@interface TableOnlyViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) BOOL fetching;
@property (nonatomic, strong) RACCommand *fetchCommand;

@end

@implementation TableOnlyViewController

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
    
    self.dataSource = [[NSMutableArray alloc] init];
    [self setupTableView];
    
    RACSignal *notFetching = [RACAbleWithStart(self.fetching) map:^id(id value) {
        return @(![value boolValue]);
    }];
    
    [notFetching subscribeNext:^(id x) {
        if([x boolValue]) {
            [self.tableView.pullToRefreshView stopAnimating];
        }
    }];
    
    self.fetchCommand = [RACCommand commandWithCanExecuteSignal:notFetching];
    
    [self.fetchCommand subscribeNext:^(id x) {
        self.fetching = YES;
    }];
    
    RACSignal *fetchedResult =
        [self.fetchCommand sequenceMany:^RACStream *{
            return [[self fetchData] materialize];
        }];
    
    [[fetchedResult filter:^BOOL(RACEvent *value) {
        return value.eventType != RACEventTypeNext;
    }] subscribeNext:^(id x) {
        self.fetching = NO;
    }];
    
    [[[fetchedResult dematerialize]
     doNext:^(id x) {
         NSLog(@"%@", x);
     }]
     subscribeNext:^(id x) {
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:x];
        [self.tableView reloadData];
    }];
    
    [self.fetchCommand execute:nil];
    //[self.tableView triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void) setupTableView {
    [self.tableView addPullToRefreshWithActionHandler:^{
        [self.fetchCommand execute:nil];
    }];
    
    [self.tableView.dynamicDataSource implementMethod:@selector(tableView:numberOfRowsInSection:) withBlock:^NSInteger(UITableView *tableView, NSInteger section) {
        return self.dataSource.count;
    }];
    
    [self.tableView.dynamicDataSource implementMethod:@selector(tableView:cellForRowAtIndexPath:) withBlock:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        id data = [self.dataSource objectAtIndex:indexPath.row];
        cell.textLabel.text = [data objectForKey:@"name"];
        return cell;
    }];
    
    self.tableView.dataSource = self.tableView.dynamicDataSource;
}

- (RACSignal*) fetchData {
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"iso3166Countries" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    
    NSError *error = nil;
    id JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if(error) {
        [subject sendError:error];
    } else {
        [subject sendNext:JSON];
        [subject sendCompleted];
    }
    
    return subject;
}

@end
