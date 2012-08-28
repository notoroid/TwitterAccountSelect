//
//  MasterViewController.h
//  SutabaSongs
//
//  Created by Noto Kaname on 12/06/03.
//  Copyright (c) 2012 Irimasu Densan Planning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingViewController.h"

@interface ViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,SettingViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView* tableView;

@end
