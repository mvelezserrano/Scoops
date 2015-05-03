//
//  MyNewViewController.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 25/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AzureSession.h"
#import "ScoopViewController.h"
#import "ASStarRatingView.h"
#import "Scoop.h"
#import "Settings.h"

@interface ScoopViewController () {
    AzureSession *azureSession;
}

@property (nonatomic) int rating;

@end

@implementation ScoopViewController

@synthesize actualRatingView;

-(id) initWithScoop: (Scoop *) scoop {
    
    if (self = [super initWithNibName:nil bundle:nil]) {
        
        _model = scoop;
        
        // Alta en notificación de cambio de status favorito.
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(setNewRating:)
                   name:RATING_DID_CHANGE_NOTIFICATION
                 object:nil];
    }
    
    return self;
}

- (IBAction)sendRating:(id)sender {
    NSLog(@"Enviamos a Azure el nuevo rating: %d", self.rating);
    
    self.valorarButton.enabled = NO;
    
    MSClient *client = [azureSession client];
    NSDictionary *parameters = @{@"idScoop" : self.model.id, @"newRating" : [NSNumber numberWithInt:self.rating]};
    
    [client invokeAPI:@"valoranoticia"
                 body:nil
           HTTPMethod:@"GET"
           parameters:parameters
              headers:nil
           completion:^(id result, NSHTTPURLResponse *response, NSError *error) {

               if (!error) {
                   
                   //NSLog(@"resultado --> %@", result);
                   NSLog(@"Api ha respondido");
               }
               
               self.valorarButton.enabled = YES;
           }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    azureSession = [AzureSession sharedAzureSession];
    
    [self syncViewWithModel];
}

- (void) dealloc {
    
    // Me doy de baja de las notificaciones
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void) syncViewWithModel {
    
    actualRatingView.canEdit = NO;
    actualRatingView.maxRating = 5;
    actualRatingView.rating = self.model.rating;
    
    self.titleView.text = self.model.title;
    self.autorView.text = self.model.authorName;
    self.textView.text = self.model.text;
}

- (void) setNewRating: (NSNotification *) notification {
    self.rating = [[notification.userInfo objectForKey:RATING_KEY] integerValue];
}















@end
