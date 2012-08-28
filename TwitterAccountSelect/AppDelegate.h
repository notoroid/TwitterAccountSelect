//
//  AppDelegate.h
//  SutabaSongs
//
//  Created by Noto Kaname on 12/06/03.
//  Copyright (c) 2012 Irimasu Densan Planning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) ACAccountStore* accountStore;
@property (nonatomic,strong) NSString* twitterIdentifier;

- (NSURL *)applicationDocumentsDirectory;
- (void)updateRepositoryWithUpdate:(BOOL) update;

@end
