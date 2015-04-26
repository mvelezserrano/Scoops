//
//  MyScoopsViewController.h
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 26/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyScoopsViewController : UIViewController <UITableViewDelegate, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *scoopsTableView;
@property (strong, nonatomic) NSArray *arrayOfMyScoops;

- (id) initWithScoops: (NSArray *) arrayOfScoops;

- (IBAction)segmentedControlAction:(id)sender;

@end
