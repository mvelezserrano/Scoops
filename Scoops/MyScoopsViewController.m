//
//  MyScoopsViewController.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 26/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "Settings.h"
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


- (void) getHeadlines {
    
    self.scoopsPublished = [[NSMutableArray alloc] init];
    [self.scoopsPublished removeAllObjects];
    self.scoopsNotPublished = [[NSMutableArray alloc] init];
    [self.scoopsNotPublished removeAllObjects];
    
    MSClient *client = [azureSession client];
    
    NSDictionary *parameters = @{@"authorId" : client.currentUser.userId};
    
    [client invokeAPI:@"getheadlinesforauthor"
                 body:nil
           HTTPMethod:@"GET"
           parameters:parameters
              headers:nil
           completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
               if (!error) {
                   for (id item in result) {
                       Scoop *scoop = [[Scoop alloc] init];
                       scoop.id = item[@"id"];
                       scoop.title = item[@"title"];
                       scoop.authorName = item[@"authorName"];
                       scoop.downloaded = NO;
                       scoop.imageURL = item[@"imageurl"];
                       scoop.status = [item[@"status"] integerValue];
                       if (scoop.status == PUBLISHED) {
                           [self.scoopsPublished addObject:scoop];
                       } else {
                           [self.scoopsNotPublished addObject:scoop];
                       }
                   }
               } else {
                   NSLog(@"Error: %@", error);
               }
               
               [self.scoopsTableView reloadData];
               [self.activityView stopAnimating];
           }];
    
}

-(void)setAuthorName:(NSString *)authorName {
    
    _authorName = authorName;
    [self addNavigationBarButtons];
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
    
    if (scoop.imageDownloaded) {
        cell.imageView.image = scoop.image;
    } else {
        
        MSClient *client = [azureSession client];
        NSDictionary *parameters = @{@"containerName" : @"scoops",
                                     @"blobName" : [scoop.imageURL lastPathComponent]};
        
        [client invokeAPI:@"getsasurlforblob" body:nil HTTPMethod:@"GET" parameters:parameters headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
            
            if (!error) {
                
                NSURL *imageSasURL = [NSURL URLWithString:[result objectForKey:@"sasUrl"]];
                [self handleSaSURLToDownload:imageSasURL
                         completionHandleSaS:^(id result, NSError *error) {
                             scoop.image = result;
                             scoop.imageDownloaded = YES;
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 cell.imageView.image = result;
                                 [cell setNeedsLayout];
                             });
                         }];
            } else {
                NSLog(@"Error: %@", error);
            }
        }];
    }
    
    cell.textLabel.text = scoop.title;
    cell.detailTextLabel.text = scoop.authorName;
    
    // Devolver
    return cell;
}

- (void)handleSaSURLToDownload:(NSURL *)theUrl completionHandleSaS:(void (^)(id result, NSError *error))completion{
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:theUrl];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDownloadTask * downloadTask = [[NSURLSession sharedSession]downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
            completion(image, error);
        }
    }];
    [downloadTask resume];
}


#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Averiguar el scoop
    Scoop *scoop = nil;
    if (self.showPublished) {
        scoop = [self.scoopsPublished objectAtIndex:indexPath.row];
    } else {
        scoop = [self.scoopsNotPublished objectAtIndex:indexPath.row];
    }
    
    MyScoopViewController *sVC = [[MyScoopViewController alloc] initWithScoop:scoop];
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

- (void) addNavigationBarButtons {
    
    // Add the reload Scoops button
    UIBarButtonItem *reloadScoops = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                  target:self
                                                                                  action:@selector(getHeadlines)];
    self.navigationItem.leftBarButtonItem = reloadScoops;
    
    // Add the new Scoop button
    UIBarButtonItem *newScoop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                              target:self
                                                                              action:@selector(createNewScoop:)];
    self.navigationItem.rightBarButtonItem = newScoop;
}
















@end
