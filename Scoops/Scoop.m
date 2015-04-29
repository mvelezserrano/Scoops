//
//  Scoop.m
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 17/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import "Scoop.h"


@interface Scoop ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *author;
@property (nonatomic) CLLocationCoordinate2D coors;
@property (nonatomic, strong) NSData *image;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic) BOOL published;


@end


@implementation Scoop


-(id)initWithTitle:(NSString *)title andPhoto:(NSData *)img aText:(NSString *)text anAuthor:(NSString *)author aCoor:(CLLocationCoordinate2D)coors{
    
    if (self = [super init]) {
        _title = title;
        _text = text;
        _author = author;
        _coors = coors;
        _image = img;
        _dateCreated = [NSDate date];
        _published = NO;
    }
    
    return self;
    
}

-(id)initWithTitle:(NSString *)title andPhoto:(NSData *)img aText:(NSString *)text anAuthor:(NSString *)author aCoor:(CLLocationCoordinate2D)coors status: (int) aStatus {
    
    if (self = [super init]) {
        _title = title;
        _text = text;
        _author = author;
        _coors = coors;
        _image = img;
        _dateCreated = [NSDate date];
        _status = aStatus;
    }
    
    return self;
    
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
