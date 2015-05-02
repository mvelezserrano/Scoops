//
//  Scoop.m
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 17/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import "Scoop.h"
#import "Settings.h"


@interface Scoop ()

@end


@implementation Scoop


- (id)initWithTitle:(NSString*)title
              photo:(NSData *)img
               text:(NSString*)aText
           authorId:(NSString *)anAuthorId
         authorName:(NSString *)anAuthorName
              coors:(CLLocationCoordinate2D) coors {
    
    if (self = [super init]) {
        _title = title;
        _image = img;
        _text = aText;
        _authorId = anAuthorId;
        _authorName = anAuthorName;
        _coors = coors;
        
        _creationDate = [NSDate date];
        _status = NOT_PUBLISHED;
    }
    
    return self;
    
}

- (id)initWithTitle:(NSString*)title
              photo:(NSData *)img
               text:(NSString*)aText
           authorId:(NSString *)anAuthorId
         authorName:(NSString *)anAuthorName
              coors:(CLLocationCoordinate2D) coors
             status: (int) aStatus {
    
    if (self = [super init]) {
        _title = title;
        _image = img;
        _text = aText;
        _authorId = anAuthorId;
        _authorName = anAuthorName;
        _coors = coors;
        
        _creationDate = [NSDate date];
        _status = aStatus;
    }
    
    return self;
    
}

-(NSDictionary *) asDictionary {
    
    return @{@"id"         : self.id,
             @"title"      : self.title,
             @"text"       : self.text,
             @"authorId"     : self.authorId,
             @"authorName" : self.authorName,
             @"coors"      : @"",
             //@"image"      : self.image,
             @"creationDate"    : self.creationDate,
             @"status"     : [NSNumber numberWithInt:self.status]};
}

-(NSDictionary *) asDictionaryNoId {
    
    return @{@"title"      : self.title,
             @"text"       : self.text,
             @"authorId"     : self.authorId,
             @"authorName" : self.authorName,
             @"coors"      : @"",
             //@"image"      : self.image,
             @"creationDate"    : self.creationDate,
             @"status"     : [NSNumber numberWithInt:self.status]};
}



#pragma mark - Overwritten

-(NSString*) description{
    return [NSString stringWithFormat:@"<%@ %@>", [self class], self.title];
}


- (BOOL)isEqual:(id)object{
    
    
    return [self.title isEqualToString:[object title]];
}

- (NSUInteger)hash{
    return [_title hash] ^ [_text hash];
}








@end
