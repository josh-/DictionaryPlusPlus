//
//  Recent.h
//  Dictionary++
//
//  Created by Josh Parnham on 2/04/13.
//  Copyright (c) 2013 Josh Parnham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Recent : NSManagedObject

@property (nonatomic, strong) NSString * word;
@property (nonatomic, strong) NSDate * dateLastViewed;

@end
