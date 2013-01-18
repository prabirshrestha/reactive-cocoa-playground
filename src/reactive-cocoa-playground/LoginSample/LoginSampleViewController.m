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

@property (nonatomic, assign) BOOL logingIn;

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
    RACSignal *formValid =
    [RACSignal
     combineLatest:@[self.usernameField.rac_textSignal, self.passwordField.rac_textSignal]
     reduce:^(NSString *username, NSString *password) {
         return @(username.length > 0 && password.length > 0);
     }];
    
    // are we loging in?
    RACSignal *logingIn = RACAble(self.logingIn);
    
    // enable/disable button based on form valid
    RACSignal *buttonEnabled =
    [RACSignal
     combineLatest:@[formValid, logingIn]
     reduce:^(id formValid, id logingIn){
         return @([formValid boolValue] && ![logingIn boolValue]);
     }];
    
    RAC(self.loginButton.enabled) = buttonEnabled;
    
    // button color based on enabledness
    UIColor *defaultButtonTitleColor = self.loginButton.titleLabel.textColor;
    RACSignal *loginButtonTitileColor = [buttonEnabled map:^id(id x) {
        return [x boolValue] ? defaultButtonTitleColor : [UIColor lightGrayColor];
    }];
    
    [loginButtonTitileColor subscribeNext:^(UIColor *color) {
        [self.loginButton setTitleColor:color forState:UIControlStateNormal];
    }];
    
    self.logingIn = NO;
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
