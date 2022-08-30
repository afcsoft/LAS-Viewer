unit ASPRSLAS;
{
  Copyright(c) Abdülkadir Çakýr all rights reserved.

  ASPRS LAS Specification 1.4 - R14
}
interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  System.ImageList,
  Vcl.ImgList,
  Vcl.Menus,
  Vcl.ExtCtrls,
  Logs, ViewPort,
  Vcl.ComCtrls;

// RGB value offsets for LAS Point Records
const
  RGBPos: array [0 .. 10] of Integer = (0, 0, 20, 28, 0, 28, 0, 30, 30, 0, 30);

  // Vertex defs. for DirectX
type
  TFloatColor = packed record
    R, G, B, A: Single;
  end;

type
  TFloatPosition = packed record
    X, Y, Z: Single;
  end;

type
  TPointVertex = packed record
    Position: TFloatPosition;
    Color: TFloatColor;
  end;

type
  PPointVertex = ^TPointVertex;

  // ASPRS LAS 1.4 Public Header
type
  TPublicHeader = packed record
    Signature: array [1 .. 4] of Byte;
    SourceID: Word;
    GlobalEncoding: Word;
    ProjectGUID: TGUID;
    VersionMajor: Byte;
    VersionMinor: Byte;
    SystemIdentifier: array [1 .. 32] of Byte;
    GeneratingSoftware: array [1 .. 32] of Byte;
    FileCreationDayOfYear: Word;
    FileCreationYear: Word;
    HeaderSize: Word;
    OffsetToPointData: UInt32;
    NumOfVarLenRecords: UInt32;
    PointDataRecordFormat: Byte;
    PointDataRecordLength: Word;
    LegacyNumOfPointRecords: UInt32;
    LegacyNumOfPointByReturn: array [0 .. 4] of UInt32;
    XScale, YScale, ZScale: Real;
    XOffset, YOffset, ZOffset: Real;
    MaxX, MaxY, MaxZ: Real;
    MinX, MinY, MinZ: Real;
    StartOfWaveformDataPacket: UInt64;
    StartOfFirstExtendedVariableLengthRecord: UInt64;
    NumberOfExtendedVariableLengthRecords: UInt32;
    NumberOfPointRecords: UInt64;
    NumberOfPointsByReturn: UInt64;
  end;

  // VLR -- Not Implemented Yet
type
  TVariableLengthRecordHeader = packed record
    Reserved: Word;
    UsedID: array [1 .. 16] of Byte;
    RecordID: Word;
    RecordLengthAfterHeader: Word;
    Description: array [1 .. 32] of Byte;
  end;

// Common Properties for LAS Point Records
type
  TBasicPoint = packed object X, Y, Z: Int32;
Intensity:
Word;
end;

// Common Color Properties  for colored LAS Point Records
type
  TBasicRGB = packed object R, G, B: Word;
end;

type
  PBasicPoint = ^TBasicPoint;
  PBasicRGB = ^TBasicRGB;

  // Point Record 0..10
type
  TPointRecord = packed object(TBasicPoint)
    ReturnFlags: Byte;
    Classification: Byte;
    ScanAngle:ShortInt;
    UserData: Byte;
    PointSourceID: Word;
end;

type
  TPointRecord1 = packed object(TPointRecord)GPSTime: Real;
end;

type
  TPointRecord2 = packed object(TPointRecord)Red, Green, Blue: Word;
end;

type
  TPointRecord3 = packed object(TPointRecord2)GPSTime: Real;
end;

type
  TPointRecord4 = packed object(TPointRecord1)WavePacketDecriptorIndex: Byte;
ByteOffsetToWaveformData: UInt64;
WaveformPacketSizeInBytes: UInt32;
ReturnPointWaveformLocation: Single;
ParametricDx, ParametricDy, ParametricDz: Single;
end;

type
  TPointRecord5 = packed object(TPointRecord3)WavePacketDecriptorIndex: Byte;
ByteOffsetToWaveformData: UInt64;
WaveformPacketSizeInBytes: UInt32;
ReturnPointWaveformLocation: Single;
ParametricDx, ParametricDy, ParametricDz: Single;
end;

type
  TPointRecord6 = packed object(TBasicPoint)ReturnFlags: Word;
Classification: Byte;
UserData: Byte;
ScanAngle: ShortInt;
PointSourceID: Word;
GPSTime: Real;
end;

type
  TPointRecord7 = packed object(TPointRecord6)Red, Green, Blue: Word;
end;

type
  TPointRecord8 = packed object(TPointRecord7)NIR: Word;
  // Near Infrared
end;

type
  TPointRecord9 = packed object(TPointRecord6)WavePacketDecriptorIndex: Byte;
ByteOffsetToWaveformData: UInt64;
WaveformPacketSizeInBytes: UInt32;
ReturnPointWaveformLocation: Single;
ParametricDx, ParametricDy, ParametricDz: Single;
end;

type
  TPointRecord10 = packed object(TPointRecord8)WavePacketDecriptorIndex: Byte;
ByteOffsetToWaveformData: UInt64;
WaveformPacketSizeInBytes: UInt32;
ReturnPointWaveformLocation: Single;
ParametricDx, ParametricDy, ParametricDz: Single;
end;

// Reader Event Type
type
  TOnReaderLog = procedure(Sender: TObject; LogKind: TLogKind; LogMessage: string);

  // ASPRS LAS File Reader Class
type
  TLasReader = class

  private
    // Reader Event
    FOnReaderLog: TOnReaderLog;
    FS: TFileStream;
    _DefR, _DefG, _DefB: Single;
    FResMemory: Boolean;
    // Restrict Memory Use
  public
    // Point Vertex List consumed by LASEngine.dll (DirectX Engine)
    Points: PPointVertex;
    PointCount: UInt64;
    // LAS Header
    Header: TPublicHeader;

    property OnReaderLog: TOnReaderLog read FOnReaderLog write FOnReaderLog;

    procedure LoadFromFile(Filename: String; Status: TStatusPanel);
    constructor Create(R, G, B: Single; RestrictMemoryUse: Boolean);
    destructor Free;
  end;

type
  TReaderThread = class(TThread)
  private
    Red, Green, Blue: Single;
    FID: Integer;
    FPoints: Pointer;
    FCount: UInt64;
    FColor: Boolean;
    FRecordType: Byte;
    FRecordSize: UInt32;
    FBlock: Pointer;
    FColorIndex: Int32;
    FXScale,FYScale,FZScale:Double;
    FXOffset,FYOffset,FZOffset:Double;
  public
    procedure Execute(); override;
    constructor Create(ID: Integer; Block: Pointer; Points: Pointer; Count: UInt64; R, G, B: Single; PublicHeader: TPublicHeader);
    procedure ReadColor();
    procedure ReadDefault();
  end;

implementation


///<summary>
/// Read colored point records
///</summary>
procedure TReaderThread.ReadColor;
var
  I: UInt64; // Point Index
  BlockPointer: Pointer; // Pointer to data read from LAS file
  PointPointer: Pointer; // Pointer to actual point verticies (PPointVertex)
  BasicPoint: PBasicPoint; // Pointer to common properties for all point records (X,Y,Z,Intensity)
  BasicRGB: PBasicRGB;   // Pointer to common RGB color for colored point records (NIR) discarded
  Vertex: PPointVertex;
begin

    //Start Indicies
    BlockPointer := FBlock;
    PointPointer := FPoints;

    // Each point dedicated to instance of TReaderClass
    for I := 0 to FCount - 1 do
    begin
      BasicPoint := PBasicPoint(BlockPointer);
      Vertex := PPointVertex(PointPointer);

      Vertex.Position.X := (BasicPoint.X * FXScale) + FXOffset;
      Vertex.Position.Y := (BasicPoint.Y * FYScale) + FYOffset;
      Vertex.Position.Z := (BasicPoint.Z * FZScale) + FZOffset;
      BasicRGB := PBasicRGB(Pointer(NativeUInt(BlockPointer) + FColorIndex));

      Vertex.Color.R := BasicRGB.R / 65535.0;
      Vertex.Color.G := BasicRGB.G / 65535.0;
      Vertex.Color.B := BasicRGB.B / 65535.0;
      Vertex.Color.A := 1;

      // Next TPointVertex and TBasicPoint
      PointPointer := Pointer(NativeUInt(PointPointer) + SizeOf(TPointVertex));
      BlockPointer := Pointer(NativeUInt(BlockPointer) + FRecordSize);
    end;

    // Free block
    FreeMem(PByte(FBlock), FCount * FRecordSize);
end;

///<summary>
/// Read uncolored point records
///</summary>
procedure TReaderThread.ReadDefault;
var
  I: UInt64; // Point Index
  BlockPointer: Pointer; // Pointer to data read from LAS file
  PointPointer: Pointer; // Pointer to actual point verticies (PPointVertex)
  BasicPoint: PBasicPoint; // Pointer to common properties for all point records (X,Y,Z,Intensity)
  Vertex: PPointVertex;
begin
    //Start Indicies
    BlockPointer := FBlock;
    PointPointer := FPoints;

    // Each point dedicated to instance of TReaderClass
    for I := 0 to FCount - 1 do
    begin

      BasicPoint := PBasicPoint(BlockPointer);
      Vertex := PPointVertex(PointPointer);

      Vertex.Position.X := (BasicPoint.X * FXScale) + FXOffset;
      Vertex.Position.Y := (BasicPoint.Y * FYScale) + FYOffset;
      Vertex.Position.Z := (BasicPoint.Z * FZScale) + FZOffset;

      Vertex.Color.R := Red;
      Vertex.Color.G := Green;
      Vertex.Color.B := Blue;
      Vertex.Color.A := 1;

      // Next TPointVertex and TBasicPoint
      PointPointer := Pointer(NativeUInt(PointPointer) + SizeOf(TPointVertex));
      BlockPointer := Pointer(NativeUInt(BlockPointer) + FRecordSize);
    end;

    // Free block
    FreeMem(PByte(FBlock), FCount * FRecordSize);
end;

///<summary> Method to be executed on Thread.Create
///</summary>
procedure TReaderThread.Execute;
begin
  if FColor then
    ReadColor
  else
    ReadDefault;
end;

///<summary>Creates suspended thread.
///</summary>
///<param name="ID">Index of thread (for debug)
///</param>
///<param name="Block">Pointer to data read from TFileStream. Each thread has dedicated Pointer to data read from TFileStream.
///</param>
///<param name="Points">Pointer to PPointVertex which needs to be allocated before TReaderThread.Create.
///</param>
///<param name="Count"> Number of points dedicated to this thread
///</param>
///<param name="R">
/// Default Red value if point records is not colored. (unsigned normalized color)
///</param>
///<param name="G">
/// Default Red value if point records is not colored. (unsigned normalized color)
///</param>
///<param name="B">
/// Default Red value if point records is not colored. (unsigned normalized color)
///</param>
///<param name="PublicHeader">
/// Public Header of LAS File
///</param>
constructor TReaderThread.Create(ID: Integer; Block: Pointer; Points: Pointer; Count: UInt64; R, G, B: Single; PublicHeader: TPublicHeader);
begin
  Self.FreeOnTerminate := False;

  FID := ID;
  FBlock := Block;
  FPoints := Points;
  FCount := Count;
  Red := R;
  Green := G;
  Blue := B;

  // Derived Properties
  FRecordType :=PublicHeader.PointDataRecordFormat;
  FRecordSize := PublicHeader.PointDataRecordLength;
  // Offsets and Scales defined in LAS Header
  FXScale:=PublicHeader.XScale;
  FYScale:=PublicHeader.YScale;
  FZScale:=PublicHeader.ZScale;

  FXOffset:=PublicHeader.XOffset;
  FYOffset:=PublicHeader.YOffset;
  FZOffset:=PublicHeader.ZOffset;


  FColor := (FRecordType = 2) or (FRecordType = 3) or (FRecordType = 5) or
    (FRecordType = 7) or (FRecordType = 8) or (FRecordType = 10);

  FColorIndex := RGBPos[FRecordType];
  inherited Create(true);
end;

///<summary>
///  Loads LAS file and converts point records to TPointVertex
///</summary>
/// <param name="Filename">Path to LAS File</param>
/// <param name="Status">Status Panel which notifies user through process</param>
procedure TLasReader.LoadFromFile(Filename: String; Status: TStatusPanel);
var
  StartTime: Int64;
  PCForEachThread: UInt64; // Point count for each Thread
  PCForLastThread: UInt64; // Point count for last thread
  // Threads
  ThreadCount: Integer;
  ThreadBlocks: array of Pointer;
  Threads: array of TReaderThread;
  ThreadHandles: array of THandle;
  I: Integer;
  Ret: Cardinal;
  ByteCount: UInt64;
begin
  if not FileExists(Filename) then
    raise Exception.Create('File Not Found!');

  Status.Text := 'Loading ' + ExtractFileName(Filename) + '...';

  FS := TFileStream.Create(Filename, fmOpenRead);
  try
    FS.Read(Header, SizeOf(TPublicHeader));

    // Legacy LAS File Compability
    if Header.VersionMajor * 1000 + Header.VersionMinor * 100 >= 1400 then
      PointCount := Header.NumberOfPointRecords
    else
      PointCount := Header.LegacyNumOfPointRecords;


    ThreadCount := TThread.ProcessorCount;

    // Don't use all threads
    if ThreadCount > 1 then
      Dec(ThreadCount, 1);

    StartTime := GetTickCount64;
    FS.Position := Header.OffsetToPointData;

    PCForEachThread := PointCount div ThreadCount;
    PCForLastThread := PointCount mod ThreadCount;
    SetLength(ThreadBlocks, ThreadCount);
    SetLength(Threads, ThreadCount);
    SetLength(ThreadHandles, ThreadCount);
    GetMem(Points, SizeOf(TPointVertex) * PointCount);

    for I := 0 to ThreadCount - 1 do
    begin
      if I=ThreadCount-1 then
        Inc(PCForEachThread,PCForLastThread);
      ByteCount := PCForEachThread * UInt64(Header.PointDataRecordLength);
      GetMem(PByte(ThreadBlocks[I]), ByteCount);
      FS.Read(PByte(ThreadBlocks[I])^, ByteCount);
      Threads[I] := TReaderThread.Create(I, ThreadBlocks[i], Points, PCForEachThread, _DefR, _DefG, _DefB, Header);
      ThreadHandles[I] := Threads[I].Handle;
      Inc(PByte(Points), PCForEachThread * SizeOf(TPointVertex));
      Threads[I].Start;
      if FResMemory then
        Threads[I].WaitFor;
    end;

    // Wait threads to finish
    while true do
    begin
      Ret := MsgWaitForMultipleObjects(ThreadCount, ThreadHandles[0], true, INFINITE, QS_ALLINPUT);

      if Ret = WAIT_OBJECT_0 then
      begin
        Status.Text := 'Complete!';
        break;
      end;

      if Ret > WAIT_OBJECT_0 then
      begin
        Status.Text := (Ret - WAIT_OBJECT_0).ToString + '/' + ThreadCount.ToString;
        Application.ProcessMessages;
      end;
    end;

    // Free all threads
    for I := 0 to ThreadCount - 1 do
      Threads[I].Free;

    // Move Pointer to Start
    Dec(Points, PointCount);

    if Assigned(FOnReaderLog) then
      FOnReaderLog(Self, lgMessage, 'It took ' + (GetTickCount64 - StartTime).ToString + ' ms to load!');

    FS.Free;
    FS := nil;

  except
    on e: Exception do
      if Assigned(FOnReaderLog) then
        FOnReaderLog(Self, lgError, e.Message);
  end;
end;
///<summary>
/// Creates instance of TLasReader with default color of uncolorized las files and memory restriction option (Experimental)
///</summary>
constructor TLasReader.Create(R, G, B: Single; RestrictMemoryUse: Boolean);
begin
  FResMemory := RestrictMemoryUse;
  _DefR := R;
  _DefG := G;
  _DefB := B;
  FS := nil;
  Points := nil;
end;

destructor TLasReader.Free;
begin
  if FS <> nil then
    FS.Free;
  if Points <> nil then
    FreeMem(PByte(Points), PointCount * SizeOf(TPointVertex));
  FS := nil;
  Points := nil;
end;

end.
