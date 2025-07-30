/*
===========================================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===========================================================================================================================================
 Autor            |   Data     |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 02/03/2023 | Incluir na rotina uma nova op��o de filtro por c�digo de vendedor. Chamado 42489. 
===========================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: ROMS069
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/05/2022
===============================================================================================================================
Descri��o---------: Painel de Comiss�o Gerencial. Chamado 39101.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ROMS069()
Local _lRet := .F.
Local _aStrucZBK
Local _aCmpZBK := {}
Local _aSizeAut  := MsAdvSize(.T.)
Local _bOk, _bCancel , _cTitulo
Local _lInverte := .F.
Local _oDlgP 
Local _nLinha, _nColuna 

Private _oMarkZBK, _cMarcaZBK := GetMark() 
Private aHeader := {} , aCols := {}

Private _cPeriodo  := Space(6) 
Private _cCodGNac  := Space(6)
Private _cCodGer   := Space(6)
Private _cCodCoord := Space(6)
Private _cCodSup   := Space(6)
Private _cCodVen   := Space(6)
Private _otemp1, _otemp2, _otemp3, _otemp4, _otemp5
Private _aItalac_F3 := {}
Private _cSelectSA3, _bCondSA3

Begin Sequence
   _cSelectSA3 := "SELECT DISTINCT A3_COD, A3_NOME FROM "+RETSQLNAME("SA3")+" SA3 WHERE SA3.D_E_L_E_T_ <> '*' AND A3_I_TIPV = 'V' ORDER BY A3_COD " 
   _bCondSA3   := NIL
   Aadd(_aItalac_F3,{"_cCodVen",_cSelectSA3,{|Tab| (Tab)->A3_COD}, {|Tab| (Tab)->A3_NOME } ,_bCondSA3 ,"Vendedores",,,1,.F.        ,       , } )

   //============================================================================
   //Montagem do aheader                                                        
   //============================================================================
   aHeader := {}
   FillGetDados(1,"ZBK",1,,,{||.T.},,,,,,.T.)
   
   //                          1                    2               3              4               5                6             7        8              9                 10 
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
   
   //================================================================================
   // Monta as colunas do MSSELECT para a tabela tempor�ria TRBZBK 
   //================================================================================
   //Aadd( _aCmpZBK , { "WK_OK"		,    , "Marca"                                          ,"@!"})
   Aadd( _aCmpZBK , { "ZBK_VEND"		,    , "C�digo"          ,"@!"})
   Aadd( _aCmpZBK , { "ZBK_NOMVEN"	,    , "Nome"            ,"@!"})
   Aadd( _aCmpZBK , { "ZBK_COMVEN"	,    , "Valor Comiss�o"  ,"@E 999,999,999.99"})

   //================================================================================
   // Cria as estruturas das tabelas tempor�rias
   //================================================================================
   _aStrucZBK := {}
   Aadd( _aStrucZBK , { "ZBK_VEND"		, "C"   , 6   ,0})
   Aadd( _aStrucZBK , { "ZBK_NOMVEN"	, "C"   , 60  ,0})
   Aadd( _aStrucZBK , { "ZBK_COMVEN"	, "N"   , 16  ,2})
   Aadd( _aStrucZBK , { "ZBK_SUPERV"	, "C"   , 6   ,0})
   Aadd( _aStrucZBK , { "ZBK_COORDE"	, "C"   , 6   ,0})
   Aadd( _aStrucZBK , { "ZBK_GERENT"	, "C"   , 6   ,0})
   Aadd( _aStrucZBK , { "ZBK_GERNAC"	, "C"   , 6   ,0})

   //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRBZBK1") > 0
      TRBZBK1->( DBCloseArea() )
   EndIf

   //================================================================================
   // Abre o arquivo TRBZBK1 criado dentro do protheus. Gerente Nacional
   //================================================================================
   _otemp1 := FWTemporaryTable():New( "TRBZBK1",  _aStrucZBK )
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp1:AddIndex( "01", {"ZBK_VEND"}   )
   _otemp1:AddIndex( "02", {"ZBK_SUPERV"} )
   _otemp1:AddIndex( "03", {"ZBK_COORDE"} )
   _otemp1:AddIndex( "04", {"ZBK_GERENT"} )
   _otemp1:AddIndex( "05", {"ZBK_GERNAC"} )

   _otemp1:Create()   

   //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRBZBK2") > 0
      TRBZBK2->( DBCloseArea() )
   EndIf

   //================================================================================
   // Abre o arquivo TRBZBK2 criado dentro do protheus. Gerente.
   //================================================================================
   _otemp2 := FWTemporaryTable():New( "TRBZBK2",  _aStrucZBK )
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp2:AddIndex( "01", {"ZBK_VEND"} )
   _otemp2:AddIndex( "02", {"ZBK_SUPERV"} )
   _otemp2:AddIndex( "03", {"ZBK_COORDE"} )
   _otemp2:AddIndex( "04", {"ZBK_GERENT"} )
   _otemp2:AddIndex( "05", {"ZBK_GERNAC"} )

   _otemp2:Create()   

   //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRBZBK3") > 0
      TRBZBK3->( DBCloseArea() )
   EndIf

   //================================================================================
   // Abre o arquivo TRBZBK3 criado dentro do protheus. Coordenador.
   //================================================================================
   _otemp3 := FWTemporaryTable():New( "TRBZBK3",  _aStrucZBK )
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp3:AddIndex( "01", {"ZBK_VEND"} )
   _otemp3:AddIndex( "02", {"ZBK_SUPERV"} )
   _otemp3:AddIndex( "03", {"ZBK_COORDE"} )
   _otemp3:AddIndex( "04", {"ZBK_GERENT"} )
   _otemp3:AddIndex( "05", {"ZBK_GERNAC"} )

   _otemp3:Create()   

   //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRBZBK4") > 0
      TRBZBK4->( DBCloseArea() )
   EndIf

   //================================================================================
   // Abre o arquivo TRBZBK2 criado dentro do protheus. Supervisor
   //================================================================================
   _otemp4 := FWTemporaryTable():New( "TRBZBK4",  _aStrucZBK )
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp4:AddIndex( "01", {"ZBK_VEND"}   )
   _otemp4:AddIndex( "02", {"ZBK_SUPERV"} )
   _otemp4:AddIndex( "03", {"ZBK_COORDE"} )
   _otemp4:AddIndex( "04", {"ZBK_GERENT"} )
   _otemp4:AddIndex( "05", {"ZBK_GERNAC"} )

   _otemp4:Create()   

   //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRBZBK5") > 0
      TRBZBK5->( DBCloseArea() )
   EndIf

   //================================================================================
   // Abre o arquivo TRBZBK5 criado dentro do protheus. Representantes.
   //================================================================================
   _otemp5 := FWTemporaryTable():New( "TRBZBK5",  _aStrucZBK )
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp5:AddIndex( "01", {"ZBK_VEND"}   )
   _otemp5:AddIndex( "02", {"ZBK_SUPERV"} )
   _otemp5:AddIndex( "03", {"ZBK_COORDE"} )
   _otemp5:AddIndex( "04", {"ZBK_GERENT"} )
   _otemp5:AddIndex( "05", {"ZBK_GERNAC"} )

   _otemp5:Create()   

   //================================================================================
   // Carrega os dados da tabela ZBK
   //================================================================================
   _bOk := {|| _lRet := .T., _oDlgInt:End()}
   _bCancel := {|| _lRet := .F., _oDlgInt:End()}
                                           
   _cTitulo := "Painel Gerencial Comiss�es"
   //================================================================================
   // Monta a tela de dados com MSSELECT.
   //================================================================================      
   _nPosLin := _aSizeAut[4] / 5
   _nPosLinA :=_aSizeAut[4] - (_nPosLin * 4) 
   _nPosLinB :=_aSizeAut[4] - (_nPosLin * 3) 
   _nPosLinC :=_aSizeAut[4] - (_nPosLin * 2) 
   _nPosLinD :=_aSizeAut[4] - (_nPosLin * 1) 
   
   _nColuna := 560

   Define MsDialog _oDlgP Title _cTitulo From _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] PIXEL  
      
      @ 02, 05 To 35 , 550 PIXEL 

      _nLinha := 05
      @ _nLinha     , 10 Say   "Per�odo (MMAAAA)" Pixel Size  060,012 Of _oDlgP
      @ _nLinha + 10, 10 MSGet _cPeriodo Picture "@R 99/9999" Pixel Size  040,012 Valid (U_ROMS069V("PERIODO")) Of _oDlgP

      @ _nLinha     , 70 Say   "Gerente Nacional" Pixel Size  060,012 Of _oDlgP
      @ _nLinha + 10, 70 MSGet _cCodGNac Pixel Size  040,012 F3 "SA3_04" Valid (U_ROMS069V("GERENTE_NACIONAL")) Of _oDlgP

      @ _nLinha     , 130 Say   "Gerente" Pixel Size  060,012 Of _oDlgP
      @ _nLinha + 10, 130 MSGet _cCodGer  Pixel Size  040,012 F3 "SA3_02" Valid (U_ROMS069V("GERENTE")) Of _oDlgP

      @ _nLinha     , 190 Say   "Coordenador" Pixel Size  060,012 Of _oDlgP
      @ _nLinha + 10, 190 MSGet _cCodCoord    Pixel Size  040,012 F3 "SA3_01" Valid (U_ROMS069V("COORDENADOR")) Of _oDlgP

      @ _nLinha     , 250 Say   "Supervisor" Pixel Size  060,012 Of _oDlgP
      @ _nLinha + 10, 250 MSGet _cCodSup     Pixel Size  040,012 F3 "SA3_03" Valid (U_ROMS069V("SUPERVISOR")) Of _oDlgP

      @ _nLinha     , 310 Say   "Vendedor"   Pixel Size  060,012 Of _oDlgP
      @ _nLinha + 10, 310 MSGet _cCodVen     Pixel Size  040,012 F3 "F3ITLC" Valid (U_ROMS069V("VENDEDOR")) Of _oDlgP
      //@ _nLinha + 10, 310 MSGet _cCodVen     Pixel Size  040,012 F3 "SA3BLQ" Valid (U_ROMS069V("VENDEDOR")) Of _oDlgP

      @ _nLinha + 10, 370  BUTTON _OBtnProce PROMPT "&Processar"  SIZE 50, 012 OF _oDlgP ACTION ( If(U_ROMS069V("PROCESSAR"),U_ROMS069P(),)) PIXEL
      @ _nLinha + 10, 430  BUTTON _OBtnProce PROMPT "&Gera Excel" SIZE 50, 012 OF _oDlgP ACTION ( If(U_ROMS069V("GERA_EXCEL"),U_ROMS069E(),)) PIXEL
      @ _nLinha + 10, 490  BUTTON _OBtnSair  PROMPT "&Sair"	      SIZE 50, 012 OF _oDlgP ACTION ( _oDlgP:End() ) PIXEL

      _nLinha += 30
      @ _nLinha     , 10 Say   "Gerente Nacional" Pixel Size  060,012 Of _oDlgP

      _nLinha += 10
      _oMarkZBKA := MsSelect():New("TRBZBK1","WK_OK","",_aCmpZBK,@_lInverte, @_cMarcaZBK,{_nLinha, 5, _nLinha+35 /*_aSizeAut[4]*/ , _nColuna /*_aSizeAut[3]-250*/}) 
 
      _nLinha += 35 
      @ _nLinha     , 10 Say   "Gerente" Pixel Size  060,012 Of _oDlgP
      
      _nLinha += 10
      _oMarkZBKB := MsSelect():New("TRBZBK2","WK_OK","",_aCmpZBK,@_lInverte, @_cMarcaZBK,{_nLinha, 5, _nLinha + 50 /*_aSizeAut[4]*/ , _nColuna /*_aSizeAut[3]-250*/})
 
      _nLinha += 50
      @ _nLinha     , 10 Say   "Coordenador" Pixel Size  060,012 Of _oDlgP

      _nLinha += 10
      _oMarkZBKC := MsSelect():New("TRBZBK3","WK_OK","",_aCmpZBK,@_lInverte, @_cMarcaZBK,{_nLinha, 5, _nLinha + 50 /*_aSizeAut[4]*/ , _nColuna /*_aSizeAut[3]-250*/})
 
      _nLinha += 50
      @ _nLinha     , 10 Say   "Supervisor" Pixel Size  060,012 Of _oDlgP

      _nLinha += 10
      _oMarkZBKD := MsSelect():New("TRBZBK4","WK_OK","",_aCmpZBK,@_lInverte, @_cMarcaZBK,{_nLinha, 5, _nLinha + 50  /*_aSizeAut[4]*/ , _nColuna /*_aSizeAut[3]-250*/})
 
      _nLinha += 50
      @ _nLinha     , 10 Say   "Vendedor" Pixel Size  060,012 Of _oDlgP

      _nLinha += 10
      _oMarkZBKE := MsSelect():New("TRBZBK5","WK_OK","",_aCmpZBK,@_lInverte, @_cMarcaZBK,{_nLinha, 5, _nLinha + 50 /*_aSizeAut[4]*/ , _nColuna /*_aSizeAut[3]-250*/})
 
    ACTIVATE MSDIALOG _oDlgP CENTERED

End Sequence

//================================================================================
// Fecha e exclui as tabelas tempor�rias
//================================================================================                    
If Select("TRBZBK1") > 0
   TRBZBK1->(DbCloseArea())
EndIf

If Select("TRBZBK2") > 0
   TRBZBK2->(DbCloseArea())
EndIf

If Select("TRBZBK3") > 0
   TRBZBK3->(DbCloseArea())
EndIf

If Select("TRBZBK4") > 0
   TRBZBK4->(DbCloseArea())
EndIf

If Select("TRBZBK5") > 0
   TRBZBK5->(DbCloseArea())
EndIf

Return Nil

/*
===============================================================================================================================
Programa----------: ROMS069V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/05/2022
===============================================================================================================================
Descri��o---------: Painel de Comiss�o Gerencial.
===============================================================================================================================
Parametros--------: _cCampo = Campo que chamou a valida��o.
===============================================================================================================================
Retorno-----------: _lRet = .T. = Valida��o Ok
                            .F. = Valida��o Incorreta.
===============================================================================================================================
*/
User Function ROMS069V(_cCampo)
Local _lRet := .T.
Local _cDtPer, _dDtPer  

Begin Sequence

   If _cCampo == "PERIODO"
      If Empty(_cPeriodo)
         Break 
      EndIf 

      _cDtPer := "01/" + SubStr(_cPeriodo,1,2)+"/"+ SubStr(_cPeriodo,3,4)
      _dDtPer := Ctod(_cDtPer)
      
      ZBK->(DbSetOrder(1))
      If ! ZBK->(MsSeek(xFilial("ZBK")+Dtos(_dDtPer)))
         U_Itmsg("N�o foi localizado nenhum fechamento de comiss�o processado para o per�odo informado.","Aten��o","Por favor, informe um per�odo que possua fechamento de comiss�o processado.",1)
         _lRet := .F.
         Break  
      EndIf 
 
   ElseIf _cCampo == "GERENTE_NACIONAL"
      If Empty(_cCodGNac)
         Break 
      EndIf 

      SA3->(DbSetOrder(1))
      If ! SA3->(MsSeek(xFilial("SA3")+_cCodGNac))
         U_Itmsg("N�o foi localizado nenhum Gerente Nacional com o c�digo informado.","Aten��o", ,1)
         _lRet := .F.
         Break  
      Else 
         //_cCodGNac  := Space(6)
         _cCodGer   := Space(6)
         _cCodCoord := Space(6)
         _cCodSup   := Space(6)
         _cCodVen   := Space(6) 
      EndIf 

   ElseIf _cCampo == "GERENTE"
      If Empty(_cCodGer)
         Break 
      EndIf 

      SA3->(DbSetOrder(1))
      If ! SA3->(MsSeek(xFilial("SA3")+_cCodGer))
         U_Itmsg("N�o foi localizado nenhum Gerente com o c�digo informado.","Aten��o", ,1)
         _lRet := .F.
         Break  
      Else 
         _cCodGNac  := Space(6)
         //_cCodGer   := Space(6)
         _cCodCoord := Space(6)
         _cCodSup   := Space(6)
         _cCodVen   := Space(6) 
      EndIf 

   ElseIf _cCampo == "COORDENADOR"
      
      If Empty(_cCodCoord)
         Break 
      EndIf 

      SA3->(DbSetOrder(1))
      If ! SA3->(MsSeek(xFilial("SA3")+_cCodCoord))
         U_Itmsg("N�o foi localizado nenhum Coordenador com o c�digo informado.","Aten��o", ,1)
         _lRet := .F.
         Break  
      Else 
         _cCodGNac  := Space(6)
         _cCodGer   := Space(6)
         //_cCodCoord := Space(6)
         _cCodSup   := Space(6) 
         _cCodVen   := Space(6)
      EndIf 

   ElseIf _cCampo == "SUPERVISOR"
      If Empty(_cCodSup)
         Break 
      EndIf 

      SA3->(DbSetOrder(1))
      If ! SA3->(MsSeek(xFilial("SA3")+_cCodSup))
         U_Itmsg("N�o foi localizado nenhum Supervisor com o c�digo informado.","Aten��o", ,1)
         _lRet := .F.
         Break  
      Else 
         _cCodGNac  := Space(6)
         _cCodGer   := Space(6)
         _cCodCoord := Space(6)
         //_cCodSup   := Space(6) 
         _cCodVen   := Space(6) 
      EndIf 
   
   ElseIf _cCampo == "VENDEDOR"
      If Empty(_cCodVen)
         Break 
      EndIf 

      SA3->(DbSetOrder(1))
      If ! SA3->(MsSeek(xFilial("SA3")+_cCodVen))
         U_Itmsg("N�o foi localizado nenhum Vendedor com o c�digo informado.","Aten��o", ,1)
         _lRet := .F.
         Break  
      Else 
         _cCodGNac  := Space(6)
         _cCodGer   := Space(6)
         _cCodCoord := Space(6)
         _cCodSup   := Space(6) 
      EndIf 
    
   ElseIf _cCampo == "PROCESSAR"

      If Empty(_cPeriodo)
         U_Itmsg("� obrigat�rio o preenchimento do per�do para rodar esta rotina.","Aten��o",,1)
         _lRet := .F.
         Break 
      EndIf 

      _cDtPer := "01/" + SubStr(_cPeriodo,1,2)+"/"+ SubStr(_cPeriodo,3,4)
      _dDtPer := Ctod(_cDtPer)
      
      ZBK->(DbSetOrder(1))
      If ! ZBK->(MsSeek(xFilial("ZBK")+Dtos(_dDtPer)))
         U_Itmsg("N�o foi localizado nenhum fechamento de comiss�o processado para o per�odo informado.","Aten��o","Por favor, informe um per�odo que possua fechamento de comiss�o processado.",1)
         _lRet := .F.
         Break  
      EndIf 
      
      SA3->(DbSetOrder(1))
      If ! Empty(_cCodGNac)
         If ! SA3->(MsSeek(xFilial("SA3")+_cCodGNac))
            U_Itmsg("N�o foi localizado nenhum Gerente Nacional com o c�digo informado.","Aten��o", ,1)
            _lRet := .F.
            Break  
         EndIf 
      EndIf 

      If ! Empty(_cCodGer)
         If ! SA3->(MsSeek(xFilial("SA3")+_cCodGer))
            U_Itmsg("N�o foi localizado nenhum Gerente com o c�digo informado.","Aten��o", ,1)
            _lRet := .F.
            Break  
         EndIf  
      EndIf 
      
      If ! Empty(_cCodCoord)
         If ! SA3->(MsSeek(xFilial("SA3")+_cCodCoord))
            U_Itmsg("N�o foi localizado nenhum Coordenador com o c�digo informado.","Aten��o", ,1)
            _lRet := .F.
            Break  
         EndIf 
      EndIf 

      If ! Empty(_cCodSup)
         If ! SA3->(MsSeek(xFilial("SA3")+_cCodSup))
            U_Itmsg("N�o foi localizado nenhum Supervisor com o c�digo informado.","Aten��o", ,1)
            _lRet := .F.
            Break  
         EndIf   
      EndIf 

      If ! Empty(_cCodVen)
         If ! SA3->(MsSeek(xFilial("SA3")+_cCodVen))
            U_Itmsg("N�o foi localizado nenhum Vendedor com o c�digo informado.","Aten��o", ,1)
            _lRet := .F.
            Break  
         EndIf   
      EndIf 

      If Empty(_cCodGNac) .And. Empty(_cCodGer) .And. Empty(_cCodCoord) .And. Empty(_cCodSup) .And. Empty(_cCodVen)
         U_Itmsg("Para rodar esta rotina � obrigat�rio informar um c�digo para um dos campos: Gerente Nacional ou Gerente ou Coordenador ou Supervisor ou Vendedor.","Aten��o", ,1)
         _lRet := .F.
         Break  
      EndIf 

   ElseIf _cCampo == "GERA_EXCEL"
      
      If Empty(_cPeriodo)
         U_Itmsg("� obrigat�rio o preenchimento do per�do para Gerar os dados em Excel.","Aten��o",,1)
         _lRet := .F.
         Break 
      EndIf 

      If Empty(_cCodGNac) .And. Empty(_cCodGer) .And. Empty(_cCodCoord) .And. Empty(_cCodSup) .And. Empty(_cCodVen)
         U_Itmsg("Para gerar os dados em Excel � obrigat�rio informar um c�digo para um dos campos: Gerente Nacional ou Gerente ou Coordenador ou Supervisor ou Vendedor.","Aten��o", ,1)
         _lRet := .F.
         Break  
      EndIf   
   
      If ! Empty(_cCodGNac)
         TRBZBK1->(DbGoTop())
         If TRBZBK1->(Eof()) .Or. TRBZBK1->(Bof()) 
            U_Itmsg("N�o h� dados para emiss�o do relat�rio em excel.","Aten��o",,1)
            _lRet := .F.
            Break 
         EndIf

      ElseIf ! Empty(_cCodGer)
         TRBZBK2->(DbGoTop())
         If TRBZBK2->(Eof()) .Or. TRBZBK2->(Bof()) 
            U_Itmsg("N�o h� dados para emiss�o do relat�rio em excel.","Aten��o",,1)
            _lRet := .F.
            Break 
         EndIf

      ElseIf ! Empty(_cCodCoord)
         TRBZBK3->(DbGoTop())
         If TRBZBK3->(Eof()) .Or. TRBZBK3->(Bof()) 
            U_Itmsg("N�o h� dados para emiss�o do relat�rio em excel.","Aten��o",,1)
            _lRet := .F.
            Break 
         EndIf

      ElseIf ! Empty(_cCodSup)
         TRBZBK4->(DbGoTop())
         If TRBZBK4->(Eof()) .Or. TRBZBK4->(Bof()) 
            U_Itmsg("N�o h� dados para emiss�o do relat�rio em excel.","Aten��o",,1)
            _lRet := .F.
            Break 
         EndIf

      ElseIf ! Empty(_cCodVen)
         TRBZBK5->(DbGoTop())
         If TRBZBK5->(Eof()) .Or. TRBZBK5->(Bof()) 
            U_Itmsg("N�o h� dados para emiss�o do relat�rio em excel.","Aten��o",,1)
            _lRet := .F.
            Break 
         EndIf

      EndIf

   EndIf 

End Sequence 

Return _lRet

/*
===============================================================================================================================
Programa----------: ROMS069P
Autor-------------: Julio de Paula Paz
Data da Criacao---: 19/05/2022
===============================================================================================================================
Descri��o---------: Gera os dados para o painel com base no filtro e no c�digo informado para uma das op��es da tela:
                    - Gerente Nacional
                    - Gerente
                    - Coordenador
                    - Supervisor
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ROMS069P()

Begin Sequence  
   
   If ! Empty(_cCodGNac)
      If U_ItMsg("Confirma a gera��o dos dados do Painel Gerencial de Comiss�es, tendo como base o c�digo do Gerente Nacional? ", "Aten��o", "",2,2,2) 
         Processa( {|| U_ROMS069N() }, "Aguarde...", "Gerando dados do painel... ",.F.) 
      EndIf 

   ElseIf ! Empty(_cCodGer)
      If U_ItMsg("Confirma a gera��o dos dados do Painel Gerencial de Comiss�es, tendo como base o c�digo do Gerente? ", "Aten��o", "",2,2,2) 
         Processa( {|| U_ROMS069G() }, "Aguarde...", "Gerando dados do painel... ",.F.) 
      EndIf 

   ElseIf ! Empty(_cCodCoord )
      If U_ItMsg("Confirma a gera��o dos dados do Painel Gerencial de Comiss�es, tendo como base o c�digo do Coordenador? ", "Aten��o", "",2,2,2) 
         Processa( {|| U_ROMS069C() }, "Aguarde...", "Gerando dados do painel... ",.F.) 
      EndIf 

   ElseIf ! Empty(_cCodSup)
      If U_ItMsg("Confirma a gera��o dos dados do Painel Gerencial de Comiss�es, tendo como base o c�digo do Supervisor? ", "Aten��o", "",2,2,2) 
         Processa( {|| U_ROMS069S() }, "Aguarde...", "Gerando dados do painel... ",.F.) 
      EndIf 

   ElseIf ! Empty(_cCodVen)
      If U_ItMsg("Confirma a gera��o dos dados do Painel Gerencial de Comiss�es, tendo como base o c�digo do Vendedor? ", "Aten��o", "",2,2,2) 
         Processa( {|| U_ROMS069R() }, "Aguarde...", "Gerando dados do painel... ",.F.) 
      EndIf 

   EndIf 

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: ROMS069N
Autor-------------: Julio de Paula Paz
Data da Criacao---: 19/05/2022
===============================================================================================================================
Descri��o---------: Gera os dados para o painel para o Gerente Nacional e estruturas hier�rquicas subordinadas.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ROMS069N()
Local _cQry, _cPeriodoQry  
Local _dFechamen, _cVersao

Begin Sequence 
   
   //============================================================================
   // Limpando o conte�do das tabelas tempor�rias para grava��o de novos dados.
   //============================================================================
   _otemp1:Zap()
   _otemp2:Zap()
   _otemp3:Zap()
   _otemp4:Zap()
   _otemp5:Zap()

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias representantes.
   //============================================================================
   ProcRegua(0)

   _dFechamen := Ctod("01/" + SubStr(_cPeriodo,1,2) + "/" + SubStr(_cPeriodo,3,4))
   
   _cVersao := U_ROMS069W(_dFechamen) // Retorna a ultima vers�o gravada para o per�odo informado.
   
   IncProc("Lendo dados das comiss�es dos Representantes...")

   _cPeriodoQry := SubStr(_cPeriodo,3,4) + SubStr(_cPeriodo,1,2)
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_VEND, ZBK_NOMVEN, "
   _cQry += " SUM(ZBK_COMVEN) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " GROUP BY ZBK_VEND, ZBK_NOMVEN "
   _cQry += " ORDER BY ZBK_VEND "
   
   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      IncProc("Gravando dados Representante: " + TRBQRY->ZBK_VEND + "-" + AllTrim(TRBQRY->ZBK_NOMVEN))

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_VEND))

      If SA3->A3_I_TIPV == "V" // V=VENDEDOR;
         TRBZBK5->(DbAppend())
         TRBZBK5->ZBK_VEND   := TRBQRY->ZBK_VEND
         TRBZBK5->ZBK_NOMVEN := TRBQRY->ZBK_NOMVEN
         TRBZBK5->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK5->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK5->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK5->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK5->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK5->(MsUnLock())

      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf
   
   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias supervisores.
   //============================================================================
   IncProc("Lendo dados das comiss�es dos Supervisores...")

   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_SUPERV, "
   _cQry += " SUM(ZBK_COMSUP) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " GROUP BY ZBK_SUPERV "
   _cQry += " ORDER BY ZBK_SUPERV "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_SUPERV))

      IncProc("Gravando dados Supervisor: " + TRBQRY->ZBK_SUPERV + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "S" // S=SUPERVISOR; 
         TRBZBK4->(DbAppend())
         TRBZBK4->ZBK_VEND   := TRBQRY->ZBK_SUPERV
         TRBZBK4->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK4->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK4->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK4->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK4->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK4->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK4->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias coordenadores.
   //============================================================================
   IncProc("Lendo dados das comiss�es dos Coordenadores...")
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_COORDE, "
   _cQry += " SUM(ZBK_COMCOO) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " GROUP BY ZBK_COORDE "
   _cQry += " ORDER BY ZBK_COORDE "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_COORDE))
      
      IncProc("Gravando dados Coordenador: " + TRBQRY->ZBK_COORDE + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "C" // C=COORDENADOR
         TRBZBK3->(DbAppend())
         TRBZBK3->ZBK_VEND   := TRBQRY->ZBK_COORDE
         TRBZBK3->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK3->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK3->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK3->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK3->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK3->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK3->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias gerentes.
   //============================================================================
   IncProc("Lendo dados das comiss�es dos Gerentes...")

   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_GERENT, "
   _cQry += " SUM(ZBK_COMGER) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " GROUP BY ZBK_GERENT "
   _cQry += " ORDER BY ZBK_GERENT "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_GERENT))
      
      IncProc("Gravando dados Gerente: " + TRBQRY->ZBK_GERENT+ "-" + AllTrim(SA3->A3_NOME))

//      If SA3->A3_I_TIPV == "G" // G=GERENTE;                                                              
         TRBZBK2->(DbAppend())
         TRBZBK2->ZBK_VEND   := TRBQRY->ZBK_GERENT
         TRBZBK2->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK2->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK2->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK2->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK2->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK2->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK2->(MsUnLock())
//      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias gerente nacional.
   //============================================================================
   IncProc("Lendo dados das comiss�es do Gerente Nacional...")
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_GERNAC, "
   _cQry += " SUM(ZBK_COMGNC) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') + " ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " GROUP BY ZBK_GERNAC "
   _cQry += " ORDER BY ZBK_GERNAC "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_GERNAC))

      IncProc("Gravando dados Gerente Nacional: " + TRBQRY->ZBK_GERNAC + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "N"  // N=GERENTE NACIONAL 
         TRBZBK1->(DbAppend())
         TRBZBK1->ZBK_VEND   := TRBQRY->ZBK_GERNAC
         TRBZBK1->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK1->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK1->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK1->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK1->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK1->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK1->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   TRBZBK1->(DbGoTop())
   TRBZBK2->(DbGoTop())
   TRBZBK3->(DbGoTop())
   TRBZBK4->(DbGoTop())
   TRBZBK5->(DbGoTop())

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa--------: ROMS069W
Autor-----------: Julio de Paula Paz
Data da Criacao-: 21/11/2019
===============================================================================================================================
Descri��o-------: Retorna a ultima vers�o gravada na tabela ZBK para o per�odo informado.
===============================================================================================================================
Parametros------: _dDtFecham = Data de fechamento
===============================================================================================================================
Retorno---------: _nRet = Retorna a ultima sequencia gravada para o per�do informado.
===============================================================================================================================
*/
User Function ROMS069W(_dDtFecham)
Local _cRet := "001"
Local _cQry 

Begin Sequence 

   _cQry := " SELECT Max(ZBK_VERSAO) VERSAO "
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += "   AND ZBK_DTFECH = '" + Dtos(_dDtFecham) +"' "   
   
   If Select("TRBZBK") > 0
      TRBZBK->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBZBK" , .T. , .F. )

   If ! TRBZBK->(Eof()) .And. ! TRBZBK->(Bof())
      _cRet := TRBZBK->VERSAO
   EndIf 

End Sequence 

Return _cRet 

/*
===============================================================================================================================
Programa----------: ROMS069G
Autor-------------: Julio de Paula Paz
Data da Criacao---: 20/05/2022
===============================================================================================================================
Descri��o---------: Gera os dados para o painel para o Gerente e estruturas hier�rquicas subordinadas.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ROMS069G()
Local _cQry, _cPeriodoQry  
Local _dFechamen, _cVersao

Begin Sequence 
   
   //============================================================================
   // Limpando o conte�do das tabelas tempor�rias para grava��o de novos dados.
   //============================================================================
   _otemp1:Zap()
   _otemp2:Zap()
   _otemp3:Zap()
   _otemp4:Zap()
   _otemp5:Zap()

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias representantes.
   //============================================================================
   ProcRegua(0)

   _dFechamen := Ctod("01/" + SubStr(_cPeriodo,1,2) + "/" + SubStr(_cPeriodo,3,4))
   
   _cVersao := U_ROMS069W(_dFechamen) // Retorna a ultima vers�o gravada para o per�odo informado.
   
   IncProc("Lendo dados das comiss�es dos Representantes...")

   _cPeriodoQry := SubStr(_cPeriodo,3,4) + SubStr(_cPeriodo,1,2)
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_VEND, ZBK_NOMVEN, "
   _cQry += " SUM(ZBK_COMVEN) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_GERENT = '" + _cCodGer + "' "
   _cQry += " GROUP BY ZBK_VEND, ZBK_NOMVEN "
   _cQry += " ORDER BY ZBK_VEND "
   
   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      IncProc("Gravando dados Representante: " + TRBQRY->ZBK_VEND + "-" + AllTrim(TRBQRY->ZBK_NOMVEN))

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_VEND))

      If SA3->A3_I_TIPV == "V" // V=VENDEDOR;
         TRBZBK5->(DbAppend())
         TRBZBK5->ZBK_VEND   := TRBQRY->ZBK_VEND
         TRBZBK5->ZBK_NOMVEN := TRBQRY->ZBK_NOMVEN
         TRBZBK5->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK5->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK5->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK5->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK5->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK5->(MsUnLock())

      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf
   
   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias supervisores.
   //============================================================================
   IncProc("Lendo dados das comiss�es dos Supervisores...")
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_SUPERV, "
   _cQry += " SUM(ZBK_COMSUP) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_GERENT = '" + _cCodGer + "' "   
   _cQry += " GROUP BY ZBK_SUPERV "
   _cQry += " ORDER BY ZBK_SUPERV "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_SUPERV))

      IncProc("Gravando dados Supervisor: " + TRBQRY->ZBK_SUPERV + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "S" // S=SUPERVISOR; 
         TRBZBK4->(DbAppend())
         TRBZBK4->ZBK_VEND   := TRBQRY->ZBK_SUPERV
         TRBZBK4->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK4->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK4->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK4->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK4->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK4->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK4->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias coordenadores.
   //============================================================================
   IncProc("Lendo dados das comiss�es dos Coordenadores...")
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_COORDE, "
   _cQry += " SUM(ZBK_COMCOO) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_GERENT = '" + _cCodGer + "' "   
   _cQry += " GROUP BY ZBK_COORDE "
   _cQry += " ORDER BY ZBK_COORDE "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_COORDE))
      
      IncProc("Gravando dados Coordenador: " + TRBQRY->ZBK_COORDE + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "C" // C=COORDENADOR
         TRBZBK3->(DbAppend())
         TRBZBK3->ZBK_VEND   := TRBQRY->ZBK_COORDE
         TRBZBK3->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK3->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK3->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK3->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK3->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK3->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK3->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias gerentes.
   //============================================================================
   IncProc("Lendo dados das comiss�es dos Gerentes...")

   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_GERENT, "
   _cQry += " SUM(ZBK_COMGER) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_GERENT = '" + _cCodGer + "' "   
   _cQry += " GROUP BY ZBK_GERENT "
   _cQry += " ORDER BY ZBK_GERENT "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_GERENT))
      
      IncProc("Gravando dados Gerente: " + TRBQRY->ZBK_GERENT+ "-" + AllTrim(SA3->A3_NOME))

//      If SA3->A3_I_TIPV == "G" // G=GERENTE;                                                              
         TRBZBK2->(DbAppend())
         TRBZBK2->ZBK_VEND   := TRBQRY->ZBK_GERENT
         TRBZBK2->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK2->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK2->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK2->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK2->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK2->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK2->(MsUnLock())
//      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias gerente nacional.
   //============================================================================
   //ProcRegua(0)
   IncProc("Lendo dados das comiss�es do Gerente Nacional...")

   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_GERNAC, "
   _cQry += " SUM(ZBK_COMGNC) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') + " ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_GERENT = '" + _cCodGer + "' "
   _cQry += " GROUP BY ZBK_GERNAC "
   _cQry += " ORDER BY ZBK_GERNAC "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_GERNAC))

      IncProc("Gravando dados Gerente Nacional: " + TRBQRY->ZBK_GERNAC + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "N"  // N=GERENTE NACIONAL 
         TRBZBK1->(DbAppend())
         TRBZBK1->ZBK_VEND   := TRBQRY->ZBK_GERNAC
         TRBZBK1->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK1->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK1->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK1->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK1->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK1->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK1->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   TRBZBK1->(DbGoTop())
   TRBZBK2->(DbGoTop())
   TRBZBK3->(DbGoTop())
   TRBZBK4->(DbGoTop())
   TRBZBK5->(DbGoTop())

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: ROMS069C
Autor-------------: Julio de Paula Paz
Data da Criacao---: 20/05/2022
===============================================================================================================================
Descri��o---------: Gera os dados para o painel para o Coordenador e estruturas hier�rquicas subordinadas.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ROMS069C()
Local _cQry, _cPeriodoQry  
Local _dFechamen, _cVersao

Begin Sequence 
   
   //============================================================================
   // Limpando o conte�do das tabelas tempor�rias para grava��o de novos dados.
   //============================================================================
   _otemp1:Zap()
   _otemp2:Zap()
   _otemp3:Zap()
   _otemp4:Zap()
   _otemp5:Zap()

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias representantes.
   //============================================================================
   ProcRegua(0)

   _dFechamen := Ctod("01/" + SubStr(_cPeriodo,1,2) + "/" + SubStr(_cPeriodo,3,4))
   
   _cVersao := U_ROMS069W(_dFechamen) // Retorna a ultima vers�o gravada para o per�odo informado.
   
   IncProc("Lendo dados das comiss�es dos Representantes...")

   _cPeriodoQry := SubStr(_cPeriodo,3,4) + SubStr(_cPeriodo,1,2)
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_VEND, ZBK_NOMVEN, "
   _cQry += " SUM(ZBK_COMVEN) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_COORDE = '" + _cCodCoord + "' "
   _cQry += " GROUP BY ZBK_VEND, ZBK_NOMVEN "
   _cQry += " ORDER BY ZBK_VEND "
   
   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      IncProc("Gravando dados Representante: " + TRBQRY->ZBK_VEND + "-" + AllTrim(TRBQRY->ZBK_NOMVEN))

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_VEND))

      If SA3->A3_I_TIPV == "V" // V=VENDEDOR;
         TRBZBK5->(DbAppend())
         TRBZBK5->ZBK_VEND   := TRBQRY->ZBK_VEND
         TRBZBK5->ZBK_NOMVEN := TRBQRY->ZBK_NOMVEN
         TRBZBK5->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK5->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK5->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK5->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK5->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK5->(MsUnLock())

      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf
   
   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias supervisores.
   //============================================================================
   //ProcRegua(0)
   IncProc("Lendo dados das comiss�es dos Supervisores...")

   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_SUPERV, "
   _cQry += " SUM(ZBK_COMSUP) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_COORDE = '" + _cCodCoord + "' " 
   _cQry += " GROUP BY ZBK_SUPERV "
   _cQry += " ORDER BY ZBK_SUPERV "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_SUPERV))

      IncProc("Gravando dados Supervisor: " + TRBQRY->ZBK_SUPERV + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "S" // S=SUPERVISOR; 
         TRBZBK4->(DbAppend())
         TRBZBK4->ZBK_VEND   := TRBQRY->ZBK_SUPERV
         TRBZBK4->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK4->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK4->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK4->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK4->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK4->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK4->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias coordenadores.
   //============================================================================
   //ProcRegua(0)
   IncProc("Lendo dados das comiss�es dos Coordenadores...")

   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_COORDE, "
   _cQry += " SUM(ZBK_COMCOO) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_COORDE = '" + _cCodCoord + "' "
   _cQry += " GROUP BY ZBK_COORDE "
   _cQry += " ORDER BY ZBK_COORDE "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_COORDE))
      
      IncProc("Gravando dados Coordenador: " + TRBQRY->ZBK_COORDE + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "C" // C=COORDENADOR
         TRBZBK3->(DbAppend())
         TRBZBK3->ZBK_VEND   := TRBQRY->ZBK_COORDE
         TRBZBK3->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK3->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK3->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK3->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK3->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK3->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK3->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias gerentes.
   //============================================================================
   //ProcRegua(0)
   IncProc("Lendo dados das comiss�es dos Gerentes...")

   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_GERENT, "
   _cQry += " SUM(ZBK_COMGER) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_COORDE = '" + _cCodCoord + "' "
   _cQry += " GROUP BY ZBK_GERENT "
   _cQry += " ORDER BY ZBK_GERENT "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_GERENT))
      
      IncProc("Gravando dados Gerente: " + TRBQRY->ZBK_GERENT+ "-" + AllTrim(SA3->A3_NOME))

//      If SA3->A3_I_TIPV == "G" // G=GERENTE;                                                              
         TRBZBK2->(DbAppend())
         TRBZBK2->ZBK_VEND   := TRBQRY->ZBK_GERENT
         TRBZBK2->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK2->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK2->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK2->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK2->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK2->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK2->(MsUnLock())
//      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias gerente nacional.
   //============================================================================
   //ProcRegua(0)
   IncProc("Lendo dados das comiss�es do Gerente Nacional...")
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_GERNAC, "
   _cQry += " SUM(ZBK_COMGNC) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') + " ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_COORDE = '" + _cCodCoord + "' "
   _cQry += " GROUP BY ZBK_GERNAC "
   _cQry += " ORDER BY ZBK_GERNAC "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_GERNAC))

      IncProc("Gravando dados Gerente Nacional: " + TRBQRY->ZBK_GERNAC + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "N"  // N=GERENTE NACIONAL 
         TRBZBK1->(DbAppend())
         TRBZBK1->ZBK_VEND   := TRBQRY->ZBK_GERNAC
         TRBZBK1->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK1->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK1->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK1->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK1->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK1->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK1->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   TRBZBK1->(DbGoTop())
   TRBZBK2->(DbGoTop())
   TRBZBK3->(DbGoTop())
   TRBZBK4->(DbGoTop())
   TRBZBK5->(DbGoTop())

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: ROMS069S
Autor-------------: Julio de Paula Paz
Data da Criacao---: 20/05/2022
===============================================================================================================================
Descri��o---------: Gera os dados para o painel para o Supervisor e estruturas hier�rquicas subordinadas.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ROMS069S()
Local _cQry, _cPeriodoQry  
Local _dFechamen, _cVersao

Begin Sequence 
   
   //============================================================================
   // Limpando o conte�do das tabelas tempor�rias para grava��o de novos dados.
   //============================================================================
   _otemp1:Zap()
   _otemp2:Zap()
   _otemp3:Zap()
   _otemp4:Zap()
   _otemp5:Zap()

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias representantes.
   //============================================================================
   ProcRegua(0)

   _dFechamen := Ctod("01/" + SubStr(_cPeriodo,1,2) + "/" + SubStr(_cPeriodo,3,4))
   
   _cVersao := U_ROMS069W(_dFechamen) // Retorna a ultima vers�o gravada para o per�odo informado.
   
   IncProc("Lendo dados das comiss�es dos Representantes...")

   _cPeriodoQry := SubStr(_cPeriodo,3,4) + SubStr(_cPeriodo,1,2)
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_VEND, ZBK_NOMVEN, "
   _cQry += " SUM(ZBK_COMVEN) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_SUPERV = '" + _cCodSup + "' "
   _cQry += " GROUP BY ZBK_VEND, ZBK_NOMVEN "
   _cQry += " ORDER BY ZBK_VEND "
   
   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      IncProc("Gravando dados Representante: " + TRBQRY->ZBK_VEND + "-" + AllTrim(TRBQRY->ZBK_NOMVEN))

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_VEND))

      If SA3->A3_I_TIPV == "V" // V=VENDEDOR;
         TRBZBK5->(DbAppend())
         TRBZBK5->ZBK_VEND   := TRBQRY->ZBK_VEND
         TRBZBK5->ZBK_NOMVEN := TRBQRY->ZBK_NOMVEN
         TRBZBK5->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK5->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK5->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK5->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK5->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK5->(MsUnLock())

      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf
   
   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias supervisores.
   //============================================================================
   //ProcRegua(0)
   IncProc("Lendo dados das comiss�es dos Supervisores...")
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_SUPERV, "
   _cQry += " SUM(ZBK_COMSUP) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_SUPERV = '" + _cCodSup + "' "
   _cQry += " GROUP BY ZBK_SUPERV "
   _cQry += " ORDER BY ZBK_SUPERV "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_SUPERV))

      IncProc("Gravando dados Supervisor: " + TRBQRY->ZBK_SUPERV + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "S" // S=SUPERVISOR; 
         TRBZBK4->(DbAppend())
         TRBZBK4->ZBK_VEND   := TRBQRY->ZBK_SUPERV
         TRBZBK4->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK4->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK4->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK4->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK4->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK4->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK4->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias coordenadores.
   //============================================================================
   //ProcRegua(0)
   IncProc("Lendo dados das comiss�es dos Coordenadores...")
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_COORDE, "
   _cQry += " SUM(ZBK_COMCOO) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_SUPERV = '" + _cCodSup + "' "
   _cQry += " GROUP BY ZBK_COORDE "
   _cQry += " ORDER BY ZBK_COORDE "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_COORDE))
      
      IncProc("Gravando dados Coordenador: " + TRBQRY->ZBK_COORDE + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "C" // C=COORDENADOR
         TRBZBK3->(DbAppend())
         TRBZBK3->ZBK_VEND   := TRBQRY->ZBK_COORDE
         TRBZBK3->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK3->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK3->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK3->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK3->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK3->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK3->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias gerentes.
   //============================================================================
   //ProcRegua(0)
   IncProc("Lendo dados das comiss�es dos Gerentes...")

   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_GERENT, "
   _cQry += " SUM(ZBK_COMGER) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_SUPERV = '" + _cCodSup + "' "
   _cQry += " GROUP BY ZBK_GERENT "
   _cQry += " ORDER BY ZBK_GERENT "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_GERENT))
      
      IncProc("Gravando dados Gerente: " + TRBQRY->ZBK_GERENT+ "-" + AllTrim(SA3->A3_NOME))

//      If SA3->A3_I_TIPV == "G" // G=GERENTE;                                                              
         TRBZBK2->(DbAppend())
         TRBZBK2->ZBK_VEND   := TRBQRY->ZBK_GERENT
         TRBZBK2->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK2->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK2->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK2->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK2->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK2->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK2->(MsUnLock())
//      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias gerente nacional.
   //============================================================================
   //ProcRegua(0)
   IncProc("Lendo dados das comiss�es do Gerente Nacional...")
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_GERNAC, "
   _cQry += " SUM(ZBK_COMGNC) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') + " ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_SUPERV = '" + _cCodSup + "' "
   _cQry += " GROUP BY ZBK_GERNAC "
   _cQry += " ORDER BY ZBK_GERNAC "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_GERNAC))

      IncProc("Gravando dados Gerente Nacional: " + TRBQRY->ZBK_GERNAC + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "N"  // N=GERENTE NACIONAL 
         TRBZBK1->(DbAppend())
         TRBZBK1->ZBK_VEND   := TRBQRY->ZBK_GERNAC
         TRBZBK1->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK1->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK1->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK1->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK1->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK1->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK1->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   TRBZBK1->(DbGoTop())
   TRBZBK2->(DbGoTop())
   TRBZBK3->(DbGoTop())
   TRBZBK4->(DbGoTop())
   TRBZBK5->(DbGoTop())

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: ROMS069E
Autor-------------: Julio de Paula Paz
Data da Criacao---: 20/05/2022
===============================================================================================================================
Descri��o---------: Gera o relat�rio em Excel para os dados exibidos em tela.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ROMS069E()
Local _aDadosGNC := {}
Local _aDadosGer := {}
Local _aDadosCoo := {}
Local _aDadosSup := {}
Local _aDadosVen := {}
Local _aCabGNC   := {}
Local _aCabGer   := {}
Local _aCabCoo   := {}
Local _aCabSup   := {}
Local _aCabVen   := {}

Begin Sequence 

   If ! U_ItMsg("Confirma a exporta��o dos dados da tela para planilha Excel? ", "Aten��o", "",2,2,2) 
      Break 
   EndIf 

   _aCabGNC   := {}
   //           Titulo das Colunas ,Alinhamento ,Formata��o, Totaliza?
	Aadd(_aCabGNC,{"Codigo"         ,1           ,1         ,.F.})  // 1
   Aadd(_aCabGNC,{"Nome"           ,1           ,1         ,.F.})  // 2
   Aadd(_aCabGNC,{"Valor Comiss�o" ,3           ,3         ,.F.})  // 3
   
   _aCabGer   := {}
   Aadd(_aCabGer,{"Codigo"         ,1           ,1         ,.F.})  // 1
   Aadd(_aCabGer,{"Nome"           ,1           ,1         ,.F.})  // 2
   Aadd(_aCabGer,{"Valor Comiss�o" ,3           ,3         ,.F.})  // 3

   _aCabCoo   := {}
   Aadd(_aCabCoo,{"Codigo"         ,1           ,1         ,.F.})  // 1
   Aadd(_aCabCoo,{"Nome"           ,1           ,1         ,.F.})  // 2
   Aadd(_aCabCoo,{"Valor Comiss�o" ,3           ,3         ,.F.})  // 3
   Aadd(_aCabCoo,{"Codigo Gerente" ,1           ,1         ,.F.})  // 4
   Aadd(_aCabCoo,{"Nome Gerente"   ,1           ,1         ,.F.})  // 5

   _aCabSup   := {}
   Aadd(_aCabSup,{"Codigo"             ,1           ,1         ,.F.}) // 1
   Aadd(_aCabSup,{"Nome"               ,1           ,1         ,.F.}) // 2
   Aadd(_aCabSup,{"Valor Comiss�o"     ,3           ,3         ,.F.}) // 3
   Aadd(_aCabSup,{"Codigo Gerente"     ,1           ,1         ,.F.}) // 4
   Aadd(_aCabSup,{"Nome Gerente"       ,1           ,1         ,.F.}) // 5
   Aadd(_aCabSup,{"Codigo Coordenador" ,1           ,1         ,.F.}) // 6 
   Aadd(_aCabSup,{"Nome Coordenador"   ,1           ,1         ,.F.}) // 7

   _aCabVen   := {}
   Aadd(_aCabVen,{"Codigo"             ,1           ,1         ,.F.}) // 1
   Aadd(_aCabVen,{"Nome"               ,1           ,1         ,.F.}) // 2
   Aadd(_aCabVen,{"Valor Comiss�o"     ,3           ,3         ,.F.}) // 3
   Aadd(_aCabVen,{"Codigo Gerente"     ,1           ,1         ,.F.}) // 4
   Aadd(_aCabVen,{"Nome Gerente"       ,1           ,1         ,.F.}) // 5
   Aadd(_aCabVen,{"Codigo Coordenador" ,1           ,1         ,.F.}) // 6
   Aadd(_aCabVen,{"Nome Coordenador"   ,1           ,1         ,.F.}) // 7
   Aadd(_aCabVen,{"Codigo Supervisor"  ,1           ,1         ,.F.}) // 8
   Aadd(_aCabVen,{"Nome Supervisor"    ,1           ,1         ,.F.}) // 9

   //=================================================================
   // Grava dados do gerente nacional
   //=================================================================
   _aDadosGNC := {}
   TRBZBK1->(DbGoTop())
   Do While ! TRBZBK1->(Eof())
                       //         1              2                  3
      Aadd(_aDadosGNC,{TRBZBK1->ZBK_VEND, TRBZBK1->ZBK_NOMVEN,TRBZBK1->ZBK_COMVEN}) 
      
      TRBZBK1->(DbSkip())
   EndDo 

   If Empty(_aDadosGNC)
                //    1   2  3
      //_aDadosGNC := {"" ,"" ,0}
      Aadd(_aDadosGNC,{"" ,"" ,0})
   EndIf 

   //=================================================================
   // Grava dados do gerente
   //=================================================================
   _aDadosGer := {}
   TRBZBK2->(DbGoTop())
   Do While ! TRBZBK2->(Eof())
                       //     1                   2                    3
      Aadd(_aDadosGer,{TRBZBK2->ZBK_VEND, TRBZBK2->ZBK_NOMVEN,TRBZBK2->ZBK_COMVEN}) 

      TRBZBK2->(DbSkip())
   EndDo 
   
   If Empty(_aDadosGer)
                  // 1   2   3
      //_aDadosGer := {"", "" ,0}
      Aadd(_aDadosGer, {"", "" ,0})
   EndIf 

   //=================================================================
   // Grava dados do coordenador
   //=================================================================
   _aDadosCoo := {}
   TRBZBK3->(DbGoTop())
   Do While ! TRBZBK3->(Eof())
      _cNomeGer := ""
      If ! Empty(TRBZBK3->ZBK_GERENT)
         _cNomeGer := Posicione( "SA3" , 1 , xFilial("SA3")+TRBZBK3->ZBK_GERENT, "A3_NOME" )
      EndIf 
                       //        1               2                     3                 4                 5
      Aadd(_aDadosCoo,{TRBZBK3->ZBK_VEND, TRBZBK3->ZBK_NOMVEN,TRBZBK3->ZBK_COMVEN, TRBZBK3->ZBK_GERENT,_cNomeGer}) 

      TRBZBK3->(DbSkip())
   EndDo 
   
   If Empty(_aDadosCoo)
                //    1  2   3   4   5
      //_aDadosCoo := {"" ,"" ,0 ,"" ,""}
      Aadd(_aDadosCoo, {"" ,"" ,0 ,"" ,""})
   EndIf 
    
   //=================================================================
   // Grava dados do supervisor
   //=================================================================
   _aDadosSup := {}
   TRBZBK4->(DbGoTop())
   Do While ! TRBZBK4->(Eof())
      _cNomeGer := ""
      If ! Empty(TRBZBK4->ZBK_GERENT)
         _cNomeGer := Posicione( "SA3" , 1 , xFilial("SA3")+TRBZBK4->ZBK_GERENT, "A3_NOME" )
      EndIf 

      _cNomeCoo := ""
      If ! Empty(TRBZBK4->ZBK_COORDE)
         _cNomeCoo := Posicione( "SA3" , 1 , xFilial("SA3")+TRBZBK4->ZBK_COORDE, "A3_NOME" )
      EndIf 
                           //      1                  2                  3                   4            5                 6              7
      Aadd(_aDadosSup,{TRBZBK4->ZBK_VEND, TRBZBK4->ZBK_NOMVEN,TRBZBK4->ZBK_COMVEN, TRBZBK4->ZBK_GERENT,_cNomeGer, TRBZBK4->ZBK_COORDE,_cNomeCoo}) 


      TRBZBK4->(DbSkip())
   EndDo 

   If Empty(_aDadosSup)
                //   1    2  3  4   5   6   7 
      //_aDadosSup := {"", "", 0, "","" ,"" ,""}
      Aadd(_aDadosSup, {"", "", 0, "","" ,"" ,""})
   EndIf 

   
   //=================================================================
   // Grava dados do vendedor
   //=================================================================
   _aDadosVen := {}
   TRBZBK5->(DbGoTop())
   Do While ! TRBZBK5->(Eof())
      _cNomeGer := ""
      If ! Empty(TRBZBK5->ZBK_GERENT)
         _cNomeGer := Posicione( "SA3" , 1 , xFilial("SA3")+TRBZBK5->ZBK_GERENT, "A3_NOME" )
      EndIf 

      _cNomeCoo := ""
      If ! Empty(TRBZBK5->ZBK_COORDE)
         _cNomeCoo := Posicione( "SA3" , 1 , xFilial("SA3")+TRBZBK5->ZBK_COORDE, "A3_NOME" )
      EndIf 

      _cNomeSup := ""
      If ! Empty(TRBZBK5->ZBK_SUPERV)
         _cNomeSup := Posicione( "SA3" , 1 , xFilial("SA3")+TRBZBK5->ZBK_SUPERV, "A3_NOME" )
      EndIf 
                  //             1                 2                   3                    4             5              6                7           8                 9   
      Aadd(_aDadosVen,{TRBZBK5->ZBK_VEND, TRBZBK5->ZBK_NOMVEN,TRBZBK5->ZBK_COMVEN, TRBZBK5->ZBK_GERENT,_cNomeGer, TRBZBK5->ZBK_COORDE,_cNomeCoo,TRBZBK5->ZBK_SUPERV,_cNomeSup}) 

      TRBZBK5->(DbSkip())
   EndDo 
   
   If Empty(_aDadosVen)
              //      1  2   3  4   5   6  7  8   9
      //_aDadosVen := {"", "", 0 ,"" ,"" ,"","","",""} 
      Aadd(_aDadosVen, {"", "", 0 ,"" ,"" ,"","","",""})
   EndIf 

   _aCabec:={}
	Aadd(_aCabec,{"Gerente Nacional" ,_aCabGNC})
	Aadd(_aCabec,{"Gerente"          ,_aCabGer}) 
   Aadd(_aCabec,{"Coordenador"      ,_aCabCoo}) 
   Aadd(_aCabec,{"Supervisor"       ,_aCabSup}) 
   Aadd(_aCabec,{"Representante"    ,_aCabVen}) 

   _aDetalhe := {_aDadosGNC,_aDadosGer,_aDadosCoo,_aDadosSup,_aDadosVen}

	         //  _cNomeArq,_cDiretorio,_cTitulo                    ,_cNomePlan,_aCabecalho,_aDetalhe,_lLeTabTemp,_cAliasTab,_aCampos,_lScheduller,_lCriaPastas,_aPergunte)
	U_ITGEREXCEL(         ,           ,"Painel Gerencial Comiss�es",          ,_aCabec     ,_aDetalhe,           ,          ,        ,            ,.T.         ,          )

End Sequence 

TRBZBK1->(DbGoTop())
TRBZBK2->(DbGoTop())
TRBZBK3->(DbGoTop())
TRBZBK4->(DbGoTop())
TRBZBK5->(DbGoTop())

U_Itmsg("Exporta��o dos dados para Excel concluido.","Aten��o", ,2)

Return Nil 

/*
===============================================================================================================================
Programa----------: ROMS069R
Autor-------------: Julio de Paula Paz
Data da Criacao---: 02/03/2023
===============================================================================================================================
Descri��o---------: Gera os dados para o painel para o Vendedor / Representante e estruturas hier�rquicas superiores.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ROMS069R()
Local _cQry, _cPeriodoQry  
Local _dFechamen, _cVersao

Begin Sequence 
   
   //============================================================================
   // Limpando o conte�do das tabelas tempor�rias para grava��o de novos dados.
   //============================================================================
   _otemp1:Zap()
   _otemp2:Zap()
   _otemp3:Zap()
   _otemp4:Zap()
   _otemp5:Zap()

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias representantes.
   //============================================================================
   ProcRegua(0)

   _dFechamen := Ctod("01/" + SubStr(_cPeriodo,1,2) + "/" + SubStr(_cPeriodo,3,4))
   
   _cVersao := U_ROMS069W(_dFechamen) // Retorna a ultima vers�o gravada para o per�odo informado.
   
   IncProc("Lendo dados das comiss�es dos Representantes...")

   _cPeriodoQry := SubStr(_cPeriodo,3,4) + SubStr(_cPeriodo,1,2)
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_VEND, ZBK_NOMVEN, "
   _cQry += " SUM(ZBK_COMVEN) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   _cQry += " AND ZBK_VEND = '" + _cCodVen + "' "
   _cQry += " GROUP BY ZBK_VEND, ZBK_NOMVEN "
   _cQry += " ORDER BY ZBK_VEND "
   
   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      IncProc("Gravando dados Representante: " + TRBQRY->ZBK_VEND + "-" + AllTrim(TRBQRY->ZBK_NOMVEN))

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_VEND))

      If SA3->A3_I_TIPV == "V" // V=VENDEDOR;
         TRBZBK5->(DbAppend())
         TRBZBK5->ZBK_VEND   := TRBQRY->ZBK_VEND
         TRBZBK5->ZBK_NOMVEN := TRBQRY->ZBK_NOMVEN
         TRBZBK5->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK5->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK5->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK5->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK5->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK5->(MsUnLock())

      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf
   
   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias supervisores.
   //============================================================================
   //ProcRegua(0)
   IncProc("Lendo dados das comiss�es dos Supervisores...")
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_SUPERV, "
   _cQry += " SUM(ZBK_COMSUP) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   //_cQry += " AND ZBK_SUPERV = '" + _cCodSup + "' "
   _cQry += " AND ZBK_VEND = '" + _cCodVen + "' "
   _cQry += " GROUP BY ZBK_SUPERV "
   _cQry += " ORDER BY ZBK_SUPERV "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_SUPERV))

      IncProc("Gravando dados Supervisor: " + TRBQRY->ZBK_SUPERV + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "S" // S=SUPERVISOR; 
         TRBZBK4->(DbAppend())
         TRBZBK4->ZBK_VEND   := TRBQRY->ZBK_SUPERV
         TRBZBK4->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK4->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK4->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK4->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK4->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK4->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK4->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias coordenadores.
   //============================================================================
   //ProcRegua(0)
   IncProc("Lendo dados das comiss�es dos Coordenadores...")
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_COORDE, "
   _cQry += " SUM(ZBK_COMCOO) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   //_cQry += " AND ZBK_SUPERV = '" + _cCodSup + "' "
   _cQry += " AND ZBK_VEND = '" + _cCodVen + "' "
   _cQry += " GROUP BY ZBK_COORDE "
   _cQry += " ORDER BY ZBK_COORDE "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 
      
      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_COORDE))
      
      IncProc("Gravando dados Coordenador: " + TRBQRY->ZBK_COORDE + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "C" // C=COORDENADOR
         TRBZBK3->(DbAppend())
         TRBZBK3->ZBK_VEND   := TRBQRY->ZBK_COORDE
         TRBZBK3->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK3->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK3->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK3->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK3->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK3->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK3->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias gerentes.
   //============================================================================
   //ProcRegua(0)
   IncProc("Lendo dados das comiss�es dos Gerentes...")

   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_GERENT, "
   _cQry += " SUM(ZBK_COMGER) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') +" ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   //_cQry += " AND ZBK_SUPERV = '" + _cCodSup + "' "
   _cQry += " AND ZBK_VEND = '" + _cCodVen + "' "
   _cQry += " GROUP BY ZBK_GERENT "
   _cQry += " ORDER BY ZBK_GERENT "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_GERENT))
      
      IncProc("Gravando dados Gerente: " + TRBQRY->ZBK_GERENT+ "-" + AllTrim(SA3->A3_NOME))

//      If SA3->A3_I_TIPV == "G" // G=GERENTE;                                                              
         TRBZBK2->(DbAppend())
         TRBZBK2->ZBK_VEND   := TRBQRY->ZBK_GERENT
         TRBZBK2->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK2->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK2->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK2->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK2->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK2->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK2->(MsUnLock())
//      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   //============================================================================
   // Grava dados das comiss�es nas tabela tempor�rias gerente nacional.
   //============================================================================
   //ProcRegua(0)
   IncProc("Lendo dados das comiss�es do Gerente Nacional...")
   
   SA3->(DbSetOrder(1))
       
   _cQry := " SELECT ZBK_GERNAC, "
   _cQry += " SUM(ZBK_COMGNC) AS TOTCOM"
   _cQry += " FROM "+ RetSqlName('ZBK') + " ZBK "
   _cQry += " WHERE "
   _cQry += "     ZBK.D_E_L_E_T_ <> '*' "
   _cQry += " AND SUBSTR( ZBK_DTFECH, 1 , 6 )  = '"+_cPeriodoQry+"' "
   _cQry += " AND ZBK_VERSAO = '" + _cVersao + "' "
   //_cQry += " AND ZBK_SUPERV = '" + _cCodSup + "' "
   _cQry += " AND ZBK_VEND = '" + _cCodVen + "' "   
   _cQry += " GROUP BY ZBK_GERNAC "
   _cQry += " ORDER BY ZBK_GERNAC "

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQRY" , .T. , .F. )

   Do While ! TRBQRY->(Eof()) 

      SA3->(MsSeek(xFilial("SA3")+TRBQRY->ZBK_GERNAC))

      IncProc("Gravando dados Gerente Nacional: " + TRBQRY->ZBK_GERNAC + "-" + AllTrim(SA3->A3_NOME))

      If SA3->A3_I_TIPV == "N"  // N=GERENTE NACIONAL 
         TRBZBK1->(DbAppend())
         TRBZBK1->ZBK_VEND   := TRBQRY->ZBK_GERNAC
         TRBZBK1->ZBK_NOMVEN := SA3->A3_NOME
         TRBZBK1->ZBK_COMVEN := TRBQRY->TOTCOM
         TRBZBK1->ZBK_SUPERV := SA3->A3_I_SUPE 
         TRBZBK1->ZBK_COORDE := SA3->A3_SUPER  
         TRBZBK1->ZBK_GERENT := SA3->A3_GEREN  
         TRBZBK1->ZBK_GERNAC := SA3->A3_I_GERNC
         TRBZBK1->(MsUnLock())
      EndIf 
      
      TRBQRY->(DbSkip())
   EndDo 

   If Select("TRBQRY") > 0
      TRBQRY->( DBCloseArea() )
   EndIf

   TRBZBK1->(DbGoTop())
   TRBZBK2->(DbGoTop())
   TRBZBK3->(DbGoTop())
   TRBZBK4->(DbGoTop())
   TRBZBK5->(DbGoTop())

End Sequence 

Return Nil 

