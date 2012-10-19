//
//  WikipediaSearchViewController.h
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 10/19/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WikipediaSearchViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UILabel *searchingForLabel;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
