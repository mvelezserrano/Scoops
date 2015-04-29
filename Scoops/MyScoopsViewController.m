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
#import "Scoop.h"

@interface MyScoopsViewController () {
    MSClient *client;
    NSString *userFBId;
    NSString *tokenFB;
}

@property (strong, nonatomic) NSMutableArray *scoopsPublished;
@property (strong, nonatomic) NSMutableArray *scoopsNotPublished;
@property (nonatomic) BOOL showPublished;
@property (weak, nonatomic) IBOutlet UIImageView *picProfile;
@property (strong, nonatomic) NSURL *profilePicture;

@end

@implementation MyScoopsViewController

- (id) initWithScoops: (NSArray *) arrayOfScoops {
    
    if (self = [super initWithNibName:nil bundle:nil]) {
        _arrayOfMyScoops = [[NSArray alloc] initWithArray:arrayOfScoops];
        _scoopsPublished = [[NSMutableArray alloc] init];
        _scoopsNotPublished = [[NSMutableArray alloc] init];
        for (Scoop *scoop in arrayOfScoops) {
            if (scoop.status == PUBLISHED) {
                [_scoopsPublished addObject:scoop];
            } else {
                [_scoopsNotPublished addObject:scoop];
            }
        }
        _showPublished = YES;
        self.title = @"My Scoops";
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"My Scoops";
    
    // llamamos a los metodos de Azure para crear y configurar la conexion
    [self warmupMSClient];
    [self loginFB];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentedControlAction:(id)sender {
    
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        // Noticias publicadas
        NSLog(@"Noticias publicadas!!!");
        self.showPublished = YES;
    } else {
        // Noticias No publicadas
        NSLog(@"Noticias NO publicadas!!!");
        self.showPublished = NO;
    }
    
    [self.scoopsTableView reloadData];
}


#pragma mark - Azure & Facebook

-(void)warmupMSClient{
    client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                 applicationKey:AZUREMOBILESERVICE_APPKEY];
    
    NSLog(@"%@", client.debugDescription);
}

- (void)loginFB {
    
    [self loginAppInViewController:self withCompletion:^(NSArray *results) {
        NSLog(@"Resultados ---> %@", results);
    }];
}

- (void)loginAppInViewController:(UIViewController *)controller withCompletion:(completeBlock)bloque{
    
    [self loadUserAuthInfo];
    
    if (client.currentUser){
        [client invokeAPI:@"getuserinfofromauthprovider" body:nil HTTPMethod:@"GET" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
            
            //tenemos info extra del usuario
            NSLog(@"%@", result);
            self.profilePicture = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
            
        }];
        
        return;
    }
    
    [client loginWithProvider:@"facebook"
                   controller:controller
                     animated:YES
                   completion:^(MSUser *user, NSError *error) {
                       
                       if (error) {
                           NSLog(@"Error en el login : %@", error);
                           bloque(nil);
                       } else {
                           NSLog(@"user -> %@", user);
                           
                           [self saveAuthInfo];
                           [client invokeAPI:@"getuserinfofromauthprovider" body:nil HTTPMethod:@"GET" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
                               
                               //tenemos info extra del usuario
                               NSLog(@"%@", result);
                               self.profilePicture = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
                               
                           }];
                           
                           bloque(@[user]);
                       }
                   }];
    
}

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


- (void) saveAuthInfo{
    [[NSUserDefaults standardUserDefaults]setObject:client.currentUser.userId forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults]setObject:client.currentUser.mobileServiceAuthenticationToken
                                             forKey:@"tokenFB"];
    [[NSUserDefaults standardUserDefaults]synchronize];
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
    cell.detailTextLabel.text = scoop.author;
    
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
    
    MyScoopViewController *sVC = [[MyScoopViewController alloc] initWithScoop:scoop];
    [self.navigationController pushViewController:sVC animated:YES];
}

















@end
