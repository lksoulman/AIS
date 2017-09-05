unit KeyFairyType;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Key Fairy Interface
// Author��      lksoulman
// Date��        2017-9-3
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Key Fairy Type
  TKeyFairyType = (kfStock_SH,          // ���й�Ʊ
                   kfStock_SZ,          // ���й�Ʊ
                   kfNewOTC,            // ������
                   kfFund,              // ����
                   kfIndex,             // ָ��
                   kfBond,              // ծȯ
                   kfFuture,            // �ڻ�
                   kfStock_HK,          // �۹�
                   kfStock_US           // ����
                   );

  // Key Char Type
  TKeyCharType = (kcNomeric,            // ����
                  kcAlpha,              // ��ĸ
                  kcChinese             // ����
                  );



implementation

end.
