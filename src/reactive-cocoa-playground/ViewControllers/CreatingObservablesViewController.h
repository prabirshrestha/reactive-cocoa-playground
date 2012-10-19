//
//  CreatingObservablesViewController.h
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 10/19/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreatingObservablesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *observableWithReturn;
@property (weak, nonatomic) IBOutlet UIButton *observableFromEmpty;
@property (weak, nonatomic) IBOutlet UIButton *observableFromArray;

@end
