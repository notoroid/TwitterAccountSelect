//
//  MasterViewController.m
//  SutabaSongs
//
//  Created by Noto Kaname on 12/06/03.
//  Copyright (c) 2012 Irimasu Densan Planning. All rights reserved.
//

#import "ViewController.h"

@interface SettingSegue : UIStoryboardSegue
- (void) perform;
@end

@implementation SettingSegue

- (void) perform
{
    UINavigationController* navControlelr = (UINavigationController*)self.destinationViewController;
    SettingViewController* settingViewController = (SettingViewController*)navControlelr.topViewController;
    
    settingViewController.settingDelegate = self.sourceViewController;
    settingViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self.sourceViewController presentModalViewController:self.destinationViewController animated:YES];
}

@end

@interface ViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation ViewController

@synthesize tableView=_tableView;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{

}

- (void) settingViewControllerDidDone:(SettingViewController*)settingViewController
{
    [self dismissModalViewControllerAnimated:YES];
    
}

@end
