//
//  TwitterProfileImage.m
//  TwitterAccountSelect
//
//  Created by Noto Kaname on 12/08/28.
//  Copyright (c) 2012 Irimasu Densan Planning. All rights reserved.
//

#import "TwitterProfileImageCache.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@implementation TwitterProfileImageCache

+ (void) loadProfileImageWithAccount:(ACAccount*)account block:(twitter_profile_image_block_t)block
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSString *tempDir = NSTemporaryDirectory();
        NSString *profileImagePath = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"profile_%@.png",account.username] ];
        
        NSFileManager* fileManager = [[NSFileManager alloc] init];
        BOOL mustReload = YES;
        
        if( [fileManager fileExistsAtPath:profileImagePath] ){
            NSError* error = nil;
            NSDictionary* dicAttributes = [fileManager attributesOfItemAtPath:profileImagePath error:&error];
        
            NSDate* modifiedDate = dicAttributes.fileModificationDate;
            NSDate* compareDate = [NSDate dateWithTimeIntervalSinceNow:- 10.0f * 60.0f /*10分前*/];
            if( [modifiedDate compare:compareDate] == NSOrderedAscending ){
                mustReload = YES;
            }else{
                mustReload = NO;
            }
        }
        
        if( mustReload != YES ){
            NSData* data = [NSData dataWithContentsOfFile:profileImagePath];
            UIImage* profileImage = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                block( profileImage ); 
            });
        }else{
            TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/users/profile_image/:screen_name"]
                                                         parameters:[NSDictionary dictionaryWithObjectsAndKeys:account.username,@"screen_name"
                                                                     ,@"normal",@"size"
                                                                     ,nil]
                                                      requestMethod:TWRequestMethodPOST];
            
            
            // Set the account used to post the tweet.
            [postRequest setAccount:account];
            NSURLRequest* request = [postRequest signedURLRequest];
            
            NSError* error = nil;
            NSURLResponse* response = nil;
            
            NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if( data != nil ){
                // 標準サイズを作成する
                UIImage* imageProfileImage = [UIImage imageWithData:data];            

                UIImage* imageNormalScale = nil;
                if( [UIScreen mainScreen].scale == 1.0f ){
                    CGColorSpaceRef  imageColorSpace = CGColorSpaceCreateDeviceRGB();
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    
                    const double width = CGImageGetWidth([imageProfileImage CGImage]);
                    const double height = CGImageGetHeight([imageProfileImage CGImage]);
                    CGRect bounds = CGRectMake(0, 0, width *.5f, height *.5f);
                    CGContextRef context = CGBitmapContextCreate (NULL,bounds.size.width,bounds.size.height,8, bounds.size.width * 4, imageColorSpace, kCGImageAlphaPremultipliedFirst );
                    transform = CGAffineTransformScale(transform, .5f, .5f);
                    
                    CGContextConcatCTM(context, transform);
                    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [imageProfileImage CGImage] );
                    CGImageRef cgImage = CGBitmapContextCreateImage(context);
                    
                    imageNormalScale = [[UIImage alloc] initWithCGImage:cgImage];
                    NSData* dataNormalScale = UIImagePNGRepresentation(imageNormalScale);
                    
                    [dataNormalScale writeToFile:profileImagePath atomically:YES];
                    
                    CGImageRelease(cgImage);
                    CGContextRelease(context);
                    CGColorSpaceRelease(imageColorSpace);
                }else{
                    [data writeToFile:profileImagePath atomically:YES];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    block( [UIScreen mainScreen].scale == 1.0 ? imageNormalScale : imageProfileImage ); 
                });
            }            
        }
        
    });

}

@end
