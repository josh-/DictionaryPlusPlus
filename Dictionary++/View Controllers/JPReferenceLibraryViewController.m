//
//  JPReferenceLibraryViewController.m
//  Dictionary++
//
//  Created by Josh Parnham on 1/04/13.
//  Copyright (c) 2013 Josh Parnham. All rights reserved.
//

#import "JPReferenceLibraryViewController.h"
#import "JPAppDelegate.h"
#import "Recent.h"
#import "Favorite.h"

@interface JPReferenceLibraryViewController ()

@property (copy) NSString *term;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation JPReferenceLibraryViewController

- (id)initWithTerm:(NSString *)term
{
    self = [super initWithTerm:term];
    if (self) {
        self.term = term;
        
        self.managedObjectContext = [(JPAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
        
        [self addRecentItem];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpBarButtonItems];
    
//    [self.view.subviews[0] setFrame:CGRectZero]; // This remove the UIReferenceLibraryViewController header
}

#pragma mark - Methods

- (void)addRecentItem
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Recent" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"word == %@", self.term];
    request.predicate = predicate;
    NSArray *wordArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    if ([wordArray count] == 0) { // Word itsn't already in the Recent lsit
        Recent *recent = [[Recent alloc] initWithEntity:[NSEntityDescription entityForName:@"Recent" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        recent.word = self.term;
        recent.dateLastViewed = [NSDate date];
        [self.managedObjectContext save:nil];
        
        return;
    }
    else { // Word is already in the Recent list
        for (Recent *recent in wordArray) {
            recent.dateLastViewed = [NSDate date];
            [self.managedObjectContext save:nil];
        }
    }
}

- (void)setUpBarButtonItems
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"word == %@", self.term];
    request.predicate = predicate;
    NSArray *wordArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    NSString *buttonText;
    SEL buttonSelector;
    
    if ([wordArray count] == 0) { // Word hasn't been favorited
        buttonText = @"Favorite";
        buttonSelector = @selector(favoriteWord:);
    }
    else { // Word has already been favorited
        buttonText = @"Unfavorite";
        buttonSelector = @selector(unfavoriteWord:);
    }
    
    UIBarButtonItem *favoriteBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:buttonText style:UIBarButtonItemStylePlain target:self action:buttonSelector];
    favoriteBarButtonItem.possibleTitles = [NSSet setWithObjects:@"Favorite", @"Unfavorite", nil];
    self.navigationItem.rightBarButtonItem = favoriteBarButtonItem;
}

- (void)favoriteWord:(id)sender
{
    Favorite *favorite = [[Favorite alloc] initWithEntity:[NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    favorite.word = self.term;
    favorite.dateFavorited = [NSDate date];
    [self.managedObjectContext save:nil];
    
    [self setUpBarButtonItems];
}

- (void)unfavoriteWord:(id)sender
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"word == %@", self.term];
    request.predicate = predicate;
    NSArray *wordArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    for (Favorite *favorite in wordArray) {
        [self.managedObjectContext deleteObject:favorite];
    }
    [self.managedObjectContext save:nil];
    
    [self setUpBarButtonItems];
}

@end
