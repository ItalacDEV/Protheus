/*
===============================================================================================================================
                          ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |    Data    |                                             Motivo                                          
-------------------------------------------------------------------------------------------------------------------------------
              |            |
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "PROTHEUS.CH"
#Include "TopConn.ch"
#include "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"   
#INCLUDE "RESTFUL.CH"

/*
===============================================================================================================================
Programa----------: MOMS065
Autor-------------: Igor Fricks Melga�o
Data da Criacao---: 16/05/2022
===============================================================================================================================
Descri��o---------: Processamento do arquivo de Ncm do portal. Chamado 39487.
===============================================================================================================================
Parametros--------: Nenhum
=========================================ZP1======================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User function MOMS065(lAuto)
Default lAuto := .T.

   If lAuto
      PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01';
      TABLES "SYD";
      MODULO 'OMS'

      MOMS065B()

      RESET ENVIRONMENT
   Else
      FwMsgRun(,{|oproc|  MOMS065B() },'Aguarde processamento...','Lendo dados...')
   EndIf

Return .T.



/*
===============================================================================================================================
Programa----------: MOMS065B
Autor-------------: Igor Fricks Melga�o
Data da Criacao---: 17/05/2022
===============================================================================================================================
Descri��o---------: Importa os dados do arquivo. Chamado 39487.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static function MOMS065B(lAuto)
Local dDtNcm     := Ctod("")
Local i          := 0
Local _oJson
Local _cRetHttp  := ""
Local _cRet      := ""
Local _cJSonRet  := Nil 
Local _nTimOut	  := 120
Local _cLinkWS   := ""
Local _cGetParms := "perfil=PUBLICO"
Local _aHeadOut   := {}
Local _cDesc := ""
Local cNcm := ""

dDtNcm     := U_ItGetMV( 'IT_DTNCM' , CTOD("01/01/2001") )
_cLinkWS   := U_ItGetMV( 'IT_SISCOM' ,"https://portalunico.siscomex.gov.br/classif/api/publico/nomenclatura/download/json")

Aadd(_aHeadOut,'Content-Type: application/json') 

_cRetHttp   := MOMS065C(AllTrim(HttpGet( _cLinkWS, _cGetParms, _nTimOut, _aHeadOut, @_cJSonRet)),.T.)
_oJson      := JsonObject():new()
_cRet       := _oJson:FromJson(_cRetHttp)

If ctod(_oJson:GetJsonObject("Data_Ultima_Atualizacao_NCM")) > dDtNcm 

   PutMV( 'IT_DTNCM' , cTod(_oJson:GetJsonObject("Data_Ultima_Atualizacao_NCM")) )

   If ! ValType(_cRet) == "U"
      _cMsgErro := "[FALSO] Erro ao popular o JSon de retorno da Cia do Leite. Problemas no JSon de retorno."
      Break
   EndIf

   _aNames := _oJson:GetNames()
   _oDados := _oJson:GetJsonObject("Nomenclaturas")

   DbSelectArea("SYD")

   If ! ValType(_oDados) == "J"

      For i := 1 to Len(_oDados)

         If Len(_oDados[i]:GetJsonObject("Codigo")) = 10 .And. !Empty(Alltrim(_oDados[i]:GetJsonObject("Descricao")))

            cNcm := Alltrim(StrTran(_oDados[i]:GetJsonObject("Codigo"),".",""))

            SYD->(DbSetOrder(1))
            If SYD->(!DbSeek(xFilial("SYD")+cNcm))

               _cDesc := decodeutf8(_oDados[i]:GetJsonObject("Descricao"),"cp1252")

               If Valtype(_cDesc) == "U"
                  _cDesc := MOMS065C(UPPER(_oDados[i]:GetJsonObject("Descricao"))) 
               Else
                  _cDesc := MOMS065C(UPPER(_cDesc))
               EndIf

               RecLock("SYD",.T.)
                  SYD->YD_TEC      := cNcm
                  SYD->YD_DESC_P   := _cDesc
                  SYD->YD_I_DTINC  := cTod(_oDados[i]:GetJsonObject("Data_Inicio"))
                  SYD->YD_I_DTFIM  := cTod(_oDados[i]:GetJsonObject("Data_Fim"))
                  SYD->YD_I_ORIGE  := "MOMS065"
               MsUnlock()
            Else
               If _oDados[i]:GetJsonObject("Data_Fim") <> "31/12/9999"
                  RecLock("SYD",.F.)
                     SYD->YD_I_DTFIM  := cTod(_oDados[i]:GetJsonObject("Data_Fim"))
                     SYD->YD_I_ORIGE  := "MOMS065"
                  MsUnlock()
               EndIf
            EndIf
         EndIf
      Next

   EndIf
EndIf

Return .T.


/*
===============================================================================================================================
Programa----------: MOMS065C
Autor-------------: Igor Fricks Melga�o
Data da Criacao---: 17/05/2022
===============================================================================================================================
Descri��o---------: Converte os caracteres especiais. Chamado 30177.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS065C(cRetorno,lXML)
Local cCarac := U_ItGetMV( 'IT_CARVAL'," ABCDEFGHIJKLMNOPQRSTUVXYZ1234567890()/\{}[]=+-_%$#@!?:;")
Local i := 0
Local cRet := ""

Default lXML := .F.

If lXML

   cRetorno:=StrTran(cRetorno,"�ndia","India") 
   cRetorno:=StrTran(cRetorno,"ímãs","imas") 
   cRetorno:=StrTran(cRetorno,"á","a") //�
   cRetorno:=StrTran(cRetorno,"�?","A") //�
   cRetorno:=StrTran(cRetorno,"é","e") //�
   cRetorno:=StrTran(cRetorno,"É","E") //�
   cRetorno:=StrTran(cRetorno,"�?","I") //�
   cRetorno:=StrTran(cRetorno,"ó","o") //�
   cRetorno:=StrTran(cRetorno,"Ó","O") //�
   cRetorno:=StrTran(cRetorno,"ú","u") //�
   cRetorno:=StrTran(cRetorno,"ã","a") //�
   cRetorno:=StrTran(cRetorno,"â","a") //�
   cRetorno:=StrTran(cRetorno,"õ","o") //�
   cRetorno:=StrTran(cRetorno,"â","a") //�
   cRetorno:=StrTran(cRetorno,"ê","e") //�
   cRetorno:=StrTran(cRetorno,"ô","o") //�
   cRetorno:=StrTran(cRetorno,"ç","c") //�
   cRetorno:=StrTran(cRetorno,"º","o") //�
   cRetorno:=StrTran(cRetorno," %","%") //%
   cRetorno:=StrTran(cRetorno," °","o") //�
   cRetorno:=StrTran(cRetorno,"�","i") //�

   cRet := cRetorno
Else
   cRetorno:=StrTran(cRetorno,"�?","E")
   cRetorno:=StrTran(cRetorno,"�^","E")
   cRetorno:=StrTran(cRetorno,"^","")
   cRetorno:=StrTran(cRetorno,"�","a")
   cRetorno:=StrTran(cRetorno,"�","A")
   cRetorno:=StrTran(cRetorno,"�","a")
   cRetorno:=StrTran(cRetorno,"�","A")
   cRetorno:=StrTran(cRetorno,"�","a")
   cRetorno:=StrTran(cRetorno,"�","A")
   cRetorno:=StrTran(cRetorno,"�","a")
   cRetorno:=StrTran(cRetorno,"�","A")
   cRetorno:=StrTran(cRetorno,"�","a")
   cRetorno:=StrTran(cRetorno,"�","A")
   cRetorno:=StrTran(cRetorno,"�","e")
   cRetorno:=StrTran(cRetorno,"�","E")
   cRetorno:=StrTran(cRetorno,"�","e")
   cRetorno:=StrTran(cRetorno,"�","E")
   cRetorno:=StrTran(cRetorno,"�","e")
   cRetorno:=StrTran(cRetorno,"�","E")
   cRetorno:=StrTran(cRetorno,"�","i")
   cRetorno:=StrTran(cRetorno,"�","I")
   cRetorno:=StrTran(cRetorno,"�","i")
   cRetorno:=StrTran(cRetorno,"�","I")
   cRetorno:=StrTran(cRetorno,"�","i")
   cRetorno:=StrTran(cRetorno,"�","I")
   cRetorno:=StrTran(cRetorno,"�","y")
   cRetorno:=StrTran(cRetorno,"�","y")
   cRetorno:=StrTran(cRetorno,"�","y")
   cRetorno:=StrTran(cRetorno,"�","o")
   cRetorno:=StrTran(cRetorno,"�","O")
   cRetorno:=StrTran(cRetorno,"�","o")
   cRetorno:=StrTran(cRetorno,"�","O")
   cRetorno:=StrTran(cRetorno,"�","o")
   cRetorno:=StrTran(cRetorno,"�","O")
   cRetorno:=StrTran(cRetorno,"�","o")
   cRetorno:=StrTran(cRetorno,"�","O")
   cRetorno:=StrTran(cRetorno,"�","o")
   cRetorno:=StrTran(cRetorno,"�","O")
   cRetorno:=StrTran(cRetorno,"�","u")
   cRetorno:=StrTran(cRetorno,"�","U")
   cRetorno:=StrTran(cRetorno,"�","u")
   cRetorno:=StrTran(cRetorno,"�","U")
   cRetorno:=StrTran(cRetorno,"�","u")
   cRetorno:=StrTran(cRetorno,"�","U")
   cRetorno:=StrTran(cRetorno,"�","c")
   cRetorno:=StrTran(cRetorno,"�","C")
   cRetorno:=StrTran(cRetorno,"�","o")
   cRetorno:=StrTran(cRetorno,"�","o")
   cRetorno:=StrTran(cRetorno,"�","a")
   cRetorno:=StrTran(cRetorno,"�","n")
   cRetorno:=StrTran(cRetorno,"�","N")
   cRetorno:=StrTran(cRetorno,"�","2")
   cRetorno:=StrTran(cRetorno,"�","3")
   cRetorno:=StrTran(cRetorno,"�","'")
   cRetorno:=StrTran(cRetorno,"�","S")
   cRetorno:=StrTran(cRetorno,"�","+")
   cRetorno:=StrTran(cRetorno,"�","-")
   cRetorno:=StrTran(cRetorno,"�","'")
   cRetorno:=StrTran(cRetorno,"o","o")
   cRetorno:=StrTran(cRetorno,"�","u")
   cRetorno:=StrTran(cRetorno,"�","1/4")
   cRetorno:=StrTran(cRetorno,"�","1/2")
   cRetorno:=StrTran(cRetorno,"�","3/4")
   cRetorno:=StrTran(cRetorno,"&","e") 
   cRetorno:=StrTran(cRetorno,";",",")
   cRetorno:=StrTran(cRetorno,"�","i")
   cRetorno:=StrTran(cRetorno,"�","c.")
   cRetorno:=StrTran(cRetorno,"�","r.")
   cRetorno:=StrTran(cRetorno,"�","L")
   cRetorno:=StrTran(cRetorno,"�","t")
   cRetorno:=StrTran(cRetorno,"�","f")
   cRetorno:=StrTran(cRetorno,"�","-")
   cRetorno:=StrTran(cRetorno,"!","")
   cRetorno:=StrTran(cRetorno,"�","x")
   cRetorno:=StrTran(cRetorno,"�","")
   cRetorno:=StrTran(cRetorno,"�","")
   cRetorno:=StrTran(cRetorno," -- ","")
   cRetorno:=StrTran(cRetorno,"-- ","")
   cRetorno:=StrTran(cRetorno,"- ","")
   cRetorno:=StrTran(cRetorno,Chr(13)+Chr(10)," ")
   cRetorno:=StrTran(cRetorno,"<i>","")
   cRetorno:=StrTran(cRetorno,"</i>","")
   cRetorno:=StrTran(cRetorno,"i-","i")
   cRetorno:=StrTran(cRetorno,"I-","I")
   cRetorno:=StrTran(cRetorno,"'"," ")

   For i := 1 To Len(cRetorno)
      If Upper(Subs(cRetorno,i,1)) $ cCarac
         cRet += Subs(cRetorno,i,1)
      Else
         cRet += " "
      EndIf
   Next

EndIf

Return cRet
