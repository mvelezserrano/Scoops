//
//  MyNewViewController.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 25/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AzureSession.h"
#import "MyScoopViewController.h"
#import "ASStarRatingView.h"
#import "Scoop.h"
#import "Settings.h"

@interface MyScoopViewController () {
    AzureSession *azureSession;
}

@property (nonatomic) int actualRating;

@end

@implementation MyScoopViewController

@synthesize actualRatingView;

-(id) initWithScoop: (Scoop *) scoop {
    
    if (self = [super initWithNibName:nil bundle:nil]) {
        
        azureSession = [AzureSession sharedAzureSession];
        _model = scoop;
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
    
    if (self.model.downloaded == NO) {
        [self downloadScoop];
    } else {
        [self syncViewWithModel];
    }
}

- (void) downloadScoop {
    MSClient *client = [azureSession client];
    
    MSTable *table = [client tableWithName:@"news"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"id == %@", self.model.id];
    MSQuery *queryModel = [table queryWithPredicate: predicate];
    [queryModel readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        id item = [items objectAtIndex:0];
        self.model.text = item[@"text"];
        self.model.authorId = item[@"authorId"];
        self.model.imageURL = [NSURL URLWithString:item[@"imageurl"]];
        self.model.coors = CLLocationCoordinate2DMake(0, 0);
        self.model.creationDate = item[@"creationDate"];
        self.model.status = [item[@"status"] integerValue];
        self.model.rating = [item[@"valoracion"] integerValue];
        self.model.downloaded = YES;
        
        [self syncViewWithModel];
    }];
    
}


- (void) syncViewWithModel {
    
    actualRatingView.canEdit = NO;
    actualRatingView.maxRating = 5;
    actualRatingView.rating = self.model.rating;
    
    self.titleView.text = self.model.title;
    self.scoopPhotoView.image = self.model.image;
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
    MSClient *client = [azureSession client];
    MSTable *table = [client tableWithName:@"news"];
    [table update:[self.model asDictionary] completion:^(NSDictionary *item, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error);
        }
    }];
}
@end
