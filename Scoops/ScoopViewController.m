//
//  MyNewViewController.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 25/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "ScoopViewController.h"
#import "Scoop.h"
#import "Settings.h"

@interface ScoopViewController ()

@property (nonatomic) int rating;

@end

@implementation ScoopViewController

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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self syncViewWithModel];
}

- (void) dealloc {
    
    // Me doy de baja de las notificaciones
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void) syncViewWithModel {
    
    self.titleView.text = self.model.title;
    self.autorView.text = self.model.authorName;
    self.textView.text = self.model.text;
}

- (void) setNewRating: (NSNotification *) notification {
    self.rating = [[notification.userInfo objectForKey:RATING_KEY] integerValue];
}















@end
