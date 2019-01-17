(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    Библиотека классов работы со списками
                    Разработчик: Усков Б. С.
                    Дата разработки: 14.04.2012
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
unit ListClasses;

interface
uses Classes,SysUtils;
type
//Обыкновенный массив
TArray=array of Variant;
//Агрегатная функция
TAgregate=function(Value1,Value2:Variant):Variant;
//Обрабатывающая функция
TProcess=function(Value:Variant):Variant;
//Элемент списка
PArrayListElem=^TArrayListElem;
TArrayListElem = record
  Data:Variant;
  Next:PArrayListElem;
  Prev:PArrayListElem;
end;

PArrayList=^ArrayList;

//Баозовый класс всех коллекций
TCollection = class
private
   function GetCount:LongWord;virtual;abstract;
public
   procedure Add(NewItem:Variant);virtual;abstract;
   procedure AddRange(Arr:TArray);overload;virtual;abstract;
   procedure AddRange(Arr:TStrings);overload;virtual;abstract;
   procedure RemoveAt(index:integer);virtual;abstract;
   procedure Remove(Value:Variant);virtual;abstract;
   function  Get(index:integer):Variant;virtual;abstract;
   function  GetElementIndex(Value:Variant):Integer;virtual;abstract;
   function  Contained(Value:Variant):LongBool;virtual;abstract;
   procedure Clear;virtual;abstract;
   procedure Sort;virtual;abstract;
   function GetArray:TArray;virtual;abstract;

   property Count:LongWord read GetCount;
end;

TCommpnListClass = class(TCollection)
  private
   Head:PArrayListElem;
   Tail:PArrayListElem;
   innerCurrent:PArrayListElem;
   procedure SetVal(index:integer;NewValue:Variant);virtual;abstract;
   function GetCurrent:Variant;virtual;
  public
   procedure AddRange(Arr:TArray);reintroduce;overload;virtual;
   procedure AddRange(Arr:TStrings);reintroduce;overload;virtual;
   function  Contained(Value:Variant):LongBool;override;
   procedure Remove(Value:Variant);override;

   procedure Processing(process:TProcess);virtual;
   function  Agregate(InitialVal:Variant;agregatefunc:TAgregate):Variant;virtual;

   procedure Clear;override;

   property Items[Index:integer]:Variant read Get write SetVal;default;
   property Current:Variant read GetCurrent;

   constructor Create;
   destructor Destroy;
end;

//Линейный однонаправленный список
ArrayList=class(TCommpnListClass)
  private
   function GetCount:LongWord;override;
   procedure SetVal(index:integer;NewValue:Variant);override;
  public
   procedure Add(NewItem:Variant);override;
   function  Get(index:integer):Variant;override;

   procedure RemoveAt(index:integer);override;
   function  GetElementIndex(Value:Variant):Integer;override;
   procedure Sort;override;

   function MoveSucc:WordBool;
   function MoveLast:WordBool;

   function GetArray:TArray;override;

   constructor Create;
end;

//Линейный двунаправленный список
TwoLinksArrayList=class(TCommpnListClass)
  private
   function GetCount:LongWord;override;
   procedure SetVal(index:integer;NewValue:Variant);override;
  public
   procedure Add(NewItem:Variant);override;
   function  Get(index:integer):Variant;override;

   procedure RemoveAt(index:integer);override;
   function  GetElementIndex(Value:Variant):Integer;override;

   function MoveSucc:WordBool;
   function MoveNext:WordBool;

   procedure Sort;override;

   function GetArray:TArray;override;
   function GetArrayReverse:TArray;

   constructor Create;
end;

implementation
//-----------------------------Базовый класс списков----------------------------
constructor TCommpnListClass.Create;
begin
   Head:=nil;
   Tail:=nil;
   innerCurrent:=nil;
end;

//Возвращает текущий элемент списка
function TCommpnListClass.GetCurrent:Variant;
begin
 if Self.innerCurrent<>nil then
  Result:=Self.innerCurrent^.Data;
end;

//Удалить элемент со значением Value
procedure TCommpnListClass.Remove(Value:Variant);
var
 Temp:PArrayListElem;
 Index:LongWord;
begin
   Index:=Self.GetElementIndex(Value);
   if Index<>-1 then
      Self.RemoveAt(Index);
end;

//Добавить в список целый массив
procedure TCommpnListClass.AddRange(Arr:TArray);
var
 I:Integer;
begin
 for I := Low(Arr) to High(Arr) do
   Self.Add(Arr[I]);

end;

//Добавить в список целый массив
procedure TCommpnListClass.AddRange(Arr:TStrings);
var
 I:Integer;
begin
 for I := 0 to Arr.Count-1 do
   Self.Add(Arr[I]);

end;

procedure TCommpnListClass.Clear;
 var
 I:Integer;
begin
while Self.Head<>nil do
   Self.RemoveAt(0);

end;

//Деструктор для списочных классов
destructor TCommpnListClass.Destroy;
 var
 I:Integer;
begin
     inherited Destroy;
     Self.Clear;
     Head:=nil;
     Tail:=nil;
end;

//Проверка, включает ли список элемент со значением Value
function TCommpnListClass.Contained(Value:Variant):LongBool;
begin
  if GetElementIndex(Value)<>-1 then
    Result:=true
  else
    Result:=false;
end;

//Выполняет над всеми элементами списка операцию process
procedure TCommpnListClass.Processing(process:TProcess);
var
 I:Integer;
 Temp:Variant;
begin
 for I:=0 to Self.Count -1 do
   begin
    Temp:=Self[I];
    Self[I]:=process(Temp);
   end;
end;

//Выполняет агрегатную функцию agregatefunc для списка
function TCommpnListClass.Agregate(InitialVal:Variant;agregatefunc:TAgregate):Variant;
var
 I:Integer;
begin
   Result:=InitialVal;
    for I:=0 to Self.Count -1 do
      Result:=agregatefunc(Result,Self[I]);
end;

//-----------------------Односвязанный линейниы список--------------------------
constructor ArrayList.Create;
begin
  inherited Create;

end;

//Перейти к предыдущему элементу. Если он есть возвращает true;
//Если функция ни разу не вызывалась будет возвращен первый элемент
function ArrayList.MoveSucc:WordBool;
var
  Temp:PArrayListElem;
begin
Temp:=Head;
   if innerCurrent=nil then
    begin
     if Temp<>nil then
      innerCurrent:=Temp;
      Result:=true;
    end
   else
    if innerCurrent^.Next<>nil then
     begin
      innerCurrent:=innerCurrent^.Next;
      Result:=true;
     end
    else
      Result:=false;
end;

//Перейти к последнему элементу списка
function ArrayList.MoveLast:WordBool;
begin

if Head<>nil then
    begin
      innerCurrent:=Head;
      Result:=true;
    end
else
      Result:=false;
end;

//Добвить новый элемент в список
procedure ArrayList.Add(NewItem:Variant);
var
 Temp:PArrayListElem;
begin
    if Head=nil then
       begin
          New(Head);
          Head^.Data:=NewItem;
          Head^.Next:=nil;
       end
    else
       begin
         New(Temp);
         Temp^.Data:=NewItem;
         Temp^.Next:=Head;
         Head:=Temp;
       end;
end;

function ArrayList.GetCount:LongWord;
var
    Temp:PArrayListElem;
    Count:LongWord;
begin
Count:=0;
Temp:=Head;
    while Temp<>nil do
      begin
        Inc(Count);
        Temp:=Temp^.Next;
      end;
      Result:=Count;
end;

//Получить элемент под номером index
function ArrayList.Get(index:integer):Variant;
var
 Temp:PArrayListElem;
 Counter:LongWord;
begin
Counter:=0;
      if index>self.Count then
        begin
          EListError.Create('Out of range.');
        end
      else
        begin
        Temp:=Head;
           while Counter<>(Self.Count-index-1) do
              begin
                Temp:=Temp^.Next;
                inc(Counter);
              end;
        end;

        Result:=Temp^.Data;

end;

//Получить из списка массив
function ArrayList.GetArray:TArray;
begin
if Self.MoveLast then
  begin
    SetLength(Result,1);
    Result[0]:=Self.Current;

       while Self.MoveSucc do
        begin
          SetLength(Result,Length(Result)+1);
          Result[Length(Result)-1]:=Self.Current;
        end;
  end;
end;

//Установить значение для элемента под номером index
procedure ArrayList.SetVal(index:integer;NewValue:Variant);
var
 Temp:PArrayListElem;
 Counter:LongWord;
begin
Counter:=0;
      if index>self.Count then
        begin
          EListError.Create('Out of range.');
        end
      else
        begin
        Temp:=Head;
           while Counter<>Self.Count - index-1 do
              begin
                Temp:=Temp^.Next;
                inc(Counter);
              end;
        end;

        Temp^.Data:=NewValue;

end;

//Удалить элемент под номером index
procedure ArrayList.RemoveAt(index:integer);
var
 Temp,Tmp:PArrayListElem;
 Counter:LongWord;
begin
      if index>self.Count then
        begin
          EListError.Create('Out of range.');
        end
      else
        begin

            Temp:=Head;
            if not (Self.Count -1 = index) then
              begin
                  Counter:=0;
                     while Counter+1<>(Self.Count-index-1)  do
                        begin
                          Temp:=Temp^.Next;
                          inc(Counter);
                        end;

                   Tmp:=Temp^.Next;
                   Temp^.Next:=Temp^.Next^.Next;
                   Dispose(Tmp);
               end
           else
              begin  //Удаление головы списка
                 Tmp:=Head;
                 Head:=Head^.Next;
                 Dispose(Tmp);

              end;
        end;
end;

//Вернуть индекс элемента
//-1 если такого элемента нет
function ArrayList.GetElementIndex(Value:Variant):Integer;
var
 Temp:PArrayListElem;
 Counter:LongWord;
begin
Counter:=0;
        Temp:=Head;
           while (Temp<>nil) and (Temp^.Data<>Value) do
              begin
                Temp:=Temp^.Next;
                inc(Counter);
              end;

if Temp=nil then
   begin
        Result:=-1;
        exit;
   end;

if Temp^.Data=Value then
    Result:=Self.Count - Counter -1
else
    Result:=-1;

end;

//Сортировка списка
procedure ArrayList.Sort;
var
 Temp1,Temp2:PArrayListElem;
begin

end;

//--------------------------Двусвязеый линейный список--------------------------
//В разработке
constructor TwoLinksArrayList.Create;
begin
  inherited Create;

end;

//Перейти к предыдущему элементу. Если он есть возвращает true;
//Если функция ни разу не вызывалась будет возвращен первый элемент
function TwoLinksArrayList.MoveSucc:WordBool;
var
  Temp:PArrayListElem;
begin
Temp:=Head;
   if innerCurrent=nil then
    begin
     if Temp<>nil then
      innerCurrent:=Temp;
      Result:=true;
    end
   else
    if innerCurrent^.Next<>nil then
     begin
      innerCurrent:=innerCurrent^.Next;
      Result:=true;
     end
    else
      Result:=false;

end;

//Перейти к предыдущему элементу. Если он есть возвращает true;
//Если функция ни разу не вызывалась будет возвращен первый элемент
function TwoLinksArrayList.MoveNext:WordBool;
var
  Temp:PArrayListElem;
begin
Temp:=Tail;
   if innerCurrent=nil then
    begin
     if Temp<>nil then
      innerCurrent:=Temp;
      Result:=true;
    end
   else
    if innerCurrent^.Prev<>nil then
     begin
      innerCurrent:=innerCurrent^.Prev;
      Result:=true;
     end
    else
      Result:=false;

end;


//Добвить новый элемент в список
procedure TwoLinksArrayList.Add(NewItem:Variant);
var
 Temp:PArrayListElem;
begin
    if Head=nil then
       begin
          New(Head);
          Head^.Data:=NewItem;
          Head^.Next:=nil;
          Head^.Prev:=nil;
          Tail:=Head;
       end
    else
       begin

         New(Temp);
         Temp^.Data:=NewItem;
         Temp^.Next:=Head;

         Head^.Prev:=Temp;

         Head:=Temp;

         while Self.MoveSucc do;
           Tail:=Self.innerCurrent;
           Self.innerCurrent:=nil;

       end;
end;

function TwoLinksArrayList.GetCount:LongWord;
var
    Temp:PArrayListElem;
    Count:LongWord;
begin
Count:=0;
Temp:=Head;
    while Temp<>nil do
      begin
        Inc(Count);
        Temp:=Temp^.Next;
      end;
      Result:=Count;
end;

//Получить элемент под номером index
function TwoLinksArrayList.Get(index:integer):Variant;
var
 Temp:PArrayListElem;
 Counter:LongWord;
begin
Counter:=0;
      if index>self.Count then
        begin
          EListError.Create('Out of range.');
        end
      else
        begin
        Temp:=Head;
           while Counter<>(Self.Count-index-1) do
              begin
                Temp:=Temp^.Next;
                inc(Counter);
              end;
        end;

        Result:=Temp^.Data;

end;

//Установить значение для элемента под номером index
procedure TwoLinksArrayList.SetVal(index:integer;NewValue:Variant);
var
 Temp:PArrayListElem;
 Counter:LongWord;
begin
Counter:=0;
      if index>self.Count then
        begin
          EListError.Create('Out of range.');
        end
      else
        begin
        Temp:=Head;
           while Counter<>Self.Count - index-1 do
              begin
                Temp:=Temp^.Next;
                inc(Counter);
              end;
        end;

        Temp^.Data:=NewValue;

end;

//Удалить элемент под номером index
procedure TwoLinksArrayList.RemoveAt(index:integer);
var
 Temp,Tmp:PArrayListElem;
 Counter:LongWord;
begin
      if index>self.Count then
        begin
          EListError.Create('Out of range.');
        end
      else
        begin

            Temp:=Head;
            if not (Self.Count -1 = index) then
              begin
                  Counter:=0;
                     while Counter+1<>(Self.Count-index-1)  do
                        begin
                          Temp:=Temp^.Next;
                          inc(Counter);
                        end;

                   Tmp:=Temp^.Next;

                   Tmp^.Next^.Prev:=Tmp^.Prev;
                   Tmp^.Prev^.Next:=Tmp^.Next;

                   Dispose(Tmp);
               end
           else
              begin  //Удаление головы списка
                 Tmp:=Head;
                 Head^.Next^.Prev:=nil;
                 Head:=Head^.Next;
                 Dispose(Tmp);
              end;
        end;
end;

//Вернуть индекс элемента
//-1 если такого элемента нет
function TwoLinksArrayList.GetElementIndex(Value:Variant):Integer;
var
 Temp:PArrayListElem;
 Counter:LongWord;
begin
Counter:=0;
        Temp:=Head;
           while (Temp<>nil) and (Temp^.Data<>Value) do
              begin
                Temp:=Temp^.Next;
                inc(Counter);
              end;

if Temp=nil then
   begin
        Result:=-1;
        exit;
   end;

if Temp^.Data=Value then
    Result:=Self.Count - Counter -1
else
    Result:=-1;

end;

//Сортировка
procedure TwoLinksArrayList.Sort;
begin

end;

//Получить из списка массив
function TwoLinksArrayList.GetArray:TArray;
begin
SetLength(Result,0);
   while Self.MoveNext do
    begin
      SetLength(Result,Length(Result)+1);
      Result[Length(Result)-1]:=Self.Current;
    end;
end;

//Получить из списка массив в обратной последовательности
function TwoLinksArrayList.GetArrayReverse:TArray;
begin
SetLength(Result,0);
   while Self.MoveSucc do
    begin
      SetLength(Result,Length(Result)+1);
      Result[Length(Result)-1]:=Self.Current;
    end;
end;

end.
