//
//  MyNewViewController.h
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 25/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

@import UIKit;
@class Scoop;

@interface NewScoopViewController : UIViewController <UITextViewDelegate>


@property (weak, nonatomic) IBOutlet UITextField *scoopTitleView;
@property (weak, nonatomic) IBOutlet UITextView *scoopTextView;

@property (strong, nonatomic) Scoop *model;
- (IBAction)sendScoop:(id)sender;

@end
