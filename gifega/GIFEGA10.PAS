program gifega;

{Version 1.0, written 1/18/88-2/7/88 by Jim Griebel. This software is
experimental! USE AT YOUR OWN RISK. In the public domain. 'GIF' and
'Graphics Interchange Format' are trademarks of Compuserve, Inc., an H&R
Block Company. 'Turbo Pascal' is a trademark of Borland International.}

{Includes for external .OBJ files}

{$L nlzw}
{$L readrast}
{$L scrsave}
{$L scroll}

{Turbo standard UNITS}

uses crt,dos;

type

{Our 64,000-byte array, used for practically everything}
    RasterArray = Array [0..63999] of byte;
    RasterP = ^RasterArray;

{Except the EGA bitplanes, which are kept here}
    Bitplane = Array [0..38399] of byte;
    PlaneP = ^BitPlane;

    Palarray = Array [0..255] of byte;
    Str12 = String [12];
    Str80 = String [80];

var
    GIFFile:File of RasterArray;     {GIF input file}
    ScrFile:File of Byte;            {Output file if desired}
    GifStuff:RasterP;                {Heap array for GIF file}
    Raster:RasterP;                  {Unblocked GIF data stream}
    Raster2:RasterP;                 {More unblocked stream if needed}
    Plane0,Plane2,Plane1,Plane3:PlaneP; {EGA bitplanes, for scroll & save}
    Regs:Registers;                  {Turbo predefined variable}
    DirInfo: SearchRec;              {Turbo predefined variable}

    Width,         {Read from GIF header, image width}
    Height,        { ditto, image height}
    LeftOfs,       { ditto, image offset from left}
    TopOfs,        { ditto, image offset from top}
    RWidth,        { ditto, raster width}
    RHeight,       { ditto, raster height}
    ClearCode,     {GIF clear code}
    EOFCode,       {GIF end-of-information code}
    MaxCode,       {Decompressor limiting value for current code size}
    CurCode,       {Decompressor variable}
    OldCode,       {Decompressor variable}
    InCode,        {Decompressor variable}
    FirstFree,     {First free code, generated per GIF spec}
    Codesize,      {Size of code, computed from GIF header}
    GIFPtr,        {Array pointer used during file read}
    FreeCode,      {Next free code, used by decompressor}
    ReadMask,      {Code AND mask for current code size}
    I,J,K,         {Loop counters, what else?}
    Bitmask,       {Used during read from compressed file}
    ColorMapSize,  {Size of the colormap}
    XDir,YDir,     {used for directory write to screen}
    DirSize,       { Ditto }
    FSize          {Size of bitplanes to write to output file}
    :word;


    Interlace,     {True if interlaced image}
    NextRaster,    {True if file>64000 bytes}
    Clear,         {True during clear}
    ColorMap:      {True if colormap present}
    Boolean;

    ch:char;       {Utility}

    a,             {Utility}
    Resolution,    {Resolution, read from GIF header}
    BitsPerPixel,  {Bits per pixel, read from GIF header}
    Background,    {Background color, read from GIF header}
    InitCodeSize,  {Starting code size, used during Clear}
    FinChar,       {Decompressor variable}
    Pass,          {Used by video output if interlaced pic}
    R,G,B          {Red,Green,Blue values used during color comps}
    :byte;

    Roll:Integer;  {Scroll offset value, an integer so
                     we can tell when it goes <0}

    {The color map, read from the GIF header}
    Red,Green,Blue: array [0..255] of word;

    {The EGA palette, derived from the color map}
    Palette: PalArray;

    {Strings used for various purposes}
    FileString:Str80;
    UString:Str80;
    Homedir:Str80;

    {Holds the directory strings}
    NString:Array [0..255] of Str12;

    {An array of computed line starting values in EGA RAM, used to
     make the program marginally faster}
    LineStart:Array [0..479] of word;

Const
    {MaxCode values for differing code sizes}
    MaxCodes: Array [0..9] of Word = (4,8,16,$20,$40,$80,$100,$200,$400,$800);

    {Saves computing these values, Pascal having no exponentiation}
    PowersOf2: Array [0..8] of word=(1,2,4,8,16,32,64,128,256);

    Rastersize:Word = 64000;
    PlaneSize:Word = 38400;
    EGAPage:Word = $A000;          {EGA video RAM segment address}
    EGAHeight:Word = 350;            {Height of vanilla EGA screen}

    Nicepal: PalArray= (1,4,54,63,63,63,63,54,63,63,63,63,63,63,54,54,60,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);


{Procedure declarations that bring our .OBJ externals into the program}

procedure nlzw; external;

procedure readrast; external;

procedure scrsave; external;

procedure Scroll; external;


{Go to the bottom line and clear same out}

Procedure BottomLine;

Begin
     GotoXY (2,24);
     DelLine;
End;


{End the program gracefully, giving the user back a text video mode and
returning him to the directory he started from}

Procedure Morgue;

Begin
     Textmode (15);
     ChDir (HomeDir);
     Halt;
End;

{Display the sorted directory listing}

Procedure ShowDir;

Var J:Word;

Begin

{List the filenames on the screen. If there are more than 20 then
display them in two or more columns}

     ClrScr;
     If DirSize=0 then Exit;
     XDir:=2;
     YDir:=3;
     For J:=0 to DirSize do
         Begin
              GotoXY (XDir,YDir);
              Writeln (NString [J]);
              YDir:=Succ (YDir);
              If YDir = 22 then
                 Begin
                      XDIR:=XDIR+15;
                      YDIR:=3;
                 End;
         End;

End;

Procedure DoDir;

{Get and put up a sorted directory display of eligible files only; uses
calls specific to Turbo. See the Turbo manual for a description of the
calls used and their results}

Var Sortflag: Boolean;
    I: Integer;

Begin

{Get the current directory}

     GetDir (0,UString);
     I:=0;

{Find the first matching file, if any}

     FindFirst ('*.gif',Anyfile,DirInfo);
     If DosError <> 0 then
     Begin
        Dirsize:=0;
        Exit;
     End;

{And subsequent, if any}

     NString [I]:=DirInfo.Name;
     I:=Succ (I);
     Repeat
           FindNext (DirInfo);
           If DosError =0 then
           Begin
              Nstring [I]:=DirInfo.Name;
              I:=Succ (I);
           End;
     Until (DosError=18) or (I=256);

{Now sort the filenames alphabetically}

     Repeat
     Sortflag:=False;
     If I>2 then
           For J:=0 to I-2 do
               Begin
                 If NString [J]>Nstring [J+1] then
                    Begin
                      NString [255]:=Nstring [J];
                      NString [J]:=Nstring [J+1];
                      NString [J+1]:=Nstring [255];
                      Sortflag:=True;
                    End;
               End;
     Until Sortflag=False;
     DirSize:=I-1;

End;

{Save the currently displayed image as an EGA Paint .SCR file}

Procedure SaveScreen;

Begin

{Convert the input filename to the output filename.}

     I:=Pos ('.',Filestring);
     Filestring:=Copy (Filestring,1,I);
     If (Height<480) or (EGAHeight<480) then
        Begin
             Filestring:=Filestring+'SCR';
             FSize:=28000;
        End
        Else
        Begin
            Filestring:=Filestring+'SCP';
            FSize:=38400;
        End;

{We let Turbo open the file, since we can grab the handle in the assembly
external}

     Assign (Scrfile,FileString);
     Rewrite (Scrfile);

{The assembly external handles the actual write}

     ScrSave;

{Close it, and we're done}

     Close (Scrfile);
End;

{This procedure checks to be sure we've got enough heap for the array
we're trying to allocate, then allocates same. If there isn't enough
heap available, we exit with an error}

Procedure AllocMem (Var P:RasterP);

Var ASize:Longint;

Begin
     ASize:=MaxAvail;
     If ASize<RasterSize then
        Begin
             Textmode (15);
             Writeln ('Insufficient memory available!');
             Halt;
        End
        Else
        Getmem (P,RasterSize);
End;

{Same as AllocMem, but for a bitplane-sized array}

Procedure AllocPlane (Var P:PlaneP);

Var ASize:LongInt;

Begin
     ASize:=Maxavail;
     If ASize<PlaneSize then
        Begin
             Textmode (15);
             Writeln ('Insufficient memory available!');
             Halt;
        End
        Else GetMem (P,PlaneSize);

End;


{Mimics a file read of a single byte, reading from the input record rather
than the file itself. If you wish to change back to a file of byte rather
than using the faster read of the record, you can modify this routine to
read directly from the file. That's simpler but slower}

Function Getbyte:Byte;
  Begin
       If GIFPtr=RasterSize then Exit;
       Getbyte:=GIFStuff^[GIFPtr];
       GIFPtr:=Succ(GIFPtr);
  End;

{Reads two bytes, to get a word value}

Function Getword:Word;

Var A,B:Byte;

Begin
     A:=Getbyte;
     B:=Getbyte;
     Getword:=A+(256*B);
End;

{During READRAST, reach out and get the rest of the file if it is
larger than 64000 bytes}

Procedure ReadMore;

Var IOR:Integer;

Begin
     {$I-}
     Read (GIFFile,GIFStuff^);
     {$I+}
     IOR:=IOResult;
End;

{During the file decompress cycle, readjust the RASTER arrays if the
original file read was larger than 64000 bytes.}

Procedure MoveUp (var Bitoffset:Longint);

Var Byteoffset:Longint;

        Begin
             Byteoffset:=Bitoffset div 8;
             Move (Raster^[Byteoffset],Raster^[0],RasterSize-Byteoffset);
             Move (Raster2^[0],Raster^[RasterSize-Byteoffset],63000);
             Bitoffset:=Bitoffset mod 8;
             FreeMem (Raster2,RasterSize);
             Nextraster:=False;
        End;


Procedure SetPal (Pal:PalArray);


Begin
     Regs.AX:=$1002;
     Regs.DX:=Ofs (Pal);
     Regs.ES:=Seg (Pal);
     Intr ($10,Regs);
End;


{Use the BIOS functions to set up the EGA. This avoids dependence on Turbo's
GRAPH package and the necessity to keep .BGI files with the executable}

Procedure InitEGA;

Var LocPal:PalArray;

Begin

{Set EGA graphics mode}

   Regs.AX:=$0010;
   Intr ($10,Regs);

{Set the palette}

   LocPal:=Palette;
   LocPal [16]:=Background;

   SetPal (LocPal);

{Compute line starting values for the assembly-language displayer}

    For I:=0 to 479 do
        LineStart [I]:=I*80;

{Enable Set/Reset on all the EGA bitplanes}
    Port [$3CE]:=1;
    Port [$3CF]:=15;

End;


{Derive the EGA palette value corresponding to the GIF colormap intensity
value for a given color.}

Procedure DetColor (Var PValue:Byte;MapValue:Byte);

Begin
        PValue:=MapValue div 64;
        If PValue=1 then PValue:=2 else
           If PValue=2 then PValue:=1;
End;

{A crude attempt to deal with 256-color pics. Works. Badly. Dot-dithering,
anyone?}

Procedure AdjustBigPal;


Var ColPtr,Cindex,I,J,X:Word;

Begin

     For I:=16 to ColorMapSize-1 do
         Begin
              Colptr:=63;
              For J:=0 to 15 do
              Begin
                  If Palette [I]>Palette[J] then
                     X:=Palette [I]-Palette[J] else X:=Palette [J]-Palette[I];
                  If (X< Colptr) then
                     Begin
                          Colptr:=X;
                          Cindex:=J;
                     End;
              End;
              Palette [I]:=Cindex;
         End;
     End;



{Set the key variables to their necessary initial values.}


Procedure ReInitialize;
Begin
     Pass:=0;        {Interlace pass counter back to 0}
     GIFPtr:=0;      {Mock file read pointer back to 0}
     Nextraster:=False; {Start by claiming file <64000 bytes}
End;

{React to GIF clear code by resetting GIF decompression values back to their
initial state.}

Procedure DoClear;

    Begin
      CodeSize:=InitCodeSize;
      MaxCode:=MaxCodes [CodeSize-2];
      FreeCode:=FirstFree;
      ReadMask:=(1 shl CodeSize)-1;
    End;


Begin    {the main program}

{First get the home directory so that we can reset to it on exit, and get
the eligible files in that directory}

Getdir (0,HomeDir);
DoDir;

Repeat   {giant loop reruns whole program till user bails}

{Initialize a bunch of variables}

     ReInitialize;         {Initialize common vars}


{Get memory for the raster data array, and the input file data array}

     AllocMem (Raster);
     AllocMem (GIFStuff);
     SetPal (NicePal);
     Textcolor (2);

 Repeat {Get GIF file}
  Repeat {Get good file}
    Repeat {Get good filename}

     ShowDir;         {Show eligible files}

{Prompt the user for the filename}

     Bottomline;
     Write ('Filename (ENTER exits,\ changes dir): ');
     Readln (Filestring);
     If Filestring = '' then Morgue; {bail on null string}
     If FileString ='\' then         {change dir on single '\' char}
        Begin
             Bottomline;
             Write ('New directory name: ');
             Readln (Ustring);
             {$I-}
             Chdir (Ustring);
             {$I+}
             I:=IOResult;
             If I<>0 then
                Begin
                     Bottomline;
                     Textcolor (1);
                     Writeln ('Error changing to directory ',Ustring);
                     Textcolor (2);
                End;
             DoDir;                   {Relist directory in new dir}
        End;
    Until FileString <> '\';    {Got good filename}

    If Pos ('.',Filestring)=0 then Filestring:=Filestring+'.gif';


    {Open the file}

    {$I-}
     Assign (GIFFile,FileString);
     Reset (GIFFile);
    {$I+}

    {Cope with I/O error should one occur}

     I:=IOResult;
     If I<>0 then
        Begin
             Textcolor (1);
             Bottomline;
             Write ('Error opening file ',FileString,'. Press any key ');
             Readln;
             Textcolor (2);
        End;

  Until I=0;    {Got good file}

{Read in the GIF file. Reading it as one big hunk rather than N bytes results
in far faster disk I/O; see user notes. Error checking is turned off in
order to avoid 'attempt to read past EOF' errors. If the file does not exist,
this will be detected at RESET}

     BottomLine;
     Write ('Reading . . . ');
{$I-}
     Read (GIFFile,GIFStuff^);
{$I+}

{Note that 4.0 requires this assignment, or else if an error results (as it
will if the file is smaller than 64000 bytes) no I/O will be allowed for
the remainder of the run. If the file is >64000 bytes, then the rest
of it will be read during ReadRast}

I:=IOResult;

{Deal with the GIF header. Start by checking the GIF tag to make sure this
is a GIF file}

     UString:='';
     for I:=1 to 6 do
     Begin
         UString:=UString+chr(Getbyte);
     End;
     If UString<>'GIF87a' then
        Begin
             Textcolor (1);
             Bottomline;
             Write (UString);
             Write ('Not a GIF file, or header read error. Press any key ');
             Textcolor (2);
             Readln;
        End;

 Until UString = 'GIF87a';  {Get GIF file}

{Get variables from the GIF screen descriptor}

     RWidth:=Getword;         {The raster width and height}
     RHeight:=Getword;

     {Get the packed byte immediately following and decode it}
     B:=Getbyte;
     If B and $80=$80 then Colormap:=True else Colormap:=False;
     Resolution:=(B and $70 shr 5)+1;
     BitsPerPixel:=(B and 7)+1;
     If BitsPerPixel=1 then I:=2 else I:=1 shl BitsPerPixel;
     Bitmask:=(1 shl BitsPerPixel)-1;

     Background:=Getbyte;
     B:=Getbyte;         {Skip byte of 0's}

{Compute size of colormap, and read in the global one if there. Compute
values to be used when we set up the EGA palette}

     ColorMapSize:=1 shl BitsPerPixel;
     If Colormap then
     Begin
     For I:=0 to ColorMapSize-1 do
     Begin
         Red [I]:=Getbyte;
         Green [I]:=Getbyte;
         Blue [I]:=Getbyte;
         DetColor (R,Red[I]);
         DetColor (G,Green [I]);
         DetColor (B,Blue [I]);
         Palette [I]:=B and 1+(2*(G and 1))+(4*(R and 1))+(8*(B div 2))+(16*(G div 2))+(32*(R div 2));
     End;
     If ColorMapSize>16 then AdjustBigPal; {Hack at 256-color pics}
     End;

{Now read in values from the image descriptor}

     B:=Getbyte;  {skip image seperator}
     Leftofs:=Getword;    {Left offset, not used here}
     Topofs:=Getword;     {Top offset, not used here}
     Width:=Getword;      {Width, not used here}
     Height:=Getword;     {Height, not used here}
     A:=Getbyte;
     If A and $40=$40 then Interlace:=True else Interlace:=False;


{Note that we ignore the possible existence of a local color map. I've yet
to encounter an image that had one, and the spec says it's defined for
future use. This could lead to an error reading some files}

{Start reading the raster data. First we get the intial code size}

     Codesize:=Getbyte;

{Compute decompressor constant values, based on the code size}

     ClearCode:=PowersOf2 [Codesize];
     EOFCode:=ClearCode+1;
     FirstFree:=ClearCode+2;
     FreeCode:=FirstFree;

{The GIF spec has it that the code size used to compute the above values is
the code size given in the file, but the code size used in compression/
decompression is the code size given in the file plus one.}

     Codesize:=Succ (Codesize);
     InitCodeSize:=Codesize;
     Maxcode:=Maxcodes [Codesize-2];
     ReadMask:=(1 shl Codesize)-1;

{Read the raster data. Here we just transpose it from the GIF array to the
Raster array, turning it from a series of blocks into one long data stream,
which makes life much easier for ReadCode. This too is now assembly}

     Writeln ('Unblocking . . . ');
     ReadRast;

{Get ready to do the actual read/display. Free up the heap used by the
GIF array since we don't need it any more}

     FreeMem (GIFStuff,RasterSize);

{Set up the EGA}

     InitEGA;

{Preset the CLEAR flag to off}

     Clear:=False;

{Decompress and display}

     nlzw;

{Get rid of the heap used by the Raster array, and close the GIF file}

   FreeMem (Raster,RasterSize);
   Close (GIFFile);

{Now grab the bitplanes from EGA memory, to be used when scrolling and
saving the file. We take advantage of the fact that although only 28000
bytes of EGA memory can be used for display, the extra memory to store
a 640x480 pic is there and working and will contain the excess scan
lines}

   AllocPlane (Plane0);
   AllocPlane (Plane1);
   AllocPlane (Plane2);
   AllocPlane (Plane3);

{Set read map select register to the plane to be read, then simply move
the plane to the corresponding array}

   Port [$3CE]:=4;
   Port [$3CF]:=0;
   Move (Mem [EGAPage:0],Plane0^,PlaneSize);
   Port [$3CE]:=4;
   Port [$3CF]:=1;
   Move (Mem [EGAPage:0],Plane1^,PlaneSize);
   Port [$3CE]:=4;
   Port [$3CF]:=2;
   Move (Mem [EGAPage:0],Plane2^,PlaneSize);
   Port [$3CE]:=4;
   Port [$3CF]:=3;
   Move (Mem [EGAPage:0],Plane3^,PlaneSize);

{If the picture is larger than my el cheapo EGA can handle, scroll it}

   If Height>EGAHeight then
   Begin

   {Wake up the user}

     Write (^G); {signals whole picture decoded}

   {Scroll offset value to top of image}

     Roll:=0;

   {Then get the scrolling keys. HOME and END move to top & bottom of
    pic. Up & Down arrow move picture in smaller increments. The values
    used here are based on the size difference between a 350 and 480 line
    EGA pic, i.e. 130 scan lines.}

     Repeat
     Ch:=Readkey;

   {We recognize special keys by their being preceded with 0}

     If (Ch=#0) and (Keypressed) then
        Begin
           Ch:=Readkey;
           Case Ch of
                #71: Roll:=0;
                #72: Begin
                     Roll:=Roll-800;
                     If Roll<0 then Roll:=0;
                     End;
                #79: Roll:=10400;
                #80: Begin
                     Roll:=Roll+800;
                     If Roll>10400 then Roll:=10400;
                     End;
           End;
           Scroll;
     End;
   Until (Ch=#27) and (not Keypressed); {ESC gets us out}
   End;

       {Get one key, then exit}

       If Ch<>#27 then    {Do this only if we didn't scroll}
       Begin
          Write (^G);
          Repeat
           Ch:=Readkey;
          Until Ch=#27;
       End;

       Textmode (15);     {Back to text}
       SetPal (NicePal);
       Writeln ('Press space bar to save as a .SCR file, or any other key to continue');
       Ch:=Readkey;
       If Ch=' ' then SaveScreen;
       FreeMem (Plane0,PlaneSize);
       FreeMem (Plane1,PlaneSize);
       FreeMem (Plane2,PlaneSize);
       FreeMem (Plane3,PlaneSize);

   Until Ch=#0;

End.                      {Finis.}
