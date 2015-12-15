//
//  CJBlueToothDemo
//
//  Created by ccj on 15/12/11.
//  Copyright © 2015年 ccj. All rights reserved.
//

#import "CCJBLECenterManager.h"
#import <sqlite3.h>


#import "FactoryManager.h"
#import "SVProgressHUD.h"

#define BatService      @"180F" // 外设电量服务
#define BatChara        @"2A19" // 外设电量特征
#define PowerCharacter  @"2A07" // 外设功率特征
#define PowerService    @"1804" // 外设功率服务
#define encryptService  @"FF00" // 加密通道服务
#define encptCharacter  @"FFC0" // 加密通道特征
#define NotCharaOrDes   @"ffe1" //外设通知服务和特征
#define AlertService    @"1802" //外设写入服务
#define AlertChara      @"2A06" //外设写入特征
#define NotifyService   @"ffe0" //外设通知服务
#define NotCharaOrDes   @"ffe1" //外设通知服务和特征
#define DESCRIPTORS     @"2902" //外设特征的描述


@interface CCJBLECenterManager () <CBCentralManagerDelegate, CBPeripheralDelegate>

/** 中心管理者 */
@property (nonatomic, strong) CBCentralManager *cMgr;

@property (nonatomic, assign) NSTimeInterval timeBegain;
@property (nonatomic, assign) sqlite3 *db;

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, copy) NSString *PeripheralName;
@end


static CCJBLECenterManager *shareManager = nil;

@implementation CCJBLECenterManager

//单例
+(instancetype)defaultBleManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (shareManager == nil) {
            shareManager = [[self alloc] init];
        }
    });
    return shareManager;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    @synchronized (self){
        if (shareManager == nil) {
            shareManager = [super allocWithZone:zone];
        }
    }
    return shareManager;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        //初始化管理中心和提取数据
        self.cMgr = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        
    }
    return self;
}


// 只要中心管理者初始化,就会触发此代理方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@"设备蓝牙已开启");
            
            
            [self.cMgr scanForPeripheralsWithServices:nil // 通过某些服务筛选外设
                                              options:nil]; // dict,条
            
        }
            break;
            
        default:
        {

            [UIAlertController alertControllerWithTitle:@"提示" message:@"蓝牙未连接,请打开蓝牙!" preferredStyle:UIAlertControllerStyleAlert];
            NSLog(@"设备蓝牙未正常开启,请开启蓝牙后重试!");
        }
            break;
    }
}


// 发现外设后调用的方法
- (void)centralManager:(CBCentralManager *)central // 中心管理者
 didDiscoverPeripheral:(CBPeripheral *)peripheral // 外设
     advertisementData:(NSDictionary *)advertisementData // 外设携带的数据
                  RSSI:(NSNumber *)RSSI // 外设发出的蓝牙信号强度
{
   
    
    [self.array addObject:advertisementData];
    if ([self.delegate respondsToSelector:@selector(sendAdvertisementArry:)])
    {
       
        [self.delegate sendAdvertisementArry:self.array];
    }
    
   

    [self.PerNames addObject:advertisementData[@"kCBAdvDataLocalName"]];
    
    if ([peripheral.name isEqualToString:self.PeripheralName])
    {
    
        self.PerName = peripheral.name;
        
        // 标记我们的外设,让他的生命周期 = vc
        self.peripheral = peripheral;
        // 发现完之后就是进行连接
        [self.cMgr connectPeripheral:self.peripheral options:nil];
    } else {
        [SVProgressHUD showErrorWithStatus:@"没有此设备,请检查后重连!"];
    }
    
}


// 中心管理者连接外设成功
- (void)centralManager:(CBCentralManager *)central // 中心管理者
  didConnectPeripheral:(CBPeripheral *)peripheral // 外设
{
    [self ccj_dismissConentedWithPeripheral:peripheral IsCancle:false];
   
    
    self.peripheral.delegate = self;
    
    
    [self.peripheral discoverServices:nil];
    // 4.1.3 读取RSSI的值
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(readRSSIInfo) userInfo:nil repeats:YES];
    
}
// 外设连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
     NSLog(@"设备连接失败!");
}

// 丢失连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
     NSLog(@"设备已断开!");
}

// 发现外设的服务后调用的方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    // 判断没有失败
    if (error) {
        NSLog(@"%s, line = %d, error = %@", __FUNCTION__, __LINE__, error.localizedDescription);
        return;
    }
    for (CBService *service in peripheral.services) {
        // 发现服务后,让设备再发现服务内部的特征们 didDiscoverCharacteristicsForService
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// 发现外设服务里的特征的时候调用的代理方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"%s, line = %d, %@", __FUNCTION__, __LINE__, [error description]);
        return;
    }
    
    for (CBCharacteristic *chara in service.characteristics)
    {
        // 外设读取特征的值
        //        [peripheral readValueForCharacteristic:chara];
        // 电量特征和服务
        if([chara.UUID isEqual:[CBUUID UUIDWithString:BatChara]] && [service.UUID isEqual:[CBUUID UUIDWithString:BatService]])
        {
            
        
            [peripheral readValueForCharacteristic:chara];
            
            // 在这里发起,记下一个时间
            NSDate *timeNow = [NSDate date];
            
            NSTimeInterval time1 = [timeNow timeIntervalSince1970];
            
            self.timeBegain = time1;
            //        NSLog(@"time1 = %f",self.timeBegain);
            
        } else if ([chara.UUID isEqual:[CBUUID UUIDWithString:PowerCharacter]] && [service.UUID isEqual:[CBUUID UUIDWithString:PowerService]])
        {
            [peripheral readValueForCharacteristic:chara];
            
        } else if ([chara.UUID isEqual:[CBUUID UUIDWithString:encptCharacter]] && [service.UUID isEqual:[CBUUID UUIDWithString:encryptService]]) // 如果是加密通道
        {
            
            NSString *str = @"Cocas Anti-lost";
           
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            
           
            [self ccj_peripheral:peripheral didWriteData:data forCharacteristic:chara];
            
            
        }else if ([chara.UUID isEqual:[CBUUID UUIDWithString:AlertChara]] && [service.UUID isEqual:[CBUUID UUIDWithString:AlertService]])
        {
            self.AlertChater = chara;
        }
        
        
    }
}
// 更新特征的value的时候会调用
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        // 它会触发
        [peripheral readValueForDescriptor:descriptor];
    }
    
    // 写入这个方法后会不停的读取特征
    [peripheral readValueForCharacteristic:characteristic];
   
    if (error) {
        
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BatChara]])
    {
        
        NSString *value = [[NSString alloc] initWithFormat:@"%@",[FactoryManager hexadecimalString:characteristic.value]];
        // 蓝牙设备的电量
        NSInteger num = strtoul([value UTF8String], 0, 16);
        
        self.Bat = num;
        
        
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:PowerCharacter]])
    {
        
        NSString *value = [[NSString alloc] initWithFormat:@"%@",[FactoryManager hexadecimalString:characteristic.value]];
                    // 蓝牙设备的电量
        NSInteger num = strtoul([value UTF8String], 0, 16);
        
        self.Power = num;
        
        
    }
}


// 更新特征的描述的值的时候会调用
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
    // 这里当描述的值更新的时候,直接调用此方法即可
    [peripheral readValueForDescriptor:descriptor];
}


//接收到通知
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    //    NSLog(@"+++++++++接收到通知");
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:NotCharaOrDes]]) {
        return;
    }
    //
    //    NSLog(@"---------------");
    
    [peripheral readValueForCharacteristic:characteristic];//接受通知后读取
    [peripheral discoverDescriptorsForCharacteristic:characteristic];
}

//读取到信号回调
-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    
    self.RSSI = [RSSI integerValue];
    
}

// 收到反馈时调用
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    [peripheral readValueForCharacteristic:characteristic];
    
}

#pragma mark - 自定义方法

// 5.外设写数据到特征中

// 需要注意的是特征的属性是否支持写数据
- (void)ccj_peripheral:(CBPeripheral *)peripheral didWriteData:(NSData *)data forCharacteristic:(nonnull CBCharacteristic *)characteristic
{
    if (characteristic.properties & CBCharacteristicPropertyWrite) {
        // 核心代码在这里
        [peripheral writeValue:data // 写入的数据
             forCharacteristic:characteristic // 写给哪个特征
                          type:CBCharacteristicWriteWithResponse];// 通过此响应记录是否成功写入
    }
}


- (void)ccj_peripheral:(CBPeripheral *)peripheral regNotifyWithCharacteristic:(nonnull CBCharacteristic *)characteristic
{
    // 外设为特征订阅通知 数据会进入 peripheral:didUpdateValueForCharacteristic:error:方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}
- (void)ccj_peripheral:(CBPeripheral *)peripheral CancleRegNotifyWithCharacteristic:(nonnull CBCharacteristic *)characteristic
{
    
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

// 7.断开连接
- (void)ccj_dismissConentedWithPeripheral:(CBPeripheral *)peripheral IsCancle:(BOOL)cancle
{
    // 停止扫描
    [self.cMgr stopScan];
    if (cancle) {
        // 断开连接
        [self.cMgr cancelPeripheralConnection:peripheral];
    }
    
}


// 读RSSI值
- (void)readRSSIInfo
{
    [self.peripheral readRSSI];
    
}

// 通过姓名连接
- (void)setConnectWithPeripheralName:(NSString *)PeripheralName
{
    self.PeripheralName = PeripheralName;
    
}

- (void)searchPeripheralWithName:(NSString *)PeripheralName
{
    [self cMgr];
    [self setConnectWithPeripheralName:PeripheralName];
    // 带有文字的转圈等待指示器
    [SVProgressHUD showWithStatus:@"   正在连接设备请稍后..." maskType:SVProgressHUDMaskTypeBlack];
    NSLog(@"正在连接设备请稍后...");
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       // 执行耗时的异步操作...
                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                           
                           // 隐藏指示器
                           [SVProgressHUD dismiss];
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               // 回到主线程，执行UI刷新操作
                               NSLog(@"设备连接成功!");
                               
                           });
                       });
                       
                   });
    
}


- (NSInteger)readRSSIValue
{
    return self.RSSI;
}

- (NSInteger)readBatValue
{
    return self.Bat;
}

- (NSInteger)readPowerValue
{
    return self.Power;
}

- (NSString *)readNameValue
{
    return self.PerName;
}

- (void)beginAlert
{
    Byte data[1];
    data[0] = 0x02;
    
    [self.peripheral writeValue:[NSData dataWithBytes:data length:1] forCharacteristic:self.AlertChater type:CBCharacteristicWriteWithoutResponse];
}

- (void)stopAlert
{
    Byte data[1];
    data[0] = 0x00;
    [self.peripheral writeValue:[NSData dataWithBytes:data length:1] forCharacteristic:self.AlertChater type:CBCharacteristicWriteWithoutResponse];
}

- (void)disconnectPeripheral
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self ccj_dismissConentedWithPeripheral:self.peripheral IsCancle:YES];
       
    });
    
}

@end
