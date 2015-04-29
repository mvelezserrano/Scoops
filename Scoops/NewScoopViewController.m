//
//  MyNewViewController.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 25/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "NewScoopViewController.h"
#import "Scoop.h"

@interface NewScoopViewController () {
    MSClient *client;
    NSString *userFBId;
    NSString *tokenFB;
}

@end

@implementation NewScoopViewController

- (id) init {
    
    if (self = [super init]) {
        self.title = @"New Scoop";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadUserAuthInfo];
    self.scoopTextView.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    // Alta en notificaciones del teclado
    [self setupKeyboardNotifications];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    // Baja en notificaciones
    [self tearDownKeyboardNotifications];
}


- (IBAction)sendScoop:(id)sender {
    
    // Crear el objeto Scoop (con el autor
    
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


- (IBAction)hideKeyboard:(id)sender {
    
    [self.view endEditing:YES];
}

- (void) setupKeyboardNotifications {
    
    // Alta en notificaciones para el teclado
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(notifiyThatKeyboardWillAppear:)
               name:UIKeyboardWillShowNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(notifyThatKeyboardWillDisappear:)
               name:UIKeyboardWillHideNotification
             object:nil];
}


- (void) tearDownKeyboardNotifications {
    
    // Damos de baja las notificaciones
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc removeObserver:self];
}

// UIKeyboardWillShowNotification

- (void) notifiyThatKeyboardWillAppear: (NSNotification *) n {
    
    // Sacar la duración de la animación del teclado
    double duration = [[n.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // Sacar el tamaño (bounds) del teclado del objeto
    // userInfo que viene en la notificación.
    NSValue *wrappedFrame = [n.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect kbdFrame = [wrappedFrame CGRectValue];
    
    // Calcular los nuevos bounds de self.textView
    CGRect currentTextFrame = self.scoopTextView.frame;
    CGRect newRect = CGRectMake(currentTextFrame.origin.x,
                                currentTextFrame.origin.y,
                                currentTextFrame.size.width,
                                currentTextFrame.size.height -
                                kbdFrame.size.height+150);
    
    
    
    // Hacerlo en una animación que coincida con el teclado.
    [UIView animateWithDuration:duration
                     animations:^{
                         self.scoopTextView.frame = newRect;
                     }];
    
}


// UIKeyboardWillHideNotification

- (void) notifyThatKeyboardWillDisappear: (NSNotification *) n {
    
    // Sacar la duración de la animación del teclado
    double duration = [[n.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // Devolver a self.textView su bounds original
    // mediante una animación que coincide con la
    // del teclado.
    [UIView animateWithDuration:duration
                     animations:^{
                         self.scoopTextView.frame = CGRectMake(25, 127, 325, 375);
                     }];
}


#pragma mark - Utils

- (BOOL)loadUserAuthInfo{
    
    userFBId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userID"];
    tokenFB = [[NSUserDefaults standardUserDefaults]objectForKey:@"tokenFB"];
    
    if (userFBId) {
        client.currentUser = [[MSUser alloc]initWithUserId:userFBId];
        client.currentUser.mobileServiceAuthenticationToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"tokenFB"];
        
        return TRUE;
    }
    
    return FALSE;
}














@end
