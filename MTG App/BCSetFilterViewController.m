//
//  BCSetFilterViewController.m
//  MTG App
//
//  Created by Brian Corbin on 6/7/13.
//  Copyright (c) 2013 Brian Corbin. All rights reserved.
//

#import "BCSetFilterViewController.h"
#import "BCSet.h"
#import "BCLoadData.h"
@interface BCSetFilterViewController ()

@end

@implementation BCSetFilterViewController
@synthesize setList, blockList, checkedIndexPaths, checkedSetNames;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Set Filter";
    
    BCLoadData *loadData = [[BCLoadData alloc]init];
    setList = [loadData loadSetData];
    blockList = [loadData loadBlockData];
    if (checkedIndexPaths == NULL) checkedIndexPaths = [[NSMutableArray alloc]init];
    if (checkedSetNames == NULL) checkedSetNames = [[NSMutableArray alloc]init];
    
    //Create right bar button to reset filter to contain no objects
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"Reset" style:UIBarButtonItemStyleBordered target:self action:@selector(actionResetFilter:)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [blockList count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [blockList objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"setBlock like[c] %@",sectionTitle];
    NSArray *setsInBlock = [[NSMutableArray alloc]init];
    setsInBlock = [setList filteredArrayUsingPredicate:predicate];
    return setsInBlock.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SetNameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SetNameCell"];
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"setBlock like[c] %@",sectionTitle];
    NSArray *setsInBlock = [[NSMutableArray alloc]init];
    setsInBlock = [setList filteredArrayUsingPredicate:predicate];
    
    BCSet *tempSet = [setsInBlock objectAtIndex:[indexPath row]];
    UILabel *setNameLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *setCodeLabel = (UILabel *)[cell viewWithTag:3];
    setNameLabel.text = tempSet.setName;
    setCodeLabel.text = tempSet.setCode;
    NSString *strSetName = [tempSet.setName stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    UIImageView *setSymbolImageView = (UIImageView *)[cell viewWithTag:2];
    BOOL fileCommonExists = [[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"/Users/Brian/Documents/iOS Apps/MTG App/MTG App/Set Symbols/Small/%@_Common.gif", strSetName]];
    BOOL fileRareExists = [[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"/Users/Brian/Documents/iOS Apps/MTG App/MTG App/Set Symbols/Small/%@_Rare.gif", strSetName]];
    if([self.checkedIndexPaths containsObject:indexPath])
    {
        if(fileRareExists) setSymbolImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_Rare.gif",strSetName]];
        else setSymbolImageView.image = [UIImage imageNamed:@"Custom_Rare.gif"];
    }
    else
    {
        if(fileCommonExists) setSymbolImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_Common.gif",strSetName]];
        else setSymbolImageView.image = [UIImage imageNamed:@"Custom_Common.gif"];
    }
    return cell;
}

-(void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *setSymbolImageView = (UIImageView *)[selectedCell viewWithTag:2];
    UILabel *setNameLabel = (UILabel *)[selectedCell viewWithTag:1];
    UILabel *setCodeLabel = (UILabel *)[selectedCell viewWithTag:3];
    
    NSString *strSetName = [setNameLabel.text stringByReplacingOccurrencesOfString:@":" withString:@""];
    BOOL fileCommonExists = [[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"/Users/Brian/Documents/iOS Apps/MTG App/MTG App/Set Symbols/Small/%@_Common.gif", strSetName]];
    BOOL fileRareExists = [[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"/Users/Brian/Documents/iOS Apps/MTG App/MTG App/Set Symbols/Small/%@_Rare.gif", strSetName]];
    if(![self.checkedIndexPaths containsObject:indexPath])
    {
        [self.checkedIndexPaths addObject:indexPath];
        [self.checkedSetNames addObject:setCodeLabel.text];
        if(fileRareExists) setSymbolImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_Rare.gif",strSetName]];
        else setSymbolImageView.image = [UIImage imageNamed:@"Custom_Rare.gif"];
    }
    else
    {
        [self.checkedIndexPaths removeObject:indexPath];
        [self.checkedSetNames removeObject:setCodeLabel.text];
        if(fileCommonExists) setSymbolImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_Common.gif",strSetName]];
        else setSymbolImageView.image = [UIImage imageNamed:@"Custom_Common.gif"];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.delegate passSetFilterBack:self didFinishWithFilter:self.checkedSetNames AndIndexPaths:self.checkedIndexPaths];
}

-(IBAction)actionResetFilter:(id)sender
{
    [self.checkedIndexPaths removeAllObjects];
    [self.checkedSetNames removeAllObjects];
    [self.tableView reloadData];
}
@end
