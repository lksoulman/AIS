unit KeyFairyType;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Key Fairy Interface
// Author：      lksoulman
// Date：        2017-9-3
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Key Fairy Type
  TKeyFairyType = (kfStock_SH,          // 沪市股票
                   kfStock_SZ,          // 深市股票
                   kfNewOTC,            // 新三板
                   kfFund,              // 基金
                   kfIndex,             // 指数
                   kfBond,              // 债券
                   kfFuture,            // 期货
                   kfStock_HK,          // 港股
                   kfStock_US           // 美股
                   );

  // Key Char Type
  TKeyCharType = (kcNomeric,            // 数字
                  kcAlpha,              // 字母
                  kcChinese             // 中文
                  );



implementation

end.
