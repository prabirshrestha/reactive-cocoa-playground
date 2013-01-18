//
//  EventsViewController.h
//  ReactiveCocoaPlayground
//
//  Created by Prabir Shrestha on 8/3/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *pushMeButton1;
@property (strong, nonatomic) IBOutlet UIButton *pushMeButton2;
@property (strong, nonatomic) IBOutlet UILabel *outputLabel;
@property (strong, nonatomic) IBOutlet UITextField *textField1;

@property (strong, nonatomic) NSString *output;

@end
