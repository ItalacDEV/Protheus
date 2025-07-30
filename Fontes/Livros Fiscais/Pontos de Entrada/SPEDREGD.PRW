/*
=====================================================================================================================================
        						 ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=====================================================================================================================================
   Autor     |	Data	 |										Motivo																
=====================================================================================================================================
Josué Danich | 05/06/2018| Ajuste de bloco H020 e organização de blocos por parâmetros  - Chamado 24000.  
-------------------------------------------------------------------------------------------------------------------------------------
Julio Paz    | 23/10/2018|Ajuste bloco H020 para novas regras geração dados.Ajuste para novo servidor Totvs Lobo Guara.Chamado 24000. 
-------------------------------------------------------------------------------------------------------------------------------------
Lucas Borges | 02/10/2019| Removidos os Warning na compilação da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço | 06/12/2021| Ajuste para correção de error.log depois de virada do release 12.1.033. Chamado 38517
-------------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço | 14/03/2022| Ajuste para correção de error.log. Chamado 39452
=====================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "protheus.ch"
#include "TopConn.ch"

/*
===============================================================================================================================
Programa----------: SPEDREGD
Autor-------------: Josué Danich Prestes
Data da Criacao---: 22/01/2018
===============================================================================================================================
Descrição---------: Ponto de Entrada para tratar bloco TRB do Sped Fiscal - Chamado 23298
===============================================================================================================================
Parametros--------: PARAMIXB[1]		 	cAlias = Alias	 	 	 	 	 	 	 	 	X	 
 					PARAMIXB[2]	 	 	aLisFIl = Contendo todas as Filiais selecionadas e nao 
 										selecionadas da geração do arquivo
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function SPEDREGD()

Local _amestres := {}
Local _anegats := {}
Local _npos := 0
Local _nTamProd := TamSX3("B9_COD")[1]
Local _nBaseCalc, _nValIcm
Local _cGrupoCST
Local _njl	:= 0
Local _nni	:= 0
Local _nnn	:= 0
Local _l0000 := .F.
Local _lMsg := .F.
Local _cRelac := ""

If TRB->(RecCount()) > 0
	//Verifica data de ínicio e fim do processamento
	If TRB->(Dbseek("0000")) 
		_aquant := strtokarr(ALLTRIM(TRB->TRB_CONT),"|")

		_dinicio := stod(substr(_aquant[4],5,4)+substr(_aquant[4],3,2)+substr(_aquant[4],1,2))
		_dfinal := stod(substr(_aquant[5],5,4)+substr(_aquant[5],3,2)+substr(_aquant[5],1,2))

		_l0000 := .T.
	Endif

	//Carrega arrays com mestres de estruturas
	If TRB->(Dbseek("0200")) .and. U_ITGETMV("ITARRNEG",.F.)
		
		_nmes := 1
		Do while TRB->TRB_TPREG == "0200" 

			// _cult   |0200|08000000001|LEITE INTEGRAL PADRONIZADO|||L|03|04012010||04||18,00||
			aadd(_amestres,substr(TRB->TRB_CONT,7,11))
			
			//Detecta estrutura negativa na sg1
			SG1->(dbsetorder(1))
			If SG1->(Dbseek(xfilial("SG1") + substr(TRB->TRB_CONT,7,11)))
			
				Do while SG1->G1_FILIAL == xfilial("SG1") .AND. ALLTRIM(SG1->G1_COD) == substr(TRB->TRB_CONT,7,11)
				
					If SG1->G1_FIM >= DDATABASE .and. SG1->G1_INI <= DDATABASE .AND. SG1->G1_QUANT < 0 .and. ascan(_anegats,{|x| x[1] = alltrim(SG1->G1_COMP)}) == 0
					
						aadd(_anegats,{alltrim(SG1->G1_COMP),alltrim(SG1->G1_COD),SG1->G1_QUANT,POSICIONE("SBZ",1,xfilial("SBZ")+SG1->G1_COD,"BZ_QB"),_nmes})
						
					Endif
					
					SG1->(Dbskip())
					
				Enddo
				
			Endif
			
			_nmes++
			TRB->(Dbskip())
			
		Enddo

	Endif 

	//Ajusta estrutura normal
	If TRB->(Dbseek("0210")) .and. U_ITGETMV("ITARRNEG",.F.)

		Do while TRB->TRB_TPREG == "0210" 
		
			_npos := val(substr(trb->trb_relac,1,50))
		
			If _npos > 0 .and. _npos < len(_amestres)
				
				// trbcont |0210|08010000121|3,477378|0|
				_nquant := lequants(_amestres[_npos],substr(TRB->TRB_CONT,7,11),_amestres)
				
				_nfator := 1
				
				_nposi := ascan(_anegats,{|x| x[5] = superval(substr(TRB->TRB_RELAC,1,50))})
				
				If  _nposi > 0
				
					_nfator := _anegats[_nposi][4] / ( _anegats[_nposi][4] + (-1 * _anegats[_nposi][3]) )
					
				Endif
				
				If _nquant > 0
				
					Reclock("TRB",.F.)
					TRB->TRB_CONT := substr(TRB->TRB_CONT,1,18) + alltrim(transform(_nquant * _nfator, "@E 999999999.999999")) + "|0|"
					TRB->(Msunlock())
				
				Endif
				
			Endif
		
			TRB->(Dbskip())
			
		Enddo

	Endif 

	IF U_ITGETMV("ITARRNEG",.F.)

		//Ajusta estrutura negativa
		For _nnn := 1 to len(_anegats)

			//Detecta os registros 0200 existentes para subprodutos
			_aregs := {}
			TRB->(Dbseek("0200"))
			_ncont := 1
			Do while TRB->TRB_TPREG == "0200" 
			
				If substr(TRB->TRB_CONT,7,11) == _anegats[_nnn][1]
				
					aadd(_aregs,{_ncont,_anegats[_nnn][1]})
					
				Endif
				
				_ncont++
				TRB->(Dbskip())
				
			Enddo
			
			//Detecta os registros 0210 relacionados aos registros 0200 de subprodutos para serem apagados
			_aapaga := {}
			_nmax := 0
			TRB->(Dbseek("0210"))
			Do while TRB->TRB_TPREG == "0210" 
			
				_npos := val(substr(trb->trb_relac,1,50))
				
				If ascan(_aregs,{|x| x[1] = _npos})
				
					aadd(_aapaga,TRB->(Recno()))
					
				Endif
				
				If TRB->TRB_ITEM >= _nmax
				
					_nmax := TRB->TRB_ITEM + 1
					
				Endif
				
				TRB->(Dbskip())
				
			Enddo
			
			//Apaga registros 0210 de subprodutos pois serão recriados
			For _njl := 1 to len(_aapaga)
			
				TRB->(Dbgoto(_aapaga[_nnj]))
				
				Reclock("TRB",.F.)
				TRB->(Dbdelete())
				TRB->(Msunlock())
				
			Next
			
			
			//Recria registros 0210 de acordo com a SG1
			For _nni := 1 to len(_anegats)
			
			
				SG1->(dbsetorder(1))
				If SG1->(Dbseek(xfilial("SG1") + _anegats[_nni][2]))
				
					Do while SG1->G1_FILIAL == xfilial("SG1") .AND. ALLTRIM(SG1->G1_COD) == _anegats[_nni][2]
					
						If SG1->G1_FIM >= DDATABASE .and. SG1->G1_INI <= DDATABASE .AND. SG1->G1_QUANT > 0 
			
							_nfator := -1 * (_anegats[_nni][3] / ( _anegats[_nni][3] + _anegats[_nni][4] ))
			
							Reclock("TRB",.T.)
							TRB->TRB_TPREG := '0210'
							TRB->TRB_RELAC := STRZERO( _aregs[ ascan(_aregs,{|x| x[2] = _anegats[_nni][1]}) ][1] , 50 ) + STRZERO( _aregs[ ascan(_aregs,{|x| x[2] = _anegats[_nni][1]}) ][1] , 50 )
							TRB->TRB_FLAG := " "
							TRB->TRB_CONT := "|0210|" + ALLTRIM(SG1->G1_COMP) + "|" + alltrim(transform(SG1->G1_QUANT * _nfator, "@E 999999999.999999")) + "|0|"
							TRB->TRB_ITEM := _nmax
							TRB->(Msunlock())
				
							_nmax++
			
						Endif
						
						SG1->(Dbskip())
						
					Enddo
					
				Endif
			
			Next
			
		Next

	Endif

	//Ajusta layout da K220
	If TRB->(Dbseek("K220")) .and. U_ITGETMV("ITARR220",.F.)

		Do while ALLTRIM(TRB->TRB_TPREG) == "K220"
		
			_aquant := strtokarr(ALLTRIM(TRB->TRB_CONT),"|")
			_cquant := _aquant[len(_aquant)]
			
			Reclock("TRB",.F.)
			TRB->TRB_CONT := ALLTRIM(TRB->TRB_CONT) + _cquant + "|"
			TRB->(Msunlock())
			
			TRB->(Dbskip())
			
		Enddo
		
	Endif

	//Ajusta saldo do produto na k230
	If TRB->(Dbseek("K230")) .and. U_ITGETMV("ITARR230",.F.) .and. _l0000

		Do while TRB->TRB_TPREG == "K230"

			_aquant := strtokarr(ALLTRIM(TRB->TRB_CONT),"|")

			If alltrim(_aquant[5]) $ u_itgetmv("IT_PK0210","08000000039") .AND. alltrim(cfilant) $ U_ITGETMV("IT_FK0210","40;04")
			
				_cquant := alltrim(transform(leprod(alltrim(_aquant[5]),_dinicio,_dfinal,alltrim(_aquant[4])), "@E 999999999.999")) 
				
				Reclock("TRB",.F.)
				TRB->TRB_CONT := "|" + _aquant[1] + "|" + _aquant[2] + "|" + _aquant[3] + "|" + _aquant[4] + "|" + _aquant[5] + "|" + _cquant + "|"
				TRB->(Msunlock())
				
			Endif
			
			
			TRB->(Dbskip())
			
		Enddo
		
	Endif

	//Ajusta linhas H010/H020
	If TRB->(Dbseek("H005")) .and. U_ITGETMV("ITARRH20",.T.)

		_aquant := strtokarr(ALLTRIM(TRB->TRB_CONT),"|")
		_dDtFechamento := stod(SUBSTR(_aquant[2],5,4)+SUBSTR(_aquant[2],3,2)+SUBSTR(_aquant[2],1,2))
		_aregs := {}
		
		TRB->(DbSkip())

		Do while TRB->TRB_TPREG == "H010" 

			_aquant := strtokarr(ALLTRIM(TRB->TRB_CONT),"|")
			
			_cProduto := _aquant[2]
			
			_aDadosIcm := U_LECST(_cProduto,_dDtFechamento )  // Esta função retorna o CSTICMS e a aliquota de ICMS.

			_cCSTICMS := _aDadosIcm[1] 
			_nAliquota := _aDadosIcm[2] 

			_nSomaValor := 0
			_nSomaQtd   := 0
		
			SB9->(DbSetOrder(1)) // B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA) 
			SB9->(DbSeek(xFilial("SB9")+Padr(_cProduto,_nTamProd," ")))
			Do While ! SB9->(Eof()) .And. SB9->(B9_FILIAL+B9_COD) == xFilial("SB9")+Padr(_cProduto,_nTamProd," ")
			
				If SB9->B9_DATA == _dDtFechamento 
					
					_nSomaValor += SB9->B9_VINI1
					_nSomaQtd   += SB9->B9_QINI

				EndIf
		
				SB9->(DbSkip())
			
			EndDo

			If _nSomaValor > 0 .and. _nSomaQtd > 0

				_nValBaseICM := _nSomaValor / _nSomaQtd
				
			Else
			
				_nValBaseICM := 0
				
			Endif
			
			_nValIcm :=  _nValBaseICM * (_nAliquota / 100)
			_cRelac  := Alltrim(TRB->TRB_RELAC)
			aadd(_aregs,{_cRelac,_nValIcm,_nValBaseICM,_cProduto})
			
			TRB->(DbSkip())
			
		Enddo

		If TRB->(Dbseek("H020"))
			
			SB1->(DbSetOrder(1))
			
			Do While TRB->TRB_TPREG == "H020"
				//=======================================================================================================
				// Nova regra de gravação do bloco H020.  
				//=======================================================================================================
				// LOCALIZA REGISTRO RELACIONADO NO _aregs
				//_nPos  :=ascan(_aregs,{|_vAux|_vAux[1]=="00000000000000000000000000000000000000000000000001" + substr(TRB->TRB_RELAC,1,50)}) 
				_cRelac := StrZero(Val(TRB->TRB_RELAC)-1,101)
				_nPos  := ascan(_aregs,{|_vAux|_vAux[1]== _cRelac })

				If _nPos > 0
				
					_aquant := strtokarr(ALLTRIM(TRB->TRB_CONT),"|")
					_cProduto := _aregs[_nPos,4] // _aquant[2]
					_aDadosIcm := U_LECST(_cProduto,_dDtFechamento )  // Esta função retorna o CSTICMS e a aliquota de ICMS.
					
					_cGrupoCST  := "000, 020, 100, 200, 300, 400, 500, " // " 000, 020, 100, 200, 300, 400, 500, 040, 041, 051, 060, 090, 190," // CSTICMS Cujo a aliquota e valor do Icm devem ser zerados.
					
					SB1->(DbSeek(xFilial("SB1")+U_ItKey(_cProduto,"B1_COD")))
		
					If SB1->B1_TIPO == "PA"
						_cCSTICMS  := "000"
						_nBaseCalc := _aregs[_npos][3]
						_nValIcm   := (_aregs[_npos][3] * 18) / 100
					Else
						_cCSTICMS := _aDadosIcm[1] 
						
						If _cCSTICMS $ _cGrupoCST
							_nBaseCalc := _aregs[_npos][3]
							_nValIcm   := (_aregs[_npos][3] * 18) / 100
						Else
							_nBaseCalc := 0
							_nValIcm   := 0
						EndIf
					EndIf
					
					//LOCALIZA REGISTRO RELACIONADO NO _aregs
					//_nPos  :=ascan(_aregs,{|_vAux|_vAux[1]=="00000000000000000000000000000000000000000000000001" + substr(TRB->TRB_RELAC,1,50)}) 
					
					Reclock("TRB", .F.)
					//TRB->TRB_CONT := "|H020|" + _cCSTICMS +  "|" + alltrim(TRANSFORM(_aregs[_npos][3], "@E 999999999.99")) + "|" + alltrim(TRANSFORM(_aregs[_npos][2], "@E 999999999.99")) + "|"			
					TRB->TRB_CONT := "|H020|" + _cCSTICMS +  "|" + alltrim(TRANSFORM(_nBaseCalc, "@E 999999999.99")) + "|" + alltrim(TRANSFORM(_nValIcm, "@E 999999999.99")) + "|"			
					TRB->(Msunlock())
				Else
					_lMsg := .T.
				EndIf
				TRB->(Dbskip())
			Enddo
			
			If _lMsg
				U_ITMSG("Algumas linhas do bloco H020 não foram reprocessadas!",'Atenção!',"Confira os dados deste bloco.",3)
			EndIf
		Endif
		
	Endif
Endif

Return

/*
===============================================================================================================================
Programa----------: LEPROD
Autor-------------: Josué Danich Prestes
Data da Criacao---: 22/01/2018
===============================================================================================================================
Descrição---------: Soma produção do produto na filial
===============================================================================================================================
Parametros--------: _cprod - produto a analisar
					_dinicio - data inicial
					_dfinal - data final
					_cop - numero da op
===============================================================================================================================
Retorno-----------: Total produzido
===============================================================================================================================
*/
Static Function LEPROD(_cprod,_dinicio,_dfinal,_cop)

Local _nprod := 0

_cQuery1:= " SELECT " 
_cQuery1+= " SUM(SD3.D3_QUANT) AS TOT " 
_cQuery1+= " FROM " + RetSqlName("SD3") + " SD3 "
_cQuery1+= " WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'"
_cQuery1+= " AND   SD3.D3_EMISSAO BETWEEN '" + DTOS(_dinicio)+ "' AND '" + DTOS(_dfinal) + "'"
_cQuery1+= " AND   SD3.D3_CF IN ('PR0') "
_cQuery1+= " AND   SD3.D3_COD = '" + ALLTRIM(_cprod) + "' "
_cQuery1+= " AND   SD3.D3_OP = '" + ALLTRIM(_cop) + "' "
_cQuery1+= " AND   SD3.D3_ESTORNO <> 'S' "
_cQuery1+= " AND   SD3.D_E_L_E_T_ = ' '	"

TcQuery _cquery1 New Alias SD3T
	
DBSelectArea("SD3T")

_nprod := SD3T->TOT

SD3T->(Dbclosearea())

Return _nprod

/*
===============================================================================================================================
Programa----------: LEQUANTS
Autor-------------: Josué Danich Prestes
Data da Criacao---: 18/04/2018
===============================================================================================================================
Descrição---------: Calcula proporção do componente na estrutura
===============================================================================================================================
Parametros--------: _cprod - produto mestre
					_ccomp - componente
					_amestre - array com os produtos mestre das estruturas
===============================================================================================================================
Retorno-----------: proporção
===============================================================================================================================
*/
Static Function LEquants(_cprod,_ccomp,_amestre)

Local _nprop := 0

SG1->(Dbsetorder(1))
If SG1->(Dbseek(xfilial("SG1")+_cprod)) //Produto mestre normal

	Do while SG1->G1_FILIAL == xfilial("SG1") .AND. alltrim(SG1->G1_COD) == alltrim(_cprod)
	
		If alltrim(SG1->G1_COMP) == alltrim(_ccomp) .AND. SG1->G1_INI <= DDATABASE .AND. SG1->G1_FIM >= DDATABASE
		
			_nprop := SG1->G1_QUANT
						
		Endif
	
		SG1->(Dbskip())
		
	Enddo

Endif

Return _nprop

/*
===============================================================================================================================
Programa----------: LECST
Autor-------------: Julio de Paula Paz
Data da Criacao---: 23/03/2018 
===============================================================================================================================
Descrição---------: Retornar o CST ICMS e a Aliquota ICMS do produto passado como parâmetro.
===============================================================================================================================
Parametros--------: _cCodProd  := Codigo do produto.
                    _dDataFech := Data de fechamento.
===============================================================================================================================
Retorno-----------: _aRet = {CST ICMS, Aliquota ICMS}
===============================================================================================================================
*/
User function LECST(_cCodProd,_dDataFech)

Local _aRet := {"   ",0}
Local _cQuery := ""

SB1->(DbSetOrder(1))

   If ! SB1->(DbSeek(xFilial("SB1")+U_ITKEY(_cCodProd,'B1_COD')))
 
   	_aRet := {"   ", 0}
   
   ElseIf SB1->B1_TIPO == "PA"

      _aRet := {"000", 18} // Conforme solicitação do usuário, quando o produto for do tipo PA, fixar codigo CST ICMS em "000" e aliquota ICMS em 18 %.

   Else

      _cQuery := "SELECT MAX(SD1.R_E_C_N_O_) AS NRRECNO "
      _cQuery += " FROM " + RetSqlName("SD1") + " SD1 "  
      _cQuery += " WHERE SD1.D_E_L_E_T_ <> '*' AND D1_FILIAL = '" + cfilant + "' AND D1_EMISSAO <= '"+Dtos(_dDataFech)+"' AND D1_COD  = '" + ALLTRIM(_cProduto) + "' "
      _cQuery += " AND (SELECT F1_ESPECIE  FROM " + RetSqlName("SF1") + " SF1 WHERE SF1.D_E_L_E_T_ <> '*' AND F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND D1_FORNECE = F1_FORNECE "
      _cQuery += " AND F1_LOJA = D1_LOJA AND ROWNUM = 1) <> 'CTE  ' "

   
      If Select("TRBNF") > 0
      	TRBNF->( DBCloseArea() )
      EndIf

      DbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , "TRBNF" , .T., .F. )                            
                                                                                  
      If !TRBNF->(Eof()) 

      	SD1->(DbGoTo(TRBNF->NRRECNO)) // Considera produto diferente de PA.
      	
      	If len(alltrim(SD1->D1_CLASFIS)) == 3
      		
      		_aRet := {SD1->D1_CLASFIS, SD1->D1_PICM, SD1->D1_CF}
      		
      	Else
      	
      		_aRet := {"   ", SD1->D1_PICM, SD1->D1_CF}
      	
      	Endif      

      EndIf

Endif

If Select("TRBNF") > 0
   TRBNF->( DBCloseArea() )
EndIf

Return _aRet
