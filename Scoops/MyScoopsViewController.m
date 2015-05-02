//
//  MyScoopsViewController.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 26/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "sharedkeys.h"
#import "MyScoopsViewController.h"
#import "MyScoopViewController.h"
#import "NewScoopViewController.h"
#import "AzureSession.h"
#import "Scoop.h"

@interface MyScoopsViewController () {

    AzureSession *azureSession;
}

@property (strong, nonatomic) NSMutableArray *scoopsPublished;
@property (strong, nonatomic) NSMutableArray *scoopsNotPublished;
@property (nonatomic) BOOL showPublished;
@property (weak, nonatomic) IBOutlet UIImageView *picProfile;
@property (strong, nonatomic) NSURL *profilePicture;
@property (nonatomic, copy) NSString *authorName;

@end

@implementation MyScoopsViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    if (self = [super initWithNibName:nil
                               bundle:nil]) {
        _showPublished = YES;
        self.title = @"My Scoops";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"My Scoops";
    
    azureSession = [AzureSession sharedAzureSession];
    [azureSession loginFBInViewController:self];
}


- (IBAction)segmentedControlAction:(id)sender {
    
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        // Noticias publicadas
        self.showPublished = YES;
    } else {
        // Noticias No publicadas
        self.showPublished = NO;
    }
    
    [self.scoopsTableView reloadData];
}

//AzureSessionDelegate
-(void)setProfilePicture:(NSURL *)profilePicture{
    
    _profilePicture = profilePicture;
    
    dispatch_queue_t queue = dispatch_queue_create("download.profile.photo", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        
        NSData *buff = [NSData dataWithContentsOfURL:profilePicture];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.picProfile.image = [UIImage imageWithData:buff];
            self.picProfile.layer.cornerRadius = self.picProfile.frame.size.width / 2;
            self.picProfile.clipsToBounds = YES;
        });
        
    });
}

- (void)populateModelFromAzure{
    
    self.scoopsPublished = [[NSMutableArray alloc] init];
    self.scoopsNotPublished = [[NSMutableArray alloc] init];
    
    MSClient *client = [azureSession client];
    
    MSTable *table = [client tableWithName:@"news"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"authorId == %@", client.currentUser.userId];
    MSQuery *queryModel = [table queryWithPredicate: predicate];
    [queryModel readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        for (id item in items) {
            NSLog(@"item -> %@", item);
            Scoop *scoop = [[Scoop alloc] initWithTitle:item[@"title"]
                                                  photo:nil
                                                   text:item[@"text"]
                                               authorId:item[@"authorId"]
                                             authorName:item[@"authorName"]
                                                  coors:CLLocationCoordinate2DMake(0, 0)
                                                 status:[item[@"status"] integerValue]];
            //Si está publicada o no añadir a un array u otro.
            if (scoop.status == PUBLISHED) {
                [self.scoopsPublished addObject:scoop];
            } else {
                [self.scoopsNotPublished addObject:scoop];
            }
            scoop.id = item[@"id"];
        }
        [self.scoopsTableView reloadData];
        [self.activityView stopAnimating];
    }];
}


-(void)setAuthorName:(NSString *)authorName {
    
    _authorName = authorName;
    [self addNewScoopButton];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(self.showPublished) {
        // Noticias publicadas
        return [self.scoopsPublished count];
    } else {
        // Noticias No publicadas
        return [self.scoopsNotPublished count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Averiguar el scoop
    Scoop *scoop = nil;
    if (self.showPublished) {
        scoop = [self.scoopsPublished objectAtIndex:indexPath.row];
    } else {
        scoop = [self.scoopsNotPublished objectAtIndex:indexPath.row];
    }
    
    // Crear la celda
    static NSString *cellId = @"cellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        // La tenemos que crear nosotros desde cero
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellId];
    }

    // Configurar
    // Sincronizar modelo (scoop) --> vista (celda)
    cell.imageView.image = [UIImage imageWithData:scoop.image];
    cell.textLabel.text = scoop.title;
    cell.detailTextLabel.text = scoop.authorName;
    
    // Devolver
    return cell;
}


#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"didSelectRow");
    
    // Averiguar el scoop
    Scoop *scoop = nil;
    if (self.showPublished) {
        scoop = [self.scoopsPublished objectAtIndex:indexPath.row];
    } else {
        scoop = [self.scoopsNotPublished objectAtIndex:indexPath.row];
    }
    
    MyScoopViewController *sVC = [[MyScoopViewController alloc] initWithScoop:scoop client:[azureSession client]];
    [self.navigationController pushViewController:sVC animated:YES];
}


- (void) createNewScoop: (id) sender {
    
    // Crear el controlador
    NewScoopViewController *newScoopVC = [[NewScoopViewController alloc] initWithMSClient:[azureSession client]
                                                                               authorName:self.authorName];
    
    // Hacer el push
    [self.navigationController pushViewController:newScoopVC
                                         animated:YES];
}

- (void) addNewScoopButton {
    
    // Add the new Scoop button
    UIBarButtonItem *newScoop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                              target:self
                                                                              action:@selector(createNewScoop:)];
    self.navigationItem.rightBarButtonItem = newScoop;
}
















@end
