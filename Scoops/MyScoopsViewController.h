//
//  MyScoopsViewController.h
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 26/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^profileCompletion)(NSDictionary* profInfo);
typedef void (^completeBlock)(NSArray* results);
typedef void (^completeOnError)(NSError *error);
typedef void (^completionWithURL)(NSURL *theUrl, NSError *error);


@interface MyScoopsViewController : UIViewController <UITableViewDelegate, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *scoopsTableView;
@property (strong, nonatomic) NSArray *arrayOfMyScoops;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

- (id) initWithScoops: (NSArray *) arrayOfScoops;

- (IBAction)segmentedControlAction:(id)sender;

@end
