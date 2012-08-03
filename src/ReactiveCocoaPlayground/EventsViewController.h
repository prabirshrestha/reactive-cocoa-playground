//
//  EventsViewController.h
//  ReactiveCocoaPlayground
//
//  Created by Prabir Shrestha on 8/3/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *pushMeButton1;
@property (strong, nonatomic) IBOutlet UILabel *outputLabel;

@property (strong, nonatomic) NSString *output;

@end
