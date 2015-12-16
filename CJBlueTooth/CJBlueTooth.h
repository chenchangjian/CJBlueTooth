//
//  CJBlueTooth.h
//  CJBlueToothDemo
//
//  Created by ccj on 15/12/15.
//  Copyright © 2015年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CJBlueTooth : NSObject

/** 电量 */
@property (nonatomic, assign) NSInteger Bat;
/** 功率 */
@property (nonatomic, assign) NSInteger Power;
/** 设备名称 */
@property (nonatomic, copy) NSString *PerName;

/** 连接到的外设 */
@property (nonatomic, strong) CBPeripheral *peripheral;

/** 外设特征 */
@property (nonatomic, strong) CBCharacteristic *AlertChater;

/** 设备名称数组 */
@property (nonatomic, copy) NSMutableArray *PerNames;

/** 读取RSSI的值 */
@property (nonatomic, assign) NSInteger RSSI;

/** 单例 */
+ (instancetype)defaultBleManager;

/** 设置连接 */
- (void)setConnectWithPeripheralName:(NSString *)PeripheralName;

/** 搜索设备*/
- (void)searchPeripheralWithName:(NSString *)PeripheralName;

/** 搜索加密设备*/
- (void)searchPeripheralWithName:(NSString *)PeripheralName UUIDService: (NSString *)UUIDService UUIDCharacteristic:(NSString *)UUIDCharacteristic andEncryptString:(NSString *)str;

/** 断开设备*/
- (void)disconnectPeripheral;

/**
 *  读取RSSI的值
 */
- (NSInteger)readRSSIValue;

/**
 *  读取电量的值
 */
- (NSInteger)readBatValue;

/** 读功率的值 */
- (NSInteger)readPowerValue;

/** 设备名称的值 */
- (NSString *)readNameValue;

/** 开始即时报警 */
- (void)beginAlert;

/** 断开即时报警*/
- (void)stopAlert;



@end
