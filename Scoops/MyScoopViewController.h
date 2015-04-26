//
//  MyNewViewController.h
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 25/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

@import UIKit;
@class Scoop;

@interface MyScoopViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) Scoop *model;

-(id) initWithScoop: (Scoop *) scoop;

- (IBAction)publish:(id)sender;
@end