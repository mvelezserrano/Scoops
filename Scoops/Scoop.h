//
//  Scoop.h
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 17/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import CoreLocation;

@interface Scoop : NSObject

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *authorId;
@property (nonatomic) CLLocationCoordinate2D coors;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic) int status;
@property (nonatomic) int rating;
@property (nonatomic) BOOL downloaded;

- (id)initWithTitle:(NSString*)title
              image:(UIImage *)img
               text:(NSString*)aText
           authorId:(NSString *)anAuthorId
         authorName:(NSString *)anAuthorName
              coors:(CLLocationCoordinate2D) coors;

- (id)initWithTitle:(NSString*)title
              image:(UIImage *)img
               text:(NSString*)aText
           authorId:(NSString *)anAuthorId
         authorName:(NSString *)anAuthorName
              coors:(CLLocationCoordinate2D) coors
             status: (int) aStatus;

-(NSDictionary *) asDictionary;
-(NSDictionary *) asDictionaryNoId;

@end
