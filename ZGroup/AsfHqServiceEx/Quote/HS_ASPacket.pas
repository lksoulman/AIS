unit HS_ASPacket;

interface

uses Windows;

type
///多结果集打包接口(一个包可有多个异构结果集
{*执行序列:
 *
 * 0、准备： SetBuffer(),如果打包缓存区由调用者提供,则必须在BeginPack()之前准备;
 * 1、开始:  BeginPack(),打包器复位;
 *
 * 2、第一个结果集打包：
 *
 *(a)添加字段名列表域：AddField()
 *
 *(b)按照结果集二维表顺序，逐字段，逐条记录添加内容：AddValue()
 *
 * 3、设置第一个结果集的返回码(可选，如果返回码为0则不用设置) SetFirstRetCode()
 *
 * 4、打下一个结果集(可选) NewDataSet()，此处同时设置了该结果集的返回码；
 *
 * 5、参考第2步实现一个结果集打包；
 *
 * 6、结束：EndPack(),重复调用会导致加入空结果集;
 *
 * 7、取打包结果(缓存区，缓存区大小，数据长度)
 *    打包结果也可以直接解包UnPack()返回解包接口
 *
 *使用注意事项:IPacker所使用的内存缓存区，均由调用者控制；
 *             结果集附带的返回码，只有在包格式版本0x20以上时有效；
 }
 IUnPacker = interface(IUnknown)

 end;
///标准接口查询,参照com标准

  IPacker = interface(IUnknown)
    ///打包器初始化(使用调用者的缓存区)
    {* 第一次使用打包器时，可先使用本方法设置好缓冲区(数据长度被置为iDataLen)
    *@param  char * pBuf  缓冲区地址
    *@param  int iBufSize  缓冲区空间
    *@param  int iDataLen  已有数据长度，新增数据加在已有数据之后（只对V1.0格式的包有效）
    }
    procedure SetBuffer(pBuf: Pointer; iBufSize: integer; iDataLen: integer ); stdcall;

    ///复位，重新开始打另一个包(字段数与记录数置为0行0例)
    {*
    * 功能：开始打包，把包长度清零(重复使用已有的缓存区空间)
    *@return 无
    }
    procedure BeginPack(); stdcall;

    ///开始打一个结果集
    {*在打单结果集的包时，可以不调用本方法,均取默认值
    *@param const char *szDatasetName 0x20版打包需要指明结果集名字
    *@param int iReturnCode           0x20版打包需要为每个结果集指明返回值
    }
    function NewDataset(szDatasetName: PAnsiChar; iReturnCode: integer): integer; stdcall;

    {*
    * 功能：向包添加字段
    *
    *有执行次序要求:在 NewDataset()或Reset(),SetBuffer()之后,逐个字段按顺序添加;
    *
    *@param szFieldName：字段名
    *@param cFieldType ：字段类型:I整数，F浮点数，C字符，S字符串，R任意二进制数据
    *@param iFieldWidth ：字段宽度（所占最大字节数）
    *@param iFieldScale ：字段精度,即cFieldType='F'时的小数位数(缺省为4位小数)
    *@return 负数表示失败，否则为目前包的长度
    }
    function AddField(szFieldName: PAnsiChar; cFieldType: AnsiChar; iFieldWidth: integer; iFieldScale: integer): integer; stdcall;

    {*
    * 功能：向包添加字符串数据
    * 有执行次序要求:必须在所有字段增加完之后,逐个字段按顺序添加;
    *@param       szValue：字符串数据
    *@return 负数表示失败，否则为目前包的长度
    }
    function AddValue(szValue: PAnsiChar): integer; stdcall; overload;

    {*
    * 功能：向包添加整数数据
    *@param       iValue：整数数据
    *@return 负数表示失败，否则为目前包的长度
    }
    function AddValue(iValue: integer): integer; stdcall; overload;

    {*
    * 功能：向包添加浮点数据
    *@param       fValue：浮点数据
    *@return 负数表示失败，否则为目前包的长度
    }
    function AddValue( fValue: double): integer; stdcall; overload;

    {*
    * 功能：向包添加一个字符
    *@param		 cValue：字符
    *@return 负数表示失败，否则为目前包的长度
    }
    function AddValue(cValue: AnsiChar): integer; stdcall; overload;

    {*
    * 功能：向包添加一个大对象
    *@param	void * lpBuff 数据区
    *@param	int iLen  数据长度
    *@return 负数表示失败，否则为目前包的长度
    }
    function AddValue(lpBuff: Pointer; iLen: integer): integer; stdcall; overload;

    ///结束打包
    procedure EndPack(); stdcall;

    {*
    * 功能：取打包结果指针
    *@return 打包结果指针
    }
    procedure PackBuf(); stdcall;

    {*
    * 功能：取打包结果长度
    *@return 打包结果长度
    }
    function PackLen(): integer; stdcall;

    {*
    * 功能：取打包结果缓冲区大小
    *@return 打包结果缓冲区大小
    }
    function PackBufSize(): integer; stdcall;

    {*
    * 功能：取打包格式版本
    *@return 版本
    }
    function getVersion(): integer; stdcall;

    ///设置结果集的返回码(0x20版以上要求)，错误结果集需要设置
    {*返回码取缺省值0，则不设置，如果设置，则必须在EndPack()之前调用
    * 功能：取打包格式版本
    *@return 版本
    }
    procedure SetReturnCode(dwRetCode: Cardinal); stdcall;

    {*
    * 功能：直接返回当前打包结果的解包接口,必须在EndPack()之后才能调用,在打包器释放时相应的解包器实例也释放
    *
    *@return 解包器接口，此解包接口不能调用destroy()来释放
    }
    function UnPack(): IUnPacker; stdcall;

  end;

   PAppContext = ^IAppContext;
  ///打包解包服务接口
  IPackService = interface(IUnknown)
    ///返回业务包格式版本
    {根据业务包首字符判断业务包格式版本,业务包版本识别规则

    V1版首部放的是字符串型的列数，所以第一个字节>=0x30;

    V2版第一个字节放的是版本号，目前值为0x20，兼容性改升时该值最大升到0x2F

    @param void * lpBuffer  业务包数据(必须是指向合法业务包的首字节)
    @return int  业务包格式版本(1: V1版,0x20~0x2F V2版版本号)
    }
    function GetVersion(const lpBuffer: Pointer): integer; stdcall;// FUNCTION_CALL_MODE GetVersion(const void * lpBuffer) = 0;

    ///取一个业务包打包器,获得打包器必须通过FreePacker()释放;
    {
    *@param int iVersion 业务包格式版本(取值:1 字串版,其他值 0x20版)
    *@return IPacker * 打包器接口指针
    }
    function GetPacker(iVersion: integer): integer; stdcall;
    ///释放打包器
    {
    *@param IPacker * 要释放的打包器接口指针
    }
    procedure FreePacker(lpPacker: integer) ; stdcall;

    ///取一个业务包解包器,获得解包器必须通过FreePacker()释放;
    {调用GetVersion
    *@param void * lpBuffer 要解包的数据（不含AR通信包头）
    *@param unsigned int iLen 数据长度
    *@return IUnPacker * 结果集操作接口指针
    }
    function  GetUnPacker(lpBuffer: Pointer;  Len: Cardinal): IUnPacker; stdcall;

    ///释放解包器
    procedure FreeUnPacker(lpUnPacker: IUnPacker); stdcall;

  end;

  ///应用上下文接口(通过本接口可以获取当前应用的内部对象接口与全局数据)
  {*基础件框架提供动态加载管理全局性内部对象接口的机制(如基础服务
  *
  *基础件的内部模块或组件一般在初始化时收到应用框架传入的本接口指针
  *
  *从而通过本接口继承的IKnown接口下的QueryInterface函数，按ID获取各类基础服务接口或内部对象接口句柄；
  *
  *也可以通过本接口，存取应用级全局数据；
  *
  *基础件框架在实现本接口时，动态加载和初始化的基础服务及全局数据等；
  }
   IAppContext = interface(IUnknown)
	///取本接口版本
	{*本方法必须为本接口的第一个方法,本接口版本不一致会导致不可预期的结果，非兼容修改要求重新编译所有组件；
	 *@return int 本接口版本yyyymmdd
	 }
    function getVersion(): integer; stdcall;

	///取AR/AS名字
	{*
	 *@return const char * 对于AR/AS返回组名
	 }
    function getName(): PAnsiChar; stdcall;

	///取编号
	{*
	 *@return int 对于AR/AS返回组内编号
	 }
    function getID(): integer; stdcall;

	///取应用启动时的初始化选项,按选项名取启动选项值
	{*
	 *@param const char * szParamName 参数名（命令行选项名为标准，单字符）
	 *@param const char * szDefaultValue    如果指定参数没有通过命令行或环境变量提供值，则返回缺省值
	 *@return const char * 参数值
	 }
    function getOption(szParamName: PAnsiChar; szDefaultValue: PAnsiChar): PAnsiChar; stdcall;

    ///根据全局数据ID，返回指定全局数据指针
    {*
     *@param int iGlbDataID  应用数据ID
     *@return void * 成功返回相应的数据区指针，出错返回NULL
     }
    procedure getGlbData(iGlbDataID: integer );

	///根据全局数据ID，保存指定全局数据指针
    {*
     *@param int iGlbDataID  全局数据ID
     *@param const void * pData      数据指针(不能为NULL)
     *@return int 成功返回I_OK，出错返回I_NONE
     }
    function setGlbData(iGlbDataID: integer; pData: Pointer): integer; stdcall;

	///取配置的安全等级
	{*
	 *@return int 安全等级(0，不校验组件签名，1 校验组件签名)
	 }
    function getSafeLevel(): integer; stdcall;

  end;

///组件初始化xxxxInit()
{*
 *@return int 版本号 yyyymmdd形式
}
TPackServiceInit = function (P: IAppContext): integer; stdcall;

///取服务接口句柄 getxxxxInstance()
{*
 *@return void * 基础服务句柄
}
TPackSvrInstanceProc = function(p: IAppContext): integer; stdcall;


///返回统一的AS基础服务组件查询接口 getxxxInfo()
{*当基础服务组件动态加载时，通过本接口或以获取服务信息(包括xxxxInit(),getxxxxInterface()函数指针)
 *@param void ** ppv    基础服务组件信息(输出参数)，
 *@return 返回0表示查到所要的接口，否则返回负数
}
//function getPackServiceInfo(iIndex: integer; ppv : tagBaseServiceInfo *  ): integer; stdcall;

implementation

end.
