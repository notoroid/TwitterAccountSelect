//
//  TwitterProfileImage.h
//  TwitterAccountSelect
//
//  Created by Noto Kaname on 12/08/28.
//  Copyright (c) 2012 Irimasu Densan Planning. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^twitter_profile_image_block_t)(UIImage* image);

@class ACAccount;

@interface TwitterProfileImageCache : NSObject

+ (void) loadProfileImageWithAccount:(ACAccount*)account block:(twitter_profile_image_block_t)block;

@end
