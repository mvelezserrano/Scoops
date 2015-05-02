//
//  MyNewViewController.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 25/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "MyScoopViewController.h"
#import "Scoop.h"
#import "Settings.h"

@interface MyScoopViewController () {
    MSClient *client;
}

@end

@implementation MyScoopViewController

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
    
    self.titleView.text = self.model.title;
    self.textView.text = self.model.text;
}

- (IBAction)publish:(id)sender {
    self.model.status = PUBLISHED;
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
