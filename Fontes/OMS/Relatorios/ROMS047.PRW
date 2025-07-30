/*
===============================================================================================================================
               ULTIMAS ATUALIZACOES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer 	  | 04/04/2017 | Foi criado relatório para apresentar as informações de desconto contratual. Chamados: 19135	        
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     	  | 24/05/2019 | Alterar relatório de descontos contratuais e incluir opção de filtro por codigo de rede. 
				  |			   | Chamado 29318. 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  	  | 17/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346

====================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
===========================================================================================================================================================================================================================================================
Antonio  - Igor Melgaço - 29/09/24 - 29/09/24 -  47942  - Correção do error.log (cannot find fun ction ALTRIM) da Parte 1.
Antonio  - Igor Melgaço - 18/07/25 - 18/07/25 -  49904  - Inclusão de Valores de IPI e Analises de Totatilzadores
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "protheus.ch"

/*
===============================================================================================================================
Programa----------: ROMS047
Autor-------------: Alex Wallauer
Data da Criacao---: 04/04/2017
===============================================================================================================================
Descrição---------: Relatorio dos descontos contratual
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ROMS047()//U_ROMS047()

Private _cPerg := "ROMS047"
Private _aLista:= {}
Private _aTit  := {}

DO WHILE .T.

   IF !Pergunte( _cPerg , .T. )
      EXIT
   ENDIF

   lSair:=.F.
   Processa({|| lSair:=ROMS47Ger() } )

   IF lSair
      EXIT
   ENDIF

   IF !ROMS47Tela()
      EXIT
   ENDIF

ENDDO

Return
/*
===============================================================================================================================
Programa----------: ROMS47Tela
Autor-------------: Alex Wallauer
Data da Criacao---: 04/04/2017
===============================================================================================================================
Descrição---------: Relatorio dos descontos contratual
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function ROMS47Tela()

LOCAL cTit := "Filtros: Filiais ("+ALLTRIM(MV_PAR01)+")  /  Fornecedores de ("+mv_par02+"-"+mv_par03+") ate ("+mv_par04+"-"+mv_par05+")  /  Datas de "+DTOC(mv_par06)+" ate "+DTOC(mv_par07)+""

LOCAL aSiz := NIL

LOCAL lRet := U_ITListBox('Relatorio dos descontos contratual (ROMS047)',_aTit,_aLista,.T.,4,cTit,,aSiz)


RETURN !lRet

/*
===============================================================================================================================
Programa----------: ROMS042PR
Autor-------------: Alex Wallauer
Data da Criacao---: 04/04/2017
===============================================================================================================================
Descrição---------: Executa relatório
===============================================================================================================================
*/
Static Function ROMS47Ger()

Local _aSalveArea:=GetArea()
Local _cFiltro   := "% "
Local _PictValor :="@E 99,999,999,999.99"
Local L			:= 0
ProcRegua(3)
IncProc("Lendo dados...")
IncProc("Lendo dados...")

If !empty(MV_PAR01)
   _cFiltro += " D2_FILIAL IN " + FormatIn(ALLTRIM(MV_PAR01),";") + " AND "
Endif
_cFiltro += " ZAY.ZAY_FILIAL = '"+xfilial("ZAY")+"'"
_cFiltro += " AND ZAY.ZAY_TPOPER = 'V' "
_cFiltro += " AND D2_CLIENTE BETWEEN '"+ MV_PAR02 + "' AND '" + MV_PAR04 + "' "
_cFiltro += " AND D2_LOJA    BETWEEN '"+ MV_PAR03 + "' AND '" + MV_PAR05 + "' "
_cFiltro += " AND D2_EMISSAO BETWEEN '"+ DtoS( MV_PAR06 ) +"' AND '"+ DtoS( MV_PAR07 ) +"' "

If !empty(MV_PAR08)
   _cFiltro += " AND A1_GRPVEN IN " + FormatIn(ALLTRIM(MV_PAR08),";") 
Endif

_cFiltro += " %"

BeginSql alias "QRY1"
			
	SELECT D2_FILIAL, D2_DOC, D2_SERIE, D2_EMISSAO, D2_CLIENTE, D2_LOJA, D2_ITEM, D2_COD, D2_CF, D2_VALBRUT, D2_TOTAL, D2_ICMSRET, D2_PEDIDO,
	      (D2_I_VLRDC + D2_I_VLPAR) VLRDC, D2_I_PRCDC , D2_TES , D2_ITEMPV, D2_VALIPI //, A1_NREDUZ, B1_DESC, F2_I_DCUST
			      FROM %table:SD2% SD2
			INNER JOIN %TABLE:ZAY% ZAY ON SD2.D2_CF = ZAY.ZAY_CF AND ZAY.%notDel%
         INNER JOIN %TABLE:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA AND SA1.%notDel%
			WHERE %exp:_cFiltro% AND SD2.%notDel%
	ORDER BY  D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA

EndSql

IncProc("Lendo dados...")

COUNT TO nTotal

ProcRegua(nTotal)

SA1->(DBSetOrder(1))
SF2->(DBSetOrder(1))
SC6->(DbSetorder(1))

QRY1->(DBGOTOP())

_cChaveNF  :=QRY1->D2_FILIAL+QRY1->D2_DOC+QRY1->D2_SERIE
_aLista    :={}
_nTotTitulo:=0
_nTotNFDesc:=0
_nContador :=0
cTotal     :=ALLTRIM(STR(nTotal))

DO WHILE QRY1->(!EOF())
   
   _nContador++
   IncProc("Lendo NF: "+QRY1->D2_DOC+" - "+ALLTRIM(STR(_nContador))+" / "+cTotal)
   
   SA1->(DBSEEK(xFilial()+QRY1->D2_CLIENTE+QRY1->D2_LOJA ))
   SF2->(DBSEEK(QRY1->D2_FILIAL+QRY1->D2_DOC+QRY1->D2_SERIE ))
   _lTemPV:=SC6->(DbSeek(QRY1->D2_FILIAL+QRY1->D2_PEDIDO+QRY1->D2_ITEMPV))

   _cDescB1   := ALLTRIM(LEFT(Posicione("SB1" , 1 , xFilial("SB1") + QRY1->D2_COD , "B1_DESC"),35))
   _cDCust    := Iif(SF2->F2_I_DCUST == "S", "SIM", "NÃO")
   _cDCIPI    := IIf(SF2->F2_I_DCIPI == "S", "SIM", "NÃO")
   _nPerDPV   := 0
   _nVDCUSPV  := 0
   _nItemNFDes:= 0
   _nTotNFDesc+= QRY1->VLRDC

   If _lTemPV 

      _nVDCUSPV := _nPerDPV := SC6->C6_I_PDESC
	  IF _nVDCUSPV # 0
		 If SF2->F2_I_DCUST = "S" // POSICIONE("ZAZ",1,xfilial("ZAZ")+SF2->F2_I_NRZAZ,"ZAZ_STBAS") = "S"  (posso usar o contrato da NF ou) // M->C5_I_NRZAZ (o contrato do PV)
		    _ntotal := QRY1->D2_TOTAL + QRY1->D2_ICMSRET
		 Else
		    _ntotal := QRY1->D2_TOTAL
		 Endif			

       If SF2->F2_I_DCIPI = "S"
         _ntotal := _nTotal + QRY1->D2_VALIPI
       EnDiF
       
	     _nItemNFDes := round(_ntotal * ( _nVDCUSPV / 100 ),2)	//Valor do desconto integral
	  ENDIF		

   ELSEIf ( Posicione( "SF4" , 1 , QRY1->D2_FILIAL + QRY1->D2_TES , "F4_DUPLIC" ) == 'S' )

	  _aDados := U_veriContrato( QRY1->D2_CLIENTE , QRY1->D2_LOJA , QRY1->D2_COD ) //Verifica se existe calculo para o desconto
			
	  //Verifica o desconto integral                                                 |
	  If _aDados[1] > 0
		 //Se estiver aprovado pelo financeiro e com data de vigencia ativa             |
		 If _aDados[2] .And. _aDados[3]
			//Verifica se considera ST como base do desconto                               |
			If POSICIONE("ZAZ",1,xfilial("ZAZ")+_aDados[4],"ZAZ_STBAS") = "S"
			   _ntotal := QRY1->D2_TOTAL + QRY1->D2_ICMSRET
			Else
			   _ntotal := QRY1->D2_TOTAL
			Endif			

			If POSICIONE("ZAZ",1,xfilial("ZAZ")+_aDados[4],"ZAZ_IPIBAS") = "S"
            _nTotal := _nTotal + QRY1->D2_VALIPI
         EndIf

         _nVDCUSPV     := _aDados[1]
			_nItemNFDes := round(_ntotal * ( _aDados[1] / 100 ),2)	//Valor do desconto integral
			_nItemNFDes += round(_ntotal * ( _aDados[5] / 100 ),2)	//Valor do desconto parcial

		 Endif			
	  Endif			
   
   Endif

                                                                                                                                                                                                //"PV %"    ,"NF %"             ,"PV Desconto"       ,"NF Desconto"     ,"DP Desconto"     ,"DIF PV / NF" ,"EXCLUIR COLUNA" ,"DIF NF / DP"
   _cDifItemPVNF:= TRANSF(QRY1->VLRDC-_nItemNFDes,_PictValor)                                   																									//%Desc PV      %Desc NF            ,"Vlr Desc. Item PV","Vlr Desc. Item NF","Vlr Desc. Titulo","Vlr Dif Item","Vlr Desconto NF","Vlr Dif Titulo"
   _lIgual:= (ROUND(QRY1->VLRDC-_nItemNFDes,2) = 0)                                                                                                                                                      //"Vlr Desc. Item PV","% Desc NF","Vlr Desc. Item NF","Vlr Dif Item","Vlr Desconto NF","Vlr Desc. Titulo","Vlr Dif Titulo","Utiliza ST?"}
                                                                                                                                                                                                   //_nItemNFDes        ,D2_I_PRCDC ,VLRDC              ,_cDifItemPVNF ,0                ,0                 ,0               ,_cDCust      } ))
               _aTit := {" "    ,"Filial" ,"Documento","Emissão"             ,"Cliente" ,"Loja" ,"Nome"        ,"Produto","Descrição","Valor Mercadoria NF","ICMS Ret","Utiliza ST?","Uti. IPI?","Vlr. Bruto NF","Val.IPI", "Pedido" ,"PV %"   ,"NF %"    ,"PV Desconto","NF Desconto","DP Desconto","DIF PV / NF" ,"DIF NF / DP"}
   QRY1->( AADD(_aLista,{_lIgual,D2_FILIAL,D2_DOC     ,DTOC(STOD(D2_EMISSAO)),D2_CLIENTE,D2_LOJA,SA1->A1_NREDUZ,D2_COD   ,_cDescB1   ,D2_TOTAL             ,D2_ICMSRET,_cDCust      ,_cDCIPI    ,D2_VALBRUT     ,D2_VALIPI, D2_PEDIDO,_nVDCUSPV,D2_I_PRCDC,_nItemNFDes  ,QRY1->VLRDC  ,0            ,_cDifItemPVNF ,0            } ))
                        // 1    ,2        ,3          ,4                     ,5         ,6      ,7             ,8        ,9          ,10                   ,11        ,12           ,13         ,14             ,15       ,16        ,17       ,18        ,19           ,20           ,21           ,22            ,23                         

   FOR L := 1 TO LEN(_aLista[LEN(_aLista)])
       IF VALTYPE(_aLista[LEN(_aLista),L]) = "N"
          _aLista[LEN(_aLista),L] := TRANSF(_aLista[LEN(_aLista),L], _PictValor )
       ENDIF
   NEXT

   QRY1->(DBSKIP())

   IF _cChaveNF # QRY1->D2_FILIAL+QRY1->D2_DOC+QRY1->D2_SERIE

      _nTotTitulo:= ROMS47Tit(SF2->F2_FILIAL + SF2->F2_CLIENTE + SF2->F2_LOJA + "DCT" + SF2->F2_DOC,SF2->F2_DOC)      

      _nPos:=21
    //_aLista[LEN(_aLista),_nPos+0]:=TRANSF(_nTotNFDesc, _PictValor )          //"Vlr Desconto NF"
      _aLista[LEN(_aLista),_nPos+0]:=TRANSF(_nTotTitulo, _PictValor )          //"Vlr Desc. Titulo"//19
      _aLista[LEN(_aLista),_nPos+2]:=TRANSF(_nTotNFDesc-_nTotTitulo,_PictValor)//"Vlr Dif Titulo"  //21

      _aLista[LEN(_aLista),01]:= (_aLista[LEN(_aLista),01] .AND. (ROUND(_nTotNFDesc-_nTotTitulo,2) = 0))

      _cChaveNF  :=QRY1->D2_FILIAL+QRY1->D2_DOC+QRY1->D2_SERIE
      _nTotNFDesc:=0
      
   ENDIF

ENDDO

QRY1->(DBCLOSEAREA())

RestArea(_aSalveArea)

Return !LEN(_aLista) > 0


/*
===============================================================================================================================
Programa----------: ROMS47Tit()
Autor-------------: Alex Wallauer
Data da Criacao---: 04/04/2017
===============================================================================================================================
Descrição---------: Função para ler os titulos
===============================================================================================================================
*/
Static Function ROMS47Tit(cChaveSE1,_cDoc)

Local _nE1NccV	:= 0
                 
SE1->( DBSetOrder(2) ) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
IF SE1->( DbSeek( cChaveSE1 ) )

   DO While SE1->( !EOF() ) .AND. SE1->E1_NUM = _cDoc

	   If SE1->E1_TIPO = "NCC"
		
	      _nE1NccV += SE1->E1_VALOR
	    	
	   EndIf
		
	   SE1->( DBSkip() )
	
	EndDo
	
EndIf

RETURN _nE1NccV
