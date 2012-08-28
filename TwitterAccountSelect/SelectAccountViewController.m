
//  SelectAccountViewController.m
//  SutabaSongs
//
//  Created by Noto Kaname on 12/06/03.
//  Copyright (c) 2012 Irimasu Densan Planning. All rights reserved.
//


static NSInteger s_accountCellID = 0;

#import "SelectAccountViewController.h"
#import "AppDelegate.h"
#import "TwitterProfileImageCache.h"

@interface SelectAccountViewController ()
{
    NSMutableArray* _identifiers;
    SEL _selGetter;
    SEL _selSetter;
}
- (void) getTwitterAccounts;
- (void) configureCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath;

@end

@implementation SelectAccountViewController
//@synthesize selectdIdentifier=_selectdIdentifier;
@synthesize target=_target;
@synthesize propertyName=_propertyName;

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

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(firedCancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(firedDone:)];

    _selGetter = NSSelectorFromString( _propertyName ); 
    if( [_target respondsToSelector:_selGetter] != YES ){
        NSLog(@"no respons getter");
        abort();
    }
    
    NSString* setterName = [NSString stringWithFormat:@"set%@%@:",[[_propertyName substringToIndex:1] capitalizedString],[_propertyName substringFromIndex:1] ];
    _selSetter = NSSelectorFromString(setterName );
    if( [_target respondsToSelector:_selSetter] != YES ){
        NSLog(@"no respons setter: %@", setterName );
        abort();
    }
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getTwitterAccounts];
}

- (void) firedCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) firedDone:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) getTwitterAccounts {
    AppDelegate* appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    
	// Create an account store object.
	ACAccountStore *accountStore = appDelegate.accountStore;
	
	// Create an account type that ensures Twitter accounts are retrieved.
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
    _identifiers = [NSMutableArray array];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        // Request access from the user to use their Twitter accounts.
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted) {
                // Get the list of Twitter accounts.
                __weak NSArray* accountsArray = [accountStore accountsWithAccountType:accountType];
                
                for (ACAccount* account in accountsArray ) {
                    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
#define kIdentifier @"identifier"                                              
                                                [account.identifier copy],kIdentifier
                                                ,[account.username copy],@"username"
                                                ,[account.accountDescription copy],@"accountDescription"
                                                ,nil];
                    
//                    NSLog(@"dic=%@",dic);
                    
                    [_identifiers addObject:dic];
                }
                
                /*
                 for (NSObject* account in accountsArray ) {
                 NSLog(@"account=%@", account );
                 }
                 _userID =  ((ACAccount*)[accountsArray objectAtIndex:0]).identifier;
                 */
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    
                    [self.tableView reloadData];
                });
                
                
            }else {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"認証が却下されました。" message:@"アプリの認証が却下されました設定画面から確認してください。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alertView show];
            }
        }];       
    });
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self getTwitterAccounts];
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
    return [_identifiers count];
}

- (void) configureCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    cell.textLabel.text = [[_identifiers objectAtIndex:indexPath.row] objectForKey:@"username"];
    s_accountCellID++;
    NSInteger currentID = cell.tag = s_accountCellID;
    
    AppDelegate* appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    ACAccountStore* accountStore = appDelegate.accountStore;
    
    cell.imageView.image = [UIImage imageNamed:@"profileImageDummy.png"];
    
    ACAccount* account = [accountStore accountWithIdentifier:[[_identifiers objectAtIndex:indexPath.row] objectForKey:@"identifier"]];
    [TwitterProfileImageCache loadProfileImageWithAccount:account block:^(UIImage *image) {
        if( self.navigationController.topViewController == self && currentID == cell.tag ){
            cell.imageView.image = image;
        }
    }];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"    
    NSString* selectedIdentifier = [_target performSelector:_selGetter];
#pragma clang diagnostic pop

    if( selectedIdentifier != nil ){
        NSDictionary* dic = [_identifiers objectAtIndex:indexPath.row];
        NSString* identifier = [dic objectForKey:kIdentifier];
        if( [identifier compare:selectedIdentifier] == NSOrderedSame ){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
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
    NSDictionary* dic = [_identifiers objectAtIndex:indexPath.row];
    NSString* selectdIdentifier = [dic objectForKey:kIdentifier];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"    
    [_target performSelector:_selSetter withObject:selectdIdentifier];
#pragma clang diagnostic pop

    NSArray* visibleCells = [tableView visibleCells];
    for( UITableViewCell* cell in visibleCells ){
        NSIndexPath* indexPathVisible = [tableView indexPathForCell:cell];
        
        if( indexPath.row != indexPathVisible.row ){
            NSDictionary* dic = [_identifiers objectAtIndex:indexPathVisible.row];
            NSString* identifier = [dic objectForKey:kIdentifier];
            if( [identifier compare:selectdIdentifier] != NSOrderedSame ){
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
