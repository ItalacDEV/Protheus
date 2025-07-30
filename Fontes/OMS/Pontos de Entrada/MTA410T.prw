/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor   |    Data    |                                             Motivo                                             
===============================================================================================================================
 Lucas Borges  | 11/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25.
 Jerry         | 18/11/2020 | Chamado 34742. Ajuste na tratativa de Log de Inclusão de PV.
 Alex Walaluer | 11/05/2020 | Chamado 31089. Ajuste para acrescentar a função FWIsInCallStack("U_AOMS116") p/ envio do RDC.
 Jerry         | 29/04/2022 | Chamado 38883. Ajuste na Efetivação Automatica Pedido Portal retirando paradas em tela.
 Julio Paz     | 01/06/2022 | Chamado 40304. Alterar rotina de gravação de Ped.Vendas para calcular e gravar valor de seguro.
 Julio Paz     | 21/06/2022 | Chamado 39908. P/calcular Frete/Seguro Fob, validar operação/data emissão em parametrp. 
 Igor Melgaço  | 08/12/2022 | Chamado 41604. Novo tratamento para Pedidos de Operacao Triangular. 
================================================================================================================================================================================================
Analista        - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
================================================================================================================================================================================================
Antônio         - Julio Paz     - 02/10/24 - 16/10/24 - 33879   - Desenvolvimento de rotina de geração de pedidos de Pallets de devolução para armazéns 40 e 42. Pedidos sem geração de carga.
Vanderlei Alves - Alex Wallauer - 09/06/25 - 10/06/25 - 45229   - Tratamento para validar FWIsInCallStack("U_AOMS085B") junto com FWISINCALLSTACK("U_ALTERAP")
================================================================================================================================================================================================

*/ 
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"

/*
===============================================================================================================================
Programa--------: MTA410T
Autor-----------: Fabiano Dias da Silva
Data da Criacao-: 04/08/2011
===============================================================================================================================
Descrição-------: P.E. após o processamento da manutenção e liberação de pedidos de vendas
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================*/
User Function MTA410T()

//Static _lGerandoOperTriangular:=.F.//Controle para não entrar em LOOP, gerar dentro da geração do PV de Remessa
Local _cFilHabilit := U_ITGETMV( 'IT_FILINTWS' , '' )
Local _laoms074 := .F.
lOCAL _laoms112 := .F.
Local _nPerSegFob := U_ITGETMV( 'IT_PERSEGFB' , 0.013 ) 
Local _lHabTpFFb  := .F. // HABILITADO TIPO FRETE FOB.
Local _nValTotImp  := 0
Local _nValSeguro  := 0
Local _cOperFret := U_ITGETMV("IT_OPERFRE","") 
Local _dDtCalcFr := Ctod(U_ITGETMV("IT_DTCALCF","23/06/2022"))

//====================================================================================================
//Se veio do webservice já retorna .T.
//====================================================================================================
If FWIsInCallStack("U_ALTERAP") .or. FWIsInCallStack("U_INCLUIC") .or. FWIsInCallStack("U_AOMS085B")
	_laoms074 := .T.
Endif

//Se esta sendo chamado via AOMS112/MOMS050 (Central Pedido Portal / Efetivaççao Automatica)
If FWIsInCallStack("U_AOMS112") .or. FWIsInCallStack("U_MOMS050")
	_laoms112 := .T.
Endif


//Grava Log se for inclusão ou cópia

/*
If inclui  .and. !FWIsInCallStack("A440AUTOMA")

	Public _aLogSC6	:= {}

	_aDadIni		:= {}
	aAdd( _aDadIni , { 'C5_FILIAL'	, SC5->C5_FILIAL	, ''		} )
	aAdd( _aDadIni , { 'C5_NUM'		, SC5->C5_NUM		, ''		} )
	aAdd( _aDadIni , { 'C5_CLIENTE'	, SC5->C5_CLIENTE	, ''		} )
	aAdd( _aDadIni , { 'C5_LOJACLI'	, SC5->C5_LOJACLI	, ''		} )
	aAdd( _aDadIni , { 'C5_EMISSAO'	, SC5->C5_EMISSAO	, StoD('')	} )
	aAdd( _aDadIni , { 'C5_I_DTENT'	, SC5->C5_I_DTENT	, StoD('')	} )
	
	_acampos		:= {'C6_ITEM','C6_PRODUTO','C6_PRCVEN','C6_TES','C6_QTDVEN','C6_LOCAL','C6_PEDCLI'}
	
	SC6->(Dbsetorder(1))
	If SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
	
		_citem := SC6->C6_ITEM

		Do while SC5->C5_FILIAL+SC5->C5_NUM == SC6->C6_FILIAL+SC6->C6_NUM

			For _nnl := 1 to len(_acampos)
				
				_cCpoAux := "SC6->"+ _acampos[_nnl]
				aAdd( _aLogSC6 , {  _acampos[_nnl] , &_cCpoAux, '' } )
						
			Next
		
			SC6->(Dbskip())
			
			If SC6->C6_ITEM != _CITEM .OR. !(SC5->C5_FILIAL + SC5->C5_NUM == SC6->C6_FILIAL+SC6->C6_NUM)
			
				U_ITGrvLog( _aLogSC6 , "SC6" , 1 , SC5->( C5_FILIAL + C5_NUM ) + _citem  , 'I' , RetCodUsr() ,  date() , time() )
				_aLogSC6 := {}
				
				If SC5->C5_FILIAL + SC5->C5_NUM == SC6->C6_FILIAL+SC6->C6_NUM
				
					_CITEM := SC6->C6_ITEM
					
				Endif
				
			Endif
			
		Enddo
	
	Endif
	
	
	U_ITGrvLog( _aDadIni , 'SC5' , 1 , SC5->( C5_FILIAL + C5_NUM ) , 'I' , RetCodUsr() , date() , time() )
	

Endif
*/ 

If (FUNNAME()=='MATA410' .OR. FUNNAME()=='AOMS061' .OR. _laoms112 .OR. FWIsInCallStack("U_AOMS116")) .and. !_laoms074
	
	If SC5->C5_I_ENVRD <> 'S'
		
		SC5->( Reclock( "SC5", .F. ) )
		
		SC5->C5_I_ENVRD := "N" 
		 
		SC5->( MsUnlock() )
		
		If SC5->C5_FILIAL $ _cFilHabilit // Filiais habilitadas na integracao Webservice Italac x RDC.
			
			U_AOMS084P()
 
		EndIf
		 
	Endif
  
    //==========================================================================================
	// Verifica e grava valor de seguro calculado sobre valor do pedido de vendas com impostos. 
    //==========================================================================================
 	_lHabTpFFb := Posicione('SA1',1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),'A1_I_FOB')
    
	If ValType(_lHabTpFFb) == "L" .And. _lHabTpFFb .And. SC5->C5_TPFRETE $ "F/D" .And. !(SC5->C5_I_OPER $ _cOperFret) .And. Dtos(SC5->C5_EMISSAO) >= Dtos(_dDtCalcFr) ;
	   .And. !(SC5->C5_CONDPAG == "001") // Não calcular o seguro se a condição de pagamento for 'a vista'.
       _nValTotImp := Ma410Impos( 6, .T., {}) // Total do Pedido de Vendas com impostos.
       _nValSeguro := _nValTotImp * _nPerSegFob / 100
       
	   SC5->( Reclock( "SC5", .F. ) )
	   SC5->C5_SEGURO := Round(_nValSeguro,2)
	   SC5->( MsUnlock() )
	Else 
	   SC5->( Reclock( "SC5", .F. ) )
	   SC5->C5_SEGURO := 0
	   SC5->( MsUnlock() )
	EndIF 
 
Endif 
/*
If (FUNNAME()=='MATA410' .OR. FUNNAME()=='AOMS061' .OR. _laoms112 ) .OR. FWIsInCallStack("U_ALTERAP") .OR. FUNNAME()='AOMS109'

	//================================================================================
	//***********   TRATAMENTO DE OPERACAO TRIANGULAR  ********************************
	_cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))// Tipos de operações da operação trigular
    If SC5->C5_I_OPER $ _cOperTriangular .AND. !_lGerandoOperTriangular//Controle para não entrar em LOOP, gerar dentro da geração do PV de Remessa
       _lGerandoOperTriangular:=.T.

	    U_IT_OperTriangular(SC5->C5_NUM,.F.)

       _lGerandoOperTriangular:=.F.
    ENDIF
    //================================================================================
     
Endif
*/
If !_laoms074

	U_ENVSITPV() //Envia interface de situação do pedido para o RDC se for pedido RDC e grava campo de situação do pedido XFUNOMS
	
Endif

//==============================================================
// Chama a rotina de geração de pedidos de pallets de devolução.
//==============================================================
If SC5->C5_I_GPADV == "S" .And. SC5->C5_I_PEDPA <> 'S'   
   U_AOMS147()
EndIf 

Return 
