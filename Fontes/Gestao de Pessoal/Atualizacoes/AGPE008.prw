/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o  |23/08/2024| Chamado 47047 - Retirada de dados de email do Fernando no fonte.
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipula��o do SX1
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'FWMVCDEF.CH'
#include "protheus.ch"
#include "topconn.ch"

/*
===============================================================================================================================
Programa--------: AGPE008
Autor-----------: Julio de Paula Paz
Data da Criacao-: 04/08/2021
Descri��o-------: Rotina de aprova��o de reajuste de sal�rios. Chamado 37366.
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================*/
User Function AGPE008()
Local _aSizeAut  := MsAdvSize(.T.)
Local _oDlgApr
Local _lRet := .F.
Local _cPerg := "AGPE008"
Local _bGrava 

Private aHeader := {}
Private aRotina := {}   
Private _oGetDB, _oTemp
Private _nSalAnter    := 0
Private _nNovoSal     := 0
Private _nDiferSal    := 0
Private _nPerReajuste := 0

Begin Sequence

   If ! Pergunte(_cPerg,.T.,"Par�metros de Filtro - Aprova��o Reajustes")
      Break 
   EndIf 

   _bGrava := {||Processa( {|| U_AGPE008G() } , 'Aguarde!' , 'Gravando aprova��es...' )}

   //======================================================
   // Configura��es iniciais
   //======================================================
   _aObjects := {} 
   AAdd( _aObjects, { 315,  50, .T., .T. } )
   AAdd( _aObjects, { 100, 100, .T., .T. } )

   _aInfo := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 } 

   _aPosObj := MsObjSize( _aInfo, _aObjects, .T. ) 

 //=================================================================================     
   AADD(aRotina,{"Pesquisar"	,"AxPesqui",0,1})
	AADD(aRotina,{"Visualizar"	,"AxVisual",0,2})
	AADD(aRotina,{"Incluir"		,"AxInclui",0,3})
	AADD(aRotina,{"Alterar"		,"AxAltera",0,4})
	AADD(aRotina,{"Excluir"		,"AxExclui",0,5})
   Inclui := .F.
   Altera := .T.

   //======================================================
   // Roda a query de dados e Cria a Tabela Tempor�ria.
   //======================================================
   
   fwmsgrun( ,{|_oProc| _lRet := U_AGPE008Q(_oProc) } , 'Aguarde...' , 'Efetuando Leitura dos dados...' )
    
   If ! _lRet 
      U_Itmsg("N�o existem dados salariais a serem reajustados.","Aten��o",,1)
      Break 
   EndIf 

   //======================================================
   // Monta o AHeader para o MSGETDB.
   //======================================================
   // aAdd(aHeader,{trim(x3_titulo),x3_campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo, x3_f3,x3_context,	x3_cbox,x3_relacao,x3_when,X3_TRIGGER,	X3_PICTVAR,.F.,.F.})

   Aadd(aHeader,{"Filial"                              ,;   // 1  = X3_TITULO                   
                 "ZGZ_FILIAL"                          ,;   // 2  = X3_CAMPO
                 ""                                    ,;   // 3  = X3_PICTURE                    
                 1                                     ,;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 ""                                     ,;  // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 ""})                                       // 10 = X3_CBOX

   Aadd(aHeader,{"Situa��o"                            ,;   // 1  = X3_TITULO                   
                 "ZGZ_SITUAC"                          ,;   // 2  = X3_CAMPO
                 getsx3cache("ZGZ_SITUAC","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                 1                                     ,;   // 4  = X3_TAMANHO            
                 0                                     ,;   // 5  = X3_DECIMAL
                 "U_AGPE008V()"                        ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                 "C"                                   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                 getsx3cache("ZGZ_SITUAC","X3_CBOX")})      // 10 = X3_CBOX

    Aadd(aHeader,{"Data Reclassifica��o"               ,;   // 1  = X3_TITULO                   
                            "ZGZ_DTOCOR"               ,;   // 2  = X3_CAMPO
                                      ""               ,;   // 3  = X3_PICTURE                    
                                       8               ,;   // 4  = X3_TAMANHO            
                                       0               ,;   // 5  = X3_DECIMAL
                                      ""               ,;   // 6  = X3_VALID                 
                                      ""               ,;   // 7  = X3_USADO
                                     "D"               ,;   // 8  = X3_TIPO                   
                                      ""               ,;   // 9  = X3_CONTEXT
                                      ""})                  // 10 = X3_CBOX

    Aadd(aHeader,{"Matr�cula"                          ,;   // 1  = X3_TITULO                   
                               "ZGZ_MAT"               ,;   // 2  = X3_CAMPO
                   getsx3cache("ZGZ_MAT","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                   getsx3cache("ZGZ_MAT","X3_TAMANHO") ,;   // 4  = X3_TAMANHO            
                   getsx3cache("ZGZ_MAT","X3_DECIMAL") ,;   // 5  = X3_DECIMAL
                   getsx3cache("ZGZ_MAT","X3_VALID")   ,;   // 6  = X3_VALID                 
                                                    "" ,;   // 7  = X3_USADO
                   getsx3cache("ZGZ_MAT","X3_TIPO")    ,;   // 8  = X3_TIPO                   
                                                    "" ,;   // 9  = X3_CONTEXT
                                                    "" })   // 10 = X3_CBOX

    Aadd(aHeader,{"Nome"                               ,;   // 1  = X3_TITULO                   
                  "ZGZ_NOME"                           ,;   // 2  = X3_CAMPO
                  getsx3cache("ZGZ_NOME","X3_PICTURE") ,;   // 3  = X3_PICTURE                    
                  25                                   ,;   // 4  = X3_TAMANHO            
                  0                                    ,;   // 5  = X3_DECIMAL
                  getsx3cache("ZGZ_NOME","X3_VALID")   ,;   // 6  = X3_VALID                 
                                                    "" ,;   // 7  = X3_USADO
                     getsx3cache("ZGZ_NOME","X3_TIPO") ,;   // 8  = X3_TIPO                   
                                                    "" ,;   // 9  = X3_CONTEXT
                                                    "" })   // 10 = X3_CBOX

    Aadd(aHeader,{"Cargo Atual"                        ,;   // 1  = X3_TITULO                   
                  "ZGZ_CARGO"                          ,;   // 2  = X3_CAMPO
                  getsx3cache("ZGZ_CARGO","X3_PICTURE"),;   // 3  = X3_PICTURE                    
                  15                                   ,;   // 4  = X3_TAMANHO            
                  0                                    ,;   // 5  = X3_DECIMAL
                  getsx3cache("ZGZ_CARGO","X3_VALID")  ,;   // 6  = X3_VALID                 
                                                     "",;   // 7  = X3_USADO
                  getsx3cache("ZGZ_CARGO","X3_TIPO")   ,;   // 8  = X3_TIPO                   
                                                     "",;   // 9  = X3_CONTEXT
                                                     ""})   // 10 = X3_CBOX


    Aadd(aHeader,{"Salario Atual"                       ,;  // 1  = X3_TITULO                   
                  "ZGZ_SALARI"                          ,;  // 2  = X3_CAMPO
                  getsx3cache("ZGZ_SALARI","X3_PICTURE"),;  // 3  = X3_PICTURE                    
                  getsx3cache("ZGZ_SALARI","X3_TAMANHO"),;  // 4  = X3_TAMANHO            
                  getsx3cache("ZGZ_SALARI","X3_DECIMAL"),;  // 5  = X3_DECIMAL
                  getsx3cache("ZGZ_SALARI","X3_VALID")  ,;  // 6  = X3_VALID                 
                                                      "",;  // 7  = X3_USADO
                  getsx3cache("ZGZ_SALARI","X3_TIPO")   ,;  // 8  = X3_TIPO                   
                                                      "",;  // 9  = X3_CONTEXT
                                                      ""})  // 10 = X3_CBOX

    Aadd(aHeader,{"Motivo"                              ,;  // 1  = X3_TITULO                   
                  "ZGZ_MOTIVO"                          ,;  // 2  = X3_CAMPO
                  getsx3cache("ZGZ_MOTIVO","X3_PICTURE"),;  // 3  = X3_PICTURE                    
                  15                                    ,;  // 4  = X3_TAMANHO            
                  0                                     ,;  // 5  = X3_DECIMAL
                  getsx3cache("ZGZ_MOTIVO","X3_VALID")  ,;  // 6  = X3_VALID                 
                                                      "",;  // 7  = X3_USADO
                  getsx3cache("ZGZ_MOTIVO","X3_TIPO")   ,;  // 8  = X3_TIPO                   
                                                      "",;  // 9  = X3_CONTEXT
                                                      ""})  // 10 = X3_CBOX
    Aadd(aHeader,{"Tipo"                               ,;    // 1  = X3_TITULO                   
                  "ZGZ_TIPO"                           ,;    // 2  = X3_CAMPO
                  getsx3cache("ZGZ_TIPO","X3_PICTURE") ,;    // 3  = X3_PICTURE                    
                  15                                   ,;  // 4  = X3_TAMANHO            
                  0                                    ,;  // 5  = X3_DECIMAL
                  getsx3cache("ZGZ_TIPO","X3_VALID")   ,;    // 6  = X3_VALID                 
                                                     "",;  // 7  = X3_USADO
                  getsx3cache("ZGZ_TIPO","X3_TIPO")    ,;    // 8  = X3_TIPO                   
                                                     "",;  // 9  = X3_CONTEXT
                  getsx3cache("ZGZ_TIPO","X3_CBOX")    })   // 10 = X3_CBOX

   Aadd(aHeader,{"Tempo Funcao"                         ,;   // 1  = X3_TITULO                   
                  "ZGZ_TMPFUN"                          ,;  // 2  = X3_CAMPO
                  getsx3cache("ZGZ_TMPFUN","X3_PICTURE"),;  // 3  = X3_PICTURE                    
                  getsx3cache("ZGZ_TMPFUN","X3_TAMANHO"),;  // 4  = X3_TAMANHO            
                  0                                     ,;  // 5  = X3_DECIMAL
                  getsx3cache("ZGZ_TMPFUN","X3_VALID")  ,;  // 6  = X3_VALID                 
                                                      "",;  // 7  = X3_USADO
                  getsx3cache("ZGZ_TMPFUN","X3_TIPO")   ,;  // 8  = X3_TIPO                   
                                                      "",;  // 9  = X3_CONTEXT
                                                      ""})  // 10 = X3_CBOX

    Aadd(aHeader,{"Cargo Proposto"                      ,;  // 1  = X3_TITULO                   
                  "ZGZ_DESCAR"                          ,;  // 2  = X3_CAMPO
                  getsx3cache("ZGZ_DESCAR","X3_PICTURE"),;  // 3  = X3_PICTURE                    
                  15                                    ,;  // 4  = X3_TAMANHO            
                  0                                     ,;  // 5  = X3_DECIMAL
                  getsx3cache("ZGZ_DESCAR","X3_VALID")  ,;  // 6  = X3_VALID                 
                                                      "",;  // 7  = X3_USADO
                  getsx3cache("ZGZ_DESCAR","X3_TIPO")   ,;  // 8  = X3_TIPO                   
                                                      "",;  // 9  = X3_CONTEXT
                                                      ""})  // 10 = X3_CBOX

    Aadd(aHeader,{"Salario Novo"                        ,;  // 1  = X3_TITULO                   
                  "ZGZ_SALPRO"                          ,;  // 2  = X3_CAMPO
                  getsx3cache("ZGZ_SALPRO","X3_PICTURE"),;  // 3  = X3_PICTURE                    
                  getsx3cache("ZGZ_SALPRO","X3_TAMANHO"),;  // 4  = X3_TAMANHO            
                  getsx3cache("ZGZ_SALPRO","X3_DECIMAL"),;  // 5  = X3_DECIMAL
                  getsx3cache("ZGZ_SALPRO","X3_VALID")  ,;  // 6  = X3_VALID                 
                                                      "",;  // 7  = X3_USADO
                  getsx3cache("ZGZ_SALPRO","X3_TIPO")   ,;  // 8  = X3_TIPO                   
                                                      "",;  // 9  = X3_CONTEXT
                                                      ""})  // 10 = X3_CBOX

    Aadd(aHeader,{"Diferen�a Salarial"                  ,;  // 1  = X3_TITULO                   
                  "WK_DIFSALA"                          ,;  // 2  = X3_CAMPO
                  "@E 999,999,999.99"                   ,;  // 3  = X3_PICTURE                    
                  12                                    ,;  // 4  = X3_TAMANHO            
                   2                                    ,;  // 5  = X3_DECIMAL
                  ""                                    ,;  // 6  = X3_VALID                 
                  ""                                    ,;  // 7  = X3_USADO
                  "N"                                   ,;  // 8  = X3_TIPO                   
                  ""                                    ,;  // 9  = X3_CONTEXT
                  ""                                    })  // 10 = X3_CBOX


    Aadd(aHeader,{"% de Aumento"                        ,;  // 1  = X3_TITULO                   
                  "WK_PERAUME"                          ,;  // 2  = X3_CAMPO
                  "@E 9,999.9999"                       ,;  // 3  = X3_PICTURE                    
                   9                                    ,;  // 4  = X3_TAMANHO            
                   4                                    ,;  // 5  = X3_DECIMAL
                   ""                                   ,;  // 6  = X3_VALID                 
                   ""                                   ,;  // 7  = X3_USADO
                   ""                                   ,;  // 8  = X3_TIPO                   
                   ""                                   ,;  // 9  = X3_CONTEXT
                   ""                                   })  // 10 = X3_CBOX

Aadd(aHeader,{"Observa��o"                           ,;  // 1  = X3_TITULO                   
                  "ZGZ_OBSAPR"                           ,;  // 2  = X3_CAMPO
                   getsx3cache("ZGZ_OBSAPR","X3_PICTURE"),;  // 3  = X3_PICTURE                    
                   50,;  // 4  = X3_TAMANHO            
                   0,;  // 5  = X3_DECIMAL
                   ""                                    ,;  // 6  = X3_VALID                 
                                                       "",;  // 7  = X3_USADO
                   "C"                                   ,;  // 8  = X3_TIPO                   
                                                       "",;  // 9  = X3_CONTEXT
                   ""                                    })     // 10 = X3_CBOX                 
_nColOBS:=len(aHeader)

    TRBZGZ->(DbGoTop())

    DEFINE MSDIALOG _oDlgApr TITLE "Rotina de Aprova��o de Reajuste Salarial" FROM _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] PIXEL // 00,00 TO 300,400
        @ _aPosObj[2,3]-30, 05  BUTTON _OButtonApr PROMPT "&Aprovar Todos"	 SIZE 50, 012 OF _oDlgApr ACTION (U_AGPE008A("A") ) PIXEL
	     @ _aPosObj[2,3]-30, 60  BUTTON _OButtonRej PROMPT "&Rejeitar Todos" SIZE 50, 012 OF _oDlgApr ACTION ( U_AGPE008A("R")) PIXEL
        @ _aPosObj[2,3]-30, 115 BUTTON _OButtonGrv PROMPT "&Pendente Aprova��o Todos"	SIZE 80, 012 OF _oDlgApr ACTION ( U_AGPE008A("P")) PIXEL
        //@ _aPosObj[2,3]-30, 200 BUTTON _OButtonGrv PROMPT "&Gravar"	       SIZE 50, 012 OF _oDlgApr ACTION ( U_AGPE008G()) PIXEL
        //@ _aPosObj[2,3]-30, 255 BUTTON _OButtonGrv PROMPT "&Sair"	       SIZE 50, 012 OF _oDlgApr ACTION ( _oDlgApr:End() ) PIXEL
        @ _aPosObj[2,3]-30, 200 BUTTON _OButtonGrv PROMPT "&Historico"	    SIZE 50, 012 OF _oDlgApr ACTION ( U_AGPE008H(TRBZGZ->ZGZ_FILIAL,TRBZGZ->ZGZ_MAT)) PIXEL
        //@ _aPosObj[2,3]-30, 255 BUTTON _OButtonGrv PROMPT "&Gravar"	       SIZE 50, 012 OF _oDlgApr ACTION ( U_AGPE008G()) PIXEL
        @ _aPosObj[2,3]-30, 255 BUTTON _OButtonGrv PROMPT "&Gravar"	       SIZE 50, 012 OF _oDlgApr ACTION ( Eval(_bGrava)) PIXEL
        @ _aPosObj[2,3]-30, 310 BUTTON _OButtonGrv PROMPT "&Sair"	       SIZE 50, 012 OF _oDlgApr ACTION ( _oDlgApr:End() ) PIXEL  
        @ _aPosObj[2,3]-35, 370 Say "Total Salario Anterior: " Of _oDlgApr Pixel 
        @ _aPosObj[2,3]-25, 370 Get _nSalAnter Size 50, 10 Picture "@E 9,999,999,999.99" WHEN .F. Of _oDlgApr Pixel
        @ _aPosObj[2,3]-35, 430 Say "Total Novo Salario: " Of _oDlgApr Pixel 
        @ _aPosObj[2,3]-25, 430 Get _nNovoSal Size 50, 10 Picture "@E 9,999,999,999.99" WHEN .F. Of _oDlgApr Pixel
        @ _aPosObj[2,3]-35, 490 Say "Total Diferen�a: " Of _oDlgApr Pixel 
        @ _aPosObj[2,3]-25, 490 Get _nDiferSal Size 50, 10 Picture "@E 9,999,999,999.99" WHEN .F. Of _oDlgApr Pixel
        @ _aPosObj[2,3]-35, 545 Say "% Total de Aumento: " Of _oDlgApr Pixel 
        @ _aPosObj[2,3]-25, 545 Get _nPerReajuste Size 50, 10 Picture "@E 9,999.9999" WHEN .F. Of _oDlgApr Pixel

                //MsGetDB():New ( < nTop>, < nLeft>, < nBottom>       , < nRight>        ,< nOpc>, [ cLinhaOk]  , [ cTudoOk]  ,[ cIniCpos], [ lDelete], [ aAlter]                   , [ nFreeze], [ lEmpty], [ uPar1], < cTRB>  , [ cFieldOk] , [ uPar2], [ lAppend], [ oWnd], [ lDisparos], [ uPar3], [ cDelOk], [ cSuperDel] ) --> oObj
       _oGetDB := MsGetDB():New (0       ,0        , _aPosObj[2,3]-40 , _aPosObj[2,4]    , 4     , "U_AGPE008V" , "U_AGPE008V", ""         , .F.       , {"ZGZ_SITUAC","ZGZ_OBSAPR"} , 0         , .F.       ,        , "TRBZGZ", "U_AGPE008V",         , .F.       , _oDlgApr, .T.        ,         ,""        , "")
       _oGetDB:oBrowse:bAdd := {||.F.} // n�o inclui novos itens MsGetDb()
       _oGetDB:Enable( ) 


       TRBZGZ->(DbGoTop())
       _oGetDB:ForceRefresh ( )

    ACTIVATE MSDIALOG _oDlgApr CENTERED

End Sequence

If SELECT("TRBZGZ") # 0
   _otemp:delete()
EndIf

If Select("QRYZGZ") <> 0
  QRYZGZ->(DbCloseArea())
EndIf

Return Nil 

/*
===============================================================================================================================
Programa--------: AGPE008Q
Autor-----------: Julio de Paula Paz
Data da Criacao-: 04/08/2021
Descri��o-------: Roda a query e grava tabela tempor�ria com os dados a serem aprovados.
Parametros------: Nenhum
Retorno---------: _lRet = .T. = H� dados a serem processados
                          .F. = N�o h� dados a serem processados.
===============================================================================================================================*/
User Function AGPE008Q(_oProc)
Local _cQry 
Local _aStruct := {}
Local _lRet := .F., _nI 
Local _nDifSalario, _nPercAumento

Begin Sequence

   //=================================================================
   // Monta a query de dados
   //=================================================================
   _cQry := "SELECT DISTINCT ZGZ_FILIAL, ZGZ_DTOCOR, ZGZ_MAT, ZGZ_NOME, ZGZ_CARGO, ZGZ_SALARI,ZGZ_CODMOT,ZGZ_MOTIVO, ZGZ_TIPO, ZGZ_TMPFUN, "
   _cQry += " ZGZ_CODCAR, ZGZ_DESCAR, ZGZ_SALPRO, ZGZ_OBSAPR, ZGZ.R_E_C_N_O_ AS ZGZ_RECNO, ZGZ_SITUAC "
   _cQry += " FROM " + RetSqlName("ZGZ") + " ZGZ "
   _cQry += " WHERE ZGZ.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZGZ_SITUAC = 'P' "
   If ! Empty(MV_PAR01)
      _cQry += " AND ZGZ_FILIAL IN " + FormatIn(MV_PAR01,";")
   EndIf 
   
   If Select("QRYZGZ") <> 0
	  QRYZGZ->(DbCloseArea())
   EndIf
	
   TCQUERY _cQry NEW ALIAS "QRYZGZ"	
   TCSetField( "QRYZGZ", "ZGZ_DTOCOR", "D", 8, 0)	

   DbSelectArea("QRYZGZ")
   Count To _nTotRegs

   QRYZGZ->(dbGoTop())

   If _nTotRegs == 0 
      Break 
   EndIf 

   _lRet := .T. 

   //=================================================================
   // Cria a tabela tempor�ria
   //=================================================================
   Aadd(_aStruct,{"WK_OK"      , "C",  2, 0})
   Aadd(_aStruct,{"ZGZ_FILIAL" , "C",  2, 0})
   Aadd(_aStruct,{"ZGZ_DTOCOR" , "D",  8, 0})
   Aadd(_aStruct,{"ZGZ_MAT"    , "C",  6, 0})
   Aadd(_aStruct,{"ZGZ_NOME "  , "C", 70, 0})
   Aadd(_aStruct,{"ZGZ_CARGO " , "C", 30, 0})
   Aadd(_aStruct,{"ZGZ_SALARI" , "N", 12, 2})
   Aadd(_aStruct,{"ZGZ_CODMOT" , "C", 03, 0})
   Aadd(_aStruct,{"ZGZ_MOTIVO" , "C", 30, 0})
   Aadd(_aStruct,{"ZGZ_TIPO"   , "C", 15, 0})
   Aadd(_aStruct,{"ZGZ_TMPFUN" , "C", 20, 0})
   Aadd(_aStruct,{"ZGZ_CODCAR" , "C",  5, 0})
   Aadd(_aStruct,{"ZGZ_DESCAR" , "C", 30, 0}) 
   Aadd(_aStruct,{"ZGZ_SALPRO" , "N", 12, 2})  
   Aadd(_aStruct,{"WK_DIFSALA" , "N", 12, 2})
   Aadd(_aStruct,{"WK_PERAUME" , "N",  9, 4})  
   Aadd(_aStruct,{"ZGZ_OBSAPR" , "C",100, 0}) 
   Aadd(_aStruct,{"ZGZ_RECNO"  , "N", 10, 0})
   Aadd(_aStruct,{"ZGZ_SITUAC" , "C",  1, 0}) 
     
   If Select("TRBZGZ") <> 0
	   TRBZGZ->(DbCloseArea())
   EndIf
   
   //======================================================================
   // Cria arquivo de dados tempor�rio
   //======================================================================
   _oTemp := FWTemporaryTable():New( "TRBZGZ",  _aStruct )
   _otemp:AddIndex( "01", {"ZGZ_DTOCOR","ZGZ_FILIAL","ZGZ_MAT"} ) // Data + Filial + Matricula
   _otemp:AddIndex( "02", {"ZGZ_FILIAL","ZGZ_DTOCOR","ZGZ_MAT"} ) // Filial + Data + Matricula
   _otemp:Create()

   //==========================================================================
   // Grava na tabela tempor�ria os dados da Query e os c�lculos de reajustes.
   //==========================================================================
   _nI := 1

   _nSalAnter    := 0
   _nNovoSal     := 0
   _nDiferSal    := 0
   _nPerReajuste := 0

   Do While ! QRYZGZ->(Eof())
      _oProc:cCaption := ("Gravando tabela tempor�ria..." + AllTrim(Str(_nI,10)) + "/" + AllTrim(Str(_nTotRegs,10)))
      ProcessMessages()
       
      _nDifSalario  := QRYZGZ->ZGZ_SALPRO - QRYZGZ->ZGZ_SALARI
      If QRYZGZ->ZGZ_SALARI == 0
         _nPercAumento := 100
      Else    
         _nPercAumento := _nDifSalario / QRYZGZ->ZGZ_SALARI * 100 
      EndIf 

      _nSalAnter   += QRYZGZ->ZGZ_SALARI
      _nNovoSal    += QRYZGZ->ZGZ_SALPRO
      _nDiferSal   += _nDifSalario

      TRBZGZ->(RecLock("TRBZGZ",.T.))
      TRBZGZ->WK_OK       := "OK"
      TRBZGZ->ZGZ_FILIAL  := QRYZGZ->ZGZ_FILIAL
      TRBZGZ->ZGZ_DTOCOR  := QRYZGZ->ZGZ_DTOCOR 
      TRBZGZ->ZGZ_MAT     := QRYZGZ->ZGZ_MAT
      TRBZGZ->ZGZ_NOME    := QRYZGZ->ZGZ_NOME
      TRBZGZ->ZGZ_CARGO   := QRYZGZ->ZGZ_CARGO
      TRBZGZ->ZGZ_SALARI  := QRYZGZ->ZGZ_SALARI
      TRBZGZ->ZGZ_CODMOT  := QRYZGZ->ZGZ_CODMOT
      TRBZGZ->ZGZ_MOTIVO  := QRYZGZ->ZGZ_MOTIVO
      TRBZGZ->ZGZ_TIPO    := QRYZGZ->ZGZ_TIPO
      TRBZGZ->ZGZ_TMPFUN  := QRYZGZ->ZGZ_TMPFUN
      TRBZGZ->ZGZ_CODCAR  := QRYZGZ->ZGZ_CODCAR
      TRBZGZ->ZGZ_DESCAR  := QRYZGZ->ZGZ_DESCAR
      TRBZGZ->ZGZ_SALPRO  := QRYZGZ->ZGZ_SALPRO
      TRBZGZ->ZGZ_OBSAPR  := QRYZGZ->ZGZ_OBSAPR
      TRBZGZ->ZGZ_RECNO   := QRYZGZ->ZGZ_RECNO
      TRBZGZ->ZGZ_SITUAC  := QRYZGZ->ZGZ_SITUAC
      TRBZGZ->WK_DIFSALA  := _nDifSalario
      TRBZGZ->WK_PERAUME  := _nPercAumento
      TRBZGZ->(MsUnLock())        

      QRYZGZ->(DbSkip())
      
      _nI += 1

   EndDo
   If _nSalAnter == 0
      _nPerReajuste := 100
   Else 
      _nPerReajuste := _nDiferSal / _nSalAnter * 100 
   EndIf 

End Sequence

If Select("QRYZGZ") <> 0
   QRYZGZ->(DbCloseArea())
EndIf

Return _lRet 

/*
===============================================================================================================================
Programa--------: AGPE008A
Autor-----------: Julio de Paula Paz
Data da Criacao-: 04/08/2021
Descri��o-------: Muda o campo situa��o para: "A" = Aprovado
                                              "R" = Reprovado
                                              "P" = Pendente de Aprova��o.
Parametros------: _cOpcao = Op��o de Atualiza��o: "A" = Aprovado
                                                  "R" = Reprovado
                                                  "P" = Pendente de Aprova��o.
Retorno---------: Nenhum
===============================================================================================================================*/
User Function AGPE008A(_cOpcao)

Begin Sequence
   
   TRBZGZ->(DbGoTop())
   Do while ! TRBZGZ->(Eof())

      TRBZGZ->(RecLock("TRBZGZ",.F.))
      TRBZGZ->ZGZ_SITUAC  := _cOpcao
      TRBZGZ->(MsUnLock())    
   
      TRBZGZ->(DbSkip())
   EndDo
   

End Sequence 

TRBZGZ->(DbGoTop())
_oGetDB:ForceRefresh()

Return Nil 

/*
===============================================================================================================================
Programa--------: AGPE008G
Autor-----------: Julio de Paula Paz
Data da Criacao-: 04/08/2021
Descri��o-------: Grava  todas  as altera��es realizadas.
Parametros------: oProc
Retorno---------: Nenhum
===============================================================================================================================*/
User Function AGPE008G() // AGPE008G(oProc)
Local _cCodlgi   := U_RetLgiLga(__cUserID)
Local _cNomeUser := UsrFullName(__cUserID)
Local _aDados    := {}
Local _aTotais   := {0,0,0}
Local _cTitulo   := "Classifica��o de Funcion�rios - Listagem com os Rejustes Que Foram Aprovados / Rejeitados"
Local _nRegAtu   := TRBZGZ->(Recno())
LOCAL _cPict     := "@E 999,999,999,999.99"
Local _lAlterou, _cSituacao, _nPercAumento, _nDifSalario, _cEmailEnv,  F

Begin Sequence
   If ! U_ITMSG("Confirma a grava��o dos reajustes salariais?","Aten��o" , , ,2, 2) 
      Break 
   EndIf
   
   //==========================================================================
   // Obtem o e-mail do aprovador
   //==========================================================================
   _cEmailEnv := ""
   _cMail     := ""
   PswOrder(1)
   PswSeek(__cUserID,.T.)
   aUsuario:=PswRet()	
   _cEmailEnv :=Alltrim(aUsuario[1,14])

   //==========================================================================
   // Efetua a grava��o dos dados.
   //==========================================================================
   SRJ->(DbSetOrder(4)) // RJ_FILIAL+RJ_CARGO
   SRA->(DbSetOrder(1)) // RA_FILIAL+RA_MAT+RA_PROCES
   SQ3->(DbSetOrder(1)) // Q3_FILIAL+Q3_CARGO+Q3_CC

   _nConta:= TRBZGZ->(LASTREC())
   _cTot  :=ALLTRIM(STR(_nConta))
   _nTam  :=LEN(_cTot)
   _nConta:=0

   ProcRegua(_nConta)   

   TRBZGZ->(DbSetOrder(2))
   TRBZGZ->(DbGoTop())

   ZGZ->(DbGoTo(TRBZGZ->ZGZ_RECNO))  
   _cFilQ:=ZGZ->ZGZ_FILIAL
   _aFiliais:= {}

   Do while ! TRBZGZ->(Eof())
      
      ZGZ->(DbGoTo(TRBZGZ->ZGZ_RECNO))  
      _nConta++
      
      IncProc("Gravando: "+ALLTRIM(STRZERO(_nConta,_nTam)) +" de "+ _cTot)

      //======================================================
      // Atualiza cadastro de reajustes.
      //======================================================
      Begin Transaction 
         _lAlterou := .F.
         If AllTrim(ZGZ->ZGZ_SITUAC) <> AllTrim(TRBZGZ->ZGZ_SITUAC) .Or. AllTrim(ZGZ->ZGZ_OBSAPR) <> AllTrim(TRBZGZ->ZGZ_OBSAPR)
            _lAlterou := .T.
         EndIf 

         ZGZ->(RecLock("ZGZ",.F.))
         ZGZ->ZGZ_SITUAC := TRBZGZ->ZGZ_SITUAC    
         ZGZ->ZGZ_OBSAPR := TRBZGZ->ZGZ_OBSAPR
         
         If _lAlterou
            ZGZ->ZGZ_DTALT := Date()
            ZGZ->ZGZ_HRALT := Time()
            ZGZ->ZGZ_USRNMA:= _cNomeUser
         EndIf 

         ZGZ->(MsUnLock())    
     
         //===============================================================
         If TRBZGZ->ZGZ_SITUAC == "A"
            SRJ->(MsSeek(xFilial("SRJ")+TRBZGZ->ZGZ_CODCAR))
            SQ3->(MsSeek(xFilial("SQ3")+TRBZGZ->ZGZ_CODCAR))
            SRA->(MsSeek(TRBZGZ->ZGZ_FILIAL+TRBZGZ->ZGZ_MAT))
            //======================================================
            // Atualiza cadastro de funcion�rios
            //======================================================
            SRA->(RecLock("SRA",.F.))
            SRA->RA_CODFUNC := SRJ->RJ_FUNCAO
            SRA->RA_SALARIO := TRBZGZ->ZGZ_SALPRO
            SRA->RA_CARGO   := TRBZGZ->ZGZ_CODCAR
            SRA->RA_USERLGA := _cCodlgi
            SRA->(MsUnLock())
      
            //======================================================
            // Atualiza Hist�rico Valores Salariais   
            //======================================================
            cSeq:="1"
            SR3->(dbSetOrder(2))
            DO WHILE SR3->(dbSeek(TRBZGZ->ZGZ_FILIAL+TRBZGZ->ZGZ_MAT+DTOS(TRBZGZ->ZGZ_DTOCOR)+cSeq+TRBZGZ->ZGZ_CODMOT+"000"))
               cSeq:=SOMA1(cSeq,1)
            ENDDO
            SR3->(dbSetOrder(1))
            SR3->(RecLock("SR3",.T.))
            SR3->R3_FILIAL := TRBZGZ->ZGZ_FILIAL
            SR3->R3_MAT    := TRBZGZ->ZGZ_MAT
            SR3->R3_DATA   := TRBZGZ->ZGZ_DTOCOR
            SR3->R3_TIPO   := TRBZGZ->ZGZ_CODMOT
            SR3->R3_PD     := "000"  
            SR3->R3_DESCPD := "SALARIO BASE"
            SR3->R3_VALOR  := TRBZGZ->ZGZ_SALPRO
            SR3->R3_SEQ    := cSeq
            SR3->(MsUnLock())

            //======================================================
            // Atualiza Hist�rico Altera��es Salariais
            //======================================================
            cSeq:="1"
            SR7->(dbSetOrder(2))
            DO WHILE SR7->(dbSeek(TRBZGZ->ZGZ_FILIAL+TRBZGZ->ZGZ_MAT+DTOS(TRBZGZ->ZGZ_DTOCOR)+cSeq+TRBZGZ->ZGZ_CODMOT))
               cSeq:=SOMA1(cSeq,1)
            ENDDO
            SR7->(dbSetOrder(1))
            SR7->(RecLock("SR7",.T.))
            SR7->R7_FILIAL  := TRBZGZ->ZGZ_FILIAL
            SR7->R7_MAT     := TRBZGZ->ZGZ_MAT
            SR7->R7_DATA    := TRBZGZ->ZGZ_DTOCOR
            SR7->R7_TIPO    := TRBZGZ->ZGZ_CODMOT
            SR7->R7_FUNCAO  := SRJ->RJ_FUNCAO  
            SR7->R7_DESCFUN := SRJ->RJ_DESC
            SR7->R7_TIPOPGT := SRA->RA_TIPOPGT    
            SR7->R7_CATFUNC := SRA->RA_CATFUNC 
            SR7->R7_USUARIO := _cNomeUser
            SR7->R7_SEQ     := cSeq
            SR7->R7_CARGO   := SQ3->Q3_CARGO 
            SR7->R7_DESCCAR := SQ3->Q3_DESCSUM
            SR7->(MsUnLock())
         EndIf 

      End Transaction 
      //=========================================================================
      // Grava dados para envio de Workflow
      //=========================================================================
      If TRBZGZ->ZGZ_SITUAC == "A" .Or. TRBZGZ->ZGZ_SITUAC == "R"
         _nDifSalario  := TRBZGZ->ZGZ_SALPRO - TRBZGZ->ZGZ_SALARI
         If TRBZGZ->ZGZ_SALARI == 0
            _nPercAumento := 100
         ELSEIf _nDifSalario == 0
            _nPercAumento := 0
         Else    
            _nPercAumento := _nDifSalario / TRBZGZ->ZGZ_SALARI * 100 
         EndIf 
      
         If TRBZGZ->ZGZ_SITUAC == "P"
            _cSituacao := "Pendente"
         ElseIf TRBZGZ->ZGZ_SITUAC == "A"
            _aTotais[1]+=TRBZGZ->ZGZ_SALARI
            _aTotais[2]+=TRBZGZ->ZGZ_SALPRO 
            _aTotais[3]+=_nDifSalario
            _cSituacao := "Aprovado"
         ElseIf TRBZGZ->ZGZ_SITUAC == "R" 
            _cSituacao := "Rejeitado" 
         EndIf 

         Aadd(_aDados,{TRBZGZ->ZGZ_FILIAL,;
                       DTOC(TRBZGZ->ZGZ_DTOCOR),; 
                       TRBZGZ->ZGZ_MAT,;
                       TRBZGZ->ZGZ_NOME,;
                       TRBZGZ->ZGZ_CARGO,;
                       "R$ "+TRANSFORM(TRBZGZ->ZGZ_SALARI,_cPict),;
                       TRBZGZ->ZGZ_CODMOT,;
                       TRBZGZ->ZGZ_MOTIVO,;
                       TRBZGZ->ZGZ_CODCAR,;
                       TRBZGZ->ZGZ_DESCAR,;
                       "R$ "+TRANSFORM(TRBZGZ->ZGZ_SALPRO,_cPict),;
                       "R$ "+TRANSFORM(_nDifSalario,_cPict),;
                       TRANSFORM(_nPercAumento,_cPict)+" %",;
                       _cSituacao,;
                       TRBZGZ->ZGZ_OBSAPR})
         
         //=================================================================================== 
         // Obtem e-mail do usu�rio do RH que incluiu o funcionario a ter reajuste salarial.
         //===================================================================================
            _cUsern := AllTrim(FWLeUserlg("ZGZ->ZGZ_USERGI"))  // Carrega a vari�vel  com o username do criador.
            PswOrder(2)
            If PswSeek(_cUsern,.T.)
               _aUsuario := PswRet()	
               If Len(aUsuario) > 0 .and.  !Alltrim(aUsuario[1,14])  $ _cMail
                  _cMail+= Alltrim(aUsuario[1,14])+";"
               EndIf
            EndIf

      EndIf 


      TRBZGZ->(DbSkip())

      If TRBZGZ->ZGZ_SITUAC == "A" .Or. TRBZGZ->ZGZ_SITUAC == "R" .OR. TRBZGZ->(Eof())
         IF _cFilQ <> TRBZGZ->ZGZ_FILIAL 
            AADD(_aFiliais,{ACLONE(_aDados),ACLONE(_aTotais),_cFilQ,_cMail})
            _aDados  := {}
            _aTotais := {0,0,0}
            _cFilQ   := TRBZGZ->ZGZ_FILIAL
            _cMail   := ""
   
         ENDIF
      ENDIF

   EndDo
   
   //=================================================================================== 
   // Envia o Workflow com as aprova��es e rejei��es
   //===================================================================================
   _cMenEnvio  := ""
   If Len(_aFiliais) > 0 

      FOR F := 1 TO LEN(_aFiliais)
          _cNomeFilial   := _aFiliais[F,3] + "-" + AllTrim( Posicione('SM0',1,cEmpAnt+_aFiliais[F,3],'M0_FILIAL') )
          _cEmailDest    := _aFiliais[F,4] + _cEmailEnv 
          IncProc("Enviando e-mail da Filial: "+_cNomeFilial)

          U_AGPE007E(.F., ,_cEmailDest,_cTitulo+" - "+_cNomeFilial,"Listagem dos Reajustes que Foram Aprovados / Rejeitados",_aFiliais[F,1],_aFiliais[F,2])
      Next
   else
      _cMenEnvio  := "Nao houve envio de e-mails"
   EndIf 

   bBloco:={|| U_ITMsgLog( _cMenEnvio , "ATENCAO") }
   U_Itmsg("Grava��o dos reajustes salariais concluidas com sucesso!","Aten��o","Clique em Ver Detalhes para conferir os envios de e-mail",2,,,,,,bBloco)  

End Sequence

TRBZGZ->(DbGoTo(_nRegAtu)) 

Return Nil 

/*
===============================================================================================================================
Programa--------: AGPE008V
Autor-----------: Julio de Paula Paz
Data da Criacao-: 04/08/2021
Descri��o-------: Grava  todas  as altera��es realizadas.
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================*/
User Function AGPE008V()
Local _lRet := .T.

Begin Sequence
   If !TRBZGZ->ZGZ_SITUAC $ ("P/A/R")
      U_Itmsg("Conte�do do campos situa��o inv�lido."+TRBZGZ->ZGZ_SITUAC,"Aten��o","Informe um conte�do v�lido para o campo situa��o.",1)
      _lRet := .F.
   Endif

End Sequence

Return _lRet 

/*
===============================================================================================================================
Programa----------: AGPE008H
Autor-------------: Julio de Paula Paz
Data da Criacao---: 07/03/2022
Descri��o---------: Exibe Hist�rico de Rejustes do Funcion�rio.
Parametros--------: _cFilial = Filial do Funcion�rio
                    _cMatric = C�digo de Matricula do Funcion�rio.
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGPE008H(_cFilial,_cMatric)
Local _aTitulos, _aDados
Local _nSalBase := 0, _cSalBaser := ""

Begin Sequence 
   
   _aTitulos := {"Filial", "Matricula", "Data Aumento","Tipo Aumento","Desc.Tipo Aumento", "Fun��o",;
                 "Desc.Fun��o", "Tipo Pagto", "Cat.Func","Salario Base"," Usuario", "Sequencia","Cargo","Desc.Cargo"}
   
   SR7->(DbSetOrder(2)) // R7_FILIAL+R7_MAT+DTOS(R7_DATA)+R7_SEQ+R7_TIPO // Matricula + Data Aumento + Sequencia + Tipo Aumento 
   SR7->(MsSeek(_cFilial + _cMatric))
   _aDados := {}
   
   Do While ! SR7->(Eof()) .And. SR7->(R7_FILIAL+R7_MAT) == _cFilial + _cMatric
      
      _nSalBase := Posicione('SR3',1,SR7->(R7_FILIAL+R7_MAT+DTOS(R7_DATA)+R7_TIPO)+"000",'R3_VALOR') // R3_FILIAL+R3_MAT+DTOS(R3_DATA)+R3_TIPO+R3_PD

      _cSalBaser := "R$ " + Transform(_nSalBase,"@E 99,999,999,999.99")


      Aadd(_aDados, {SR7->R7_FILIAL,;                   // FILIAL    
	                  SR7->R7_MAT,;                      // Matricula
	                  SR7->R7_DATA,;                     // Data Aumento
	                  SR7->R7_TIPO,;                     // Tipo Aumento
	                  Tabela("41",SR7->R7_TIPO,.F.),;    // Desc.Tipo Aumento  // SR7->R7_DESCTIP
	                  SR7->R7_FUNCAO,;                   // Fun��o
	                  SR7->R7_DESCFUN,;                  // Desc.Fun��o
	                  SR7->R7_TIPOPGT,;                  // Tipo Pagto
	                  SR7->R7_CATFUNC,;                  // Cat.Func
                     _cSalBaser,;                       // Salario Base //  _nSalBase,;
	                  SR7->R7_USUARIO,;                  // Usuario
	                  SR7->R7_SEQ,;                      // Sequencia
	                  SR7->R7_CARGO,;                    // Cargo
	                  SR7->R7_DESCCAR})                  // Desc.Cargo

      SR7->(DbSkip())
   EndDo 

   If Empty(_aDados)   
      U_Itmsg("N�o existem dados de hist�rico a serem exibidos.","Aten��o",,1)
      Break 
   EndIf    

	U_ITListBox( "Hist�rico de Reajustes Salariais" , _aTitulos , _aDados , .T. , 1 )

End Sequence 

Return Nil 
