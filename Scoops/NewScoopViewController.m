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
#import "Settings.h"

@interface NewScoopViewController () {
    MSClient *client;
}

@property (nonatomic, copy) NSString *authorName;

@end

@implementation NewScoopViewController

- (id) initWithMSClient: (MSClient *) aClient authorName: (NSString *) anAuthorName {
    
    if (self = [super init]) {
        client = aClient;
        _authorName = anAuthorName;
        self.title = @"New Scoop";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.scoopTextView.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    // Alta en notificaciones del teclado
    [self addPhotoButton];
    [self setupKeyboardNotifications];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    // Baja en notificaciones
    [self tearDownKeyboardNotifications];
}


- (IBAction)sendScoop:(id)sender {
    
    // Crear el objeto Scoop (con el autor
    MSTable *news = [client tableWithName:@"news"];
    
    Scoop *scoop = [[Scoop alloc] initWithTitle:self.scoopTitleView.text
                                          image:self.scoopPhotoView.image
                                           text:self.scoopTextView.text
                                       authorId:client.currentUser.userId
                                     authorName:self.authorName
                                          coors:CLLocationCoordinate2DMake(0, 0)
                                         status:NOT_PUBLISHED];
    
    NSDictionary *scoopDict = [scoop asDictionaryNoId];
    
    [news insert:scoopDict
      completion:^(NSDictionary *item, NSError *error) {
          
          if (error) {
              NSLog(@"Error %@", error);
          } else {
              //NSLog(@"INSERCIÓN DE NOTICIA EN AZURE OK!!!");
              scoop.id = item[@"id"];
              [self.navigationController popViewControllerAnimated:YES];
          }
          
      }];
}


- (void) addPhotoButton {
    
    // Add the new Scoop button
    UIBarButtonItem *photoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                  target:self
                                                                                  action:@selector(takePicture)];
    self.navigationItem.rightBarButtonItem = photoButton;
}


- (void) takePicture {
    
    // Creamos un UIImagePickerController
    UIImagePickerController *picker = [UIImagePickerController new];
    
    // Lo configuro
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        // Uso la cámara
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        
        // Tiro del carrete
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    picker.delegate = self;
    
    // Cambiamos la animación de entrada del picker
    picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:picker
                       animated:YES
                     completion:^{
                         // Esto se va a ejecutar cuando termine la animación que
                         // muestra al picker.
                     }];
}


#pragma mark - UIImagePickerControllerDelegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // ¡OJO! Pico de memoria asegurado, especialmente en
    // dispositivos antiguos: 4s, 5.
    
    // Sacamos la UIImage del diccionario
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // La guardo en el modelo
    self.scoopPhotoView.image = img;
    // Sincronizo modelo --> vista
    //self.photoView.image = self.model.image;
    
    // Hay que quitar el controlador al que estamos presentando, una vez el usuario
    // ha terminado.
    
    if (self.imagePickerPopover) {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
        NSLog(@"Dismiss del popover");
    } else {
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     // Se ejecutará cuando se haya ocultado del todo
                                     
                                 }];
    }
    
}


#pragma mark - UIPopoverControllerDelegate
-(void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.imagePickerPopover = nil;
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
                                kbdFrame.size.height+100);
    
    
    
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
                         self.scoopTextView.frame = CGRectMake(25, 304, 325, 257);
                     }];
}
















@end
