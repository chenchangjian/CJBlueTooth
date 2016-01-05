//
//  CJBlueToothDemo
//
//  Created by ccj on 15/12/11.
//  Copyright © 2015年 ccj. All rights reserved.
//  源码下载地址: https://github.com/chenchangjian/CJBlueTooth


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FactoryManager : NSObject
//
+ (void)addHorizontalLineLeft:(float)left top:(float)top width:(float)width onView:(UIView *)targetView lineColor:(UIColor *)lineColor;

+ (void)addVerticalLineTop:(float)top Left:(float)left height:(float)height onView:(UIView *)onView lineColor:(UIColor *)lineColor;

+ (void)setBGImageWithImageName:(NSString *)imageName onView:(UIView *)onView;

+ (NSString*)hexadecimalString:(NSData *)data;

+ (NSData*)dataWithHexstring:(NSString *)hexstring;

+ (NSString *)getDate;
@end
