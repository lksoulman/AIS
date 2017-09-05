unit QuoteColumnDefinex;

interface

{*******************************************************************************
* 文件名称：对应恒生HSColumnDefinex.h文件
* 文件标识：取单列行情时=    RT_HQCOL_VALUE;列ID的定义文件
*******************************************************************************}

const
{ 基本行情列定义				0-9999 }
  HQ_COL_BASE_BEGIN	 =			0;									// 0
  HQ_COL_BASE_END		 = HQ_COL_BASE_BEGIN + 9999;			// 9999

{ 扩展行情列定义				10000-19999 }
  HQ_COL_EX_BEGIN							=    HQ_COL_BASE_END + 1;				// 10000
  HQ_COL_EX_END							=    HQ_COL_EX_BEGIN + 9999;			// 19999

{* 品种相关行情列定义			20000-39999
 *      指数					20000-20999
 *      债券					21000-21999
 *      期货					22000-22999
 *      基金					23000-23999
 *      港股					24000-24999
 }
  HQ_COL_KIND_INFO_BEGIN					=    HQ_COL_EX_END + 1;					// 20000
  HQ_COL_KIND_INFO_END					=    HQ_COL_KIND_INFO_BEGIN + 19999;	// 39999

{ 品种相关=    指数;行情列定义		20000-20999 }
  HQ_COL_INDEX_BEGIN						=    HQ_COL_KIND_INFO_BEGIN;			// 20000
  HQ_COL_INDEX_END						=    HQ_COL_INDEX_BEGIN + 999;			// 20999

{ 品种相关=    债券;行情列定义		21000-21999 }
  HQ_COL_BOND_BEGIN						=    HQ_COL_INDEX_END + 1;				// 21000
  HQ_COL_BOND_END							=    HQ_COL_BOND_BEGIN + 999;			// 21999

{ 品种相关=    期货;行情列定义		22000-22999 }
  HQ_COL_FUTURES_BEGIN					=    HQ_COL_BOND_END + 1;				// 22000
  HQ_COL_FUTURES_END						=    HQ_COL_FUTURES_BEGIN + 999;		// 22999

{ 品种相关=    基金;行情列定义		23000-23999 }
  HQ_COL_FUND_BEGIN						=    HQ_COL_FUTURES_END + 1;			// 23000
  HQ_COL_FUND_END							=    HQ_COL_FUND_BEGIN + 999;			// 23999

{ 品种相关=    港股;行情列定义		24000-24999 }
  HQ_COL_HK_BEGIN							=    HQ_COL_FUND_END + 1;				// 24000
  HQ_COL_HK_END							=    HQ_COL_HK_BEGIN + 999;				// 24999

{ 品种相关=    现货;行情列定义		25000-25999 }
  HQ_COL_SPOT_BEGIN						=    HQ_COL_HK_END + 1;					// 25000
  HQ_COL_SPOT_END							=    HQ_COL_SPOT_BEGIN + 999;			// 25999

{ 品种相关=    期权;行情列定义		26000-26999 }
  HQ_COL_OPTION_BEGIN						=    HQ_COL_SPOT_END + 1;			    // 26000
  HQ_COL_OPTION_END						=    HQ_COL_OPTION_BEGIN + 999;			// 26999

{ 品种相关=    股份转让;行情列定义 27000-27999 }
  HQ_COL_NEEQ_BEGIN						=    HQ_COL_OPTION_END + 1;			    // 27000
  HQ_COL_NEEQ_END						    =    HQ_COL_NEEQ_BEGIN + 999;			// 27999

{ 股本数据行情列定义			40000-49999 }
  HQ_COL_CAPITALIZATION_BEGIN				=    HQ_COL_KIND_INFO_END + 1;			// 40000
  HQ_COL_CAPITALIZATION_END				=    HQ_COL_CAPITALIZATION_BEGIN + 9999;// 49999

{ 财务数据行情列字段定义		50000-59999 }
  HQ_COL_FINANCE_BEGIN					=    HQ_COL_CAPITALIZATION_END + 1;		// 50000
  HQ_COL_FINANCE_END						=    HQ_COL_FINANCE_BEGIN + 9999;		// 59999

{ 动态竞价行情列字段定义		60000-69999 }
  HQ_COL_DYNAMIC_BEGIN                    =    HQ_COL_FINANCE_END + 1;            // 60000
  HQ_COL_DYNAMIC_END                      =    HQ_COL_DYNAMIC_BEGIN + 9999;       // 69999

{ 定价交易行情列字段定义       70000-79999 }
  HQ_COL_FIXEDPRICE_BEGIN                 =    HQ_COL_DYNAMIC_END + 1;            // 70000
  HQ_COL_FIXEDPRICE_END                   =    HQ_COL_FIXEDPRICE_BEGIN + 9999;    // 79999

{      行情列ID								行情列ID值							// 字段含义					字段来源							字段获取处 }

{ 基本行情列定义				0-9999
  HQ_COL_BASE_BEGIN						=    0;									// 0
  HQ_COL_BASE_END							=    HQ_COL_BASE_BEGIN + 9999;			// 9999
 }
  HQ_COL_BASE_NUMBER						=    HQ_COL_BASE_BEGIN + 1;				// 序号						当前屏的股票序号						本地
  HQ_COL_BASE_ARROW						=    HQ_COL_BASE_BEGIN + 2;				// 上下箭头					涨跌情况=    涨：上箭头；跌：下箭头;		本地
  HQ_COL_BASE_CODE						=    HQ_COL_BASE_BEGIN + 3;				// 股票代码					CodeInfo::m_cCode[6]					本地
  HQ_COL_BASE_NAME						=    HQ_COL_BASE_BEGIN + 4;				// 股票名称					StockUserInfo::m_cStockName				本地
  HQ_COL_BASE_PRECLOSE					=    HQ_COL_BASE_BEGIN + 5;				// 昨收						StockUserInfo::m_lPrevClose				本地/服务器
  HQ_COL_BASE_OPEN						=    HQ_COL_BASE_BEGIN + 6;				// 开盘价格					HSStockRealTime::m_lOpen				服务器
  HQ_COL_BASE_MAX_PRICE					=    HQ_COL_BASE_BEGIN + 7;				// 最高价					HSStockRealTime::m_lMaxPrice			服务器
  HQ_COL_BASE_MIN_PRICE					=    HQ_COL_BASE_BEGIN + 8;				// 最低价					HSStockRealTime::m_lMinPrice			服务器
  HQ_COL_BASE_NEW_PRICE					=    HQ_COL_BASE_BEGIN + 9;				// 成交价=    现价、最新价;	HSStockRealTime::m_lNewPrice			服务器
  HQ_COL_BASE_TOTAL_HAND					=    HQ_COL_BASE_BEGIN + 10;			// 总手						HSStockRealTime::m_lTotal				服务器
  HQ_COL_BASE_MONEY						=    HQ_COL_BASE_BEGIN + 11;			// 成交金额=    总金额;		HSStockRealTime::m_fAvgPrice			服务器
  HQ_COL_BASE_ORDER_BUY_VOLUME			=    HQ_COL_BASE_BEGIN + 12;			// 委买量=    买一量;			HSStockRealTime::m_lBuyCount1			服务器
  HQ_COL_BASE_ORDER_SELL_VOLUME			=    HQ_COL_BASE_BEGIN + 13;			// 委卖量=    卖一量;			HSStockRealTime::m_lSellCount1			服务器
  HQ_COL_BASE_ORDER_BUY_PRICE				=    HQ_COL_BASE_BEGIN + 14;			// 委买价=    买一价;			HSStockRealTime::m_lBuyPrice1			服务器
  HQ_COL_BASE_ORDER_SELL_PRICE			=    HQ_COL_BASE_BEGIN + 15;			// 委卖价=    卖一价;			HSStockRealTime::m_lSellPrice1			服务器
  HQ_COL_BASE_HAND						=    HQ_COL_BASE_BEGIN + 16;			// 每手股数					HSStockRealTime::m_nHand				服务器
  HQ_COL_BASE_CUR_HANDS					=    HQ_COL_BASE_BEGIN + 17;			// 现手						StockOtherData::m_lCurrent				服务器
  HQ_COL_BASE_IN_HANDS					=    HQ_COL_BASE_BEGIN + 18;			// 内盘						StockOtherData::m_lInside				服务器
  HQ_COL_BASE_OUT_HANDS					=    HQ_COL_BASE_BEGIN + 19;			// 外盘						StockOtherData::m_lOutside				服务器
  HQ_COL_BASE_SPEEDUP						=    HQ_COL_BASE_BEGIN + 20;			// 涨速=    使用该功能号;		HSStockRealTimeOther::m_fSpeedUp		服务器
//  HQ_COL_BASE_STOP_FLAG					=    HQ_COL_BASE_BEGIN + 21;			// 停盘标志					HSStockRealTimeOther::m_lStopFlag		服务器
  HQ_COL_BASE_AVERAGE_PRICE				=    HQ_COL_BASE_BEGIN + 22;			// 均价						总成交金额 / 总成交量					服务器
  HQ_COL_BASE_RISE_VALUE					=    HQ_COL_BASE_BEGIN + 23;			// 涨跌值					现价 - 昨收								服务器
  HQ_COL_BASE_RANGE						=    HQ_COL_BASE_BEGIN + 24;			// 振幅						=    最高价 - 最低价;/ 昨收					服务器
  HQ_COL_BASE_RISE_RATIO					=    HQ_COL_BASE_BEGIN + 25;			// 涨跌幅=    幅度;			=    现价 - 昨收;/ 昨收						服务器
  HQ_COL_BASE_ORDER_RATIO					=    HQ_COL_BASE_BEGIN + 26;			// 委比						=    委买 - 委卖;/ =    委买 + 委卖;			服务器
  HQ_COL_BASE_ORDER_DIFF					=    HQ_COL_BASE_BEGIN + 27;			// 委差						委买 - 委卖								服务器
  HQ_COL_BASE_VOLUME_RATIO				=    HQ_COL_BASE_BEGIN + 28;			// 量比						成交量 * 总时间 / =    五日量 * 现在时间;	服务器
  HQ_COL_BASE_INFO_MARK                   =    HQ_COL_BASE_BEGIN + 29;            // 信息地雷

{ 扩展行情列定义				10000-19999
  HQ_COL_EX_BEGIN							=    HQ_COL_BASE_END + 1;				// 10000
  HQ_COL_EX_END							=    HQ_COL_EX_BEGIN + 9999;			// 19999
}
  HQ_COL_EX_BUY_PRICE1					=    HQ_COL_EX_BEGIN + 1;				// 买入价格一				HSStockRealTime::m_lBuyPrice1			本地/服务器
  HQ_COL_EX_BUY_PRICE2					=    HQ_COL_EX_BEGIN + 2;				// 买入价格二				HSStockRealTime::m_lBuyPrice2			本地/服务器
  HQ_COL_EX_BUY_PRICE3					=    HQ_COL_EX_BEGIN + 3;				// 买入价格三				HSStockRealTime::m_lBuyPrice3			本地/服务器
  HQ_COL_EX_BUY_PRICE4					=    HQ_COL_EX_BEGIN + 4;				// 买入价格四				HSStockRealTime::m_lBuyPrice4			本地/服务器
  HQ_COL_EX_BUY_PRICE5					=    HQ_COL_EX_BEGIN + 5;				// 买入价格五				HSStockRealTime::m_lBuyPrice5			本地/服务器
  HQ_COL_EX_BUY_VOLUME1					=    HQ_COL_EX_BEGIN + 6;				// 买入数量一				HSStockRealTime::m_lBuyCount1			本地/服务器
  HQ_COL_EX_BUY_VOLUME2					=    HQ_COL_EX_BEGIN + 7;				// 买入数量二				HSStockRealTime::m_lBuyCount2			本地/服务器
  HQ_COL_EX_BUY_VOLUME3					=    HQ_COL_EX_BEGIN + 8;				// 买入数量三				HSStockRealTime::m_lBuyCount3			本地/服务器
  HQ_COL_EX_BUY_VOLUME4					=    HQ_COL_EX_BEGIN + 9;				// 买入数量四				HSStockRealTime::m_lBuyCount4			本地/服务器
  HQ_COL_EX_BUY_VOLUME5					=    HQ_COL_EX_BEGIN + 10;				// 买入数量五				HSStockRealTime::m_lBuyCount5			本地/服务器
  HQ_COL_EX_SELL_PRICE1					=    HQ_COL_EX_BEGIN + 11;				// 卖出价格一				HSStockRealTime::m_lSellPrice1			本地/服务器
  HQ_COL_EX_SELL_PRICE2					=    HQ_COL_EX_BEGIN + 12;				// 卖出价格二				HSStockRealTime::m_lSellPrice2			本地/服务器
  HQ_COL_EX_SELL_PRICE3					=    HQ_COL_EX_BEGIN + 13;				// 卖出价格三				HSStockRealTime::m_lSellPrice3			本地/服务器
  HQ_COL_EX_SELL_PRICE4					=    HQ_COL_EX_BEGIN + 14;				// 卖出价格四				HSStockRealTime::m_lSellPrice4			本地/服务器
  HQ_COL_EX_SELL_PRICE5					=    HQ_COL_EX_BEGIN + 15;				// 卖出价格五				HSStockRealTime::m_lSellPrice5			本地/服务器
  HQ_COL_EX_SELL_VOLUME1					=    HQ_COL_EX_BEGIN + 16;				// 卖出数量一				HSStockRealTime::m_lSellCount1			本地/服务器
  HQ_COL_EX_SELL_VOLUME2					=    HQ_COL_EX_BEGIN + 17;				// 卖出数量二				HSStockRealTime::m_lSellCount2			本地/服务器
  HQ_COL_EX_SELL_VOLUME3					=    HQ_COL_EX_BEGIN + 18;				// 卖出数量三				HSStockRealTime::m_lSellCount3			本地/服务器
  HQ_COL_EX_SELL_VOLUME4					=    HQ_COL_EX_BEGIN + 19;				// 卖出数量四				HSStockRealTime::m_lSellCount4			本地/服务器
  HQ_COL_EX_SELL_VOLUME5					=    HQ_COL_EX_BEGIN + 20;				// 卖出数量五				HSStockRealTime::m_lSellCount5			本地/服务器
  HQ_COL_EX_5DAY_AVGVOLUME				=    HQ_COL_EX_BEGIN + 21;				// 5日平均量 				StockUserInfo::m_l5DayVol				本地/服务器
  HQ_COL_EX_UPPRICE						=    HQ_COL_EX_BEGIN + 22;				// 涨停板价					SeverCalculateData::m_fUpPrice			本地/服务器
  HQ_COL_EX_DOWNPRICE						=    HQ_COL_EX_BEGIN + 23;				// 跌停板价					SeverCalculateData::m_fDownPrice		本地/服务器
//  HQ_COL_EX_MARKETNAME					=    HQ_COL_EX_BEGIN + 24;				// 市场名称					该股的市场名称=    全称;					本地
//  HQ_COL_EX_MARKETSHORTNAME				=    HQ_COL_EX_BEGIN + 25;				// 市场简称					该股的市场名称=    简称;					本地
  HQ_COL_EX_SPECIAL_MARKER				=    HQ_COL_EX_BEGIN + 26;				// 表示股票代码属性的标记字段，如是否为港股通等
	///以下属于HQ_COL_EX_SPECIAL_MARKER 值的含义
	  SM_DELIST_WARNING    =       $01;  ///< 退市警示标的
	  SM_RISK_WARNING      =       $02;  ///< 风险警示标的
	  SM_CRD_BUY           =       $04;  ///< 融资标的
	  SM_CRD_SELL          =       $08;  ///< 融券标的
	  SM_SH2HK             =       $10;  ///< 沪股通标的=    可买可卖;
	  SM_HK2SH             =       $20;  ///< 港股通标的=    可买可卖;
	  SM_SH2HK_ONLY_SELL   =       $40;  ///< 沪股通标的=    只可卖;
	  SM_HK2SH_ONLY_SELL   =       $80;  ///< 港股通标的=    只可卖;

// 之前是上证重点指数的范围 现在已经移送到指数 这些列字段范围空出来
  HQ_COL_EX_EXHAND_RATIO			  	    =    HQ_COL_EX_BEGIN + 33;			    // 换手率 					成交量=    单位：股; / 总股本		服务器不支持
{ 以下字段服务器不支持 }
  HQ_COL_EX_PE_RATIO  					=    HQ_COL_EX_BEGIN + 34;				// 市盈率 					最新价 / 每股收益率				服务器不支持
  HQ_COL_EX_PB							=    HQ_COL_EX_BEGIN + 35;				// 市净率					最新价 / 每股净资产				服务器不支持
//  HQ_COL_EX_DIRECTION   				=    HQ_COL_EX_BEGIN + 36;				// 成交方向					显示最近几笔的买卖方向					不支持
  HQ_COL_EX_MARKET_CAPITALIZATION			=    HQ_COL_EX_BEGIN + 37;				// 流通市值					最新价 * 流通A股						服务器
  HQ_COL_EX_TOTAL_MARKET_CAPITALIZATION	=    HQ_COL_EX_BEGIN + 38;				// 总市值					最新价 * 总股本							服务器
//  HQ_COL_EX_ORDER_BUY_AVGPRICE			=    HQ_COL_EX_BEGIN + 39;				// 委买均价															服务器
//  HQ_COL_EX_ORDER_SELL_AVGPRICE			=    HQ_COL_EX_BEGIN + 40;				// 委卖均价															服务器
//  HQ_COL_EX_ORDER_BUY_TOTAL_VOLUME		=    HQ_COL_EX_BEGIN + 41;				// 委买总量															服务器
//  HQ_COL_EX_ORDER_SELL_TOTAL_VOLUME		=    HQ_COL_EX_BEGIN + 42;				// 委卖总量															服务器
  HQ_COL_EX_BUY_ORDER_COUNT				=    HQ_COL_EX_BEGIN + 43;				// 买入单数															服务器
  HQ_COL_EX_SELL_ORDER_COUNT			    =    HQ_COL_EX_BEGIN + 44;				// 卖出单数															服务器
  HQ_COL_EX_BUY_ORDER_MID				    =    HQ_COL_EX_BEGIN + 45;				// 中单买入															服务器
  HQ_COL_EX_BUY_ORDER_BIG				    =    HQ_COL_EX_BEGIN + 46;				// 大单买入															服务器
  HQ_COL_EX_BUY_ORDER_HUGE				=    HQ_COL_EX_BEGIN + 47;				// 特大买入															服务器
  HQ_COL_EX_SELL_ORDER_MID				=    HQ_COL_EX_BEGIN + 48;				// 中单卖出															服务器
  HQ_COL_EX_SELL_ORDER_BIG				=    HQ_COL_EX_BEGIN + 49;				// 大单卖出															服务器
  HQ_COL_EX_SELL_ORDER_HUGE				=    HQ_COL_EX_BEGIN + 50;				// 特大卖出															服务器
  HQ_COL_EX_BUY_ORDER_INSTITUTION		    =    HQ_COL_EX_BEGIN + 51;				// 机构买单吃货数			委买单中机构挂单的总量					服务器
  HQ_COL_EX_SELL_ORDER_INSTITUTION		=    HQ_COL_EX_BEGIN + 52;				// 机构卖单吃货数			委卖单中机构挂单的总量					服务器
  HQ_COL_EX_ORDER_DIFF_INSTITUTION		=    HQ_COL_EX_BEGIN + 53;				// 机构单数差				机构买单吃货数 - 机构卖单吃货数			服务器
//  HQ_COL_EX_BUY_INSTITUTION				=    HQ_COL_EX_BEGIN + 54;				// 机构吃货数				机构买单成交的单数						服务器
//  HQ_COL_EX_SELL_INSTITUTION			=    HQ_COL_EX_BEGIN + 55;				// 机构吐货数				机构卖单成交的单数						服务器
//  HQ_COL_EX_BUY_HAND_INSTITUTION		=    HQ_COL_EX_BEGIN + 56;				// 机构吃货量				机构买入的手数							服务器
//  HQ_COL_EX_SELL_HAND_INSTITUTION		=    HQ_COL_EX_BEGIN + 57;				// 机构吐货量				机构卖出的手数							服务器
//  HQ_COL_EX_BUY_AVGRAGE_INSTITUTION		=    HQ_COL_EX_BEGIN + 58;				// 机构吃货均额			机构吃货量 * 每手股数 / 机构吃货数 * 现价	服务器
//  HQ_COL_EX_SELL_AVGRAGE_INSTITUTION	=    HQ_COL_EX_BEGIN + 59;				// 机构吐货均额			机构吐货量 * 每手股数 / 机构吐货数 * 现价	服务器
  HQ_COL_EX_DDX							=    HQ_COL_EX_BEGIN + 60;				// DDX
  HQ_COL_EX_DDY							=    HQ_COL_EX_BEGIN + 61;				// DDY
  HQ_COL_EX_DDZ							=    HQ_COL_EX_BEGIN + 62;				// DDZ
  HQ_COL_EX_DDX_5DAY						=    HQ_COL_EX_BEGIN + 63;				// 5日DDX
  HQ_COL_EX_DDY_5DAY						=    HQ_COL_EX_BEGIN + 64;				// 5日DDY
  HQ_COL_EX_DDX_60DAY						=    HQ_COL_EX_BEGIN + 65;				// 60日DDX
  HQ_COL_EX_DDY_60DAY						=    HQ_COL_EX_BEGIN + 66;				// 60日DDY
  HQ_COL_EX_10DAY_RED						=    HQ_COL_EX_BEGIN + 67;				// 10日内飘红天数
  HQ_COL_EX_10DAY_RED_CONSTANCY			=    HQ_COL_EX_BEGIN + 68;				// 10日内连续飘红天数
  HQ_COL_EX_MAX_PRICE64                   =    HQ_COL_EX_BEGIN + 69;              // 最高报价=    64位;
  HQ_COL_EX_MAX_VOLUME64                  =    HQ_COL_EX_BEGIN + 70;              // 最高数量=    64位;
  HQ_COL_EX_DDZ_5DAY	                    =    HQ_COL_EX_BEGIN + 71;              // 5日DDZ
  HQ_COL_EX_DDZ_60DAY	                    =    HQ_COL_EX_BEGIN + 72;              // 60日DDZ
  HQ_COL_EX_DDE_VOLUME	                =    HQ_COL_EX_BEGIN + 73;              // DDE成交量
  HQ_COL_EX_DDE_TRADE	                    =    HQ_COL_EX_BEGIN + 74;	            // DDE成交额
  HQ_COL_EX_BUY_ORDER_SMALL_AMOUNT        =    HQ_COL_EX_BEGIN + 75;              // 小单买入
  HQ_COL_EX_BUY_ORDER_MID_AMOUNT          =    HQ_COL_EX_BEGIN + 76;              // 中单买入
  HQ_COL_EX_BUY_ORDER_BIG_AMOUNT          =    HQ_COL_EX_BEGIN + 77;              // 大单买入
  HQ_COL_EX_SELL_ORDER_SMALL_AMOUNT       =    HQ_COL_EX_BEGIN + 78;              // 小单卖出
  HQ_COL_EX_SELL_ORDER_MID_AMOUNT         =    HQ_COL_EX_BEGIN + 79;              // 中单卖出
  HQ_COL_EX_SELL_ORDER_BIG_AMOUNT         =    HQ_COL_EX_BEGIN + 80;              // 大单卖出

  HQ_COL_EX_AH_TOTAL_MARKET_CAPITALIZATION =    HQ_COL_EX_BEGIN + 81;				// AH总市值
  HQ_COL_EX_AH_PREMIUM_VALUE				=    HQ_COL_EX_BEGIN + 82;				// AH溢价
  HQ_COL_EX_AH_PREMIUM_RATE				=    HQ_COL_EX_BEGIN + 83;				// AH溢价率

{ 品种相关=    指数;行情列定义		20000-20999
  HQ_COL_INDEX_BEGIN						=    HQ_COL_KIND_INFO_BEGIN;			// 20000
  HQ_COL_INDEX_END						=    HQ_COL_INDEX_BEGIN + 999;			// 20999
}
  HQ_COL_INDEX_RISE_COUNT					=    HQ_COL_INDEX_BEGIN + 1;			// 上涨家数					HSIndexRealTime::m_nRiseCount			服务器
  HQ_COL_INDEX_FALL_COUNT					=    HQ_COL_INDEX_BEGIN + 2;			// 下跌家数					HSIndexRealTime::m_nFallCount			服务器
  HQ_COL_INDEX_TOTAL_STOCK1				=    HQ_COL_INDEX_BEGIN + 3;			// 综合指数：所有股票-指数	HSIndexRealTime::m_nTotalStock1			服务器
  HQ_COL_INDEX_TOTAL_STOCK2				=    HQ_COL_INDEX_BEGIN + 4;			// 综合指数：A股+B股 分类指数：0	HSIndexRealTime::m_nTotalStock2	服务器
//  HQ_COL_INDEX_TYPE						=    HQ_COL_INDEX_BEGIN + 5;			// 指数种类：0-综合指数1-A股2-B股	HSIndexRealTime::m_nType		服务器
//  HQ_COL_INDEX_LEAD						=    HQ_COL_INDEX_BEGIN + 6;			// 领先指标					HSIndexRealTime::m_nLead				服务器
//  HQ_COL_INDEX_RISE_TREND				=    HQ_COL_INDEX_BEGIN + 7;			// 上涨趋势					HSIndexRealTime::m_nRiseTrend			服务器
//  HQ_COL_INDEX_FALL_TREND				=    HQ_COL_INDEX_BEGIN + 8;			// 下跌趋势					HSIndexRealTime::m_nFallTrend			服务器
{ 以下字段服务器暂不支持 }
  HQ_COL_INDEX_EQUAL_COUNT				=    HQ_COL_INDEX_BEGIN + 9;			// 平盘家数					不是基础字段，客户端自己算		服务器不支持
  HQ_COL_INDEX_SAMPLE_COUNT				=    HQ_COL_INDEX_BEGIN + 10;			// 样本数量					上证重点指数的样本数量					本地
  HQ_COL_INDEX_SAMPLE_AVERAGE				=    HQ_COL_INDEX_BEGIN + 11;			// 样本均价					上证重点指数的样本均价					本地
  HQ_COL_INDEX_TURNOVER					=    HQ_COL_INDEX_BEGIN + 12;			// 成交额=    亿元;			上证重点指数的成交额=    亿元;				本地
  HQ_COL_INDEX_AVERAGE_EQUITY				=    HQ_COL_INDEX_BEGIN + 13;			// 平均股本=    亿股;			上证重点指数的平均股本=    亿股;			本地
  HQ_COL_INDEX_MARKET_VALUE				=    HQ_COL_INDEX_BEGIN + 14;			// 总市值=    万亿;			上证重点指数的总市值=    万亿;				本地
  HQ_COL_INDEX_RATIO						=    HQ_COL_INDEX_BEGIN + 15;			// 占比=    %;					上证重点指数的占比=    %;					本地
  HQ_COL_INDEX_STATIC_PER					=    HQ_COL_INDEX_BEGIN + 16;			// 静态市盈率				上证重点指数的静态市盈率				本地
// 板块指数特有
  HQ_COL_INDEX_RISE_CODE					=    HQ_COL_INDEX_BEGIN + 17;           // 领涨股票代码			HSIndexRealTimeOther::m_szRiseCode		本地
  HQ_COL_INDEX_RISE_FLUCTUATION		    =    HQ_COL_INDEX_BEGIN + 18;           // 领涨股票涨幅			HSIndexRealTimeOther::m_lRise			本地
  HQ_COL_INDEX_FALL_CODE                  =    HQ_COL_INDEX_BEGIN + 19;           // 领跌股票代码			HSIndexRealTimeOther::m_szFallCode		本地
  HQ_COL_INDEX_FALL_FLUCTUATION           =    HQ_COL_INDEX_BEGIN + 20;           // 领跌股票跌幅			HSIndexRealTimeOther::m_lFall			本地
  HQ_COL_INDEX_INDUSTRY_LEVEL				=    HQ_COL_INDEX_BEGIN + 21;			// 行业分级					HSIndexRealTimeOther::m_nNo2[0]			本地
  HQ_COL_INDEX_CLASSIFIED_CODE			=    HQ_COL_INDEX_BEGIN + 22;			// 分级编码

{ 品种相关=    债券;行情列定义		21000-21999
  HQ_COL_BOND_BEGIN						=    HQ_COL_INDEX_END + 1;				// 21000
  HQ_COL_BOND_END							=    HQ_COL_BOND_BEGIN + 999;			// 21999
}
  HQ_COL_BOND_ACCRUAL 					=    HQ_COL_BOND_BEGIN + 1;				// 利息						HSStockRealTime::m_lNationalDebtRatio	服务器
{ 以下字段服务器暂不支持 }
  HQ_COL_BOND_TOTAL_VALUE					=    HQ_COL_BOND_BEGIN + 2;				// 全价						利息 + 现价						服务器不支持

{ 品种相关=    期货;行情列定义		22000-22999
  HQ_COL_FUTURES_BEGIN					=    HQ_COL_BOND_END + 1;				// 22000
  HQ_COL_FUTURES_END						=    HQ_COL_FUTURES_BEGIN + 999;		// 22999
}
  HQ_COL_FUTURES_AMOUNT					=    HQ_COL_FUTURES_BEGIN + 1;			// 持仓量					HSQHRealTime::m_lChiCangLiang			服务器
  HQ_COL_FUTURES_PREAMOUNT				=    HQ_COL_FUTURES_BEGIN + 2;			// 昨持仓量					HSQHRealTime::m_lPreCloseChiCang		服务器
  HQ_COL_FUTURES_SETTLE					=    HQ_COL_FUTURES_BEGIN + 3;			// 结算价					HSQHRealTime::m_lJieSuanPrice			服务器
  HQ_COL_FUTURES_PRESETTLE				=    HQ_COL_FUTURES_BEGIN + 4;			// 昨结算价					HSQHRealTime::m_lPreJieSuanPrice		服务器
  HQ_COL_FUTURES_HIS_HIGH					=    HQ_COL_FUTURES_BEGIN + 5;			// 史最高					HSQHRealTime::m_lHIS_HIGH				服务器
  HQ_COL_FUTURES_HIS_LOW					=    HQ_COL_FUTURES_BEGIN + 6;			// 史最低					HSQHRealTime::m_lHIS_LOW				服务器
  HQ_COL_FUTURES_CURRENT_CLOSE			=    HQ_COL_FUTURES_BEGIN + 7;			// 今收盘					HSQHRealTime::m_lCurrentCLOSE			服务器
  HQ_COL_FUTURES_PRE_CLOSE				=    HQ_COL_FUTURES_BEGIN + 8;			// 前天收盘					HSQHRealTime::m_lPreClose				服务器
{ 字段服务器暂不支持 }
  HQ_COL_FUTURES_OPEN_INTEREST_DAY		=    HQ_COL_FUTURES_BEGIN + 9;			// 日增仓					持仓量 - 昨持仓量			    	    服务器不支持
{ }
  HQ_COL_FUTURES_CONTRACT_MULTIPLIER_UNIT =    HQ_COL_FUTURES_BEGIN + 10;         // 合约乘数                 按列字段请求                            服务器

{ 品种相关=    基金;行情列定义		23000-23999
  HQ_COL_FUND_BEGIN						=    HQ_COL_FUTURES_END + 1;			// 23000
  HQ_COL_FUND_END							=    HQ_COL_FUND_BEGIN + 999;			// 23999
}
  HQ_COL_FUND_NETVALUE					=    HQ_COL_FUND_BEGIN + 1;				// 基金净值					HSStockRealTime::m_lNationalDebtRatio	服务器


{ 品种相关=    港股;行情列定义		24000-24999
  HQ_COL_HK_BEGIN							=    HQ_COL_FUND_END + 1;				// 24000
  HQ_COL_HK_END							=    HQ_COL_HK_BEGIN + 999;				// 24999
}
  HQ_COL_HK_BUY_PRICE						=    HQ_COL_HK_BEGIN + 1;				// 最优买价					HSHKStockRealTime::m_lBuyPrice			服务器
  HQ_COL_HK_BUY_SPEED						=    HQ_COL_HK_BEGIN + 2;				// 买价差					HSHKStockRealTime::m_lBuySpread			服务器
  HQ_COL_HK_SELL_PRICE					=    HQ_COL_HK_BEGIN + 3;				// 最优卖价					HSHKStockRealTime::m_lSellPrice			服务器
  HQ_COL_HK_SELL_SPEED					=    HQ_COL_HK_BEGIN + 4;				// 卖价差					HSHKStockRealTime::m_lSellSpread		服务器
  HQ_COL_HK_IEV							=    HQ_COL_HK_BEGIN + 5;				// 今日收盘价				HSHKStockRealTime::m_lIEV				服务器
  HQ_COL_HK_H_CODE						=    HQ_COL_HK_BEGIN + 6;				// H股代码					CodeInfo::m_cCode[6]					本地
  HQ_COL_HK_H_NAME						=    HQ_COL_HK_BEGIN + 7;				// H股名称					StockUserInfo::m_cStockName				本地
  HQ_COL_HK_H_RISE_RATIO					=    HQ_COL_HK_BEGIN + 8;				// H股涨跌幅=    幅度;			=    现价 - 昨收;/ 昨收					服务器
  HQ_COL_HK_H_NEW_PRICE					=    HQ_COL_HK_BEGIN + 9;				// H股成交价=    现价、最新价;HSStockRealTime::m_lNewPrice			服务器
  HQ_COL_HK_H_EXHAND_RATIO			  	=    HQ_COL_HK_BEGIN + 10;			    // H股换手率 				成交量=    单位：股; / 总股本				服务器不支持

{ 品种相关=    商品;行情列定义		25000-25999
  HQ_COL_SPOT_BEGIN						=    HQ_COL_HK_END + 1;					// 25000
  HQ_COL_SPOT_END							=    HQ_COL_SPOT_BEGIN + 999;			// 25999
}
  HQ_COL_SPOT_ORDER_AMOUNT				=    HQ_COL_SPOT_BEGIN + 1;				// 订货量					HSSpotRealTime::m_lOrderAmount			服务器
  HQ_COL_SPOT_DAILY_END_PRICE	            =    HQ_COL_SPOT_BEGIN + 2;	            // 日终止价					HSSpotRealTime::m_lReserved				uint32
  HQ_COL_SPOT_DAILY_INCREASED_VOL	        =    HQ_COL_SPOT_BEGIN + 3;	            // 日增量					无										uint64
  HQ_COL_SPOT_DAILY_DECREASED_VOL	        =    HQ_COL_SPOT_BEGIN + 4;	            // 日减量					无										uint64



{ 品种相关=    期权;行情列定义		26000-26999
  HQ_COL_OPTION_BEGIN						=    HQ_COL_SPOT_END + 1;			    // 26000
  HQ_COL_OPTION_END					    =    HQ_COL_OPTION_BEGIN + 999;			// 26999
}
  HQ_COL_OPTION_TREATY_CODE               =    HQ_COL_OPTION_BEGIN + 1;           // 合约代码
  HQ_COL_OPTION_DEADLINE                  =    HQ_COL_OPTION_BEGIN + 2;           // 到期日期
  HQ_COL_OPTION_EXEPRICE					=    HQ_COL_OPTION_BEGIN + 3;           // 行权价
  HQ_COL_OPTION_UNDERLYING_CODE	        =    HQ_COL_OPTION_BEGIN + 4;           // 标的代码															本地
  HQ_COL_OPTION_UNDERLYING_CLOSE	        =    HQ_COL_OPTION_BEGIN + 5;           // 标的昨收															本地
  HQ_COL_OPTION_DELTA	                    =    HQ_COL_OPTION_BEGIN + 6;           // 期权Delta值														本地
  HQ_COL_OPTION_THETA	                    =    HQ_COL_OPTION_BEGIN + 7;			// 期权Theta值														本地
  HQ_COL_OPTION_GAMMA						=    HQ_COL_OPTION_BEGIN + 8;			// 期权Gamma值														本地
  HQ_COL_OPTION_VEGA						=    HQ_COL_OPTION_BEGIN + 9;			// 期权Vega值														本地
  HQ_COL_OPTION_RHO						=    HQ_COL_OPTION_BEGIN + 10;			// 期权Rho值														本地
  HQ_COL_OPTION_EXEDATE                   =    HQ_COL_OPTION_BEGIN + 11;          // 行权时间                                                         本地
  HQ_COL_OPTION_STARTDATE                 =    HQ_COL_OPTION_BEGIN + 12;          // 交易开始                                                         本地
  HQ_COL_OPTION_ENDDATE                   =    HQ_COL_OPTION_BEGIN + 13;          // 交易结束										                    本地
  HQ_COL_OPTION_TYPE                      =    HQ_COL_OPTION_BEGIN + 14;          // 期权类型                                                         本地
  HQ_COL_OPTION_FLAG                      =    HQ_COL_OPTION_BEGIN + 15;          // 调整标志                                                         本地
  HQ_COL_OPTION_AUCTION_PRICE	            =    HQ_COL_OPTION_BEGIN + 16;          // 动态参考价														HSOPTRealTime::m_lAutionPrice	uint32	取值与排序
  HQ_COL_OPTION_VIRTURAL_AUCTION_QTY	    =    HQ_COL_OPTION_BEGIN + 17;          // 虚拟匹配数量													    HSOPTRealTime::m_fAutionQty	    uint64	仅取值
  HQ_COL_OPTION_TRADING_PHASE_CODE	    =    HQ_COL_OPTION_BEGIN + 18;	        // 产品实施阶段标志													HSOPTRealTime::m_cTradingPhase	int32	仅取值
  HQ_COL_OPTION_SYMBOL	                =    HQ_COL_OPTION_BEGIN + 19;	        // 证券名称															（string类型 16字节）			        仅取值
  HQ_COL_OPTION_SECURITY_DESC	            =    HQ_COL_OPTION_BEGIN + 20;	        // 证券简称															（string类型 18字节）			        仅取值
  HQ_COL_OPTION_PRICING                   =    HQ_COL_OPTION_BEGIN + 21;          // 期权定价
// 未平仓合约数就是持仓量 故去掉
//   HQ_COL_OPTION_TOTAL_LONG_POSITION       =    HQ_COL_OPTION_BEGIN + 22;          // 未平仓合约数
  HQ_COL_OPTION_NATURE                    =    HQ_COL_OPTION_BEGIN + 23;          // 期权状态                                                         本地表示：实值、虚值、平值      uint32
  HQ_COL_OPTION_MID_PRICE					=    HQ_COL_OPTION_BEGIN + 30;			// 买卖中间价
  HQ_COL_OPTION_VOLUME					=    HQ_COL_OPTION_BEGIN + 31;			// 交易量
  HQ_COL_OPTION_SELL_DEPOSIT				=    HQ_COL_OPTION_BEGIN + 32;			// 卖出保证金
  HQ_COL_OPTION_PRICE_MARGIN				=    HQ_COL_OPTION_BEGIN + 33;			// 买卖差价
  HQ_COL_OPTION_TRADE_CODE				=    HQ_COL_OPTION_BEGIN + 34;			// 交易代码
//   HQ_COL_OPTION_EMMBEDDED_VALUE_TYPE		=    HQ_COL_OPTION_BEGIN + 35;			// 虚实
  HQ_COL_OPTION_TIME_PRICE				=    HQ_COL_OPTION_BEGIN + 36;			// 时间价值
  HQ_COL_OPTION_INSIDE_PRICE				=    HQ_COL_OPTION_BEGIN + 37;			// 内在价值
  HQ_COL_OPTION_VIRTUAL_AMOUNT			=    HQ_COL_OPTION_BEGIN + 38;			// 虚值额
  HQ_COL_OPTION_IMPLIED_VOLATILITY		=    HQ_COL_OPTION_BEGIN + 39;			// 实时隐含波动率
  HQ_COL_OPTION_BUY_IMPLIED_VOLATILITY	=    HQ_COL_OPTION_BEGIN + 40;			// 买价隐含波动率
  HQ_COL_OPTION_SELL_IMPLIED_VOLATILITY	=    HQ_COL_OPTION_BEGIN + 41;			// 卖价隐含波动率
  HQ_COL_OPTION_MID_IMPLIED_VOLATILITY	=    HQ_COL_OPTION_BEGIN + 42;			// 中间价隐含波动率
  HQ_COL_OPTION_VOLATILITY_PRICE_MARGIN	=    HQ_COL_OPTION_BEGIN + 43;			// 波动率差价
  HQ_COL_OPTION_VEGA2						=    HQ_COL_OPTION_BEGIN + 44;			// 期权vega2值
  HQ_COL_OPTION_THETA2					=    HQ_COL_OPTION_BEGIN + 45;			// 期权theta2值
  HQ_COL_OPTION_THETA3					=    HQ_COL_OPTION_BEGIN + 46;			// 期权theta3值
  HQ_COL_OPTION_RHO2						=    HQ_COL_OPTION_BEGIN + 47;			// 期权rho2值
  HQ_COL_OPTION_PHI						=    HQ_COL_OPTION_BEGIN + 48;			// 期权phi值
  HQ_COL_OPTION_PHI2						=    HQ_COL_OPTION_BEGIN + 49;			// 期权phi2值
  HQ_COL_OPTION_LAMBDA					=    HQ_COL_OPTION_BEGIN + 50;			// 期权lambda值
  HQ_COL_OPTION_STRIKE_DETLA				=    HQ_COL_OPTION_BEGIN + 51;			// 期权strike_detla值
  HQ_COL_OPTION_ZETA						=    HQ_COL_OPTION_BEGIN + 52;			// 期权zeta值
  HQ_COL_OPTION_D_ZETA_DVOL				=    HQ_COL_OPTION_BEGIN + 53;			// 期权d_zeta_dvol值
  HQ_COL_OPTION_D_ZETAD_TIME				=    HQ_COL_OPTION_BEGIN + 54;			// 期权d_zetad_time值
  HQ_COL_OPTION_D_ZETAD_TIME2				=    HQ_COL_OPTION_BEGIN + 55;			// 期权d_zetad_time2值
  HQ_COL_OPTION_D_ZETAD_TIME3				=    HQ_COL_OPTION_BEGIN + 56;			// 期权d_zetad_time3值
  HQ_COL_OPTION_GAMMA_PERCENT				=    HQ_COL_OPTION_BEGIN + 57;			// 期权gamma_percent值
  HQ_COL_OPTION_STRIKE_GAMMA				=    HQ_COL_OPTION_BEGIN + 58;			// 期权strike_gamma值
  HQ_COL_OPTION_VANNA						=    HQ_COL_OPTION_BEGIN + 59;			// 期权vanna值
  HQ_COL_OPTION_VANNA2					=    HQ_COL_OPTION_BEGIN + 60;			// 期权vanna2值
  HQ_COL_OPTION_CHARM						=    HQ_COL_OPTION_BEGIN + 61;			// 期权charm值
  HQ_COL_OPTION_CHARM2					=    HQ_COL_OPTION_BEGIN + 62;			// 期权charm2值
  HQ_COL_OPTION_CHARM3					=    HQ_COL_OPTION_BEGIN + 63;			// 期权charm3值
  HQ_COL_OPTION_VETA						=    HQ_COL_OPTION_BEGIN + 64;			// 期权veta值
  HQ_COL_OPTION_VOMMA						=    HQ_COL_OPTION_BEGIN + 65;			// 期权vomma值
  HQ_COL_OPTION_VOMMA2					=    HQ_COL_OPTION_BEGIN + 66;			// 期权vomma2值
  HQ_COL_OPTION_ULTIMA					=    HQ_COL_OPTION_BEGIN + 67;			// 期权ultima值
  HQ_COL_OPTION_SPEED						=    HQ_COL_OPTION_BEGIN + 68;			// 期权speed值
  HQ_COL_OPTION_ZOOMA						=    HQ_COL_OPTION_BEGIN + 69;			// 期权zooma值
  HQ_COL_OPTION_COLOR						=    HQ_COL_OPTION_BEGIN + 70;			// 期权color值

{ 品种相关=    股份转让;行情列定义 27000-27999
  HQ_COL_NEEQ_BEGIN						=    HQ_COL_OPTION_END + 1;			    // 27000
  HQ_COL_NEEQ_END						    =    HQ_COL_NEEQ_BEGIN + 999;			// 27999
}
  HQ_COL_NEEQ_TRANSFER_STATUS             =    HQ_COL_NEEQ_BEGIN + 1;             // 转让状态 　                                                                                      char    仅取值   服务器 　 　 　 　 　 　 　 　 　 　 　 　 　 　 　 　 　 　 　 　 　
  HQ_COL_NEEQ_MARKET_MAKER_COUNT          =    HQ_COL_NEEQ_BEGIN + 2;             // 做市商数量                                                                                       int32	仅取值	 服务器


{ 股本数据行情列定义			40000-49999
  HQ_COL_CAPITALIZATION_BEGIN				=    HQ_COL_KIND_INFO_END + 1;			// 40000
  HQ_COL_CAPITALIZATION_END				=    HQ_COL_CAPITALIZATION_BEGIN + 9999;// 49999
}
  HQ_COL_CAPITALIZATION_TOTAL				=    HQ_COL_CAPITALIZATION_BEGIN + 1;	// 总股本															本地
//  HQ_COL_CAPITALIZATION_UNLIMITED		=    HQ_COL_CAPITALIZATION_BEGIN + 2;	// 无限售股合计														本地
  HQ_COL_CAPITALIZATION_PASS_A			=    HQ_COL_CAPITALIZATION_BEGIN + 3;	// 流通A股															本地
  HQ_COL_CAPITALIZATION_PASS_B			=    HQ_COL_CAPITALIZATION_BEGIN + 4;	// B股															本地
  HQ_COL_CAPITALIZATION_PASS_H			=    HQ_COL_CAPITALIZATION_BEGIN + 5;	// H股															本地
//  HQ_COL_CAPITALIZATION_PASS_ABROAD		=    HQ_COL_CAPITALIZATION_BEGIN + 6;	// 境外上市股														本地
//  HQ_COL_CAPITALIZATION_PASS_OTHERS		=    HQ_COL_CAPITALIZATION_BEGIN + 7;	// 其他流通股														本地
//  HQ_COL_CAPITALIZATION_LIMITED			=    HQ_COL_CAPITALIZATION_BEGIN + 8;	// 限售股合计														本地
  HQ_COL_CAPITALIZATION_NATIONAL			=    HQ_COL_CAPITALIZATION_BEGIN + 9;	// 国有股													本地
//  HQ_COL_CAPITALIZATION_CORP			=    HQ_COL_CAPITALIZATION_BEGIN + 10;	// 境内法人股														本地
//  HQ_COL_CAPITALIZATION_PERSON			=    HQ_COL_CAPITALIZATION_BEGIN + 11;	// 境内自然人股														本地
//  HQ_COL_CAPITALIZATION_INITIATOR_OTHERS	=    HQ_COL_CAPITALIZATION_BEGIN + 12;	// 其他发起人股														本地
  HQ_COL_CAPITALIZATION_INITIATOR			=    HQ_COL_CAPITALIZATION_BEGIN + 13;	// 发起人法人股														本地
//  HQ_COL_CAPITALIZATION_CORP_ABROAD		=    HQ_COL_CAPITALIZATION_BEGIN + 14;	// 境外法人股														本地
//  HQ_COL_CAPITALIZATION_PERSON_ABROAD	=    HQ_COL_CAPITALIZATION_BEGIN + 15;	// 境外自然人股														本地
//  HQ_COL_CAPITALIZATION_PREFERRED		=    HQ_COL_CAPITALIZATION_BEGIN + 16;	// 优先股或其他														本地
  HQ_COL_CAPITALIZATION_CORPORATION		=    HQ_COL_CAPITALIZATION_BEGIN + 17;	// 法人股															本地
  HQ_COL_CAPITALIZATION_EMPLOYEE			=    HQ_COL_CAPITALIZATION_BEGIN + 18;	// 职工股															本地
  HQ_COL_CAPITALIZATION_A2_GIVE			=    HQ_COL_CAPITALIZATION_BEGIN + 19;	// A2转配股															本地
  HQ_COL_CAPITALIZATION_TOTAL_HK			=    HQ_COL_CAPITALIZATION_BEGIN + 20;	// 港股本


{ 财务数据行情列字段定义		50000-59999
  HQ_COL_FINANCE_BEGIN					=    HQ_COL_CAPITALIZATION_END + 1;		// 50000
  HQ_COL_FINANCE_END						=    HQ_COL_FINANCE_BEGIN + 9999;		// 59999
}
//  HQ_COL_FINANCE_PUBLISH_DATE			=    HQ_COL_FINANCE_BEGIN + 1;			// 发布日期															本地
  HQ_COL_FINANCE_REPORT_DATE				=    HQ_COL_FINANCE_BEGIN + 2;			// 报告期															本地
//  HQ_COL_FINANCE_PUBLIC_DATE			=    HQ_COL_FINANCE_BEGIN + 3;			// 上市日期															本地
  HQ_COL_FINANCE_PER_INCOME				=    HQ_COL_FINANCE_BEGIN + 4;			// 每股收益															本地
  HQ_COL_FINANCE_PER_ASSETS				=    HQ_COL_FINANCE_BEGIN + 5;			// 每股净资产														本地
  HQ_COL_FINANCE_ASSETS_YIELD				=    HQ_COL_FINANCE_BEGIN + 6;			// 净资产收益率														本地
//  HQ_COL_FINANCE_PER_SHARE_CASH			=    HQ_COL_FINANCE_BEGIN + 7;			// 每股经营现金														本地
  HQ_COL_FINANCE_PER_SHARE_ACCFUND		=    HQ_COL_FINANCE_BEGIN + 8;			// 每股公积金														本地
  HQ_COL_FINANCE_PER_UNPAID				=    HQ_COL_FINANCE_BEGIN + 9;			// 每股未分配														本地
  HQ_COL_FINANCE_PARTNER_RIGHT_RATIO  	=    HQ_COL_FINANCE_BEGIN + 10;			// 股东权益比														本地
//  HQ_COL_FINANCE_NET_PROFIT_RATIO		=    HQ_COL_FINANCE_BEGIN + 11;			// 净利润同比														本地
//  HQ_COL_FINANCE_MAIN_INCOME_RATIO		=    HQ_COL_FINANCE_BEGIN + 12;			// 主营收入同比														本地
//  HQ_COL_FINANCE_SALES_GROSS_MARGIN		=    HQ_COL_FINANCE_BEGIN + 13;			// 销售毛利率														本地
  HQ_COL_FINANCE_ADJUST_PER_ASSETS		=    HQ_COL_FINANCE_BEGIN + 14;			// 调整每股净资产													本地
  HQ_COL_FINANCE_TOTAL_ASSETS				=    HQ_COL_FINANCE_BEGIN + 15;			// 总资产															本地
  HQ_COL_FINANCE_CURRENT_ASSETS			=    HQ_COL_FINANCE_BEGIN + 16;			// 流动资产															本地
  HQ_COL_FINANCE_CAPITAL_ASSETS			=    HQ_COL_FINANCE_BEGIN + 17;			// 固定资产															本地
  HQ_COL_FINANCE_UNBODIED_ASSETS			=    HQ_COL_FINANCE_BEGIN + 18;			// 无形资产															本地
  HQ_COL_FINANCE_CURRENT_LIABILITIES  	=    HQ_COL_FINANCE_BEGIN + 19;			// 流动负债															本地
  HQ_COL_FINANCE_LONG_LIABILITIES			=    HQ_COL_FINANCE_BEGIN + 20;			// 长期负债															本地
//  HQ_COL_FINANCE_TOTAL_DEBT				=    HQ_COL_FINANCE_BEGIN + 21;			// 总负债															本地
  HQ_COL_FINANCE_PARTNER_RIGHT			=    HQ_COL_FINANCE_BEGIN + 22;			// 股东权益															本地
  HQ_COL_FINANCE_CAPITAL_ACCFUND			=    HQ_COL_FINANCE_BEGIN + 23;			// 资本公积金														本地
//  HQ_COL_FINANCE_OPERATING_CASH_FLOW	=    HQ_COL_FINANCE_BEGIN + 24;			// 经营现金流量														本地
//  HQ_COL_FINANCE_INVESTMENT_CASH_FLOW	=    HQ_COL_FINANCE_BEGIN + 25;			// 投资现金流量														本地
//  HQ_COL_FINANCE_FINANCING_CASH_FLOW	=    HQ_COL_FINANCE_BEGIN + 26;			// 筹资现金流量														本地
//  HQ_COL_FINANCE_CASH_INCREASEMENT		=    HQ_COL_FINANCE_BEGIN + 27;			// 现金增加额														本地
  HQ_COL_FINANCE_MAIN_INCOME				=    HQ_COL_FINANCE_BEGIN + 28;			// 主营收入															本地
  HQ_COL_FINANCE_MAIN_PROFIT				=    HQ_COL_FINANCE_BEGIN + 29;			// 主营利润															本地
  HQ_COL_FINANCE_TAKING_PROFIT			=    HQ_COL_FINANCE_BEGIN + 30;			// 营业利润															本地
  HQ_COL_FINANCE_YIELD					=    HQ_COL_FINANCE_BEGIN + 31;			// 投资收益															本地
  HQ_COL_FINANCE_OTHER_INCOME				=    HQ_COL_FINANCE_BEGIN + 32;			// 营业外收支														本地
  HQ_COL_FINANCE_TOTAL_PROFIT				=    HQ_COL_FINANCE_BEGIN + 33;			// 利润总额															本地
  HQ_COL_FINANCE_RETAINED_PROFITS			=    HQ_COL_FINANCE_BEGIN + 34;			// 净利润															本地
  HQ_COL_FINANCE_UNPAID_PROFIT			=    HQ_COL_FINANCE_BEGIN + 35;			// 未分配利润														本地
  HQ_COL_FINANCE_LONG_INVESTMENT			=    HQ_COL_FINANCE_BEGIN + 36;			// 长期投资  														本地
  HQ_COL_FINANCE_OTHER_PROFIT				=    HQ_COL_FINANCE_BEGIN + 37;			// 其他利润 														本地
  HQ_COL_FINANCE_SUBSIDY					=    HQ_COL_FINANCE_BEGIN + 38;			// 补贴收入															本地
  HQ_COL_FINANCE_LAST_PROFIT_LOSS			=    HQ_COL_FINANCE_BEGIN + 39;			// 上年损益调整														本地
  HQ_COL_FINANCE_SCOT_PROFIT				=    HQ_COL_FINANCE_BEGIN + 40;			// 税后利润															本地
  HQ_COL_FINANCE_PER_INCOME_TTM			=    HQ_COL_FINANCE_BEGIN + 41;			// 每股收益TTM
  HQ_COL_FINANCE_PER_DIVIDEND				=    HQ_COL_FINANCE_BEGIN + 42;			// 每股股息
  HQ_COL_FINANCE_DIVIDEND_RATE			=    HQ_COL_FINANCE_BEGIN + 43;			// 股息率
  HQ_COL_FINANCE_NET_ASSETS 				=    HQ_COL_FINANCE_BEGIN + 44;			// 净资产

{ 动态竞价行情列字段定义		60000-69999
  HQ_COL_DYNAMIC_BEGIN                    =    HQ_COL_FINANCE_BEGIN + 1;          // 60000
  HQ_COL_DYNAMIC_END                      =    HQ_COL_DYNAMIC_BEGIN + 9999;       // 69999
}
  HQ_COL_DYNAMIC_VALIDTIME                =    HQ_COL_DYNAMIC_BEGIN + 1;          // 挂牌有效时间
  HQ_COL_DYNAMIC_LIST_DATE                =    HQ_COL_DYNAMIC_BEGIN + 2;          // 挂牌日期
  HQ_COL_DYNAMIC_VALIDREMAIN              =    HQ_COL_DYNAMIC_BEGIN + 3;          // 挂牌有效剩余时间
  HQ_COL_DYNAMIC_REIMBURSEMENTTIME        =    HQ_COL_DYNAMIC_BEGIN + 4;          // 补款截止时间
  HQ_COL_DYNAMIC_LATEST_TIME              =    HQ_COL_DYNAMIC_BEGIN + 5;          // 最新报价时间
  HQ_COL_DYNAMIC_REIMBURSEMENTREMAIN      =    HQ_COL_DYNAMIC_BEGIN + 6;          // 补款剩余时间
  HQ_COL_DYNAMIC_MARGINRATIO              =    HQ_COL_DYNAMIC_BEGIN + 7;          // 保证金比例
  HQ_COL_DYNAMIC_NEW_PRICE64              =    HQ_COL_DYNAMIC_BEGIN + 8;          // 64位最新价
  HQ_COL_DYNAMIC_LIST_PRICE               =    HQ_COL_DYNAMIC_BEGIN + 9;          // 挂牌价格

{ 定价交易行情列字段定义       70000-79999
  HQ_COL_FIXEDPRICE_BEGIN                 =    HQ_COL_DYNAMIC_BEGIN + 1;          // 70000
  HQ_COL_FIXEDPRICE_END                   =    HQ_COL_DYNAMIC_END   + 9999;       // 79999
}
  HQ_COL_FIXEDPRICE_LISTVOLUME            =    HQ_COL_FIXEDPRICE_BEGIN + 1;       // 挂牌数量
  HQ_COL_FIXEDPRICE_MINDEALRATIO          =    HQ_COL_FIXEDPRICE_BEGIN + 2;       // 最小成交比例
  HQ_COL_FIXEDPRICE_DEALMODE              =    HQ_COL_FIXEDPRICE_BEGIN + 3;       // 成交方向
  HQ_COL_FIXEDPRICE_TOTAL_DECLARE_VOLUME  =    HQ_COL_FIXEDPRICE_BEGIN + 4;       // 申报总量
















implementation

end.
