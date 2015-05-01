//
//  AzureSession.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 30/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import "AzureSession.h"
#import "sharedkeys.h"

@interface AzureSession ()

@end

@implementation AzureSession

+(instancetype) sharedAzureSession {
    
    static dispatch_once_t onceToken;
    static AzureSession *shared;
    dispatch_once(&onceToken, ^{
        shared = [[AzureSession alloc] init];
    });
    
    return shared;
}

- (id) init {
    if (self = [super init]) {
        _client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                     applicationKey:AZUREMOBILESERVICE_APPKEY];
        
        NSLog(@"%@", _client.debugDescription);
    }
    
    return self;
}

- (void)loginFBInViewController: (UIViewController *) vC {
    
    [self loginAppInViewController:vC withCompletion:^(NSArray *results) {
        
        NSLog(@"Resultados ---> %@", results);
    }];
}

#pragma mark - Login

- (void)loginAppInViewController:(UIViewController *)controller withCompletion:(completeBlock)bloque{
    
    [self loadUserAuthInfo];
    
    if (self.client.currentUser){
        [self.client invokeAPI:@"getCurrentUserInfo" body:nil HTTPMethod:@"GET" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
            
            //tenemos info extra del usuario
            NSLog(@"%@", result);
            //self.profilePicture = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
            
        }];
        
        return;
    }
    
    [self.client loginWithProvider:@"facebook"
                   controller:controller
                     animated:YES
                   completion:^(MSUser *user, NSError *error) {
                       
                       if (error) {
                           NSLog(@"Error en el login : %@", error);
                           bloque(nil);
                       } else {
                           NSLog(@"user -> %@", user);
                           
                           [self saveAuthInfo];
                           [self.client invokeAPI:@"getCurrentUserInfo" body:nil HTTPMethod:@"GET" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
                               
                               //tenemos info extra del usuario
                               NSLog(@"%@", result);
                               //self.profilePicture = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
                               
                           }];
                           
                           bloque(@[user]);
                       }
                   }];
    
}


#pragma mark - Utils

- (BOOL)loadUserAuthInfo{
    
    self.userFBId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userID"];
    self.tokenFB = [[NSUserDefaults standardUserDefaults]objectForKey:@"tokenFB"];
    
    if (self.userFBId) {
        self.client.currentUser = [[MSUser alloc]initWithUserId:self.userFBId];
        self.client.currentUser.mobileServiceAuthenticationToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"tokenFB"];
        
        return TRUE;
    }
    
    return FALSE;
}


- (void) saveAuthInfo{
    
    [[NSUserDefaults standardUserDefaults]setObject:self.client.currentUser.userId forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults]setObject:self.client.currentUser.mobileServiceAuthenticationToken
                                             forKey:@"tokenFB"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
