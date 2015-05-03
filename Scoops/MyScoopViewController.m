//
//  MyNewViewController.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 25/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "MyScoopViewController.h"
#import "ASStarRatingView.h"
#import "Scoop.h"
#import "Settings.h"

@interface MyScoopViewController () {
    MSClient *client;
}

@property (nonatomic) int actualRating;

@end

@implementation MyScoopViewController

@synthesize actualRatingView;

-(id) initWithScoop: (Scoop *) scoop client: (MSClient *) aClient {
    
    if (self = [super initWithNibName:nil bundle:nil]) {
        
        _model = scoop;
        client = aClient;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.model.status == PUBLISHED) {
        self.publishLabel.hidden = YES;
        self.publishSwitch.hidden = YES;
    }
    
    [self syncViewWithModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) syncViewWithModel {
    
    actualRatingView.canEdit = NO;
    actualRatingView.maxRating = 5;
    actualRatingView.rating = self.model.rating;
    
    self.titleView.text = self.model.title;
    self.textView.text = self.model.text;
    
    if (self.model.status == NOT_PUBLISHED) {
        [self.publishSwitch setOn:NO];
    } else {
        [self.publishSwitch setOn:YES];
    }
}

- (IBAction)publish:(id)sender {
    if ([sender isOn]) {
        self.model.status = PENDING;
    } else {
        self.model.status = NOT_PUBLISHED;
    }
    MSTable *table = [client tableWithName:@"news"];
    [table update:[self.model asDictionary] completion:^(NSDictionary *item, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error);
        } else {
            NSLog(@"MODIFICACIÓN DE SCOOP A PUBLICADA OK!!");
        }
    }];
}
@end
