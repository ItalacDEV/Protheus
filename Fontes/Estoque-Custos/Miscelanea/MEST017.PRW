/*
===============================================================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================================================================
   Autor         |    Data    |                              Motivo                      										 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
 Alex Wallauer   | 04/04/2018 | inclusão do PARAMETRO "IT_TXFUNDES" - Chamado 28650
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
 Alex Wallauer   | 08/05/2018 | Ajustes para parametros novos IT_MPDESMON e IT_PATRANS  - Chamado 29221
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
 Alex Wallauer   | 10/07/2018 | Ajustes para parametro novo IT_CRETCUST - Chamado 29718
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
 Alex Wallauer   | 21/08/2018 | Ajustes p/ parametros novos IT_FAFRVEN/IT_VOLUAGUA/IT_OUTROMOV - Chamado 30301
===============================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"  
#Include "TopConn.ch"

#DEFINE _ENTER CHR(13)+CHR(10)      

/*
===============================================================================================================================
Programa----------: MEST017
Autor-------------: Alex Wallauer
Data da Criacao---: 23/12/2018
===============================================================================================================================
Descrição---------: Rotina de atualização de parâmetros de EMCARGOS PARA FOLHA DE PAGAMENTO - CUSTO GERENCIAL - Chamado 27368
8===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MEST017()       

Local _cPict := "@E 999.999"
Local _cPict2:= "@E 9.9999999"
Local _cPict5:= "@E 999.99999"
Local _cPictI:= "@E 999,999,999.99999"
Local _cPictC:= "@!"

//VERIFICA PERMISSÕES DE ACESSO
Private _lRet1 := .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )
//Private _lRet2 := .F.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )//NÃO USA MAIS
Private _lRet3 := .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )
//Private _lRet4 := .F.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )//NÃO USA MAIS
Private _lRet5 := .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )

Private _lRetA := .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )
Private _lRetB := .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )
Private _lRetB2:= .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )
Private _lRetC := .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )
Private _lRetC2:= .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )
Private _lRetD := .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )
Private _lRetE := .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )
Private _lRetF := .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )
Private _lRetF2:= .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )
Private _lRetG := .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )
Private _lRetH := .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )
Private _lRetI := .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )
Private _lRetJ := .T.//U_ITVACESS( 'ZZL' , 3 , 'ZZL_' , "S" )

Private _oDlg				// Dialog Principal
Private _lcontinua := .T.
oMainWnd:ReadClientCoords()//So precisa declarar uma fez para o Programa todo                                                                                

//PASTA 1 "EMCARGOS P/ FOLHA DE PAGAMENTO E FRETE"
Private _cPerg1 := {"Ferias (%) ?"                ,"IT_FERIAS - Digite o percentual de Ferias"}
//Private _cPerg2 := {"Encargos de Ferias (%) ? "   ,"IT_EFERIA - Digite o percentual de Encargos de Ferias"}
Private _cPerg3 := {"13 Salario (%) ?"            ,"IT_13SALA - Digite o percentual de 13 Salario"}
//Private _cPerg4 := {"Encargos de 13 Salario (%) ?","IT_E13SAL - Digite o percentual de Encargos de 13 Salario"}
Private _cPerg5 := {"Fator Frete Vendas ?"        ,"IT_FAFRVEN - Digite o Fator Frete Vendas"}
//PASTA 2 "VOLUME DO LEITE"
Private _cPergA := {"Postos de captação?"                  ,"IT_POSTCAPT - Informar nesse parametro quais são os postos de captação"}
Private _cPergB := {"Produtos MP para composição do vol.?" ,"IT_MPCUSTO  - Informar produtos que irão compor o volume através das entradas do leite para quando a filial for posto de captação e quando não for posto, a soma dos produtos informados será através das requisições para a produção(consumo)"}
Private _cPergB2:= {"Considera Desmontagens dos Produtos MP acima?","IT_MPDESMON - Considera Desmontagens dos Produtos MP acima"}
Private _cPergC := {"Produtos PA para composição do vol.?" ,"IT_PACUSTO  - A soma das produções dos PAs informados nesse parâmetro irão compor o volume total"}
Private _cPergC2:= {"Considera Transferencias (550) dos Produtos PA acima?","IT_PATRANS - Considera Transferencias (550) dos Produtos PA acima"}
Private _cPergD := {"Centros Custo das MPs p/ compor vol?.","IT_MPCCUST  - Os centros de custos informados aqui irão filtrar a soma do volume para os produtos informados nesse parametro"}
Private _cPergE := {"Centros Custo das PAs p/ compor vol.?","IT_PACCUST  - Os centros de custos informados aqui irão filtrar a soma do volume para os produtos informados nesse parametro"}
Private _cPergF := {"Produtos de retorno?"                 ,"IT_RETCUST  - Os produtos informados aqui são os que tiveram retorno para os estoque através da produção"}
Private _cPergF2:= {"Para compor vol.?"                    ,"IT_CRETCUST - Os produtos informados acima serão somados ou descontados no volume total"}
Private _cPergG := {"Filais para somar no volume?"         ,"IT_FILSOMA  - Caso o volume total seja através da soma de dados de mais de uma filial informar aqui quais são as filiais, caso seja somente de uma não há necessidade de preencher. O conteudo deste parametro será somente processado caso nas perguntas de execução da leitura de regras a pergunta 'Soma Litragem' estiver como 'Sim'"}
Private _cPergH := {"Especifico RS - Taxa FUNDESA?"        ,"IT_TXFUNDES - Taxa de contribuição a ser aplicada no volume compro/recebido Leite/MP, valor de contribuição para o Fundo de Desenvolvimento e Defesa Sanitária Animal do Rio Grande do Sul - FUNDESA."}
Private _cPergI := {"Volume Agua ?"                        ,"IT_VOLUAGUA - Volume da agua aplicado no total de litros leite por consumo de materia prima."}
Private _cPergJ := {"Outro Mov. ?"                         ,"IT_OUTROMOV - Outro movimento aplicado no total de litros leite por consumo de materia prima."}

//MONTA VARIAVEIS
//PASTA 1 "EMCARGOS P/ FOLHA DE PAGAMENTO"
Private _nIT_FERIAS  := VAL(U_ITGetMV("IT_FERIAS","11.107"))
//Private _nIT_EFERIA  := VAL(U_ITGetMV("IT_EFERIA","04.130"))
Private _nIT_13SALA  := VAL(U_ITGetMV("IT_13SALA","08.330"))
//Private _nIT_E13SAL  := VAL(U_ITGetMV("IT_E13SAL","03.100"))
//PASTA 2 "VOLUME DO LEITE"
Private _cIT_POSTCAPT:= U_ITGetMV("IT_POSTCAPT",SPACE(LEN(ZP1->ZP1_CONTEU)))
Private _cIT_MPCUSTO := U_ITGetMV("IT_MPCUSTO",SPACE(LEN(ZP1->ZP1_CONTEU)))
Private _cIT_PACUSTO := U_ITGetMV("IT_PACUSTO",SPACE(LEN(ZP1->ZP1_CONTEU)))
Private _cIT_MPCCUST := U_ITGetMV("IT_MPCCUST",SPACE(LEN(ZP1->ZP1_CONTEU)))
Private _cIT_PACCUST := U_ITGetMV("IT_PACCUST",SPACE(LEN(ZP1->ZP1_CONTEU)))
Private _cIT_RETCUST := U_ITGetMV("IT_RETCUST",SPACE(LEN(ZP1->ZP1_CONTEU)))
Private _cIT_FILSOMA := U_ITGetMV("IT_FILSOMA",SPACE(LEN(ZP1->ZP1_CONTEU)))
Private _nIT_TXFUNDE := U_ITGetMV("IT_TXFUNDES",0)

If  _lRet5
    _aOp5:={}
	AADD(_aOp5,"Multiplicar")
	AADD(_aOp5,"Dividir    ")
    _nIT_FAFRVEN := U_ITGetMV("IT_FAFRVEN","0*")
	IF "*" $ _nIT_FAFRVEN
	   _nIT_FAFRVEN:= VAL(_nIT_FAFRVEN)
	   _cIT_FAFRVEN:= "Multiplicar"
    ELSEIF "/" $ _nIT_FAFRVEN 
	   _nIT_FAFRVEN:= VAL(_nIT_FAFRVEN)
	   _cIT_FAFRVEN:= "Dividir    "
	ENDIF
Endif

If  _lRetB2
	_cIT_MPDESMON:=U_ITGETMV("IT_MPDESMON","N") 
	IF VALTYPE(_cIT_MPDESMON) = "L"
	   _cIT_MPDESMON:="N"
	ENDIF
	IF _cIT_MPDESMON = "S"
	   _cIT_MPDESMON:= "Sim"
    ELSEIF _cIT_MPDESMON = "A"
	   _cIT_MPDESMON:= "Ambos"
    ELSE
	   _cIT_MPDESMON:= "Nao"
	ENDIF
Endif

If  _lRetC2
	_cIT_PATRANS:=U_ITGETMV("IT_PATRANS","N")
	IF VALTYPE(_cIT_PATRANS) = "L"
	   _cIT_PATRANS:="N"
	ENDIF
	IF _cIT_PATRANS = "S"
	   _cIT_PATRANS:= "Sim"
    ELSEIF _cIT_PATRANS = "A"
	   _cIT_PATRANS:= "Ambos"
    ELSE
	   _cIT_PATRANS:= "Nao"
	ENDIF
Endif

If  _lRetF2
    _aOpF2:={}
	AADD(_aOpF2,"1-Soma DE1")
	AADD(_aOpF2,"2-Desconta DE1")
	AADD(_aOpF2,"3-Soma RE7")
	AADD(_aOpF2,"4-Desconta RE7")
	AADD(_aOpF2,"5-Soma Ambos")
	AADD(_aOpF2,"6-Desconta Ambos")

	_cIT_CRETCUST:=VAL(U_ITGETMV("IT_CRETCUST","4"))
	IF _cIT_CRETCUST >  0 .AND. _cIT_CRETCUST <= LEN(_aOpF2)
	   _cIT_CRETCUST:= _aOpF2[_cIT_CRETCUST]
	ELSE   
	   _cIT_CRETCUST:= _aOpF2[4]
	ENDIF
Endif

If  _lRetI
    _aOpI:={}
	AADD(_aOpI,"Somar ")
	AADD(_aOpI,"Abater")
    _nIT_VOLUAGUA:= U_ITGetMV("IT_VOLUAGUA",0)
	IF _nIT_VOLUAGUA >= 0
	   _cIT_VOLUAGUA:= "Somar "
    ELSE
	   _nIT_VOLUAGUA:= _nIT_VOLUAGUA * -1
	   _cIT_VOLUAGUA:= "Abater"
	ENDIF
Endif

If  _lRetJ
    _aOpJ:={}
	AADD(_aOpJ,"Somar ")
	AADD(_aOpJ,"Abater")
    _nIT_OUTROMOV:= U_ITGetMV("IT_OUTROMOV",0)
	IF _nIT_OUTROMOV >= 0
	   _cIT_OUTROMOV:= "Somar "
    ELSE
	   _nIT_OUTROMOV:= _nIT_OUTROMOV * -1
	   _cIT_OUTROMOV:= "Abater"
	ENDIF
Endif

_cIT_POSTCAPT:= _cIT_POSTCAPT+SPACE(LEN(ZP1->ZP1_CONTEU)-LEN(_cIT_POSTCAPT))
_cIT_MPCUSTO := _cIT_MPCUSTO +SPACE(LEN(ZP1->ZP1_CONTEU)-LEN(_cIT_MPCUSTO))
_cIT_PACUSTO := _cIT_PACUSTO +SPACE(LEN(ZP1->ZP1_CONTEU)-LEN(_cIT_PACUSTO))
_cIT_MPCCUST := _cIT_MPCCUST +SPACE(LEN(ZP1->ZP1_CONTEU)-LEN(_cIT_MPCCUST))
_cIT_PACCUST := _cIT_PACCUST +SPACE(LEN(ZP1->ZP1_CONTEU)-LEN(_cIT_PACCUST))
_cIT_RETCUST := _cIT_RETCUST +SPACE(LEN(ZP1->ZP1_CONTEU)-LEN(_cIT_RETCUST))
_cIT_FILSOMA := _cIT_FILSOMA +SPACE(LEN(ZP1->ZP1_CONTEU)-LEN(_cIT_FILSOMA))

nposv := 005
nposh := 010
navav := 040
navah := 230
//*****************************************************************************************************************************
*******************************************************************************************************************************
nQuebra:=007//ESSA É QUANTIDADE DE GET DE CADA LADO Ex. se for 10 no total coloca 5 se 12 coloca 6 e assim por diante
*******************************************************************************************************************************
//*****************************************************************************************************************************
//Monta array de posições
_ni  := 0
_nqt := 15
apos := {}	
nQuebra--//Tem que tirar para dar certo
DO WHILE _ni <= _nqt
  
	AADD(apos,{nposv + ( iif(_ni > nQuebra, _ni - (nQuebra+1), _ni) * navav ), (iif(_ni > nQuebra, 1,0) * navah) + nposh})
	_ni++
	
ENDDO

_nInicio   :=  MEST017T(015)

_nColFolder:=  MEST017T(500)//LARGURA
_nLinFolder:=  MEST017T(275)//ALTURA

_nColPanel :=  MEST017T(500)//LARGURA
_nLinPanel :=  MEST017T(250)//ALTURA

_lcontinua := .T.

Do while _lcontinua
	
	_ni := 1
	_lcontinua :=.T.

	DEFINE MSDIALOG _oDlg TITLE "CUSTO GERENCIAL - PARAMETROS" FROM MEST017T(000),MEST017T(000) TO MEST017T(585),MEST017T(1000) PIXEL
	

	@ MEST017T(2),MEST017T(150) Button "Atualizar Parametros" Size MEST017T(080),MEST017T(013) PIXEL OF _oDlg ACTION(MsgRun("Processando alteracao, aguarde...",,{|| _lcontinua := MEST017C(_oDlg)}))
	
	@ MEST017T(2),MEST017T(250) Button "SAIR" Size MEST017T(080),MEST017T(013) PIXEL OF _oDlg ACTION(Close(_oDlg))

    _aFoders:={"EMCARGOS P/ FOLHA DE PAGAMENTO E FRETE","VOLUME DO LEITE"}

    oTFolder1:= TFolder():New( _nInicio,1,_aFoders,,_oDlg,,,,.T., , _nColFolder,_nLinFolder )
//              TScrollBox():New( [ oWnd ]            ,[ nTop ],[ nLeft],[ nHeight ] , [ nWidth],lVertical,lHorizontal,lBorder)
	oPanel	 := TScrollBox():New(oTFolder1:aDialogs[1], 1      ,1       ,_nLinPanel,_nColPanel-5,.T.      ,.T.        ,.T.)

	If _ni <= len(apos) .and. _lRet1
		
		@ MEST017T(apos[_ni][1]),MEST017T(apos[_ni][2]) TO MEST017T(apos[_ni][1]+35),MEST017T(apos[_ni][2]+216)  PIXEL OF oPanel
		
		@ MEST017T(apos[_ni][1]+14),MEST017T(apos[_ni][2] +4) Say _cPerg1[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel
		
		@ MEST017T(apos[_ni][1]+13),MEST017T(apos[_ni][2] + 160) MSGET _oIT_FERIAS VAR _nIT_FERIAS Size MEST017T(030),MEST017T(008) COLOR CLR_BLACK Picture _cPict PIXEL OF oPanel VALID POSITIVO()

        _oIT_FERIAS:bHelp:={|| ShowHelpCpo("_nIT_FERIAS",{_cPerg1[2]},2,;
                                                         {"Deve ser Positivo"},2)}		
		_ni++
		
	Endif
	
/*	If _ni <= len(apos) .and. _lRet2
		@ MEST017T(apos[_ni][1]),MEST017T(apos[_ni][2]) TO MEST017T(apos[_ni][1]+35),MEST017T(apos[_ni][2]+216)  PIXEL OF oPanel
		@ MEST017T(apos[_ni][1]+14),MEST017T(apos[_ni][2] + 4) Say _cPerg2[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel
		@ MEST017T(apos[_ni][1]+13),MEST017T(apos[_ni][2] + 150) MsGet _oIT_EFERIA VAR _nIT_EFERIA Size MEST017T(030),MEST017T(008) COLOR CLR_BLACK  Picture _cPict PIXEL OF oPanel VALID POSITIVO()
        _oIT_EFERIA:bHelp:={|| ShowHelpCpo("_nIT_EFERIA",{_cPerg2[2]},2,{"Deve ser Positivo"},2)}		
		_ni++
	Endif*/
	
	
	If _ni <= len(apos) .and. _lRet3
		
		@ MEST017T(apos[_ni][1]),MEST017T(apos[_ni][2]) TO MEST017T(apos[_ni][1]+35),MEST017T(apos[_ni][2]+216)  PIXEL OF oPanel
		
		@ MEST017T(apos[_ni][1]+14),MEST017T(apos[_ni][2] +4) Say  _cPerg3[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel
		
		@ MEST017T(apos[_ni][1]+13),MEST017T(apos[_ni][2] + 160) MsGet _oIT_13SALA VAR _nIT_13SALA Size MEST017T(030),MEST017T(008) COLOR CLR_BLACK Picture _cPict PIXEL OF oPanel VALID POSITIVO()

        _oIT_13SALA:bHelp:={|| ShowHelpCpo("_nIT_13SALA",{_cPerg3[2]},2,;
                                                         {"Deve ser Positivo"},2)}		
		
		_ni++
		
	Endif
	
/*	If _ni <= len(apos) .and. _lRet4
		@ MEST017T(apos[_ni][1]),MEST017T(apos[_ni][2]) TO MEST017T(apos[_ni][1]+35),MEST017T(apos[_ni][2]+216)  PIXEL OF oPanel
		@ MEST017T(apos[_ni][1]+14),MEST017T(apos[_ni][2] +4) Say _cPerg4[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel
		@ MEST017T(apos[_ni][1]+13),MEST017T(apos[_ni][2] + 150) MsGet _oIT_E13SAL VAR _nIT_E13SAL Size MEST017T(030),MEST017T(008) COLOR CLR_BLACK Picture _cPict PIXEL OF oPanel VALID POSITIVO()
        _oIT_E13SAL:bHelp:={|| ShowHelpCpo("_nIT_E13SAL",{_cPerg4[2]},2,{"Deve ser Positivo"},2)}		
		_ni++
	Endif*/

	If _ni <= len(apos) .and. _lRet5
		
		@ MEST017T(apos[_ni][1]),MEST017T(apos[_ni][2]) TO MEST017T(apos[_ni][1]+35),MEST017T(apos[_ni][2]+216)  PIXEL OF oPanel
		
		@ MEST017T(apos[_ni][1]+14),MEST017T(apos[_ni][2] +4) Say _cPerg5[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel
		
		@ MEST017T(apos[_ni][1]+13),MEST017T(apos[_ni][2]+80) MsGet    _oIT_FAFRVEN  VAR _nIT_FAFRVEN SIZE MEST017T(060),MEST017T(008) COLOR CLR_BLACK PICTURE _cPict5 PIXEL OF oPanel VALID POSITIVO()
        _oIT_FAFRVEN:bHelp:={|| ShowHelpCpo("_nIT_FAFRVEN",{_cPerg5[2]},2,{"Deve ser Positivo"},2)}		

		@ MEST017T(apos[_ni][1]+13),MEST017T(apos[_ni][2]+150) COMBOBOX _ocIT_FAFRVEN VAR _cIT_FAFRVEN SIZE MEST017T(045),MEST017T(010) COLOR CLR_BLACK  PIXEL OF oPanel ITEMS _aOp5
		_ocIT_FAFRVEN:bHelp:={|| ShowHelpCpo("_cIT_FAFRVEN",{_cPergF2[2]},2,{'Escolha uma das opcoes'},2)}
		
		_ni++
		
	Endif

///////////////// *****************  PASTA 2 - VOLUME DO LEITE

//             TScrollBox():New( [ oWnd ]            ,[ nTop ],[ nLeft],[ nHeight ] , [ nWidth],lVertical,lHorizontal,lBorder)
	oPanel2 := TScrollBox():New(oTFolder1:aDialogs[2], 1      ,1       ,_nLinPanel,_nColPanel-5,.T.      ,.T.        ,.T.)
	_ni2 := 1

	If _ni2 <= len(apos) .and. _lRetA
		@ MEST017T(apos[_ni2][1]),MEST017T(apos[_ni2][2]) TO MEST017T(apos[_ni2][1]+35),MEST017T(apos[_ni2][2]+216)  PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+14),MEST017T(apos[_ni2][2] +4) Say _cPergA[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2] +100) MSGET _oIT_POSTCAPT VAR _cIT_POSTCAPT Size MEST017T(100),MEST017T(008) COLOR CLR_BLACK Picture _cPictC PIXEL OF oPanel2
        _oIT_POSTCAPT:bHelp:={|| ShowHelpCpo("_cIT_POSTCAPT",{_cPergA[2]},2,{'Separe os codigos com ponto e virgula ";"'},2)}
		_ni2++
	Endif

	If _ni2 <= len(apos) .and. _lRetB
		@ MEST017T(apos[_ni2][1]),MEST017T(apos[_ni2][2]) TO MEST017T(apos[_ni2][1]+35),MEST017T(apos[_ni2][2]+216)  PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+14),MEST017T(apos[_ni2][2] +4) Say _cPergB[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2] +100) MSGET _oIT_MPCUSTO VAR _cIT_MPCUSTO Size MEST017T(100),MEST017T(008) COLOR CLR_BLACK Picture _cPictC PIXEL OF oPanel2
        _oIT_MPCUSTO:bHelp:={|| ShowHelpCpo("_cIT_MPCUSTO",{_cPergB[2]},2,{'Separe os codigos com ponto e virgula ";"'},2)}
		_ni2++
	Endif

	If _ni2 <= len(apos) .and. _lRetB2
		@ MEST017T(apos[_ni2][1]),MEST017T(apos[_ni2][2]) TO MEST017T(apos[_ni2][1]+35),MEST017T(apos[_ni2][2]+216)  PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+14),MEST017T(apos[_ni2][2]+4) Say _cPergB2[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2]+160) COMBOBOX _oIT_MPDESMON VAR _cIT_MPDESMON Size MEST017T(040),MEST017T(010) COLOR CLR_BLACK  PIXEL OF oPanel2 ITEMS {"Sim","Nao","Ambos"}
		_oIT_MPDESMON:bHelp:={|| ShowHelpCpo("_cIT_MPDESMON",{_cPergB2[2]},2,{'Escolha uma opcao Sim ou Nao ou Ambos'},2)}
		_ni2++
	Endif

	If _ni2 <= len(apos) .and. _lRetC
		@ MEST017T(apos[_ni2][1]),MEST017T(apos[_ni2][2]) TO MEST017T(apos[_ni2][1]+35),MEST017T(apos[_ni2][2]+216)  PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+14),MEST017T(apos[_ni2][2] +4) Say _cPergC[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2] +100) MSGET _oIT_PACUSTO VAR _cIT_PACUSTO Size MEST017T(100),MEST017T(008) COLOR CLR_BLACK Picture _cPictC PIXEL OF oPanel2
        _oIT_PACUSTO:bHelp:={|| ShowHelpCpo("_cIT_PACUSTO",{_cPergC[2]},2,{'Separe os codigos com ponto e virgula ";"'},2)}
		_ni2++
	Endif

	If _ni2 <= len(apos) .and. _lRetC2
		@ MEST017T(apos[_ni2][1]),MEST017T(apos[_ni2][2]) TO MEST017T(apos[_ni2][1]+35),MEST017T(apos[_ni2][2]+216)  PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+14),MEST017T(apos[_ni2][2] +4) Say _cPergC2[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2] +160) COMBOBOX _oIT_PATRANS VAR _cIT_PATRANS Size MEST017T(040),MEST017T(010) COLOR CLR_BLACK  PIXEL OF oPanel2 ITEMS {"Sim","Nao","Ambos"}
		_oIT_PATRANS:bHelp:={|| ShowHelpCpo("_cIT_PATRANS",{_cPergC2[2]},2,{'Escolha uma opcao Sim ou Nao ou Ambos'},2)}
		_ni2++
	Endif

	If _ni2 <= len(apos) .and. _lRetD
		@ MEST017T(apos[_ni2][1]),MEST017T(apos[_ni2][2]) TO MEST017T(apos[_ni2][1]+35),MEST017T(apos[_ni2][2]+216)  PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+14),MEST017T(apos[_ni2][2] +4) Say _cPergD[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2] +100) MSGET _oIT_MPCCUST VAR _cIT_MPCCUST Size MEST017T(100),MEST017T(008) COLOR CLR_BLACK Picture _cPictC PIXEL OF oPanel2
        _oIT_MPCCUST:bHelp:={|| ShowHelpCpo("_cIT_MPCCUST",{_cPergD[2]},2,{'Separe os codigos com ponto e virgula ";"'},2)}
		_ni2++
	Endif
	
	If _ni2 <= len(apos) .and. _lRetE
		@ MEST017T(apos[_ni2][1]),MEST017T(apos[_ni2][2]) TO MEST017T(apos[_ni2][1]+35),MEST017T(apos[_ni2][2]+216)  PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+14),MEST017T(apos[_ni2][2] +4) Say _cPergE[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2] +100) MSGET _oIT_PACCUST VAR _cIT_PACCUST Size MEST017T(100),MEST017T(008) COLOR CLR_BLACK Picture _cPictC PIXEL OF oPanel2
        _oIT_PACCUST:bHelp:={|| ShowHelpCpo("_cIT_PACCUST",{_cPergE[2]},2,{'Separe os codigos com ponto e virgula ";"'},2)}
		_ni2++
	Endif
	
	If _ni2 <= len(apos) .and. _lRetF
		@ MEST017T(apos[_ni2][1]),MEST017T(apos[_ni2][2]) TO MEST017T(apos[_ni2][1]+35),MEST017T(apos[_ni2][2]+216)  PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+14),MEST017T(apos[_ni2][2] +4) Say _cPergF[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2] +100) MSGET _oIT_RETCUST VAR _cIT_RETCUST Size MEST017T(100),MEST017T(008) COLOR CLR_BLACK  Picture _cPictC PIXEL OF oPanel2
        _oIT_RETCUST:bHelp:={|| ShowHelpCpo("_cIT_RETCUST",{_cPergF[2]},2,{'Separe os codigos com ponto e virgula ";"'},2)}
		_ni2++
	Endif

	If _ni2 <= len(apos) .and. _lRetF2
		@ MEST017T(apos[_ni2][1]),MEST017T(apos[_ni2][2]) TO MEST017T(apos[_ni2][1]+35),MEST017T(apos[_ni2][2]+216)  PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+14),MEST017T(apos[_ni2][2] +4) Say _cPergF2[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2] +135) COMBOBOX _oIT_CRETCUST VAR _cIT_CRETCUST Size MEST017T(065),MEST017T(010) COLOR CLR_BLACK  PIXEL OF oPanel2 ITEMS _aOpF2
		_oIT_CRETCUST:bHelp:={|| ShowHelpCpo("_cIT_CRETCUST",{_cPergF2[2]},2,{'Escolha uma das opcoes'},2)}
		_ni2++
	Endif
	
	If _ni2 <= len(apos) .and. _lRetG
		@ MEST017T(apos[_ni2][1]),MEST017T(apos[_ni2][2]) TO MEST017T(apos[_ni2][1]+35),MEST017T(apos[_ni2][2]+216)  PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+14),MEST017T(apos[_ni2][2] +4) Say _cPergG[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2] +100) MSGET _oIT_FILSOMA VAR _cIT_FILSOMA Size MEST017T(100),MEST017T(008) COLOR CLR_BLACK Picture _cPictC PIXEL OF oPanel2
        _oIT_FILSOMA:bHelp:={|| ShowHelpCpo("_cIT_FILSOMA",{_cPergG[2]},2,{'Separe os codigos com ponto e virgula ";"'},2)}
		_ni2++
	Endif

	If _ni2 <= len(apos) .and. _lRetH
		@ MEST017T(apos[_ni2][1]),MEST017T(apos[_ni2][2]) TO MEST017T(apos[_ni2][1]+35),MEST017T(apos[_ni2][2]+216)  PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+14),MEST017T(apos[_ni2][2] +4) Say _cPergH[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2] +100) MsGet _oIT_TXFUNDE VAR _nIT_TXFUNDE Size MEST017T(100),MEST017T(008) COLOR CLR_BLACK Picture _cPict2 PIXEL OF oPanel2 VALID POSITIVO()
        _oIT_TXFUNDE:bHelp:={|| ShowHelpCpo("_nIT_TXFUNDE",{_cPergH[2]},2,{"Deve ser Positivo"},2)}
		_ni2++
	Endif

	If _ni2 <= len(apos) .and. _lRetI
		@ MEST017T(apos[_ni2][1]),MEST017T(apos[_ni2][2]) TO MEST017T(apos[_ni2][1]+35),MEST017T(apos[_ni2][2]+216)  PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+14),MEST017T(apos[_ni2][2] +4) Say _cPergI[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2]+080) MsGet    _oIT_VOLUAGUA  VAR _nIT_VOLUAGUA SIZE MEST017T(060),MEST017T(008) COLOR CLR_BLACK PICTURE _cPictI PIXEL OF oPanel2 VALID POSITIVO()
        _oIT_VOLUAGUA:bHelp:={|| ShowHelpCpo("_nIT_VOLUAGUA",{_cPergI[2]},2,{"Deve ser Positivo"},2)}		
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2] +160) COMBOBOX _ocIT_VOLUAGUA VAR _cIT_VOLUAGUA Size MEST017T(040),MEST017T(010) COLOR CLR_BLACK  PIXEL OF oPanel2 ITEMS _aOpI
		_ocIT_VOLUAGUA:bHelp:={|| ShowHelpCpo("_cIT_VOLUAGUA",{_cPergI[2]},2,{'Escolha uma opcao Somar ou Abater'},2)}
		_ni2++
	Endif

	If _ni2 <= len(apos) .and. _lRetJ
		@ MEST017T(apos[_ni2][1]),MEST017T(apos[_ni2][2]) TO MEST017T(apos[_ni2][1]+35),MEST017T(apos[_ni2][2]+216)  PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+14),MEST017T(apos[_ni2][2] +4) Say _cPergJ[1] Size MEST017T(150),MEST017T(015) COLOR CLR_BLACK PIXEL OF oPanel2
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2]+080) MsGet    _oIT_OUTROMOV VAR _nIT_OUTROMOV SIZE MEST017T(060),MEST017T(008) COLOR CLR_BLACK PICTURE _cPictI PIXEL OF oPanel2 VALID POSITIVO()
        _oIT_OUTROMOV:bHelp:={|| ShowHelpCpo("_nIT_OUTROMOV",{_cPergJ[2]},2,{"Deve ser Positivo"},2)}		
		@ MEST017T(apos[_ni2][1]+13),MEST017T(apos[_ni2][2] +160) COMBOBOX _ocIT_OUTROMOV VAR _cIT_OUTROMOV Size MEST017T(040),MEST017T(010) COLOR CLR_BLACK  PIXEL OF oPanel2 ITEMS _aOpJ
		_ocIT_OUTROMOV:bHelp:={|| ShowHelpCpo("_cIT_OUTROMOV",{_cPergJ[2]},2,{'Escolha uma opcao Somar ou Abater'},2)}
		_ni2++
	Endif

	ACTIVATE MSDIALOG _oDlg CENTERED

	_lcontinua :=.F.
	
Enddo

Return(.T.)
/*
===============================================================================================================================
Programa----------: MEST017C
Autor-------------: Josué Danich 
Data da Criacao---: 09/01/2017
===============================================================================================================================
Descrição---------: Atualiza parâmetros da filial corrente 
===============================================================================================================================
Parametros--------: _cArmazem - Armazem CQ
					dDtUlMes
					_nporcenta
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST017C(_oDlg)     

Local _alog := {} , V
Local _aVal := {}
cFilAnt:=cFilAnt
        
AADD(_aVal,{"IT_FERIAS",STR(_nIT_FERIAS,8,3),_lRet1,_cPerg1,"C"})
//AADD(_aVal,{"IT_EFERIA",STR(_nIT_EFERIA,8,3),_lRet2,_cPerg2,"C"})
AADD(_aVal,{"IT_13SALA",STR(_nIT_13SALA,8,3),_lRet3,_cPerg3,"C"})
//AADD(_aVal,{"IT_E13SAL",STR(_nIT_E13SAL,8,3),_lRet4,_cPerg4,"C"})
AADD(_aVal,{"IT_FAFRVEN",STR(_nIT_FAFRVEN,9,5)+IF(_cIT_FAFRVEN="Multiplicar","*","/"),_lRet5,_cPerg5,"C"})
AADD(_aVal,{"IT_POSTCAPT",_cIT_POSTCAPT,_lRetA ,_cPergA,"C"})
AADD(_aVal,{"IT_MPCUSTO" ,_cIT_MPCUSTO ,_lRetB ,_cPergB,"C"})
AADD(_aVal,{"IT_MPDESMON",IF(_cIT_MPDESMON="Sim","S",IF(_cIT_MPDESMON="Ambos","A","N")),_lRetB2,_cPergB2,"C"})
AADD(_aVal,{"IT_PACUSTO" ,_cIT_PACUSTO ,_lRetC ,_cPergC ,"C"})
AADD(_aVal,{"IT_PATRANS" ,IF(_cIT_PATRANS ="Sim","S",IF(_cIT_MPDESMON="Ambos","A","N")),_lRetC2,_cPergC2,"C"})
AADD(_aVal,{"IT_MPCCUST" ,_cIT_MPCCUST ,_lRetD ,_cPergD ,"C"})
AADD(_aVal,{"IT_PACCUST" ,_cIT_PACCUST ,_lRetE ,_cPergE ,"C"})
AADD(_aVal,{"IT_RETCUST" ,_cIT_RETCUST ,_lRetF ,_cPergF ,"C"})
AADD(_aVal,{"IT_CRETCUST",_cIT_CRETCUST,_lRetF2,_cPergF2,"C"})
AADD(_aVal,{"IT_FILSOMA" ,_cIT_FILSOMA ,_lRetG ,_cPergG ,"C"})
AADD(_aVal,{"IT_TXFUNDES",STR(_nIT_TXFUNDE,15,8),_lRetH,_cPergH,"N"})//O tipo é numerico na hora da leitura
AADD(_aVal,{"IT_VOLUAGUA",IF(_cIT_VOLUAGUA="Abater","-","")+ALLTRIM(STR(_nIT_VOLUAGUA,15,5)),_lRetI,_cPergI,"N"})
AADD(_aVal,{"IT_OUTROMOV",IF(_cIT_OUTROMOV="Abater","-","")+ALLTRIM(STR(_nIT_OUTROMOV,15,5)),_lRetJ,_cPergJ,"N"})

ZP1->(Dbsetorder(2))

FOR V := 1 TO LEN(_aVal)
	
	If _aVal[V,3]
		
		IF (ZP1->(DbSeek('  ' + cFilAnt + _aVal[V,1] )) .OR. ZP1->(DbSeek('  ' + '  ' + _aVal[V,1] ) ))
			
			AADD(_alog,{_aVal[V,1],LEFT(_aVal[V,4,1],LEN(_aVal[V,4,1])-1)+" alterado de: "+ALLTRIM(ZP1->ZP1_CONTEUD)+" para: " + ALLTRIM(_aVal[V,2]) + " na filial: ["+IF(EMPTY(ZP1->ZP1_FILPAR),"Todas",ZP1->ZP1_FILPAR)+"]"})
			
			ZP1->(RecLock("ZP1",.F.))
			ZP1->ZP1_CONTEUD:= ALLTRIM(_aVal[V,2])
		    ZP1->ZP1_TIPO   :=_aVal[V,5]
			ZP1->(MsUnlock())
			
			
		ELSE
			
			AADD(_alog,{_aVal[V,1],_aVal[V,4,1]+": parametro FOR CRIADO para filial atual, conteudo digitado: " + ALLTRIM(_aVal[V,2]) + " na filial: ["+cFilAnt+"]"})
		    ZP1->(RECLOCK("ZP1",.T.))
		    ZP1->ZP1_FILIAL:=xFilial("ZP1")
		    ZP1->ZP1_MODULO:="04"
		    ZP1->ZP1_GRUPO :="M"
		    ZP1->ZP1_ROTINA:="MEST009"
		    ZP1->ZP1_DESROT:="Leitura de regras de custos gerenciais"
  		    ZP1->ZP1_FILPAR:=cFilAnt
		    ZP1->ZP1_PARAM :=ALLTRIM(_aVal[V,1])
		    ZP1->ZP1_DESCRI:=SUBSTR((_aVal[V,4,2]),15)
		    ZP1->ZP1_TIPO  :=_aVal[V,5]
		    ZP1->ZP1_CONTEU:=ALLTRIM(_aVal[V,2])
			ZP1->(MsUnlock())
			
		ENDIF
	ENDIF
	
NEXT

If len(_alog) == 0

	U_ITMSG("Nenhuma Alteração Realizada",'Atenção!',,3)
	
Else

	U_ITListBox( 'Ajustes EFETIVADOS nos parâmetros' , {"Parametro",'Descrição'} , _alog , .T. , 1 , 'Os seguintes ajustes FORAM EFETIVADOS: ' )
	
Endif

//Registra log de acesso a rotina
U_ITLOGACS('MEST017')

Close(_oDlg)

Return .T.


/*
===============================================================================================================================
Programa----------: MEST017T
Autor-------------: André Lisboa
Data da Criacao---: 09/01/2017
===============================================================================================================================
Descrição---------: Funcao responsavel por manter o Layout independente da resolucao horizontal do Monitor do Usuario.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST017T(_nTam)                                                         

Local _nHres	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     

	If _nHres == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  

		_nTam *= 0.8                                                                

	ElseIf (_nHres == 798).Or.(_nHres == 800)	// Resolucao 800x600                

		_nTam *= 1   	                                                               

	Else	// Resolucao 1024x768 e acima faz proporcao                                          

		_nTam = (_nTam * 1)                                                               

	EndIf                                                                         

Return Int(_nTam)    



