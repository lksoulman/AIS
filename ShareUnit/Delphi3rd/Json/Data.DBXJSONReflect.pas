﻿//=============================================================================
//
// 描述： 来自Delphi 10.1 Berlin的JSON反射单元
// 使用方法： 见Delphi官方文档： http://docwiki.embarcadero.com/RADStudio/Berlin/en/Serializing_User_Objects
// 作者： Chang Guangyu
// 日期： 2016-05-23
//
//=============================================================================
{*******************************************************}
{                                                       }
{               Delphi DBX Framework                    }
{                                                       }
{ Copyright(c) 1995-2015 Embarcadero Technologies, Inc. }
{                                                       }
{*******************************************************}

/// <summary> DBX JSON conversion framework </summary>
/// <remarks>
/// Lightweight framework for object serialization with a concrete focus in
/// JSON objects.
///
/// Allows use to convert any user object into a serializabile object (JSON,
/// XML, etc) and back.
///
/// Conversion into a serializabile object is called marshalling. TJSONMarshal
/// class converts user objects into TJSONValue. The reverse process is called
/// un-marshalling. TJSONUnMarshal reverts a TJSONValue back into an user
/// object.
///
/// Marshalling is done based on a visitor pattern. On pre-determined situations
/// events are emitted. Here is a list of these situations that occur during
/// marshalling:
/// - a new object is encountered: OnTypeStart
/// - an already visited object is encountered: OnRefType
/// - a new object content was visited: OnTypeEnd
/// - a new field is encountered: OnFieldStart
/// - a new field is visited: OnFieldEnd
/// - a string value is encoutered: OnString
/// - a numeric value is encoutered: OnNumber
/// - a nil value is encountered: OnNull
/// - a boolean value is encoutered: OnBoolean
/// - a list value is encoutered: OnListStart
/// - a list is finished processing: OnListEnd
///
/// Events are received by a converter. These events are imbricated depending
/// on the structure of the user object. Based on the events and their
/// arguments the converter is responsible with building an equivalent image
/// of the user object. A JSON converter is implemented by TJSONConverter.
///
/// The object image built by the converter can be used for persistency,
/// remoting, etc. That image can be used to re-constitute the original user
/// object using reverter events driven by an un-marshaller.  TJSONUnMarshal
/// uses a JSON image to restore the user object. The un-marshalling is a
/// simpler process that uses RTTI to reconstitute the user object. It is assumed
/// that the user object has a no-argument constructor.
///
/// Marshalling process transforms all fields into strings, numbers and boolean
/// numbers. For more complex fields it requires user converters (and revertors)
/// to transform those. Both user converters and revertors can be registered
/// with the marshaller and unmarshaller instance before any processing.
///
/// Converters and revertors can be registered against a type and a field or for
/// a type. Any field declared of that type is processed by the provided user
/// converter/revertor. A field registered converter/reverter takes precedence
/// in from of a type converter/reverter.
///
/// A field converter can transform a field value into a string, an object, a
/// list of strings or a list of objects. The contract is that those transformed
/// values will be passed as arguments to the correspondent revertor to
/// re-constitute the field value.
///
/// A type converter can transform a value into a string, object, list of
/// strings or list of objects. These will be in turn passed as arguments to the
/// type reverter that will reconstitute the original type instance.
///
/// For example, a TStringList field can be converted into an array of strings
/// by a converter and a reverter can use that list of strings to create and
/// populate an instance of a TStringList with them. This is the degree of the
/// complexity expected by a user defined converter/reverter.
///
/// As RTTI becomes more powerful and more meta-data will be stored in library
/// code the need for user defined converters will subside.
///
/// These are the fields for which there is already a built-in
/// conversion/reversion: integer, string, char, enumeration, float, object. For
/// these types the field values are ignored and user conversion is expected:
/// set, method, variant, interface, pointer, dynArray, classRef, array.
///
/// </remarks>

unit Data.DBXJSONReflect;

interface

uses
  SysUtils,
  System.JSON,
  Generics.Collections,
  TypInfo,
  Rtti,
  Classes
;


const
  PackageVersion = '200';
  AssemblyVersion = '20.0.0.0';

resourcestring
  SBadVariantType = 'Unsupported variant type: %s';
  SAlreadyRegistered        = '%s class already registered';
  SNotRegistered            = '%s class is not registered';
  SInvalidClassRegister     = '%s class registered with a nil class reference';
  SInvalidClassName         = '%s class cannot be found in %s';
  SCannotFreeClassRegistry  = 'Cannot free TClassRegistry.ClassRegistry';
  SDllLoadError       = 'Unable to load %s (ErrorCode %d).  It may be missing from the system path.';
  SDllProcLoadError   = 'Unable to find procedure %s';
  SUnknownDriver      = 'Unknown driver:  %s';
  SInvalidArgument    = 'Invalid argument:  %s';
  SInvalidTransaction = 'Invalid transaction Object';
  SNotImplemented     = 'Feature not implemented';
  SRequiredProperty   = '%s property not set';
  SDriverLoadError    = '%s driver cannot be loaded.  Make sure your project either uses the %s unit or uses packages so the %s package can be loaded dynamically';
  SReaderNew          = 'Reader Next method has not been called';
  SReaderClosed       = 'Reader has no more rows';
  SReadOnlyType       = '%s type cannot be modified';
  SReadOnlyParameter  = '%s parameter cannot be modified';
  SSetSingletonOnce     = 'Cannot set this singleton instance more than once or after it has been retrieved one or more times';
  SConnectionFactoryInitFailed  = 'Cannot find connection files from application directory (%s) or the system registry (%s).';
  SInvalidDelegationDepth       = 'Cannot delegate a connection more than 16 times:  %s';
  SInvalidOrdinal     = 'Invalid Ordinal:  %d';
  SDefaultErrorMessage          = 'DBX Error:  %s';
  SErrorCode          = 'Error Code:  ';
  SAlreadyPrepared    = 'Command can only be prepared once';
  SInvalidTypeAccess  = '%s value type cannot be accessed as %s value type';
  SDriverAlreadyLoaded = 'A driver instance with the %s name has already been loaded.';
  SConnectionClosed = 'Operation failed.  Connection was closed';
  SMetaDataLoadError = 'Could not find metadata: %s; package: %s. Add %s to your uses.';
  SJSONByteStream = 'JSON byte stream cannot be parsed correctly into a JSON value';
  SNoStatementToExecute = 'No statement to execute';
  SAdditionalInfo = '%s.  Vendor error message:  %s.';
  SInvalidDataType = 'dbExpress driver does not support the %s data type';
  SUnmatchedBrace = 'Unmatched brace found in format string: %s';
  SParameterIndexOutOfRange = 'Unmatched brace found in format string: %d';
  SConnectTimeout = 'Connect request timed out after %s milliseconds';
  SInvalidCommand = 'Unrecognized command:  %s';
  SINVALID_TRACE_FLAG       =
    '%s is an invalid setting for the %s property.'#13#10
    +'Use ''%s'' or a semicolon separated list of one or more of the following:'#13#10
    +'%s %s %s %s %s %s %s %s %s %s %s %s';
  SFieldValueMissing = 'Internal: Field %s has no serialized value';
  SFieldExpected = 'Internal: Field %s conversion is incomplete';
  SArrayExpected = 'Internal: Array expected instead of %s';
  SNoArray = 'Internal: Array expected instead of nil';
  STypeExpected = 'Internal: Type expected';
  STypeFieldsPairExpected = 'Internal: Type fields pair expected';
  SValueExpected = 'Internal: JSON value expected instead of %s';
  SInvalidContext = 'Internal: Current context cannot accept a value';
  SObjectExpectedForPair = 'Internal: Object context expected when processing a pair';
  SInvalidContextForPair = 'Internal: Current context cannot accept a pair';
  STypeNotSupported = 'Internal: Type %s is not currently supported';
  SNoTypeInterceptorExpected = 'Field attribute should provide a field interceptor instead of a type one on field %s';
  SInconsistentConversion = 'Internal: Conversion failed, converted object is most likely incomplete';
  SNoConversionForType = 'Internal: No conversion possible for type: %s';
  SNoFieldFoundForType = 'Internal: Field %s cannot be found in type %s';
  SNoValueConversionForField = 'Internal: Value %s cannot be converted to be assigned to field %s in type %s';
  SNoConversionAvailableForValue = 'Value %s cannot be converted into %s. You may use a user-defined reverter';
  SInvalidTypeForField = 'Cannot set value for field %s as it is expected to be an array instead of %s';
  SCannotCreateType = 'Internal: Cannot instantiate type %s';
  SCannotCreateObject = 'The input value is not a valid Object';
  SObjectNotFound = 'Internal: Object type %s not found for id: %s';
  SUnexpectedPairName = 'Internal: Invalid pair name %s: expected %s or %s';
  SInvalidJSONFieldType = 'Un-marshaled array cannot be set as a field value. A reverter may be missing for field %s of %s';
  SObjectExpectedInArray = 'Object expected at position %d in JSON array %s';
  SStringExpectedInArray = 'String expected at position %d in JSON array %s';
  SArrayExpectedForField = 'JSON array expected for field %s in JSON %s';
  SObjectExpectedForField = 'JSON object expected for field %s in JSON %s';
  SStringExpectedForField = 'JSON string expected for field %s in JSON %s';
  SNoProductNameFound = 'No Product name found for Data Provider. No metadata can be provided.';
  SNoDialectForProduct = 'No metadata could be loaded for: %s.';
  SDialectTypeNotFound = 'Could not locate the type: %s.';
  SBeforeRow = 'Invoke Next before getting data from a reader.';
  SAfterRow = 'No more data in reader.';
  SUnknownDataType = 'Unknown Data Type';
  SNoMetadataProvider = 'Cannot load metadata for %s.';
  SUnexpectedMetaDataType = 'Unexpected metadata type';
  SInsertNotCalled = 'Must call Insert before Post.';
  SPostNotCalled = 'Must call Post before moving away from a new row.';
  SEditNotCalled = 'Must call Edit before table can be modified.';
  SMustKeepOriginalColumnOrder = 'Additional columns must be added after the prescribed columns.';
  SObjectNotSupported = 'Objecta are not supported with this metadata store.';
  SUnexpectedDataType = 'Unexpected data type %s';
  SDriverAlreadyRegistered = 'Driver already registered:  ';
  SNotDefinedIn = 'No "%s" defined in %s';
  SDBXErrNone = 'None';
  SDBXErrWarning = 'Warning';
  SDBXErrNoMemory = 'Insufficient memory to complete the operation';
  SDBXErrUnsupportedFieldType = 'Unsupported field type';
  SDBXErrInvalidHandle = 'Unexpected internal error. DBX Object such as a connection, command, or reader may already be closed.';
  SDBXErrNotSupported = 'Not supported';
  SDBXErrInvalidTime = 'Invalid time';
  SDBXErrInvalidType = 'Invalid type';
  SDBXErrInvalidOrdinal = 'Invalid ordinal';
  SDBXErrInvalidParameter = 'Invalid parameter';
  SDBXErrEOF = 'No more rows';
  SDBXErrParameterNotSet = 'Parameter not set';
  SDBXErrInvalidUserOrPassword = 'Invalid username or password';
  SDBXErrInvalidPrecision = 'Invalid precision';
  SDBXErrInvalidLength = 'Invalid length';
  SDBXErrInvalidIsolationLevel = 'Invalid isolation level';
  SDBXErrInvalidTransactionId = 'Invalid transaction id';
  SDBXErrDuplicateTransactionId = 'Duplicate transaction id';
  SDBXErrDriverRestricted = 'Driver restricted';
  SDBXErrTransactionActive = 'Transaction active';
  SDBXErrMultipleTransactionNotEnabled = 'Multiple transaction not enabled';
  SDBXErrConnectionFailed = 'Connection failed';
  SDBXErrDriverInitFailed = 'Driver could not be properly initialized.  Client library may be missing, not installed properly, of the wrong version, or the driver may be missing from the system path.';
  SDBXErrOptimisticLockFailed = 'Optimistic lock failed';
  SDBXErrInvalidReference = 'Invalid reference';
  SDBXErrNoTable = 'No table';
  SDBXErrMissingParameterMarker = 'Missing parameter marker';
  SDBXErrNotImplemented = 'Not implemented';
  SDBXErrDriverIncompatible = 'Driver incompatible';
  SDBXErrInvalidArgument = 'Invalid argument';
  SDBXErrNoData = 'No data';
  SDBXErrVendorError = 'Vendor error';
  SDBXErrUnrecognizedCommandType = 'Unrecognized command type.';
  SDBXErrSchemaNameUnspecified = 'Schema or user name separated by a ''.'' must be specified.';
  SDBXErrDatabaseUnspecified = 'Database must be specified.';
  SDBXErrLibraryNameUnspecified = 'LibraryName must be specified.';
  SDBXErrGetDriverFuncUnspecified = 'GetDriverFunc must be specified.';
  SDBXErrVendorLibUnspecified = 'VendorLib must be specified';
  SInvalidOrderByColumn = 'Table cannot use column %s in an order by operation since it does not exist';
  SIllegalArgument = 'Illegal argument';
  SUnsupportedOperation = 'Unsupported operation';
  SUnexpectedStringOverflow = 'Unexpected string overflow.  Length(''%s'') >= %s)';
  SInvalidJsonStream = 'Cannot convert JSON input into a stream';
  SNoConversionToJSON = 'Cannot convert DBX type %s into a JSON value';
  SNoConversionToDBX = 'Cannot convert JSON value %s input into %s';
  SNoJSONConversion = 'No conversion exists for JSON value %s';
  SIsLiteralSupported = 'Literal Supported';
  SDataType = 'Platform Type Name';
  SCatalogName = 'Catalog Name';
  SProcedureType = 'Procedure Type';
  SUnclosedQuotes = 'Unclosed quotes were found in the metadata query: %s.';
  SDefaultValue = 'Default Value';
  SForeignKeyName = 'Foreign Key Name';
  SIndexName = 'Index Name';
  SIsUnsigned = 'Unsigned';
  SIsUnique = 'Unique';
  SPrimaryKeyName = 'Primary Key Name';
  SIsAscending = 'Ascending';
  SOrdinalOutOfRange = 'Ordinal is outside the bounds of this cursor.';
  SScale = 'Scale';
  SColumnName = 'Column Name';
  STableSchemaName = 'Table Schema Name';
  SPrimaryColumnName = 'Primary Column Name';
  SOrdinal = 'Ordinal';
  SWrongAccessorForType = 'Wrong accessor method used for the datatype: %s.';
  SIsCaseSensitive = 'Case Sensitive';
  SMinimumVersion = 'Minimum Version';
  SIsSearchableWithLike = 'Searchable With Like';
  SCreateParameters = 'Create Parameters';
  SPackageName = 'Package Name';
  SParameterMode = 'Parameter Mode';
  SPrecision = 'Precision';
  SIsBestMatch = 'Best Match';
  SMissingImplementation = 'This method must be implemented in a derived class.';
  SNoSchemaNameSpecified = 'No schema name specified.';
  SMaximumVersion = 'Maximum Version';
  SIsAutoIncrement = 'Auto Increment';
  SLiteralSuffix = 'Literal Suffix';
  SCreateFormat = 'Create Format';
  SSchemaName = 'Schema Name';
  SIsConcurrencyType = 'Concurrency';
  SReservedWord = 'Reserved Word';
  SPrimaryCatalogName = 'Primary Catalog Name';
  SUserName = 'User Name';
  SExternalDefinition = 'External Definition';
  STypeName = 'Type Name';
  SIsNullable = 'Nullable';
  SProviderDbType = 'Provider Type';
  SIsFixedLength = 'Fixed Length';
  SIsSearchable = 'Searchable';
  SConstraintName = 'Constraint Name';
  SUnknownSchemaName = 'Unknown schema name specified: %s';
  SParameterName = 'Parameter Name';
  STableType = 'Table Type';
  SViewName = 'View Name';
  SMinimumScale = 'Minimum Scale';
  SColumnSize = 'Column Size';
  SIsUnicode = 'Unicode';
  SIsFixedPrecisionScale = 'Fixed Precision';
  SUnexpectedSymbol = 'Could not parse the %1:s metadata command. Problem found near: %0:s. Original query: %2:s.';
  SUnknownTableType = 'Unknown table type specified:';
  SMetaDataCommandExpected = 'A MetaData command was expected here e.g. GetTables.';
  SLiteralPrefix = 'Literal Prefix';
  SIsPrimary = 'Primary';
  SSynonymName = 'Synonym Name';
  SRoleName = 'Role Name';
  STableCatalogName = 'Table Catalog Name';
  SMaximumScale = 'Maximum Scale';
  SPrimarySchemaName = 'Primary Schema Name';
  SMustCallNextFirst = 'Cursor is positioned before the first row, move to the next row before getting data';
  SDbxDataType = 'DbxType';
  SIsLong = 'Long';
  SPrimaryTableName = 'Primary Table Name';
  SMaxInline = 'Max Inline';
  STableName = 'Table Name';
  SProcedureName = 'Procedure Name';
  SIsAutoIncrementable = 'AutoIncrementable';
  SPastEndOfCursor = 'No more data.';
  SDefinition = 'Definition';
  SNoTypeWithEnoughPrecision = 'The best type match in %s for the column: %s is %s. But it is does not have sufficient precision.';
  SCannotBeUsedForAutoIncrement = 'The best type match in %s for the column: %s is %s. But is cannot be used for an auto increment column.';
  SNoBlobTypeFound = 'No long %2:s type found for the column: %1:s in %0:s.';
  STypeNameNotFound = 'Data type: %s is not recognized for SQL dialect.';
  SWrongViewDefinition = 'A view definition must start with the CREATE keyword.';
  SNoSignedTypeFound = 'The best type match in %s for the column: %s is %s. But it is unsigned.';
  SCannotHoldWantedPrecision = 'The best type match in %s for the column: %s is %s. But the max precision is: %s which is less than the specified: %s.';
  SCannotHoldWantedScale = 'The best type match in %s for the column: %s is %s. But the max scale is: %s which is less than the specified: %s.';
  STypeNotFound = 'No %2:s type found for the column: %1:s in %0:s.';
  SCannotHoldUnicodeChars = 'The best type match in %s for the column: %s is %s. But it cannot hold unicode characters.';
  SCannotRecreateConstraint = 'The constraint: %s could not be recreated, because the column: %s was dropped.';
  SUnknownColumnName = 'The Data type: %s requires a column: %s, which does not exist on the Column collection.';
  SUnsupportedType = 'Unsupported data type:  %s';
  SParameterNotSet = 'Parameter not set for column number %s';
  SInvalidHandle = 'Invalid Handle';
  SUnexpectedIndex = 'Unexpected index: %d';
const

  /// <summary>Used to set the ValidatePeerCertificate event into a DBX Properties Event collection.
  /// </summary>
  sValidatePeerCertificate = 'ValidatePeerCertificate'; {Do not localize}

type
  /// <summary>Contains the exception thrown when the conversion or reversion
  /// process cannot complete.</summary>
  EConversionError = class(Exception);

  /// <summary>Represents the base converter class.</summary>
  TConverter<TSerial> = class abstract
  protected
    /// <summary> Returns the serialized object </summary>
    /// <returns> Serialized object </returns>
    function GetSerializedData: TSerial; virtual; abstract;
  public
    constructor Create; virtual;
    /// <summary> Resets the instance state </summary>
    /// <remarks>
    /// Clears all residual data so the instance can be reused for a new
    /// conversion.
    /// </remarks>
    procedure Clear; virtual; abstract;
    /// <summary> Event called for pre-visited instance </summary>
    /// <remarks> It is the marshal class that provides the functionality of
    /// detecting circuits in the serialization process. The un-marshal code
    /// will use the id to restore the actual pointer </remarks>
    /// <param name="TypeName"> User object type name </param>
    /// <param name="id"> The pre-visited instance id </param>
    procedure OnRefType(TypeName: string; id: Integer); virtual; abstract;
    /// <summary> Event called for each new object instance </summary>
    /// <remarks> The object id is unique within the scope of a serialization
    /// process and it is not meant to be used outside it.</remarks>
    /// <param name="TypeName"> user object type name </param>
    /// <param name="id"> unique user object id </param>
    procedure OnTypeStart(TypeName: string; id: Integer); virtual; abstract;
    /// <summary> Event called when a new user object processing ends </summary>
    /// <remarks> All fields are processed at this time </remarks>
    /// <param name="TypeName"> user object type name, matching a previous
    /// OnTypeStart event</param>
    /// <param name="id"> user object id, matching a previous OnTypeStart event
    /// </param>
    procedure OnTypeEnd(TypeName: string; id: Integer); virtual; abstract;
    /// <summary> Event called for each field of an object </summary>
    /// <remarks> The field value is provided by one of the events OnString,
    /// OnNumber, OnBoolean, OnNull, OnListStart.</remarks>
    /// <param name="FieldName"> field name </param>
    procedure OnFieldStart(FieldName: string); virtual; abstract;
    /// <summary> Event called for each field immediately after its value was
    /// processed. </summary>
    /// <param name="FieldName">Field name matching a previous ObFieldStart</param>
    procedure OnFieldEnd(FieldName: string); virtual; abstract;
    /// <summary> Event called when a field value is a list of values </summary>
    /// <remarks> This event may be followed by a number of OnString, OnNumber
    /// OnBoolean, OnNull or even imbricated OnListStart/End events </remarks>
    procedure OnListStart; virtual; abstract;
    /// <summary> Event marking the processing of the last value of a list</summary>
    /// <remarks> The event matches a previous OnListStart event</remarks>
    procedure OnListEnd; virtual; abstract;
    /// <summary> String value event </summary>
    /// <remarks> The event was precedeed by a OnFieldStart (eventually an
    /// OnListStart) open event.</remarks>
    /// <param name="Data">Field or array element value as a string</param>
    procedure OnString(Data: string); virtual; abstract;
    /// <summary> Number value event </summary>
    /// <remarks> The event was precedeed by a OnFieldStart (eventually an
    /// OnListStart) open event.</remarks>
    /// <param name="Data">Field or array element value as a number</param>
    procedure OnNumber(Data: string); virtual; abstract;
    /// <summary> Boolean value event </summary>
    /// <remarks> The event was precedeed by a OnFieldStart (eventually an
    /// OnListStart) open event. Boolean are treated a special case of
    /// enumerations. </remarks>
    /// <param name="Data">Field or array element value as a boolean</param>
    procedure OnBoolean(Data: Boolean); virtual; abstract;
    /// <summary> Nil value event </summary>
    /// <remarks> The event was precedeed by a OnFieldStart (eventually an
    /// OnListStart) open event.</remarks>
    procedure OnNull; virtual; abstract;
    /// <summary> IsConsistent marks the successfull object serialization </summary>
    /// <remarks> By returning true it ensures that no open event exists and the
    /// serialized value can be used to restore the original value. </remarks>
    /// <returns>true if the process will return a consistent serialized object</returns>
    function IsConsistent: Boolean; virtual; abstract;
    /// <summary> Bypass for value events </summary>
    /// <remarks> Sets the expected serialized value directly </remarks>
    /// <param name="Data"> field serialized value </param>
    procedure SetCurrentValue(Data: TSerial); virtual; abstract;
    /// <summary> Serialized value, that can be used if ISConsistent is true</summary>
    property SerializedData: TSerial read GetSerializedData;
  end;

  TListOfObjects = array of TObject;
  TListOfStrings = array of string;

  // / <summary>Type for field converters that transform a field value into an
  // / array of objects</summary>
  // / <param name="Data">Current object instance being serialized</param>
  // / <param name="Field">Field name</param>
  // / <result> an array of serializable objects </result>
  TObjectsConverter = reference to function(Data: TObject;
    Field: string): TListOfObjects;
  // / <summary>Type for field converters that transform a field value into an
  // / array of strings</summary>
  // / <param name="Data">Current object instance being serialized</param>
  // / <param name="Field">Field name</param>
  // / <result> an array of strings </result>
  TStringsConverter = reference to function(Data: TObject;
    Field: string): TListOfStrings;
  // / <summary>Type for type converters that transform any field value of the
  // / registered type into an array of objects</summary>
  // / <param name="Data">Current field object value</param>
  // / <result> an array of serializable objects </result>
  TTypeObjectsConverter = reference to function(Data: TObject): TListOfObjects;
  // / <summary>Type for type converters that transform any field value of the
  // / registered type into an array of strings</summary>
  // / <param name="Data">Current field object value</param>
  // / <result> an array of serializable strings </result>
  TTypeStringsConverter = reference to function(Data: TObject): TListOfStrings;

  // / <summary>Type for field converters that transform a field value into an
  // / object</summary>
  // / <param name="Data">Current object instance being serialized</param>
  // / <param name="Field">Field name</param>
  // / <result> a serializable object </result>
  TObjectConverter = reference to function(Data: TObject;
    Field: string): TObject;
  // / <summary>Type for field converters that transform a field value into an
  // / string</summary>
  // / <param name="Data">Current object instance being serialized</param>
  // / <param name="Field">Field name</param>
  // / <result> a string </result>
  TStringConverter = reference to function(Data: TObject;
    Field: string): string;
  // / <summary>Type for type converters that transform any field value of the
  // / registered type into an object</summary>
  // / <param name="Data">Current field object value</param>
  // / <result> a serializable object </result>
  TTypeObjectConverter = reference to function(Data: TObject): TObject;
  // / <summary>Type for type converters that transform any field value of the
  // / registered type into a string</summary>
  // / <param name="Data">Current field object value</param>
  // / <result> a string </result>
  TTypeStringConverter = reference to function(Data: TObject): string;

  /// <summary>Includes all the converter types.</summary>
  TConverterType = (ctObjects, ctStrings, ctTypeObjects, ctTypeStrings,
    ctObject, ctString, ctTypeObject, ctTypeString);

  // / <summary>Type for field reverters that sets field to a value based on
  // / an array of objects</summary>
  // / <param name="Data">Current object instance being serialized</param>
  // / <param name="Field">Field name</param>
  // / <param name="Args"> an array of objects </param>
  TObjectsReverter = reference to procedure(Data: TObject; Field: string;
    Args: TListOfObjects);
  // / <summary>Type for field reverters that sets field to a value based on
  // / an array of strings</summary>
  // / <param name="Data">Current object instance being serialized</param>
  // / <param name="Field">Field name</param>
  // / <param name="Args"> an array of strings </param>
  TStringsReverter = reference to procedure(Data: TObject; Field: string;
    Args: TListOfStrings);
  // / <summary>Type for type reverters that create a value based on
  // / an array of objects</summary>
  // / <param name="Data">array of objects</param>
  // / <returns>object that will be set to any field of registered type</returns>
  TTypeObjectsReverter = reference to function(Data: TListOfObjects): TObject;
  // / <summary>Type for type reverters that create a value based on
  // / an array of strings</summary>
  // / <param name="Data">array of strings</param>
  // / <returns>object that will be set to any field of registered type</returns>
  TTypeStringsReverter = reference to function(Data: TListOfStrings): TObject;

  // / <summary>Type for field reverters that sets field to a value based on
  // / an object</summary>
  // / <param name="Data">Current object instance being serialized</param>
  // / <param name="Field">Field name</param>
  // / <param name="Arg"> an object </param>
  TObjectReverter = reference to procedure(Data: TObject; Field: string;
    Arg: TObject);
  // / <summary>Type for field reverters that sets field to a value based on
  // / a string</summary>
  // / <param name="Data">Current object instance being serialized</param>
  // / <param name="Field">Field name</param>
  // / <param name="Arg"> a string </param>
  TStringReverter = reference to procedure(Data: TObject; Field: string;
    Arg: string);
  // / <summary>Type for type reverters that create a value based on
  // / an object</summary>
  // / <param name="Data">an object</param>
  // / <returns>object that will be set to any field of registered type</returns>
  TTypeObjectReverter = reference to function(Data: TObject): TObject;
  // / <summary>Type for type reverters that create a value based on
  // / a string</summary>
  // / <param name="Data">a string</param>
  // / <returns>object that will be set to any field of registered type</returns>
  TTypeStringReverter = reference to function(Data: string): TObject;

  /// <summary>Includes all the supported reverter types.</summary>
  TReverterType = (rtObjects, rtStrings, rtTypeObjects, rtTypeStrings, rtObject,
    rtString, rtTypeObject, rtTypeString);

  /// <summary>Represents the converter event class.</summary>
  TConverterEvent = class
  private
    FFieldClassType: TClass;
    FFieldName: string;
    FConverterType: TConverterType;
    FObjectsConverter: TObjectsConverter;
    FStringsConverter: TStringsConverter;
    FTypeObjectsConverter: TTypeObjectsConverter;
    FTypeStringsConverter: TTypeStringsConverter;
    FObjectConverter: TObjectConverter;
    FStringConverter: TStringConverter;
    FTypeObjectConverter: TTypeObjectConverter;
    FTypeStringConverter: TTypeStringConverter;
  protected
    procedure SetObjectsConverter(Converter: TObjectsConverter);
    procedure SetStringsConverter(Converter: TStringsConverter);
    procedure SetTypeObjectsConverter(Converter: TTypeObjectsConverter);
    procedure SetTypeStringsConverter(Converter: TTypeStringsConverter);
    procedure SetObjectConverter(Converter: TObjectConverter);
    procedure SetStringConverter(Converter: TStringConverter);
    procedure SetTypeObjectConverter(Converter: TTypeObjectConverter);
    procedure SetTypeStringConverter(Converter: TTypeStringConverter);
  public
    constructor Create; overload;
    constructor Create(AFieldClassType: TClass; AFieldName: string); overload;

    function IsTypeConverter: Boolean;

    property ConverterType: TConverterType read FConverterType;
    property ObjectsConverter: TObjectsConverter read FObjectsConverter write SetObjectsConverter;
    property StringsConverter: TStringsConverter read FStringsConverter write SetStringsConverter;
    property TypeObjectsConverter: TTypeObjectsConverter read FTypeObjectsConverter write SetTypeObjectsConverter;
    property TypeStringsConverter: TTypeStringsConverter read FTypeStringsConverter write SetTypeStringsConverter;
    property ObjectConverter: TObjectConverter read FObjectConverter write SetObjectConverter;
    property StringConverter: TStringConverter read FStringConverter write SetStringConverter;
    property TypeObjectConverter: TTypeObjectConverter read FTypeObjectConverter write SetTypeObjectConverter;
    property TypeStringConverter: TTypeStringConverter read FTypeStringConverter write SetTypeStringConverter;
    property FieldClassType: TClass read FFieldClassType;
    property FieldName: string read FFieldName;
  end;

  TReverterEvent = class
  private
    FFieldClassType: TClass;
    FFieldName: string;
    FReverterType: TReverterType;
    FObjectsReverter: TObjectsReverter;
    FStringsReverter: TStringsReverter;
    FTypeObjectsReverter: TTypeObjectsReverter;
    FTypeStringsReverter: TTypeStringsReverter;
    FObjectReverter: TObjectReverter;
    FStringReverter: TStringReverter;
    FTypeObjectReverter: TTypeObjectReverter;
    FTypeStringReverter: TTypeStringReverter;
  protected
    procedure SetObjectsReverter(Reverter: TObjectsReverter);
    procedure SetStringsReverter(Reverter: TStringsReverter);
    procedure SetTypeObjectsReverter(Reverter: TTypeObjectsReverter);
    procedure SetTypeStringsReverter(Reverter: TTypeStringsReverter);
    procedure SetObjectReverter(Reverter: TObjectReverter);
    procedure SetStringReverter(Reverter: TStringReverter);
    procedure SetTypeObjectReverter(Reverter: TTypeObjectReverter);
    procedure SetTypeStringReverter(Reverter: TTypeStringReverter);
  public
    constructor Create; overload;
    constructor Create(AFieldClassType: TClass; AFieldName: string); overload;

    function IsTypeReverter: Boolean;

    property ReverterType: TReverterType read FReverterType;
    property ObjectsReverter: TObjectsReverter read FObjectsReverter write SetObjectsReverter;
    property StringsReverter: TStringsReverter read FStringsReverter write SetStringsReverter;
    property TypeObjectsReverter: TTypeObjectsReverter read FTypeObjectsReverter write SetTypeObjectsReverter;
    property TypeStringsReverter: TTypeStringsReverter read FTypeStringsReverter write SetTypeStringsReverter;
    property ObjectReverter: TObjectReverter read FObjectReverter write SetObjectReverter;
    property StringReverter: TStringReverter read FStringReverter write SetStringReverter;
    property TypeObjectReverter: TTypeObjectReverter read FTypeObjectReverter write SetTypeObjectReverter;
    property TypeStringReverter: TTypeStringReverter read FTypeStringReverter write SetTypeStringReverter;

    property FieldClassType: TClass read FFieldClassType;
    property FieldName: string read FFieldName;
  end;

  TJSONCanPopulateProc = TFunc<TObject,TRttiField,Boolean>;
  TJSONPopulationCustomizer = class
  private
    FCanPopulate: TJSONCanPopulateProc;
  protected
    function CanPopulate(Data: TObject; rttiField: TRttiField): Boolean; virtual;
    procedure PrePopulateObjField(Data: TObject; rttiField: TRttiField); virtual;
    procedure DoFieldPopulated(Data: TObject; rttiField: TRttiField); virtual;
  public
    constructor Create(ACanPopulate: TJSONCanPopulateProc);
    /// <summary>Customizer to alter an unmarshalled object instance before
    /// populating fields</summary>
    /// <param name="Data">Current object instance being serialized</param>
    /// <param name="rttiContext">RTTI context for field reflection</param>
    procedure PrePopulate(Data: TObject; rttiContext: TRttiContext); virtual;
    /// <summary>Customizer to alter an unmarshalled object instance after
    /// populating fields</summary>
    /// <param name="Data">Current object instance being serialized</param>
    procedure PostPopulate(Data: TObject); virtual;
  end;

  TJSONInterceptor = class
  private
    FConverterType: TConverterType;
    FReverterType: TReverterType;
  public
    /// <summary>Converters that transforms a field value into an
    /// array of objects</summary>
    /// <param name="Data">Current object instance being serialized</param>
    /// <param name="Field">Field name</param>
    /// <result> an array of serializable objects </result>
    function ObjectsConverter(Data: TObject; Field: string): TListOfObjects; virtual;
    /// <summary>Converter that transforms a field value into an
    /// array of strings</summary>
    /// <param name="Data">Current object instance being serialized</param>
    /// <param name="Field">Field name</param>
    /// <result> an array of strings </result>
    function StringsConverter(Data: TObject; Field: string): TListOfStrings; virtual;
    /// <summary>Converter that transforms any object into an array of intermediate
    /// objects</summary>
    /// <param name="Data">Current object instance</param>
    /// <result> an array of serializable objects </result>
    function TypeObjectsConverter(Data: TObject): TListOfObjects; virtual;
    /// <summary>Converter that transforms an object instance into an array of
    /// strings</summary>
    /// <param name="Data">Current object instance</param>
    /// <result> an array of strings </result>
    function TypeStringsConverter(Data: TObject): TListOfStrings; virtual;
    /// <summary>Converters that transforms a field value into an
    /// intermediate object</summary>
    /// <param name="Data">Current object instance being serialized</param>
    /// <param name="Field">Field name</param>
    /// <result> a serializable object </result>
    function ObjectConverter(Data: TObject; Field: string): TObject; virtual;
    /// <summary>Converters that transforms a field value into an
    /// string</summary>
    /// <param name="Data">Current object instance being serialized</param>
    /// <param name="Field">Field name</param>
    /// <result> a string </result>
    function StringConverter(Data: TObject; Field: string): string; virtual;
    /// <summary>Converter that transforms an object into an equivalent
    /// that can be eventually marshaled</summary>
    /// <param name="Data">Current object instance</param>
    /// <result> an intermediate object </result>
    function TypeObjectConverter(Data: TObject): TObject; virtual;
    /// <summary>Converter for an object instance into a string</summary>
    /// <param name="Data">Current object</param>
    /// <result>string equivalent</result>
    function TypeStringConverter(Data: TObject): string; virtual;
    /// <summary>Field reverter that sets an object field to a value based on
    /// an array of intermediate objects</summary>
    /// <param name="Data">Current object instance being populated</param>
    /// <param name="Field">Field name</param>
    /// <param name="Args"> an array of objects </param>
    procedure ObjectsReverter(Data: TObject; Field: string;
      Args: TListOfObjects); virtual;
    /// <summary>Reverter that sets an object field to a value based on
    /// an array of strings</summary>
    /// <param name="Data">Current object instance being populated</param>
    /// <param name="Field">Field name</param>
    /// <param name="Args"> an array of strings </param>
    procedure StringsReverter(Data: TObject; Field: string;
      Args: TListOfStrings); virtual;
    /// <summary>Reverter that creates an object instance based on
    /// an array of intermediate objects</summary>
    /// <param name="Data">array of intermediate objects</param>
    /// <returns>object that will be set to any field of registered type</returns>
    function TypeObjectsReverter(Data: TListOfObjects): TObject; virtual;
    /// <summary>Reverter that creates an object instance from string array</summary>
    /// <param name="Data">array of strings</param>
    /// <returns>object that will be set to any field of registered type</returns>
    function TypeStringsReverter(Data: TListOfStrings): TObject; virtual;
    /// <summary>Reverter that sets an object field to a value based on
    /// an intermediate object</summary>
    /// <param name="Data">Current object instance being populated</param>
    /// <param name="Field">Field name</param>
    /// <param name="Arg"> intermediate object </param>
    procedure ObjectReverter(Data: TObject; Field: string; Arg: TObject); virtual;
    /// <summary>Reverter that sets an object field to a value from
    /// a string</summary>
    /// <param name="Data">Current object instance being populated</param>
    /// <param name="Field">Field name</param>
    /// <param name="Arg">serialized value as a string </param>
    procedure StringReverter(Data: TObject; Field: string; Arg: string); virtual;
    /// <summary>Reverter that creates a value based on an object</summary>
    /// <param name="Data">TObject - intermediate object</param>
    /// <returns>object that will be set to any field of registered type</returns>
    function TypeObjectReverter(Data: TObject): TObject; virtual;
    /// <summary>Creates an instance based from a string</summary>
    /// <param name="Data">String - string value</param>
    /// <returns>TObject - object that will be set to any field of registered type</returns>
    function TypeStringReverter(Data: string): TObject; virtual;

    function IsTypeConverter: Boolean;
    function IsTypeReverter: Boolean;

    property ConverterType: TConverterType read FConverterType write FConverterType;
    property ReverterType: TReverterType read FReverterType write FReverterType;
  end;

  /// <summary>Represents an attribute that defines the interceptor used to
  /// marshal and unmarshal data.</summary>
  JSONReflect = class(TCustomAttribute)
  private
    FMarshalOwner: Boolean;
    FConverterType: TConverterType;
    FReverterType: TReverterType;
    FInterceptor: TClass;
    FPopulationCustomizer: TClass;
  public
    constructor Create(IsMarshalOwned: Boolean); overload;
    constructor Create(ConverterType: TConverterType;
      ReverterType: TReverterType; InterceptorType: TClass = nil;
      PopulationCustomizerType: TClass = nil;
      IsMarshalOwned: Boolean = false); overload;

    /// <summary>Creates a TJSONInterceptor instance from the current definition.
    /// </summary>
    /// <remarks>The caller takes ownership of that object</remarks>
    /// <returns>TJSONInterceptor - interceptor instance</returns>
    function JSONInterceptor: TJSONInterceptor;

    /// <summary>Creates a TJSONPopulationCustomizer instance from the current
    /// definition.</summary>
    /// <remarks>The caller takes ownership of that object</remarks>
    /// <returns>TJSONPopulationCustomizer - population customizer instance</returns>
    function JSONPopulationCustomizer: TJSONPopulationCustomizer;

    /// <summary> If true, the intermediate objects created during marshalling are freed</summary>
    property MarshalOwner: Boolean read FMarshalOwner;
  end;

  JSONBooleanAttribute = class(TCustomAttribute)
  private
    FValue: Boolean;
  public
    constructor Create(val: Boolean = true);
    property Value: Boolean read FValue;
  end;

  /// <summary>Attribute that specifies whether a field or type should be
  /// marshalled or unmarshalled.</summary>
  JSONMarshalled = class(JSONBooleanAttribute)
  end;

  /// <summary>Attribute that specifies whether a field should be freed before
  /// being populated during the unmarshalling process.</summary>
  JSONOwned = class(JSONBooleanAttribute)
  end;

  /// <summary>Represents the class holder for transient fields.</summary>
  TTransientField = class
  private
    FClassUnitName: string;
    FClassTypeName: string;
    FUnitName: string;
    FTypeName: string;
    FFieldName: string;
    FTypeInstance: TObject;
  public
    /// <summary>Fields' class type unit name</summary>
    property ClassUnitName: string read FClassUnitName write FClassUnitName;
    /// <summary>Fields' class type class name</summary>
    property ClassTypeName: string read FClassTypeName write FClassTypeName;
    /// <summary>Field type unit name</summary>
    {$WARN HIDING_MEMBER OFF}
    property UnitName: string read FUnitName write FUnitName;
    {$WARN HIDING_MEMBER ON}
    /// <summary>Field type class name</summary>
    property TypeName: string read FTypeName write FTypeName;
    /// <summary>Field name</summary>
    property FieldName: string read FFieldName write FFieldName;
    /// <summary>Object instance owning the field value</summary>
    property TypeInstance: TObject read FTypeInstance write FTypeInstance;
  end;

  TMarshalUnmarshalBase = class
  private
    FWarnings: TArray<TTransientField>;
    FMarshalled: TDictionary<string, Boolean>;
    procedure RegisterJSONMarshalled(AComposeKey: string; Marshal: Boolean); overload;
  protected
    /// <summary> Adds a new warnings </summary>
    /// <param name="Data">Object instance where the fields cannot be marshalled</param>
    /// <param name="FieldClassUnit">Fields' class unit name</param>
    /// <param name="FieldClassName">Fields' class name</param>
    /// <param name="FieldTypeUnit">Fields' value class unit name</param>
    /// <param name="FieldTypeName">Fields' value class name</param>
    /// <param name="FieldName">Fields' name</param>
    procedure AddWarning(Data: TObject; FieldClassUnit: string;
      FieldClassName: string; FieldTypeUnit: string; FieldTypeName: string;
      FieldName: string); virtual;
  public
    /// <summary>static function for key generation used in dictionary lookups</summary>
    /// <param name="clazz">a meta class</param>
    /// <param name="field">field name</param>
    /// <returns>dictionary key</returns>
    class function ComposeKey(clazz: TClass; Field: string): string; overload;

    /// <summary>Registers whether a field or type should be
    /// marshalled/unmarshalled. This takes priority over the
    /// JSONMarshalled attribute, which defaults to true.
    /// If Marshal is false, the field/type will be skipped during the marshalling or
    /// unmarshalling process</summary>
    /// <remarks>This takes priority over the JSONMarshalled attribute</remarks>
    /// <param name="clazz">object metaclass</param>
    /// <param name="field">field name</param>
    /// <param name="marshal">marshal flag</param>
    procedure RegisterJSONMarshalled(clazz: TClass; Field: string; Marshal: Boolean); overload;
    /// <summary>Unregisters whether a field or type should be
    /// marshalled/unmarshalled. This clears the existing registration
    /// and defaults back to the JSONMarshalled attribute (if present), and true
    /// if no attribute is available</summary>
    /// <remarks>Clears the existing JSONMarshalled registration if set</remarks>
    /// <param name="clazz">object metaclass</param>
    /// <param name="field">field name</param>
    procedure UnregisterJSONMarshalled(clazz: TClass; Field: string);
    /// <summary>Checks whether or not an object field should be marshalled
    /// based on the JSONMarshalled registration and attribute</summary>
    /// <remarks>The JSONMarshalled registration takes priority over the attribute,
    /// and both default to True</remarks>
    /// <param name="Data">Data to be marshalled</param>
    /// <param name="rttiField">TRTTIField - rtti instance associated with the field</param>
    /// <returns>whether or not to marshal</returns>
    function ShouldMarshal(Data: TObject; rttiField: TRTTIField): Boolean;

    /// <summary> Returns true if the marshalling process generated warnings</summary>
    /// <remarks> List of transient fields can be accessed through the Warnings property.
    /// Warnings are available until next marshal call.
    /// </remarks>
    /// <returns>True if the marshalling has warnings</returns>
    function HasWarnings: Boolean;
    /// <summary> Clears the warning list </summary>
    /// <remarks> If one needs to hold on to the warning objects beyond past
    /// the next marshal call then the warnings can be cleared with false as
    /// an argument.
    /// </remarks>
    /// <param name="OwnWarningObject">true (default) if the warnings objects can
    /// be released</param>
    procedure ClearWarnings(OwnWarningObject: Boolean = true); virtual;
    /// <summary> Marshalling process warnings list </summary>
    property Warnings: TArray<TTransientField>read FWarnings;
    constructor Create;
    destructor Destroy; override;
  end;

  /// <summary>Represents the marshaling parent class.</summary>
  TTypeMarshaller<TSerial: class> = class(TMarshalUnmarshalBase)
  private
    FObjectHash: TDictionary<NativeInt, Integer>;
    FPointerHash: TDictionary<Integer, Integer>;
    FId: Integer;
    FConverter: TConverter<TSerial>;
    FOwnConverter: Boolean;
    FConverters: TDictionary<string, TConverterEvent>;
    FShareConverters: Boolean;
    FRTTICtx: TRTTIContext;

  private
    function MarshalSimpleField(rttiField: TRTTIField; Data: Pointer): Boolean;

    procedure DestroyIfTransient(rttiType: TRttiType; Data: TObject);

  protected
    /// <summary>composes the type name by qualifying the class name with the
    /// unit name</summary>
    /// <param name="Data">non-nil object instance</param>
    class function ComposeTypeName(Data: TObject): string;
    /// <summary>restores the unit name and the class name from a type name</summary>
    /// <param name="TypeName">Type name generated by ComposeTypeName</param>
    /// <param name="UnitName">Type unit name</param>
    /// <param name="ClassName">Type class name</param>
    class procedure DecomposeTypeName(TypeName: string; out UnitName: string;
      out ClassName: string);
    /// <summary>Return the next available object id</summary>
    /// <returns>Next available object id as an integer</returns>
    function NextId: Integer;
    /// <summary>Returns the new id associated with a given non-nill object instance
    /// </summary>
    /// <param name="Data">An object instance</param>
    /// <returns>Object id</returns>
    function MarkObject(Data: TObject): Integer;
    /// <summary>returns true if the argument was already marked</summary>
    /// <param name="Data">current user object</param>
    /// <returns>true if the object was marked before</returns>
    function IsObjectMarked(Data: TObject): Boolean;
    /// <summary>Returns an object id</summary>
    /// <remarks>Assumes the object is marked, once can use IsObjectMarked before</remarks>
    /// <param name="Data">non-nil object instance</param>
    /// <returns>object id</returns>
    function ObjectMark(Data: TObject): Integer;
    /// <summary>Returns the converter associate with a class and a field</summary>
    /// <remarks>Assumes the converter exists</remarks>
    /// <param name="clazz">Object type</param>
    /// <param name="field">field name</param>
    /// <returns>converter associated with class and field</returns>
    function Converter(clazz: TClass; Field: string): TConverterEvent;
    /// <summary>Checks for the existance of a converter for given meta class and field</summary>
    /// <param name="clazz">Object type</param>
    /// <param name="field">field name</param>
    /// <returns>true if there is a converter associated with type and field</returns>
    function HasConverter(clazz: TClass; Field: string): Boolean;
    /// <summary>Returns the attribute interceptor defined with a class type</summary>
    /// <remarks>Returns nil if there is no attribute defined with the type</remarks>
    /// <param name="clazz">TClass - class type</param>
    /// <returns>TJSONInterceptor instance</returns>
    function GetTypeConverter(clazz: TClass): TJSONInterceptor; overload;
    /// <summary>Returns the attribute interceptor defined with a class type using the class type RTTI instance</summary>
    /// <remarks>Returns nil if there is no attribute defined with the type. It is
    /// expected that the attribute defines a type interceptor
    /// </remarks>
    /// <param name="rttiType">TRTTIType - rtti instance associated with the user class type</param>
    /// <returns>TJSONInterceptor instance</returns>
    function GetTypeConverter(rttiType: TRttiType): TJSONInterceptor; overload;
    /// <summary>Returns the attribute interceptor defined with a field using the field RTTI instance</summary>
    /// <remarks>Returns nil if there is no attribute defined with the field. It is
    /// expected that the attribute defines a value interceptor
    /// </remarks>
    /// <param name="rttiField">TRTTIField - rtti instance associated with the field</param>
    /// <returns>TJSONInterceptor instance</returns>
    function GetTypeConverter(rttiField: TRTTIField): TJSONInterceptor; overload;
    //// <summary>Returns true if there is an attribute interceptor defined for a given field</summary>
    /// <param name="rttiField">TRTTIField - rtti instance associated with the field</param>
    /// <returns>boolean - true if there is an interceptor defined</returns>
    function HasInterceptor(rttiField: TRTTIField): Boolean;
    /// <summary>Marshal argument using default converters if user converters are
    /// not defined</summary>
    /// <remarks>If no user converters are defined, it tries to use the default
    /// ones. If a type converter exists then that one is used. If a field converter
    /// is used that the field converter is used. The field converter has precedence
    /// over the type one. </remarks>
    /// <param name="Data">Data to be marshelled</param>
    procedure MarshalData(Data: TObject);
    /// <summary>Marshal argument independent of field name or type</summary>
    /// <param name="Value">Data to be marshelled</param>
    /// <param name="fieldRTTI">TRTTIField - rtti instance associated with the field</param>
    procedure MarshalValue(Value: TValue; fieldRTTI: TRTTIField = nil);
    /// <summary>Marshal argument using a registered field converter</summary>
    /// <param name="Data">Data to be marshalled</param>
    /// <param name="field">field name</param>
    procedure MarshalConverter(Data: TObject; Field: string); overload;
    /// <summary>Marshal argument using a field converter</summary>
    /// <param name="Data">Data to be marshalled</param>
    /// <param name="field">field name</param>
    /// <param name="ConverterEvent">user converter registered with this instance</param>
    procedure MarshalConverter(Data: TObject; Field: string;
      ConverterEvent: TConverterEvent); overload;
    /// <summary>Marshal argument using an attribute interceptor</summary>
    /// <param name="Data">Data to be marshalled</param>
    /// <param name="field">field name</param>
    /// <param name="ConverterEvent">interceptor defined through the attribute</param>
    procedure MarshalConverter(Data: TObject; Field: string;
      ConverterEvent: TJSONInterceptor); overload;
    /// <summary>Marshal argument using a type converter</summary>
    /// <param name="Data">Data to be marshalled</param>
    /// <param name="field">field name</param>
    /// <param name="ConverterEvent">type converter</param>
    procedure MarshalTypeConverter(Data: TObject; Field: string;
      ConverterEvent: TConverterEvent); overload;
    /// <summary>Marshal argument using a user interceptor</summary>
    /// <param name="Data">Data to be marshalled</param>
    /// <param name="field">field name</param>
    /// <param name="ConverterEvent">user interceptor instance</param>
    procedure MarshalTypeConverter(Data: TObject; Field: string;
      ConverterEvent: TJSONInterceptor); overload;
  public
    /// <summary>Marshal constructor for a given converter.</summary>
    /// <remarks> The converter is freed if second parameter is true (default)</remarks>
    /// <param name="Converter">implementation for On* events</param>
    /// <param name="OwnConverter">If true (default) it takes ownership of the
    /// converter</param>
    constructor Create(Converter: TConverter<TSerial>;
      OwnConverter: Boolean = true); overload; virtual;
    constructor Create(Converter: TConverter<TSerial>; OwnConverter: Boolean;
      Converters: TObjectDictionary<string, TConverterEvent>); overload; virtual;
    destructor Destroy; override;

    /// <summary>Marshals an object into an equivalent representation.</summary>
    /// <remarks>It uses the converter passed in the constructor</remarks>
    /// <param name="Data">Object instance to be serialized</param>
    /// <returns> the serialized equivalent</returns>
    function Marshal(Data: TObject): TSerial; virtual;

    /// <summary>Registers a user converter event</summary>
    /// <remarks>The converter event will be released by the destructor</remarks>
    /// <param name="clazz">object metaclass</param>
    /// <param name="field">field name</param>
    /// <param name="converter">converter event implementation</param>
    procedure RegisterConverter(clazz: TClass; Field: string;
      Converter: TConverterEvent); overload;
    /// <summary> Convenience user converter registration for object list</summary>
    /// <remarks> The event converter instance is created behind the scene</remarks>
    /// <param name="clazz">meta class</param>
    /// <param name="field">field name</param>
    /// <param name="func"> object list converter</param>
    procedure RegisterConverter(clazz: TClass; Field: string;
      func: TObjectsConverter); overload;
    /// <summary> Convenience user defined converter registration for object</summary>
    /// <remarks> The converter event is created behind the scene</remarks>
    /// <param name="clazz">meta class</param>
    /// <param name="field">field name</param>
    /// <param name="func"> object converter</param>
    procedure RegisterConverter(clazz: TClass; Field: string;
      func: TObjectConverter); overload;
    /// <summary> Convenience user defined converter registration for string array</summary>
    /// <remarks> A converter event is created behind the scene</remarks>
    /// <param name="clazz">meta class</param>
    /// <param name="field">field name</param>
    /// <param name="func"> user converter for string array</param>
    procedure RegisterConverter(clazz: TClass; Field: string;
      func: TStringsConverter); overload;
    /// <summary> Convenience user defined converter registration for string</summary>
    /// <param name="clazz">meta class</param>
    /// <param name="field">field name</param>
    /// <param name="func"> user defined string converter</param>
    procedure RegisterConverter(clazz: TClass; Field: string;
      func: TStringConverter); overload;
    /// <summary> Convenience user converter registration for object list</summary>
    /// <param name="clazz">meta class</param>
    /// <param name="func"> user defined converter for string array</param>
    procedure RegisterConverter(clazz: TClass; func: TTypeObjectsConverter); overload;
    /// <summary> Convenience user defined converter registration for object</summary>
    /// <param name="clazz">meta class</param>
    /// <param name="func"> user defined converter for object</param>
    procedure RegisterConverter(clazz: TClass; func: TTypeObjectConverter); overload;
    /// <summary> Convenience user defined converter registration for string array</summary>
    /// <param name="clazz">meta class</param>
    /// <param name="func"> type converter for string array</param>
    procedure RegisterConverter(clazz: TClass; func: TTypeStringsConverter); overload;
    /// <summary> Convenience user defined converter registration for string</summary>
    /// <param name="clazz">meta class</param>
    /// <param name="func"> type converter for string</param>
    procedure RegisterConverter(clazz: TClass; func: TTypeStringConverter); overload;
  end;

  TJSONConverter = class(TConverter<TJSONValue>)
  private
    FRoot: TJSONValue;
    FStack: TStack<TJSONAncestor>;
  protected
    function GetSerializedData: TJSONValue; override;
    procedure ProcessData(Data: TJSONAncestor); virtual;
    function GetCurrent: TJSONAncestor;

    property Current: TJSONAncestor read GetCurrent;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure OnRefType(TypeName: string; id: Integer); override;
    procedure OnTypeStart(TypeName: string; id: Integer); override;
    procedure OnTypeEnd(TypeName: string; id: Integer); override;
    procedure OnFieldStart(FieldName: string); override;
    procedure OnFieldEnd(FieldName: string); override;
    procedure OnListStart; override;
    procedure OnListEnd; override;
    procedure OnString(Data: string); override;
    procedure OnNumber(Data: string); override;
    procedure OnBoolean(Data: Boolean); override;
    procedure OnNull; override;
    function IsConsistent: Boolean; override;
    procedure SetCurrentValue(Data: TJSONValue); override;
  end;

  TJSONMarshal = class(TTypeMarshaller<TJSONValue>)
  public
    constructor Create; overload;
    constructor Create(Converter: TConverter<TJSONValue>;
      OwnConverter: Boolean = true); overload; override;
    constructor Create(Converter: TConverter<TJSONValue>; OwnConverter: Boolean;
      Converters: TObjectDictionary<string, TConverterEvent>); overload; override;
  end;

  /// <summary>Represents the unmarshaling class for JSON objects.</summary>
  TJSONUnMarshal = class(TMarshalUnmarshalBase)
  private
    FObjectHash: TDictionary<string, TObject>;
    FReverters: TDictionary<string, TReverterEvent>;
    FRTTICtx: TRTTIContext;
    FShareReverters: Boolean;
    class function ObjectType(Ctx: TRTTIContext; TypeName: string): TRttiType;
  public
    /// <summary>Creates a new instance of an object based on type name
    /// </summary>
    /// <remarks>It is assumed the object has a no-parameter Create constructor
    /// </remarks>
    /// <param name="Ctx">runtime context information instance</param>
    /// <param name="TypeName">object type as generated by marshal ComposeKey</param>
    /// <returns>object instance or nil if creation fails</returns>
    class function ObjectInstance(Ctx: TRTTIContext; TypeName: string): TObject;

  protected
    /// <summary>returns true if a reverter matching the given key was registered
    /// </summary>
    /// <param name="key">reverter key, as generated by ComposeKey</param>
    /// <returns>true if a reverter is available</returns>
    function HasReverter(key: string): Boolean;
    /// <summary>Returns the reverter defined by a JSONReverter attribute, if any</summary>
    /// <param name="field">TRTTIField instance associated with object field to be reverted</param>
    /// <returns>TReverterEvent instance defined by the attribute, nil there is no JSONReverter attribute</returns>
    function FieldReverter(Field: TRTTIField): TJSONInterceptor; overload;
    /// <summary>Returns the reverter defined by a JSONReverter attribute, if any</summary>
    /// <param name="Data">TObject - current data instance</param>
    /// <param name="Field">String - field name where an JSONReverter attribute was defined</param>
    /// <returns>TReverterEvent instance defined by the attribute, nil there is no JSONReverter attribute</returns>
    function FieldReverter(Data: TObject; Field: string): TJSONInterceptor; overload;
    function FieldTypeReverter(ctxType: TRttiType): TJSONInterceptor; overload;
    function FieldTypeReverter(Data: TObject; Field: string): TJSONInterceptor; overload;
    /// <summary>Returns the reverter registered with the given key</summary>
    /// <param name="key">reverter key</param>
    /// <returns>reverter event instance</returns>
    function Reverter(key: string): TReverterEvent;
    /// <summary>Returns the meta-class of a field</summary>
    /// <param name="Data">object instance</param>
    /// <param name="Field">object field name</param>
    /// <returns>meta class instance</returns>
    function ClassTypeOf(Data: TObject; Field: string): TClass;

    /// <summary>returns true if the object id identifies a created object
    /// </summary>
    /// <param name="ObjId">object id</param>
    /// <returns>true if there is an object with given id</returns>
    function HasObject(ObjId: string): Boolean;
    /// <summary>stores an object based on object id</summary>
    /// <param name="ObjId">object key</param>
    /// <param name="Obj">object instance</param>
    procedure StoreObject(ObjId: string; Obj: TObject);
    /// <summary>returns a stored object based on its id</summary>
    /// <param name="ObjId">object key</param>
    function GetObject(ObjId: string): TObject;
    /// <summary>returns field's RTTI info</summary>
    /// <param name="Data">object instance</param>
    /// <param name="Field">field name</param>
    /// <returns>TRTTIField - RTTI field instance</returns>
    function GetFieldType(Data: TObject; Field: string): TRTTIField;
    /// <summary>sets an object field with given object value</summary>
    /// <param name="Data">object instance</param>
    /// <param name="Field">field name</param>
    /// <param name="Value">field value</param>
    procedure SetField(Data: TObject; Field: string; Value: TObject); overload;
    /// <summary>sets an object field with given string value</summary>
    /// <param name="Data">object instance</param>
    /// <param name="Field">field name</param>
    /// <param name="Value">field value</param>
    procedure SetField(Data: TObject; Field: string; Value: string); overload;
    /// <summary>sets an object field with given boolean value</summary>
    /// <param name="Data">object instance</param>
    /// <param name="Field">field name</param>
    /// <param name="Value">field value</param>
    procedure SetField(Data: TObject; Field: string; Value: Boolean); overload;
    /// <summary>sets an object field to nil</summary>
    /// <param name="Data">object instance</param>
    /// <param name="Field">field name</param>
    procedure SetFieldNull(Data: TObject; Field: string);
    /// <summary>sets a field of array type
    /// </summary>
    /// <param name="Data">object instance</param>
    /// <param name="Field">field name</param>
    /// <param name="Value">field value</param>
    procedure SetFieldArray(Data: TObject; Field: string; Value: TJSONArray);
    /// <summary>creates an object based on a serialized JSON representation
    /// </summary>
    /// <param name="JsonObj">JSON object instance</param>
    /// <returns>object instance</returns>
    function CreateObject(JsonObj: TJSONObject): TObject;
    /// <summary>creates an object based on a serialized JSON representation
    ///  If the object cannot be instantiated based on the marshalled type
    ///  name, a warning is added to notify the user
    /// </summary>
    /// <param name="Data">object instance</param>
    /// <param name="Field">field name</param>
    /// <param name="JsonObj">JSON object instance</param>
    /// <param name="MarshalledObj">Object unmarshalled from jsonObj</param>
    /// <returns>object instance</returns>
    function TryCreateObject(Data: TObject; Field: string; JsonObj: TJSONObject; out MarshalledObj: TObject): Boolean;
    /// <summary>populates the instance fields with values from the JSON
    /// serialized representation</summary>
    /// <param name="JsonFields">serialized fields object</param>
    /// <param name="Data">object instance</param>
    /// <param name="JsonCustomizer">population customizer instance</param>
    procedure PopulateFields(JsonFields: TJSONObject; Data: TObject; JsonCustomizer: TJSONPopulationCustomizer);
    /// <summary>transforms a JSON array into an array of objects</summary>
    /// <param name="JsonArray">JSON array for a list of objects</param>
    /// <returns>list of objects</returns>
    function GetArgObjects(JsonArray: TJSONArray): TListOfObjects;
    /// <summary>transforms a JSON array into an array of strings</summary>
    /// <param name="JsonArray">JSON array for a list of strings</param>
    /// <returns>list of strings</returns>
    function GetArgStrings(JsonArray: TJSONArray): TListOfStrings;
    /// <summary> Converts a JSON value into its TValue equivalent based
    /// on given type info
    /// </summary>
    /// <remarks>Throws exception if the conversion is not possible</remarks>
    /// <param name="JsonValue">JSON value</param>
    /// <param name="rttiType">type to be converted into</param>
    /// <returns>TValue equivalent of JsonValue</returns>
    function JSONToTValue(JsonValue: TJSONValue; rttiType: TRttiType): TValue;
    /// <summary> Marshal a string into a TValue based on type info
    /// </summary>
    /// <remarks>Throws exception if the conversion is not possible</remarks>
    /// <param name="Value">string value</param>
    /// <param name="typeInfo">type to be converted into</param>
    /// <returns>TValue equivalent of Value</returns>
    function StringToTValue(Value: string; typeInfo: PTypeInfo): TValue;
    /// <summary> Invokes the reverter event for a given field. As an end result
    /// the field is populated with a value from its JSON representation
    /// </summary>
    /// <param name="recField">TRTTIField - RTTI field to be populated</param>
    /// <param name="Instance">Pointer - current object address</param>
    /// <param name="revEv">TReverterEvent - user reverter that will generate
    /// the field value </param>
    /// <param name="jsonFieldVal">TJSONValue - JSON value used to populate user's value</param>
    procedure RevertType(recField: TRTTIField; Instance: Pointer;
      revEv: TReverterEvent; jsonFieldVal: TJSONValue); overload;
    /// <summary> Invokes the interceptor for a given field. As an end result
    /// the field is populated with a value from its JSON representation. The
    /// interceptor is defined through an attribute
    /// </summary>
    /// <param name="recField">TRTTIField - RTTI field to be populated</param>
    /// <param name="Instance">Pointer - current object address</param>
    /// <param name="revEv">TJSONInterceptor - instance of the user interceptor that will generate
    /// the field value. The interceptor is specified through an attribute </param>
    /// <param name="jsonFieldVal">TJSONValue - JSON value used to populate user's value</param>
    procedure RevertType(recField: TRTTIField; Instance: Pointer;
      revEv: TJSONInterceptor; jsonFieldVal: TJSONValue); overload;

  public
    constructor Create; overload; virtual;
    constructor Create(Reverters: TObjectDictionary<string, TReverterEvent>); overload; virtual;
    destructor Destroy; override;

    /// <summary>Creates an user object based on a marshalled representation
    /// into a JSON object.</summary>
    /// <remarks>It is assumed that reverters are registered with the object
    /// instance prior to this call matching the converters used in marshalling
    /// process.</remarks>
    /// <param name="Data">serialized JSON instance</param>
    /// <returns>user object inatance</returns>
    function Unmarshal(Data: TJSONValue): TObject;

    /// <summary>Registers a user reverter event</summary>
    /// <remarks>The reverter event object will be released by the destructor</remarks>
    /// <param name="clazz">object metaclass</param>
    /// <param name="field">field name</param>
    /// <param name="reverter">reverter event implementation</param>
    procedure RegisterReverter(clazz: TClass; Field: string;
      Reverter: TReverterEvent); overload;
    /// <summary> Convenience method for user revertor registration for an object list</summary>
    /// <remarks> The event reverter instance is created behind the scene</remarks>
    /// <param name="clazz">meta class</param>
    /// <param name="field">field name</param>
    /// <param name="func"> object list reverter</param>
    procedure RegisterReverter(clazz: TClass; Field: string;
      func: TObjectsReverter); overload;
    /// <summary> Convenience method for user revertor registration for an object instance</summary>
    /// <remarks> The event reverter instance is created behind the scene</remarks>
    /// <param name="clazz">meta class</param>
    /// <param name="field">field name</param>
    /// <param name="func"> object instance reverter</param>
    procedure RegisterReverter(clazz: TClass; Field: string;
      func: TObjectReverter); overload;
    /// <summary> Convenience method for user revertor registration for an string list</summary>
    /// <remarks> The event reverter instance is created behind the scene</remarks>
    /// <param name="clazz">meta class</param>
    /// <param name="field">field name</param>
    /// <param name="func">string list reverter</param>
    procedure RegisterReverter(clazz: TClass; Field: string;
      func: TStringsReverter); overload;
    /// <summary> Convenience method for user revertor registration for a string</summary>
    /// <remarks> The event reverter instance is created behind the scene</remarks>
    /// <param name="clazz">meta class</param>
    /// <param name="field">field name</param>
    /// <param name="func"> string generated by a converter</param>
    procedure RegisterReverter(clazz: TClass; Field: string;
      func: TStringReverter); overload;
    /// <summary> Convenience method for user type revertor registration for an object list</summary>
    /// <remarks> The event reverter instance is created behind the scene</remarks>
    /// <param name="clazz">meta class</param>
    /// <param name="func"> object list reverter</param>
    procedure RegisterReverter(clazz: TClass; func: TTypeObjectsReverter); overload;
    /// <summary> Convenience method for user type revertor registration for an object</summary>
    /// <remarks> The event reverter instance is created behind the scene</remarks>
    /// <param name="clazz">meta class</param>
    /// <param name="func"> object list reverter</param>
    procedure RegisterReverter(clazz: TClass; func: TTypeObjectReverter); overload;
    /// <summary> Convenience method for user type revertor registration for a string list</summary>
    /// <remarks> The event reverter instance is created behind the scene</remarks>
    /// <param name="clazz">meta class</param>
    /// <param name="func">string list reverter</param>
    procedure RegisterReverter(clazz: TClass; func: TTypeStringsReverter); overload;
    /// <summary> Convenience method for user type revertor registration for a string</summary>
    /// <remarks> The event reverter instance is created behind the scene</remarks>
    /// <param name="clazz">meta class</param>
    /// <param name="func">string generated by a type converter</param>
    procedure RegisterReverter(clazz: TClass; func: TTypeStringReverter); overload;
  end;

  /// <summary>TSerStringItem is a class for TStringList items that can be
  /// serialized.</summary>
  TSerStringItem = class
  private
    FString: string;
    FObject: TObject;
  public
    constructor Create(AString: string; AObject: TObject);
  end;

  /// <summary>Serializable TStringList object</summary>
  [JSONReflect(true)]
  TSerStringList = class
  private
    FSerStringItemList: array of TSerStringItem;
    FSorted: Boolean;
    FDuplicates: TDuplicates;
    FCaseSensitive: Boolean;
  public
    constructor Create(Source: TStringList);
    destructor Destroy; override;
    function AsStringList: TStringList;
  end;

  TStringListInterceptor = class(TJSONInterceptor)
  public
    function TypeObjectConverter(Data: TObject): TObject; override;
    function TypeObjectReverter(Data: TObject): TObject; override;
  end;

  TJSONConverters = class
  private
    class var
      CFRegConverters: TObjectDictionary<string, TConverterEvent>;
      CFRegReverters: TObjectDictionary<string, TReverterEvent>;
      CFRegMarshal: TDictionary<string, Boolean>;
  public
      class constructor Create;
      class destructor Destroy;
      class function GetJSONMarshaler: TJSONMarshal;
      class function GetJSONUnMarshaler: TJSONUnMarshal;

      class procedure AddConverter(event: TConverterEvent);
      class procedure AddReverter(event: TReverterEvent);
      class procedure AddMarshalFlag(AClass: TClass; AField: string; Marshal: Boolean);
      class procedure ClearMarshalFlag(AClass: TClass; AField: string);
   end;

/// <summary>Converts a TStringList into a TSerStringList</summary>
function StringListConverter(Data: TObject): TObject;
/// <summary>The StringListReverter reverts a TSerStringList into a
/// TStringList.</summary>
function StringListReverter(Ser: TObject): TObject;
/// <summary>Converts the pair list of a TJSONObject into a serializable
/// structure.</summary>
function JSONObjectPairListConverter(Data: TObject; Field: string): TListOfObjects;
function JSONArrayElementsConverter(Data: TObject; Field: string): TListOfObjects;
procedure JSONObjectPairListReverter(Data: TObject; Field: string; Args: TListOfObjects);
procedure JSONArrayElementsReverter(Data: TObject; Field: string; Args: TListOfObjects);

/// <summary>Returns the value of a boolean attribute of the specified class on
/// the specified RTTI object or DefaultValue if the attribute is not defined in
/// the RTTI object.</summary>
function JSONBooleanAttributeValue( rttiObject: TRttiNamedObject;
  AttributeClass: TClass; DefaultValue: Boolean = false ): Boolean;

implementation

uses
  StrUtils,
  DBXPlatform,
  DBXCommonResStrs;

type
  TInternalJSONPopulationCustomizer = class(TJSONPopulationCustomizer)
  private
    FBackupCache: TDictionary<TRttiField,TObject>;
    procedure Cleanup;
  protected
    procedure PrePopulateObjField(Data: TObject; rttiField: TRttiField); override;
    procedure DoFieldPopulated(Data: TObject; rttiField: TRttiField); override;
  public
    constructor Create(ACanPopulate: TJSONCanPopulateProc);
    destructor Destroy; override;
    procedure PostPopulate(Data: TObject); override;
  end;

const
  TYPE_NAME = 'type';
  ID_NAME = 'id';
  REF_NAME = 'ref';
  FIELDS_NAME = 'fields';
  FIELD_ANY = '*';
  SEP_DOT = '.';

/// <summary>Converts the pair list of a TJSONObject into a serializable
/// structure.</summary>
function JSONObjectPairListConverter(Data: TObject; Field: string): TListOfObjects;
var
  I: Integer;
begin
  Assert(Data is TJSONObject);
  SetLength(Result, TJSONObject(Data).Count);

  for I := 0 to TJSONObject(Data).Count - 1 do
    Result[I] := TJSONObject(Data).Pairs[I]
end;
function JSONArrayElementsConverter(Data: TObject; Field: string): TListOfObjects;
var
  I: Integer;
begin
  Assert(Data is TJSONArray);
  SetLength(Result, TJSONArray(Data).Count);
  for I := 0 to TJSONArray(Data).Count - 1 do
    Result[I] := TJSONArray(Data).Items[I]
end;

procedure JSONObjectPairListReverter(Data: TObject; Field: string; Args: TListOfObjects);
var
  I: Integer;
begin
  Assert(Data is TJSONObject);
  TJSONObject(Data).SetPairs(TList<TJSONPair>.Create);
  for I := 0 to Length(Args) - 1 do
  begin
    Assert(Args[I] <> nil);
    Assert(Args[I] is TJSONPair);
    TJSONObject(Data).AddPair(TJSONPair(Args[I]));
  end;
end;
procedure JSONArrayElementsReverter(Data: TObject; Field: string; Args: TListOfObjects);
var
  I: Integer;
begin
  Assert(Data is TJSONArray);
  TJSONArray(Data).SetElements(TList<TJSONValue>.Create);
  for I := 0 to Length(Args) - 1 do
  begin
    Assert(Args[I] <> nil);
    Assert(Args[I] is TJSONValue);
    TJSONArray(Data).AddElement(TJSONValue(Args[I]));
  end;
end;

// Provide converter and reverter because TRTTIField.FieldType is nil for TStringBuilder.FData
procedure StringBuilderReverter(Data: TObject; Field: string; Arg: string);
begin
  Assert(Data is TStringBuilder);
  TStringBuilder(Data).Clear;
  TStringBuilder(Data).Append(Arg);
end;

function StringBuilderConverter(Data: TObject; Field: string): string;
begin
  Assert(Data is TStringBuilder);
  Result := TStringBuilder(Data).ToString;
end;

{ TJSONConverter }

constructor TConverter<TSerial>.Create;
begin

end;

procedure TJSONConverter.Clear;
begin
  FStack.Clear;
  FRoot := nil;
end;

constructor TJSONConverter.Create;
begin
  FStack := TStack<TJSONAncestor>.Create;
end;

destructor TJSONConverter.Destroy;
begin
  // it is normally an error to have an non-empty stack at this point
  FreeAndNil(FStack);
  inherited;
end;

function TJSONConverter.GetCurrent: TJSONAncestor;
begin
  if FStack.Count = 0 then
    Result := nil
  else
    Result := FStack.Peek
end;

function TJSONConverter.GetSerializedData: TJSONValue;
begin
  Result := FRoot;
end;

function TJSONConverter.IsConsistent: Boolean;
begin
  Result := (FRoot <> nil) and (FStack.Count = 0)
end;

procedure TJSONConverter.OnBoolean(Data: Boolean);
begin
  if Data then
    ProcessData(TJSONTrue.Create)
  else
    ProcessData(TJSONFalse.Create)
end;

procedure TJSONConverter.OnFieldEnd(FieldName: string);
begin
  if (Current is TJSONPair)
    and (TJSONPair(Current).JsonString.Value = FieldName) then
  begin
    if TJSONPair(Current).JsonValue = nil then
      raise EConversionError.Create(Format(SFieldValueMissing, [FieldName]));
    FStack.Pop;
  end
  else
    raise EConversionError.Create(Format(SFieldExpected, [FieldName]));
end;

procedure TJSONConverter.OnFieldStart(FieldName: string);
begin
  ProcessData(TJSONPair.Create(FieldName, nil));
end;

procedure TJSONConverter.OnListEnd;
begin
  if Current is TJSONArray then
    FStack.Pop
  else if Current = nil then
    raise EConversionError.Create(Format(SArrayExpected, ['nil']))
  else
    raise EConversionError.Create(SNoArray)
end;

procedure TJSONConverter.OnListStart;
begin
  ProcessData(TJSONArray.Create);
end;

procedure TJSONConverter.OnNull;
begin
  ProcessData(TJSONNull.Create);
end;

procedure TJSONConverter.OnNumber(Data: string);
begin
  ProcessData(TJSONNumber.Create(Data));
end;

procedure TJSONConverter.OnRefType(TypeName: string; id: Integer);
begin
  ProcessData(TJSONObject.Create);
  OnFieldStart(TYPE_NAME);
  OnString(TypeName);
  OnFieldEnd(TYPE_NAME);
  OnFieldStart(REF_NAME);
  OnNumber(IntToStr(id));
  OnFieldEnd(REF_NAME);
  FStack.Pop;
end;

procedure TJSONConverter.OnString(Data: string);
begin
  ProcessData(TJSONString.Create(Data));
end;

procedure TJSONConverter.OnTypeEnd(TypeName: string; id: Integer);
begin
  FStack.Pop;
  if (FStack.Count <> 0) and (Current is TJSONPair) then
    FStack.Pop
  else
    raise EConversionError.Create(STypeFieldsPairExpected);
  if (FStack.Count <> 0) and (Current is TJSONObject) then
    FStack.Pop
  else
    raise EConversionError.Create(STypeExpected);
end;

procedure TJSONConverter.OnTypeStart(TypeName: string; id: Integer);
begin
  ProcessData(TJSONObject.Create);
  OnFieldStart(TYPE_NAME);
  OnString(TypeName);
  OnFieldEnd(TYPE_NAME);
  OnFieldStart(ID_NAME);
  OnNumber(IntToStr(id));
  OnFieldEnd(ID_NAME);
  ProcessData(TJSONPair.Create(FIELDS_NAME, nil));
  ProcessData(TJSONObject.Create);
end;

procedure TJSONConverter.ProcessData(Data: TJSONAncestor);
begin
  // setup the root
  if FRoot = nil then
    if Data is TJSONValue then
      FRoot := TJSONValue(Data)
    else
      raise EConversionError.Create(Format(SValueExpected, [Data.ClassName]));
  // update current
  if Current <> nil then
  begin
    // pair for an object?
    if Data is TJSONPair then
      if Current is TJSONObject then
        TJSONObject(Current).AddPair(TJSONPair(Data))
      else
        raise EConversionError.Create(SObjectExpectedForPair)
      else if not(Data is TJSONValue) then
        raise EConversionError.Create(Format(SValueExpected, [Data.ClassName]))
      else
        SetCurrentValue(TJSONValue(Data));
  end
  else if Data is TJSONPair then
    raise EConversionError.Create(SInvalidContextForPair);
  // push into the stack
  if (Data is TJSONObject) or (Data is TJSONPair) or (Data is TJSONArray) then
    FStack.Push(Data);
end;

procedure TJSONConverter.SetCurrentValue(Data: TJSONValue);
begin
  // data for a pair or an array
  if Current is TJSONPair then
    TJSONPair(Current).JsonValue := TJSONValue(Data)
  else if Current is TJSONArray then
    TJSONArray(Current).AddElement(TJSONValue(Data))
  else
    raise EConversionError.Create(SInvalidContext);
end;

{ TTypeMarshaller<TDataType, TSerial> }

class function TTypeMarshaller<TSerial>.ComposeTypeName(Data: TObject): string;
begin
  Result := Data.UnitName + SEP_DOT + Data.ClassName;
end;

function TTypeMarshaller<TSerial>.Converter(clazz: TClass;
  Field: string): TConverterEvent;
var
  key: string;
  Value: TConverterEvent;
begin
  key := ComposeKey(clazz, Field);
  TMonitor.Enter(FConverters);
  try
    FConverters.TryGetValue(key, Result);
  finally
    TMonitor.Exit(FConverters);
  end;
end;

constructor TTypeMarshaller<TSerial>.Create(Converter: TConverter<TSerial>;
  OwnConverter: Boolean; Converters: TObjectDictionary<string,
  TConverterEvent>);
begin
  inherited Create;
  FId := 1;
  FObjectHash := TDictionary<NativeInt, Integer>.Create;
  FPointerHash := TDictionary<Integer, Integer>.Create;
  FConverter := Converter;
  FOwnConverter := OwnConverter;
  FConverters := Converters;
  FShareConverters := true;
  FRTTICtx.GetType(TObject);
end;

constructor TTypeMarshaller<TSerial>.Create(Converter: TConverter<TSerial>;
  OwnConverter: Boolean = true);
begin
  inherited Create;
  FId := 1;
  FObjectHash := TDictionary<NativeInt, Integer>.Create;
  FPointerHash := TDictionary<Integer, Integer>.Create;
  FConverters := TObjectDictionary<string,
    TConverterEvent>.Create([doOwnsValues]);
  FShareConverters := false;
  FConverter := Converter;
  FOwnConverter := OwnConverter;
  FRTTICtx.GetType(TObject);
end;

class procedure TTypeMarshaller<TSerial>.DecomposeTypeName(TypeName: string;
  out UnitName, ClassName: string);
var
  DotPos: Integer;
begin
  // find the last .
  DotPos := LastDelimiter(SEP_DOT, TypeName) + 1;
  if DotPos > 0 then
  begin
    UnitName := AnsiLeftStr(TypeName, DotPos - 1);
    ClassName := AnsiRightStr(TypeName, Length(TypeName) - DotPos);
  end;
end;

destructor TTypeMarshaller<TSerial>.Destroy;
begin
  FreeAndNil(FObjectHash);
  FreeAndNil(FPointerHash);
  if not FShareConverters then
    FreeAndNil(FConverters);
  if FOwnConverter then
    FreeAndNil(FConverter);
  inherited;
end;

procedure TTypeMarshaller<TSerial>.DestroyIfTransient(rttiType: TRttiType;
  Data: TObject);
var
  attr: TCustomAttribute;
begin
  try
    for attr in rttiType.GetAttributes do
      if (attr is JSONReflect) and JSONReflect(attr).MarshalOwner then
      begin
        try
          if FObjectHash.ContainsKey(NativeInt(Pointer(Data))) then
            FObjectHash.Remove(NativeInt(Pointer(Data)));
        finally
          Data.Free;
        end;
        break
      end;
  except

  end;
end;

function TTypeMarshaller<TSerial>.GetTypeConverter(clazz: TClass)
  : TJSONInterceptor;
begin
  Result := GetTypeConverter(FRTTICtx.GetType(clazz));
end;

function TTypeMarshaller<TSerial>.GetTypeConverter(rttiField: TRTTIField)
  : TJSONInterceptor;
var
  attr: TCustomAttribute;
begin
  try
    for attr in rttiField.GetAttributes do
      if attr is JSONReflect then
        exit(JSONReflect(attr).JSONInterceptor);
  except

  end;

  Result := nil;
end;

function TTypeMarshaller<TSerial>.GetTypeConverter(rttiType: TRttiType)
  : TJSONInterceptor;
var
  attr: TCustomAttribute;
begin
  try
    for attr in rttiType.GetAttributes do
      if attr is JSONReflect then
        exit(JSONReflect(attr).JSONInterceptor);
  except
  end;
  Result := nil;
end;

function TTypeMarshaller<TSerial>.HasConverter(clazz: TClass;
  Field: string): Boolean;
begin
  TMonitor.Enter(FConverters);
  try
    Result := FConverters.ContainsKey(ComposeKey(clazz, Field));
  finally
    TMonitor.Exit(FConverters);
  end;
end;

function TTypeMarshaller<TSerial>.HasInterceptor(
  rttiField: TRTTIField): Boolean;
var
  attr: TCustomAttribute;
begin
  try
    for attr in rttiField.GetAttributes do
      if attr is JSONReflect then
        exit(true);
  except

  end;

  Result := false;
end;

function TTypeMarshaller<TSerial>.IsObjectMarked(Data: TObject): Boolean;
begin
  Result := FObjectHash.ContainsKey(NativeInt(Pointer(Data)))
end;

function TTypeMarshaller<TSerial>.MarkObject(Data: TObject): Integer;
begin
  Result := NextId;
  FObjectHash.Add(NativeInt(Pointer(Data)), Result);
end;

function TTypeMarshaller<TSerial>.Marshal(Data: TObject): TSerial;
begin
  // clear previous warnings
  ClearWarnings;
  try
    MarshalData(Data);
    if FConverter.IsConsistent then
      Result := FConverter.GetSerializedData
    else
      raise EConversionError.Create(SInconsistentConversion)
  finally
    begin
      // clear
      FObjectHash.Clear;
      FPointerHash.Clear;
      FId := 1;
      FConverter.Clear;
    end;
  end;
end;

procedure TTypeMarshaller<TSerial>.MarshalConverter(Data: TObject;
  Field: string; ConverterEvent: TConverterEvent);
var
  ObjItem: TObject;
  StrItem: string;
  NbrItem: string;
begin
  FConverter.OnFieldStart(Field);
  case ConverterEvent.ConverterType of
    ctObjects:
      begin
        FConverter.OnListStart;
        for ObjItem in ConverterEvent.ObjectsConverter(Data, Field) do
          MarshalData(ObjItem);
        FConverter.OnListEnd;
      end;
    ctStrings:
      begin
        FConverter.OnListStart;
        for StrItem in ConverterEvent.StringsConverter(Data, Field) do
          FConverter.OnString(StrItem);
        FConverter.OnListEnd;
      end;
    ctObject:
      begin
        ObjItem := ConverterEvent.ObjectConverter(Data, Field);
        MarshalData(ObjItem);
      end;
    ctString:
      FConverter.OnString(ConverterEvent.StringConverter(Data, Field));
  else
    raise EConversionError.Create(Format(SNoConversionForType,
        [GetEnumName(typeInfo(TConverterType),
          Integer(ConverterEvent.ConverterType))]));
  end;
  FConverter.OnFieldEnd(Field);
end;

procedure TTypeMarshaller<TSerial>.MarshalConverter(Data: TObject;
  Field: string; ConverterEvent: TJSONInterceptor);
var
  ObjItem: TObject;
  StrItem: string;
  NbrItem: string;
begin
  case ConverterEvent.ConverterType of
    ctObjects:
      begin
        FConverter.OnListStart;
        for ObjItem in ConverterEvent.ObjectsConverter(Data, Field) do
          MarshalData(ObjItem);
        FConverter.OnListEnd;
      end;
    ctStrings:
      begin
        FConverter.OnListStart;
        for StrItem in ConverterEvent.StringsConverter(Data, Field) do
          FConverter.OnString(StrItem);
        FConverter.OnListEnd;
      end;
    ctObject:
      begin
        ObjItem := ConverterEvent.ObjectConverter(Data, Field);
        MarshalData(ObjItem);
      end;
    ctString:
      FConverter.OnString(ConverterEvent.StringConverter(Data, Field));
  else
    raise EConversionError.Create(Format(SNoConversionForType,
        [GetEnumName(typeInfo(TConverterType),
          Integer(ConverterEvent.ConverterType))]));
  end;
end;

procedure TTypeMarshaller<TSerial>.MarshalTypeConverter(Data: TObject;
  Field: string; ConverterEvent: TConverterEvent);
var
  ObjItem: TObject;
  StrItem: string;
  NbrItem: string;
begin
  case ConverterEvent.ConverterType of
    ctTypeObjects:
      begin
        FConverter.OnListStart;
        for ObjItem in ConverterEvent.TypeObjectsConverter(Data) do
          MarshalData(ObjItem);
        FConverter.OnListEnd;
      end;
    ctTypeStrings:
      begin
        FConverter.OnListStart;
        for StrItem in ConverterEvent.TypeStringsConverter(Data) do
          FConverter.OnString(StrItem);
        FConverter.OnListEnd;
      end;
    ctTypeObject:
      begin
        ObjItem := ConverterEvent.TypeObjectConverter(Data);
        MarshalData(ObjItem);
      end;
    ctTypeString:
      FConverter.OnString(ConverterEvent.TypeStringConverter(Data));
  else
    raise EConversionError.Create(Format(SNoConversionForType,
        [GetEnumName(typeInfo(TConverterType),
          Integer(ConverterEvent.ConverterType))]));
  end;
end;

procedure TTypeMarshaller<TSerial>.MarshalTypeConverter(Data: TObject;
  Field: string; ConverterEvent: TJSONInterceptor);
var
  ObjItem: TObject;
  StrItem: string;
  NbrItem: string;
begin
  case ConverterEvent.ConverterType of
    ctTypeObjects:
      begin
        FConverter.OnListStart;
        for ObjItem in ConverterEvent.TypeObjectsConverter(Data) do
          MarshalData(ObjItem);
        FConverter.OnListEnd;
      end;
    ctTypeStrings:
      begin
        FConverter.OnListStart;
        for StrItem in ConverterEvent.TypeStringsConverter(Data) do
          FConverter.OnString(StrItem);
        FConverter.OnListEnd;
      end;
    ctTypeObject:
      begin
        ObjItem := ConverterEvent.TypeObjectConverter(Data);
        MarshalData(ObjItem);
      end;
    ctTypeString:
      FConverter.OnString(ConverterEvent.TypeStringConverter(Data));
  else
    raise EConversionError.Create(Format(SNoConversionForType,
        [GetEnumName(typeInfo(TConverterType),
          Integer(ConverterEvent.ConverterType))]));
  end;
end;

procedure TTypeMarshaller<TSerial>.MarshalValue(Value: TValue; fieldRtti: TRTTIField);
var
  I, Len: Integer;
  rttiType: TRttiType;
  rttiField: TRTTIField;
  convEv: TJSONInterceptor;
  Data: TObject;
begin
  if Value.IsEmpty then
    FConverter.OnNull
  else
    case Value.Kind of
      TTypeKind.tkInteger:
        FConverter.OnNumber(IntToStr(Value.AsInteger));
      TTypeKind.tkInt64:
        FConverter.OnNumber(IntToStr(Value.AsInt64));
      TTypeKind.tkFloat:
        FConverter.OnNumber(TDBXPlatform.JsonFloat(Value.AsExtended));
      TTypeKind.tkChar:
        if Value.AsType<char> = #0 then
          FConverter.OnString('')
        else
          FConverter.OnString(Value.AsString);
      TTypeKind.tkWChar:
        if Value.AsType<widechar> = #0 then
          FConverter.OnString('')
        else
          FConverter.OnString(Value.AsString);
      TTypeKind.tkString, TTypeKind.tkLString, TTypeKind.tkWString,
        TTypeKind.tkUString:
        FConverter.OnString(Value.AsString);
      TTypeKind.tkEnumeration:
        if ((fieldRTTI <> nil) and (CompareText('Boolean',
              fieldRTTI.FieldType.Name) = 0)) or
          ((fieldRTTI = nil) and (CompareText('Boolean',
              Value.typeInfo.NameFld.ToString) = 0)) then
          FConverter.OnBoolean(Value.AsBoolean)
        else
          FConverter.OnString(GetEnumName(Value.typeInfo,
              TValueData(Value).FAsSLong));
      TTypeKind.tkDynArray, TTypeKind.tkArray:
        begin
          FConverter.OnListStart;
          Len := Value.GetArrayLength;
          for I := 0 to Len - 1 do
            MarshalValue(Value.GetArrayElement(I));
          FConverter.OnListEnd
        end;
      TTypeKind.tkClass:
        begin
          Data := Value.AsObject;
          if (Data <> nil) then
            if HasConverter(Data.ClassType, FIELD_ANY) then
              MarshalTypeConverter(Data, EmptyStr, Converter(Data.ClassType,
                  FIELD_ANY))
            else
            begin
              convEv := GetTypeConverter(Data.ClassType);
              if (convEv = nil) and (fieldRtti <> nil) then
                convEv := GetTypeConverter(fieldRtti);
              if convEv <> nil then
                try
                  MarshalTypeConverter(Data, EmptyStr, convEv)
                    finally convEv.Free
                end
              else
                MarshalData(Data);
            end
            else
              MarshalData(nil);
        end;
      TTypeKind.tkRecord:
        begin
          FConverter.OnListStart;

          // get the type definition
          rttiType := FRTTICtx.GetType(Value.typeInfo);
          if (rttiType.Name = 'TListHelper') and
            (Length(rttiType.GetFields) > 1) and
            (rttiType.GetFields[0].Name = 'FCount')  then
          begin
            // Special handling for TList<T>.FListHelper.  Marshal FCount.
            rttiField := rttiType.GetFields[0];
            MarshalValue(rttiField.GetValue(Value.GetReferenceToRawData), rttiField);
          end
          else
          begin
            // get the record fields
            for rttiField in rttiType.GetFields do
            begin
              MarshalValue(rttiField.GetValue(Value.GetReferenceToRawData), rttiField);
            end;
          end;

          FConverter.OnListEnd
        end;
      TTypeKind.tkPointer:
        raise EConversionError.Create(Format(STypeNotSupported, ['tkPointer']));
      TTypeKind.tkSet:
        raise EConversionError.Create(Format(STypeNotSupported, ['tkSet']));
      TTypeKind.tkMethod:
        raise EConversionError.Create(Format(STypeNotSupported, ['tkMethod']));
      TTypeKind.tkVariant:
        raise EConversionError.Create(Format(STypeNotSupported, ['tkVariant']));
      TTypeKind.tkInterface:
        raise EConversionError.Create(Format(STypeNotSupported, ['tkInterface']));
      TTypeKind.tkClassRef:
        raise EConversionError.Create(Format(STypeNotSupported, ['tkClassRef']));
      TTypeKind.tkProcedure:
        raise EConversionError.Create(Format(STypeNotSupported, ['tkProcedure']));
      else
        raise EConversionError.Create(Format(STypeNotSupported,
            [GetEnumName(Value.typeInfo, TValueData(Value).FAsSLong)]));
    end;
end;

procedure TTypeMarshaller<TSerial>.MarshalConverter(Data: TObject;
  Field: string);
begin
  MarshalConverter(Data, Field, Converter(Data.ClassType, Field));
end;

procedure TTypeMarshaller<TSerial>.MarshalData(Data: TObject);
var
  id: Integer;
  rttiType: TRttiType;
  rttiField: TRTTIField;
  convEv: TJSONInterceptor;
  lConverter: TConverterEvent;
begin
  if Data = nil then
  begin
    FConverter.OnNull;
  end
  else if IsObjectMarked(Data) then
  begin
    FConverter.OnRefType(ComposeTypeName(Data), ObjectMark(Data))
  end
  else
  begin
    id := MarkObject(Data);
    FConverter.OnTypeStart(ComposeTypeName(Data), id);
    // marshall the fields
    rttiType := FRTTICtx.GetType(Data.ClassType);
    for rttiField in rttiType.GetFields do
    begin
      if not ShouldMarshal(Data, rttiField) then
        continue;
      if HasConverter(Data.ClassType, rttiField.Name) then
      begin
          lConverter := Converter(Data.ClassType, rttiField.Name);
          if lConverter.IsTypeConverter then
            if (rttiField.FieldType <> nil) and
               (rttiField.FieldType.TypeKind = tkClass) and
               (rttiField.GetValue(Data).AsObject <> nil) then
              begin
                FConverter.OnFieldStart(rttiField.Name);
                MarshalTypeConverter(rttiField.GetValue(Data).AsObject,
                                     rttiField.Name, lConverter);
                FConverter.OnFieldEnd(rttiField.Name)
              end
              else
                raise EConversionError.Create(Format(SNoTypeInterceptorExpected,
                                              [rttiField.FieldType.Name]))
          else
            MarshalConverter(Data, rttiField.Name);
      end
      else if HasInterceptor(rttiField) then
      begin
        convEv := GetTypeConverter(rttiField);
        try
          if convEv.IsTypeConverter then
            if (rttiField.FieldType <> nil) and
               (rttiField.FieldType.TypeKind = tkClass) and
               (rttiField.GetValue(Data).AsObject <> nil) then
              begin
                FConverter.OnFieldStart(rttiField.Name);
                MarshalTypeConverter(rttiField.GetValue(Data).AsObject,
                                     rttiField.Name, convEv);
                FConverter.OnFieldEnd(rttiField.Name)
              end
            else
              raise EConversionError.Create(Format(SNoTypeInterceptorExpected,
                                            [rttiField.FieldType.Name]))
          else
          begin
            FConverter.OnFieldStart(rttiField.Name);
            MarshalConverter(Data, rttiField.Name, convEv);
            FConverter.OnFieldEnd(rttiField.Name)
          end
        finally
          convEv.Free
        end
      end
      else if rttiField.FieldType = nil then
        AddWarning(Data, Data.ClassType.UnitName, Data.ClassName, EmptyStr,
          EmptyStr, rttiField.Name)
      else if (rttiField.FieldType.TypeKind = tkClass)
        and (rttiField.GetValue(Data).AsObject <> nil) then
      begin
        if HasConverter(rttiField.GetValue(Data).AsObject.ClassType, FIELD_ANY)
          then
        begin
          FConverter.OnFieldStart(rttiField.Name);
          MarshalTypeConverter(rttiField.GetValue(Data).AsObject,
            rttiField.Name,
            Converter(rttiField.GetValue(Data).AsObject.ClassType, FIELD_ANY));
          FConverter.OnFieldEnd(rttiField.Name)
        end
        else
        begin
          convEv := GetTypeConverter(rttiField);
          if convEv <> nil then
            try
              FConverter.OnFieldStart(rttiField.Name);
              if convEv.IsTypeConverter then
                MarshalTypeConverter(rttiField.GetValue(Data).AsObject,
                  rttiField.Name, convEv)
              else
                MarshalConverter(rttiField.GetValue(Data).AsObject,
                  rttiField.Name, convEv);
              FConverter.OnFieldEnd(rttiField.Name)
            finally
              convEv.Free
            end
          else
          begin
            convEv := GetTypeConverter(rttiField.GetValue(Data)
                .AsObject.ClassType);
            if convEv <> nil then
              try
                FConverter.OnFieldStart(rttiField.Name);
                MarshalTypeConverter(rttiField.GetValue(Data).AsObject,
                  rttiField.Name, convEv);
                FConverter.OnFieldEnd(rttiField.Name)
              finally
                convEv.Free
              end
            else if not MarshalSimpleField(rttiField, Data) then
              AddWarning(Data, Data.ClassType.UnitName, Data.ClassName,
                EmptyStr, rttiField.FieldType.Name, rttiField.Name)
          end;
        end;
      end
      else if not MarshalSimpleField(rttiField, Data) then
        AddWarning(Data, Data.ClassType.UnitName, Data.ClassName, EmptyStr,
          rttiField.FieldType.Name, rttiField.Name)

    end;
    FConverter.OnTypeEnd(ComposeTypeName(Data), id);

    DestroyIfTransient(rttiType, Data);
  end;
end;

function TTypeMarshaller<TSerial>.MarshalSimpleField(rttiField: TRTTIField;
  Data: Pointer): Boolean;
var
  fieldValue: TValue;
begin
  case rttiField.FieldType.TypeKind of
    TTypeKind.tkInteger, TTypeKind.tkInt64, TTypeKind.tkChar, TTypeKind.tkWChar,
      TTypeKind.tkString, TTypeKind.tkLString, TTypeKind.tkWString,
      TTypeKind.tkUString, TTypeKind.tkFloat, TTypeKind.tkClass,
      TTypeKind.tkDynArray, TTypeKind.tkArray:
      begin
        FConverter.OnFieldStart(rttiField.Name);
        MarshalValue(rttiField.GetValue(Data));
        FConverter.OnFieldEnd(rttiField.Name);
      end;
    TTypeKind.tkEnumeration:
      begin
        fieldValue := rttiField.GetValue(Data);
        FConverter.OnFieldStart(rttiField.Name);
        // if fieldValue.IsType<Boolean> then
        if CompareText('Boolean', rttiField.FieldType.Name) = 0 then
          // JSON has boolean value types
          FConverter.OnBoolean(fieldValue.AsBoolean)
        else
          MarshalValue(rttiField.GetValue(Data));
        FConverter.OnFieldEnd(rttiField.Name);
      end;
    TTypeKind.tkRecord:
      begin
        FConverter.OnFieldStart(rttiField.Name);
        MarshalValue(rttiField.GetValue(Data), rttiField);
        FConverter.OnFieldEnd(rttiField.Name);
      end;
    TTypeKind.tkSet, TTypeKind.tkMethod, TTypeKind.tkVariant,
      TTypeKind.tkInterface, TTypeKind.tkPointer, TTypeKind.tkClassRef,
      TTypeKind.tkProcedure:
      begin
        Exit(False);
      end;
  else
    raise EConversionError.Create(Format(STypeNotSupported,
        [rttiField.FieldType.Name]));
  end;
  Exit(True);
end;

function TTypeMarshaller<TSerial>.NextId: Integer;
begin
  Result := FId;
  Inc(FId);
end;

function TTypeMarshaller<TSerial>.ObjectMark(Data: TObject): Integer;
begin
  FObjectHash.TryGetValue(NativeInt(Pointer(Data)), Result)
end;

procedure TTypeMarshaller<TSerial>.RegisterConverter(clazz: TClass;
  Field: string; func: TStringsConverter);
var
  ConverterEvent: TConverterEvent;
begin
  ConverterEvent := TConverterEvent.Create;
  ConverterEvent.StringsConverter := func;
  RegisterConverter(clazz, Field, ConverterEvent);
end;

procedure TTypeMarshaller<TSerial>.RegisterConverter(clazz: TClass;
  Field: string; func: TObjectConverter);
var
  ConverterEvent: TConverterEvent;
begin
  ConverterEvent := TConverterEvent.Create;
  ConverterEvent.ObjectConverter := func;
  RegisterConverter(clazz, Field, ConverterEvent);
end;

procedure TTypeMarshaller<TSerial>.RegisterConverter(clazz: TClass;
  Field: string; func: TStringConverter);
var
  ConverterEvent: TConverterEvent;
begin
  ConverterEvent := TConverterEvent.Create;
  ConverterEvent.StringConverter := func;
  RegisterConverter(clazz, Field, ConverterEvent);
end;

procedure TTypeMarshaller<TSerial>.RegisterConverter(clazz: TClass;
  Field: string; func: TObjectsConverter);
var
  ConverterEvent: TConverterEvent;
begin
  ConverterEvent := TConverterEvent.Create;
  ConverterEvent.ObjectsConverter := func;
  RegisterConverter(clazz, Field, ConverterEvent);
end;

procedure TTypeMarshaller<TSerial>.RegisterConverter(clazz: TClass;
  Field: string; Converter: TConverterEvent);
begin
  TMonitor.Enter(FConverters);
  try
    FConverters.AddOrSetValue(ComposeKey(clazz, Field), Converter);
  finally
    TMonitor.Exit(FConverters);
  end;
end;

procedure TTypeMarshaller<TSerial>.RegisterConverter(clazz: TClass;
  func: TTypeStringsConverter);
var
  ConverterEvent: TConverterEvent;
begin
  ConverterEvent := TConverterEvent.Create;
  ConverterEvent.TypeStringsConverter := func;
  RegisterConverter(clazz, FIELD_ANY, ConverterEvent);
end;

procedure TTypeMarshaller<TSerial>.RegisterConverter(clazz: TClass;
  func: TTypeObjectConverter);
var
  ConverterEvent: TConverterEvent;
begin
  ConverterEvent := TConverterEvent.Create;
  ConverterEvent.TypeObjectConverter := func;
  RegisterConverter(clazz, FIELD_ANY, ConverterEvent);
end;

procedure TTypeMarshaller<TSerial>.RegisterConverter(clazz: TClass;
  func: TTypeObjectsConverter);
var
  ConverterEvent: TConverterEvent;
begin
  ConverterEvent := TConverterEvent.Create;
  ConverterEvent.TypeObjectsConverter := func;
  RegisterConverter(clazz, FIELD_ANY, ConverterEvent);
end;

procedure TTypeMarshaller<TSerial>.RegisterConverter(clazz: TClass;
  func: TTypeStringConverter);
var
  ConverterEvent: TConverterEvent;
begin
  ConverterEvent := TConverterEvent.Create;
  ConverterEvent.TypeStringConverter := func;
  RegisterConverter(clazz, FIELD_ANY, ConverterEvent);
end;

{ TConverter<TSerial> }

{ TConverterEvent }

procedure TConverterEvent.SetTypeObjectConverter
  (Converter: TTypeObjectConverter);
begin
  FConverterType := ctTypeObject;
  FTypeObjectConverter := Converter;
end;

procedure TConverterEvent.SetTypeObjectsConverter
  (Converter: TTypeObjectsConverter);
begin
  FConverterType := ctTypeObjects;
  FTypeObjectsConverter := Converter;
end;

procedure TConverterEvent.SetTypeStringConverter
  (Converter: TTypeStringConverter);
begin
  FConverterType := ctTypeString;
  FTypeStringConverter := Converter;
end;

procedure TConverterEvent.SetTypeStringsConverter
  (Converter: TTypeStringsConverter);
begin
  FConverterType := ctTypeStrings;
  FTypeStringsConverter := Converter;
end;

constructor TConverterEvent.Create;
begin
  inherited;
end;

constructor TConverterEvent.Create(AFieldClassType: TClass; AFieldName: string);
begin
  inherited Create;

  FFieldClassType := AFieldClassType;
  FFieldName := AFieldName;
end;

function TConverterEvent.IsTypeConverter: Boolean;
begin
  Result := FConverterType in [ctTypeObjects, ctTypeStrings, ctTypeObject,
    ctTypeString];
end;

procedure TConverterEvent.SetObjectConverter(Converter: TObjectConverter);
begin
  FConverterType := ctObject;
  FObjectConverter := Converter;
end;

procedure TConverterEvent.SetObjectsConverter(Converter: TObjectsConverter);
begin
  FConverterType := ctObjects;
  FObjectsConverter := Converter;
end;

procedure TConverterEvent.SetStringConverter(Converter: TStringConverter);
begin
  FConverterType := ctString;
  FStringConverter := Converter;
end;

procedure TConverterEvent.SetStringsConverter(Converter: TStringsConverter);
begin
  FConverterType := ctStrings;
  FStringsConverter := Converter;
end;

{ TReverterEvent }

constructor TReverterEvent.Create;
begin
  inherited;
end;

constructor TReverterEvent.Create(AFieldClassType: TClass; AFieldName: string);
begin
  inherited Create;

  FFieldClassType := AFieldClassType;
  FFieldName := AFieldName;
end;

function TReverterEvent.IsTypeReverter: Boolean;
begin
  Result := FReverterType in [rtTypeObjects, rtTypeStrings, rtTypeObject,
    rtTypeString];
end;

procedure TReverterEvent.SetObjectReverter(Reverter: TObjectReverter);
begin
  FReverterType := rtObject;
  FObjectReverter := Reverter;
end;

procedure TReverterEvent.SetObjectsReverter(Reverter: TObjectsReverter);
begin
  FReverterType := rtObjects;
  FObjectsReverter := Reverter;
end;

procedure TReverterEvent.SetStringReverter(Reverter: TStringReverter);
begin
  FReverterType := rtString;
  FStringReverter := Reverter;
end;

procedure TReverterEvent.SetStringsReverter(Reverter: TStringsReverter);
begin
  FReverterType := rtStrings;
  FStringsReverter := Reverter;
end;

procedure TReverterEvent.SetTypeObjectReverter(Reverter: TTypeObjectReverter);
begin
  FReverterType := rtTypeObject;
  FTypeObjectReverter := Reverter;
end;

procedure TReverterEvent.SetTypeObjectsReverter(Reverter: TTypeObjectsReverter);
begin
  FReverterType := rtTypeObjects;
  FTypeObjectsReverter := Reverter;
end;

procedure TReverterEvent.SetTypeStringReverter(Reverter: TTypeStringReverter);
begin
  FReverterType := rtTypeString;
  FTypeStringReverter := Reverter;
end;

procedure TReverterEvent.SetTypeStringsReverter(Reverter: TTypeStringsReverter);
begin
  FReverterType := rtTypeStrings;
  FTypeStringsReverter := Reverter;
end;

{ TJSONUnMarshal }

function TJSONUnMarshal.FieldReverter(Data: TObject;
  Field: string): TJSONInterceptor;
begin
  Result := FieldReverter(GetFieldType(Data, Field));
end;

function TJSONUnMarshal.FieldTypeReverter(ctxType: TRttiType): TJSONInterceptor;
var
  attr: TCustomAttribute;
begin
  try
    for attr in ctxType.GetAttributes do
      if attr is JSONReflect then
        exit(JSONReflect(attr).JSONInterceptor);
  except

  end;
  Result := nil;
end;

function TJSONUnMarshal.FieldTypeReverter(Data: TObject;
  Field: string): TJSONInterceptor;
begin
  Result := FieldTypeReverter(GetFieldType(Data, Field).FieldType);
end;

function TJSONUnMarshal.ClassTypeOf(Data: TObject; Field: string): TClass;
var
  tRtti: TRttiType;
  fRtti: TRTTIField;
begin
  Result := nil;
  tRtti := FRTTICtx.GetType(Data.ClassType);
  if tRtti <> nil then
  begin
    fRtti := tRtti.GetField(Field);
    if (fRtti <> nil) and (fRtti.FieldType.IsInstance) then
      Result := fRtti.FieldType.AsInstance.MetaclassType;
  end;
end;

constructor TJSONUnMarshal.Create;
begin
  inherited Create;
  FObjectHash := TDictionary<string, TObject>.Create;
  FReverters := TObjectDictionary<string,
    TReverterEvent>.Create([doOwnsValues]);
  FShareReverters := false;
  FRTTICtx.GetType(TObject);

  // JSON reverters
  RegisterReverter(TJSONObject, 'FMembers', JSONObjectPairListReverter);
  RegisterReverter(TJSONArray, 'FElements', JSONArrayElementsReverter);
  RegisterReverter(TStringBuilder, 'FData', StringBuilderReverter);
end;

constructor TJSONUnMarshal.Create(Reverters: TObjectDictionary<string,
  TReverterEvent>);
begin
  inherited Create;
  FObjectHash := TDictionary<string, TObject>.Create;
  FReverters := Reverters;
  FShareReverters := true;
  FRTTICtx.GetType(TObject);
end;

function TJSONUnMarshal.CreateObject(JsonObj: TJSONObject): TObject;
var
  objType: string;
  ObjId: string;
  objFields: TJSONObject;
  Obj: TObject;
  rttiType : TRttiType;
  attr : TCustomAttribute;
  customizer : TJSONPopulationCustomizer;
  JsonPairID: TJSONPair;
  JsonPairType: TJSONPair;
  JsonPairFields: TJSONPair;
  JsonPairRefName: TJSONPair;
begin
  assert(JsonObj <> nil);
  assert(JsonObj.Count > 1);
  JsonPairID := JsonObj.Get(ID_NAME);
  if JsonPairID <> nil then
  begin
    JsonPairType := JsonObj.Get(TYPE_NAME);
    JsonPairFields := JsonObj.Get(FIELDS_NAME);
    Assert(JsonPairFields <> nil);
    Assert(JsonPairType <> nil);
    objType := JsonPairType.JsonValue.Value;

    ObjId := JsonPairID.JsonValue.Value;

    objFields := TJSONObject(JsonPairFields.JsonValue);

    Obj := ObjectInstance(FRTTICtx, objType);
    if Obj = nil then
      raise EConversionError.Create(Format(SCannotCreateType, [objType]));
    StoreObject(ObjId, Obj);

    customizer := nil;
    rttiType := ObjectType(FRTTICtx, objType);
    if rttiType <> nil then
      for attr in rttiType.GetAttributes do
        if attr is JSONReflect then
        begin
          customizer := JSONReflect(attr).JSONPopulationCustomizer;
        end;
    if customizer = nil then // Use default population customizer to prevent leaked memory
      customizer := TInternalJSONPopulationCustomizer.Create(
        function(AData: TObject; AField: TRttiField): Boolean
        begin
          Result := ShouldMarshal(AData, AField);
        end);
    try
      try
        customizer.PrePopulate(Obj,FRTTICtx);
        PopulateFields(objFields, Obj, customizer);
        customizer.PostPopulate(Obj);
      except
        FObjectHash.Remove(ObjId);
        Obj.Free;
        raise
      end;
    finally
      customizer.Free;
    end;

    exit(Obj);
  end
  else
  begin
    JsonPairRefName := JsonObj.Get(REF_NAME);
    if JsonPairRefName <> nil then
    begin
      JsonPairType := JsonObj.Get(TYPE_NAME);
      Assert(JsonPairType <> nil);
      objType := JsonPairType.JsonValue.Value;

      ObjId := JsonPairRefName.JsonValue.Value;

      if HasObject(ObjId) then
      begin
        Obj := GetObject(ObjId);
        // eventually compare classname and unit with objType

        exit(Obj);
      end
      else
        raise EConversionError.Create(Format(SObjectNotFound, [objType, ObjId]));
    end
    else
      raise EConversionError.Create(Format(SUnexpectedPairName,
          [JsonObj.ToString, TYPE_NAME, REF_NAME]));
  end;

end;

function TJSONUnMarshal.TryCreateObject(Data: TObject; Field: string; JsonObj: TJSONObject; out MarshalledObj: TObject): Boolean;
var
  objType: string;
  ObjId: string;
  objFields: TJSONObject;
  Obj: TObject;
  rttiType : TRttiType;
  attr : TCustomAttribute;
  customizer : TJSONPopulationCustomizer;
  JsonPairID: TJSONPair;
  JsonPairType: TJSONPair;
  JsonPairFields: TJSONPair;
  JsonPairRefName: TJSONPair;
begin
  Result := False;
  MarshalledObj := nil;
  assert(JsonObj <> nil);
  assert(JsonObj.Count > 1);
  JsonPairID := JsonObj.Get(ID_NAME);
  if JsonPairID <> nil then
  begin
    JsonPairType := JsonObj.Get(TYPE_NAME);
    JsonPairFields := JsonObj.Get(FIELDS_NAME);
    Assert(JsonPairFields <> nil);
    Assert(JsonPairType <> nil);
    objType := JsonPairType.JsonValue.Value;

    ObjId := JsonPairID.JsonValue.Value;

    objFields := TJSONObject(JsonPairFields.JsonValue);

    Obj := ObjectInstance(FRTTICtx, objType);
    if Obj = nil then
    begin
      // create a warning instead of failing to make unmarshalling more resilient
      // when errors are found on field members
      AddWarning(Data, EmptyStr, objType, EmptyStr, objType, Field);
      Exit;
    end;

    if Obj <> nil then
    begin
      MarshalledObj := Obj;
      StoreObject(ObjId, Obj);

      customizer := nil;
      rttiType := ObjectType(FRTTICtx, objType);
      if rttiType <> nil then
        for attr in rttiType.GetAttributes do
          if attr is JSONReflect then
          begin
            customizer := JSONReflect(attr).JSONPopulationCustomizer;
          end;
      if customizer = nil then // Use default population customizer to prevent leaked memory
        customizer := TInternalJSONPopulationCustomizer.Create(
          function(AData: TObject; AField: TRttiField): Boolean
          begin
            Result := ShouldMarshal(Data, AField);
          end);
      try
        customizer.PrePopulate(Obj,FRTTICtx);
        PopulateFields(objFields, Obj, customizer);
        customizer.PostPopulate(Obj);
      finally
        customizer.Free;
      end;
    end;

    exit(True);
  end
  else
  begin
    JsonPairRefName := JsonObj.Get(REF_NAME);
    if JsonPairRefName <> nil then
    begin
      JsonPairType := JsonObj.Get(TYPE_NAME);
      Assert(JsonPairType <> nil);
      objType := JsonPairType.JsonValue.Value;

      ObjId := JsonPairRefName.JsonValue.Value;

      if HasObject(ObjId) then

        exit(True)
      else
        raise EConversionError.Create(Format(SObjectNotFound, [objType, ObjId]));
    end
    else
      raise EConversionError.Create(Format(SUnexpectedPairName,
          [JsonObj.ToString, TYPE_NAME, REF_NAME]));
  end;

end;

destructor TJSONUnMarshal.Destroy;
begin
  FreeAndNil(FObjectHash);
  if not FShareReverters then
    FreeAndNil(FReverters);

  inherited;
end;

function TJSONUnMarshal.FieldReverter(Field: TRTTIField): TJSONInterceptor;
var
  fieldAttr: TCustomAttribute;
begin
  try
    for fieldAttr in Field.GetAttributes do
      if fieldAttr is JSONReflect then
        exit(JSONReflect(fieldAttr).JSONInterceptor) except

  end;
  Result := nil;
end;

function TJSONUnMarshal.GetArgObjects(JsonArray: TJSONArray): TListOfObjects;
var
  I, Count: Integer;
  jsonVal: TJSONValue;
begin
  Count := JsonArray.Count;
  SetLength(Result, Count);
  for I := 0 to Count - 1 do
  begin
    jsonVal := JsonArray.Items[I];
    if jsonVal is TJSONObject then
      Result[I] := CreateObject(TJSONObject(jsonVal))
    else
      raise EConversionError.Create(Format(SObjectExpectedInArray,
          [I, JsonArray.ToString]));
  end;
end;

function TJSONUnMarshal.GetArgStrings(JsonArray: TJSONArray): TListOfStrings;
var
  I, Count: Integer;
  jsonVal: TJSONValue;
begin
  Count := JsonArray.Count;
  SetLength(Result, Count);
  for I := 0 to Count - 1 do
  begin
    jsonVal := JsonArray.Items[I];
    if jsonVal is TJSONString then
      Result[I] := TJSONString(jsonVal).Value
    else
      raise EConversionError.Create(Format(SStringExpectedInArray,
          [I, JsonArray.ToString]))
  end;
end;

function TJSONUnMarshal.GetFieldType(Data: TObject; Field: string): TRTTIField;
var
  rType: TRttiType;
begin
  rType := FRTTICtx.GetType(Data.ClassType);
  Result := rType.GetField(Field);
  if Result = nil then
    raise EConversionError.Create(Format(SNoFieldFoundForType,
        [Field, Data.ClassName]));
end;

function TJSONUnMarshal.GetObject(ObjId: string): TObject;
begin
  Result := FObjectHash.Items[ObjId];
end;

function TJSONUnMarshal.HasObject(ObjId: string): Boolean;
begin
  Result := FObjectHash.ContainsKey(ObjId);
end;

function TJSONUnMarshal.HasReverter(key: string): Boolean;
begin
  TMonitor.Enter(FReverters);
  try
    exit(FReverters.ContainsKey(key));
  finally
    TMonitor.Exit(FReverters);
  end;
end;

procedure TJSONUnMarshal.RevertType(recField: TRTTIField; Instance: Pointer;
  revEv: TReverterEvent; jsonFieldVal: TJSONValue);
begin
  case revEv.ReverterType of
    rtTypeObjects:
      begin
        if jsonFieldVal is TJSONArray then
          recField.SetValue(Instance,
            revEv.TypeObjectsReverter(GetArgObjects(TJSONArray(jsonFieldVal))))
        else if jsonFieldVal is TJSONNull then
          recField.SetValue(Instance, TValue.Empty)
        else
          raise EConversionError.Create(Format(SArrayExpectedForField,
              [recField.Name, jsonFieldVal.ToString]));
      end;
    rtTypeStrings:
      begin
        if jsonFieldVal is TJSONArray then
          recField.SetValue(Instance,
            revEv.TypeStringsReverter(GetArgStrings(TJSONArray(jsonFieldVal))))
        else if jsonFieldVal is TJSONNull then
          recField.SetValue(Instance, TValue.Empty)
        else
          raise EConversionError.Create(Format(SArrayExpectedForField,
              [recField.Name, jsonFieldVal.ToString]));
      end;
    rtTypeObject:
      begin
        if jsonFieldVal is TJSONObject then
          recField.SetValue(Instance,
            revEv.TypeObjectReverter(CreateObject(TJSONObject(jsonFieldVal))))
        else if jsonFieldVal is TJSONNull then
          recField.SetValue(Instance, TValue.Empty)
        else
          raise EConversionError.Create(Format(SObjectExpectedForField,
              [recField.Name, jsonFieldVal.ToString]));
      end;
    rtTypeString:
      begin
        if jsonFieldVal is TJSONString then
          recField.SetValue(Instance,
            revEv.TypeStringReverter(TJSONString(jsonFieldVal).Value))
        else if jsonFieldVal is TJSONNull then
          recField.SetValue(Instance, TValue.Empty)
        else
          raise EConversionError.Create(Format(SObjectExpectedForField,
              [recField.Name, jsonFieldVal.ToString]));
      end
    else
      raise EConversionError.Create(Format(SNoConversionForType,
          [GetEnumName(typeInfo(TReverterType), Integer(revEv.ReverterType))]));
  end;
end;

procedure TJSONUnMarshal.RevertType(recField: TRTTIField; Instance: Pointer;
  revEv: TJSONInterceptor; jsonFieldVal: TJSONValue);
begin
  case revEv.ReverterType of
    rtTypeObjects:
      begin
        if jsonFieldVal is TJSONArray then
          recField.SetValue(Instance,
            revEv.TypeObjectsReverter(GetArgObjects(TJSONArray(jsonFieldVal))))
        else if jsonFieldVal is TJSONNull then
          recField.SetValue(Instance, TValue.Empty)
        else
          raise EConversionError.Create(Format(SArrayExpectedForField,
              [recField.Name, jsonFieldVal.ToString]));
      end;
    rtTypeStrings:
      begin
        if jsonFieldVal is TJSONArray then
          recField.SetValue(Instance,
            revEv.TypeStringsReverter(GetArgStrings(TJSONArray(jsonFieldVal))))
        else if jsonFieldVal is TJSONNull then
          recField.SetValue(Instance, TValue.Empty)
        else
          raise EConversionError.Create(Format(SArrayExpectedForField,
              [recField.Name, jsonFieldVal.ToString]));
      end;
    rtTypeObject:
      begin
        if jsonFieldVal is TJSONObject then
          recField.SetValue(Instance,
            revEv.TypeObjectReverter(CreateObject(TJSONObject(jsonFieldVal))))
        else if jsonFieldVal is TJSONNull then
          recField.SetValue(Instance, TValue.Empty)
        else
          raise EConversionError.Create(Format(SObjectExpectedForField,
              [recField.Name, jsonFieldVal.ToString]));
      end;
    rtTypeString:
      begin
        if jsonFieldVal is TJSONString then
          recField.SetValue(Instance,
            revEv.TypeStringReverter(TJSONString(jsonFieldVal).Value))
        else if jsonFieldVal is TJSONNull then
          recField.SetValue(Instance, TValue.Empty)
        else
          raise EConversionError.Create(Format(SObjectExpectedForField,
              [recField.Name, jsonFieldVal.ToString]));
      end
    else
      raise EConversionError.Create(Format(SNoConversionForType,
          [GetEnumName(typeInfo(TReverterType), Integer(revEv.ReverterType))]));
  end;
end;

function TJSONUnMarshal.JSONToTValue(JsonValue: TJSONValue;
  rttiType: TRttiType): TValue;
var
  tvArray: array of TValue;
  Value: string;
  I: Integer;
  elementType: TRttiType;
  Data: TValue;
  recField: TRTTIField;
  attrRev: TJSONInterceptor;
  jsonFieldVal: TJSONValue;
  ClassType: TClass;
  Instance: Pointer;
begin
  // null or nil returns empty
  if (JsonValue = nil) or (JsonValue is TJSONNull) then
    Exit(TValue.Empty);

  // for each JSON value type
  if JsonValue is TJSONNumber then
    // get data "as is"
    Value := TJSONNumber(JsonValue).ToString
  else if JsonValue is TJSONString then
    Value := TJSONString(JsonValue).Value
  else if JsonValue is TJSONTrue then
    Exit(True)
  else if JsonValue is TJSONFalse then
    Exit(False)
  else if JsonValue is TJSONObject then
    // object...
    Exit(CreateObject(TJSONObject(JsonValue)))
  else
  begin
    case rttiType.TypeKind of
      TTypeKind.tkDynArray, TTypeKind.tkArray:
        begin
          // array
          SetLength(tvArray, TJSONArray(JsonValue).Count);
          if rttiType is TRttiArrayType then
            elementType := TRttiArrayType(rttiType).elementType
          else
            elementType := TRttiDynamicArrayType(rttiType).elementType;
          for I := 0 to Length(tvArray) - 1 do
            tvArray[I] := JSONToTValue(TJSONArray(JsonValue).Items[I],
              elementType);
          Exit(TValue.FromArray(rttiType.Handle, tvArray));
        end;
      TTypeKind.tkRecord:
        begin
          TValue.Make(nil, rttiType.Handle, Data);
          // match the fields with the array elements
          I := 0;
          for recField in rttiType.GetFields do
          begin
            Instance := Data.GetReferenceToRawData;
            jsonFieldVal := TJSONArray(JsonValue).Items[I];
            // check for type reverter
            ClassType := nil;
            if recField.FieldType.IsInstance then
              ClassType := recField.FieldType.AsInstance.MetaclassType;
            if (ClassType <> nil) then
            begin
              if HasReverter(ComposeKey(ClassType, FIELD_ANY)) then
                RevertType(recField, Instance,
                  Reverter(ComposeKey(ClassType, FIELD_ANY)),
                  jsonFieldVal)
              else
              begin
                attrRev := FieldTypeReverter(recField.FieldType);
                if attrRev = nil then
                   attrRev := FieldReverter(recField);
                if attrRev <> nil then
                  try
                    RevertType(recField, Instance, attrRev, jsonFieldVal)
                  finally
                    attrRev.Free
                  end
                else
                 recField.SetValue(Instance, JSONToTValue(jsonFieldVal,
                      recField.FieldType));
              end
            end
            else
              recField.SetValue(Instance, JSONToTValue(jsonFieldVal,
                  recField.FieldType));
            Inc(I);
          end;
          Exit(Data);
        end;
    end;
  end;

  // transform value string into TValue based on type info
  Exit(StringToTValue(Value, rttiType.Handle));
end;


class function TJSONUnMarshal.ObjectType(Ctx: TRttiContext; TypeName: string) : TRttiType;
begin
  // type name is qualified at this point (UnitName.TypeName)
  Result := Ctx.FindType(TypeName);
end;

class function TJSONUnMarshal.ObjectInstance(Ctx: TRTTIContext;
  TypeName: string): TObject;
var
  rType: TRttiType;
  mType: TRTTIMethod;
  metaClass: TClass;
begin
  rType := ObjectType(Ctx, TypeName);
  if ( rType <> nil ) then
    for mType in rType.GetMethods do
    begin
      if mType.HasExtendedInfo and mType.IsConstructor then
      begin
        if Length(mType.GetParameters) = 0 then
        begin
          // invoke
          metaClass := rType.AsInstance.MetaclassType;
          Exit(mType.Invoke(metaClass, []).AsObject);
        end;
      end;
    end;
  Exit(nil);
end;

procedure TJSONUnMarshal.PopulateFields(JsonFields: TJSONObject; Data: TObject; JsonCustomizer: TJSONPopulationCustomizer);
var
  FieldName: string;
  jsonFieldVal: TJSONValue;
  revEv: TReverterEvent;
  revAttr: TJSONInterceptor;
  ClassType: TClass;
  JsonPairField: TJSONPair;
  LObject: TObject;
  LPopulated: Boolean;
begin
  for JsonPairField in JsonFields do
  begin
    LPopulated := True;
    FieldName := JsonPairField.JsonString.Value;
    jsonFieldVal := JsonPairField.JsonValue;
    ClassType := Data.ClassType;
    // check for reverters
    if HasReverter(ComposeKey(ClassType, FieldName)) then
    begin
      revEv := Reverter(ComposeKey(ClassType, FieldName));
      case revEv.ReverterType of
        rtTypeObjects:
          begin
            if jsonFieldVal is TJSONArray then
              SetField(Data, FieldName,
                revEv.TypeObjectsReverter(GetArgObjects(TJSONArray(jsonFieldVal)
                    )))
            else if jsonFieldVal is TJSONNull then
              SetField(Data, FieldName, nil)
            else
              raise EConversionError.Create(Format(SArrayExpectedForField,
                  [FieldName, jsonFieldVal.ToString]));
          end;
        rtTypeStrings:
          begin
            if jsonFieldVal is TJSONArray then
              SetField(Data, FieldName,
                revEv.TypeStringsReverter(GetArgStrings(TJSONArray(jsonFieldVal)
                    )))
            else if jsonFieldVal is TJSONNull then
              SetField(Data, FieldName, nil)
            else
              raise EConversionError.Create(Format(SArrayExpectedForField,
                  [FieldName, jsonFieldVal.ToString]));
          end;
        rtTypeObject:
          begin
            if jsonFieldVal is TJSONObject then
              SetField(Data, FieldName,
                revEv.TypeObjectReverter(CreateObject(TJSONObject(jsonFieldVal))
                  ))
            else if jsonFieldVal is TJSONNull then
              SetField(Data, FieldName, nil)
            else
              raise EConversionError.Create(Format(SObjectExpectedForField,
                  [FieldName, jsonFieldVal.ToString]));
          end;
        rtTypeString:
          begin
            if jsonFieldVal is TJSONString then
              SetField(Data, FieldName,
                revEv.TypeStringReverter(TJSONString(jsonFieldVal).Value))
            else if jsonFieldVal is TJSONNull then
              SetField(Data, FieldName, nil)
            else
              raise EConversionError.Create(Format(SObjectExpectedForField,
                  [FieldName, jsonFieldVal.ToString]));
          end;
        rtObjects:
          begin
            if jsonFieldVal is TJSONArray then
              revEv.ObjectsReverter(Data, FieldName,
                GetArgObjects(TJSONArray(jsonFieldVal)))
            else if jsonFieldVal is TJSONNull then
              revEv.ObjectsReverter(Data, FieldName, nil)
            else
              raise EConversionError.Create(Format(SArrayExpectedForField,
                  [FieldName, jsonFieldVal.ToString]));
          end;
        rtStrings:
          begin
            if jsonFieldVal is TJSONArray then
              revEv.StringsReverter(Data, FieldName,
                GetArgStrings(TJSONArray(jsonFieldVal)))
            else if jsonFieldVal is TJSONNull then
              revEv.ObjectsReverter(Data, FieldName, nil)
            else
              raise EConversionError.Create(Format(SArrayExpectedForField,
                  [FieldName, jsonFieldVal.ToString]));
          end;
        rtObject:
          begin
            if jsonFieldVal is TJSONObject then
              revEv.ObjectReverter(Data, FieldName,
                CreateObject(TJSONObject(jsonFieldVal)))
            else if jsonFieldVal is TJSONNull then
              revEv.ObjectsReverter(Data, FieldName, nil)
            else
              raise EConversionError.Create(Format(SObjectExpectedForField,
                  [FieldName, jsonFieldVal.ToString]));
          end;
        rtString:
          begin
            if jsonFieldVal is TJSONString then
              revEv.StringReverter(Data, FieldName,
                TJSONString(jsonFieldVal).Value)
            else if jsonFieldVal is TJSONNull then
              revEv.ObjectsReverter(Data, FieldName, nil)
            else
              raise EConversionError.Create(Format(SObjectExpectedForField,
                  [FieldName, jsonFieldVal.ToString]));
          end;
      else
        raise EConversionError.Create(Format(SNoConversionForType,
            [GetEnumName(typeInfo(TReverterType), Integer(revEv.ReverterType))])
          );
      end;
    end
    else if HasReverter(ComposeKey(ClassTypeOf(Data, FieldName),
        FIELD_ANY)) then
    begin
      revEv := Reverter(ComposeKey(ClassTypeOf(Data, FieldName),
          FIELD_ANY));
      case revEv.ReverterType of
        rtTypeObjects:
          begin
            if jsonFieldVal is TJSONArray then
              SetField(Data, FieldName,
                revEv.TypeObjectsReverter(GetArgObjects(TJSONArray(jsonFieldVal)
                    )))
            else if jsonFieldVal is TJSONNull then
              SetField(Data, FieldName, nil)
            else
              raise EConversionError.Create(Format(SArrayExpectedForField,
                  [FieldName, jsonFieldVal.ToString]));
          end;
        rtTypeStrings:
          begin
            if jsonFieldVal is TJSONArray then
              SetField(Data, FieldName,
                revEv.TypeStringsReverter(GetArgStrings(TJSONArray(jsonFieldVal)
                    )))
            else if jsonFieldVal is TJSONNull then
              SetField(Data, FieldName, nil)
            else
              raise EConversionError.Create(Format(SArrayExpectedForField,
                  [FieldName, jsonFieldVal.ToString]));
          end;
        rtTypeObject:
          begin
            if jsonFieldVal is TJSONObject then
              SetField(Data, FieldName,
                revEv.TypeObjectReverter(CreateObject(TJSONObject(jsonFieldVal))
                  ))
            else if jsonFieldVal is TJSONNull then
              SetField(Data, FieldName, nil)
            else
              raise EConversionError.Create(Format(SObjectExpectedForField,
                  [FieldName, jsonFieldVal.ToString]));
          end;
        rtTypeString:
          begin
            if jsonFieldVal is TJSONString then
              SetField(Data, FieldName,
                revEv.TypeStringReverter(TJSONString(jsonFieldVal).Value))
            else if jsonFieldVal is TJSONNull then
              SetField(Data, FieldName, nil)
            else
              raise EConversionError.Create(Format(SObjectExpectedForField,
                  [FieldName, jsonFieldVal.ToString]));
          end
        else
          raise EConversionError.Create(Format(SNoConversionForType,
              [GetEnumName(typeInfo(TReverterType),
                Integer(revEv.ReverterType))]));
      end;
    end
    else
    begin
      revAttr := FieldReverter(Data, FieldName);
      if revAttr = nil then
        revAttr := FieldTypeReverter(Data, FieldName);
      if revAttr <> nil then
        try
          case revAttr.ReverterType of
            rtTypeObjects:
              begin
                if jsonFieldVal is TJSONArray then
                  SetField(Data, FieldName,
                    revAttr.TypeObjectsReverter
                      (GetArgObjects(TJSONArray(jsonFieldVal))))
                else if jsonFieldVal is TJSONNull then
                  SetField(Data, FieldName, nil)
                else
                  raise EConversionError.Create(Format(SArrayExpectedForField,
                      [FieldName, jsonFieldVal.ToString]));
              end;
            rtTypeStrings:
              begin
                if jsonFieldVal is TJSONArray then
                  SetField(Data, FieldName,
                    revAttr.TypeStringsReverter
                      (GetArgStrings(TJSONArray(jsonFieldVal))))
                else if jsonFieldVal is TJSONNull then
                  SetField(Data, FieldName, nil)
                else
                  raise EConversionError.Create(Format(SArrayExpectedForField,
                      [FieldName, jsonFieldVal.ToString]));
              end;
            rtTypeObject:
              begin
                if jsonFieldVal is TJSONObject then
                  SetField(Data, FieldName,
                    revAttr.TypeObjectReverter
                      (CreateObject(TJSONObject(jsonFieldVal))))
                else if jsonFieldVal is TJSONNull then
                  SetField(Data, FieldName, nil)
                else
                  raise EConversionError.Create(Format(SObjectExpectedForField,
                      [FieldName, jsonFieldVal.ToString]));
              end;
            rtTypeString:
              begin
                if jsonFieldVal is TJSONString then
                  SetField(Data, FieldName,
                    revAttr.TypeStringReverter(TJSONString(jsonFieldVal).Value))
                else if jsonFieldVal is TJSONNull then
                  SetField(Data, FieldName, nil)
                else
                  raise EConversionError.Create(Format(SObjectExpectedForField,
                      [FieldName, jsonFieldVal.ToString]));
              end;
            rtObjects:
              begin
                if jsonFieldVal is TJSONArray then
                  revAttr.ObjectsReverter(Data, FieldName,
                    GetArgObjects(TJSONArray(jsonFieldVal)))
                else if jsonFieldVal is TJSONNull then
                  revAttr.ObjectsReverter(Data, FieldName, nil)
                else
                  raise EConversionError.Create(Format(SArrayExpectedForField,
                      [FieldName, jsonFieldVal.ToString]));
              end;
            rtStrings:
              begin
                if jsonFieldVal is TJSONArray then
                  revAttr.StringsReverter(Data, FieldName,
                    GetArgStrings(TJSONArray(jsonFieldVal)))
                else if jsonFieldVal is TJSONNull then
                  revAttr.ObjectsReverter(Data, FieldName, nil)
                else
                  raise EConversionError.Create(Format(SArrayExpectedForField,
                      [FieldName, jsonFieldVal.ToString]));
              end;
            rtObject:
              begin
                if jsonFieldVal is TJSONObject then
                  revAttr.ObjectReverter(Data, FieldName,
                    CreateObject(TJSONObject(jsonFieldVal)))
                else if jsonFieldVal is TJSONNull then
                  revAttr.ObjectsReverter(Data, FieldName, nil)
                else
                  raise EConversionError.Create(Format(SObjectExpectedForField,
                      [FieldName, jsonFieldVal.ToString]));
              end;
            rtString:
              begin
                if jsonFieldVal is TJSONString then
                  revAttr.StringReverter(Data, FieldName,
                    TJSONString(jsonFieldVal).Value)
                else if jsonFieldVal is TJSONNull then
                  revAttr.ObjectsReverter(Data, FieldName, nil)
                else
                  raise EConversionError.Create(Format(SObjectExpectedForField,
                      [FieldName, jsonFieldVal.ToString]));
              end
            else
              raise EConversionError.Create(Format(SNoConversionForType,
                  [GetEnumName(typeInfo(TReverterType),
                    Integer(revAttr.ReverterType))]));
          end
        finally
          revAttr.Free
        end
      else
      begin
        if jsonFieldVal is TJSONNumber then
          SetField(Data, FieldName, jsonFieldVal.ToString)
        else if jsonFieldVal is TJSONString then
          SetField(Data, FieldName, jsonFieldVal.Value)
        else if jsonFieldVal is TJSONTrue then
          SetField(Data, FieldName, True)
        else if jsonFieldVal is TJSONFalse then
          SetField(Data, FieldName, False)
        else if jsonFieldVal is TJSONNull then
          SetFieldNull(Data, FieldName)
        else if jsonFieldVal is TJSONObject then
        begin
          // object...
          if TryCreateObject(Data, FieldName, TJSONObject(jsonFieldVal), LObject) then
            SetField(Data, FieldName, LObject)
          else
            LPopulated := False;
        end
        else if jsonFieldVal is TJSONArray then
          SetFieldArray(Data, FieldName, TJSONArray(jsonFieldVal))
        else
          raise EConversionError.Create(Format(SInvalidJSONFieldType,
              [FieldName, Data.ClassName]));
      end
    end;
    if LPopulated then
      JsonCustomizer.DoFieldPopulated(Data, GetFieldType(Data, FieldName));
  end
end;

procedure TJSONUnMarshal.RegisterReverter(clazz: TClass; Field: string;
  func: TObjectReverter);
var
  ReverterEvent: TReverterEvent;
begin
  ReverterEvent := TReverterEvent.Create;
  ReverterEvent.ObjectReverter := func;
  RegisterReverter(clazz, Field, ReverterEvent);
end;

procedure TJSONUnMarshal.RegisterReverter(clazz: TClass; Field: string;
  func: TStringsReverter);
var
  ReverterEvent: TReverterEvent;
begin
  ReverterEvent := TReverterEvent.Create;
  ReverterEvent.StringsReverter := func;
  RegisterReverter(clazz, Field, ReverterEvent);
end;

procedure TJSONUnMarshal.RegisterReverter(clazz: TClass; Field: string;
  Reverter: TReverterEvent);
begin
  TMonitor.Enter(FReverters);
  try
    FReverters.AddOrSetValue(ComposeKey(clazz, Field), Reverter);
  finally
    TMonitor.Exit(FReverters);
  end;
end;

procedure TJSONUnMarshal.RegisterReverter(clazz: TClass; Field: string;
  func: TObjectsReverter);
var
  ReverterEvent: TReverterEvent;
begin
  ReverterEvent := TReverterEvent.Create;
  ReverterEvent.ObjectsReverter := func;
  RegisterReverter(clazz, Field, ReverterEvent);
end;

procedure TJSONUnMarshal.RegisterReverter(clazz: TClass; Field: string;
  func: TStringReverter);
var
  ReverterEvent: TReverterEvent;
begin
  ReverterEvent := TReverterEvent.Create;
  ReverterEvent.StringReverter := func;
  RegisterReverter(clazz, Field, ReverterEvent);
end;

procedure TJSONUnMarshal.RegisterReverter(clazz: TClass;
  func: TTypeStringsReverter);
var
  ReverterEvent: TReverterEvent;
begin
  ReverterEvent := TReverterEvent.Create;
  ReverterEvent.TypeStringsReverter := func;
  RegisterReverter(clazz, FIELD_ANY, ReverterEvent);
end;

procedure TJSONUnMarshal.RegisterReverter(clazz: TClass;
  func: TTypeStringReverter);
var
  ReverterEvent: TReverterEvent;
begin
  ReverterEvent := TReverterEvent.Create;
  ReverterEvent.TypeStringReverter := func;
  RegisterReverter(clazz, FIELD_ANY, ReverterEvent);
end;

procedure TJSONUnMarshal.RegisterReverter(clazz: TClass;
  func: TTypeObjectsReverter);
var
  ReverterEvent: TReverterEvent;
begin
  ReverterEvent := TReverterEvent.Create;
  ReverterEvent.TypeObjectsReverter := func;
  RegisterReverter(clazz, FIELD_ANY, ReverterEvent);
end;

procedure TJSONUnMarshal.RegisterReverter(clazz: TClass;
  func: TTypeObjectReverter);
var
  ReverterEvent: TReverterEvent;
begin
  ReverterEvent := TReverterEvent.Create;
  ReverterEvent.TypeObjectReverter := func;
  RegisterReverter(clazz, FIELD_ANY, ReverterEvent);
end;

function TJSONUnMarshal.Reverter(key: string): TReverterEvent;
begin
  TMonitor.Enter(FReverters);
  try
    exit(FReverters.Items[key]);
  finally
    TMonitor.Exit(FReverters);
  end;
end;

procedure TJSONUnMarshal.SetField(Data: TObject; Field: string; Value: TObject);
begin
  GetFieldType(Data, Field).SetValue(Data, Value);
end;

procedure TJSONUnMarshal.SetField(Data: TObject; Field, Value: string);
var
  rField: TRTTIField;
begin
  rField := GetFieldType(Data, Field);
  if rField = nil then
    raise EConversionError.Create(Format(SNoFieldFoundForType,
        [Field, Data.ClassName]));
  case rField.FieldType.TypeKind of
    TTypeKind.tkString, TTypeKind.tkWString, TTypeKind.tkLString,
      TTypeKind.tkUString, TTypeKind.tkFloat, TTypeKind.tkInteger,
      TTypeKind.tkInt64, TTypeKind.tkChar, TTypeKind.tkWChar,
      TTypeKind.tkEnumeration:
      rField.SetValue(Data, StringToTValue(Value, rField.FieldType.Handle));
  else
    raise EConversionError.Create(Format(SNoValueConversionForField,
        [Value, Field, Data.ClassName]));
  end;
end;

procedure TJSONUnMarshal.SetField(Data: TObject; Field: string; Value: Boolean);
begin
  GetFieldType(Data, Field).SetValue(Data, Value);
end;

procedure TJSONUnMarshal.SetFieldArray(Data: TObject; Field: string;
  Value: TJSONArray);
var
  rField: TRTTIField;
  LValue: TValue;
  LFields: TArray<TRttiField>;
begin
  rField := GetFieldType(Data, Field);

  case rField.FieldType.TypeKind of
    TTypeKind.tkArray, TTypeKind.tkDynArray:
      rField.SetValue(Data, JSONToTValue(Value, rField.FieldType));
    TTypeKind.tkRecord:
    begin
      LFields := rField.FieldType.GetFields;
      // Special handling for TList<T>.FListHelper.  Unmashal FCount.  Preserve other FTypeInfo, FNotify, FCompare.
      if (rField.Name = 'FListHelper') and
        (Value.Count = 1) and
        (Length(LFields) > 1) and
        (LFields[0].Name = 'FCount')  then
      begin
        LValue := rField.GetValue(Data); // Get FListHelper
        LFields[0].SetValue(LValue.GetReferenceToRawData, JSONToTValue(Value.Items[0], LFields[0].FieldType)); // Update FCount
        rField.SetValue(Data, LValue); // Set FListHelper
      end
      else
        rField.SetValue(Data, JSONToTValue(Value, rField.FieldType));
    end
  else
    raise EConversionError.Create(Format(SInvalidTypeForField,
        [Field, rField.FieldType.Name]));
  end;
end;

procedure TJSONUnMarshal.SetFieldNull(Data: TObject; Field: string);
begin
  GetFieldType(Data, Field).SetValue(Data, TValue.Empty);
end;

procedure TJSONUnMarshal.StoreObject(ObjId: string; Obj: TObject);
begin
  FObjectHash.Add(ObjId, Obj);
end;

function TJSONUnMarshal.StringToTValue(Value: string;
  typeInfo: PTypeInfo): TValue;
var
  vChar: char;
  vWChar: widechar;
  fValue: TValue;
  enumVal: Integer;
begin
  case typeInfo.Kind of
{$IFNDEF NEXTGEN}
    TTypeKind.tkString:
      exit(TValue.From<ShortString>(ShortString(Value)));
    TTypeKind.tkWString:
      exit(TValue.From<WideString>(WideString(Value)));
{$ELSE}
    TTypeKind.tkString, TTypeKind.tkWString,
{$ENDIF !NEXTGEN}
    TTypeKind.tkLString, TTypeKind.tkUString:
      exit(Value);
    TTypeKind.tkFloat:
      exit(TDBXPlatform.JsonToFloat(Value));
    TTypeKind.tkInteger:
      exit(StrToInt(Value));
    TTypeKind.tkInt64:
      exit(StrToInt64(Value));
    TTypeKind.tkChar:
      begin
        if Value = '' then
          vChar := #0
        else
          vChar := Value[1];
        TValue.Make(@vChar, typeInfo, fValue);
        exit(fValue);
      end;
    TTypeKind.tkWChar:
      begin
        if Value = '' then
          vWChar := #0
        else
          vWChar := Value[1];
        TValue.Make(@vWChar, typeInfo, fValue);
        exit(fValue);
      end;
    TTypeKind.tkEnumeration:
      begin
        enumVal := GetEnumValue(typeInfo, Value);
        TValue.Make(@enumVal, typeInfo, fValue);
        exit(fValue);
      end
    else
      raise EConversionError.Create(Format(SNoConversionAvailableForValue,
          [Value, typeInfo.NameFld.ToString]));
  end;
end;

function TJSONUnMarshal.Unmarshal(Data: TJSONValue): TObject;
var
  Root: TJSONObject;
begin
  if not (Data is TJSONObject) then
    raise EConversionError.Create(SCannotCreateObject);

  // clear previous warnings
  ClearWarnings;
  Root := TJSONObject(Data);
  try
    Result := CreateObject(Root)
  finally
    FObjectHash.Clear;
  end;
end;

{ TSerStringItem }

constructor TSerStringItem.Create(AString: string; AObject: TObject);
begin
  FString := AString;
  FObject := AObject;
end;

{ TSerStringList }

function TSerStringList.AsStringList: TStringList;
var
  item: TSerStringItem;
begin
  Result := TStringList.Create;
  for item in FSerStringItemList do
    Result.AddObject(item.FString, item.FObject);
  Result.Duplicates := FDuplicates;
  Result.Sorted := FSorted;
  Result.CaseSensitive := FCaseSensitive
end;

constructor TSerStringList.Create(Source: TStringList);
var
  I: Integer;
begin
  SetLength(FSerStringItemList, Source.Count);
  for I := 0 to Source.Count - 1 do
    FSerStringItemList[I] := TSerStringItem.Create(Source[I],
      Source.Objects[I]);
  FCaseSensitive := Source.CaseSensitive;
  FSorted := Source.Sorted;
  FDuplicates := Source.Duplicates;
end;

destructor TSerStringList.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(FSerStringItemList) - 1 do
    FSerStringItemList[I].Free;
  inherited;
end;

{ StringListConverter }

function StringListConverter(Data: TObject): TObject;
begin
  if Data = nil then
    Exit(nil);
  Exit(TSerStringList.Create(TStringList(Data)));
end;

{ StringListReverter }

function StringListReverter(Ser: TObject): TObject;
begin
  if Ser = nil then
    exit(nil);
  try
    exit(TSerStringList(Ser).AsStringList);
  finally
    Ser.Free;
  end;
end;

{JSONBooleanAttribute}
constructor JSONBooleanAttribute.Create(val: Boolean);
begin
  FValue := val;
end;

function JSONBooleanAttributeValue( rttiObject: TRttiNamedObject; AttributeClass:
  TClass; DefaultValue: Boolean = false ): Boolean;
var
  rttiAttrib: TCustomAttribute;
begin
  for rttiAttrib in rttiObject.GetAttributes do
    if rttiAttrib is AttributeClass then
      exit(JSONBooleanAttribute(rttiAttrib).Value);
  exit(DefaultValue);
end;

{ JSONReflect }

constructor JSONReflect.Create(IsMarshalOwned: Boolean);
begin
  FMarshalOwner := IsMarshalOwned;
  inherited Create;
end;

constructor JSONReflect.Create(ConverterType: TConverterType;
  ReverterType: TReverterType;  InterceptorType: TClass;
  PopulationCustomizerType: TClass; IsMarshalOwned: Boolean);
begin
  FMarshalOwner := IsMarshalOwned;
  FReverterType := ReverterType;
  FConverterType := ConverterType;
  FInterceptor := InterceptorType;
  FPopulationCustomizer := PopulationCustomizerType;
  inherited Create;
end;

function JSONReflect.JSONInterceptor: TJSONInterceptor;
begin
  Result := FInterceptor.NewInstance as TJSONInterceptor;
  Result.ConverterType := FConverterType;
  Result.ReverterType := FReverterType;
end;

function JSONReflect.JSONPopulationCustomizer: TJSONPopulationCustomizer;
begin
  if FPopulationCustomizer <> nil then
    Result := FPopulationCustomizer.NewInstance as TJSONPopulationCustomizer
  else
    Result := nil;
end;


{ TJSONPopulationCustomizer }

procedure TJSONPopulationCustomizer.PrePopulate(Data: TObject; rttiContext: TRttiContext);
var
  rttiType : TRttiType;
  rttiField : TRttiField;
begin
  // Free any initialized fields before population
  rttiType := rttiContext.GetType( Data.ClassType );
  for rttiField in rttiType.GetFields do
  begin
    if not CanPopulate(Data, rttiField) then
      continue;
    if (rttiField.FieldType <> nil)
        and (rttiField.FieldType.TypeKind = tkClass)
        and JSONBooleanAttributeValue(rttiField,JSONOwned,true)
        //and JSONBooleanAttributeValue(rttiField,JSONMarshalled,true)
        and (rttiField.GetValue(Data).AsObject <> nil) then
          PrePopulateObjField(Data, rttiField);
  end;
end;

procedure TJSONPopulationCustomizer.PrePopulateObjField(Data: TObject;
  rttiField: TRttiField);
var
  Value: TObject;
begin
  if rttiField <> nil then
  begin
    if not CanPopulate(Data, rttiField) then
      Exit;
    Value := rttiField.GetValue(Data).AsObject;
    Value.Free;
    rttiField.SetValue(Data, TValue.Empty);
  end;
end;

function TJSONPopulationCustomizer.CanPopulate(Data: TObject;
  rttiField: TRttiField): Boolean;
begin
  if Assigned(FCanPopulate) then
    Result := FCanPopulate(Data, rttiField)
  else
    Result := JSONBooleanAttributeValue(rttiField,JSONMarshalled,true);
end;

constructor TJSONPopulationCustomizer.Create(ACanPopulate: TJSONCanPopulateProc);
begin
  inherited Create;
  FCanPopulate := ACanPopulate;
end;

procedure TJSONPopulationCustomizer.DoFieldPopulated(Data: TObject;
  rttiField: TRttiField);
begin
  // No customization by default
end;

procedure TJSONPopulationCustomizer.PostPopulate(Data: TObject);
begin
  // No customization by default
end;

{ TJSONInterceptor }

function TJSONInterceptor.IsTypeConverter: Boolean;
begin
  Result := FConverterType in [ctTypeObjects, ctTypeStrings, ctTypeObject,
    ctTypeString];
end;

function TJSONInterceptor.IsTypeReverter: Boolean;
begin
  Result := FReverterType in [rtTypeObjects, rtTypeStrings, rtTypeObject,
    rtTypeString];
end;

function TJSONInterceptor.ObjectConverter(Data: TObject;
  Field: string): TObject;
begin
  Result := nil;
end;

procedure TJSONInterceptor.ObjectReverter(Data: TObject; Field: string;
  Arg: TObject);
begin

end;

function TJSONInterceptor.ObjectsConverter(Data: TObject;
  Field: string): TListOfObjects;
begin
  Result := nil;
end;

procedure TJSONInterceptor.ObjectsReverter(Data: TObject; Field: string;
  Args: TListOfObjects);
begin

end;

function TJSONInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := EmptyStr;
end;

procedure TJSONInterceptor.StringReverter(Data: TObject; Field, Arg: string);
begin

end;

function TJSONInterceptor.StringsConverter(Data: TObject;
  Field: string): TListOfStrings;
begin
  Result := nil;
end;

procedure TJSONInterceptor.StringsReverter(Data: TObject; Field: string;
  Args: TListOfStrings);
begin

end;

function TJSONInterceptor.TypeObjectConverter(Data: TObject): TObject;
begin
  Result := nil;
end;

function TJSONInterceptor.TypeObjectReverter(Data: TObject): TObject;
begin
  Result := nil;
end;

function TJSONInterceptor.TypeObjectsConverter(Data: TObject): TListOfObjects;
begin
  Result := nil;
end;

function TJSONInterceptor.TypeObjectsReverter(Data: TListOfObjects): TObject;
begin
  Result := nil;
end;

function TJSONInterceptor.TypeStringConverter(Data: TObject): string;
begin
  Result := EmptyStr;
end;

function TJSONInterceptor.TypeStringReverter(Data: string): TObject;
begin
  Result := nil;
end;

function TJSONInterceptor.TypeStringsConverter(Data: TObject): TListOfStrings;
begin
  Result := nil;
end;

function TJSONInterceptor.TypeStringsReverter(Data: TListOfStrings): TObject;
begin
  Result := nil;
end;

{ TStringListInterceptor }

function TStringListInterceptor.TypeObjectConverter(Data: TObject): TObject;
begin
  Result := StringListConverter(Data);
end;

function TStringListInterceptor.TypeObjectReverter(Data: TObject): TObject;
begin
  Result := StringListReverter(Data);
end;

{ TJSONMarshal }

constructor TJSONMarshal.Create;
begin
  inherited Create(TJSONConverter.Create, true);

  //JSON converters
  RegisterConverter(TJSONObject, 'FMembers', JSONObjectPairListConverter);
  RegisterConverter(TJSONArray, 'FElements', JSONArrayElementsConverter);
  RegisterConverter(TStringBuilder, 'FData', StringBuilderConverter);
end;

constructor TJSONMarshal.Create(Converter: TConverter<TJSONValue>;
  OwnConverter: Boolean);
begin
  inherited Create(Converter, OwnConverter);

end;

constructor TJSONMarshal.Create(Converter: TConverter<TJSONValue>;
  OwnConverter: Boolean;
  Converters: TObjectDictionary<string, TConverterEvent>);
begin
  inherited Create(Converter, OwnConverter, Converters);

end;

{ TConverters }

class constructor TJSONConverters.Create;
begin
  CFRegConverters := TObjectDictionary<string, TConverterEvent>.Create([doOwnsValues]);
  CFRegReverters := TObjectDictionary<string, TReverterEvent>.Create([doOwnsValues]);
  CFRegMarshal := TDictionary<string, Boolean>.Create;
end;

class destructor TJSONConverters.Destroy;
begin
  FreeAndNil(CFRegMarshal);
  FreeAndNil(CFRegConverters);
  FreeAndNil(CFRegReverters);
end;

class function TJSONConverters.GetJSONMarshaler: TJSONMarshal;
var
  LKey: string;
begin
  Result := TJSONMarshal.Create(TJSONConverter.Create, true, CFRegConverters);
  TMonitor.Enter(CFRegMarshal);
  try
    for LKey in CFRegMarshal.Keys do
      Result.RegisterJSONMarshalled(LKey, CFRegMarshal.Items[LKey]);
  finally
    TMonitor.Exit(CFRegMarshal);
  end;
  // add JSON converters
  Result.RegisterConverter(TJSONObject, 'FMembers', JSONObjectPairListConverter);
  Result.RegisterConverter(TJSONArray, 'FElements', JSONArrayElementsConverter);
  Result.RegisterConverter(TStringBuilder, 'FData', StringBuilderConverter);
end;

class function TJSONConverters.GetJSONUnMarshaler: TJSONUnMarshal;
var
  LKey: string;
begin
  Result := TJSONUnMarshal.Create(CFRegReverters);
  TMonitor.Enter(CFRegMarshal);
  try
    for LKey in CFRegMarshal.Keys do
      Result.RegisterJSONMarshalled(LKey, CFRegMarshal.Items[LKey]);
  finally
    TMonitor.Exit(CFRegMarshal);
  end;
  // add JSON reverters
  Result.RegisterReverter(TJSONObject, 'FMembers', JSONObjectPairListReverter);
  Result.RegisterReverter(TJSONArray, 'FElements', JSONArrayElementsReverter);
  Result.RegisterReverter(TStringBuilder, 'FData', StringBuilderReverter);
end;

class procedure TJSONConverters.AddConverter(event: TConverterEvent);
begin
  TMonitor.Enter(CFRegConverters);
  try
    CFRegConverters.Add(TJSONMarshal.ComposeKey(event.FieldClassType, event.FieldName), event);
  finally
    TMonitor.Exit(CFRegConverters);
  end;
end;

class procedure TJSONConverters.AddMarshalFlag(AClass: TClass; AField: string;
  Marshal: Boolean);
begin
  TMonitor.Enter(CFRegMarshal);
  try
    CFRegMarshal.AddOrSetValue(TJSONMarshal.ComposeKey(AClass, AField), Marshal);
  finally
    TMonitor.Exit(CFRegMarshal);
  end;
end;

class procedure TJSONConverters.ClearMarshalFlag(AClass: TClass; AField: string);
var
  LKey: string;
begin
  TMonitor.Enter(CFRegMarshal);
  try
    LKey := TJSONMarshal.ComposeKey(AClass, AField);
    if CFRegMarshal.ContainsKey(LKey) then
      CFRegMarshal.Remove(LKey);
  finally
    TMonitor.Exit(CFRegMarshal);
  end;
end;

class procedure TJSONConverters.AddReverter(event: TReverterEvent);
begin
  TMonitor.Enter(CFRegReverters);
  try
    CFRegReverters.Add(TJSONMarshal.ComposeKey(event.FieldClassType, event.FieldName), event);
  finally
    TMonitor.Exit(CFRegReverters);
  end;
end;

{ TMarshalUnmarshalBase }

constructor TMarshalUnmarshalBase.Create;
begin
  inherited Create;
  FMarshalled := TDictionary<string,Boolean>.Create;
end;

destructor TMarshalUnmarshalBase.Destroy;
begin
  ClearWarnings;
  FMarshalled.Free;
  inherited;
end;

class function TMarshalUnmarshalBase.ComposeKey(clazz: TClass;
  Field: string): string;
begin
  if clazz <> nil then
    Result := clazz.UnitName + SEP_DOT + clazz.ClassName + SEP_DOT + Field
  else
    Result := '';
end;

procedure TMarshalUnmarshalBase.AddWarning(Data: TObject; FieldClassUnit,
  FieldClassName, FieldTypeUnit, FieldTypeName, FieldName: string);
var
  idx: Integer;
begin
  SetLength(FWarnings, Length(FWarnings) + 1);
  idx := High(FWarnings);
  FWarnings[idx] := TTransientField.Create;
  FWarnings[idx].TypeInstance := Data;
  FWarnings[idx].ClassUnitName := FieldClassUnit;
  FWarnings[idx].ClassTypeName := FieldClassName;
  FWarnings[idx].UnitName := FieldTypeUnit;
  FWarnings[idx].TypeName := FieldTypeName;
  FWarnings[idx].FieldName := FieldName;
end;

procedure TMarshalUnmarshalBase.ClearWarnings(OwnWarningObject: Boolean);
var
  I: Integer;
begin
  if OwnWarningObject then
    for I := Low(Warnings) to High(Warnings) do
      FWarnings[I].Free;
  SetLength(FWarnings, 0);
end;

function TMarshalUnmarshalBase.HasWarnings: Boolean;
begin
  Result := Length(FWarnings) > 0;
end;

procedure TMarshalUnmarshalBase.RegisterJSONMarshalled(AComposeKey: string;
  Marshal: Boolean);
begin
  FMarshalled.AddOrSetValue(AComposeKey, Marshal);
end;

procedure TMarshalUnmarshalBase.RegisterJSONMarshalled(clazz: TClass;
  Field: string; Marshal: Boolean);
begin
  FMarshalled.AddOrSetValue(ComposeKey(clazz, Field), Marshal);
end;

procedure TMarshalUnmarshalBase.UnregisterJSONMarshalled(clazz: TClass;
  Field: string);
var
  LKey: string;
begin
  LKey := ComposeKey(clazz, Field);
  if FMarshalled.ContainsKey(LKey) then
    FMarshalled.Remove(LKey);
end;

function TMarshalUnmarshalBase.ShouldMarshal(Data: TObject;
  rttiField: TRTTIField): Boolean;
var
  LKey: string;
begin
  assert(Data <> nil);
{$IFDEF AUTOREFCOUNT}
  if rttiField.Name = 'FRefCount' then
    Exit(False);
{$ENDIF}
  LKey := ComposeKey(Data.ClassType, rttiField.Name);
  if FMarshalled.ContainsKey(LKey) then
    Exit(FMarshalled.Items[LKey]);
  Result := JSONBooleanAttributeValue(rttiField,JSONMarshalled,true);
end;

{ TInternalJSONPopulationCustomizer }

procedure TInternalJSONPopulationCustomizer.Cleanup;
begin
  FBackupCache.Clear;
end;

constructor TInternalJSONPopulationCustomizer.Create(ACanPopulate: TJSONCanPopulateProc);
begin
  inherited Create(ACanPopulate);
  FBackupCache := TObjectDictionary<TRttiField, TObject>.Create([doOwnsValues]);
end;

destructor TInternalJSONPopulationCustomizer.Destroy;
begin
  FBackupCache.Free;
  inherited;
end;

procedure TInternalJSONPopulationCustomizer.DoFieldPopulated(Data: TObject;
  rttiField: TRttiField);
begin
  if FBackupCache.ContainsKey(rttiField) then
    FBackupCache.Remove(rttiField);
end;

procedure TInternalJSONPopulationCustomizer.PostPopulate(Data: TObject);
var
  LRttiField: TRttiField;
  LPair: TPair<TRttiField, TObject>;
begin
  for LRttiField in FBackupCache.Keys do
  begin
    assert(LRttiField.GetValue(Data).AsObject = nil);
    LPair := FBackupCache.ExtractPair(LRttiField);
    LPair.Key.SetValue(Data, TValue.From<TObject>(LPair.Value));
  end;
  Cleanup;
end;

procedure TInternalJSONPopulationCustomizer.PrePopulateObjField(Data: TObject;
  rttiField: TRttiField);
begin
  if rttiField <> nil then
  begin
    FBackupCache.AddOrSetValue(rttiField, rttiField.GetValue(Data).AsObject);
    rttiField.SetValue(Data, TValue.Empty);
  end;
end;

end.

