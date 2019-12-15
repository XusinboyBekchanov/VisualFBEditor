#include once "sqlite3.bi" 

'#IfDef __FB_64BIT__
'    #libpath "X:\FBОДјюїв\lib\64"
'#Else
'    #libpath "X:\FBОДјюїв\lib\32"
'#endif 
'#Include Once "sqlite3.bi" 
Sub SQLiteClose(ByVal hDB As  sqlite3 Ptr )
    sqlite3_close(hDB)
End Sub

Function SQLiteErrMsg( ByVal hDB As  sqlite3 Ptr  ) As String
 Return  *sqlite3_errmsg(hDB )
End Function

Function SQLiteExec(ByVal db As SQLite3 Ptr ,ByVal sSql As String ) As Integer 'ЦґРРSQL 
    Dim aa As Integer
    sSql=ToUtf8(sSql) & Chr(0)
    Return sqlite3_exec(DB,ByVal StrPtr(sSQL),0,0,0)
'¶ФУЪёьРВЎўЙѕіэЎўІеИлµИІ»РиТЄ»ШµчєЇКэµДІЩЧчЈ¬sqlite3_execµДµЪИэЎўµЪЛДёцІОКэїЙТФґ«Ил0»тХЯNullЎЈ
'НЁіЈЗйїцПВsqlite3_exec·µ»ШSQLITE_OK=0µДЅб№ыЈ¬·З0Ѕб№ыїЙТФНЁ№эerrmsgАґ»сИЎ¶ФУ¦µДґнОуГиКцЎЈ
End Function

Function SQLiteOpen(ByRef DB As SQLite3 Ptr ,ByVal sFileSpec As String,ByVal Password As String="" ) As Integer
'ґтїЄКэѕЭївЈ¬їЙТФУРГЬВл
    Dim szFileSpec As ZString  * 500
    Dim r As Long 
    szFileSpec = ToUtf8(sFileSpec) & Chr(0)
    r = sqlite3_open( @szFileSpec, @DB )

    If r Then 'іцґн
'        ErrStr = *sqlite3_errmsg(DB)
        sqlite3_close(DB ) 
        Return r
    End If
    If Len(Password) Then 'УРГЬВл 
        If sqlite3_key(DB,ByVal StrPtr(Password),Len(Password)) Then
             Print "Open DB Failure " +SQLiteErrMsg(db)
        End If
        If sqlite3_key(db,ByVal StrPtr(Password),Len(Password)) Then
          print SQLiteErrMsg(db)
        End If
    End If

End Function

Function SQLiteReKey(ByVal db as  SQLite3 Ptr ,ByVal newkey as String ) as Integer 'ЙиЦГГЬВлЈ¬Из№ыОЄїХЈ¬ИЎПыГЬВл
   ' Dim aa as Integer 
    RETURN sqlite3_rekey(DB,ByVal StrPtr(newkey),Len(newkey))
 
End Function

Function SQLiteSelect(ByVal db as  SQLite3 Ptr ,ByVal sSql as String ,saRecSetZ() as String ) as Integer
'»сИЎКэѕЭЈ¬·µ»ШРРКэЈ¬Из№ы=<0 ОЄіцґнЈ¬їЙТФ¶Б ErrStr АґїґКІГґґн
'·µ»Ш saRecSetZ() 2О¬КэЧй
'ЦґРРІйСЇµДЅб№ыФЪ saRecSetZЈЁ РР, БРЈ©ПВ±кОЄБг
' Ѕб№ыµЪТ»РР0ОЄБРГыіЖ,ЧЦ¶ОГыЧЦ
' КэѕЭґУ1їЄКјБ¬Рш 
    Dim i as Integer
    Dim lpTable    as ZString Ptr Ptr ' ·µ»Шёш¶Ё±нµДКэЧйЦёХлЈЁґУБРГыіЖЈ©
    Dim nRows      as Integer         ' ·µ»ШµДјЗВјјЇµДРРКэ
    Dim nColumns   as Integer         ' ·µ»ШµДјЗВјјЇµДБРКэ
    Dim lpErrorSz  as ZString Ptr         ' ґнОуРЕПў
    Dim zField     as ZString Ptr   ' ·µ»Шёш¶Ё±нµДЧЦ¶ОЈЁФЪlpTableКэЧйФЄЛШЈ©
    Dim iFields    as Integer         ' ·µ»Ш±н·µ»ШµДЧЦ¶ОКэ
    Dim iRow       as Integer
    Dim iCol       as Integer
    Dim iResult    as Integer         ' РР»тґнОуµДКэБїУЙОТєЇКэ·µ»Ш
    ''' ЦґРРІйСЇµДЅб№ыФЪ saRecSetZЈЁ RowNo&, ColNo&Ј©ПВ±кОЄБг
    ''' Ѕб№ыµЪТ»РР0ОЄБРГыіЖ
    ''' КэѕЭґУ1їЄКјБ¬Рш

   sSql=ToUtf8( sSql) & Chr(0)
'Declare Function sqlite3_get_table(ByVal db as sqlite3 Ptr, ByVal zSql as Const ZString Ptr, 
'ByVal pazResult as ZString Ptr Ptr Ptr, ByVal pnRow as Long Ptr, ByVal pnColumn as Long Ptr, ByVal pzErrmsg as ZString Ptr Ptr) as Long
'µЪ2ёцІОКэКЗ sql УпѕдЈ¬ёъ sqlite3_exec АпµД sql КЗТ»СщµДЎЈКЗТ»ёцєЬЖХНЁµДТФ/0ЅбОІµДchar *ЧЦ·ыґ®ЎЈ
'µЪ3ёцІОКэКЗІйСЇЅб№ыЈ¬ЛьТАИ»Т»О¬КэЧйЈЁІ»ТЄТФОЄКЗ¶юО¬КэЧйЈ¬ёьІ»ТЄТФОЄКЗИэО¬КэЧйЈ©ЎЈ
'ЛьДЪґжІјѕЦКЗЈєµЪТ»РРКЗЧЦ¶ОГыіЖЈ¬єуГжКЗЅфЅУЧЕКЗГїёцЧЦ¶ОµДЦµЎЈПВГжУГАэЧУАґЛµКВЎЈ 
'µЪ4ёцІОКэКЗІйСЇіц¶аЙЩМхјЗВјЈЁјґІйіц¶аЙЩРРЈ©ЎЈ
'µЪ5ёцІОКэКЗ¶аЙЩёцЧЦ¶ОЈЁ¶аЙЩБРЈ©ЎЈ
'µЪ6ёцІОКэКЗґнОуРЕПўЈ¬ёъЗ°ГжТ»СщЈ¬ХвАпІ»¶аЛµБЛЎЈ 
    If sqlite3_get_table(DB, ByVal StrPtr(sSQL), @lpTable, @nRows, @nColumns, @lpErrorSz) = 0 Then 'іЙ№¦   
        If nRows = 0 Then 
           'declare sub sqlite3_free_table(byval result as zstring ptr ptr)
           sqlite3_free_table lpTable  'І»ВЫКэѕЭївІйСЇКЗ·сіЙ№¦Ј¬¶јКН·Е char** ІйСЇЅб№ы
           RETURN  -1
        end if
        iFields = ((nRows+1) * nColumns)-1
        ReDim saRecSetZ(nRows, nColumns-1)
        For i = 0 To iFields
'            zField = *lpTable[i]
            saRecSetZ(iRow, iCol) = *lpTable[i]
            iCol +=1 
            If iCol = nColumns Then iCol = 0
            If (i+1) Mod nColumns = 0 Then iRow +=1
        Next 
    Else
        iResult = -1  
'        ErrStr = *sqlite3_errmsg(DB)
         sqlite3_free_table lpTable  'І»ВЫКэѕЭївІйСЇКЗ·сіЙ№¦Ј¬¶јКН·Е char** ІйСЇЅб№ы
        RETURN  -1
    End If 
    RETURN  nRows
End Function
      



