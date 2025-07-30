/*
=======================================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=======================================================================================================================================
       Autor   |    Data    |                              Motivo                       									  
---------------------------------------------------------------------------------------------------------------------------------------
 Josué Danich  | 25/10/2018 | Chamado 25790. Exceção de validação de segunda unidade para corte de produtos.
---------------------------------------------------------------------------------------------------------------------------------------
 Josué Danich  | 02/01/2018 | Chamado 27075. Ajuste regras de transit time.
---------------------------------------------------------------------------------------------------------------------------------------
 Josué Danich  | 08/05/2019 | Chamado 28694. Inclusão de exceções para central de efetivação de PVs.
---------------------------------------------------------------------------------------------------------------------------------------
 Julio Paz     | 24/09/2021 | Chamado 37814. Inclusão de novas regras para definir transit time na validação da data de entrega. 
---------------------------------------------------------------------------------------------------------------------------------------
  Jerry        | 29/04/2022 | Chamado 38883. Ajuste na Efetivação Automatica Pedido Portal retirando paradas em tela. 
---------------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 08/02/2024 | Chamado 44782. Jerry. Ajustes para a nova opcao de tipo de entrega: O = Agendado pelo Op.Log.
--------------------------------------------------------------------------------------------------------------------------------------- 
 Julio Paz     | 10/04/2024 | Chamado 46888. Ajustar a validação data de entrega do pedido de vendas para ser por capa e não por item. 
=======================================================================================================================================
*/
  
//Includes e definições da rotina 

#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"

/*
===============================================================================================================================
Programa----------: AOMS050
Autor-------------: Heder Jose
Data da Criacao---: 20/05/2011
===============================================================================================================================
Descrição---------: Validação de dados dos Pedidos de Vendas
===============================================================================================================================
Parametros--------: nVld == 1 -> Valida a obrigatoriedade de preenchimento da segunda unidade de medida qdo o produto pertencer
------------------:              ao grupo de produto 0006(Queijo) para controle de estoque de pecas de queijo.
------------------: nVld == 2 -> Valida NCM informado no cadastro do produto.
------------------: nVld == 3 -> Replica a informação da data de entrega informada na C5 para C6, evitando desta forma que de
------------------:              alguma forma a data da C6 fique divergente do informado na C5.
===============================================================================================================================
Retorno-----------: Lógico - define se confirma os dados validados.
===============================================================================================================================
*/

User Function AOMS050( _nVld,cTes,lDifPes )

Local _aArea	:=	GetArea()
Local _lRet		:= .T.

Local _nPa		:= 	""
Local _npl		:= 	""
Local _nPa2		:= 	""
Local _npl2		:= 	""
Local cQtdZero	:= 	""
Local _cFilCarreg := ""


_nPa 		:= aScan( aHeader, { |x| Alltrim(x[2])== "C6_PRODUTO" } )
_npl := Alltrim( aCols[n,_nPa] )

//Se esta sendo chamado via AOMS112/MOMS050 (Central Pedido Portal / Efetivaççao Automatica)
If IsInCallStack("U_AOMS112") .or. IsInCallStack("U_MOMS050")
	Return .T.
Endif

//================================================================================
// Linha nao Deletada
//================================================================================
If aCols[n][ Len(aHeader) + 1 ] == .F.
	
	If _nVld == 1
		If !lDifPes .and. TYPE("LDIFPES")=="L"
		
			If Posicione( "SB1" , 1 , xFilial("SB1") + _npl , "B1_SEGUM" ) <> ' '		
				_nPa2 	:= aScan( aHeader, { |x| Alltrim(x[2])== "C6_UNSVEN" } )
				_npl2 	:= acols[n,_nPa2]	                                      
				_nPa2 := aScan( aHeader, { |x| Alltrim(x[2])== "C6_UNSVEN" } )
				
				If _npl2 == 0                                                     
				
					cQtdZero 	:= Posicione("SF4",1,xFilial("SF4")+cTES,"F4_QTDZERO") //Verifica se TES é Qtd Zerada. Chamado 7374
					cDifPe1     := aScan( aHeader, { |x| Alltrim(x[2])== "C6_I_DIFPE" } )
					cDifPe		:= acols[n,cDifPe1] 
					
										
				    If (Inclui .or. Altera) .and. cDifPe <> "S"
									    
						If cQtdZero != "1" .AND. !IsInCallStack("U_AOMS109") 
						  
								u_ITMSG(	"Para o produto "+ AllTrim(_npl) +" é obrigatório o preenchimento da segunda unidade de medida.",;
										    "Atenção! Ped.: "+M->C5_NUM,;
											"Informar quantidade no campo Segunda Unidade de Medida (Qtd Ven 2 UM) para prosseguir com inclusão de Pedido de Venda.",1)				
							_lRet := .F.
						Else
							_lRet := .T.
						Endif          
						
					Endif
				Endif			  
			EndIf 
		Endif
		 
	ElseIf _nVld == 3 
								
		If (funname() == "AOMS061" .OR. funname() == "MATA410" ) .and. !IsInCallStack("U_AOMS032")
						                      //   Botão Transferencia               Botão copia                     ALTEROU A DATA                           
			If funname() == "MATA410" .and. (IsInCallStack('A410PCopia') .OR.  M->C5_I_DTENT != SC5->C5_I_DTENT )  //Só valida na alteração de houver mudança da data de entrega
			
				If M->C5_I_AGEND $ 'I/O' .OR. ( INCLUI .AND. M->C5_I_AGEND != "P") .or.  M->C5_I_DTENT != SC5->C5_I_DTENT 
				   //Sempre valida na inclusão e entrega imediata e na alteração de data de entrega 
                   _cFilCarreg := xFilial("SC5")
                   If ! Empty(M->C5_I_FLFNC)
                      _cFilCarreg := M->C5_I_FLFNC
                   EndIf 

                   // Esta Validação foi alterada para ser realizada na capa do pedido de vendas e não no item do pedido no fonte MT410TOK. 
				   //_lret:= U_OMSVLDENT(M->C5_I_DTENT, M->C5_CLIENT, M->C5_LOJACLI, M->C5_I_FILFT, M->C5_NUM,0    ,      ,_cFilCarreg,M->C5_I_OPER,M->C5_I_TPVEN) //Valida data de entrega 
				   					
				Elseif M->C5_I_AGEND == 'P' //Aguardando agenda joga último dia do ano sem validar a data de entrega
				
					If MONTH(DATE()) == 12
				
						M->C5_I_DTENT := STOD(ALLTRIM(STR((YEAR(DATE())+2)))+"0101")-1  
						M->C5_FECENT :=  STOD(ALLTRIM(STR((YEAR(DATE())+2)))+"0101")-1  
						
					Else
					
						M->C5_I_DTENT := STOD(ALLTRIM(STR((YEAR(DATE())+1)))+"0101")-1  
						M->C5_FECENT := STOD(ALLTRIM(STR((YEAR(DATE())+1)))+"0101")-1  
					
					Endif
					
				Else
				
					_lret := .T.
				
				Endif
				

			Else
			
				If M->C5_I_AGEND  $ 'I/O' .AND. M->C5_I_DTENT < date() //Se a data a ser gravada for menor que o dia atual vai atualizar
				
                    _cFilCarreg := xFilial("SC5")
                    If ! Empty(M->C5_I_FLFNC)
                       _cFilCarreg := M->C5_I_FLFNC
                    EndIf 

					M->C5_I_DTENT := date() + U_OMSVLDENT(M->C5_I_DTENT,M->C5_CLIENTE,M->C5_LOJACLI,M->C5_I_FILFT,M->C5_NUM,1, ,_cFilCarreg,M->C5_I_OPER,M->C5_I_TPVEN)  
					M->C5_FECENT  := M->C5_I_DTENT
					
					If !(alltrim(SC5->C5_I_OPER) $ AllTrim(U_ITGETMV( 'IT_MPVOP' , '50/51/02')))
                       
					   _cFilCarreg := SC5->C5_FILIAL
                       If ! Empty(SC5->C5_I_FLFNC)
                          _cFilCarreg := SC5->C5_I_FLFNC
                       EndIf

                       _dDTNECE := M->C5_I_DTENT - (U_OMSVLDENT(M->C5_I_DTENT,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_I_FILFT,SC5->C5_NUM,1, ,_cFilCarreg,SC5->C5_I_OPER,SC5->C5_I_TPVEN))
                       _cJUSCOD := "007"//Alterado Data de Entrega
                       _cCOMENT := "Data de entrega modificada de " + dtoc(SC5->C5_I_DTENT) + " para " + dtoc(M->C5_I_DTENT) + "  via validação data retroativa."

                       //Grava monitor
                       If !(alltrim(M->C5_I_OPER) $ AllTrim(U_ITGETMV( 'IT_MPVOP' , '50/51/02'))) 

                       		U_GrvMonitor(,,_cJUSCOD,_cCOMENT,"",_dDTNECE,M->C5_I_DTENT,SC5->C5_I_DTENT)
                       		
                       Endif     


					Endif
				
				Elseif M->C5_I_AGEND = "P" .AND. M->C5_I_DTENT < date()
				
				 	If MONTH(DATE()) == 12
				
						M->C5_I_DTENT := STOD(ALLTRIM(STR((YEAR(DATE())+2)))+"0101")-1  
						M->C5_FECENT :=  STOD(ALLTRIM(STR((YEAR(DATE())+2)))+"0101")-1  
						
					Else
					
						M->C5_I_DTENT := STOD(ALLTRIM(STR((YEAR(DATE())+1)))+"0101")-1  
						M->C5_FECENT := STOD(ALLTRIM(STR((YEAR(DATE())+1)))+"0101")-1  
					
					Endif
					
					If !(alltrim(SC5->C5_I_OPER) $ AllTrim(U_ITGETMV( 'IT_MPVOP' , '50/51/02')))

                       _cFilCarreg := SC5->C5_FILIAL
                       If ! Empty(SC5->C5_I_FLFNC)
                          _cFilCarreg := SC5->C5_I_FLFNC
                       EndIf

                       _dDTNECE := M->C5_I_DTENT - (U_OMSVLDENT(M->C5_I_DTENT,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_I_FILFT,SC5->C5_NUM,1, ,_cFilCarreg,SC5->C5_I_OPER,SC5->C5_I_TPVEN))
                       _cJUSCOD := "007"//Alterado Data de Entrega
                       _cCOMENT := "Data de entrega modificada de " + dtoc(SC5->C5_I_DTENT) + " para " + dtoc(M->C5_I_DTENT) + "  via validação data retroativa."

                       //Grava monitor
                       If !(alltrim(M->C5_I_OPER) $ AllTrim(U_ITGETMV( 'IT_MPVOP' , '50/51/02'))) 

                       		U_GrvMonitor(,,_cJUSCOD,_cCOMENT,"",_dDTNECE,M->C5_I_DTENT,SC5->C5_I_DTENT)
                       		
                       Endif     


					Endif
					
				Endif
			
			Endif
			
		Else
		
			_lret := .T.
			
		Endif
			
		If _lret
		
			aCols[n][ aScan( aHeader , { |x| Alltrim(x[2] ) == "C6_ENTREG" } ) ] := M->C5_I_DTENT
			
		EndIf
		
	EndIf
	
EndIf

RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AOMS050G
Autor-------------: Josué Danich Prestes
Data da Criacao---: 02/01/2019
===============================================================================================================================
Descrição---------: Gatilho de data de entrega a partir de tipo de agenda
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS050G()

Local _ddaten := M->C5_I_DTENT

If M->C5_I_AGEND == "P"

	If MONTH(DATE()) == 12
				
		_ddaten := STOD(ALLTRIM(STR((YEAR(DATE())+2)))+"0101")-1  
						
	Else
					
		_ddaten := STOD(ALLTRIM(STR((YEAR(DATE())+1)))+"0101")-1  
					
	Endif

Elseif 	M->C5_I_AGEND  $ 'I/O'

    _cFilCarreg := xFilial("SC5")
    If ! Empty(M->C5_I_FLFNC)
       _cFilCarreg := M->C5_I_FLFNC
    EndIf 

	_ddaten := date() + U_OMSVLDENT(M->C5_I_DTENT,M->C5_CLIENTE,M->C5_LOJACLI,M->C5_I_FILFT,M->C5_NUM,1, ,_cFilCarreg,M->C5_I_OPER,M->C5_I_TPVEN) 
	
Elseif INCLUI 

    _cFilCarreg := xFilial("SC5")
    If ! Empty(M->C5_I_FLFNC)
       _cFilCarreg := M->C5_I_FLFNC
    EndIf 

	_ddaten := date() + U_OMSVLDENT(M->C5_I_DTENT,M->C5_CLIENTE,M->C5_LOJACLI,M->C5_I_FILFT,M->C5_NUM,1, ,_cFilCarreg,M->C5_I_OPER,M->C5_I_TPVEN) 

Elseif ALTERA .AND. M->C5_I_AGEND $ "AM"

	_ddaten := SC5->C5_I_DTENT
	
Endif

Return  _ddaten
