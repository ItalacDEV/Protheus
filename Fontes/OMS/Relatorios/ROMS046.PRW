 /*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                            
------------------------------------------------------------------------------------------------------------------------------- 
Alex Wallauer     | 16/07/2018 | Correção da geração do codigo do GTIN da Etiqueta - Chamado 25439
Alex Wallauer     | 06/02/2019 | Troca de Site para geração de codigo de barra - Chamado 27971
Lucas Borges      | 28/08/2024 | Incluída proteção na classe evitando error.log - Chamado 48314
=============================================================================================================================== 
Analista     - Programador  - Inicio   - Envio    - Chamado - Motivo da Alteração
===============================================================================================================================
Alex         - Igor Melgaço - 02/05/25 - 06/05/25 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
===============================================================================================================================
*/
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*
===============================================================================================================================
Programa----------: ROMS046
Autor-------------: Josué Danich Prestes
Data da Criacao---: 24/11/2016
===============================================================================================================================
Descrição---------: Emissão de etiquetas de produtos
===============================================================================================================================
Parametros--------: lreimprime - Se verdadeiro reimprime usando dados da ZFW posicionada
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function ROMS046(lreimprime)

Private oDlg, oPrint            	
Private cproduto := space(LEN(ZFW->ZFW_PRODUT))
Private cprodAux := space(LEN(ZFW->ZFW_PRODUT))
Private nquant := 0
Private dprod := date()
Private dvalid := date() + POSICIONE("SBZ", 1, xFilial("SBZ") + cproduto, "BZ_I_DIVLD")//240
Private clote := SPACE(LEN(ZFW->ZFW_LOTE))
Private npeso := 0
Private sai := .T.
Private csequen := space(7)
Private cPallet := SPACE(LEN(ZFW->ZFW_PALLET))
Default lreimprime := .F.
Private _oBBrowse:=GetMBrowse()

Private _cCaixa  := SPACE(LEN(ZFW->ZFW_CAIXA))
Private _cFilSG1 := xFilial("SG1")
Private _nQtdCxPa:= 0
Private _nTaraEmb:= 0
Private _nTaraCx := 0
Private _cTaras  := ""
Private aret     := {0,0,0}

If lreimprime
	ROMS046E(lreimprime) //Imprime Etiqueta de caixa
Else
	If .not. ZFW->(Eof())
		cproduto:= ZFW->ZFW_PRODUT
		cprodAux:= ZFW->ZFW_PRODUT
		nquant  := ZFW->ZFW_QUANT
		npeso   := ZFW->ZFW_PESO
		clote   := ZFW->ZFW_LOTE
		dprod   := ZFW->ZFW_DPROD
		dvalid  := ZFW->ZFW_DVALID
		IF ZFW->ZFW_TIPO = "P"
			U_ITMSG("Ação não permitida para etiqueta de Pallet [ Tipo = P ] ","Atenção","Posicione em uma etiqueta de Caixa [ Tipo = C ]",1)
			RETURN .F.
		ENDIF
	Endif

	_nTotSB1:=0

	IF !ROMS46Val("ANTES_TELA")//Chama para carregar o numero do cPallet e o _nTotSB1
		RETURN .F.
	ENDIF

	Do while sai

		sai := .F.

		_nLinha:=5
		_nPula :=20
		_nCol1:=5
		_nCol2:=50
		_nCol3:=150
		_nCol4:=200
				
		@ 000, 000 To 200, 660 Dialog oDlg Title "Impressão de Etiquetas Caixa"

		@ _nLinha, _nCol1 Say "Produto:" pixel
		@ _nLinha, _nCol2 Get cproduto Picture "@!" F3 "SB1" VALID existcpo("SB1") .and. ROMS46Val("PRODUTO") Size 060, 010
		@ _nLinha, _nCol2+65 Get _nTotSB1 Picture "@E 999999"  Size 10,08  pixel WHEN .F.
		_nLinha+=_nPula

		@ _nLinha, _nCol1 Say "Quantidade:" pixel
		@ _nLinha, _nCol2 Get nquant Picture "@E 9,999,999"  Size 060, 010  pixel VALID ROMS46Val("QTDE")
		_nLinha+=_nPula

		@ _nLinha, _nCol1 Say "Peso Bruto:"  pixel
		@ _nLinha, _nCol2 Get npeso Picture "@E 9,999,999.999"  Size 060, 010  pixel VALID ROMS46Val("PB")
		_nLinha+=_nPula

		@ _nLinha, _nCol1 Say "Pallet:"  pixel
		@ _nLinha, _nCol2 Get cpallet  Size 060, 011  pixel WHEN .F.
		@ _nLinha, _nCol2+65 Get _nQtdCxPa Picture "@E 999999"  Size 10,08  pixel WHEN .F.
		_nLinha+=_nPula

		@ _nLinha, _nCol1 Say "Caixa:"  pixel
		@ _nLinha, _nCol2 Get _cCaixa  Size 060, 011  pixel WHEN .F.

		_nLinha:=5

		@ _nLinha, _nCol3 Say "Lote:"  pixel
		@ _nLinha, _nCol4 Get clote  VALID NaoVazio(clote) .AND. ROMS46Val("LOTE")  Size 050, 010 PIXEL PICTURE AVSX3("ZFW_LOTE",6)
		_nLinha+=_nPula

		@ _nLinha, _nCol3 Say "Data Produção:"  pixel
		@ _nLinha, _nCol4 Get dprod   Size 050, 010  pixel VALID ROMS46Val("DT")
		_nLinha+=_nPula

		@ _nLinha, _nCol3 Say "Data Validade:"  pixel
		@ _nLinha, _nCol4 Get dvalid  Size 050, 010   pixel VALID ROMS46Val("VALIDADE")
		_nLinha+=_nPula

		@ _nLinha, _nCol3 Say "Taras:"  pixel
		@ _nLinha, _nCol4 Get _cTaras  Size 110, 010   pixel WHEN .F.
		_nLinha+=_nPula
	//  Foi retirado pq agora imprimi só o que foi gravado
	//	@ _nLinha, 129 BmpButton Type 06 Action Processa( {|| ROMS046E(lreimprime),_oBBrowse:Refresh() }, "Aguarde...", "Imprimindo etiquetas...",.F.)//Imprimir 
		@ _nLinha, 182 BmpButton Type 13 Action Processa( {|| nRecZFW:=ROMS046G() ,ZFW->(DBGOTO(nRecZFW)) ,_oBBrowse:Refresh() }, "Aguarde...", "Gravando etiquetas...",.F.) //Salvar
		@ _nLinha, 235 BmpButton Type 02 Action oDlg:End()

		Activate Dialog oDlg Centered

	Enddo
	
Endif

Return 

/*
===============================================================================================================================
Programa----------: ROMS46Val
Autor-------------: Alex Wallauer
Data da Criacao---: 06/07/2017
===============================================================================================================================
Descrição---------: Validacao 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/  
Static Function ROMS46Val(_cCpoOrigem)

LOCAL cquery    := ""
LOCAL cquery2   := ""
LOCAL cquery3   := ""
LOCAL cpalletMAX:= ""
LOCAL _nQtdeVal := POSICIONE("SBZ", 1, xFilial("SBZ") + cproduto, "BZ_I_DIVLD")//240
DEFAULT _cCpoOrigem  := "PRODUTO_E_LOTE"
PRIVATE _nQtePacCX   := 0 // qtde de pacotinhos em 1 caixa
//IVATE _nPesTotCaixa:= 0 // Peso total dos pacotes na caixa
PRIVATE _nPesDigCaixa:= 0 // Peso do pacotes digitados
PRIVATE _lAutomatico := !(POSICIONE("SBZ", 1, xFilial("SBZ") + cproduto, "BZ_I_QBLOT") = "N")

IF _cCpoOrigem == "DT"
	
	dvalid := dprod + _nQtdeVal
	RETURN .T.

ELSEIF _cCpoOrigem == "VALIDADE"

	IF _nQtdeVal = 0 //.AND. ((dvalid - dprod) > 365)
		U_ITMSG("Prazo de validade não cadastrado para esse produto","Atenção","Favor verificar com o setor de cadastrode produtos, a validade cadastrada para esse produto [BZ_I_DIVLD] no cadastro de indicadores.",1)
	    RETURN .F.
	ENDIF

	dvalidAux := dprod + _nQtdeVal 
	IF dvalid >= (dvalidAux+5) .OR. dvalid <= (dvalidAux-5)
	   _nDif:=(dvalid-dprod)
		U_ITMSG("A Data de validade desse produto não condiz com a quantidade de dias do cadastro de indicadores [BZ_I_DIVLD].","Atenção","A data de validade deve ser igual a ( data produção + "+ALLTRIM(STR(_nQtdeVal)) +" ) = "+DTOC(dvalidAux)+", a data de validade digita esta a "+ALLTRIM(STR(_nDif))+" dias da data de produção.",1)
	    RETURN .F.
	ENDIF
	RETURN .T.
	
ELSEIF _cCpoOrigem == "QTDE"
	
	_nQtePacCX:=ROMS046Tot(cproduto,"QTDE",nquant)//preenche a vairavel _nPesDigCaixa
	IF nquant # _nQtePacCX
		U_ITMSG("Quantidade digitada deve ser "+ALLTRIM(STR(_nQtePacCX))+" unidades que cabem em uma caixa","Atenção","Quantidade deve ser igual a "+ALLTRIM(STR(_nQtePacCX)),1)
	    nquant:=ROMS046Tot(cproduto,"QTDE",0)//preenche a vairavel _nPesDigCaixa
	ENDIF
	IF !_lAutomatico
		npeso:= _nPesDigCaixa
	ENDIF
    aret := ROMS046Q(_cFilSG1)//Calcula peso das embalagens x quantidade digitada

	RETURN .T.
	
ELSEIF _cCpoOrigem == "PB"
	
	IF !_lAutomatico
		ROMS046Tot(cproduto,"QTDE",nquant)//preenche a vairavel _nPesDigCaixa
		IF npeso > _nPesDigCaixa
			IF !U_ITMSG("Peso digitado maior que "+ALLTRIM(STR(_nPesDigCaixa))+" Kgs que é equivalente a quantidade digitada de "+ALLTRIM(STR(nquant))+". Deseja continuar?","Atenção",,3,2,2)
			    npeso:=_nPesDigCaixa
				RETURN .F.
			ENDIF
		ENDIF
	ENDIF
	
	RETURN .T.

ELSEIF _cCpoOrigem == "LOTE"
/*	IF !_lAutomatico
	   ZFW->(Dbsetorder(3))
	   If ZFW->(Dbseek(xfilial("ZFW")+_cCaixa+cLote))
	   	  U_ITMSG("Esse lote já esta na caixa "+_cCaixa,"Atenção","Digite outro numero de lote",1)
		  RETURN .F.
	   ENDIF
	ENDIF*/
//  RETURN .T.
ENDIF

_nTotSB1:=ROMS046Tot(cproduto)//Quantidade de caixas

//IF !_lAutomatico
   IF _cCpoOrigem == "PRODUTO" .AND. cProdAux # ZFW->ZFW_PRODUT//Trocou de produto
      cProdAux:= ZFW->ZFW_PRODUT
      dprod   := DATE()
      dvalid  := DATE() + POSICIONE("SBZ", 1, xFilial("SBZ") + cproduto, "BZ_I_DIVLD")//240
      clote   := SPACE(LEN(ZFW->ZFW_LOTE))
	  nquant  := ROMS046Tot(cproduto,"QTDE",0)//preenche a vairavel _nPesDigCaixa //Quantidade nas caixas
	  npeso   := _nPesDigCaixa
      _cFilSG1 := xFilial("SG1")
      _nTaraEmb:= 0
      _nTaraCx := 0
   ENDIF
//ENDIF

IF _cCpoOrigem == "PRODUTO" .AND. !ROMS046Fil(cproduto)//Tenho pegar depois do IF de cima por causa das taras
   Return .F.
ENDIF

IF _cCpoOrigem == "ANTES_TELA"
   _cTaras:= "Caixa: "+ALLTRIM(TRANS(ZFW->ZFW_TRCAX,"@E 999,999.999"))+" - Embalagem: "+ALLTRIM(TRANS(ZFW->ZFW_TREMB,"@E 999,999.999"))
ELSE
   aret   := ROMS046Q(_cFilSG1)//Calcula as _cTaras
ENDIF

_cCaixa := ROMS046Caixa(.F.)

cquery := "SELECT MAX(ZFW_PALLET) NUM FROM " + RETSQLNAME("ZFW")
cquery += " WHERE D_E_L_E_T_ <> '*' AND ZFW_FILIAL = '" + xFilial("ZFW")+"'"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TSD1', .T., .F.)

If VAL(TSD1->NUM) = 0 //Trantamento para o primeiro registro da filial atual
   cPallet:= '0000001'
   TSD1->(Dbclosearea())
   RETURN .T.
Else
   cpalletMAX:= STRZERO(VAL(TSD1->NUM),7)
endif

cquery2 := "SELECT MAX(ZFW_PALLET) ULTPALLET "
cquery2 += " from " + retsqlname("ZFW") + " WHERE D_E_L_E_T_ <> '*' AND ZFW_FILIAL = '" + xFilial("ZFW") +"'" 
cquery2 += " AND ZFW_PRODUT = '" + cProduto + "'" 
cquery2 += " AND ZFW_LOTE   = '" + cLote + "'" 
cquery2 += " AND ZFW_TIPO   = 'C'" 

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery2), 'TSD2', .T., .F.)

If VAL(TSD2->ULTPALLET) = 0//Senão existe produto + lote gera novo numero de pallet

   cPallet:= STRZERO(VAL(cpalletMAX)+1,7)

ELSE

   cPallet:= STRZERO(VAL(TSD2->ULTPALLET),7)//Pega o numero do Pallet e verefica se tá fechado

   cquery3 := "SELECT COUNT(ZFW_PALLET) TEMPALLET "
   cquery3 += " from " + retsqlname("ZFW") + " WHERE D_E_L_E_T_ <> '*' AND ZFW_FILIAL = '" + xFilial("ZFW") +"'" 
   cquery3 += " AND ZFW_PRODUT = '" + cProduto + "'" 
   cquery3 += " AND ZFW_LOTE   = '" + cLote + "'" 
   cquery3 += " AND ZFW_PALLET = '" + cPallet + "'" 
   cQUERY_P:= " AND ZFW_TIPO   = 'P'" 

   dbUseArea(.T., "TOPCONN", TCGenQry(,, (cquery3+cQUERY_P) ), 'TSD3', .T., .F.)

   If TSD3->TEMPALLET > 0//Se o Produto + Lote tem PALLAET FECHADO para o cPallet encontrado gera novo numero de pallet
      cPallet:= STRZERO(VAL(cpalletMAX)+1,7)
   ELSE
      cQUERY_C := " AND ZFW_TIPO   = 'C'" 
      dbUseArea(.T., "TOPCONN", TCGenQry(,, (cquery3+cQUERY_C)) , 'TSD4', .T., .F.)   
      _nQtdCxPa:= TSD4->TEMPALLET
      TSD4->(Dbclosearea())
   ENDIF

   TSD3->(Dbclosearea())
   
ENDIF

TSD1->(Dbclosearea())
TSD2->(Dbclosearea())
DbSelectArea("ZFW")

Return .T.

/*
===============================================================================================================================
Programa----------: ROMS046E
Autor-------------: Josué Danich Prestes
Data da Criacao---: 24/11/2016
===============================================================================================================================
Descrição---------: Impressão de etiquetas de produtos
===============================================================================================================================
Parametros--------: lreimprime - se é reimpressão de etiqueta ou nova etiqueta
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function ROMS046E(lreimprime)

Local sai := .T.
Local cpalini := space(7)
Local cpalfim := space(7)
Local cini := space(7)
Local cfim := space(7)

Private nlinha := 40
Private ncoluna := 20

Private ntamh := 1120
Private ntamv := 1680
Private aregs := {}

If .not. lreimprime
	sai := .T.
	ROMS046Z('0','0','0','0',nil,.F.)
Else
	sai := .T.

	Do while sai

		sai    := .F.
		cpalini:= ZFW->ZFW_PALLET
		cpalfim:= ZFW->ZFW_PALLET
		cini   := ZFW->ZFW_SEQUEN
		cfim   := ZFW->ZFW_SEQUEN
		_nLin:=1

		lTodas:=U_ITMSG("Imprmir todas as etiquetas do Pallet?",'Atenção!',,3,2,2)
			
		@ 000, 000 To 300, 350 Dialog oDlg Title "Reimpressão de Etiquetas"
		
		@ _nLin, 001 Say "Pallet inicial:"
		@ _nLin, 010 Get cpalini Picture "9999999"  Size 060, 010
		_nLin+=1
		@ _nLin, 001 Say "Pallet final:"
		@ _nLin, 010 Get cpalfim Picture "9999999"  Size 060, 010
		_nLin+=1
		IF !lTodas
		@ _nLin, 001 Say "Seq Inicial:"
		@ _nLin, 010 Get cini Picture "9999999"  Size 060, 010
			_nLin+=1
		@ _nLin, 001 Say "Seq Final:"
		@ _nLin, 010 Get cfim Picture "9999999"  Size 060, 010
		ELSE
		cini:=""
		cfim:=""
		ENDIF
		
		@ 0080, 010 BmpButton Type 1 Action Processa( {|| ROMS046Z(cpalini,cpalfim,cini,cfim,oDlg,.T.) }, "Aguarde...", "Imprimindo etiquetas...",.F.)
		@ 0080, 085 BmpButton Type 2 Action Close(oDlg)

		Activate Dialog oDlg Centered

	Enddo

Endif

//Zera sequencia para não correr risco de gravar repetida
csequen := space(7)

Return

/*
===============================================================================================================================
Programa----------: ROMS046Q
Autor-------------: Josué Danich Prestes
Data da Criacao---: 24/11/2016
===============================================================================================================================
Descrição---------: Carrega peso de embalagens
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Array com peso da caixa, peso da embalagem 
===============================================================================================================================
*/  
Static function ROMS046Q(_cFilSG1)

Local aret := {0,0,0}
Local cquery:= ""

IF EMPTY(cproduto)
   RETURN aret
ENDIF

IF _nTaraEmb # 0 .AND. _nTaraCx # 0
    aret := {_nTaraCx,_nTaraEmb,_nTaraEmb+_nTaraCx}
    _cTaras  :="Caixa: "+ALLTRIM(TRANS(_nTaraCx,"@E 999,999.999"))+" - Embalagem: "+ALLTRIM(TRANS(_nTaraEmb,"@E 999,999.999"))
    RETURN aret
ENDIF

cquery := "select G1_FILIAL,G1_COD,G1_COMP,G1_TRT,G1_QUANT,G1_REVINI,G1_REVFIM,"
cquery += "(SELECT MAX(G1_REVfim) FROM " + retsqlname("SG1") + " SG1T2 WHERE SG1T2.D_E_L_E_T_ <> '*' AND sg1t2.g1_revfim <> 'ZZZ'"
cquery += " and sg1t2.g1_cod = sg1.g1_cod and sg1t2.g1_filial = '" + _cFilSG1 + "') revi,"
cquery += " sg1.g1_quant/(select bz_QB from " + retsqlname("SBZ") + " sbz where sbz.d_e_l_e_t_ <> '*' and sbz.bz_cod = sg1.g1_cod and sbz.bz_filial = '" + _cFilSG1 + "') quant, "
cquery += " (SELECT B1_PESO FROM " + RETSQLNAME("SB1") + " SB1 WHERE SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = SG1.G1_COMP) PESO, "
//cquery += " (sg1.g1_quant/(select bz_QB from " + retsqlname("SBZ") + " sbz where sbz.d_e_l_e_t_ <> '*' and sbz.bz_cod = sg1.g1_cod and sbz.bz_filial = '" + xfilial("SBZ") + "')) PESO,"
cquery += " (SELECT BZ_QB FROM " + retsqlname("SBZ") + " sbz where sbz.d_e_l_e_t_ <> '*' and sbz.bz_cod = sg1.g1_cod and sbz.bz_filial = '" + _cFilSG1 + "') QB,"
//cquery += " (SELECT B1_TIPO FROM " + RETSQLNAME("SB1") + " SB12 WHERE SB12.D_E_L_E_T_ <> '*' AND SB12.B1_COD = SG1.G1_COMP) TIPO,"
cquery += " (SELECT B1_DESC FROM " + RETSQLNAME("SB1") + " SB13 WHERE SB13.D_E_L_E_T_ <> '*' AND SB13.B1_COD = SG1.G1_COMP) DESCR,"
cquery += " (SELECT B1_I_QESP FROM " + RETSQLNAME("SB1") + " SB14 WHERE SB14.D_E_L_E_T_ <> '*' AND SB14.B1_COD = SG1.G1_COMP) QESP"
cquery += " from " + retsqlname("SG1") + " sg1" 
cquery += " where sg1.d_e_l_e_t_ <> '*' and sg1.g1_filial = '" + _cFilSG1 + "'" //xfilial("SG1")
cquery += "                            and sg1.g1_cod = '" + alltrim(cproduto) + "'" 
cquery += "                            and (select b1_tipo from " + retsqlname("SB1") + " sb1 where sb1.d_e_l_e_t_ <> '*' and sb1.b1_cod = sg1.g1_COMP) = 'EM'" 
cquery += "                            and (((SELECT MAX(G1_REVfim) FROM " + retsqlname("SG1") + " SG1T WHERE SG1T.D_E_L_E_T_ <> '*' and sg1t.g1_filial = '" + _cFilSG1 + "'" //xfilial("SG1")
cquery += "                                                                                      AND sg1t.g1_revfim <> 'ZZZ'" 
cquery += "                                                                                      and sg1t.g1_cod = sg1.g1_cod) = sg1.g1_revfim )" 
cquery += "                                                                                      or sg1.g1_revfim = 'ZZZ')"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TSG1', .T., .F.)
DbSelectArea("TSG1")

Do while .not. TSG1->(Eof())

	aret[3] += TSG1->PESO
	
	If "CX" $ TSG1->DESCR .OR. "CAIXA" $ TSG1->DESCR  .OR. "CARTELA" $ TSG1->DESCR
	
	  aret[1] += TSG1->PESO
	  
	ElseIf !Empty(TSG1->QESP)
	
	  aret[2] += TSG1->PESO * nquant
	
	Endif                                                                               	
	
	TSG1->(Dbskip())
	
Enddo

TSG1->(Dbclosearea())

_cTaras  :="Caixa: "+ALLTRIM(TRANS(aret[1],"@E 999,999.999"))+" - Embalagem: "+ALLTRIM(TRANS(aret[2],"@E 999,999.999"))

Return aret

/*
===============================================================================================================================
Programa----------: ROMS046G
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/09/2016
===============================================================================================================================
Descrição---------: Grava dados da etiqueta de caixa
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  

Static Function ROMS046G()

IF !ROMS46Val("QTDE") .OR. !ROMS46Val("LOTE")
   RETURN ZFW->(RECNO())
ENDIF
If csequen == space(7) //Se ainda não carregou sequencia faz agora
   csequen:= getsxenum("ZFW","ZFW_SEQUEN")
   Confirmsx8()
Endif

ZFW->(Reclock("ZFW", .T.))

ZFW->ZFW_SEQUEN:= csequen
ZFW->ZFW_PESO  := npeso
ZFW->ZFW_FILIAL:= xfilial("ZFW")
ZFW->ZFW_PRODUT:= cproduto
ZFW->ZFW_QUANT := nquant
ZFW->ZFW_LOTE  := clote
ZFW->ZFW_DPROD := dprod
ZFW->ZFW_DVALID:= dvalid
ZFW->ZFW_TIPO  := "C" 
ZFW->ZFW_PALLET:= cpallet
ZFW->ZFW_CAIXA := _cCaixa
//aret:={_nTaraCx,_nTaraEmb,_nTaraEmb+_nTaraCx}
ZFW->ZFW_TREMB := IF(_nTaraEmb#0,_nTaraEmb,aret[2])
ZFW->ZFW_TRCAX := IF(_nTaraCx #0,_nTaraCx ,aret[1])

ZFW->(Msunlock())

cPallet := ROMS046VP()
_cCaixa := ROMS046Caixa(.F.)

csequen:=space(7)//Zera sequencia para não correr risco de gravar repetida

nRecZFW:=ZFW->(RECNO())
IF nRecZFW > 15//numero de linhas do Browse
   nRecZFW:=(nRecZFW-15)//Posição do primeiro registro do Browse onde deixa o utimo registro da tabela na ultima linha do browse
ENDIF

Return nRecZFW

/*
===============================================================================================================================
Programa----------: ROMS046VP
Autor-------------: Josué Danich Prestes
Data da Criacao---: 24/11/2016
===============================================================================================================================
Descrição---------: Verifica número de pallet do novo registro
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: string com número do pallet
===============================================================================================================================
*/  
STATIC FUNCTION ROMS046vp()

Local cpallet := '0000000'
Local cquery  := ""
Local cpalletu:= "0000000"

cquery := "SELECT ZFW_PALLET, "
cquery += "	COUNT(ZFW_PALLET) QTDE,"
cquery += "	SUM(ZFW_PESO)     PESO,"
cquery += " SUM(ZFW_QUANT)    quant,"
cquery += " SUM(ZFW_TRCAX)    ZCAIXA,"
cquery += " SUM(ZFW_TREMB)    ZEMB"
cquery += " from " + retsqlname("ZFW") + " where d_e_l_e_t_ <> '*' and zfw_filial = '" + xFilial("ZFW") +"'" 
cquery += " and zfw_produt = '" + cproduto + "'" 
cquery += " and zfw_lote   = '" + clote + "'" 
cquery += " and zfw_dprod  = '" + dtos(dprod) + "'" 
cquery += " and zfw_dvalid = '" + dtos(dvalid) + "'"
cquery += " and zfw_tipo   = 'C'" 
cquery += " group by zfw_pallet"
cquery += "	order by zfw_pallet"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TSD1', .T., .F.)
DbSelectArea("TSD1")

_nTotSB1:=ROMS046Tot(cproduto)//(posicione("SB1",1,xfilial("SB1")+cproduto,"B1_I_CXPAL") / SB1->B1_I_QT3UM)
//Procura pallet incompleto
If .not. TSD1->(Eof())

	Do while .not. TSD1->(Eof())
	
		_nTotC   := TSD1->QTDE
		_nQtdCxPa:= TSD1->QTDE
		If _nTotC < _nTotSB1
			cpallet := TSD1->ZFW_PALLET
			exit
		Endif
		
		//Guarda dados do ultimo pallet
		npesou   := TSD1->PESO
		nqtdeu   := TSD1->QTDE
		cpalletu := TSD1->ZFW_PALLET
        nTrCaixa := TSD1->ZCAIXA
        nTrEmb   := TSD1->ZEMB
		
		TSD1->(Dbskip())
		
	Enddo
	
Endif

TSD1->(Dbclosearea())

//Se não achou pallet incompleto faz um novo pallet
If cpallet == '0000000'

	cquery := "select max(zfw_pallet) num from " + retsqlname("ZFW") + " where d_e_l_e_t_ <> '*' and zfw_filial = '" + xFilial("ZFW") +"'"   

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TSD1', .T., .F.)
	DbSelectArea("TSD1")

	If TSD1->(Eof()) 
		cpallet := '0000001'
	Else
		//Antes de criar novo pallet atualiza registro do último pallet sendo criado
		ZFW->(Dbsetorder(2))
		
		If ZFW->(Dbseek(xfilial("ZFW")+"C"+cpalletu))
			
				csequen := getsxenum("ZFW","ZFW_SEQUEN")
				ConfirmSX8()
				
				ZFW->(Reclock("ZFW", .T.))
				
				ZFW->ZFW_FILIAL := xfilial("ZFW")
				ZFW->ZFW_PESO   := npesou
				ZFW->ZFW_QUANT  := nqtdeu
				ZFW->ZFW_SEQUEN := csequen  //csequenu//Troquei pq agora gera o Pallet por ultimo
				ZFW->ZFW_PRODUT := cproduto //cprodutou
				ZFW->ZFW_LOTE   := clote    //cloteu
				ZFW->ZFW_DPROD  := dprod    //dprodu
				ZFW->ZFW_DVALID := dvalid   //dvalidu
				ZFW->ZFW_TIPO   := "P" 
				ZFW->ZFW_PALLET := cpalletu
                ZFW->ZFW_CAIXA  := _cCaixa
                ZFW->ZFW_TREMB  := nTrEmb//IF(_nTaraEmb#0,_nTaraEmb,aret[2])
                ZFW->ZFW_TRCAX  := nTrCaixa//IF(_nTaraCx #0,_nTaraCx ,aret[1])
				ZFW->(Msunlock())
				
		Endif
		
		ZFW->(Dbsetorder(1))
		cpallet := strzero(val(TSD1->NUM)+1,7)
		
	Endif
	
	TSD1->(Dbclosearea())
	
Endif

Return cpallet

/*
===============================================================================================================================
Programa----------: ROMS046Z
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/09/2016
===============================================================================================================================
Descrição---------: Impressão de multiplas etiquetas
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function ROMS046Z(cpalini, cpalfim,cini,cfim,odlg,lreimprime)

Local cquery := "",_ni , ni

Private aregs := {}

IF lreimprime
   cproduto:=ZFW->ZFW_PRODUT
ENDIF

If lreimprime

	cquery := "select r_e_c_n_o_ num from " + retsqlname("ZFW")
	cquery += " where d_e_l_e_t_ <> '*' AND ZFW_FILIAL = '" + xFilial("ZFW")+"' and ZFW_PALLET >= '" + alltrim(cpalini) + "' and  ZFW_PALLET <= '" + alltrim(cpalfim) + "'" 
	cquery += " and ZFW_TIPO = 'C'"
	IF !EMPTY(cini)
	   cquery += " and ZFW_SEQUEN >= '" + ALLTRIM(cini) + "' "
	ENDIF
	IF !EMPTY(cfim)
	   cquery += " and ZFW_SEQUEN <= '" + ALLTRIM(cfim) + "' "
	ENDIF

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TSD1', .T., .F.)
	DbSelectArea("TSD1")

	If TSD1->(Eof()) 

		U_ITMSG("Não foram encontradas etiquetas!",,,1)
  
		TSD1->(Dbclosearea())
  
		Return
  
	Endif

	Do while .not. TSD1->(Eof())


		aadd(aregs,TSD1->NUM)
  
		TSD1->(Dbskip())
  
	Enddo

	TSD1->(Dbclosearea())

	close(odlg)

Else

	//Se for impressão nova só deixa uma passagem no loop 

	aregs := {1}

Endif

PRIVATE _lSite:=.F.//U_ITMSG("Origem do Codigo de Barra do Site ? ",'Atenção!',,3,2,2)

IF _lSite
	ntamv    :=1680
	ntamh    :=1120
	nLinMeio :=0500 
	ncoluna  :=20
	nTamFonte:=00
	nlinhaIni:=40
	nLinhAux1:=00
	nLinhAux2:=00
	nColuAux1:=500
	_nMeioE  :=250
	_nMeio   :=500
	_nMeioD  :=800
	_nEsqu1  :=010
	_nEsqu2  :=nLinMeio + 10

	oPrint := TAVPrinter():New("Etiquetas p/ produtos")                     
	oPrint :SetPortrait()                  // Fixa a Impressao em Retrato
	oPrint :Setup()

ELSE
	ntamv    :=1550//ALTURA DAS LINHA LATERAIS 
	ntamh    :=1140//LARGURA DA ETIQUETA
	nLinMeio  :=0460 
	ncoluna  :=15
	nTamFonte:=04
	nlinhaIni:=35
	nLinhAux1:=35
	nLinhAux2:=15
	nColuAux1:=100
	_nMeio   :=010
	_nMeioE  :=010
	_nMeioD  :=nLinMeio+05
	_nEsqu1  :=010
	_nEsqu2  :=nLinMeio+05

	cLocal:= GetTempPath()

	cFileName:="ROM046_"
	cFileName+=DToS( DATE() ) + "_"
	cFileName+=StrTran(TIME(), ":" , "" )
	cFileName:=cFileName+".pdf"

	oPrint:= FwMsPrinter():New(cFileName, IMP_PDF , .T., cLocal , .T.)//, .T., NIL, NIL, NIL, NIL, NIL, .F., NIL)
	oPrint:cPathPDF := cLocal	// Caso seja utilizada impressão em IMP_PDF
	oPrint:SetPortrait()        // Fixa a Impressao em Retrato
	oPrint:Setup()

	IF UPPER(oPrint:cPathPDF) == "C:\" .OR. EMPTY(oPrint:cPathPDF)
	   oPrint:cPathPDF := cLocal
	ENDIF
	
	IF oPrint:nModalResult = 2//APERTOU O CANCELA
	   RETURN .F.
	ENDIF
ENDIF   

oFont10  := TFont():New("Arial", 9, (10+nTamFonte  ), .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont10n := TFont():New("Arial", 9, (10+nTamFonte  ), .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont12n := TFont():New("Arial", 9, (12+nTamFonte+1), .T., .T., 5,,, .T., .F.,,,,,, oPrint)//TITULO

ni := 1

cerros := ""
procregua(len(aregs))

FOR ni := 1 TO  LEN(aregs)
	
	ZFW->(DBGOTO(aregs[ni]))
	nlinha := nlinhaIni
	nRecZFW:=ZFW->(RECNO())
	
	incproc("Imprimindo etiqueta " + strzero(ni,2) + " de " + strzero(len(aregs),2))
	
	if lreimprime
		
		cproduto := ZFW->ZFW_PRODUT
		nquant   := ZFW->ZFW_QUANT
		npeso    := ZFW->ZFW_PESO
		clote    := ZFW->ZFW_LOTE
		dprod    := ZFW->ZFW_DPROD
		dvalid   := ZFW->ZFW_DVALID
		
	Endif
	
	//Localiza produto selecionado
	posicione("SB1",1,xfilial("SB1")+cproduto,"B1_COD")
	
	If EMPTY(SB1->B1_CONV)
		_lLayoutVariavel:=.T.
	ELSE
		_lLayoutVariavel:=.F.
	ENDIF
	
	If LEN(ALLTRIM(SB1->B1_I_DUN14)) < 13
		
		If !(cproduto$cerros)
			
			U_ITMSG("Produto sem código DUN14 válido","Atenção","Preencha o campo "+AVSX3("B1_I_DUN14",5)+" no cadastro do produto: "+cproduto,3)
			
			cerros += "|" + cproduto
			
		Endif
		
		ni++
		
		Loop
		
	Endif
	
	
	//Calcula peso das embalagens
	//aret := ROMS046Q(_cFilSG1)
	
	oPrint:StartPage()              // Inicializa a Pagina de Impressao
	
//	oPrint:Line(nlinhaIni,ncoluna - 5     , nlinha + ntamv , ncoluna - 5     )//LINHA LATERAL ESQUERDA 
//	oPrint:Line(nlinhaIni,ncoluna + ntamh , nlinha + ntamv , ncoluna + ntamh )//LINHA LATERAL DIRETA
	
	oPrint:Line(nlinha,ncoluna - 5 , nlinha , ncoluna + ntamh)//LINHA INICIAL
	
	nLinha += 010
	
	oPrint:Say(nLinha+nLinhAux1, nColuna + nColuAux1,"Goiasminas Indústria de Laticínios Ltda.", oFont12n,,,,2)
	
	nLinha += 060
	oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
	
	IF _lLayoutVariavel // ***************   LAYOUT  VARIAVEL  ****************************
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "GTIN", oFont10n)//200
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, "Peso Líquido", oFont10n)//610
		
		oPrint:Line(nlinha , ncoluna + nLinMeio, nlinha + 110,  ncoluna + nLinMeio)
		
		nLinha += 060-nLinhAux2
		
		nsoma := 0
		
		cprebar := "9" + SUBSTR(alltrim(SB1->B1_I_DUN14),2,(len(alltrim(SB1->B1_I_DUN14))-2))
		
		For _ni := 1 to len(cprebar)
			
			If int(_ni/2) == _ni/2
				
				nsoma +=  val(substr(cprebar,_ni,1))
				
			Else
				
				nsoma += 3 * val(substr(cprebar,_ni,1))
				
			Endif
			
		Next
		
		nprox := nsoma
		
		Do while int(nprox/10) != nprox/10
			
			nprox++
			
		Enddo
		
		cdigito := alltrim(str(nprox-nsoma))
		
		cgtin := cprebar + cdigito
		
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, cgtin, oFont10)//150
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, transform(round((npeso - (ZFW->ZFW_TREMB+ZFW->ZFW_TRCAX)),2),"@E 9,999,999.99") + " kg.", oFont10) //aret[2]+aret[1]//750
		nLinha += 050
		
		oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
		nLinha += 010
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Data de Validade", oFont10n)//70
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, "Quantidade", oFont10n)//610

		oPrint:Line(nlinha - 10  , ncoluna + nLinMeio, nlinha + 110,  ncoluna + nLinMeio)
		
		nLinha += 060-nLinhAux2
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, dtoc(dvalid), oFont10)//210
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, TRANSFORM(nquant,"@E 9,999,999"), oFont10)//750
		
		nLinha += 050
		oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
		nLinha += 010
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Lote", oFont10n)//170
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, "Data de Prod", oFont10n)//710
		oPrint:Line(nlinha - 10 , ncoluna + nLinMeio, nlinha + 110,  ncoluna + nLinMeio)
		
		nLinha += 060-nLinhAux2
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, clote, oFont10)//210
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, dtoc(dprod), oFont10)//750
		
		nLinha += 050
		oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
		nLinha += 010
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Peso Bruto", oFont10n)//120
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, "Produto"   , oFont10n)//710
		
		nLinha += 060-nLinhAux2
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, TRANSFORM(ROUND(npeso,2),"@E 9,999,999.99") + " kg.", oFont10)//110
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, SUBSTR(ALLTRIM(SB1->B1_DESC),1,30), oFont10)//510

		nLinha += 050

  		oPrint:Line(nlinha - 110 , ncoluna + nLinMeio, nlinha,  ncoluna + nLinMeio)//LINHA DO MEIO FINAL
		oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)                   // Imprime um Traco

		nLinha += 010
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "No. Registro Processador", oFont10n)//350
		
		nLinha += 060-nLinhAux2
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "0763763", oFont10)//370
		
		nLinha += 050
		oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)                    // Imprime um Traco
		nLinha += 010
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "SSCC - Código de Série da Unidade Logística", oFont10n)//220
		
		nLinha += 060-nLinhAux2
		
		//Monta pré string do SSCC para calcular dígito verificador - http://www.gs1.org/how-calculate-check-digit-manually
		
		If lreimprime
			
			csequen  := ZFW->ZFW_SEQUEN
			
		Else
			
			csequen := getsxenum("ZFW","ZFW_SEQUEN")
			
		Endif
		
		cprebar := "0" + "789808064" + csequen
		
		nsoma := 0
		
		For _ni := 1 to len(cprebar)
			If int(_ni/2) == _ni/2
				nsoma +=  val(substr(cprebar,_ni,1))
			Else
				nsoma += 3 * val(substr(cprebar,_ni,1))
			Endif
		Next _ni
		
		nprox := nsoma
		
		Do while int(nprox/10) != nprox/10
			nprox++
		Enddo
		
		cdigito := alltrim(str(nprox-nsoma))
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "0" + "789808064" + csequen + cdigito, oFont10)//350
		
	ELSE// ***************  LAYOUT FIXO  *********************************************************************
		
		//=========================== quadrado "GTIN"
		
		nsoma := 0
		
  		cprebar := "0" + SUBSTR(alltrim(SB1->B1_I_DUN14),2,(len(alltrim(SB1->B1_I_DUN14))-2))//SUBSTR(ALLTRIM(SB1->B1_I_DUN14),1,13)//( LEN(ALLTRIM(SB1->B1_I_DUN14))-1)

		IF LEN(cprebar) < 14
			
			For _ni := 1 to len(cprebar)
				If int(_ni/2) == _ni/2
					nsoma +=  val(substr(cprebar,_ni,1))
				Else
					nsoma += 3 * val(substr(cprebar,_ni,1))
				Endif
			Next _ni
			
			nprox := nsoma
			
			Do while int(nprox/10) != nprox/10
				nprox++
			Enddo
			
			cdigito := alltrim(str(nprox-nsoma))
		ELSE
			cdigito:=""
		ENDIF
		
		cgtin := cprebar + cdigito
	
	    oPrint:Say(nLinha+nLinhAux1, nColuna+_nMeio, "GTIN", oFont10n,,,, 2)
		nLinha += 060
		
	    oPrint:Say(nLinha+nLinhAux1, nColuna+_nMeio, cgtin, oFont10,,,,2)
		nLinha += 050
		
		
		//===================================  quadrado "Data de Validade" + "Data de Validade"
		
		oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
		nLinha += 010
		
	   oPrint:Say(nLinha+nLinhAux1, nColuna + _nMeioE, "Data de Validade", oFont10n,,,,2)
	   oPrint:Say(nLinha+nLinhAux1, nColuna + _nMeioD, "Data de Prod."   , oFont10n,,,,2)

		oPrint:Line(nlinha - 10 , ncoluna + nLinMeio, nlinha + 110,  ncoluna + nLinMeio)
		nLinha += 060
		
	    oPrint:Say(nLinha+nLinhAux1, nColuna + _nMeioE, dtoc(dvalid), oFont10,,,,2)
	    oPrint:Say(nLinha+nLinhAux1, nColuna + _nMeioD, dtoc(dprod) , oFont10,,,,2)
		nLinha += 050
		
		oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
		nLinha += 010
		
		//===================================  quadrado lote + produto

        nLinhAux1:=35
		
	    oPrint:Say(nLinha+nLinhAux1, nColuna + _nMeioE, "Lote"   , oFont10n,,,,2)
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nMeioD, "Produto", oFont10n,,,,2)
		
		nLinha += 060
		
	    oPrint:Say(nLinha+nLinhAux1, nColuna + _nMeioE, clote , oFont10,,,,2)
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nMeioD, substr(alltrim(SB1->B1_DESC),1,30), oFont10)
		
		
		nLinha += 050

  		oPrint:Line(nlinha - 120 , ncoluna + nLinMeio, nlinha,  ncoluna + nLinMeio)//LINHA DO MEIO FINAL
		oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)                    // Imprime um Traco

		nLinha += 010
		
		//=================================== quadrado No. Registro Processador"
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nMeio, "No. Registro Processador", oFont10n,,,,2)
		
		nLinha += 060
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nMeio, "0763763", oFont10,,,,2)
		nLinha += 050
		
		oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)                    // Imprime um Traco
		nLinha += 010
		
		//=================================== quadrado SSCC - Código de Série da Unidade Logística
		
		//Monta pré string do SSCC para calcular dígito verificador - http://www.gs1.org/how-calculate-check-digit-manually
		
		If lreimprime
			csequen  := ZFW->ZFW_SEQUEN
		Else
			csequen := getsxenum("ZFW","ZFW_SEQUEN")
		Endif
		
		cprebar := "0" + "789808064" + csequen
		
		nsoma := 0
		
		For _ni := 1 to len(cprebar)
			If int(_ni/2) == _ni/2
				nsoma +=  val(substr(cprebar,_ni,1))
			Else
				nsoma += 3 * val(substr(cprebar,_ni,1))
			Endif
		Next _ni
		
		nprox := nsoma
		
		Do while int(nprox/10) != nprox/10
			nprox++
		Enddo
		
		cdigito := alltrim(str(nprox-nsoma))
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nMeio, "SSCC - Código de Série da Unidade Logística", oFont10n,,,,2)
		nLinha += 060
		
		oPrint:Say(nLinha+nLinhAux1, nColuna + _nMeio, "0" + "789808064" + csequen + cdigito, oFont10,,,,2)
		
	ENDIF
	
	//=================================== quadrado taras
	
	nLinha += 050
	oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)                    // Imprime um Traco
	
	oPrint:Say(nLinha+nLinhAux1, nColuna + 10, "Tara Embalagem:", oFont10n)
	oPrint:Say(nLinha+nLinhAux1, nColuna + 350, transform(round(ZFW->ZFW_TREMB,3),"@E 9,999.999") + " kg", oFont10)
	nLinha += 060 - nLinhAux2
	
	oPrint:Say(nLinha+nLinhAux1, nColuna + 10, "Tara Caixa:", oFont10n)
	oPrint:Say(nLinha+nLinhAux1, nColuna + 350, transform(round(ZFW->ZFW_TRCAX,3),"@E 9,999.999") + " kg", oFont10)
	nLinha += 060 - nLinhAux2
	
	oPrint:Say(nLinha+nLinhAux1, nColuna + 10, "Tara Total:", oFont10n)
	oPrint:Say(nLinha+nLinhAux1, nColuna + 350, transform(round(ZFW->ZFW_TREMB+ZFW->ZFW_TRCAX,3),"@E 9,999.999") + " kg", oFont10)
	
	nLinha += 060
	
	//=================================== CODIGO DE BARRAS
	
	IF _lLayoutVariavel // ***************   LAYOUT  VARIAVEL  ****************************
		
		ccodbar1 := "(01)" + cgtin + "(3102)" + strzero(round((npeso - (ZFW->ZFW_TREMB+ZFW->ZFW_TRCAX))*100,0),6)//aret[2]+aret[1]
		
		ccodbar1 += "(3302)" +  strzero(round(npeso*100,0),6) + "(30)" + ALLTRIM(str(round(nquant,0)))
		
		ccodbar2 := "(15)" + substr(dtos(dvalid),3,2) +  substr(dtos(dvalid),5,2) + substr(dtos(dvalid),7,2)
		//    					ano                        mes                           dia
		
		ccodbar2 += "(11)" +  substr(dtos(dprod),3,2) +  substr(dtos(dprod),5,2) + substr(dtos(dprod),7,2)
		//						ano                        mes                           dia
		
		ccodbar2 += "(7030)" + "0763763" 
		//                      Reg SIF
	   cCodBar2Say:=ccodbar2
       ccodbar2:=STRTRAN(ccodbar2,"(","")
       ccodbar2:=STRTRAN(ccodbar2,")","")
	   ccodbar2 += "(10)" + ALLTRIM(clote)
	   cCodBar2Say+= "(10)" + ALLTRIM(clote)
		
		ccodbar3 := "(00)0" + "789808064" + csequen + cdigito
		//                       Registro GS1
		
	ELSE// ***************  LAYOUT FIXO  ****************************
		
		ccodbar1 := "(01)" + cgtin + "(15)"  + substr(dtos(dvalid),3,2) +  substr(dtos(dvalid),5,2) + substr(dtos(dvalid),7,2)
		//    					                        ano                        mes                           dia
		
		ccodbar1 += "(11)" +  substr(dtos(dprod),3,2) +  substr(dtos(dprod),5,2) + substr(dtos(dprod),7,2)
		//    					ano                        mes                           dia
		
		ccodbar2 := "(7030)" + "0763763" //+ "(10)" + ALLTRIM(clote)
		//                      Reg SIF//      IF _lSite
	    cCodBar2Say:=ccodbar2
        ccodbar2:=STRTRAN(ccodbar2,"(","")
        ccodbar2:=STRTRAN(ccodbar2,")","")
		ccodbar2 += "(10)" + ALLTRIM(clote)
	    cCodBar2Say+= "(10)" + ALLTRIM(clote)
		
		ccodbar3 := "(00)0" + "789808064" + csequen + cdigito
		//                       Registro GS1
		
	ENDIF
	
	IF _lSite

		ccodbar1:=STRTRAN(ccodbar1,"(","")
		ccodbar1:=STRTRAN(ccodbar1,")","")
		
		ccodbar3:=STRTRAN(ccodbar3,"(","")
		ccodbar3:=STRTRAN(ccodbar3,")","")
		
		_cExt     := ".gif"
		_EndHttp1 := "https://barcode.tec-it.com/barcode.ashx?data="
		_EndHttp2 := "&code=EANUCC128&multiplebarcodes=true&translate-esc=true&unit=Fit&dpi=96&imagetype=Gif&rotation=0&color=%23000000&bgcolor=%23ffffff&qunit=Mm&quiet=0"
		_cCaminho := cLocal
		
		url := _EndHttp1 + ccodbar1 + _EndHttp2
		Html  := HttpGet( Url )
		IF Html <> nil
			MemoWrite( _cCaminho + ccodbar1 + _cExt, Html )
		ENDIF
		oPrint:SayBitmap( nlinha - 05 ,ncoluna+40,_cCaminho + ccodbar1 + _cExt,1050,170 )
		
	ELSE
  
		cCodBar1Say:=ccodbar1
		ccodbar1:=STRTRAN(ccodbar1,"(","")
		ccodbar1:=STRTRAN(ccodbar1,")","")
		
		cCodBar3Say:=ccodbar3
		ccodbar3:=STRTRAN(ccodbar3,"(","")
		ccodbar3:=STRTRAN(ccodbar3,")","")

		_cTypeBar:="EAN128"//"CODE128"
		nlinha+=5
		
	ENDIF
	
	nLinha += 180
	
	IF _lSite

		url := _EndHttp1 + ccodbar2 + _EndHttp2 //+ "&code=EANUCC128&multiplebarcodes=false&translate-esc=true&unit=Fit&dpi=96&imagetype=Gif&rotation=0&color=%23000000&bgcolor=%23ffffff&qunit=Mm&quiet=0%27%20alt=%27Barcode%20Generator%20TEC-IT%27"//"&SHOW-TEXT=FALSE"
		Html  := HttpGet( Url )
		IF Html <> nil
			MemoWrite( _cCaminho + ccodbar2 + _cExt, Html )
		ENDIF
		oPrint:SayBitmap( nlinha + 55 ,ncoluna+40,_cCaminho + ccodbar2 + _cExt,1050,170 )
		
	ELSE
		
  	   oPrint:Say(nLinha-30, nColuna + 100, cCodBar1Say, oFont10)
		
		nlinha+=10
		
	ENDIF

	nLinha += 245

	IF _lSite
		
		url := _EndHttp1 + ccodbar3  + _EndHttp2//+ "&code=EANUCC128&multiplebarcodes=false&translate-esc=true&unit=Fit&dpi=96&imagetype=Gif&rotation=0&color=%23000000&bgcolor=%23ffffff&qunit=Mm&quiet=0%27%20alt=%27Barcode%20Generator%20TEC-IT%27"//"&SHOW-TEXT=FALSE"
		Html  := HttpGet( Url )
		IF Html <> nil
			MemoWrite( _cCaminho + ccodbar3 + _cExt, Html )
		ENDIF
		oPrint:SayBitmap( nlinha + 55 ,ncoluna+40,_cCaminho + ccodbar3 + _cExt,600,170 )
		
	ELSE
		
		oPrint:Say(nLinha-060, nColuna + 100, cCodBar2Say, oFont10)
		
		nlinha+=10
		
		IF _lLayoutVariavel // ***************   LAYOUT  VARIAVEL  ****************************

			
//          oPrint:FWMsBar(_cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz, nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
			oPrint:FWMSBAR(_cTypeBar,20,0.4,ccodbar1,oPrint,.T.,,.T.,0.0168,0.7,.F.,"Arial","C",.F.,1,1,.F.)
			
			oPrint:FWMSBAR(_cTypeBar,25,0.5,ccodbar2,oPrint,.T.,,.T.,0.0168,0.7,.F.,"Arial","C",.F.,1,1,.F.)
			
			oPrint:FWMSBAR(_cTypeBar,30,0.5,ccodbar3,oPrint,.T.,,.T.,0.0168,0.7,.F.,"Arial","C",.F.,1,1,.F.)
		ELSE

			oPrint:FWMSBAR(_cTypeBar,19,1,ccodbar1,oPrint,.T.,,.T.,0.0168,0.9,.F.,"Arial","C",.F.,1,1,.F.)
			
			oPrint:FWMSBAR(_cTypeBar,24,1,ccodbar2,oPrint,.T.,,.T.,0.0168,0.9,.F.,"Arial","C",.F.,1,1,.F.)
			
			oPrint:FWMSBAR(_cTypeBar,29,1,ccodbar3,oPrint,.T.,,.T.,0.0168,0.9,.F.,"Arial","C",.F.,1,1,.F.)
			
		ENDIF
		
	ENDIF
	//=================================== CODIGO DE BARRAS
	
	nLinha += 245

	IF _lSite
		nLinha += 60
	ELSE

        oPrint:Say(nLinha-100, nColuna + 100, cCodBar3Say, oFont10)
        
		nLinha += 20

	ENDIF

  	oPrint:Line(nlinhaIni,ncoluna - 5     , nlinha, ncoluna - 5     )//LINHA LATERAL ESQUERDA 
  	oPrint:Line(nlinhaIni,ncoluna + ntamh , nlinha, ncoluna + ntamh )//LINHA LATERAL DIRETA
	oPrint:Line(nlinha   ,ncoluna - 5     , nlinha ,ncoluna + ntamh )//LINHA FINAL
	
	oPrint:EndPage()                // Finaliza a Pagina de Impressao

NEXT

IF _lSite
	
    LjMsgRun( "Gerando a visualização..." , "Aguarde!" , {|| oPrint:Preview() } )//Visualiza antes de imprimir
	oPrint:End()
	
ELSE
	
	If !(oPrint:nModalResult == PD_OK)
		oPrint:Deactivate() 
		Return
	EndIf
    LjMsgRun( "Gerando a visualização..." , "Aguarde!" , {|| oPrint:Preview() } )//Visualiza antes de imprimir

ENDIF

Return nRecZFW

/*
===============================================================================================================================
Programa----------: ROMS046Fil
Autor-------------: Alex Wallauer
Data da Criacao---: 21/12/2017
===============================================================================================================================
Descrição---------: Get da filial da estrutura do produto
===============================================================================================================================
Parametros--------: cproduto: codigo do produto
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/  
STATIC function ROMS046Fil(cproduto)
LOCAL _lRet:=.T.,oDlgFil
LOCAL _cFilsSG1:=""
LOCAL _nCol1:=15
LOCAL _nCol2:=90

IF EMPTY(cproduto)
   RETURN .T.
ENDIF

SG1->(DBSETORDER(1))
IF SG1->(DBSEEK(_cFilSG1+cproduto))
   RETURN .T.
ENDIF

cquery := "SELECT G1_FILIAL FROM " + RETSQLNAME("SG1")
cquery += " WHERE D_E_L_E_T_ <> '*' AND G1_COD = '" + cproduto+"'"
cquery += " GROUP BY G1_FILIAL "

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'FilSG1', .T., .F.)
FilSG1->(DBGOTOP())

DO WHILE FilSG1->(!EOF())
   _cFilsSG1+=FilSG1->G1_FILIAL+", "
   FilSG1->(DBSKIP())
ENDDO

FilSG1->(Dbclosearea())
DBSELECTAREA("ZFW")

_cFilsSG1:=LEFT(_cFilsSG1,LEN(_cFilsSG1)-2)

DO WHILE .T.

   @ 000, 000 To 140, 300 Dialog oDlgFil Title "Produto "+ALLTRIM(cproduto)+IF(EMPTY(_cFilsSG1)," NÃO possui estrutura","")
    
    IF !EMPTY(_cFilsSG1)
    
	   @ 011, 015 Say "Filial da Estrutura do Produto" PIXEL
	   @ 010, 100 Get _cFilSG1 Picture "99"  Size 030, 010 F3 "SM0"
	   @ 023, 015 Say "Filiais com Estrutura desse Produto: "+_cFilsSG1 PIXEL

     ELSE

	   @ 005, _nCol1 Say "Tara Embalagem:" PIXEL
	   @ 005, _nCol2 Get _nTaraEmb Picture "@E 999.999"  Size 030, 010 VALID NaoVazio(_nTaraEmb) .AND. Positivo(_nTaraEmb) PIXEL

	   @ 020, _nCol1 Say "Tara Caixa:" PIXEL
	   @ 020, _nCol2 Get _nTaraCx Picture "@E 999.999"  Size 030, 010 VALID NaoVazio(_nTaraCx) .AND. Positivo(_nTaraCx) PIXEL

    ENDIF

	@ 040, 030 BmpButton Type 1 Action ( _lRet := .T. ,  Close(oDlgFil))
	@ 040, 100 BmpButton Type 2 Action ( _lRet := .F. ,  Close(oDlgFil))

   Activate Dialog oDlgFil Centered

   IF _lRet
      IF !EMPTY(_cFilsSG1)
         SG1->(DBSETORDER(1))
         IF EMPTY(_cFilSG1) .OR. !SG1->(DBSEEK(_cFilSG1+cproduto))
            U_ITMSG("Não existe estrutura desse produto na filial informada","Atenção","Selecione uma da(s) filiais ("+_cFilsSG1+") que possua estrutura para esse produto: "+cproduto,1)
            LOOP
         ENDIF
      ELSE
         IF !( NaoVazio(_nTaraEmb) .AND. Positivo(_nTaraEmb) .AND. NaoVazio(_nTaraCx) .AND. Positivo(_nTaraCx) )
            LOOP
         ELSEIF _nTaraEmb+_nTaraEmb >= npeso
            U_ITMSG("A soma das Taras não podem ser maior que o peso Bruto","Atenção","Digite valores cujo a soma ser menor que "+TRANSFORM(ROUND(npeso,2),"@E 9,999,999.99")+" kg.",1)
            LOOP
         ENDIF
      ENDIF
   ENDIF                             

   EXIT
   
ENDDO

RETURN _lRet


/*
===============================================================================================================================
Programa----------: ROMS046Tot
Autor-------------: Alex Wallauer
Data da Criacao---: 21/12/2017
===============================================================================================================================
Descrição---------: calcula a qtde de caixa
===============================================================================================================================
Parametros--------: cproduto: codigo do produto ; _cCalc: decide o retorno ; nquant: QUANTIDADE dentro da caixa
===============================================================================================================================
Retorno-----------: Retorna Total de caixas do produto ou a quantidade na caixa e preenche a nquant _nPesDigCaixa
===============================================================================================================================
*/  
Static function ROMS046Tot(cproduto,_cCalc,nquant)
LOCAL _nTotSB1:=0,_nPesPac,_n1Kg

SB1->(DBSETORDER(1))
IF SB1->(DBSEEK(xfilial("SB1")+cproduto))
	IF _cCalc == "QTDE"

       IF SB1->B1_UM = "KG" .AND. SB1->B1_SEGUM = "CX"

          ZA2->(DBSETORDER(1))
          IF !ZA2->(DBSEEK(xfilial()+SB1->B1_I_NIV3)) .OR. !"G" $ UPPER(ZA2->ZA2_DESCRI)
             RETURN 0
          ENDIF
          _nPesPac:=VAL(ALLTRIM(ZA2->ZA2_DESCRI))
          _n1Kg   :=(1000/_nPesPac)//qtde de pacotinhos em 1 KG
          _nQtePacCX   := _n1Kg * SB1->B1_CONV//qtde de pacotinhos em 1 caixa
          nquant:=IF(nquant>0,nquant,_nQtePacCX)
          _nPesDigCaixa:= nquant * (_nPesPac/1000) //Peso do pacotes digitados

          RETURN _nQtePacCX//Qtde na caixa para produto fixo

       ELSEIF SB1->B1_UM = "KG"  .AND. SB1->B1_I_3UM = "CX"

          RETURN SB1->B1_I_QT3UM//Qtde na caixa para produto vairavel

       ELSEIF SB1->B1_UM = "UN" .AND. SB1->B1_SEGUM = "CX"

          RETURN SB1->B1_CONV //Qtde na caixa para produto fixo

       ELSE

          RETURN 0

       ENDIF  

	ELSE

		IF SB1->B1_I_UMPAL <> SB1->B1_I_QTOC3 .AND. !EMPTY(SB1->B1_I_QTOC3)

			_nTotSB1:=(SB1->B1_I_CXPAL / SB1->B1_I_QT3UM)

		ELSE

			_nTotSB1:=SB1->B1_I_CXPAL

		ENDIF

	ENDIF
	
ENDIF

RETURN _nTotSB1

/*
===============================================================================================================================
Programa----------: ROMS046Caixa
Autor-------------: Alex Wallauer
Data da Criacao---: 22/12/2017
===============================================================================================================================
Descrição---------: Verifica número de caixa do novo registro
===============================================================================================================================
Parametros--------: _lValida:  .T. ou .F.
===============================================================================================================================
Retorno-----------: string com número da caixa
===============================================================================================================================*/  

STATIC FUNCTION ROMS046Caixa(_lValida)

Local _xCaixa   := ""
Local cquery    := ""
LOCAL _nQtePacCX:=0

cquery := "SELECT ZFW_CAIXA, COUNT(ZFW_CAIXA) QTDE,"
cquery += " SUM(ZFW_QUANT) QUANT"
cquery += " FROM " + retsqlname("ZFW") + " WHERE D_E_L_E_T_ <> '*' AND ZFW_FILIAL = '" + xFilial("ZFW") +"'" 
cquery += " AND ZFW_PRODUT = '" + cproduto + "' AND ZFW_TIPO = 'C'" 
IF _lValida
   cquery += " AND ZFW_CAIXA = '" + _cCaixa + "'" 
   _xCaixa:=.T.
ENDIF
cquery += " GROUP BY ZFW_CAIXA ORDER BY ZFW_CAIXA "

DBUSEAREA(.T., "TOPCONN", TCGENQRY(,,CQUERY), 'TSD1', .T., .F.)

_nQtePacCX:=ROMS046Tot(cproduto,"QTDE",nquant)

DO WHILE !TSD1->(Eof())
    
	IF _lValida
  	   _nTotC:=(TSD1->QUANT+nquant)
  	   _xCaixa:=.T.
    ELSE
  	   _nTotC:=TSD1->QUANT  	   
    ENDIF
	If !_lValida .AND. _nTotC < _nQtePacCX//Procura CAIXA incompleto
       _xCaixa := TSD1->ZFW_CAIXA
       EXIT
	ELSEIF _lValida .AND. _nTotC > _nQtePacCX
       U_ITMSG("Essa caixa já tem "+ALLTRIM(STR(TSD1->QUANT))+" unidades" ,"Atenção","Digite no maximo mais "+ALLTRIM(STR(_nQtePacCX-TSD1->QUANT))+" pacote(s).",1)
       TSD1->(Dbclosearea())
       RETURN .F.
	ENDIF

	TSD1->(Dbskip())
		
Enddo

TSD1->(Dbclosearea())

//Se não achou caixa incompleto faz um novo pallet
If EMPTY(_xCaixa) .AND. !_lValida

	cquery := "SELECT MAX(ZFW_CAIXA) NUM FROM " + RETSQLNAME("ZFW") + " WHERE D_E_L_E_T_ <> '*' AND ZFW_FILIAL = '" + xFilial("ZFW") +"'"   

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TSD1', .T., .F.)

	If TSD1->(Eof()) 
		_xCaixa := STRZERO(1,LEN(ZFW->ZFW_CAIXA))
	Else
		_xCaixa := STRZERO(VAL(TSD1->NUM)+1,LEN(ZFW->ZFW_CAIXA))
	Endif
	
	TSD1->(Dbclosearea())
	
Endif

Return _xCaixa
