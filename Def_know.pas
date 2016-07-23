unit Def_know;

(*
ModuleDataTable
---------------
//������� �� ModuleCount ������� ����
WORD 	ID;
PSTR 	ModuleName;
PSTR	Filename;
WORD 	UsesNum;
WORD 	UsesID[UsesNum];	//������ ��������������� �������
PSTR	UsesNames[UsesNum];	//������ ���� �������

ConstDataTable
--------------
//������� �� ModuleCount ������� ����
WORD 	ModuleID;
PSTR 	ConstName;
BYTE 	Type; //'C'-ConstDecl, 'P'-PDecl (VMT), 'V'-VarCDecl
PSTR 	TypeDef; //���
PSTR 	Value; //��������
DWORD	DumpTotal;	//����� ������ ����� (����+������+�������)
DWORD 	DumpSize; //������ ��������� ����� (RTTI)
DWORD 	FixupNum; //���������� �������� �����
BYTE 	Dump[DumpSize]; //�������� ���� (RTTI)
BYTE 	Relocs[DumpSize];
FIXUPINFO Fixups[FixupNum]; //������ ��������

TypeDataTable
-------------
//������� �� TypeCount ������� ����
DWORD   Size; //Size of Type
WORD 	ModuleID;
PSTR 	TypeName;
BYTE 	Kind; //drArrayDef,...,drVariantDef (��. ������)
DWORD 	VMCnt; //���������� ��������� VMT (������� � 0)
PSTR 	Decl; //����������
DWORD	DumpTotal;	//����� ������ ����� (����+������+�������)
DWORD 	DumpSize; //������ ��������� ����� (RTTI)
DWORD 	FixupNum; //���������� �������� �����
BYTE 	Dump[DumpSize]; //�������� ���� (RTTI)
BYTE 	Relocs[DumpSize];
FIXUPINFO Fixups[FixupNum]; //�������
DWORD	FieldsTotal;	//����� ������ ������ �����
WORD 	FieldsNum; //���������� ����� (class, interface, record)
FIELDINFO Fields[FieldNum]; //����
DWORD	PropsTotal;	//����� ������ ������ �������
WORD 	PropsNum; //���������� ������� (class, interface)
PROPERTYINFO Props[PropNum]; //��������
DWORD	MethodsTotal;	//����� ������ ������ �������
WORD 	MethodsNum; //���������� ������� (class, interface)
METHODINFO Methods[MethodNum]; //������

VarDataTable
------------
//������� �� VarCount ������� ����
WORD 	ModuleID;
PSTR 	VarName;
BYTE 	Type; //'V'-Var;'A'-AbsVar;'S'-SpecVar;'T'-ThreadVar
PSTR 	TypeDef;
PSTR 	AbsName; //��� ��������� ����� absolute

ResStrDataTable
---------------
//������� �� ResStrCount ������� ����
WORD 	ModuleID;
PSTR 	ResStrName;
PSTR 	TypeDef;
PSTR	Context;

ProcDataTable
-------------
//Contains ProcCount structures:
WORD 	ModuleID;
PSTR 	ProcName;
BYTE 	Embedded; //Contains embedded procs
BYTE 	DumpType; //'C' - code, 'D' - data
BYTE 	MethodKind; //'M'-method,'P'-procedure,'F'-function,'C'-constructor,'D'-destructor
BYTE 	CallKind; //1-'cdecl', 2-'pascal', 3-'stdcall', 4-'safecall'
int 	VProc; //Flag for "overload" (if Delphi version > verD3 and VProc&0x1000 != 0)
PSTR 	TypeDef; //Type of Result for function
DWORD	DumpTotal;	//Total size of dump (dump+relocs+fixups)
DWORD 	DumpSz; //Dump size
DWORD 	FixupNum; //Dump fixups number
BYTE 	Dump[DumpSz]; //Binary dump
BYTE 	Relocs[DumpSize];
FIXUPINFO Fixups[FixupNum]; //Fixups
DWORD	ArgsTotal;	//Total size of arguments
WORD 	ArgsNum; //Arguments number
ARGINFO Args[ArgNum]; //Arguments
DWORD	LocalsTotal;	//Total size of local vars
WORD 	LocalsNum; //Local vars number
LOCALINFO Locals[LocalNum]; //Local vars
*)

interface

Uses Classes;

Type

  // Flags about validity of the class info structures
  TInfoFlags = (
    INFO_DUMP,     // 1;
    INFO_ARGS,     // 2;
    INFO_LOCALS,   // 4;
    INFO_FIELDS,   // 8;
    INFO_PROPS,    // 16;
    INFO_METHODS,  // 32;
    INFO_ABSNAME   // 64;
  );
  TInfoFlagSet = set of TInfoFlags;

  TKBsection = (
    //Sections of the Knowledge Base
    //KB_NO_SECTION      = 0;
    KB_CONST_SECTION,   // 1;
    KB_TYPE_SECTION,    // 2;
    KB_VAR_SECTION,     // 4;
    KB_RESSTR_SECTION,  // 8;
    KB_PROC_SECTION     // 16;
  );
  TKBset = set of TKBsection;

  // Information about offsets of names and data
  OffsetInfo = record
    Offset,
    Size,
    ModId,    //Modules
    NamId:Integer;    //Names
  End;
  POffsetInfo = ^OffsetInfo;
  ArrOffsetInfo = Array Of OffsetInfo;

  //Fixup info
  FixupInfo = record
    _Type:Byte;           //'A' - ADR, 'J' - JMP, 'D' - DAT
    Ofs:Integer;            //Offset relative to the beginning of dump
    Name:PAnsiChar;
  End;
  PFixupInfo = ^FixupInfo;

  FieldInfo = class
    //FIELDINFO():xrefs(0){}
    //~FIELDINFO();
    Scope:Byte;       //9-private, 10-protected, 11-public, 12-published
    Offset:Integer;   //Offset in the object
    _Case:Integer;    //case for record types (0xFFFFFFFF for the rest)
    Name:AnsiString;  //Field name
    _Type:AnsiString; //Field type
    xrefs:TList;		  //References to this field from the CODE section
    Constructor Create;
    Destructor Destroy; Override;
  End;
  //PFieldInfo = ^FieldInfo;

  PropInfo = record
    Scope:Byte;            //9-private, 10-protected, 11-public, 12-published
    Index:Integer;         //readonly, writeonly depending on bits 1 and 2
    DispID:Integer;        //???
    Name:AnsiString;       //Field name
    TypeDef:AnsiString;    //Field type
    ReadName:AnsiString;   //Name of getter method, or member field
    WriteName:AnsiString;  //Name of setter method, or member field
    StoredName:AnsiString; //Name of method to check DEFAULT, or the boolean value itself
  end;
  PPropInfo = ^PropInfo;

  MethodInfo = Record
    Scope:Byte;            //9-private, 10-protected, 11-public, 12-published
    MethodKind:Byte;       //'M'-method, 'P'-procedure, 'F'-function, 'C'-constructor, 'D'-destructor
    Prototype:AnsiString;  //Prototype full name
  End;
  PMethodInfo = ^MethodInfo;

  ArgInfo = Record
    Tag:Byte;           //0x21-"val", 0x22-"var"
    in_Reg:Boolean;     //If true - argument is in register, else - in stack
    Ndx:Integer;        //Register number and offset (XX-number, XXXXXX-offset) (0-EAX, 1-ECX, 2-EDX)
    Size:Integer;		    //Argument Size
    Name:AnsiString;    //Argument Name
    TypeDef:AnsiString; //Argument Type
  end;
  PArgInfo = ^ArgInfo;

  LocalInfo = Record
    Ofs:Integer;         //Offset of local var (from ebp or EP)
    Size:Integer;        //Size of local var
    Name:AnsiString;     //Local var Name
    TypeDef:AnsiString;  //Local var Type
  end;
  PLocalInfo = ^LocalInfo;

  XrefRec = record
    _type:Char;       //'C'-call; 'J'-jmp; 'D'-data
    adr:Integer;        //address of procedure
    offset:Integer;   //offset in procedure
  End;
  PXrefRec = ^XrefRec;

  MConstInfo = record
  //public
    ModuleID:WORD;
    ConstName:AnsiString;
    _Type:Byte;       //'C'-ConstDecl, 'P'-PDecl (VMT), 'V'-VarCDecl
    TypeDef:AnsiString;
    Value:AnsiString;
    DumpSz,     //Size of the binary dump
    FixupNum:Integer;   //Number of fixups
    Dump:PAnsiChar;     //Binary dump
    //Constructor Create;
  end;
  PMConstInfo = ^MConstInfo;

  MTypeInfo = record
  //public
    Size:Integer;
    ModuleID:WORD;
    TypeName:AnsiString;
    Kind:Byte;       //drArrayDef,...,drVariantDef
    VMCnt:WORD;      //Number of elements in VMT (indexed from 0)
    Decl:AnsiString; //Declaration
    DumpSz,    //������ ��������� �����
    FixupNum:Integer;  //���������� �������� �����
    Dump:PAnsiChar;    //�������� ����
    FieldsNum:WORD;  //���������� ����� (class, interface, record)
    Fields:PAnsiChar;
    PropsNum:WORD;   //���������� ������� (class, interface)
    Props:PAnsiChar;
    MethodsNum:WORD; //���������� ������� (class, interface)
    Methods:PAnsiChar;
    //Constructor Create;
  end;
  PMTypeInfo = ^MTypeInfo;

  MVarInfo = record
  //public
    ModuleID:WORD;
    VarName:AnsiString;
    _Type:Byte; //'V'-Var;'A'-AbsVar;'S'-SpecVar;'T'-ThreadVar
    TypeDef:AnsiString;
    AbsName:AnsiString; //��� ��������� ����� absolute
    //Constructor Create;
  end;
  PMVarInfo = ^MVarInfo;

  MResStrInfo = record
  //public
    ModuleID:WORD;
    ResStrName:AnsiString;
    TypeDef:AnsiString;
    //Context:AnsiString;
    //Constructor Create;
  end;
  PMResInfo = ^MResStrInfo;

  MProcInfo = record
  //public
    ModuleID:WORD;
    ProcName:AnsiString;
    Embedded:Boolean;   //true = contains nested procedures
    DumpType:Char;   //'C' - code, 'D' - data
    MethodKind:Char; //'M'-method,'P'-procedure,'F'-function,'C'-constructor,'D'-destructor
    CallKind:Byte;   //1-'cdecl', 2-'pascal', 3-'stdcall', 4-'safecall'
    VProc:Integer;      //flag for "overload" (���� ������ ������ > verD3 � VProc&0x1000 != 0)
    TypeDef:AnsiString;
    DumpSz,     //������ ��������� �����
    FixupNum:Integer;   //���������� �������� �����
    Dump:PAnsiChar;      //�������� ���� (�������� � ���� ���������� ����, ������ � �������)
    ArgsNum:WORD;    //���������� ���������� ���������
    Args:Pointer;      //������ ����������
    //LocalsNum:WORD;  //���������� ��������� ���������� ���������
    //Locals:Pointer;    //������ ��������� ����������
    //Constructor Create;
  end;
  PMProcInfo = ^MProcInfo;

Const

  // Description of the Kind values
  drArrayDef         = $4C;    //'L'
  drClassDef         = $46;    //'F'
  drFileDef          = $4F;    //'O'
  drFloatDef         = $49;    //'I'
  drInterfaceDef     = $54;    //'T'
  drObjVMTDef        = $47;    //'G'
  drProcTypeDef      = $48;    //'H'
  drPtrDef           = $45;    //'E'
  drRangeDef         = $44;    //'D'
  drRecDef           = $4D;    //'M'
  drSetDef           = $4A;    //'J'
  drShortStrDef      = $4B;    //'K'
  drStringDef        = $52;    //'R'
  drTextDef          = $50;    //'P'
  drVariantDef       = $53;    //'S'
  drAliasDef         = $41;    //'Z'

  //Var Type field
  VT_VAR        =  'V';
  VT_ABSVAR     =  'A';
  VT_SPECVAR    =  'S';
  VT_THREADVAR  =  'T';

implementation

Constructor FieldInfo.Create;
Begin
  xrefs:=TList.Create;
end;

Destructor FieldInfo.Destroy;
var
  i:Integer;
Begin
  for i:=0 to xrefs.Count-1 do
    Dispose(PXRefRec(xrefs[i]));
  xrefs.Free;
end;
(*
Constructor MConstInfo.Create;
Begin
  ModuleID:=$FFFF;
end;

Constructor MTypeInfo.Create;
Begin
  ModuleID:=$FFFF;
  Kind:=255;
end;

Constructor MVarInfo.Create;
Begin
  ModuleID:=$FFFF;
end;

Constructor MResStrInfo.Create;
Begin
  ModuleID:=$FFFF;
end;

Constructor MProcInfo.Create;
Begin
  ModuleID:=$FFFF;
end;
*)
end.
