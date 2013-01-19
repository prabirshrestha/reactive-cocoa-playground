//
//  MainViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 1/16/13.
//  Copyright (c) 2013 Prabir Shrestha. All rights reserved.
//

#import "MainViewController.h"

#import <BlocksKit.h>

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataSource;

@end

@implementation MainViewController

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
    
    self.dataSource = @[
        @"CreatingObservables",
        @"RxOperators",
        @"Events",
        @"Schedulers",
        @"AFNetworking",
        @"LoginSample",
        @"TwitterSearch",
        @"TwitterInstantSearch",
        @"LocationManager",
        @"Facebook",
        @"TableSamples",
    ];
    
    [self setupTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)setupTableView {
    [self.tableView.dynamicDataSource implementMethod:@selector(tableView:numberOfRowsInSection:) withBlock:^NSInteger(UITableView *tableView, NSInteger section) {
        return self.dataSource.count;
    }];
    
    [self.tableView.dynamicDataSource implementMethod:@selector(tableView:cellForRowAtIndexPath:) withBlock:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.textLabel.text = [self.dataSource objectAtIndex:indexPath.row];
        return cell;
    }];
    
    [self.tableView.dynamicDelegate implementMethod:@selector(tableView:didSelectRowAtIndexPath:) withBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSString *selected = [self.dataSource objectAtIndex:indexPath.row];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@Storyboard", selected] bundle:nil];
        UIViewController* vc = [storyboard instantiateInitialViewController];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    self.tableView.dataSource = self.tableView.dynamicDataSource;
    self.tableView.delegate = self.tableView.dynamicDelegate;
}

@end
