/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include 'rwmake.ch' 
#include "APWEBSRV.CH"
#Include 'Protheus.ch'  
#INCLUDE "TBICONN.CH"   

/*
===============================================================================================================================
Programa----------: MOMS035
Autor-------------: Alex Wallauer
Data da Criacao---: 30/01/2018
===============================================================================================================================
Descrição---------: Tela de conferência de recebimento físico de canhotos - Chamado 23296
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS035()

LOCAL oDlg
LOCAL _cCodBarra := SPACE(LEN(SF2->F2_FILIAL)+LEN(SF2->F2_DOC)+LEN(SF2->F2_SERIE))
Local aTitulo    := {"Filial","No. Nota Fiscal","Serie","Contador"}
Local aColsSize  := {20,45,20,30} //Tamanho das colunas
Local nLinha:=012
Local nPula :=030
Local nCol1 :=010
Local nColTW:=100
Local nLarg :=130
Local nAltu :=250
Local nLinTl:=510
Local nColTl:=460
Local lGrava:=.F.

PRIVATE _cFil := SUBSTR(_cCodBarra,01,2)
PRIVATE _cNF  := SUBSTR(_cCodBarra,03,9)
PRIVATE _cSer := SUBSTR(_cCodBarra,12,3)
PRIVATE aLista:= {{"","","",0}}

DO WHILE .T.

   nLinha:=012 //Reinicia por causa do LOOP
   IF lGrava//Testa pora causa do LOOP da pergunta, não pode zerar
      aLista:={{"","","",0}}//Reinicia por causa do LOOP
   ENDIF
   lGrava:=.F.//Reinicia por causa do LOOP

   DEFINE MSDIALOG oDlg TITLE "REGISTRO DO CANHOTO" FROM 000, 000  TO nLinTl,nColTl PIXEL

	@ nLinha, nCol1 SAY "Insira o Codigo de Barras"  SIZE 090, 007 PIXEL OF oDlg

	nLinha+=10
	@ nLinha, nCol1 MSGET _cCodBarra                 SIZE 075, 010 PIXEL OF oDlg VALID MOMS035Val(@_cCodBarra)

    oList:=TWBrowse():New(02,nColTW,nLarg,nAltu,,aTitulo,aColsSize,oDlg,,,,,,,,,,,,,"ARRAY",.T.)
  	oList:SetArray(aLista)					
    oList:bLine:={|| {aLista[oList:nAt,1],aLista[oList:nAt,2],aLista[oList:nAt,3],aLista[oList:nAt,4]} }
	
	nLinha+=nPula
	TButton():New(nLinha,nCol1, 'SALVAR', oDlg,{|| lGrava:=.T. , oDlg:End() },075,015,,,,.T.,,,,,,)

	nLinha+=nPula
    TButton():New(nLinha,nCol1, 'SAIR'  , oDlg,{|| lGrava:=.F. , oDlg:End() },075,015,,,,.T.,,,,,,)

   ACTIVATE MSDIALOG oDlg 

   IF lGrava
      FWMSGRUN( ,{|P| MOMS035Grava(P) },"Aguarde!","Gravando Canhotos..."  )
      LOOP
   ELSEIF !EMPTY(aLista[1,1]) .AND. !U_ITMSG("Confirma Sair",'Atenção!',,3,2,2)
      LOOP
   ENDIF

   EXIT

ENDDO

Return

/*
===============================================================================================================================
Programa----------: MOMS035Val()
Autor-------------: Alex Wallauer
Data da Criacao---: 30/01/2018
===============================================================================================================================
Descrição---------: Validação
===============================================================================================================================
Parametros--------: _cCodBarra,aLista
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MOMS035Val(_cCodBarra)
_cFil:=SUBSTR(_cCodBarra,01,2)
_cNF :=SUBSTR(_cCodBarra,03,9)
_cSer:=SUBSTR(_cCodBarra,12,3)

IF EMPTY(_cCodBarra)
   RETURN .T.
ENDIF

SF2->(Dbsetorder(1))
If !SF2->(Dbseek(_cFil+_cNF+_cSer))
   U_ITMSG("Nota não existe: Filial: "+_cFil+", Nota: "+_cNF+", Serie: "+_cSer,"Alteração","Verifique o numero inserido",3)
   RETURN .F.
ENDIF

ZGJ->(Dbsetorder(1))
If ZGJ->(Dbseek(_cFil+_cNF+_cSer))
   U_ITMSG("Canhoto já recepicionado: Filial: "+_cFil+", Nota: "+_cNF+", Serie: "+_cSer,"Alteração","Verifique o numero inserido",3)
   RETURN .F.
ENDIF

IF EMPTY(aLista[1,1])
   aLista [1,1]:=_cFil
   aLista [1,2]:=_cNF
   aLista [1,3]:=_cSer
   aLista [1,4]:=1
ELSEIF ASCAN(aLista, {|L| L[1]+L[2]+L[3] == _cFil+_cNF+_cSer } ) = 0
   AADD(aLista,{_cFil,_cNF,_cSer, LEN(aLista)+1 })
ENDIF
oList:Refresh()

_cCodBarra := SPACE(LEN(SF2->F2_FILIAL)+LEN(SF2->F2_DOC)+LEN(SF2->F2_SERIE))

RETURN .F.

/*
===============================================================================================================================
Programa----------: MOMS035Grava()
Autor-------------: Alex Wallauer
Data da Criacao---: 30/01/2018
===============================================================================================================================
Descrição---------: Gravação
===============================================================================================================================
Parametros--------: aLista
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MOMS035Grava(oProc)
LOCAL L

FOR L := 1 TO LEN(aLista)
	
	oProc:cCaption := ("Gravando NF: "+aLista[L,2])
	ProcessMessages()
	If !ZGJ->(Dbseek(aLista[L,1]+aLista[L,2]+aLista[L,3]))  
		ZGJ->(Reclock("ZGJ",.T.))
		ZGJ->ZGJ_FILIAL:= aLista[L,1]
		ZGJ->ZGJ_NOTA  := aLista[L,2]
		ZGJ->ZGJ_SERIE := aLista[L,3]
		ZGJ->ZGJ_DATAI := DATE()
		ZGJ->ZGJ_HORAI := TIME()
		ZGJ->ZGJ_STATUS:= "Recepcionado"
        IF ZGJ->(FIELDPOS("ZGJ_USERI")) # 0
		   ZGJ->ZGJ_USERI := ALLTRIM(UsrFullName(__cUserId))
		ENDIF
		ZGJ->(Msunlock())  
	ENDIF
	
NEXT

Return .T.