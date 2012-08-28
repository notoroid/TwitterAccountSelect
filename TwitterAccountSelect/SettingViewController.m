//
//  SettingViewController.m
//  SutabaSongs
//
//  Created by Noto Kaname on 12/06/03.
//  Copyright (c) 2012 Irimasu Densan Planning. All rights reserved.
//

#import "SettingViewController.h"
#import "SelectAccountViewController.h"
#import "AppDelegate.h"
#import "TwitterProfileImageCache.h"

static NSInteger s_tagID = 0;

@interface SettingViewController ()

- (void) configureCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath;

@property (nonatomic,strong) NSString* twitterIdentifier;

@end

@implementation SettingViewController
@synthesize twitterIdentifier=_twitterIdentifier;
@synthesize settingDelegate=_settingDelegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate* appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    if( self.twitterIdentifier != nil ){
        if( appDelegate.twitterIdentifier == nil || [appDelegate.twitterIdentifier compare:self.twitterIdentifier] != NSOrderedSame ){
            appDelegate.twitterIdentifier = self.twitterIdentifier;
            [appDelegate updateRepositoryWithUpdate:NO];
            
#define SECTION_TWITTER_ACCOUNT 0
            NSArray* visibleCells = [self.tableView visibleCells];
            for( UITableViewCell* cell in visibleCells ){
                NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
                if( indexPath.section == SECTION_TWITTER_ACCOUNT && indexPath.row == 0 ){
                    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    [self configureCell:cell withIndexPath:indexPath];
                }
            }
       }
    }else{
        self.twitterIdentifier = appDelegate.twitterIdentifier;
    }
        
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
    case SECTION_TWITTER_ACCOUNT:
        rows = 1;
        break;
    default:
        break;
    }
    
    return rows;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title = @"アカウント";
    
    return title;
}

- (void) configureCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
        case SECTION_TWITTER_ACCOUNT:
        {
            AppDelegate* appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
            if( appDelegate.twitterIdentifier != nil ){
                ACAccountStore* accountStore = appDelegate.accountStore;
                
                ACAccount* account = [accountStore accountWithIdentifier:appDelegate.twitterIdentifier];
                if( account != nil ){
                    cell.textLabel.text = account.username;
                    
                    s_tagID++;
                    NSInteger currentID = cell.tag = s_tagID;
                    cell.imageView.image = [UIImage imageNamed:@"profileImageDummy.png"];
                    [TwitterProfileImageCache loadProfileImageWithAccount:account block:^(UIImage *image) {
                        if( self.navigationController.topViewController == self && cell.tag == currentID ){
                            cell.imageView.image = image;
                            [cell layoutSubviews]; 
                        }
                    }];
                }else{
                    cell.textLabel.text = @"無効アカウントです。";
                }
            }else{
                cell.textLabel.text = @"なし";
            }
        }
            break;
        default:
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell withIndexPath:indexPath];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectAccountViewController* selectAccountViewController = (SelectAccountViewController*)([self.storyboard instantiateViewControllerWithIdentifier:@"SelectAccount"]);
    selectAccountViewController.target = self;
    selectAccountViewController.propertyName = @"twitterIdentifier";
    
    [self.navigationController pushViewController:selectAccountViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(IBAction) firedDone:(id)sender
{
    [_settingDelegate settingViewControllerDidDone:self];    
}

@end
