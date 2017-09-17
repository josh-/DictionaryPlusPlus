//
//  JPUserListViewController.m
//  Dictionary++
//
//  Created by Josh Parnham on 1/04/13.
//  Copyright (c) 2013 Josh Parnham. All rights reserved.
//

#import "JPUserListViewController.h"
#import "JPReferenceLibraryViewController.h"
#import "JPAppDelegate.h"
#import "Recent.h"
#import "Favorite.h"

@interface JPUserListViewController ()

@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) NSMutableArray *wordsArray;

@end

@implementation JPUserListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Recent", @"Favorites"]];
        self.segmentedControl.frame = CGRectMake(0, 0, 200, 30);
        [self.segmentedControl addTarget:self action:@selector(segmentedControlIndexChanged:) forControlEvents:UIControlEventValueChanged];
        [self.segmentedControl setSelectedSegmentIndex:0];
        self.navigationItem.titleView = self.segmentedControl;
        
        self.wordsArray =  [[NSMutableArray alloc] init];
        
        UIBarButtonItem *doneBarButttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneTapped:)];
        self.navigationItem.rightBarButtonItem = doneBarButttonItem;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateWordsArray];
}

#pragma mark - Methods

- (void)updateWordsArray
{
    [self.wordsArray removeAllObjects];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *managedObjectContext = [(JPAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    NSSortDescriptor *sortDescriptor;
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            request.entity = [NSEntityDescription entityForName:@"Recent" inManagedObjectContext:managedObjectContext];
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateLastAccessed" ascending:YES selector:@selector(compare:)];
            [self.wordsArray addObjectsFromArray:[managedObjectContext executeFetchRequest:request error:nil]];
            break;
        case 1:
            request.entity = [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:managedObjectContext];
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateFavorited" ascending:YES selector:@selector(compare:)];
            [self.wordsArray addObjectsFromArray:[managedObjectContext executeFetchRequest:request error:nil]];
            break;
            
        default:
            break;
    }
}

- (void)doneTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)segmentedControlIndexChanged:(id)sender
{
    [self updateWordsArray];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.wordsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[self.wordsArray objectAtIndex:indexPath.row] word];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *word = [(Recent *)[self.wordsArray objectAtIndex:indexPath.row] word];
    JPReferenceLibraryViewController *referenceLibraryViewController = [[JPReferenceLibraryViewController alloc] initWithTerm:word];
    [self.navigationController pushViewController:referenceLibraryViewController animated:YES];
}

@end
