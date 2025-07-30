/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |27/05/2025| Chamado 50617. Revisões diversas visando padronizar os fontes
Lucas Borges  |19/06/2025| Chamado 50617. Revisões diversas visando padronizar os fontes
===============================================================================================================================
========================================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
========================================================================================================================================================================
Andre       - Alex Wallauer - 05/06/25 -          - 50929   - Ajustes para salvar a área do SC7 e restaurar ela e o recno.
==============================================================================================================================================================================================
*/

#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: ACOM011
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 02/12/2015
Descrição---------: Rotina desenvolvida para Liberação Gestor de Compras
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM011

Local aArea		:= FWGetArea() As Array
Local cFilPC	:= SuperGetMV("IT_FILWFPC",.F.,"01") As Character
Local lFilPC	:= Iif(cFilAnt $ cFilPC,.T.,.F.) As Logical
Local nUsado 	:= 0 As Numeric
Local cPedido	:= SC7->C7_NUM As Character
Local oGetGrpA 	:= Nil As Object
Local oGetGrpN	:= Nil As Object
Local cGetGrpN	:= Space(TamSX3("AL_NOME")[1]) As Character
Local oGroupA	:= Nil As Object
Local oSayGrpA	:= Nil As Object
Local oSButton1	:= Nil As Object
Local oSButtonOk:= Nil As Object
Local nX,nA		:= 0 As Numeric
Local aFields		:= {"AL_ITEM","AL_COD","AL_USER","AL_NOME","AL_NIVEL","AL_TPLIBER"} As Array
Local aAlterFields	:= {} As Array
Local aColsAux		:= {} As Array
Local nOpca			:= 0 As Numeric
Local dEmissao		:= CtoD("//") As Date
Local lContinua		:= .T. As Logical

Private aHeader		:= {} As Array
Private aCols		:= {} As Array
Private oDlgApr		:= Nil As Object
Private oMSNewApr	:= Nil As Object
Private _aHeaderSAL := {} As Array
Private cGetGrpA	:= Space(TamSX3("AL_COD")[1]) As Character

Begin Sequence

	If lFilPC
		ZZL->(dbSetOrder(3))
	  	If ZZL->(dbSeek(xFilial("ZZL") + __cUserID))
			//===============================================================
			// Grava log da rotina liberação Gestor de Compras 
			//=============================================================== 
			U_ITLOGACS('ACOM011')
		
			If ZZL->ZZL_GCOM == "S"
				SC7->(dbSetOrder(1))
				If SC7->(dbSeek(xFilial("SC7") + cPedido))
					lContinua := U_ACOM011V(xFilial("SC7"), cPedido, .T.)
					If lContinua
						SC7->(dbSeek(xFilial("SC7") + cPedido))
						DO WHILE SC7->(!EOF()) .And. cPedido == SC7->C7_NUM .AND. SC7->C7_FILIAL == xFilial("SC7")
			         		If SC7->C7_CONAPRO == "B" .And. SC7->C7_QUJE < SC7->C7_QUANT .And. SC7->C7_APROV == "PENLIB" .AND. SC7->C7_RESIDUO != 'S'
								//                     1            2         3           4          5        6        7       8       9       10          11      12        13       14         15        16   17
								// aAdd(aHeader,{trim(x3_titulo),x3_campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo, x3_f3,x3_context,	x3_cbox,x3_relacao,x3_when,X3_TRIGGER,	X3_PICTVAR,.F.,.F.})
								aHeader := {}

								aCols   := {}
								For nUsado := 1 to len(aFields)
									_cCampo:=aFields[nUsado]
									_cUsado:=Getsx3cache(_cCampo,"X3_USADO")
									If X3USO(_cUsado)
										aAdd( aHeader , {Getsx3cache(_cCampo,"X3_TITULO") ,;
														Getsx3cache(_cCampo,"X3_CAMPO") ,;
														Getsx3cache(_cCampo,"X3_PICTURE") ,;
														Getsx3cache(_cCampo,"X3_TAMANHO") ,;
														Getsx3cache(_cCampo,"X3_DECIMAL") ,;
														Getsx3cache(_cCampo,"X3_VALID") ,;
														_cUsado                         ,;
														Getsx3cache(_cCampo,"X3_TIPO") ,;
														Getsx3cache(_cCampo,"X3_F3") ,;
														Getsx3cache(_cCampo,"X3_CONTEXT") })
									Endif
								Next nUsado
								aColsAux:= {}
      
								For nX := 1 To Len(aHeader)
									If Ascan(aFields, AllTrim(aHeader[nX,2])) > 0
										Aadd(_aHeaderSAL,aHeader[nX])
										If aHeader[nX,8] == "C"      // SX3->X3_TIPO == "C"
											Aadd(aColsAux, "")
										ElseIf aHeader[nX,8] == "N"  // SX3->X3_TIPO == "N"
											Aadd(aColsAux, 0)
										ElseIf aHeader[nX,8] == "D"  // SX3->X3_TIPO == "D"
											Aadd(aColsAux, StoD(""))
										EndIf
									EndIf
								Next nX
			
								Aadd(aColsAux, .F.)
								Aadd(aCols, aColsAux)
								aHeader := AClone(_aHeaderSAL)
								_cF3:="SAL"

								SY1->(dbSetOrder(3))
								IF SY1->(dbSeek(xFilial("SY1") + SC7->C7_USER))
									_cGrpLeite:= ACOM11_ZP1("IT_GRPLEIT")
									IF SY1->Y1_GRUPCOM $ _cGrpLeite
										_cGrpALeite:= ALLTRIM(SuperGetMV("IT_GRPALEI",.F.,""))							  
										IF !EMPTY(_cGrpALeite)
											_cF3:="F3ITLC"
											_cSelecSAL:="SELECT DISTINCT AL_COD , AL_DESC  , AL_USER , AL_NIVEL  FROM "+RETSQLNAME("SAL")+" SAL WHERE D_E_L_E_T_ = ' ' AND AL_MSBLQL <> '1'  AND  AL_COD IN " + FormatIn(_cGrpALeite,";") +" ORDER BY AL_COD , AL_NIVEL " 
											_aItalac_F3:={}//       1           2         3                      4                      5                                          6                   7         8          9         10         11        12
											//  (_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave            , _nCpoDesc              ,_bCondTab                               , _cTitAux           , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
											AADD(_aItalac_F3,{"cGetGrpA" ,_cSelecSAL,{|Tab| (Tab)->AL_COD }, {|Tab| UsrRetName((Tab)->AL_USER)  +" // "+ALLTRIM((Tab)->AL_DESC)+" // "+(Tab)->AL_NIVEL}  , ,"Grupo Aprovadores" ,          ,          , 1        ,.F.        ,       , } )
										ENDIF
									ENDIF						   
								ENDIF
								SAJ->(DBSETORDER(1))
		
								DEFINE MSDIALOG oDlgApr TITLE "Grupos de Aprovação" FROM 000, 000  TO 205, 500 COLORS 0, 16777215 PIXEL

									@ 005, 006 SAY oSayGrpA PROMPT "Grupo Aprovador" SIZE 044, 007 OF oDlgApr COLORS 0, 16777215 PIXEL
									@ 005, 054 MSGET oGetGrpA VAR cGetGrpA SIZE 032, 010 OF oDlgApr COLORS 0, 16777215 F3 _cF3 VALID {|| ACOM011F(cGetGrpA, @cGetGrpN)} PIXEL
									@ 017, 054 MSGET oGetGrpN VAR cGetGrpN SIZE 158, 010 OF oDlgApr COLORS 0, 16777215 PIXEL
									@ 031, 003 GROUP oGroupA TO 086, 246 PROMPT "Aprovadores" OF oDlgApr COLOR 0, 16777215 PIXEL
									oMSNewApr := MsNewGetDados():New( 038, 007, 083, 242, 0, "AllwaysTrue", "AllwaysTrue", "", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgApr, aHeader, aCols)
									DEFINE SBUTTON oSButtonOk FROM 089, 091 TYPE 01 OF oDlgApr ENABLE Action (nOpca := 1, oDlgApr:End())
									DEFINE SBUTTON oSButton1 FROM 089, 120 TYPE 02 OF oDlgApr ENABLE Action oDlgApr:End()
			
								ACTIVATE MSDIALOG oDlgApr CENTERED
									
								If nOpca == 1
									Begin Transaction
										dbSelectArea("SC7")
										SC7->(dbSetOrder(1))
				
										If SC7->(dbSeek(xFilial("SC7") + cPedido))
											//Grava aprovador no Sc7
											_nTotPed:=0
											_nItem:=0
											MaFisEnd()
											aRefImp	:= MaFisRelImp('MT100',{"SC7"})
											aStru		:= FWFormStruct(3,"SC7")[1]

											DO While SC7->(!EOF()) .And. cPedido == SC7->C7_NUM .AND. SC7->C7_FILIAL == xFilial("SC7")
												MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",aRefImp)						
												MaFisIniLoad(1)
												_nItem++
												For nA := 1 To Len(aRefImp)
													nPos := aScan(aStru,{|x| AllTrim(x[3]) == AllTrim(aRefImp[nA][2])})
													If nPos > 0 .And. !aStru[nPos,14]
														MaFisLoad(aRefImp[nA][3],SC7->(&(aRefImp[nA][2])),1)
													Endif
												Next nA
												MaFisRecal("",1)
												MaFisEndLoad(1)
												MaFisAlt("IT_ALIQIPI",SC7->C7_IPI    ,1)
												MaFisAlt("IT_ALIQICM",SC7->C7_PICM   ,1)
												MaFisAlt("IT_VALSOL" ,SC7->C7_ICMSRET,1)
												MaFisWrite(1,"SC7",1)
												_nTotPed += MaFisRet(1,"IT_TOTAL")
												MaFisEnd()
		
												dEmissao := SC7->C7_EMISSAO
												SC7->(RecLock("SC7",.F.))
												SC7->C7_APROV   := cGetGrpA
												SC7->C7_I_GCOM  := __cUserID
												SC7->C7_I_DTLIB := Date()
												SC7->C7_I_HRLIB := Time()
												SC7->(MsUnLock())
												SC7->(dbSkip())
											Enddo

											//Inclui linhas de aprovador no SCR
											SAL->(Dbsetorder(2))//AL_FILIAL+AL_COD+AL_NIVEL
											If SAL->(Dbseek(xfilial("SAL")+cGetGrpA))
												nConta:=0
												Do while !(SAL->(Eof())) .and. alltrim(cGetGrpA) == SAL->AL_COD
													IF SAL->AL_MSBLQL = '1' 
														SAL->(Dbskip())  
														LOOP									   
													ENDIF										     
													nConta++
													SCR->(Reclock("SCR",.T.))
													SCR->CR_FILIAL := xfilial("SCR")
													SCR->CR_num 	:= cPedido
													SCR->CR_TIPO 	:= "PC"
													SCR->CR_USER	:= SAL->AL_USER
													SCR->CR_APROV	:= SAL->AL_APROV
													SCR->CR_NIVEL	:= SAL->AL_NIVEL
													SCR->CR_STATUS	:= IF(nConta > 1 ,'01','02')//Não olhamos o nivel mais pq o aprovador anterior pode esta bloqueado
													SCR->CR_EMISSAO:= DDATABASE
													SCR->CR_MOEDA	:= 1
													SCR->CR_TXMOEDA:= 1
													SCR->CR_GRUPO 	:= cGetGrpA
													SCR->CR_TOTAL 	:= _nTotPed
													SCR->(Msunlock())
														
													SAL->(Dbskip())
												Enddo
											Endif
										EndIf
										FWAlertSuccess('Processo concluído com sucesso.',"ACOM01101")
									End Transaction
								Else
									FwRestArea(aArea)
									Break 
								EndIf
							ElseIF SC7->C7_RESIDUO == 'S'
								FWAlertInfo("Pedido de Compras eliminado por residuo. Verifique a Situação atual do Pedido de Compras.","Liberação PC - Gestor de Compras - ACOM01102")
								FwRestArea(aArea)
								Break 
							Else
								FWAlertInfo("Pedido de Compras já liberado pelo Gestor de Compras. Verifique a Situação atual do Pedido de Compras.","Liberação PC - Gestor de Compras - ACOM01103")
								RestArea(aArea)
								break
							EndIf
				
							SC7->(Dbskip())
						EndDo
					EndIf
			 	EndIf
		  Else
			 FWAlertWarning( __cUserID + " - " + cUserName + ", sem permissão para utilizar esta funcionalidade. "+;
					"Por favor comunicar a área de Compras que é responsável por solicitar para TI a liberação desta funcionalidade.","Liberação PC - Gestor de Compras - ACOM01104")
			 RestArea(aArea)
			 Break
		  EndIf
	   Else
		  FWAlertWarning( __cUserID + " - " + cUserName + ", sem permissão para utilizar esta funcionalidade. "+;
			       "Por favor comunicar a área de Compras que é responsável por solicitar para TI a liberação desta funcionalidade.","Liberação PC - Gestor de Compras - ACOM01105")
		  FwRestArea(aArea)
	  	  Break // Return
	   EndIf
    Else
	     FWAlertWarning("Filial não habilitada para aprovação de pedido de compras. "+;
				 "Filial não habilitada para aprovação de pedido de compras para TI a liberação desta filial.","Liberação PC - Gestor de Compras - ACOM01106")
    EndIf
End Sequence

FwRestArea(aArea)

Return

/*
===============================================================================================================================
Programa----------: ACOM011F
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 02/12/2015
Descrição---------: Função criada para carregamento do grid
Parametros--------: cGetGrpA - Código do grupo
                    cGetGrpN - Nome do grupo
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ACOM011F(cGetGrpA As Character, cGetGrpN As Character)

Local aArea	    := FWGetArea() As Array
Local cQuery    := "" As Character
Local cAlias	:= GetNextAlias() As Character
Local nX		:= 0 As Numeric
Local aColsAux	:= {} As Array
Local aForaLim	:= {} As Array
Local lRet		:= .T. As Logical
Local _cNome	:= "" As Character
Local _cObs		:= "" As Character
Local _cAlias   := GetNextAlias() As Character
LOCAL _cPV      := SC7->C7_NUM As Character
Local _bGetMv   := {|x| GETMV("MV_SIMB"+x )} As Codeblock

cQuery := "SELECT R_E_C_N_O_ SALREC "
cQuery += "FROM " + RetSqlName("SAL") + " "
cQuery += "WHERE AL_FILIAL = '" + xFilial("SAL") + "' "
cQuery += "  AND AL_COD = '" + cGetGrpA + "' "
cQuery += "  AND AL_MSBLQL = '2' "
cQuery += "  AND D_E_L_E_T_ = ' ' "
cQuery += "  ORDER BY AL_COD, AL_NIVEL  "
cQuery := ChangeQuery(cQuery)
MPSysOpenQuery(cQuery,cAlias)

(cAlias)->( dbGotop() )

If (cAlias)->( !Eof() )
	oMSNewApr:aCols := {}
	
	BeginSQL Alias _cAlias
		SELECT SUM(SC7.C7_TOTAL) C7TOTAL
		FROM %Table:SC7% SC7
		WHERE SC7.C7_FILIAL=%xFilial:SC7% AND	SC7.C7_NUM = %Exp:_cPV% AND
		SC7.%NotDel%
	EndSQL
	_nTotal:=(_cAlias)->C7TOTAL
	(_cAlias)->(dbCloseArea())
	DHL->(dbSetOrder(1))
	
	DO WHILE (cAlias)->( !Eof() )
		
		SAL->(DBGOTO( (cAlias)->SALREC) )
		cGetGrpN := SAL->AL_DESC
		_cNome:=Posicione("SAK",2,xFilial("SAK")+SAL->AL_USER,"AK_NOME")

		_nLimPerfil:=0
		_cMoePV :=ALLTRIM(Eval(_bGetMV, STR(SC7->C7_MOEDA,1)))
		_cMoeDHL:=""
		IF DHL->(MsSeek(xFilial("DHL")+SAL->AL_PERFIL))//Perfil
			_nLimPerfil:=DHL->DHL_LIMMAX
			_cMoeDHL:=ALLTRIM(Eval(_bGetMv,STR(DHL->DHL_MOEDA,1)))
			_cObs:=""
			IF _nTotal > _nLimPerfil
				_cObs:=" - Acima do Limite"
			ENDIF
			IF SC7->C7_MOEDA <> DHL->DHL_MOEDA
				_cObs+=" - Moeda diferente"
			ENDIF
	    ELSE
	       _cObs:=" - Perfil não encontrado nessa filial: "+xFilial("DHL")+" "+SAL->AL_PERFIL
	    ENDIF
		IF !EMPTY(_cObs)
			AADD(aForaLim,{.F. , _cNome , _cMoeDHL+" "+STR(_nLimPerfil,15,2) , _cMoePV+" "+STR(_nTotal,15,2), _cObs})
			lRet := .F.
		ELSE
			AADD(aForaLim,{.T. , _cNome , _cMoeDHL+" "+STR(_nLimPerfil,15,2) , _cMoePV+" "+STR(_nTotal,15,2), "OK" })
		ENDIF
		
		aColsAux := {}
		For nX := 1 To Len(aHeader)
			If AllTrim(aHeader[nX,2]) == "AL_NOME"
				aAdd(aColsAux, _cNome)
			ElseIf aHeader[nX,8] == "D" 
				aAdd(aColsAux, StoD(SAL->&(aHeader[nX,2])))
			Else
				aAdd(aColsAux, SAL->&(aHeader[nX,2]) )
			EndIf
		Next nX
		Aadd(aColsAux, .F.)
		Aadd(oMSNewApr:aCols, aColsAux)
		
		(cAlias)->(dbSkip())
	ENDDO
Else
	FWAlertWarning("Grupo informado não existe, favor informar um código de grupo existente.","Liberação PC - Gestor de Compras - ACOM01107")
	lRet := .F.
EndIf

IF LEN(aForaLim) > 0 .AND. !lRet
	
	bBloco:={|| U_ITListBox('Lista de aprovadores com limite de aprovação',;
	        {" ",'Aprovador','Limite','Total PV',"Observação"},aForaLim,.F.,4,,,;
	        { 10,         90,      50,        50,         90}) }
	
	U_ITMSG("A indicação não poderá ser feita para este grupo de aprovação...",'Atenção!',;
	        "Pois existe aprovador que não tem limite suficiente para aprovar o valor do pedido ou a moeda do perfil é diferente: VER Mais Detalhes",1,,,,,,bBloco)
	
	lRet := .F.
	
ENDIF

(cAlias)->( dbCloseArea() )

oMSNewApr:oBrowse:Refresh()
oMSNewApr:Refresh()
FWRestArea(aArea)

Return(lRet)

/*
===============================================================================================================================
Programa----------: ACOM011V
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 26/02/2016
Descrição---------: Função criada para exibir as inconsistências entre Valor Unitário x Última Compra
Parametros--------: _cFilial - Filial do Pedido de Compras
                    _cPedido - Número do Pedido de Comrpas
                    _lLibera - .T. Mostra a tela de liberação, .F. caso contrário
Retorno-----------: lRet	- .T. continua com o processo de liberação pelo gestor, .F. caso contrário
===============================================================================================================================
*/
User Function ACOM011V(_cFilial As Character, _cPedido As Character, _lLibera As Logical)

Local aArea	  	:= FWGetArea() As Array
Local aSC7Area	:= SC7->(FWGetArea()) As Array
Local lRet		:= .T. As Logical
Local nPtol		:= SuperGetMV("IT_PTOLP3",.F.,0) As Numeric

Local aCampPla	:= {	'Índice',;
						'Filial',;
						'Num PC',;
						'Item',;
						'Quantidade',;
						'Prc Unitário',;
						'Vlr. Total',;
						'Ult. Preço',;
						'Diferença %',;
						'Dt. Emissão',;
						'Urgente',;
						'Aplicação',;
						'Produto',;
						'Descrição',;
						'Unidade',;
						'Dt Ult. Compra',;
						'Fornecedor',;
						'N Fantasia',;
						'Dt Faturado',;
						'Cod.Investim',;
						'Des.Investim',;
						'Observações'} As Array

Local aLogPla	:= {} As Array
Local nCont		:= 1 As Numeric
Local _cGrupoItem  := '' as Character
Local _cGrpNaoObrigat :=SuperGetMV("IT_GRPNOBR",.F.,"1000") As Character

dbSelectArea('SC7')
SC7->(dbSetOrder(1))
SC7->(dbSeek(_cFilial + _cPedido))

While !SC7->(Eof()) .And. SC7->C7_FILIAL == _cFilial .And. SC7->C7_NUM == _cPedido

	dbSelectArea("SBZ")
	SBZ->(dbSetOrder(1))
	SBZ->(dbSeek(xFilial("SBZ") + SC7->C7_PRODUTO))
	
	_cGrupoItem := Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_GRUPO") 

	If SBZ->BZ_UPRC > 0  .And. !(_cGrupoItem $ _cGrpNaoObrigat) 
        _nPrecoRS:=SC7->C7_PRECO
        IF SC7->C7_MOEDA <> 1
           _nPrecoRS:=SC7->C7_PRECO*SC7->C7_TXMOEDA
        ENDIF

		If Iif( SBZ->BZ_UPRC > _nPrecoRS, ( ( SBZ->BZ_UPRC * 100 ) / _nPrecoRS ) - 100 > nPtol, ( ( SBZ->BZ_UPRC * 100 ) / _nPrecoRS ) - 100 < ( - nPtol ) )
			aAdd( aLogPla , {	StrZero(nCont++,4),;																						//[1]Índice
								SC7->C7_FILIAL + " - " + AllTrim(FWFilialName(cEmpAnt,SC7->C7_FILIAL,1)),;									//[2]Filial
								SC7->C7_NUM,;																								//[3]Num PC
								SC7->C7_ITEM,;												 												//[4]Item
								AllTrim(Transform(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT"))),;												//[5]Quantidade
								AllTrim(Transform(_nPrecoRS,PesqPict("SBZ","BZ_UPRC"))),;												//[6]Preço Unitário
								AllTrim(Transform(SC7->C7_TOTAL,PesqPict("SC7","C7_TOTAL"))),;												//[7]Valor Total
								AllTrim(Transform(SBZ->BZ_UPRC,PesqPict("SBZ","BZ_UPRC"))),;												//[8]Último Preço
								AllTrim(Transform((((_nPrecoRS - SBZ->BZ_UPRC) / SBZ->BZ_UPRC) * 100), PesqPict("SBZ","BZ_UPRC"))),;	//[9]Diferença
								DtoC(SC7->C7_EMISSAO),;																						//[10]Emissão
								SC7->C7_I_URGEN,;												  											//[11]Urgente
								SC7->C7_I_APLIC,;												  											//[12]Aplicação
								SC7->C7_PRODUTO,;																							//[13]Produto
								SC7->C7_DESCRI,;																							//[14]Descrição
								SC7->C7_UM,;																								//[15]Unidade
								DtoC(SBZ->BZ_UCOM),;																						//[16]Data Última Compra
								SC7->C7_FORNECE,;										   													//[17]Fornecedor
								Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NREDUZ"),;								//[18]Nome Reduzido
								DtoC(SC7->C7_I_DTFAT),;											 											//[19]Dt Faturado
								SC7->C7_I_CDINV,;												 											//[20]Código Investimento
								Posicione("ZZI",1,xFilial("ZZI")+SC7->C7_I_CDINV,"ZZI_DESINV"),;											//[21]Descrição Investimento
								SC7->C7_OBS})														   										//[22]Observação
		EndIf
	EndIf
	SC7->(dbSkip())
EndDo

If Len(aLogPla) > 0
	lRet := .F.
	FWAlertWarning('Este pedido contém inconsistência entre o Valor Unitário x Última Compra. Serão apresentadas as inconsistências na próxima tela.',"ACOM01108")
	U_ITListBox( 'Inconsistência Valor Unitário x Última Compra (Tolerância: ' + AllTrim(Str(nPtol)) + ' %)' , aCampPla , aLogPla , .T. , 1 )
	If _lLibera
		If FWAlertYesNo('Este Pedido contém diferenças fora da tolerância entre os valores da última compra e o preço unitário. Deseja Liberar este pedido mesmo assim ?',"ACOM01109")
			lRet := .T.
		EndIf
	EndIf
EndIf

FwRestArea(aArea)
FwRestArea(aSC7Area)
Return(lRet)

/*
===============================================================================================================================
Programa----------: ACOM11_ZP1
Autor-------------: Alex Walluer
Data da Criacao---: 29/03/2022
Descrição---------: Rotina que faz a leitura do parâmetro do ZP1 de todas as filiais
Parametros--------: Parâmetro: parâmetro
Retorno-----------: _cLista
===============================================================================================================================
*/
Static Function ACOM11_ZP1(_cParam As Character)

Local _cLista	:= "" As Character
Local _cQuery	:= "" As Character
Local _cAlias	:= GetNextAlias() As Character

_cQuery := " SELECT * "
_cQuery += " FROM  "+ RetSqlName('SX6') +" SX6 "
_cQuery += " WHERE X6_VAR = '"+ _cParam +"' "
_cQuery += "   AND D_E_L_E_T_ = ' ' "
_cQuery := ChangeQuery(_cQuery)
MPSysOpenQuery(_cQuery,_cAlias)

(_cAlias)->( DBGoTop() )
DO While (_cAlias)->( !Eof() ) 
   _cLista+=ALLTRIM((_cAlias)->X6_CONTEUD)+";"
   (_cAlias)->( DBSkip() )
EndDo
(_cAlias)->( DBCloseArea() )

Return( _cLista )

/*
===============================================================================================================================
Programa----------: ACOM11QBG
Autor-------------: Alex Wallauer
Data da Criacao---: 12/04/2022
Descrição---------: Gravção do campo CR_TOTAL
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM11QBG()

Local nA 		:= 0 As Numeric
Local _aParRet	:= {} As Array
Local _aParAux	:= {} As Array
Local _bOK		:= {|| .T. } As Codeblock
Local _cTimeIni	:= TIME() As Character
Local _cTitAux	:= "QBG de Aprovações" As Character
Local _aStatus	:= {"1-Todos     ","2-Abertos   ","3-Encerrados"} As Array

MV_PAR01:=CTOD("01/01/2020")
MV_PAR02:=DDATABASE
MV_PAR03:=SPACE(100)
MV_PAR04:=_aStatus[1]

AADD( _aParAux , { 1 , "Data Inicial", MV_PAR01, "@D", "", ""	, "" , 050 , .F.  })
AADD( _aParAux , { 1 , "Data Final"	 , MV_PAR02, "@D", "", ""	, "" , 050 , .F.  })
AADD( _aParAux , { 1 , "Filial"      , MV_PAR03, "@!"  , ""  ,"LSTFIL", "" , 100 , .F. } ) 
AADD( _aParAux , { 2 , "Status PC"   , MV_PAR04, _aStatus, 060   ,".T.",.T. ,".T."}) 

For nA := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nA][03] )
Next nA

DO WHILE .T.
							//aParametros, cTitle                                , @aRet    ,[bOk], [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
	If !ParamBox( _aParAux , _cTitAux, @_aParRet, _bOK, /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
		RETURN .F.
	EndIf

	_aDados:={}

	FWMSGRUN( ,{|oproc| _aDados := ACOM11QBG(oproc) } , "Aguarde!" , "Hor Inicial: "+_cTimeIni+" / Executando a SELECT Andre..." )

	If len(_aDados) > 0
		aCab:={}
		AADD(aCab," ")
		AADD(aCab,"Filial")
		AADD(aCab,"Pedido")
		AADD(aCab,"Dt Emissao")
		AADD(aCab,"Status")
		AADD(aCab,"Dt Liberacao")
		AADD(aCab,"Cod. User")
		AADD(aCab,"Cod. Aprov")
		AADD(aCab,"Valor SCR")
		AADD(aCab,"Valor PC")
		AADD(aCab,"Reg SCR")
		
		_cTitulo2:=_cTitAux+' - Data: ' + DtoC(Date()) 
		_cMsgTop:="Par. 1: "+ALLTRIM(AllToChar(MV_PAR01))+"; Par. 2: "+ALLTRIM(AllToChar(MV_PAR02))+" -  H.I.: "+_cTimeIni+" H.F.: "+TIME()

		If U_ITListBox( _cTitulo2 , aCab , _aDados , .T. , 2 , _cMsgTop)
			_nConta:=0
			For nA := 1 To Len( _aDados )
				
				IF _aDados[nA,1] .AND. !EMPTY(_aDados[nA,LEN(_aDados[nA] )-1])
					SCR->(DBGOTO( _aDados[nA,LEN(_aDados[nA] )]) )
					IF MV_PAR04 = "3" // ENCERRADOS
						IF SCR->CR_STATUS  = "03" .AND. !EMPTY(_aDados[nA,LEN(_aDados[nA] )-1])// APROVADO - "Nível Aprovado"
							SCR->(Reclock("SCR",.F.))
							SCR->CR_TOTAL   := _aDados[nA,LEN(_aDados[nA] )-1]
							SCR->CR_TIPOLIM := Posicione("SAK",1,xFilial("SAK")+SCR->CR_LIBAPRO,"AK_TIPO")
							SCR->(Msunlock())
							_nConta++
						ENDIF
					ELSE
						SCR->(Reclock("SCR",.F.))
						SCR->CR_TOTAL:=_aDados[nA,LEN(_aDados[nA] )-1]
						SCR->(Msunlock())
						_nConta++
					ENDIF
				ENDIF
			Next nA
			FWAlertSuccess('Processo concluído com sucesso. Registros atualizados: '+CValToChar(_nConta),"ACOM01110")
		Endif
	Else
		FWAlertInfo('Não há registros.',"ACOM01111")
	Endif
ENDDO

RETURN

/*
===============================================================================================================================
Programa----------: ACOM11QBG
Autor-------------: Alex Wallauer
Data da Criacao---: 12/04/2022
Descrição---------: Gravção do campo CR_TOTAL
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function ACOM11QBG(oproc As Object)

Local _cQuery	:= "" As Character
Local _cAlias	:= GetNextAlias() As Character
LOCAL nA 		:= 0 As Numeric
LOCAL _cPict 	:= PesqPict("SCR","CR_TOTAL") As Character

_cQuery := " SELECT "
_cQuery += " DISTINCT CR_FILIAL, CR_NUM  "	  
_cQuery += " FROM "+ RetSqlName("SCR") +" SCR "+ CRLF
_cQuery += " WHERE D_E_L_E_T_ = ' ' "
IF MV_PAR04 = "2"     // ABERTOS
   _cQuery += " AND CR_DATALIB = '  ' "
ELSEIF MV_PAR04 = "3"     // ENCERRADOS
   _cQuery += " AND CR_DATALIB <> '  ' "
ENDIF
_cQuery += "    AND CR_TIPO = 'PC' "
_cQuery += "    AND CR_TOTAL <= 0 "
IF !EMPTY(MV_PAR01)
   _cQuery += "   AND CR_EMISSAO >= '" + DTOS(MV_PAR01) + "' "
ENDIF
IF !EMPTY(MV_PAR02)
   _cQuery += "   AND CR_EMISSAO <= '" + DTOS(MV_PAR02) + "' "
ENDIF
IF !EMPTY(MV_PAR03)
   _cQuery += "   AND CR_FILIAL IN "+FormatIn(ALLTRIM(MV_PAR03),";")"
ENDIF

_cQuery += "   ORDER BY CR_FILIAL, CR_NUM  "
_cQuery := ChangeQuery(_cQuery)

MPSysOpenQuery( _cQuery,_cAlias )

DbSelectArea(_cAlias)
_nTot:=nConta:=0
COUNT TO _nTot
_cTot:=ALLTRIM(STR(_nTot))
_cAlias->(DBGOTOP())

SC7->(dbSetOrder(1))
SCR->(Dbsetorder(1)) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
_aDados:={}
DO WHILE (_cAlias)->(!EOF())
	_cFilial:=(_cAlias)->CR_FILIAL
	cPedido:=AllTrim((_cAlias)->CR_NUM )
	nConta++
	oproc:cCaption := ("Lendo PC: "+_cFilial+" "+cPedido+" - "+STRZERO(nConta,5) +" de "+ _cTot )
	ProcessMessages()

	If SC7->(dbSeek(_cFilial + cPedido))
		IF MV_PAR04 = "3" // ENCERRADOS
			IF !SC7->C7_ENCER = 'E'//IGNORA ABERTOS
				(_cAlias)->(DBSKIP())
				LOOP	
			ENDIF
		Endif

		_nTotPed:=0
		MaFisEnd()
		aRefImp	:= MaFisRelImp('MT100',{"SC7"})
		aStru		:= FWFormStruct(3,"SC7")[1]
		DO While (!EOF()) .And. cPedido == SC7->C7_NUM .AND. SC7->C7_FILIAL == _cFilial
		
			MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",aRefImp)						
			MaFisIniLoad(1)
			For nA := 1 To Len(aRefImp)
				nPos := aScan(aStru,{|x| AllTrim(x[3]) == AllTrim(aRefImp[nA][2])})
				If nPos > 0 .And. !aStru[nPos,14]
					MaFisLoad(aRefImp[nA][3],SC7->(&(aRefImp[nA][2])),1)
				Endif
			Next nA
			
			MaFisRecal("",1)
			MaFisEndLoad(1)
			MaFisAlt("IT_ALIQIPI",SC7->C7_IPI    ,1)
			MaFisAlt("IT_ALIQICM",SC7->C7_PICM   ,1)
			MaFisAlt("IT_VALSOL" ,SC7->C7_ICMSRET,1)
			MaFisWrite(1,"SC7",1)
			_nTotPed += MaFisRet(1,"IT_TOTAL")
			MaFisEnd()

			SC7->(dbSkip())
		ENDDO
		
		SC7->(dbSeek(_cFilial + cPedido))
		If SCR->(Dbseek(SC7->C7_FILIAL+"PC"+alltrim(SC7->C7_NUM)))
			Do while !(SCR->(Eof())) .and. SC7->C7_FILIAL == SCR->CR_FILIAL .AND. SCR->CR_TIPO == 'PC' .AND. ALLTRIM(SCR->CR_NUM) == alltrim(SC7->C7_NUM)

				_aItem:={}
				AADD(_aItem,.T.)                             //01
				AADD(_aItem,SCR->CR_FILIAL)                  //02
				AADD(_aItem,ALLTRIM(SCR->CR_NUM))            //03
				AADD(_aItem,DTOC(SCR->CR_EMISSAO))           //04
				AADD(_aItem,SCR->CR_STATUS)                  //04
				AADD(_aItem,DTOC(SC7->C7_I_DTLIB))           //05
				AADD(_aItem,SCR->CR_USER)                    //06
				AADD(_aItem,SCR->CR_APROV)                   //07
				AADD(_aItem,Transform(SCR->CR_TOTAL,_cPict) )//08 
				AADD(_aItem,0 )                              //09
				AADD(_aItem,SCR->(RECNO()))                  //10      
				
				AADD(_aDados,_aItem)

				SCR->(Dbskip())
			Enddo
		Endif

		IF MV_PAR04 = "3" // ENCERRADOS
			IF _aDados[ LEN(_aDados) , 04 ] = "03"// CR_STATUS -> APROVADO - "Nível Aprovado"
				_aDados[ LEN(_aDados) , 09 ] := _nTotPed
			ENDIF
		Endif
	ENDIF
	(_cAlias)->(DBSKIP())
ENDDO

RETURN _aDados
