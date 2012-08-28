//
//  SettingViewController.h
//  SutabaSongs
//
//  Created by Noto Kaname on 12/06/03.
//  Copyright (c) 2012 Irimasu Densan Planning. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingViewControllerDelegate;

@interface SettingViewController : UITableViewController

@property(nonatomic,weak) IBOutlet id<SettingViewControllerDelegate> settingDelegate;

@end

@protocol SettingViewControllerDelegate

- (void) settingViewControllerDidDone:(SettingViewController*)settingViewController;

@end
