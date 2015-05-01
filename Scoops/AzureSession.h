//
//  AzureSession.h
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 30/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

typedef void (^profileCompletion)(NSDictionary* profInfo);
typedef void (^completeBlock)(NSArray* results);
typedef void (^completeOnError)(NSError *error);
typedef void (^completionWithURL)(NSURL *theUrl, NSError *error);

@interface AzureSession : NSObject

@property (strong, nonatomic) MSClient *client;
@property (copy, nonatomic) NSString * userFBId;
@property (copy, nonatomic) NSString *tokenFB;

+(instancetype) sharedAzureSession;

- (void) loginFBInViewController: (UIViewController *) vC;
- (BOOL) loadUserAuthInfo;
- (void) saveAuthInfo;

@end
