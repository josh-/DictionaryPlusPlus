//
//  JPMainViewController.m
//  Dictionary++
//
//  Created by Josh Parnham on 1/04/13.
//  Copyright (c) 2013 Josh Parnham. All rights reserved.
//

#import "JPMainViewController.h"
#import "JPReferenceLibraryViewController.h"
#import "JPUserListViewController.h"

@interface JPMainViewController ()

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) UITextChecker *textChecker;
@property (strong, nonatomic) NSMutableArray *words;
@property (strong, nonatomic) NSMutableArray *ignoredWords;

@end

@implementation JPMainViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.searchBar.delegate = self;
        self.navigationItem.titleView = self.searchBar;
        
        UIBarButtonItem *recentsBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(recentButtonTapped:)];
        self.navigationItem.rightBarButtonItem = recentsBarButtonItem;
        
        self.textChecker = [[UITextChecker alloc] init];
        self.words = [[NSMutableArray alloc] init];
        self.ignoredWords = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.searchBar becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.searchBar isFirstResponder]) {
        [self.searchBar becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self.ignoredWords removeAllObjects];
}

#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self updateWords];
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:searchBar.text]) {
        [searchBar resignFirstResponder];
        
        JPReferenceLibraryViewController *referenceLibraryViewController = [[JPReferenceLibraryViewController alloc] initWithTerm:searchBar.text];
        [self.navigationController pushViewController:referenceLibraryViewController animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.words count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.words objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    NSString *word = [self.words objectAtIndex:indexPath.row];
    JPReferenceLibraryViewController *referenceLibraryViewController = [[JPReferenceLibraryViewController alloc] initWithTerm:word];
    [self.navigationController pushViewController:referenceLibraryViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Text checker

- (void)updateWords
{    
    [self.words removeAllObjects];
    
    NSString *word = self.searchBar.text;
    NSRange range = NSMakeRange(0, word.length);
    
    NSArray *guesses = [self.textChecker guessesForWordRange:range inString:word language:@"en_US"];
    
    for (int i = 0; i < [guesses count]; i++) {
        if ([self.ignoredWords count] > 0) {
            if (![self.ignoredWords containsObject:guesses[i]]) {
                [self.words addObject:guesses[i]];
            }
        }
        else {
            [self.words addObject:guesses[i]];
        }
    }
    
    NSArray *completions = [self.textChecker completionsForPartialWordRange:range inString:word language:@"en_US"];
    
    for (int i = 0; i < [completions count]; i++) {
        if ([self.ignoredWords count] > 0) {
            if (![self.ignoredWords containsObject:completions[i]]) {
                [self.words addObject:completions[i]];
            }
        }
        else {
            [self.words addObject:completions[i]];
        }
    }
    
    dispatch_async( dispatch_get_global_queue(0, 0), ^{
        [self trimWords];
    });
}

- (void)trimWords
{        
    /*
     UIReferenceLibraryViewController's +dictionaryHasDefinitionForTerm: method can be quite time-consuming (taking up to 0.3 seconds in my testing) and thus should only be done in a background thread when being called on multiple NSStrings
     */
    
    NSMutableArray *trimmedArray = [[NSMutableArray alloc] initWithArray:self.words];
    for (int i = 0; i<[trimmedArray count]; i++) {
        if (![UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:[trimmedArray objectAtIndex:i]]) {
            [self.ignoredWords addObject:[trimmedArray objectAtIndex:i]];
        }
    }
}

#pragma mark - Methods

- (void)recentButtonTapped:(id)sender
{
    JPUserListViewController *userListViewController = [[JPUserListViewController alloc] init];
    UINavigationController *userListNavigationController = [[UINavigationController alloc] initWithRootViewController:userListViewController];
    [self presentViewController:userListNavigationController animated:YES completion:nil];
}

@end
