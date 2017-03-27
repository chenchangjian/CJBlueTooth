//
//  CJBlueToothDemo
//
//  Created by ccj on 15/12/11.
//  Copyright © 2015年 ccj. All rights reserved.
//  源码下载地址: https://github.com/chenchangjian/CJBlueTooth

#import "FactoryManager.h"

@implementation FactoryManager
// 划线－－水平线
+ (void)addHorizontalLineLeft:(float)left top:(float)top width:(float)width onView:(UIView *)targetView lineColor:(UIColor *)lineColor
{
    
    CALayer *line = [[CALayer alloc] init];
    line.frame = CGRectMake(left, top, width, 1);
    line.backgroundColor = [lineColor CGColor];
    [targetView.layer addSublayer:line];
    
}
// 画竖线
+ (void)addVerticalLineTop:(float)top Left:(float)left height:(float)height onView:(UIView *)onView lineColor:(UIColor *)lineColor
{
    
    CALayer *line = [[CALayer alloc] init];
    line.frame = CGRectMake(left, top, 1, height);
    line.backgroundColor = [lineColor CGColor];
    [onView.layer addSublayer:line];
}
/**
 *  获得当前日期
 *
 */
+ (NSString *)getDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *date = [[NSDate alloc] init];
    NSString *time = [formatter stringFromDate:date];
    return time;
}

// 设置onView背景图片
+ (void)setBGImageWithImageName:(NSString *)imageName onView:(UIView *)onView
{
    UIImage *bgImage = [UIImage imageNamed:imageName];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width/2.0 topCapHeight:bgImage.size.height/2.0f];

    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:onView.bounds];
    bgImageView.image = bgImage;
    [onView addSubview:bgImageView];
    
}
// 将传入的16进制NSData类型转换成16进制NSString并返回,蓝牙ble 4.0使用
+ (NSString*)hexadecimalString:(NSData *)data
{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer)
    {
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++)
    {
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}

// 将传入的16进制NSString类型转换成16进制NSData并返回 蓝牙ble 4.0使用
+ (NSData*)dataWithHexstring:(NSString *)hexstring
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for(idx = 0; idx + 2 <= hexstring.length; idx += 2)
    {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexstring substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
@end
