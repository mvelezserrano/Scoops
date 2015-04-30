//
//  Scoop.h
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 17/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface Scoop : NSObject

- (id)initWithTitle:(NSString*)title
              photo:(NSData *)img
               text:(NSString*)aText
           authorId:(NSString *)anAuthorId
         authorName:(NSString *)anAuthorName
              coors:(CLLocationCoordinate2D) coors;

- (id)initWithTitle:(NSString*)title
              photo:(NSData *)img
               text:(NSString*)aText
           authorId:(NSString *)anAuthorId
         authorName:(NSString *)anAuthorName
              coors:(CLLocationCoordinate2D) coors
             status: (int) aStatus;

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *authorId;
@property (nonatomic) CLLocationCoordinate2D coors;
@property (nonatomic, strong) NSData *image;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic) int status;

-(NSDictionary *) asDictionary;
-(NSDictionary *) asDictionaryNoId;

@end
