//
//  MyScoopsTableViewController.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 26/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "MyScoopsTableViewController.h"
#import "sharedkeys.h"

@interface MyScoopsTableViewController () {

    MSClient *client;
    NSString *userFBId;
    NSString *tokenFB;
}

@property (weak, nonatomic) IBOutlet UIImageView *picProfile;
@property (strong, nonatomic) NSURL *profilePicture;

@end

@implementation MyScoopsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // llamamos a los metodos de Azure para crear y configurar la conexion
    [self warmupMSClient];
    [self loginFB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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

#pragma mark - Login

- (void)loginAppInViewController:(UIViewController *)controller withCompletion:(completeBlock)bloque{
    
    [self loadUserAuthInfo];
    
    if (client.currentUser){
        [client invokeAPI:@"getCurrentUserInfo" body:nil HTTPMethod:@"GET" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
            
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
                           [client invokeAPI:@"getCurrentUserInfo" body:nil HTTPMethod:@"GET" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
                               
                               //tenemos info extra del usuario
                               NSLog(@"%@", result);
                               self.profilePicture = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
                               
                           }];
                           
                           bloque(@[user]);
                       }
                   }];
    
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/


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


- (void) saveAuthInfo{
    
    [[NSUserDefaults standardUserDefaults]setObject:client.currentUser.userId forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults]setObject:client.currentUser.mobileServiceAuthenticationToken
                                             forKey:@"tokenFB"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}



@end
