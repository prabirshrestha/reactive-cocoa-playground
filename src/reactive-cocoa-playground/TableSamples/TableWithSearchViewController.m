//
//  TableWithSearchViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 1/20/13.
//  Copyright (c) 2013 Prabir Shrestha. All rights reserved.
//

#import "TableWithSearchViewController.h"
#import <ReactiveCocoa.h>
#import <BlocksKit.h>
#import <SVPullToRefresh.h>

@interface TableWithSearchViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, assign) BOOL fetching;
@property (nonatomic, strong) RACCommand *fetchCommand;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *displayDataSource;

@end

@implementation TableWithSearchViewController

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
    self.displayDataSource = [[NSMutableArray alloc] initWithArray:self.dataSource];
    
    [self setupTableView];
    
    RACSignal *notFetching = [RACAbleWithStart(self.fetching) map:^id(id value) {
        return @(![value boolValue]);
    }];
    
    [notFetching subscribeNext:^(id x) {
        if([x boolValue]) {
            [self.tableView.pullToRefreshView stopAnimating];
        }
    }];
    
    self.fetchCommand = [RACCommand commandWithCanExecuteSignal:notFetching block:nil];
    
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
     subscribeNext:^(NSArray *x) {
         self.dataSource = x;
         [self.displayDataSource removeAllObjects];
         [self.displayDataSource addObjectsFromArray:self.dataSource];
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
    [self setSearchBar:nil];
    [super viewDidUnload];
}


- (void) setupTableView {
    [self.tableView addPullToRefreshWithActionHandler:^{
        [self.fetchCommand execute:nil];
    }];
    
    [self.tableView.dynamicDataSource implementMethod:@selector(numberOfSectionsInTableView:) withBlock:^NSInteger(UITableView *tableView) {
        return 1;
    }];
    
    [self.tableView.dynamicDataSource implementMethod:@selector(tableView:numberOfRowsInSection:) withBlock:^NSInteger(UITableView *tableView, NSInteger section) {
        return self.displayDataSource.count;
    }];
    
    [self.tableView.dynamicDataSource implementMethod:@selector(tableView:cellForRowAtIndexPath:) withBlock:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        id data = [self.displayDataSource objectAtIndex:indexPath.row];
        cell.textLabel.text = [data objectForKey:@"name"];
        return cell;
    }];
    
    self.tableView.dataSource = self.tableView.dynamicDataSource;
    
    // search bar
    
    [self.searchBar.dynamicDelegate implementMethod:@selector(searchBarSearchButtonClicked:) withBlock:^void(UISearchBar* searchBar) {
        [searchBar resignFirstResponder];
    }];
    
    [self.searchBar.dynamicDelegate implementMethod:@selector(searchBarCancelButtonClicked:) withBlock:^void(UISearchBar* searchBar) {
        [searchBar resignFirstResponder];
    }];
    
    RACReplaySubject *searchTextChanged = [RACReplaySubject subject];
    
    [self.searchBar.dynamicDelegate implementMethod:@selector(searchBar:textDidChange:) withBlock: ^void(UISearchBar *searchBar, NSString *searchText) {
        [searchTextChanged sendNext:searchText];
    }];
    self.searchBar.delegate = self.searchBar.dynamicDelegate;
    
    [[searchTextChanged filter:^BOOL(NSString *value) {
        return value.length == 0;
    }] subscribeNext:^(id x) {
        [self.displayDataSource removeAllObjects];
        [self.displayDataSource addObjectsFromArray:self.dataSource];
        [self.tableView reloadData];
    }];
    
    [[[searchTextChanged filter:^BOOL(NSString *value) {
        return value.length > 0;
    }] doNext:^(id x) {
        NSLog(@"%@", x);
    }] subscribeNext:^(NSString *x) {
        [self.displayDataSource removeAllObjects];
        for (id data in self.dataSource) {
            NSRange range = [[data objectForKey:@"name"] rangeOfString:x options:NSCaseInsensitiveSearch];
            if(range.location != NSNotFound) {
                [self.displayDataSource addObject:data];
            }
        }
        [self.tableView reloadData];
    }];
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
