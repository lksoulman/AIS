unit QuoteConst;

interface

uses Windows, Messages;

const

  SH_MajorIndex_HSCODE = '1A0001'; // 上证指数恒生代码
  SZ_MajorIndex_HSCODE = '2A01'; // 深证成指恒生代码

  MaxCount = 100000;
  MAX_MULTITREND_COUNT = 10;

  PATH_Setting = 'Setting\'; // 基础配置目录夹
  PATH_Block = 'Block\'; // 系统板块目录夹
  PATH_UserBlock = 'UserBlock\'; // 用户板块目录夹
  PATH_Data = 'Data\'; // 数据目录夹

  PATH_Data_SH_Day = 'Data\sh\day\';
  PATH_Data_SH_min1 = 'Data\sh\min1\';
  PATH_Data_SH_min5 = 'Data\sh\min5\';

  PATH_Data_SZ_Day = 'Data\sz\day\';
  PATH_Data_SZ_min1 = 'Data\sz\min1\';
  PATH_Data_SZ_min5 = 'Data\sz\min5\';

  EX_RIGHT_FILE = 'exright.dat'; // 除权数据文件
  CURRENT_FINANCE_FILE = 'curfinance.fin'; // 最新财务数据
  HIS_FINANCE_DAT_FILE = 'hisfinance.dat'; // 历史财务报表数据文件
  BLOCK_DEF_FILE = 'block.def';

  PYJC_MAX_LENGTH = 16; // 拼音长度
  STOCK_NAME_SIZE = 16; // 股票名称长度
  MAX_HQCOL_COUNT = 8; // RT_HQCOL_VALUE 一次查询的最大行情字段数

  // Update_RealTime begin
  // 设置数据
  Update_RealTime_Codes_SetData = $0002;
  // 复权数据
  Update_RealTime_ExRight_SetData = $0003;
  // 财务数据
  Update_RealTime_Finance_SetData = $0004;
  // 完整报价数据
  Update_RealTime_RealTimeData = $0005;
  // 更新Level2 报价牌
  Update_RealTime_Level_RealTimeData = $0006;

  Update_RealTime_RealTimeDataExt = $0007;

  Update_RealTime_Server_Calc = $0008;

  Update_RealTime_DelayDataExt = $0009;

  // Update_RealTime end

  // Update_TechData begin
  // 完整分时数据
  Update_Trend_TrendData = $0001;

  Update_Trend_TrendData_Ext = $0008;
  // 推送数据
  Update_Trend_AutoPush = $0002;
  // 历史分时
  Update_Trend_HisTrendData = $0003;

  Update_Trend_MultiHisTrendData = $0004;

  Update_Trend_MAjorIndexLeadData = $0005;

  Update_Trend_MAjorIndexTickData = $0006;

  Update_Trend_VirtualAuction = $0007;

  Update_Trend_AutoPush_Ext = $0009;

  Update_Trend_DelayAutoPush_Ext = $000A;
  // Update_TechData end

  // Update_StockTick begin
  // 完整分笔数据
  Update_StockTick_StockTickData = $0001;
  // 推送数据
  Update_StockTick_AutoPush = $0002;

  Update_StockTick_AutoPush_Ext = $0003;
  // Update_StockTick  end;

  // Update_Tech begin
  // 完整当前数据
  Update_Tech_TechData = $0001;
  // 增量历史数据
  Update_Tech_DiffData = $0002;
  // 推送数据
  Update_Tech_AutoPush = $0003;

  Update_Tech_Busy = $0004;

  Update_Tech_WaitCount = $0005;

  Update_Tech_ResetWaitCount = $0006;

  Update_Tech_TechCurrData = $0007;

  Update_Tech_AutoPush_Ext = $0008;

  // 数据长度
  State_Tech_DataLen = $0101;
  // 版本号
  State_Tech_VarCode = $0102;

  State_Tech_IsBusy = $0103;

  State_Tech_WaitCount = $0104;
  // Update_Tech end

  // Update_ReprotSort begin
  Update_ReprotSort_Data = $0001;
  // Update_ReprotSort end

  // Update_GeneralSort begin
  Update_GeneralSort_ReqGeneralSort = $0001;

  Update_GeneralSort_Data = $0002;

  State_GeneralSort_RefCount = $0101;

  // Update_GeneralSort end

  // Update_Transaction begin
  Update_Transaction_Data = $0001;
  Update_TransactionAuto_Data = $0002;

  // Update_Transaction end

  // Update_OrderQueue begin
  Update_OrderQueue_Data = $0001;

  // Update_OrderQueue end

  // Update_TOTALMAX begin
  Update_TOTALMAX_Data = $0001;
  Update_TOTALMAXAuto_Data = $0002;
  // Update_TOTALMAX end

  // Update_SINGLEMA begin
  Update_SINGLEMA_Data = $0001;
  Update_SINGLEMAAuto_Data = $0002;
  // Update_SINGLEMA end
  RT_BEGIN = $0100;
  RT_END = $8FFF;

  BLOCK_NAME_LENGTH = 32;

  RT_COMPASKDATA = $8FFE; // 组合请求类型
  RT_ZIPDATA = $8001; // 压缩返回包类型

  RT_JAVA_MARK = $0010; // JAVA登录 | RT_LOGIN_*
  RT_WINCE_MARK = $0020; // WINCE登录 | RT_LOGIN_*
  RT_NOTZIP = $0040; // 不使用压缩数据传输
  RT_DEBUG = $0080; // 纪录客户请求日志 maxy add 20090908

  RT_INITIALINFO = $0101; // 客户端数据所有初始化
  RT_LOGIN = $0102; // 客户端登录行情服务器
  RT_SERVERINFO = $0103; // 主站信息
  RT_BULLETIN = $0104; // 紧急公告(主推)
  RT_PARTINITIALINFO = $0105; // 客户端数据部分初始化
  RT_ETF_INIT = $0106; // 52只股票数据(ETF)
  RT_LOGIN_HK = $0107; // 客户端登录港股服务器
  RT_LOGIN_FUTURES = $0108; // 客户端登录期货服务器
  RT_LOGIN_FOREIGN = $0109; // 客户端登录外汇服务器
  RT_LOGIN_WP = $010A; // 客户端登录外盘服务器
  RT_LOGIN_INFO = $010B; // 客户端登录资讯服务器
  RT_CHANGE_PWD = $010C; // 修改密码

  // ghm add level2 登陆请求
  RT_LOGIN_LEVEL = $010D; // level2登陆请求
  RT_SERVERINFO2 = $010E; // 主站信息2
  RT_VERIFYINFO = $010F; // 用户认证信息返回
  RT_MODIFY_LV2PWD = $0112; // 修改Level2用户密码
  RT_DISCONNLEVEL2 = $0113; // level2断线
  RT_INITIALINFO_VARCODE = $0134; // 变长代码的初始化信息
  RT_LOGIN_DDE = $0122; // 客户端登录DDE行情服务器
  RT_LOGIN_US = $0124; // 美股登陆行情服务器

  RT_REALTIME = $0201; // 行情报价表:1-6乾隆操作键
  RT_DYNREPORT = $0202; // 强弱分析;指标排序;热门板块分析;区间分析;跑马灯股票列表数据;预警
  RT_REPORTSORT = $0203; // 排名报价表:61-66、点击列排序
  RT_GENERALSORT = $0204; // 综合排名报表:81-86
  RT_GENERALSORT_EX = $0205; // 综合排名报表:81-86加入自定义分钟排名
  RT_SEVER_EMPTY = $0206; // 服务器无数据返回空包
  RT_SEVER_CALCULATE = $0207; // 服务器计算数据包,包括涨停、跌停
  RT_ANS_BYTYPE = $0208; // 根据类型返回数据包
  RT_QHMM_REALTIME = $0209; // 期货买卖盘
  RT_LEVEL_REALTIME = $020A; // level
  RT_CLASS_REALTIME = $020B; // 根据分类类别获取行情报价
  // ghm add level2其他数据查询消息
  RT_LEVEL_ORDERQUEUE = $020C; // level2买卖队列
  RT_LEVEL_TRANSACTION = $020D; // LEVEL2逐笔成交
  RT_QHARB_REALTIME = $020E; // 期货套利报价 maxy add
  RT_REALTIME_EXT = $020F; // 扩展的行情报价盘 maxy add

  RT_REALTIME_EXT_DELAY = $0223; // 用于美股延时

  RT_QZINFO = $0211; // 权证信息

  RT_HQCOL_VALUE = $0216; // 按行情列ID查询行情字段值

  RT_TREND = $0301; // 分时走势
  RT_ADDTREND = $0302; // 走势图叠加、多股同列
  RT_BUYSELLPOWER = $0303; // 买卖力道
  RT_HISTREND = $0304; // 历史回忆;多日分时;右小图下分时走势
  RT_TICK = $0305; // TICK图
  RT_ETF_TREND = $0306; // ETF分时走势
  RT_ETF_NOWDATA = $0307; // ETF时时数据
  RT_ETF_TREND_TECH = $0308; // ETFtech分时走势
  RT_HISTREND_INDEX = $0309; // 对于大盘领先-历史回忆;多日分时;右小图下分时走势
  RT_AUTOARBPUSH = $030A; // 期货套利报价 maxy add
  RT_TREND_EXT = $030B; // 扩展的分时请求 maxy add
  RT_VIRTUAL_AUCTION = $030E; // 集合竞价数据请求

  RT_TECHDATA = $0400; // 盘后分析
  RT_FILEDOWNLOAD = $0401; // 文件请求（盘后数据下载）
  RT_TECHDATA_EX = $0402; // 盘后分析扩展 -- 支持基金净值
  RT_DATA_WEIHU = $0403; // 数据维护处理
  RT_FILEDOWNLOAD2 = $0404; // 下载服务器指定目录文件
  RT_FILED_CFG = $0405; // 配置文件升级/更新
  RT_FILL_DATA = $0406; // 补线处理
  RT_TECHDATA_BYPERIOD = $0407; // 盘后分析扩展 -- 支持不同周期转换
  RT_TECHDATA_INCREMENT = $0408; // 盘后分析扩展 -- 增量数据请求
  RT_TECHDATA_RANGE = $0410; // 分段盘后分析 add by maxy 20090714

  RT_MARKET_MONITOR_SUPPORT_QUERY = $0907; // 短线精灵支持市场查询校验
  RT_MARKET_MONITOR_AUTOPUSH = $0A17; // 短线精灵主推
  RT_MARKET_MONITOR_STOCK_QUERY = $0908; // 查询单只股票所有短线精灵事件
  RT_MARKET_MONITOR_DATE_QUERY = $0909; // 按日期和市场查询短线精灵事件

  RT_TEXTDATAWITHINDEX_PLUS = $0501; // 正序资讯索引数据
  RT_TEXTDATAWITHINDEX_NEGATIVE = $0502; // 倒序资讯索引数据
  RT_BYINDEXRETDATA = $0503; // 资讯内容数据
  RT_USERTEXTDATA = $0504; // 自定义资讯请求（如菜单等）
  RT_FILEREQUEST = $0505; // 配置文件文件
  RT_FILESimplify = $0506; // 精简文件请求
  RT_ATTATCHDATA = $0507; // 附件数据
  RT_PROMPT_INFO = $0508; // 服务器设置的提示信息
  RT_CODELINK_INFO = $0509; // 关联股票 maxy add

  RT_STOCKTICK = $0601; // 个股分笔、个股详细的分笔数据
  RT_BUYSELLORDER = $0602; // 个股买卖盘
  RT_LIMITTICK = $0603; // 指定长度的分笔请求
  RT_HISTORYTICK = $0604; // 历史的分笔请求
  RT_MAJORINDEXTICK = $0605; // 大盘明细
  RT_VALUE = $0606; // 右小图“值”
  RT_BUYSELLORDER_HK = $0607; // 个股买卖盘(港股）
  RT_BUYSELLORDER_FUTURES = $0608; // 个股买卖盘(期货）
  RT_VALUE_HK = $0609; // 右小图“值”(港股),右小图也发此请求
  RT_VALUE_FUTURES = $060A; // 右小图“值”(期货),左下小图也发此请求
  RT_TOTAL = $060B; // 总持请求包

  RT_LEAD = $0702; // 大盘领先指标
  RT_MAJORINDEXTREND = $0703; // 大盘走势
  RT_MAJORINDEXADL = $0704; // 大盘走势－ADL
  RT_MAJORINDEXBBI = $0705; // 大盘走势－多空指标
  RT_MAJORINDEXBUYSELL = $0706; // 大盘走势－买卖力道
  RT_SERVERFILEINFO = $0707; // 服务器自动推送要更新的文件信息
  RT_DOWNSERVERFILEINFO = $0708; // 下载-服务器自动推送要更新的文件信息

  RT_CURRENTFINANCEDATA = $0801; // 最新的财务数据
  RT_HISFINANCEDATA = $0802; // 历史财务数据
  RT_EXRIGHT_DATA = $0803; // 除权数据
  RT_HK_RECORDOPTION = $0804; // 港股期权
  RT_BROKER_HK = $0805; // 港股经纪席位下委托情况;  // 看我们的服务器是否生成此数据
  RT_BLOCK_DATA = $0806; // 板块数据
  RT_USER_BLOKC_DATA = $0810;
  RT_STATIC_HK = $0807; // 港股静态数据

  // zxw add 按代码请求财务数据和除权数据
  RT_FINANCE_BYCODE = $0808;
  RT_EXRIGHT_BYCODE = $0809;

  RT_ONE_BLOCKDATA = $0408; // 一个板块数据请求

  RT_MASSDATA = $0901; // 大单
  RT_SERVERTIME = $0902; // 服务器当前时间
  RT_KEEPACTIVE = $0903; // 保活通信包
  RT_TEST = $0904; // 测试通信包
  RT_TESTSRV = $0905; // 测试客户端到服务器是否通畅
  RT_PUSHINFODATA = $0906; // 资讯实时主推

  RT_AUTOPUSH = $0A01; // 常用主推;  // 改RealTimeData 为 CommRealTimeData
  RT_AUTOPUSHSIMP = $0A02; // 精简主推;  // 改为请求主推
  RT_REQAUTOPUSH = $0A03; // 请求主推,应用于：预警、跑马灯;  // 改RealTimeData 为 CommRealTimeData
  RT_ETF_AUTOPUSH = $0A04; // ETF主推
  RT_AUTOBROKER_HK = $0A05; // 经纪主推
  RT_AUTOTICK_HK = $0A06; // 港股分笔主推
  RT_AUTOPUSH_QH = $0A07; // 期货最小主推
  RT_PUSHREALTIMEINFO = $0A08; // 实时解盘主推
  RT_RAW_AUTOPUSH = $0A09; // 数据源原始数据主推

  RT_QHMM_AUTOPUSH = $0A0A; // 期货买卖盘主推
  RT_LEVEL_AUTOPUSH = $0A0B; // level主推
  // ghm add level2其他数据主推消息
  RT_LEVEL_BORDERQUEUE_AUTOPUSH = $0A0C; // LEVEL2买卖队列买方向主推
  RT_LEVEL_SORDERQUEUE_AUTOPUSH = $0A0D; // LEVEL2买卖队列卖方向主推
  RT_LEVEL_TRANSACTION_AUTOPUSH = $0A0E; // LEVEL2逐笔成交主推
  RT_AUTOPUSH_EXT = $0A0F; // 扩展的常用主推 maxy add

  RT_AUTOPUSH_EXT_DELAY = $0A1F; // 延时扩展主推，主要用于美股

  // 个股龙虎看盘
  RT_DDE_BIGORDER_REALTIME_BYTRANS = $091C;
  RT_DDE_BIGORDER_REALTIME_BYORDER = $0910;
  // 个股多日历史龙虎看盘
  RT_DDE_BIGORDER_HIS = $0911;

  // DDE Level2缓存逐笔
  RT_DDE_TRANSACTION_BYTRANS = $0912;
  RT_DDE_TRANSACTION_BYORDER = $0913;

  // DDE 委托队列
  RT_DDE_ORDEQUEUE = $0914;
  // 历史DDE指标包含：DDX、DDY、DDZ
  // 个股DDE指标：单股票多日DDE数据
  RT_DDE_HISTORY = $0915;
  // 历史DDE指标包含：DDX、DDY、DDZ
  // 、5日DDX、5日DDY、5日DDZ指标；60日DDX、60日DDY、60日DDZ指标；
  // DDX飘红天数（10内）、DDX飘红天数（连续）
  // 用于DDE决策：多股票当日DDE数据，中长线DDE指标

  RT_DDE_REALTIME = $0916;

  // 当日分时DDE指标：DDX、DDY、DDZ
  RT_DDE_TREND = $0917;

  // 个股当日分时大小单分类成交统计数据
  RT_DDE_BIGORDER_TREND = $0918;

  // 历史主力机构分类成交统计数据
  // 个股历史主力机构统计数据：主力机构线
  RT_DDE_MASS_HISTORY = $0919;

  // 主力机构看盘数据
  RT_DDE_MASS_REALTIME = $091A;

  // 当日分时主力机构分类成交统计数据
  RT_DDE_MASS_TREND = $091B;

  // Level2主推逐笔，带逐笔算法大小单标识
  RT_DDE_TRANSACTION_BYTRANS_AUTOPUSH = $0A20;
  // Level2主推逐笔，带逐单算法大小单标识）
  RT_DDE_TRANSACTION_BYORDER_AUTOPUSH = $0A21;
  // 委托队列快照
  RT_DDE_ORDERQUEUE_AUTOPUSH = $0A22;
  // 委托队列增量变化信息
  RT_DDE_ORDERQUEUE_DETAIL_AUTOPUSH = $0A23;
  // 订阅Level2深度分析逐笔大小单统计快照数据。主要用于个股龙虎看盘逐笔统计界面。
  RT_DDE_BIGORDER_BYTRANS_AUTOPUSH = $0A24;
  // 当前逐单大小单统计快照
  RT_DDE_BIGORDER_BYORDER_AUTOPUSH = $0A25;
  // 个股精灵信息
  // 订阅Level2深度分析的一些有关大小单、主力机构的监控信息。包括：主力大单、机构买单、机构卖单、机构吃货、机构吐货等
  RT_DDE_MONITION = $0A26;

  // zxw add level2Cancellation 主推
  RT_LEVEL_TOTALMAX_AUTOPUSH = $0A10; // LEVEL2单笔撤单主推排名
  RT_LEVEL_SINGLEMA_AUTOPUSH = $0A11; // LEVEL2累计撤单主推排名

  RT_AUTOPUSH_RES = $0A12; // 预留的常用主推 maxy add
  RT_AUTOPUSH_LV2RES = $0A13; // 预留的level2主推 maxy add

  // zxw add
  RT_LEVEL_TOTALMAX = $2001; // 查询
  RT_LEVEL_SINGLEMAX = $2002;

  RT_UPDATEDFINANCIALDATA = $0B01; // 增量的财务报表数据
  RT_SYNCHRONIZATIONDATA = $0B02; // 数据同步处理

  //
  RT_Send_Notice = $0C01; // 发表公告
  RT_Send_ScrollText = $0C02; // 发表滚动信息
  RT_Change_program = $0C03; // 更改服务器程序
  RT_Send_File_Data = $0C04; // 发送文件到服务器
  RT_RequestDBF = $0C05; // 请求DBF文件

  RT_InfoSend = $0C06; // 发布信息
  RT_InfoUpdateIndex = $0C07; // 更新信息索引
  RT_InfoUpdateOneIndex = $0C08; // 更新一条信息索引
  RT_NoteMsgData = $0C09; // 定制短信数据传送
  RT_InfoDataTransmit = $0C0A; // 验证转发
  RT_InfoCheckPurview = $0C0B; // 返回注册详细分类信息
  RT_InfoClickTime = $0C0C; // 点击次数

  RT_REPORTSORT_Simple = $0D01; // 排名报价表:61-66、点击列排序（精简）
  RT_PARTINITIALINFO_Simple = $0D02; // 代码返回
  RT_RETURN_EMPTY = $0D03; // 返回空的数据包
  RT_InfoDataRailing = $0D04; // 请求栏目

  // wince 相关
  RT_WINCE_FIND = $0E01; // 查找代码
  RT_WINCE_UPDATE = $0E02; // CE版本升级
  RT_WINCE_ZIXUN = $0E03; // CE资讯请求

  RT_Srv_SrvStatus = $0F01; // 后台程序运行状态

  // wince 客户端使用的协议
  Session_Socket = $0001; // socket
  Session_Http = $0002; // http

  WINCEZixun_StockInfo = $1000; // 个股资讯


  // AskData 中 m_nOption 指向的类型

  // 公告信息配置
  Notice_Option_WinCE = $0001; // 公告信息只对WinCE用户//
  Notice_Option_SaveSrv = $0002; // 公告信息在服务器自动保存。
  Login_Option_Password = $0004; // 登陆时使用新的加密方式。
  Login_Option_NotCheck = $0008; // 不检测用户。

  // AskData 中 m_nOption 指向的类型,为子类型
  ByType_LevelStatic = $1000; // 数据类型 LevelStatic
  ByType_LevelRealTime = $2000; // 数据类型 LevelRealTime

  // 市场到俺码转换
  Market_STOCK_MARKET = $0001; // 股票
  Market_HK_MARKET = $0002; // 港股
  Market_WP_MARKET = $0004; // 外盘
  Market_FUTURES_MARKET = $0008; // 期货
  Market_FOREIGN_MARKET = $0010; // 外汇

  Market_Address_Changed = $0020; // 当前服务器需要地址切换
  Market_Client_ForceUpdate = $0040; // 当前客户端必须升级才能够使用
  Market_DelayUser = $0080; // 当前用户为延时用户，在港股连接时使用
  Market_TestSrvData = $0100; // 是否支持测试
  Market_UserCheck = $0200; // 返回数据中包含用户资讯权限信息
  Market_LOGIN_INFO = $0400; // 资讯

  Market_STOCK_LEVEL = $0800; // level2
  Market_SrvInfo = $2000; // 服务器返回信息,参见结构：TestSrvInfoData

  // Market_SrvLoad = $0800 ;  // 需要服务器返回负载信息,参见结构：TestSrvLoadData
  // Market_SrvCheckError = $1000 ;  // 登陆验证服务器失败

  // Market_STOCK_MARKET_CH = $0100;  // 股票改变
  // Market_HK_MARKET_CH = $0200 ;  // 港股改变
  // Market_WP_MARKET_CH = $0400 ;  // 外盘改变
  // Market_FUTURES_MARKET_CH = $0800 ;  // 期货改变
  // Market_FOREIGN_MARKET_CH = $1000 ;  // 外汇改变

  // 服务器
  //
  RT_Srv_Sub_Restart = $0001; // 重新启动程序
  RT_Srv_Sub_Replace = $0002; // 替换程序

  RT_Srv_Sub_DownCFG = $0003; // 下载配置文件
  RT_Srv_Sub_UpCFG = $0004; // 上传配置文件

  RT_Srv_Sub_DownUserDB = $0005; // 下载用户管理文件文件
  RT_Srv_Sub_UpUserDB = $0006; // 上传用户管理文件文件

  RT_Srv_Sub_DownReport = $0007; // 下载后台程序报告文件
  RT_Srv_Sub_LimitPrompt = $0008; // 权限错误提示

  RT_Srv_Sub_Succ = $1000; // 操作成功提示


  // 请求/返回 DEFINE END

  // 实时数据俺码　DEFINE BEGIN
  MASK_REALTIME_DATA_OPEN = $00000001; // 今开盘
  MASK_REALTIME_DATA_MAXPRICE = $00000002; // 最高价
  MASK_REALTIME_DATA_MINPRICE = $00000004; // 最低价
  MASK_REALTIME_DATA_NEWPRICE = $00000008; // 最新价

  MASK_REALTIME_DATA_TOTAL = $00000010; // 成交量(单位:股)
  MASK_REALTIME_DATA_MONEY = $00000020; // 成交金额(单位:元)

  MASK_REALTIME_DATA_BUYPRICE1 = $00000040; // 买１价
  MASK_REALTIME_DATA_BUYCOUNT1 = $00000080; // 买１量
  MASK_REALTIME_DATA_BUYPRICE2 = $00000100; // 买２价
  MASK_REALTIME_DATA_BUYCOUNT2 = $00000200; // 买２量
  MASK_REALTIME_DATA_BUYPRICE3 = $00000400; // 买３价
  MASK_REALTIME_DATA_BUYCOUNT3 = $00000800; // 买３量
  MASK_REALTIME_DATA_BUYPRICE4 = $00001000; // 买４价
  MASK_REALTIME_DATA_BUYCOUNT4 = $00002000; // 买４量
  MASK_REALTIME_DATA_BUYPRICE5 = $00004000; // 买５价
  MASK_REALTIME_DATA_BUYCOUNT5 = $00008000; // 买５量

  MASK_REALTIME_DATA_SELLPRICE1 = $00010000; // 卖１价
  MASK_REALTIME_DATA_SELLCOUNT1 = $00020000; // 卖１量
  MASK_REALTIME_DATA_SELLPRICE2 = $00040000; // 卖２价
  MASK_REALTIME_DATA_SELLCOUNT2 = $00080000; // 卖２量
  MASK_REALTIME_DATA_SELLPRICE3 = $00100000; // 卖３价
  MASK_REALTIME_DATA_SELLCOUNT3 = $00200000; // 卖３量
  MASK_REALTIME_DATA_SELLPRICE4 = $00400000; // 卖４价
  MASK_REALTIME_DATA_SELLCOUNT4 = $00800000; // 卖４量
  MASK_REALTIME_DATA_SELLPRICE5 = $01000000; // 卖５价
  MASK_REALTIME_DATA_SELLCOUNT5 = $02000000; // 卖５量

  MASK_REALTIME_DATA_PERHAND = $04000000; // 股/手 单位
  MASK_REALTIME_DATA_NATIONAL_DEBT_RATIO = $08000000; // 国债利率
  // 以下为高32位  m_lReqMask1 对应StockOtherData结构
  MASK_REALTIME_DATA_TIME = $00000001; // 距开盘分钟数
  MASK_REALTIME_DATA_CURRENT = $00000002; // 现手
  MASK_REALTIME_DATA_OUTSIDE = $00000004; // 外盘
  MASK_REALTIME_DATA_INSIDE = $00000008; // 内盘
  MASK_REALTIME_DATA_OPEN_POSITION = $00000010; // 今开仓
  MASK_REALTIME_DATA_CLEAR_POSITION = $00000020; // 今平仓
  MASK_REALTIME_DATA_CODEINFO = $10000000; // 代码

  // 增加列定义说明
  MASK_REALTIME_DATA_BUYORDER1 = $00000080; // 买1盘数
  MASK_REALTIME_DATA_BUYORDER2 = $00000100; // 买2盘数
  MASK_REALTIME_DATA_BUYORDER3 = $00000200; // 买3盘数
  MASK_REALTIME_DATA_BUYORDER4 = $00000400; // 买4盘数
  MASK_REALTIME_DATA_BUYORDER5 = $00000800; // 买5盘数

  MASK_REALTIME_DATA_SELLORDER1 = $00001000; // 卖1盘数
  MASK_REALTIME_DATA_SELLORDER2 = $00002000; // 卖2盘数
  MASK_REALTIME_DATA_SELLORDER3 = $00004000; // 卖3盘数
  MASK_REALTIME_DATA_SELLORDER4 = $00008000; // 卖4盘数
  MASK_REALTIME_DATA_SELLORDER5 = $00010000; // 卖5盘数


  // 实时数据俺码　DEFINE END

  // 综合排名排序类型掩码 DEFINE BEGIN
  RT_RISE = $0001; // 涨幅排名
  RT_FALL = $0002; // 跌幅排名
  RT_5_RISE = $0004; // 5分钟涨幅排名
  RT_5_FALL = $0008; // 5分钟跌幅排名
  RT_AHEAD_COMM = $0010; // 买卖量差(委比)正序排名
  RT_AFTER_COMM = $0020; // 买卖量差(委比)倒序排名
  RT_AHEAD_PRICE = $0040; // 成交价震幅正序排名
  RT_AHEAD_VOLBI = $0080; // 成交量变化(量比)正序排名
  RT_AHEAD_MONEY = $0100; // 资金流向正序排名
  // 综合排名排序类型掩码 DEFINE END

  // K线请求的周期类型 BEGIN
  PERIOD_TYPE_DAY = $0010; // 分析周期：日
  PERIOD_TYPE_MINUTE1 = $00C0; // 分析周期：1分钟
  PERIOD_TYPE_MINUTE5 = $0030; // 分析周期：5分钟
  PERIOD_TYPE_MINUTE15 = $0040;
  PERIOD_TYPE_MINUTE30 = $0050;
  PERIOD_TYPE_MINUTE60 = $0060;
  PERIOD_TYPE_WEEK = $0080;
  PERIOD_TYPE_MONTH = $0090;

  // K线请求的周期类型 END

  // 金融大类
  OPT_MARKET = $7000; // 个股期权

  OPT_SH_BOURSE = $0100; // 上海
  OPT_SZ_BOURSE = $0200; // 深圳

  STOCK_MARKET = $1000; // 股票
  SH_BOURSE = $0100; // 上海
  SZ_BOURSE = $0200; // 深圳
  BK_BOURES = $0300; // 板块
  SYSBK_BOURSE = $0400; // 系统板块
  USERDEF_BOURSE = $0800; // 自定义（自选股或者自定义板块）
  GZ_BOURSE = $0C00; // 新三板市场
  KIND_INDEX = $0000; // 指数
  KIND_STOCKA = $0001; // A股
  KIND_STOCKB = $0002; // B股
  KIND_BOND = $0003; // 债券
  KIND_FUND = $0004; // 基金
  KIND_THREEBOAD = $0005; // 三板
  KIND_SMALLSTOCK = $0006; // 中小盘股
  KIND_PLACE = $0007; // 配售
  KIND_LOF = $0008; // LOF
  KIND_ETF = $0009; // ETF
  KIND_QuanZhen = $000A; // 权证
  KIND_VENTURE = $000D; // 创业板

  KIND_OtherIndex = $000E; // 第三方行情分类，如:中信指数

  SC_Others = $000F; // 其他 = $09
  KIND_USERDEFINE = $0010; // 自定义指数

  // 港股市场
  HK_MARKET = $2000; // 港股分类
  HK_BOURSE = $0100; // 主板市场
  GE_BOURSE = $0200; // 创业板市场(Growth Enterprise Market)
  INDEX_BOURSE = $0300; // 指数市场
  HK_KIND_INDEX = $0000; // 港指
  HK_KIND_FUTURES_INDEX = $0001; // 期指
  // KIND_Option = $0002	;        // 港股期权

  HK_KIND_BOND = $0000; // 债券
  HK_KIND_MulFund = $0001; // 一揽子认股证
  HK_KIND_FUND = $0002; // 基金
  KIND_WARRANTS = $0003; // 认股证
  KIND_JR = $0004; // 金融
  KIND_ZH = $0005; // 综合
  KIND_DC = $0006; // 地产
  KIND_LY = $0007; // 旅游
  KIND_GY = $0008; // 工业
  KIND_GG = $0009; // 公用
  KIND_QT = $000A; // 其它

  // 期货大类
  FUTURES_MARKET = $4000; // 期货
  DALIAN_BOURSE = $0100; // 大连
  KIND_BEAN = $0001; // 连豆
  KIND_YUMI = $0002; // 大连玉米
  KIND_SHIT = $0003; // 大宗食糖
  KIND_DZGY = $0004; // 大宗工业1
  KIND_DZGY2 = $0005; // 大宗工业2
  KIND_DOUYOU = $0006; // 连豆油
  KIND_JYX = $0007; // 聚乙烯
  KIND_ZTY = $0008; // 棕榈油

  SHANGHAI_BOURSE = $0200; // 上海
  KIND_METAL = $0001; // 上海金属
  KIND_RUBBER = $0002; // 上海橡胶
  KIND_FUEL = $0003; // 上海燃油
  // KIND_GUZHI = $0004;        // 股指期货
  KIND_QHGOLD = $0005; // 上海黄金

  ZHENGZHOU_BOURSE = $0300; // 郑州
  KIND_XIAOM = $0001; // 郑州小麦
  KIND_MIANH = $0002; // 郑州棉花
  KIND_BAITANG = $0003; // 郑州白糖
  KIND_PTA = $0004; // 郑州PTA
  KIND_CZY = $0005; // 菜籽油

  HUANGJIN_BOURSE = $0400; // 黄金交易所
  KIND_GOLD = $0001; // 上海黄金

  GUZHI_BOURSE = $0500; // 股指期货
  KIND_GUZHI = $0001; // 股指期货

  // 其他指数 中证、申万指数
  OTHER_MARKET = $A000; // 其他指数
  ConceptIndex_BORRSE = $A502; // 概念指数
  // SW_BOURSE = $0200;   //申万指数
  ZZ_BOURSE = $0100; // 申万/中证指数沪深
  GN_BOURSE = $0500; // 概念板块/地域板块
  ZX_BORRSE = $0800; // 中信指数

  //指数板块
  IndexPlate_MARKET = $A505; // 沪深300指数等指数板块

  // 外盘大类
  WP_MARKET = $5000; // 外盘
  WP_INDEX = $0100; // 国际指数;        // 不用了
  WP_LME = $0200; // LME;        // 不用了
  WP_LME_CLT = $0210; // "场内铜";
  WP_LME_CLL = $0220; // "场内铝";
  WP_LME_CLM = $0230; // "场内镍";
  WP_LME_CLQ = $0240; // "场内铅";
  WP_LME_CLX = $0250; // "场内锌";
  WP_LME_CWT = $0260; // "场外铝";
  WP_LME_CW = $0270; // "场外";
  WP_LME_SUB = $0000;

  WP_CBOT = $0300; // CBOT
  WP_NYMEX = $0400; // NYMEX
  WP_NYMEX_YY = $0000; // "原油";
  WP_NYMEX_RY = $0001; // "燃油";
  WP_NYMEX_QY = $0002; // "汽油";

  WP_COMEX = $0500; // COMEX
  WP_TOCOM = $0600; // TOCOM
  WP_IPE = $0700; // IPE
  WP_NYBOT = $0800; // NYBOT
  WP_NOBLE_METAL = $0900; // 贵金属
  WP_NOBLE_METAL_XH = $0000; // "现货";
  WP_NOBLE_METAL_HJ = $0001; // "黄金";
  WP_NOBLE_METAL_BY = $0002; // "白银";

  WP_FUTURES_INDEX = $0A00; // 期指
  WP_SICOM = $0B00; // SICOM
  WP_LIBOR = $0C00; // LIBOR
  WP_NYSE = $0D00; // NYSE
  WP_CEC = $0E00; // CEC

  WP_INDEX_AZ = $0110; // "澳洲";
  WP_INDEX_OZ = $0120; // "欧洲";
  WP_INDEX_MZ = $0130; // "美洲";
  WP_INDEX_TG = $0140; // "泰国";
  WP_INDEX_YL = $0150; // "印尼";
  WP_INDEX_RH = $0160; // "日韩";
  WP_INDEX_XHP = $0170; // "新加坡";
  WP_INDEX_FLB = $0180; // "菲律宾";
  WP_INDEX_CCN = $0190; // "中国大陆";
  WP_INDEX_TW = $01A0; // "中国台湾";
  WP_INDEX_MLX = $01B0; // "马来西亚";
  WP_INDEX_SUB = $0000;

  // 外汇大类
  FOREIGN_MARKET = $8000; // 外汇
  WH_BASE_RATE = $0100; // 基本汇率
  WH_ACROSS_RATE = $0200; // 交叉汇率
  FX_TYPE_AU = $0000; // AU	澳元
  FX_TYPE_CA = $0001; // CA	加元
  FX_TYPE_CN = $0002; // CN	人民币
  FX_TYPE_DM = $0003; // DM	马克
  FX_TYPE_ER = $0004; // ER	欧元
  FX_TYPE_HK = $0005; // HK	港币
  FX_TYPE_SF = $0006; // SF	瑞士
  FX_TYPE_UK = $0007; // UK	英镑
  FX_TYPE_YN = $0008; // YN	日元

  WH_FUTURES_RATE = $0300; // 期汇

  YHJZQ_BOURSE = $0200; // 银行间现券市场
  XHCJ_BOURSE = $0300; // 信用拆借
  ZYSHG_BOURSE = $0400; // 质押式回购
  MDSHG_BOURSE = $0500; // 买断式回购

  // *** 美股 *** //
  US_MARKET = $9000; // 美股市场
  AMEX_BOURSE = $0100; // 美国证券交易所(AMEX)
  NYSE_BOURSE = $0200; // 纽约证券交易所(NYSE)
  NASDAQ_BOURSE = $0300; // 纳斯达克证券市场(NASDAQ)

  COLUMN_BEGIN = 10000;
  COLUMN_END = (COLUMN_BEGIN + 999);
  { 基本行情 COLUMN_HQ_BASE_ DEFINE BEGIN }
  COLUMN_HQ_BASE_BEGIN = COLUMN_BEGIN;
  COLUMN_HQ_BASE_END = (COLUMN_HQ_BASE_BEGIN + 100);

  COLUMN_HQ_BASE_NAME = (COLUMN_HQ_BASE_BEGIN + 47); // 股票名称
  COLUMN_HQ_BASE_OPEN = (COLUMN_HQ_BASE_BEGIN + 48); // 开盘价格
  COLUMN_HQ_BASE_NEW_PRICE = (COLUMN_HQ_BASE_BEGIN + 49); // 成交价格
  COLUMN_HQ_BASE_RISE_VALUE = (COLUMN_HQ_BASE_BEGIN + 50); // 涨跌值
  COLUMN_HQ_BASE_TOTAL_HAND = (COLUMN_HQ_BASE_BEGIN + 51); // 总手
  COLUMN_HQ_BASE_HAND = (COLUMN_HQ_BASE_BEGIN + 52); // 现手
  COLUMN_HQ_BASE_MAX_PRICE = (COLUMN_HQ_BASE_BEGIN + 53); // 最高价格
  COLUMN_HQ_BASE_MIN_PRICE = (COLUMN_HQ_BASE_BEGIN + 54); // 最低价格
  COLUMN_HQ_BASE_BUY_PRICE = (COLUMN_HQ_BASE_BEGIN + 55); // 买入价格
  COLUMN_HQ_BASE_SELL_PRICE = (COLUMN_HQ_BASE_BEGIN + 56); // 卖出价格
  COLUMN_HQ_BASE_RISE_RATIO = (COLUMN_HQ_BASE_BEGIN + 57); // 涨跌幅
  COLUMN_HQ_BASE_CODE = (COLUMN_HQ_BASE_BEGIN + 58); // 股票代码

  COLUMN_HQ_BASE_PRECLOSE = (COLUMN_HQ_BASE_BEGIN + 59); // 昨收
  COLUMN_HQ_BASE_VOLUME_RATIO = (COLUMN_HQ_BASE_BEGIN + 60); // 量比
  COLUMN_HQ_BASE_ORDER_BUY_PRICE = (COLUMN_HQ_BASE_BEGIN + 61); // 委买价
  COLUMN_HQ_BASE_ORDER_BUY_VOLUME = (COLUMN_HQ_BASE_BEGIN + 62); // 委买量
  COLUMN_HQ_BASE_ORDER_SELL_PRICE = (COLUMN_HQ_BASE_BEGIN + 63); // 委卖价
  COLUMN_HQ_BASE_ORDER_SELL_VOLUME = (COLUMN_HQ_BASE_BEGIN + 64); // 委卖量
  COLUMN_HQ_BASE_IN_HANDS = (COLUMN_HQ_BASE_BEGIN + 65); // 内盘
  COLUMN_HQ_BASE_OUT_HANDS = (COLUMN_HQ_BASE_BEGIN + 66); // 外盘
  COLUMN_HQ_BASE_MONEY = (COLUMN_HQ_BASE_BEGIN + 67); // 成交金额
  COLUMN_HQ_BASE_RISE_SPEED = (COLUMN_HQ_BASE_BEGIN + 68); // 涨速（不用）
  COLUMN_HQ_BASE_AVERAGE_PRICE = (COLUMN_HQ_BASE_BEGIN + 69); // 均价
  COLUMN_HQ_BASE_RANGE = (COLUMN_HQ_BASE_BEGIN + 70); // 振幅
  COLUMN_HQ_BASE_ORDER_RATIO = (COLUMN_HQ_BASE_BEGIN + 71); // 委比
  COLUMN_HQ_BASE_ORDER_DIFF = (COLUMN_HQ_BASE_BEGIN + 72); // 委差
  COLUMN_HQ_BASE_SPEEDUP = (COLUMN_HQ_BASE_BEGIN + 78); // 新的涨速
  { 基本行情 COLUMN_HQ_BASE_ DEFINE END }

  { 扩展行情 COLUMN_HQ_EX_ DEFINE BEGIN }
  COLUMN_HQ_EX_BEGIN = (COLUMN_HQ_BASE_END + 1);
  COLUMN_HQ_EX_END = (COLUMN_HQ_EX_BEGIN + 50);

  COLUMN_HQ_EX_BUY_PRICE1 = (COLUMN_HQ_EX_BEGIN + 1); // 买入价格一
  COLUMN_HQ_EX_BUY_VOLUME1 = (COLUMN_HQ_EX_BEGIN + 2); // 买入数量一
  COLUMN_HQ_EX_BUY_PRICE2 = (COLUMN_HQ_EX_BEGIN + 3); // 买入价格二
  COLUMN_HQ_EX_BUY_VOLUME2 = (COLUMN_HQ_EX_BEGIN + 4); // 买入数量二
  COLUMN_HQ_EX_BUY_PRICE3 = (COLUMN_HQ_EX_BEGIN + 5); // 买入价格三
  COLUMN_HQ_EX_BUY_VOLUME3 = (COLUMN_HQ_EX_BEGIN + 6); // 买入数量三
  COLUMN_HQ_EX_BUY_PRICE4 = (COLUMN_HQ_EX_BEGIN + 7); // 买入价格四
  COLUMN_HQ_EX_BUY_VOLUME4 = (COLUMN_HQ_EX_BEGIN + 8); // 买入数量四
  COLUMN_HQ_EX_BUY_PRICE5 = (COLUMN_HQ_EX_BEGIN + 9); // 买入价格五
  COLUMN_HQ_EX_BUY_VOLUME5 = (COLUMN_HQ_EX_BEGIN + 10); // 买入数量五

  COLUMN_HQ_EX_SELL_PRICE1 = (COLUMN_HQ_EX_BEGIN + 11); // 卖出价格一
  COLUMN_HQ_EX_SELL_VOLUME1 = (COLUMN_HQ_EX_BEGIN + 12); // 卖出数量一
  COLUMN_HQ_EX_SELL_PRICE2 = (COLUMN_HQ_EX_BEGIN + 13); // 卖出价格二
  COLUMN_HQ_EX_SELL_VOLUME2 = (COLUMN_HQ_EX_BEGIN + 14); // 卖出数量二
  COLUMN_HQ_EX_SELL_PRICE3 = (COLUMN_HQ_EX_BEGIN + 15); // 卖出价格三
  COLUMN_HQ_EX_SELL_VOLUME3 = (COLUMN_HQ_EX_BEGIN + 16); // 卖出数量三
  COLUMN_HQ_EX_SELL_PRICE4 = (COLUMN_HQ_EX_BEGIN + 17); // 卖出价格四
  COLUMN_HQ_EX_SELL_VOLUME4 = (COLUMN_HQ_EX_BEGIN + 18); // 卖出数量四
  COLUMN_HQ_EX_SELL_PRICE5 = (COLUMN_HQ_EX_BEGIN + 19); // 卖出价格五
  COLUMN_HQ_EX_SELL_VOLUME5 = (COLUMN_HQ_EX_BEGIN + 20); // 卖出数量五

  COLUMN_HQ_EX_EXHAND_RATIO = (COLUMN_HQ_EX_BEGIN + 21); // 换手率
  COLUMN_HQ_EX_5DAY_AVGVOLUME = (COLUMN_HQ_EX_BEGIN + 22); // 5日平均量
  COLUMN_HQ_EX_PE_RATIO = (COLUMN_HQ_EX_BEGIN + 23); // 市盈率
  COLUMN_HQ_EX_DIRECTION = (COLUMN_HQ_EX_BEGIN + 24); // 成交方向

  { 扩展行情 COLUMN_HQ_EX_ DEFINE END }

  SH_BOURSE_Mark = 100000; // 上海
  SZ_BOURSE_Mark = 200000; // 深圳
  // 期货
  FUTURES_DALIAN_BOURSE_Mark = 400000; // 大连 商品
  FUTURES_SHANGHAI_BOURSE_Mark = 500000; // 上海 商品
  FUTURES_ZHENGZHOU_BOURSE_Mark = 600000; // 郑州 商品
  FUTURES_GUZHI_BOURSE_Mark = 700000; // 股指期货
  // 香港
  HK_BOURSE_Mark = 800000; // 香港主板
  HK_GE_BOURSE_Mark = 900000; // 香港创业板
  HK_INDEX_BOURSE_Mark = 1000000; // 香港指数
  // 其他指数
  A_OTHER_BOURSE_Mark = 1100000; // 申万 中证
  // 银行间债券
  YHJZQ_BOURSE_Mark = 1200000; // 银行间现券市场
  XHCJ_BOURSE_Mark = 1300000; // 信用拆借
  ZYSHG_BOURSE_Mark = 1400000; // 质押式回购
  MDSHG_BOURSE_Mark = 1500000; // 买断式回购
  // 其它
  OTHER_SECU_MARK = 1600000; // 其它证券

  RT_TREND_IB = $1003; // 银行间债券分时
  RT_TRANS_IB = $1004; // 银行间债券	日内行情
  RT_TECHDATA_IB = $1005; // 银行间债券 	K线
  RT_BOND_BASE_INFO_IB = $1006; // 银行间债券 债券基础信息

  COLUMN_FUTURES_BEGIN = (COLUMN_HQ_EX_END + 1);
  COLUMN_FUTURES_END = (COLUMN_FUTURES_BEGIN + 50);

  COLUMN_INTERBANK_BEGIN = (COLUMN_FUTURES_END + 1);
  COLUMN_INTERBANK_END = (COLUMN_INTERBANK_BEGIN + 50);

  COLUMN_INTERBANK_OPEN_RATE = (COLUMN_INTERBANK_BEGIN + 0); // 开盘净价收益率
  COLUMN_INTERBANK_HIGH_RATE = (COLUMN_INTERBANK_BEGIN + 1); // 最高净价收益率
  COLUMN_INTERBANK_LOW_RATE = (COLUMN_INTERBANK_BEGIN + 2); // 最低净价收益率
  COLUMN_INTERBANK_NEW_RATE = (COLUMN_INTERBANK_BEGIN + 3); // 最新净价收益率
  COLUMN_INTERBANK_WEIGHT_PRICE = (COLUMN_INTERBANK_BEGIN + 4); // 加权均价
  COLUMN_INTERBANK_WEIGHT_RATE = (COLUMN_INTERBANK_BEGIN + 5); // 加权均价收益率
  COLUMN_INTERBANK_TURNOVER = (COLUMN_INTERBANK_BEGIN + 6); // 换手率
  COLUMN_INTERBANK_TOTAL = (COLUMN_INTERBANK_BEGIN + 7); // 券面总额
  COLUMN_INTERBANK_TOTAL_JY = (COLUMN_INTERBANK_BEGIN + 8); // 聚源计算成交量
  COLUMN_INTERBANK_MONEY_JY = (COLUMN_INTERBANK_BEGIN + 9); // 聚源计算金额
  COLUMN_INTERBANK_SETTLE_MONEY_JY = (COLUMN_INTERBANK_BEGIN + 10); // 聚源计算结算金额

  // 后缀
  SH_Suffix = 'SH'; // 上海
  SZ_Suffix = 'SZ'; // 深圳
  OC_Suffix = 'OC'; // 三板
  FU_Suffix = 'FU'; // 期货
  HK_Suffix = 'HK'; // 港股
  OT_Suffix = 'OT'; // 其他指数
  IB_Suffix = 'IB'; // 银行间证券
  OPT_Suffix = 'OPT'; // 个股期权
  ZXI_Suffix = 'CI'; // 中信指数
  US_Suffix = 'US'; // 美股

implementation

end.
