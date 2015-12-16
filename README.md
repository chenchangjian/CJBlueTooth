# CJBlueTooth
本框架封装了蓝牙4.0 BLE 的基本功能,包括连接外设、断开外设、通过加密通道连接外设、读取RSSI值、功率值、电量值、设备名称、外设报警、外设断开等, 开发者只需很少的代码就能实现上述全部功能, 欢迎访问本人技术博客: [陈长见](http://www.jianshu.com/users/066654344178/latest_articles)

###使用介绍

首先下载框架到项目中,并导入头件

    #import "CJBlueTooth.h"
在合适的地方初始化框架

    CJBlueTooth *cenMgr = [CJBlueTooth defaultBleManager];
按照连接外设的逻辑,先连接设备,我这里提供通过外设的名称来连接

    [cenMgr searchPeripheralWithName:@"ITAG"];
也可以通过加密通道来连接设备,加密通道连接设备试用于你的外设已经加密处理

    /**
     *  UUIDService 加密服务字 
     *  UUIDCharacteristic 加密特征
     *  andEncryptString 要写入的加密字符串
     */
    [cenMgr searchPeripheralWithName:@"ITAG" UUIDService:nil UUIDCharacteristic:nil andEncryptString:nil];
之后我们就可以获取我们想要的值,或者报警功能的处理,方法如下:

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
最后断开外设的连接

    /** 断开设备*/
    - (void)disconnectPeripheral;
