//
//  MyNewViewController.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 25/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import "MyScoopViewController.h"
#import "Scoop.h"

@interface MyScoopViewController ()

@end

@implementation MyScoopViewController

-(id) initWithScoop:(Scoop *)scoop {
    
    if (self = [super initWithNibName:nil bundle:nil]) {
        
        _model = scoop;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
    
    NSLog(@"Publicar noticia");
}
@end
