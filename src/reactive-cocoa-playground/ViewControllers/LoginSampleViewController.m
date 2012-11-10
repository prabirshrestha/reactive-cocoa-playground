//
//  LoginSampleViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 11/9/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "LoginSampleViewController.h"
#import <ReactiveCocoa.h>

@interface LoginSampleViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, assign) BOOL processing;

@end

@implementation LoginSampleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(!self) return nil;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // are all entries valid?
    RACSubscribable *formValid =
        [RACSubscribable
         combineLatest:@[
            self.usernameField.rac_textSubscribable,
            self.passwordField.rac_textSubscribable
         ] reduce:^id(RACTuple *xs) {
             NSString *username = xs[0];
             NSString *password = xs[1];
             
             return @(username.length > 0 && password.length > 0);
         }];
    
    // are we processing login?
    RACSubscribable *processing = RACAble(self.processing);
    
    // button enabledness depends when form is valid and not processing
    RACSubscribable *buttonEnabled =
        [RACSubscribable
         combineLatest:@[formValid, processing]
         reduce:^id(RACTuple *xs) {
             BOOL formValid = [xs[0] boolValue];
             BOOL processing = [xs[1] boolValue];
             return @(formValid && !processing);
         }];
    
    RAC(self.loginButton.enabled) = buttonEnabled;
    
    // defaults
    self.processing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setUsernameField:nil];
    [self setPasswordField:nil];
    [self setLoginButton:nil];
    [super viewDidUnload];
}
@end
