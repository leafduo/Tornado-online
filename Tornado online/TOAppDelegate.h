//
//  TOAppDelegate.h
//  Tornado online
//
//  Created by leafduo on 7/26/12.
//  Copyright (c) 2012 leafduo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TOAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
