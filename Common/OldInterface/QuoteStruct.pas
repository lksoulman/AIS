unit QuoteStruct;

interface

uses Windows, QuoteConst, SysUtils, Ansistrings, QuoteMngr_TLB, Messages, QuoteLibrary;

const
  // 消息定义
  WM_HandleEvent = WM_USER + 5000;
  WM_DataArrive = WM_USER + 5001;
  WM_DataReset = WM_USER + 5002;

type
  // 股票代码结构
  HSMarketDataType = USHORT; // 市场分类数据类型
  PCodeInfo = ^TCodeInfo;

  TCodeInfo = packed record
    m_cCodeType: HSMarketDataType; // 证券类型
    m_cCode: array [0 .. 5] of AnsiChar; // 证券代码
  end;

  // 请求/返回类型 DEFINE BEGIN
  // 市场类别定义：
  // 各位含义表示如下：
  // 15                   12                8                                        0
  // |                        |                    |                                        |
  // | 金融分类        |市场分类 |        交易品种分类        |
  TSrvFileType = // 服务器路径类型

    (Srv_BlockUserStock, // 板块、自选股
    Srv_Setting, // 设置...
    Srv_Setting_File, // 配置文件
    Srv_FinancialData, Srv_ClientFileUpdate, // 客户端文件升级
    Srv_UserManagerDBF, // 用户管理
    Srv_UserConfig, // 用户对应的配置文件
    Srv_sysInfoData, // 系统运行状态文件
    Srv_AcceptFilePath, // 收到上传的文件
    Srv_DFxPath, // 大福星1.5服务器配置文件目录
    Srv_Gif, // gif文件目录
    Srv_Config, // gif文件设置目录
    Srv_Dynamic_File, // 进程保存
    Srv_ExterDll); // dll路径

  Tm_Oper = packed record
    case integer of
      0:
        (m_cOperator: AnsiChar); // 客户端使用，服务器：=1时，当前请求包不能清，=0时，清除
      // 客户端使用，当前所属的服务器类别，指向CEV_Connect_HQ_等的定义。
      1:
        (m_cSrv: AnsiChar); // 服务器使用
  end;

  TCodeInfos = array [0 .. MaxCount] of TCodeInfo;
  PCodeInfos = ^TCodeInfos;

  // 验证数据
  HSPrivateKey = packed record
    m_pCode: TCodeInfo; // 商品代码
  end;

  // 返回包头结构
  PDataHead = ^TDataHead;

  TDataHead = packed record
    m_nType: USHORT; // 请求类型，与请求数据包一致
    m_nIndex: Byte; // 请求索引，与请求数据包一致
    m_Oper: Tm_Oper;
    m_lKey: LongInt; // 一级标识，通常为窗口句柄
    m_nPrivateKey: HSPrivateKey; // 二级标识
  end;

  // 压缩返回包格式
  PTransZipData = ^TTransZipData;

  TTransZipData = packed record
    m_nType: USHORT; // 请求类型,恒为RT_ZIPDATA
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_lZipLen: LongInt; // 压缩后的长度
    m_lOrigLen: LongInt; // 压缩前的长度
    m_cData: array [0 .. 0] of AnsiChar; // 压缩后的数据
  end;

  TStockOtherDataDetailTime = packed record
    m_nTime: USHORT;
    m_nSecond: USHORT;
  end;

  TStockOtherData_Time = packed record
    case integer of
      0:
        (m_nTimeOld: ULONG); // 现在时间
      1:
        (m_nTime: USHORT); // 现在时间
      2:
        (m_sDetailTime: TStockOtherDataDetailTime);
  end;

  TStockOtherData_Data = packed record
    case integer of
      0:
        (m_lKaiCang: ULONG); // 今开仓,深交所股票单笔成交数,港股交易宗数
      1:
        (m_lPreClose: ULONG); // 对于外汇时，昨收盘数据
  end;

  TStockOtherData_Data1 = packed record
    case integer of
      0:
        (m_rate_status: ULONG); // 对于外汇时，报价状态
      // 对于股票，信息状态标志,
      // MAKELONG(MAKEWORD(nStatus1,nStatus2),MAKEWORD(nStatus3,nStatus4))
      1:
        (m_lPingCang: ULONG); // 今平
  end;

  // 各股票其他数据
  TStockOtherData = packed record
    m_Time: TStockOtherData_Time;

    m_lCurrent: ULONG; // 现在总手
    m_lOutside: ULONG; // 外盘
    m_lInside: ULONG; // 内盘
    m_Data: TStockOtherData_Data;
    m_Data1: TStockOtherData_Data1;
  end;

  // 股票分类名称
  TStockTypeName = packed record
    m_szName: array [0 .. 19] of AnsiChar; // 股票分类名称
  end;

  /// *
  // 返回结构：
  // 代码表的验证和初始化应答
  // 股票初始化信息
  // */
  /// * 单个股票信息 */
  PStockInitInfo = ^TStockInitInfo;

  TStockInitInfo = packed record
    m_cStockName: array [0 .. STOCK_NAME_SIZE - 1] of AnsiChar; // 股票名称
    m_ciStockCode: TCodeInfo; // 股票代码结构
    m_lPrevClose: LongInt; // 昨收
    m_l5DayVol: LongInt; // 5日量(是否可在此加入成交单位？？？？）
  end;

  /// * 单个股票信息 变长 个股期权*/
  PStockInitInfo_VarCode = ^TStockInitInfo_VarCode;

  TStockInitInfo_VarCode = packed record
    m_lPrevClose: Cardinal; // 昨收
    m_l5DayVol: Cardinal; // 5日量(是否可在此加入成交单位？？？？）
    m_cStockCode: array [0 .. 0] of AnsiChar;
    // 股票名称，包括代码、英文名和中文名;顺序为：代码、中文名、英语名;其中代码、英文名和中文名的长度定义;在CommBourseInfo_VarCode结构中,若对应长度为0，则无对应字段
  end;

  PStockInitInfoSimple = ^TStockInitInfoSimple;

  TStockInitInfoSimple = packed record

    m_ciStockCode: TCodeInfo; // 股票代码结构
    m_lPrevClose: LongInt; // 昨收
    m_l5DayVol: LongInt; // 5日量(是否可在此加入成交单位？？？？）
    m_nSize: short; // 名称长度
    m_cStockName: array [0 .. STOCK_NAME_SIZE - 1] of AnsiChar; // 股票名称
  end;

  // 证券信息
  THSTypeTime = packed record
    m_nOpenTime: short; // 前开市时间
    m_nCloseTime: short; // 前闭市时间
  end;

  THSTypeTime_Unoin = packed record

    m_nAheadOpenTime: short; // 前开市时间
    m_nAheadCloseTime: short; // 前闭市时间
    m_nAfterOpenTime: short; // 后开市时间
    m_nAfterCloseTime: short; // 后闭市时间

    m_nTimes: array [0 .. 8] of THSTypeTime; // 新加入区段边界,两边界为-1时，为无效区段

    m_nPriceDecimal: THSTypeTime; // 小数位, < 0
  end;

  PStockType = ^TStockType;

  TStockType = packed record
    m_stTypeName: TStockTypeName; // 对应分类的名称
    m_nStockType: short; // 证券类型
    m_nTotal: short; // 证券总数
    m_nOffset: short; // 偏移量
    m_nPriceUnit: short; // 价格单位
    m_nTotalTime: short; // 总开市时间（分钟）
    m_nCurTime: short; // 现在时间（分钟）
    case integer of
      0:
        (m_nNewTimes: array [0 .. 10] of THSTypeTime);
      1:
        (m_union: THSTypeTime_Unoin);
  end;

  //
  // 通讯包格式说明:
  //
  // 单包请求包结构
  // 说明：
  // 1、        m_nIndex、m_cOperor、m_lKey、m_nPrivateKey为客户端专用的一些信息，
  // 服务器端处理时直接拷贝返回,下同。
  // 2、        宏定义：HS_SUPPORT_UNIX_ALIGN为使用于UNIX服务器4字节对齐使用，下同。
  // 3、        所有请求都发送此包，根据m_nType类型具体情况来确定m_nSize和m_pCode[1]
  // 内容来实现各种各样的请求。
  // 4、        常用请求：指的是m_nSize取值为n个，m_pCode[1]内容只有n个CodeInfo，
  // 即只请求n个股票数据，根据m_nType来识别请求类型。
  //
  PAskData = ^TAskData;

  TAskData = packed record
    m_nType: USHORT; // 请求类型，与请求数据包一致
    m_nIndex: Byte; // 请求索引，与请求数据包一致
    m_Oper: Tm_Oper;
    m_lKey: LongInt; // 一级标识，通常为窗口句柄
    m_nPrivateKey: HSPrivateKey; // 二级标识
    m_nSize: short; // 请求证券总数，小于零时，
    m_nOption: short; // 为了4字节对齐而添加的字段
  end;

  //
  // 请求类型: RT_BULLETIN
  // 功能说明: 主推紧急公告
  // 备          注:
  //
  // 请求结构 : 无请求
  // 返回结构
  PAnsBulletin = ^TAnsBulletin;

  TAnsBulletin = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: short; // 公告内容长度
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_cData: array [0 .. 0] of AnsiChar; // 公告内容
  end;

  //
  // 请求类型: RT_SERVERINFO
  // 功能说明: 主站信息
  // 备          注:
  //
  // 请求结构 : 常用请求
  //
  // 返回结构 :
  // 主站返回信息结构
  //
  PAnsServerInfo = ^TAnsServerInfo;

  TAnsServerInfo = packed record
    m_dhHead: TDataHead; // 数据报头
    m_pName: array [0 .. 31] of AnsiChar; // 服务器名
    m_pSerialNo: array [0 .. 11] of AnsiChar; // 序列号，验证正版性
    m_lTotalCount: LongInt; // 已连接过的总数
    m_lToDayCount: LongInt; // 当日连接总数
    m_lNowCount: LongInt; // 当前连接数
  end;

  // 通用文件头结构
  PHSCommonFileHead = ^THSCommonFileHead;

  THSCommonFileHead = packed record
    m_lFlag: LongInt; // 文件类型标识
    m_lDate: Double; // 文件更新日期(长度:32bit)
    m_lVersion: LongInt; // 文件结构版本标识
    m_lCount: LongInt; // 数据总个数
  end;

  //
  // 请求类型: RT_LOGIN、RT_LOGIN_INFO、RT_LOGIN_HK、RT_LOGIN_FUTURES、RT_LOGIN_FOREIGN
  // 功能说明: 客户端登录请求
  // 备          注:
  //
  // 请求结构
  PReqLogin = ^TReqLogin;

  TReqLogin = packed record
    m_szUser: array [0 .. 63] of AnsiChar; // 用户名
    m_szPWD: array [0 .. 63] of AnsiChar; // 密码
  end;

  // 客户端登录 返回结构
  PAnsLogin = ^TAnsLogin;

  TAnsLogin = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nError: short; // 错误号
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_nSize: integer; // 长度
    m_szRet: array [0 .. 0] of AnsiChar; // 配置文件数据或者返回错误信息字符串
  end;

  // Level2应答包体结构
  PAnsLoginLevel2 = ^TAnsLoginLevel2;

  TAnsLoginLevel2 = packed record
    m_nError: short; // 错误标识 0: 校验通过 1:用户名或密码错误
    // 2:客户已登陆 3:未开通 4:过期等等
    m_nGrant: integer; // 权限位 二进制位：每位代表一种权限，具体权限按需求定
    m_nValidDay: integer; // 有效天数,提供客户端快到期提醒使用
  end;

  //
  // /*
  // 请求类型: RT_INITIALINFO
  // 功能说明: 代码表的验证和初始化
  // 备          注:
  // */
  //
  /// *
  // 请求结构：
  // 代码表的验证和初始化请求
  // */
  PReqInitSrv = ^TReqInitSrv;

  TReqInitSrv = packed record
    m_nSrvCompareSize: short; // 服务器比较个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    // m_sServerCompare[1]: ServerCompare;   // 服务器比较信息
  end;

  // 服务器证券简短信息
  PServerCompare = ^TServerCompare;

  TServerCompare = packed record
    m_cBourse: HSMarketDataType; // 证券分类类型
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_dwCRC: UINT; // CRC校验码
  end;

  TServerCompares = array [0 .. MaxCount] of TServerCompare;
  PServerCompares = ^TServerCompares;

  // 市场信息结构
  PCommBourseInfo = ^TCommBourseInfo;

  TCommBourseInfo = packed record
    m_stTypeName: TStockTypeName; // 市场名称(对应市场类别)
    m_nMarketType: short; // 市场类别(最高俩位)
    m_cCount: short; // 有效的证券类型个数
    m_lDate: LongInt; // 今日日期（19971230）
    m_dwCRC: UINT; // CRC校验码（分类）
    m_stNewType: array [0 .. 0] of TStockType; // 证券信息
  end;

  // 市场信息结构  变长 个股期权
  PCommBourseInfo_VarCode = ^TCommBourseInfo_VarCode;

  TCommBourseInfo_VarCode = packed record
    m_stTypeName: TStockTypeName; // 市场名称(对应市场类别)
    m_nMarketType: short; // 市场类别(最高俩位)
    m_cCount: short; // 有效的证券类型个数

    m_nCodeLen: short; // 股票代码的长度 须定义成4的倍数，此字段不能为0
    m_nChNameLen: short; // 股票中文名长度 须定义成4的倍数，为0则无中文名
    m_nEnNameLen: short; // 股票英文名长度 须定义成4的倍数，为0则无英文名
    m_nDSTFlag: short; // 夏令时标志 0，非夏令时。1，夏令时。
    m_nTimeZone: short; // 时区格式±HHMM 如东八区为800，西11区为-1100。
    m_nEncodingType: short; // 中文编码类型 参见ENCODING_*一系列宏定义
    m_nHand: short; // 每股手数

    m_lDate: LongInt; // 今日日期（19971230）
    m_dwCRC: UINT; // CRC校验码（分类）
    m_stNewType: array [0 .. 0] of TStockType; // 证券信息
  end;

  PStockInitData = ^TStockInitData;

  TStockInitData = packed record
    m_nSize: short; // 股票个数据
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_pstInfo: array [0 .. 0] of TStockInitInfo; // (m_biInfo）里指定分类的代码数据
  end;

  // 变长(期权)
  PStockInitData_VarCode = ^TStockInitData_VarCode;

  TStockInitData_VarCode = packed record
    m_nSize: short; // 股票个数据
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_pstInfo: array [0 .. 0] of TStockInitInfo_VarCode; // (m_biInfo）里指定分类的代码数据
  end;

  POneMarketData = ^TOneMarketData;

  TOneMarketData = packed record
    m_biInfo: TCommBourseInfo; // 市场信息
    m_pstData: TStockInitData;
  end;

  // 变长(期权)
  POneMarketData_VarCode = ^TOneMarketData_VarCode;

  TOneMarketData_VarCode = packed record
    m_biInfo: TCommBourseInfo_VarCode; // 市场信息
    m_nSize: short; // 股票个数据
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_pstInfo: array [0 .. 0] of TStockInitInfo_VarCode; // (m_biInfo）里指定分类的代码数据
  end;

  TInitialOper = packed record
    case integer of
      0:
        (m_nAlignment: short); // 是否为主推初始化包(0：请求初始化包，非0：主推初始化包)
      1:
        (m_nOpertion: short); // 返回选项,参见:AnsInitialData_All 定义
  end;

  // 初始化返回结构
  PAnsInitialData = ^TAnsInitialData;

  TAnsInitialData = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: short; // 市场个数
    m_Oper: TInitialOper; // 是否为主推初始化包(0：请求初始化包，非0：主推初始化包)
    // 返回选项,参见:AnsInitialData_All 定义
    m_sOneMarketData: array [0 .. 0] of TOneMarketData; // 市场数据
  end;

  // 变长初始化返回结构 (个股期权)
  PAnsInitialData_VarCode = ^TAnsInitialData_VarCode;

  TAnsInitialData_VarCode = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: short; // 市场个数
    m_Oper: TInitialOper; // 是否为主推初始化包(0：请求初始化包，非0：主推初始化包)
    // 返回选项,参见:AnsInitialData_All 定义
    m_sOneMarketData: array [0 .. 0] of TOneMarketData_VarCode; // 市场数据
  end;

  // 实时数据
  THSStockRealTime = packed record
    m_lOpen: LongInt; // 今开盘
    m_lMaxPrice: LongInt; // 最高价
    m_lMinPrice: LongInt; // 最低价
    m_lNewPrice: LongInt; // 最新价
    m_lTotal: ULONG; // 成交量(单位:股)
    m_fAvgPrice: Single; // 成交金额
    m_lBuyPrice1: LongInt; // 买一价
    m_lBuyCount1: ULONG; // 买一量
    m_lBuyPrice2: LongInt; // 买二价
    m_lBuyCount2: ULONG; // 买二量
    m_lBuyPrice3: LongInt; // 买三价
    m_lBuyCount3: ULONG; // 买三量
    m_lBuyPrice4: LongInt; // 买四价
    m_lBuyCount4: ULONG; // 买四量
    m_lBuyPrice5: LongInt; // 买五价
    m_lBuyCount5: ULONG; // 买五量
    m_lSellPrice1: LongInt; // 卖一价
    m_lSellCount1: ULONG; // 卖一量
    m_lSellPrice2: LongInt; // 卖二价
    m_lSellCount2: ULONG; // 卖二量
    m_lSellPrice3: LongInt; // 卖三价
    m_lSellCount3: ULONG; // 卖三量
    m_lSellPrice4: LongInt; // 卖四价
    m_lSellCount4: ULONG; // 卖四量
    m_lSellPrice5: LongInt; // 卖五价
    m_lSellCount5: ULONG; // 卖五量

    m_nHand: LongInt; // 每手股数(是否可放入代码表中？？？？）
    m_lNationalDebtRatio: LongInt; // 国债利率,基金净值
  end;

  // 指标类实时数据
  THSIndexRealTime = packed record
    m_lOpen: LongInt; // 今开盘
    m_lMaxPrice: LongInt; // 最高价
    m_lMinPrice: LongInt; // 最低价
    m_lNewPrice: LongInt; // 最新价
    m_lTotal: ULONG; // 成交量
    m_fAvgPrice: Single; // 成交金额(指数数据单位百元)

    m_nRiseCount: short; // 上涨家数
    m_nFallCount: short; // 下跌家数
    m_nTotalStock1: LongInt;
    /// * 对于综合指数：所有股票 - 指数   对于分类指数：本类股票总数 */
    m_lBuyCount: ULONG; // 委买数
    m_lSellCount: ULONG; // 委卖数
    m_nType: short; // 指数种类：0-综合指数 1-A股 2-B股
    m_nLead: short; // 领先指标
    m_nRiseTrend: short; // 上涨趋势
    m_nFallTrend: short; // 下跌趋势
    m_nNo2: array [0 .. 4] of short; // 保留
    m_nTotalStock2: short; // 对于综合指数：A股 + B股   对于分类指数：0 */
    m_lADL: LongInt; // ADL 指标
    m_lNo3: array [0 .. 2] of LongInt; // 保留
    m_nHand: LongInt; // 每手股数
  end;

  THSHKStockRealTime_union = packed record
    case integer of
      0:
        (m_lYield: LongInt); // 周息率 股票相关
      1:
        (m_lOverFlowPrice: LongInt); // 溢价% 认股证相关
    // 认购证的溢价＝（认股证现价×兑换比率＋行使价－相关资产现价）/相关资产现价×100
    // 认沽证的溢价＝（认股证现价×兑换比率－行使价＋相关资产现价）/相关资产现价×100
  end;

  THSHKStockRealTime = packed record
    m_lOpen: LongInt; // 今开盘
    m_lMaxPrice: LongInt; // 最高价
    m_lMinPrice: LongInt; // 最低价
    m_lNewPrice: LongInt; // 最新成交价

    m_lTotal: ULONG; // 当前总成交量（股）
    m_fAvgPrice: Single; // 当前总成交金额(元)

    m_lBuyPrice: LongInt; // 最优买价  //买1价：可以由买1价来技术2，3，4，5买价，由客户端计算并显示
    m_lBuySpread: LongInt; // 买价差
    m_lSellPrice: LongInt; // 最优卖价  //卖1价：可以由卖1价来技术2，3，4，5卖价，由客户端计算并显示
    m_lSellSpread: LongInt; // 卖价差

    m_lBuyCount1: LongInt; // 买一量
    m_lBuyCount2: LongInt; // 买二量
    m_lBuyCount3: LongInt; // 买三量
    m_lBuyCount4: LongInt; // 买四量
    m_lBuyCount5: LongInt; // 买五量

    m_lSellCount1: LongInt; // 卖一量
    m_lSellCount2: LongInt; // 卖二量
    m_lSellCount3: LongInt; // 卖三量
    m_lSellCount4: LongInt; // 卖四量
    m_lSellCount5: LongInt; // 卖五量

    m_lHand: LongInt; // 每手股数
    m_lIEV: LongInt; // 预留
  end;

  // 没有成交额和成交均价，成交均价从m_lNominalFlat取。
  THSQHRealTime = packed record
    m_lOpen: LongInt; // 今开盘
    m_lMaxPrice: LongInt; // 最高价
    m_lMinPrice: LongInt; // 最低价
    m_lNewPrice: LongInt; // 最新价

    m_lTotal: ULONG; // 成交量(单位:合约单位)
    m_lChiCangLiang: LongInt; // 持仓量(单位:合约单位)

    m_lBuyPrice1: LongInt; // 买一价
    m_lBuyCount1: LongInt; // 买一量
    m_lSellPrice1: LongInt; // 卖一价
    m_lSellCount1: LongInt; // 卖一量

    m_lPreJieSuanPrice: LongInt; // 昨结算价

    m_lJieSuanPrice: LongInt; // 现结算价
    m_lCurrentCLOSE: LongInt; // 今收盘
    m_lHIS_HIGH: LongInt; // 史最高
    m_lHIS_LOW: LongInt; // 史最低
    m_lUPPER_LIM: LongInt; // 涨停板
    m_lLOWER_LIM: LongInt; // 跌停板

    m_nHand: LongInt; // 每手股数
    m_lPreCloseChiCang: LongInt; // 昨持仓量(单位:合约单位)

    m_llongintPositionOpen: LongInt; // 多头开(单位:合约单位)
    m_llongintPositionFlat: LongInt; // 多头平(单位:合约单位)
    m_lNominalOpen: LongInt; // 空头开(单位:合约单位)
    m_lNominalFlat: LongInt; // （成交均价）

    m_lPreClose: LongInt; // 前天收盘????
  end;

  THSWHRealTime = packed record
    m_lOpen: LongInt; // 今开盘(1/10000元)
    m_lMaxPrice: LongInt; // 最高价(1/10000元)
    m_lMinPrice: LongInt; // 最低价(1/10000元)
    m_lNewPrice: LongInt; // 最新价(1/10000元)

    m_lBuyPrice: LongInt; // 买价(1/10000元)
    m_lSellPrice: LongInt; // 卖价(1/10000元)
  end;

  THSQHRealTime_Min = packed record
    m_lOpen: LongInt; // 今开盘
    m_lMaxPrice: LongInt; // 最高价
    m_lMinPrice: LongInt; // 最低价
    m_lNewPrice: LongInt; // 最新价

    m_lTotal: ULONG; // 成交量(单位:合约单位)
    m_lChiCangLiang: LongInt; // 持仓量(单位:合约单位)

    m_lBuyPrice1: LongInt; // 买一价
    m_lBuyCount1: LongInt; // 买一量
    m_lSellPrice1: LongInt; // 卖一价
    m_lSellCount1: LongInt; // 卖一量

    m_lPreJieSuanPrice: LongInt; // 昨结算价
  end;
  // 说明：
  // 1、	信用拆借、买断式回购、质押式回购等市场的利率存储在相应的价格字段中；
  // 2、	质押式回购市场的成交量扩大100倍。

  THSIBRealTime = packed record
    m_nTradeMethodNumber: AnsiChar; // 成交方式，参看CMDS的10317字段
    m_nReserved: AnsiChar; // 预留
    m_nOption: short; // 预留
    m_lOpenPrice: long; // 今开盘
    m_lMaxPrice: long; // 最高净价
    m_lMinPrice: long; // 最低净价
    m_lNewPrice: long; // 最新净价
    m_lWeightedPrice: long; // 加权平均价
    m_lAvgPrice: long; // 净价均价
    m_lOpenRate: long; // 今开盘收益率
    m_lMaxRate: long; // 最高净价收益率
    m_lMinRate: long; // 最低净价收益率
    m_lNewRate: long; // 最新净价收益率
    m_lWeightedRate: long; // 加权平均价收益率
    m_lRise: long; // 涨幅
    m_lInterest: long; // 应计利息
    m_lCBPrice: long; // 中债估值净价
    m_lCBRate: long; // 中债估值净价收益率
    m_lCBDuration: long; // 中债估值修正久期
    m_lCBConvexity: long; // 中债估值凸性
    m_lCBBasisPointValue: long; // 中债估值基点价值

    m_lPreClosePrice: long; // 昨收盘净价
    m_lPreCloseRate: long; // 昨收盘净价收益率
    m_lPreInterest: long; // 昨应计利息
    m_llVolume: int64; // 券面总额(元)
  end;

  // 个股期权
  TOrderUnit = packed record
    price: integer; // 委托价
    qty: Single; // 委托量(单位:合约单位)
  end;

  THSOPTRealTime_Simple = packed record
    m_lOpen: LongInt; // 今开盘
    m_lMaxPrice: LongInt; // 最高价
    m_lMinPrice: LongInt; // 最低价
    m_lNewPrice: LongInt; // 最新价

    m_lJieSuanPrice: LongInt; // 现结算价
    m_lAutionPrice: LongInt; // 动态参考价

    m_lTotal: Single; // 成交量(单位:合约单位)
    m_fMoney: Single; // 总成交额

    m_lPreJieSuanPrice: LongInt; // 昨结算--以此计算涨跌幅
    m_fAutionQty: Single; // 虚拟匹配数量
    m_lTotalLongPosition: Single; // 未平仓合约数

    m_Bid: TOrderUnit; // 委买
    m_Offer: TOrderUnit; // 委卖

    m_cTradingPhase: array [0 .. 3] of Char; // 产品实施阶段标志--参考v1.03
    m_nHand: LongInt; // 合约乘数
  end;

  THSOPTRealTime = packed record
    m_lOpen: LongInt; // 今开盘
    m_lMaxPrice: LongInt; // 最高价
    m_lMinPrice: LongInt; // 最低价
    m_lNewPrice: LongInt; // 最新价

    m_lJieSuanPrice: LongInt; // 现结算价
    m_lAutionPrice: LongInt; // 动态参考价

    m_lTotal: Single; // 成交量(单位:合约单位)
    m_fMoney: Single; // 总成交额

    m_lPreJieSuanPrice: LongInt; // 昨结算--以此计算涨跌幅
    m_fAutionQty: Single; // 虚拟匹配数量
    m_lTotalLongPosition: Single; // 未平仓合约数

    m_Bid: array [0 .. 4] of TOrderUnit; // 委买
    m_Offer: array [0 .. 4] of TOrderUnit; // 委卖

    m_cTradingPhase: array [0 .. 3] of Char; // 产品实施阶段标志--参考v1.03
    m_nHand: LongInt; // 合约乘数
  end;

  // *** 美股实时 *** //
  THSUSStockRealTime = packed record
    m_lOpen: LongInt; // 今开盘
    m_lMaxPrice: LongInt; // 最高价
    m_lMinPrice: LongInt; // 最低价
    m_lNewPrice: LongInt; // 最新价
    m_lTotal: int64; // 成交量(单位:股)
    m_fMoney: Single; // 成交金额
    m_lMaxPrice52: LongInt; // 52周最高价
    m_lMinPrice52: LongInt; // 52周最低价
    m_lWeightedAveragePx: LongInt; // 加权平均价
    m_Bid: array [0 .. 0] of TOrderUnit; // 委买
    m_Offer: array [0 .. 0] of TOrderUnit; // 委卖
    m_nHand: LongInt; // 每手股数
    m_nDelayflag: short; // 是否是延迟行情，主要用于区分当前成交量和成交额是否是延时行情
    m_nTrandCond: short; // 交易情况（-1：停牌 0：盘前，1：盘中，2：盘后）
    m_ltime: LongInt; // 盘前/盘后交易时间，格式为hhmmss
    m_lPrice: LongInt; // 盘前/盘后价格
    m_lVolume: int64; // 盘前/盘后成交量
    m_lRise: LongInt; // 盘前/盘后涨跌量
    m_lRiseRatio: LongInt; // 盘前/盘后涨跌幅
  end;

  // *** 美股延时 *** //
  THSUSStockRealTimeDelay = packed record
	  m_lNewPrice: LongInt;  // 最新价
	  m_lTotalL: Int64;			 // 成交量(单位:股)
	  m_fMoney: Single;			 // 成交金额
	  m_lWeightedAveragePx: LongInt;	//加权平均价
  end;


  // 实时数据分类
  TShareRealTimeData = packed record
    case integer of
      0:
        (m_nowData: THSStockRealTime); // 个股实时基本数据
      1:
        (m_stStockData: THSStockRealTime);
      2:
        (m_indData: THSIndexRealTime); // 指数实时基本数据
      3:
        (m_hkData: THSHKStockRealTime); // 港股实时基本数据
      4:
        (m_qhData: THSQHRealTime); // 期货实时基本数据
      5:
        (m_whData: THSWHRealTime); // 外汇实时基本数据
      6:
        (m_qhMin: THSQHRealTime_Min);
      7:
        (m_HSIB: THSIBRealTime); // 银行间证券实时基本数据.
//      8:
//        (m_OPTData: THSOPTRealTime); // 个股期权。这个没有用到，所以之前没有定义，为了和TShareRealTimeData_Ext的结构统一，所以定义了这个
      9:
        (m_USData: THSUSStockRealTime); // 美股实时基本数据
      10:
        (m_USDelayData: THSUSStockRealTimeDelay); // 美股延时数据
    // ghm add level2
    // LevelRealTimem_levelNowData;// 个股level2实时数据
  end;

  // 请求类型: RT_REALTIME
  // 功能说明: 行情报价表--1-6乾隆操作键
  // 备  注:
  // */
  /// * 请求结构 : 常用请求*/
  /// * 行情报价表数据项 */
  PCommRealTimeData = ^TCommRealTimeData;

  TCommRealTimeData = packed record
    m_ciStockCode: TCodeInfo; // 股票代码
    m_othData: TStockOtherData; // 实时其它数据
    m_cNowData: TShareRealTimeData; // 指向ShareRealTimeData的任意一个
  end;

  /// * 返回结构 */
  PAnsRealTime = ^TAnsRealTime;

  TAnsRealTime = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: short; // 报价表数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_pnowData: array [0 .. 0] of TCommRealTimeData; // 报价表数据
  end;

  PAnsHSAutoPushData = ^TAnsHSAutoPushData;

  TAnsHSAutoPushData = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: LongInt; // 报价表数据个数
    m_pnowData: array [0 .. 0] of TCommRealTimeData; // 报价表数据
  end;

  PPriceVolItem = ^TPriceVolItem;

  TPriceVolItem = packed record
    m_lNewPrice: LongInt; // 最新价
    m_lTotal: ULONG; // 成交量(在外汇时，是跳动量)
  end;

  TPriceVolItems = array [0 .. MaxCount] of TPriceVolItem;
  PPriceVolItems = ^TPriceVolItems;
  /// *
  // 请求类型: RT_TREND_EXT
  // 功能说明: 分时走势
  // 备	  注:
  // */
  /// *请求结构：常用请求AskData */
  /// *返回结构*/

  PAnsTrendData = ^TAnsTrendData;

  TAnsTrendData = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nHisLen: short; // 分时数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_othData: TStockOtherData;
    m_cNowData: TShareRealTimeData; // 指向ShareRealTimeData的任意一个
    m_pHisData: array [0 .. 0] of TPriceVolItem; // 历史分时数据
  end;

  // 集合竞价分时数据
  PStockVirtualAuction = ^TStockVirtualAuction;

  TStockVirtualAuction = packed record
    m_lTime: LongInt; // 虚拟匹配的时间，格式为hhmmssxxx
    m_lPrice: LongInt; // 虚拟匹配价格
    m_fQty: Single; // 虚拟匹配量
    m_fQtyLeft: Single; // 虚拟未匹配量；如果为正数，表示委买的未匹配量；如果为负数，表示委卖的未匹配量
  end;

  /// *
  // 请求类型: RT_VIRTUAL_AUCTION
  // 功能说明: 集合竞价数据
  // */
  /// /请求结构：常用请求 AskData
  /// /返回结构：集合竞价返回包
  ///
  PAnsVirtualAuction = ^TAnsVirtualAuction;

  TAnsVirtualAuction = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: long; // 虚拟竞价匹配的次数，如果该股票没有匹配，则，该值为0；
    m_vaData: array [0 .. 0] of TStockVirtualAuction; // 每次虚拟竞价的详细信息
  end;

  /// *
  // 请求类型: RT_STOCKTICK
  // 功能说明: 个股分笔、个股详细的分笔数据
  // */
  /// /请求结构：常用请求 AskData
  /// /返回结构：个股分笔返回包
  ///
  TStockTickDetailTime = packed record
    m_nBuyOrSell: AnsiChar;
    m_nSecond: AnsiChar;
  end;

  TStockTick_Buy = packed record
    case integer of
      0:
        (m_nBuyOrSellOld: short); // 旧的，保留
      1:
        (m_nBuyOrSell: AnsiChar); // 是按价成交还是按卖价成交(1 按买价 0 按卖价)
      2:
        (m_sDetailTime: TStockTickDetailTime); // 包含秒数据
  end;

  // 分笔记录
  PStockTick = ^TStockTick;

  TStockTick = packed record
    m_nTime: short; // 当前时间（距开盘分钟数）
    m_Buy: TStockTick_Buy;
    m_lNewPrice: LongInt; // 成交价
    m_lCurrent: ULONG; // 成交量
    m_lBuyPrice: LongInt; // 委买价
    m_lSellPrice: LongInt; // 委卖价
    m_nChiCangLiang: ULONG; // 持仓量,深交所股票单笔成交数,港股成交盘分类(Y,M,X等，根据数据源再确定）
  end;

  TStockTicks = array [0 .. MaxCount] of TStockTick;
  PStockTicks = ^TStockTicks;

  PAnsStockTick = ^TAnsStockTick;

  TAnsStockTick = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: LongInt; // 数据个数
    m_traData: Array [0 .. 0] of TStockTick; // 分笔数据
  end;

  // /*
  // 请求类型: RT_CURRENTFINANCEDATA
  // 功能说明: 最新的财务数据
  // */
  /// * 请求结构 */
  ///
  PReqCurrentFinanceData = ^TReqCurrentFinanceData;

  TReqCurrentFinanceData = packed record
    m_lLastDate: LongInt; // 最新日期
  end;

  /// * 返回结构 */
  PCurrentFinanceData = ^TCurrentFinanceData;

  TCurrentFinanceData = packed record
    m_ciStockCode: TCodeInfo; // 股票代码
    m_nDate: integer; // 日期
    m_fFinanceData: array [0 .. 38] of Single; // 数据项
  end;

  PAnsCurrentFinance = ^TAnsCurrentFinance;

  TAnsCurrentFinance = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: short; // 后续数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_sFinanceData: array [0 .. 0] of TCurrentFinanceData; // 财务数据
  end;

  /// *
  // 请求类型: RT_HISFINANCEDATA
  // 功能说明: 历史财务数据
  // 请求结构: 常用请求:AskData
  // */
  /// *返回结构*/
  PHisFinanceData = ^THisFinanceData;

  THisFinanceData = packed record
    m_nDate: integer; // 日期
    m_fFinanceData: array [0 .. 38] of Single; // 数据项
  end;

  PAnsHisFinance = ^TAnsHisFinance;

  TAnsHisFinance = packed record
    m_dhHead: TDataHead; // 数据报头

    m_nSize: short; // 后续数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_sFinanceData: array [0 .. 0] of THisFinanceData; // 财务数据
  end;

  /// *
  // 请求类型: RT_FILEDOWNLOAD
  //
  // 功能说明:
  // 用于文件的请求与应答，目前主要用于数据下载
  // */
  /// *请求结构*/

  PReqFileTransferData = ^TReqFileTransferData;

  TReqFileTransferData = packed record // 正序索引和文件请求
    m_lCRC: LongInt; // ＣＲＣ值，校验全部文件内容
    m_lOffsetPos: LongInt; // 文件的偏移（字节）
    m_lCheckCRC: LongInt; // 是否进行校验ＣＲＣ　非０进行校验，０则不校验，
    m_cFilePath: array [0 .. 255] of AnsiChar; // 文件名/路径
  end;
  // 路径中具有"$ml30"字串时，服务器以钱龙数据的绝对路径替换

  PAnsFileTransferData = ^TAnsFileTransferData;

  TAnsFileTransferData = packed record // 正序索引和文件请求
    m_dhHead: TDataHead; // 数据包头
    m_lCRC: LongInt; // ＣＲＣ值
    m_nSize: ULONG; // 数据长度
    m_cData: array [0 .. 0] of AnsiChar; // 数据
  end;

  PReqFileTransferData2 = ^TReqFileTransferData2;

  TReqFileTransferData2 = packed record // 正序索引和文件请求
    m_nType: short; // 类别,参见SrvFileType定义
    m_nReserve: short;
    m_lCRC: LongInt; // ＣＲＣ值，校验全部文件内容
    m_lOffsetPos: LongInt; // 文件的偏移（字节）
    m_lCheckCRC: LongInt; // 是否进行校验ＣＲＣ　非０进行校验，０则不校验，
    m_cFilePath: array [0 .. 255] of AnsiChar; // 文件名/路径
    // 路径中具有"$ml30"字串时，服务器以钱龙数据的绝对路径替换
  end;

  /// *
  // 请求类型: RT_BUYSELLPOWER
  // 功能说明: 买卖力道
  // 备  注:
  // */
  /// *请求结构：常用请求AskData */
  //
  /// *返回结构 */
  /// * 买卖力道数据项 */

  PBuySellPowerData = ^TBuySellPowerData;

  TBuySellPowerData = packed record
    m_lBuyCount: LongInt; // 买量
    m_lSellCount: LongInt; // 卖量
  end;

  PAnsBuySellPower = ^TAnsBuySellPower;

  TAnsBuySellPower = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nHisLen: short; // 买卖数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_pHisData: array [0 .. 0] of TBuySellPowerData; // 买卖数据
  end;

  /// *
  // 请求类型: RT_BUYSELLORDER
  // 功能说明: 个股买卖盘
  // */

  // 请求结构：
  PReqBuySellOrder = ^TReqBuySellOrder;

  TReqBuySellOrder = packed record // 个股买卖盘请求包
    m_pCode: TCodeInfo; // 代码
    m_nOffsetSize: short; // m_nOffsetSize = -1全部返回; m_nOffsetSize >= 0倒叙的起始位置
    m_nCount: short; // 需要返回的长度
    m_lDate: LongInt; // 日期,格式:19990101,
  end;

  // 返回结构：
  PBuySellOrderData = ^TBuySellOrderData;

  TBuySellOrderData = packed record
    m_nTime: short; // 现在时间
    m_nHand: short; // 股/手
    m_lCurrent: ULONG; // 现在总手
    m_lNewPrice: LongInt; // 最新价
    m_lPrevClose: LongInt; // 昨收盘
    m_lBuyPrice1: LongInt; // 买一价
    m_lBuyCount1: LongInt; // 买一量
    m_lBuyPrice2: LongInt; // 买二价
    m_lBuyCount2: LongInt; // 买二量
    m_lBuyPrice3: LongInt; // 买三价
    m_lBuyCount3: LongInt; // 买三量
    m_lBuyPrice4: LongInt; // 买四价
    m_lBuyCount4: LongInt; // 买四量
    m_lBuyPrice5: LongInt; // 买五价
    m_lBuyCount5: LongInt; // 买五量

    m_lSellPrice1: LongInt; // 卖一价
    m_lSellCount1: LongInt; // 卖一量
    m_lSellPrice2: LongInt; // 卖二价
    m_lSellCount2: LongInt; // 卖二量
    m_lSellPrice3: LongInt; // 卖三价
    m_lSellCount3: LongInt; // 卖三量
    m_lSellPrice4: LongInt; // 卖四价
    m_lSellCount4: LongInt; // 卖四量
    m_lSellPrice5: LongInt; // 卖五价
    m_lSellCount5: LongInt; // 卖五量
  end;

  PAnsBuySellOrder = ^TAnsBuySellOrder;

  TAnsBuySellOrder = packed record
    m_dhHead: TDataHead; // 数据报头

    m_nOffsetSize: short; // 对应请求包
    m_nCount: short; // 对应请求包
    m_lDate: LongInt; // 日期,格式:19990101

    m_nSize: LongInt; // 数据个数
    // short  m_nAlignment;// 为了4字节对齐而添加的字段
    m_sBuySellOrderData: array [0 .. 0] of TBuySellOrderData; // 买卖盘数据
  end;

  // 返回结构：同分笔结构

  /// *
  // 请求类型: RT_MAJORINDEXTICK
  // 功能说明: 大盘明细
  // 请求结构：常用请求 AskData
  // */
  // 返回结构：
  PMajorIndexItem = ^TMajorIndexItem;

  TMajorIndexItem = packed record
    m_lNewPrice: LongInt; // 最新价（指数）
    m_lTotal: ULONG; // 成交量
    m_fAvgPrice: Single; // 成交额
    m_nRiseCount: short; // 上涨家数
    m_nFallCount: short; // 下跌家数
  end;

  PAnsMajorIndexTick = ^TAnsMajorIndexTick;

  TAnsMajorIndexTick = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: short; // 数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_ntrData: array [0 .. 0] of TMajorIndexItem; // 大盘一分钟成交明细
  end;

  /// *
  // 请求类型: RT_LEAD
  // 功能说明: 大盘领先指标
  // 请求结构: 常用请求AskData
  // */
  // 返回结构：
  PStockLeadData = ^TStockLeadData;

  TStockLeadData = packed record
    m_lNewPrice: LongInt; // 最新价(指数)
    m_lTotal: ULONG; // 成交量
    m_nLead: short; // 领先指标
    m_nRiseTrend: short; // 上涨趋势
    m_nFallTrend: short; // 下跌趋势
    m_nAlignment: short; // 为了4字节对齐而添加的字段
  end;

  PAnsLeadData = ^TAnsLeadData;

  TAnsLeadData = packed record
    m_dhHead: TDataHead; // 数据头
    m_indData: THSIndexRealTime; // 指数实时数据

    m_nHisLen: short; // 领先数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_pHisData: array [0 .. 0] of TStockLeadData; // 领先数据
  end;

  // /*
  // 请求类型: RT_MAJORINDEXTREND
  // 功能说明: 大盘走势
  // 请求结构: 常用请求AskData
  // */
  /// *返回结构*/

  PAnsMajorIndexTrend = ^TAnsMajorIndexTrend;

  TAnsMajorIndexTrend = packed record
    m_dhHead: TDataHead; // 数据头
    m_indData: THSIndexRealTime; // 上证30或深证指数NOW数据

    m_nHisLen: short; // 领先数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_pHisData: array [0 .. 0] of TPriceVolItem; // 分时数据 见说明
  end;

  //
  // /*
  // 请求类型: RT_MAJORINDEXADL
  // 功能说明: 大盘ADL
  // 请求结构: 常用请求AskData
  // */
  /// *返回结构：
  // 说明:
  // 返回包为AnsMajorIndexTrend，使用此结构代替AnsMajorIndexTrend结构
  // m_pHisData[1];一项
  // */
  PADLItem = ^TADLItem;

  TADLItem = packed record

    m_lNewPrice: LongInt; // 指数
    m_lTotal: ULONG; // 成交量
    m_lADL: LongInt; // ADL值（算法:ADL = （上涨家数 - 下跌家数）累计值）
  end;

  /// *
  // 请求类型: RT_MAJORINDEXBBI
  // 功能说明: 大盘多空指标BBI
  // 请求结构: 常用请求AskData
  // */
  /// *返回结构：
  // 说明:
  // 返回包为AnsMajorIndexTrend，使用此结构代替AnsMajorIndexTrend结构m_pHisData[1];一项
  // */
  PLeadItem = ^TLeadItem;

  TLeadItem = packed record
    m_lNewPrice: LongInt; // 最新价（指数）
    m_lTotal: ULONG; // 成交量

    m_nLead: short; // 领先指标
    m_nRiseTrend: short; // 上涨趋势
    m_nFallTrend: short; // 下跌趋势
    m_nAlignment: short; // 为了4字节对齐而添加的字段
  end;

  /// *
  // 请求类型: RT_MAJORINDEXBUYSELL
  // 功能说明: 大盘买卖力道
  // 请求结构: 常用请求AskData
  // */
  /// *返回结构：
  // 返回包为AnsMajorIndexTrend，使用此结构代替AnsMajorIndexTrend结构
  // m_pHisData[1];一项
  // */
  PMajorIndexBuySellPowerItem = ^TMajorIndexBuySellPowerItem;

  TMajorIndexBuySellPowerItem = packed record
    m_lNewPrice: LongInt; // 最新价
    m_lTotal: ULONG; // 成交量
    m_lBuyCount: LongInt; // 买量
    m_lSellCount: LongInt; // 卖量
  end;

  //
  /// *请求类型: RT_VALUE
  // 功能:请求与应答显示于客户端右小图“值”的数据(股票)
  // */
  // 请求结构：常用请求
  // 返回结构：
  TCalcData_Share = packed record // 股票计算
    m_lMa10: LongInt; // 10天，20天，50天收盘均价
    m_lMa20: LongInt;
    m_lMa50: LongInt;
    m_lMonthMax: LongInt; // 月最高最低
    m_lMonthMin: LongInt;
    m_lYearMax: LongInt; // 年最高最低
    m_lYearMin: LongInt;
    m_lHisAmplitude: LongInt; // 历史波幅(使用时除1000为百分比数）
  end;

  PAnsValueData = ^TAnsValueData;

  TAnsValueData = packed record
    m_dhHead: TDataHead; // 数据报头

    m_nTime: LongInt; // 时间，距离开盘分钟数
    m_lTotal: ULONG; // 总手
    m_fAvgPrice: Single; // 总金额
    m_lNewPrice: LongInt; // 最新价
    m_lTickCount: LongInt; // 成交笔数
    case integer of
      0:
        (m_lMa10: LongInt; // 10天，20天，50天收盘均价
          m_lMa20: LongInt;
          m_lMa50: LongInt;
          m_lMonthMax: LongInt; // 月最高最低
          m_lMonthMin: LongInt;
          m_lYearMax: LongInt; // 年最高最低
          m_lYearMin: LongInt;
          m_lHisAmplitude: LongInt; // 历史波幅(使用时除1000为百分比数）
        );
      1:
        (m_Share: TCalcData_Share)
  end;

  // 倒序资讯索引和资讯内容数据项
  TTextMarkData = packed record
    m_lCRC: LongInt; // ＣＲＣ值
    m_lBeginPos: LongInt; // 开始位置，直接针对索引文件或内容文件的偏移（字节）
    m_lEndPos: LongInt; // 终止位置,同上,参见说明
    m_lCheckCRC: LongInt; // 是否进行校验ＣＲＣ　非０进行校验，０则不校验，
    // *指向字串,客户端使用,字串格式为: aa;bb;cc;dd
    // 其中aa为:
    // #define INFO_PATH_KEY_F10 "F10-%i"
    // #define INFO_PATH_KEY_TREND "TREND-%i"
    // #define INFO_PATH_KEY_TECH "TECH-%i"
    // #define INFO_PATH_KEY_REPORT "REPORT-%i"
    // 其中bb为: 配置的段名
    // 其中cc为: 配置的取值名
    // 其中dd为: 配置文件名*/
    m_szInfoCfg: array [0 .. 127] of AnsiChar; // 包含配置文件名称等信息的字符串，客户端使用
    m_cTitle: array [0 .. 63] of AnsiChar; // 标题,客户端本地使用
    m_cFilePath: array [0 .. 191] of AnsiChar; // 文件名/路径
  end;

  // 请求结构
  PReqTextData = ^TReqTextData;

  TReqTextData = packed record // 索引和内容请求包
    m_sMarkData: TTextMarkData; // 校验数据项
  end;

  // 返回结构
  PAnsTextData = ^TAnsTextData;

  TAnsTextData = packed record // 详细文本信息返回
    m_dhHead: TDataHead; // 数据报头
    m_sMarkData: TTextMarkData; // 索引和内容
    m_nSize: ULONG; // 数据长度
    m_cData: array [0 .. 0] of AnsiChar; // 数据
  end;

  //
  // 请求类型: RT_TECHDATA / RT_TECHDATA_EX
  // 功能说明: 盘后分析
  // */
  //
  /// *请求结构*/
  PReqDayData = ^TReqDayData;

  TReqDayData = packed record
    m_nPeriodNum: short; // 周期长度,服务器不用
    m_nSize: USHORT; // 本地数据当前已经读取数据起始个数,服务器不用
    m_lBeginPosition: LongInt; // 起始个数，0 表示当前位置。 （服务器端已经返回的个数）
    m_nDay: USHORT; // 申请的个数
    m_cPeriod: short; // 周期类型
    m_ciCode: TCodeInfo; // 申请的股票代码
  end;

  // 针对RT_TECHDATA_EX请求返回
  PStockCompDayDataEx = ^TStockCompDayDataEx;

  TStockCompDayDataEx = packed record
    m_lDate: ULONG; // 日期
    m_lOpenPrice: LongInt; // 开
    m_lMaxPrice: LongInt; // 高
    m_lMinPrice: LongInt; // 低
    m_lClosePrice: LongInt; // 收
    m_lMoney: ULONG; // 成交金额（单位千元）
    m_lTotal: ULONG; // 成交量
    m_lNationalDebtRatio: LongInt; // 国债利率(单位为0.1分),基金净值(单位为0.1分), 无意义时，须将其设为0 2004年2月26日加入
  end;

  TStockCompDayDataExs = array [0 .. MaxCount] of TStockCompDayDataEx;
  PStockCompDayDataExs = ^TStockCompDayDataExs;

  PAnsDayDataEx = ^TAnsDayDataEx;

  TAnsDayDataEx = packed record
    m_dhHead: TDataHead; // 数据头
    m_nSize: LongInt; // 日线数据个数
    m_sdData: array [0 .. 0] of TStockCompDayDataEx; // 日线数据
  end;

  /// *
  // 请求类型: RT_HISTREND
  // 功能说明: 历史回忆、多日分时、右小图下分时走势
  // 备  注:
  // */
  /// *请求结构*/
  PReqHisTrend = ^TReqHisTrend;

  TReqHisTrend = packed record
    m_ciStockCode: TCodeInfo; // 股票代码
    m_lDate: LongInt; // 日期 见RT_HISTREND说明1
  end;

  // 历史分时走势数据
  TStockHistoryTrendHead = packed record
    m_lDate: LongInt; // 日期
    m_lPrevClose: LongInt; // 昨收
    m_Data: TShareRealTimeData;
    m_nSize: short; // 每天数据总个数
    m_nAlignment: short; // 对齐用
  end;

  // 历史分时1分钟数据
  PStockCompHistoryData = ^TStockCompHistoryData;

  TStockCompHistoryData = packed record
    m_lNewPrice: LongInt; // 最新价
    m_lTotal: ULONG;
    /// * 成交量 //对于股票(单位:股)
    m_fAvgPrice: Single;
    /// *成交金额 */
    m_lBuyCount: LongInt; // 委买量
    m_lSellCount: LongInt; // 委卖量
  end;

  /// *
  // RT_HISTREND说明1:
  // m_lDate：
  // 如为正数则指具体日期,格式如20030701
  // 如为负数则倒推m_lDate天数的当天分时走势（如-10则返回倒数第10天的）
  // 如等于0,为当天
  // */
  PHisTrendData = ^THisTrendData;

  THisTrendData = packed record
    m_shHead: TStockHistoryTrendHead; // 历史分时走势数据(2004年6月23日 改动处 结构不同）
    m_shData: array [0 .. 0] of TStockCompHistoryData; // 分钟历史数据
  end;

  /// *返回结构*/
  PAnsHisTrend = ^TAnsHisTrend;

  TAnsHisTrend = packed record
    m_dhHead: TDataHead; // 数据报头
    m_shTend: THisTrendData; // 分时数据
  end;

  PReqBlockData = ^TReqBlockData;

  TReqBlockData = packed record
    m_lLastDate: LongInt; // 最新日期
  end;

  PReqExRightData = ^TReqExRightData;

  TReqExRightData = packed record
    m_lLastDate: LongInt; // 最新日期
  end;

  // 返回结构：
  PAnsExRightData = ^TAnsExRightData;

  TAnsExRightData = packed record

    m_dhHead: TDataHead; // 数据报头
    m_nSize: LongInt; // 后续数据流长度
    m_cData: array [0 .. 0] of AnsiChar; // 除权数据流，格式同文件，参见：除权文件结构
  end;

  PHSExRight = ^THSExRight;

  THSExRight = packed record
    m_CodeInfo: TCodeInfo;
    m_lLastDate: LongInt; // 最新日期
    m_lCount: LongInt; // 参考使用
  end;

  // 除权数据结构
  PHSExRightItem = ^THSExRightItem;

  THSExRightItem = packed record
    m_nTime: integer; // 时间
    m_fGivingStock: Single; // 送股
    m_fPlacingStock: Single; // 配股
    m_fGivingPrice: Single; // 送股价
    m_fBonus: Single; // 分红
  end;

  /// *
  // 说明 : 精简主推（当前适用于指数）
  // 类型 : RT_AUTOPUSHSIMP
  // */
  /// *请求结构*/
  /// / 常用请求包
  //
  /// *返回结构*/
  TSimplifyIndexNowData = packed record // 指标类精简主推
    m_lNewPrice: LongInt; // 最新价
    m_lTotal: ULONG; // 成交量
    m_fAvgPrice: Single; // 成交金额

    m_nRiseCount: short; // 上涨家数
    m_nFallCount: short; // 下跌家数
    m_nLead: short; // 领先指标
    m_nRiseTrend: short; // 上涨趋势
    m_nFallTrend: short; // 下跌趋势
    m_nTotalStock2: short; // 对于综合指数：A股 + B股
  end;

  PSimplifyStockItem = ^TSimplifyStockItem;

  TSimplifyStockItem = packed record
    m_ciStockCode: TCodeInfo; // 股票代码
    m_sSimplifyIndexNowData: TSimplifyIndexNowData; // 数据
  end;

  PAnsSimplifyAutoPushData = ^TAnsSimplifyAutoPushData;

  TAnsSimplifyAutoPushData = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: short; // 数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_pstData: array [0 .. 0] of TSimplifyStockItem; // 主机实时发送的数据
  end;

  /// *
  // 说明: 常用主推  （在客户端适用于所有页面）
  // 类型: RT_AUTOPUSH
  //
  // 说明: 请求主推，目前用于预警
  // 类型: RT_REQAUTOPUSH
  // */
  /// *返回结构*/


  // 请求类型: RT_LIMITTICK
  // 功能说明: 指定长度的分笔请求

  // 请求结构：
  PReqLimitTick = ^TReqLimitTick;

  TReqLimitTick = packed record
    m_pCode: TCodeInfo; // 代码
    m_nCount: short; // 需要返回的长度
    m_nAlignment: short; // 为了4字节对齐而添加的字段
  end;

  // RT_KEEPACTIVE说明 BEGIN
  // 说明：保活通信
  // 类型：RT_KEEPACTIVE
  // 请求结构:
  PReqKeepActive = ^TReqKeepActive;

  TReqKeepActive = packed record
    m_nType: USHORT; // 请求类型，与请求数据包一致

    m_nIndex: WORD; // 请求索引，与请求数据包一致
    m_cOperator: WORD; // 操作（0：清空 1:不清空)
  end;

  // 返回结构
  PAnsKeepActive = ^TAnsKeepActive;

  TAnsKeepActive = packed record
    m_nType: USHORT; // 请求类型，与请求数据包一致
    m_nIndex: AnsiChar; // 请求索引，与请求数据包一致
    m_cOperator: AnsiChar; // 操作（0：清空 1:不清空)
    m_nDateTime: integer; // 当前时间(time_t,从1970/1/1 0:0:0开始的秒计数)
  end;

  /// *
  // RT_REPORTSORT说明1:
  // m_cCodeType有以下几种分类：
  // 1、	标准分类：上A、深A
  // m_nSize = 0，m_sAnyReportData不指向任何东西
  // 2、	系统板块：SysBK_Bourse -- 当前版本暂时不支持验证板块。
  // m_sAnyReportData指向ReqOneBlock
  // 板块文件采用配置文件＋单个文件方式，客户端请求时将板块CRC校验码发送给服务器，服务器	将服务器板块CRC与客户端板块CRC进行检查，如果两者不匹配，则发送系统板块压缩数据包；然后发送报价数据，否则直接发送报价数据。
  // 3、	自选股和自定义板块：UserDefBk_Bourse
  // m_sAnyReportData指向AnyReportData
  // */
  //
  // #define BLOCK_NAME_LENGTH		32			// 板块名称长度
  /// * 请求结构 单个板块请求*/
  PReqOneBlock = ^TReqOneBlock;

  TReqOneBlock = packed record
    m_lCRC: LongInt; // 板块CRC
    m_szBlockName: array [0 .. BLOCK_NAME_LENGTH - 1] of AnsiChar; // 板块名
  end;

  PAnyReportData = ^TAnyReportData;

  TAnyReportData = packed record
    m_ciStockCode: TCodeInfo; // 股票代码
  end;

  TAnyReportDatas = array [0 .. MaxCount] of TAnyReportData;
  PAnyReportDatas = ^TAnyReportDatas;

  PReqAnyReport = ^TReqAnyReport;

  TReqAnyReport = packed record
    m_cCodeType: HSMarketDataType; // 类别，见RT_REPORTSORT说明1
    m_nBegin: short; // 显示开始
    m_nCount: short; // 显示个数
    m_bAscending: Byte; // 升序/降序
    m_cAlignment: AnsiChar; // 为了4字节对齐而添加的字段
    m_nColID: integer; // 排名列id
    m_nSize: short; // 个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    // m_sAnyReportData: TAnyReportData; //客户端给参考数据给服务器端  见RT_REPORTSORT说明1*/
  end;

  // 说明:
  // 1。服务器收到RT_KEEPACTIVE请求时，如果应答缓冲区中有返回数据，则可不处理此包，不用返回。
  // 2。服务器收到此包时，不可按通用请求的方式处理，即收到此请求时不清应答或请求缓冲区。
  // RT_KEEPACTIVE说明 END

  // RT_SEVER_EMPTY
  // 服务器没有数据时返回空包情况，一般日线无数据时
  PAnsSeverEmpty = ^TAnsSeverEmpty;

  TAnsSeverEmpty = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nOldType: USHORT; // 数据请求类型
    m_nAlignment: USHORT; //
    m_nSize: integer;
    m_cData: array [0 .. 0] of AnsiChar;
  end;

  // 财务数据
  // 1   总股本       2   国家股    3   发起人法人股 4   法人股     5   B股        6   H股       7   流通A股
  // 8   职工股       9   A2转配股  10  总资产股     11  流动资产   12  固定资产   13  无形资产
  // 14  长期投资     15  流动负债  16  长期负债     17  资本公积金 18  每股公积金 19  股东权益
  // 20	主营收入     21	主营利润   22	其他利润      23	营业利润   24	投资收益    25	补贴收入   26	营业外收支
  // 27	上年损益调整 28	利润总额   29	税后利润      30	净利润     31	未分配利润   32	每股未分配
  // 33	每股收益     34	每股净资产 35	调整每股净资  36	股东权益比 37	净资收益率

  PFinanceInfo = ^TFinanceInfo;

  TFinanceInfo = packed Record
    m_cAType: Array [0 .. 1] of AnsiChar;
    m_cAUnknow: Array [0 .. 1] of AnsiChar;
    m_cCode: Array [0 .. 5] of AnsiChar;
    m_fFinanceData: array [0 .. 38] of Single; // 数据项
  end;

  PExRight = ^TExRight;

  TExRight = packed Record
    m_cAType: Array [0 .. 1] of AnsiChar;
    m_cACode: Array [0 .. 5] of AnsiChar;
    m_cAUnknow: Array [0 .. 1] of integer;
  end;

  PExRightItem = ^TExRightItem;

  TExRightItem = packed Record
    m_nTime: integer;
    m_fSg: Single;
    m_fPg: Single;
    m_fPgPrice: Single;
    m_fGive: Single;
  end;

  // Level 2 行情数据
  PLevelRealTime = ^TLevelRealTime;

  TLevelRealTime = packed record
    m_lOpen: LongInt; // 开
    m_lMaxPrice: LongInt; // 高
    m_lMinPrice: LongInt; // 低
    m_lNewPrice: LongInt; // 新
    m_lTotal: ULONG; // 成交量
    m_fAvgPrice: Single; // 6成交额(单位: 百元)

    m_lBuyPrice1: LongInt; // 买一价
    m_lBuyCount1: ULONG; // 买一量
    m_lBuyPrice2: LongInt; // 买二价
    m_lBuyCount2: ULONG; // 买二量
    m_lBuyPrice3: LongInt; // 买三价
    m_lBuyCount3: ULONG; // 买三量
    m_lBuyPrice4: LongInt; // 买四价
    m_lBuyCount4: ULONG; // 买四量
    m_lBuyPrice5: LongInt; // 买五价
    m_lBuyCount5: ULONG; // 买五量

    m_lSellPrice1: LongInt; // 卖一价
    m_lSellCount1: ULONG; // 卖一量
    m_lSellPrice2: LongInt; // 卖二价
    m_lSellCount2: ULONG; // 卖二量
    m_lSellPrice3: LongInt; // 卖三价
    m_lSellCount3: ULONG; // 卖三量
    m_lSellPrice4: LongInt; // 卖四价
    m_lSellCount4: ULONG; // 卖四量
    m_lSellPrice5: LongInt; // 卖五价
    m_lSellCount5: ULONG; // 卖五量

    m_lBuyPrice6: LongInt; // 买六价
    m_lBuyCount6: ULONG; // 买六量
    m_lBuyPrice7: LongInt; // 买七价
    m_lBuyCount7: ULONG; // 买七量
    m_lBuyPrice8: LongInt; // 买八价
    m_lBuyCount8: ULONG; // 买八量
    m_lBuyPrice9: LongInt; // 买九价
    m_lBuyCount9: ULONG; // 买九量
    m_lBuyPrice10: LongInt; // 买十价
    m_lBuyCount10: ULONG; // 买十量

    m_lSellPrice6: LongInt; // 卖六价
    m_lSellCount6: ULONG; // 卖六量
    m_lSellPrice7: LongInt; // 卖七价
    m_lSellCount7: ULONG; // 卖七量
    m_lSellPrice8: LongInt; // 卖八价
    m_lSellCount8: ULONG; // 卖八量
    m_lSellPrice9: LongInt; // 卖九价
    m_lSellCount9: ULONG; // 卖九量
    m_lSellPrice10: LongInt; // 卖十价
    m_lSellCount10: ULONG; // 卖十量

    m_lTickCount: ULONG; // 成交笔数

    m_fBuyTotal: Single; // 委托买入总量
    WeightedAvgBidPx: Single; // 加权平均委买价格
    AltWeightedAvgBidPx: Single;

    m_fSellTotal: Single; // 委托卖出总量
    WeightedAvgOfferPx: Single; // 加权平均委卖价格
    AltWeightedAvgOfferPx: Single;

    m_IPOVETFIPOV: Single; //

    m_Time: ULONG; // 时间戳
  end;

  // 各股票Level2其他数据
  TLevelStockOtherData = packed record
    m_nTime: Record
    case integer of 0: (m_nTimeOld: ULONG); // 现在时间
      1: (m_nTime: USHORT); // 现在时间
      2: (m_sDetailTime: TStockOtherDataDetailTime);
    end;

    m_lCurrent: ULONG; // 现在总手
    m_lOutside: ULONG; // 外盘
    m_lInside: ULONG; // 内盘

    m_KaiPre: Record
    case integer of
      0:
        (m_lKaiCang: ULONG); // 今开仓,深交所股票单笔成交数,港股交易宗数
      1:
        (m_lPreClose: ULONG); // 对于外汇时，昨收盘数据
    end;

    status: Record
    case integer of
      0:
        (m_rate_status: ULONG); // 对于外汇时，报价状态
      // 对于股票，信息状态标志,
      // MAKELONG(MAKEWORD(nStatus1,nStatus2),MAKEWORD(nStatus3,nStatus4))
      1:
        (m_lPingCang: ULONG); // 今平仓
    end;
  end;

  PReqReportSort = ^TReqReportSort;

  TReqReportSort = packed record
    m_nBegin: short; // 显示开始
    m_nCount: short; // 显示个数
    m_bAscending: Byte; // 升序/降序  1：升序 0：降序
    m_nColID: integer; // 排名列id
  end;

  PRealTimeDataLevel = ^TRealTimeDataLevel;

  TRealTimeDataLevel = packed record
    m_ciStockCode: TCodeInfo; // 代码
    m_othData: TLevelStockOtherData; // 实时其它数据
    m_sLevelRealTime: TLevelRealTime; //
  end;

  THSStockRealTimeOther = packed record
    m_lExt1: LongInt; // 目前只在ETF时有用，为其IOPV值（例如510050时为510051的最新价）
    m_lStopFlag: LongInt; // 停盘标志。0：正常，1：长停盘 2：暂停
    // case integer of
    m_fSpeedUp: Single; // 五分钟涨速
    m_lRes: array [0 .. 1] of LongInt; // 预留
    // m_lOther: array[0..2] of LongInt;	// 预留
    // end;
  end;

  THKBSOrder = packed record
    m_lBuyCount: array [0 .. 4] of LongInt; // 买6~买10量
    m_lSellCount: array [0 .. 4] of LongInt; // 卖6~卖10量
  end;

  THSHKStockRealTime_Ext = packed record
    m_baseReal: THSHKStockRealTime; // 5档基本实时
    m_extBuySell: THKBSOrder; // 5档扩展委托量（包含买/卖方向）
  end;

  // 扩展指数市场实时扩展数据
  THSIndexRealTimeOther = packed record
    m_szRiseCode: array [0 .. 7] of AnsiChar; // 领涨代码
    m_szFallCode: array [0 .. 7] of AnsiChar; // 领跌代码
    m_szClassifiedCode: array [0 .. 7] of AnsiChar; // 指数分级编码，目前不知有什么用途，暂时这样
    m_lRise: LongInt; // 领涨代码涨幅
    m_lFall: LongInt; // 领跌代码跌幅
  end;

  // 股票实时数据扩展
  THSStockRealTime_Ext = packed record
    m_cSize: USHORT; // 结构体长度
    m_nVersion: USHORT; // 版本号
    m_stockRealTime: THSStockRealTime; // 实时数据
    m_stockOther: THSStockRealTimeOther; // 扩展数据
  end;

  // 扩展指数市场实时数据 扩展
  THSIndexRealTime_Ext = packed record
    m_cSize: USHORT; // 结构体长度
    m_nVersion: USHORT; // 版本号
    m_indexRealTime: THSIndexRealTime; // 实时数据
    m_indexRealTimeOther: THSIndexRealTimeOther; // 扩展数据
  end;

  // 实时数据分类
  PShareRealTimeData_Ext = ^TShareRealTimeData_Ext;

  TShareRealTimeData_Ext = packed record
    case integer of
      0:
        (m_nowDataExt: THSStockRealTime_Ext); // 个股实时基本数据
      1:
        (m_stStockDataExt: THSStockRealTime_Ext);
      2:
        (m_indData: THSIndexRealTime_Ext); // 扩展指数实时基本数据
      3:
        (m_hkData: THSHKStockRealTime_Ext); // 港股实时基本数据
      4:
        (m_qhData: THSQHRealTime); // 期货实时基本数据
      5:
        (m_whData: THSWHRealTime); // 外汇实时基本数据
      6:
        (m_qhMin: THSQHRealTime_Min);
      7:
        (m_IBData: THSIBRealTime); // 银行间债券
      8:
        (m_OPTData: THSOPTRealTime); // 个股期权
      9:
        (m_USData: THSUSStockRealTime); // 美股实时基本数据
      10:
        (m_USDelayData: THSUSStockRealTimeDelay); // 美股延时数据
  end;

  PCommRealTimeData_Ext = ^TCommRealTimeData_Ext;

  TCommRealTimeData_Ext = packed record
    m_cSize: USHORT; // 结构体长度
    m_nVersion: USHORT; // 版本号
    m_ciStockCode: TCodeInfo; // 股票代码
    m_othData: TStockOtherData; // 实时其它数据
    m_cNowData: TShareRealTimeData_Ext; // 指向ShareRealTimeData_Ext的任意一个
  end;

  // 扩展实时数据RT_REALTIME_EXT
  PAnsRealTime_EXT = ^TAnsRealTime_EXT;

  TAnsRealTime_EXT = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: short; // 报价表数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_pnowData: array [0 .. 0] of TCommRealTimeData_Ext; // 报价表数据
  end;

  // PAnsHSAutoPushData_Ext = ^TAnsHSAutoPushData_Ext;
  // TAnsHSAutoPushData_Ext = packed record
  // m_dhHead:TDataHead;				// 数据报头
  // m_nSize:long;				// 数据个数
  // m_pnowData:array[0..0] of TCommRealTimeData_Ext;	// 主机实时发送的数据
  // end;

  // level主推 rt_level_realtime or rt_level_autopush
  PAnsHSAutoPushLevel = ^TAnsHSAutoPushLevel;

  TAnsHSAutoPushLevel = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: LongInt; // 数据个数
    m_pstData: array [0 .. 0] of TRealTimeDataLevel; // 主机实时发送的数据
  end;

  // 逐笔成交 查询请求
  PReqLevelTransaction = ^TReqLevelTransaction;

  TReqLevelTransaction = packed record
    m_CodeInfo: TCodeInfo;
    m_nSize: LongInt;
    m_nPostion: LongInt;
  end;

  TStockTransaction = packed record
    m_TradeRef: LongInt; // 成交编号
    m_TradeTime: LongInt; // 成交时间
    m_TradePrice: LongInt; // 成交价格
    m_TradeQty: LongInt; // 成交数量
    m_TradeMoney: LongInt; // 成交金额
  end;

  TStockTransactions = array [0 .. MaxCount] of TStockTransaction;
  PStockTransactions = ^TStockTransactions;

  /// *
  // 说明: 常用主推  （在客户端适用于所有页面）
  // 类型: RT_AUTOPUSH
  //
  // 说明: 请求主推，目前用于预警
  // 类型: RT_REQAUTOPUSH
  // */
  /// *返回结构*/

  /// *
  // RT_GENERALSORT说明1:
  // m_nSortType掩码如下：（可取多值）
  // 1、RT_RISE			涨幅排名
  // 2、RT_FALL			跌幅排名
  // 3、RT_5_RISE		5分钟涨幅排名
  // 4、RT_5_FALL		5分钟跌幅排名
  // 5、RT_AHEAD_COMM	买卖量差（委比）正序排名
  // 6、RT_AFTER_COMM	买卖量差（委比）倒序排名
  // 7、RT_AHEAD_PRICE	成交价震幅正序排名
  // 8、RT_AHEAD_VOLBI	成交量变化（量比）正序排名
  // 9、RT_AHEAD_MONEY	资金流向正序排名
  // */
  //
  /// * 综合排名报表数据项 */
  /// *
  // 请求类型: RT_GENERALSORT_EX
  // 功能说明: 综合排名报表(加入了几分钟排名设置)
  // 备	  注:
  // */
  /// * 请求结构 */
  ///
  PReqGeneralSortEx = ^TReqGeneralSortEx;

  TReqGeneralSortEx = packed record

    m_cCodeType: HSMarketDataType; // 市场类别
    m_nRetCount: short; // 返回总数
    m_nSortType: short; // 排序类型 见RT_GENERALSORT说明1
    m_nMinuteCount: short; // 用于综合排名中快速排名窗口的几份钟排名设置。
    // 0 使用服务器默认分钟数
    // 1 ... 15为合法取值(一般可能的取值为1,2,3,4,5,10,15)
  end;

  // 综合排名报表数据项 */
  TGeneralSortData = packed record
    m_ciStockCode: TCodeInfo; // 股票代码
    m_lNewPrice: LongInt; // 最新价
    m_lValue: LongInt; // 计算值
  end;

  TGeneralSortDatas = array [0 .. MaxCount] of TGeneralSortData;
  PGeneralSortDatas = ^TGeneralSortDatas;

  /// *返回结构*/
  PAnsGeneralSortEx = ^TAnsGeneralSortEx;

  TAnsGeneralSortEx = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSortType: short; // 排序类型
    m_nSize: short; // 单个子包所含数据GeneralSortData个数
    // 当m_ nSortType为单值时（只有一位为1）,
    // 表示m_prptData数组的个数为m_nSize个。
    // 当m_ nSortType为多值相或时（如N位为1），表示此返回包针对N个子包，
    // 每个子包所含GeneralSortData个数为m_nSize，数组m_prptData的长度为N*m_nSize。
    m_nAlignment: short; // 字节对齐
    m_nMinuteCount: short; // 用于综合排名中快速排名窗口的几份钟排名设置。
    // 0 使用服务器默认分钟数
    // 1 ... 15为合法取值(一般可能的取值为1,2,3,4,5,10,15)
    m_prptData: array [0 .. 0] of TGeneralSortData; // 数据
  end;

  // 返回结构 */
  PAnsReportData = ^TAnsReportData;

  TAnsReportData = packed record
    m_dhHead: TDataHead; // 数据头
    m_nSize: short; // 数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_prptData: array [0 .. 0] of TCommRealTimeData; // 数据
  end;

  // 逐笔成交结构
  PLevelTransaction = ^TLevelTransaction;

  TLevelTransaction = packed record
    m_CodeInfo: TCodeInfo; // 代码
    m_nSize: LongInt; // 逐笔成交个数
    m_Data: array [0 .. 0] of TStockTransaction; // 逐笔成交数据
  end;

  // 港股逐笔成交 返回结构
  PAnsLevelTick = ^TAnsLevelTick;

  TAnsLevelTick = packed record
    m_dhHead: TDataHead; // 数据头
    m_nSize: LongInt; // 返回逐笔的个数个数
    m_Data: array [0 .. 0] of TLevelTransaction; // 逐笔数据
  end;

  TLevelTransactions = array [0 .. MaxCount] of TLevelTransaction;
  PLevelTransactions = ^TLevelTransactions;

  // 逐笔成交
  PAnsLevelTransaction = ^TAnsLevelTransaction;

  TAnsLevelTransaction = packed record
    m_ciStockCode: TDataHead; // 数据头
    m_nSize: LongInt; // 返回代码个数
    m_Data: array [0 .. 0] of TStockTransaction; // 逐笔成交数据数据
  end;

  // 逐笔成交订阅返回包
  PAnsLevelTransactionAuto = ^TAnsLevelTransactionAuto;

  TAnsLevelTransactionAuto = packed record
    m_dhHead: TDataHead; // 数据头
    m_nSize: LongInt; // 返回代码个数
    m_Data: array [0 .. 0] of TLevelTransaction; // 逐笔成交数据数据
  end;

  TSingleCacellation = packed record
    m_nRanking: integer; // 排名序号
    m_cCode: array [0 .. 5] of AnsiChar; // 证券代码
    m_MarketType: HSMarketDataType; // 市场类型
    m_nOrderEntryTime: LongInt; // 委托时间
    m_nQuantity: LongInt; // 委托数量
    m_nPrice: LongInt; // 委托价格
  end;

  TOrderCacellaion = packed record
    m_nRanking: integer; // 排名序号
    m_cCode: array [0 .. 5] of AnsiChar; // 证券代码
    m_MarketType: HSMarketDataType; // 市场类型
    m_lTotalWD: LongInt; // 撤单累计数
    m_nTime: LongInt; // 当前时间
  end;

  TCancelOrder = packed record
    case integer of
      0:
        (SingleRanking: TSingleCacellation);
      1:
        (ConsolidatedRanking: TOrderCacellaion);
  end;

  POrderCancelRanking = ^TOrderCancelRanking;

  TOrderCancelRanking = packed record
    side: AnsiChar; // 买卖方向
    size: integer; // 排名数量
    ctype: integer; // 排名类型  1:Single 2:Consolidated
    orderRanking: array [0 .. 0] of TCancelOrder;
  end;

  // 撤单排名数据主推应答包，在DataHead里有消息号进行区分
  PAnsHsLevelCancelOrder = ^TAnsHsLevelCancelOrder;

  TAnsHsLevelCancelOrder = packed record
    m_dhHead: TDataHead; // 数据头
    m_pData: TOrderCancelRanking; // 数据
  end;

  // 最优盘口
  PLevelOrderQueue = ^TLevelOrderQueue;

  TLevelOrderQueue = packed record
    m_Side: AnsiChar; // 买卖方向
    m_Price: LongInt; // 价格水平
    m_nActualOrderNum: short; // 委托笔数	表示实际委托笔数，可能比50笔多
    m_noOrders: short; // 上证通推过来的笔数  最多50笔	FAST协议最多100笔
    m_lData: array [0 .. 0] of LongInt; // 数据指针，指向的数据为订单数量
  end;

  PAnsQueryOrderQueue = ^TAnsQueryOrderQueue;

  TAnsQueryOrderQueue = packed record
    m_dhHead: TDataHead; // 数据头
    m_pstData: TLevelOrderQueue; // 数据
  end;

  // 买卖队列请求
  PReqOrderQueue = ^TReqOrderQueue;

  TReqOrderQueue = packed record
    m_CodeInfo: TCodeInfo; // 代码
    m_direct: integer; // 1为买，2为卖
  end;

  POrderQueueData = ^TOrderQueueData;

  TOrderQueueData = packed record
    m_CodeInfo: TCodeInfo; // 代码
    m_Data: TLevelOrderQueue; // 数据
  end;

  // 最佳盘口数据主推应答包，在DataHead里有消息号进行区分
  PAnsLevelOrderQueueAuto = ^TAnsLevelOrderQueueAuto;

  TAnsLevelOrderQueueAuto = packed record
    m_dhHead: TDataHead; // 数据头
    m_nSize: LongInt; // 买卖方向
    m_pstData: array [0 .. 0] of TOrderQueueData; // 数据end;
  end;

  PTestSrvData = ^TTestSrvData;

  TTestSrvData = packed record
    m_nType: USHORT; // 请求类型，与请求数据包一致
    m_nIndex: WORD; // 请求索引，与请求数据包一致
    m_cOperator: WORD; // 操作（0：清空 1:不清空)
  end;

  // 实时数据
  HSStockRealTime_Ext = packed record
    m_cSize: USHORT; // 结构体长度
    m_nVersion: USHORT; // 版本号
    m_stockRealTime: THSStockRealTime; // 时时数据
    m_stockOther: THSStockRealTimeOther; // 扩展数据
  end;

  // 请求类型: RT_TREND_EXT
  // 功能说明: 分时走势
  // 备	  注:
  //
  // 请求结构：常用请求AskData
  TPriceVolItem_Ext = packed record
    m_cSize: USHORT; // 结构体长度
    m_nVersion: USHORT; // 版本号
    m_pvi: TPriceVolItem;
    // long			    m_lNewPrice;	// 最新价
    // unsigned long		m_lTotal;		// 成交量(在外汇时，是跳动量)
    m_lExt1: LongInt; // 目前只在ETF时有用，为其IOPV值（例如510050时为510051的最新价）
    m_lStopFlag: LongInt; // 停盘标志。0：正常，1：停盘
  end;

  // 返回结构
  PAnsTrendData_Ext = ^TAnsTrendData_Ext;

  TAnsTrendData_Ext = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nHisLen: short; // 分时数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_othData: TStockOtherData;
    m_cNowData: TShareRealTimeData_Ext; // 指向ShareRealTimeData的任意一个
    m_pHisData: array [0 .. 0] of TPriceVolItem_Ext; // 历史分时数据
  end;

  // 个股龙虎看盘
  TBigOrderItem = packed record
    m_TransType: short; // 大小单档位信息(0-买小单；1-买中单；2-买大单；3-买特大单；4-卖小单；5-卖中单；6-卖大单；7-卖特大单)
    m_Volume: Single; // 当前档位大小单成交量
    m_Money: Single; // 当前档位大小单成交金额
    m_Count: ULONG; // 当前档位大小单成交次数
  end;

  TBigOrderItems = array [0 .. 0] of TBigOrderItem;
  PBigOrderItems = ^TBigOrderItems;

  PBigOrderData = ^TBigOrderData;

  TBigOrderData = packed record
    m_ciStockCode: TCodeInfo;
    m_nSize: long;
    m_pstData: array [0 .. 0] of TBigOrderItem;
  end;

  PAnsHSAutoPushBigOrder = ^TAnsHSAutoPushBigOrder;

  TAnsHSAutoPushBigOrder = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: long; // 数据个数;
    m_pstArray: array [0 .. 0] of TBigOrderData; // Level2的实时大小单队列
  end;

  PAnsHSBigOrder = ^TAnsHSBigOrder;

  TAnsHSBigOrder = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nType: short;
    m_nSize: long; // 数据个数;
    m_pstArray: array [0 .. 0] of TBigOrderData; // Level2的实时大小单队列
  end;

  // 个股多日历史龙虎看盘  请求结构
  TRegHSBigOrder = packed record
    m_lBeginPosition: long; // 起始个数，0表示当前位置
    m_nDay: USHORT; // 申请的个数
    m_nReqType: short; // 请求类型
    m_ciCode: TCodeInfo; // 申请的股票代码
  end;

  TBigOrderHisData = packed record
    m_lDate: ULONG;
    m_nSize: long;
    m_pstData: array [0 .. 0] of TBigOrderItem;
  end;

  // 个股多日历史龙虎看盘  返回结构
  TAnsBigOrderHis = packed record

    m_dhHead: TDataHead; // 数据报头
    m_ciStockCode: TCodeInfo; // 股票代码
    m_nDate: long; // 大小单数据生成时间
    m_nType: short; // 大小单算法类型（0-逐笔，1-逐单）
    m_nSize: long; // 数据个数
    m_pstArray: array [0 .. 0] of TBigOrderHisData;
  end;

  // DDE Level2缓存逐笔 请求结构：
  PReqDDETransByTrans = ^TReqDDETransByTrans;

  TReqDDETransByTrans = packed record
    m_CodeInfo: TCodeInfo; // 代码
    m_nSize: integer; // 请求的逐笔的个数
    m_nPostion: integer; // 开始请求逐笔的起始位置，目前都为0：表示从最新开始请求
  end;

  TReqDDETransByTranss = array [0 .. 0] of TReqDDETransByTrans;
  PReqDDETransByTranss = ^TReqDDETransByTranss;

  TTransDataByTrans = packed record
    m_TradeIdx: ULONG; // 成交索引，在连续单中用于连续单序号进行保存
    m_TradeTime: ULONG; // 成交时间
    m_TradePx: long; // 成交价格
    m_TradeQty: long; // 成交数量
    m_TradeMoney: Single; // 成交金额
    m_TransType: short; // 逐笔成交大单类型,0-买小单；1-买中单；2-买大单；3-买特大单；4-卖小单；5-卖中单；6-卖大单；7-卖特大单
  end;

  // DDE Level2缓存逐笔  返回结构：
  PAnsDDETransByTrans = ^TAnsDDETransByTrans;

  TAnsDDETransByTrans = packed record
    m_dhHead: TDataHead; // 数据头
    m_nType: short;
    m_nSize: LongInt; // 返回逐笔的个数个数
    m_CodeInfo: TCodeInfo; // 代码
    m_Data: array [0 .. 0] of TTransDataByTrans; // 逐笔成交数据数据
  end;

  // Level2股票逐笔成交 请求结构：
  TReqDDETransByOrder = packed record
    m_CodeInfo: TCodeInfo; // 代码
    m_nSize: integer; // 请求的逐笔的个数
    m_nPostion: integer; // 开始请求逐笔的起始位置，目前都为0：表示从最新开始请求
  end;

  // 返回结构：

  TTransDataByOrder = packed record
    m_TradeIdx: ULONG; // 成交索引，在连续单中用于连续单序号进行保存
    m_TradeTime: ULONG; // 成交时间
    m_TradePx: long; // 成交价格
    m_TradeQty: long; // 成交数量
    m_TradeMoney: Single; // 成交金额
    m_OrderType: short; // 逐单成交大单类型,高8位保存买挂单的大单类别，低8位保存卖挂单的大单类别，大单类别定义同逐笔成交大单类型
    m_SeriesNum: short; // 买挂单连续单序号，以连续单开始的成交索引来区分挂单是否连续
    m_OfferSeriesNum: short; // 卖挂单连续单序号，以连续单开始的成交索引来区分挂单是否连续
    m_BidOrderQty: Single; // 买挂单量
    m_OfferOrderQty: Single; // 卖挂单量
    m_TransSide: AnsiChar; // 成交快照方向，说明：只用于逐单算法，不是逐笔成交的主动性买卖方向
    m_SearchSide: AnsiChar; // 买挂单查找方向，1-向前找；2-向后找,0:默认,无需找
    m_OfferSearchSide: AnsiChar; // 卖挂单查找方向，1-向前找；2-向后找,0:默认,无需找
  end;

  PAnsDDETransByOrder = ^TAnsDDETransByOrder;

  TAnsDDETransByOrder = packed record
    m_dhHead: TDataHead; // 数据头
    m_nType: short;
    m_nSize: long; // 返回逐笔的个数个数
    m_CodeInfo: TCodeInfo; // 代码
    m_Data: array [0 .. 0] of TTransDataByOrder; // 逐笔成交数据数据
  end;

  // DDE 委托队列 请求结构：
  TReqDDEOrderQueue = packed record
    m_nSize: integer; // 请求委托队列的个数
    m_nPostion: integer; // 开始请求委托的起始位置，目前都为0：表示从最新开始请求
    m_CodeInfo: TCodeInfo; // 代码
  end;

  TOrderQueueItem = packed record
    m_Side: AnsiChar; // 买卖方向
    m_Price: long; // 价格水平
    m_nTime: long; // 委托队列时间
    m_nActualOrderNum: short; // 委托笔数表示实际委托笔数，可能比50笔多
    m_noOrders: short; // 上证通推过来的笔数最多50笔;FAST协议最多100笔
    m_lData: array [0 .. 0] of long; // 数据指针，指向的数据为订单数量
    m_lDataType: array [0 .. 0] of long; // 数据指针，指向的数据为订单的大小单类型
  end;

  // DDE 委托队列返回结构：
  TAnsDDEOrderQueue = packed record
    m_dhHead: TDataHead; // 数据头
    m_CodeInfo: TCodeInfo; // 代码
    m_nSeq: long; // 最新委托变化序号
    m_nSize: long; // 返回委托队列的个数
    m_Data: TOrderQueueItem; // 委托队列数据
  end;

  // 历史DDE指标包含：DDX、DDY、DDZ
  // 个股DDE指标：单股票多日DDE数据
  PReqHisDDE = ^TReqHisDDE;

  TReqHisDDE = packed record
    m_lBeginPosition: long; // 起始个数，0 表示当前位置
    m_nDay: USHORT; // 申请的个数
    m_ciCode: TCodeInfo; // 申请的股票代码
  end;

  // 返回结构：
  THisDDEData = packed record
    m_lDate: ULONG;
    m_ddx: Single; // DDX
    m_ddy: Single; // DDY
    m_ddz: Single; // DDZ
  end;

  THisDDEDatas = array [0 .. 0] of THisDDEData;
  PHisDDEDatas = ^THisDDEDatas;

  TAnsHisDDE = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: long; // 数据个数
    m_ciStockCode: TCodeInfo; // 代码
    m_pstArray: array [0 .. 0] of THisDDEData; // 主机实时发送的数据
  end;
  // 历史DDE指标包含：DDX、DDY、DDZ
  // 、5日DDX、5日DDY、5日DDZ指标；60日DDX、60日DDY、60日DDZ指标；
  // DDX飘红天数（10内）、DDX飘红天数（连续）
  // 用于DDE决策：多股票当日DDE数据，中长线DDE指标

  TDDEDecisionData = packed record
    m_ciStockCode: TCodeInfo; // 代码
    m_ddx: Single; // DDX
    m_ddy: Single; // DDY
    m_ddz: Single; // DDZ
    m_5ddx: Single; // 5日DDX
    m_5ddy: Single; // 5日DDY
    m_5ddz: Single; // 5日DDZ
    m_60ddx: Single; // 60日DDX
    m_60ddy: Single; // 60日DDY
    m_60ddz: Single; // 60日DDZ
    m_10days: short; // 10日DDX飘红天数
    m_days: short; // 10日DDX飘红天数（连续）
  end;

  TDDEDecisionDatas = array [0 .. 0] of TDDEDecisionData;
  PDDEDecisionDatas = ^TDDEDecisionDatas;

  PAnsDDEDecision = ^TAnsDDEDecision;

  TAnsDDEDecision = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: long; // 数据个数
    m_pstArray: array [0 .. 0] of TDDEDecisionData; // 主机实时发送的数据
  end;

  PAnsHisDDETrend = ^TAnsHisDDETrend;

  TAnsHisDDETrend = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nHisLen: short; // 分时数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_ciStockCode: TCodeInfo; // 股票代码
    m_pstArray: array [0 .. 0] of THisDDEData; // 主机实时发送的数据
  end;

  // 个股当日分时大小单分类成交统计数据

  TBigOrderTrendData = packed record
    m_nSize: long;
    m_pstData: array [0 .. 0] of TBigOrderItem;
  end;

  TAnsBigOrderTrend = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nHisLen: short; // 分时数据个数
    m_nType: short; // 大小单算法类型（0-逐笔，1-逐单）
    m_ciStockCode: TCodeInfo; // 股票代码
    m_pstArray: array [0 .. 0] of TBigOrderTrendData; // 主机实时发送的数据
  end;

  // 历史主力机构分类成交统计数据
  // 个股历史主力机构统计数据：主力机构线
  TReqHisMass = packed record
    m_lBeginPosition: long; // 起始个数，0 表示当前位置
    m_nDay: USHORT; // 申请的个数
    m_ciCode: TCodeInfo; // 申请的股票代码
  end;

  TMassData = packed record
    m_TotalVolume: Single; // 总成交量
    m_TotalMoney: Single; // 总成交额
    m_TotalCount: Single; // 总成交笔数
    m_MfVolume: Single; // note="买主力成交量" />
    m_MfMoney: Single; // note="买主力成交额" />
    m_MfCount: Single; // note="买主力成交笔数" />
    m_MfOrderCount: Single; // note="买主力挂单数" />
    m_InsVolume: Single; // note="买机构成交量" />
    m_InsMoney: Single; // note="买机构成交额" />
    m_InsCount: Single; // note="买机构成交笔数" />
    m_InsOrderCount: Single; // note="买机构挂单数" />
    m_OfferMfVolume: Single; // note="卖主力成交量" />
    m_OfferMfMoney: Single; // note="卖主力成交额" />
    m_OfferMfCount: Single; // note="卖主力成交笔数" />
    m_0fferMfOrderCount: Single; // note="卖主力挂单数" />
    m_OfferInsVolume: Single; // note="卖机构成交量" />
    m_OfferInsMoney: Single; // note="卖机构成交额" />
    m_OfferInsCount: Single; // note="卖机构成交笔数" />
    m_OfferInsOrderCount: Single; // note="卖机构挂单数" />
  end;

  // 返回结构：
  TAnsHisMass = packed record
    m_dhHead: TDataHead; // 数据报头
    m_ciStockCode: TCodeInfo; // 代码
    m_nSize: long; // 数据个数
    m_pstArray: array [0 .. 0] of TMassData; // 主机实时发送的数据
  end;

  // 主力机构看盘数据
  TMassDecisionData = packed record
    m_ciStockCode: TCodeInfo; // 代码
    m_TotalVolume: Single; // 总成交量
    m_TotalMoney: Single; // 总成交额
    m_TotalCount: Single; // 总成交笔数
    m_MfVolume: Single; // note="买主力成交量" />
    m_MfMoney: Single; // note="买主力成交额" />
    m_MfCount: Single; // note="买主力成交笔数" />
    m_MfOrderCount: Single; // note="买主力挂单数" />
    m_InsVolume: Single; // note="买机构成交量" />
    m_InsMoney: Single; // note="买机构成交额" />
    m_InsCount: Single; // note="买机构成交笔数" />
    m_InsOrderCount: Single; // note="买机构挂单数" />
    m_OfferMfVolume: Single; // note="卖主力成交量" />
    m_OfferMfMoney: Single; // note="卖主力成交额" />
    m_OfferMfCount: Single; // note="卖主力成交笔数" />
    m_0fferMfOrderCount: Single; // note="卖主力挂单数" />
    m_OfferInsVolume: Single; // note="卖机构成交量" />
    m_OfferInsMoney: Single; // note="卖机构成交额" />
    m_OfferInsCount: Single; // note="卖机构成交笔数" />
    m_OfferInsOrderCount: Single; // note="卖机构挂单数" />
  end;

  TAnsMassDecision = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: long; // 股票个数个数
    m_pstArray: array [0 .. 0] of TMassDecisionData; // 主机实时发送的数据
  end;

  // 当日分时主力机构分类成交统计数据
  TAnsMassTrend = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nHisLen: short; // 分时数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_ciStockCode: TCodeInfo; // 股票代码
    m_pstArray: array [0 .. 0] of TMassData; // 主机实时发送的数据
  end;

  TOrderQueueDetailItem = packed record
    m_Side: AnsiChar; // 买卖方向
    m_LevelOp: AnsiChar; // 价格档位操作
    m_Type: AnsiChar; // 大小单标识
    m_none: AnsiChar;
    m_nSeq: long; // 委托变化序号
    m_nIndex: long; // 委托单下标
    m_nOrderNum: long; // 委托单数量
  end;

  // 当前逐单大小单统计快照
  TAnsDDEOrderQueueDetail = packed record
    m_dhHead: TDataHead; // 数据头
    m_nSize: short; // 返回委托队列的个数
    m_nAlignment: short;
    m_ciStockCode: TCodeInfo; // 代码
    m_nPrice: long; // 档位价格
    m_Data: array [0 .. 0] of TOrderQueueDetailItem; // 委托增量变化数据
  end;

  { //个股精灵信息
    TMonitionData = packed record
    m_ciStockCode: TCodeInfo;    // 代码
    m_nTime: Long;//时间
    m_nType: short;//警告类型
    m_nAlignment: short ;    //为了4字节对齐而添加的字段
    m_Value1: uint64     ;//警告值1
    m_Value2: uint64     ;//警告值2
    end;


    TAnsMonition = packed record
    m_dhHead: TDataHead ;// 数据报头
    m_nSize: long ;// 数据个数
    m_pstArray: array [0..0] of TMonitionData  ;// 主机实时发送的数据
    end; }

  // ***************************H5 DDE V1.1 Begin****************************************/
  // 功能号定义
const
  // HDA实时行情查询
  RT_HDA_REALTIME_QUERY = $0910;
  // HDA实时行情主推
  RT_HDA_REALTIME_AUTOPUSH = $0A20;
  // HDA分时查询
  RT_HDA_TREND_QUERY = $0911;
  // 成交分类查询(龙虎看盘)-逐单
  RT_HDA_TRADE_CLASSIFY_BYORDER_QUERY = $0912;
  // 成交分类查询(龙虎看盘)-逐笔
  RT_HDA_TRADE_CLASSIFY_BYTRNAS_QUERY = $0915;
  // 成交分类主推-逐单
  RT_HDA_TRADE_CALSSIFY_BYORDER_AUTOPUSH = $0A21;
  // 成交分类主推-逐笔
  RT_HDA_TRADE_CALSSIFY_BYTRNAS_AUTOPUSH = $0A22;
  // HDA指标K线查询
  RT_HDA_CANDLE_QUERY = $0913;
  // HDA成交分类K线查询
  RT_HDA_CLASSIFY_CANDLE_QUERY = $0914;

  // HDA指标小数位精度
  HDA_DECIMAL = 5;

  // K线请求周期 日
  PERIOD_TYPE_DAY = $0010;

  // 成交分类统计的视角
  HDA_CLASSIFY_VIEW_TRANS = 0; // 逐笔
  HDA_CLASSIFY_VIEW_ORDER = 1; // 逐单
  HDA_CLASSIFY_VIEW_FENBI = 2; // Only For Level1, Not Use In Current Verion.

  // 成交分类的规模
  HDA_CLASSIFY_COUNT = 4;

type
  // 成交分类的规模
  THDA_CLASSIFY_TYPE = (emSIZE_SUPER = 0, // 超大单
    emSIZE_LARGE = 1, // 大单
    emSIZE_MEDIUM = 2, // 中单
    emSIZE_LITTLE = 3); // 小单

  // HDA行情基本项
  THDA_Item = packed record
    m_nDDX: integer;
    m_nDDY: integer;
    m_nDDZ: integer;
  end;

  PHDA_Items = ^THDA_Items;
  THDA_Items = array [0 .. 0] of THDA_Item;

  // HDA实时行情
  THDA_RealTime = packed record
    m_LastHDA: THDA_Item;
    m_5DayHDA: THDA_Item;
    m_60DayHDA: THDA_Item;
    m_nRiseDays: integer; // DDX连续飘红天数
    m_nRiseDayPast10: integer; // 10日内飘红天数
  end;

  // HDA成交分类项
  THDA_ClassifyItem = packed record
    m_nVolume: int64; // 成交量
    m_nTurnOver: int64; // 成交额
    m_nTransCount: Cardinal; // 逐笔数
    m_nOrderCount: Cardinal; // 委托单数
  end;

  // HDA-K线
  THDA_Candle_Item = packed record
    m_lDate: Cardinal;
    m_nDDX: integer;
    m_nDDY: integer;
    m_nDDZ: integer;
  end;

  PHDA_Candle_Items = ^THDA_Candle_Items;
  THDA_Candle_Items = array [0 .. 0] of THDA_Candle_Item;

  // HDA-成交统计K线
  THDA_Classify_Candle_Item = packed record
    m_lDate: Cardinal;
    m_ayOfferClassify: array [emSIZE_SUPER .. emSIZE_LITTLE] of THDA_Candle_Item;
    m_ayBidClassify: array [emSIZE_SUPER .. emSIZE_LITTLE] of THDA_Candle_Item;
  end;

  // HDA实时行情请求: CodeInfo,
  // HDA实时行情应答：AnsRealTime_HDA
  // 功能号:
  // 查询: RT_HDA_REALTIME_QUERY
  // 主推: RT_HDA_REALTIME_AUTOPUSH
  PHDARealTimeData = ^THDARealTimeData;

  THDARealTimeData = packed record
    m_StockCode: TCodeInfo; // 股票代码
    m_OtherData: TStockOtherData;
    m_RealTime: THDA_RealTime;
  end;

  THDARealTimeDatas = array [0 .. 0] of THDARealTimeData;
  PHDARealTimeDatas = ^THDARealTimeDatas;

  PAnsRealTime_HDA = ^TAnsRealTime_HDA;

  TAnsRealTime_HDA = packed record
    m_DataHead: TDataHead;
    m_nSize: integer;
    m_lpRealTime: array [0 .. 0] of THDARealTimeData;
  end;

  // 客户端扩展(报价牌)使用，CodeInfo转NBBM
  PHDARealTimeDataEx = ^THDARealTimeDataEx;

  THDARealTimeDataEx = packed record
    m_RealTimeData: THDARealTimeData;
    NBBM: integer;
  end;

  THDARealTimeDataExs = array [0 .. 0] of THDARealTimeDataEx;
  PHDARealTimeDataExs = ^THDARealTimeDataExs;

  // 请求-应答结构
  // HDA分时请求: ReqTrend_HDA
  // HDA分时应答：AnsTrend_HDA
  // 功能号:
  // 查询: RT_HDA_TREND_QUERY
  PReqTrend_HDA = ^TReqTrend_HDA;

  TReqTrend_HDA = packed record
    m_CodeInfo: TCodeInfo;
    m_lDate: integer; // >0为要请求的日期, <=0为偏移的历史分时走势,0:为今天
  end;

  PAnsTrend_HDA = ^TAnsTrend_HDA;

  TAnsTrend_HDA = packed record
    m_DataHead: TDataHead;
    m_StockCode: TCodeInfo;
    m_nDate: integer;
    m_nSize: integer;
    m_lpTrends: array [0 .. 0] of THDA_Item;
  end;

  // 成交分类(龙虎看盘)请求: AskData
  // 成交分类(龙虎看盘)应答: AnsTradeClassify_HDA
  // 功能号:
  // 查询: RT_HDA_TRADE_CLASSIFY_BYORDER_QUERY,RT_HDA_TRADE_CLASSIFY_BYTRANS_QUERY
  // 主推: RT_HDA_TRADE_CALSSIFY_BYORDER_AUTOPUSH,RT_HDA_TRADE_CALSSIFY_BYTRANS_AUTOPUSH
  PHDATradeClassifyData = ^THDATradeClassifyData;

  THDATradeClassifyData = packed record
    m_StockCode: TCodeInfo;
    m_OtherData: TStockOtherData;
    m_emView: integer; // 分类视角
    m_OfferClassify: array [emSIZE_SUPER .. emSIZE_LITTLE] of THDA_ClassifyItem;
    m_BidClassify: array [emSIZE_SUPER .. emSIZE_LITTLE] of THDA_ClassifyItem;
  end;

  PAnsTradeClassify_HDA = ^TAnsTradeClassify_HDA;

  TAnsTradeClassify_HDA = packed record
    m_DataHead: TDataHead;
    m_nSize: integer;
    m_lpClassify: array [0 .. 0] of THDATradeClassifyData;
  end;

  // HDA-K线请求: ReqCandle_HDA
  // HDA-K线应答: AnsCandle_HDA
  // 功能号:
  // 查询: RT_HDA_CANDLE_QUERY
  // Note: 目前资金流只只支持的历史日K线
  PReqCandle_HDA = ^TReqCandle_HDA;

  TReqCandle_HDA = packed record
    m_cPeriod: short; // K线周期类型，目前仅支持日线(PERIOD_TYPE_DAY)
    m_nSize: WORD; // 请求K线的个数
    m_nAlignment: WORD; // 预留字段
    m_lBeginPosition: integer; // 起始位置，-1 表示当前位置
    m_ciCode: TCodeInfo;
  end;

  PAnsCandle_HDA = ^TAnsCandle_HDA;

  TAnsCandle_HDA = packed record
    m_DataHead: TDataHead;
    m_StockCode: TCodeInfo;
    m_cPeriod: short; // K线类型与请求一致
    m_nCount: integer;
    m_lpItems: array [0 .. 0] of THDA_Candle_Item;
  end;

  // HDA-K线请求: ReqCandle_HDA
  // HDA-K线应答: AnsCandle_Classify_HDA
  // 功能号:
  // 查询: RT_HDA_CLASSIFY_CANDLE_QUERY
  // Note: 目前资金流只只支持的历史日K线
  TAnsCandle_Classify_HDA = packed record
    m_DataHead: TDataHead;
    m_StockCode: TCodeInfo;
    m_cPeriod: short; // K线类型与请求一致
    m_nCount: integer;
    m_lpItems: array [0 .. 0] of THDA_Classify_Candle_Item;
  end;
  // ***************************DDE V1.1 End************************************/

  // ***************************INTER BANK BEGIN********************************/

  // 分时数据
  PPriceVolItem_IB = ^TPriceVolItem_IB;

  TPriceVolItem_IB = packed record
    m_lNewPrice: integer; // 最新净价
    m_lBuyPrice: integer; // 委买净价
    m_lSellPrice: integer; // 委卖净价
    m_llVolume: int64; // 成交量(元)
  end;

  // 分时应答
  PAnsIBTrendData = ^TAnsIBTrendData;

  TAnsIBTrendData = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nCount: short; // 分时数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_pVolData: array [0 .. 0] of TPriceVolItem_IB; // 分时数据
  end;

  // 银行间债券 日内行情
  PReqIBTrans = ^TReqIBTrans;

  TReqIBTrans = packed record
    m_ciStockCode: TCodeInfo; // 证券信息
    m_nSize: long; // 请求分笔总数，小于等于0时，表示请求全部
  end;

  // 日内行情数据
  PIBTransData = ^TIBTransData;

  TIBTransData = packed record
    m_nTime: USHORT; // 距离开盘的分钟数
    m_nSecond: AnsiChar; // 秒数
    m_nTradeMethodNumber: AnsiChar; // 成交方式
    m_lNewPrice: long; // 最新净价
    m_lNewRate: long; // 最新净价收益率
    m_lRise: long; // 涨幅
    m_lWeightPrice: long; // 加权净价
    m_lWeightRate: long; // 加权净价收益率
    m_llVolume: int64; // 券面总额(元)
  end;

  TIBTransDatas = array [0 .. 0] of TIBTransData;
  PIBTransDatas = ^TIBTransDatas;

  PAnsIBTransData = ^TAnsIBTransData;

  TAnsIBTransData = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: short; // 请求Data结构的总数
    m_nAlignment: short; // 预留字段
    m_pData: array [0 .. 0] of TIBTransData; //
  end;

  // K线请求
  PReqIBTechData = ^TReqIBTechData;

  TReqIBTechData = packed record
    m_nDataType: short; // 数据类型，1为净价，2为净价收益率，3为中债估值
    m_cPeriod: short; // K线周期类型，同ReqDayData
    m_nSize: USHORT; // 请求K线的个数
    m_nAlignment: USHORT; // 预留字段
    m_lBeginPosition: long; // 起始位置，0表示从当前，正数表示向前偏移
    m_ciCode: TCodeInfo; // 申请的股票代码
  end;

  // K线数据
  PIBTechData = ^TIBTechData;

  TIBTechData = packed record
    m_lDate: ULONG; // 日期
    m_lOpen: long; // 开
    m_lMax: long; // 高
    m_lMin: long; // 低
    m_lClose: long; // 收，当日的取最新
    m_lInterest: long; // 应计利息
    m_llVolume: int64; // 成交量
  end;

  TIBTechDatas = array [0 .. 0] of TIBTechData;
  PIBTechDatas = ^TIBTechDatas;

  // K线应答
  PAnsIBTechData = ^TAnsIBTechData;

  TAnsIBTechData = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nDataType: short; // 数据类型，1为净价，2为净价收益率，3为中债估值
    m_nSize: short; // 请求Data结构的总数
    m_pData: array [0 .. 0] of TIBTechData; // 具体数据
  end;

  TIBBondBaseInfoData = packed record
    m_ciStockCode: TCodeInfo; // 证券信息
    m_nCouponType: short; // 付息类型1固定2浮动3零息4贴现
    m_nPaymentFequency: short; // 付息频率
    m_nCouponRate: long; // 票面利率
    m_lFaceValue: long; // 债券面额
    m_lIssuePrice: long; // 发行价格
    m_lCashPrice: long; // 兑付价格
    m_lIssueAmount: int64; // 发行总额
    m_lDelistingDate: long; // 债券摘牌日
  end;

  PAnsIBBondBaseInfoData = ^TAnsIBBondBaseInfoData;

  TAnsIBBondBaseInfoData = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: short; // 请求Data结构的总数
    m_nAlignment: short; // 预留字段
    m_pData: array [0 .. 0] of TIBBondBaseInfoData; //
  end;

  PSeverCalculateData = ^TSeverCalculateData;

  TSeverCalculateData = packed record
    m_ciStockCode: TCodeInfo; // 证券信息
    m_fUpPrice: Single; // 涨停板价
    m_fDownPrice: Single; // 跌停板价
  end;

  PAnsSeverCalculate = ^TAnsSeverCalculate;

  TAnsSeverCalculate = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: integer; // 数据个数
    SeverCalculateData: array [0 .. 0] of TSeverCalculateData end;

    PMarketMonitor = ^TMarketMonitor;
    TMarketMonitor = Packed record m_nMarketType: USHORT;
  end;

  // 短线精灵主推请求
  // 支持市场查询校验请求
  { 和扩展主推等一样，
    AskData::m_nOption字段表示订阅的种类：
    0: 覆盖订阅；
    1: 追加订阅；
    2: 取消订阅。 }
  PReqMarketMonitor = ^TReqMarketMonitor;

  TReqMarketMonitor = Packed record
    m_nMktCount: USHORT; // 订阅市场的个数
    m_nReserved: USHORT; // 保留
    m_sMarkets: array [0 .. 0] of TMarketMonitor; // 订阅的市场列表
  end;

  // 支持市场查询校验应答
  PAnsMarketMonitor = ^TAnsMarketMonitor;

  TAnsMarketMonitor = Packed record
    m_dhHead: TDataHead;
    m_nMktCount: USHORT; // 支持市场的个数
    m_nReserved: USHORT; // 保留
    m_sMarkets: array [0 .. 0] of TMarketMonitor; // 返回支持的市场列表
  end;

  // 短线精灵事件结构
  PMarketEvent = ^TMarketEvent;

  TMarketEvent = Packed record
    m_nEventID: USHORT; // 监控类别ID，用来对应格式串
    m_nReserved: USHORT; // 保留
    m_nTime: UINT; // 事件时间hhmmss(客户端目前不展示秒)
    m_CodeInfo: TCodeInfo; // 代码信息
    m_cDirection: Byte; // 方向：1 正，0 平，-1 负。用来对应提示信息的颜色
    m_cValueCount: Byte; // 有效值的个数(取值为: 0, 1, 2)
    m_cValue1Scale: Byte; // 值1缩放10的多少次方
    m_cValue2Scale: Byte; // 值2缩放10的多少次方
    m_nValue1: integer; // 值1       //最新价 or 涨跌幅
    m_nValue2: integer; // 值2       //现手
  end;
  // 监控类别ID
  { <event id="0" name="火箭发射" decimal1="2" decimal2="0" suffix="%" seperator="/" />
    <event id="1" name="步入低谷" decimal1="2" decimal2="0" suffix="%" seperator="/" />
    <!--
    <event id="2" name="快速反弹" decimal1="2" decimal2="0" suffix="%" seperator="/" />
    <event id="3" name="高台跳水" decimal1="2" decimal2="0" suffix="%" seperator="/" />
    <event id="4" name="加速上涨" decimal1="2" decimal2="0" suffix="%" seperator="/" />
    <event id="5" name="加速下跌" decimal1="2" decimal2="0" suffix="%" seperator="/" />
    -->
    <event id="6" name="大笔买入" decimal1="2" decimal2="0" suffix="" seperator="/" />
    <event id="7" name="大笔卖出" decimal1="2" decimal2="0" suffix="" seperator="/" />
    <event id="8" name="封涨停板" decimal1="2" decimal2="0" suffix="元" seperator="/" />
    <event id="9" name="封跌停板" decimal1="2" decimal2="0" suffix="元" seperator="/" />
    <event id="10" name="打开涨停" decimal1="2" decimal2="0" suffix="元" seperator="/" />
    <event id="11" name="打开跌停" decimal1="2" decimal2="0" suffix="元" seperator="/" />
    <!--
    <event id="12" name="有大买盘" decimal1="0" decimal2="0" suffix="手" seperator="/" />
    <event id="13" name="有大卖盘" decimal1="0" decimal2="0" suffix="手" seperator="/" />
    --> }

  // 短线精灵主推应答
  PAnsMarketEvent = ^TAnsMarketEvent;

  TAnsMarketEvent = Packed record
    m_dhHead: TDataHead;
    m_nDate: UINT; // 日期yyyymmdd
    m_nSize: UINT; // MarketEvent的个数
    m_MarketEvents: Array [0 .. 0] of TMarketEvent;
  end;

  // 单只股票当天所有事件 请求     //应答结构为AnsMarketEvent
  TReqStockMarketEvent = Packed record
    m_CodeInfo: TCodeInfo; // 代码信息
    m_nOffset: UINT; // 正序的偏移
    m_nCount: UINT; // 请求的事件个数
  end;

  // 按日期和市场请求短线精灵事件请求  //应答结构为AnsMarketEvent
  PReqDateMarketEvent = ^TReqDateMarketEvent;

  TReqDateMarketEvent = Packed Record
    m_nDate: UINT; // 日期yyyymmdd
    m_nOffset: UINT; // 逆序的偏移
    m_nCount: UINT; // 请求的事件个数
    m_nMktCount: USHORT; // 需要查询市场的个数
    m_nReserved: USHORT; // 保留
    m_sMarkets: array [0 .. 0] of TMarketMonitor; // 需要查询的市场列表
  end;

  // RT_HQCOL_VALUE 查询行情字段值 请求结构
  PReqHQColValue = ^TReqHQColValue;

  TReqHQColValue = Packed record
    m_lHQColCount: UINT; // 有效字段个数
    m_lHQCols: Array [0 .. MAX_HQCOL_COUNT - 1] of UINT; // 请求字段,内容同排序字段列定义
    m_lCodeSize: USHORT; // 请求的证券代码总数
    m_nReserved: USHORT; // 保留
    m_pCode: Array [0 .. 0] of TCodeInfo; // 证券代码数组
  end;

  THQColField = Packed Record
    m_lField: UINT; // 行情列ID
    m_lFieldWidth: USHORT; // 行情列值的宽度,目前可选4 或者 8,分别对应32位(4字节),64位(8字节)
    m_nSortPrecision: USHORT; // 表示放大10的多少次方.如成交金额等字段排序不需要放大,则置为0,但各市场还在按原来金额放大的值去处理。
  end;

  // RT_HQCOL_VALUE 查询行情字段值 应答结构
  PAnsHQColValue = ^TAnsHQColValue;

  TAnsHQColValue = Packed record
    m_dhHead: TDataHead; // 数据头
    m_lHQColCount: UINT; // 有效字段总数
    m_HQColFields: Array [0 .. MAX_HQCOL_COUNT - 1] of THQColField; // 请求字段,内容同排序字段列定义
    m_lColCodeSize: USHORT; // 证券代码总数
    m_nReserved: USHORT; // 保留
    m_pData: array [0 .. 0] of Char; // 返回指定字段数据.
  end; // 格式为CodeInfo + m_lFieldSize个行情字段数据(对应字段的宽度为m_ColFields.m_FieldWidth),
  // 如果该值不存在,则填0,以保证每个代码数据长度一致
  // 每个证券的数据格式大小为
  // sizeof(TCodeInfo) + m_FieldSize个字段长度之和,
  // 其中每个字段长度为m_ColFieldS[i].m_lFieldWidth,i为当前列下标.


  // AnsiChar6 = array [0..5] of AnsiChar;

function CodeInfoKey(CodeInfo: PCodeInfo): string; overload;

function CodeInfoKey(CodeType: short; const Code: string): string; overload;
// 市场
function CodeInfoKey(cAType: string; const Code: string): string; overload;

function GetKeyByZQLB(ZQSC: integer; ZQLB: integer; Code: string): string; overload;
function GetKeyByZQLB(ZQSC: integer; ZQLB: integer; Code: string; Suffix: string): string; overload;

function ATypeToCodeType(cAType: string): short;
function CTypeToCodeType(ctype: string): USHORT;

// 金融分类
function HSMarketType(CodeType: HSMarketDataType; Market: integer): boolean;
// 市场分类
function HSBourseType(CodeType: HSMarketDataType; Bourse: integer): boolean;
// 交易品种分类
function HSKindType(CodeType: HSMarketDataType; Kind: integer): boolean;

// 金融分类 + 市场分类
function HSMarketBourseType(CodeType: HSMarketDataType; Market, Bourse: integer): boolean;
// 金融 + 市场+ 品种分类
function HSMarketBourseKindType(CodeType: HSMarketDataType; Market, Bourse, Kind: integer): boolean;

function ToServerType(CodeType: HSMarketDataType): ServerTypeEnum;

function ServerTypeToStr(ServerType: ServerTypeEnum): string;

function CodeInfoToCode(P: PCodeInfo): string;
Function AnsiCharArrayToStr(Arr: Array of AnsiChar): string;

Function IsStockMajorIndex(CodeInfo: PCodeInfo): boolean;

implementation

function CodeInfoToCode(P: PCodeInfo): string;
var
  IBCode: Array [0 .. 20] of AnsiChar;
  tmp: Cardinal;
begin
  // if p = nil then exit('');
  if HSMarketType(P.m_cCodeType, Foreign_MARKET) then
  begin
    if HSMarketBourseType(P.m_cCodeType, Foreign_MARKET, YHJZQ_BOURSE) or // 银行间债券
      HSMarketBourseType(P.m_cCodeType, Foreign_MARKET, XHCJ_BOURSE) Or // 信用拆借
      HSMarketBourseType(P.m_cCodeType, Foreign_MARKET, ZYSHG_BOURSE) or // 质押式回购
      HSMarketBourseType(P.m_cCodeType, Foreign_MARKET, MDSHG_BOURSE) // 买断式回购
    then
    begin
      ZeroMemory(@IBCode[0], Length(IBCode));
      decodeInterbankBondCode(AnsiChar6(P.m_cCode), @IBCode[0], Length(IBCode));
      Result := AnsiCharArrayToStr(IBCode);
    end;
  end
  else if HSMarketBourseType(P.m_cCodeType, OPT_MARKET, OPT_SH_BOURSE) or // 个股期权 上海
    HSMarketBourseType(P.m_cCodeType, OPT_MARKET, OPT_SZ_BOURSE) then // 个股期权 深圳
  begin
    CopyMemory(@tmp, @P.m_cCode[0], SizeOf(integer));
    Result := IntToStr(tmp);
  end
  else
    Result := AnsiCharArrayToStr(P.m_cCode);
end;

Function AnsiCharArrayToStr(Arr: Array of AnsiChar): string;
var
  Str: Ansistring;
  Len: integer;
begin
  Len := Length(Arr);
  if Len < 1 then
    Exit('');
  if Arr[Len - 1] = #0 then
    Str := PAnsiChar(@Arr[0])
  else
  begin
    SetLength(Str, Len);
    ZeroMemory(@Str[1], Len);
    CopyMemory(@Str[1], @Arr[0], Len);
  end;
  Result := String(Str);
end;

function ToServerType(CodeType: HSMarketDataType): ServerTypeEnum;
begin
  // 股票 期权
  if HSMarketType(CodeType, STOCK_MARKET) or HSMarketType(CodeType, OPT_MARKET) then
  begin
    Result := stStockLevelI;
  end
  else if HSMarketType(CodeType, Other_MARKET) then
  begin
    Result := stStockLevelI;
  end
  else if HSMarketType(CodeType, FUTURES_MARKET) then
  begin
    Result := stFutues;
    // 港股主板
  end
  else if HSMarketType(CodeType, HK_MARKET) then
  begin
    Result := stStockHK;

  end
  else if HSMarketType(CodeType, Foreign_MARKET) then
  begin
    Result := stForeign;
  end
  else if HSMarketType(CodeType, US_MARKET) then
    Result := stUSStock
  else
    Result := stStockLevelI;
end;

// 金融 + 市场+ 品种分类
function HSMarketBourseKindType(CodeType: HSMarketDataType; Market, Bourse, Kind: integer): boolean;
begin
  Result := HSMarketType(CodeType, Market) and HSBourseType(CodeType, Bourse) and HSKindType(CodeType, Kind);
end;

// 金融 + 市场 分类
function HSMarketBourseType(CodeType: HSMarketDataType; Market, Bourse: integer): boolean;
begin
  Result := HSMarketType(CodeType, Market) and HSBourseType(CodeType, Bourse);
end;

// 金融分类
function HSMarketType(CodeType: HSMarketDataType; Market: integer): boolean;
begin
  Result := (CodeType and $F000) = Market;
end;

// 市场分类
function HSBourseType(CodeType: HSMarketDataType; Bourse: integer): boolean;
begin
  Result := (CodeType and $0F00) = Bourse;
end;

// 交易品种分类
function HSKindType(CodeType: HSMarketDataType; Kind: integer): boolean;
begin
  Result := (CodeType and $00FF) = Kind;
end;

function CodeInfoKey(CodeType: short; const Code: string): string;
begin
  // if True then

  if HSMarketBourseType(CodeType, STOCK_MARKET, SH_BOURSE) then
    Result := Code + '_' + SH_Suffix
  else if HSMarketBourseType(CodeType, STOCK_MARKET, SZ_BOURSE) then
    Result := Code + '_' + SZ_Suffix
  else if HSMarketBourseType(CodeType, STOCK_MARKET, GZ_BOURSE) then // 三板市场
    Result := Code + '_' + OC_Suffix
    // else if HSMarketType(CodeType, STOCK_MARKET) then
    // Result := Code + '_'
  else if HSMarketType(CodeType, FUTURES_MARKET) then // 期货
    Result := Code + '_' + FU_Suffix
  else if HSMarketType(CodeType, HK_MARKET) then // 港股
    Result := Code + '_' + HK_Suffix
  else if HSMarketBourseType(CodeType, Other_MARKET, ZZ_BOURSE) then // 中证/申万指数
    Result := Code + '_' + OT_Suffix
  else if HSMarketBourseType(CodeType, Other_MARKET, GN_BOURSE) then // 概念板块/地域板块指数
    Result := Code + '_' + OT_Suffix
  else if HSMarketBourseType(CodeType, Other_MARKET, ZX_BORRSE) then // 中信指数
    Result := Code + '_' + ZXI_Suffix
  else if HSMarketType(CodeType, Foreign_MARKET) then // 银行间债券
    Result := Code + '_' + IB_Suffix
  else if HSMarketType(CodeType, OPT_MARKET) then // 个股期权
    Result := Code + '_' + OPT_Suffix
  else if HSMarketType(CodeType, US_MARKET) then
    Result := Code + '_' + US_Suffix  //美股
  else
    Result := Code;
end;

function GetKeyByZQLB(ZQSC: integer; ZQLB: integer; Code: string): string;
begin
  if (ZQSC in [76,77,78]) then
    Result := Code
  else
    Result := Copy(Code, 1, 6);
  if ZQLB = 110 then
  begin
    Result := Code + '_' + OPT_Suffix; // 个股期权
    Exit;
  end;
  case ZQSC of
    83:
      begin // 上海市场
        if (ZQLB = 4) then // 指数
        begin
          if (pos('2D', Code) = 1) then // 中证/申万指数
            Result := Result + '_' + OT_Suffix
          else if (pos('CI', Code) = 1) then // 中信指数
            Result := Copy(Code, 3, 100) + '_' + ZXI_Suffix
          else
            Result := Result + '_' + SH_Suffix;
        end
        else
          Result := Result + '_' + SH_Suffix; // 上海证券交易所
      end;
    90:
      Result := Result + '_' + SZ_Suffix; // 深圳证券交易所
    81:
      Result := Result + '_' + OC_Suffix; // 三板市场
    10, 13, 15, 19, 20:
      Result := Result + '_' + FU_Suffix; // 期货
    72:
      Result := Result + '_' + HK_Suffix; // 香港联交所
    76,77,78:
      Result := Result + '_' + US_Suffix; // 美股
    84:
      begin
        case ZQLB of
          910:
            begin
              Result := Copy(Code, 3, 6) + '_' + OT_Suffix; // 概念板块去掉前面的28
            end;
          920:
            begin
              Result := 'DY' + Copy(Code, 5, 6) + '_' + OT_Suffix; // 地域板块前面的2800替换为DY
            end;
        else
          Result := Result + '_' + OT_Suffix; // 其他指数
        end;
      end;
    89:
      Result := Code + '_' + IB_Suffix; // 银行间债券
    0:
      case ZQLB of
        910:
          begin
            Result := Copy(Code, 3, 6) + '_' + OT_Suffix; // 概念板块去掉前面的28
          end;
        920:
          begin
            Result := 'DY' + Copy(Code, 5, 6) + '_' + OT_Suffix; // 地域板块前面的2800替换为DY
          end;
      end;
  end;
end;

function GetKeyByZQLB(ZQSC: integer; ZQLB: integer; Code: string; Suffix: string): string;
begin
  if (ZQSC in [76,77,78,79]) then
    Result := Code
  else
    Result := Copy(Code, 1, 6);
  if ZQLB = 110 then
  begin
    Result := Code + '_' + OPT_Suffix; // 个股期权
    Exit;
  end;
  case ZQSC of
    83:
      begin // 上海市场
        if (ZQLB = 4) then // 指数
        begin
          if (pos('2D', Code) = 1) or (Suffix = 'CSI') then // 中证/申万指数
            Result := Result + '_' + OT_Suffix
          else if (pos('CI', Code) = 1) then // 中信指数
            Result := Copy(Code, 3, 100) + '_' + ZXI_Suffix
          else
            Result := Result + '_' + SH_Suffix;
        end
        else
          Result := Result + '_' + SH_Suffix; // 上海证券交易所
      end;
    90:
      Result := Result + '_' + SZ_Suffix; // 深圳证券交易所
        81:
      Result := Result + '_' + OC_Suffix; // 三板市场
        10, 13, 15, 19, 20:
      Result := Result + '_' + FU_Suffix; // 期货
        72:
      Result := Result + '_' + HK_Suffix; // 香港联交所
    76,77,78,79:
      Result := Result + '_' + US_Suffix; // 美股
        84:
      begin
        case ZQLB of
          910, 930:
            begin
//              Result := Copy(Code, 3, 6) + '_' + OT_Suffix;
              Result := Copy(Result, 3, 6) + '_' + OT_Suffix; // 概念板块去掉前面的28
            end;
          920:
            begin
              Result := 'DY' + Copy(Code, 5, 6) + '_' + OT_Suffix; // 地域板块前面的2800替换为DY
            end;
        else
          Result := Result + '_' + OT_Suffix; // 其他指数
        end;
      end;
    89:
      Result := Code + '_' + IB_Suffix; // 银行间债券
        0:
      case ZQLB of
        910, 930:
          begin
//            Result := Copy(Code, 3, 6) + '_' + OT_Suffix;
            Result := Copy(Result, 3, 6) + '_' + OT_Suffix; // 概念板块去掉前面的28
          end;
        920:
          begin
            Result := 'DY' + Copy(Code, 5, 6) + '_' + OT_Suffix; // 地域板块前面的2800替换为DY
          end;
      end;
  end;
end;

function CTypeToCodeType(ctype: string): USHORT;
begin
  if ctype = SH_Suffix then // 83 上海证券交易所
    Result := STOCK_MARKET or SH_BOURSE
  else if ctype = SZ_Suffix then
    Result := STOCK_MARKET or SZ_BOURSE
  else if ctype = OC_Suffix then // 81三板市场
    Result := STOCK_MARKET or GZ_BOURSE
  else if ctype = FU_Suffix then // 期货  400000
    Result := FUTURES_MARKET
  else if ctype = HK_Suffix then // 港股  300000
    Result := HK_MARKET
  else if ctype = OT_Suffix then
    Result := Other_MARKET
  else if ctype = IB_Suffix then // 银行间债券
    Result := Foreign_MARKET
  else if ctype = OPT_Suffix then
    Result := OPT_MARKET
  else
    Result := 0;
end;

function ATypeToCodeType(cAType: string): short;
begin
  if cAType = '83' then // 83 上海证券交易所
    Result := STOCK_MARKET or SH_BOURSE
  else if cAType = '81' then // 81三板市场
    Result := STOCK_MARKET or SZ_BOURSE
  else if cAType = '90' then // 90 深圳证券交易所
    Result := STOCK_MARKET or SZ_BOURSE
  else
    Result := 0;
end;

function CodeInfoKey(cAType: string; const Code: string): string; overload;
begin
  Result := CodeInfoKey(ATypeToCodeType(cAType), Code);
end;

function CodeInfoKey(CodeInfo: PCodeInfo): string;
begin
  Result := CodeInfoKey(CodeInfo^.m_cCodeType, CodeInfoToCode(CodeInfo));
end;

function ServerTypeToStr(ServerType: ServerTypeEnum): string;
begin
  case ServerType of
    stStockLevelI:
      Result := 'stStockLevelI';
    stStockLevelII:
      Result := 'stStockLevelII';
    stFutues:
      Result := 'stFutues';
    stStockHK:
      Result := 'stStockHK';
    stForeign:
      Result := 'stForeign';
    stDDE:
      Result := 'stDDE';
    stUSStock:
      Result := 'stUSStock';
  else
    Result := 'unknown'
  end;
end;

Function IsStockMajorIndex(CodeInfo: PCodeInfo): boolean;
var
  HSCode: Ansistring;
begin

  Result := HSMarketType(CodeInfo.m_cCodeType, STOCK_MARKET) and HSKindType(CodeInfo.m_cCodeType, KIND_INDEX);
  if Result then
  begin
    HSCode := Ansistring(SH_MajorIndex_HSCODE);
    Result := CompareMem(@CodeInfo.m_cCode[0], @HSCode[1], Length(HSCode));
    if Result then
      Exit;
    HSCode := Ansistring(SZ_MajorIndex_HSCODE);
    Result := CompareMem(@CodeInfo.m_cCode[0], @HSCode[1], Length(HSCode));
  end;
end;

end.
