unit ErrorCode;

interface

const
  ErrorCode_Success                                  =    0;
  ErrorCode_Unknown                                  =   -1;

  ErrorCode_Service_Wait_Timeout                     = 1001;
  ErrorCode_Service_Wait_Failed                      = 1002;
  ErrorCode_Service_Network_Except                   = 1003;

  ErrorCode_Service_Request_UrlIsNull                = 1100;
  ErrorCode_Service_Request_Compress                 = 1101;
  ErrorCode_Service_Request_Encrypt                  = 1102;
  ErrorCode_Service_Request_Post                     = 1103;
  ErrorCode_Service_Request_FundId_NoExists          = 1104;

  ErrorCode_Service_Response_Uncompress              = 1110;
  ErrorCode_Service_Response_Decrypt                 = 1111;
  ErrorCode_Service_Response_DataIsNull              = 1112;
  ErrorCode_Service_Response_NoLogin                 = 1113;
  ErrorCode_Service_Response_NoExistsSid             = 1114;
  ErrorCode_Service_Response_Session_Timeout         = 1115;

  ErrorCode_Service_Login_Failed                     = 1150;
  ErrorCode_Service_Login_Password_CheckFailed       = 1151;
  ErrorCode_Service_Login_MacCode_CheckFailed        = 1152;
  ErrorCode_Service_Login_License_Binded             = 1153;
  ErrorCode_Service_Login_License_Bind_Except        = 1154;
  ErrorCode_Service_Login_License_Invalid            = 1155;
  ErrorCode_Service_Login_ElseWhere_Logined          = 1156;

  ErrorCode_Service_Indicator_NoExists               = 1180;
  ErrorCode_Service_Indicator_JsonFormat             = 1181;
  ErrorCode_Service_Indicator_Params_CheckFailed     = 1182;
  ErrorCode_Service_Indicator_Params_CountFailed     = 1183;
  ErrorCode_Service_Indicator_Params_TypeFailed      = 1184;
  ErrorCode_Service_Indicator_Execute_Except         = 1185;
  ErrorCode_Service_Indicator_Return_Result_Except   = 1186;

  ErrorCode_Service_System_Except                    = 1500;


  function ErrorCodeToErrorInfo(AErrorCode: Integer): WideString;

implementation

  function ErrorCodeToErrorInfo(AErrorCode: Integer): WideString;
  begin
    case AErrorCode of
      ErrorCode_Success:
        begin
          Result := 'Success';
        end;
      ErrorCode_Unknown:
        begin
          Result := 'Unknown';
        end;
      ErrorCode_Service_Wait_Timeout:
        begin
          Result := 'Service Wait Timeout';
        end;
      ErrorCode_Service_Wait_Failed:
        begin
          Result := 'Service Wait Failed';
        end;
      ErrorCode_Service_Network_Except:
        begin
          Result := 'Service Network Except';
        end;
      ErrorCode_Service_Request_UrlIsNull:
        begin
          Result := 'Service Request Url Is Null';
        end;
      ErrorCode_Service_Request_Compress:
        begin
          Result := 'Service Request Compress Error';
        end;
      ErrorCode_Service_Request_Encrypt:
        begin
          Result := 'Service Request Encrypt Error';
        end;
      ErrorCode_Service_Request_Post:
        begin
          Result := 'Service Request Post Error';
        end;
      ErrorCode_Service_Request_FundId_NoExists:
        begin
          Result := 'Service Request FundId No Exists';
        end;
      ErrorCode_Service_Response_Uncompress:
        begin
          Result := 'Service Response Uncompress Error';
        end;
      ErrorCode_Service_Response_Decrypt:
        begin
          Result := 'Service Response Decrypt Error';
        end;
      ErrorCode_Service_Response_DataIsNull:
        begin
          Result := 'Service Response Data Is Null';
        end;
      ErrorCode_Service_Response_NoLogin:
        begin
          Result := 'Service Response No Login';
        end;
      ErrorCode_Service_Response_NoExistsSid:
        begin
          Result := 'Service Response No Exists';
        end;
      ErrorCode_Service_Response_Session_Timeout:
        begin
          Result := 'Service Response Session Timeout';
        end;
      ErrorCode_Service_Login_Failed:
        begin
          Result := 'Service Login Failed';
        end;
      ErrorCode_Service_Login_Password_CheckFailed:
        begin
          Result := 'Service Login Password Check Failed';
        end;
      ErrorCode_Service_Login_MacCode_CheckFailed:
        begin
          Result := 'Service Login Mac Code Check Failed';
        end;
      ErrorCode_Service_Login_License_Binded:
        begin
          Result := 'Service Login License Binded';
        end;
      ErrorCode_Service_Login_License_Bind_Except:
        begin
          Result := 'Service Login License Bind Except';
        end;
      ErrorCode_Service_Login_License_Invalid:
        begin
          Result := 'Service Login License Invalid';
        end;
      ErrorCode_Service_Login_ElseWhere_Logined:
        begin
          Result := 'Service Login ElseWhere Logined';
        end;
      ErrorCode_Service_Indicator_NoExists:
        begin
          Result := 'Service Indicator No Exists';
        end;
      ErrorCode_Service_Indicator_JsonFormat:
        begin
          Result := 'Service Indicator Json Format Error';
        end;
      ErrorCode_Service_Indicator_Params_CheckFailed:
        begin
          Result := 'Service Indicator Params Check Failed';
        end;
      ErrorCode_Service_Indicator_Params_CountFailed:
        begin
          Result := 'Service Indicator Params Count Failed';
        end;
      ErrorCode_Service_Indicator_Params_TypeFailed:
        begin
          Result := 'Service Indicator Params Type Failed';
        end;
      ErrorCode_Service_Indicator_Execute_Except:
        begin
          Result := 'Service Indicator Execute Except';
        end;
      ErrorCode_Service_Indicator_Return_Result_Except:
        begin
          Result := 'Service Indicator Return Result Except';
        end;
      ErrorCode_Service_System_Except:
        begin
          Result := 'Service System Except';
        end;
    else
      Result := 'Unknown';
    end;
  end;

end.
