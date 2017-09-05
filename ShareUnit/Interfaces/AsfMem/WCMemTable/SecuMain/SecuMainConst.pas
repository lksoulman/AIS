unit SecuMainConst;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� SecuMain Memory Table Const
// Author��      lksoulman
// Date��        2017-9-2
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

const

  { MARGIN }

  // ������ȯ����
  GIL_MARGIN_NONE                           = 0;  // �������ʲ�����ȯ
  GIL_MARGIN_FINANCE                        = 10; // ������
  GIL_MARGIN_LOAN                           = 20; // ����ȯ
  GIL_MARGIN_FINANCE_AND_LOAN               = 30; // �����ʿ���ȯ

  // ������ȯ����
  MARGIN_NONE                               = $00; // �������ʲ�����ȯ
  MARGIN_FINANCE                            = $10; // ������
  MARGIN_LOAN                               = $20; // ����ȯ
  MARGIN_FINANCE_AND_LOAN                   = $30; // �����ʿ���ȯ
  MARGIN_MASK                               = $F0; // ����

  { THROUGH }

  // �۹�ͨ��ʶ����
  GIl_THROUGH_NONE                          = 0;   // ��ͨ��־
  GIl_THROUGH_HK_SH                         = 1;   // �۹�ͨ��
  GIl_THROUGH_SH                            = 2;   // ����ͨ
  GIl_THROUGH_SZ                            = 3;   // ���ͨ
  GIl_THROUGH_HK_SZ                         = 4;   // �۹�ͨ��
  GIl_THROUGH_HK_SH_SZ                      = 5;   // �۹�ͨ(����)

  // �۹�ͨ��ʶ����
  THROUGH_NONE                              = $00; // ��ͨ��־
  THROUGH_HK_SH                             = $01; // �۹�ͨ��
  THROUGH_SH                                = $02; // ����ͨ
  THROUGH_SZ                                = $03; // ���ͨ
  THROUGH_HK_SZ                             = $04; // �۹�ͨ��
  THROUGH_HK_SH_SZ                          = $05; // �۹�ͨ(����)
  THROUGH_MASK                              = $F0; // ����

  { LISTEDSTATE }

  // ����״̬
  GIl_LISTEDSTATE_LISTING                   = 1;  //����	1
  GIl_LISTEDSTATE_PRE_LISTING               = 2;  //Ԥ����	2
  GIl_LISTEDSTATE_STOP                      = 3;  //��ͣ	3
  GIl_LISTEDSTATE_LISTING_FAILURE           = 4;  //����ʧ��	4
  GIl_LISTEDSTATE_TERMINATED                = 5;  //��ֹ	5
  GIl_LISTEDSTATE_OTHER                     = 9;  //����	9
  GIl_LISTEDSTATE_TRADING                   = 10; //����	10
  GIl_LISTEDSTATE_SUSPENDED                 = 11; //ͣ��	11
  GIl_LISTEDSTATE_DELIST                    = 12; //ժ��	12

  // ����״̬
  LISTEDSTATE_LISTING                       = 1;  //����	1
  LISTEDSTATE_PRE_LISTING                   = 2;  //Ԥ����	2
  LISTEDSTATE_STOP                          = 3;  //��ͣ	3
  LISTEDSTATE_LISTING_FAILURE               = 4;  //����ʧ��	4
  LISTEDSTATE_TERMINATED                    = 5;  //��ֹ	5
  LISTEDSTATE_OTHER                         = 9;  //����	9
  LISTEDSTATE_TRADING                       = 10; //����	10
  LISTEDSTATE_SUSPENDED                     = 11; //ͣ��	11
  LISTEDSTATE_DELIST                        = 12; //ժ��	12

  { INNERCODE}

  // �̶�����֤ȯ
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

  // ֤ȯ�г�
  GIl_SECUMARKET_310 = 310;
  GIL_SECUMARKET_320 = 320;

  // ֤ȯ�г�
  SECUMARKET_310 = 254;
  SECUMARKET_320 = 255;






implementation

end.
