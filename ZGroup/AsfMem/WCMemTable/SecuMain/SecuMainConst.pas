unit SecuMainConst;

////////////////////////////////////////////////////////////////////////////////
//
// Description： SecuMain Memory Table Const
// Author：      lksoulman
// Date：        2017-9-2
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

const

  { MARGIN }

  // 融资融券常量
  GIL_MARGIN_NONE                           = 0;  // 不可融资不可融券
  GIL_MARGIN_FINANCE                        = 10; // 可融资
  GIL_MARGIN_LOAN                           = 20; // 可融券
  GIL_MARGIN_FINANCE_AND_LOAN               = 30; // 可融资可融券

  // 融资融券常量
  MARGIN_NONE                               = $00; // 不可融资不可融券
  MARGIN_FINANCE                            = $10; // 可融资
  MARGIN_LOAN                               = $20; // 可融券
  MARGIN_FINANCE_AND_LOAN                   = $30; // 可融资可融券
  MARGIN_MASK                               = $F0; // 掩码

  { THROUGH }

  // 港股通标识常量
  GIl_THROUGH_NONE                          = 0;   // 无通标志
  GIl_THROUGH_HK_SH                         = 1;   // 港股通沪
  GIl_THROUGH_SH                            = 2;   // 沪股通
  GIl_THROUGH_SZ                            = 3;   // 深股通
  GIl_THROUGH_HK_SZ                         = 4;   // 港股通深
  GIl_THROUGH_HK_SH_SZ                      = 5;   // 港股通(沪深)

  // 港股通标识常量
  THROUGH_NONE                              = $00; // 无通标志
  THROUGH_HK_SH                             = $01; // 港股通沪
  THROUGH_SH                                = $02; // 沪股通
  THROUGH_SZ                                = $03; // 深股通
  THROUGH_HK_SZ                             = $04; // 港股通深
  THROUGH_HK_SH_SZ                          = $05; // 港股通(沪深)
  THROUGH_MASK                              = $F0; // 掩码

  { LISTEDSTATE }

  // 上市状态
  GIl_LISTEDSTATE_LISTING                   = 1;  //上市	1
  GIl_LISTEDSTATE_PRE_LISTING               = 2;  //预上市	2
  GIl_LISTEDSTATE_STOP                      = 3;  //暂停	3
  GIl_LISTEDSTATE_LISTING_FAILURE           = 4;  //上市失败	4
  GIl_LISTEDSTATE_TERMINATED                = 5;  //终止	5
  GIl_LISTEDSTATE_OTHER                     = 9;  //其他	9
  GIl_LISTEDSTATE_TRADING                   = 10; //交易	10
  GIl_LISTEDSTATE_SUSPENDED                 = 11; //停牌	11
  GIl_LISTEDSTATE_DELIST                    = 12; //摘牌	12

  // 上市状态
  LISTEDSTATE_LISTING                       = 1;  //上市	1
  LISTEDSTATE_PRE_LISTING                   = 2;  //预上市	2
  LISTEDSTATE_STOP                          = 3;  //暂停	3
  LISTEDSTATE_LISTING_FAILURE               = 4;  //上市失败	4
  LISTEDSTATE_TERMINATED                    = 5;  //终止	5
  LISTEDSTATE_OTHER                         = 9;  //其他	9
  LISTEDSTATE_TRADING                       = 10; //交易	10
  LISTEDSTATE_SUSPENDED                     = 11; //停牌	11
  LISTEDSTATE_DELIST                        = 12; //摘牌	12

  { INNERCODE}

  // 固定内码证券
  GIl_INNERCODE_YUEBAO                  = 64119;

  { SECUMARKET }

  {
    SELECT MAX(SecuMarket) FROM SecuMain

    SecuMarket
    NULL
    10
    13
    15
    20
    37
    38
    39
    40
    41
    43
    44
    49
    50
    51
    52
    54
    55
    56
    57
    66
    67
    68
    69
    70
    71
    72
    73
    74
    75
    76
    77
    78
    79
    80
    81
    83
    84
    85
    86
    87
    88
    89
    90
    91
    92
    93
    94
    95
    99
    101
    102
    103
    104
    105
    161
    240
    310  = 254
    320  = 255
  }

  // 证券市场
  GIl_SECUMARKET_310 = 310;
  GIL_SECUMARKET_320 = 320;

  // 证券市场
  SECUMARKET_310 = 254;
  SECUMARKET_320 = 255;






implementation

end.
