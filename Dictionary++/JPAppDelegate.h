//
//  JPAppDelegate.h
//  Dictionary++
//
//  Created by Josh Parnham on 1/04/13.
//  Copyright (c) 2013 Josh Parnham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
