//
//  MyNewViewController.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 25/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import "NewScoopViewController.h"
#import "Scoop.h"

@interface NewScoopViewController ()

@end

@implementation NewScoopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.scoopTextView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendScoop:(id)sender {
    
    NSLog(@"Enviar la noticia");
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"Entramos a editar el texto");
    
    if ([self.scoopTextView.text isEqualToString:@"Introduce el texto de la noticia aquí"]) {
        self.scoopTextView.text = @"";
        self.scoopTextView.textColor = [UIColor blackColor]; //optional
    }
    [self.scoopTextView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"Acabamos de editar el texto");
    
    if ([self.scoopTextView.text isEqualToString:@""]) {
        self.scoopTextView.text = @"Introduce el texto de la noticia aquí";
        self.scoopTextView.textColor = [UIColor lightGrayColor]; //optional
    }
    [self.scoopTextView resignFirstResponder];
}


















@end
