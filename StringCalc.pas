(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Contains useful classed which implement useful strings operations
  Author: Uskov Boris Sergeevich
  Created: 14.04.2012
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

unit StringCalc;

interface
  uses SysUtils;
type
  TArr=array of String;
  TStringCalculator=class
  public
   class function  Reverse(Source:String):String;static;
   class function RussianLowerCase(Source:Char):Char;static;
   class function RussianUpperCase(Source:char):char;static;
   class function Split(Source:String; Delimeter:char):TArr ;static;
   class Function TrimRight(Str:String):String;static;
   class Function TrimLeft(Str:String):String;static;
   class Function Trim(Str:String):String;static;
  end;

  const
    CyrillicBigAlphavit='¿¡¬√ƒ≈®∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹›ﬁﬂ';
    CyrillicSmallAlphavit='‡·‚„‰Â∏ÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˜¯ˆ˙˚¸˝˛ˇ';
   LatinAlphavit:set of Char= ['A'..'Z'];
implementation

   class function  TStringCalculator.RussianLowerCase(Source:Char):Char;
   begin
     if (Source in LatinAlphavit)  then
     begin
        Result:=LowerCase(Source)[1];
        exit;
     end
     else
        if Pos(Source,CyrillicBigAlphavit)<>0 then
        begin
          Result:=CyrillicSmallAlphavit[Pos(Source,CyrillicBigAlphavit)] ;
          exit;
        end;


              Result:=Source;
   end;

   class function  TStringCalculator.RussianUpperCase(Source:char):char;
   begin
   if (Source in LatinAlphavit)  then
   begin
        Result:=UpperCase(Source)[1];
        exit;
   end
     else
        if Pos(Source,CyrillicSmallAlphavit)<>0 then
        begin
          Result:=CyrillicBigAlphavit[Pos(Source,CyrillicSmallAlphavit )];
          exit;
        end;
              Result:=Source;

   end;

 class function  TStringCalculator.Reverse(Source:String):String;
   var
    I:Word;
    FirstCharacter:Char;
   begin
   FirstCharacter:=Source[1];
    if (Source[1] in LatinAlphavit) or (Pos(Source[1],CyrillicBigAlphavit)<>0) then
      begin
       Source[1]:=RussianLowerCase(Source[1]);
       Source[Length(Source)]:=RussianUpperCase(Source[Length(Source)]);
      end;

     for I := 1 to Length(Source) do
       Result:=Concat(Result,Source[Length(Source)-I+1]);
   end;

class function TStringCalculator.Split(Source:String; Delimeter:char):TArr;
var
Poz,I:Byte;
Begin
 I:=0;
 While  Pos(Delimeter,Source)<>0 Do
 Begin
  poz:=Pos(Delimeter,Source);
  Result[I]:=Copy(Source,1,Poz-1);
  Source:=Copy(Source,Poz+1,Length(Source)-Poz);
  Inc(I);
 End;
// Source[I]:=String(Source);

End;

class Function TStringCalculator.TrimLeft(Str:String):String;
var I:Byte;
const StartPos=1;
Begin
 While (Length(Str)>0)  and (Str[StartPos]=' ') Do
 begin
    Delete(Str,StartPos,1);
  End;
 Result:=Str;
End;

class Function TStringCalculator.TrimRight(Str:String):String;
var FinishPos:Byte;
Begin
FinishPos:=Length(Str);
 While (Length(Str)>0)  and (Str[FinishPos]=' ') Do
 begin
    Delete(Str,FinishPos,1);
    FinishPos:=Length(Str);
  End;
 Result:=Str;
End;

class Function TStringCalculator.Trim(Str:String):String;
Begin
 Result:=TrimRight(TrimLeft(Str));
End;

end.
