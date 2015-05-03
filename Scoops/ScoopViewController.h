//
//  MyNewViewController.h
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 25/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
@import UIKit;
@class Scoop;
@class ASStarRatingView;

@interface ScoopViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *autorView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *valorarButton;

@property (weak, nonatomic) IBOutlet ASStarRatingView *actualRatingView;

@property (strong, nonatomic) Scoop *model;

-(id) initWithScoop: (Scoop *) scoop;

- (IBAction)sendRating:(id)sender;
@end