/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaco  |04/06/2021| Chamado 36391. Tratamento da opcao nova 3-COMISSAO
Alex Wallauer |23/08/2021| Chamado 37546. Nova Pergunta "Custo operacional por planta?" p/ filial 10
Lucas Borges  |13/10/2024| Chamado 48465. Retirada da função de conout
Lucas Borges  |23/07/2025| Chamado 51340. Ajustar função para validação de ambiente de teste
==============================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Andre       - Alex Wallauer - 04/04/25 - 04/04/25 - 50389   - Novo filtro para considerar centro de custo no calculo das horas extras.
Andre       - Alex Wallauer - 29/04/25 - 29/04/25 - 50525   - Alteracao do diretorio temporario para GetTempPath().
==============================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"

#DEFINE ENTER CHR(13)+CHR(10)

STATIC _aSalvaCusMGCMS
//STATIC _nSlvGetVlrMix
//STATIC _nSlvVolLeite

/*
===============================================================================================================================
Programa----------: MEST009
Autor-------------: Josue Danich
Data da Criacao---: 04/12/2015
Descricao---------: Gestao de custo gerencial ( Chamado 12497 )
Parametros--------: Nenhum
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/
User Function MEST009()

Local _bProcess  	:= nil
//Local _oSelf		:= nil
Local _lRet		:= .F.
Local oProcess
PRIVATE lHtml := (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtmlLocal 
PRIVATE _cdir := GetTempPath()
IF lHtml
   _cdir := "\data\Italac\MEST009\LOGS\"
ENDIF


//============================================
//VERIFICA PERMISSAO DE ACESSO
//============================================
_lRet :=  U_ITVACESS( 'ZZL' , 3 , 'ZZL_GCUSTO' , "S" )

If !_lRet

	U_ITMSG('Usuario sem acesso à rotina de gestão de custos gerenciais!',"ATENÇÃO",;
			'Favor entrar em contato com o responsavel do Leite.',3)
	
	Return .F.
	                                               
EndIf

//============================================
//Cria perguntas de regras
//============================================
PERGUNTE("MEST009",.F.)
_nTamInt:=LEN(MV_PAR09)

_aItalac_F3:={}
AADD(_aItalac_F3,{"MV_PAR12",,,,,"Planilhas disponiveis para Geração",2,U_MEST9Plan()} )//'LSTME9'
AADD(_aItalac_F3,{"MV_PAR02","ZL5", ZL5->(FIELDPOS("ZL5_CODGRP"))                          ,{|| "["+ZL5->ZL5_TPCUST+"] "+ZL5->ZL5_DESGRP },{|| IIF(EMPTY(MV_PAR01),.T.,ZL5->ZL5_TPCUST $ ALLTRIM(MV_PAR01)) },"Grupo Custo do Leite",LEN(ZL5->ZL5_CODGRP),, } )
AADD(_aItalac_F3,{"MV_PAR09","SM2",{|| STRTRAN(STRZERO(SM2->M2_MOEDA2,_nTamInt,2),".",",")},{|| DTOC(SM2->M2_DATA)                       },{|| SM2->M2_DATA >=  MV_PAR05 .AND. SM2->M2_DATA <= MV_PAR06     },"Taxas Moeda Dolar",_nTamInt,,1,.F. } )

PRIVATE _lGera1Pla:= .F.
PRIVATE _lGera2Pla:= .F.
PRIVATE _lGera3Pla:= .F.
PRIVATE _lGera4Pla:= .F.
PRIVATE _nTotdol  := 0
PRIVATE _aCusto04 := {}

DO WHILE .T.

   //============================================
   //Cria interface principal
   //============================================
   _lLoop:=.F.
//   lExecuta:=.F.
   PRIVATE oTProcess
   oProcess:= MsNewProcess():New({|_lEnd,oProcess| MEST009M(@oProcess, @_lEnd) },"Gestao de Custo Gerencial H.I.: "+TIME(),"Processando",.T.)      

   _bProcess    := {|O|IF( MEST009K(O), oProcess:Activate() , _lLoop := .T. ) }
   TNewProcess():New( "MEST009", "Gestao de Custo Gerencial", _bProcess, "Rotina de geracao de dados de custos gerenciais","MEST009",,,,,,.T.)
   oProcess:=NIL
   DelClassIntf()
   IF _lLoop//Se A função MEST009K() devolver .F. ou usuario abortar ou processsar normalmente dá o loop para aparecer a tela novamente senão sai fora 
      LOOP
   ENDIF
   EXIT//Botão cancela 

ENDDO
Return .T.

/*
===============================================================================================================================
Programa----------: MEST009M
Autor-------------: Josue Danich
Data da Criacao---: 28/10/2014
Descricao---------: Processamento principal da Gestao de custo gerencial 
Parametros--------: _oself - Objeto da interface principal / _lEnd - Variavel de Cancelamento
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/
Static Function MEST009M(_oSelf,_lEnd)

Local _nRegZL6 := 0
Local _lRet		:= .F.
Local _lMensagem:=.F.

_oSelf:SetRegua1( 4 )
_oSelf:SetRegua2( 4 )
_oSelf:IncRegua1("Iniciando os trabalhos, Aguarde..." )
_oSelf:IncRegua2("Iniciando os trabalhos, Aguarde..." )

IF TYPE("oTProcess") = "O" 
   oTProcess:SetRegua1( 2 )
   oTProcess:SetRegua2( 2 )
   oTProcess:IncRegua1("Ainda Processando, Aguarde..." )
   oTProcess:IncRegua2("Ainda Processando, Aguarde..." )
ENDIF

_lEnd:= .F.

Private lPrim		:= .T.
Private _ntotlei 	:= 0
Private _nTotSoro   := 0
Private _atotlei	:= {}
PRIVATE _cFilsemSRX := ""
PRIVATE _cTimeIni   := TIME()

MV_PAR09:=STRTRAN(LEFT(MV_PAR09,_nTamInt),",",".")
PRIVATE _nTotdol := VAL(MV_PAR09)
PRIVATE _aFactoMike:={}
AADD(_aFactoMike,{"08000000039",1.0350,0,'x'})//Leite Cru: Quando o código do leite for 08000000039, fazer a conversão da quantidade encontrada * 1,035

AADD(_aFactoMike,{"08000000001",1.0313,0,'x'})//Leite Integral: Quando o código do leite for 08000000001;08000000051, fazer a conversão da quantidade encontrada * 1,0313
AADD(_aFactoMike,{"08000000051",1.0313,0,'x'})//Leite Integral: Quando o código do leite for 08000000001;08000000051, fazer a conversão da quantidade encontrada * 1,0313

AADD(_aFactoMike,{"08000000073",1.0344,0,'x'})//Leite Semi: Quando o código do leite for 08000000073;08000000003;08000000057, fazer a conversão da quantidade encontrada * 1,0344
AADD(_aFactoMike,{"08000000003",1.0344,0,'x'})//Leite Semi: Quando o código do leite for 08000000073;08000000003;08000000057, fazer a conversão da quantidade encontrada * 1,0344
AADD(_aFactoMike,{"08000000057",1.0344,0,'x'})//Leite Semi: Quando o código do leite for 08000000073;08000000003;08000000057, fazer a conversão da quantidade encontrada * 1,0344

AADD(_aFactoMike,{"08000000074",1.0344,0,'x'})//Leite Desnatado: Quando o código do leite for 08000000074;08000000002, fazer a conversão da quantidade encontrada * 1,0344
AADD(_aFactoMike,{"08000000002",1.0344,0,'x'})//Leite Desnatado: Quando o código do leite for 08000000074;08000000002, fazer a conversão da quantidade encontrada * 1,0344

AADD(_aFactoMike,{"08140000001",1.0320,0,'08000000028'})//Leite em pó Integral: As quantidade de leite em pó nos códigos: 08140000001;00020010501;00020010533 Após encontrar as quantidade de leite em pó, convertemos para o Rendimento em LTs, que é a quantidade*8,3. Após isso, convertemos novamente de LTS P/ KG, o resultado*1,032
AADD(_aFactoMike,{"00020010501",1.0320,0,'08000000028'})//--Leite em pó Integral: As quantidade de leite em pó nos códigos: 08140000001;00020010501;00020010533 Após encontrar as quantidade de leite em pó, convertemos para o Rendimento em LTs, que é a quantidade*8,3. Após isso, convertemos novamente de LTS P/ KG, o resultado*1,032
//NAÕ USA AADD(_aFactoMike,{"00020010533",1.0320,0,'08000000028'})//Leite em pó Integral: As quantidade de leite em pó nos códigos: 08140000001;00020010501;00020010533 Após encontrar as quantidade de leite em pó, convertemos para o Rendimento em LTs, que é a quantidade*8,3. Após isso, convertemos novamente de LTS P/ KG, o resultado*1,032

AADD(_aFactoMike,{"00020020533",1.0320,0,'08000000050'})//Leite em pó Desnatado: As quantidade de leite em pó nos códigos:00020020533;08140000002;00020020501 Após encontrar as quantidades de leite em pó, convertemos para o Rendimento em LTs, que é a quantidade*10,7. Após isso, convertemos novamente de LTS P/ KG, o resultado*1,032
AADD(_aFactoMike,{"08140000002",1.0320,0,'08000000050'})//--Leite em pó Desnatado: As quantidade de leite em pó nos códigos:00020020533;08140000002;00020020501 Após encontrar as quantidades de leite em pó, convertemos para o Rendimento em LTs, que é a quantidade*10,7. Após isso, convertemos novamente de LTS P/ KG, o resultado*1,032
//NAÕ USA AADD(_aFactoMike,{"00020020501",1.0320,0,'08000000050'})//Leite em pó Desnatado: As quantidade de leite em pó nos códigos:00020020533;08140000002;00020020501 Após encontrar as quantidades de leite em pó, convertemos para o Rendimento em LTs, que é a quantidade*10,7. Após isso, convertemos novamente de LTS P/ KG, o resultado*1,032
PRIVATE _aRecalVlrs:={}
                 //ORIGEM                ,DESTINO
AADD(_aRecalVlrs,{"LEITE EM PO INTEGRAL 25 KG",'LEITE EM PO INTEGRAL',0})//Leite em pó Integral
//AADD(_aRecalVlrs,{"LEITE EM PO INTEGRAL 25 KG","08140000001",0})//Leite em pó Integral
//AADD(_aRecalVlrs,{"LEITE EM PO INTEGRAL 25 KG","00020010501",0})//Leite em pó Integral

AADD(_aRecalVlrs,{"LEITE EM PO DESNATADO 25 KG",'LEITE EM PO DESNATADO',0})//Leite em pó Desnatado
//AADD(_aRecalVlrs,{"LEITE EM PO DESNATADO","08140000002",0})//Leite em pó Desnatado
//AADD(_aRecalVlrs,{"LEITE EM PO DESNATADO","00020020501",0})//Leite em pó Desnatado

//INICIAANDO VARIAVEIS STATICAS
_aSalvaCusMGCMS:={}
//_nSlvGetVlrMix:=0
//_nSlvVolLeite:=0
		
//==================================================
//Roda engine de dados de custo gerencial
//==================================================
//MV_PAR01 - Tipo Grupo
//MV_PAR02 - Grupo Custo
//MV_PAR05 - Data inicial
//MV_PAR06 - Data Final
// Ultimo parâmetro indica que e a primeira etapa de leitura da ZL6
PRIVATE _lMostraSoro:=.F.

If MV_PAR07 = 2//Atualiza dados
   MV_PAR01:=" "
   MV_PAR02:=" "
   MV_PAR03:=" "
   MV_PAR04:=" "
ELSEIf MV_PAR07 = 3//Gera Excel
   If cFilAnt = "10"
      _lMostraSoro := U_ITMSG("Custo operacional por planta?",'Atenção!', ,3,2,2)//ALERT
   ENDIF  
ENDIF
/*
If	YEAR(MV_PAR06) <>  YEAR(MV_PAR05) .OR. MONTH(MV_PAR06) <> MONTH(MV_PAR05)
	U_ITMSG("O ano e o mes da data inicial e final não estão iguais.","ATENCAO","Selecione datas com o primeiro dia do mes e o ultimo dia do mesmo mes e ano.",1)
	RETURN .F.
Endif
*/
_nRegZL6 := U_MEST009E(mv_par01,MV_PAR02,MV_PAR05,MV_PAR06,1,_oSelf,@_lEnd)[1]
IF _lLoop
   RETURN .F.
ENDIF

DBSELECTAREA("ZL6T")

DBGOTOP()
		
If ZL6T->(!Eof())
		
	//==================================================
	//Executa relatorio 
	//==================================================
	If MV_PAR07 = 1
		
		MEST009P()
		
	Endif
		
	//==================================================
	//Atualiza dados
	//==================================================
	If MV_PAR07 = 2
					
		//============================================
		//VERIFICA PERMISSAO DE ACESSO PARA GRAVACAO
		//============================================
		_lRet :=  U_ITVACESS( 'ZZL' , 3 , 'ZZL_WCUSTO' , "S" )

		If !_lRet

			U_ITMSG( 'Usuario sem acesso à gravacao de custos gerenciais!', "ATENÇÃO" ,;
					 'Favor entrar em contato com o responsavel do Leite.', 3  )
	
			Return .F.
	
		EndIf
		_lGera1Pla:= .T.//Liga para calcular os dados de DEMONSTRATIVO DO ESTOQUE FINAL PLANILHA 03 Grupo (000006) OU (PLANILHA 02 PASTA 2 Grupos (000004/000005) ) ZL6T->ZL6_OBSERV == "E"
		//==================================================
		//RODA GRAVACAO DE DADOS
		//==================================================
		_lret := MEST009D(_oSelf,_nRegZL6,@_lEnd)  
		
		//==================================================
		//VERIFICA SE USUARIO PODE E QUER FAZER O FECHAMENTO
		//==================================================
		If _lret
		
			If U_ITVACESS( 'ZZL' , 3 , 'ZZL_FCUSTO' , "S" )

				If U_ITMSG("Gravar fechamento para o mês " + STRZERO(MONTH(MV_PAR05),2) + " /" + ALLTRIM(STR(YEAR(MV_PAR05))) + " ?","Fechamento de custo",,3,2,2)// == 6
				
					Dbselectarea("ZP1")
					ZP1->( Dbsetorder(2) ) //ZP1_FILIAL+ZP1_FILPAR+ZP1_PARAM
					
					If ZP1->( Dbseek( xFilial("ZP1") + xFilial("ZL6") + "IT_ULMES") )
					
						ZP1->( RecLock( 'ZP1' , .F. ))
						ZP1->ZP1_CONTEU	:= strzero(month(MV_PAR05),2) + alltrim(str(year(MV_PAR05)))
						ZP1->( MsUnLock() )
						
/*						_oself:SaveLog( "REALIZADO FECHAMENTO DE CUSTOS GERENCIAIS" )
						_oself:SaveLog( "PERIODO  - " + strzero(month(MV_PAR05),2) + alltrim(str(year(MV_PAR05))) )
						_oself:SaveLog( "USUARIO 	- " + cusername)
						_oself:SaveLog( "DATA - " + dtoc(date()) + " - " + time())
*/						
					Endif
				
				Endif				
	
			Endif

		EndIf		
		
	Endif
	
	//==================================================
	//Gera Excel
	//==================================================
	If MV_PAR07 = 3

	   _lMensagem:=MEST009Y(_oself,_nRegZL6,@_lEnd)
		
	Endif
	
Else
	
	U_ITMSG("Nao foram encontradas regras de custo para os paramentros informados",'Atenção',"Verifique os paramentros e tente novamente",1)	
    Return .F.
	
Endif
	
If Select("ZL6T") > 0 
	ZL6T->( DBCloseArea() )
EndIf

//========================================	
//abre novamente a tela inicial
//========================================
_lLoop:=.T.	
IF _lMensagem
   U_ITMSG("Planilha(s) "+ALLTRIM(MV_PAR12)+" Gerada(s)!!!",'Informação!',"Hora inicial: "+_cTimeIni+ENTER+"Hora final: "+TIME(),2)
ENDIF
Return .T.

/*
===============================================================================================================================
Programa----------: MEST009D
Autor-------------: Josue Danich Prestes
Data da Criacao---: 04/11/2015
Descricao---------: Gera dados de custos gerenciais
Parametros--------: _oself - Objeto da interface principal / _nRegZL6 - numero de registros lidos na ZL6  / _lEnd - Variavel de Cancelamento
Retorno-----------: .T. se processou com sucesso ou .F. se ocorreram erros ou cancelamento do processamento
===============================================================================================================================
*/
Static Function MEST009D(_oSelf,_nRegZL6,_lEnd)
//Local _nVlrSin 		:= 0
//Local _nQtdSin 		:= 0
Local _cfiltro 		:= ""
//Local _aretorno  	:= {}
Local _culmes		:= ""
Local _ni			:= 1
Local _aze0			:= {}
Local _aze1			:= {}
Local _azeNew		:= {}
Local _nvalope		:= 0
Local _aprod		:= {}
//Local _cquery 		:= ""
Local _acustop		:= {}
Local _ns 			:= 0
Local _atotprod		:= {}
Local _ntotop		:= 0
Local _ntotprod 	:= 0
Local _no 			:= 0 , _Cus  , _np , _Pi , _Qba
//Private _nTotdol	:= MV_PAR09 //Dolar

//========================================================
//Define data inicial e final e pergunta se continua
//========================================================
MV_PAR05 := stod(alltrim(str(year(MV_PAR05))) + strzero((month(MV_PAR05)),2)+"01")

If month(MV_PAR05) < 12
	MV_PAR06 := stod(alltrim(str(year(MV_PAR05))) + strzero((month(MV_PAR05)+1),2)+"01") - 1
Else
	MV_PAR06 := stod(alltrim(str((year(MV_PAR05)+1))) + "0101") - 1
Endif

//===========================================================================
//Verifica se nao vai rodar período ja fechado pelo IT_ULMES
//===========================================================================
_culmes := U_ITGETMV( "IT_ULMES" , "012001") //"112018" //"112018" //

If	(SUBSTR(_culmes,3,4) >  alltrim(str(year(MV_PAR05)))) .OR. (SUBSTR(_culmes,3,4) =  alltrim(str(year(MV_PAR05))) .AND.  SUBSTR(_culmes,1,2) >= STRZERO(MONTH(MV_PAR05),2))
	U_ITMSG("Período selecionado já fechado! ( " + substr(_culmes,1,2) + "/" + substr(_culmes,3,4) + " ).","Fechamento","Reabra o fechamento para nova gravacao.",1)
	RETURN .F.
Endif

If !U_ITMSG("At. Dados sera realizada para período de " + dtoc(MV_PAR05) + " ate " + dtoc(MV_PAR06) + ", continua?","Atualizacao Dados",,3,2,2)// <> 6
   RETURN .F.
Endif


//==============================================================
//Roda SubEngine que prepara arrays e valores de gravação
//==============================================================
MEST009SE( _nRegZL6, _oself, @_aze0, @_aze1, @_nvalope, @_azeNew,@_lEnd)
IF _lLoop
   RETURN .F.
ENDIF

//unifica _aze0 e _aze1
Do while _ni <= len(_aze1)

	aadd(_aze0,_aze1[_ni])
	_ni++
	
Enddo

//elimina itens suprimidos e nao soma
_ni := 1

_aze1 := _aze0
_aze0 := {}

Do while _ni <= len(_aze1)

	if (_aze1[_ni][13] != '4' .and. _aze1[_ni][13] != '5') .OR. _aze1[_ni][16] == '6'
	
		aadd(_aze0,_aze1[_ni])
		
	Endif
	
	_ni++
	
Enddo

//Algutina itens regra 2
_ni := 1

_aze1 := _aze0
_aze0 := {}


Do while _ni <= len(_aze1)

	_np := ascan(_aze0,{|_vAux|_vAux[1]==_aze1[_ni][01] .and. _vAux[2]==_aze1[_ni][02]  .and. _vAux[4]==_aze1[_ni][04]  .and.  _vAux[8]==_aze1[_ni][08].and.  _vAux[17]==_aze1[_ni][14] }) 


	if !(_aze1[_ni][13] == '2') .and. _np > 0
			
			_aze0[_np][10]  +=  _aze1[_ni][10]
			_aze0[_np][11]  +=  _aze1[_ni][11]	
			
	Else	
	
		aadd(_aze0,_aze1[_ni])
		
	Endif
	
	_ni++
	
Enddo

_oself:SetRegua1( _nRegZL6 )
_oself:SetRegua2( _nRegZL6 )
_ni := 1 

_nRegZL6:=LEN(_aze0)
_nContaZ:=0
_oself:SetRegua1( _nRegZL6 )
_oself:SetRegua2( _nRegZL6 )
_cTotRegZL6:=ALLTRIM(STR(_nRegZL6))

_cTeste:=" ATUALIZACAO: "+ENTER
_aTotais:={}
_ni:=1
FOR _ni := 1 TO LEN(_aze0)
	
	If .NOT. (ALLTRIM(_aze0[_ni][05]) == "PRODUTOS ACABADOS PRODUZIDOS") // _aze0[_ni][16] == '6' .AND. _aze0[_ni][3] == "PRODUTOS ACABADOS" .AND. 
		
		_cChave:=ALLTRIM(_aze0[_ni][01])+alltrim(_aze0[_ni][03])+alltrim(_aze0[_ni][09])
		
		IF (nPos:=ASCAN(_aTotais,{ |C| C[1] == _cChave })) = 0
			AADD(_aTotais, {_cChave,0,0,0} )
			nPos:=LEN(_aTotais)
		ENDIF

//      _cTeste+=_aze0[_ni][02]+";"+_aze0[_ni][09]+";"+_aze0[_ni][05]+";"+_aze0[_ni][07]+";"+STR(_aze0[_ni][11],20,8)+ENTER
  
		If !(LEN(_aze0[_ni]) >= 21 .AND. VALTYPE(_aze0[_ni][21]) = "N" .AND. _aze0[_ni][21] <> 0)//--> <> "N" //soma tudo que não tiver a regra do ZL6T->ZL6_CUSPR = "S" e "A" e "B"
           //_cTeste+=STR(nPos,1)+";T;"+_aze0[_ni][02]+";"+_aze0[_ni][09]+";"+_aze0[_ni][05]+";"+_aze0[_ni][07]+";"+STR(_aze0[_ni][11],20,8)+ENTER
		   _aTotais[nPos,2]+=_aze0[_ni][11]      //CUSTO PRODUCAO
		ENDIF
		IF "EMBALAGENS" $ _aze0[_ni][05]
           //_cTeste+=STR(nPos,1)+";;E;"+_aze0[_ni][02]+";"+_aze0[_ni][09]+";"+_aze0[_ni][05]+";"+_aze0[_ni][07]+";"+STR(_aze0[_ni][11],20,8)+ENTER
		   _aTotais[nPos,3]+=_aze0[_ni][11]  //CUSTO PRODUTO ABERTO
		ENDIF
		
	Endif

NEXT

//_cTeste+=" RATEIO: "+ENTER

FOR _ni := 1 TO LEN(_aze0)
	
	If _aze0[_ni][3] == "PRODUTOS ACABADOS" .AND. .NOT. ALLTRIM(_aze0[_ni][05]) == "PRODUTOS ACABADOS PRODUZIDOS"//_aze0[_ni][16] == '6' .AND. 
		
		If  LEN(_aze0[_ni]) >= 21 .AND. VALTYPE(_aze0[_ni][21]) = "N" .AND. _aze0[_ni][21] <> 0//--> <> "N"
			
			_cChave:=ALLTRIM(_aze0[_ni][01])+alltrim(_aze0[_ni][03])+alltrim(_aze0[_ni][09])
			
			IF (nPos:=ASCAN(_aTotais,{ |C| C[1] == _cChave })) <> 0
				
				_np := ascan(_atotlei,{|_vAux|_vAux[1]==_aze0[_ni][08]})
				If _np > 0
					_ntotlei2 := _atotlei[_np][2]
				Else
					_ntotlei2 := 1
				Endif
				If _aze0[_ni][2] == '000001' .OR. _aze0[_ni][2] == '000003'
					_ntotlei2 := _ntotlei
				Endif

				_nCusmed := _aTotais[nPos,2] / _ntotlei2//CUSTO PRODUCAO
				_nCusAbe := _aTotais[nPos,3] / _ntotlei2//CUSTO PRODUTO ABERTO

				IF _aze0[_ni][21]=2 .AND. _nCusAbe = 0//ZE0_TPCUS+ZE0_GRPCT+ZE0_DSECT
				   _nCusAbe:=MEST2BuscaZE0(_aze0[_ni][2],_aze0[_ni][9],_aze0[_ni][7],_aze0[_ni])
				ENDIF

				_nCusFor := _aTotais[nPos,4] / (_ntotlei2+_nCusAbe)//CUSTO PRODUTO FORMULADO

//              _cTeste+=_aze0[_ni][02]+";"+_aze0[_ni][09]+";"+_aze0[_ni][05]+";"+_aze0[_ni][07]+";"+STR(_aTotais[nPos,2],20,8)+";"+STR(_ntotlei2,20,8)+";"+STR(_nCusmed,20,8)+ENTER

				// _aze0[_ni][21] == 0 = "N" = ZL6T->ZL6_CUSPR
				IF _aze0[_ni][21] = 1  .AND. _nCusmed <> 0     // ZL6T->ZL6_CUSPR = "S" = 1 = _aze0[_ni][21]
				   
				   _aze0[_ni][11] := _nCusmed * _aze0[_ni][10]// CUSTO PRODUCAO       //                   _cTeste+="1;"+STR(_aze0[_ni][11],20,8)+";"+_aze0[_ni][02]+";"+_aze0[_ni][09]+";"+_aze0[_ni][05]+";"+_aze0[_ni][07]+";"+STR(_aze0[_ni][10],20,8)+";"+STR(_nCusmed,20,8)+ENTER

				ELSEIF _aze0[_ni][21] = 2 .AND. _nCusAbe <> 0  // ZL6T->ZL6_CUSPR = "A" = 2 = _aze0[_ni][21]
				   
				   _aze0[_ni][11] := _nCusAbe * _aze0[_ni][10]// CUSTO PRODUTO ABERTO    //                   _cTeste+="2;"+STR(_aze0[_ni][11],20,8)+";"+_aze0[_ni][02]+";"+_aze0[_ni][09]+";"+_aze0[_ni][05]+";"+_aze0[_ni][07]+";"+STR(_aze0[_ni][10],20,8)+";"+STR(_nCusAbe,20,8)+ENTER

				ELSEIF _aze0[_ni][21] = 3 .AND. _nCusFor <> 0  // ZL6T->ZL6_CUSPR = "B" = 3 = _aze0[_ni][21]
					
					_aze0[_ni][11] := _nCusFor * _aze0[_ni][10]// CUSTO PRODUTO FORMULADO
				
				ENDIF
				
			ENDIF
		Endif
		
	Endif
	
NEXT

_cTeste:=""
_ni:=1
DO WHILE _ni <= LEN(_aze0)

	_nContaZ++
    IF VALTYPE(_oSelf) = "O" 
	   _oself:IncRegua1("1/4-Gravando dados: "+ALLTRIM(STR(_nContaZ,6))+" de "+_cTotRegZL6)
       ProcessMessages()
	ENDIF
    
	_np := ascan(_atotlei,{|_vAux|_vAux[1]==_aze0[_ni][08]})
	If _np > 0
		_ntotlei2 := _atotlei[_np][2]
	Else
		_ntotlei2 := 1
	Endif  
	If _aze0[_ni][2] == '000001' .OR. _aze0[_ni][2] == '000003'
		_ntotlei2 := _ntotlei
	Endif


	_cfiltro :=  xfilial("ZE0") + substr(dtos(MV_PAR05),5,2) +  substr(dtos(MV_PAR05),1,4) + _aze0[_ni][8] + _aze0[_ni][2]
	_cfiltro +=  _aze0[_ni][4] + _aze0[_ni][6]
	
	If ZE0->( Dbseek( _cfiltro ) )
	
		//========================================================
		//Achou registro so atualiza quantidade e valor
		//========================================================
		RecLock("ZE0",.F.)
		ZE0->ZE0_QTDE	:= _aze0[_ni][10]
		ZE0->ZE0_VALOR	:= _aze0[_ni][11]
		ZE0->ZE0_VLRLT	:= _aze0[_ni][11] / _ntotlei2
		ZE0->ZE0_VDOLAR := _aze0[_ni][11] / (_ntotlei2 * _nTotdol)
		ZE0->ZE0_LITRAG := _ntotlei2
				
	Else
	
		//========================================================
		//Nao achou registro cria um novo
		//========================================================
			                     	
		RecLock("ZE0",.T.)    
		
		ZE0->ZE0_FILIAL := 	_aze0[_ni][1]	
		ZE0->ZE0_TPCUS	:=	_aze0[_ni][2]
		ZE0->ZE0_DTPCT	:=	_aze0[_ni][3]
		ZE0->ZE0_EVCUS	:=	_aze0[_ni][4]
		ZE0->ZE0_DEVCT	:=	_aze0[_ni][5]
		ZE0->ZE0_SEVCT	:= 	_aze0[_ni][6]
		ZE0->ZE0_DSECT	:= 	_aze0[_ni][7]
		ZE0->ZE0_GRPCT	:= 	_aze0[_ni][8]
		ZE0->ZE0_DGRPCT	:= 	_aze0[_ni][9]
		ZE0->ZE0_QTDE	:= 	_aze0[_ni][10]
		ZE0->ZE0_VALOR	:= 	_aze0[_ni][11]
		ZE0->ZE0_DATARQ	:= 	_aze0[_ni][12]
		ZE0->ZE0_VLRLT	:=  _aze0[_ni][11] / _ntotlei2
		ZE0->ZE0_VDOLAR :=  _aze0[_ni][11] / (_ntotlei2 * _nTotdol)
		ZE0->ZE0_LITRAG := _ntotlei2
		
	Endif
	
	//===============================================================
	//Prepara array de total de custo e qtde de produção por grupo
	//===============================================================
	_ns:=0
	If ZE0->ZE0_TPCUS == '000002' .and. alltrim(_aze0[_ni][16]) != "6" .and. alltrim(_aze0[_ni][16]) != "1"
	
		_ns := ascan( _acustop,{|_vAux | _vAux[1] == alltrim(ZE0->ZE0_GRPCT)})
		
		If _ns > 0
		
			_acustop[_ns][2] += ZE0->ZE0_VALOR
			
		Else
		    _cChave1:=xFilial("ZL6")+_aze0[_ni][8]+PADR(_aze0[_ni][3],60)+PADR(_aze0[_ni][9],40)
		    _cChave2:=alltrim(_aze0[_ni][01])+alltrim(_aze0[_ni][03])+alltrim(_aze0[_ni][09])

			aadd(_acustop,{ alltrim(ZE0->ZE0_GRPCT),;//01
			                        ZE0->ZE0_VALOR ,;//02
			                        	  _cChave1,; //03	
			                              _cChave2 ,;//04 
			                              0        })//05 nDev 
			
		Endif
		
	Elseif ZE0->ZE0_TPCUS == '000002' .and. alltrim(_aze0[_ni][16]) == "6" 
	
		_ns := ascan( _atotprod,{|_vAux | _vAux[1] == alltrim(ZE0->ZE0_GRPCT)})
		
		If _ns > 0
		
			_atotprod[_ns][2] += ZE0->ZE0_QTDE
			
		Else
		
			aadd(_atotprod,{ alltrim(ZE0->ZE0_GRPCT), ZE0->ZE0_QTDE })
			
		Endif
		
		_ntotprod += ZE0->ZE0_QTDE
		
	Elseif ZE0->ZE0_TPCUS == '000001' .OR. ZE0->ZE0_TPCUS == '000003'
	
		_ntotop += ZE0->ZE0_VALOR
	
	Endif
			
	ZE0->(MsUnlock())
	
	//Adiciona registros finais de produto acabado produzido para cada produto
	If _aze0[_ni][16] == '6'
	    
	   	//========================================================================
		//Prepara subtotal do grupo
		//========================================================================
		_nsubtot5		:= 0 
		_no := _ni //guarda posição do aray
                     
		For _ni := 1 to len(_aze0)  
  
	 		If (alltrim(_aze0[_ni][01])+alltrim(_aze0[_ni][03])+alltrim(_aze0[_ni][09]) == ;
	    		alltrim(_aze0[_no][01])+alltrim(_aze0[_no][03])+alltrim(_aze0[_no][09])) .and. ALLTRIM(_aze0[_ni][5]) != "PRODUTOS ACABADOS PRODUZIDOS" 

	            _cTeste+=";"+ARRTOKSTR(_aze0[_ni],";")+ENTER
	            _cTeste+=TRANSFORM(_aze0[_ni][11], "@E 999999999.99" )+ENTER
		
				_nsubtot5 	+=	_aze0[_ni][11]

	            _cTeste+=ENTER

	  		Endif
  	
		Next
	
		_ni := _no
	    
	    dbselectarea("ZL6")
		_cproduto:= Posicione("ZL6",8,xFilial("ZL6")+_aze0[_ni][8]+PADR(_aze0[_ni][3],60)+PADR(_aze0[_ni][9],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_CODPRO")

// foi para dentro do MEST9ICMS("CARGA_VARIAVEIS_ICMS",_cChave)
//	    _nVIcmEst:= Posicione("ZL6",8,xFilial("ZL6")+_aze0[_ni][8]+PADR(_aze0[_ni][3],60)+PADR(_aze0[_ni][9],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_VICMSE")
//	    _nVIcmInt:= Posicione("ZL6",8,xFilial("ZL6")+_aze0[_ni][8]+PADR(_aze0[_ni][3],60)+PADR(_aze0[_ni][9],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_VICMSI")
//	    _nVIcmTrs:= Posicione("ZL6",8,xFilial("ZL6")+_aze0[_ni][8]+PADR(_aze0[_ni][3],60)+PADR(_aze0[_ni][9],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_VICMST")
//      _nDifAlq := Posicione("ZL6",8,xFilial("ZL6")+_aze0[_ni][8]+PADR(_aze0[_ni][3],60)+PADR(_aze0[_ni][9],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_DIFALQ")

	    _nVlrIcm :=_nVIcmEst:=_nVIcmInt:=_nVIcmTrs:=_nDifAlq:=0//Variaveis antigas
        _nICMSEst:=_nICMSInt:=_nICMSTrs:=0//Variaveis novas valores preco medio
        nDespEst := 0//Variaveis novas para calcular o percentual
        nDespInt := 0//Variaveis novas para calcular o percentual
        nDespTrs := 0//Variaveis novas para calcular o percentual
        _cChave  :=xFilial("ZL6")+_aze0[_ni][8]+PADR(_aze0[_ni][3],60)+PADR(_aze0[_ni][9],40)+"PRODUTOS ACABADOS PRODUZIDOS            "

        MEST9ICMS("CARGA_VARIAVEIS_ICMS",_cChave)

	    _cSegUni := Posicione("ZL6",8,xFilial("ZL6")+_aze0[_ni][8]+PADR(_aze0[_ni][3],60)+PADR(_aze0[_ni][9],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_TUNID")
        _cEstAnt := Posicione("ZL6",8,xFilial("ZL6")+_aze0[_ni][8]+PADR(_aze0[_ni][3],60)+PADR(_aze0[_ni][9],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_ESTANT")
        _cGrpCus := Posicione("ZL6",8,xFilial("ZL6")+_aze0[_ni][8]+PADR(_aze0[_ni][3],60)+PADR(_aze0[_ni][9],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_GRPCUS")
        _cFilis  := Posicione("ZL6",8,xFilial("ZL6")+_aze0[_ni][8]+PADR(_aze0[_ni][3],60)+PADR(_aze0[_ni][9],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_FILIS")
        _cLocais := Posicione("ZL6",8,xFilial("ZL6")+_aze0[_ni][8]+PADR(_aze0[_ni][3],60)+PADR(_aze0[_ni][9],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_LOCAL")

		_aval 		:= MEST009SB9(alltrim(_cproduto),  _cSegUni,_cEstAnt,_cGrpCus)//valores de estoque anterior
		_aven 		:= MEST009SD1(alltrim(_cproduto),2,_cSegUni)//valores de entradas em transferência
		_avdv 		:= MEST009SD1(alltrim(_cproduto),1,_cSegUni)//valores de entradas em devolução
		_aicst 		:= MEST009IST(alltrim(_cproduto))           //valores icms st
		_aExp 		:= MEST009EXP(alltrim(_cproduto),  _cSegUni,_cLocais)//Quantidade expedida
		_aFret		:= MEST009FRT(alltrim(_cproduto),_aExp[1][1])           //Valor Frete
		_nDev 		:= (_nsubtot5 + _aval[1][2]) / (_aval[1][1] + _ntotlei2)  //Valor real de devolução

         _cTeste+="_nDev(;"+TRANSFORM(_nsubtot5, "@E 999999999.99" )+"; + ;"+TRANSFORM(_aval[1][2], "@E 999999999.99" )+";) / (;"+TRANSFORM(_aval[1][1], "@E 999999999.99" )+"; + ;"+TRANSFORM(_ntotlei2, "@E 999999999.99" )+";)"+ENTER

		_nExp 		:= ((_aExp[1][1] ) * ( _nDev ))             //Valor real de expedição
		_nSldAtu	:= MEST9BscSB2(_cproduto)

        IF _nICMSEst > 0 .AND. nDespEst > 0
           _nVIcmEst:=(_nVIcmEst*_aExp[1][2])
        ENDIF
        IF _nICMSInt > 0 .AND. nDespInt > 0
           _nVIcmInt:=(_nVIcmInt*_aExp[1][3])
        ENDIF
        IF _nICMSTrs > 0 .AND. nDespTrs > 0
           _nVIcmTrs:=(_nVIcmTrs*_aExp[1][4])
        ENDIF

		MEST009GRD(_aze0, _ni,_aval[1][2]			, _aval[1][1]					, "999999", "9999", "ESTOQUE ANTERIOR")
		MEST009GRD(_aze0, _ni,_avdv[1][1] * _nDev	, _avdv[1][1]					, "999998", "9998", "ENTRADAS DEVOLUCAO")
		MEST009GRD(_aze0, _ni,_aven[1][2]			, _aven[1][1]					, "999997", "9997", "ENTRADAS TRANSFERENCIA")
		MEST009GRD(_aze0, _ni,_nExp					, _aExp[1][1]					, "999996", "9996", "EXPEDIDO")
		MEST009GRD(_aze0, _ni,_aFret[1][1]			, _aExp[1][1]					, "999995", "9995", "FRETE")
//		MEST009GRD(_aze0, _ni,_nVlrIcm  			, _aExp[1][1]					, "999994", "9994", "ICMS Normal")
		MEST009GRD(_aze0, _ni,_nVIcmEst  			, _aExp[1][1]					, "999994", "9994E", "ICMS Estadual")
		MEST009GRD(_aze0, _ni,_nVIcmInt  			, _aExp[1][1]					, "999994", "9994I", "ICMS InterEstadual")
		MEST009GRD(_aze0, _ni,_nVIcmTrs  			, _aExp[1][1]					, "999994", "9994T", "ICMS Transferencia")

		MEST009GRD(_aze0, _ni,_aicst[1][1]			, _aExp[1][1]					, "999993", "9993", "ICMS Substituicao Tributaria")
		MEST009GRD(_aze0, _ni,_nDifAlq				, _aExp[1][1]					, "999993", "9992", "ICMS Diferencial Aliquota")
		MEST009GRD(_aze0, _ni,_nSldAtu * _nDev		, _nSldAtu 						, "999992", "9991", "ESTOQUE ATUAL")
	
	Endif
		 					
	_ni++

Enddo

_cTeste:=STRTRAN(_cTeste,".",",")
_cFileNome:=_cdir+"MEST009_GRV_ESTOQUE_ATUAL_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".CSV"
MemoWrite(_cFileNome,_cTeste)

//=========================================================================================
// Recalcula o TOTAL PRODUTOS ACABADOS para ficar igual o da geração do Excel - AWF
//=========================================================================================
_nRegZL6:=LEN(_acustop)
_nContaZ:=0
_oself:SetRegua2( _nRegZL6 )
_cTotRegZL6:=ALLTRIM(STR(_nRegZL6))

FOR _Cus := 1 TO LEN(_acustop)
	
	IF VALTYPE(_oSelf) = "O"
		_oself:IncRegua2("2/4-Gravando dados: "+ALLTRIM(STR(_nContaZ,6))+" de "+_cTotRegZL6)
		ProcessMessages()
	ENDIF
	
	_cChave1:=_acustop[_Cus][3]
	_cChave2:=_acustop[_Cus][4]
	
	_np := ascan(_atotlei,{|_vAux|_vAux[1]==_acustop[_Cus][1]})
	If _np > 0
		_ntotlei2 := _atotlei[_np][2]
	Else
		_ntotlei2 := 1
	Endif
	_nsubtot5:=0
	For _ni := 1 to len(_aze0)
		If (alltrim(_aze0[_ni][01])+alltrim(_aze0[_ni][03])+alltrim(_aze0[_ni][09]) == _cChave2 ) .and. ALLTRIM(_aze0[_ni][5]) != "PRODUTOS ACABADOS PRODUZIDOS"
			_nsubtot5 	+=	_aze0[_ni][11]
		Endif
	Next
	
	_cproduto:= Posicione("ZL6",8,_cChave1+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_CODPRO")
	//	_nVIcmEst:= Posicione("ZL6",8,_cChave1+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_VICMSE")
	//	_nVIcmInt:= Posicione("ZL6",8,_cChave1+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_VICMSI")
	//	_nVIcmTrs:= Posicione("ZL6",8,_cChave1+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_VICMST")
	//	_nVlrIcm := _nVIcmEst + _nVIcmInt + _nVIcmTrs
	//  _nDifAlq := Posicione("ZL6",8,_cChave1+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_DIFALQ")
	
	_nVlrIcm :=_nVIcmEst:=_nVIcmInt:=_nVIcmTrs:=_nDifAlq:=0//Variaveis antigas
	_nICMSEst:=_nICMSInt:=_nICMSTrs:=0//Variaveis novas valores preco medio
	nDespEst := 0//Variaveis novas para calcular o percentual
	nDespInt := 0//Variaveis novas para calcular o percentual
	nDespTrs := 0//Variaveis novas para calcular o percentual
	_cChave  :=_cChave1+"PRODUTOS ACABADOS PRODUZIDOS            "
	
	MEST9ICMS("CARGA_VARIAVEIS_ICMS",_cChave)
	
	_cSegUni := Posicione("ZL6",8,_cChave1+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_TUNID")
	_cEstAnt := Posicione("ZL6",8,_cChave1+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_ESTANT")
	_cGrpCus := Posicione("ZL6",8,_cChave1+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_GRPCUS")
	_cLocais := Posicione("ZL6",8,_cChave1+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_LOCAL")
	
	_aval 	 := MEST009SB9(alltrim(_cproduto),_cSegUni,_cEstAnt,_cGrpCus)  //valores de estoque anterior
	_aicst 	 := MEST009IST(alltrim(_cproduto))           //valores icms st
	_aExp 	 := MEST009EXP(alltrim(_cproduto),_cSegUni,_cLocais)  //Quantidade expedida
	_aFret	 := MEST009FRT(alltrim(_cproduto),_aExp[1][1])           //Valor Frete
	
	IF _nICMSEst > 0 .AND. nDespEst > 0
		_nVIcmEst:=(_nVIcmEst*_aExp[1][2])
	ENDIF
	IF _nICMSInt > 0 .AND. nDespInt > 0
		_nVIcmInt:=(_nVIcmInt*_aExp[1][3])
	ENDIF
	IF _nICMSTrs > 0 .AND. nDespTrs > 0
		_nVIcmTrs:=(_nVIcmTrs*_aExp[1][4])
	ENDIF
	_nVlrIcm := _nVIcmEst + _nVIcmInt + _nVIcmTrs
	
	_nDev 	 := (_nsubtot5 + _aval[1][2])/(_aval[1][1] + _ntotlei2)  //Valor real de devolução
	_nExp 	 := ((_aExp[1][1] ) * ( _nDev ))    //Valor real de expedição
	
	_nCustoGeral := _nExp +  _aFret[1][1] + _aicst[1][1]+  _nVlrIcm + _nDifAlq//Recalcula o TOTAL PRODUTOS ACABADOS para ficar igual o da geração do Excel
	
	_acustop[_Cus][2] := IF(_nCustoGeral>0,_nCustoGeral,_acustop[_Cus][2])
	_acustop[_Cus][5] := _nDev
	
NEXT
//=========================================================================================

//=========================================================================================
// Grava dados de produtos para ZE1
//=========================================================================================

//monta array de produtos acabados com custo de produção
_ni := 1

Do while _ni <= len(_aze0)

	If alltrim(_aze0[_ni][16]) == "6" 
	
		_aRet    := MEST009PMMTFQF(_aze0[_ni][15])//Procura preço mínimo, preço máximo, total de faturamento e quantidade faturada
		_nPrcmin := _aRet[1]
		_nPrcmax := _aRet[2]
		_nfatura := _aRet[3]
		_nqtdfat := _aRet[4]
		
		_nPosCus := ascan( _acustop,{|_vAux | _vAux[1] == alltrim(_aze0[_ni][8]) })
		_ncuspro := _aze0[_ni][10] * _acustop[ _nPosCus ][2]
 		_ncuspro := _ncuspro /(_atotprod[ ascan( _atotprod,{|_vAux | _vAux[1] == alltrim(_aze0[_ni][8])}) ][2])
		_ncusop  := _aze0[_ni][10] * (_ntotop / _ntotlei)//_aze0[_ni][10] * (_ntotop / _ntotprod)
		_nDev    := _acustop[_nPosCus][5]
	
		aadd(_aprod, { _aze0[_ni][15],;   	    //01 Produto
						 _nPrcmin,; 			//02 Preco Minimo *
						 _nPrcmax,; 			//03 Preco Maximo  *
						 _ncuspro,; 			//04 Custo produção
						 _nfatura,; 			//05 Faturado
						 _nqtdfat,; 			//06 Qtde Faturada *
						 _aze0[_ni][10],; 		//07 Qtde Produzida  *******
						 _aze0[_ni][12],;		//08 Competencia
						 _ncusop,;				//09 Custo operacional
						  0,;					//10 Embalagens
						  0,;					//11 Frete
						  0,;					//12 Insumos
						  0,;					//13 Outros
						  0,;					//14 Leite mp
						  _aze0[_ni][9],;		//15 Descriçao do grupo do custo
						  (_atotprod[ascan( _atotprod,{|_vAux | _vAux[1] == alltrim(_aze0[_ni][8])})][2]),;//16 Total produzido do grupo
						  _aze0[_ni][19] ,;     //17 Centros de custos
						  _aze0[_ni][08] ,;     //18 Código do grupo de custo //AWF 03/05/17
						  _aze0[_ni][8]+PADR(_aze0[_ni][3],60)+PADR(_aze0[_ni][9],40) ,;//19 CHAVE para dar seek no ZL6//AWF 11/09/17
						  _nDev               })//20 Valor acumulado + devolucao /- transferencia do grupo//AWF 11/09/17
        
		
	Endif
	
	_ni++
	
Enddo


//atualiza custos proporcionais no array de produtos
For _ni := 1 to len(_aze0)

	If alltrim(_aze0[_ni][02]) == "000002"  // tipo de custo de produto acabado
			
		//Embalagens
		If alltrim(_aze0[_ni][16]) == "2"
		
			For _np := 1 to len(_aprod)
			
				If alltrim(_aprod[_np][15]) == alltrim(_aze0[_ni][09])
				
					_aprod[_np][10] += ( _aprod[_np][07] / _aprod[_np][16]) *  _aze0[_ni][11]
					
				Endif
				
			Next
			
		Endif
		
		//Frete
		If alltrim(_aze0[_ni][16]) == "3"
		
			For _np := 1 to len(_aprod)
			
				If alltrim(_aprod[_np][15]) == alltrim(_aze0[_ni][09])
				
					_aprod[_np][11] += ( _aprod[_np][07] /_aprod[_np][16] ) *  _aze0[_ni][11]
					
				Endif
				
			Next
			
		Endif
		
		//Insumos
		If alltrim(_aze0[_ni][16]) == "4"
		
			For _np := 1 to len(_aprod)
			
				If alltrim(_aprod[_np][15]) == alltrim(_aze0[_ni][09])
				
					_aprod[_np][12] += ( _aprod[_np][07] / _aprod[_np][16]) *  _aze0[_ni][11]
					
				Endif
				
			Next
			
		Endif
		
		//Outros
		If alltrim(_aze0[_ni][16]) == "5"
		
			For _np := 1 to len(_aprod)
			
				If alltrim(_aprod[_np][15]) == alltrim(_aze0[_ni][09])
				
					_aprod[_np][13] += ( _aprod[_np][07] / _aprod[_np][16]) *  _aze0[_ni][11]
					
				Endif
				
			Next
			
		Endif
		
		//Leite-MP
		If alltrim(_aze0[_ni][16]) == "7"
		
			For _np := 1 to len(_aprod)
			
				If alltrim(_aprod[_np][15]) == alltrim(_aze0[_ni][09])
				
					_aprod[_np][14] += ( _aprod[_np][07] / _aprod[_np][16]) *  _aze0[_ni][11]
					
				Endif
				
			Next
			
		Endif
		
	Endif
	
Next

_aQuebraProd:={}

_cQuery1:= " SELECT " 
_cQuery1+= " SUM(SD3.D3_QUANT) AS TOT " 
_cQuery1+= " FROM " + RetSqlName("SD3") + " SD3 "
_cQuery1+= " WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'"
_cQuery1+= " AND   SD3.D3_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
_cQuery1+= " AND   SD3.D3_CF IN ('PR0') "
_cQuery1+= " AND   SD3.D3_ESTORNO <> 'S' "
_cQuery1+= " AND   SD3.D_E_L_E_T_ = ' '	"

_nRegZL6:=LEN(_aprod)
_nContaZ:=0
_oself:SetRegua1( _nRegZL6 )
_cTotRegZL6:=ALLTRIM(STR(_nRegZL6))

FOR _ni := 1 TO LEN(_aprod)

	_nContaZ++
    IF VALTYPE(_oSelf) = "O" 
	   _oself:IncRegua1("3/4-Gravando dados: "+ALLTRIM(STR(_nContaZ,6))+" de "+_cTotRegZL6)
       ProcessMessages()
	ENDIF

	_aItem := STRTOKARR(alltrim(_aprod[_ni][01]), ';')
    nTotQtdeProd:=0
	IF LEN(_aItem) > 1 .AND. VALTYPE(_aItem) = "A"

       FOR _Pi := 1 TO len(_aItem)   
	       _cAlias := GetNextAlias()
	       _cQuery2:= " AND   SD3.D3_COD = '" + _aItem[_Pi] + "'"
	       IF !EMPTY(_aprod[_ni][17])
	          _cQuery2+= " AND   SD3.D3_CC IN " +  FormatIn(ALLTRIM(_aprod[_ni][17]),";") 
	       ENDIF   
//	       TcQuery (_cquery1+_cquery2) New Alias (_cAlias)
           MPSysOpenQuery( (_cquery1+_cquery2) , _cAlias ) 
           nQtdeProd:=(_cAlias)->TOT
           IF nQtdeProd # 0
		      _aRet := MEST009PMMTFQF(_aItem[_Pi])//Procura preço mínimo, preço máximo, total de faturamento e quantidade faturada
              nTotQtdeProd+=nQtdeProd//Soma só para conferir no debug se bate com o _aprod[_ni][07]
              AADD(_aQuebraProd,{alltrim(_aprod[_ni][01]),;//01-Grupo dos itens
                                              _aItem[_Pi],;//02-Item
                                                nQtdeProd,;//03-Qtde do item
                                          _aprod[_ni][07],;//04-total dos itens
                                                    _aRet})//05-Preço mínimo, Preço máximo, Total de Faturamento e Quantidade Faturada
           ENDIF                                               
       NEXT

	ELSE

       AADD(_aQuebraProd,{alltrim(_aprod[_ni][01]), _aItem[1], _aprod[_ni][07], _aprod[_ni][07], {0,0,0,0} })

	ENDIF

NEXT	
		
//grava ZE1

_nRegZL6:=LEN(_aQuebraProd)
_nContaZ:=0
_oself:SetRegua2( _nRegZL6 )
_cTotRegZL6:=ALLTRIM(STR(_nRegZL6))

dbselectarea("ZE1")
ZE1->( dbsetorder(1) )

FOR _Qba := 1 TO LEN(_aQuebraProd)

    IF VALTYPE(_oSelf) = "O" 
	   _oself:IncRegua2("4/4-Gravando dados: "+ALLTRIM(STR(_nContaZ,6))+" de "+_cTotRegZL6)
       ProcessMessages()
	ENDIF

   _nFator  := (_aQuebraProd[_Qba,3]/_aQuebraProd[_Qba,4])
   _nFator  := IF(_nFator<=0,1,_nFator)
   _aRet    := _aQuebraProd[_Qba,5]
   _nPrcmin := _aRet[1]//SD2T->PRCMIN
   _nPrcmax := _aRet[2]//SD2T->PRCMAX
   _nfatura := _aRet[3]//SD2T->FATUR
   _nqtdfat := _aRet[4]//SD2T->QTDE

   FOR _ni := 1 to len(_aprod)
  
      IF !(alltrim(_aprod[_ni][01]) == _aQuebraProd[_Qba,1])
         LOOP
      ENDIF
      _cSeek:=_aprod[_ni][19]//_aze0[_ni][8]+PADR(_aze0[_ni][3],60)+PADR(_aze0[_ni][9],40)

//    _nVIcmEst := Posicione("ZL6",8,xFilial("ZL6")+_cSeek+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_VICMSE")
//    _nVIcmInt := Posicione("ZL6",8,xFilial("ZL6")+_cSeek+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_VICMSI")
//    _nVIcmTrs := Posicione("ZL6",8,xFilial("ZL6")+_cSeek+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_VICMST")
//    _nDifAlq  := Posicione("ZL6",8,xFilial("ZL6")+_cSeek+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_DIFALQ")
//    _nVlrIcm  := _nVIcmEst + _nVIcmInt + _nVIcmTrs 

	  _nVlrIcm :=_nVIcmEst:=_nVIcmInt:=_nVIcmTrs:=_nDifAlq:=0//Variaveis antigas
      _nICMSEst:=_nICMSInt:=_nICMSTrs:=0//Variaveis novas valores preco medio
	  nDespEst := 0//Variaveis novas para calcular o percentual
	  nDespInt := 0//Variaveis novas para calcular o percentual
	  nDespTrs := 0//Variaveis novas para calcular o percentual
	  _cChave  :=_cChave1+"PRODUTOS ACABADOS PRODUZIDOS            "
	
	  MEST9ICMS("CARGA_VARIAVEIS_ICMS",_cChave)

      _cSegUni := Posicione("ZL6",8,xFilial("ZL6")+_cSeek+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_TUNID")
      _cEstAnt := Posicione("ZL6",8,xFilial("ZL6")+_cSeek+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_ESTANT")
      _cGrpCus := Posicione("ZL6",8,xFilial("ZL6")+_cSeek+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_GRPCUS")
      _cFilis  := Posicione("ZL6",8,xFilial("ZL6")+_cSeek+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_FILIS")
      _cLocais := Posicione("ZL6",8,xFilial("ZL6")+_cSeek+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_LOCAL")

	  _cproduto:= alltrim(_aprod[_ni][01])

	  _aTotItem:= MEST009SB9(alltrim(_cproduto),_cSegUni,_cEstAnt,_cGrpCus,.T.)	//valores de estoque anterior
	  IF (_nPos:=ASCAN(_aTotItem,{|I| I[1] == SUBSTR(alltrim(_aQuebraProd[_Qba,2]),1,11) } )) # 0
	      _nEstoqueAnterior:= _aTotItem[_nPos,2]
      ELSE
          _nEstoqueAnterior:= 0
	  ENDIF    
    
	_aven 		:= MEST009SD1(alltrim(_cproduto),2,_cSegUni)  	//valores de entradas em transferência
	_avdv 		:= MEST009SD1(alltrim(_cproduto),1,_cSegUni)  	//valores de entradas em devolução
	_aicst 		:= MEST009IST(alltrim(_cproduto))  		        //valores icms st
	_aExp 		:= MEST009EXP(alltrim(_cproduto),_cSegUni,_cLocais)  	//Quantidade expedida
	_aFret		:= MEST009FRT(alltrim(_cproduto),_aExp[1][1])          	//Valor Frete
	_nDev 		:= _aprod[_ni][20]//(_aprod[_ni][04] + _aval[1][2]) / (_aval[1][1] + _aprod[_ni][16])  //Valor real de devolução
	_aTotItem	:= MEST9BscSB2(_cproduto,.T.)

	IF _nICMSEst > 0 .AND. nDespEst > 0
		_nVIcmEst:=(_nVIcmEst*_aExp[1][2])
	ENDIF
	IF _nICMSInt > 0 .AND. nDespInt > 0
		_nVIcmInt:=(_nVIcmInt*_aExp[1][3])
	ENDIF
	IF _nICMSTrs > 0 .AND. nDespTrs > 0
		_nVIcmTrs:=(_nVIcmTrs*_aExp[1][4])
	ENDIF
	_nVlrIcm := _nVIcmEst + _nVIcmInt + _nVIcmTrs

	IF (_nPos:=ASCAN(_aTotItem,{|I| I[1] == SUBSTR(alltrim(_aQuebraProd[_Qba,2]),1,11) } )) # 0
	    _nSaldoAtual:= _aTotItem[_nPos,2]
	    _nValorAtual:= (_nSaldoAtual*_nDev) //* _nFator
    ELSE
        _nSaldoAtual:= 0
	    _nValorAtual:= 0
	ENDIF

	_cfiltro :=  xfilial("ZE1") + substr(dtos(MV_PAR05),5,2) +  substr(dtos(MV_PAR05),1,4) + space(4) + SUBSTR(alltrim(_aQuebraProd[_Qba,2]),1,11)   //_aprod[_ni][01]
		
	If ZE1->( Dbseek( _cfiltro ) )


		//========================================================
		//Achou registro so atualiza quantidade e valor
		//========================================================
		RecLock("ZE1",.F.)
		
		ZE1->ZE1_PRCMIN		:= IF(_nPrcmin#0,_nPrcmin,_aprod[_ni][02])
		ZE1->ZE1_PRCMAX		:= IF(_nPrcmax#0,_nPrcmax,_aprod[_ni][03])
		ZE1->ZE1_CUSTOP		:= (_aprod[_ni][04]*_nFator)
		ZE1->ZE1_FATURA		:= IF(_nFatura#0,_nFatura,_aprod[_ni][05])
		ZE1->ZE1_QTDFAT		:= IF(_nqtdfat#0,_nqtdfat,_aprod[_ni][06])
		ZE1->ZE1_QTDPRO		:= _aQuebraProd[_Qba,3] //_aprod[_ni][07]
		ZE1->ZE1_CUSTOO		:= (_aprod[_ni][09]*_nFator)
		ZE1->ZE1_CUSTOE		:= (_aprod[_ni][10]*_nFator)
		ZE1->ZE1_CUSTOF		:= (_aFret[1][1]*_nFator)
		ZE1->ZE1_CUSTOI		:= (_aprod[_ni][12]*_nFator)
		ZE1->ZE1_CUSTOU		:= (_aprod[_ni][13]*_nFator)
		ZE1->ZE1_CUSTOL		:= (_aprod[_ni][14]*_nFator)
		ZE1->ZE1_ESTA		:= _nEstoqueAnterior//(_aval[1][2]*_nFator)
		ZE1->ZE1_ENTRA		:= (_aven[1][2]*_nFator)
		ZE1->ZE1_ENDEV		:= (_avdv[1][2]*_nFator)
		ZE1->ZE1_ICMS		:= (_nVlrIcm*_nFator)//_aicms[1][1]
		ZE1->ZE1_ICST		:= (_aicst[1][1] *_nFator)
		ZE1->ZE1_EXPE		:= (_aExp[1][1] *_nFator)
		ZE1->ZE1_DIFALQ		:= (_nDifAlq*_nFator)
		ZE1->ZE1_ESTATU		:= _nSaldoAtual//(_nSldAtu*_nFator)
		ZE1->ZE1_VESTAT		:= _nValorAtual
			
	Else
	
		//========================================================
		//Nao achou registro cria um novo
		//========================================================
			                     	
		RecLock("ZE1",.T.)    
		
		ZE1->ZE1_FILIAL		:= xfilial("SD2")	
		ZE1->ZE1_PRODUT		:= _aQuebraProd[_Qba,2]  //SUBSTR(alltrim(_aprod[_ni][01]),1,11)	
		ZE1->ZE1_PRCMIN		:= IF(_nPrcmin#0,_nPrcmin,_aprod[_ni][02])
		ZE1->ZE1_PRCMAX		:= IF(_nPrcmax#0,_nPrcmax,_aprod[_ni][03])
		ZE1->ZE1_CUSTOP		:= (_aprod[_ni][04]*_nFator)
		ZE1->ZE1_FATURA		:= IF(_nFatura#0,_nFatura,_aprod[_ni][05])
		ZE1->ZE1_QTDFAT		:= IF(_nqtdfat#0,_nqtdfat,_aprod[_ni][06])
		ZE1->ZE1_QTDPRO		:= _aQuebraProd[_Qba,3] //_aprod[_ni][07]
		ZE1->ZE1_CUSTOO		:= (_aprod[_ni][09]*_nFator)
	   	ZE1->ZE1_COMP		:= _aprod[_ni][08]
	   	ZE1->ZE1_CUSTOE		:= (_aprod[_ni][10]*_nFator)
		ZE1->ZE1_CUSTOF		:= (_aFret[1][1]*_nFator)
		ZE1->ZE1_CUSTOI		:= (_aprod[_ni][12]*_nFator)
		ZE1->ZE1_CUSTOU		:= (_aprod[_ni][13]*_nFator)
		ZE1->ZE1_CUSTOL		:= (_aprod[_ni][14]*_nFator)
		ZE1->ZE1_ESTA		:= _nEstoqueAnterior//(_aval[1][2]*_nFator)
		ZE1->ZE1_ENTRA		:= (_aven[1][2]*_nFator)
		ZE1->ZE1_ENDEV		:= (_avdv[1][2]*_nFator)
		ZE1->ZE1_ICMS		:= (_nVlrIcm*_nFator)//_aicms[1][1]
		ZE1->ZE1_ICST		:= (_aicst[1][1]*_nFator)
		ZE1->ZE1_EXPE		:= (_aExp[1][1]*_nFator)
		ZE1->ZE1_DIFALQ		:= (_nDifAlq*_nFator)
		ZE1->ZE1_ESTATU		:= _nSaldoAtual//(_nSldAtu*_nFator)
		ZE1->ZE1_VESTAT		:= _nValorAtual
		
	Endif
	
	_cCodGrupo       	:= Posicione("SB1",1,xFilial("SB1")+ZE1->ZE1_PRODUT,"B1_GRUPO")
	ZE1->ZE1_GRUPO		:= Posicione("SBM",1,XFILIAL("SBM")+_cCodGrupo     ,"BM_DESC")//Descrição do grupo do produto   
	IF ZE1->(FIELDPOS("ZE1_GRPCT")) # 0
	   ZE1->ZE1_GRPCT   := _aprod[_ni][18]//Código do grupo do custo    ZE0->ZE0_GRPCT :=_aze0[_ni][8]
	   ZE1->ZE1_DRGPCT  := _aprod[_ni][15]//Descriçao do grupo do custo ZE0->ZE0_DGRPCT:=_aze0[_ni][9]
	ENDIF
	
	ZE1->(MsUnlock())       
			
   NEXT	

Next
/*
_oself:SaveLog( "FINALIZOU COM SUCESSO - GERANDO DADOS DE CUSTO GERENCIAL" )
_oself:SaveLog( "DATA - " + dtoc(date()) + " - " + time())
*/

U_ITMSG("Dados atualizados com sucesso para período " + SUBSTR(DTOS(MV_PAR05),5,2) + "/" +  SUBSTR(DTOS(MV_PAR05),1,4) + ".", "Atualizacao Dados",,2) 

Return .T.

/*
===============================================================================================================================
Programa----------: MEST009P
Autor-------------: Josue Danich Prestes
Data da Criacao---: 31/10/2014
Descricao---------: Relatorio de custos gerenciais
Parametros--------:
Retorno-----------:
===============================================================================================================================
*/
Static Function MEST009P()

Private oReport
lPrim 	:= .F.

oReport := MEST009RP()
oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: MEST009RP
Autor-------------: Josue Danich Prestes
Data da Criacao---: 31/10/2014
Descricao---------: Gera planilha de custos
Parametros--------:
Retorno-----------: oReport - objeto de impressao
===============================================================================================================================
*/
Static Function MEST009RP()

Local oSection1
Local oBreak1

If MV_PAR08 == 1

	cDescTp := "Sintetico"

Else

	cDescTp := "Analitico"

Endif

oReport:= TReport():New("Planilha de Custos (MEST009)","Planilha de Custos - "+cDescTp,"MEST009",{|oReport| MEST009I(oReport) },"Impressao da Planilha de Custos gerado atraves da rotina MEST009")
oReport:SetLandScape()
oReport:SetTotalInLine(.F.)
oReport:ParamReadOnly(.T.)

//===================================
//Definicao das secoes do relatorio |
//===================================

oSection1 := TRSection():New(oReport, "Custos",{"ZL6","SD1","SD3","SE5","SE2"})

//======================================
//Definicao das celulas para impressao |
//======================================
dbSelectArea("SX3")
dbSetOrder(2)

SX3->( dbSeek("ZL6_DTPCUS") )
TRCell():New(oSection1,"ZL6_DTPCUS","ZL6",X3TITULO(),,TamSX3("ZL6_DTPCUS")[1]+2)
SX3->( dbSeek("ZL6_DGRCUS") )
TRCell():New(oSection1,"ZL6_DGRCUS","ZL6",X3TITULO(),,TamSX3("ZL6_DGRCUS")[1]+2)
SX3->( dbSeek("ZL6_DESEVE") )
TRCell():New(oSection1,"ZL6_DESEVE","ZL6",X3TITULO(),,TamSX3("ZL6_DESEVE")[1]+2)
SX3->( dbSeek("ZL6_DSUBEV") )
TRCell():New(oSection1,"ZL6_DSUBEV","ZL6",X3TITULO(),,TamSX3("ZL6_DSUBEV")[1]+2)

If MV_PAR08 == 2	//Analitico

	SX3->( dbSeek("D1_COD") )
	TRCell():New(oSection1,"PRODCOD","ZL6",X3TITULO(),,TamSX3("D1_COD")[1]+1)
	SX3->( dbSeek("D1_I_DESC") )
	TRCell():New(oSection1,"PRODDESC","ZL6",X3TITULO(),,TamSX3("D1_I_DESC")[1]+1)

	TRCell():New(oSection1,"CODFORN","ZL6","Cod Forn/Clente",,10)

	TRCell():New(oSection1,"DESFORN","ZL6","Nome",,100)

	SX3->( dbSeek("D1_CF") )
	TRCell():New(oSection1,"CFOP","ZL6",X3TITULO(),,TamSX3("D1_CF")[1]+1)

Endif

SX3->( dbSeek("D1_QUANT") ) 
TRCell():New(oSection1,"QUANT","SD1",X3TITULO(),,TamSX3("D1_QUANT")[1]+2)
SX3->( dbSeek("D1_TOTAL") )
TRCell():New(oSection1,"VALOR","SD1",X3TITULO(),,TamSX3("D1_TOTAL")[1]+2)

If MV_PAR08 == 2	//Analitico

	SX3->( dbSeek("D1_DOC") )
	TRCell():New(oSection1,"DOC","SD1",X3TITULO(),,TamSX3("D1_DOC")[1]+2)
	SX3->( dbSeek("D1_CC") )
	TRCell():New(oSection1,"CCUSTO","SD1",X3TITULO(),,TamSX3("D1_CC")[1]+2)
	SX3->( dbSeek("E5_NATUREZ") )
	TRCell():New(oSection1,"NATUREZA","SD1",X3TITULO(),,TamSX3("E5_NATUREZ")[1]+2)
	SX3->( dbSeek("E5_DATA") )
	TRCell():New(oSection1,"DATA","SE5",X3TITULO(),,TamSX3("E5_DATA")[1]+2)
	SX3->( dbSeek("D1_EMISSAO") )
	TRCell():New(oSection1,"EMISSAO","SD1",X3TITULO(),,TamSX3("D1_EMISSAO")[1]+2)
	SX3->( dbSeek("D1_DTDIGIT") )
	TRCell():New(oSection1,"DTDIGIT","SD1",X3TITULO(),,TamSX3("D1_DTDIGIT")[1]+2)
	TRCell():New(oSection1,"TES","SD1","TES",,TamSX3("D1_TES")[1]+2)
	SX3->( dbSeek("D1_NUMSEQ") )
	TRCell():New(oSection1,"NUMSEQ","SD1",X3TITULO(),,TamSX3("D1_NUMSEQ")[1]+2)
	TRCell():New(oSection1,"USUARIO","SD1","Usuario",,30)
	SX3->( dbSeek("RD_MAT") )
	TRCell():New(oSection1,"MAT","SRC",X3TITULO(),,TamSX3("RD_MAT")[1]+2)
	SX3->( dbSeek("RD_PD") )
	TRCell():New(oSection1,"PD","SRC",X3TITULO(),,TamSX3("RD_PD")[1]+2)
	SX3->( dbSeek("RD_TIPO1") )
	TRCell():New(oSection1,"TIPO1","SRC",X3TITULO(),,TamSX3("RD_TIPO1")[1]+2)
	SX3->( dbSeek("E2_FILIAL") )
	TRCell():New(oSection1,"FILIAL","SE2",X3TITULO(),,TamSX3("E2_FILIAL")[1]+2)
	SX3->( dbSeek("D3_I_OBS") )
	TRCell():New(oSection1,"OBS","SD3",X3TITULO(),,TamSX3("D3_I_OBS")[1]+2)

	
		
	oBreak1 := TRBreak():New(oSection1, oSection1:Cell("ZL6_DSUBEV")    ,"Total Sub Ev",.F.,"")
	TRFunction():New(oSection1:Cell("VALOR")  ,"","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("QUANT")  ,"","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T.)

Endif

oSection1:SetTotalInLine(.F.)

Return oReport

/*
===============================================================================================================================
Programa----------: MEST009I
Autor-------------: Josue Danich Prestes
Data da Criacao---: 31/10/2014
Descricao---------: Gera planilha de custos
Parametros--------: oReport - objeto de impressao
Retorno-----------:
===============================================================================================================================
*/
Static Function MEST009I(oReport)

Local oSection1 	:= oReport:Section(1)
Local _nVlrSin		:= 0
Local _nQtdSin		:= 0
Local _lErro		:= .F.
Local cProdDesc 	:= ""
Local _cUsuario 	:= ""
Local cCodUser	:= ""

oSection1:Init()
oReport:SetMeter(10)
oReport:IncMeter()


While ZL6T->(!EOF())

		_lErro := .F.
	
	
		//==================================================
		//Roda engine de dados de custo gerencial
		//==================================================
		//MV_PAR01 - Tipo Grupo
		//MV_PAR02 - Grupo Custo
		//MV_PAR05 - Data inicial
		//MV_PAR06 - Data Final
		// Ultimo parâmetro indica que e a segunda etapa de leitura de varias tabelas com regras da ZL6 lida na primeira etapa
        oReport:IncMeter()
		_aretorno := U_MEST009E(MV_PAR01,MV_PAR02,MV_PAR05,MV_PAR06,2,)
        IF _lLoop
           RETURN .F.
        ENDIF
	
	    oReport:SetMeter(10)
	    IF SELECT("TRB") # 0
		   TRB->( dbgotop() )
		   oReport:SetMeter(("TRB")->(RecCount()))
		   dbSelectArea("TRB")
		   TRB->( dbgotop() )
		ENDIF	
		
		_nQtdSin 	:= _aretorno[1]
		_nVlrSin 	:= _aretorno[2]	
		
		While SELECT("TRB") # 0 .AND. TRB->(!Eof()) .and. MV_PAR08 == 2	//Analitico
		
			oReport:IncMeter()
			If ZL6T->ZL6_QTD == "2"
	
				_nmul := -1
	
			Else 
		
				_nmul := 1
	
			Endif
	
			oSection1:Cell("ZL6_DGRCUS"):SetValue(ALLTRIM(ZL6T->ZL6_DGRCUS))
			oSection1:Cell("ZL6_DTPCUS"):SetValue(ALLTRIM(ZL6T->ZL6_DTPCUS))
			oSection1:Cell("ZL6_DESEVE"):SetValue(ALLTRIM(ZL6T->ZL6_DESEVE))
			oSection1:Cell("ZL6_DSUBEV"):SetValue(ALLTRIM(ZL6T->ZL6_DSUBEV))

			If ZL6T->ZL6_OBSERV == "1" //*
	
				oSection1:Cell("PRODCOD")	:SetValue(TRB->D1_COD)
					
				cPrdDesc := Posicione("SB1",1,xFilial("SB1")+TRB->D1_COD,"B1_DESC")
					
				oSection1:Cell("FILIAL")	:SetValue(TRB->D1_FILIAL)
				oSection1:Cell("PRODDESC")	:SetValue(cPrdDesc)

				oSection1:Cell("CODFORN")	:SetValue(TRB->F1_FORNECE)
				oSection1:Cell("DESFORN")	:SetValue(Posicione("SA2",1,xFilial("SA2")+TRB->F1_FORNECE,"A2_NOME"))

				oSection1:Cell("CFOP")		:SetValue(TRB->D1_CF)
				oSection1:Cell("QUANT")		:SetValue(TRB->D1_QUANT * _nmul)
				oSection1:Cell("VALOR")		:SetValue(TRB->D1_TOTAL * _nmul)
				oSection1:Cell("DOC")		:SetValue(ALLTRIM(TRB->D1_DOC))
				oSection1:Cell("CCUSTO")	:SetValue(Posicione("CTT",1,xFilial("CTT")+TRB->D1_CC,"CTT_DESC01"))
				oSection1:Cell("NATUREZA")	:SetValue("")
				oSection1:Cell("EMISSAO")	:SetValue(STOD(TRB->D1_EMISSAO))
				oSection1:Cell("DTDIGIT")	:SetValue(STOD(TRB->D1_DTDIGIT))
				oSection1:Cell("TES")		:SetValue(ALLTRIM(TRB->D1_TES))
				oSection1:Cell("NUMSEQ")	:SetValue(ALLTRIM(TRB->D1_NUMSEQ))
						
				If (!EMPTY(TRB->F1_USERLGI) .and. !EMPTY(TRB->F1_USERLGA));
						 .or. (EMPTY(TRB->F1_USERLGI) .and. !EMPTY(TRB->F1_USERLGA))
					
					cCodUser := ""
					cCodUser := Subs(Embaralha(TRB->F1_USERLGA, 1), 3, 6)
					PswOrder(1)     // Busca por ID
						
					If PSWSEEK( cCodUser, .T. )
					
						aUser := PSWRET() // Retorna vetor com informacoes do usuario
						oSection1:Cell("USUARIO"):SetValue(aUser[1,2])
						
					Else
					
						oSection1:Cell("USUARIO"):SetValue("N/C")
					
					EndIf
						
					
				ElseIf !EMPTY(TRB->F1_USERLGI) .and. EMPTY(TRB->F1_USERLGA)
					
					cCodUser := ""
					cCodUser := Subs(Embaralha(TRB->F1_USERLGI, 1), 3, 6)
					PswOrder(1)     // Busca por ID
						
					If PSWSEEK( cCodUser, .T. )
					
						aUser := PSWRET() // Retorna vetor com informacoes do usuario
						oSection1:Cell("USUARIO"):SetValue(aUser[1,2])
					
					Else
					
						oSection1:Cell("USUARIO"):SetValue("N/C")
					
					EndIf
						
					
				Endif
					
				oSection1:Cell("MAT")	:SetValue("")
				oSection1:Cell("PD")	:SetValue("")
				oSection1:Cell("TIPO1")	:SetValue("")
				oSection1:Cell("OBS")	:SetValue("")
						
			ElseIf ZL6T->ZL6_OBSERV == "2" 
					
					oSection1:Cell("PRODCOD"):SetValue(TRB->D2_COD)
					
					cPrdDesc := Posicione("SB1",1,xFilial("SB1")+TRB->D2_COD,"B1_DESC")
					
					oSection1:Cell("PRODDESC")	:SetValue(cPrdDesc)
					oSection1:Cell("CFOP")		:SetValue(TRB->D2_CF)
					oSection1:Cell("QUANT")		:SetValue(TRB->D2_QUANT * _nmul)
					If ZL6T->ZL6_D2FRET == 'S'
						oSection1:Cell("VALOR")		:SetValue(TRB->D2_I_FRET * _nmul)
					Else
						oSection1:Cell("VALOR")		:SetValue(TRB->D2_TOTAL * _nmul)
					Endif		
					oSection1:Cell("DOC")		:SetValue(ALLTRIM(TRB->D2_DOC))
					oSection1:Cell("CCUSTO")	:SetValue("")
					oSection1:Cell("NATUREZA")	:SetValue("")
					oSection1:Cell("EMISSAO")	:SetValue(STOD(TRB->D2_EMISSAO))
					oSection1:Cell("DTDIGIT")	:SetValue(STOD(""))
					oSection1:Cell("TES")		:SetValue(ALLTRIM(TRB->D2_TES))
					oSection1:Cell("NUMSEQ")	:SetValue(ALLTRIM(TRB->D2_NUMSEQ))
					oSection1:Cell("MAT")		:SetValue("")
					oSection1:Cell("PD")		:SetValue("")
					oSection1:Cell("TIPO1")		:SetValue("")
					oSection1:Cell("OBS")		:SetValue("")					
			
			Elseif ZL6T->ZL6_OBSERV == "3"
	
				oSection1:Cell("PRODCOD")	:SetValue(TRB->D3_COD)
					
				cPrdDesc := Posicione("SB1",1,xFilial("SB1")+TRB->D3_COD,"B1_DESC")
					
				oSection1:Cell("FILIAL")	:SetValue(TRB->D3_FILIAL)
				oSection1:Cell("PRODDESC")	:SetValue(cPrdDesc)
				oSection1:Cell("CFOP")		:SetValue(TRB->D3_CF)
				oSection1:Cell("QUANT")		:SetValue(TRB->QUANT * _nmul)
				oSection1:Cell("VALOR")		:SetValue(TRB->D3_CUSTO1 * _nmul)
				oSection1:Cell("DOC")		:SetValue(ALLTRIM(TRB->D3_DOC))
				oSection1:Cell("CCUSTO")	:SetValue(Posicione("CTT",1,xFilial("CTT")+TRB->D3_CC,"CTT_DESC01"))
				oSection1:Cell("NATUREZA")	:SetValue("")
				oSection1:Cell("EMISSAO")	:SetValue(STOD(TRB->D3_EMISSAO))
				oSection1:Cell("DTDIGIT")	:SetValue(STOD(""))
				oSection1:Cell("TES")		:SetValue(ALLTRIM(TRB->D3_TM))
				oSection1:Cell("NUMSEQ")	:SetValue(ALLTRIM(TRB->D3_NUMSEQ))
				oSection1:Cell("USUARIO")	:SetValue(TRB->D3_USUARIO)
				oSection1:Cell("MAT")		:SetValue("")
				oSection1:Cell("PD")		:SetValue("")
				oSection1:Cell("TIPO1")		:SetValue("")
				oSection1:Cell("OBS")		:SetValue(TRB->D3_I_OBS)
					
			Elseif ZL6T->ZL6_OBSERV == "4"//4
				
				If ZL6T->ZL6_TXFIN == "S" .and. !ZL6T->ZL6_RPA $ '1,2,3'
					oSection1:Cell("FILIAL")	:SetValue(TRB->E2_FILIAL)
				Elseif ZL6T->ZL6_RPA == "1" 	//RPA
					oSection1:Cell("FILIAL")	:SetValue(TRB->ZZ2_FILIAL)
				Elseif ZL6T->ZL6_RPA == "2" 	//CAIXINHA
					oSection1:Cell("FILIAL")	:SetValue(TRB->EU_FILIAL)
				Elseif ZL6T->ZL6_RPA == "3" 	//COMISSAO
					oSection1:Cell("FILIAL")	:SetValue(TRB->E3_FILIAL)
				Else//NENHUM
					oSection1:Cell("FILIAL")	:SetValue(TRB->E5_FILIAL)	
				Endif	

				If ZL6T->ZL6_RPA = "2" //CAIXINHA
				   oSection1:Cell("CODFORN")	:SetValue("")
				   oSection1:Cell("DESFORN")	:SetValue(TRB->FORNEC)
				ElseIf ZL6T->ZL6_RPA = "3" //COMISSAO
				   oSection1:Cell("CODFORN")	:SetValue(TRB->E3_VEND)
				   oSection1:Cell("DESFORN")	:SetValue(TRB->A3_NOME)
				ELSE
				   oSection1:Cell("CODFORN")	:SetValue(TRB->FORNEC)
				   oSection1:Cell("DESFORN")	:SetValue(Posicione("SA2",1,xFilial("SA2")+TRB->FORNEC,"A2_NOME"))
				ENDIF

				oSection1:Cell("PRODCOD")		:SetValue("")
				oSection1:Cell("PRODDESC")		:SetValue("")
				oSection1:Cell("CFOP")			:SetValue("")
				oSection1:Cell("QUANT")			:SetValue("")
				oSection1:Cell("VALOR")			:SetValue(TRB->VALOR * _nmul)
				If !ZL6T->ZL6_RPA $ '1,2,3'
					oSection1:Cell("DOC")		:SetValue(ALLTRIM(TRB->E5_NUMERO))
				ElseIf ZL6T->ZL6_RPA ="1"
					oSection1:Cell("DOC")		:SetValue(ALLTRIM(TRB->ZZ2_RECIBO))
				ElseIf ZL6T->ZL6_RPA ="2"
					oSection1:Cell("DOC")		:SetValue(ALLTRIM(TRB->EU_NRCOMP))
				ElseIf ZL6T->ZL6_RPA ="3"
					oSection1:Cell("DOC")		:SetValue(ALLTRIM(TRB->E3_NUM))
				Endif		
				oSection1:Cell("CCUSTO")		:SetValue("")
				If !ZL6T->ZL6_RPA $ '1,2,3' 
					oSection1:Cell("NATUREZA")	:SetValue(TRB->E5_NATUREZ)
				Endif	
				If !ZL6T->ZL6_RPA $ '1,2,3'
					oSection1:Cell("EMISSAO")	:SetValue(STOD(TRB->E5_DATA))
				ElseIf ZL6T->ZL6_RPA ="1"
					oSection1:Cell("EMISSAO")	:SetValue(STOD(TRB->ZZ2_DATA))
				ElseIf ZL6T->ZL6_RPA ="2"
					oSection1:Cell("EMISSAO")	:SetValue(STOD(TRB->EU_DTDIGIT))
				ElseIf ZL6T->ZL6_RPA ="3"
					oSection1:Cell("EMISSAO")	:SetValue(STOD(TRB->E3_EMISSAO))
				Endif		
				oSection1:Cell("DTDIGIT")		:SetValue(STOD(""))
				oSection1:Cell("TES")			:SetValue("")
				oSection1:Cell("NUMSEQ")		:SetValue("")
					
				oSection1:Cell("MAT")	:SetValue("")
				oSection1:Cell("PD")	:SetValue("")           	
				oSection1:Cell("TIPO1")	:SetValue("")
				If !ZL6T->ZL6_RPA $ '1,2,3' .and. ZL6T->ZL6_TXFIN <> 'S'
					oSection1:Cell("OBS")	:SetValue(TRB->E5_HISTOR)
				ElseIf ZL6T->ZL6_RPA ="2"
					oSection1:Cell("OBS")	:SetValue(TRB->EU_HISTOR)
				Else	
					oSection1:Cell("OBS")	:SetValue("")
				Endif	
					
			Elseif ZL6T->ZL6_OBSERV == "5" 
				
				oSection1:Cell("FILIAL")	:SetValue(TRB->BC_FILIAL)
				oSection1:Cell("PRODCOD")	:SetValue(TRB->BC_PRODUTO)
				oSection1:Cell("PRODDESC")	:SetValue(TRB->BC_I_NPROD)
				oSection1:Cell("CFOP")		:SetValue("")
				oSection1:Cell("QUANT")		:SetValue(TRB->BC_QUANT * _nmul)
				oSection1:Cell("VALOR")		:SetValue(TRB->BC_I_CUSTO * _nmul)
				oSection1:Cell("DOC")		:SetValue(TRB->BC_OP)
				oSection1:Cell("CCUSTO")	:SetValue(Posicione("CTT",1,xFilial("CTT")+TRB->BC_CC,"CTT_DESC01"))
				oSection1:Cell("NATUREZA")	:SetValue("")
				oSection1:Cell("EMISSAO")	:SetValue(STOD(TRB->BC_DATA))
				oSection1:Cell("DTDIGIT")	:SetValue(STOD(""))
				oSection1:Cell("TES")		:SetValue("")
				oSection1:Cell("NUMSEQ")	:SetValue(TRB->BC_NUMSEQ)
				oSection1:Cell("USUARIO")	:SetValue("")
				oSection1:Cell("MAT")		:SetValue("")
				oSection1:Cell("PD")		:SetValue("")
				oSection1:Cell("TIPO1")		:SetValue("")
				oSection1:Cell("OBS")		:SetValue("")						
			
			Elseif ZL6T->ZL6_OBSERV == "6" 
				
				
				oSection1:Cell("FILIAL")	:SetValue(ZL6T->ZL6_FILIS)
				oSection1:Cell("PRODCOD")	:SetValue("")
				oSection1:Cell("PRODDESC")	:SetValue("")
				oSection1:Cell("CFOP")		:SetValue("")
				
				oSection1:Cell("QUANT")	:SetValue(0)
						
				oSection1:Cell("VALOR")		:SetValue(TRB->TOTAL_GERAL * _nmul)
				oSection1:Cell("DOC")		:SetValue("")
				oSection1:Cell("CCUSTO")	:SetValue("")
				oSection1:Cell("NATUREZA")	:SetValue("")
				oSection1:Cell("EMISSAO")	:SetValue(STOD(""))
				oSection1:Cell("DTDIGIT")	:SetValue(STOD(""))
				oSection1:Cell("TES")		:SetValue("")
				oSection1:Cell("NUMSEQ")	:SetValue("")
				oSection1:Cell("USUARIO")	:SetValue("")
				oSection1:Cell("MAT")		:SetValue("")
				oSection1:Cell("PD")		:SetValue("")
				oSection1:Cell("TIPO1")		:SetValue("")
				oSection1:Cell("OBS")		:SetValue("")										
			
			Elseif ZL6T->ZL6_OBSERV == "7" 
				
				oSection1:Cell("FILIAL")	:SetValue(ZL6T->ZL6_FILIS)
				oSection1:Cell("PRODCOD")	:SetValue("")
				oSection1:Cell("PRODDESC")	:SetValue("")
				oSection1:Cell("CFOP")		:SetValue("")
				                                                      
				oSection1:Cell("QUANT")	:SetValue(TRB->RD_HORAS * _nmul)
						
				oSection1:Cell("VALOR")		:SetValue(TRB->RD_VALOR * _nmul)
				oSection1:Cell("DOC")		:SetValue("")
				oSection1:Cell("CCUSTO")	:SetValue("")
				oSection1:Cell("NATUREZA")	:SetValue("")
				oSection1:Cell("EMISSAO")	:SetValue(STOD(""))
				oSection1:Cell("DTDIGIT")	:SetValue(STOD(""))
				oSection1:Cell("TES")		:SetValue("")
				oSection1:Cell("NUMSEQ")	:SetValue("")
				oSection1:Cell("USUARIO")	:SetValue("")
				oSection1:Cell("MAT")		:SetValue("")
				oSection1:Cell("PD")		:SetValue("")
				oSection1:Cell("TIPO1")		:SetValue("")
				oSection1:Cell("OBS")		:SetValue("")										
						
			Elseif ZL6T->ZL6_OBSERV == "8" 
			
				oSection1:Cell("FILIAL")	:SetValue(TRB->B9_FILIAL)
				oSection1:Cell("PRODCOD")	:SetValue(TRB->B9_COD)
				oSection1:Cell("PRODDESC")	:SetValue(posicione("SB1",1,xFilial("SB1")+TRB->B9_COD,"B1_DESC"))
				oSection1:Cell("CFOP")		:SetValue("")
				
				oSection1:Cell("QUANT")	:SetValue(TRB->B9_QINI * _nmul)
						
				oSection1:Cell("VALOR")		:SetValue(TRB->B9_VINI1 * _nmul)
				oSection1:Cell("DOC")		:SetValue("")
				oSection1:Cell("CCUSTO")		:SetValue("")
				oSection1:Cell("NATUREZA")	:SetValue("")
				oSection1:Cell("EMISSAO")	:SetValue(STOD(""))
				oSection1:Cell("DTDIGIT")	:SetValue(STOD(""))
				oSection1:Cell("TES")		:SetValue("")
				oSection1:Cell("NUMSEQ")		:SetValue("")
				oSection1:Cell("USUARIO")	:SetValue("")
				oSection1:Cell("MAT")		:SetValue("")
				oSection1:Cell("PD")			:SetValue("")
				oSection1:Cell("TIPO1")		:SetValue("")
				oSection1:Cell("OBS")		:SetValue("")										
				
		
			Elseif ZL6T->ZL6_OBSERV == "9" 
			
				If ZL6T->ZL6_TERCEI = "S"
					oSection1:Cell("PRODCOD")	:SetValue("")
				Else	
					oSection1:Cell("PRODCOD")	:SetValue(TRB->ZLF_A2COD)
				Endif
				If ZL6T->ZL6_TERCEI = "S"
					oSection1:Cell("PRODDESC")	:SetValue("")
				Else	
					oSection1:Cell("PRODDESC")	:SetValue(posicione("SA2",1,xFilial("SA2")+TRB->ZLF_A2COD,"A2_NOME"))
				Endif	
				oSection1:Cell("CFOP")		:SetValue("")
				
				oSection1:Cell("QUANT")	:SetValue(TRB->QUANT * _nmul)
						
				oSection1:Cell("VALOR")		:SetValue((TRB->CREDITO - TRB->DEBITO) * _nmul)
				oSection1:Cell("DOC")		:SetValue("")
				oSection1:Cell("CCUSTO")		:SetValue("")
				oSection1:Cell("NATUREZA")	:SetValue("")
				oSection1:Cell("EMISSAO")	:SetValue(STOD(""))
				oSection1:Cell("DTDIGIT")	:SetValue(STOD(""))
				oSection1:Cell("TES")		:SetValue("")
				oSection1:Cell("NUMSEQ")		:SetValue("")
				oSection1:Cell("USUARIO")	:SetValue("")
				oSection1:Cell("MAT")		:SetValue("")
				oSection1:Cell("PD")			:SetValue("")
				oSection1:Cell("TIPO1")		:SetValue("")                       
				oSection1:Cell("OBS")		:SetValue("")										
	
			Endif
				
			oSection1:PrintLine()				
			
			cProdDesc := ""
			_cUsuario := ""
			
			If oReport:Cancel()
			
				Exit
				
			EndIf
			
			TRB->(dbSkip())
			
		End

		If ( MV_PAR08 == 1 .and. !_lErro ) .OR. ( ZL6T->ZL6_OBSERV $ "A,B,C,D" )
			
			oSection1:Cell("ZL6_DGRCUS"):SetValue(ALLTRIM(ZL6T->ZL6_DGRCUS))
			oSection1:Cell("ZL6_DTPCUS"):SetValue(ALLTRIM(ZL6T->ZL6_DTPCUS))
			oSection1:Cell("ZL6_DESEVE"):SetValue(ALLTRIM(ZL6T->ZL6_DESEVE))
			oSection1:Cell("ZL6_DSUBEV"):SetValue(ALLTRIM(ZL6T->ZL6_DSUBEV))
			
			If ZL6T->ZL6_OBSERV <> "4" 
			
				oSection1:Cell("QUANT")	:SetValue(_nQtdSin)
			
			Else
			
				oSection1:Cell("QUANT")	:SetValue(0)
			
			Endif
			
			oSection1:Cell("VALOR")	:SetValue(_nVlrSin)
			
			oSection1:PrintLine()
			oReport:IncMeter()
			
	    Endif
		 
	_nVlrSin := 0
	_nQtdSin := 0
		
    IF SELECT("TRB") # 0
  	   TRB->(dbCloseArea())
	ENDIF	
	
	If oReport:Cancel()
	   Exit
	EndIf
	
	ZL6T->(dbSkip())

End

oSection1:Finish()
ZL6T->(dbCloseArea())

Return .T.

/*
===============================================================================================================================
Programa----------: MEST009K
Autor-------------: Josue Danich Prestes
Data da Criacao---: 06/11/2015
Descricao---------: Realiza validacao das Datas
Parametros--------: Nenhum
Retorno-----------: .T. se validou ou .F. se encontrou data invalida
===============================================================================================================================
*/

Static Function MEST009K(oTProcess)

Local _lRet := .T.

If MV_PAR05 > MV_PAR06
	
	U_ITMSG("'Emissao De' maior que 'Emissao Ate'.","Data invalida","A data final tem que ser maior que a inicial",1)
	
	_lRet := .F.
	
ELSE
	
	IF VALTYPE(oTProcess) = "O"
		oTProcess:SetRegua1( 3 )
		oTProcess:IncRegua1("Ainda Processando, Aguarde..." )
		oTProcess:IncRegua1("Ainda Processando, Aguarde..." )
	ENDIF

EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: MEST009E
Autor-------------: Josue Danich
Data da Criacao---: 29/10/2015
Descricao---------: Engine de dados de custo gerencial
Parametros--------: 	_cTpGrupo	Tipo Grupo
						_cGrupo	Grupo Custo
						_dinicial	Data inicial
						_dfinal	Data Final
						_netapa	1 -	indica que e a primeira etapa de leitura da ZL6
									2 -	indica que e a segunda etapa de leitura de varias tabelas com regras da ZL6 
										lida na primeira etapa	
Retorno-----------: _aretorno - para etapa 1 retorna quantidade de registros lidos na ZL6
					   _aretorno - para etapa 2 retorna matriz {_nQtdSin, _nVlrSin} com quantidade e valor encontrados
					   				 para a regra
===============================================================================================================================
*/
User Function MEST009E(_cTpGrupo,_cGrupo,_dinicial,_dfinal,_netapa,_oself,_lEnd)
 
Local _cquery		:= ""
Local _cquery2		:= ""
Local _nRegZL6		:= 0
Local _nVlrSin		:= 0
Local _nQtdSin		:= 0
Local _aretorno		:= {} 
Local _nVlrMix		:= 0
Local _nVMixSF		:= 0
Local _CstMix		:= 0   , _zi  , E , _Am
Local _cEmpresa		:= Substr(FWFilialName( cEmpAnt , Xfilial("ZL6") , 2 ),8,35)
Local _aProd        := {} , _ni

Default _cTpGrupo 	:= ""
Default _cGrupo		:= ""
Default _netapa 	:= 1
Default _dinicial	:= DATE()//ctod('01/01/2020')
Default _dfinal		:= DATE()//ctod('01/01/2049')
Default _oSelf      := ""
Default _lEnd       :=.F.

IF _lEnd 
   _lLoop:=.T.
   IF (_lEnd:=U_ITMSG("Confirma Cancelamento???? .","Atenção",,3,2,2))
      RETURN {}
   ENDIF   
ENDIF

PRIVATE _aProdsRateio:={}////Variavel usada na função MEST9Rateio(_CodProd)
//==========================================================================
//Carrega Valor do Mix do leite
//==========================================================================
dbselectarea("ZL2")
Zl2->( dbsetorder(2) )

If Empty(MV_PAR10)
	If ZL2->( Dbseek( xFilial("ZL2") + Alltrim(_cempresa)) )
		If ZL2->ZL2_DTUMIX >= _dinicial .and. ZL2->ZL2_DTUMIX <= ( _dfinal + 15 )
			_nVlrMix := ZL2->ZL2_ULTMIX
			_nVMixSF := ZL2->ZL2_ULMISF
		Else
			_nVlrMix := MV_PAR10
		Endif
	Else
		_nVlrMix := MV_PAR10
	Endif
Else				
	_nVlrMix := MV_PAR10
Endif
dbclosearea()	

//==========================================================================
//Carrega regras de custo gerencial
//==========================================================================
If _netapa == 1

    _oSelf:IncRegua1("LENDO ETAPA 1 DO ZL6..." )
	If Select("ZL6T") > 0 
		ZL6T->( DBCloseArea() )
	EndIf
 
	_cquery	:= " SELECT  * " 
	_cquery  	+= " FROM " + RetSqlName("ZL6") + " ZL6 "
	_cquery  	+= " WHERE ZL6_FILIAL = '" + xFilial("ZL6") + "'"
	
	_cquery  	+=  IIf(!EMPTY(ALLTRIM(_cTpGrupo))	," AND   ZL6_TPCUS  IN "+ FormatIn(ALLTRIM(_cTpGrupo),";")	,"")	
	_cquery  	+=  IIf(!EMPTY(ALLTRIM(_cGrupo))	," AND   ZL6_GRPCUS IN "+ FormatIn(ALLTRIM(_cGrupo),";")	,"")
	_cquery  	+=  IIf(!EMPTY(ALLTRIM(MV_PAR03))	," AND   ZL6_CODEVE IN "+ FormatIn(ALLTRIM(MV_PAR03),";")	,"")
	_cquery  	+=  IIf(!EMPTY(ALLTRIM(MV_PAR04))	," AND   ZL6_SUBEVE IN "+ FormatIn(ALLTRIM(MV_PAR04),";")	,"")		

	_cquery  	+= " AND   ZL6_MSBLQL <> '1' 	"
	_cquery 	+= " AND   ZL6.D_E_L_E_T_ 	= ' '	"
	
	_cquery  	+= " ORDER BY ZL6_OBSERV, ZL6_TPCUS, ZL6_GRPCUS, ZL6_CODEVE, ZL6_SUBEVE " 

    MPSysOpenQuery( _cQuery, "ZL6T" ) 

	DBSelectArea("ZL6T")
  	COUNT TO _nRegZL6
	
	ZL6T->( DBGOTOP() )
	
	_aretorno := { _nRegZL6 }
	
Endif

//==========================================================================
//Carrega dados de custo gerencial
//==========================================================================
If _netapa == 2

	If MV_PAR07 == 3 .AND. VALTYPE(_oSelf) = "O"

//		_oSelf:IncRegua1("LENDO ETAPA 2 DO ZL6..." )
	    _oself:IncRegua2(ZL6T->ZL6_OBSERV+" - "+ALLTRIM(ZL6T->ZL6_DSUBEV))
		
	Endif
	
	If Select("TRB") > 0 

		TRB->( DBCloseArea() )

	EndIf
	

	//==========================================================================
	//Nota Fiscal de entrada
	//==========================================================================
	If  ZL6T->ZL6_OBSERV == "1" 		

		_cquery2	:= U_MEST0091(_dinicial,_dfinal) //Rotina que carrega query  de nota fiscal de entrada	
				
	//==========================================================================
	//Nota Fiscal de saída
	//==========================================================================
	ElseIf ZL6T->ZL6_OBSERV == "2"
			
		_cquery2	:= U_MEST0092(_dinicial,_dfinal) //Rotina que carrega query  de nota fiscal de saída		
           
/*      _cTeste:=ZL6T->ZL6_DESEVE+ENTER
        _cTeste+=ZL6T->ZL6_DSUBEV+ENTER
        _cTeste+=ZL6T->ZL6_DGRCUS+ENTER
        _cTeste+=_cquery2
        If MV_PAR07 = 2
          _cFileNome:=_cdir+"MEST009_OBS_2_ATU_"+STRTRAN(TIME(),":","_")+".CSV"
        ELSE
          _cFileNome:=_cdir+"MEST009_OBS_2_PLAN_"+STRTRAN(TIME(),":","_")+".CSV"
        ENDIF  
        MemoWrite(_cFileNome,_cTeste)
        */
					
	//==========================================================================
	//Movim. Interno
	//==========================================================================	
	Elseif ZL6T->ZL6_OBSERV == "3" 	
			
		_cquery2	:= U_MEST0093(_dinicial,_dfinal) //Rotina que carrega query  de movimentos internos

/*      _cTeste:=ZL6T->ZL6_DESEVE+ENTER
        _cTeste+=ZL6T->ZL6_DSUBEV+ENTER
        _cTeste+=ZL6T->ZL6_DGRCUS+ENTER
        _cTeste+=_cquery2
        If MV_PAR07 = 2
          _cFileNome:=_cdir+"MEST009_OBS_3_ATU_"+STRTRAN(TIME(),":","_")+".CSV"
        ELSE
          _cFileNome:=_cdir+"MEST009_OBS_3_PLAN_"+STRTRAN(TIME(),":","_")+".CSV"
        ENDIF  
         MemoWrite(_cFileNome,_cTeste)*/
	
	//==========================================================================
	//Financeiro
	//==========================================================================	
	Elseif ZL6T->ZL6_OBSERV == "4" 	
                                                                                          
		_cquery2	:= U_MEST0094(_dinicial,_dfinal) //Rotina que carrega query  de financeiro
	
	//==========================================================================
	//Perdas por OP
	//==========================================================================	
	Elseif ZL6T->ZL6_OBSERV == "5" //ATE AQUI TRATA DATA TIPO P-PERIODO 25 A 26
			
		_cquery2	:= U_MEST0095(_dinicial,_dfinal) //Rotina que carrega query  de perdas por op
		
	//==========================================================================
	//Mao de Obra
	//==========================================================================		
	Elseif  ZL6T->ZL6_OBSERV == "6"
	
		_cquery2 := ""
		_aVlrSin := U_MEST0096(_dinicial,_dfinal) //Rotina que carrega qtde e valor de funcionarios
		_nVlrSin := _aVlrSin[1]
		_nQtdSin := _aVlrSin[2]
				
	//==========================================================================
	//Hora Extra
	//==========================================================================		
	Elseif  ZL6T->ZL6_OBSERV == "7"
	
		_cquery2	:= U_MEST0097(_dinicial,_dfinal) //Rotina que carrega query  de hora extra
				
	//==========================================================================
	//Saldos iniciais
	//==========================================================================		
	Elseif  ZL6T->ZL6_OBSERV == "8"
	
		_cquery2	:= U_MEST0098(_dinicial,_dfinal) //Rotina que carrega query  de saldos iniciais
				
	//==========================================================================
	//Gestão do Leite
	//==========================================================================		
	Elseif  ZL6T->ZL6_OBSERV == "9"
	
		_cquery2	:= U_MEST0099(_dinicial,_dfinal) //Rotina que carrega query  de gestão de leite
		
	//==========================================================================
	//Frete Proporcional
	//==========================================================================		
	Elseif  ZL6T->ZL6_OBSERV == "A"
	
		_cquery2 := ""
		_aVlrSin := U_MEST009A(_dinicial,_dfinal)
		_nVlrSin := _aVlrSin[1]
		_nQtdSin := _aVlrSin[2]

	//==========================================================================		
	//Valores Manual
	//==========================================================================		
	Elseif  ZL6T->ZL6_OBSERV == "B"
	
		_cquery2 := ""
		_nVlrSin := ZL6T->ZL6_MVALOR
		_nQtdSin := ZL6T->ZL6_MQTDE				
				
	//==========================================================================		
	//NFE + ST
	//==========================================================================		
	Elseif  ZL6T->ZL6_OBSERV == "C"

		_cquery2 := ""
		_aVlrSin := MEST009IST( ALLTRIM(ZL6T->ZL6_CODPRO) )
		_nVlrSin := _aVlrSin[1,1]

	//==========================================================================		
	//CUSTO GERENCIAL FECHADO
	//==========================================================================		
	Elseif  ZL6T->ZL6_OBSERV == "D" .AND. ALLTRIM(ZL6T->ZL6_TPCUS) <> '000005'

		_cquery2 := ""    
		_aVlrSin := MEST9BuscaZE0(ALLTRIM(ZL6T->ZL6_FILIS),ALLTRIM(ZL6T->ZL6_CLIENTE),ALLTRIM(ZL6T->ZL6_CODPRO),ALLTRIM(ZL6T->ZL6_TPCUS))
		_nQtdSin := _aVlrSin[1]
		_nVlrSin := _aVlrSin[2]
	
	//==========================================================================		
	//PARA O DEMONSTRATIVO DO ESTOQUE FINAL PLANILHA 03 Grupo (000006) OU (PLANILHA 02 PASTA 2 Grupos (000004/000005) )
	//==========================================================================		
	Elseif  ZL6T->ZL6_OBSERV == "E" .AND. (_lGera3Pla .OR. (_lGera2Pla .OR. _lGera1Pla))

		_cquery2 := ""    
		_aVlrSin := MEST9EstoqueFinal(_oself,@_lEnd)
		_nVlrSin := _aVlrSin[1]
		_nQtdSin := _aVlrSin[2]
		_aProd   := _aVlrSin[3]

	//==========================================================================
	//EXCEDENTE MATERIA GORDA
	//==========================================================================	
	Elseif ZL6T->ZL6_OBSERV == "F" 	
			
		_cquery2 := ""    
		_aVlrSin := U_MEST9MGE(_dinicial,_dfinal)
		_nVlrSin := _aVlrSin[3]
		_nQtdSin := 0
        _lTemMateriaPrima:=.T.
	
	Endif	

    IF _lEnd 
       _lLoop:=.T.
       IF (_lEnd:=U_ITMSG("Confirma Cancelamento???? .","Atenção",,3,2,2))
          RETURN _aretorno
       ENDIF   
    ENDIF

	IF !EMPTY(_cquery2)
       MPSysOpenQuery( _cQuery2 , "TRB" ) 
       DBSelectArea("TRB")
    ENDIF
    
    _lTemEstoquenaDT:=.F.
    _nQtdemKG:=0
    
	DO While !EMPTY(_cquery2) .AND. TRB->(!Eof())

        IF _lLoop
           EXIT
        ENDIF
	
		If ZL6T->ZL6_OBSERV == "1"
	
			_nVlrSin += TRB->D1_TOTAL
			_nQtdSin += TRB->D1_QUANT
	
		ElseIf ZL6T->ZL6_OBSERV == "2"
	
			If ZL6T->ZL6_D2FRET == 'S'
				_nVlrSin += TRB->D2_I_FRET
			Else
				_nVlrSin += TRB->D2_TOTAL
			Endif	
			_nQtdSin += TRB->D2_QUANT
	
		Elseif ZL6T->ZL6_OBSERV == "3"
            
	        If ZL6T->ZL6_MIX = "S" .and. _nVlrMix > 0
            	_CstMix := TRB->QUANT * _nVlrMix
				_nVlrSin += _CstMix
			Elseif ZL6T->ZL6_MIX = "F" .and. _nVMixSF > 0
				_CstMix := TRB->QUANT * _nVMixSF
				_nVlrSin += _CstMix			
			ElseIf ZL6T->ZL6_MIX $ "P,L"
		        _lTemMateriaPrima:=.T.
			ElseIf !EMPTY(ZL6T->ZL6_GRPCUF)
				_nVlrSin := 0
			Else//If ZL6T->ZL6_MIX = "N"
				_nVlrSin += TRB->D3_CUSTO1
			Endif	
		    _nQtdSin += TRB->QUANT
		    
		    IF (nPos:=ASCAN(_aFactoMike, {|P| P[1] == ALLTRIM(TRB->D3_COD) })) <>  0
               _nQtdemKG+= (_aFactoMike[nPos,2] * TRB->QUANT)
		    ENDIF
               
		Elseif ZL6T->ZL6_OBSERV == "4"

			_nVlrSin += TRB->VALOR

		Elseif ZL6T->ZL6_OBSERV == "5" 

			_nVlrSin += TRB->BC_I_CUSTO 
			_nQtdSin += TRB->BC_QUANT

		Elseif ZL6T->ZL6_OBSERV == "6" 	

			_nQtdSin += TRB->QUANT
			_nVlrSin += TRB->TOTAL_GERAL
   
		Elseif ZL6T->ZL6_OBSERV == "7" 	

			_nQtdSin += TRB->RD_HORAS
			_nVlrSin += TRB->RD_VALOR
			
		Elseif ZL6T->ZL6_OBSERV == "8" 	

			_nQtdSin += TRB->B9_QINI
			_nVlrSin += TRB->B9_VINI1
			_lTemEstoquenaDT:=.T.
			
		Elseif ZL6T->ZL6_OBSERV == "9" 	

			_nQtdSin += TRB->QUANT
			_nVlrSin += TRB->CREDITO - TRB->DEBITO
			
//		Elseif ZL6T->ZL6_OBSERV == "A" 	
//			_nVlrSin += TRB->TOTAL

		Endif
   
   		TRB->(dbSkip())
			
	End

	//Trabalha campos de multiplicação e divisão
	If ZL6T->ZL6_RCMUL > 0 .and. ZL6T->ZL6_OBSERV <> "7" .and. ZL6T->ZL6_OBSERV <> "6"
			 
		_nVlrSin := _nVlrSin * ZL6T->ZL6_RCMUL
		
	Endif
		
	If ZL6T->ZL6_RCDIV > 0.and. ZL6T->ZL6_OBSERV <> "7" .and. ZL6T->ZL6_OBSERV <> "6"
		
		_nVlrSin := _nVlrSin / ZL6T->ZL6_RCDIV
			
	Endif

	//Caso produção em terceiros e perda contratual
	If ZL6T->ZL6_TERCEI = "S" .and. ZL6T->ZL6_TCMUL <> 0	
		_nQtdsin := _nQtdsin * ZL6T->ZL6_TCMUL
		_nVlrSin := _nVlrSin * ZL6T->ZL6_TCMUL	
	Endif
	If ZL6T->ZL6_TERCEI = "S" .and. ZL6T->ZL6_TCDIV <> 0
		_nQtdsin := _nQtdsin / ZL6T->ZL6_TCDIV
		_nVlrSin := _nVlrSin / ZL6T->ZL6_TCDIV
	Endif	
	
	//define se é regra unitária ou de quantidade
	If ZL6T->ZL6_CONTA == "N"
	
		_nQtdSin := 0
		
	Endif
   
	If ZL6->(FIELDPOS("ZL6_RATCUS")) <> 0 .AND. ZL6T->ZL6_RATCUS == "S" .AND. !EMPTY(ZL6T->ZL6_PRDRAT) 

       _cChave:=xFilial("ZL6")+ZL6T->ZL6_GRPCUS+PADR(ZL6T->ZL6_DTPCUS,60)+PADR(ZL6T->ZL6_DGRCUS,40)+"PRODUTOS ACABADOS PRODUZIDOS            "
       _cValores:=_cChave+ENTER
	   _cProduto:= Posicione("ZL6",8,_cChave,"ZL6_CODPRO")
       _cValores+=_cProduto+ENTER

	   aProds:=STRTOKARR(alltrim(_cProduto), ';')

       _nVlrNew:=0
       _nQtdNew:=0
	   FOR _ni := 1 TO LEN(aProds)
		  nPer:=MEST9Rateio(aProds[_ni])
          _nVlrNew+=_nVlrSin*nPer
          _nQtdNew+=_nQtdsin*nPer

		  _cValores+="RETORNO: "+ENTER
		  _cValores+=aProds[_ni]+" - "+STR(nPer,22,7)+ENTER
		  _cValores+=aProds[_ni]+" - "+STR(_nVlrSin*nPer,22,7)+" - "+STR(_nQtdsin*nPer,22,7)+ENTER+ENTER
	   NEXT
	   _cValores+="TOTAL ORIGINAL: "+STR(_nVlrSin,22,7)+" - "+STR(_nQtdsin,22,7)+ENTER
	   _nQtdsin := _nQtdNew
	   _nVlrSin := _nVlrNew
	   _cValores+="TOTAL NOVO: "+STR(_nVlrSin,22,7)+" - "+STR(_nQtdsin,22,7)+ENTER

	   nHandle := FCreate(_cdir+"SELECT_RATEIO__"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
       FWrite(nHandle, _cValores )
       FClose(nHandle)

	
	ENDIF	   

   //monta array de retorno e alimenta array de total operacional
   
   If ZL6T->ZL6_QTD == "2" //.and.  _nVlrSin > 0
	
		_aretorno := { _nQtdSin * -1 , _nVlrSin * -1 , _lTemEstoquenaDT , _aProd , _nQtdemKG }	
	
	Else 
		
		_aretorno := { _nQtdSin      , _nVlrSin      , _lTemEstoquenaDT , _aProd , _nQtdemKG }
	
	Endif


Endif


//=====================================================================================================
//Carrega total litros leite por consumo de materia prima
//=====================================================================================================
If _netapa == 3

    _oSelf:IncRegua1("LENDO ETAPA 3 DO ZL6..." )

	_cPosCap	:= U_ITGETMV( "IT_POSTCAPT")
	_cprods 	:= U_ITGETMV( "IT_MPCUSTO")
	_cDesmontagem :=U_ITGETMV( "IT_MPDESMON","N")
	_cprodsPA 	:= U_ITGETMV( "IT_PACUSTO")
	_cTransferencias:=U_ITGETMV( "IT_PATRANS","N")
	_cprodsCC 	:= U_ITGETMV( "IT_MPCCUST")
	_cprodsCCPA	:= U_ITGETMV( "IT_PACCUST")
	_cProdsRet  := U_ITGETMV( "IT_RETCUST")
	_nProdsRet  := VAL(U_ITGETMV( "IT_CRETCUST","4"))//	"1-Soma RE1" , "2-Desconta RE1" , "3-Soma RE7" , "4-Desconta RE7" , "5-Soma Ambos" ,"6-Desconta Ambos" 
    _nITVOLUAGUA:= U_ITGetMV("IT_VOLUAGUA",0)
    _nITOUTROMOV:= U_ITGetMV("IT_OUTROMOV",0)

	If MV_PAR11 = 2
		_cFilSom	:= ""
	ElseIf MV_PAR11 <> 2
		_cFilSom	:= U_ITGETMV( "IT_FILSOMA")
	Endif	 

    _cValores:=""

	If Select("SD3T") > 0 

		SD3T->( DBCloseArea() )

	EndIf

	_cquery	:= " SELECT " 
	
	_cquery += " SUM(SD3.D3_QUANT) AS TOT " 
	 	 
	_cquery += " FROM " + RetSqlName("SD3") + " SD3 "
	If !Empty(_cFilSom)
		_cquery += " WHERE SD3.D3_FILIAL IN " + FormatIn(ALLTRIM(_cFilSom),";")
	Else	
		_cquery += " WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'"
	Endif	
	_cquery  += " AND   SD3.D3_EMISSAO BETWEEN '" + DTOS(_dinicial)+ "' AND '" + DTOS(_dfinal) + "'"
	_cquery  += " AND   SD3.D3_ESTORNO <> 'S' "
	_cquery  += " AND   SD3.D_E_L_E_T_ = ' '	"

    _cQuery1:=_cQuery2:=_cquery3:="" 
	_nVolLeite:=0

	If cfilant $ (_cPosCap)
        _aFils :=STRTOKARR(_cPosCap,';')
        _cSetor:=""
        FOR _ni := 1 TO LEN(_aFils)
            IF ZLT->(DBSEEK(xFilial()+_aFils[_ni]))
               _cSetor+=ALLTRIM(ZLT->ZLT_SETOR)//Pega os setores das filiais
               IF RIGHT(_cSetor,1) <> ";"
                  _cSetor+=";"
               ENDIF
            ENDIF   
        NEXT              
        _cSetor:=LEFT(_cSetor, LEN(_cSetor)-1 )
        _nVolLeite:=VolLeite(_cSetor) //VOLUME
  		_cprods:=_cprodsPA:=_cProdsRet:=""

	Else	
	    IF !EMPTY(_cprods)
		   _cquery1 += " AND SD3.D3_COD IN " + FormatIn(ALLTRIM(_cprods),";")
	        IF _cDesmontagem = "S"//SE SIM 
		       _cquery1 += " AND SD3.D3_CF  = 'DE7' "
			ELSEIF _cDesmontagem = "A"//AMBOS
		       _cquery1 += " AND SD3.D3_CF  IN ('RE1','DE7') "   
			ELSE//IF _cDesmontagem = "N"//NÃO
		       _cquery1 += " AND SD3.D3_CF  = 'RE1' "
	        ENDIF
	        IF !EMPTY(_cprodsCC)
	    	   _cquery1 	+= " AND SD3.D3_CC IN " + FormatIn(ALLTRIM(_cprodsCC),";")
	        ENDIF
	    Endif	
        IF !EMPTY(_cprodsPA)
		   _cquery2 += " AND SD3.D3_COD IN " + FormatIn(ALLTRIM(_cprodsPA),";")
	        IF _cTransferencias = "S"//SE SIM 
			   _cquery2 += " AND  SD3.D3_CF IN ('RE4') AND SD3.D3_I_TPTRS = '1'  "
		    ELSEIF _cTransferencias = "A"//SE AMBOS
			   
			   _cquery2 += " AND ( ( SD3.D3_CF IN ('PR0')  "
	           IF !EMPTY(_cprodsCCPA)
	    	      _cquery2 	+= " AND SD3.D3_CC IN " + FormatIn(ALLTRIM(_cprodsCCPA),";")
	           ENDIF
			   _cquery2 += " ) OR (SD3.D3_CF IN ('RE4')  AND SD3.D3_I_TPTRS = '1') ) "

		    ELSE//IF _cTransferencias = "N"//SE NÃO
		       _cquery2 += " AND SD3.D3_CF IN ('PR0') "
	           IF !EMPTY(_cprodsCCPA)
	    	      _cquery2 	+= " AND SD3.D3_CC IN " + FormatIn(ALLTRIM(_cprodsCCPA),";")
	           ENDIF
            ENDIF
   	    Endif	
	    IF !EMPTY(_cProdsRet)
	        IF STR(_nProdsRet,1)  $ "1,2"//"1-Soma DE1" , "2-Desconta DE1" , "3-Soma RE7" , "4-Desconta RE7" , "5-Soma Ambos" ,"6-Desconta Ambos" 
                _cquery3+= " AND  SD3.D3_CF IN ('DE1') "
	        ELSEIF STR(_nProdsRet,1)  $ "3,4"
                _cquery3+= " AND  SD3.D3_CF IN ('RE7') "
	        ELSEIF STR(_nProdsRet,1)  $ "5,6"
                _cquery3+= " AND  SD3.D3_CF IN ('DE1','RE7') "
	        ENDIF
	       	_cquery3	+= " AND SD3.D3_COD IN " + FormatIn(ALLTRIM(_cProdsRet),";")
	    ENDIF
    ENDIF

	_aretorno:= _nRegZL6:=_nRegZL6Aux:= 0

	_cValores+=_cquery+_cquery1+ENTER+ENTER

    IF !EMPTY(_cprods)
       MPSysOpenQuery( (_cquery+_cquery1) ,"SD3T" ) 
       DBSelectArea("SD3T")
  	   COUNT TO _nRegZL6Aux
  	   _nRegZL6+=_nRegZL6Aux
	   SD3T->( DBGOTOP() )
	   _aretorno += SD3T->TOT
	   	_cValores+=STR(SD3T->TOT,21,8)+ENTER+ENTER
    ENDIF	
	_cValores+=_cquery+_cquery2+ENTER+ENTER

	If Select("SD3T") > 0 
		SD3T->( DBCloseArea() )
	EndIf
    IF !EMPTY(_cprodsPA)
       MPSysOpenQuery( (_cquery+_cquery2) ,"SD3T" ) 
       DBSelectArea("SD3T")
       _nRegZL6Aux:=0
  	   COUNT TO _nRegZL6Aux
  	   _nRegZL6+=_nRegZL6Aux
	   SD3T->( DBGOTOP() )
	   _aretorno += SD3T->TOT
	   	_cValores+=STR(SD3T->TOT,21,8)+ENTER+ENTER
    ENDIF
	If Select("SD3T") > 0 
		SD3T->( DBCloseArea() )
	EndIf
	_cValores+=_cquery+_cquery3+ENTER+ENTER
    IF !EMPTY(_cProdsRet)
       MPSysOpenQuery( (_cquery+_cquery3) ,"SD3T" ) 
       DBSelectArea("SD3T")
       _nRegZL6Aux:=0
  	   COUNT TO _nRegZL6Aux
  	   _nRegZL6+=_nRegZL6Aux
	   SD3T->( DBGOTOP() )
  	   _cValores+=STR(_aretorno,21,8)+ENTER+ENTER
	   IF STR(_nProdsRet,1)  $ "1,3,5"//"1-Soma RE1" , "2-Desconta RE1" , "3-Soma RE7" , "4-Desconta RE7" , "5-Soma Ambos" ,"6-Desconta Ambos" 
	      _aretorno += SD3T->TOT
	   ELSEIF STR(_nProdsRet,1)  $ "2,4,6"
	      _aretorno -= SD3T->TOT
	   ENDIF
	   _cValores+=U_ITGETMV( "IT_CRETCUST","4")+";"+STR(SD3T->TOT,21,8)+ENTER+ENTER
    ENDIF

  	_cValores+="_nVolLeite: "+STR(_nVolLeite,21,8)+ENTER+ENTER

	_aretorno+=_nVolLeite
    _aretorno+=_nITVOLUAGUA
    _aretorno+=_nITOUTROMOV

  	_cValores+="_nITVOLUAGUA: "+STR(_nITVOLUAGUA,22,8)+ENTER+ENTER
  	_cValores+="_nITOUTROMOV: "+STR(_nITOUTROMOV,22,8)+ENTER+ENTER
  	_cValores+="_aretorno: "+STR(_aretorno,21,8)+ENTER+ENTER
  	
     _aretorno := { _aretorno,0 }

    _cFileNome:=_cdir+"MEST009_LEITE_MP_"+xFilial("ZL6")+"_"+STRTRAN(TIME(),":","_")+".TXT"
    MemoWrite(_cFileNome,_cValores)

Endif

IF _lEnd 
   IF (_lEnd:=U_ITMSG("Confirma Cancelamento???? .","Atenção",,3,2,2))
      _lLoop:=.T.
      RETURN _aretorno
   ENDIF   
ENDIF

//========================================================================================
// Se for a filial de Jaru tem um cálculo específico para total de consumo de soro
//========================================================================================
If _netapa == 3 .and. cfilant == "10" 

    _oSelf:IncRegua1("LENDO ETAPA 3 FILIAL 10 DO ZL6..." )


    _cData:= LastDate(MonthSub(MV_PAR06,1))

    _aPlanilia:={}                    //3,4,5,6,7,8,9,10
    AADD(_aPlanilia,{'08000000029',1.00,0,0,0,0,0,0,0,1.00})
    AADD(_aPlanilia,{'08000000049',9.16,0,0,0,0,0,0,0,3.08})
    AADD(_aPlanilia,{'08000000056',3.10,0,0,0,0,0,0,0,3.08})
    AADD(_aPlanilia,{'TOTAIS'     ,   0,0,0,0,0,0,0,0,0   })

//1 - ESTOQUE INICIAL - POS 3
	If Select("SB9T") > 0 
	   SB9T->( DBCloseArea() )
	EndIf

	_cB9query := " SELECT B9_COD, SUM(B9_QINI) QTDE FROM " + retsqlname("SB9") 
	_cB9query += " WHERE D_E_L_E_T_ = ' ' "
	_cB9query += " AND B9_COD IN ('08000000029','08000000049','08000000056') "
	_cB9query += " AND B9_FILIAL = '" +cFilAnt+"'
	_cB9query += " AND B9_DATA = '" +DTOS(_cData) + "'
	_cB9query += " GROUP BY B9_COD"
   
    MPSysOpenQuery( _cB9query ,"SB9T" ) 
    DBSelectArea("SB9T")
	
    _lTemSaldoIni:=.F.
	DO WHILE ! SB9T->( Eof() )
	   IF (nPos:=ASCAN(_aPlanilia,{|P| P[1]==ALLTRIM(SB9T->B9_COD) })) # 0
           _aPlanilia[nPos,3]:=SB9T->QTDE
           _lTemSaldoIni:=.T.
       ENDIF
       SB9T->( DBSKIP() )
	ENDDO

    IF !_lTemSaldoIni
    
        _aLocal:={"01","03","04"}

	    For _zi := 1 To len(_aPlanilia)
	        FOR _Am := 1 To len(_aLocal)
		        _aSaldos := CalcEst( _aPlanilia[_zi,1] , _aLocal[_Am] , _cData+1  ) //obtém o saldo final em estoque na data informada	
		        _aPlanilia[_zi,3]+=_aSaldos[1]
	        Next	
	    Next	

    ENDIF

//2 - PRODUÇÃO POS - 4
	If Select("SD3P") > 0 
	   SD3P->( DBCloseArea() )
	EndIf
	_cD3Pquery	:= " SELECT SD3.D3_COD, SUM(SD3.D3_QUANT) AS QTDE" 
	_cD3Pquery 	+= " FROM " + RetSqlName("SD3") + " SD3 "
	_cD3Pquery  += " WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'"
	_cD3Pquery  += " AND   SD3.D3_COD IN ('08000000029','08000000049','08000000056') " 
	_cD3Pquery  += " AND   SD3.D3_EMISSAO BETWEEN '" + DTOS(_dinicial)+ "' AND '" + DTOS(_dfinal) + "'"
 	_cD3Pquery  += " AND   (SD3.D3_CF  = 'PR0' OR SD3.D3_CF  = 'DE1')"
	_cD3Pquery  += " AND   SD3.D3_ESTORNO <> 'S' "
	_cD3Pquery 	+= " AND   SD3.D_E_L_E_T_ = ' '	"
	_cD3Pquery  += " GROUP BY SD3.D3_COD"

    MPSysOpenQuery( _cD3Pquery ,"SD3P" ) 
    DBSelectArea("SD3P")

	DO WHILE ! SD3P->( Eof() )
	   IF (nPos:=ASCAN(_aPlanilia,{|P| P[1]==ALLTRIM(SD3P->D3_COD) })) # 0
           _aPlanilia[nPos,4]:=SD3P->QTDE
           _lTemSaldoIni:=.T.
       ENDIF
       SD3P->( DBSKIP() )
	ENDDO

//3 - COMPRAS  - POS 5
	If Select("SD1C") > 0 
	   SD1C->( DBCloseArea() )
	EndIf
	_cD1Cquery	:= " SELECT SD1.D1_COD, SUM(SD1.D1_QUANT) AS QTDE" 
	_cD1Cquery  += " FROM " + RetSqlName("SD1") + " SD1 "
	_cD1Cquery  += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "'"
	_cD1Cquery  += " AND   SD1.D1_COD IN ('08000000029','08000000049','08000000056') "
	_cD1Cquery  += " AND   SD1.D1_DTDIGIT BETWEEN '" + DTOS(_dinicial)+ "' AND '" + DTOS(_dfinal) + "'"
 	_cD1Cquery  += " AND   SD1.D1_TES <> ' ' "
	_cD1Cquery 	+= " AND   SD1.D_E_L_E_T_ 	= ' '	"
	_cD1Cquery  += " GROUP BY SD1.D1_COD"

    MPSysOpenQuery( _cD1Cquery ,"SD1C" ) 
    DBSelectArea("SD1C")

	DO WHILE ! SD1C->( Eof() )
	   IF (nPos:=ASCAN(_aPlanilia,{|P| P[1]==ALLTRIM(SD1C->D1_COD) })) # 0
           _aPlanilia[nPos,5]:=SD1C->QTDE
           _lTemSaldoIni:=.T.
       ENDIF
       SD1C->( DBSKIP() )
	ENDDO

//4 - SAIDA PROD. SORO PÓ - POS 6
	If Select("SD3S") > 0 
	   SD3S->( DBCloseArea() )
	EndIf
	_cD3Squery	:= " SELECT SD3.D3_COD, SUM(SD3.D3_QUANT) AS QTDE" 
	_cD3Squery  += " FROM " + RetSqlName("SD3") + " SD3 "
	_cD3Squery  += " WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'"
	_cD3Squery  += " AND   SD3.D3_COD IN ('08000000029', '08000000049','08000000056') "
	_cD3Squery  += " AND   SD3.D3_EMISSAO BETWEEN '" + DTOS(_dinicial)+ "' AND '" + DTOS(_dfinal) + "'"
	_cD3Squery  += " AND   SD3.D3_CF = 'RE1' "
	_cD3Squery  += " AND   SD3.D3_CC IN ('24191001')"
	_cD3Squery  += " AND   SD3.D3_ESTORNO <> 'S' "
	_cD3Squery 	+= " AND   SD3.D_E_L_E_T_ = ' '	"
    _cD3Squery  += " GROUP BY SD3.D3_COD"

    MPSysOpenQuery( _cD3Squery ,"SD3S" ) 
    DBSelectArea("SD3S")

	DO WHILE ! SD3S->( Eof() )
	   IF (nPos:=ASCAN(_aPlanilia,{|P| P[1]==ALLTRIM(SD3S->D3_COD) })) # 0
           _aPlanilia[nPos,6]:=SD3S->QTDE
           _lTemSaldoIni:=.T.
       ENDIF
       SD3S->( DBSKIP() )
	ENDDO

//5 - SAIDA PROD. COMPOSTO  - POS 7
	If Select("SD3C") > 0 
	   SD3C->( DBCloseArea() )
	EndIf
	_cD3Cquery	:= " SELECT SD3.D3_COD, SUM(SD3.D3_QUANT) AS QTDE" 
	_cD3Cquery  += " FROM " + RetSqlName("SD3") + " SD3 "
	_cD3Cquery  += " WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'"
	_cD3Cquery  += " AND   SD3.D3_COD IN ('08000000029', '08000000049','08000000056') "
	_cD3Cquery  += " AND   SD3.D3_EMISSAO BETWEEN '" + DTOS(_dinicial)+ "' AND '" + DTOS(_dfinal) + "'"
	_cD3Cquery 	+= " AND   SD3.D3_CF        = 'RE1' "
	_cD3Cquery 	+= " AND   SD3.D3_CC IN ('24132001')"
	_cD3Cquery  += " AND   SD3.D3_ESTORNO <> 'S' "
	_cD3Cquery 	+= " AND   SD3.D_E_L_E_T_ = ' '	"
	_cD3Cquery  += " GROUP BY SD3.D3_COD"

    MPSysOpenQuery( _cD3Cquery ,"SD3C" ) 
    DBSelectArea("SD3C")

	DO WHILE ! SD3C->( Eof() )
	   IF (nPos:=ASCAN(_aPlanilia,{|P| P[1]==ALLTRIM(SD3C->D3_COD) })) # 0
           _aPlanilia[nPos,7]:=SD3C->QTDE
           _lTemSaldoIni:=.T.
       ENDIF
       SD3C->( DBSKIP() )
	ENDDO

//6 - SAIDA DEVOLUÇÃO - POS 8
	If Select("SD2C") > 0 
	   SD2C->( DBCloseArea() )
	EndIf
	_cD2query	:= " SELECT SD2.D2_COD, SUM(SD2.D2_QUANT) AS QTDE" 
	_cD2query  	+= " FROM " + RetSqlName("SD2") + " SD2 "
	_cD2query  	+= " WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
	_cD2query  	+= " AND   SD2.D2_COD IN ('08000000029','08000000049','08000000056') "
	_cD2query  	+= " AND   SD2.D2_EMISSAO BETWEEN '" + DTOS(_dinicial)+ "' AND '" + DTOS(_dfinal) + "'"
 	_cD2query  	+= " AND   SD2.D2_TIPO = 'D' "
	_cD2query 	+= " AND   SD2.D_E_L_E_T_ 	= ' '	"
	_cD2query 	+= " GROUP BY SD2.D2_COD "

    MPSysOpenQuery( _cD2query ,"SD2C" ) 
    DBSelectArea("SD2C")

	DO WHILE ! SD2C->( Eof() )
	   IF (nPos:=ASCAN(_aPlanilia,{|P| P[1]==ALLTRIM(SD2C->D2_COD) })) # 0
           _aPlanilia[nPos,8]:=SD2C->QTDE
           _lTemSaldoIni:=.T.
       ENDIF
       SD2C->( DBSKIP() )
	ENDDO

//7 - ESTOQUE FINAL - POS 9
     nPos:=LEN(_aPlanilia)//TOTAIS
     FOR E := 1 TO (nPos-1)
         IF SB5->(FIELDPOS("B5_I_FATR1")) # 0
            _nFator1:=Posicione("SB5",1,xFilial("SB5")+_aPlanilia[E,1],"B5_I_FATR1")
            _nFator2:=Posicione("SB5",1,xFilial("SB5")+_aPlanilia[E,1],"B5_I_FATR2")
            _aPlanilia[E,10]:= IF(_nFator1=0,1,_nFator1)//Fator de conversao compra do soro  3.12
            _aPlanilia[E,02]:= IF(_nFator2=0,1,_nFator1)//Fator de conversao de Rendimento 3.1,9,16
         ENDIF   
         _aPlanilia[E,09]:= (_aPlanilia[E,3]+_aPlanilia[E,4]+_aPlanilia[E,5]) - (_aPlanilia[E,6]+_aPlanilia[E,7]+_aPlanilia[E,8])
     NEXT

//CONTA MANUAL = FLUIDO - TOTAIS
//    1          , 2  ,3,4,5,6,7,8,9, 10
//1 '08000000029',1   ,0,0,0,0,0,0,0,1.0 }) 1
//2 '08000000049',9.16,0,0,0,0,0,0,0,3.12}) 2
//3 '08000000056',3.10,0,0,0,0,0,0,0,3.12}) 3
//4 'TOTAIS'     ,   0,0,0,0,0,0,0,0,0   }) 4
//  1            ,2   ,3,4,5,6,7,8,9
                            //linha 1                              linha 2                              linha 3
      _aPlanilia[nPos,3]:= (_aPlanilia[1,3]* _aPlanilia[1,02]) + (_aPlanilia[2,3]*_aPlanilia[2,02]) + (_aPlanilia[3,3]*_aPlanilia[3,02])//1-ESTOQUE INICIAL
      _aPlanilia[nPos,4]:=  _aPlanilia[1,4] //2-PRODUÇÃO
      _aPlanilia[nPos,5]:= (_aPlanilia[1,5]* _aPlanilia[1,10]) + (_aPlanilia[2,5]*_aPlanilia[2,10]) + (_aPlanilia[3,5]*_aPlanilia[3,10]) //3-COMPRAS
      _aPlanilia[nPos,7]:= (_aPlanilia[1,7]* _aPlanilia[1,02]) + (_aPlanilia[2,7]*_aPlanilia[2,02]) + (_aPlanilia[3,7]*_aPlanilia[3,02]) //5-SAIDA PROD. COMPOSTO
      _aPlanilia[nPos,8]:= (_aPlanilia[1,8]* _aPlanilia[1,10]) + (_aPlanilia[2,8]*_aPlanilia[2,10]) + (_aPlanilia[3,8]*_aPlanilia[3,10]) //6-SAIDA DEVOLUÇÃO
      _aPlanilia[nPos,9]:= (_aPlanilia[1,9]* _aPlanilia[1,02]) + (_aPlanilia[2,9]*_aPlanilia[2,02]) + (_aPlanilia[3,9]*_aPlanilia[3,02]) //5-SAIDA PROD. COMPOSTO

      _aPlanilia[nPos,6]:= (_aPlanilia[4,3]+_aPlanilia[4,4]+_aPlanilia[4,5]) - (_aPlanilia[4,7]+_aPlanilia[4,8]+_aPlanilia[4,9])//CALCULO MANUAL

     _aretorno[2] := _aPlanilia[nPos,6]

//1 - ESTOQUE INICIAL - POS 3
	If Select("SB9T") > 0 
	   SB9T->( DBCloseArea() )
	EndIf
//2 - PRODUÇÃO POS - 4
	If Select("SD3P") > 0 
	   SD3P->( DBCloseArea() )
	EndIf
//3 - COMPRAS  - POS 5
	If Select("SD1C") > 0 
	   SD1C->( DBCloseArea() )
	EndIf
//4 - SAIDA PROD. SORO PÓ - POS 6
	If Select("SD3S") > 0 
	   SD3S->( DBCloseArea() )
	EndIf
//5 - SAIDA PROD. COMPOSTO  - POS 7
	If Select("SD3C") > 0 
	   SD3C->( DBCloseArea() )
	EndIf
//6 - SAIDA DEVOLUÇÃO - POS 8
	If Select("SD2C") > 0 
	   SD2C->( DBCloseArea() )
	EndIf
	DBSelectArea("ZL6")

Endif

Return _aretorno


/*
===============================================================================================================================
Programa----------: MEST0091
Autor-------------: Josue Danich
Data da Criacao---: 29/10/2015
Descricao---------: Retorna query para custo gerencial de notas de entrada
Parametros--------: 	_dinicial - data inicial de analise
						_dfinal   - data final e analise
Retorno-----------: _cquery2  - query a ser executada
===============================================================================================================================
*/ 
User function MEST0091(_dinicial,_dfinal)

Local _cquery2 := ""
Local _cTabela	:= "SD1.D1"
Local _cTabela2 	:= "SF1.F1"
				

		_cQuery2 	:= " SELECT "
			
		//=================================================
		//escolhe valor total ou custo padrao do Protheus
		//=================================================
		If ZL6T->ZL6_EXIMPO == "S"
		
			If ZL6T->ZL6_PISCOF == "S"
			
				_cQuery2 	+= " 			(D1_CUSTO + D1_VALIMP5 + D1_VALIMP6) AS D1_TOTAL,"
				
			Else
			
				_cQuery2 	+= " 			D1_CUSTO AS D1_TOTAL,"
			
			Endif
			
		Else
		
			If ZL6T->ZL6_PISCOF == "S"
			
				If ZL6T->ZL6_ABTDES = "S"
					_cQuery2 	+= " 			(((D1_TOTAL+D1_VALFRE) - D1_VALDESC) - (D1_VALIMP5 + D1_VALIMP6)) AS D1_TOTAL,"
				Else	
					_cQuery2 	+= " 			((D1_TOTAL+D1_VALFRE) - (D1_VALIMP5 + D1_VALIMP6)) AS D1_TOTAL,"
				Endif	
			Else
				If ZL6T->ZL6_ABTDES = "S"
					_cQuery2 	+= " 			((D1_TOTAL+D1_VALFRE) - D1_VALDESC) AS D1_TOTAL,"
				Else	
					_cQuery2 	+= " 			(D1_TOTAL+D1_VALFRE) AS D1_TOTAL,"
				Endif	
			Endif
			
		Endif
		If ZL6T->ZL6_TUNID == 'S'
		   _cQuery2	+= " 			D1_QTSEGUM D1_QUANT,"
		ELSE
		   _cQuery2	+= " 			D1_QUANT,"
		ENDIF
		_cQuery2 	+= " 			D1_COD,"
		_cQuery2 	+= " 			D1_CF,"
		_cQuery2 	+= " 			D1_DOC,"
		_cQuery2 	+= " 			D1_CC,"
		_cQuery2 	+= " 			D1_EMISSAO,"
		_cQuery2 	+= " 			D1_DTDIGIT,"
		_cQuery2 	+= " 			D1_TES,"
		_cQuery2 	+= " 			D1_NUMSEQ,"
		_cQuery2 	+= " 			F1_FORNECE,"
		_cQuery2 	+= " 			F1_USERLGA,"
		_cQuery2 	+= " 			F1_USERLGI,"
		_cQuery2 	+= " 			(SELECT SUM(E2_VALOR) FROM "+ RetSqlName("SE2") + " SE2"
		_cQuery2 	+= "          						 WHERE SE2.E2_FILIAL		= SD1.D1_FILIAL	AND "
		_cQuery2 	+= "											SE2.E2_FORNECE 	= SD1.D1_FORNECE 	AND "
		_cQuery2 	+= "											SE2.E2_LOJA 		= SD1.D1_LOJA		AND "
		_cQuery2 	+= "											SE2.E2_NUM			= SD1.D1_DOC     	AND "		
		_cQuery2 	+= "											SE2.D_E_L_E_T_ = ' ') AS E2_VALOR,"
		_cQuery2 	+= " 			(SELECT E2_NATUREZ FROM "+ RetSqlName("SE2") + " SE2"
		_cQuery2 	+= "          						 WHERE SE2.E2_FILIAL		= SD1.D1_FILIAL	AND "
		_cQuery2 	+= "											SE2.E2_FORNECE	= SD1.D1_FORNECE 	AND "
		_cQuery2 	+= "											SE2.E2_LOJA 		= SD1.D1_LOJA		AND "
		_cQuery2 	+= "											SE2.E2_NUM			= SD1.D1_DOC     	AND "	
		_cQuery2 	+= "											ROWNUM = 1 AND"			
		_cQuery2 	+= "											SE2.D_E_L_E_T_ = ' ') AS E2_NATUREZ,"
		_cQuery2 	+= " 			D1_FILIAL"		
			
		_cQuery2 	+= " FROM "+ RetSqlName("SD1")+ " SD1 "
					
		_cQuery2 	+= " INNER JOIN "+ RetSqlName("SF1")+" SF1 ON 	SF1.F1_FILIAL 	= SD1.D1_FILIAL	AND "
		_cQuery2 	+= "  													SF1.F1_FORNECE	= SD1.D1_FORNECE 	AND "
		_cQuery2 	+= "  													SF1.F1_LOJA 		= SD1.D1_LOJA		AND " 
		_cQuery2 	+= "  													SF1.F1_SERIE 		= SD1.D1_SERIE	AND " 
		_cQuery2 	+= "  													SF1.F1_DOC 		= SD1.D1_DOC "
		
		 
		If EMPTY(ZL6T->ZL6_FILIS)
		
			_cQuery2 += " WHERE SD1.D1_FILIAL = '" + xfilial("SD1") + "'"
			
		Else
		
			_cQuery2 += " WHERE SD1.D1_FILIAL IN " +  FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";") 
		
		Endif
		
		If ALLTRIM(ZL6T->ZL6_PRXMES) == "S"
			nMonth := 1
			_dinicial := MonthSum( _dinicial , nMonth ) //Soma Meses em Uma Data
			_dfinal	  := MonthSum( _dfinal , nMonth ) //Soma Meses em Uma Data	 
		ELSEIf ALLTRIM(ZL6T->ZL6_PRXMES) == "N"
			nMonth := 1
			_dinicial := MonthSub( _dinicial , nMonth ) //diminui Meses em Uma Data
			_dfinal	  := MonthSub( _dfinal , nMonth ) //diminui Meses em Uma Data	 

		ELSEIf ALLTRIM(ZL6T->ZL6_PRXMES) == "P" .AND. ZL6->(FIELDPOS("ZL6_PERIOD")) <> 0 .AND. !EMPTY(ZL6T->ZL6_PERIOD)
		
		    _cDiaI:=LEFT(ZL6T->ZL6_PERIOD,2)
		    _cDiaF:=RIGHT(ZL6T->ZL6_PERIOD,2)

	        IF MONTH(_dinicial) = 2 
               IF VAL(_cDiaI) > 28
                  _cDiaI:="28"
               ENDIF   
               IF VAL(_cDiaF) > 28
                  _cDiaF:="28"
               ENDIF   
	        ENDIF

            IF MONTH(_dinicial) > 1
			   _dinicial := STOD(ALLTRIM(STR( YEAR(_dinicial)   )) + STRZERO((MONTH(_dinicial)-1),2)+_cDiaI)
            Else
               _dinicial := STOD(ALLTRIM(STR((YEAR(_dinicial)-1))) + "12"+_cDiaI) 
            Endif
			_dfinal	     := STOD(ALLTRIM(STR( YEAR(_dfinal)     )) + STRZERO((MONTH(_dfinal)),2)+_cDiaF)

        Endif
		
		If ALLTRIM(ZL6T->ZL6_VENCTO) == "S"
		
			_cQuery2 += " AND	(SELECT E2_VENCTO FROM "+ RetSqlName("SE2") + " SE2"
			_cQuery2 	+= "          						 WHERE SE2.E2_FILIAL		= SD1.D1_FILIAL	AND "
			_cQuery2 	+= "											SE2.E2_FORNECE 	= SD1.D1_FORNECE 	AND "
			_cQuery2 	+= "											SE2.E2_LOJA 		= SD1.D1_LOJA		AND "
			_cQuery2 	+= "											SE2.E2_NUM			= SD1.D1_DOC     	AND "	
			_cQuery2 	+= "											ROWNUM		= 1     	AND "		
			_cQuery2 	+= "											SE2.D_E_L_E_T_ = ' ')  BETWEEN '" + DTOS(_dinicial)+ "' AND '" + DTOS(_dfinal) + "'"
				
		ELSEIf ALLTRIM(ZL6T->ZL6_VENCTO) == "D"

			_cQuery2 += " AND SD1.D1_DTDIGIT BETWEEN '" + DTOS(_dinicial)+ "' AND '" + DTOS(_dfinal) + "'"

		Else
										
			_cQuery2 += " AND SD1.D1_EMISSAO BETWEEN '" + DTOS(_dinicial)+ "' AND '" + DTOS(_dfinal) + "'"
			
		Endif
						
		_cQuery2 	+= " AND SD1.D1_TES > ' ' "
		
		IF !EMPTY(ZL6T->ZL6_CFOP)
		
			_cQuery2	+= " AND " + _cTabela + "_CF  IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CFOP),";")
		
		Endif
		
		IF !EMPTY(ZL6T->ZL6_NCFOP)
		
			_cQuery2	+= " AND " + _cTabela + "_CF  NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCFOP),";")
		
		Endif
	
		If  !EMPTY(ZL6T->ZL6_LOCAL)
		
			_cQuery2 += " AND " + _cTabela + "_LOCAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_LOCAL),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_NLOCAL)
		
			_cQuery2 += " AND " + _cTabela + "_LOCAL NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NLOCAL),";")
		
		Endif
		
	
	
		If	!EMPTY(ZL6T->ZL6_CENTRO)
		
			_cQuery2 	+= " AND " + _cTabela + "_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
		
		Endif
		
		If	!EMPTY(ZL6T->ZL6_NCENTR)
		
			_cQuery2 	+= " AND " + _cTabela + "_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		
		Endif
		
		If	!EMPTY(ZL6T->ZL6_TES)
		
			_cQuery2 	+= " AND " + _cTabela + "_TES IN " + FormatIn(ALLTRIM(ZL6T->ZL6_TES),";")
		
		Endif
		
		If	!EMPTY(ZL6T->ZL6_NTES)
		
			_cQuery2 	+= " AND " + _cTabela + "_TES NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NTES),";")
		
		Endif
	
		
		If	 !EMPTY(ZL6T->ZL6_NATURE)
		
		
			_cQuery2 	+= " AND		(SELECT E2_NATUREZ FROM "+ RetSqlName("SE2") + " SE2"
			_cQuery2 	+= "          						 WHERE SE2.E2_FILIAL		= SD1.D1_FILIAL	AND "
			_cQuery2 	+= "											SE2.E2_FORNECE 	= SD1.D1_FORNECE 	AND "
			_cQuery2 	+= "											SE2.E2_LOJA 		= SD1.D1_LOJA		AND "
			_cQuery2 	+= "											SE2.E2_NUM			= SD1.D1_DOC     	AND "	
			_cQuery2 	+= "											ROWNUM = 1 AND"			
			_cQuery2 	+= "											SE2.D_E_L_E_T_ = ' ') IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NATURE),";")
			
		Endif
		
		If	 !EMPTY(ZL6T->ZL6_NNATUR)
		
			_cQuery2 	+= " AND		(SELECT E2_NATUREZ FROM "+ RetSqlName("SE2") + " SE2"
			_cQuery2 	+= "          						 WHERE SE2.E2_FILIAL		= SD1.D1_FILIAL	AND "
			_cQuery2 	+= "											SE2.E2_FORNECE 	= SD1.D1_FORNECE 	AND "
			_cQuery2 	+= "											SE2.E2_LOJA 		= SD1.D1_LOJA		AND "
			_cQuery2 	+= "											SE2.E2_NUM			= SD1.D1_DOC     	AND "	
			_cQuery2 	+= "											ROWNUM = 1 AND"			
			_cQuery2 	+= "											SE2.D_E_L_E_T_ = ' ') NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NNATUR),";")
		
		Endif
	
		
		If	 !EMPTY(ZL6T->ZL6_CODPRO)
		
			_cQuery2 += " AND " + _cTabela + "_COD IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CODPRO),";")
		
		Endif
		
		If !EMPTY(ZL6T->ZL6_NCODPR)
		
			_cQuery2 += " AND " + _cTabela + "_COD NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCODPR),";")
		
		Endif	
	
		If  !EMPTY(ZL6T->ZL6_TPROD)
		
			_cQuery2 += " AND " + _cTabela + "_TP IN " + FormatIn(ALLTRIM(ZL6T->ZL6_TPROD),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_NTPRO)
		
			_cQuery2 += " AND " + _cTabela + "_TP NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NTPRO),";")
		
		Endif
		
		If !EMPTY(ZL6T->ZL6_GRPPRO)
		
			_cQuery2 += " AND " + _cTabela + "_GRUPO IN " + FormatIn(ALLTRIM(ZL6T->ZL6_GRPPRO),";")
		
		Endif
		
		If !EMPTY(ZL6T->ZL6_NGRPPR)
		
			_cQuery2 += " AND " + _cTabela + "_GRUPO NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NGRPPR),";")
		
		Endif
		
		If !EMPTY(ZL6T->ZL6_CONDIC)
		
			_cQuery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
		
		Endif
		
		If !EMPTY(ZL6T->ZL6_FORNEC)
		
			_cQuery2 += " AND " + _cTabela + "_FORNECE IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FORNEC),";")
		
		Endif
		
		If !EMPTY(ZL6T->ZL6_NFORNE)
		
			_cQuery2 += " AND " + _cTabela + "_FORNECE NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NFORNE),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_TNOTA)
		
			_cQuery2 += " AND " + _cTabela + "_TIPO IN " + FormatIn(ALLTRIM(ZL6T->ZL6_TNOTA),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_NTNOT)
		
			_cQuery2 += " AND " + _cTabela + "_TIPO NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NTNOT),";")
		
		Endif	 
		
		_cQuery2 += " AND " + SUBSTR(_cTabela,1,4)  + "D_E_L_E_T_ = ' '"
		_cQuery2 += " AND " + SUBSTR(_cTabela2,1,4)  + "D_E_L_E_T_ = ' '"
		

Return _cquery2

/*
===============================================================================================================================
Programa----------: MEST0092
Autor-------------: Josue Danich
Data da Criacao---: 29/10/2015
Descricao---------: Retorna query para custo gerencial de notas de saída
Parametros--------: _dinicial - data inicial de analise
						_dfinal   - data final e analise
Retorno-----------: _cquery2  - query a ser executada
===============================================================================================================================
*/ 
User function MEST0092(_dinicial,_dfinal)

Local _cquery2 := ""
Local _cTabela	:= "SD2.D2"

		_cQuery2 	:= " SELECT "
				
		_cQuery2 	+= " 			D2_COD,"
		_cQuery2 	+= " 			D2_CF,"
		If ZL6T->ZL6_TUNID == 'S'
		   _cQuery2	+= " 			D2_QTSEGUM D2_QUANT,"
		ELSE
		   _cQuery2	+= " 			D2_QUANT,"
		ENDIF
		_cQuery2 	+= " 			D2_I_FRET,"
		_cQuery2 	+= " 			D2_DOC,"
		_cQuery2 	+= " 			D2_EMISSAO,"
		_cQuery2 	+= " 			D2_TES,"
		_cQuery2 	+= " 			D2_NUMSEQ,"
		_cQuery2 	+= " 			D2_TOTAL,"
		_cQuery2 	+= " 			D2_QUANT"
			
		_cQuery2 	+= " FROM "+ RetSqlName("SD2")+ " SD2 "
							
		If EMPTY(ZL6T->ZL6_FILIS)
		
			_cQuery2 += " WHERE SD2.D2_FILIAL = '" + xfilial("SD2") + "'"
			
		Else
		
			_cQuery2 += " WHERE  SD2.D2_FILIAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";") 
		
		Endif
										
		If ALLTRIM(ZL6T->ZL6_PRXMES) == "S"
			nMonth := 1
			_dinicial := MonthSum( _dinicial , nMonth ) //Soma Meses em Uma Data
			_dfinal	  := MonthSum( _dfinal , nMonth ) //Soma Meses em Uma Data	 
		ELSEIf ALLTRIM(ZL6T->ZL6_PRXMES) == "N"
			nMonth := 1
			_dinicial := MonthSub( _dinicial , nMonth ) //diminui Meses em Uma Data
			_dfinal	  := MonthSub( _dfinal , nMonth ) //diminui Meses em Uma Data	 
		ELSEIf ALLTRIM(ZL6T->ZL6_PRXMES) == "P" .AND. ZL6->(FIELDPOS("ZL6_PERIOD")) <> 0 .AND. !EMPTY(ZL6T->ZL6_PERIOD)
		
		    _cDiaI:=LEFT(ZL6T->ZL6_PERIOD,2)
		    _cDiaF:=RIGHT(ZL6T->ZL6_PERIOD,2)
	        IF MONTH(_dinicial) = 2 
               IF VAL(_cDiaI) > 28
                  _cDiaI:="28"
               ENDIF   
               IF VAL(_cDiaF) > 28
                  _cDiaF:="28"
               ENDIF   
	        ENDIF

            IF MONTH(_dinicial) > 1
			   _dinicial := STOD(ALLTRIM(STR( YEAR(_dinicial)   )) + STRZERO((MONTH(_dinicial)-1),2)+_cDiaI)
            Else
               _dinicial := STOD(ALLTRIM(STR((YEAR(_dinicial)-1))) + "12"+_cDiaI)
            Endif
			_dfinal	     := STOD(ALLTRIM(STR( YEAR(_dfinal)     )) + STRZERO((MONTH(_dfinal)),2)+_cDiaF)
        Endif
		
		_cQuery2 += " AND " + _cTabela + "_EMISSAO BETWEEN '" + DTOS(_dinicial) + "' AND '" + DTOS(_dfinal) + "'"		
		
		IF !EMPTY(ZL6T->ZL6_CFOP)
		
			_cQuery2	+= " AND "+_cTabela+"_CF  IN "+ FormatIn(ALLTRIM(ZL6T->ZL6_CFOP),";")
		
		Endif
		
		IF !EMPTY(ZL6T->ZL6_NCFOP)
		
			_cQuery2	+= " AND "+_cTabela+"_CF  NOT IN "+ FormatIn(ALLTRIM(ZL6T->ZL6_NCFOP),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_LOCAL)
		
			_cQuery2 += " AND " + _cTabela + "_LOCAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_LOCAL),";")
		
		Endif
		
		IF !EMPTY(ZL6T->ZL6_NESTAD)
		
					_cQuery2	+= " AND "+_cTabela+"_EST  NOT IN "+ FormatIn(ALLTRIM(ZL6T->ZL6_NESTAD),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_ESTADO)
		
			_cQuery2 += " AND " + _cTabela + "_EST IN " + FormatIn(ALLTRIM(ZL6T->ZL6_ESTADO),";")
		
		Endif
	
		
		If  !EMPTY(ZL6T->ZL6_NLOCAL)
		
			_cQuery2 += " AND " + _cTabela + "_LOCAL NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NLOCAL),";")
		
		Endif
		
	
		If	!EMPTY(ZL6T->ZL6_CENTRO)
		
			_cQuery2 	+= " AND " + _cTabela + "_CCUSTO IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
		
		Endif
		
		If	!EMPTY(ZL6T->ZL6_NCENTR)
		
			_cQuery2 	+= " AND " + _cTabela + "_CCUSTO NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		
		Endif
		
		If	 !EMPTY(ZL6T->ZL6_CODPRO)
		
			_cQuery2 += " AND " + _cTabela + "_COD IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CODPRO),";")
		
		Endif
		
		If !EMPTY(ZL6T->ZL6_NCODPRO)
		
			_cQuery2 += " AND " + _cTabela + "_COD NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCODPRO),";")
		
		Endif	
	
		If  !EMPTY(ZL6T->ZL6_TPROD)
		
			_cQuery2 += " AND " + _cTabela + "_TP IN " + FormatIn(ALLTRIM(ZL6T->ZL6_TPROD),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_NTPRO)
		
			_cQuery2 += " AND " + _cTabela + "_TP NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NTPRO),";")
		
		Endif
	
		If !EMPTY(ZL6T->ZL6_GRPPRO)
		
			_cQuery2 += " AND " + _cTabela + "_GRUPO IN "+ FormatIn(ALLTRIM(ZL6T->ZL6_GRPPRO),";")
		
		Endif
		
		If !EMPTY(ZL6T->ZL6_NGRPPR)
		
			_cQuery2 += " AND " + _cTabela + "_GRUPO IN "+ FormatIn(ALLTRIM(ZL6T->ZL6_NGRPPR),";")
		
		Endif
		
		If !EMPTY(ZL6T->ZL6_FORNEC)
		
			_cQuery2 += " AND " + _cTabela + "_CLIENTE IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FORNEC),";")
		
		Endif
		
		If !EMPTY(ZL6T->ZL6_NFORNE)
		
			_cQuery2 += " AND " + _cTabela + "_CLIENTE NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NFORNE),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_TNOTA)
		
			_cQuery2 += " AND " + _cTabela + "_TIPO IN " + FormatIn(ALLTRIM(ZL6T->ZL6_TNOTA),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_NTNOT)
		
			_cQuery2 += " AND " + _cTabela + "_TIPO NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NTNOT),";")
		
		Endif
		
		If  ZL6T->ZL6_D2FRET == "S"
		
			_cQuery2 += " AND " + _cTabela + "_I_FRET <> 0"
		
		Endif
		
		
		If !EMPTY(ZL6T->ZL6_CONDIC)
		
			_cQuery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
		
		Endif
		
		
		_cQuery2 += " AND " + SUBSTR(_cTabela,1,4)  + "D_E_L_E_T_ = ' '"
		
		_cQuery2 += " ORDER BY " + _cTabela + "_DOC, " + _cTabela + "_EMISSAO"


Return _cquery2

/*
===============================================================================================================================
Programa----------: MEST0093
Autor-------------: Josue Danich
Data da Criacao---: 29/10/2015
Descricao---------: Retorna query para custo gerencial de movimentos internos
Parametros--------: _dinicial - data inicial de analise
						_dfinal   - data final e analise
Retorno-----------: _cquery2  - query a ser executada
===============================================================================================================================
*/ 
User function MEST0093(_dinicial,_dfinal)

Local _cquery2 	:= ""
Local _cTabela 	:= "SD3.D3"

		_cQuery2 	:= " SELECT "

		_cQuery2 	+= "  			D3_COD,"
		_cQuery2 	+= "  			D3_CF,"
		_cQuery2 	+= "  			D3_CC,"
		
		//Se campo TUNID = 'S' manda quantidade na segunda unidade do produto 
		
		If ZL6T->ZL6_TUNID == 'S'
		
  			_cQuery2 	+= "        (CASE WHEN (SELECT B1_CONV FROM " + RetSqlName("SB1") + " SB1 WHERE	SB1.D_E_L_E_T_ = ' ' AND 
   			_cQuery2 	+= "																		   			ROWNUM = 1 AND"
   			_cQuery2 	+= "																	          	SB1.B1_COD = SD3.D3_COD) > 0
   			_cQuery2 	+= "		THEN	
   			_cQuery2 	+= "			(CASE 	WHEN (SELECT B1_TIPCONV FROM " + RetSqlName("SB1") + " SB1 WHERE SB1.D_E_L_E_T_ = ' ' AND ROWNUM = 1 AND"
   			_cQuery2 	+= "																						SB1.B1_COD = SD3.D3_COD) = 'D'"
   			_cQuery2 	+= "				THEN (D3_QUANT / (SELECT B1_CONV FROM " + RetSqlName("SB1") + " SB1 WHERE	SB1.D_E_L_E_T_ = ' ' AND 
   			_cQuery2 	+= "																						   			ROWNUM = 1 AND"
   			_cQuery2 	+= "																						          	SB1.B1_COD = SD3.D3_COD))"   
   			_cQuery2 	+= "				ELSE (D3_QUANT * (SELECT B1_CONV FROM " + RetSqlName("SB1") + " SB1 WHERE	SB1.D_E_L_E_T_ = ' ' AND 
   			_cQuery2 	+= "																						   			ROWNUM = 1 AND"
   			_cQuery2 	+= "																					          	SB1.B1_COD = SD3.D3_COD)) 
    		_cQuery2 	+= "					END)
    		_cQuery2 	+= "  			ELSE D3_QUANT
    		_cQuery2 	+= "  			END ) QUANT, "

		Else 
		
			_cQuery2 	+= "  			D3_QUANT QUANT,"
		
		Endif
		
		_cQuery2 	+= "  			D3_CUSTO1,"
		_cQuery2 	+= "  			D3_DOC,"
		_cQuery2 	+= "			D3_EMISSAO,"
		_cQuery2 	+= "  			D3_TM,"
		_cQuery2 	+= "  			D3_NUMSEQ,"
		_cQuery2 	+= "  			D3_USUARIO,"	
		_cQuery2 	+= "  			D3_CUSTO1,"
		_cQuery2 	+= "  			D3_FILIAL,"		
		_cQuery2	+= "			D3_I_OBS"	
		
		_cQuery2 	+= "  FROM " + RetSqlName("SD3") + " SD3 "		
		
		If EMPTY(ZL6T->ZL6_FILIS)
		
			_cQuery2 += " WHERE SD3.D3_FILIAL = '" + xfilial("SD3") + "'"
			
		Else
		
			_cQuery2 += " WHERE SD3.D3_FILIAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";") 
		
		Endif
		
		If ALLTRIM(ZL6T->ZL6_PRXMES) == "S"
			nMonth := 1
			_dinicial := MonthSum( _dinicial , nMonth ) //Soma Meses em Uma Data
			_dfinal	  := MonthSum( _dfinal , nMonth ) //Soma Meses em Uma Data	 
		ELSEIf ALLTRIM(ZL6T->ZL6_PRXMES) == "N"
			nMonth := 1
			_dinicial := MonthSub( _dinicial , nMonth ) //diminui Meses em Uma Data
			_dfinal	  := MonthSub( _dfinal , nMonth ) //diminui Meses em Uma Data	 
		ELSEIf ALLTRIM(ZL6T->ZL6_PRXMES) == "P" .AND. ZL6->(FIELDPOS("ZL6_PERIOD")) <> 0 .AND. !EMPTY(ZL6T->ZL6_PERIOD)
		
		    _cDiaI:=LEFT(ZL6T->ZL6_PERIOD,2)
		    _cDiaF:=RIGHT(ZL6T->ZL6_PERIOD,2)
	        IF MONTH(_dinicial) = 2 
               IF VAL(_cDiaI) > 28
                  _cDiaI:="28"
               ENDIF   
               IF VAL(_cDiaF) > 28
                  _cDiaF:="28"
               ENDIF   
	        ENDIF

            IF MONTH(_dinicial) > 1
			   _dinicial := STOD(ALLTRIM(STR( YEAR(_dinicial)   )) + STRZERO((MONTH(_dinicial)-1),2)+_cDiaI)
            Else
               _dinicial := STOD(ALLTRIM(STR((YEAR(_dinicial)-1))) + "12"+_cDiaI) 
            Endif
			_dfinal	     := STOD(ALLTRIM(STR( YEAR(_dfinal)     )) + STRZERO((MONTH(_dfinal)),2)+_cDiaF)
        Endif
		
		_cQuery2 	+= " AND " + _cTabela + "_EMISSAO BETWEEN '" + DTOS(_dinicial) + "' AND '" + DTOS(_dfinal) + "'"
		_cQuery2 	+= " AND " + _cTabela + "_ESTORNO = ' ' "

		
		
		If  !EMPTY(ZL6T->ZL6_LOCAL)
		
			_cQuery2 += " AND " + _cTabela + "_LOCAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_LOCAL),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_NLOCAL)
		
			_cQuery2 += " AND " + _cTabela + "_LOCAL NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NLOCAL),";")
		
		Endif
		
		
		If  !EMPTY(ZL6T->ZL6_CF)
		
			_cQuery2 += " AND " + _cTabela + "_CF IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CF),";")
		
		Endif
		                    
		If  !EMPTY(ZL6T->ZL6_NCF)
		
			_cQuery2 += " AND " + _cTabela + "_CF NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCF),";")
		
		Endif
	
		
		If  !EMPTY(ZL6T->ZL6_TPMOV)
		
			_cQuery2 += " AND " + _cTabela + "_TM IN " + FormatIn(ALLTRIM(ZL6T->ZL6_TPMOV),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_NTPMOV)
		
			_cQuery2 += " AND " + _cTabela + "_TM NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NTPMOV),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_TPROD)
		
			_cQuery2 += " AND " + _cTabela + "_TIPO IN " + FormatIn(ALLTRIM(ZL6T->ZL6_TPROD),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_NTPRO)
		
			_cQuery2 += " AND " + _cTabela + "_TIPO NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NTPRO),";")
		
		Endif
		
		If	 !EMPTY(ZL6T->ZL6_CENTRO)
		
			_cQuery2 += " AND " + _cTabela + "_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
		
		Endif
		
		If	 !EMPTY(ZL6T->ZL6_NCENTR)
		
			_cQuery2 += " AND " + _cTabela + "_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		
		Endif
		
		If	!EMPTY(ZL6T->ZL6_CODPRO)
		
			_cQuery2 += " AND " + _cTabela + "_COD IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CODPRO),";")
		
		Endif
		
		If !EMPTY(ZL6T->ZL6_NCODPRO)
		
			_cQuery2 += " AND " + _cTabela + "_COD NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCODPRO),";")
		
		Endif	
	
		
		If	!EMPTY(ZL6T->ZL6_GRPPRO)
		
			_cQuery2 += " AND " + _cTabela + "_GRUPO IN " + FormatIn(ALLTRIM(ZL6T->ZL6_GRPPRO),";") 
		
		Endif
		
		If !EMPTY(ZL6T->ZL6_ORIGEM)
		
			_cQuery2 += " AND " + _cTabela + "_I_ORIGE NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_ORIGEM),";")
		
		Endif	
	
		
		If	!EMPTY(ZL6T->ZL6_NORIGE)
		
			_cQuery2 += " AND " + _cTabela + "_I_ORIGE NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NORIGE),";") 
		
		Endif
		
		
		If	!EMPTY(ZL6T->ZL6_NGRPPR)
		
			_cQuery2 += " AND " + _cTabela + "_GRUPO NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NGRPPR),";") 
		
		Endif
		
		If	ZL6T->ZL6_D3OBS == 'S'
		
			_cQuery2 += " AND " + _cTabela + "_I_OBS <> ''"
		
		Endif
	
		
		If !EMPTY(ZL6T->ZL6_CONDIC)
		
			_cQuery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
		
		Endif
		
		_cQuery2 	+= " AND " + SUBSTR(_cTabela,1,4) + "D_E_L_E_T_ = ' '"
		
		_cQuery2 += " ORDER BY " + _cTabela + "_DOC, " + _cTabela + "_EMISSAO"


Return _cquery2 


/*
===============================================================================================================================
Programa----------: MEST9MGE
Autor-------------: Alex Wallauer
Data da Criacao---: 03/01/2019
Descricao---------: 
Parametros--------: _dinicial - data inicial de analise
					_dfinal   - data final e analise
Retorno-----------: 
===============================================================================================================================
*/ 
User function MEST9MGE(_dinicial,_dfinal)

Local _cQueryW 	:= ""
Local _cquery2 	:= ""
//Local _cTabela 	:= "SD3.D3"

		_cQuery2 	:= " SELECT "
  		_cQuery2 	+= " (SUM(SD3.D3_QUANT)* B1_PESO) QTDEMKGS FROM " + RetSqlName("SD3") + " SD3 JOIN " + RetSqlName("SB1") + " ON D3_COD = B1_COD "
		
		If EMPTY(ZL6T->ZL6_FILIS)
		
			_cQuery2 += " WHERE SD3.D3_FILIAL = '" + xfilial("SD3") + "'"
			
		Else
		
			_cQuery2 += " WHERE SD3.D3_FILIAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";") 
		
		Endif
		
		_cQuery2 	+= " AND SD3.D3_EMISSAO BETWEEN '" + DTOS(_dinicial) + "' AND '" + DTOS(_dfinal) + "'"
		_cQuery2 	+= " AND SD3.D3_ESTORNO <> 'S' "

		If  !EMPTY(ZL6T->ZL6_LOCAL)
		
			_cQuery2 += " AND " + "SD3.D3" + "_LOCAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_LOCAL),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_NLOCAL)
		
			_cQuery2 += " AND " + "SD3.D3" + "_LOCAL NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NLOCAL),";")
		
		Endif
		
		
		If  !EMPTY(ZL6T->ZL6_CF)
		
			_cQuery2 += " AND " + "SD3.D3" + "_CF IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CF),";")
		
		Endif
		                    
		
		If	 !EMPTY(ZL6T->ZL6_CENTRO)
		
			_cQuery2 += " AND " + "SD3.D3" + "_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
		
		Endif
		
		If	 !EMPTY(ZL6T->ZL6_NCENTR)
		
			_cQuery2 += " AND " + "SD3.D3" + "_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		
		Endif
		
		
		
		If !EMPTY(ZL6T->ZL6_CONDIC)
		
			_cQuery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
		
		Endif
		
		_cQuery2 	+= " AND SD3.D_E_L_E_T_ = ' '"
		

		If	!EMPTY(ZL6T->ZL6_CODPRO)
		
			_cQueryW := " AND SD3.D3_COD IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CODPRO),";")+" GROUP BY B1_PESO "
		
		Endif		

MPSysOpenQuery( _cQuery2+_cQueryW ,"SD2T" ) 

_nQuantI:=SD2T->QTDEMKGS

SD2T->( DbClosearea() )

//_cTeste:=_cQuery2+_cQueryW
//_cTeste+=ENTER
//_cTeste:=STR(_nQuantI,20,6)
//_cTeste+=ENTER

If	!EMPTY(ZL6T->ZL6_GRPPRO)
	_cQueryW :=  " AND SD3.D3_GRUPO IN " + FormatIn(ALLTRIM(ZL6T->ZL6_GRPPRO),";")+" GROUP BY B1_PESO "
Endif
		
MPSysOpenQuery( _cQuery2+_cQueryW ,"SD2T" ) 

//_cTeste+=_cQuery2+_cQueryW
//_cTeste+=ENTER

_nQuantT:=0
DO WHILE SD2T->(!EOF())
   _nQuantT+=SD2T->QTDEMKGS
//  _cTeste+=STR(SD2T->QTDEMKGS,20,6)
//  _cTeste+=ENTER
   SD2T->(DBSKIP())
ENDDO 

SD2T->( DbClosearea() )

//_cTeste:=STRTRAN(_cTeste,".",",")
//_cFileNome:=_cdir+"\MEST009_GORDA_"+xFilial("ZL6")+"_"+STRTRAN(TIME(),":","_")+".CSV"
//MemoWrite(_cFileNome,_cTeste)

Return {_nQuantI , _nQuantT , (_nQuantI/_nQuantT) }


/*
===============================================================================================================================
Programa----------: MEST0094
Autor-------------: Josue Danich
Data da Criacao---: 29/10/2015
Descricao---------: Retorna query para custo gerencial de financeiro
Parametros--------: _dinicial - data inicial de analise
						_dfinal   - data final e analise
Retorno-----------: _cquery2  - query a ser executada
===============================================================================================================================
*/ 
User function MEST0094(_dinicial,_dfinal)

Local _cquery2 := ""
_cQuery2 := " SELECT "

If ZL6T->ZL6_RPA == '2' .OR. ZL6T->ZL6_RPA == '3'

	If ALLTRIM(ZL6T->ZL6_PRXMES) == "S"
	   nMonth := 1
	   _dinicial := MonthSum( _dinicial , nMonth ) //Soma Meses em Uma Data
	   _dfinal	  := MonthSum( _dfinal , nMonth ) //Soma Meses em Uma Data	 
	ELSEIf ALLTRIM(ZL6T->ZL6_PRXMES) == "N"
	   nMonth := 1
	   _dinicial := MonthSub( _dinicial , nMonth ) //diminui Meses em Uma Data
	   _dfinal	  := MonthSub( _dfinal , nMonth ) //diminui Meses em Uma Data	 

	ELSEIf ALLTRIM(ZL6T->ZL6_PRXMES) == "P" .AND. ZL6->(FIELDPOS("ZL6_PERIOD")) <> 0 .AND. !EMPTY(ZL6T->ZL6_PERIOD)
		
	    _cDiaI:=LEFT(ZL6T->ZL6_PERIOD,2)
	    _cDiaF:=RIGHT(ZL6T->ZL6_PERIOD,2)
        IF MONTH(_dinicial) = 2 
           IF VAL(_cDiaI) > 28
              _cDiaI:="28"
           ENDIF   
           IF VAL(_cDiaF) > 28
              _cDiaF:="28"
           ENDIF   
        ENDIF

        IF MONTH(_dinicial) > 1
		   _dinicial := STOD(ALLTRIM(STR( YEAR(_dinicial)   )) + STRZERO((MONTH(_dinicial)-1),2)+_cDiaI)
        Else
           _dinicial := STOD(ALLTRIM(STR((YEAR(_dinicial)-1))) + "12"+_cDiaI) 
        Endif
		_dfinal	     := STOD(ALLTRIM(STR( YEAR(_dfinal)     )) + STRZERO((MONTH(_dfinal)),2)+_cDiaF)

    Endif

EndIf

If ZL6T->ZL6_RPA == '2'//CAIXINHA

	_cQuery2 += "	EU_VALOR VALOR,"
	_cQuery2 += "	EU_NUM     ,  "
	_cQuery2 += "	EU_NRCOMP  ,  "
	_cQuery2 += "	EU_EMISSAO ,  "
	_cQuery2 += "	EU_DTDIGIT ,  "
	_cquery2 += " 	EU_FILIAL  ,  "
	_cquery2 += " 	EU_HISTOR  ,  "
	_cquery2 += " 	EU_BAIXA   ,  "
	_cquery2 += " 	EU_BENEF AS FORNEC "
	_cQuery2 += "	FROM " + RETSQLNAME("SEU") + "  SEU "
	
	If EMPTY(ZL6T->ZL6_FILIS)
		
		_cQuery2 += " WHERE SEU.EU_FILIAL = '" + xfilial("SEU")+ "'
	Else
		
		_cQuery2 += " WHERE SEU.EU_FILIAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";")
	Endif

	_cQuery2 += " 	AND SEU.EU_DTDIGIT BETWEEN '" + DTOS(_dinicial) + "' AND '" + DTOS(_dfinal) + "'" 
	_cQuery2 += " 	AND SEU.D_E_L_E_T_ = ' '"
		
	If !EMPTY(ZL6T->ZL6_CONDIC)
		
		_cQuery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
		
	Endif

	_cQuery2 += " ORDER BY EU_NRCOMP, EU_DTDIGIT "

   Return _cquery2 

ElseIf ZL6T->ZL6_RPA == '3' //COMISSAO

	_cQuery2 += "	E3_COMIS VALOR,"
	_cQuery2 += "	E3_NUM     ,  "
	_cQuery2 += "	E3_EMISSAO ,  "
	_cQuery2 += "	E3_DATA    ,  "
	_cquery2 += " 	E3_FILIAL  ,  "
	_cquery2 += " 	E3_VEND    ,  "
	_cquery2 += " 	A3_NOME       "

	_cQuery2 += "	FROM " + RETSQLNAME("SE3") + "  SE3 "
	_cQuery2 += "    JOIN " + RetSqlName("SA3") + " SA3 ON SA3.A3_COD = SE3.E3_VEND AND SA3.D_E_L_E_T_ = ' ' "

	If EMPTY(ZL6T->ZL6_FILIS)
		
		_cQuery2 += " WHERE SE3.E3_FILIAL = '" + xfilial("SE3")+ "'
	Else
		
		_cQuery2 += " WHERE SE3.E3_FILIAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";")
	Endif
	
	_cQuery2 += " 	AND SE3.E3_EMISSAO BETWEEN '" + DTOS(_dinicial) + "' AND '" + DTOS(_dfinal) + "'" 
	_cQuery2 += " 	AND SE3.D_E_L_E_T_ = ' '"
		
	If !EMPTY(ZL6T->ZL6_CONDIC)
		
		_cQuery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
		
	Endif

	_cQuery2 += " ORDER BY E3_NUM, E3_DATA "
	Return _cquery2
ENDIF
	
		
If ZL6T->ZL6_TXFIN == 'S' .and. !ZL6T->ZL6_RPA $ '1,2,3'
				
	_cQuery2 += " 			E2_VALOR + 
	_cQuery2 += "           NVL((SELECT SUM(E2_VALOR) FROM " + RETSQLNAME("SE2") + " TE22  WHERE 	TE22.D_E_L_E_T_ = ' ' AND"
	_cQuery2 += " 				         			                                        SE2.E2_FILIAL = TE22.E2_FILIAL AND"
	_cQuery2 += " 				         			                                        SE2.E2_TIPO = SUBSTR(TE22.E2_TITPAI,15,3) AND"
	_cQuery2 += " 				         			                                        SE2.E2_NUM = SUBSTR(TE22.E2_TITPAI,4,9) AND"
	_cQuery2 += " 				         			                                        SE2.E2_PREFIXO = SUBSTR(TE22.E2_TITPAI,1,3) AND"
	_cQuery2 += " 				         			                                        SE2.E2_PARCELA = SUBSTR(TE22.E2_TITPAI,13,2) AND"
	_cQuery2 += " 				         			                                        SE2.E2_FORNECE = SUBSTR(TE22.E2_TITPAI,18,6)),0) VALOR, "
	_cQuery2 += " 			E2_NUM AS E5_NUMERO,"
	_cQuery2 += "		 	E2_NATUREZ AS E5_NATUREZ,"
	_cQuery2 += "			E2_EMISSAO AS E5_DATA,"		
	_cQuery2 += "			E2_USERLGI AS E5_USERLGI,"	
	_cQuery2 += "			E2_USERLGA AS E5_USERLGA,"
	_cQuery2 += "			E2_FORNECE AS FORNEC, "
	_cQuery2 += " 			E2_HIST,"
	_cQuery2 += " 			E2_FILIAL "	
     
   	_cQuery2 += "			FROM " + RETSQLNAME("SE2") + "  SE2"
 			
			
	If EMPTY(ZL6T->ZL6_FILIS)
			
		_cQuery2 += " WHERE SE2.D_E_L_E_T_ = ' ' AND SE2.E2_FILIAL = '" + xfilial("SE5") + "'"
			
	Else
		
		_cQuery2 += " WHERE SE2.D_E_L_E_T_ = ' ' AND SE2.E2_FILIAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";")
		
	Endif
	
	If ALLTRIM(ZL6T->ZL6_PRXMES) == "S"
	   nMonth := 1
	   _dinicial := MonthSum( _dinicial , nMonth ) //Soma Meses em Uma Data
	   _dfinal	  := MonthSum( _dfinal , nMonth ) //Soma Meses em Uma Data	 
	ELSEIf ALLTRIM(ZL6T->ZL6_PRXMES) == "N"
	   nMonth := 1
	   _dinicial := MonthSub( _dinicial , nMonth ) //diminui Meses em Uma Data
	   _dfinal	  := MonthSub( _dfinal , nMonth ) //diminui Meses em Uma Data	 

	ELSEIf ALLTRIM(ZL6T->ZL6_PRXMES) == "P" .AND. ZL6->(FIELDPOS("ZL6_PERIOD")) <> 0 .AND. !EMPTY(ZL6T->ZL6_PERIOD)
		
	    _cDiaI:=LEFT(ZL6T->ZL6_PERIOD,2)
	    _cDiaF:=RIGHT(ZL6T->ZL6_PERIOD,2)
        IF MONTH(_dinicial) = 2 
           IF VAL(_cDiaI) > 28
              _cDiaI:="28"
           ENDIF   
           IF VAL(_cDiaF) > 28
              _cDiaF:="28"
           ENDIF   
        ENDIF

        IF MONTH(_dinicial) > 1
		   _dinicial := STOD(ALLTRIM(STR( YEAR(_dinicial)   )) + STRZERO((MONTH(_dinicial)-1),2)+_cDiaI)
        Else
           _dinicial := STOD(ALLTRIM(STR((YEAR(_dinicial)-1))) + "12"+_cDiaI) 
        Endif
		_dfinal	     := STOD(ALLTRIM(STR( YEAR(_dfinal)     )) + STRZERO((MONTH(_dfinal)),2)+_cDiaF)
    Endif
	
	If ALLTRIM(ZL6T->ZL6_VENCTO) == "S"
	
		_cQuery2 += " 	AND SE2.E2_VENCTO BETWEEN '" + DTOS(_dinicial) + "' AND '" + DTOS(_dfinal) + "'"
				
	ELSEIf ALLTRIM(ZL6T->ZL6_VENCTO) == "D"

		_cQuery2 += " AND SE2.E2_MOVIMEN BETWEEN '" + DTOS(_dinicial)+ "' AND '" + DTOS(_dfinal) + "'"

	Else
	
		_cQuery2 += " 	AND SE2.E2_EMISSAO BETWEEN '" + DTOS(_dinicial) + "' AND '" + DTOS(_dfinal) + "'"
		
	Endif  	
		
	If	!EMPTY(ZL6T->ZL6_NATURE)
		
		_cQuery2 += " AND SE2.E2_NATUREZ IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NATURE),";")
		
	Endif
		
	If	!EMPTY(ZL6T->ZL6_NNATUR)
		
		_cQuery2 += " AND SE2.E2_NATUREZ NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NNATUR),";")
		
	Endif
		
		
	If	!EMPTY(ZL6T->ZL6_E5PREF)
		
		_cQuery2 += " AND SE2.E2_PREFIXO IN " + FormatIn(ALLTRIM(ZL6T->ZL6_E5PREF),";")
		
	Endif
		
	If	!EMPTY(ZL6T->ZL6_NE5PRE)
		
		_cQuery2 += " AND SE2.E2_PREFIXO NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NE5PRE),";")
		
	Endif
		
	If	!EMPTY(ZL6T->ZL6_E5TIPO)
		
		_cQuery2 += " AND SE2.E2_TIPO IN " + FormatIn(ALLTRIM(ZL6T->ZL6_E5TIPO),";")
		
	Endif
		
	If	!EMPTY(ZL6T->ZL6_NE5TIP)
		
		_cQuery2 += " AND SE2.E2_TIPO NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NE5TIP),";")
		
	Endif
		
	If	!EMPTY(ZL6T->ZL6_E5BENE)
		
		_cQuery2 += " AND SE2.E2_BENEF LIKE '%" + ALLTRIM(ZL6T->ZL6_E5BENE) + "%'"
		
	Endif
		
	If	!EMPTY(ZL6T->ZL6_NE5BEN)
		
		_cQuery2 += " AND SE2.E2_BENEF NOT LIKE '%" + ALLTRIM(ZL6T->ZL6_NE5BEN) + "%'"
		
	Endif
		
		
	If !EMPTY(ZL6T->ZL6_FORNEC)
		
		_cQuery2 += " AND " +  "SE2.E2_FORNECE IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FORNEC),";")
		
	Endif
		
	If !EMPTY(ZL6T->ZL6_NFORNE)
		
		_cQuery2 += " AND "  + "SE2.E2_FORNECE NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NFORNE),";")
		
	Endif
	
		
	If !EMPTY(ZL6T->ZL6_CONDIC)
		
		_cQuery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
		
	Endif
	
	_cQuery2 += " ORDER BY SE2.E2_NUM, SE2.E2_EMISSAO"
	
Elseif !ZL6T->ZL6_RPA $ '1,2,3'	
		
		
	_cQuery2 += " 			E5_VALOR VALOR,"
	_cQuery2 += " 			E5_NUMERO,"
	_cQuery2 += "			E5_NATUREZ,"
	_cQuery2 += "			E5_DATA,"		
	_cQuery2 += "			E5_USERLGI,"	
	_cQuery2 += "			E5_USERLGA,"
	_cQuery2 += "			E5_FILIAL,"
	_cQuery2 += "			E5_HISTOR,"
	_cQuery2 += "			E5_CLIFOR AS FORNEC  "
			
       
	_cQuery2 += "			FROM " + RETSQLNAME("SE5") + "  SE5 
				
		
	If EMPTY(ZL6T->ZL6_FILIS)
		
		_cQuery2 += " WHERE SE5.E5_FILIAL = '" + xfilial("SE5")+ "'

	Else
		
		_cQuery2 += " WHERE SE5.E5_FILIAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";")	//+ " AND SE2.E2_FILIAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";")
	Endif
		
	If ALLTRIM(ZL6T->ZL6_PRXMES) == "S"
	   nMonth := 1
	   _dinicial := MonthSum( _dinicial , nMonth ) //Soma Meses em Uma Data
	   _dfinal	  := MonthSum( _dfinal , nMonth ) //Soma Meses em Uma Data	 
	ELSEIf ALLTRIM(ZL6T->ZL6_PRXMES) == "N"
	   nMonth := 1
	   _dinicial := MonthSub( _dinicial , nMonth ) //diminui Meses em Uma Data
	   _dfinal	  := MonthSub( _dfinal , nMonth ) //diminui Meses em Uma Data	 
	ELSEIf ALLTRIM(ZL6T->ZL6_PRXMES) == "P" .AND. ZL6->(FIELDPOS("ZL6_PERIOD")) <> 0 .AND. !EMPTY(ZL6T->ZL6_PERIOD)
		
	    _cDiaI:=LEFT(ZL6T->ZL6_PERIOD,2)
	    _cDiaF:=RIGHT(ZL6T->ZL6_PERIOD,2)
        IF MONTH(_dinicial) = 2 
           IF VAL(_cDiaI) > 28
              _cDiaI:="28"
           ENDIF   
           IF VAL(_cDiaF) > 28
              _cDiaF:="28"
           ENDIF   
        ENDIF

        IF MONTH(_dinicial) > 1
		   _dinicial := STOD(ALLTRIM(STR( YEAR(_dinicial)   )) + STRZERO((MONTH(_dinicial)-1),2)+_cDiaI)
        Else
           _dinicial := STOD(ALLTRIM(STR((YEAR(_dinicial)-1))) + "12"+_cDiaI) 
        Endif
		_dfinal	     := STOD(ALLTRIM(STR( YEAR(_dfinal)     )) + STRZERO((MONTH(_dfinal)),2)+_cDiaF)

    Endif
	
	_cQuery2 += " 	AND SE5.E5_DATA BETWEEN '" + DTOS(_dinicial) + "' AND '" + DTOS(_dfinal) + "'" 
	_cQuery2 += " 	AND SE5.E5_LA = 'S'"
	_cQuery2 += " 	AND SE5.E5_TIPODOC <> 'EST' "
	_cQuery2 += " 	AND SE5.D_E_L_E_T_ = ' ' "
	_cQuery2 += " 	AND SE5.E5_SITUACA <> 'C' "
		
	If	!EMPTY(ZL6T->ZL6_NATURE)
		
		_cQuery2 += " AND SE5.E5_NATUREZ IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NATURE),";")
		
	Endif
		
	If	!EMPTY(ZL6T->ZL6_NNATUR)
		
		_cQuery2 += " AND SE5.E5_NATUREZ NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NNATUR),";")
		
	Endif
		
	If	!EMPTY(ZL6T->ZL6_E5PREF)
		
		_cQuery2 += " AND SE5.E5_PREFIXO IN " + FormatIn(ALLTRIM(ZL6T->ZL6_E5PREF),";")
		
	Endif
		
	If	!EMPTY(ZL6T->ZL6_NE5PRE)
		
		_cQuery2 += " AND SE5.E5_PREFIXO NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NE5PRE),";")
		
	Endif
		
	If	!EMPTY(ZL6T->ZL6_E5TIPO)
		
		_cQuery2 += " AND SE5.E5_TIPO IN " + FormatIn(ALLTRIM(ZL6T->ZL6_E5TIPO),";")
		
	Endif
		
	If	!EMPTY(ZL6T->ZL6_NE5TIP)
		
		_cQuery2 += " AND SE5.E5_TIPO NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NE5TIP),";")
		
	Endif
		
	If	!EMPTY(ZL6T->ZL6_E5BENE)
		
		_cQuery2 += " AND SE5.E5_BENEF LIKE '%" + ALLTRIM(ZL6T->ZL6_E5BENE) + "%'"
		
	Endif
		
	If	!EMPTY(ZL6T->ZL6_NE5BEN)
		
		_cQuery2 += " AND SE5.E5_BENEF NOT LIKE '%" + ALLTRIM(ZL6T->ZL6_NE5BEN) + "%'"
		
	Endif
		
	If !EMPTY(ZL6T->ZL6_FORNEC)
		
		_cQuery2 += " AND SE5.E5_CLIFOR IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FORNEC),";")
		
	Endif
		
	If !EMPTY(ZL6T->ZL6_NFORNE)
		
		_cQuery2 += " AND SE5.E5_CLIFOR NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NFORNE),";")
		
	Endif
		
	If !EMPTY(ZL6T->ZL6_CONDIC)
		
		_cQuery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
		
	Endif
		
	_cQuery2 += " ORDER BY SE5.E5_NUMERO, SE5.E5_DATA"
		
Endif

Return _cquery2 

/*
===============================================================================================================================
Programa----------: MEST0095
Autor-------------: Josue Danich
Data da Criacao---: 29/10/2015
Descricao---------: Retorna query para custo gerencial de perdas por op
Parametros--------: _dinicial - data inicial de analise
						_dfinal   - data final e analise
Retorno-----------: _cquery2  - query a ser executada
===============================================================================================================================
*/ 
User function MEST0095(_dinicial,_dfinal)

Local _cquery2 	:= ""
Local _cTabela 	:= "SBC.BC"


		_cQuery2 	:= " SELECT "
		
		_cQuery2 	+= " 			 BC_PRODUTO,"
		_cQuery2 	+= " 			 BC_I_NPROD,"
		If ZL6T->ZL6_TUNID == 'S'
		   _cQuery2	+= " 			BC_QTSEGUM BC_QUANT,"
		ELSE
		   _cQuery2	+= " 			BC_QUANT,"
		ENDIF
		_cQuery2 	+= " 			 BC_I_CUSTO,"
		_cQuery2 	+= " 			 BC_OP,"
		_cQuery2 	+= " 			 BC_CC,"
		_cQuery2 	+= " 			 BC_DATA,"
		_cQuery2 	+= " 			 BC_NUMSEQ,"
		_cQuery2 	+= " 			 BC_FILIAL "
		
		_cQuery2 	+= " FROM " + RetSqlName("SBC") + " SBC "
		
		If EMPTY(ZL6T->ZL6_FILIS)
		
			_cQuery2 += " WHERE SBC.BC_FILIAL = '" + xfilial("SBC") + "'"
			
		Else
		
			_cQuery2 += " WHERE SBC.BC_FILIAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";") 
		
		Endif
		
	If ALLTRIM(ZL6T->ZL6_PRXMES) == "S"
	   nMonth := 1
	   _dinicial := MonthSum( _dinicial , nMonth ) //Soma Meses em Uma Data
	   _dfinal	  := MonthSum( _dfinal , nMonth ) //Soma Meses em Uma Data	 
	ELSEIf ALLTRIM(ZL6T->ZL6_PRXMES) == "N"
	   nMonth := 1
	   _dinicial := MonthSub( _dinicial , nMonth ) //diminui Meses em Uma Data
	   _dfinal	  := MonthSub( _dfinal , nMonth ) //diminui Meses em Uma Data	 

	ELSEIf ALLTRIM(ZL6T->ZL6_PRXMES) == "P" .AND. ZL6->(FIELDPOS("ZL6_PERIOD")) <> 0 .AND. !EMPTY(ZL6T->ZL6_PERIOD)
		
	    _cDiaI:=LEFT (ZL6T->ZL6_PERIOD,2)
	    _cDiaF:=RIGHT(ZL6T->ZL6_PERIOD,2)
	    IF MONTH(_dinicial) = 2 
           IF VAL(_cDiaI) > 28
              _cDiaI:="28"
           ENDIF   
           IF VAL(_cDiaF) > 28
              _cDiaF:="28"
           ENDIF   
	    ENDIF

        IF MONTH(_dinicial) > 1
		   _dinicial := STOD(ALLTRIM(STR( YEAR(_dinicial)   )) + STRZERO((MONTH(_dinicial)-1),2)+_cDiaI)
        Else
           _dinicial := STOD(ALLTRIM(STR((YEAR(_dinicial)-1))) + "12"+_cDiaI) 
        Endif
		_dfinal	     := STOD(ALLTRIM(STR( YEAR(_dfinal)     )) + STRZERO((MONTH(_dfinal)),2)+_cDiaF)

    Endif
		
		_cQuery2 	+= " AND " + SUBSTR(_cTabela,1,4) + "D_E_L_E_T_ = ' '"
		_cQuery2 	+= " AND " + _cTabela + "_DATA BETWEEN '" + DTOS(_dinicial) + "' AND '" + DTOS(_dfinal) + "'"		
			
		If !EMPTY(ZL6T->ZL6_CODPRO)
		
			_cQuery2 += " AND " + _cTabela + "_PRODUTO IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CODPRO),";")
		
		Endif	
		
		If !EMPTY(ZL6T->ZL6_NCODPRO)
		
			_cQuery2 += " AND " + _cTabela + "_PRODUTO NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCODPRO),";")
		
		Endif	
		
		If !EMPTY(ZL6T->ZL6_CENTRO)
		
			_cQuery2 += " AND (SELECT C2_CC FROM " + RetSqlName("SC2") + " SC2 WHERE SC2.C2_FILIAL = SBC.BC_FILIAL
			_cQuery2 += " 																	AND SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN = SBC.BC_OP"
			_cQuery2 += " 																	AND ROWNUM = 1)  IN  " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
		
		Endif	
		
		If !EMPTY(ZL6T->ZL6_NCENTR)
		
			_cQuery2 += " AND (SELECT C2_CC FROM " + RetSqlName("SC2") + " SC2 WHERE SC2.C2_FILIAL = SBC.BC_FILIAL
			_cQuery2 += " 																	AND SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN = SBC.BC_OP"
			_cQuery2 += " 																	AND ROWNUM = 1)  NOT IN  " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
	
		Endif	
		
			
		If !EMPTY(ZL6T->ZL6_CONDIC)
		
			_cQuery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
		
		Endif
			
		_cQuery2 += " ORDER BY " + _cTabela + "_OP, " + _cTabela + "_DATA"

Return _cquery2   

/*
===============================================================================================================================
Programa----------: MEST0096
Autor-------------: Josue Danich
Data da Criacao---: 29/10/2015
Descricao---------: Retorna query para custo gerencial de mao de obra
Parametros--------: _dinicial - data inicial de analise
						_dfinal   - data final e analise
Retorno-----------: _cquery2  - query a ser executada
===============================================================================================================================
*/ 
User function MEST0096(_dinicial,_dfinal)

Local _cquery2 	:= ""
Local _cQueryQ 	:= ""
Local _cquery	:= ""
//Local _cTabela 	:= "SRD.RD"
Local _cQuery1	:= ""
Local _cFecham	:= ""
Local _nQuant 	:= 0
Local _nValor   := 0
Local _nip,VV
Local _cDIncial := ALLTRIM(STR(YEAR(_dinicial)))+ STRZERO(MONTH(_dinicial),2)
Local _cDFinal	:= ALLTRIM(STR(YEAR(_dfinal)))+ STRZERO(MONTH(_dfinal),2)
Local _cFER:=U_ITGetMV("IT_FERIAS","11.107")//"11.107" //FÉRIAS	           11,107% - [Fixo]   
Local _cEFE:=0//U_ITGetMV("IT_EFERIA","04.130")//"4.13"   //Encargos sob Férias	4,130% - [Fixo]  
Local _c13S:=U_ITGetMV("IT_13SALA","08.330")//"8.33"   //13º SALARIO	        8,330% - [Fixo]
Local _cE13:=0//U_ITGetMV("IT_E13SAL","00.000")//"0"      //"3.10"   //Encargos sob 13º	3,100% - [Fixo]
LOCAL _cValores:= ""
//Local _cEST:="15.241" //VALOR_ESTAG        15.241% - [Fixo]

_cFER:=IF(EMPTY(_cFER),"11.107",_cFER)//"11.107" //FÉRIAS	           11,107% - [Fixo]   
_c13S:=IF(EMPTY(_c13S),"08.330",_c13S)//"8.33"   //13º SALARIO	        8,330% - [Fixo]

//=================================================================================================		
//Buscar data do ultimo fechamento  
//=================================================================================================

	_cQuery1 := " SELECT MAX(RD_DATARQ) AS ULTF FROM " + RETSQLNAME("SRD") + " SRD "
	_cQuery1 += " WHERE SRD.D_E_L_E_T_ = ' ' "
	_cQuery1 += " AND RD_FILIAL = '" + xFilial("SRD") + "'"
	_cQuery1 += " AND RD_ROTEIR = 'FOL' "
	
//	TcQuery _cquery1 New Alias SRDU
    MPSysOpenQuery( _cquery1 ,"SRDU" ) 
    DBSelectArea("SRDU")

    _cValores+=_cquery1+ENTER

   If !(SRDU->( Eof() ))
   	  _cFecham := SRDU->ULTF
      _cValores+="MAX(RD_DATARQ): "+_cFecham+ENTER+ENTER
   Endif		
   
   SRDU->( DbClosearea() )

//=================================================================================================		
//Prepara array com filiais para montar o union de queries de rh 
//=================================================================================================		
_afiliais := {}

If !(EMPTY(ZL6T->ZL6_FILIS))

	_nip := 1
	Do while _nip + 1 <= len(alltrim(ZL6T->ZL6_FILIS))
			
			aadd(_afiliais,substr(alltrim(ZL6T->ZL6_FILIS),_nip,2))
		
		_nip := _nip + 3
		
	Enddo
Else
	aadd(_afiliais, xfilial("SRA"))	

Endif

//=================================================================================================		
//Essa query e fixa e nao retorna valores para o relatorio analítico, somente retorna o total 
// do custo de mao de obra da filial e quantidade de funcionarios ativos
// Vai montar uma querie para cada filial fazendo union entre todas para dar a somatória final
//=================================================================================================
_cFilsemSRX := ""
_nip := 1
FOR _nip := 1 TO LEN(_afiliais)

   //Busca Impostos - INSS, RAT(ACT), FGTS
   _cquery := " SELECT SUBSTR(RCC_CONTEU,2,7) AS INSS, SUBSTR(RCC_CONTEU,12,6) AS ACT, SUBSTR(RCC_CONTEU,26,6) AS FGTS
   _cquery += " FROM " + RETSQLNAME("RCC") + " RCC "
   _cquery += " WHERE RCC.D_E_L_E_T_ = ' ' "
   _cquery += " AND RCC_CODIGO = 'S037' "
   _cquery += " AND SUBSTR(RCC_CONTEU,1,1) = '1'"
   _cquery += " AND SUBSTR(RCC_FIL,1,2) = '" +_afiliais[_nip] + "'"
   _cquery += " AND RCC_CHAVE = '"+SUBSTR(DTOS(_dInicial),1,6)+"'"

   MPSysOpenQuery( _cquery ,"SRXT" ) 
   DBSelectArea("SRXT")

   If !(SRXT->( Eof() ))
		

	  _nInss 	:= alltrim(SRXT->INSS)
	  _nAct	 	:= alltrim(SRXT->ACT)
	  _nFgts	:= alltrim(SRXT->FGTS) //VALOR_SM
	
   Else

      _cFilsemSRX += _afiliais[_nip]+", "
      
	  _nInss:= "0"
      _nAct	:= "0"
	  _nFgts:= "0"
				
   Endif

   SRXT->( DbClosearea() )
   
   //Busca Impostos - TERCEIROS
   _cquery := " SELECT SUBSTR(RCC_CONTEU,7,6) AS TERC "
   _cquery += " FROM " + RETSQLNAME("RCC") + " RCC "
   _cquery += " WHERE RCC.D_E_L_E_T_ = ' ' "
   _cquery += " AND RCC_CODIGO = 'S038' "
   _cquery += " AND SUBSTR(RCC_FIL,1,2) = '" +_AFILIAIS[_nip] + "'"
   _cquery += " AND (SUBSTR(RCC_CHAVE,13,6) = '"+SUBSTR(DTOS(_dInicial),1,6)+"'"
   _cquery += "      OR  RCC_CHAVE = ' ') ORDER BY RCC_CHAVE DESC "                   

   MPSysOpenQuery( _cquery ,"SRXV" ) 
   DBSelectArea("SRXV")
   DBGOTOP()

   If !(SRXV->( Eof() ))
	  _nTerc:= alltrim(SRXV->TERC)
   ENDIF
   IF EMPTY(_nTerc)
	  _nTerc:= "0"
   Endif		
   
   SRXV->( DbClosearea() )

   _cEFE:=(VAL(_nInss)+VAL(_nFgts)+VAL(_nTerc)+VAL(_nAct))*(VAL(_cFER))/100 //Encargos sob Férias	
   _cE13:=(VAL(_nInss)+VAL(_nFgts)+VAL(_nTerc)+VAL(_nAct))*(VAL(_c13S))/100 //Encargos sob 13º	

   _cDC :=VAL(_nInss)+VAL(_nFgts)+VAL(_nTerc)+VAL(_nAct) //VALOR_DC - 37,22
   _cDC :=STR(_cDC,7,3) //VALOR_DC - 37,22
 
   _cSMT:=VAL(_nInss)+VAL(_cFER) +_cEFE +VAL(_nFgts)+VAL(_nTerc)+VAL(_nAct)//VALOR_SMT - 52.46336
   _cSMT:=STR(_cSMT,7,3)//VALOR_SMT - 52.46336
   
   _cEST:=VAL(_cFER) +_cEFE
   _cEST:=STR(_cEST,7,3)

//Quantidade de funcionários ativos
	_cQueryQ 	:= " SELECT  COUNT(RA_FILIAL)  QUANT "+ENTER
	_cQueryQ 	+= "             FROM " + RETSQLNAME("SRA") + " WHERE "+ENTER
	_cQueryQ 	+= "                          D_E_L_E_T_ = ' ' AND   "+ENTER
	_cQueryQ 	+= "                          RA_FILIAL = '" + _afiliais[_nip] + "' AND "+ENTER
	_cQueryQ 	+= "                          (RA_CATFUNC = 'M' OR RA_CATFUNC = 'E' OR RA_CATFUNC = 'H') AND "+ENTER
	_cQueryQ 	+= "                          RA_ADMISSA <= '"+DTOS(_dfinal)+"'  AND "+ENTER
	_cQueryQ 	+= "                          (RA_DEMISSA = ' ' OR RA_DEMISSA > '"+DTOS(_dfinal)+"')  "+ENTER
    If !EMPTY(ZL6T->ZL6_CENTRO)		
	    _cQueryQ += " AND RA_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
	Endif
	If !EMPTY(ZL6T->ZL6_NCENTR)
	   _cQueryQ  += " AND RA_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
	Endif

   MPSysOpenQuery( _cQueryQ , "QUANTF" ) 
   DBSelectArea("QUANTF")
   DBGOTOP()
   _cValores+=_cQueryQ+ENTER

   If !(QUANTF->( Eof() ))
       _nQuant+=QUANTF->QUANT
      _cValores+=_afiliais[_nip]+" / "+"QUANTIDADE: "+STR(QUANTF->QUANT,22,7)+ENTER+ENTER
   ENDIF
   
   QUANTF->( DbClosearea() )   
//Quantidade de funcionários ativos
   
    //=========================================================================================================================
	// Se faixa de data dos parâmetros pertence pelo menos um dia à competência do MV_FOLMES puxa o SRC inteiro
	// para o resultado pois o RC_PERIODO pode conter datas fora do período mas ainda assim pertencer a competência do MV_FOLMES]
	//==========================================================================================================================
	FOR VV := 1 TO 3
		
		_cquery2:= " SELECT "
		
		IF (STRZERO(YEAR(MV_PAR05),4) + STRZERO(MONTH(MV_PAR05),2)) > _cFecham .OR.;
		   (STRZERO(YEAR(MV_PAR06),4) + STRZERO(MONTH(MV_PAR06),2)) > _cFecham
			
			//Total de verbas
			_cquery2 	+= " TMP2.TOTAL_GERAL  AS TOTAL_T FROM "           +ENTER
			
			IF VV = 1//query com verbas com todos os impostos
				
				_cquery2 	+= " (SELECT "+ENTER
				_cquery2 	+= "  (SUM(TMP.INSS+TMP.ACT+TMP.RAT_TERC+TMP.FGTS+TMP.FERIAS+TMP.DECIMO_TERC+TMP.FOLHA)+"+ENTER
				_cquery2 	+= "  DECODE(SUM(TMP.VALOR_ESTAG),NULL,0,SUM(TMP.VALOR_ESTAG))+"+ENTER
				_cquery2 	+= "  DECODE(SUM(TMP.VALOR_MULTA_DEMIS),NULL,0,SUM(TMP.VALOR_MULTA_DEMIS))+"+ENTER
				_cquery2 	+= "  DECODE(SUM(TMP.VALOR_SM),NULL,0,SUM(TMP.VALOR_SM))+"+ENTER
				_cquery2 	+= "  DECODE(SUM(TMP.VALOR_ACD_INSS),NULL,0,SUM(TMP.VALOR_ACD_INSS))+"+ENTER				
				_cquery2 	+= "  DECODE(SUM(TMP.VALOR_DC),NULL,0,SUM(TMP.VALOR_DC))+"+ENTER
				_cquery2 	+= "  DECODE(SUM(TMP.VALOR_SMT),NULL,0,SUM(TMP.VALOR_SMT))) AS TOTAL_GERAL FROM ( "+ENTER//TOTAL_GERAL_T
				
			ELSEIF VV = 2//query com verbas sem impostos
				
				_cquery2 	+= " (SELECT "+ENTER
				_cquery2 	+= " (SUM(TMP.FOLHA))"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_ESTAG),NULL,0,SUM(TMP.VALOR_ESTAG))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_MULTA_DEMIS),NULL,0,SUM(TMP.VALOR_MULTA_DEMIS))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_SM),NULL,0,SUM(TMP.VALOR_SM))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_DC),NULL,0,SUM(TMP.VALOR_DC))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_SMT),NULL,0,SUM(TMP.VALOR_SMT))) AS TOTAL_GERAL FROM ( "+ENTER//TOTAL_GERAL_SE
				_cquery2 	+= " AS TOTAL_GERAL FROM ( "+ENTER//TOTAL_GERAL_SE
				
			ELSEIF VV = 3//query com verbas FGTS
				
				_cquery2 	+= " (SELECT "+ENTER
				_cquery2 	+= " (SUM(TMP.FOLHA+TMP.FGTS))"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_ESTAG),NULL,0,SUM(TMP.VALOR_ESTAG))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_MULTA_DEMIS),NULL,0,SUM(TMP.VALOR_MULTA_DEMIS))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_SM),NULL,0,SUM(TMP.VALOR_SM))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_DC),NULL,0,SUM(TMP.VALOR_DC))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_SMT),NULL,0,SUM(TMP.VALOR_SMT))) AS TOTAL_GERAL FROM ( "+ENTER//TOTAL_GERAL_F
				_cquery2 	+= " AS TOTAL_GERAL FROM ( "+ENTER//TOTAL_GERAL_F
				
			ENDIF
			
			_cquery2 	+= " select "+ENTER
			_cquery2 	+= " 		((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nInss+")/100) as INSS,"+ENTER
			_cquery2 	+= "    	((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nAct +")/100) as ACT,"+ENTER
			_cquery2 	+= "  		((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nTerc+")/100) as RAT_TERC,"+ENTER
			_cquery2 	+= "  		((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nFgts+")/100) as FGTS,"+ENTER
			
			_cquery2 	+= "  		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) + "+ENTER
			_cquery2 	+= " 	 	(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) * ("+_nInss+")/100) + "+ENTER
			_cquery2 	+= "  		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) * ("+_nAct +")/100) + " +ENTER
			_cquery2 	+= " 		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) * ("+_nTerc+")/100) + "+ENTER
			_cquery2 	+= "  		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) *(("+_nFgts+")/100) )) as Ferias, "+ENTER
//			_cquery2 	+= "  		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) *(("+_c13S +")/100) )) as Ferias, "+ENTER
			
			_cquery2 	+= "  		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) + "+ENTER
			_cquery2 	+= "  		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nInss+")/100) + " +ENTER
			_cquery2 	+= " 		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nAct +")/100) + "+ENTER
			_cquery2 	+= " 		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nTerc+")/100) + "+ENTER
			_cquery2 	+= " 		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nFgts+")/100))  as Decimo_Terc, "+ENTER
			
			_cquery2 	+= "  		(decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) as Folha, "+ENTER
			
			_cquery2 	+= " (SELECT SUM(RC_VALOR) FROM " + RETSQLNAME("SRC") + " SRC WHERE SRC.D_E_L_E_T_ = ' '  "+ENTER
			_cquery2 	+= "         AND RC_FILIAL = '"+_afiliais[_nip]+"' AND  RC_PERIODO >= '"+_cDIncial+"' AND  RC_PERIODO <= '"+_cDFinal+"'  "+ENTER
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RC_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cquery2  += " AND RC_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= "         AND RC_PD IN ('727','831')) AS VALOR_MULTA_DEMIS,  "+ENTER
			
			_cquery2 	+= " (SELECT ((TM.VALOR*"+_nFgts+")/100) FROM "+ENTER//8.00
			_cquery2 	+= " (SELECT SUM(RC_VALOR) VALOR FROM " + RETSQLNAME("SRC") + " SRC WHERE SRC.D_E_L_E_T_ = ' '  "+ENTER
			_cquery2 	+= "         AND RC_FILIAL = '"+_afiliais[_nip]+"' AND RC_PERIODO >= '"+_cDIncial+"' AND  RC_PERIODO <= '"+_cDFinal+"'  "+ENTER
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RC_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cquery2  += " AND RC_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= "         AND RC_PD IN ('097')) TM ) AS VALOR_SM, "+ENTER

			_cquery2 	+= " (SELECT ((TM.VALOR*"+_nFgts+")/100) FROM "+ENTER//8.00
			_cquery2 	+= " (SELECT SUM(RC_VALOR) VALOR FROM " + RETSQLNAME("SRC") + " SRC WHERE SRC.D_E_L_E_T_ = ' '  "+ENTER
			_cquery2 	+= "         AND RC_FILIAL = '"+_afiliais[_nip]+"' AND RC_PERIODO >= '"+_cDIncial+"' AND  RC_PERIODO <= '"+_cDFinal+"'  "+ENTER
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RC_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cquery2  += " AND RC_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= "         AND RC_PD IN ('098')) TM ) AS VALOR_ACD_INSS, "+ENTER


			_cquery2 	+= " (SELECT ((TSM.VALOR*"+_cSMT+")/100) FROM "+ENTER//52.46336
			_cquery2 	+= " (SELECT SUM(RC_VALOR) VALOR FROM " + RETSQLNAME("SRC") + " SRC WHERE SRC.D_E_L_E_T_ = ' '  "+ENTER
			_cquery2 	+= "         AND RC_FILIAL = '"+_afiliais[_nip]+"' AND RC_PERIODO >= '"+_cDIncial+"' AND  RC_PERIODO <= '"+_cDFinal+"' "+ENTER
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RC_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cquery2  += " AND RC_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= "         AND RC_PD IN ('121','323','361')) TSM ) AS VALOR_SMT, "+ENTER
			
			_cquery2 	+= " (SELECT TDC.VALOR+((TDC.VALOR*"+_cDC+")/100) FROM "+ENTER//37,22
			_cquery2 	+= " (SELECT SUM(RC_VALOR) VALOR FROM " + RETSQLNAME("SRC") + " SRC WHERE SRC.D_E_L_E_T_ = ' '  "+ENTER
			_cquery2 	+= "         AND RC_FILIAL = '"+_afiliais[_nip]+"' AND RC_PERIODO >= '"+_cDIncial+"' AND  RC_PERIODO <= '"+_cDFinal+"' "+ENTER
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RC_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cquery2  += " AND RC_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= "         AND RC_PD IN ('200','356','205')) TDC ) AS VALOR_DC, "+ENTER
			
			_cquery2 	+= " (SELECT ((TE.VALOR*"+_cEST+")/100) FROM "+ENTER//15.241
			_cquery2 	+= " (SELECT SUM(RC_VALOR) VALOR FROM " + RETSQLNAME("SRC") + " SRC WHERE SRC.D_E_L_E_T_ = ' '  "+ENTER
			_cquery2 	+= "         AND RC_FILIAL = '"+_afiliais[_nip]+"' AND RC_PERIODO >= '"+_cDIncial+"' AND  RC_PERIODO <= '"+_cDFinal+"' "+ENTER
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RC_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cquery2  += " AND RC_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= "         AND RC_PD IN ('192','193')) TE ) AS VALOR_ESTAG "+ENTER
			
			_cquery2 	+= " from ( "+ENTER
			
			_cquery2 	+= "   	select 	sum(RC_valor) as proventos, "+ENTER
			_cquery2 	+= " 				 	RC_filial  "+ENTER
			_cquery2 	+= " 		from " + retsqlname("SRC") + " SRC2  join " + retsqlname("SRV") + " SRV2 on rc_filial = rv_filial and rc_pd = rv_cod "+ENTER
			
			
			_cQuery2 += " WHERE RC_FILIAL = '" + _afiliais[_nip] + "'"+ENTER
			
			_cquery2 	+= "   	AND	sRC2.d_e_l_e_t_ = ' ' and srv2.d_e_l_e_t_ = ' ' "+ENTER
			_cquery2	+= "	AND	RV_I_CUSTG = '1' "+ENTER

			IF VV = 1//query com verbas com todos os impostos
			   _cquery2	+= " 	AND RV_INSS = 'S' AND RV_FGTS = 'S' " +ENTER				
			ELSEIF VV = 2//query com verbas sem impostos
			   _cquery2	+= " 	AND RV_INSS = 'N' AND RV_FGTS = 'N' " +ENTER				
			ELSEIF VV = 3//query com verbas FGTS
			   _cquery2	+= " 	AND RV_INSS = 'N' AND RV_FGTS = 'S' " +ENTER				
			ENDIF
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RC_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cquery2  += " AND RC_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif

			_cquery2 	+= " 		group by RC_filial) p "+ENTER
			
			_cquery2 	+= " FULL OUTER join ( "+ENTER
			
			_cquery2 	+= " 		select sum(RC_valor) as devol, "+ENTER
			_cquery2 	+= " 				RC_filial "+ENTER
			_cquery2 	+= " 		from " + retsqlname("SRC") + " SRC3 join " + retsqlname("SRV") + " SRV3 on rc_filial = rv_filial and rc_pd = rv_cod "+ENTER
			_cquery2 	+= "  WHERE SRC3.D_E_L_E_T_ = ' '  AND SRV3.D_E_L_E_T_ = ' ' " +ENTER
			_cQuery2    += "       AND RC_FILIAL = '" + _afiliais[_nip] + "'"+ENTER
			_cquery2	+= " 	   AND RV_I_CUSTG = '2' " +ENTER

			IF VV = 1//query com verbas com todos os impostos
			   _cquery2	+= " 	   AND RV_INSS = 'S' AND RV_FGTS = 'S' " +ENTER				
			ELSEIF VV = 2//query com verbas sem impostos
			   _cquery2	+= " 	   AND RV_INSS = 'N' AND RV_FGTS = 'N' " +ENTER				
			ELSEIF VV = 3//query com verbas FGTS
			   _cquery2	+= " 	   AND RV_INSS = 'N' AND RV_FGTS = 'S' " +ENTER				
			ENDIF
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RC_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cquery2  += " AND RC_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= " 		GROUP BY RC_FILIAL) D "+ENTER
			_cquery2 	+= " 				ON P.RC_FILIAL = D.RC_FILIAL "+ENTER
			_cquery2 	+= " ) TMP ) TMP2 "+ENTER
			
		Else
			
			//Total de verbas
			_cquery2 	+= " TMP2.TOTAL_GERAL  AS TOTAL_T  FROM " +ENTER
			
			IF VV = 1//query com verbas com todos os impostos
				
				_cquery2 	+= " (SELECT "+ENTER
				_cquery2 	+= "  (SUM(TMP.INSS+TMP.ACT+TMP.RAT_TERC+TMP.FGTS+TMP.FERIAS+TMP.DECIMO_TERC+TMP.FOLHA)+"+ENTER
				_cquery2 	+= "  DECODE(SUM(TMP.VALOR_ESTAG),NULL,0,SUM(TMP.VALOR_ESTAG))+"+ENTER
				_cquery2 	+= "  DECODE(SUM(TMP.VALOR_MULTA_DEMIS),NULL,0,SUM(TMP.VALOR_MULTA_DEMIS))+"+ENTER
				_cquery2 	+= "  DECODE(SUM(TMP.VALOR_SM),NULL,0,SUM(TMP.VALOR_SM))+"+ENTER
				_cquery2 	+= "  DECODE(SUM(TMP.VALOR_ACD_INSS),NULL,0,SUM(TMP.VALOR_ACD_INSS))+"+ENTER				
				_cquery2 	+= "  DECODE(SUM(TMP.VALOR_DC),NULL,0,SUM(TMP.VALOR_DC))+"+ENTER
				_cquery2 	+= "  DECODE(SUM(TMP.VALOR_SMT),NULL,0,SUM(TMP.VALOR_SMT))) AS TOTAL_GERAL FROM ( "+ENTER//TOTAL_GERAL_T
				
			ELSEIF VV = 2//query com verbas sem impostos
				
				_cquery2 	+= " (SELECT "+ENTER
				_cquery2 	+= " (SUM(TMP.FOLHA))"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_ESTAG),NULL,0,SUM(TMP.VALOR_ESTAG))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_MULTA_DEMIS),NULL,0,SUM(TMP.VALOR_MULTA_DEMIS))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_SM),NULL,0,SUM(TMP.VALOR_SM))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_DC),NULL,0,SUM(TMP.VALOR_DC))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_SMT),NULL,0,SUM(TMP.VALOR_SMT))) AS TOTAL_GERAL FROM ( "+ENTER//TOTAL_GERAL_SE
				_cquery2 	+= " AS TOTAL_GERAL FROM ( "+ENTER//TOTAL_GERAL_SE
				
			ELSEIF VV = 3//query com verbas FGTS
				
				_cquery2 	+= " (SELECT "+ENTER
				_cquery2 	+= " (SUM(TMP.FOLHA+TMP.FGTS))"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_ESTAG),NULL,0,SUM(TMP.VALOR_ESTAG))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_MULTA_DEMIS),NULL,0,SUM(TMP.VALOR_MULTA_DEMIS))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_SM),NULL,0,SUM(TMP.VALOR_SM))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_DC),NULL,0,SUM(TMP.VALOR_DC))+"+ENTER
//				_cquery2 	+= " DECODE(SUM(TMP.VALOR_SMT),NULL,0,SUM(TMP.VALOR_SMT))) AS TOTAL_GERAL FROM ( "+ENTER//TOTAL_GERAL_F
				_cquery2 	+= " AS TOTAL_GERAL FROM ( "+ENTER//TOTAL_GERAL_F
				
			ENDIF
			
			_cquery2 	+= " select "+ENTER
			_cquery2 	+= " 		((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nInss+")/100) as INSS,"+ENTER
			_cquery2 	+= "    	((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nAct +")/100) as ACT,"+ENTER
			_cquery2 	+= "  		((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nTerc+")/100) as RAT_TERC,"+ENTER
			_cquery2 	+= "  		((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nFgts+")/100) as FGTS,"+ENTER
			
			_cquery2 	+= "  		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) + "+ENTER
			_cquery2 	+= " 	 	(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) * ("+_nInss+")/100) + "+ENTER
			_cquery2 	+= "  		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) * ("+_nAct +")/100) + " +ENTER
			_cquery2 	+= " 		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) * ("+_nTerc+")/100) + "+ENTER
			_cquery2 	+= "  		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) *(("+_nFgts+")/100) )) as Ferias, "+ENTER
//			_cquery2 	+= "  		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) *(("+_c13S +")/100) )) as Ferias, "+ENTER
			
			_cquery2 	+= "  		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) + "+ENTER
			_cquery2 	+= "  		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nInss+")/100) + " +ENTER
			_cquery2 	+= " 		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nAct +")/100) + "+ENTER
			_cquery2 	+= " 		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nTerc+")/100) + "+ENTER
			_cquery2 	+= " 		(((decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nFgts+")/100))  as Decimo_Terc, "+ENTER
			
			_cquery2 	+= "  		(decode(p.proventos,null,0,p.proventos) - (case when d.devol > 1 then d.devol else 0 end)) as Folha, "+ENTER
			
			_cquery2 	+= " (SELECT SUM(RD_VALOR) FROM " + RETSQLNAME("SRD") + " SRD WHERE SRD.D_E_L_E_T_ = ' '  "+ENTER
			_cquery2 	+= "         AND RD_FILIAL = '"+_afiliais[_nip]+"' AND  RD_DATARQ >= '"+_cDIncial+"' AND  RD_DATARQ <= '"+_cDFinal+"'  "+ENTER
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif			
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RD_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cQuery2  += " AND RD_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= "         AND RD_PD IN ('727','831')) AS VALOR_MULTA_DEMIS,  "+ENTER
			
			_cquery2 	+= " (SELECT ((TM.VALOR*"+_nFgts+")/100) FROM "+ENTER//8.00
			_cquery2 	+= " (SELECT SUM(RD_VALOR) VALOR FROM " + RETSQLNAME("SRD") + " SRD WHERE SRD.D_E_L_E_T_ = ' '  "+ENTER
			_cquery2 	+= "         AND RD_FILIAL = '"+_afiliais[_nip]+"' AND RD_DATARQ >= '"+_cDIncial+"' AND  RD_DATARQ <= '"+_cDFinal+"'  "+ENTER
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += "        AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif			
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += "        AND RD_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cquery2  += "        AND RD_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= "         AND RD_PD IN ('097')) TM ) AS VALOR_SM, "+ENTER
			
			_cquery2 	+= " (SELECT ((TM.VALOR*"+_nFgts+")/100) FROM "+ENTER//8.00
			_cquery2 	+= " (SELECT SUM(RD_VALOR) VALOR FROM " + RETSQLNAME("SRD") + " SRD WHERE SRD.D_E_L_E_T_ = ' '  "+ENTER
			_cquery2 	+= "         AND RD_FILIAL = '"+_afiliais[_nip]+"' AND RD_DATARQ >= '"+_cDIncial+"' AND  RD_DATARQ <= '"+_cDFinal+"'  "+ENTER
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif			
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RD_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cQuery2  += " AND RD_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= "         AND RD_PD IN ('098')) TM ) AS VALOR_ACD_INSS, "+ENTER
			
			_cquery2 	+= " (SELECT ((TSM.VALOR*"+_cSMT+")/100) FROM "+ENTER//52.46336
			_cquery2 	+= " (SELECT SUM(RD_VALOR) VALOR FROM " + RETSQLNAME("SRD") + " SRD WHERE SRD.D_E_L_E_T_ = ' '  "+ENTER
			_cquery2 	+= "         AND RD_FILIAL = '"+_afiliais[_nip]+"' AND RD_DATARQ >= '"+_cDIncial+"' AND  RD_DATARQ <= '"+_cDFinal+"' "+ENTER
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif			
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RD_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cQuery2  += " AND RD_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= "         AND RD_PD IN ('121','323','361')) TSM ) AS VALOR_SMT, "+ENTER
			
			_cquery2 	+= " (SELECT TDC.VALOR+((TDC.VALOR*"+_cDC+")/100) FROM "+ENTER//37,22
			_cquery2 	+= " (SELECT SUM(RD_VALOR) VALOR FROM " + RETSQLNAME("SRD") + " SRD WHERE SRD.D_E_L_E_T_ = ' '  "+ENTER
			_cquery2 	+= "         AND RD_FILIAL = '"+_afiliais[_nip]+"' AND RD_DATARQ >= '"+_cDIncial+"' AND  RD_DATARQ <= '"+_cDFinal+"' "+ENTER
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif			
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RD_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cQuery2  += " AND RD_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= "         AND RD_PD IN ('200','356','205')) TDC ) AS VALOR_DC, "+ENTER
			
			_cquery2 	+= " (SELECT ((TE.VALOR*"+_cEST+")/100) FROM "+ENTER//15.241
			_cquery2 	+= " (SELECT SUM(RD_VALOR) VALOR FROM " + RETSQLNAME("SRD") + " SRD WHERE SRD.D_E_L_E_T_ = ' '  "+ENTER
			_cquery2 	+= "         AND RD_FILIAL = '"+_afiliais[_nip]+"' AND RD_DATARQ >= '"+_cDIncial+"' AND  RD_DATARQ <= '"+_cDFinal+"' "+ENTER
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RD_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cQuery2  += " AND RD_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= "         AND RD_PD IN ('192','193')) TE ) AS VALOR_ESTAG "+ENTER
			
			_cquery2 	+= " from ( "+ENTER
			
			_cquery2 	+= "   	select 	sum(RD_valor) as proventos, "+ENTER
			_cquery2 	+= " 				 	RD_filial  "+ENTER
			_cquery2 	+= " 		from " + retsqlname("SRD") + " SRD2  join " + retsqlname("SRV") + " SRV2 on rd_filial = rv_filial and rd_pd = rv_cod "+ENTER
			
			
			_cQuery2    += " WHERE RD_FILIAL = '" + _afiliais[_nip] + "'"+ENTER
			_cquery2 	+= " 		and	rd_datarq >= '" + _cDIncial + "' and "+ENTER
			_cquery2 	+= " 		rd_datarq <= '" + _cDFinal + "' and "+ENTER
			_cquery2 	+= "   		sRD2.d_e_l_e_t_ = ' ' and srv2.d_e_l_e_t_ = ' ' "+ENTER
			_cquery2	+= "		AND RV_I_CUSTG = '1' "+ENTER

			IF VV = 1//query com verbas com todos os impostos
			   _cquery2	+= " 	AND RV_INSS = 'S' AND RV_FGTS = 'S' " +ENTER				
			ELSEIF VV = 2//query com verbas sem impostos
			   _cquery2	+= " 	AND RV_INSS = 'N' AND RV_FGTS = 'N' " +ENTER				
			ELSEIF VV = 3//query com verbas FGTS
			   _cquery2	+= " 	AND RV_INSS = 'N' AND RV_FGTS = 'S' " +ENTER				
			ENDIF

			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RD_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cQuery2  += " AND RD_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= " 		group by RD_filial) p "+ENTER
			
			_cquery2 	+= " FULL OUTER join ( "+ENTER
			
			_cquery2 	+= " 		select sum(RD_valor) as devol, "+ENTER
			_cquery2 	+= " 				RD_filial "+ENTER
			_cquery2 	+= " 		from " + retsqlname("SRD") + " SRD3 join " + retsqlname("SRV") + " SRV3 on rd_filial = rv_filial and rd_pd = rv_cod "+ENTER
			_cquery2 	+= " 		where 	sRD3.d_e_l_e_t_ = ' '  and srv3.d_e_l_e_t_ = ' ' and " +ENTER
			
			
			_cQuery2 += "  RD_FILIAL = '" + _afiliais[_nip] + "'"+ENTER
			_cquery2 	+= "	and rd_datarq >= '" + _cDIncial + "'"+ENTER
			_cquery2 	+= "	and rd_datarq <= '" + _cDFinal + "'"		+ENTER
			_cquery2	+= " 	AND RV_I_CUSTG = '2' " +ENTER
			IF VV = 1//query com verbas com todos os impostos
			   _cquery2	+= " 	AND RV_INSS = 'S' AND RV_FGTS = 'S' " +ENTER				
			ELSEIF VV = 2//query com verbas sem impostos
			   _cquery2	+= " 	AND RV_INSS = 'N' AND RV_FGTS = 'N' " +ENTER				
			ELSEIF VV = 3//query com verbas FGTS
			   _cquery2	+= " 	AND RV_INSS = 'N' AND RV_FGTS = 'S' " +ENTER				
			ENDIF                                                
			If !EMPTY(ZL6T->ZL6_CONDIC)
				_cquery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
			Endif
		    If !EMPTY(ZL6T->ZL6_CENTRO)		
			    _cquery2 += " AND RD_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
  		    Endif
		    If !EMPTY(ZL6T->ZL6_NCENTR)
			   _cQuery2  += " AND RD_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
		    Endif
			_cquery2 	+= " 		group by RD_filial) d "+ENTER
			_cquery2 	+= " 				on p.RD_filial = d.RD_filial "+ENTER
			_cquery2 	+= " ) TMP ) TMP2"+ENTER
			
		Endif
		
		MPSysOpenQuery( _cquery2 , "VALOR1" )
		DBSelectArea("VALOR1")
		DBGOTOP()
		_cValores+=_cquery2+ENTER
		
		If !(VALOR1->( Eof() ))
			_nValor+=VALOR1->TOTAL_T
 			_cValores+=_afiliais[_nip]+" / "+STRZERO(VV,3)+": "+STR(VALOR1->TOTAL_T,22,7)+ENTER+ENTER
		ENDIF
		
		VALOR1->( DbClosearea() )
		
	NEXT


NEXT

IF !EMPTY(_cFilsemSRX)
   _cFilsemSRX:=LEFT(_cFilsemSRX,LEN(_cFilsemSRX)-2)
   IF !_lLoop .AND. !U_ITMSG("Não foram localizados dados de impostos do mês para RH, Filiais: "+_cFilsemSRX+", Deseja continuar ?","ATENÇÃO",,3,2,2) 
      _lLoop:=.T.
   ENDIF
   _cTimeIni:= TIME()//Reinicia o tempo pq o usuario pode demorar para responder
ENDIF	                                 	

_cValores+="VALOR TOTAL: "+STR(_nValor,22,7)+ENTER
_cValores+="QUANTIDADE: "+STR(_nQuant,22,7)+ENTER

nHandle := FCreate(_cdir+"VALORES_MAO_DE_OBRA_"+cFilant+"_"+STRTRAN(TIME(),":","_")+".txt")
FWrite(nHandle, _cValores)
FClose(nHandle)

Return {_nValor , _nQuant }

/*
===============================================================================================================================
Programa----------: MEST0097
Autor-------------: Josue Danich
Data da Criacao---: 29/10/2015
Descricao---------: Retorna query para custo gerencial de horas extras
Parametros--------: _dinicial - data inicial de analise
					 	_dfinal   - data final e analise
Retorno-----------: _cquery2  - query a ser executada
===============================================================================================================================
*/ 
User function MEST0097(_dinicial,_dfinal)

Local _cquery2 	:= ""
Local _cTabela 	:= "SRD.RD"
Local _cTabela2 	:= "SRC.RC"
Local _cQuery1	:= ""
Local _cFecham	:= ""

//=================================================================================================		
//Buscar data do ultimo fechamento  
//=================================================================================================

	_cQuery1 := " Select max(rd_datarq) as ULTF from " + retsqlname("SRD") + " srd "
	_cQuery1 += " where srd.d_e_l_e_t_ = ' ' "
	_cQuery1 += " and rd_filial = '" + xFilial("SRD") + "'"
	_cQuery1 += " and rd_roteir = 'FOL' "
	
   MPSysOpenQuery( _cquery1 ,"SRDU" ) 
   DBSelectArea("SRDU")

   If !(SRDU->( Eof() ))
   		_cFecham := SRDU->ULTF
   Endif		
   
   SRDU->( DbClosearea() )
		


_cQuery2 	:= " SELECT "

If ZL6T->ZL6_RCMUL > 0
	_cQuery2 	+= "		   (SUM(RD_VALOR) * " + ALLTRIM(STR(ZL6T->ZL6_RCMUL)) + ") AS RD_VALOR,"  			
Else
	_cQuery2 	+= "		   (SUM(RD_VALOR)) AS RD_VALOR,"
Endif	  				
_cQuery2 	+= "			SUM(RD_HORAS) AS RD_HORAS"

					
_cQuery2 	+= "  FROM "+ RetSqlName("SRD") + " SRD "

If EMPTY(ZL6T->ZL6_FILIS)
		
	_cQuery2 += " WHERE RD_FILIAL = '" + xfilial("SRD") + "'"
			
Else
		
	_cQuery2 += " WHERE RD_FILIAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";") 
		
Endif

_cQuery2 	+= " AND " + _cTabela + "_DATARQ >= '" + ALLTRIM(STR(YEAR(_dinicial)))+ STRZERO(MONTH(_dinicial),2) + "'"
_cQuery2 	+= " AND " + _cTabela + "_DATARQ <= '" + ALLTRIM(STR(YEAR(_dfinal))) + STRZERO(MONTH(_dfinal),2) + "'"
_cQuery2 	+= " AND " + SUBSTR(_cTabela,1,4) + "D_E_L_E_T_ = ' '"
			
If !EMPTY(ZL6T->ZL6_RCPD)
		
	_cQuery2 += " AND " + _cTabela + "_PD IN " + FormatIn(ALLTRIM(ZL6T->ZL6_RCPD),";")
		
Endif	
	
		
If !EMPTY(ZL6T->ZL6_CONDIC)
		
	_cQuery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
		
Endif

If !EMPTY(ZL6T->ZL6_NCENTR)
   _cQuery2  += " AND "+ _cTabela + "_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
Endif

If !EMPTY(ZL6T->ZL6_CENTRO)
   _cQuery2  += " AND "+ _cTabela + "_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
Endif

//=========================================================================================================================
// Se faixa de data dos parâmetros pertence pelo menos um dia à competência do MV_FOLMES puxa o SRC inteiro
// para o resultado pois o RC_PERIODO pode conter datas fora do período mas ainda assim pertencer a competência do MV_FOLMES]
//==========================================================================================================================
IF (strzero(YEAR(MV_PAR05),4) + strzero(MONTH(MV_PAR05),2)) > _cFecham;
	.OR. (strzero(YEAR(MV_PAR06),4) + strzero(MONTH(MV_PAR06),2)) > _cFecham
	
	_cQuery2 += " UNION ALL"

	_cQuery2 	+= " SELECT "

	If ZL6T->ZL6_RCMUL > 0 
		_cQuery2 	+= "		   (SUM(RC_VALOR) * " + ALLTRIM(STR(ZL6T->ZL6_RCMUL)) + ") AS RD_VALOR,"
	Else
		_cQuery2 	+= "		   (SUM(RC_VALOR)) AS RD_VALOR,"
	Endif
			  			
	_cQuery2 	+= "			SUM(RC_HORAS) AS RD_HORAS" 			


	_cQuery2 	+= "  FROM "+ RetSqlName("SRC") + " SRC "
	
	If EMPTY(ZL6T->ZL6_FILIS)
		
		_cQuery2 += " WHERE RC_FILIAL = '" + xfilial("SRC") + "'"
			
	Else
		
		_cQuery2 += " WHERE RC_FILIAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";") 
		
	Endif
	
		
	_cQuery2 	+= " AND " + SUBSTR(_cTabela2,1,4) + "D_E_L_E_T_ = ' '"
			
	If !EMPTY(ZL6T->ZL6_RCPD)
		
		_cQuery2 += " AND " + _cTabela2 + "_PD IN " + FormatIn(ALLTRIM(ZL6T->ZL6_RCPD),";")
		
	Endif	
	
		
	If !EMPTY(ZL6T->ZL6_CONDIC)
		
		_cQuery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
		
	Endif
	
	If !EMPTY(ZL6T->ZL6_NCENTR)
   		_cQuery2  += " AND "+ _cTabela2 + "_CC NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCENTR),";")
	Endif

	If !EMPTY(ZL6T->ZL6_CENTRO)
   		_cQuery2  += " AND "+ _cTabela2 + "_CC IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CENTRO),";")
	Endif
			
Endif

//nHandle := FCreate(_cdir+"query1.txt")
//FWrite(nHandle, _cquery2)  
//FClose(nHandle)

Return _cquery2  

/*
===============================================================================================================================
Programa----------: MEST0098
Autor-------------: Josue Danich
Data da Criacao---: 29/10/2015
Descricao---------: Retorna query para custo gerencial de saldos iniciais
Parametros--------: _dinicial - data inicial de analise
						_dfinal   - data final e analise
Retorno-----------: _cquery2  - query a ser executada
===============================================================================================================================
*/ 
User function MEST0098(_dinicial,_dfinal)

Local _cQuery2 	:= ""
Local _cTabela 	:= "SB9.B9"
Local _nmes		:= 0
Local _nano		:= 0
Local _dquery


//==========================================================
//Calcula data do B9 para saldos iniciais
//==========================================================
_nmes 		:= month(_dinicial)
_nano		:= year(_dinicial)
_dquery		:= stod(strzero(_nano,4)+strzero(_nmes,2)+'01')
_dquery 	:= _dquery - 1	


		_cQuery2 	:= " SELECT "
		_cQuery2 	+= "  			B9_COD,"
		_cQuery2 	+= "  			B9_LOCAL,"
//		_cQuery2 	+= "  			B9_QINI,"
		If ZL6T->ZL6_TUNID == 'S'
		   _cQuery2	+= " 			B9_QISEGUM B9_QINI,"
		ELSE
		   _cQuery2	+= " 			B9_QINI,"
		ENDIF
		_cQuery2 	+= "  			B9_VINI1,"
		_cQuery2 	+= "  			B9_DATA,"
		_cQuery2 	+= "  			B9_FILIAL "
			
		_cQuery2 	+= "  FROM " + RetSqlName("SB9") + " SB9"		
		
		If EMPTY(ZL6T->ZL6_FILIS)
		
			_cQuery2 += " WHERE B9_FILIAL = '" + xfilial("SB9") + "'"
			
		Else
		
			_cQuery2 += " WHERE B9_FILIAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";")
		
		Endif
	
		_cQuery2 	+= " AND " + _cTabela + "_DATA = '" + dtos(_dquery) + "'"
	
		If  ALLTRIM(ZL6T->ZL6_TPCUS) == '000004'

		    _cquery2 	+= " AND B9_LOCAL IN ( SELECT NNR_CODIGO FROM " + RetSqlName("NNR") + " NNR WHERE "
		    _cquery2 	+= "													      			NNR.NNR_CODIGO NOT IN ('40','36','37') AND "
		    _cquery2 	+= "													      			NNR.D_E_L_E_T_ = ' ' AND "
		    _cquery2 	+= "													      			NNR.NNR_FILIAL = '" + xfilial("NNR")+"') "

		ELSE

		    _cquery2 	+= " AND ( SELECT NNR_I_PA FROM " + RetSqlName("NNR") + " NNR WHERE 	NNR.NNR_CODIGO NOT IN ('40','36','37') AND "
		    _cquery2 	+= "													      			NNR.NNR_CODIGO = SB9.B9_LOCAL AND"
		    _cquery2 	+= "													      			NNR.D_E_L_E_T_ = ' ' AND "
		    _cquery2 	+= "													      			NNR.NNR_FILIAL = '" + xfilial("NNR") + "' AND "
		    _cquery2 	+= "													      			ROWNUM = 1) = '1'"

		ENDIF
			
		If  !EMPTY(ZL6T->ZL6_TPROD)
		
			_cQuery2 += " AND (SELECT B1_TIPO FROM " + RetSqlName("SB1") + " SB1 WHERE B1_FILIAL = '" +Xfilial("SB1") + "'"
			_cQuery2 += "                                                      AND D_E_L_E_T_ = ' '"
			_cQuery2 += "                                                      AND SB1.B1_COD = SB9.B9_COD ) "
			_cQuery2 += " IN " + FormatIn(ALLTRIM(ZL6T->ZL6_TPROD),";")
		
		Endif
		
		If  !EMPTY(ZL6T->ZL6_NTPRO)
		
			_cQuery2 += " AND (SELECT B1_TIPO FROM " + RetSqlName("SB1") + " SB1 WHERE B1_FILIAL = '" +Xfilial("SB1") + "'"
			_cQuery2 += "                                                      AND D_E_L_E_T_ = ' '"
			_cQuery2 += "                                                      AND SB1.B1_COD = SB9.B9_COD ) "
			_cQuery2 += " NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NTPRO),";")
	
		Endif
		
		If	!EMPTY(ZL6T->ZL6_CODPRO)
		
			_cQuery2 += " AND " + _cTabela + "_COD IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CODPRO),";")
		
		Endif
		
		If !EMPTY(ZL6T->ZL6_NCODPRO)
		
			_cQuery2 += " AND " + _cTabela + "_COD NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NCODPRO),";")
		
		Endif	
	
		
		If	!EMPTY(ZL6T->ZL6_GRPPRO)
		
			_cQuery2 += " AND (SELECT B1_GRUPO FROM " + RetSqlName("SB1") + " SB1 WHERE B1_FILIAL = '" +Xfilial("SB1") + "'"
			_cQuery2 += "                                                      AND D_E_L_E_T_ = ' '"
			_cQuery2 += "                                                      AND SB1.B1_COD = SB9.B9_COD ) "
			_cQuery2 += " IN " + FormatIn(ALLTRIM(ZL6T->ZL6_GRPPRO),";")
		
		Endif
		
		If	!EMPTY(ZL6T->ZL6_NGRPPR)
		
			_cQuery2 += " AND (SELECT B1_GRUPO FROM " + RetSqlName("SB1") + " SB1 WHERE B1_FILIAL = '" +Xfilial("SB1") + "'"
			_cQuery2 += "                                                      AND D_E_L_E_T_ = ' '"
			_cQuery2 += "                                                      AND SB1.B1_COD = SB9.B9_COD ) "
			_cQuery2 += " NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NGRPPR),";")
	
		
		Endif
		
		If !EMPTY(ZL6T->ZL6_CONDIC)
		
			_cQuery2 += " AND "+STRTRAN(UPPER(ALLTRIM(ZL6T->ZL6_CONDIC)),"SIGA.","")
		
		Endif
		
		_cQuery2 	+= " AND " + SUBSTR(_cTabela,1,4) + "D_E_L_E_T_ = ' '"
		
		_cQuery2 += " ORDER BY " + _cTabela + "_COD" 


Return _cquery2 

/*
===============================================================================================================================
Programa----------: MEST0099
Autor-------------: Josue Danich
Data da Criacao---: 16/12/2015
Descricao---------: Retorna query para custo gerencial de gestao do leite
Parametros--------: _dinicial - data inicial de analise
					_dfinal   - data final e analise
Retorno-----------: _cquery2  - query a ser executada
===============================================================================================================================
*/ 
User function MEST0099(_dinicial,_dfinal)

Local _cquery2 	:= ""

IF ZL6T->ZL6_TERCEI = "S"

	_cquery2 += " SELECT SUM(ZLX_VOLREC) AS QUANT , 0 AS CREDITO, 0 AS DEBITO FROM " + RetSqlName("ZLX") + " ZLX "
	_cquery2 += " WHERE D_E_L_E_T_ = ' '
	If EMPTY(ZL6T->ZL6_FILIS)
		_cquery2 += " AND ZLX.ZLX_FILIAL = '" + xfilial("ZLX") + "'"
	Else
		_cquery2 += " AND ZLX.ZLX_FILIAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";")
	Endif
	_cquery2 += " AND ZLX_TIPOLT = 'T' "
	_cquery2 += " AND ZLX_DTENTR BETWEEN '" + DTOS(_dinicial)+ "' AND '" + DTOS(_dfinal) + "'"


ELSE
	
	_cquery2 += " SELECT ZLF.ZLF_LINROT ZLD_LINROT,ZLF.ZLF_A2COD ,ZLF.ZLF_A2LOJA,
	_cquery2 += "		SUM(ZLF_QTDBOM) AS QUANT,"
	_cquery2 += " 	SUM( CASE WHEN ZLF_DEBCRE = 'C' THEN ZLF_TOTAL ELSE 0 END ) as CREDITO,"
	_cquery2 += " 	SUM( CASE WHEN ZLF_DEBCRE = 'D' THEN ZLF_TOTAL ELSE 0 END ) as DEBITO	 "
	_cquery2 += " FROM " + RetSqlName("ZLF") + " ZLF "
	_cquery2 += " JOIN " + RetSqlName("SA2") + " SA2 ON SA2.A2_COD = ZLF.ZLF_A2COD AND SA2.A2_LOJA = ZLF.ZLF_A2LOJA "
	_cquery2 += " WHERE ZLF.D_E_L_E_T_ = ' ' "
	_cquery2 += " AND SA2.D_E_L_E_T_ = ' ' "
	
	If EMPTY(ZL6T->ZL6_FILIS)
		_cQuery2 += " AND ZLF.ZLF_FILIAL = '" + xfilial("ZLF") + "'"
	Else
		_cQuery2 += " AND ZLF.ZLF_FILIAL IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";")
	Endif
	
	_cquery2 += " AND SUBSTR(ZLF.ZLF_A2COD,1,1) = 'P' "
	
	If !EMPTY(ZL6T->ZL6_FORNEC)
		_cQuery2 += " AND ZLF.ZLF_A2COD IN " + FormatIn(ALLTRIM(ZL6T->ZL6_FORNEC),";")
	Endif
	
	If !EMPTY(ZL6T->ZL6_NFORNE)
		_cQuery2 += " AND ZLF.ZLF_A2COD NOT IN " + FormatIn(ALLTRIM(ZL6T->ZL6_NFORNE),";")
	Endif
	
	If !EMPTY(ZL6T->ZL6_SETOR)
		_cQuery2 += " AND ZLF.ZLF_SETOR IN " + FormatIn(ALLTRIM(ZL6T->ZL6_SETOR),";")
	Endif
	
	If !EMPTY(ZL6T->ZL6_EVENTO)
		_cQuery2 += " AND ZLF.ZLF_EVENTO IN " + FormatIn(ALLTRIM(ZL6T->ZL6_EVENTO),";")
	Endif
	
	If !EMPTY(ZL6T->ZL6_CODMIX)
		_cQuery2 += " AND ZLF.ZLF_CODZLE IN " + FormatIn(ALLTRIM(ZL6T->ZL6_CODMIX),";")
	Endif

	_cquery2 += " AND ZLF.ZLF_DTINI BETWEEN '" + DTOS(_dinicial) + "' AND '"+ DTOS(_dfinal) +"' "
	_cquery2 += " AND ZLF.ZLF_DTFIM BETWEEN '" + DTOS(_dinicial) + "' AND '"+ DTOS(_dfinal) +"' "
	
	_cquery2 += " GROUP BY ZLF.ZLF_LINROT,ZLF.ZLF_A2COD,ZLF.ZLF_A2LOJA "
	_cquery2 += " ORDER BY 1,2,3 "
	
ENDIF

//    _cFileNome:=_cdir+"MEST009_MEST0099_"+xFilial("ZL6")+"_"+STRTRAN(TIME(),":","_")+".TXT"
//    MemoWrite(_cFileNome,_cquery2)

Return _cquery2 


/*
===============================================================================================================================
Programa----------: MEST009A
Autor-------------: Josue Danich
Data da Criacao---: 02/03/2016
Descricao---------: Retorna query para frete proporcional
Parametros--------: _dinicial - data inicial de analise
						_dfinal   - data final e analise
Retorno-----------: _cquery2  - query a ser executada
===============================================================================================================================
*/ 
User function MEST009A(_dinicial,_dfinal,_cCF,_cProd,_cCC)
Local _cQuery2 := ""
Local _nValor  := _nQtde:=0
DEFAULT _cCF  :='RE1'
DEFAULT _cProd:=ALLTRIM(ZL6T->ZL6_CODPRO)
DEFAULT _cCC  :=ALLTRIM(ZL6T->ZL6_CENTRO)

_cQuery2:= " SELECT SUM(D3_QUANT) QUANT "
_cQuery2+= "  FROM " + RetSqlName("SD3") + " SD3 "
_cQuery2+= " WHERE SD3.D3_FILIAL = '" + xfilial("SD3") + "'"
_cQuery2+= " AND SD3.D3_EMISSAO BETWEEN '" + DTOS(_dinicial) + "' AND '" + DTOS(_dfinal) + "'"
_cQuery2+= " AND SD3.D3_ESTORNO <> 'S' "
_cQuery2+= " AND SD3.D3_CF = '"+_cCF+"' "
_cQuery2+= " AND SD3.D_E_L_E_T_ = ' '"
If !EMPTY(_cCC)
   _cQuery2 += " AND SD3.D3_CC IN " + FormatIn(_cCC,";")
Endif
_cQuery:=_cQuery2

If !EMPTY(_cProd)
   _cQuery2 += " AND SD3.D3_COD IN " + FormatIn(_cProd,";")
   _cQuery:=_cQuery2
   MPSysOpenQuery( _cQuery2 ,"SD2T" ) 

   IF .NOT. SD2T->( EOF() )
      _nQtde:=SD2T->QUANT
   ENDIF
Endif

Return {_nValor,_nQtde}

/*
===============================================================================================================================
Programa----------: MEST009N
Autor-------------: Josue Danich
Data da Criacao---: 30/10/2015
Descricao---------: Valida edicao dos campos ZL6 com base no ZL6_OBSERV
Parametros--------: _cCond - Quais origens de informacao que permitem a edicao do campo
Retorno-----------: .T. se e campo editavel ou .F. se e campo bloqueado
===============================================================================================================================
*/
User function MEST009N(_cCond)

Local _lret 		:= .T.


Return _lRet


/*
===============================================================================================================================
Programa----------: MEST009Y
Autor-------------: Josue Danich Prestes
Data da Criacao---: 04/11/2015
Descricao---------: Gera Excel de custos gerenciais
Parametros--------: _oself , _nRegZL6
Retorno-----------:
===============================================================================================================================
*/
Static Function MEST009Y(_oself,_nRegZL6,_lEnd)

Local _axmlc	:= {}
Local _axmld	:= {}
Local _axmle	:= {}
Local _axmlf	:= {}
//Local _cFile   	:= ""
Local _cFile01 	:= "Custos01.xml"
Local _cFile02	:= "Custos02.xml"
Local _cFile03	:= "Custos03.xml"
Local _cFile04	:= "Custos04.xml"
Local _nH		:= 0 
Local _ni 		:= 1
Local _aze0		:= {}
Local _aze1		:= {}
Local _azeNew	:= {}
//Local _aretorno := {}
//Local _nQtdSin	:= 0
//Local _nVlrSin	:= 0
Local _nvalope 	:= 0
Local _np		:= 0
Local _nConta   := 0 , _ni2 , _cTotReg  
DEFAULT _lEnd:=.F.

//Planilha 01-Operacional - PA,  Grupos (000001/000002/000003)
//Planilha 02-Custo / Estoque - MP,  Grupos (000004/000005)   
//Planilha 03-Demonstrativo do Estoque Final,  Grupo (000006) 
//Planilha 04-Espelho Composicao dos Custos,  Depende do 01   

PRIVATE _lGera1Pla:= (EMPTY(MV_PAR12) .OR. "01" $ MV_PAR12) .AND. (EMPTY(MV_PAR01) .OR. '000001' $ ALLTRIM(MV_PAR01) .OR. '000002' $ ALLTRIM(MV_PAR01) .OR. '000003' $ ALLTRIM(MV_PAR01) )//Planilha 01 *
PRIVATE _lGera2Pla:= (EMPTY(MV_PAR12) .OR. "02" $ MV_PAR12) .AND. (EMPTY(MV_PAR01) .OR. '000004' $ ALLTRIM(MV_PAR01) .OR. '000005' $ ALLTRIM(MV_PAR01)) .AND. _lGera1Pla//Planilha 02 com 2 pastas e Le a palnilha 1
PRIVATE _lGera3Pla:= (EMPTY(MV_PAR12) .OR. "03" $ MV_PAR12) .AND. (EMPTY(MV_PAR01) .OR. '000006' $ ALLTRIM(MV_PAR01))               //Planilha 03 
PRIVATE _lGera4Pla:= (EMPTY(MV_PAR12) .OR. "04" $ MV_PAR12) .AND. _lGera1Pla .AND. _lGera1Pla                                       //Planilha 04 e Le a palnilha 1 e 2 

IF !_lGera1Pla .AND. !_lGera2Pla .AND. !_lGera3Pla .AND. !_lGera4Pla //.AND. !_lGera5Pla .AND. !_lGera6Pla .AND. !_lGera7Pla .AND. !_lGera8Pla .AND. !_lGera9Pla .AND. !_lGeraAPla
   U_ITMSG("Nenhuma Planilha será gerada devido a combinação dos parametros",'Atenção!',"Verifique os parametros e tente novamente",1)
   RETURN .F.
ENDIF

PRIVATE _lGerouAlguma:=.F.
//PRIVATE _nTotdol := MV_PAR09 //Valor do dolar
PRIVATE _nPag	 := 1
PRIVATE _aCusto04:={}

//==============================================================
//Roda SubEngine que prepara arrays e valores de gravação
//==============================================================
MEST009SE( _nRegZL6, _oself, @_aze0, @_aze1, @_nvalope, @_azeNew,@_lEnd)
IF _lLoop
   RETURN .F.
ENDIF

//================================================
//CRIANDO PLANILHA 1
//================================================
IF _lGera1Pla
	
 BEGIN SEQUENCE 

  IF FILE(_cdir+_cFile01)
	_nConta :=1
	DO WHILE FERASE(_cdir+_cFile01) = -1 .AND. _nConta <= 5
		U_ITMSG("FECHE A PLANILHA: "+_cdir+_cFile01,'Atenção! '+ALLTRIM(STR(_nConta))+" tentativas de 5","Para o sistema consegui-la gera-lá novamente",3)
		_nConta++
	ENDDO
	
	IF FILE(_cdir+_cFile01) .AND. FERASE(_cdir+_cFile01) = -1
	   U_ITMSG("A PLANILHA: "+_cdir+_cFile01+" não pode ser gerada",'Atenção!',"Não foi possivel apagar o arquivo "+_cdir+_cFile01,1)
	   BREAK
	ENDIF
  ENDIF
	
	//================================================
	//Monta cabecalho do excel - 01-Operacional - PA
	//================================================
	_axmlc := MEST009E1()
    IF LEN(_axmlc) = 0
	   BREAK
    ENDIF

	IF _lGera4Pla .OR. _lGera2Pla //.OR. _lGera1Pla
  	   _aCusto04:={}
	    AADD(_aCusto04,{"CUSTO OPERACIONAL                 ",00,0,0})//01
		AADD(_aCusto04,{"CUSTO OPERACIONAL FILIAIS         ",00,0,0})//02
		AADD(_aCusto04,{"CUSTO LEITE IN-NATURA + FRETE     ",00,0,0})//03
		AADD(_aCusto04,{"CUSTO SORO DE LEITE + FRETE       ",00,0,0})//04
		AADD(_aCusto04,{"CUSTO SORO CONCENTRADO + FRETE    ",00,0,0})//05    
		AADD(_aCusto04,{"CUSTO CREME DE LEITE + FRETE      ",00,0,0})//06     
	    AADD(_aCusto04,{"CUSTO SORO PRE-CONCENTRADO + FRETE",00,0,0})//07 *** NOVO
		AADD(_aCusto04,{"CUSTO COM ICMS P/ LEITE UHT       ",00,0,0})//08
		AADD(_aCusto04,{"CUSTO COM ICMS P/ DERIVADOS       ",00,0,0})//09
		AADD(_aCusto04,{"CUSTO COM ICMS P/ MERC. ADQUIRIDAS",00,0,0})//10
		AADD(_aCusto04,{"CUSTO IRPJ/CSSL(PARCELAMENTO)     ",00,0,0})//11
    ENDIF	
	//================================================
	//Monta corpo da página de custo operacional do excel - 01-Operacional - PA
	//================================================
	If LEN(_aze0) > 0
		
		_axmld := MEST009E2(_aze0,"CUSTO OPERACIONAL",_ntotlei)
		_nPag++
		
	Endif
	
	//===============================================================
	//Monta corpo das páginas de custo de produtos acabados do excel - 01-Operacional - PA
	//================================================================
	_axmlt := {}
	_aze2  := {}
	
	_oself:SetRegua1( LEN(_aze1) )
	_oself:SetRegua2( LEN(_aze1) )
	_cTotReg:=ALLTRIM(STR( LEN(_aze1) ))
	_nConta :=0
	For _ni := 1 to len(_aze1)
		
		_nConta++
	    IF VALTYPE(_oSelf) = "O" 
		   _oself:IncRegua1("8-Processando Regras "+STR(_nConta,6)+" de "+_cTotReg )
  	       _oself:IncRegua2(ALLTRIM(_aze1[_ni][09]))
           ProcessMessages()
	       IF _lEnd 
              IF (_lEnd:=U_ITMSG("Confirma Cancelamento???? .","Atenção",,3,2,2))
                 _lLoop:=.T.
                 RETURN .F.
              ENDIF   
	       ENDIF
        ENDIF   
		If _ni = len(_aze1) .or. _aze1[_ni][08] != _aze1[_ni + 1][08]
			
			
			If !(_aze1[_ni][13] == "4")//ZL6_REGRA
				
				aadd( _aze2, {	_aze1[_ni][01],;										//01
				_aze1[_ni][02],;														//02
				_aze1[_ni][03],;														//03
				_aze1[_ni][06],;														//04
				_aze1[_ni][07],;														//05
				_aze1[_ni][06],;														//06
				_aze1[_ni][07],;														//07
				_aze1[_ni][04],;														//08
				_aze1[_ni][05],;														//09
				_aze1[_ni][10],;														//10
				_aze1[_ni][11],;														//11
				_aze1[_ni][12],;														//12
				_aze1[_ni][13],;														//13
				_aze1[_ni][14],;														//14
				_aze1[_ni][15],;														//15
				_aze1[_ni][09],;														//16
				_aze1[_ni][08],;														//17
				_aze1[_ni][21],;														//18 ZL6_CUSPR
				_aze1[_ni][26],;														//19 ZL6_REDIME
				_aze1[_ni][20],;														//20 ZL6_OBSERV
				_aze1[_ni][27]})														//21 _nQtdemKG
				
			Endif
			
			_np := ascan(_atotlei,{|_vAux|_vAux[1]==_aze1[_ni][08]})
			
			If len(_aze2) > 0
				
				If _np > 0
					
					_axmlt := MEST009E2(_aze2,"PRODUTOS ACABADOS - " + _aze1[_ni][09],_atotlei[_np][2],,_atotlei[_np][4])
					
				Else
					
					_axmlt := MEST009E2(_aze2,"PRODUTOS ACABADOS - " + _aze1[_ni][09],0)
					
				Endif
				
			Endif
			
			_nPag++
			
			For _ni2 := 1 to len(_axmlt)
				
				aadd(_axmlf, _axmlt[_ni2])
				
			Next
			
			_aze2 := {}
			
		Else
			
			If !(_aze1[_ni][13] == "4")//ZL6_REGRA
				
				aadd( _aze2, {	_aze1[_ni][01],;										//01
				_aze1[_ni][02],;														//02
				_aze1[_ni][03],;														//03
				_aze1[_ni][06],;														//04
				_aze1[_ni][07],;														//05
				_aze1[_ni][06],;														//06
				_aze1[_ni][07],;														//07
				_aze1[_ni][04],;														//08
				_aze1[_ni][05],;														//09
				_aze1[_ni][10],;														//10
				_aze1[_ni][11],;														//11
				_aze1[_ni][12],;														//12
				_aze1[_ni][13],;														//13
				_aze1[_ni][14],;														//14
				_aze1[_ni][15],;														//15
				_aze1[_ni][09],;														//16
				_aze1[_ni][08],;														//17
				_aze1[_ni][21],; 														//18 ZL6_CUSPR
				_aze1[_ni][26],;														//19 ZL6_REDIME
				_aze1[_ni][20],;														//20 ZL6_OBSERV
				_aze1[_ni][27]})														//21 _nQtdemKG
				
			Endif
			
		Endif
		
	Next
	
	_oself:IncRegua2("OK")
	
	//================================================
	//Monta totais e final do excel - 01-Operacional - PA
	//================================================
	_axmle := MEST009E3()//Finaliza arquivo Excel
	
	//================================================
	//CRIANDO PLANILHA 1 - 01-Operacional - PA
	//================================================
	_nH := FCREATE(_cdir+_cFile01)
	
	If _nH == -1
	   U_ITMSG("Falha ao criar arquivo: "+_cdir+_cFile01+" / ERRO "+STR(FERROR()),"ATENÇÃO","Tente novamente",1)
	   BREAK
	Endif
	
	_oself:SetRegua1( (LEN(_axmlc)/100)+10 )
	_cTotReg:=ALLTRIM(STR( LEN(_axmlc) ))
	_nConta :=0
	
	For _ni := 1 to len(_axmlc)//CABECALHO DO EXCEL DA PLANILHA 1 - 01-Operacional - PA
		
		_nConta++
	    IF VALTYPE(_oSelf) = "O" .AND. (MOD(_nConta,100) = 0 .OR. _nConta < 10)
		   _oself:IncRegua1("1/4-Gerando "+_cFile01+STR(_nConta,7)+" de "+_cTotReg )
		ENDIF   
		
  		fWrite(_nH,_axmlc[_ni] + ENTER )
		
	Next
	
	_oself:SetRegua1( (LEN(_axmld)/100)+10 )
	_cTotReg:=ALLTRIM(STR( len(_axmld) ))
	_nConta :=0
	
	For _ni := 1 to len(_axmld)//PLANILHA 1 - 01-Operacional - PA
		
		_nConta++
	    IF VALTYPE(_oSelf) = "O" .AND. (MOD(_nConta,100) = 0 .OR. _nConta < 10)
		   _oself:IncRegua1("2/4-Gerando "+_cFile01+STR(_nConta,7)+" de "+_cTotReg )
		ENDIF   
		
  		fWrite(_nH,_axmld[_ni] + ENTER )
		
	Next
	
	_oself:SetRegua1( (len(_axmlf)/100)+10 )
	_cTotReg:=ALLTRIM(STR( len(_axmlf) ))
	_nConta :=0
	
	For _ni := 1 to len(_axmlf)//PLANILHA 1 - 01-Operacional - PA
		
		_nConta++
	    IF VALTYPE(_oSelf) = "O" .AND. (MOD(_nConta,100) = 0 .OR. _nConta < 10)
		   _oself:IncRegua1("3/4-Gerando "+_cFile01+STR(_nConta,7)+" de "+_cTotReg )
		ENDIF   
		
  		fWrite(_nH,_axmlf[_ni] + ENTER )
		
	Next
	
	_oself:SetRegua1( (len(_axmle)/100)+10 )
	_cTotReg:=ALLTRIM(STR( len(_axmle) ))
	_nConta :=0
	
	For _ni := 1 to len(_axmle)//PLANILHA Custos01.xml - 01-Operacional - PA
		
		_nConta++
	    IF VALTYPE(_oSelf) = "O" .AND. MOD(_nConta,100) = 0
		   _oself:IncRegua1("4/4-Gerando "+_cFile01+STR(_nConta,7)+" de "+_cTotReg )
		ENDIF   
		
  		fWrite(_nH,_axmle[_ni] + ENTER )
		
	Next
	
	_oself:IncRegua1("ABRINDO PLANILHA 1, AGUARDE..." )
	
	fClose(_nH)

    IF _lEnd 
       IF (_lEnd:=U_ITMSG("Confirma Cancelamento???? .","Atenção",,3,2,2))
          _lLoop:=.T.
          _lGerouAlguma:=.F.
        ENDIF   
	ENDIF

	IF !lHtml
	   
	   IF !_lEnd .AND. ShellExecute("open", _cFile01, "", _cdir, 1) > 41 // ABRE PLANILHA Custos01.xml - 01-Operacional - PA
          _lGerouAlguma:=.T.
       ENDIF   
	
	ELSEIF !_lEnd

	   If (nErro:=CpyS2TW(_cdir+_cFile01)) <> 0
		  U_ITMSG("Falha ao abrir arquivo: "+_cdir+_cFile01+" / ERRO "+STR(nErro),"ATENÇÃO","Tente novamente",1)
	   ELSE
          _lGerouAlguma:=.T.
	   EndIf

	ENDIF

   END SEQUENCE
	
ENDIF

_nContPlan:=0
_nContTPlan:=0
IF(_lGera2Pla,_nContTPlan++,)
IF(_lGera3Pla,_nContTPlan++,)
IF(_lGera4Pla,_nContTPlan++,)   

IF !_lEnd .AND. _lGera2Pla//02-Custo MP/ Estoque - MP - Rodas os codigos '000004' e '000005' 
   _nContPlan++
   MEST9ProcPlan(_cFile02 , {|| MEST92Plan(_azeNew)   }, _oself,@_lEnd ) //GERA A PLANILHA Custos02.xml
ENDIF

IF !_lEnd .AND. _lGera3Pla//03-Demonstrativo do Estoque Final - Rodas os codigos '000006' 
   _nContPlan++
   MEST9ProcPlan(_cFile03 , {|| MEST93Plan(_azeNew)   }, _oself,@_lEnd ) //GERA A PLANILHA Custos03.xml
ENDIF

IF !_lEnd .AND. _lGera4Pla//04-Espelho Composicao dos Custos - depende da palnilha 01
   _nContPlan++
   MEST9ProcPlan(_cFile04 , {|| MEST94Plan(_aCusto04) }, _oself,@_lEnd ) //GERA A PLANILHA Custos04.xml
ENDIF

U_ITLOGACS('MEST009')

Return _lGerouAlguma

/*
===============================================================================================================================
Programa----------: MEST9ProcPlan()
Autor-------------: Alex Wallauer
Data da Criacao---: 27/07/2018
Descricao---------: Testa, gera e abre as novas planilhas
Parametros--------: _cFile,_bExecuta,_oself
===============================================================================================================================
*/
Static Function MEST9ProcPlan(_cFile,_bExecuta,_oSelf,_lEnd)
LOCAL _nFile,_aXmlNovo,_cTotReg , _ni
LOCAL _nConta:=1
PRIVATE _oRegua:=_oSelf
DEFAULT _lEnd:=.F.
IF SuperGetMV("IT_AMBTEST",.F.,.T.)
   _cFile:="D"+_cFile
ENDIF
BEGIN SEQUENCE
	
    IF FILE(_cdir+_cFile)
	   
	   DO WHILE FERASE(_cdir+_cFile) = -1 .AND. _nConta <= 5
	   	  U_ITMSG("FECHE A PLANILHA: "+_cdir+_cFile,'Atenção! '+ALLTRIM(STR(_nConta))+" tentativas de 5","Para o sistema consegui-la gera-lá novamente",3)
		  _nConta++
	   ENDDO
	
	   IF FILE(_cdir+_cFile) .AND. FERASE(_cdir+_cFile) = -1
		  U_ITMSG("A PLANILHA: "+_cdir+_cFile+" não pode ser gerada",'Atenção!',"Não foi possivel apagar o arquivo "+_cdir+_cFile,1)
		  BREAK
	   ENDIF

    ENDIF

	_nFile := FCREATE(_cdir+_cFile)
	
	If _nFile == -1
		U_ITMSG("Falha ao criar arquivo: "+_cdir+_cFile+" / ERRO "+STR(FERROR()),"ATENÇÃO","Tente novamente",1)
		BREAK
	Endif
	_oself:IncRegua1("Lendo dados da PLANILHA "+_cFile)
	_oself:IncRegua2("Aguarde..." )
	_aXmlNovo := EVAL(_bExecuta)//MEST9?Plan(_azeNew) ///GERA A PLANILHA

	IF LEN(_aXmlNovo) = 0
		BREAK
	ENDIF
	
	_oself:SetRegua1( (LEN(_aXmlNovo)/100)+10 )
	_cTotReg:=ALLTRIM(STR( LEN(_aXmlNovo) ))
	_nConta :=0
	
	For _ni := 1 to len(_aXmlNovo)
		
		_nConta++
	    IF VALTYPE(_oSelf) = "O" .AND. (MOD(_nConta,100) = 0 .OR. _nConta < 10)
		   _oself:IncRegua1(STR(_nContPlan,1)+"/"+STR(_nContTPlan,1)+"-Gerando "+_cFile+STR(_nConta,7)+" de "+_cTotReg )
		ENDIF
  		fWrite(_nFile,_aXmlNovo[_ni] + ENTER )

	    IF _lEnd 
           IF (_lEnd:=U_ITMSG("Confirma Cancelamento???? .","Atenção",,3,2,2))
              _lLoop:=.T.
              _lGerouAlguma:=.F.
              EXIT
           ENDIF   
	    ENDIF
		
	Next
	
	_oself:IncRegua1("ABRINDO PLANILHA "+_cFile)
	_oself:IncRegua2("Aguarde..." )
	
	FCLOSE(_nFile)
	
	IF !lHtml

	   IF !_lEnd .AND. ShellExecute("open", _cFile, "", _cdir, 1) > 41// ABRE PLANILHA
          _lGerouAlguma:=.T.
 	   ENDIF

	 ELSEIF !_lEnd

	   If (nErro:=CpyS2TW(_cdir+_cFile)) <> 0
		  U_ITMSG("Falha ao abrir arquivo: "+_cdir+_cFile+" / ERRO "+STR(nErro),"ATENÇÃO","Tente novamente",1)
	   ELSE
          _lGerouAlguma:=.T.
	   EndIf

   ENDIF   

END SEQUENCE

RETURN _lGerouAlguma

/*
===============================================================================================================================
Programa----------: MEST009SE
Autor-------------: Josue Danich Prestes
Data da Criacao---: 06/01/2016
Descricao---------: Subengine de preparação de arrays para excel e banco de dados
Parametros--------: _nRegZL6, _oself, _aze0, _aze1,  _nvalope, _azeNew
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST009SE( _nRegZL6, _oself, _aze0, _aze1,  _nvalope, _azeNew,_lEnd)

Local _aretorno 	:= {}
Local _nQtdSin	:= 0
Local _nVlrSin	:= 0
Local _cordem		:= ""
Local _ni			:= 0
Local _np			:= 0
Local _nContaZ      := 0 , _cTotRegZL6 , _nAux
PRIVATE _lTemMateriaPrima:=.F.//Variavel alterada na função _aretorno := U_MEST009E(mv_par01,mv_par02,MV_PAR05,MV_PAR06,2,_oself,@_lEnd)

//================================================
//Monta matriz com dados de trabalho
//================================================
_nRegZL6:=0
DBSELECTAREA("ZL6T")
COUNT TO _nRegZL6
DBGOTOP()
_oself:SetRegua1( _nRegZL6 )
_oself:SetRegua2( _nRegZL6 )
_cTotRegZL6:=ALLTRIM(STR(_nRegZL6))

DO While ZL6T->(!EOF())
	
	//==================================================
	//Roda engine de dados de custo gerencial
	//==================================================
	//MV_PAR01 - Tipo Grupo
	//MV_PAR02 - Grupo Custo
	//MV_PAR05 - Data inicial
	//MV_PAR06 - Data Final
	// Ultimo parâmetro indica que e a segunda etapa de leitura de varias tabelas com regras da ZL6 lida na primeira etapa  ZL6_DSUBEV
	_nContaZ++
    IF VALTYPE(_oSelf) = "O" 
	   _oself:IncRegua1("1-Lendo Regra: "+ALLTRIM(STR(_nContaZ,6))+" de "+_cTotRegZL6)
  	   _oself:IncRegua2(ZL6T->ZL6_OBSERV+" - "+ALLTRIM(ZL6T->ZL6_DSUBEV))
       ProcessMessages()
	   IF _lEnd 
          IF (_lEnd:=U_ITMSG("Confirma Cancelamento???? .","Atenção",,3,2,2))
             _lLoop:=.T.
             RETURN .F.
          ENDIF   
	   ENDIF
	ENDIF
    	
	_aretorno := U_MEST009E(MV_PAR01,MV_PAR02,MV_PAR05,MV_PAR06,2,_oself,@_lEnd)
    IF _lLoop
       RETURN .F.
    ENDIF
	
	_nQtdSin:= _aretorno[1]
	_nVlrSin:= _aretorno[2]
    IF LEN(_aretorno) > 2
	   _lTemEstoquenaDT:= _aretorno[3]
	ELSE
	   _lTemEstoquenaDT:= .F.
	ENDIF
    IF LEN(_aretorno) > 3
	   _aProdutos:= _aretorno[4]
	ELSE
	   _aProdutos:= {}
	ENDIF
    IF LEN(_aretorno) > 4
	   _nQtdemKG:=_aretorno[5]
	ELSE
	   _nQtdemKG:=0
	ENDIF   
	
	if ZL6T->ZL6_ORDEM > 0
		
		_cordem :=  ALLTRIM(STRZERO(10000-ZL6T->ZL6_ORDEM,4))
			
	Else
		
		_cordem := '00000'
			
	Endif
		
	
	If ALLTRIM(ZL6T->ZL6_TPCUS) == '000001' .OR. ALLTRIM(ZL6T->ZL6_TPCUS) == '000003'  // Tipo de custo operacional 
	
	
		aadd( _aze0, {	xfilial("ZE0"),;															//01
					ALLTRIM(ZL6T->ZL6_TPCUS),;														//02
					ALLTRIM(ZL6T->ZL6_DTPCUS),;														//03
					ALLTRIM(ZL6T->ZL6_CODEVE),;														//04	
					ALLTRIM(ZL6T->ZL6_DESEVE),;														//05
					ALLTRIM(ZL6T->ZL6_SUBEVE),;														//06
					ALLTRIM(ZL6T->ZL6_DSUBEV),;														//07
					ALLTRIM(ZL6T->ZL6_GRPCUS),;														//08
					ALLTRIM(ZL6T->ZL6_DGRCUS),;														//09
					_nQtdSin,;																		//10
					_nVlrSin,;																		//11
					(substr(dtos(MV_PAR05),5,2) +  substr(dtos(MV_PAR05),1,4)),;					//12
					ALLTRIM(ZL6T->ZL6_REGRA),;														//13
					_cordem,;																		//14
					ALLTRIM(ZL6T->ZL6_CODPRO),;														//15
					ZL6T->ZL6_TCUSTO,;																//16
					ZL6T->ZL6_TUNID,;																//17
					ZL6T->ZL6_CODPRO,;                                                              //18
					ZL6T->ZL6_CENTRO,; 																//19				
					ZL6T->ZL6_OBSERV,; 																//20  ZL6T->ZL6_FILIS
					0})																				//21 
																								

	Elseif ALLTRIM(ZL6T->ZL6_TPCUS) == '000002'  // Tipo de custo produto acabado 

        _cOrdem:=ALLTRIM(STRZERO(10000-VAL(ZL6T->ZL6_ORDGRU),4))+_cOrdem
        _nCusto:=0//ZL6T->ZL6_CUSPR = "N"
	    IF ZL6T->ZL6_CUSPR = "S"
	       _nCusto:=1
	    ELSEIF ZL6T->ZL6_CUSPR = "A"
	       _nCusto:=2
	    ELSEIF ZL6T->ZL6_CUSPR = "B"
	       _nCusto:=3
        ENDIF
	
		aadd( _aze1, {	xfilial("ZE0"),;															//01*
					ALLTRIM(ZL6T->ZL6_TPCUS),;														//02 *
					ALLTRIM(ZL6T->ZL6_DTPCUS),;														//03
					ALLTRIM(ZL6T->ZL6_CODEVE),;														//04	
					ALLTRIM(ZL6T->ZL6_DESEVE),;			 											//05
					ALLTRIM(ZL6T->ZL6_SUBEVE),;														//06
					ALLTRIM(ZL6T->ZL6_DSUBEV),;														//07
					ALLTRIM(ZL6T->ZL6_GRPCUS),;														//08
					ALLTRIM(ZL6T->ZL6_DGRCUS),;														//09
					_nQtdSin,;																		//10 - QTDE
					_nVlrSin,;																		//11 - VLR
					(substr(dtos(MV_PAR05),5,2) +  substr(dtos(MV_PAR05),1,4)),;					//12
					ALLTRIM(ZL6T->ZL6_REGRA),;														//13
					_cordem,;																		//14
					ALLTRIM(ZL6T->ZL6_CODPRO),;														//15
					ZL6T->ZL6_TCUSTO,;																//16		
					ZL6T->ZL6_TUNID,;  																//17
					ZL6T->ZL6_CODPRO,;                                                              //18
					ZL6T->ZL6_CENTRO,; 																//19				
					ZL6T->ZL6_OBSERV,; 																//20  ZL6_OBSERV
					_nCusto,;		                                                                //21  ZL6_CUSPR
					ZL6T->ZL6_FRETPE,;                                                              //22
					ZL6T->ZL6_MIX,;                                                                 //23
					ZL6T->ZL6_QTD,;                                                                 //24
					ZL6T->ZL6_GRPCUF,;                                                              //25
					ZL6T->ZL6_REDIME,;                                                              //26  ZL6_REDIME
					_nQtdemKG})                                                                     //27  _nQtdSin * fATOR
					
	Elseif ALLTRIM(ZL6T->ZL6_TPCUS) $ '000004,000005,000006'  // 02-CUSTO E ESTOQUE MP (000004,000005) e 03-ESTOQUE FINAL (000006).  PLANILHAS 02 E 03
	
		aadd(_azeNew,{	xfilial("ZE0"),;															//01*
					ALLTRIM(ZL6T->ZL6_TPCUS),;														//02 *
					ALLTRIM(ZL6T->ZL6_DTPCUS),;														//03
					ALLTRIM(ZL6T->ZL6_CODEVE),;														//04	*
					ALLTRIM(ZL6T->ZL6_DESEVE),;			 											//05
					ALLTRIM(ZL6T->ZL6_SUBEVE),;														//06      *
					UPPER(ALLTRIM(ZL6T->ZL6_DSUBEV)),;												//07  DESCRICAO
					ALLTRIM(ZL6T->ZL6_GRPCUS),;														//08   *
					ALLTRIM(ZL6T->ZL6_DGRCUS),;														//09
					_nQtdSin,;																		//10 - QTDE INICIAL
					_nVlrSin,;																		//11 - VALOR
					(substr(dtos(MV_PAR05),5,2) +  substr(dtos(MV_PAR05),1,4)),;					//12
					ALLTRIM(ZL6T->ZL6_REGRA),;														//13
					_cordem,;																		//14  *
					ALLTRIM(ZL6T->ZL6_CODPRO),;														//15 CODIGO DE PRODUTOS
					ZL6T->ZL6_TCUSTO,;																//16		
					ZL6T->ZL6_TUNID ,; 																//17
					ALLTRIM(ZL6T->ZL6_GRPPRO),;                                                     //18 GRUPOS
					ZL6T->ZL6_CENTRO,; 																//19				
					ZL6T->ZL6_OBSERV,; 																//20  
					_lTemEstoquenaDT,; 																//21 
					ZL6T->ZL6_FILIS ,; 																//22
					_aProdutos      ,; 																//23
					ALLTRIM(ZL6T->ZL6_MOBSER),;														//24
					ALLTRIM(ZL6T->ZL6_CLIENTE)})													//25

	
	Endif

	ZL6T->(dbSkip())

Enddo

ZL6T->( dbclosearea() )
_oself:IncRegua2("OK")
//  1                2           14                       8             4             6
//	xfilial("ZE0") + ZL6_TPCUS + (ZL6_ORDGRU+ZL6_ORDEM) + ZL6_GRPCUS  + ZL6_CODEVE  + ZL6_SUBEVE
_aze0  := aSort(_aze0  ,,,{|x,y| x[1]+x[2]+x[14]+x[8]+x[4]+x[6] > y[1]+y[2]+y[14]+y[8]+y[4]+y[6] })
_aze1  := aSort(_aze1  ,,,{|x,y| x[1]+x[2]+x[14]+x[8]+x[4]+x[6] > y[1]+y[2]+y[14]+y[8]+y[4]+y[6] })
_azeNew:= aSort(_azeNew,,,{|x,y| x[1]+x[2]+x[14]+x[8]+x[4]+x[6] > y[1]+y[2]+y[14]+y[8]+y[4]+y[6] })

//Total custo operacional
For _ni := 1 to len(_aze0)

	_nvalope += _aze0[_ni][11]
	
Next

_aTotCustoOp:={}

_oself:SetRegua1( len(_aze1)*2 )

_aCustoMP:={}

//_cTeste:=" _aCustoMP "+ENTER

IF _lTemMateriaPrima .AND. LEN(_aze1) > 0

   _oself:IncRegua1("2-Calculando Valor Unitario da MP ...")

   _aCustoMP     := MEST9PCustoMP(,_aZeNew,.T.,_oSelf)  //Essa função devolve as primeiras 4 linhas do _aCustoMP
   _nDifLeite    := MEST9PEstoqueMP(,_aZeNew,.T.,_oSelf)// Roda os codigos "000004" para gravar a quinta linha
   _aCustoMP[5,2]:= _nDifLeite

   //                1-NOME                    ,2-Custo,3-Custo F,4-Frete,5-Qtde,6-Frete 2
   //AADD(_aCustoMP,{"LEITE IN NATURA"         ,0      ,0        ,0      ,0     ,0        })//01
   //AADD(_aCustoMP,{"SORO DE LEITE"           ,0      ,0        ,0      ,0               })//02
   //AADD(_aCustoMP,{"SORO CONCENTRADO"        ,0      ,0        ,0      ,0               })//03    
   //AADD(_aCustoMP,{"CREME DE LEITE TERCEIROS",0      ,0        ,0      ,0               })//04     
   //AADD(_aCustoMP,{"DIFERENCA ESTOQUE MP" ,_nDifLeite,0        ,0      ,0               })//05     
   //AADD(_aCustoMP,{"SORO PRE-CONCENTRADO"    ,0      ,0        ,0      ,0               })//06    

// _cTeste+=_aCustoMP[1,1]+";"+STR(_aCustoMP[1,2],20,8)+";"+STR(_aCustoMP[1,3],20,8)+";"+STR(_aCustoMP[1,4],20,8)+";"+STR(_aCustoMP[1,5],20,8)+";"+STR(_aCustoMP[1,6],20,8)+";"+STR(_aCustoMP[1,7],20,8)+ENTER
// _cTeste+=_aCustoMP[2,1]+";"+STR(_aCustoMP[2,2],20,8)+";"+STR(_aCustoMP[2,3],20,8)+";"+STR(_aCustoMP[2,4],20,8)+";"+STR(_aCustoMP[2,5],20,8)+ENTER
// _cTeste+=_aCustoMP[3,1]+";"+STR(_aCustoMP[3,2],20,8)+";"+STR(_aCustoMP[3,3],20,8)+";"+STR(_aCustoMP[3,4],20,8)+";"+STR(_aCustoMP[3,5],20,8)+ENTER
// _cTeste+=_aCustoMP[4,1]+";"+STR(_aCustoMP[4,2],20,8)+";"+STR(_aCustoMP[4,3],20,8)+";"+STR(_aCustoMP[4,4],20,8)+";"+STR(_aCustoMP[4,5],20,8)+ENTER

ENDIF

//_cTeste:=STRTRAN(_cTeste,".",",")
//_cFileNome:=_cdir+"MEST009_CustoMP_"+xFilial("ZL6")+"_"+STRTRAN(TIME(),":","_")+".CSV"
//MemoWrite(_cFileNome,_cTeste)
//_cTeste:=" _AZE1 "+ENTER

//total geral do leite para custo operacional
_aTotais := U_MEST009E(mv_par01,MV_PAR02,MV_PAR05,MV_PAR06,3,_oself,@_lEnd)
IF _lLoop
   RETURN .F.
ENDIF
_nTotLei := _aTotais[1]
_nTotSoro:= _aTotais[2]

//Total de litragem do leite para produtos acabados
For _ni := 1 to len(_aze1)

	_oself:IncRegua1("2-Processando Regras...")

	If _lTemMateriaPrima .AND. "MATERIA PRIMA" $ _aze1[_ni][5]
                          //ZL6_DSUBEV            //ZL6_OBSERV
       If "MATERIA GORDA" $ _aze1[_ni][7] .AND. _aze1[_ni][20] = "F"

          _aze1[_ni][11]:=(  _aCustoMP[1,7]*_aze1[_ni][11] )

         IF _aze1[_ni][24] = "2" .AND. _aze1[_ni][11] > 0 //ZL6_QTD
            _aze1[_ni][11]:=(_aze1[_ni][11]*-1)
         ENDIF 
                                                            //ZL6_OBSERV             //ZL6_QTD
         _aze1[_ni][07]:= ALLTRIM(_aze1[_ni][07])+" ("+_aze1[_ni][20]+")"+" ("+_aze1[_ni][24]+")"
                          //ZL6_DSUBEV            //ZL6_OBSERV
      ELSEIf "DIFERENCA" $ _aze1[_ni][07] .AND. _aze1[_ni][20] = "3"
         _nQtPerda:=0                                    //"DIFERENCA ESTOQUE MP"
         For _nAux := 1 to len(_aze1)             
			 IF _aze1[_nAux][02]==_aze1[_ni][02] .and.;// ZL6_TPCUS
		 		_aze1[_nAux][04]==_aze1[_ni][04] .and.;// ZL6_CODEVE
				_aze1[_nAux][08]==_aze1[_ni][08] .and.;// ZL6_GRPCUS
				"PERDA MP" $ _aze1[_nAux][07]      // ZL6_DSUBEV

                _nQtPerda+=_aze1[_nAux][10]//Tem varias linhas de perdas positivas e negativas

		    ENDIF
		 NEXT 
         
		 _nQtdeNew:=((_aze1[_ni][10]+_nQtPerda)/_nTotLei) * _aCustoMP[5,2]
         _aze1[_ni][11]:=(  _nQtdeNew * _aCustoMP[1,2] )//"LEITE IN NATURA" Csuto

         IF _aze1[_ni][24] = "2" .AND. _aze1[_ni][11] > 0 //ZL6_QTD
            _aze1[_ni][11]:=(_aze1[_ni][11]*-1)
         ENDIF 
                                                            //ZL6_OBSERV            //ZL6_QTD              QUANTIDADE PROD                          QUANTIDADE PERDA
         _aze1[_ni][07]:= ALLTRIM(_aze1[_ni][07])+" ("+_aze1[_ni][20]+")"+" ("+_aze1[_ni][24]+") ("+ALLTRIM(STR(_aze1[_ni][10],20,2))+") ("+ALLTRIM(STR(_nQtPerda,20,2))+")"
         _aze1[_ni][10]:=_nQtdeNew

	   ELSEIF !EMPTY(_aze1[_ni][22])//ZL6T->ZL6_FRETPE//22
		
		_nPos:=0
       IF _aze1[_ni][22]     = '1'//"LEITE IN NATURA + TERCEIROS"
          _nPos:=1
       ELSEIF _aze1[_ni][22] = '2'//"SORO DE LEITE
          _nPos:=2
       ELSEIF _aze1[_ni][22] = '3'//"SORO DE LEITE CONCENTRADO
          _nPos:=3
       ELSEIF _aze1[_ni][22] = '4'//"CREME DE LEITE
          _nPos:=4
       ELSEIF _aze1[_ni][22] = '5'//"SORO DE LEITE PRE-CONCENTRADO
          _nPos:=6
       ENDIF

	   IF _nPos <> 0

         IF "FRETE" $ _aze1[_ni][7] 
             _aze1[_ni][11]:=(  _aCustoMP[_nPos,3]*_aze1[_ni][10] )
	     ELSE
	         IF _aze1[_ni][23] = 'L'//ZL6T->ZL6_MIX//23
                _aze1[_ni][11]:=( (_aCustoMP[_nPos,2]-_aCustoMP[_nPos,3])*_aze1[_ni][10] )
             ELSE//'P'
                _aze1[_ni][11]:=(  _aCustoMP[_nPos,2]*_aze1[_ni][10] )
             ENDIF
         ENDIF
       
         IF _aze1[_ni][24] = "2" .AND. _aze1[_ni][11] > 0 //ZL6_QTD
            _aze1[_ni][11]:=(_aze1[_ni][11]*-1)
         ENDIF 
                                                         //ZL6_MIX            //ZL6_QTD           //ZL6_FRETPE
         _aze1[_ni][07]:= ALLTRIM(_aze1[_ni][07])+" ("+_aze1[_ni][23]+") ("+_aze1[_ni][24]+") ("+_aze1[_ni][22]+")"
       ENDIF   

       ENDIF   

	ENDIF	

	If alltrim(_aze1[_ni][16]) == "6"                    

	   _cUN  :=""
       _cProd:=alltrim(_aze1[_ni][15])
       _nPos :=AT(";",_cProd)
       IF _nPos > 1
          _cProd:=SUBSTR(_cProd,1,_nPos-1)
       ENDIF
	   IF _aze1[_ni][17] == "S"  //Se usa segunda unidade puxa unidade, senão é litro
          _cUN:=Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_SEGUM")
       ELSE
          _cUN:=Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_UM")
       ENDIF
       
	   If len(_atotlei) == 0
		
		  aadd(_atotlei,{_aze1[_ni][08],_aze1[_ni][10],_aze1[_ni][11],_cUN})
			
	   Else
		
		  _np := ascan(_atotlei,{|_vAux|_vAux[1]==_aze1[_ni][08]})
			
		  If _np > 0
			
				_atotlei[_np][02] +=  _aze1[_ni][10]
				_atotlei[_np][03] +=  _aze1[_ni][11]
				
		  Else
			
				aadd(_atotlei,{_aze1[_ni][08],_aze1[_ni][10],_aze1[_ni][11],_cUN})//"LT"
				
		  Endif
			
		Endif
		
	Endif

	If alltrim(_aze1[_ni][05]) == "CUSTO OPERACIONAL" 

       _np := ascan(_aTotCustoOp,{|_vAux|_vAux[1]==_aze1[_ni][08]})
			
       If _np > 0
			
		  _aTotCustoOp[_np][02] +=  _aze1[_ni][10]
				
       Else
			
		  aadd(_aTotCustoOp,{_aze1[_ni][08],_aze1[_ni][10]})//"LT"
				
       Endif

	ENDIF

Next

_oself:IncRegua1("3-Processando Regras...")

//Atualiza custo operacional se existir
For _ni := 1 to len(_aze1)

    _oself:IncRegua1("4-Processando Regras...")
    
	If alltrim(_aze1[_ni][05]) == "CUSTO OPERACIONAL" .OR.;
	   alltrim(_aze1[_ni][05]) == "CUSTO OPERACIONAL UNIFICADO" .OR. ;
	  (!'ESTOQUE INICIAL' $ UPPER(ALLTRIM(_aze1[_ni][05])) .AND. _aze1[_ni][20] = "D")
	

       IF _aze1[_ni][20] = "D"

		  _np := ascan(_aTotCustoOp,{|_vAux|_vAux[1]==_aze1[_ni][08]})
			
		  If _np > 0

	          nTots:=_aTotCustoOp[_np,2]
	          nTots:=(( nTots /_ntotlei) * _aze1[_ni][11])
			  _aze1[_ni][11] := nTots

          ENDIF


       ELSE

	      _np := ascan(_atotlei,{|_vAux|_vAux[1]==_aze1[_ni][08]})
			
	      If _np > 0

              IF  alltrim(_aze1[_ni][05]) == "CUSTO OPERACIONAL" .AND. xFilial("ZL6") = "10"
		         if !_lMostraSoro  
   
		            _aze1[_ni][10] := _nTotLei+_nTotSoro
		            _aze1[_ni][11] := ((_nvalope/(_ntotlei+_nTotSoro) ) * _aze1[_ni][10])

		         ELSEIF "SORO" $ ALLTRIM(_aze1[_ni][9])//Soros: "00090010501;00090020501"

		            _aze1[_ni][10] := _nTotSoro
		            _aze1[_ni][11] := (((_nvalope/4)/_nTotSoro) * _aze1[_ni][10])
		           
		            
		         ELSE

		            _aze1[_ni][11] := (( (_nvalope-(_nvalope/4)) /_ntotlei) * _aze1[_ni][10])
		            
                 ENDIF

		      ELSE

		         _aze1[_ni][11] := ((_nvalope/_ntotlei) * _aze1[_ni][10])
		         
              ENDIF

     	  Endif

      ENDIF

		
	Endif	   

Next

_oself:SetRegua1( len(_aze1) )
_cTotReg:=ALLTRIM(STR(len(_aze1)))
_nConta :=0
		
//Atualiza quantidade e valor do creme (M.G.) usada nas manteigas por rateio
For _ni := 1 to len(_aze1)
	
	_nConta++
	_oself:IncRegua1("5-Processando Regras "+STR(_nConta,4)+" de "+_cTotReg )

	If substring(alltrim(_aze1[_ni][09]),1,8) == "MANTEIGA" .and. alltrim(_aze1[_ni][05]) == "MATERIA PRIMA" .and. alltrim(_aze1[_ni][20]) <> "B"
		
		_ccLeite 	:= "'24511001','24511002','24001006','24003006','24002006','24001001','24001004','24002001','24002004','24003004','24004001','24004003'"
		_ccMg500 	:= '24401001'
		_ccMg200 	:= '24401002'
		_aQtde	 	:= {}
		_dinicial	:= MV_PAR05
		_dfinal		:= MV_PAR06
		_nVlrMix 	:= 0
		_nVMixSF	:= 0
		_cEmpresa	:= Substr(FWFilialName( cEmpAnt , Xfilial("ZL6") , 2 ),8,35)
		
		dbselectarea("ZL2")
		Zl2->( dbsetorder(2) )

		If Empty(MV_PAR10)
			If ZL2->( Dbseek( xFilial("ZL2") + Alltrim(_cempresa)) )
				If ZL2->ZL2_DTUMIX >= _dinicial .and. ZL2->ZL2_DTUMIX <= ( _dfinal + 15 )
					_nVlrMix := ZL2->ZL2_ULTMIX
					_nVMixSF := ZL2->ZL2_ULMISF
				Else
					_nVlrMix := MV_PAR10
				Endif
			Else
				_nVlrMix := MV_PAR10
			Endif
		Else
			_nVlrMix := MV_PAR10
		Endif					
			
		dbclosearea()	
		
		
		_cquery:= " Select round((tmp.muq/(tmp.qm2+tmp.qm5)*tmp.qm5),2) q5, round((tmp.muq/(tmp.qm2+tmp.qm5)*tmp.qm2),2) q2 from ( "
		_cquery+= " Select m2.qtde QM2, m5.qtde QM5, (select sum(d3_quant) from "+ RetSqlName("SD3") + " SD3 " 
		_cquery+= " where sd3.d3_FILIAL = '" + xFilial("SD3") + "'"
		_cquery+= " and sd3.d_e_l_e_t_ = ' ' and d3_cf = 'DE1' 
		_cquery+= " and d3_cod = '"+alltrim(_aze1[_ni][15])+"'
		_cquery+= " and d3_cc in ("+_ccLeite+")
		_cquery+= " and d3_estorno <> 'S'
		_cquery+= " and d3_emissao between '" + DTOS(_dinicial)+ "' AND '" + DTOS(_dfinal) + "' ) muq from "
		_cquery+= " (select sum(d3_quant) qtde, d3_cod from "+ RetSqlName("SD3") + " SD3 "
		_cquery+= " where sd3.d3_FILIAL = '" + xFilial("SD3") + "'"
		_cquery+= " and sd3.d_e_l_e_t_ = ' ' and d3_cf = 'RE1' "
		_cquery+= " and d3_cc in ('"+_ccMg200+"')
		_cquery+= " and d3_estorno <> 'S' and d3_cod = '"+alltrim(_aze1[_ni][15])+"' "
		_cquery+= " and d3_emissao between '" + DTOS(_dinicial)+ "' AND '" + DTOS(_dfinal) + "'"
		_cquery+= " group by d3_cod ) m2
		_cquery+= " join (
		_cquery+= " select sum(d3_quant) qtde, d3_cod from "+ RetSqlName("SD3") + " SD3 "
		_cquery+= " where sd3.d3_FILIAL = '" + xFilial("SD3") + "'"
		_cquery+= " and sd3.d_e_l_e_t_ = ' ' and d3_cf = 'RE1' "
		_cquery+= " and d3_cc in ('"+_ccMg500+"')
		_cquery+= " and d3_estorno <> 'S' and d3_cod = '"+alltrim(_aze1[_ni][15])+"' "
		_cquery+= " and d3_emissao between '" + DTOS(_dinicial)+ "' AND '" + DTOS(_dfinal) + "'"
		_cquery+= " group by d3_cod ) m5
		_cquery+= " on m2.d3_cod = m5.d3_cod ) tmp
			
        MPSysOpenQuery( _cquery ,"SD3TT" ) 
		DBSelectArea("SD3TT")

		If .not. SD3TT->( Eof() )

			aadd(_aQtde,{SD3TT->Q5,SD3TT->Q2})
		
		Else

			aadd(_aQtde,{0,0})
	
		Endif

		SD3TT->( DbClosearea() )


		If Substr(alltrim(_aze1[_ni][09]),1,12) == "MANTEIGA 200"
			_aze1[_ni][10] := _aQtde[1][2]
			If _nVlrMix > 0
				_aze1[_ni][11] := _aQtde[1][2] * _nVlrMix
			Else	
				_aze1[_ni][11] := _aQtde[1][2] * _nVMixSF
			Endif	
		Elseif Substr(alltrim(_aze1[_ni][09]),1,12) == "MANTEIGA 500"
			_aze1[_ni][10] := _aQtde[1][1]
			If _nVlrMix > 0
				_aze1[_ni][11] := _aQtde[1][1] * _nVlrMix
			Else	
				_aze1[_ni][11] := _aQtde[1][1] * _nVMixSF
			Endif	
		Endif	
									
	Endif

Next		


//Algutina itens regra 2
_ni := 1

_aze0b := _aze0
_aze0 := {}

_oself:IncRegua1("6-Processando Regras...")

//  1                2           14                       8             4             6
//	xfilial("ZE0") + ZL6_TPCUS + (ZL6_ORDGRU+ZL6_ORDEM) + ZL6_GRPCUS  + ZL6_CODEVE  + ZL6_SUBEVE
_aze0b:= aSort(_aze0b  ,,,{|x,y| x[1]+x[2]+x[14]+x[8]+x[4]+x[6] < y[1]+y[2]+y[14]+y[8]+y[4]+y[6] })//INVERTE A ORDEM

Do while _ni <= len(_aze0b)

	_np := ascan(_aze0,{|_vAux|_vAux[01]==_aze0b[_ni][01] .and.;
							   _vAux[02]==_aze0b[_ni][02] .and.;
							   _vAux[04]==_aze0b[_ni][04] .and.;
							   _vAux[08]==_aze0b[_ni][08] .and.;
							   _vAux[14]==_aze0b[_ni][14] }) //ZL6_ORDEM

	if _aze0b[_ni][13] == "2" .and. _np > 0//ZL6_REGRA
			
		_aze0[_np][10]  +=  _aze0b[_ni][10]
		_aze0[_np][11]  +=  _aze0b[_ni][11]	
			
	Else	
	
		aadd(_aze0,_aze0b[_ni])
		
	Endif
	
	_ni++
	
Enddo
//  1                2           14                       8             4             6
//	xfilial("ZE0") + ZL6_TPCUS + (ZL6_ORDGRU+ZL6_ORDEM) + ZL6_GRPCUS  + ZL6_CODEVE  + ZL6_SUBEVE
_aze0:= aSort(_aze0  ,,,{|x,y| x[1]+x[2]+x[14]+x[8]+x[4]+x[6] > y[1]+y[2]+y[14]+y[8]+y[4]+y[6] })//DESINVERTE A ORDEM

_ni := 1

_aze1b := _aze1
_aze1 := {}

_oself:IncRegua1("7-Processando Regras...")

//  1                2           14                       8             4             6
//	xfilial("ZE0") + ZL6_TPCUS + (ZL6_ORDGRU+ZL6_ORDEM) + ZL6_GRPCUS  + ZL6_CODEVE  + ZL6_SUBEVE
_aze1b:= aSort(_aze1b  ,,,{|x,y| x[1]+x[2]+x[14]+x[8]+x[4]+x[6] < y[1]+y[2]+y[14]+y[8]+y[4]+y[6] })//INVERTE A ORDEM
//_cTeste:=""
Do while _ni <= len(_aze1b) 

	_np := ascan(_aze1,{|_vAux|_vAux[01]==_aze1b[_ni][01] .and.;
							   _vAux[02]==_aze1b[_ni][02] .and.;
							   _vAux[04]==_aze1b[_ni][04] .and.;
							   _vAux[08]==_aze1b[_ni][08] .and.;
							   _vAux[14]==_aze1b[_ni][14] }) //ZL6_ORDEM

	if _aze1b[_ni][13] == "2" .and. _np > 0//ZL6_REGRA
			
			_aze1[_np][10]  +=  _aze1b[_ni][10]
			_aze1[_np][11]  +=  _aze1b[_ni][11]	
			
	Else
	
		aadd(_aze1,_aze1b[_ni])
		
	Endif
//   _cTeste+=_aze1b[_ni][01]+";"+_aze1b[_ni][02]+";"+_aze1b[_ni][14]+";"+_aze1b[_ni][08]+";"+_aze1b[_ni][04]+";"+_aze1b[_ni][06]+ENTER
	
	_ni++
	
Enddo

//  1                2           14                       8             4             6
//	xfilial("ZE0") + ZL6_TPCUS + (ZL6_ORDGRU+ZL6_ORDEM) + ZL6_GRPCUS  + ZL6_CODEVE  + ZL6_SUBEVE
_aze1:= aSort(_aze1  ,,,{|x,y| x[1]+x[2]+x[14]+x[8]+x[4]+x[6] > y[1]+y[2]+y[14]+y[8]+y[4]+y[6] })//DESINVERTE A ORDEM

_oself:IncRegua1("9-Processando Regras...")

_aGrupos:={}
For _ni := 1 to len(_aze1)
   IF !EMPTY(_aze1[_ni][25])//ZL6_GRPCUF

	  If ASCAN(_aGrupos,{|G| G[1]==_aze1[_ni][25] })  = 0//ZL6_GRPCUF 
         AADD(_aGrupos,{_aze1[_ni][25],0})//ZL6_GRPCUF
      ENDIF   

//    _cTeste+=_aze1[_ni][25]+ENTER//ZL6_GRPCUF
   ENDIF   
NEXT

For _ni := 1 to len(_aze1)

//  _cTeste+=ARRTOKSTR(_aze1[_ni])+ENTER
   //SOMA = (MATERIA PRIMA + FRETE + INSUMOS) do grupo de custo INDICADO NO ZL6_GRPCUF

//01|000002|PRODUTOS ACABADOS|000052|PRODUTOS ACABADOS PRODUZIDOS|0001|PRODUTOS ACABADOS PRODUZIDOS|000001|LEITE UHT ITALAC 1 L|0|0|012019|4|99999999|00010010101;00010010120;00010010134;00010030101;00010030120;00010030134;00010020101;00010020120;00010020134|6| |00010010101;00010010120;00010010134;00010030101;00010030120;00010030134;00010020101;00010020120;00010020134                                                                         | |3|0| | |1|    

	If (nPos:=ASCAN(_aGrupos,{|G| G[1] ==_aze1[_ni][8] }) ) <> 0  .AND._aze1[_ni][2] == "000002" .AND.;
	   ("MATERIA PRIMA" $ _aze1[_ni][5] .OR. "FRETE" $ _aze1[_ni][5] .OR. "INSUMOS" $ _aze1[_ni][5])

       _aGrupos[nPos,2]+=_aze1[_ni][11]

//     _cTeste+=STR(_aze1[_ni][11],20,8)+"|"+ENTER
//     _cTeste+=STR(_aGrupos[nPos,2],20,8)+"|"+ENTER

	ENDIF

NEXT

_oself:IncRegua1("10-Processando Regras...")

For _ni := 1 to len(_aze1)


   IF !EMPTY(_aze1[_ni][25])           //ZL6_GRPCUF                    //ZL6_DESEVE
	  If (nPos:=ASCAN(_aGrupos,{|G| G[1]==_aze1[_ni][25]  }) ) <> 0 //ZL6_GRPCUF 
          
           _cQuery:=""
           nQtde:=U_MEST009A(MV_PAR05,MV_PAR06,"PR0",_aze1[_ni][15],"")[2]

          _aze1[_ni][11]:=(_aGrupos[nPos,2]/nQtde)*_aze1[_ni][10]

//       _cTeste+="QUERY:| "+_aze1[_ni][05]+" -| "+_cQuery+ENTER
//       _cTeste+="QUTDE:| "+_aze1[_ni][25]+" -| "+STR(nQtde,20,8)+ENTER
//       _cTeste+="VALOR:| "+_aze1[_ni][25]+" -| "+STR(_aGrupos[nPos,2],20,8)+ENTER
	    ENDIF
	ENDIF
NEXT

//_cTeste:=STRTRAN(_cTeste,".",",")//ACERTA NUMEROS 
//_cTeste:=STRTRAN(_cTeste,";","/")//ACERTA LISTAS
//_cTeste:=STRTRAN(_cTeste,"|",";")//ACERTA PARA CSV
//_cFileNome:=_cdir+"MEST009_AZE1_"+xFilial("ZL6")+"_"+STRTRAN(TIME(),":","_")+".CSV"
// MemoWrite(_cFileNome,_cTeste)

Return


/*
===============================================================================================================================
Programa----------: MEST009E2
Autor-------------: Josue Danich Prestes
Data da Criacao---: 23/11/2015
Descricao---------: Gera corpo de custos do Excel
Parametros--------: _AZE0 - array com dados de custo do grupo
						_ctitulo - Titulo do grupo
						_ntoteli2 - total de litragem ou unidades
						_cproduto - produto do grupo
						_cun - unidade do produto
Retorno-----------: _axml
===============================================================================================================================
*/

Static function MEST009E2(_aze0,_ctitulo,_ntotlei2,_cproduto,_cun)

Local _axml 		:= {}
Local _cult 		:= alltrim(_aze0[01][08])+alltrim(_aze0[01][04])
Local _nqtot 		:= 0
Local _nvtot		:= 0 
Local _ni 			:= 1 
Local _cult2 		:= alltrim(_aze0[01][09])
Local _cult3		:= alltrim(_aze0[01][08])+alltrim(_aze0[01][04])+alltrim(_aze0[01][06])
Local _nsubtot		:= 0 
Local _ntotger		:= 0
Local _nporce		:= 0
Local _asubs		:= {}
Local _ni2			:= 1
Local _nsubtot2		:= 0
Local _lsub			:= .F.
Local _ctitulo2		:= _ctitulo
Local _aicst		:= {}
Local _aExp 		:= {}  //Quantidade expedida
Local _aFret		:= {}  //Valor Frete
Local _nExp 		:= 0
Local _nExpD 		:= 0
Local _nExpF 		:= 0
Local _nExpT 		:= 0 ,  nX   , nPos


//Default _cun := "LT"
Default _cun := U_ITGETMV("IT_UMVOLLEI","LT")
Default _ntotlei2 := 0
_ntotlei := _ntotlei2


//=========================================================================
//Monta cabeçalho da seção
//=========================================================================
If _nPag > 1

	aadd( _axml, '   <Row ss:AutoFitHeight="0" ss:Height="18">')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0" ss:Height="18">')
	aadd( _axml, '   </Row>')

Endif

aadd( _axml, '   <Row ss:AutoFitHeight="0" ss:Height="18">')
aadd( _axml, '    <Cell ss:MergeDown="1" ss:StyleID="s69"/>')
aadd( _axml, '    <Cell ss:StyleID="s71"/>')
aadd( _axml, '    <Cell ss:MergeAcross="4" ss:StyleID="s73"><Data ss:Type="String">' + _ctitulo2 + '</Data></Cell>')
aadd( _axml, '    <Cell ss:StyleID="s74"><Data ss:Type="Number">' + strzero(_nPag,3) + '</Data></Cell>')
aadd( _axml, '   </Row>')
aadd( _axml, '   <Row ss:AutoFitHeight="0" ss:Height="18">')
aadd( _axml, '    <Cell ss:Index="2" ss:StyleID="s71"/>')
If "UNIFICADO" $ _aze0[1][3]
	If xFilial("ZL6") == "23"
		aadd( _axml, '    <Cell ss:MergeAcross="4" ss:StyleID="s73"><Data ss:Type="String">POR LITROS PRODUZIDOS  -  ITALAC/SUL UNIFICADO </Data></Cell>')
	ElseIf xFilial("ZL6") == "10"
		aadd( _axml, '    <Cell ss:MergeAcross="4" ss:StyleID="s73"><Data ss:Type="String">POR LITROS PRODUZIDOS  -  ITALAC/RONDONIA UNIFICADO </Data></Cell>')
	Endif		
Else	
	aadd( _axml, '    <Cell ss:MergeAcross="4" ss:StyleID="s73"><Data ss:Type="String">POR LITROS PRODUZIDOS  - ' + FWFilialName( cEmpAnt , Xfilial("ZL6") , 2 )  + '</Data></Cell>')
Endif	
aadd( _axml, '    <Cell ss:StyleID="s75"><Data ss:Type="String">' + mesextenso(month(MV_PAR05)) + '/' + alltrim(str(year(MV_PAR05))) + '</Data></Cell>')
aadd( _axml, '   </Row>')
aadd( _axml, '   <Row ss:AutoFitHeight="0">')
aadd( _axml, '    <Cell ss:StyleID="s76"/>')
aadd( _axml, '    <Cell ss:StyleID="s77"/>')
aadd( _axml, '    <Cell ss:StyleID="s78"/>')
aadd( _axml, '    <Cell ss:StyleID="s79"/>')
aadd( _axml, '    <Cell ss:StyleID="s80"/>')
aadd( _axml, '    <Cell ss:StyleID="s81"/>')
aadd( _axml, '    <Cell ss:StyleID="s82"/>')
aadd( _axml, '    <Cell ss:StyleID="s83"/>')
aadd( _axml, '   </Row>')
aadd( _axml, '   <Row ss:AutoFitHeight="0">')
aadd( _axml, '    <Cell ss:StyleID="s84"/>')
aadd( _axml, '    <Cell ss:StyleID="s71"/>')
aadd( _axml, '    <Cell ss:StyleID="s84"/>')
aadd( _axml, '    <Cell ss:StyleID="s85"/>')
aadd( _axml, '    <Cell ss:StyleID="s86"/>')
aadd( _axml, '    <Cell ss:StyleID="s87"/>')
aadd( _axml, '    <Cell ss:StyleID="s84"/>')
aadd( _axml, '    <Cell ss:StyleID="s84"/>')
aadd( _axml, '   </Row>')

//=============================================================================================================
//Só trás dolar e litragem para filiais menores que 90 (não CD)
//=============================================================================================================

aadd( _axml, '   <Row ss:AutoFitHeight="0">')
aadd( _axml, '    <Cell ss:MergeAcross="1" ss:StyleID="s89"><Data ss:Type="String">DOLAR COML</Data></Cell>')
aadd( _axml, '    <Cell ss:StyleID="s94"><Data ss:Type="Number">'+ALLTRIM(str(_nTotdol))+'</Data></Cell>')
aadd( _axml, '    <Cell ss:StyleID="s95"/>')
aadd( _axml, '    <Cell ss:StyleID="s86"/>')
aadd( _axml, '    <Cell ss:StyleID="s96"/>')
aadd( _axml, '    <Cell ss:StyleID="s97"/>')
aadd( _axml, '    <Cell ss:StyleID="s97"/>')
aadd( _axml, '   </Row>')

_cTesteA:=_ctitulo+ENTER
_cTesteA:=_ctitulo2+ENTER
_cTesteA+="ZL6_TPCUS;ZL6_DTPCUS;ZL6_DESEVE;ZL6_DSUBEV;PROD;ZL6_REDIME;_nQtdSin;_nQtdemKG;_nQtdeProd;_aze0[nX][21] * _aFactoMike[nPos,3];ZL6_OBSERV"+ENTER
_nRendim:=0
_nQtdeProd:=0
_cImpProdKG:=""
_lImpProdKG:=.F.
For nX := 1 to len(_aze0)
    _nQtdemKG:=0
	IF ALLTRIM(_aze0[nX][19]) $ "S,A"//ZL6_REDIME
	   IF ALLTRIM(_aze0[nX][19]) = "S"//ZL6_REDIME
	      _nQtdeProd+=_aze0[nX][10]//_nQtdSin
	      FOR nPos := 1 TO LEN(_aFactoMike)
	          IF _aFactoMike[nPos,4] $ ALLTRIM(_aze0[nX][15])//posicao 4 codigos 
                 _aFactoMike[nPos,3] := (_nQtdeProd/_nTotLei)//Rendimento  do leite em PÓ
	          ENDIF
	      NEXT
	   ELSEIF ALLTRIM(_aze0[nX][19]) = "A"//ZL6_REDIME
	      _nQtdemKG:=_aze0[nX][21]
	      IF (nPos:=ASCAN(_aFactoMike, {|P| P[1] $ ALLTRIM(_aze0[nX][15]) })) <>  0 .AND. _aFactoMike[nPos,3] <> 0 
             _nQtdemKG := ( _aze0[nX][21] * _aFactoMike[nPos,3] )
	      ENDIF
	      _nQtdeProd+=_nQtdemKG//_nQtdemKG
	   ENDIF  
//     _nRendim+=_aze2[nX][10]//SE TIVER 2 LINHAS COM S NO _aze0 vai duplicar
    ENDIF
    IF ALLTRIM(_aze0[nX][19]) = "A"//ZL6_REDIME
       _lImpProdKG:=.T.
	ENDIF
	IF "PERDAS P.A." $ _aze0[nX][7]
       _cImpProdKG:=ALLTRIM(_aze0[nX][15])
	ENDIF
    _cTesteA+="'"+_aze0[nX][2]+";"+_aze0[nX][3]+";"+_aze0[nX][9]+";'"+_aze0[nX][7]+";'"+STRTRAN(_aze0[nX][15],";",",")+";"+_aze0[nX][19]+";"+;
    STR(_aze0[nX][10])+";"+STR(_aze0[nX][21])+";"+STR(_nQtdeProd)+";"+STR(_nQtdemKG)+";"+_aze0[nX][20]+ENTER
NEXT

//_cRendim := Posicione("ZL6",8,xFilial("ZL6")+_aze2[1][17]+PADR(_aze2[1][3],60)+PADR(_aze2[1][16],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_REDIME")

IF _lImpProdKG
	_nPos:=AT(";",_cImpProdKG)
	IF _nPos > 1
		_cImpProdKG:=SUBSTR(_cImpProdKG,1,_nPos-1)
	ENDIF
	SB1->(DbSetOrder(1))
	SB1->(DBSeek(xFilial("SB1")+_cImpProdKG)) 
    cRet:=AllTrim(Posicione("ZA2",1,xFilial("ZA2")+SB1->B1_I_NIV3,"ZA2_DESCRI"))
    _cTesteA+=ENTER
    _cTesteA+="ZA2_DESCRI = "+cRet+ENTER
    IF "KG" $ UPPER(cRet)
       nFator:=VAL(STRTRAN(cRet,",","."))
    ELSE
       nFator:=VAL(cRet)/1000
    ENDIF   
    _cTesteA+="nFator = "+STR(nFator)+ENTER
    _cTesteA+="_nTotLei = "+STR(_nTotLei)+ENTER
   _nProdKG := nFator * _nTotLei
    _cTesteA+="_nProdKG = "+STR(_nProdKG)+ENTER
   aadd( _axml, '   <Row ss:AutoFitHeight="0">')
   aadd( _axml, '    <Cell ss:MergeAcross="1" ss:StyleID="s89"><Data ss:Type="String">PRODUCAO KG</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">' + alltrim(str(_nProdKG)) + '</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s95"/>')
   aadd( _axml, '    <Cell ss:StyleID="s86"/>')
   aadd( _axml, '    <Cell ss:StyleID="s96"/>')
   aadd( _axml, '    <Cell ss:StyleID="s97"/>')
   aadd( _axml, '    <Cell ss:StyleID="s97"/>')
   aadd( _axml, '   </Row>')

   _nRendim:=(_nQtdeProd/_nProdKG)

    _cTesteA+=" _nQtdeProd/_nProdKG : "+str(_nQtdeProd)+ " / "+ str(_nProdKG)+ENTER

ELSE
   _nRendim:=(_nQtdeProd/_nTotLei)

    _cTesteA+=" _nQtdeProd/_nTotLei : "+str(_nQtdeProd)+ " / "+ str(_nTotLei)+ENTER

ENDIF

IF _nQtdeProd <> 0
   aadd( _axml, '   <Row ss:AutoFitHeight="0">')
   aadd( _axml, '    <Cell ss:MergeAcross="1" ss:StyleID="s89"><Data ss:Type="String">RENDIMENTO</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">' + alltrim(str(_nRendim)) + '</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s95"/>')
   aadd( _axml, '    <Cell ss:StyleID="s86"/>')
   aadd( _axml, '    <Cell ss:StyleID="s96"/>')
   aadd( _axml, '    <Cell ss:StyleID="s97"/>')
   aadd( _axml, '    <Cell ss:StyleID="s97"/>')
   aadd( _axml, '   </Row>')
ENDIF


aadd( _axml, '   <Row ss:AutoFitHeight="0">')
aadd( _axml, '    <Cell ss:MergeAcross="1" ss:StyleID="s99"><Data ss:Type="String">' + IF(xfilial("ZL6") = "10",'LEITE/QUEIJO/LEITE EM PO/MANTEIGA','') + '</Data></Cell>')
//aadd( _axml, '    <Cell ss:StyleID="' + Iif(val(xfilial("ZL6")) < 90,'s103"><Data ss:Type="String">','s108"><Data ss:Type="String">') + Iif(val(xfilial("ZL6")) < 90,TRANSFORM(_nTotLei, "@E 999,999,999.99" ) + ' ' + alltrim(_cun),'') + '</Data></Cell>')
aadd( _axml, '    <Cell ss:StyleID="s103"><Data ss:Type="String">' + TRANSFORM(_nTotLei, "@E 999,999,999.99" ) + ' ' + alltrim(_cun) + '</Data></Cell>')
aadd( _axml, '    <Cell ss:StyleID="s104"><Data ss:Type="String">QUANTIDADE</Data></Cell>')
aadd( _axml, '    <Cell ss:StyleID="s105"><Data ss:Type="String">UNIT.</Data></Cell>')
aadd( _axml, '    <Cell ss:StyleID="s106"><Data ss:Type="String">VALORES ( R$ )</Data></Cell>')
aadd( _axml, '    <Cell ss:StyleID="s107"><Data ss:Type="String">P. R$(P/LT )</Data></Cell>')
aadd( _axml, '    <Cell ss:StyleID="s108"><Data ss:Type="String">P. US$(P/LT )</Data></Cell>')
aadd( _axml, '   </Row>')

IF _cTitulo = "CUSTO OPERACIONAL" .AND. xFilial("ZL6") = "10"//LEITE/QUEIJO/LEITE EM PO/MANTEIGA
   aadd( _axml, '   <Row ss:AutoFitHeight="0">')
   aadd( _axml, '    <Cell ss:MergeAcross="1" ss:StyleID="s99"><Data ss:Type="String">SORO</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s103"><Data ss:Type="String">'+TRANSFORM(_nTotSoro, "@E 999,999,999.99" ) + ' ' + alltrim(_cun) + '</Data></Cell>')
   aadd( _axml, '   </Row>')
ENDIF

aadd( _axml, '   <Row ss:AutoFitHeight="0">')
aadd( _axml, '    <Cell ss:StyleID="s109"/>')
aadd( _axml, '    <Cell ss:StyleID="s110"/>')
aadd( _axml, '    <Cell ss:StyleID="s111"/>')
aadd( _axml, '    <Cell ss:StyleID="s112"/>')
aadd( _axml, '    <Cell ss:StyleID="s86"/>')
aadd( _axml, '    <Cell ss:StyleID="s113"/>')
aadd( _axml, '    <Cell ss:StyleID="s114"/>')
aadd( _axml, '    <Cell ss:StyleID="s114"/>')
aadd( _axml, '   </Row>')

	
//========================================================================
//Monta total geral e subtotais para usar na montagem do corpo do excel
//=========================================================================
_cult2 := alltrim(_aze0[_ni][08]) 
_nTotCusP := 0//CUSTO PRODUCAO
_nTotCusA := 0//CUSTO PRODUTO ABERTO

//_cTeste:=" EXCEL: "+ENTER

For _ni := 1 to len(_aze0)

	If alltrim(_aze0[_ni][13]) <> "4"//ZL6_REGRA
	
		If _cult2 != alltrim(_aze0[_ni][08]) //ZL6_CODEVE
	
			aadd(_asubs, _nsubtot)

//           _cTeste+="TOTAL.D:;"+_aze0[_ni][13]+";"+_aze0[_ni][02]+";"+_aze0[_ni][16]+";"+_aze0[_ni][09]+";"+_aze0[_ni][07]+";"+STR(_nsubtot,20,8)+ENTER
			
  			_nTotCusP += _nsubtot//CUSTO PRODUCAO

			_nsubtot := 0
			
			_cult2 := alltrim(_aze0[_ni][08])//ZL6_CODEVE 
	
		Endif  
	
		If alltrim(_aze0[_ni][13]) <> "5" //ZL6_REGRA
		
//         _cTeste+="SOMA:;"+_aze0[_ni][13]+";"+_aze0[_ni][02]+";"+_aze0[_ni][16]+";"+_aze0[_ni][09]+";"+_aze0[_ni][07]+";"+STR(_aze0[_ni][11],20,8)+ENTER
                                            //                             _aze0[_ni][18] == 0 = "N" = ZL6T->ZL6_CUSPR 
	       If !(LEN(_aze0[_ni]) >= 18 .AND. VALTYPE(_aze0[_ni][18]) = "N" .AND. _aze0[_ni][18] <> 0)//--> <> N //soma tudo que não tiver a regra do ZL6T->ZL6_CUSPR = "S" e "A"
		      _nsubtot += _aze0[_ni][11]
		   ENDIF
		  _ntotger += _aze0[_ni][11]

		Endif

		IF "EMBALAGENS" $ _aze0[_ni][09]//ZL6_DESEVE
            _nTotCusA += _aze0[_ni][11]//CUSTO PRODUTO ABERTO
        ENDIF   
		
	Endif
		
Next


//_cTeste+="TOTAL.F:;"+STR(_nsubtot,20,8)+ENTER
aadd(_asubs, _nsubtot)
_nTotCusP += _nsubtot//CUSTO PRODUCAO


//===================================================================================================
//Para registros marcados como custo médio de produção atualiza custo pelo subtotal de produção
//===================================================================================================
_ncusmed := _nTotCusP / _ntotlei//CUSTO PRODUCAO
_nCusAbe := _nTotCusA / _ntotlei//CUSTO PRODUTO ABERTO
_lrecalc := .F.

//_cTeste+= "_ncusmed:;"+STR(_ncusmed,20,8)+";"+STR(_nTotCusP,20,8)+";"+STR(_ntotlei,20,8)
//_cTeste+=ENTER
//_cTeste+= "_nCusAbe:;"+STR(_nCusAbe,20,8)+";"+STR(_nTotCusA,20,8)+";"+STR(_ntotlei,20,8)
//_cTeste+=ENTER
//_cTeste+="CALCULO: "+ENTER

For _ni := 1 to len(_aze0)


  If _aze0[_ni][3] == "PRODUTOS ACABADOS"  

                                         //                             _aze0[_ni][18] == 0 = "N" = ZL6T->ZL6_CUSPR 
	If  LEN(_aze0[_ni]) >= 18 .AND. VALTYPE(_aze0[_ni][18]) = "N" .AND. _aze0[_ni][18] <> 0//--> <> N

//      _cTeste+=_aze0[_ni][02]+";"+_aze0[_ni][16]+";"+_aze0[_ni][09]+";"+_aze0[_ni][07]+";"+STR(_nTotCusP,20,8)+";"+STR(_ntotlei,20,8)+";"+STR(_nCusmed,20,8)+ENTER

        IF _aze0[_ni][18] = 1            // ZL6T->ZL6_CUSPR = "S" = 1 = _aze0[_ni][18]

//          _cTeste+=_aze0[_ni][02]+";"+_aze0[_ni][16]+";"+_aze0[_ni][09]+";"+_aze0[_ni][07]+";"+STR(_aze0[_ni][11],20,8)+";"+STR(_aze0[_ni][10],20,8)+";"+STR(_nCusmed,20,8)+ENTER

		   _aze0[_ni][11] := _ncusmed * _aze0[_ni][10]//CUSTO PRODUCAO
		   _lrecalc := .T.

  		ELSEIF _aze0[_ni][18] = 2        // ZL6T->ZL6_CUSPR = "A" = 2 = _aze0[_ni][18]
           IF _nCusAbe = 0//ZE0_TPCUS+ZE0_GRPCT+ZE0_DSECT
              _nCusAbe:=MEST2BuscaZE0(_aze0[_ni][2],_aze0[_ni][16],_aze0[_ni][7],_aze0[_ni])
           ENDIF
		   _aze0[_ni][11] := _nCusAbe * _aze0[_ni][10]//CUSTO PRODUTO ABERTO
		   _lrecalc := .T.

 		ENDIF

	Endif

  Endif
	
Next

//_cTeste:=STRTRAN(_cTeste,".",",")
//_cFileNome:=_cdir+"MEST009_SOMA_P_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".CSV"
//MemoWrite(_cFileNome,_cTeste)

//========================================================================
//ReMonta total geral e subtotais para usar na montagem do corpo do excel
//=========================================================================

If _lrecalc

	_cult2 := alltrim(_aze0[1][08])//ZL6_CODEVE
	_asubs := {}
	_nsubtot := 0
	_ntotger := 0 

	For _ni := 1 to len(_aze0)

		If alltrim(_aze0[_ni][13]) <> "4"
	
			If _cult2 != alltrim(_aze0[_ni][08]) //ZL6_CODEVE
	
				aadd(_asubs, _nsubtot)
				_nsubtot := 0
				_cult2 := alltrim(_aze0[_ni][08]) //ZL6_CODEVE
	
			Endif  
	
			If alltrim(_aze0[_ni][13]) <> "5"
		
				_ntotger += _aze0[_ni][11]
				_nsubtot += _aze0[_ni][11]
		
			Endif
		
		Endif
		
	Next
	aadd(_asubs, _nsubtot)

Endif
/*
_cTeste+= "SUB;"+arrtokstr(_asubs)
_cTeste+=ENTER
_cTeste+= "TOG;"+STR(_ntotger,20,8)
_cTeste+=ENTER

_cTeste:=STRTRAN(_cTeste,".",",")
_cTeste:=STRTRAN(_cTeste,"|",";")
_cFileNome:=_cdir+"MEST009_AZE0_"+xFilial("ZL6")+"_"+STRTRAN(TIME(),":","_")+".CSV"
MemoWrite(_cFileNome,_cTeste)
*/
//===================================================================
//Reinicializa contadores e monta corpo do excel
//===================================================================
_cult2 	:= alltrim(_aze0[01][09])
_nsubtot:= 0
_np2v 	:= 0
AADD(_aze0,{"","XXXXXX","3","XXXXX","5","6","7","XXXXX","9",0,0,"12","","14","15","16","17","18","19","20",0})
AADD(_aze0,{"","XXXXXX","3","XXXXX","5","6","7","XXXXX","9",0,0,"12","","14","15","16","17","18","19","20",0})
_aSomaEntTrans:={0,0}
For _ni := 1 to len(_aze0) 

	If _aze0[_ni][20] = "1" .AND. "ENTRADAS TRANSFERENCIA" $ ALLTRIM(_aze0[_ni][7])
       _aSomaEntTrans[1]+=_aze0[_ni][10]
       _aSomaEntTrans[2]+=_aze0[_ni][11]
	ENDIF
		
	If alltrim(_aze0[_ni][13]) <> "4"
		
		If (alltrim(_aze0[_ni][08])+alltrim(_aze0[_ni][04]) == _cult .and. alltrim(_aze0[_ni][13]) != "3" .and. alltrim(_aze0[_ni][13]) != "2") .or.;
			(alltrim(_aze0[_ni][08])+alltrim(_aze0[_ni][04])+alltrim(_aze0[_ni][06])  == _cult3 .and. alltrim(_aze0[_ni][13]) != "3" .and. alltrim(_aze0[_ni][13]) == "2")
			
			If alltrim(_aze0[_ni][13]) <> "5"
				
				_nqtot 	 +=	_aze0[_ni][10]
				_nvtot	 +=	_aze0[_ni][11]
				_nsubtot +=	_aze0[_ni][11]
				_nsubtot2+=	_aze0[_ni][11]
			Else
				_nqtot 	+= 	_aze0[_ni][10]
				_nvtot	+= 	_aze0[_ni][11]
			Endif
			
			_np2v++
			
		ElseIF alltrim(_aze0[_ni][13]) != "3"
			
			_cult := alltrim(_aze0[_ni][08])+alltrim(_aze0[_ni][04])//ZL6_CODEVE
			_cult3:= alltrim(_aze0[01][08])+alltrim(_aze0[01][04])+alltrim(_aze0[01][06])
			_ni--
			
			aadd( _axml, '   <Row ss:AutoFitHeight="0">')
			
			
			If _cult2 != alltrim(_aze0[_ni][08]) .or. _ni2 == 1//ZL6_CODEVE
				
				If _ni2 <= len(_asubs)
					
					_nporce := (_asubs[_ni2] /_ntotger) * 100
					
				Else
					
					_nporce := 0
					
				Endif
				
				_ni2++

	            IF ALLTRIM(_aze0[_ni][09]) == "CUSTO FILIAIS" .AND. (_lGera4Pla .OR. _lGera2Pla)// .OR. _lGera1Pla)
	            	_aCusto04[2,2]:=_ntotlei
            		_aCusto04[2,3]:=_nvtot
            		_aCusto04[2,4]:=_nvtot / _ntotlei
            	ENDIF
				
				aadd( _axml, '    <Cell ss:StyleID="s153"><Data ss:Type="String">' + _aze0[_ni][09] + ' - ' + transform( _nporce, "@E 999.99%")   +  '</Data></Cell>')
				_cult2 := alltrim(_aze0[_ni][08])//ZL6_CODEVE
				
			Elseif alltrim(_aze0[_ni][08]) == alltrim(_aze0[_ni][08])//ZL6_CODEVE
				
				aadd( _axml, '    <Cell ss:StyleID="s126"><Data ss:Type="String">  </Data></Cell>')
				
			Else
				
				aadd( _axml, '    <Cell ss:StyleID="s134"><Data ss:Type="String">  </Data></Cell>')
				
			Endif
			
			_lsub := .F.
			
			If _ni == len(_aze0) .or. alltrim(_aze0[_ni][08]) != alltrim(_aze0[_ni+1][08])//ZL6_CODEVE
				
/*				If alltrim(_aze0[_ni][13]) == "2"
					
					_ccod := ""
					_cdesc := ""
					
				Else*/
					
					_ccod := _aze0[_ni][04]
					_cdesc := _aze0[_ni][05]
					
//				Endif
				
				_lsub := .T.
				_nVlr_Unitario:=_nvtot / _nqtot
				_nReal_Litro  :=_nvtot / _ntotlei 
				_nUSS_Litro   :=_nvtot / ( _ntotlei * _nTotdol )
				IF _nVlr_Unitario < 0
				   _nVlr_Unitario:=(_nVlr_Unitario*-1)
				ENDIF  
				IF _nReal_Litro < 0
				   _nReal_Litro:=(_nReal_Litro*-1)
				ENDIF  
				IF _nUSS_Litro < 0
				   _nUSS_Litro:=(_nUSS_Litro*-1)
				ENDIF  

                FOR nPos := 1 TO LEN(_aRecalVlrs)
              	   IF _aRecalVlrs[nPos,2] $ UPPER(LEFT(ALLTRIM(_cdesc),21))
                       _nVlr_Unitario:=_aRecalVlrs[nPos,3]//(_ntotger / _ntotlei)//P. R$(P/LT )
              	   ENDIF
                NEXT			
				
				aadd( _axml, '    <Cell ss:StyleID="s156"><Data ss:Type="String">' + _ccod   + '</Data></Cell>')
				aadd( _axml, '    <Cell ss:StyleID="s157"><Data ss:Type="String">' + _cdesc + '</Data></Cell>')
				aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">' + alltrim(str(_nqtot)) + '</Data></Cell>')
				aadd( _axml, '    <Cell ss:StyleID="s159"><Data ss:Type="Number">' + alltrim(str((_nVlr_Unitario))) + '</Data></Cell>')
				aadd( _axml, '    <Cell ss:StyleID="s160"><Data ss:Type="Number">' + alltrim(str(_nvtot)) + '</Data></Cell>')
				
				aadd( _axml, '    <Cell ss:StyleID="s161"><Data ss:Type="Number">' + alltrim(str(_nReal_Litro )) + '</Data></Cell>')
				aadd( _axml, '    <Cell ss:StyleID="s162"><Data ss:Type="Number">' + alltrim(str(_nUSS_Litro  )) + '</Data></Cell>')
				
				aadd( _axml, '   </Row>')
				
				aadd( _axml, '   <Row ss:AutoFitHeight="0">')
				aadd( _axml, '    <Cell ss:StyleID="s116"/>')
				aadd( _axml, '    <Cell ss:StyleID="s71"/>')
				aadd( _axml, '    <Cell ss:StyleID="s64"/>')
				aadd( _axml, '    <Cell ss:StyleID="s140"><Data ss:Type="String">Sub-Total.:</Data></Cell>')
				aadd( _axml, '    <Cell ss:StyleID="s141"/>')
				aadd( _axml, '    <Cell ss:StyleID="s142"><Data ss:Type="Number">' + alltrim(str(_nsubtot)) + '</Data></Cell>')
				aadd( _axml, '    <Cell ss:StyleID="s143"><Data ss:Type="Number">' + alltrim(str(_nsubtot / _ntotlei)) + '</Data></Cell>')
				aadd( _axml, '    <Cell ss:StyleID="s144"><Data ss:Type="Number">' + alltrim(str(_nsubtot / ( _ntotlei * _nTotdol ))) + '</Data></Cell>')
				aadd( _axml, '   </Row>')
				aadd( _axml, '   <Row ss:AutoFitHeight="0">')
				aadd( _axml, '    <Cell ss:StyleID="s145"/>')
				aadd( _axml, '    <Cell ss:StyleID="s146"/>')
				aadd( _axml, '    <Cell ss:StyleID="s145"/>')
				aadd( _axml, '    <Cell ss:StyleID="s145"/>')
				aadd( _axml, '    <Cell ss:StyleID="s147"/>')
				aadd( _axml, '    <Cell ss:StyleID="s148"/>')
				aadd( _axml, '    <Cell ss:StyleID="s148"/>')
				aadd( _axml, '    <Cell ss:StyleID="s148"/>')
				aadd( _axml, '   </Row>')
				
				_nsubtot := 0
				
			Else
				
/*				If alltrim(_aze0[_ni][13]) == "2"
					
					_ccod :=  ""
					_cdesc :=  ""
					
				Else*/
					
					_ccod := _aze0[_ni][04]
					_cdesc := _aze0[_ni][05]
					
//				Endif

				_nVlr_Unitario:=_nvtot / _nqtot
				_nReal_Litro  :=_nvtot / _ntotlei 
				_nUSS_Litro   :=_nvtot / ( _ntotlei * _nTotdol )
				IF _nVlr_Unitario < 0
				   _nVlr_Unitario:=(_nVlr_Unitario*-1)
				ENDIF  
				IF _nReal_Litro < 0
				   _nReal_Litro:=(_nReal_Litro*-1)
				ENDIF  
				IF _nUSS_Litro < 0
				   _nUSS_Litro:=(_nUSS_Litro*-1)
				ENDIF  

                FOR nPos := 1 TO LEN(_aRecalVlrs)
              	   IF _aRecalVlrs[nPos,2] $ UPPER(LEFT(ALLTRIM(_cdesc),21))  .AND. _aRecalVlrs[nPos,3] <> 0
                       _nVlr_Unitario:=_aRecalVlrs[nPos,3] //:= (_ntotger / _ntotlei)//P. R$(P/LT )
              	   ENDIF
                NEXT
				
				aadd( _axml, '    <Cell ss:StyleID="s116"><Data ss:Type="String">' + _ccod   + '</Data></Cell>')
				aadd( _axml, '    <Cell ss:StyleID="s117"><Data ss:Type="String">' + _cdesc + '</Data></Cell>')
				aadd( _axml, '    <Cell ss:StyleID="s119"><Data ss:Type="Number">' + alltrim(str(_nqtot)) + '</Data></Cell>')
				aadd( _axml, '    <Cell ss:StyleID="s120"><Data ss:Type="Number">' + alltrim(str(_nVlr_Unitario)) + '</Data></Cell>')
				aadd( _axml, '    <Cell ss:StyleID="s122"><Data ss:Type="Number">' + alltrim(str(_nvtot)) + '</Data></Cell>')

				aadd( _axml, '    <Cell ss:StyleID="s161"><Data ss:Type="Number">' + alltrim(str(_nReal_Litro )) + '</Data></Cell>')
				aadd( _axml, '    <Cell ss:StyleID="s162"><Data ss:Type="Number">' + alltrim(str(_nUSS_Litro  )) + '</Data></Cell>')

//				aadd( _axml, '    <Cell ss:StyleID="s123"><Data ss:Type="Number">' + alltrim(str(_nvtot / _ntotlei )) + '</Data></Cell>')
//				aadd( _axml, '    <Cell ss:StyleID="s124"><Data ss:Type="Number">' + alltrim(str(_nvtot / ( _ntotlei * _nTotdol ))) + '</Data></Cell>')

				aadd( _axml, '   </Row>')				
				
			Endif
			
			_ni++
			
			If alltrim(_aze0[_ni][13]) != "5"
				
				_nqtot := _aze0[_ni][10]
				_nvtot := _aze0[_ni][11]
				_nsubtot 	+=	_aze0[_ni][11]
				_nsubtot2 	+=	_aze0[_ni][11]
			Else
				_nqtot := _aze0[_ni][10]
				_nvtot := _aze0[_ni][11]
				
			Endif
			
			_np2v := 0
			
		Endif
		
	Endif
	
Next

//=========================================================================
//Ultima linha antes dos totais gerais
//=========================================================================
If _np2v < 1
	
	_ni := len(_aze0)
/*	
	If alltrim(_aze0[_ni][13]) == "2"
		
		_ccod :=  ""
		_cdesc := ""
		
	Else*/
		
		_ccod := _aze0[_ni][04]
		_cdesc := _aze0[_ni][05]
		
//	Endif
	
	_lsub := .T.
	
	If len(_asubs) > 0
		
		_nporce := (_asubs[len(_asubs)] /_ntotger) * 100
		
	Else
		
		_nporce := 0
		
	Endif

	IF _cdesc == "CUSTO FILIAIS" .AND. (_lGera4Pla .OR. _lGera2Pla)// .OR. _lGera1Pla)
		_aCusto04[2,2]:=_ntotlei
		_aCusto04[2,3]:=_nvtot
		_aCusto04[2,4]:=_nvtot / _ntotlei
	ENDIF

	
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s153"><Data ss:Type="String">' + _aze0[_ni][09] + ' - ' + transform( _nporce, "@E 999.99%")   +  '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s156"><Data ss:Type="String">' + _ccod   + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s157"><Data ss:Type="String">' + _cdesc + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">' + alltrim(str(_nqtot)) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s159"><Data ss:Type="Number">' + alltrim(str((_nvtot/_nqtot))) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s160"><Data ss:Type="Number">' + alltrim(str(_nvtot)) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s161"><Data ss:Type="Number">' + alltrim(str(_nvtot / _ntotlei )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s162"><Data ss:Type="Number">' + alltrim(str(_nvtot / ( _ntotlei * _nTotdol ))) + '</Data></Cell>')
	aadd( _axml, '   </Row>')
	
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s116"/>')
	aadd( _axml, '    <Cell ss:StyleID="s71"/>')
	aadd( _axml, '    <Cell ss:StyleID="s64"/>')
	aadd( _axml, '    <Cell ss:StyleID="s140"><Data ss:Type="String">Sub-Total.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s141"/>')
	aadd( _axml, '    <Cell ss:StyleID="s142"><Data ss:Type="Number">' + alltrim(str(_nsubtot)) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s143"><Data ss:Type="Number">' + alltrim(str(_nsubtot / _ntotlei)) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s144"><Data ss:Type="Number">' + alltrim(str(_nsubtot / ( _ntotlei * _nTotdol ))) + '</Data></Cell>')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s145"/>')
	aadd( _axml, '    <Cell ss:StyleID="s146"/>')
	aadd( _axml, '    <Cell ss:StyleID="s145"/>')
	aadd( _axml, '    <Cell ss:StyleID="s145"/>')
	aadd( _axml, '    <Cell ss:StyleID="s147"/>')
	aadd( _axml, '    <Cell ss:StyleID="s148"/>')
	aadd( _axml, '    <Cell ss:StyleID="s148"/>')
	aadd( _axml, '    <Cell ss:StyleID="s148"/>')
	aadd( _axml, '   </Row>')
	
Endif





//=========================================================================
//Ultimo subtotal antes dos totais gerais
//=========================================================================

if !(_lsub) 

	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s116"/>')
	aadd( _axml, '    <Cell ss:StyleID="s71"/>')
	aadd( _axml, '    <Cell ss:StyleID="s64"/>')
	aadd( _axml, '    <Cell ss:StyleID="s140"><Data ss:Type="String">Sub-Total.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s141"/>')
	aadd( _axml, '    <Cell ss:StyleID="s142"><Data ss:Type="Number">' + alltrim(str(_nsubtot)) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s143"><Data ss:Type="Number">' + alltrim(str(_nsubtot / _ntotlei)) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s144"><Data ss:Type="Number">' + alltrim(str(_nsubtot / ( _ntotlei * _nTotdol ))) + '</Data></Cell>')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s145"/>')
	aadd( _axml, '    <Cell ss:StyleID="s146"/>')
	aadd( _axml, '    <Cell ss:StyleID="s145"/>')
	aadd( _axml, '    <Cell ss:StyleID="s145"/>')
	aadd( _axml, '    <Cell ss:StyleID="s147"/>')
	aadd( _axml, '    <Cell ss:StyleID="s148"/>')
	aadd( _axml, '    <Cell ss:StyleID="s148"/>')
	aadd( _axml, '    <Cell ss:StyleID="s148"/>')
	aadd( _axml, '   </Row>')
	
Endif


//==================================================================================================
//Total acumulado
//==================================================================================================

aadd( _axml, '   <Row ss:AutoFitHeight="0">')
aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">TOTAL ACUMULADO.:</Data></Cell>')
aadd( _axml, '    <Cell ss:StyleID="s252"/>')
aadd( _axml, '    <Cell ss:StyleID="s253"/>')

IF _cTitulo = "CUSTO OPERACIONAL" .AND. xFilial("ZL6") = "10"
   aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">' + alltrim(str(_ntotlei+_nTotSoro)) + '</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s255"/>')
   aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">' + alltrim(str( _ntotger )) + '</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">' + alltrim(str( _ntotger /   (_ntotlei+_nTotSoro) )) + '</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">' + alltrim(str( _ntotger / ( (_ntotlei+_nTotSoro) * _nTotdol ) )) + '</Data></Cell>')
ELSE
   aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">' + alltrim(str(_ntotlei)) + '</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s255"/>')
   aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">' + alltrim(str( _nsubtot2 )) + '</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">' + alltrim(str( _nsubtot2 / _ntotlei )) + '</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">' + alltrim(str( _nsubtot2 / ( _ntotlei * _nTotdol ) )) + '</Data></Cell>')
ENDIF

aadd( _axml, '   </Row>')
aadd( _axml, '   <Row ss:AutoFitHeight="0">')
aadd( _axml, '    <Cell ss:StyleID="s163"/>')
aadd( _axml, '    <Cell ss:StyleID="s71"/>')
aadd( _axml, '    <Cell ss:StyleID="s84"/>')
aadd( _axml, '    <Cell ss:StyleID="s164"/>')
aadd( _axml, '    <Cell ss:StyleID="s165"/>')
aadd( _axml, '    <Cell ss:StyleID="s166"/>')
aadd( _axml, '    <Cell ss:StyleID="s167"/>')
aadd( _axml, '    <Cell ss:StyleID="s167"/>')
aadd( _axml, '   </Row>')


//==================================================================================================
//Custos totalizadores
//==================================================================================================

For _ni := 1 to len(_aze0)

	if alltrim(_aze0[_ni][13]) == "3"
	
		aadd( _axml, '   <Row ss:AutoFitHeight="0">')
		aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">' + _aze0[_ni][07]   + '</Data></Cell>')//TOTAL  CUSTO OPERACIONAL
		aadd( _axml, '    <Cell ss:StyleID="s252"/>')
		aadd( _axml, '    <Cell ss:StyleID="s253"/>')
		aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">' + alltrim(str( _aze0[_ni][11] / _ntotger ))   + '</Data></Cell>')
		aadd( _axml, '    <Cell ss:StyleID="s255"/>')
		aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">' + alltrim(str( _aze0[_ni][11] ))   + '</Data></Cell>')
		aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">' + alltrim(str( _aze0[_ni][11] / _ntotlei ))   + '</Data></Cell>')
		aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">' + alltrim(str( _aze0[_ni][11] / ( _ntotlei * _nTotdol )  ))   + '</Data></Cell>')
		aadd( _axml, '   </Row>')


		aadd( _axml, '   <Row ss:AutoFitHeight="0">')
		aadd( _axml, '    <Cell ss:StyleID="s163"/>')
		aadd( _axml, '    <Cell ss:StyleID="s71"/>')
		aadd( _axml, '    <Cell ss:StyleID="s84"/>')
		aadd( _axml, '    <Cell ss:StyleID="s164"/>')
		aadd( _axml, '    <Cell ss:StyleID="s165"/>')
		aadd( _axml, '    <Cell ss:StyleID="s166"/>')
		aadd( _axml, '    <Cell ss:StyleID="s167"/>')
		aadd( _axml, '    <Cell ss:StyleID="s167"/>')
		aadd( _axml, '   </Row>')

	Endif
	
Next

//===================================================================================
// Faz linhas de estoque anterior, entradas por transferencia, entradas por devolucao
//===================================================================================
_cSegUni:="N"
_cEstAnt:="1"
_cGrpCus:=""
_cLocais:=""
_cCUF2UM:="N"
_cFilis  :=""
_cProduto:=""
_cCliente:=""
If substr(_ctitulo,1,17) == "PRODUTOS ACABADOS"

	_nVlrIcm :=_nVIcmEst:=_nVIcmInt:=_nVIcmTrs:=_nDifAlq:=0//Variaveis antigas
    _nICMSEst :=_nICMSInt:=_nICMSTrs:=0//Variaveis novas valores medio
    nDespEst := nOprsEst:=0//Variaveis novas percentual
    nDespInt := nOprsInt:=0//Variaveis novas percentual
    nDespTrs := nOprsTrs:=0//Variaveis novas percentual
    _cChave  := xFilial("ZL6")+_aze2[1][17]+PADR(_aze2[1][3],60)+PADR(_aze2[1][16],40)+"PRODUTOS ACABADOS PRODUZIDOS            "

    MEST9ICMS("CARGA_VARIAVEIS_ICMS",_cChave)

    _cProduto:= Posicione("ZL6",8,xFilial("ZL6")+_aze2[1][17]+PADR(_aze2[1][3],60)+PADR(_aze2[1][16],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_CODPRO")
    _cGrpCus := Posicione("ZL6",8,xFilial("ZL6")+_aze2[1][17]+PADR(_aze2[1][3],60)+PADR(_aze2[1][16],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_GRPCUS")
	_cFilis  := Posicione("ZL6",8,xFilial("ZL6")+_aze2[1][17]+PADR(_aze2[1][3],60)+PADR(_aze2[1][16],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_FILIS")
	_cCliente:= Posicione("ZL6",8,xFilial("ZL6")+_aze2[1][17]+PADR(_aze2[1][3],60)+PADR(_aze2[1][16],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_CLIENTE")
    _cSegUni := Posicione("ZL6",8,xFilial("ZL6")+_aze2[1][17]+PADR(_aze2[1][3],60)+PADR(_aze2[1][16],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_TUNID")
    _cEstAnt := Posicione("ZL6",8,xFilial("ZL6")+_aze2[1][17]+PADR(_aze2[1][3],60)+PADR(_aze2[1][16],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_ESTANT")
//  _nDifAlq := Posicione("ZL6",8,xFilial("ZL6")+_aze2[1][17]+PADR(_aze2[1][3],60)+PADR(_aze2[1][16],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_DIFALQ")//NÃO USA MAIS ESSE CAMPO
    _cLocais := Posicione("ZL6",8,xFilial("ZL6")+_aze2[1][17]+PADR(_aze2[1][3],60)+PADR(_aze2[1][16],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_LOCAL")
    _cCUF2UM := Posicione("ZL6",8,xFilial("ZL6")+_aze2[1][17]+PADR(_aze2[1][3],60)+PADR(_aze2[1][16],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_CUF2UM")
    //ZL6_FILIAL+ZL6_GRPCUS+ZL6_DTPCUS+ZL6_DGRCUS+ZL6_DESEVE                                                                                                          
	//ZE0_FILIAL+ZE0_DATARQ + 01 042019 000010 000002 999992 9991  
	          //ZE0_GRPCT+ZE0_TPCUS+ZE0_EVCUS+ZE0_SEVCT
	_cZE0Chave:=_cGrpCus+_aze2[1][2]+"999992"+"9991  "
                      //_cproduto           ,_cSegUni,_cEstAnt,_cGrpCus,_lPorItem,_cLocal,_cChave	
	_aval := MEST009SB9(alltrim(_cproduto)  ,_cSegUni,_cEstAnt,_cGrpCus,         ,       ,_cZE0Chave)//valores de estoque anterior
	_aven := MEST009SD1(alltrim(_cproduto),2,_cSegUni)           //valores de entradas em transferência
    _aven[1][1]+=_aSomaEntTrans[1]	//COMPRAS DE TERCEIROS
    _aven[1][2]+=_aSomaEntTrans[2]	//COMPRAS DE TERCEIROS
	_avdv := MEST009SD1(alltrim(_cproduto),1,_cSegUni)           //valores de entradas em devolução
	_nDev := (_nsubtot2 + _aval[1][2])/(_aval[1][1] + _ntotlei)
	_nSldAtu := MEST9BscSB2(alltrim(_cproduto))        //Quantidade atual em estoque

	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s163"/>')
	aadd( _axml, '    <Cell ss:StyleID="s71"/>')
	aadd( _axml, '    <Cell ss:StyleID="s84"/>')
	aadd( _axml, '    <Cell ss:StyleID="s164"/>')
	aadd( _axml, '    <Cell ss:StyleID="s165"/>')
	aadd( _axml, '    <Cell ss:StyleID="s166"/>')
	aadd( _axml, '    <Cell ss:StyleID="s167"/>')
	aadd( _axml, '    <Cell ss:StyleID="s167"/>')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">ESTOQUE ANTERIOR.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s252"/>')
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">' + alltrim(str( _aval[1][1] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s255"/>')
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">' + alltrim(str( _aval[1][2] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">' + alltrim(str( _aval[1][2] / _aval[1][1] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">' + alltrim(str( _aval[1][2] / _aval[1][1] / _nTotdol )) + '</Data></Cell>')
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')///////////////////////////////  COMEÇAR A COLOCAR A TAXA DO DOLAR DAQUI
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">ENTRADAS DEVOLUCAO.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s252"/>')
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">' + alltrim(str( _avdv[1][1] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s255"/>')
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">' + alltrim(str( _avdv[1][1] * _nDev )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">' + alltrim(str( _avdv[1][1] * _nDev / _avdv[1][1] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">' + alltrim(str( _avdv[1][1] * _nDev / _avdv[1][1] / _nTotdol )) + '</Data></Cell>')
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">ENTRADAS TRANSFERENCIA / COMPRAS TERC:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s252"/>')
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">' + alltrim(str( _aven[1][1] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s255"/>')
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">' + alltrim(str( _aven[1][1] * _nDev )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">' + alltrim(str( _aven[1][1] * _nDev / _aven[1][1]  )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">' + alltrim(str( _aven[1][1] * _nDev / _aven[1][1] / _nTotdol )) + '</Data></Cell>')
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s163"/>')
	aadd( _axml, '    <Cell ss:StyleID="s71"/>')
	aadd( _axml, '    <Cell ss:StyleID="s84"/>')
	aadd( _axml, '    <Cell ss:StyleID="s164"/>')
	aadd( _axml, '    <Cell ss:StyleID="s165"/>')
	aadd( _axml, '    <Cell ss:StyleID="s166"/>')
	aadd( _axml, '    <Cell ss:StyleID="s167"/>')
	aadd( _axml, '    <Cell ss:StyleID="s167"/>')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">ESTOQUE ATUAL.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s252"/>')
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">'+ alltrim(str( _nSldAtu )) +'</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s255"/>')
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">'+ alltrim(str( _nSldAtu *_nDev)) +'</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">'+ alltrim(str( _nSldAtu * _nDev / _nSldAtu )) +'</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">'+ alltrim(str( _nSldAtu * _nDev / _nSldAtu / _nTotdol )) +'</Data></Cell>')
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s163"/>')
	aadd( _axml, '    <Cell ss:StyleID="s71"/>')
	aadd( _axml, '    <Cell ss:StyleID="s84"/>')
	aadd( _axml, '    <Cell ss:StyleID="s164"/>')
	aadd( _axml, '    <Cell ss:StyleID="s165"/>')
	aadd( _axml, '    <Cell ss:StyleID="s166"/>')
	aadd( _axml, '    <Cell ss:StyleID="s167"/>')
	aadd( _axml, '    <Cell ss:StyleID="s167"/>')
	aadd( _axml, '   </Row>')

//===================================================================================
// Faz linhas dos custos de expedição
//===================================================================================							
    _aExp := MEST009EXP(alltrim(_cproduto),_cSegUni,_cLocais)  //Quantidade expedida
    _aFret:= MEST009FRT(alltrim(_cproduto),_aExp[1][1])           //Valor Frete
    _nExp := ((_aExp[1][1] ) * ( _nDev ))
    _nExpD := ((_aExp[1][2] ) * ( _nDev ))
    _nExpF := ((_aExp[1][3] ) * ( _nDev ))
    _nExpT := ((_aExp[1][4] ) * ( _nDev ))

	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s163"/>')
	aadd( _axml, '    <Cell ss:StyleID="s71"/>')
	aadd( _axml, '    <Cell ss:StyleID="s84"/>')
	aadd( _axml, '    <Cell ss:StyleID="s164"/>')
	aadd( _axml, '    <Cell ss:StyleID="s165"/>')
	aadd( _axml, '    <Cell ss:StyleID="s166"/>')
	aadd( _axml, '    <Cell ss:StyleID="s167"/>')
	aadd( _axml, '    <Cell ss:StyleID="s167"/>')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">EXPEDIDO ESTADUAL.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s252"/>')
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">'+ alltrim(str( _aExp[1][2] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s255"/>')
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">' +alltrim(str (_nExpD)) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">' + alltrim(str( _nExpD / _aExp[1][2] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">' + alltrim(str( _nExpD / _aExp[1][2] / _nTotdol )) + '</Data></Cell>')
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">EXPEDIDO INTERESTADUAL.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s252"/>')
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">'+ alltrim(str( _aExp[1][3] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s255"/>')
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">' +alltrim(str (_nExpF)) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">' + alltrim(str( _nExpF / _aExp[1][3] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">' + alltrim(str( _nExpF / _aExp[1][3] / _nTotdol )) + '</Data></Cell>')
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">TRANSFERENCIA.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s252"/>')
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">'+ alltrim(str( _aExp[1][4] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s255"/>')
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">' +alltrim(str (_nExpT)) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">' + alltrim(str( _nExpT / _aExp[1][4] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">' + alltrim(str( _nExpT / _aExp[1][4] / _nTotdol )) + '</Data></Cell>')
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')

	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">FRETE.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s252"/>')
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">'+ alltrim(str( _aExp[1][1] )) +'</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s255"/>')
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">' + alltrim(str( _aFret[1][2] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">' + alltrim(str( _aFret[1][2] / _aExp[1][1] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">' + alltrim(str( _aFret[1][2] / _aExp[1][1] / _nTotdol )) + '</Data></Cell>')
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')
////1-FRETE SOMADO       ,2-FRETE PURO ,3-SEGURO               ,4-CHEP
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">SEGURO.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s252"/>')
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">'+ alltrim(str( _aExp[1][1] )) +'</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s255"/>')
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">' + alltrim(str( _aFret[1][3] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">' + alltrim(str( _aFret[1][3] / _aExp[1][1] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">' + alltrim(str( _aFret[1][3] / _aExp[1][1] / _nTotdol )) + '</Data></Cell>')
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')

	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">CHEP.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s252"/>')
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">'+ alltrim(str( _aExp[1][1] )) +'</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s255"/>')
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">' + alltrim(str( _aFret[1][4] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">' + alltrim(str( _aFret[1][4] / _aExp[1][1] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">' + alltrim(str( _aFret[1][4] / _aExp[1][1] / _nTotdol )) + '</Data></Cell>')
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')

	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">OCORRENCIAS.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s252"/>')
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">'+ alltrim(str( _aExp[1][1] )) +'</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s255"/>')
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">' + alltrim(str( _aFret[1][5] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">' + alltrim(str( _aFret[1][5] / _aExp[1][1] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">' + alltrim(str( _aFret[1][5] / _aExp[1][1] / _nTotdol )) + '</Data></Cell>')
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')

	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s163"/>')
	aadd( _axml, '    <Cell ss:StyleID="s71"/>')
	aadd( _axml, '    <Cell ss:StyleID="s84"/>')
	aadd( _axml, '    <Cell ss:StyleID="s164"/>')
	aadd( _axml, '    <Cell ss:StyleID="s165"/>')
	aadd( _axml, '    <Cell ss:StyleID="s166"/>')
	aadd( _axml, '    <Cell ss:StyleID="s167"/>')
	aadd( _axml, '    <Cell ss:StyleID="s167"/>')
	aadd( _axml, '   </Row>')

//===================================================================================
// Faz linhas dos  Impostos (ICMS, ICMS ST, PIS/COFINS, IRPJ/CSSL/Parc. IPI)
//===================================================================================							
	_aicst 	:= MEST009IST(alltrim(_cproduto))  //valores icms st
//	_aicms	:= MEST009ICM(alltrim(_cproduto))  //Media da % do icms nas vendas/transferencias 

    IF _nICMSEst > 0 .AND. nDespEst > 0
       _nVIcmEst:=(_nVIcmEst*_aExp[1][2])
    ENDIF
    IF _nICMSInt > 0 .AND. nDespInt > 0
       _nVIcmInt:=(_nVIcmInt*_aExp[1][3])
    ENDIF
    IF _nICMSTrs > 0 .AND. nDespTrs > 0
       _nVIcmTrs:=(_nVIcmTrs*_aExp[1][4])
    ENDIF
	_nVlrIcm:= _nVIcmEst + _nVIcmInt + _nVIcmTrs
	
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">ICMS Normal - ESTADUAL.:</Data></Cell>') // A
	aadd( _axml, '    <Cell ss:StyleID="s252"><Data ss:Type="String">'+TRANSFORM( ROUND(nDespEst/nOprsEst*100,2), "@E 999.99%")+' </Data></Cell>')//B
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')//C
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">'+ alltrim(str( _aExp[1][2]) ) + '</Data></Cell>')//D
	aadd( _axml, '    <Cell ss:StyleID="s255"><Data ss:Type="Number">'+ alltrim(str( _nICMSEst ) ) + '</Data></Cell>')//E  
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">'+ alltrim(str( _nVIcmEst))+'</Data></Cell>')//F
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">'+ alltrim(str( _nVIcmEst /_aExp[1][2]))+'</Data></Cell>') //G
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">'+ alltrim(str( _nVIcmEst /_aExp[1][2] / _nTotdol))+'</Data></Cell>') //H
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">ICMS Normal - INTERESTADUAL.:</Data></Cell>')//A
	aadd( _axml, '    <Cell ss:StyleID="s252"><Data ss:Type="String">'+TRANSFORM( ROUND(nDespInt/nOprsInt*100,2), "@E 999.99%")+' </Data></Cell>')//B
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')//D
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">'+ alltrim(str( _aExp[1][3]) ) + '</Data></Cell>')//D
	aadd( _axml, '    <Cell ss:StyleID="s255"><Data ss:Type="Number">'+ alltrim(str( _nICMSInt ) ) + '</Data></Cell>')//E
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">'+ alltrim(str( _nVIcmInt))+'</Data></Cell>')//F
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">'+ alltrim(str( _nVIcmInt /_aExp[1][3]))+'</Data></Cell>') //G
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">'+ alltrim(str( _nVIcmInt /_aExp[1][3] / _nTotdol))+'</Data></Cell>') //H
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">ICMS Normal - TRANSFERENCIA.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s252"><Data ss:Type="String">'+TRANSFORM( ROUND(nDespTrs/nOprsTrs*100,2), "@E 999.99%")+' </Data></Cell>')//B
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')//C
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">'+ alltrim(str( _aExp[1][4]) ) + '</Data></Cell>')//D
	aadd( _axml, '    <Cell ss:StyleID="s255"><Data ss:Type="Number">'+ alltrim(str( _nICMSTrs ) ) + '</Data></Cell>')//E
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">'+ alltrim(str( _nVIcmTrs))+'</Data></Cell>')//F
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">'+ alltrim(str( _nVIcmTrs /_aExp[1][4]))+'</Data></Cell>') //G
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">'+ alltrim(str( _nVIcmTrs /_aExp[1][4] / _nTotdol))+'</Data></Cell>') //H
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">ICMS Dif. de Aliquotas.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s252"/>')
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')
	aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">'+ alltrim(str( _aExp[1][1]) )+'</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s255"/>')
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">'+ alltrim(str( _nDifAlq))+'</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">'+ alltrim(str( _nDifAlq /_aExp[1][1]))+'</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">'+ alltrim(str( _nDifAlq /_aExp[1][1] / _nTotdol))+'</Data></Cell>')
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')
	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">ICMS Substituicao Tributaria.:</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s252"/>')
	aadd( _axml, '    <Cell ss:StyleID="s253"/>')
	If _aicst[1][1] > 0
		aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">' + alltrim(str( _aExp[1][1] )) + '</Data></Cell>')
	Else
		aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number"></Data></Cell>')
	Endif		
	aadd( _axml, '    <Cell ss:StyleID="s255"/>')
	aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">' + alltrim(str( _aicst[1][1] )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">' + alltrim(str( _aicst[1][1] /  _aExp[1][1]  )) + '</Data></Cell>')
	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">' + alltrim(str( _aicst[1][1] /  _aExp[1][1] / _nTotdol  )) + '</Data></Cell>')
//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>')
	aadd( _axml, '   </Row>')
/*
	_cFilsFUNDOPEM:=U_ITGETMV( "IT_FILFUNOP","20")
	IF cFilAnt $ _cFilsFUNDOPEM//FUNDOPEM Pagar
		_nVlrFUNDOPEM:=Posicione("ZL6",8,xFilial("ZL6")+_aze2[1][17]+PADR(_aze2[1][3],60)+PADR(_aze2[1][16],40)+"PRODUTOS ACABADOS PRODUZIDOS            ","ZL6_VLFUOP")
		aadd( _axml, '   <Row ss:AutoFitHeight="0">')
		aadd( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">FUNDOPEM Pagar.:</Data></Cell>')
		aadd( _axml, '    <Cell ss:StyleID="s252"/>')
		aadd( _axml, '    <Cell ss:StyleID="s253"/>')
		aadd( _axml, '    <Cell ss:StyleID="s158"><Data ss:Type="Number">'+ alltrim(str( _aExp[1][1]) ) + '</Data></Cell>')
		aadd( _axml, '    <Cell ss:StyleID="s255"/>')
		aadd( _axml, '    <Cell ss:StyleID="s256"><Data ss:Type="Number">'+alltrim(str(_nVlrFUNDOPEM))+'</Data></Cell>')
		aadd( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">'+ alltrim(str( _nVlrFUNDOPEM/_aExp[1][1]))+'</Data></Cell>') //
		aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number">'+ alltrim(str( _nVlrFUNDOPEM/_aExp[1][1] / _nTotdol))+'</Data></Cell>') //
		//	aadd( _axml, '    <Cell ss:StyleID="s258"><Data ss:Type="Number"></Data></Cell>') ///////////////////////////////  COLOCA A TAXA DO DOLAR ATE AQUI
		aadd( _axml, '   </Row>')
	ENDIF*/

	aadd( _axml, '   <Row ss:AutoFitHeight="0">')
	aadd( _axml, '    <Cell ss:StyleID="s163"/>')
	aadd( _axml, '    <Cell ss:StyleID="s71"/>')
	aadd( _axml, '    <Cell ss:StyleID="s84"/>')
	aadd( _axml, '    <Cell ss:StyleID="s164"/>')
	aadd( _axml, '    <Cell ss:StyleID="s165"/>')
	aadd( _axml, '    <Cell ss:StyleID="s166"/>')
	aadd( _axml, '    <Cell ss:StyleID="s167"/>')
	aadd( _axml, '    <Cell ss:StyleID="s167"/>')
	aadd( _axml, '   </Row>')

Endif	

//==================================================================================================
//Total Geral
//==================================================================================================
//Ajusta total de acordo com quadro de entradas e estoque anterior
//==================================================================================================
_aval := MEST009SB9(alltrim(_cproduto),_cSegUni,_cEstAnt,_cGrpCus)//valores de estoque anterior
_aven := MEST009SD1(alltrim(_cproduto),2,_cSegUni)         	//valores de entradas em transferência
_avdv := MEST009SD1(alltrim(_cproduto),1,_cSegUni)         	//valores de entradas em devolução
_aicst:= MEST009IST(alltrim(_cproduto))             		//valores icms st
_aExp := MEST009EXP(alltrim(_cproduto),_cSegUni,_cLocais)  	//Quantidade expedida
_aFret:= MEST009FRT(alltrim(_cproduto),_aExp[1][1])         //Valor Frete

_nDev := (_nsubtot2 + _aval[1][2])/(_aval[1][1] + _ntotlei)
_nExp := ((_aExp[1][1] ) * ( _nDev ))

_cUnidadeinvertida:=""
If substr(_ctitulo,1,17) == "PRODUTOS ACABADOS"
	_ntotlei := _aExp[1][1]
	_ntotger := _nExp + _aFret[1][1] + _aicst[1][1] + _nVlrIcm

    MEST9Calc2UN("S",_nTotlei,_cProduto)//Posiciona no SB1 por isso executa sempre
	IF _cSegUni = "S"
       _cUnidadeinvertida:=" ("+SB1->B1_SEGUM+")"
	ELSE   
	   _cUnidadeinvertida:=" ("+SB1->B1_UM+")"
	ENDIF

Endif	

IF  _cTitulo = "CUSTO OPERACIONAL" .AND. xFilial("ZL6") = "10"

   aadd( _axml, '   <Row ss:AutoFitHeight="0">')
   aadd( _axml, '    <Cell ss:StyleID="s264"><Data ss:Type="String">TOTAL  '+ _ctitulo + '</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s265"/>')
   aadd( _axml, '    <Cell ss:StyleID="s266"/>')
   aadd( _axml, '    <Cell ss:StyleID="s267"><Data ss:Type="Number">' + alltrim(str(_ntotlei+_nTotSoro))    +'</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s268"/>')
   aadd( _axml, '    <Cell ss:StyleID="s269"><Data ss:Type="Number">' + alltrim(str(_ntotger))   + '</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s270"><Data ss:Type="Number">' + alltrim(str(_ntotger /   (_ntotlei+_nTotSoro) ))    + '</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s271"><Data ss:Type="Number">' + alltrim(str(_ntotger / ( (_ntotlei+_nTotSoro) * _nTotdol ) ))  + '</Data></Cell>')
   aadd( _axml, '   </Row>')

   IF _lMostraSoro 
      aadd( _axml, '   <Row ss:AutoFitHeight="0">')
      aadd( _axml, '    <Cell ss:StyleID="s264"><Data ss:Type="String">TOTAL CUSTO OPERACIONAL LEITE/QUEIJO/LEITE EM PO/MANTEIGA</Data></Cell>')
      aadd( _axml, '    <Cell ss:StyleID="s265"/>')
      aadd( _axml, '    <Cell ss:StyleID="s266"/>')
      aadd( _axml, '    <Cell ss:StyleID="s267"><Data ss:Type="Number">' + alltrim(str(_ntotlei))    +'</Data></Cell>')
      aadd( _axml, '    <Cell ss:StyleID="s268"/>')
      aadd( _axml, '    <Cell ss:StyleID="s269"><Data ss:Type="Number">' + alltrim(str( _ntotger-(_ntotger/4)))   + '</Data></Cell>')
      aadd( _axml, '    <Cell ss:StyleID="s270"><Data ss:Type="Number">' + alltrim(str((_ntotger-(_ntotger/4)) / (_ntotlei) ))    + '</Data></Cell>')
      aadd( _axml, '    <Cell ss:StyleID="s271"><Data ss:Type="Number">' + alltrim(str((_ntotger-(_ntotger/4)) / ( (_ntotlei) * _nTotdol ) ))  + '</Data></Cell>')
      aadd( _axml, '   </Row>')
   
      aadd( _axml, '   <Row ss:AutoFitHeight="0">')
      aadd( _axml, '    <Cell ss:StyleID="s264"><Data ss:Type="String">TOTAL CUSTO OPERACIONAL SORO EM PO</Data></Cell>')
      aadd( _axml, '    <Cell ss:StyleID="s265"/>')
      aadd( _axml, '    <Cell ss:StyleID="s266"/>')
      aadd( _axml, '    <Cell ss:StyleID="s267"><Data ss:Type="Number">' + alltrim(str(_nTotSoro))    +'</Data></Cell>')
      aadd( _axml, '    <Cell ss:StyleID="s268"/>')
      aadd( _axml, '    <Cell ss:StyleID="s269"><Data ss:Type="Number">' + alltrim(str(_ntotger/4))   + '</Data></Cell>')
      aadd( _axml, '    <Cell ss:StyleID="s270"><Data ss:Type="Number">' + alltrim(str((_ntotger/4) / _nTotSoro ))    + '</Data></Cell>')
      aadd( _axml, '    <Cell ss:StyleID="s271"><Data ss:Type="Number">' + alltrim(str((_ntotger/4) / ( _nTotSoro * _nTotdol ) ))  + '</Data></Cell>')
      aadd( _axml, '   </Row>')
   ENDIF
ELSE


   aadd( _axml, '   <Row ss:AutoFitHeight="0">')
   aadd( _axml, '    <Cell ss:StyleID="s264"><Data ss:Type="String">TOTAL  '+ _ctitulo +_cUnidadeinvertida+ '</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s265"/>')
   aadd( _axml, '    <Cell ss:StyleID="s266"/>')
   aadd( _axml, '    <Cell ss:StyleID="s267"><Data ss:Type="Number">' + alltrim(str(_ntotlei))    +'</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s268"/>')
   aadd( _axml, '    <Cell ss:StyleID="s269"><Data ss:Type="Number">' + alltrim(str(_ntotger))   + '</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s270"><Data ss:Type="Number">' + alltrim(str(_ntotger / _ntotlei ))    + '</Data></Cell>')
   aadd( _axml, '    <Cell ss:StyleID="s271"><Data ss:Type="Number">' + alltrim(str(_ntotger / ( _ntotlei * _nTotdol ) ))  + '</Data></Cell>')
   aadd( _axml, '   </Row>')

   FOR nPos := 1 TO LEN(_aRecalVlrs)
	   IF _aRecalVlrs[nPos,1] $ ALLTRIM(_ctitulo2)
          _aRecalVlrs[nPos,3] := (_ntotger / _ntotlei)//P. R$(P/LT )
	   ENDIF
   NEXT
	
	IF _cCUF2UM = "1"
		
	    _nTotleInv:=MEST9Calc2UN("S",_nTotlei,_cProduto)//Posiciona no SB1 por isso executa sempre
	    _cUnidadeinvertida:=" ("+SB1->B1_SEGUM+")"
		IF _cSegUni = "S"//Se o de cima foi segunda pega a primeira unidade para segunda linha
		   _nTotleInv:=_aExp[1][5]
		   _cUnidadeinvertida:=" ("+SB1->B1_UM+")"
		ENDIF
	    //PULA LINHA
		aadd( _axml, '   <Row ss:AutoFitHeight="0">')
		aadd( _axml, '    <Cell ss:StyleID="s163"/>')
		aadd( _axml, '    <Cell ss:StyleID="s71"/>')
		aadd( _axml, '    <Cell ss:StyleID="s84"/>')
		aadd( _axml, '    <Cell ss:StyleID="s164"/>')
		aadd( _axml, '    <Cell ss:StyleID="s165"/>')
		aadd( _axml, '    <Cell ss:StyleID="s166"/>')
		aadd( _axml, '    <Cell ss:StyleID="s167"/>')
		aadd( _axml, '    <Cell ss:StyleID="s167"/>')
		aadd( _axml, '   </Row>')
	    //PULA LINHA
		aadd( _axml, '   <Row ss:AutoFitHeight="0">')
		aadd( _axml, '    <Cell ss:StyleID="s264"><Data ss:Type="String">TOTAL '+ _ctitulo+_cUnidadeinvertida + '</Data></Cell>')
		aadd( _axml, '    <Cell ss:StyleID="s265"/>')
		aadd( _axml, '    <Cell ss:StyleID="s266"/>')
		aadd( _axml, '    <Cell ss:StyleID="s267"><Data ss:Type="Number">' + alltrim(str(_nTotleInv))    +'</Data></Cell>')
		aadd( _axml, '    <Cell ss:StyleID="s268"/>')
		aadd( _axml, '    <Cell ss:StyleID="s269"><Data ss:Type="Number">' + alltrim(str(_ntotger))   + '</Data></Cell>')
		aadd( _axml, '    <Cell ss:StyleID="s270"><Data ss:Type="Number">' + alltrim(str(_ntotger / _nTotleInv ))    + '</Data></Cell>')
		aadd( _axml, '    <Cell ss:StyleID="s271"><Data ss:Type="Number">' + alltrim(str(_ntotger / ( _nTotleInv * _nTotdol ) ))  + '</Data></Cell>')
		aadd( _axml, '   </Row>')

    ENDIF

    IF _cTitulo <> "CUSTO OPERACIONAL" 

	    //PULA LINHA
		aadd( _axml, '   <Row ss:AutoFitHeight="0">')
		aadd( _axml, '    <Cell ss:StyleID="s163"/>')
		aadd( _axml, '    <Cell ss:StyleID="s71"/>')
		aadd( _axml, '    <Cell ss:StyleID="s84"/>')
		aadd( _axml, '    <Cell ss:StyleID="s164"/>')
		aadd( _axml, '    <Cell ss:StyleID="s165"/>')
		aadd( _axml, '    <Cell ss:StyleID="s166"/>')
		aadd( _axml, '    <Cell ss:StyleID="s167"/>')
		aadd( _axml, '    <Cell ss:StyleID="s167"/>')
		aadd( _axml, '   </Row>')
        
		_nPrecoMedio:=MEST9PMedio(_cFilis,_cProduto,_cCliente)
	    
		AADD( _axml, '   <Row ss:AutoFitHeight="0">')
	    AADD( _axml, '    <Cell ss:StyleID="s251"><Data ss:Type="String">PRECO MEDIO DE VENDA</Data></Cell>')
	    AADD( _axml, '    <Cell ss:StyleID="s252"/>')
	    AADD( _axml, '    <Cell ss:StyleID="s253"/>')
	    AADD( _axml, '    <Cell ss:StyleID="s253"/>')
	    AADD( _axml, '    <Cell ss:StyleID="s255"/>')
	    AADD( _axml, '    <Cell ss:StyleID="s253"/>')
	    AADD( _axml, '    <Cell ss:StyleID="s257"><Data ss:Type="Number">'+ ALLTRIM(STR( _nPrecoMedio ))+'</Data></Cell>')
  	    AADD( _axml, '    <Cell ss:StyleID="s258"/>')
	    AADD( _axml, '   </Row>')

	ENDIF

ENDIF

IF _lGera4Pla .OR. _lGera2Pla //.OR. _lGera1Pla
	IF _ctitulo = "CUSTO OPERACIONAL"
		_aCusto04[1,2]:=_ntotlei
		_aCusto04[1,3]:=_ntotger
		_aCusto04[1,4]:=_ntotger / _ntotlei
	ELSE
		AADD(_aCusto04,{SUBSTR(_ctitulo,21),_ntotlei,_ntotger, (_ntotger / _ntotlei) })
	ENDIF
ENDIF

_cTesteA:=STRTRAN(_cTesteA,".",",")
_cFileNome:=_cdir+"MEST009_REDIMENTO_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".CSV"
MemoWrite(_cFileNome,_cTesteA)

Return _axml

/*
===============================================================================================================================
Programa----------: MEST009E3
Autor-------------: Josue Danich Prestes
Data da Criacao---: 23/11/2015
Descricao---------: Fecha arquivo Excel
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
static function MEST009E3()

Local _axml := {}

aadd( _axml, '  </Table>')
aadd( _axml, '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">')
aadd( _axml, '   <PageSetup>')
aadd( _axml, '    <Header x:Margin="0.31496062000000002"/>')
aadd( _axml, '    <Footer x:Margin="0.31496062000000002"/>')
aadd( _axml, '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"')
aadd( _axml, '     x:Right="0.511811024" x:Top="0.78740157499999996"/>')
aadd( _axml, '   </PageSetup>')
aadd( _axml, '   <Unsynced/>')
aadd( _axml, '   <Zoom>85</Zoom>')
aadd( _axml, '   <Selected/>')
aadd( _axml, '   <Panes>')
aadd( _axml, '    <Pane>')
aadd( _axml, '     <Number>3</Number>')
aadd( _axml, '     <ActiveRow>4</ActiveRow>')
aadd( _axml, '     <ActiveCol>8</ActiveCol>')
aadd( _axml, '    </Pane>')
aadd( _axml, '   </Panes>')
aadd( _axml, '   <ProtectObjects>False</ProtectObjects>')
aadd( _axml, '   <ProtectScenarios>False</ProtectScenarios>')
aadd( _axml, '  </WorksheetOptions>')
aadd( _axml, ' </Worksheet>')

aadd( _axml, '</Workbook>')

Return _axml

/*
===============================================================================================================================
Programa----------: MEST009E1
Autor-------------: Josue Danich Prestes
Data da Criacao---: 16/11/2015
Descricao---------: Monta cabecalho do excel
Parametros--------:
Retorno-----------:
===============================================================================================================================
*/
Static Function MEST009E1()

Local _axml  := {}
LOCAL _cArq01:= "\data\italac\mest009\MEST009_PLAN_01.txt"
Local _lTXT  := FILE(_cArq01)

IF _lTXT
	
	If FT_FUSE(_cArq01) == -1
		
		U_ITMSG("Não foi possível abrir o arquivo: "+_cArq01 , "Arquivo inválido" , "Favor verificar se o arquivo se esta correto.",1)
		Return _axml
		
	EndIf
	
	FT_FGOTOP()//PONTO NO TOPO
	
	If FT_FLASTREC() == 0 
		
		U_ITMSG("O arquivo "+_cArq01+" não possui dados." , "Arquivo inválido" , "Favor verificar se o arquivo se esta correto.",1)
		
		Return _axml
		
	EndIf
	
	DO WHILE !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
		_cLinha:=FT_FREADLN()
		IF !EMPTY(_cLinha)
			AADD(_axml,ALLTRIM(_cLinha))
		ENDIF
		FT_FSKIP()   //próximo registro no arquivo txt
		
	EndDo
	
	FT_FUSE()//Fecha o arquivo

ENDIF

Return _axml

/*
===============================================================================================================================
Programa----------: MEST009SB9
Autor-------------: Josue Danich Prestes
Data da Criacao---: 22/03/2016
Descricao---------: Retorna quantidade e valor de estoque anterior de um produto
Parametros--------: _cproduto,_cSegUni,_cEstAnt,_cGrpCus,_lPorItem,_cLocal,_cChave
Retorno-----------: _aval - array com quantidade e valor de estoque anterior
===============================================================================================================================
*/
Static Function MEST009SB9(_cproduto,_cSegUni,_cEstAnt,_cGrpCus,_lPorItem,_cLocal,_cChave)

Local _aval 	:= {}
Local _cquery 	:= ""
Local _dFim		:= MV_PAR06
Local _aSaldos	:= {} , _xi , _vl , _ji , _zi , _ii 
Local _aItem	:= {}
Local _aLocal	:= {}
Local _atrab	:= {}
Local _nQtde	:= 0
Local _nValor	:= 0
Local _nExpe	:= 0
Local _nVlr		:= 0
Local _aFilial	:= {}
Local _aTotItem := {}
Local _cFilGuard:= cFilant

DEFAULT _cLocal	  := "03;20;21;22;30;31;32;33;34;40;04;07;50;52"
DEFAULT _lPorItem := .F.
DEFAULT _cChave   := ""

_dfim:= LastDate(MonthSub(_dfim,1))

IF _cEstAnt = "2" // ZL6_ESTANT = "2=Fechamanto Anterior (ZE0)"

   _cMes:=VAL(Substr(dtos(MV_PAR05),5,2))
   IF _cMes = 1//Janeiro
      _cMes:="12"+STR( VAL(substr(dtos(MV_PAR05),1,4)) - 1 , 4)
   ELSE
      _cMes:=STRZERO( _cMes - 1 , 2) + substr(dtos(MV_PAR05),1,4)
   ENDIF

	If "08000000064" $ _cproduto  .OR. "08000000007"  $ _cproduto//_nExpe == 0 .and. _nVlr == 0
    	
       _cQuery := " SELECT ZE0_QTDE, ZE0_VALOR FROM "+ RETSQLNAME("ZE0")+" ZE0 "
       _cQuery += " WHERE ZE0.D_E_L_E_T_ = ' ' AND "
       _cQuery += "       ZE0_FILIAL = '"+cFilant+"' AND "
       _cQuery += "       ZE0_DSECT  = 'ESTOQUE ATUAL' AND "
       _cQuery += "       ZE0_DGRPCT = 'CREME DE LEITE A GRANEL' AND "
       _cQuery += "       ZE0_DATARQ = '"+_cMes+"' "

       MPSysOpenQuery( _cQuery, "ZE0T" ) 
 	
       If .NOT. ZE0T->( Eof() )
	      _nExpe   += ZE0T->ZE0_QTDE
	      _nVlr    += ZE0T->ZE0_VALOR
       ENDIF
       ZE0T->( DBCLOSEAREA() )

	   AADD(_aTotItem,{"",0,0})	
	   AADD(_aval,{ _nExpe , _nVlr   })	

       IF _lPorItem
          RETURN _aTotItem
       ELSE
          RETURN _aval
       ENDIF
/*
       _cValores:="ZE0_QTDE: "+STR(_nExpe,22,7)+ENTER
       _cValores+="ZE0_VALOR: "+STR(_nVlr,22,7)+ENTER
  		nHandle := FCreate(_cdir+"QUERY_"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
  		FWrite(nHandle, _cQuery+ENTER+ENTER+_cValores)
  		FClose(nHandle)*/

    ENDIF	

   _aItem 	:= STRTOKARR(alltrim(_cproduto), ';')
// _aItem2  := {}
// _aLocal	:= STRTOKARR(alltrim(_cLocal), ';')
   
   ZE0->(DBSETORDER(1))
   IF !EMPTY(_cChave) .AND. ZE0->(DBSEEK(xfilial("ZE1")+_cMes+_cChave))
      _nExpe:= ZE0->ZE0_QTDE
      _nVlr := ZE0->ZE0_VALOR
	  _aItem:={}
   ENDIF

    ZE1->( dbsetorder(1) )
   For _vl := 1 to Len(_aItem)
	   _cSeek := xfilial("ZE1") + _cMes + "    " + _aItem[_vl]

    	If ZE1->( Dbseek( _cSeek ) )

	    	_nExpe   += ZE1->ZE1_ESTATU
	    	_nVlr    += ZE1->ZE1_VESTAT//(ZE1->ZE1_CUSTOP/ZE1->ZE1_EXPE)*ZE1->ZE1_ESTATU

	        IF (_nPos:=ASCAN(_aTotItem,{|I| I[1] == _aItem[_vl] } )) = 0
	           AADD(_aTotItem,{_aItem[_vl],ZE1->ZE1_VESTAT,ZE1->ZE1_CUSTOP })
         	ELSE
	           _aTotItem[_nPos,2]+=ZE1->ZE1_VESTAT
	           _aTotItem[_nPos,3]+=ZE1->ZE1_CUSTOP
	        ENDIF	
//      else
//		    AADD(_aItem2,_aItem[_vl])
		ENDIF
   Next

   IF LEN(_aTotItem) = 0
      AADD(_aTotItem,{"",0,0})	
   ENDIF
   AADD(_aval,{ _nExpe , _nVlr   })	

/*
	If LEN(_aItem2) > 0 //_nExpe == 0 .and. _nVlr == 0
	   _aItem := ACLONE(_aItem2)
  	   nCustoM:=_nVlr/_nExpe 

		If MV_PAR07 <> 2
			If !empty(_cfilis)
				_aFilial := STRTOKARR(alltrim(_cfilis), ';')
			Endif			
		Endif	
		FOR _xi := 1 TO len(_aItem)   

			For _ii:= 1 TO len(_aLocal)
				If MV_PAR07 <> 2
					If !empty(_cfilis)
						For _ji := 1 to len(_aFilial)
							aadd(_atrab,{_aitem[_xi],_alocal[_ii], _aFilial[_ji]})
						Next		
					Else	
						aadd(_atrab,{_aitem[_xi],_alocal[_ii]})
					Endif
				Else
					aadd(_atrab,{_aitem[_xi],_alocal[_ii]})
				Endif		
			Next	
		
		Next
		For _zi := 1 To len(_atrab)
			If MV_PAR07 <> 2
				If !empty(_cFilis)
                   cFilant:=_atrab[_zi,3]
				   _aSaldos := CalcEst( _atrab[_zi,1] , _atrab[_zi,2] , _dFim + 1, _atrab[_zi,3] ) //obtém o saldo final em estoque na data informada
				Else
				   _aSaldos := CalcEst( _atrab[_zi,1] , _atrab[_zi,2] , _dFim + 1 ) //obtém o saldo final em estoque na data informada	
				Endif
			Else
				_aSaldos := CalcEst( _atrab[_zi,1] , _atrab[_zi,2] , _dFim + 1 ) //obtém o saldo final em estoque na data informada	
			Endif			

	        If _cSegUni = "S"
               _nSldItem:= _asaldos[7]
            Else
               _nSldItem:= _asaldos[1]
         	Endif
			_nQtde	+= _nSldItem
			_nValor += (nCustoM*_nSldItem)//_asaldos[2]

	        IF (_nPos:=ASCAN(_aTotItem,{|I| I[1] == _atrab[_zi,1] } )) = 0
	           AADD(_aTotItem,{_atrab[_zi,1],_nSldItem,_asaldos[2] })
         	ELSE
	           _aTotItem[_nPos,2]+=_nSldItem
	           _aTotItem[_nPos,3]+=_asaldos[2]
	        ENDIF	
		Next	
        _nQtde +=_nExpe
		_nValor+=_nVlr
//		_nValor := _nQtde * (_nVlr/_nExpe)
		AADD(_aval,{ _nQtde , _nValor })	
//		AADD(_aval,{ MEST9Calc2UN(_cSegUni,_nQtde,_cProduto) ,_nValor})	
	Else
		AADD(_aval,{ _nExpe , _nVlr   })	
//		AADD(_aval,{ MEST9Calc2UN(_cSegUni,_nExpe,_cProduto) ,_nVlr})	
	Endif		*/

ELSEIf xFilial("SB9") == "92" .and. !empty(_cproduto) .and. !empty(_cfilis)
	
	_aFilial := STRTOKARR(alltrim(_cfilis), ';')
	_aItem 	:= STRTOKARR(alltrim(_cproduto), ';')
	_aLocal	:= STRTOKARR(alltrim(_cLocal), ';')

	FOR _xi := 1 TO len(_aItem)   

		For _ii:= 1 TO len(_aLocal)
			If !empty(_cfilis)
				For _ji := 1 to len(_aFilial)
					aadd(_atrab,{_aitem[_xi],_alocal[_ii], _aFilial[_ji]})
				Next		
			Else	
				aadd(_atrab,{_aitem[_xi],_alocal[_ii]})
			Endif
		Next	
		
	Next
	For _zi := 1 To len(_atrab)
		If !empty(_cFilis)
            cFilant:=_atrab[_zi,3]
			_aSaldos := CalcEst( _atrab[_zi,1] , _atrab[_zi,2] , _dFim + 1, _atrab[_zi,3] ) //obtém o saldo final em estoque na data informada
		Endif
		_nQtde	+= _asaldos[1]
		_nValor += _asaldos[2]

        IF (_nPos:=ASCAN(_aTotItem,{|I| I[1] == _atrab[_zi,1] } )) = 0
           AADD(_aTotItem,{_atrab[_zi,1],_asaldos[1] , _asaldos[2] })
       	ELSE
           _aTotItem[_nPos,2]+=_asaldos[1]
           _aTotItem[_nPos,3]+=_asaldos[2]
        ENDIF	

	Next	

	AADD(_aval,{ MEST9Calc2UN(_cSegUni,_nQtde,_cProduto) ,_nValor})		

Elseif !empty(_cproduto)
	

	_aItem 	:= STRTOKARR(alltrim(_cproduto), ';')
	_aLocal	:= STRTOKARR(alltrim(_cLocal), ';')

	If MV_PAR07 <> 2
		If !empty(_cfilis)
			_aFilial := STRTOKARR(alltrim(_cfilis), ';')
		Endif			
	Endif	
	FOR _xi := 1 TO len(_aItem)   

		For _ii:= 1 TO len(_aLocal)
			If MV_PAR07 <> 2
				If !empty(_cfilis)
					For _ji := 1 to len(_aFilial)
						aadd(_atrab,{_aitem[_xi],_alocal[_ii], _aFilial[_ji]})
					Next		
				Else	
					aadd(_atrab,{_aitem[_xi],_alocal[_ii]})
				Endif
			Else
				aadd(_atrab,{_aitem[_xi],_alocal[_ii]})
			Endif		
		Next	
		
	Next
	For _zi := 1 To len(_atrab)
		If MV_PAR07 <> 2
			If !empty(_cFilis)
               cFilant:=_atrab[_zi,3]
			   _aSaldos := CalcEst( _atrab[_zi,1] , _atrab[_zi,2] , _dFim + 1, _atrab[_zi,3] ) //obtém o saldo final em estoque na data informada
			Else
			   _aSaldos := CalcEst( _atrab[_zi,1] , _atrab[_zi,2] , _dFim + 1 ) //obtém o saldo final em estoque na data informada	
			Endif
		Else
			_aSaldos := CalcEst( _atrab[_zi,1] , _atrab[_zi,2] , _dFim + 1 ) //obtém o saldo final em estoque na data informada	
		Endif			
        If _cSegUni = "S"
           _nSldItem:= _asaldos[7]
        Else
           _nSldItem:= _asaldos[1]
      	Endif
		_nQtde	+= _nSldItem
		_nValor += _asaldos[2]

        IF (_nPos:=ASCAN(_aTotItem,{|I| I[1] == _atrab[_zi,1] } )) = 0
           AADD(_aTotItem,{_atrab[_zi,1],_nSldItem , _asaldos[2] })
       	ELSE
           _aTotItem[_nPos,2]+=_nSldItem
           _aTotItem[_nPos,3]+=_asaldos[2]
        ENDIF	

	Next	

	AADD(_aval,{ _nQtde , _nValor })	

Else

	aadd(_aval,{0,0})	
	aadd(_aTotItem,{"",0,0})	

Endif

cFilant:=_cFilGuard

IF _lPorItem
   RETURN _aTotItem
ELSE
   Return _aval
ENDIF

/*
===============================================================================================================================
Programa----------: MEST009SD1
Autor-------------: Josue Danich Prestes
Data da Criacao---: 22/03/2016
Descricao---------: Retorna quantidade e valor de estoque por entrada de devolução ou transferência
Parametros--------: _cproduto - código do produto
Retorno-----------: _aval - array com quantidade e valor de entrada por devolução e transferência
===============================================================================================================================
*/
Static Function MEST009SD1(_cproduto,_ntipo,_cSegUni)

Local _aval := {}
Local _cquery := ""

_CQUERY := " SELECT SUM(D1_QUANT) QTDE, SUM(D1_CUSTO) VALOR FROM " + RETSQLNAME("SD1") + " SD1"
_CQUERY += " JOIN " + RETSQLNAME("SF4") + " SF4 ON D1_TES = F4_CODIGO AND D1_FILIAL = F4_FILIAL "
_cquery += " WHERE SD1.D_E_L_E_T_ = ' ' "
_cquery += " AND D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
_cquery += " AND D1_TES > ' ' "
                         
IF !EMPTY(_cproduto)
	If xFilial("SD1") = "92"
		If MV_PAR07 <> 2
			If EMPTY(_cFilis)
				_cquery += " AND D1_FILIAL = '" + xfilial("SD1") + "'"
			Else
				_cquery += " AND D1_FILIAL IN " +  FormatIn(ALLTRIM(_cFilis),";") 
			Endif
		Else
			_cquery += " AND D1_FILIAL = '" + xfilial("SD1") + "'"		
		Endif	
	Else
		_cquery += " AND D1_FILIAL = '" + xfilial("SD1") + "'"		
	Endif	
Endif	

_cquery += " AND D1_COD IN " + FormatIn(ALLTRIM(_cproduto),";") + ""
_cquery += " AND F4_ESTOQUE = 'S' "


If _ntipo == 1 //Notas de devolução

  _cquery += " AND D1_LOCAL IN ('31','03') "  

Elseif _ntipo == 2 //Outras notas

	_cquery += " AND (SELECT F1_TIPO FROM " +  retsqlname("SF1") + " SF1 WHERE SF1.D_E_L_E_T_ = ' '"
	_cquery += "      AND F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE
	_cquery += "      AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND ROWNUM = 1) <> 'D'"
	_cquery += " AND D1_LOCAL IN ('20','22') AND D1_FORNECE = 'F00001' "  

Endif

_cquery += " GROUP BY D1_FILIAL"

//TcQuery _cquery New Alias SD1T
MPSysOpenQuery( _cquery ,"SD1T" ) 
DBSelectArea("SD1T")

If !SD1T->( Eof() )

   AADD(_aval,{ MEST9Calc2UN(_cSegUni,SD1T->QTDE,_cProduto) , SD1T->VALOR })

Else

	AADD(_aval,{0,0})
	
Endif

SD1T->( DbClosearea() )
	
Return _aval

/*
===============================================================================================================================
Programa----------: MEST009IST
Autor-------------: Andre Lisboa
Data da Criacao---: 08/04/2016
Descricao---------: Retorna valor do ICMS ST para o produto
Parametros--------: _cproduto - código do produto
Retorno-----------: _aval - array valor total do ICMS ST
===============================================================================================================================
*/
Static Function MEST009IST(_cproduto)

Local _aicst := {}
Local _cquery := ""

_CQUERY := "SELECT CASE WHEN D.ICMSRET > 0 THEN V.TOTAL - D.ICMSRET ELSE V.TOTAL END AS TOTAL,"
_CQUERY += "                                                          V.QUANT AS QUANT"
_CQUERY += " FROM  (SELECT D2_FILIAL, SUM(D2_VALBRUT) - SUM(D2_TOTAL) TOTAL,          "
_CQUERY += "        (SELECT SUM(D2_QUANT) FROM " + RETSQLNAME("SD2") 
_CQUERY += "                WHERE D_E_L_E_T_ = ' '  AND D2_COD IN " + FORMATIN(ALLTRIM(_CPRODUTO),";")
_CQUERY += "                  AND D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
_CQUERY += "                  AND D2_FILIAL = '" + XFILIAL("SD2") + "' ) AS QUANT "
_CQUERY += "        FROM " + RETSQLNAME("SD2") 
_CQUERY += "        WHERE D_E_L_E_T_ = ' '  "
_CQUERY += "              AND D2_COD IN " + FORMATIN(ALLTRIM(_CPRODUTO),";")
_CQUERY += "              AND D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
_CQUERY += "              AND D2_FILIAL = '" + XFILIAL("SD2") + "'"
_CQUERY += "        GROUP BY D2_FILIAL ) V "
_CQUERY += "LEFT JOIN "
_CQUERY += "     (SELECT  D1_FILIAL, SUM(D1_TOTAL) DEV, SUM(D1_ICMSRET) ICMSRET  "
_CQUERY += "              FROM "+ retsqlname("SD1") 
_CQUERY += "              WHERE D_E_L_E_T_ = ' ' AND D1_COD IN " + FORMATIN(ALLTRIM(_CPRODUTO),";")
_CQUERY += "                AND D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
_CQUERY += "                AND D1_FILIAL = '" + xfilial("SD1") + "'"
_CQUERY += "                AND D1_TIPO = 'D' "
_CQUERY += "      GROUP BY D1_FILIAL) D  "
_CQUERY += "ON V.D2_FILIAL =  D.D1_FILIAL "

MPSysOpenQuery( _cquery ,"SD2T" ) 
DBSelectArea("SD2T")

If .not. SD2T->( Eof() )
   IF SD2T->TOTAL > 0
      AADD(_aicst,{SD2T->TOTAL,0})
   ELSE   
	  AADD(_aicst,{0,0})
   ENDIF	
Else

	AADD(_aicst,{0,0})
	
Endif

SD2T->( DbClosearea() )
	
Return _aicst


/*
===============================================================================================================================
Programa----------: MEST009EXP
Autor-------------: Andre Lisboa
Data da Criacao---: 20/04/2016
Descricao---------: Retorna quantidade expedida
Parametros--------: _cproduto - código do produto
Retorno-----------: _aExp - array quantidade total
===============================================================================================================================
*/
Static Function MEST009EXP(_cproduto,_cSegUni,_cLocais)

Local _aExp := {}
Local _cquery := ""
Local _cEst := Posicione('SM0',1,cEmpAnt+xfilial("SD2"),'M0_ESTCOB')

If EMPTY(_cproduto)
   AADD(_aExp,{0,0,0,0,0})
   Return _aExp
ENDIF

_cquery += " SELECT (DECODE(TMP.DQUANT,NULL,0,TMP.DQUANT)+DECODE(TMP.FQUANT,NULL,0,TMP.FQUANT)+DECODE(T.QUANT,NULL,0,T.QUANT)) AS TOT, "
_cquery += "        TMP.DQUANT, "
_cquery += "        TMP.FQUANT, "
_cquery += "        T.QUANT "
_cquery += " from "
//
_cquery += " (SELECT D.QUANT AS DQUANT, F.QUANT AS FQUANT, D.D2_FILIAL AS FILIAL FROM "
_cquery += "     (SELECT SUM(D2_QUANT) AS QUANT, D2_FILIAL "
_cquery += "         from ("+RETSQLNAME("SD2")+" SD2 "
_cquery += "         JOIN  "+RETSQLNAME("SC5")+" SC5 ON D2_FILIAL = C5_FILIAL AND D2_PEDIDO = C5_NUM) "
_cquery += "         JOIN  "+RETSQLNAME("SF4")+" SF4 on D2_FILIAL = F4_FILIAL AND D2_TES = F4_CODIGO "
_cquery += "         where SD2.D_E_L_E_T_ = ' ' and SC5.D_E_L_E_T_ = ' ' and SF4.D_E_L_E_T_ = ' ' "
_cquery += "         and c5_i_oper <> ' ' "
_cquery += "         and f4_estoque = 'S' "
If xFilial("SD2") $ ("93/90")
	_cquery += "         AND D2_LOCAL IN ('20', '21', '22','03','36','42') "
Else
	_cquery += "         AND D2_LOCAL IN ('20', '21', '22','03') "
Endif		
_cquery += "         AND D2_CF <> '5927' "
_cquery += "         and d2_cod in " + FormatIn(ALLTRIM(_cproduto),";")
_cquery += "         and d2_emissao between '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
If !EMPTY(_cproduto)
	If xFilial("SD2") = "92"
		If MV_PAR07 <> 2
			If EMPTY(_cFilis)
				_cquery += " AND D2_FILIAL = '" + xfilial("SD2") + "'"
			Else
				_cquery += " AND D2_FILIAL IN " +  FormatIn(ALLTRIM(_cFilis),";")
			Endif
		Else
			_cquery += " AND D2_FILIAL = '" + xfilial("SD2") + "'"
		Endif
	Else
		_cquery += " AND D2_FILIAL = '" + xfilial("SD2") + "'"
	Endif
Endif
_cquery += "         and d2_est = '" + _cEst + "' "
_cquery += "         and d2_cliente <> '000001' group by d2_filial) D "    
//
_cquery += "   FULL OUTER JOIN "
_cquery += "     (SELECT SUM(D2_QUANT) AS QUANT, D2_FILIAL  "
_cquery += "         FROM ("+RETSQLNAME("SD2")+" SD2 "
_cquery += "         JOIN  "+RETSQLNAME("SC5")+" SC5 ON D2_FILIAL = C5_FILIAL AND D2_PEDIDO = C5_NUM) "
_cquery += "         JOIN  "+RETSQLNAME("SF4")+" SF4 on D2_FILIAL = F4_FILIAL AND D2_TES = F4_CODIGO "
_cquery += "            where SD2.D_E_L_E_T_ = ' ' and SC5.D_E_L_E_T_ = ' ' and SF4.D_E_L_E_T_ = ' ' "
_cquery += "            and c5_i_oper <> ' ' "
_cquery += "            and f4_estoque = 'S' "
If xFilial("SD2") $ ("93/90")
	_cquery += "         AND D2_LOCAL IN ('20', '21', '22','03','36','42') "
Else
	_cquery += "         AND D2_LOCAL IN ('20', '21', '22','03') "
Endif		
_cquery += "            AND D2_CF  <> '5927' "
_cquery += "            and d2_cod in " + FormatIn(ALLTRIM(_cproduto),";")
_cquery += "            and d2_emissao between '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
If !EMPTY(_cproduto)
	If xFilial("SD2") = "92"
		If MV_PAR07 <> 2
			If EMPTY(_cFilis)
				_cquery += " AND D2_FILIAL = '" + xfilial("SD2") + "'"
			Else
				_cquery += " AND D2_FILIAL IN " +  FormatIn(ALLTRIM(_cFilis),";")
			Endif
		Else
			_cquery += " AND D2_FILIAL = '" + xfilial("SD2") + "'"
		Endif
	Else
		_cquery += " AND D2_FILIAL = '" + xfilial("SD2") + "'"
	Endif
Endif
_cquery += "            AND D2_EST <> '" + _cEst + "' "
_cquery += "            AND D2_CLIENTE <> '000001' group by d2_filial) F    "
_cquery += "            ON D.D2_FILIAL = F.D2_FILIAL ) TMP "
//IF !EMPTY(ALLTRIM(_cLocais))
//  _cquery += "   RIGHT JOIN "
//ELSE
   _cquery += "   FULL OUTER JOIN "
//ENDIF
_cquery += "     (select SUM(D2_QUANT) AS QUANT, D2_FILIAL  "
_cquery += "         FROM ("+RETSQLNAME("SD2")+" SD2 "
_cquery += "         JOIN  "+RETSQLNAME("SC5")+" SC5 ON D2_FILIAL = C5_FILIAL AND D2_PEDIDO = C5_NUM) "
_cquery += "         JOIN  "+RETSQLNAME("SF4")+" SF4 ON D2_FILIAL = F4_FILIAL AND D2_TES = F4_CODIGO "
_cquery += "            WHERE SD2.D_E_L_E_T_ = ' ' and SC5.D_E_L_E_T_ = ' ' and SF4.D_E_L_E_T_ = ' ' "
_cquery += "            AND C5_I_OPER <> ' ' "
_cquery += "            AND F4_ESTOQUE = 'S'  "

IF !EMPTY(ALLTRIM(_cLocais))
	If xFilial("SD2") $ ("93/90")   
   		_cLocais:="20;21;22;03;36;42"+ALLTRIM(_cLocais)
   	Else
   		_cLocais:="20;21;22;03;"+ALLTRIM(_cLocais)	
   	Endif	
ELSE
   If xFilial("SD2") $ ("93/90")   
   		_cLocais:="20;21;22;03;36;42"+ALLTRIM(_cLocais)
   Else		
   		_cLocais:="20;21;22;03"    
   Endif		
ENDIF

_cquery += "            AND D2_LOCAL IN "+FormatIn(_cLocais,";")//('20', '21', '22')
_cquery += "            AND D2_CF  <> '5927' "
_cquery += "            AND D2_COD IN " + FormatIn(ALLTRIM(_cproduto),";") + ""
_cquery += "            AND D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
If !EMPTY(_cproduto)
	If xFilial("SD2") = "92"
		If MV_PAR07 <> 2
			If EMPTY(_cFilis)
				_cquery += " AND D2_FILIAL = '" + xfilial("SD2") + "'"
			Else
				_cquery += " AND D2_FILIAL IN " +  FormatIn(ALLTRIM(_cFilis),";")
			Endif
		Else
			_cquery += " AND D2_FILIAL = '" + xfilial("SD2") + "'"
		Endif
	Else
		_cquery += " AND D2_FILIAL = '" + xfilial("SD2") + "'"
	Endif
Endif
_cquery += "            and d2_cliente = '000001' group by d2_filial) T "
_cquery += " ON TMP.FILIAL = T.D2_FILIAL "

MPSysOpenQuery( _cquery ,"SD2T" ) 
DBSelectArea("SD2T")

If .not. SD2T->( Eof() )

	AADD(_aExp,{ MEST9Calc2UN(_cSegUni,SD2T->TOT   ,_cProduto),;//1
	             MEST9Calc2UN(_cSegUni,SD2T->DQUANT,_cProduto),;//2
	             MEST9Calc2UN(_cSegUni,SD2T->FQUANT,_cProduto),;//3
	             MEST9Calc2UN(_cSegUni,SD2T->QUANT ,_cProduto),;//4
	             SD2T->TOT})//5 - Qtde sem conversão
		
Else

	AADD(_aExp,{0,0,0,0,0})
	
Endif

SD2T->( DbClosearea() )
	
Return _aExp

/*
===============================================================================================================================
Programa----------: MEST009FRT
Autor-------------: Andre Lisboa
Data da Criacao---: 20/04/2016
Descricao---------: Retorna valor do frete
Parametros--------: _cproduto - código do produto
Retorno-----------: _aFret - array valor total
===============================================================================================================================
*/
Static Function MEST009FRT(_cproduto,_nExp)

Local _aFret := {}//
Local _cquery    := ""
Local _cquery2   := ""
Local _cqueryp   := ""
Local _cqueryChep:= ""
Local _cqueryOcor:= "" 
Local _nFator    := U_ITGETMV( "IT_SEGFRET" , 0.0013)
Local _nVlrGrupo := _nVlrGeral := 0
Local _nFatorFret:= U_ITGetMV("IT_FAFRVEN","0*")
Local _lDividir  := .T.
IF "*" $ _nFatorFret
   _lDividir:= .F.
ENDIF
_nFatorFret:= VAL(_nFatorFret)

//SEGURO       * 
//_cquery2 := " SELECT SUM(D2_L-D2_VALDEV) AS VLRSEG from "+ RETSQLNAME("SD2") " // JARU ABATE AS DEVOUÇOES
_cquery2 := " SELECT SUM(D2_VALBRUT) AS VLRSEG "
_cquery2 += " FROM "+ RETSQLNAME("SD2")+" SD2 "  
_cquery2 += " JOIN  "+RETSQLNAME("SC5")+" SC5 ON D2_FILIAL = C5_FILIAL AND D2_PEDIDO = C5_NUM "
_cquery2 += " JOIN  "+RETSQLNAME("SF4")+" SF4 on D2_FILIAL = F4_FILIAL AND D2_TES = F4_CODIGO "
_cquery2 += "  WHERE SD2.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ' AND SF4.D_E_L_E_T_ = ' ' "
_cquery2 += "   AND C5_I_OPER <> ' ' "
_cquery2 += "   AND F4_ESTOQUE = 'S' "
_cquery2 += "   AND SD2.D2_LOCAL IN ('20', '21', '22') "
_cquery2 += "   AND SD2.D2_CF  <> '5927' "
IF !EMPTY(_cproduto)
   _cquery2 += "   AND SD2.D2_COD IN " + FormatIn(ALLTRIM(_cproduto),";")
ENDIF   
_cquery2 += "   AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
//_cquery2 += "   AND SD2.D2_CLIENTE <> '000001'   "
_cquery2 += "   AND SD2.D2_FILIAL = '" + xfilial("SD2") + "'"
_cquery2 += "   AND SD2.D2_TIPO = 'N' AND D2_TP = 'PA'" 

_cTeste:=""
_cTeste+="SEGURO: "+CHR(13)+CHR(10)
_cTeste+=_cquery2+CHR(13)+CHR(10)

//nHandle := FCreate(_cdir+"QUERY_P_"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
//FWrite(nHandle, _cquery2)
//FClose(nHandle)

MPSysOpenQuery( _cquery2 ,"SD2TX" ) 
DBSelectArea("SD2TX")

_cValores:=""

If .not. SD2TX->( Eof() ) .and. !empty(_cproduto)
                 //1-FRETE SOMADO       ,2-FRETE,3-SEGURO               ,4-CHEP,5-OCORRENCIAS
	AADD(_aFret,{(SD2TX->VLRSEG*_nFator),0      ,(SD2TX->VLRSEG*_nFator),0     ,0         })

    _nVlrGrupo:=SD2TX->VLRSEG

    _cValores:="SD2TX->VLRSEG: "+STR(SD2TX->VLRSEG,22,7)+ENTER

Else
	AADD(_aFret,{0,0,0,0,0})	
Endif

SD2TX->( DbClosearea() )

_cTeste+=_cValores+ENTER

//nHandle := FCreate(_cdir+"QUERY_P_"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
//FWrite(nHandle, _cquery2+ENTER+ENTER+_cValores)
//FClose(nHandle)


IF _nVlrGrupo = 0
   RETURN _aFret
ENDIF

///VALOR TOTAL DE FATURAMENTO DO PRODUTO   * 
_cqueryp := " SELECT SUM(D2_TOTAL) AS VLRTOT "
_cqueryp += " FROM "+ RETSQLNAME("SD2") +" SD2 "
_cqueryp += " JOIN  "+RETSQLNAME("SC5")+" SC5 ON D2_FILIAL = C5_FILIAL AND D2_PEDIDO = C5_NUM "
_cqueryp += " JOIN  "+RETSQLNAME("SF4")+" SF4 on D2_FILIAL = F4_FILIAL AND D2_TES = F4_CODIGO "
_cqueryp += "  WHERE SD2.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ' AND SF4.D_E_L_E_T_ = ' ' "
_cqueryp += "   AND C5_I_OPER <> ' ' "
_cqueryp += "   AND F4_ESTOQUE = 'S' "
_cqueryp += "   AND SD2.D2_LOCAL IN ('20', '21', '22') "
_cqueryp += "   AND SD2.D2_CF  <> '5927' "
_cqueryp += "   AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
_cqueryp += "   AND SD2.D2_CLIENTE <> '000001'   "
_cqueryp += "   AND SD2.D2_FILIAL = '" + xfilial("SD2") + "'"
_cqueryp += "   AND SD2.D2_TIPO = 'N' AND D2_TP = 'PA' " 

_cTeste+="VALOR TOTAL DE FATURAMENTO DO PRODUTO: "+CHR(13)+CHR(10)
_cTeste+=_cqueryp+CHR(13)+CHR(10)

//nHandle := FCreate(_cdir+"QUERY_T_"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
//FWrite(nHandle, _cqueryp)
//FClose(nHandle)

MPSysOpenQuery( _cqueryp ,"SD2TP" ) 

_cValores:=""

If .not. SD2TP->( Eof() )
   _nVlrGeral:=SD2TP->VLRTOT

    _cValores:="SD2TP->VLRTOT: "+STR(SD2TP->VLRTOT,22,7)+ENTER

Endif

SD2TP->( DbClosearea() )

_cTeste+=_cValores+ENTER
//nHandle := FCreate(_cdir+"QUERY_T_"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
//FWrite(nHandle, _cqueryp+ENTER+ENTER+_cValores)
//FClose(nHandle)

/// FRETE A SOMAR
_cquery := " SELECT SUM(D2_I_FRET) AS FRETE from "+ retsqlname("SD2") "
_cquery += " WHERE D_E_L_E_T_ = ' ' AND D2_COD IN " + FormatIn(ALLTRIM(_cproduto),";") + ""
_cquery += " AND D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"

If !EMPTY(_cproduto)
   If xFilial("SD2") = "92"
		If EMPTY(_cFilis)
			_cquery += " AND D2_FILIAL = '" + xfilial("SD2") + "'"
		Else
			_cquery += " AND D2_FILIAL IN " +  FormatIn(ALLTRIM(_cFilis),";")
		Endif
   Else
		_cquery += " AND D2_FILIAL = '" + xfilial("SD2") + "'"
   Endif
Endif

_cTeste+="FRETE A SOMAR: "+CHR(13)+CHR(10)
_cTeste+=_cquery+CHR(13)+CHR(10)
_cValores:=""

MPSysOpenQuery( _cquery ,"SD2T" ) 

If .NOT. SD2T->( Eof() )
   IF _nFatorFret=0 
      _nFrete:=SD2T->FRETE
   ELSEIF _lDividir
      _nFrete:=SD2T->FRETE/_nFatorFret
   ELSE
      _nFrete:=SD2T->FRETE*_nFatorFret
   ENDIF   
   //1-FRETE SOMADO,2-FRETE,3-SEGURO,4-CHEP
   _aFret[1,2]+= _nFrete
   _aFret[1,1]+= _nFrete
   _cValores:="_nFatorFret: "+STR(_nFatorFret,22,7)+IF(_lDividir,"/","*")+ENTER
   _cValores+="_nFrete: "+STR(_nFrete,22,7)+ENTER
Endif	

_cTeste+=_cValores+ENTER


//CHEP'S
_cqueryChep := " SELECT SUM(E2_VALOR) VLRCHEP FROM "+ retsqlname("SE2") "
_cqueryChep += " WHERE D_E_L_E_T_ = ' ' "
_cqueryChep += " AND E2_FILIAL = '" + xfilial("SE2") + "'"
_cqueryChep += " AND E2_NOMFOR LIKE '%CHEP%' "
_cqueryChep += " AND E2_BAIXA <> ' ' "
//_cqueryChep += " AND E2_NUMBOR <> ' ' "
_cqueryChep += " AND E2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"

_cTeste+="CHEP'S: "+CHR(13)+CHR(10)
_cTeste+=_cqueryChep+CHR(13)+CHR(10)
_cValores:=""

MPSysOpenQuery( _cqueryChep ,"SE2T" ) 

If .not. SE2T->( Eof() )
   //1-FRETE SOMADO,2-FRETE,3-SEGURO,4-CHEP
   _aFret[1,4]+=(SE2T->VLRCHEP * (_nVlrGrupo/_nVlrGeral))
   _aFret[1,1]+=(SE2T->VLRCHEP * (_nVlrGrupo/_nVlrGeral))

   _cValores:="SE2T->VLRCHEP: "+STR(SE2T->VLRCHEP,22,7)+ENTER

Endif

_cTeste+=_cValores+ENTER

If _nExp > 0
	//OCORRENCIAS DE FRETE
	_cqueryOcor := " SELECT SUM(ZF5_CUSTO+ZF5_CUSTOI+ZF5_CUSTOR) AS VLROCO FROM "+ RETSQLNAME("ZF5") "
	_cqueryOcor += " WHERE D_E_L_E_T_ = ' ' "
	_cqueryOcor += " AND ZF5_FILIAL = '" + XFILIAL("ZF5") + "'"
	_cqueryOcor += " AND ZF5_DTINI BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
	_cqueryOcor += " AND ZF5_DTFIN BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"

_cTeste+="OCORRENCIAS DE FRETE: "+CHR(13)+CHR(10)
_cTeste+=_cqueryOcor+CHR(13)+CHR(10)
_cValores:=""
	
	MPSysOpenQuery( _cqueryOcor ,"ZF5T" )
	
	If .not. ZF5T->( Eof() )
		//1-FRETE SOMADO,2-FRETE,3-SEGURO,4-CHEP,5-OCORRENCIAS
		_aFret[1,5]+=(ZF5T->VLROCO * (_nVlrGrupo/_nVlrGeral))
		_aFret[1,1]+=(ZF5T->VLROCO * (_nVlrGrupo/_nVlrGeral))

        _cValores:="ZF5T->VLROCO: "+STR(ZF5T->VLROCO,22,7)+ENTER

	Endif

    _cTeste+=_cValores+ENTER
	
	ZF5T->( DbClosearea() )
Endif

SD2T->( DbClosearea() )
SE2T->( DbClosearea() )

nHandle := FCreate(_cdir+"QUERYS_MEST009FRT_"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
FWrite(nHandle, _cTeste)
FClose(nHandle)
	
Return _aFret


/*
===============================================================================================================================
Programa----------: MEST009GRD
Autor-------------: Josué Danich Prestes
Data da Criacao---: 20/05/2016
Descricao---------: Grava detalhes do produto na ZE0
Parametros--------: 	_aze0 - dados da gravação
					  	_ni - posição de gravação
					  	_nvalor - valor do evento
					  	_nqtde - quantidade do evento
					  	_ccod1 - código do evento
					  	_ccod2 - código do subevento
					  	_desc - descrição do evento
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST009GRD(_aze0, _ni, _nvalor,_nqtde, _ccod1, _ccod2, _cdesc)
					
Local _cfiltro := ""

_cfiltro :=  xfilial("ZE0") + substr(dtos(MV_PAR05),5,2) +  substr(dtos(MV_PAR05),1,4) + _aze0[_ni][8] + _aze0[_ni][2]
_cfiltro +=  _ccod1 + _ccod2
	
If ZE0->( Dbseek( _cfiltro ) )
	 	
	//achou registro cria faz atualização
 	RecLock("ZE0",.F.)    
		
	ZE0->ZE0_QTDE	:= 	_nqtde
	ZE0->ZE0_VALOR	:= 	_nvalor
	ZE0->ZE0_VLRLT	:=  _nvalor / _ntotlei
	ZE0->ZE0_VDOLAR :=  _nvalor / (_ntotlei * _nTotdol)
	 	
 	("ZE0")->(MsUnlock())
	 	
Else
	 	
	//não achou registro cria um novo
 	RecLock("ZE0",.T.)    
		
	ZE0->ZE0_FILIAL := 	_aze0[_ni][1]	
	ZE0->ZE0_TPCUS	:=	_aze0[_ni][2]
	ZE0->ZE0_DTPCT	:=	_aze0[_ni][3]
	ZE0->ZE0_EVCUS	:=	_ccod1
	ZE0->ZE0_DEVCT	:=	_cdesc
	ZE0->ZE0_SEVCT	:= 	_ccod2
	ZE0->ZE0_DSECT	:= 	_cdesc
	ZE0->ZE0_GRPCT	:= 	_aze0[_ni][8]
	ZE0->ZE0_DGRPCT	:= 	_aze0[_ni][9]
	ZE0->ZE0_QTDE	:= 	_nqtde
	ZE0->ZE0_VALOR	:= 	_nvalor
	ZE0->ZE0_DATARQ	:= 	_aze0[_ni][12]
	ZE0->ZE0_VLRLT	:=  _nvalor / _ntotlei
	ZE0->ZE0_VDOLAR :=  _nvalor / (_ntotlei * _nTotdol)
	 	
 	("ZE0")->(MsUnlock())
	 	
Endif

Return

/*
===============================================================================================================================
Programa----------: MEST009PMMTFQF
Autor-------------: Alex Walaluer
Data da Criacao---: 11/10/2016
Descricao---------: procura preço mínimo, preço máximo, total de faturamento e quantidade faturada
Parametros--------: _cCodProd: Código de um ou de uma lista de produtos separados por ;
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST009PMMTFQF(_cCodProd)

LOCAL _nPrcmin := 0
LOCAL _nPrcmax := 0
LOCAL _nfatura := 0
LOCAL _nqtdfat := 0
LOCAL _cAlias  := GetNextAlias()
LOCAL _cquery  := " SELECT " 
	
_cquery  	+= " D2_COD, "
_cquery  	+= " ROUND(MAX( ( D2_VALBRUT - ( D2_I_FRET + D2_VALICM + D2_VALIMP5 + D2_VALIMP6 + D2_VALIPI ) ) / D2_QUANT ),2) AS PRCMAX, "
_cquery  	+= " ROUND(MIN( ( D2_VALBRUT - ( D2_I_FRET + D2_VALICM + D2_VALIMP5 + D2_VALIMP6 + D2_VALIPI ) ) / D2_QUANT ),2) AS PRCMIN, "
_cquery  	+= " SUM( D2_QUANT ) AS QTDE, "
_cquery  	+= " SUM( D2_VALBRUT - ( D2_I_FRET + D2_VALICM + D2_VALIMP5 + D2_VALIMP6 + D2_VALIPI ) ) AS FATUR "
_cquery  	+= " FROM " + RetSqlName("SD2") + " SD2 JOIN  " + RetSqlName("SF4") + " SF4 ON  SF4.F4_FILIAL = SD2.D2_FILIAL AND SF4.F4_CODIGO = SD2.D2_TES"

If MV_PAR07 <> 2
	If EMPTY(ZL6T->ZL6_FILIS)
		_cquery  	+= " WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
	Else
		_cquery += " WHERE SD2.D2_FILIAL IN " +  FormatIn(ALLTRIM(ZL6T->ZL6_FILIS),";")
	Endif	
Else
	_cquery  	+= " WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "'"	
Endif	

_cquery   	+= " AND SD2.D2_EMISSAO >= '" + dtos(MV_PAR05) + "' AND D2_EMISSAO <= '" + dtos(MV_PAR06) + "' "
_cquery   	+= " AND SD2.D2_QUANT > 0 "
_cquery  	+= " AND SD2.D2_COD IN " + FormatIn(ALLTRIM(_cCodProd),";")
_cquery  	+= " AND SF4.D_E_L_E_T_ = ' ' "
_cquery  	+= " AND SF4.F4_FILIAL = '" + xfilial("SF4") + "' "
_cquery 	+= " AND SF4.F4_DUPLIC = 'S'	"
_cquery 	+= " AND SF4.F4_ESTOQUE= 'S'	"
_cquery 	+= " GROUP BY D2_COD "

MPSysOpenQuery( _cquery , _cAlias ) 

If .not. (_cAlias)->( Eof() )
	
	_nPrcmin := (_cAlias)->PRCMIN
	_nPrcmax := (_cAlias)->PRCMAX
	_nfatura := (_cAlias)->FATUR
	_nqtdfat := (_cAlias)->QTDE

Endif
		
(_cAlias)->( DbClosearea() )

DBSelectArea("SD2")

RETURN {_nPrcmin,_nPrcmax,_nfatura,_nqtdfat}


/*
===============================================================================================================================
Programa----------: MEST9Calc2UN(_nQtde,_cProd)
Autor-------------: Alex Walaluer
Data da Criacao---: 11/10/2016
Descricao---------: devolve a segunda unidade
Parametros--------: _cSegUni: Se usa a segunda unidade
                    _nQtde: Quantidade na primeira unidade
                    _cProd: Código de um ou de uma lista de produtos separados por
Retorno-----------: Quantidade na segunda unidade
===============================================================================================================================
*/
Static Function MEST9Calc2UN(_cSegUni,_nQtde,_cProd)
LOCAL _nPos:=0

_cProd:=ALLTRIM(_cProd)
_nPos:=AT(";",_cProd)
IF _nPos > 1
   _cProd:=SUBSTR(_cProd,1,_nPos-1)
ENDIF
SB1->(DbSetOrder(1))
SB1->(DBSeek(xFilial("SB1")+_cProd)) 

IF _cSegUni = "S" .AND. _nQtde # 0
   IF  SB1->B1_CONV > 0
	  IF SB1->B1_TIPCONV = 'D'
         _nQtde:=(_nQtde/SB1->B1_CONV)
      ELSE
         _nQtde:=(_nQtde*SB1->B1_CONV)
      ENDIF
   ENDIF
ENDIF

RETURN _nQtde

/*
===============================================================================================================================
Programa----------: MEST9BuscaZE0()
Autor-------------: Alex Walaluer
Data da Criacao---: 29/06/2017
Descricao---------: Devolve o valor de outras filiais
Parametros--------: _cFils: Filiais
Retorno-----------: Valor
===============================================================================================================================
*/
Static Function MEST9BuscaZE0(_cFilis,_cClientes,_cProds,_cCusto)
Local _cQuery := ""
Local _nFator := 0
Local _nValor := 0
Local _nQtde  := 0
Local _cMes   := MONTH(MV_PAR05)

_cQuery += " SELECT  SUM(ZE0_QTDE) QTDE,  SUM(ZE0_VALOR) TOTAL FROM "+ RETSQLNAME("ZE0")+" ZE0"
_cQuery += " WHERE ZE0.D_E_L_E_T_ = ' ' "
IF !EMPTY(_cFilis)
    _cQuery += " AND ZE0_FILIAL IN "+FormatIn(ALLTRIM(_cFilis),";") 
ENDIF    
IF ALLTRIM(_cCusto) <> '000005' .AND. ALLTRIM(ZL6T->ZL6_TPCUS) == '000002' .AND. 'ESTOQUE INICIAL' $ UPPER(ZL6T->ZL6_DESEVE)
   _cQuery += " AND ZE0_TPCUS = '000002' AND ZE0_DEVCT LIKE '%ESTOQUE FINAL%' "
   _cQuery += " AND ZE0_GRPCT = '"+ZL6T->ZL6_GRPCUS+"' "
   IF _cMes = 1//Janeiro
      _cMes:="12"+STR( YEAR(MV_PAR05) - 1 , 4)
   ELSE
      _cMes:=STRZERO(_cMes - 1 ,2) + ALLTRIM(STR(YEAR(MV_PAR05)))
   ENDIF
   _cQuery += " AND ZE0_DATARQ = '"+_cMes+"' "
ELSE
   _cQuery += " AND ZE0_TPCUS = '000001' "
   _cQuery += " AND ZE0_DATARQ = '"+ STRZERO(MONTH(MV_PAR05),2) + ALLTRIM(STR(YEAR(MV_PAR05))) +"' "
ENDIF

IF ALLTRIM(_cCusto) <> '000005' 

   MPSysOpenQuery( _cQuery, "ZE0T" ) 
 	
   If .NOT. ZE0T->( Eof() )
      _nValor:=ZE0T->TOTAL
  	  _nQtde :=ZE0T->QTDE
   ENDIF
/*
_cTeste:=_cQuery
_cTeste+=ENTER
_cTeste+= "Qtde: "+STR(_nQtde,20,8)
_cTeste+=ENTER
_cTeste+= "Total: "+STR(_nValor,20,8)
_cTeste+=ENTER
*/
   ZE0T->( DbClosearea() )

   IF ALLTRIM(ZL6T->ZL6_TPCUS) == '000002' .AND. 'ESTOQUE INICIAL DE PRODUTO' $ UPPER(ZL6T->ZL6_DESEVE)

//      _cFileNome:=_cdir+"MEST009_ZE0_"+xFilial("ZL6")+"_"+STRTRAN(TIME(),":","_")+".TXT"
//      MemoWrite(_cFileNome,_cTeste)

      RETURN {_nQtde,_nValor}
   ENDIF   

ENDIF

_cQuery := ""
_cQuery += " SELECT B.FIL, B.QTDE, ROUND(RATIO_TO_REPORT(B.QTDE) OVER(),2) AS PRORP FROM "
_cQuery += "  (SELECT ZZM_CODIGO FIL, D2_CLIENTE, D2_LOJA, SUM(D2_QUANT) QTDE FROM "+ RETSQLNAME("SD2")+" D2 "
_cQuery += "         JOIN "+ RETSQLNAME("SA1")+" A1 ON D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA "
_cQuery += "         JOIN "+ RETSQLNAME("ZZM")+" ZZM ON A1_CGC = ZZM_CGC "
_cQuery += "         WHERE D2.D_E_L_E_T_ = ' ' AND A1.D_E_L_E_T_ = ' ' AND ZZM.D_E_L_E_T_ = ' ' "
_cQuery += "         AND D2_FILIAL  IN "+FormatIn(ALLTRIM(_cFilis),";") 
_cQuery += "         AND D2_CLIENTE||D2_LOJA IN "+FormatIn(ALLTRIM(_cClientes),";")
_cQuery += "         AND D2_COD IN "+FormatIn(ALLTRIM(_cProds),";")
_cQuery += "         AND D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
_cQuery += "         GROUP BY ZZM_CODIGO, D2_CLIENTE, D2_LOJA) B "

MPSysOpenQuery( _cQuery, "SD2T" ) 

If .NOT. SD2T->( Eof() )
   IF SD2T->FIL = cFilAnt
	  _nFator:=SD2T->PRORP
   ENDIF
   SD2T->( DBSKIP() )
   IF SD2T->FIL = cFilAnt
	  _nFator:=SD2T->PRORP
   ENDIF
Endif

 SD2T->( DbClosearea() )
_nValor:=_nValor*_nFator
/*
_cTeste+=_cQuery
_cTeste+=ENTER
_cTeste+= "Fator: "+STR(_nFator,20,8)
_cTeste+=ENTER
_cTeste+= "Total X Fator: "+STR(_nValor,20,8)
_cTeste+=ENTER
_cFileNome:=_cdir+"MEST009_ZE0_"+xFilial("ZL6")+"_"+STRTRAN(TIME(),":","_")+".TXT"
MemoWrite(_cFileNome,_cTeste)
*/

IF ALLTRIM(_cCusto) = '000005' 
   RETURN _nFator
ELSE
   RETURN {_nQtde,_nValor}
ENDIF
/*
===============================================================================================================================
Programa----------: MEST9EstoqueFinal()
Autor-------------: Alex Walaluer
Data da Criacao---: 04/07/2018
Descricao---------: PARA O DEMONSTRATIVO DO ESTOQUE FINAL PLANILHA 03
Parametros--------: _oself
Retorno-----------: {Valor,Quantidade]
===============================================================================================================================
*/
Static Function MEST9EstoqueFinal(_oself,_lEnd)
Local _cQuery2  := ""
//Local _cTabela 	:= "SB2.B2"
Local cAliasSB2 := GetNextAlias()
Local _dFim		:= MV_PAR06
Local _nQtde    := 0
Local _nQtdeItem:= 0
Local _nValrUni := 0
Local _nValor   := 0
Local _cSegUni  := ZL6T->ZL6_TUNID 
Local _cCodsProd:= ZL6T->ZL6_CODPRO
Local _cFiliais := ZL6T->ZL6_FILIS
Local _cFilAtual:= cFilant
Local aSaldo    := {}
Local _aProdutos:= {}
Local _cCampo   := "" , _cTotReg
Local _cFilSB1  := xFilial("SB1")
Local _dDtSB9   := LastDate(MV_PAR06)
Local _dULMES 	:= GETMV("MV_ULMES")      
DEFAULT _lEnd   := .F.

_cCampo += "(SELECT B1_TIPO FROM " + RetSqlName("SB1") + " SB1 WHERE B1_FILIAL = '" +Xfilial("SB1") + "' "
_cCampo += "                                                     AND D_E_L_E_T_ = ' ' "
_cCampo += "                                                     AND SB1.B1_COD = SB2.B2_COD ) TIPO "
_dFim:= LastDate(_dFim)

_cQuery2:= " SELECT B2_COD,  B2_LOCAL,  B2_FILIAL, "+_cCampo+"  FROM " + RetSqlName("SB2") + " SB2 WHERE "

IF ALLTRIM(ZL6T->ZL6_TPCUS) <> "000006"  // Aqui entra para a as Panilhas 01 e 02 (_lGera2Pla .OR. _lGera1Pla) 02-CUSTO E ESTOQUE MP (000004,000005) PLANILHAS 01 E 02
   IF !EMPTY(_cFiliais)
      _cQuery2 += " SB2.B2_FILIAL IN "+FormatIn(ALLTRIM(_cFiliais ),";")+" AND "
   ELSE
      _cQuery2 += " SB2.B2_FILIAL = '"+cFilant+"' AND "
   ENDIF   
   IF !EMPTY(_cCodsProd)
      _cQuery2 += " SB2.B2_COD    IN "+FORMATIN(ALLTRIM(_cCodsProd),";")+" AND "  // ELSE RETURN {0,0,,,,,0}
   ENDIF   
ELSE//ALLTRIM(ZL6T->ZL6_TPCUS) == '000006' aqui entra só para a planilha 03 (_lGera3Pla) 03-ESTOQUE FINAL (000006).  
   _cQuery2 += " B2_FILIAL = '" +Xfilial("SB2") + "' "
   _cQuery2 += " AND NOT EXISTS (SELECT B1_TIPO FROM " + RetSqlName("SB1") + " SB1 "
   _cQuery2 += "                                                        WHERE B1_FILIAL  = '" +Xfilial("SB1") + "' "
   _cQuery2 += "                                                          AND D_E_L_E_T_ = ' ' "
   _cQuery2 += "                                                          AND SB1.B1_COD = SB2.B2_COD   "
   _cQuery2 += "                                                          AND (B1_TIPO IN ('PA','MP','PP','PI','SV') OR B1_MSBLQL = '1'  ) ) " 
   _cQuery2 += " AND ( "

	_cQuery2 += "      (SELECT B1_TIPO FROM " + RetSqlName("SB1") + " SB1 WHERE B1_FILIAL = '" +Xfilial("SB1") + "' "
	_cQuery2 += "                                                          AND D_E_L_E_T_ = ' ' "
	_cQuery2 += "                                                          AND SB1.B1_COD = SB2.B2_COD ) "
	_cQuery2 += "      IN ('EM','IN')" 
	_cQuery2 += " OR "
  	_cQuery2 += "      SUBSTR(B2_COD,1,4) IN (SELECT BM_GRUPO FROM " + RetSqlName("SBM") + " SBM "
  	_cQuery2 += "   	                            WHERE BM_FILIAL = '" +xFilial("SBM") + "' AND D_E_L_E_T_ = ' ' AND "
  	_cQuery2 += "                                         BM_GRUPO NOT IN ('0599','0800','0801','0814') AND  "
  	_cQuery2 += "                                         SUBSTR(BM_GRUPO,1,2) <> '03' ) "

    _cQuery2 += "  ) AND  "
ENDIF

_cQuery2 	+= " D_E_L_E_T_ = ' ' "
_cQuery2 	+= " ORDER BY B2_COD , B2_LOCAL "
  
IF VALTYPE(_oSelf) = "O"
   _oSelf:SetRegua1( 0 )
   _oSelf:SetRegua2( 3 )
   _oSelf:IncRegua1("Lendo Estoque dos itens...")
   _oSelf:IncRegua2("Lendo Estoque dos itens...")
   _nRegSB2:=0
ENDIF
  
MPSysOpenQuery( _cQuery2 ,  cAliasSB2 ) 
DBSelectArea(cAliasSB2)
  
IF VALTYPE(_oSelf) = "O"
   COUNT TO _nRegSB2
   _oSelf:SetRegua2( (_nRegSB2/100)+100 )
   _cTotReg:=ALLTRIM(STR(_nRegSB2))
   _nConta:=0
   _oSelf:IncRegua2("Lendo Item / Grupo: "+ALLTRIM(STR(_nConta,6))+" de "+_cTotReg+" [ " + ALLTRIM((cAliasSB2)->B2_COD) +" ] ")
   ProcessMessages()
ENDIF
//_cTeste:=""
SB1->(DbSetOrder(1))
SB9->(DbSetOrder(1))
aSaldo:={0,0,,,,,0}
(cAliasSB2)->(DBGOTOP())
DO While (cAliasSB2)->(!Eof())
	
	_nConta++
	IF VALTYPE(_oSelf) = "O" .AND. (Mod(_nConta,100) = 0 .OR. _nConta < 100)
	   _oSelf:IncRegua2("Lendo Item / Grupo: "+ALLTRIM(STR(_nConta,6))+" de "+_cTotReg+" [ " + ALLTRIM((cAliasSB2)->B2_COD) +" ] ")
       ProcessMessages()
       IF _lEnd 
          IF (_lEnd:=U_ITMSG("Confirma Cancelamento???? .","Atenção",,3,2,2))
             _lLoop:=.T.
             RETURN {0,0,{}}
          ENDIF   
       ENDIF
	ENDIF

	cFilant:=(cAliasSB2)->B2_FILIAL
	IF SB9->(DBSEEK(cFilant+(cAliasSB2)->B2_COD+(cAliasSB2)->B2_LOCAL+DTOS(_dDtSB9)))
       aSaldo:={SB9->B9_QINI,SB9->B9_VINI1,,,,,SB9->B9_QISEGUM}
	   _cCalcEst:=""
	ELSEIF (_dULMES < _dDtSB9)
  	   aSaldo := CalcEst( (cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,_dFim+1,(cAliasSB2)->B2_FILIAL )
	   _cCalcEst:="[CE]"
	ENDIF   
	
	IF VALTYPE(aSaldo[1]) = "N" .AND. aSaldo[1] <> 0//Se tiver quantidade
		
		If _cSegUni = "S"
			_nQtde    += aSaldo[7]
			_nQtdeItem:= aSaldo[7]
		Else
			_nQtde    += aSaldo[1]
			_nQtdeItem:= aSaldo[1]
		Endif
		
		IF _lGera3Pla
			_nValor += aSaldo[2]//Soma dos totais
			
			SB1->(DBSeek(_cFilSB1+(cAliasSB2)->B2_COD))
			IF (cAliasSB2)->TIPO = 'EM'
				_cOrdem:="A "+ALLTRIM(SB1->B1_DESC)//(cAliasSB2)->B2_LOCAL+" "+(cAliasSB2)->TIPO+" "+(cAliasSB2)->B2_COD
			ELSEIF (cAliasSB2)->TIPO = 'IN'
				_cOrdem:="B "+ALLTRIM(SB1->B1_DESC)//(cAliasSB2)->B2_LOCAL+" "+(cAliasSB2)->TIPO+" "+(cAliasSB2)->B2_COD
			ELSE
				_cOrdem:="C "+(cAliasSB2)->(SUBSTR(B2_COD,1,4))+" "+ALLTRIM(SB1->B1_DESC)+(cAliasSB2)->B2_COD//(cAliasSB2)->B2_LOCAL+" "+(cAliasSB2)->TIPO+" "+(cAliasSB2)->B2_COD
			ENDIF   

	        AADD(_aProdutos,{(cAliasSB2)->B2_COD,;//01
	                     aSaldo[2]              ,;//02
	                     _nQtdeItem             ,;//03
	                     (cAliasSB2)->B2_LOCAL  ,;//04
	                     (cAliasSB2)->TIPO      ,;//05
	                     (cAliasSB2)->(SUBSTR(B2_COD,1,4)),;//06 - Grupo
	                     _cOrdem                          ,;//07 - ORDENACAO
	                     _cCalcEst                        })//08 - CALCEST  
	                     
        ENDIF
	
	ENDIF   
	
	(cAliasSB2)->(DBSKIP())
	
ENDDO

cFilant:=_cFilAtual

//                 Ordenação// 7-ORDEM (ABC) + 6-GRUPO + 4-LOCAL + 5-TIPO + 1-CODIGO DO ITEM
_aProdutos:= aSort(_aProdutos,,,{|x,y| x[7] < y[7] })

_nValrUni:=(_nValor/_nQtde)//Valor Unitario

(cAliasSB2)->( DBCloseArea() )

IF VALTYPE(_oSelf) = "O"
   _oSelf:IncRegua2("OK")
   ProcessMessages()
ENDIF

RETURN {_nValrUni,_nQtde,_aProdutos}

/*
===============================================================================================================================
Programa----------: MEST9BuscaSB2()
Autor-------------: Andre Lisboa
Data da Criacao---: 21/07/2017
Descricao---------: Retorna saldo atual conforme data final informada no parametro do relatorio
Parametros--------: _cproduto: Produtos
Retorno-----------: Quantidade
===============================================================================================================================
*/
Static Function MEST9BscSB2(_cproduto,_lPorItem)

Local _dFim		:= MV_PAR06
Local _aSaldos	:= {}
Local _cLocal	:= "03;20;21;22;30;31;32;33;34;40;04;07;50;52"
Local _aItem	:= {}
Local _aLocal	:= {}
Local _nSldAtu	:= 0
Local _nValor	:= 0
Local _aFilial	:= {}
Local _atrab	:= {}
Local _aTotItem := {}
Local _nSldItem := 0 , _ji , _ii  , _xi  , _zi
Local _cFilGuard:= cFilant

DEFAULT _lPorItem := .F.
_aItem 	:= STRTOKARR(alltrim(_cproduto), ';')
_aLocal	:= STRTOKARR(alltrim(_cLocal), ';')
_aFilial:= STRTOKARR(alltrim(_cfilis), ';')

FOR _xi := 1 TO len(_aItem)   

	For _ii:= 1 TO len(_aLocal)
		If !empty(_cfilis)
			For _ji := 1 to len(_aFilial)
				aadd(_atrab,{_aitem[_xi],_alocal[_ii], _aFilial[_ji]})
			Next		
		Else	
			aadd(_atrab,{_aitem[_xi],_alocal[_ii]})
		Endif
	Next	
		
Next
For _zi := 1 To len(_atrab)
   If !empty(_cfilis)
        cFilant:=_atrab[_zi,3]
		_aSaldos := CalcEst( _atrab[_zi,1] , _atrab[_zi,2] , _dFim + 1, _atrab[_zi,3] ) //obtém o saldo final em estoque na data informada
	Else
		_aSaldos := CalcEst( _atrab[_zi,1] , _atrab[_zi,2] , _dFim + 1 ) //obtém o saldo final em estoque na data informada			
	Endif	
	If _cSegUni = "S"
        _nSldItem:= _asaldos[7]
	Else
        _nSldItem:= _asaldos[1]
	Endif
	_nSldAtu += _nSldItem
	_nValor  += _asaldos[2]

	IF (_nPos:=ASCAN(_aTotItem,{|I| I[1] == _atrab[_zi,1] } )) = 0
	   AADD(_aTotItem,{_atrab[_zi,1],_nSldItem,_asaldos[2]})
	ELSE
	   _aTotItem[_nPos,2]+=_nSldItem
	   _aTotItem[_nPos,3]+=_asaldos[2]
	ENDIF
Next	

cFilant:=_cFilGuard

IF _lPorItem

   RETURN _aTotItem

ELSE

   RETURN _nSldAtu
   
ENDIF


/*
===============================================================================================================================
Programa----------: MEST92Plan()
Autor-------------: Alex Wallauer
Data da Criacao---: 20/06/2018
Descricao---------: Retorna o LayOut da Planilha 2 "02-Custo / Estoque - MP          "
Parametros--------: _azeNew
Retorno-----------: _axml 
===============================================================================================================================
*/
Static Function MEST92Plan(_aZeNew)
LOCAL _AXML   := {}

*******************************************************  /*Definições*/  ***************************************************************
	
_AXML:=MEST9CabNovo(_AXML)

*****************************************************  /*CUSTO MP PASTA 1*/  ***********************************************************

_AXML:=  MEST9PCustoMP(_AXML,_aZeNew)//Rodas os codigos "000005"

****************************************************  /*ESTOQUE MP PASTA 2*/  **********************************************************

_AXML:=MEST9PEstoqueMP(_AXML,_aZeNew)//Rodas os codigos "000004" 


RETURN _AXML
/*
===============================================================================================================================
Programa----------: MEST93Plan()
Autor-------------: Alex Wallauer
Data da Criacao---: 05/07/2018
Descricao---------: Retorna o LayOut da Planilha 3  "03-Demonstrativo do Estoque Final"
Parametros--------: _azeNew
Retorno-----------: _axml 
===============================================================================================================================
*/
Static Function MEST93Plan(_aZeNew)
LOCAL _AXML      := {}
LOCAL _aProdutos := {}
LOCAL _aTotais   := {0,0} , _ni , P
LOCAL _cArq01    := "\data\italac\mest009\MEST009_PLAN_03.txt"

*******************************************************  /*Definições*/  ***************************************************************
If FT_FUSE(_cArq01) == -1
	
	U_ITMSG("Não foi possível abrir o arquivo: "+_cArq01 , "Arquivo inválido" , "Favor verificar se o arquivo existe.",1)
	Return _AXML
	
EndIf

FT_FGOTOP()//PONTO NO TOPO

If FT_FLASTREC() == 0
	
	U_ITMSG("O arquivo "+_cArq01+" não possui dados.","Arquivo inválido","Favor verificar se o arquivo esta vazio.",1)
	Return _AXML
	
EndIf

DO WHILE !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
	_cLinha:=FT_FREADLN()
	IF !EMPTY(_cLinha)
		AADD(_AXML,ALLTRIM(_cLinha))
	ENDIF
	FT_FSKIP()   //próximo registro no arquivo txt
	
EndDo

FT_FUSE()//Fecha o arquivo

*****************************************************  /*PASTA*/  ***********************************************************

/*		aadd(_azeNew,{	xfilial("ZE0"),;															//01       *
					ALLTRIM(ZL6T->ZL6_TPCUS),;														//02
					ALLTRIM(ZL6T->ZL6_DTPCUS),;														//03
					ALLTRIM(ZL6T->ZL6_CODEVE),;														//04	 *
					ALLTRIM(ZL6T->ZL6_DESEVE),;			 											//05  DESCRICAO  DO GRUPO
					ALLTRIM(ZL6T->ZL6_SUBEVE),;														//06
					UPPER(ALLTRIM(ZL6T->ZL6_DSUBEV)),;												//07  DESCRICAO  OD SUB GRUPO  ****
					ALLTRIM(ZL6T->ZL6_GRPCUS),;														//08  CODIGO DE CONTROLE
					ALLTRIM(ZL6T->ZL6_DGRCUS),;														//09
					_nQtdSin,;																		//10  QUANTIDADES 
					_nVlrSin,;																		//11  VALOR
					(substr(dtos(MV_PAR05),5,2) +  substr(dtos(MV_PAR05),1,4)),;					//12
					ALLTRIM(ZL6T->ZL6_REGRA),;														//13
					_cordem,;																		//14
					ALLTRIM(ZL6T->ZL6_CODPRO),;														//15  CODIGO ITEM
					ZL6T->ZL6_TCUSTO,;																//16		
					ZL6T->ZL6_TUNID ,; 																//17  SEG Unidade ?
					ZL6T->ZL6_GRPPRO,;                                                              //18  GRUPOS  *
					ZL6T->ZL6_CENTRO,; 																//19				
					ZL6T->ZL6_OBSERV,; 																//20  TIPOS 
					_lTemEstoquenaDT,; 																//21  TEM ESTOQUE NA DATA ?
					ZL6T->ZL6_FILIS ,; 																//22  OUTRAS FILIAIS
					_aProdutos      ,; 																//23
					ALLTRIM(ZL6T->ZL6_MOBSER),;														//24
					ZL6T->ZL6_CLIENTE})																//25

	   AADD(_aProdutos,{ (cAliasSB2)->B2_COD   ,;//01
	                     aSaldo[2]             ,;//02
	                     _nQtdeItem            ,;//03
	                     (cAliasSB2)->B2_LOCAL ,;//04
	                     (cAliasSB2)->TIPO     ,;//05
	                     (cAliasSB2)->(SUBSTR(B2_COD,1,4)),;//06 - Grupo
	                     _cOrdem                          })//07 - ORDENACAO

  					*/

SB1->(DbSetOrder(1))
FOR _ni := 1 to len(_azeNew)//Rodas os codigos '000006' 

  	IF _azeNew[_ni][02] <> '000006'//ALLTRIM(ZL6T->ZL6_TPCUS)
  	   LOOP
  	ENDIF

	IF _azeNew[_ni][08] = '000001' //////////////////////////////////////// PRODUTOS /////////////////////////////////////////////

          _aItens:=_azeNew[_ni][23]//_aProdutos DA FUNCAO  MEST9EstoqueFinal()
          _cGrupoIni:=""
          _nQtdGrupo:=0
          _nTotGrupo:=0
          
          FOR P := 1 TO LEN(_aItens)

              IF EMPTY(_cGrupoIni) .AND. !_aItens[P][5] $ 'EM,IN'
                 _cGrupoIni:=_aItens[P][6]
                 AADD(_aProdutos,{"","",0,0,0,0})//PULA LINHA
              ENDIF  

			  If !_aItens[P][5] $ 'EM,IN'
				 IF _cGrupoIni <> _aItens[P][6]
					If MV_PAR08 = 2 //Analitico
						_cDescri:="TOTAL Grupo "+_cGrupoIni+" - "+Posicione("SBM",1,XFILIAL("SBM")+_cGrupoIni,"BM_DESC")+_aItens[P][8]
					ELSE
						_cDescri:=_cGrupoIni+" - "+Posicione("SBM",1,XFILIAL("SBM")+_cGrupoIni,"BM_DESC")+_aItens[P][8]
					ENDIF
					_cInidade:="DIV"//Especie ,Descricao, Valor Unitario        ,Quantidade,Valor Total
					AADD(_aProdutos,{_cInidade,_cDescri ,(_nTotGrupo/_nQtdGrupo),_nQtdGrupo,_nTotGrupo,'' })
					If MV_PAR08 = 2 //Analitico
                       AADD(_aProdutos,{"","",0,0,0,0})//PULA LINHA
                    ENDIF   
                    //Reinicia
					_cGrupoIni:=_aItens[P][6]
					_nQtdGrupo:=0
					_nTotGrupo:=0

				 ENDIF
				 _nQtdGrupo+=_aItens[P][3]//Quantidade do Grupo
				 _nTotGrupo+=_aItens[P][2]//Valor do Grupo
			  ENDIF
              
              If MV_PAR08 = 2 .OR. _aItens[P][5] $ 'EM,IN'   //Analitico OU tipos 'EM','IN'

                 SB1->(DBSeek(xFilial("SB1")+_aItens[P][1])) 
                 IF  _aItens[P][5] $ 'EM,IN'
                     _cDescri:="["+ALLTRIM(_aItens[P][1])+"-"+_aItens[P][4]+"-"+SB1->B1_TIPO+"]-"+SB1->B1_DESC+_aItens[P][8]
                 ELSE
//                  IF _aItens[P][1] <= "06000002000" 
                       _cDescri:="Item Grupo "+RTRIM(SB1->B1_GRUPO)+"-["+ALLTRIM(_aItens[P][1])+"-"+_aItens[P][4]+"-"+SB1->B1_TIPO+"]-"+SB1->B1_DESC+_aItens[P][8]
//                  ELSE 
//                     _cDescri:="Item Grupo "+RTRIM(SB1->B1_GRUPO)+"-["+ALLTRIM(_aItens[P][1])+"-"+_aItens[P][4]+"-"+SB1->B1_TIPO+"]-"+"TESTE ITEM"+_aItens[P][8]
//                  ENDIF 
                 ENDIF    
                 IF _azeNew[_ni][17] = "S"
                    _cInidade:=SB1->B1_SEGUM
                 ELSE
                    _cInidade:=SB1->B1_UM
                 ENDIF           // Especie,Descricao, Valor Unitario              ,Quantidade   ,Valor Total
                 AADD(_aProdutos,{_cInidade,_cDescri ,(_aItens[P][2]/_aItens[P][3]),_aItens[P][3],_aItens[P][2],_aItens[P][7]})//DADOS DO PRODUTO
              ENDIF              //    01      02                03                      04            05          06  

              _aTotais[1]+=_aItens[P][3]//Quantidade Total
              _aTotais[2]+=_aItens[P][2]//Valor Total

              IF P = LEN(_aItens)//ULTIMO TOTAL
				 If MV_PAR08 = 2 //Analitico
					_cDescri:="TOTAL Grupo "+_cGrupoIni+" - "+Posicione("SBM",1,XFILIAL("SBM")+_cGrupoIni,"BM_DESC")+_aItens[P][8]
				 ELSE
					_cDescri:=_cGrupoIni+" - "+Posicione("SBM",1,XFILIAL("SBM")+_cGrupoIni,"BM_DESC")+_aItens[P][8]
				 ENDIF
				 _cInidade:="DIV"//Especie,Descricao, Valor Unitario        ,Quantidade,Valor Total
				 AADD(_aProdutos,{_cInidade,_cDescri ,(_nTotGrupo/_nQtdGrupo),_nQtdGrupo,_nTotGrupo ,'' })//DADOS DO GRUPO
              ENDIF

          NEXT

	ENDIF
	
NEXT

AADD( _AXML,' <Worksheet ss:Name="ESTOQUE FINAL">')
AADD( _AXML,'  <Table ss:ExpandedColumnCount="999999" ss:ExpandedRowCount="999999" x:FullColumns="1"')
AADD( _AXML,'   x:FullRows="1" ss:DefaultRowHeight="15">')
AADD( _AXML,'   <Column ss:Index="2" ss:AutoFitWidth="0" ss:Width="288"/>')
AADD( _AXML,'   <Column ss:AutoFitWidth="0" ss:Width="85.5"/>')
AADD( _AXML,'   <Column ss:AutoFitWidth="0" ss:Width="111.75"/>')
AADD( _AXML,'   <Column ss:AutoFitWidth="0" ss:Width="166.5"/> ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="s64"><Data ss:Type="String">        DEMONSTRATIVO DO ESTOQUE FINAL - UND. ' + FWFilialName( cEmpAnt , Xfilial("ZL6") , 2 )  + '</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s66"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="s64"><Data ss:Type="String">Ultimo dia do Mes</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s64"><Data ss:Type="String">' + MESEXTENSO(MONTH(MV_PAR05)) + '/' + ALLTRIM(STR(YEAR(MV_PAR05))) + '</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s68"/>')
AADD( _AXML,'    <Cell ss:StyleID="s68"/>')
AADD( _AXML,'    <Cell ss:StyleID="s70"/>')
AADD( _AXML,'    <Cell ss:StyleID="s68"/>')
AADD( _AXML,'    <Cell ss:StyleID="s68"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">Especie</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">Discriminacao</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s72"><Data ss:Type="String">Valor Unitario</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">Quantidade</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">Valor Total</Data></Cell>')
AADD( _AXML,'   </Row>')

FOR _ni := 1 to len(_aProdutos)

    IF EMPTY(_aProdutos[_ni,1])//Pula LINHA
       AADD( _AXML,'<Row> ')
       AADD( _AXML,'</Row>')
       LOOP
    ENDIF

    _aProdutos[_ni,2]:=STRTRAN(ALLTRIM(_aProdutos[_ni,2]),"<","")
    _aProdutos[_ni,2]:=STRTRAN(_aProdutos[_ni,2],">","")

    AADD( _AXML,'    <Row> ')
    AADD( _AXML,'    <Cell ss:StyleID="s73"><Data ss:Type="String">' + ALLTRIM(_aProdutos[_ni,1])  + '</Data></Cell>')
    AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="String">' + ALLTRIM(_aProdutos[_ni,2])  + '</Data></Cell>')
    IF "TOTAL " == LEFT(_aProdutos[_ni,2],6) .AND. MV_PAR08 = 2 
       AADD( _AXML,'    <Cell ss:StyleID="s87"><Data ss:Type="Number">' + ALLTRIM(STR( _aProdutos[_ni,3])) + '</Data></Cell>')
       AADD( _AXML,'    <Cell ss:StyleID="s92"><Data ss:Type="Number">' + ALLTRIM(STR( _aProdutos[_ni,4])) + '</Data></Cell>')
       AADD( _AXML,'    <Cell ss:StyleID="s87"><Data ss:Type="Number">' + ALLTRIM(STR( _aProdutos[_ni,5])) + '</Data></Cell>')
       AADD( _AXML,'    </Row>')
    ELSE
       AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">' + ALLTRIM(STR( _aProdutos[_ni,3])) + '</Data></Cell>')
       AADD( _AXML,'    <Cell ss:StyleID="s91"><Data ss:Type="Number">' + ALLTRIM(STR( _aProdutos[_ni,4])) + '</Data></Cell>')
       AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">' + ALLTRIM(STR( _aProdutos[_ni,5])) + '</Data></Cell>')
       AADD( _AXML,'    </Row>')
    ENDIF

NEXT
  
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:MergeAcross="2" ss:StyleID="m766764296"><Data ss:Type="String">TOTAL GERAL</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s92"><Data ss:Type="Number">' + ALLTRIM(STR( _aTotais[1])) + '</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"><Data ss:Type="Number">' + ALLTRIM(STR( _aTotais[2])) + '</Data></Cell>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'  </Table>')
AADD( _AXML,'  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">')
AADD( _AXML,'   <PageSetup>')
AADD( _AXML,'    <Header x:Margin="0.31496062000000002"/>')
AADD( _AXML,'    <Footer x:Margin="0.31496062000000002"/>')
AADD( _AXML,'    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"')
AADD( _AXML,'     x:Right="0.511811024" x:Top="0.78740157499999996"/>')
AADD( _AXML,'   </PageSetup>')
AADD( _AXML,'   <Unsynced/>')
AADD( _AXML,'   <Selected/>')
AADD( _AXML,'   <Panes>')
AADD( _AXML,'    <Pane>')
AADD( _AXML,'     <Number>3</Number>')
AADD( _AXML,'     <RangeSelection>R1C1:R1C4</RangeSelection>')
AADD( _AXML,'    </Pane>')
AADD( _AXML,'   </Panes>')
AADD( _AXML,'   <ProtectObjects>False</ProtectObjects>')
AADD( _AXML,'   <ProtectScenarios>False</ProtectScenarios>')
AADD( _AXML,'  </WorksheetOptions>')
AADD( _AXML,' </Worksheet>')
AADD( _AXML,'</Workbook>')

RETURN _AXML
/*

/*
===============================================================================================================================
Programa----------: MEST9CabNovo()
Autor-------------: Alex Wallauer
Data da Criacao---: 20/06/2018
Descricao---------: Monta cabecalho do excel
Parametros--------: _AXML
Retorno-----------: _AXML
===============================================================================================================================*/
Static Function MEST9CabNovo(_AXML)

LOCAL _cArq01:= "\data\italac\mest009\MEST009_PLAN_02.txt"
	
If FT_FUSE(_cArq01) == -1
	
	U_ITMSG("Não foi possível abrir o arquivo: "+_cArq01,"Arquivo inválido","Favor verificar se o arquivo se esta correto.",1)
	Return _AXML
	
EndIf

FT_FGOTOP()//PONTO NO TOPO

If FT_FLASTREC() == 0
	
	U_ITMSG("O arquivo "+_cArq01+" não possui dados.","Arquivo inválido","Favor verificar se o arquivo se esta correto.",1)
	Return _AXML
	
EndIf

DO WHILE !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
	_cLinha:=FT_FREADLN()
	IF !EMPTY(_cLinha)
		AADD(_AXML,ALLTRIM(_cLinha))
	ENDIF
	FT_FSKIP()   //próximo registro no arquivo txt
	
EndDo

FT_FUSE()//Fecha o arquivo

RETURN _AXML 

/*
===============================================================================================================================
Programa----------: MEST9PCustoMP()
Autor-------------: Alex Wallauer
Data da Criacao---: 20/06/2018
Descricao---------: Monta Pasta Materia prima do excel
Parametros--------: _AXML,_aZeNew,lSoPegaVlrs,_oSelf
Retorno-----------: _AXML
===============================================================================================================================
*/
Static Function MEST9PCustoMP(_AXML,_aZeNew,lSoPegaVlrs,_oSelf)
LOCAL _ni
LOCAL _aCustOpera:={}
LOCAL _aLeiteProp:={}
LOCAL _aLeiteTerc:={}
LOCAL _aResumoGer:={}
LOCAL _aSoroLeite:={}
LOCAL _aSoroConce:={}
LOCAL _aSoroPreCo:={}
LOCAL _aCremeLeit:={}
DEFAULT lSoPegaVlrs := .F.

*****************************************************  /*PASTA*/  ***********************************************************
/*	    AADD(_aCusto04,{"CUSTO OPERACIONAL                 ",00,0,0})//01
		AADD(_aCusto04,{"CUSTO OPERACIONAL FILIAIS         ",00,0,0})//02
		AADD(_aCusto04,{"CUSTO LEITE IN-NATURA + FRETE     ",00,0,0})//03
		AADD(_aCusto04,{"CUSTO SORO DE LEITE + FRETE       ",00,0,0})//04
		AADD(_aCusto04,{"CUSTO SORO CONCENTRADO + FRETE    ",00,0,0})//05    
		AADD(_aCusto04,{"CUSTO CREME DE LEITE + FRETE      ",00,0,0})//06     
	    AADD(_aCusto04,{"CUSTO SORO PRE-CONCENTRADO + FRETE",00,0,0})//07

		_aCusto04[1,2]:=_ntotlei
		_aCusto04[1,3]:=_ntotger
		_aCusto04[1,4]:=_ntotger / _ntotlei					*/
/*
		aadd(_azeNew,{	xfilial("ZE0"),;															//01*
					ALLTRIM(ZL6T->ZL6_TPCUS),;														//02 *
					ALLTRIM(ZL6T->ZL6_DTPCUS),;														//03
					ALLTRIM(ZL6T->ZL6_CODEVE),;														//04	*
					ALLTRIM(ZL6T->ZL6_DESEVE),;			 											//05
					ALLTRIM(ZL6T->ZL6_SUBEVE),;														//06      *
					UPPER(ALLTRIM(ZL6T->ZL6_DSUBEV)),;												//07  DESCRICAO
					ALLTRIM(ZL6T->ZL6_GRPCUS),;														//08   *
					ALLTRIM(ZL6T->ZL6_DGRCUS),;														//09
					_nQtdSin,;																		//10 - QTDE INICIAL
					_nVlrSin,;																		//11 - VALOR
					(substr(dtos(MV_PAR05),5,2) +  substr(dtos(MV_PAR05),1,4)),;					//12
					ALLTRIM(ZL6T->ZL6_REGRA),;														//13
					_cordem,;																		//14  *
					ALLTRIM(ZL6T->ZL6_CODPRO),;														//15 CODIGO DE PRODUTOS
					ZL6T->ZL6_TCUSTO,;																//16		
					ZL6T->ZL6_TUNID ,; 																//17
					ALLTRIM(ZL6T->ZL6_GRPPRO),;                                                     //18 GRUPOS
					ZL6T->ZL6_CENTRO,; 																//19				
					ZL6T->ZL6_OBSERV,; 																//20  
					_lTemEstoquenaDT,; 																//21 
					ZL6T->ZL6_FILIS ,; 																//22
					_aProdutos      ,; 																//23
					ALLTRIM(ZL6T->ZL6_MOBSER),;														//24
					ZL6T->ZL6_CLIENTE})																//25
					*/
//
_aCustoMP:={}//MEST9PCustoMP(,.T.)         2-Custo,3-Custo F,4-Frete,5-Qtde,6-Frete 2,7-Custo Materia Gorda
AADD(_aCustoMP,{"LEITE IN NATURA"         ,0      ,0        ,0      ,0     ,0        ,0                    })//01
AADD(_aCustoMP,{"SORO DE LEITE"           ,0      ,0        ,0      ,0                                     })//02
AADD(_aCustoMP,{"SORO CONCENTRADO"        ,0      ,0        ,0      ,0                                     })//03    
AADD(_aCustoMP,{"CREME DE LEITE TERCEIROS",0      ,0        ,0      ,0                                     })//04     
AADD(_aCustoMP,{"DIFERENCA ESTOQUE MP"    ,0      ,0        ,0      ,0                                     })//05
AADD(_aCustoMP,{"SORO PRE-CONCENTRADO"    ,0      ,0        ,0      ,0                                     })//06

IF lSoPegaVlrs//SÓ PARA NÃO DAR ERRO
	AADD(_aCusto04,{"CUSTO OPERACIONAL                 ",0,0,0})//01
	AADD(_aCusto04,{"CUSTO OPERACIONAL FILIAIS         ",0,0,0})//02
	AADD(_aCusto04,{"CUSTO LEITE IN-NATURA + FRETE     ",0,0,0})//03
	AADD(_aCusto04,{"CUSTO SORO DE LEITE + FRETE       ",0,0,0})//04
	AADD(_aCusto04,{"CUSTO SORO CONCENTRADO + FRETE    ",0,0,0})//05
	AADD(_aCusto04,{"CUSTO CREME DE LEITE + FRETE      ",0,0,0})//06
	AADD(_aCusto04,{"CUSTO SORO PRE-CONCENTRADO + FRETE",0,0,0})//07
ENDIF

IF VALTYPE(_oSelf) = "O"
   _oRegua:=_oSelf
ENDIF
IF VALTYPE(_oRegua) = "O"
   _oRegua:SetRegua2( 15 )
   _oRegua:IncRegua2("CMP-Lendo custo leite operacional ...")
	ProcessMessages()
ENDIF
ZLT->(DBSEEK(xFilial()+cFilant))
_cSetor   :=ALLTRIM(ZLT->ZLT_SETOR)
IF RIGHT(_cSetor,1) = ";"
   _cSetor:=LEFT(_cSetor, LEN(_cSetor)-1 )
ENDIF

IF (nPos  :=ASCAN(_aZeNew,{|Z| Z[2] == '000005'} ) ) <> 0
   _cFils :=ALLTRIM(_aZeNew[nPos,22])//ZL6T->ZL6_FILIS 
   _aSetor :=STRTOKARR(_cSetor,';')
   _cSetor:=""
   FOR _ni := 1 TO LEN(_aSetor)
       IF !LEFT(_aSetor[_ni],2) $ _cFils
          _cSetor+=_aSetor[_ni]+";"
       ENDIF   
   NEXT              
   IF RIGHT(_cSetor,1) = ";"
      _cSetor:=LEFT(_cSetor, LEN(_cSetor)-1 )
   ENDIF
ENDIF
   
_nVolLeite:=VolLeite(_cSetor)
_nTotValor:=0
IF (nPos:=ASCAN(_aCusto04,{|C| ALLTRIM(C[1]) == "CUSTO OPERACIONAL FILIAIS"} )) <> 0
   _nTotValor:=_aCusto04[nPos,3]
ENDIF   

AADD(_aCustOpera,{"CUSTO OPERACIONAL",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//01 - é regravado no CUSTO POSTO/FABRICA - LEITE PROPRIO

////////////////////////////  LEITE PROPRIO ////////////////////////////////////////////////////////////////////////////////////
IF VALTYPE(_oRegua) = "O"
   _oRegua:IncRegua2("CMP-Lendo custo leite proprio MIX ...")
	ProcessMessages()
ENDIF
_nTotValor:=GetVlrMix(_cSetor)   

_nVlrSoma :=MEST9ICMS("FUNDOLEITE",,cFilant)// = FUNDOPEM
_nTotValor+=_nVlrSoma

_nIT_TXFUNDE:=U_ITGetMV("IT_TXFUNDES",0)// = FUNDESA
_nVlrSoma :=(_nIT_TXFUNDE*_nVolLeite)
_nTotValor+=_nVlrSoma

AADD(_aLeiteProp,{"CUSTO LEITE PROPRIO - MIX",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite) })//01  - OK
//
AADD(_aLeiteProp,{"CUSTO FRETE 1o. PERCURSO",0,0,0 })//02 PREENCHE ABAIXO
//
IF VALTYPE(_oRegua) = "O"
   _oRegua:IncRegua2("CMP-Lendo custo frete 2o. percurso s/ ICMS ...")
	ProcessMessages()
ENDIF
_aSetor:=STRTOKARR(_cSetor,';')
_cFilis:=""
FOR _ni := 1 TO LEN(_aSetor)
    IF !LEFT( _aSetor[_ni],2 ) $ _cFilis
       _cFilis+=LEFT( _aSetor[_ni],2 )+";"//Paga as filiais dos setores
    ENDIF   
NEXT              
_cFilis   := LEFT(_cFilis,LEN(_cFilis)-1)
_aTotias  := CusFret2P(_cFilis,"F;P","001")
_nVolLeite:= _aTotias[1]
_nTotValor:= _aTotias[2]
AADD(_aLeiteProp,{"CUSTO FRETE 2o. PERCURSO (SEM ICMS)",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite) })//03 - OK

//                                           2-Custo,3-Custo F,4-Frete,5-Qtde,6-Frete 2
//AADD(_aCustoMP,{"LEITE IN NATURA"         ,0      ,0        ,0      ,0     ,0        })//01
_aCustoMP[1,4]:=_nTotValor//Valor do Frete do Leite IN NATURA

_aLeiteProp[2,2]:=( _aLeiteProp[1,2]-_nVolLeite )//"CUSTO FRETE 1o. PERCURSO" - só preenche a qtde

_nTotValor:=_nVolLeite:=0
IF (nPos  :=ASCAN(_aZeNew,{|Z| Z[2] == '000005'} ) ) <> 0

   _cFils :=ALLTRIM(_aZeNew[nPos,22])//ZL6T->ZL6_FILIS 
   _aFils :=STRTOKARR(_cFils,';')
   _cSetor:=""
   FOR _ni := 1 TO LEN(_aFils)
       IF ZLT->(DBSEEK(xFilial()+_aFils[_ni]))
          _cSetor+=ALLTRIM(ZLT->ZLT_SETOR)//Pega os setores das filiais
          IF RIGHT(_cSetor,1) <> ";"
             _cSetor+=";"
          ENDIF
       ENDIF   
   NEXT              
   _cSetor:=LEFT(_cSetor, LEN(_cSetor)-1 )

   _nVolLeite:=VolLeite(_cSetor) //VOLUME
   _nTotValor:=GetVlrMix(_cSetor)//VALOR

   //Percentual da Filial  //_cFilis,_cClientes      ,_cProds         ,_cCusto
   _nPerc:=MEST9BuscaZE0(_cFils ,_aZeNew[nPos,25],_aZeNew[nPos,15],'000005')

   _nVlrSoma :=MEST9ICMS("FUNDOLEITE",,_cFils)// = FUNDOPEM
   _nTotValor+=_nVlrSoma
   
   _nVolLeite:=_nVolLeite*_nPerc
   _nTotValor:=_nTotValor*_nPerc   

ENDIF

_nIT_TXFUNDE:=U_ITGetMV("IT_TXFUNDES",0)// = FUNDESA
_nVlrSoma :=(_nIT_TXFUNDE*_nVolLeite)
_nTotValor+=_nVlrSoma

AADD(_aLeiteProp,{"CUSTO LEITE POSTOS - MIX",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite) })//04  - OK

//
_nVolLeite:= _aLeiteProp[1,2]+_aLeiteProp[4,2] //+_aLeiteProp[2,2]+_aLeiteProp[3,2]
_nTotValor:= _aLeiteProp[1,3]+_aLeiteProp[2,3]+_aLeiteProp[3,3]+_aLeiteProp[4,3]
AADD(_aLeiteProp,{"CUSTO POSTO/FABRICA - LEITE PROPRIO",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite) })//05 - OK 
//REGRA CUSTO OPERACIONAL
_aCustOpera[1,2]:=_aLeiteProp[5,2]                    // VOLME DO CUSTO OPERACIONAL
_aCustOpera[1,4]:=_aCustOpera[1,3] / _aLeiteProp[5,2] // CUSTO / L DO CUSTO OPERACIONAL
//REGRA CUSTO OPERACIONAL
////////////////////////////  LEITE TERCEIROS ////////////////////////////////////////////////////////////////////////////////////
IF VALTYPE(_oRegua) = "O"
   _oRegua:IncRegua2("CMP-Lendo custo leite terceiros c/ MG e ICMS ...")
   ProcessMessages()
ENDIF
_aTotias  := CusComICMS(_cFilis,"001")
_nVolLeite:= _aTotias[1]
_nTotValor:= _aTotias[2]
AADD(_aLeiteTerc,{"CUSTO LEITE TERCEIROS (COM MG E COM ICMS)",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite) })//01 - OK
//
IF VALTYPE(_oRegua) = "O"
   _oRegua:IncRegua2("CMP-Lendo custo excedente materia gorda ...")
   ProcessMessages()
ENDIF
_aTMGICMS := CusMGCMS(_cFilis)
_nVolLeite:= _aTMGICMS[1,1]
_nTotValor:= _aTMGICMS[1,2]*(-1)
AADD(_aLeiteTerc,{"CUSTO EXCEDENTE MATERIA GORDA  ( - )",0,_nTotValor,(_nTotValor/_nVolLeite) })//02 - OK

//                                           2-Custo,3-Custo F,4-Frete,5-Qtde,6-Frete 2,7-Custo Materia Gorda
//AADD(_aCustoMP,{"LEITE IN NATURA"         ,0      ,0        ,0      ,0     ,0        ,0                    })//01
_aCustoMP[1,7]:=_aTMGICMS[1,2]//Valor do CUSTO EXCEDENTE MATERIA GORDA

//
_nVolLeite:= _aLeiteTerc[01,2]//Para dividir
_nTotValor:= _aTMGICMS[1,3]*(-1)//"001"
AADD(_aLeiteTerc,{"APROVEITAMENTO CREDITO ICMS ( - ) (obs.: Desconsiderado transf. entre filiais)",0,_nTotValor,(_nTotValor/_nVolLeite) })//03 - OK
//
_nVolLeite:= _aLeiteTerc[01,2]//+_aLeiteTerc[2,2]+_aLeiteTerc[3,2]
_nTotValor:= _aLeiteTerc[01,3]+_aLeiteTerc[02,3]+_aLeiteTerc[03,3]
AADD(_aLeiteTerc,{"CUSTO LEITE TERCEIROS (SEM MG E  SEM ICMS)",0,_nTotValor,(_nTotValor/_nVolLeite) })//04 - OK
//
_nVolLeite:= 0//Elker/Naum e Flavio analisarao o relatorio ->Naum definira data
_nTotValor:= 0//Elker/Naum e Flavio analisarao o relatorio ->Naum definira data
AADD(_aLeiteTerc,{"LEITE DIRETO P/ FABRICA SEM CUSTO DE FRETE",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite) })//05
//
IF VALTYPE(_oRegua) = "O"
   _oRegua:IncRegua2("CMP-Lendo custo frete 2o. percurso s/ ICMS ...")
	ProcessMessages()
ENDIF
_aTotias  := CusFret2P(_cFilis,"T","001")
_nVolLeite:= _aTotias[1]
_nTotValor:= _aTotias[2]
AADD(_aLeiteTerc,{"CUSTO FRETE 2o. PERCURSO (SEM ICMS)",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite) })//06 - OK

//                                           2-Custo,3-Custo F,4-Frete,5-Qtde,6-Frete 2
//AADD(_aCustoMP,{"LEITE IN NATURA"         ,0      ,0        ,0      ,0     ,0        })//01
_aCustoMP[1,6]:=_nTotValor//Valor do Frete do Leite TERCEIROS

IF _aLeiteTerc[5,2] = 0
   _aLeiteTerc[5,2]:=_aLeiteTerc[1,2]-_nVolLeite//"LEITE DIRETO P/ FABRICA SEM CUSTO DE FRETE" POR ENQUANTO
ENDIF   
//
_nVolLeite:=_aLeiteTerc[5,2]+_aLeiteTerc[6,2]
_nTotValor:=_aLeiteTerc[4,3]+_aLeiteTerc[5,3]+_aLeiteTerc[6,3]
AADD(_aLeiteTerc,{"CUSTO EFETIVO LEITE TERCEIROS + FRETE (S / MG E S/ ICMS)",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite) })//07 - OK

////////////////////////////  RESUMO GERAL - CUSTO LEITE ////////////////////////////////////////////////////////////////////////////////////
_nVolLeite:= _aLeiteProp[1,2]+_aLeiteProp[4,2]
_nTotValor:= _aLeiteProp[1,3]+_aLeiteProp[2,3]+_aLeiteProp[3,3]+_aLeiteProp[4,3]
AADD(_aResumoGer,{"CUSTO LEITE - PROPRIO",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite) })//01 - OK

_nVolLeite:= _aLeiteTerc[4,2]+_aLeiteTerc[5,2]+_aLeiteTerc[6,2]
_nTotValor:= _aLeiteTerc[4,3]+_aLeiteTerc[5,3]+_aLeiteTerc[6,3]
AADD(_aResumoGer,{"CUSTO LEITE - TERCEIROS",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite) })//02 - OK

_nVolLeite+= _aLeiteProp[1,2]+_aLeiteProp[4,2] //"CUSTO LEITE - TERCEIROS += CUSTO LEITE - PROPRIO
_nTotValor+= _aLeiteProp[1,3]+_aLeiteProp[2,3]+_aLeiteProp[3,3]+_aLeiteProp[4,3]//"CUSTO LEITE - TERCEIROS += CUSTO LEITE - PROPRIO
AADD(_aResumoGer,{"CUSTO (FIFO) LEITE IN-NATURA - TOTAL",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite) })//03 - OK

_aCusto04[3,2]:=_nVolLeite
_aCusto04[3,3]:=_nTotValor
_aCusto04[3,4]:=(_nTotValor/_nVolLeite)

//                                           2-Custo,3-Custo F,4-Frete,5-Qtde,6-Frete 2
//AADD(_aCustoMP,{"LEITE IN NATURA"         ,0      ,0        ,0      ,0     ,0        })//01
_aCustoMP[1,2]:=(_nTotValor/_nVolLeite)//"CUSTO MP LEITE IN-NATURA"
_aCustoMP[1,3]:=((_aCustoMP[1,4]+_aCustoMP[1,6])/_nVolLeite)//Custo dos Fretes por Qtde total dos leites
_aCustoMP[1,5]:=_nVolLeite//Qtde total dos leites

_nVolLeite:= _aLeiteTerc[2,2]
_nTotValor:= _aLeiteTerc[2,3]
AADD(_aResumoGer,{"CUSTO EXC. MATERIA GORDA A TRANSPORTAR P/ CREME DE LEITE UHT",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//04 - OK

////////////////////////////  SORO DE LEITE ////////////////////////////////////////////////////////////////////////////////////
IF VALTYPE(_oRegua) = "O"
   _oRegua:IncRegua2("CMP-Lendo custo soro c/ ICMS ...")
	ProcessMessages()
ENDIF
_aTotias  := CusComICMS(_cFilis,"002")
_nVolLeite:= _aTotias[1]
_nTotValor:= _aTotias[2]
AADD(_aSoroLeite,{"CUSTO SORO C/ ICMS"                  ,_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//01 - OK

_nTotValor:= _aTMGICMS[2,3]*(-1)//"002"
AADD(_aSoroLeite,{"APROVEITAMENTO CREDITO ICMS ( - )"   ,0,_nTotValor,(_nTotValor/_nVolLeite)})//02 - OK

_nTotValor:= _aSoroLeite[1,3]+_aSoroLeite[2,3]
AADD(_aSoroLeite,{"CUSTO SORO S/ ICMS"                  ,_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//03 - OK

IF VALTYPE(_oRegua) = "O"
   _oRegua:IncRegua2("CMP-Lendo custo frete 2o. percurso s/ ICMS ...")
	ProcessMessages()
ENDIF
_aTotias  := CusFret2P(_cFilis,"F;P;T","002")
//_nVolLeite:= _aTotias[1]
_nTotValor:= _aTotias[2]
AADD(_aSoroLeite,{"CUSTO FRETE 2o. PERCURSO (S/ ICMS)"  ,_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//04 - OK
//                                2-Custo,3-Custo F,4-Frete,5-Qtde,6-Frete 2
//AADD(_aCustoMP,{"SORO DE LEITE",0      ,0        ,0      ,0     ,0        })//01
_aCustoMP[2,3]:=(_nTotValor/_nVolLeite)//"SORO DE LEITE custo do frete"
_aCustoMP[2,4]:=_nTotValor//"SORO DE LEITE frete"
_aCustoMP[2,5]:=_nVolLeite//"SORO DE LEITE qtde"

_nVolLeite:= _aSoroLeite[1,2]//+_aSoroLeite[2,2]+_aSoroLeite[3,2]+_aSoroLeite[4,2]
_nTotValor:= _aSoroLeite[3,3]+_aSoroLeite[4,3]
AADD(_aSoroLeite,{"CUSTO (FIFO) EFETIVO - SORO DE LEITE",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//05  - OK

//                                2-Custo,3-Custo F,4-Frete,5-Qtde,6-Frete 2
//AADD(_aCustoMP,{"SORO DE LEITE",0      ,0        ,0      ,0     ,0        })//01
_aCustoMP[2,2]:=(_nTotValor/_nVolLeite)//"SORO DE LEITE"

_aCusto04[4,2]:=_nVolLeite
_aCusto04[4,3]:=_nTotValor
_aCusto04[4,4]:=(_nTotValor/_nVolLeite)


////////////////////////////  SORO DE LEITE PRE-CONCENTRADO ////////////////////////////////////////////////////////////////////////////////////
IF VALTYPE(_oRegua) = "O"
   _oRegua:IncRegua2("CMP-Lendo custo soro PRE-CONCENTRADO c/ ICMS ...")
	ProcessMessages()
ENDIF
_aTotias  := CusComICMS(_cFilis,"011")
_nVolLeite:= _aTotias[1]
_nTotValor:= _aTotias[2]
AADD(_aSoroPreCo,{"CUSTO SORO PRE-CONCENTRADO C/ ICMS"                  ,_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//01
//
_nTotValor:= _aTMGICMS[3,3]*(-1)//"003"
AADD(_aSoroPreCo,{"APROVEITAMENTO CREDITO ICMS ( - )"               ,0,_nTotValor,(_nTotValor/_nVolLeite)})//02 - OK
//
_nTotValor:= _aSoroPreCo[1,3]+_aSoroPreCo[2,3]
AADD(_aSoroPreCo,{"CUSTO SORO PRE-CONCENTRADO S/ ICMS"                  ,_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//03 - OK
//
IF VALTYPE(_oRegua) = "O"
   _oRegua:IncRegua2("CMP-Lendo custo frete 2o. percurso s/ ICMS ...")
	ProcessMessages()
ENDIF
_aTotias  := CusFret2P(_cFilis,"F;P;T","011")
_nVolLeite:= _aTotias[1]
_nTotValor:= _aTotias[2]
AADD(_aSoroPreCo,{"CUSTO FRETE 2o. PERCURSO (S/ ICMS)",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//04 - OK
//                                    2-Custo,3-Custo F,4-Frete,5-Qtde,6-Frete 2
//AADD(_aCustoMP,{"SORO PRE-CONCENTRADO"",0      ,0        ,0      ,0     ,0        })//01
_aCustoMP[6,3]:=(_nTotValor/_nVolLeite)//"SORO PRE-CONCENTRADO" custo do frete"
_aCustoMP[6,4]:=_nTotValor//"SORO PRE-CONCENTRADO" frete"
_aCustoMP[6,5]:=_nVolLeite//"SORO PRE-CONCENTRADO" qtde"

_nVolLeite:= _aSoroPreCo[1,2]//+_aSoroPreCo[2,2]+_aSoroPreCo[3,2]+_aSoroPreCo[4,2]
_nTotValor:= _aSoroPreCo[3,3]+_aSoroPreCo[4,3]
AADD(_aSoroPreCo,{"CUSTO (FIFO) EFETIVO - SORO DE LEITE CONCENTRADO",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//05 - OK
_aCustoMP[6,2]:=(_nTotValor/_nVolLeite)//"SORO CONCENTRADO"

_aCusto04[7,2]:=_nVolLeite
_aCusto04[7,3]:=_nTotValor
_aCusto04[7,4]:=(_nTotValor/_nVolLeite)

////////////////////////////  SORO DE LEITE CONCENTRADO ////////////////////////////////////////////////////////////////////////////////////
IF VALTYPE(_oRegua) = "O"
   _oRegua:IncRegua2("CMP-Lendo custo soro concentrado c/ ICMS ...")
	ProcessMessages()
ENDIF
_aTotias  := CusComICMS(_cFilis,"003")
_nVolLeite:= _aTotias[1]
_nTotValor:= _aTotias[2]
AADD(_aSoroConce,{"CUSTO SORO CONCENTRADO C/ ICMS"                  ,_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//01
//
_nTotValor:= _aTMGICMS[3,3]*(-1)//"003"
AADD(_aSoroConce,{"APROVEITAMENTO CREDITO ICMS ( - )"               ,0,_nTotValor,(_nTotValor/_nVolLeite)})//02 - OK
//
_nTotValor:= _aSoroConce[1,3]+_aSoroConce[2,3]
AADD(_aSoroConce,{"CUSTO SORO CONCENTRADO S/ ICMS"                  ,_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//03 - OK
//
IF VALTYPE(_oRegua) = "O"
   _oRegua:IncRegua2("CMP-Lendo custo frete 2o. percurso s/ ICMS ...")
	ProcessMessages()
ENDIF
_aTotias  := CusFret2P(_cFilis,"F;P;T","003")
_nVolLeite:= _aTotias[1]
_nTotValor:= _aTotias[2]
AADD(_aSoroConce,{"CUSTO FRETE 2o. PERCURSO (S/ ICMS)",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//04 - OK
//                                    2-Custo,3-Custo F,4-Frete,5-Qtde,6-Frete 2
//AADD(_aCustoMP,{"SORO CONCENTRADO"",0      ,0        ,0      ,0     ,0        })//01
_aCustoMP[3,3]:=(_nTotValor/_nVolLeite)//"SORO CONCENTRADO" custo do frete"
_aCustoMP[3,4]:=_nTotValor//"SORO CONCENTRADO" frete"
_aCustoMP[3,5]:=_nVolLeite//"SORO CONCENTRADO" qtde"

_nVolLeite:= _aSoroConce[1,2]//+_aSoroConce[2,2]+_aSoroConce[3,2]+_aSoroConce[4,2]
_nTotValor:= _aSoroConce[3,3]+_aSoroConce[4,3]
AADD(_aSoroConce,{"CUSTO (FIFO) EFETIVO - SORO DE LEITE CONCENTRADO",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//05 - OK
_aCustoMP[3,2]:=(_nTotValor/_nVolLeite)//"SORO CONCENTRADO"

_aCusto04[5,2]:=_nVolLeite
_aCusto04[5,3]:=_nTotValor
_aCusto04[5,4]:=(_nTotValor/_nVolLeite)

////////////////////////////  CREME DE LEITE ////////////////////////////////////////////////////////////////////////////////////
IF VALTYPE(_oRegua) = "O"
   _oRegua:IncRegua2("CMP-Lendo CUSTO CREME C/ ICMS ...")
   ProcessMessages()
ENDIF
_aTotias  := CusComICMS(_cFilis,"004")
_nVolLeite:= _aTotias[1]
_nTotValor:= _aTotias[2]
AADD(_aCremeLeit,{"CUSTO CREME C/ ICMS",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//01 - OK
//
_nTotValor:= _aTMGICMS[4,3]*(-1)//"004"
AADD(_aCremeLeit,{"APROVEITAMENTO CREDITO ICMS ( - ) (obs.: Desconsiderado transf. entre filiais)",0,_nTotValor,(_nTotValor/_nVolLeite)})//02 - OK
//
_nTotValor:= _aCremeLeit[1,3]+_aCremeLeit[2,3]
AADD(_aCremeLeit,{"CUSTO CREME S/ ICMS",0,_nTotValor,(_nTotValor/_nVolLeite)})//03  - OK
//
IF VALTYPE(_oRegua) = "O"
   _oRegua:IncRegua2("CMP-Lendo custo frete 2o. percurso s/ ICMS ...")
	ProcessMessages()
ENDIF
_aTotias  := CusFret2P(_cFilis,"F;P;T","004")
_nVolLeite:= _aTotias[1]
_nTotValor:= _aTotias[2]
AADD(_aCremeLeit,{"CUSTO FRETE 2o. PERCURSO (S/ ICMS)",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//04 - OK
//                                 2-Custo,3-Custo F,4-Frete,5-Qtde,6-Frete 2
//AADD(_aCustoMP,{"CREME DE LEITE",0      ,0        ,0      ,0     ,0        })//01
_aCustoMP[4,3]:=(_nTotValor/_nVolLeite)//"CREME DE LEITE" custo do frete"
_aCustoMP[4,4]:=_nTotValor//"CREME DE LEITE" frete"
_aCustoMP[4,5]:=_nVolLeite//"CREME DE LEITE" qtde"

_nVolLeite:= _aCremeLeit[1,2]//+_aCremeLeit[2,2]+_aCremeLeit[3,2]+_aCremeLeit[4,2]
_nTotValor:= _aCremeLeit[3,3]+_aCremeLeit[4,3]
AADD(_aCremeLeit,{"CUSTO (FIFO) EFETIVO - CREME DE LEITE",_nVolLeite,_nTotValor,(_nTotValor/_nVolLeite)})//05 - OK
_aCustoMP[4,2]:=(_nTotValor/_nVolLeite)//"CREME DE LEITE"

_aCusto04[6,2]:=_nVolLeite
_aCusto04[6,3]:=_nTotValor
_aCusto04[6,4]:=(_nTotValor/_nVolLeite)

IF VALTYPE(_oRegua) = "O"
   _oRegua:SetRegua2( 0 )
   _oRegua:IncRegua2("CMP - LIDO OK")
	ProcessMessages()
ENDIF
IF lSoPegaVlrs
   RETURN _aCustoMP
ENDIF

//////////////////////////////////////////////////////////  CUSTO MP  PASTA 1 ////////////////////////////////////////////////////////////////////////////////////
AADD( _AXML,' <Worksheet ss:Name="CUSTO MP">')
AADD( _AXML,'  <Table ss:ExpandedColumnCount="6" ss:ExpandedRowCount="999999" x:FullColumns="1"')
AADD( _AXML,'   x:FullRows="1" ss:DefaultRowHeight="15">')
AADD( _AXML,'   <Column ss:Width="342.75"/>')
AADD( _AXML,'   <Column ss:Width="89.25"/>')
AADD( _AXML,'   <Column ss:Width="123"/>')
AADD( _AXML,'   <Column ss:Width="87"/>')
AADD( _AXML,'   <Column ss:AutoFitWidth="0" ss:Width="63.75"/>')
AADD( _AXML,'   <Column ss:AutoFitWidth="0" ss:Width="97.5"/>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0" ss:Height="15.75">')
AADD( _AXML,'    <Cell ss:MergeAcross="2" ss:StyleID="s65"><Data ss:Type="String">APURACAO DE CUSTOS MATERIA PRIMA  - UND. ' + FWFilialName( cEmpAnt , Xfilial("ZL6") , 2 )  + '</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">' + MESEXTENSO(MONTH(MV_PAR05)) + '/' + ALLTRIM(STR(YEAR(MV_PAR05))) + '</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0" ss:Height="15.75">')
AADD( _AXML,'    <Cell ss:StyleID="s66"/>')
AADD( _AXML,'    <Cell ss:StyleID="s66"/>')
AADD( _AXML,'    <Cell ss:StyleID="s66"/>')
AADD( _AXML,'    <Cell ss:StyleID="s66"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0" ss:Height="15.75">')
AADD( _AXML,'    <Cell ss:StyleID="s68"><Data ss:Type="String">DESCRICAO</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s68"><Data ss:Type="String">VOLUME</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s68"><Data ss:Type="String">CUSTO TOTAL</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s68"><Data ss:Type="String">CUSTO / L</Data></Cell>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="s70"><Data ss:Type="String">CUSTO OPERACIONAL DAS FILIAIS</Data></Cell>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO OPERACIONAL</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s77"><Data ss:Type="Number">'+ALLTRIM(STR(_aCustOpera[1,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aCustOpera[1,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aCustOpera[1,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="s76"><Data ss:Type="String">LEITE PROPRIO</Data></Cell>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO LEITE PROPRIO - MIX</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s77"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteProp[1,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteProp[1,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteProp[1,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
//NOVA LINHA ENTRO DEPOIS
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO LEITE POSTOS - MIX</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s77"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteProp[4,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteProp[4,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteProp[4,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
//NOVA LINHA ENTRO DEPOIS
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO FRETE 1o. PERCURSO</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s77"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteProp[2,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">INCLUSO NO MIX</Data></Cell>')//'+ALLTRIM(STR(_aLeiteProp[2,3]))+'
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteProp[2,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO FRETE 2o. PERCURSO (SEM ICMS)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s77"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteProp[3,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteProp[3,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteProp[3,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s82"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s83"><Data ss:Type="String">CUSTO POSTO/FABRICA - LEITE PROPRIO</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s84"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteProp[5,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s85"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteProp[5,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s86"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteProp[5,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="s76"><Data ss:Type="String">LEITE TERCEIROS</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO LEITE TERCEIROS (COM MG E COM ICMS) (A)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s77"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[1,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[1,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[1,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s89"/>')
AADD( _AXML,'    <Cell ss:StyleID="s90"/>')
AADD( _AXML,'    <Cell ss:StyleID="s90"/>')
AADD( _AXML,'    <Cell ss:StyleID="s91"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO EXCEDENTE MATERIA GORDA  ( - ) (B)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[2,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s92"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[2,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">APROVEITAMENTO CREDITO ICMS ( - ) (C) (obs.: Desconsiderado transf. entre filiais)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[3,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s92"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[3,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO LEITE TERCEIROS (SEM MG E SEM ICMS) (A) - (B) - (C) = (D)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[4,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[4,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">LEITE DIRETO P/ FABRICA SEM CUSTO DE FRETE (E)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s77"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[5,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[5,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[5,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO FRETE 2o. PERCURSO (SEM ICMS) (F)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s77"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[6,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[6,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[6,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s83"><Data ss:Type="String">CUSTO EFETIVO LEITE TERCEIROS + FRETE (S/ MG e S/ICMS) (D) + (E) + (F)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s84"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[7,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s85"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[7,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s86"><Data ss:Type="Number">'+ALLTRIM(STR(_aLeiteTerc[7,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="s94"><Data ss:Type="String">RESUMO GERAL - CUSTO LEITE</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO LEITE - PROPRIO</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s77"><Data ss:Type="Number">'+ALLTRIM(STR(_aResumoGer[1,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aResumoGer[1,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aResumoGer[1,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO LEITE - TERCEIROS</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s77"><Data ss:Type="Number">'+ALLTRIM(STR(_aResumoGer[2,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aResumoGer[2,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aResumoGer[2,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s82"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s95"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s96"><Data ss:Type="String">CUSTO (FIFO) LEITE IN-NATURA - TOTAL</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s97"><Data ss:Type="Number">'+ALLTRIM(STR(_aResumoGer[3,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s98"><Data ss:Type="Number">'+ALLTRIM(STR(_aResumoGer[3,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s99"><Data ss:Type="Number">'+ALLTRIM(STR(_aResumoGer[3,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s100"/>')
AADD( _AXML,'    <Cell ss:StyleID="s100"/>')
AADD( _AXML,'    <Cell ss:StyleID="s100"/>')
AADD( _AXML,'    <Cell ss:StyleID="s100"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s101"><Data ss:Type="String">CUSTO EXC. MATERIA GORDA A TRANSPORTAR P/ CREME DE LEITE UHT</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s102"/>')
AADD( _AXML,'    <Cell ss:StyleID="s103"><Data ss:Type="Number">'+ALLTRIM(STR(_aResumoGer[4,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s104"><Data ss:Type="Number">'+ALLTRIM(STR(_aResumoGer[4,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s100"/>')
AADD( _AXML,'    <Cell ss:StyleID="s106"/>')
AADD( _AXML,'    <Cell ss:StyleID="s100"/>')
AADD( _AXML,'    <Cell ss:StyleID="s100"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="s76"><Data ss:Type="String">SORO DE LEITE</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')//_aSoroLeite
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO SORO C/ ICMS</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s77"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroLeite[1,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroLeite[1,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroLeite[1,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">APROVEITAMENTO CREDITO ICMS ( - )</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroLeite[2,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s92"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroLeite[2,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO SORO S/ ICMS</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroLeite[3,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroLeite[3,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO FRETE 2o. PERCURSO (S/ ICMS)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroLeite[4,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroLeite[4,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s83"><Data ss:Type="String">CUSTO (FIFO) EFETIVO - SORO DE LEITE</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s84"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroLeite[5,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s85"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroLeite[5,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s86"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroLeite[5,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s100"/>')
AADD( _AXML,'    <Cell ss:StyleID="s107"/>')
AADD( _AXML,'    <Cell ss:StyleID="s107"/>')
AADD( _AXML,'    <Cell ss:StyleID="s100"/>')
AADD( _AXML,'   </Row>')

//**********************************************************************************************************************************
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="s76"><Data ss:Type="String">SORO DE LEITE PRE-CONCENTRADO</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')//_aSoroPreCo
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO SORO PRE-CONCENTRADO C/ ICMS</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s77"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroPreCo[1,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroPreCo[1,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroPreCo[1,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">APROVEITAMENTO CREDITO ICMS ( - )</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroPreCo[2,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s92"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroPreCo[2,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO SORO PRE-CONCENTRADO S/ ICMS</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroPreCo[3,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroPreCo[3,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO FRETE 2o. PERCURSO (S/ ICMS)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroPreCo[4,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroPreCo[4,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s83"><Data ss:Type="String">CUSTO (FIFO) EFETIVO - SORO DE LEITE PRE-CONCENTRADO</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s84"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroPreCo[5,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s85"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroPreCo[5,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s86"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroPreCo[5,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s100"/>')
AADD( _AXML,'    <Cell ss:StyleID="s107"/>')
AADD( _AXML,'    <Cell ss:StyleID="s107"/>')
AADD( _AXML,'    <Cell ss:StyleID="s100"/>')
AADD( _AXML,'   </Row>')
//**********************************************************************************************************************************

//**********************************************************************************************************************************
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="s76"><Data ss:Type="String">SORO DE LEITE CONCENTRADO</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')//_aSoroConce
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO SORO CONCENTRADO C/ ICMS</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s77"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroConce[1,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroConce[1,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroConce[1,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">APROVEITAMENTO CREDITO ICMS ( - )</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroConce[2,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s92"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroConce[2,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO SORO CONCENTRADO S/ ICMS</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroConce[3,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroConce[3,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO FRETE 2o. PERCURSO (S/ ICMS)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroConce[4,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroConce[4,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s83"><Data ss:Type="String">CUSTO (FIFO) EFETIVO - SORO DE LEITE CONCENTRADO</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s84"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroConce[5,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s85"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroConce[5,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s86"><Data ss:Type="Number">'+ALLTRIM(STR(_aSoroConce[5,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s100"/>')
AADD( _AXML,'    <Cell ss:StyleID="s107"/>')
AADD( _AXML,'    <Cell ss:StyleID="s107"/>')
AADD( _AXML,'    <Cell ss:StyleID="s100"/>')
AADD( _AXML,'   </Row>')
//**********************************************************************************************************************************

AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="s76"><Data ss:Type="String">CREME DE LEITE</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO CREME C/ ICMS</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s108"><Data ss:Type="Number">'+ALLTRIM(STR(_aCremeLeit[1,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data  ss:Type="Number">'+ALLTRIM(STR(_aCremeLeit[1,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data  ss:Type="Number">'+ALLTRIM(STR(_aCremeLeit[1,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">APROVEITAMENTO CREDITO ICMS ( - ) (obs.: Desconsiderado transf. entre filiais)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aCremeLeit[2,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s92"><Data ss:Type="Number">'+ALLTRIM(STR(_aCremeLeit[2,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO CREME S/ ICMS</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aCremeLeit[3,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aCremeLeit[3,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s109"/>')
AADD( _AXML,'    <Cell ss:StyleID="s110"/>')
AADD( _AXML,'    <Cell ss:StyleID="s110"/>')
AADD( _AXML,'    <Cell ss:StyleID="s111"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s71"><Data ss:Type="String">CUSTO FRETE 2o. PERCURSO (S/ ICMS)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"/>')
AADD( _AXML,'    <Cell ss:StyleID="s74"><Data ss:Type="Number">'+ALLTRIM(STR(_aCremeLeit[4,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s75"><Data ss:Type="Number">'+ALLTRIM(STR(_aCremeLeit[4,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s78"/>')
AADD( _AXML,'    <Cell ss:StyleID="s79"/>')
AADD( _AXML,'    <Cell ss:StyleID="s80"/>')
AADD( _AXML,'    <Cell ss:StyleID="s81"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">')
AADD( _AXML,'    <Cell ss:StyleID="s83"><Data ss:Type="String">CUSTO (FIFO) EFETIVO - CREME DE LEITE</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s112"><Data ss:Type="Number">'+ALLTRIM(STR(_aCremeLeit[5,2]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s85"><Data  ss:Type="Number">'+ALLTRIM(STR(_aCremeLeit[5,3]))+'</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s86"><Data  ss:Type="Number">'+ALLTRIM(STR(_aCremeLeit[5,4]))+'</Data></Cell>')
AADD( _AXML,'   </Row>') 

AADD( _AXML,'  </Table>')
AADD( _AXML,'  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">')
AADD( _AXML,'   <PageSetup>')
AADD( _AXML,'    <Header x:Margin="0.31496062000000002"/>')
AADD( _AXML,'    <Footer x:Margin="0.31496062000000002"/>')
AADD( _AXML,'    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"')
AADD( _AXML,'     x:Right="0.511811024" x:Top="0.78740157499999996"/>')
AADD( _AXML,'   </PageSetup>')
AADD( _AXML,'   <Unsynced/>')
AADD( _AXML,'   <Selected/>')
AADD( _AXML,'   <Panes>')
AADD( _AXML,'    <Pane>')
AADD( _AXML,'     <Number>3</Number>')
AADD( _AXML,'     <ActiveRow>2</ActiveRow>')
AADD( _AXML,'    </Pane>')
AADD( _AXML,'   </Panes>')
AADD( _AXML,'   <ProtectObjects>False</ProtectObjects>')
AADD( _AXML,'   <ProtectScenarios>False</ProtectScenarios>')
AADD( _AXML,'  </WorksheetOptions>')
AADD( _AXML,' </Worksheet>')

RETURN _AXML 

/*
===============================================================================================================================
Programa----------: MEST9PEstoqueMP()
Autor-------------: Alex Wallauer
Data da Criacao---: 20/06/2018
Descricao---------: Monta Pasta Materia prima do excel
Parametros--------: _AXML,_aZeNew,lSoPegaVlrs,_oRegua
Retorno-----------: _AXML
===============================================================================================================================
*/
Static Function MEST9PEstoqueMP(_AXML,_aZeNew,lSoPegaVlrs,_oSelf)
LOCAL _nQtdSin  :=0 , _ni   , _nPos
LOCAL _cSegUni  :="N"
LOCAL _cEstAnt  :="1"
LOCAL _cGrpCus  :="" 
LOCAL _cLocais  :="" 
LOCAL _aEstoqFim:={}
LOCAL _aEntradas:={}
LOCAL _aConsumo :={}
LOCAL _aVendas  :={}
LOCAL _aTrans   :={}
LOCAL _aOutros  :={}
LOCAL _aPerdas  :={}
LOCAL _aDiferenc:={}
LOCAL _cFiliais :=""
LOCAL _nPosTotal:=0
LOCAL _nPosGeral:=0
LOCAL _aEstoque :={0,0,0}  //Grupo Custo:  "000001"
DEFAULT lSoPegaVlrs := .F.
PRIVATE _cFilis :=""

AADD(_aEntradas,{00,"TOTAL ENTRADAS MATERIA PRIMA DO MES"})// (B) 	        //NN  = _azeNew[_ni][07] = Grupo Custo:  "000002" SOMATORIO DO GRUPO
_nPosTotal:=LEN(_aEntradas)
AADD(_aEntradas,{00,"TOTAL MATERIA PRIMA DO MES (A)+(B)=(C)"})              //NN  SOMATORIO DOS ANTERIORES
_nPosGeral:=LEN(_aEntradas)

AADD(_aConsumo ,{00,"SALDO PARCIAL (C)-(D) = (E)","ULTIMO","0"})	        //NN  SALDO PARCIAL (C)+(D)+(E) = (F)      SOMATORIO DO GRUPO
_nTotConsumo:=LEN(_aConsumo)

AADD(_aVendas  ,{00,"TOTAL VENDAS LEITE RESFRIADO DO MES (F)"})             //01 //_azeNew[_ni][08] = Grupo Custo: "000004"  SOMATORIO DO GRUPO

AADD(_aTrans   ,{00,"TOTAL DE TRANSFERENCIAS (G)"})			                //01 //_azeNew[_ni][08] = Grupo Custo: "000005"  SOMATORIO DO GRUPO //TOTAL DE TRANSFERENCIAS (G)
AADD(_aTrans   ,{00,"SALDO PARCIAL  (E)-(F)-(G) = (H)"})	                //01 //SALDO PARCIAL  (E)-(F)-(G) = (H)

AADD(_aEstoqFim,{00,"TOTAL ESTOQUE FINAL DO MES (I)"})                      //NN SOMATORIO DO GRUPO // TOTAL ESTOQUE FINAL DO MES (I)
_nTotEstoqFim:=LEN(_aEstoqFim)
AADD(_aEstoqFim,{00,"SALDO PARCIAL (H)-(I) = (J)"})                         //NN CALCULO DO SALDO // SALDO PARCIAL  (H)-(I) = (J)
_nTotEFSalPar:=LEN(_aEstoqFim)

AADD(_aOutros,{00,"DESCONTO FRETISTA FILIAIS"})                             //01 //_azeNew[_ni][08] = Grupo Custo: "000007"
AADD(_aOutros,{00,"PERDAS FILIAIS (RESPONSABILIDADE FABRICA)"})             //02
AADD(_aOutros,{00,"DOACOES FILIAIS"})                                       //03
AADD(_aOutros,{00,"SAIDAS PRODUTOR"})                                       //04
AADD(_aOutros,{00,"TOTAL OUTRAS SAIDAS (K)"})                               //05//TOTAL OUTRAS SAIDAS (K) - SÓ SOMATORIA
_nTotOuSalPar:=LEN(_aOutros)

AADD(_aPerdas,{00,"PERDAS DE LEITE/CREME"})                                 //01 //_azeNew[_ni][08] = Grupo Custo: "000008"
AADD(_aPerdas,{00,"PERDAS SORO DE LEITE"})                                  //02
AADD(_aPerdas,{00,"TOTAL PERDAS (L)"})                                      //03 // TOTAL PERDAS        (L) - SÓ SOMATORIA
_nTotPeSalPar:=LEN(_aPerdas)

AADD(_aDiferenc,{00,"DIFERENCA (J)-(K)-(L)"}) 			                    //01 //_azeNew[_ni][08] = Grupo Custo: "000009"//NÃO TEM MAIS ESSA REGRA DESDE 04/02/219
//AADD(_aDiferenc,{00,"DIFERENCA POSITIVA"})                                //02
//_nSaldoFINAL:=0                                                             //03

/*		aadd(_azeNew,{	xfilial("ZE0"),;															//01
					ALLTRIM(ZL6T->ZL6_TPCUS),;														//02
					ALLTRIM(ZL6T->ZL6_DTPCUS),;														//03
					ALLTRIM(ZL6T->ZL6_CODEVE),;														//04	
					ALLTRIM(ZL6T->ZL6_DESEVE),;			 											//05  DESCRICAO
					ALLTRIM(ZL6T->ZL6_SUBEVE),;														//06
					UPPER(ALLTRIM(ZL6T->ZL6_DSUBEV)),;												//07  DESCRICAO
					ALLTRIM(ZL6T->ZL6_GRPCUS),;														//08  CODIGO DE CONTROLE
					ALLTRIM(ZL6T->ZL6_DGRCUS),;														//09
					_nQtdSin,;																		//10  QUANTIDADES 
					_nVlrSin,;																		//11
					(substr(dtos(MV_PAR05),5,2) +  substr(dtos(MV_PAR05),1,4)),;					//12
					ALLTRIM(ZL6T->ZL6_REGRA),;														//13
					_cordem,;																		//14
					ALLTRIM(ZL6T->ZL6_CODPRO),;														//15
					ZL6T->ZL6_TCUSTO,;																//16		
					ZL6T->ZL6_TUNID ,; 																//17
					ZL6T->ZL6_GRPPRO,;                                                              //18  GRUPOS
					ZL6T->ZL6_CENTRO,; 																//19				
					ZL6T->ZL6_OBSERV,; 																//20  TIPOS 
					_lTemEstoquenaDT,; 																//21  TEM ESTOQUE NA DATA ?
					ZL6T->ZL6_FILIS ,; 																//22  OUTRAS FILIAIS
					_aProdutos      ,; 																//23
					ALLTRIM(ZL6T->ZL6_MOBSER),;														//24
					ZL6T->ZL6_CLIENTE})																//25
					*/

IF VALTYPE(_oSelf) = "O"
   _oRegua:=_oSelf
ENDIF

IF VALTYPE(_oRegua) = "O"
   _oRegua:SetRegua2( LEN(_azeNew) )
ENDIF

FOR _ni := 1 to LEN(_azeNew)//Rodas os codigos '000004' 

    IF VALTYPE(_oRegua) = "O"
       _oRegua:IncRegua2("RMP-Lendo "+_azeNew[_ni][07]+"...")
	   ProcessMessages()
    ENDIF

	IF _azeNew[_ni][02] <> "000004" //ALLTRIM(ZL6T->ZL6_TPCUS)
	   LOOP
	ENDIF

	IF _azeNew[_ni][08] = "000001" //_azeNew[_ni][20] = "8" ////////////////////// ESTOQUE INICIAL FIXO ///////////////// 

	   _nQtdSin:=_azeNew[_ni][10]
       _cFilis := ALLTRIM(_azeNew[_ni][22])//Essa variavel usa na função MEST009SB9()
	   IF _nQtdSin = 0 .AND. !_azeNew[_ni][21] .AND. !EMPTY(_azeNew[_ni][15])
  	      _cLocais:= MEST9Locais()
	      _aRet   := MEST009SB9(_azeNew[_ni][15],_cSegUni,_cEstAnt,_cGrpCus,,_cLocais)  //valores de estoque anterior
	      _nQtdSin:= _aRet[1][1]
	   ENDIF   
       IF EMPTY(_cFilis)
	      _aEstoque[1] += _nQtdSin //ESTOQUE INICIAL DO MES
	   ELSE   
  	       _cFiliais:=STRTRAN(_cFilis,";",",")
	      _aEstoque[2] += _nQtdSin//ESTOQUE INICIAL DAS FILIAIS ['+_cFiliais+'] DO MES
	   ENDIF   

	ELSEIF _azeNew[_ni][08] = "000002" //_azeNew[_ni][20] = "1" ou _azeNew[_ni][20] = "3"//////// ENTRADAS VARIADO /////////////////////////// 

       AADD(_aEntradas,{_azeNew[_ni][10],_azeNew[_ni][07]})
       _aEntradas[_nPosTotal,1]+=_azeNew[_ni][10]
 
	ELSEIF _azeNew[_ni][08] = "000003" //_azeNew[_ni][20] = "1" ou _azeNew[_ni][20] = "3"//////// CONSUMO  /////////////////////////// 
                        //_nQtdSin         , ZL6->ZL6_DSUBEV ,_cordem  03     ,ZL6->ZL6_REGRA 04
       AADD(_aConsumo,{ (_azeNew[_ni][10]) , _azeNew[_ni][07],_azeNew[_ni][14],_azeNew[_ni][13] })
       _aConsumo[_nTotConsumo,1]+=_azeNew[_ni][10]//SALDO PARCIAL

	ELSEIF _azeNew[_ni][08] = "000004" //////////////////////////////////////// VENDAS /////////////////////////////////////////////////////////////

       AADD(_aVendas,{_azeNew[_ni][10],_azeNew[_ni][07]})
       _aVendas[01,1]+=_azeNew[_ni][10]//TOTAL VENDAS LEITE RESFRIADO DO MES

	ELSEIF _azeNew[_ni][08] = "000005" ////////////////////////////////// TRANSFERENCIA /////////////////////////////////////////////////////////

       _azeNew[_ni][10]:=(_azeNew[_ni][10])
       AADD(_aTrans,{_azeNew[_ni][10],_azeNew[_ni][07]})
       _aTrans[01,1]+=_azeNew[_ni][10]//TOTAL DE TRANSFERENCIAS 
 
	ELSEIF _azeNew[_ni][08] = "000006"//_azeNew[_ni][20] =  "E"  //////////// ESTOQUE FINAL  ////////////////////////////////////////////////// 

       AADD(_aEstoqFim,{_azeNew[_ni][10],_azeNew[_ni][07]})
       _aEstoqFim[_nTotEstoqFim,1]+=_azeNew[_ni][10]

	ELSEIF _azeNew[_ni][08] = "000007" //////////// OUTROS  FIXO ////////////////////////////////////////////////// 

       _nPos:=ASCAN(_aOutros,{|E| E[2] == _azeNew[_ni][07] } )
       IF _nPos <> 0
          _aOutros[_nPos,1]+=_azeNew[_ni][10]
          _aOutros[_nTotOuSalPar,1]+=_azeNew[_ni][10]
       ENDIF

	ELSEIF _azeNew[_ni][08] = "000008" //////////// PERDAS  FIXO ////////////////////////////////////////////////// 

       _nPos:=ASCAN(_aPerdas,{|E| E[2] == _azeNew[_ni][07] } )
       IF _nPos <> 0
          _aPerdas[_nPos,1]+=_azeNew[_ni][10]
          _aPerdas[_nTotPeSalPar,1]+=_azeNew[_ni][10]
       ENDIF

/*  NÃO TEM MAIS ESSA REGRA DESDE 04/02/219
	ELSEIF _azeNew[_ni][08] = "000009" //////////// DIFERENÇAS  FIXO ////////////////////////////////////////////////// 

       _nPos:=ASCAN(_aDiferenc,{|E| E[2] == _azeNew[_ni][07] } )
       IF _nPos <> 0
          _aDiferenc[_nPos,1]+=_azeNew[_ni][10]
          _nSaldoFINAL+=_azeNew[_ni][10]
       ENDIF*/

	ENDIF

NEXT

_ni := 1

_aConsAux := _aConsumo
_aConsumo := {}

_cTesteA:="Valor;Produto;Ordem;Regra"+ENTER+"ANTES:"+ENTER
_cTesteD:="DEPOIS:"+ENTER
FOR _ni := 1 TO len(_aConsAux) 

    _cTesteA+=STR(_aConsAux[_ni][01],20,8)+";"+_aConsAux[_ni][02]+";"+_aConsAux[_ni][03]+";"+_aConsAux[_ni][04]+ENTER

	_np := ASCAN(_aConsumo,{|C|C[03]==_aConsAux[_ni][03] }) //ZL6_ORDEM

	if _aConsAux[_ni][4] == "2" .AND. _np > 0//ZL6_REGRA
	   _aConsumo[_np][1] += _aConsAux[_ni][1]
	Else
		AADD(_aConsumo,_aConsAux[_ni])
	Endif
	
NEXT
FOR _ni := 1 TO len(_aConsumo) 
    _cTesteD+=STR(_aConsumo[_ni][01],20,8)+";"+_aConsumo[_ni][02]+";"+_aConsumo[_ni][03]+";"+_aConsAux[_ni][04]+ENTER
NEXT
_cTeste:=STRTRAN(_cTesteA+_cTesteD,".",",")
_cFileNome:=_cdir+"MEST009_CONSUMO_RESUMIDO_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".CSV"
MemoWrite(_cFileNome,_cTeste)

//////////////////////////////////////////////   CALCULOS DOS TOTAIS  /////////////////////////////////////////////////////////////////////////////////////////
_aEstoque[3]               :=_aEstoque[1]+_aEstoque[2]                             //TOTAL ESTOQUE INICIAL DE LEITE DO MES (A)
_aEntradas[_nPosGeral,1]   :=_aEstoque[3]+_aEntradas[_nPosTotal,1]                 //TOTAL MATERIA PRIMA DO MES (A)+(B)=(C)
_aConsumo[_nTotConsumo,1]  :=_aEntradas[_nPosGeral,1]-_aConsumo[_nTotConsumo,1]    //SALDO PARCIAL (C)-(Tot. Consumos) = (E)
_aTrans[02,1]              :=_aConsumo[_nTotConsumo,1]-_aVendas[01,1]-_aTrans[01,1]//SALDO PARCIAL  (E)-(F)-(G) = (H)
_aEstoqFim[_nTotEFSalPar,1]:=_aTrans[02,1]-_aEstoqFim[_nTotEstoqFim,1]             //SALDO PARCIAL  (H)-(I) = (J)
//_aOutros[_nTotOuSalPar,01]:=_aOutros[_nTotOuSalPar,01]                           //TOTAL OUTRAS SAIDAS (K) - SÓ SOMATORIA
//_aPerdas[_nTotPeSalPar,01]:=_aPerdas[_nTotPeSalPar,01]                           //TOTAL PERDAS        (L) - SÓ SOMATORIA
_aDiferenc[01,01]:=_aEstoqFim[_nTotEFSalPar,1]-_aOutros[_nTotOuSalPar,01]-_aPerdas[_nTotPeSalPar,01]//DIFERENCA (J)-(K)-(L)
//_nSaldoFINAL               :=_nSaldoFINAL+_aPerdas[,01]                          //SALDO - NÃO TEM MAIS
/////////////////////////////////////////////   CALCULOS DOS TOTAIS   /////////////////////////////////////////////////////////////////////////////////////////

IF VALTYPE(_oRegua) = "O"
   _oRegua:SetRegua2(0)
   _oRegua:IncRegua2("RMP - LIDO OK")
   ProcessMessages()
ENDIF

IF lSoPegaVlrs
   RETURN _aDiferenc[01,01]
ENDIF

AADD( _AXML,' <Worksheet ss:Name="ESTOQUE MP">')//////////////////   ESTOQUE MP  //////////////////////////////////////////////////////////////////////////////

AADD( _AXML,'  <Table ss:ExpandedColumnCount="6" ss:ExpandedRowCount="999999" x:FullColumns="1"')
AADD( _AXML,'   x:FullRows="1" ss:DefaultRowHeight="15">')
AADD( _AXML,'   <Column ss:AutoFitWidth="0" ss:Width="387.75"/>')
AADD( _AXML,'   <Column ss:Index="4" ss:AutoFitWidth="0" ss:Width="18.75"/>')
AADD( _AXML,'   <Column ss:AutoFitWidth="0" ss:Width="20.25"/>')
AADD( _AXML,'   <Column ss:AutoFitWidth="0" ss:Width="83.25"/>')
AADD( _AXML,'   <Row>')

AADD( _AXML,'    <Cell ss:MergeAcross="4" ss:StyleID="s113"><Data ss:Type="String">RESUMO ENTRADAS DE MATERIAS PRIMAS - UND. ' + FWFilialName( cEmpAnt , Xfilial("ZL6") , 2 )+'</Data></Cell>')

AADD( _AXML,'    <Cell ss:StyleID="s144"><Data ss:Type="String">' + MESEXTENSO(MONTH(MV_PAR05)) + '/' + ALLTRIM(STR(YEAR(MV_PAR05))) + '</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s115"/>')
AADD( _AXML,'    <Cell ss:StyleID="s116"/>')
AADD( _AXML,'    <Cell ss:StyleID="s116"/>')
AADD( _AXML,'    <Cell ss:StyleID="s116"/>')
AADD( _AXML,'    <Cell ss:StyleID="s116"/>')
AADD( _AXML,'    <Cell ss:StyleID="s116"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'    <Cell ss:StyleID="s67"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:MergeAcross="4" ss:StyleID="s129"><Data ss:Type="String">HISTORICO</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s145"><Data ss:Type="String">QUANTIDADE</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s146"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s135"><Data ss:Type="String">ESTOQUE</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s146"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">ESTOQUE INICIAL DO MES</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s136"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">' + ALLTRIM(STR( _aEstoque[1] )) + '</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">ESTOQUE INICIAL DAS FILIAIS ['+_cFiliais+'] DO MES</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s136"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">' + alltrim(str( _aEstoque[2] )) + '</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s136"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s138"><Data ss:Type="String">TOTAL ESTOQUE INICIAL DE LEITE DO MES (A)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s140"/>')
AADD( _AXML,'    <Cell ss:StyleID="s148"><Data ss:Type="Number">' + ALLTRIM(STR( _aEstoque[3] )) + '</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s138"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s140"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s135"><Data ss:Type="String">ENTRADAS</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')

FOR _ni := 3 TO LEN(_aEntradas)
    AADD( _AXML,'   <Row>')
    AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">' + ALLTRIM(_aEntradas[_ni,2]) + '</Data></Cell>')
    AADD( _AXML,'    <Cell ss:StyleID="s142"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">' + ALLTRIM(STR( _aEntradas[_ni,1] )) + '</Data></Cell>')
    AADD( _AXML,'   </Row>')      
NEXT

AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s136"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s138"><Data ss:Type="String">TOTAL ENTRADAS MATERIA PRIMA DO MES (B)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s140"/>')
AADD( _AXML,'    <Cell ss:StyleID="s148"><Data ss:Type="Number">' + ALLTRIM(STR( _aEntradas[_nPosTotal,1] )) + '</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s136"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s138"><Data ss:Type="String">TOTAL MATERIA PRIMA DO MES (A)+(B) = (C)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s140"/>')
AADD( _AXML,'    <Cell ss:StyleID="s148"><Data ss:Type="Number">' + ALLTRIM(STR( _aEntradas[_nPosGeral,1] )) + '</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')

FOR _ni := 2 TO LEN(_aConsumo)
    AADD( _AXML,'   <Row>')
    AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">' + ALLTRIM(_aConsumo[_ni,2]) + '</Data></Cell>')
    AADD( _AXML,'    <Cell ss:StyleID="s142"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">' + ALLTRIM(STR( _aConsumo[_ni,1] )) + '</Data></Cell>')
    AADD( _AXML,'   </Row>')      
NEXT

AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s138"><Data ss:Type="String">SALDO PARCIAL (C)-(Tot. Consumos) = (E)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s148"><Data ss:Type="Number">' + ALLTRIM(STR( _aConsumo[_nTotConsumo,1] )) + '</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')
FOR _ni := 2 TO LEN(_aVendas)
    AADD( _AXML,'   <Row>')
    AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">' + ALLTRIM(_aVendas[_ni,2]) + '</Data></Cell>')
    AADD( _AXML,'    <Cell ss:StyleID="s142"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">' + ALLTRIM(STR( _aVendas[_ni,1] )) + '</Data></Cell>')
    AADD( _AXML,'   </Row>')      
NEXT
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s138"><Data ss:Type="String">TOTAL VENDAS LEITE RESFRIADO DO MES (F)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s148"><Data ss:Type="Number">' + ALLTRIM(STR( _aVendas[01,1] )) + '</Data></Cell>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')

FOR _ni := 3 TO LEN(_aTrans)
    AADD( _AXML,'   <Row>')
    AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">' + ALLTRIM(_aTrans[_ni,2]) + '</Data></Cell>')
    AADD( _AXML,'    <Cell ss:StyleID="s142"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">' + ALLTRIM(STR( _aTrans[_ni,1] )) + '</Data></Cell>')
    AADD( _AXML,'   </Row>')      
NEXT

AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s138"><Data ss:Type="String">TOTAL DE TRANSFERENCIAS (G)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s148"><Data ss:Type="Number">' + ALLTRIM(STR( _aTrans[01,1] )) + '</Data></Cell>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row>')                                                     
AADD( _AXML,'    <Cell ss:StyleID="s138"><Data ss:Type="String">SALDO PARCIAL (E)-(F)-(G) = (H)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s148"><Data ss:Type="Number">' + ALLTRIM(STR( _aTrans[02,1] )) + '</Data></Cell>')
AADD( _AXML,'   </Row>')

AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')

FOR _ni := 3 TO LEN(_aEstoqFim)
    AADD( _AXML,'   <Row>')
    AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">' + ALLTRIM(_aEstoqFim[_ni,2]) + '</Data></Cell>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
    AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">' +  ALLTRIM(STR( _aEstoqFim[_ni,1] )) + '</Data></Cell>')
    AADD( _AXML,'   </Row>')      
NEXT

AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s138"><Data ss:Type="String">TOTAL ESTOQUE FINAL DO MES (I)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s148"><Data ss:Type="Number">' + ALLTRIM(STR( _aEstoqFim[_nTotEstoqFim,1] )) + '</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s138"><Data ss:Type="String">SALDO PARCIAL (H)-(I) = (J) </Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s148"><Data ss:Type="Number">' + ALLTRIM(STR( _aEstoqFim[_nTotEFSalPar,1] )) + '</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">DESCONTO FRETISTA FILIAIS</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">'+ALLTRIM(STR(_aOutros[01,01]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">PERDAS FILIAIS (RESPONSABILIDADE FABRICA)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">'+ALLTRIM(STR(_aOutros[02,01]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">DOACOES FILIAIS</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">'+ALLTRIM(STR(_aOutros[03,01]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">SAIDAS PRODUTOR</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">'+ALLTRIM(STR(_aOutros[04,01]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s138"><Data ss:Type="String">TOTAL OUTRAS SAIDAS (K)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s148"><Data ss:Type="Number">'+ALLTRIM(STR( _aOutros[_nTotOuSalPar,01] ))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">PERDA DE LEITE/CREME</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">'+ALLTRIM(STR(_aPerdas[01,01]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">PERDAS SORO DE LEITE</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">'+ALLTRIM(STR(_aPerdas[02,01]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s138"><Data ss:Type="String">TOTAL PERDAS (L)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s139"/>')
AADD( _AXML,'    <Cell ss:StyleID="s148"><Data ss:Type="Number">'+ALLTRIM(STR(_aPerdas[_nTotPeSalPar,01]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s138"><Data ss:Type="String">DIFERENCA '+IF(_aDiferenc[01,01]>0,"A CUSTEAR",IF(_aDiferenc[01,01]<0,"A COMPENSAR",""))+' (J)-(K)-(L)</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s148"><Data ss:Type="Number">'+ALLTRIM(STR(_aDiferenc[01,01]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
/*
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">DIFERENCA  (J)-(K)-(L) </Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">'+ALLTRIM(STR(_aDiferenc[01,01]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"/>')
AADD( _AXML,'   </Row>')
AADD( _AXML,'   <Row>')
AADD( _AXML,'    <Cell ss:StyleID="s132"><Data ss:Type="String">DIFERENCA  (J)-(K)-(L) </Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s133"/>')
AADD( _AXML,'    <Cell ss:StyleID="s147"><Data ss:Type="Number">'+ALLTRIM(STR(_aDiferenc[01,01]))+'</Data></Cell>')
AADD( _AXML,'   </Row>')
*/
AADD( _AXML,'  </Table>')
AADD( _AXML,'  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">')
AADD( _AXML,'   <PageSetup>')
AADD( _AXML,'    <Header x:Margin="0.31496062000000002"/>')
AADD( _AXML,'    <Footer x:Margin="0.31496062000000002"/>')
AADD( _AXML,'    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"')
AADD( _AXML,'     x:Right="0.511811024" x:Top="0.78740157499999996"/>')
AADD( _AXML,'   </PageSetup>')
AADD( _AXML,'   <Print>')
AADD( _AXML,'    <ValidPrinterInfo/>')
AADD( _AXML,'    <PaperSizeIndex>9</PaperSizeIndex>')
AADD( _AXML,'    <HorizontalResolution>600</HorizontalResolution>')
AADD( _AXML,'    <VerticalResolution>600</VerticalResolution>')
AADD( _AXML,'   </Print>')
AADD( _AXML,'   <Panes>')
AADD( _AXML,'    <Pane>')
AADD( _AXML,'     <Number>3</Number>')
AADD( _AXML,'     <ActiveRow>2</ActiveRow>')
AADD( _AXML,'    </Pane>')
AADD( _AXML,'   </Panes>')
AADD( _AXML,'   <ProtectObjects>False</ProtectObjects>')
AADD( _AXML,'   <ProtectScenarios>False</ProtectScenarios>')
AADD( _AXML,'  </WorksheetOptions>')
AADD( _AXML,' </Worksheet>')

AADD( _AXML,'</Workbook>')

RETURN _AXML 

/*
===============================================================================================================================
Programa----------: MEST94Plan()
Autor-------------: Alex Wallauer
Data da Criacao---: 05/07/2018
Descricao---------: Retorna o LayOut da Planilha 4 "04-Espelho Composicao dos Custos "
Parametros--------: _aCusto04
Retorno-----------: _axml 
===============================================================================================================================
*/
Static Function MEST94Plan(_aCusto04)
LOCAL _AXML      := {}
LOCAL _ni 
LOCAL _cArq01    := "\data\italac\mest009\MEST009_PLAN_04.txt"

*******************************************************  /*Definições*/  ***************************************************************
If FT_FUSE(_cArq01) == -1
	
	U_ITMSG("Não foi possível abrir o arquivo: "+_cArq01,"Arquivo inválido","Favor verificar se o arquivo se esta correto.",1)
	Return _AXML
	
EndIf

FT_FGOTOP()//PONTO NO TOPO

If FT_FLASTREC() == 0
	
	U_ITMSG("O arquivo "+_cArq01+" não possui dados.","Arquivo inválido","Favor verificar se o arquivo se esta correto.",1)
	Return _AXML
	
EndIf

DO WHILE !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
	_cLinha:=FT_FREADLN()
	IF !EMPTY(_cLinha)
		AADD(_AXML,_cLinha)
	ENDIF
	FT_FSKIP()   //próximo registro no arquivo txt
	
EndDo

FT_FUSE()//Fecha o arquivo

*****************************************************  /*PASTA*/  ***********************************************************

/*		AADD(_aCusto04,{"CUSTO OPERACIONAL                 ",0,0,0})//01
		AADD(_aCusto04,{"CUSTO OPERACIONAL FILIAIS         ",0,0,0})//02
		AADD(_aCusto04,{"CUSTO LEITE IN-NATURA + FRETE     ",0,0,0})//03
		AADD(_aCusto04,{"CUSTO SORO DE LEITE + FRETE       ",0,0,0})//04
		AADD(_aCusto04,{"CUSTO SORO CONCENTRADO + FRETE    ",0,0,0})//05    
		AADD(_aCusto04,{"CUSTO CREME DE LEITE + FRETE      ",0,0,0})//06     
		AADD(_aCusto04,{"CUSTO COM ICMS P/ LEITE UHT       ",0,0,0})//07
		AADD(_aCusto04,{"CUSTO COM ICMS P/ DERIVADOS       ",0,0,0})//08
		AADD(_aCusto04,{"CUSTO COM ICMS P/ MERC. ADQUIRIDAS",0,0,0})//09
		AADD(_aCusto04,{"CUSTO IRPJ/CSSL(PARCELAMENTO)     ",0,0,0})//10
		AADD(_aCusto04,{"DO 11 PARA FRENTE NÃO É FIXO)     ",0,0,0})//11*/

AADD( _AXML,'<Worksheet ss:Name="ESPELHO CUSTOS">                                                                                                   ')
AADD( _AXML,'  <Table ss:ExpandedColumnCount="7" ss:ExpandedRowCount="999999" x:FullColumns="1"                                                         ')
AADD( _AXML,'   x:FullRows="1" ss:DefaultRowHeight="15">                                                                                            ')
AADD( _AXML,'   <Column ss:Index="4" ss:AutoFitWidth="0" ss:Width="174.75"/>                                                                        ')
AADD( _AXML,'   <Column ss:AutoFitWidth="0" ss:Width="108.75" ss:Span="2"/>                                                                         ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')

AADD( _AXML,'    <Cell ss:MergeAcross="4" ss:StyleID="s65"><Data ss:Type="String">ESPELHO DA COMPOSICAO DOS CUSTOS - UND. ' + FWFilialName( cEmpAnt , Xfilial("ZL6") , 2 )  + '</Data></Cell> ')
AADD( _AXML,'    <Cell ss:StyleID="s102"><Data ss:Type="String">' + MESEXTENSO(MONTH(MV_PAR05)) + '/' + ALLTRIM(STR(YEAR(MV_PAR05))) + '</Data></Cell>                                                             ')

AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:MergeAcross="6" ss:StyleID="s67"/>                                                                                        ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="m136891136"><Data ss:Type="String">HISTORICO</Data></Cell>                                    ')
AADD( _AXML,'    <Cell ss:StyleID="s78"><Data ss:Type="String">QUANTIDADES</Data></Cell>                                                            ')
AADD( _AXML,'    <Cell ss:StyleID="s78"><Data ss:Type="String">VALOR</Data></Cell>                                                                  ')
AADD( _AXML,'    <Cell ss:StyleID="s78"><Data ss:Type="String">PARTIC.</Data></Cell>                                                                ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="m136891156"><Data ss:Type="String">' + ALLTRIM(_aCusto04[1,1] ) + '</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s86"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[1,2] )) + '</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s87"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[1,3] )) + '</Data></Cell>')
AADD( _AXML,'    <Cell ss:StyleID="s88"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[1,4] )) + '</Data></Cell>')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s89"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s90"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s91"/>                                                                                                           ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="m136891176"><Data ss:Type="String">' + ALLTRIM(_aCusto04[2,1] ) + '</Data></Cell>             ')
AADD( _AXML,'    <Cell ss:StyleID="s86"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[2,2] )) + '</Data></Cell>                                 ')
AADD( _AXML,'    <Cell ss:StyleID="s87"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[2,3] )) + '</Data></Cell>                                 ')
AADD( _AXML,'    <Cell ss:StyleID="s88"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[2,4] )) + '</Data></Cell>                                 ')
//AADD( _AXML,'    <Cell ss:StyleID="s88" ss:Formula="=IF(RC[-1]=0,0,RC[-1]/RC[-2])"><Data                                                            ')
//AADD( _AXML,'      ss:Type="Number">0</Data></Cell>                                                                             ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s89"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s90"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="m136891196"><Data ss:Type="String">' + ALLTRIM(_aCusto04[3,1] ) + '</Data></Cell>             ')
AADD( _AXML,'    <Cell ss:StyleID="s86"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[3,2] )) + '</Data></Cell>                                 ')
AADD( _AXML,'    <Cell ss:StyleID="s87"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[3,3] )) + '</Data></Cell>                                 ')
AADD( _AXML,'    <Cell ss:StyleID="s88"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[3,4] )) + '</Data></Cell>                                 ')
//AADD( _AXML,'    <Cell ss:StyleID="s88" ss:Formula="=IF(RC[-1]=0,0,RC[-1]/RC[-2])"><Data                                                            ')
//AADD( _AXML,'      ss:Type="Number">0</Data></Cell>                                                                                ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s89"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s90"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="m136891304"><Data ss:Type="String">' + ALLTRIM(_aCusto04[4,1] ) + '</Data></Cell>             ')
AADD( _AXML,'    <Cell ss:StyleID="s86"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[4,2] )) + '</Data></Cell>                                 ')
AADD( _AXML,'    <Cell ss:StyleID="s87"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[4,3] )) + '</Data></Cell>                                 ')
AADD( _AXML,'    <Cell ss:StyleID="s88"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[4,4] )) + '</Data></Cell>                                 ')
//AADD( _AXML,'    <Cell ss:StyleID="s88" ss:Formula="=IF(RC[-1]=0,0,RC[-1]/RC[-2])"><Data                                                            ')
//AADD( _AXML,'      ss:Type="Number">0</Data></Cell>                                                                               ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s89"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s90"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="m136891324"><Data ss:Type="String">' + ALLTRIM(_aCusto04[5,1] ) + '</Data></Cell>             ')
AADD( _AXML,'    <Cell ss:StyleID="s86"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[5,2] )) + '</Data></Cell>                                 ')
AADD( _AXML,'    <Cell ss:StyleID="s87"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[5,3] )) + '</Data></Cell>                                 ')
AADD( _AXML,'    <Cell ss:StyleID="s88"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[5,4] )) + '</Data></Cell>                                 ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s89"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s90"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="m136891344"><Data ss:Type="String">' + ALLTRIM(_aCusto04[6,1] ) + '</Data></Cell>             ')
AADD( _AXML,'    <Cell ss:StyleID="s86"><Data ss:Type="String">' + ALLTRIM(TRANSFORM(_aCusto04[6,2], "@E 999,999,999,999" )) + ' KG</Data></Cell>   ')//GAMBIS
//AADD( _AXML,'    <Cell ss:StyleID="s86"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[6,2] )) + '</Data></Cell>                               ')
AADD( _AXML,'    <Cell ss:StyleID="s87"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[6,3] )) + '</Data></Cell>                                 ')
AADD( _AXML,'    <Cell ss:StyleID="s88"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[6,4] )) + '</Data></Cell>                                 ')
//AADD( _AXML,'    <Cell ss:StyleID="s88" ss:Formula="=IF(RC[-1]=0,0,RC[-1]/RC[-2])"><Data                                                          ')
//AADD( _AXML,'      ss:Type="Number">0</Data></Cell>                                                                                               ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s89"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s90"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="m136891364"><Data ss:Type="String">' + ALLTRIM(_aCusto04[7,1] ) + '</Data></Cell>             ')
AADD( _AXML,'    <Cell ss:StyleID="s86"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s87"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[7,2] )) + '</Data></Cell>                                 ')
AADD( _AXML,'    <Cell ss:StyleID="s92"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[7,3] )) + '</Data></Cell>                                 ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="m136891384"><Data ss:Type="String">' + ALLTRIM(_aCusto04[8,1] ) + '</Data></Cell>             ')
AADD( _AXML,'    <Cell ss:StyleID="s86"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s87"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[8,2] )) + '</Data></Cell>                                 ')
AADD( _AXML,'    <Cell ss:StyleID="s92"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[8,3] )) + '</Data></Cell>                                 ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="m136891404"><Data ss:Type="String">' + ALLTRIM(_aCusto04[9,1] ) + '</Data></Cell>             ')
AADD( _AXML,'    <Cell ss:StyleID="s86"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s87"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[9,2] )) + '</Data></Cell>                                 ')
AADD( _AXML,'    <Cell ss:StyleID="s92"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[9,3] )) + '</Data></Cell>                                 ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s89"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s90"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="m136891512"><Data ss:Type="String">' + ALLTRIM(_aCusto04[10,1] ) + '</Data></Cell>            ')
AADD( _AXML,'    <Cell ss:StyleID="s86"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s87"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[10,2] )) + '</Data></Cell>                                ')
AADD( _AXML,'    <Cell ss:StyleID="s95"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[10,3] )) + '</Data></Cell>                                ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:StyleID="s96"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s96"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s96"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s96"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s96"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s96"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s96"/>                                                                                                           ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:MergeAcross="6" ss:StyleID="s98"><Data ss:Type="String">CUSTO DE &quot;EXPEDICAO&quot; PRODUTOS ITALAC</Data></Cell>      ')
AADD( _AXML,'   </Row>                                                                                                                              ')
AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                          ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                           ')
AADD( _AXML,'   </Row>                                                                                                                              ')

FOR _ni := 11 to len(_aCusto04)
	
	AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                      ')
	AADD( _AXML,'    <Cell ss:MergeAcross="3" ss:StyleID="m136891552"><Data ss:Type="String">' + ALLTRIM(_aCusto04[_ni,1] ) + '</Data></Cell>       ')
	AADD( _AXML,'    <Cell ss:StyleID="s86"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[_ni,2] )) + '</Data></Cell>                           ')
	AADD( _AXML,'    <Cell ss:StyleID="s87"><Data ss:Type="Number">' + ALLTRIM(STR( _aCusto04[_ni,3] )) + '</Data></Cell>                           ')
	AADD( _AXML,'    <Cell ss:StyleID="s88" ss:Formula="=IF(RC[-1]=0,0,RC[-1]/RC[-2])"><Data                                                        ')
	AADD( _AXML,'      ss:Type="Number">0</Data></Cell>                                                                                             ')
	AADD( _AXML,'   </Row>                                                                                                                          ')
	AADD( _AXML,'   <Row ss:AutoFitHeight="0">                                                                                                      ')
	AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                       ')
	AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                       ')
	AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                       ')
	AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                       ')
	AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                       ')
	AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                       ')
	AADD( _AXML,'    <Cell ss:StyleID="s63"/>                                                                                                       ')
	AADD( _AXML,'   </Row>                                                                                                                          ')
	
NEXT

AADD( _AXML,'  </Table>                                                                                                                             ')
AADD( _AXML,'  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">                                                                    ')
AADD( _AXML,'   <PageSetup>                                                                                                                         ')
AADD( _AXML,'    <Header x:Margin="0.31496062000000002"/>                                                                                           ')
AADD( _AXML,'    <Footer x:Margin="0.31496062000000002"/>                                                                                           ')
AADD( _AXML,'    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"                                                                   ')
AADD( _AXML,'     x:Right="0.511811024" x:Top="0.78740157499999996"/>                                                                               ')
AADD( _AXML,'   </PageSetup>                                                                                                                        ')
AADD( _AXML,'   <Unsynced/>                                                                                                                         ')
AADD( _AXML,'   <Print>                                                                                                                             ')
AADD( _AXML,'    <ValidPrinterInfo/>                                                                                                                ')
AADD( _AXML,'    <PaperSizeIndex>9</PaperSizeIndex>                                                                                                 ')
AADD( _AXML,'    <HorizontalResolution>600</HorizontalResolution>                                                                                   ')
AADD( _AXML,'    <VerticalResolution>600</VerticalResolution>                                                                                       ')
AADD( _AXML,'   </Print>                                                                                                                            ')
AADD( _AXML,'   <Selected/>                                                                                                                         ')
AADD( _AXML,'   <Panes>                                                                                                                             ')
AADD( _AXML,'    <Pane>                                                                                                                             ')
AADD( _AXML,'     <Number>3</Number>                                                                                                                ')
AADD( _AXML,'     <ActiveRow>9</ActiveRow>                                                                                                          ')
AADD( _AXML,'     <RangeSelection>R10C1:R10C4</RangeSelection>                                                                                      ')
AADD( _AXML,'    </Pane>                                                                                                                            ')
AADD( _AXML,'   </Panes>                                                                                                                            ')
AADD( _AXML,'   <ProtectObjects>False</ProtectObjects>                                                                                              ')
AADD( _AXML,'   <ProtectScenarios>False</ProtectScenarios>                                                                                          ')
AADD( _AXML,'  </WorksheetOptions>                                                                                                                  ')
AADD( _AXML,' </Worksheet>                                                                                                                          ')
AADD( _AXML,'</Workbook>                                                                                                                            ')


RETURN _AXML

/*
===============================================================================================================================
Programa----------: MEST9Locais()
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2018
Descricao---------: Devolve todos os armazens cadastrados 
Parametros--------: Nenhum
Retorno-----------: Locais
===============================================================================================================================
*/
Static Function MEST9Locais()
LOCAL _cQuery :="" 
LOCAL _cLocais:="" 

_cQuery	+= " SELECT NNR_CODIGO FROM " + RetSqlName("NNR") + " NNR WHERE "
_cQuery	+= "								      			  NNR.NNR_CODIGO NOT IN ('40','36','37') AND "
_cQuery	+= "								      			  NNR.D_E_L_E_T_ = ' ' AND "
_cQuery	+= "								      			  NNR.NNR_FILIAL = '" + xfilial("NNR")+"'"

MPSysOpenQuery( _cQuery , "TRBLocs" ) 

DO WHILE TRBLocs->(!EOF())
   _cLocais+=TRBLocs->NNR_CODIGO+";"
   TRBLocs->(dbskip())
ENDDO
TRBLocs->(DBCLOSEAREA())

RETURN _cLocais

/*
===============================================================================================================================
Programa----------: MEST9PLAN()
Autor-------------: Alex Wallauer
Data da Criacao---: 04/07/2018
Descricao---------: Função usada no ITALACXFUN.PRW - F3: LSTME9
Parametros--------: Nenhum
Retorno-----------: Planilhas disponiveis para Geração
===============================================================================================================================*/
USER Function MEST9PLAN()
LOCAL _aPlans:={}

AADD( _aPlans , "01-Operacional - PA,  Grupos (000001/000002/000003)            ")
AADD( _aPlans , "02-Custo / Estoque - MP,  Grupos (000004/000005), Depende do 01")
AADD( _aPlans , "03-Demonstrativo do Estoque Final,  Grupo (000006)             ")
AADD( _aPlans , "04-Espelho Composicao dos Custos, Depende do 01 e 02           ")

RETURN _aPlans

/*
===============================================================================================================================
Programa----------: MEST9Info()
Autor-------------: Alex Wallauer
Data da Criacao---: 10/07/2018
Descricao---------: Função usada no ITALACXFUN.PRW - F3: LSTMT9 / U_MEST9Info(ZL6->ZL6_OBSERV)
Parametros--------: Nenhum
Retorno-----------: Tipos do campo CAMPO ZL6_OBSERV Informação 
===============================================================================================================================*/
USER Function MEST9Info(cTipo)//U_MEST9Info("ACOLS")
LOCAL _aTipos:={},nPos
DEFAULT cTipo:=" "
//ANTIGO: 1=NOTA ENTRADA;2=NOTA SAIDA;3=MOVIMENTOS INTERNOS;4=FINANCEIRO;5=PERDAS;6=MO;7=HE;8=SALDO INICIAL;9=GESTAO LEITE;A=FRETE MP
//NOVO B: 1=NF ENTRADA;2=NF SAIDA;3=MOVIMENTOS INTERNOS;4=FINANCEIRO;5=PERDAS;6=MO;7=HE;8=SALDO INICIAL;9=GESTAO LEITE;A=FRETE MP;B=MANUAL
//NOVO E: 1=NFE;2=NFS;3=MOV INT;4=FIN;5=PERDAS;6=MO;7=HE;8=SLD INI;9=GLT;A=FRETE MP;B=MANUAL;C=NFE + ST;D=FECH CUSTO GER;E=ESTOQ FINAL
AADD( _aTipos , "1-NOTA ENTRADA              " )
AADD( _aTipos , "2-NOTA SAIDA                " )
AADD( _aTipos , "3-MOVIMENTOS INTERNOS       " )
AADD( _aTipos , "4-FINANCEIRO                " )
AADD( _aTipos , "5-PERDAS                    " )
AADD( _aTipos , "6-FOLHA DE PAGAMENTO        " )
AADD( _aTipos , "7-HORA EXTRA                " )
AADD( _aTipos , "8-SALDO INICIAL             " )
AADD( _aTipos , "9-GESTAO DE LEITE           " )//X
AADD( _aTipos , "A-FRETE MATERIA PRIMA       " )
AADD( _aTipos , "B-MANUAL                    " )
AADD( _aTipos , "C-NFE + SITUACAO TRIBUTARIA " )//X
AADD( _aTipos , "D-FECH CUSTO GERRENCIAL M.A." )
AADD( _aTipos , "E-ESTOQUE FINAL             " )
AADD( _aTipos , "F-EXCEDENTE MATERIA GORDA   " )
IF cTipo = " "
   RETURN _aTipos
ELSE
   IF cTipo = "BROWSES" .AND. (TYPE("M->ZL6_TPCUS") <> "C"  .OR. !EMPTY(M->ZL6_TPCUS))
      cTipo:=ZL6->ZL6_OBSERV
   ENDIF   
   IF (nPos:=ASCAN(_aTipos,{|T| UPPER(LEFT(T,1)) == UPPER(cTipo) } )) <> 0
      RETURN SUBSTR(_aTipos[nPos],3)
   ELSE
      RETURN "       "
   ENDIF   
ENDIF

/*
===============================================================================================================================
Programa----------: VolLeite(()
Autor-------------: Alex Wallauer
Data da Criacao---: 23/08/2018
Descrição---------: Retorna volume de leite (ZLD)
Parametros--------: _nSetor: Código do Setor
Retorno-----------: _nTotal	: Total do volume de leite
===============================================================================================================================*/
STATIC Function VolLeite( _cSetor )
Local _aArea	:= GetArea()
Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ''
Local _nTotal	:= 0

IF EMPTY(_cSetor)
   Return _nTotal 
ENDIF

//IF _nSlvVolLeite <> 0
//   Return _nSlvVolLeite
//ENDIF

_cQuery := " SELECT "
_cQuery += " 		SUM(ZLD_QTDBOM) AS TBOM "
_cQuery += " FROM  "+ RETSQLNAME( 'ZLD' ) +" ZLD "
_cQuery += " WHERE ZLD_SETOR  IN " + FormatIn(ALLTRIM(_cSetor),";")
_cQuery += " AND ZLD_DTCOLE BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
_cQuery += " AND ZLD.D_E_L_E_T_ = ' ' "

MPSysOpenQuery( _cQuery , _cAlias ) 

If (_cAlias)->( !Eof() )
	_nTotal  := (_cAlias)->TBOM
EndIf

(_cAlias)->( DBCloseArea() )

RestArea( _aArea )

//_nSlvVolLeite:=_nTotal 

Return _nTotal 

/*
===============================================================================================================================
Programa----------: GetVlrMix
Autor-------------: Alex Wallauer
Data da Criacao---: 23/08/2018
Descrição---------: Retorna total de movimentos na ZLF de determinado evento
Parametros--------: _cSetor  - Setor a ser considerado
Retorno-----------: _nTotal	: Total do volume de leite
===============================================================================================================================*/
STATIC FUNCTION GetVlrMix( _cSetor  )
Local cArea		:= GetArea()
Local cAliasLF	:= GetNextAlias()
Local _nTotal	:= 0

IF EMPTY(_cSetor)
   Return _nTotal 
ENDIF

//IF _nSlvGetVlrMix <> 0//Não dá mais par aslavar pq executa mais de uma vez com setores diferentes
//   Return _nSlvGetVlrMix
//ENDIF

// Obtendo movimentos na ZLF do grupo corrente                                  |
cQuery := " SELECT SUM( CASE WHEN ZLF.ZLF_DEBCRE = 'C' THEN ZLF.ZLF_TOTAL ELSE ZLF.ZLF_TOTAL * -1 END ) AS TOTAL "
cQuery += " FROM "+ RetSqlName("ZLF") +" ZLF "
cQuery += " WHERE D_E_L_E_T_	= ' ' "
cQuery += "  AND ZLF.ZLF_DTINI BETWEEN '" + DTOS(MV_PAR05) + "' AND '"+ DTOS(MV_PAR06) +"' "
cQuery += "  AND ZLF.ZLF_DTFIM BETWEEN '" + DTOS(MV_PAR05) + "' AND '"+ DTOS(MV_PAR06) +"' "
cQuery += "  AND ZLF_SETOR IN " + FormatIn(ALLTRIM(_cSetor),";")
cQuery += "  AND EXISTS ( SELECT ZL8.ZL8_COD "
cQuery += "              FROM "+ RetSqlName("ZL8") +" ZL8 "
cQuery += "              WHERE ZL8.D_E_L_E_T_ = ' '  "
cQuery += "              AND ZL8.ZL8_FILIAL = ZLF.ZLF_FILIAL "
cQuery += "              AND ZL8.ZL8_COD    = ZLF.ZLF_EVENTO "
cQuery += "              AND ZL8.ZL8_MIX    = 'S' ) "

MPSysOpenQuery( cQuery , cAliasLF ) 

IF (cAliasLF)->( !Eof() )
   _nTotal:= (cAliasLF)->TOTAL
ENDIF
(cAliasLF)->( DBCloseArea() )

//_nSlvGetVlrMix:=_nTotal

RestArea(cArea)
Return( _nTotal )


/*
===============================================================================================================================
Programa----------: CusFret2P
Autor-------------: Alex Wallauer
Data da Criacao---: 23/08/2018
Descrição---------: Retorna o total CUSTO FRETE 2º PERCURSO (SEM ICMS)
------------------: Baseado no RGLT013 - Recepção do Leite de Terceiros - Fatura de Frete
Parametros--------: _cFilis , _cTipos: F=LEITE FILIAIS, T=LEITE TERCEIRO, P=PLATAFORMA
------------------: _cGrpProd: 001 - LEITE IN-NATURA, 002 - SORO LIQUIDO, 003 - SORO CONCENTRADO, 004 - CREME
Retorno-----------: _aRet: {Volume,Valor}
===============================================================================================================================*/
STATIC FUNCTION CusFret2P(_cFiliais,_cTipos,_cGrpProd)
Local _aArea := GetArea()
Local _aRet  :={0,0,0}
Local _cQuery:= ""
Local _cAlias:= GetNextAlias()

_cQuery := " SELECT ZZX.ZZX_CODPRD ,"
_cQuery += "        SUM(ZLX_VOLREC) ZLX_VOLREC, "
_cQuery += "        SUM(ZLX_TVLFRT) ZLX_TVLFRT, "
_cQuery += "        SUM(ZLX_ICMSFR) ZLX_ICMSFR"

_cQuery += " FROM  "+ RETSQLNAME('ZLX') +" ZLX, "
_cQuery +=            RETSQLNAME('ZZX') +" ZZX "

_cQuery += " WHERE "+ RETSQLDEL( 'ZLX,ZZX' )
_cQuery += "   AND ZLX.ZLX_CODANA = ZZX.ZZX_CODIGO "
_cQuery += "   AND ZLX.ZLX_FILIAL = ZZX.ZZX_FILIAL "
_cQuery += "   AND ZLX.ZLX_PGFRT  = 'S' "
_cQuery += "   AND ZLX.ZLX_FILIAL IN "+FormatIn(ALLTRIM(_cFiliais),";") 
_cQuery += "   AND ZLX.ZLX_DTENTR BETWEEN '" + DTOS(MV_PAR05) + "' AND '"+ DTOS(MV_PAR06) +"' "
_cQuery += "   AND ZLX.ZLX_TIPOLT IN " + FormatIn(ALLTRIM(_cTipos),";")//F=LEITE FILIAIS //T=LEITE TERCEIRO //P=PLATAFORMA
_cQuery += "   AND ZZX.ZZX_CODPRD = '"+ _cGrpProd+"' "  // PRODUTOS:  //001 - LEITE IN-NATURA //002 - SORO LIQUIDO //003 - SORO CONCENTRADO //004 - CREME       
_cQuery += " GROUP BY ZZX_CODPRD"

MPSysOpenQuery( _cQuery , _cAlias ) 

DO While (_cAlias)->( !Eof() )

	_aRet[01] += (_cAlias)->ZLX_VOLREC                          //Volume Recebido
	IF MV_PAR13 = 2 //NAO
	   _aRet[02] += (_cAlias)->ZLX_TVLFRT//Total do Frete C/ ICMS
	ELSE
	   _aRet[02] += ((_cAlias)->ZLX_TVLFRT - (_cAlias)->ZLX_ICMSFR)//Total do Frete S/ ICMS
    ENDIF	
	_aRet[03] += (_cAlias)->ZLX_ICMSFR                          //Total ICMS
							
	(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

RestArea(_aArea)

Return(_aRet)

/*
==================================================================================================================================================
Programa----------: CusComICMS
Autor-------------: Alex Wallauer
Data da Criacao---: 30/08/2018
Descrição---------: Baseado no Relatório dos registros de recebimentos de leite de terceiros - Síntese de Recepções - RGLT033
Parametros--------: _cFilis,_cGrpProd: 001-LEITE IN-NATURA, 002-SORO LIQUIDO, 003-SORO CONCENTRADO, 004-CREME, 011-SORO PRE-CONCENTRADO
Retorno-----------: _aRet: {Volume,Valor}
==================================================================================================================================================
*/
STATIC FUNCTION CusComICMS(_cFilis,_cGrpProd)
Local _aArea := GetArea()
Local _aRet  :={0,0}
Local _cQuery:= ""
Local _cAlias:= GetNextAlias()

_cQuery += " SELECT "
_cQuery += "     ZLX.ZLX_TIPOLT ,"
_cQuery += "     ZLX.ZLX_FILIAL ,"
_cQuery += "     SUM(ZLX.ZLX_VOLREC) ZLX_VOLREC ,"/////////////////////  SOMA
//IF _cGrpProd == "004"
//   _cQuery += "     ROUND(  SUM( ZLX.ZLX_VOLREC * SC7.C7_PRECO ) + "
//ELSE
   _cQuery += "     ROUND( DECODE( ZZX.ZZX_CODPRD , '004' , 0 , SUM( ZLX.ZLX_VOLREC * SC7.C7_PRECO ) ) + "
//ENDIF
_cQuery += "     SUM((((NVL(ROUND((SELECT AVG(ZAP_GORD) "
_cQuery +=                        " FROM  "+ RETSQLNAME('ZAP') +" ZAP "
_cQuery +=                        " WHERE "+ RETSQLDEL('ZAP')
_cQuery +=                        " AND ZLX.ZLX_FILIAL = ZAP.ZAP_FILIAL "
_cQuery +=                        " AND ZLX.ZLX_CODANA = ZAP.ZAP_CODIGO ) , 2 ) , 0 ) - SC7.C7_L_PMGB ) * ZLX.ZLX_VOLREC ) / 100 ) "
_cQuery +=                        "    * SC7.C7_L_EXEMG ) , 2 ) VL_A_PAGAR "/////////////////////  SOMA
_cQuery += " FROM "
_cQuery += RETSQLNAME('ZLX') +" ZLX, "
_cQuery += RETSQLNAME('SD1') +" SD1, "
_cQuery += RETSQLNAME('SC7') +" SC7, "
_cQuery += RETSQLNAME('ZZX') +" ZZX  "

_cQuery += " WHERE "+ RETSQLDEL( 'ZLX,SD1,SC7,ZZX' )
_cQuery += " AND ZLX.ZLX_FILIAL = SC7.C7_FILIAL"
_cQuery += " AND SD1.D1_PEDIDO  = SC7.C7_NUM"
_cQuery += " AND SD1.D1_ITEMPC  = SC7.C7_ITEM"
_cQuery += " AND ZLX.ZLX_NRONF  = SD1.D1_DOC"
_cQuery += " AND ZLX.ZLX_SERINF = SD1.D1_SERIE"
_cQuery += " AND ZLX.ZLX_FORNEC = SD1.D1_FORNECE"
_cQuery += " AND ZLX.ZLX_LJFORN = SD1.D1_LOJA"
_cQuery += " AND ZLX.ZLX_FILIAL = SD1.D1_FILIAL"
_cQuery += " AND ZZX.ZZX_CODIGO = ZLX.ZLX_CODANA"
_cQuery += " AND ZLX.ZLX_FILIAL = ZZX.ZZX_FILIAL"
_cQuery += " AND SD1.D1_FORMUL  <> 'S'"

_cQuery += " AND ZLX.ZLX_TIPOLT <> 'P'"//"Terceiros" //F=LEITE FILIAIS //T=LEITE TERCEIRO //P=PLATAFORMA(LEITE PRATAFORMA)

_cQuery += " AND ZLX.ZLX_FILIAL IN "+ FormatIn( _cFilis , ';' )
_cQuery += " AND ZLX.ZLX_DTENTR BETWEEN '" + DTOS(MV_PAR05) + "' AND '"+ DTOS(MV_PAR06) +"' "//Data Inicial e final
IF !_cGrpProd $ "004/011"
   _cQuery += " AND ZZX.ZZX_FORNEC <> 'F00001' "//"Terceiros"
ENDIF
_cQuery += " AND SUBSTR(ZZX.ZZX_FORNEC,1,1) <> 'Z' "//"Terceiros"

_cQuery += " AND ZZX.ZZX_CODPRD = '"+ _cGrpProd+"' "// PRODUTOS:  //001 - LEITE IN-NATURA //002 - SORO LIQUIDO //003 - SORO CONCENTRADO //004 - CREME //011 SORO PRE-CONCENTRADO

_cQuery += " GROUP BY ZZX_CODPRD, ZLX.ZLX_TIPOLT, ZLX.ZLX_FILIAL"

nHandle := FCreate(_cdir+"MEST009_CusComICMS_"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
FWrite(nHandle, _cquery)
FClose(nHandle)

MPSysOpenQuery( _cQuery , _cAlias ) 

DO While (_cAlias)->( !Eof() )

   _aRet[01] += (_cAlias)->ZLX_VOLREC
   _aRet[02] += (_cAlias)->VL_A_PAGAR
							
	(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

RestArea(_aArea)

Return(_aRet)

/*
===============================================================================================================================
Programa----------: CusMGCMS
Autor-------------: Alex Wallauer
Data da Criacao---: 30/08/2018
Descrição---------: Baseado no Relatório dos registros de recebimentos de leite de terceiros - Síntese de Recepções - RGLT033
Parametros--------: _cFilis,
Retorno-----------: _aRet: {Volume,Valor}
===============================================================================================================================*/
STATIC FUNCTION CusMGCMS(_cFilis)
Local _aArea := GetArea()
Local _aRet  :={},X:=0
Local _cQuery:= ""
Local _cAlias:= GetNextAlias()
Local _cDtini:= DTOS(MV_PAR05) 
Local _cDtfim:= DTOS(MV_PAR06) 

IF LEN(_aSalvaCusMGCMS) > 0
   RETURN _aSalvaCusMGCMS
ENDIF

_cquery += " SELECT "
_cquery +=     " RES.ZZX_CODPRD,"
_cquery +=     " RES.ZLX_TIPOLT,"
_cquery +=     " NVL(ROUND(SUM(((( RES.MED_GOR - RES.C7_L_PMGB )* RES.ZLX_VOLREC )/100)),4),0) QTD_EMGKG, "
_cquery +=     " NVL(ROUND(SUM(((( RES.MED_GOR - RES.C7_L_PMGB )* RES.ZLX_VOLREC )/100)*RES. C7_L_EXEMG ),2),0) VLR_PGMG, "
_cquery +=     " NVL(SUM(RES.ZLX_ICMSNF)  ,0) ZLX_ICMSNF ," //Result.Cr. ICMS
_cquery +=     " NVL(AVG(RES.VL_ICMS_NF_C),0) VLR_ICMSC  ," //Cr. ICMS NFC
_cquery +=     " NVL(AVG(RES.VL_ICMS_NF_D),0) VLR_ICMSD   " //Déb. ICMS NFD
_cquery += " FROM (SELECT "
_cquery +=             " ZZX.ZZX_CODPRD,"
_cquery +=             " ZLX.ZLX_TIPOLT,"
_cquery +=             " ZLX.ZLX_FORNEC,"
_cquery +=             " ZLX.ZLX_LJFORN,"
_cquery +=             " ZLX.ZLX_CODANA,"
_cquery +=             " SC7.C7_L_EXEMG,"
_cquery +=             " SC7.C7_L_PMGB,"
_cquery +=             " SC7.C7_PRECO, "
_cquery +=             " SUM(ZLX.ZLX_VOLREC) ZLX_VOLREC,"
_cquery +=             " SUM(ZLX.ZLX_ICMSNF) ZLX_ICMSNF," //
_cquery +=             " ROUND(AVG(NVL((SELECT AVG(ZAP_GORD) "
_cquery +=                              " FROM "+ RETSQLNAME("ZAP") +" ZAP "
_cquery +=                             " WHERE ZAP.D_E_L_E_T_ = ' ' "
_cQuery +=                               " AND ZLX.ZLX_FILIAL = ZAP.ZAP_FILIAL "
_cquery +=                               " AND ZLX.ZLX_CODANA = ZAP.ZAP_CODIGO),0)),2) MED_GOR,"//
_cquery +=             " NVL(( SELECT SUM( SD1CI.D1_VALICM ) "
_cquery +=                     " FROM "+ RetSqlName('SD1') +" SD1CI "
_cquery +=                    " WHERE SD1CI.D_E_L_E_T_ = ' ' "
_cquery +=                      " AND SD1CI.D1_TIPO IN ('N','C') "
_cQuery +=                      " AND SD1CI.D1_FILIAL IN "+ FormatIn( Alltrim( _cFilis ) , ';' )
_cquery +=                      " AND EXISTS (SELECT 1 "
_cquery +=                                    " FROM "+ RetSqlName('ZLX') +" ZLXCI, "+ RetSqlName('ZZX') +" ZZXCI, "+ RetSqlName('SC7') +" SC7CI, "+ RetSqlName('SD1') +" SD1CCI "
_cquery +=                                   " WHERE ZLXCI.D_E_L_E_T_ = ' ' "
_cquery +=                                     " AND ZZXCI.D_E_L_E_T_ = ' ' "
_cquery +=                                     " AND SC7CI.D_E_L_E_T_ = ' ' "
_cquery +=                                     " AND SD1CCI.D_E_L_E_T_ = ' ' "
_cQuery +=                                     " AND ZLXCI.ZLX_FILIAL IN "+ FormatIn( Alltrim( _cFilis ) , ';' ) 
_cQuery +=                                     " AND ZZXCI.ZZX_FILIAL IN "+ FormatIn( Alltrim( _cFilis ) , ';' ) 
_cQuery +=                                     " AND SC7CI.C7_FILIAL IN "+  FormatIn( Alltrim( _cFilis ) , ';' ) 
_cQuery +=                                     " AND SD1CCI.D1_FILIAL IN "+ FormatIn( Alltrim( _cFilis ) , ';' ) 
_cquery +=                                     " AND ZLXCI.ZLX_FILIAL = ZZXCI.ZZX_FILIAL"
_cquery +=                                     " AND ZZXCI.ZZX_FILIAL = SC7CI.C7_FILIAL"
_cquery +=                                     " AND SC7CI.C7_FILIAL = SD1CCI.D1_FILIAL"
_cquery +=                                     " AND SD1CI.D1_FILIAL = SD1CCI.D1_FILIAL"
_cquery +=                                     " AND SD1CI.D1_FORNECE = ZLXCI.ZLX_FORNEC "
_cquery +=                                     " AND SD1CI.D1_LOJA = ZLXCI.ZLX_LJFORN "
_cquery +=                                     " AND SD1CI.D1_NFORI = ZLXCI.ZLX_NRONF "
_cquery +=                                     " AND SD1CI.D1_SERIORI = ZLXCI.ZLX_SERINF "
_cquery +=                                     " AND SD1CI.D1_FORNECE = SD1CCI.D1_FORNECE "
_cquery +=                                     " AND SD1CI.D1_LOJA = SD1CCI.D1_LOJA "
_cquery +=                                     " AND SD1CI.D1_NFORI = SD1CCI.D1_DOC "
_cquery +=                                     " AND SD1CI.D1_SERIORI = SD1CCI.D1_SERIE "
_cquery +=                                     " AND ZLXCI.ZLX_DTENTR BETWEEN '"+ _cDtini +"' AND '"+ _cDtfim +"' "
_cquery +=                                     " AND SD1CI.D1_FORNECE = ZLX.ZLX_FORNEC "
_cquery +=                                     " AND SD1CI.D1_LOJA = ZLX.ZLX_LJFORN "
_cquery +=                                     " AND ZZXCI.ZZX_CODIGO = ZLXCI.ZLX_CODANA "
_cquery +=                                     " AND ZZXCI.ZZX_CODPRD = ZZX_CODPRD "
_cquery +=                                     " AND SC7CI.C7_L_EXEMG = SC7.C7_L_EXEMG "
_cquery +=                                     " AND SC7CI.C7_L_PMGB = SC7.C7_L_PMGB "
_cquery +=                                     " AND SC7CI.C7_PRECO = SC7.C7_PRECO "
_cquery +=                                     " AND SD1CCI.D1_PEDIDO = SC7CI.C7_NUM "
_cquery +=                                     " AND SD1CCI.D1_ITEMPC = SC7CI.C7_ITEM)),0) VL_ICMS_NF_C,"  //
_cquery +=             " NVL(( SELECT SUM(SD2DI.D2_VALICM) "
_cquery +=                     " FROM "+ RetSqlName('SD2') +" SD2DI "
_cquery +=                    " WHERE SD2DI.D_E_L_E_T_ = ' ' "
_cquery +=                      " AND SD2DI.D2_TIPO IN ('B','D') "
_cQuery +=                      " AND SD2DI.D2_FILIAL IN "+ FormatIn( Alltrim( _cFilis ) , ';' )
_cquery +=                      " AND EXISTS (SELECT 1 "
_cquery +=                                    " FROM "+ RetSqlName('ZLX') +" ZLXDI, "+ RetSqlName('ZZX') +" ZZXDI, "+ RetSqlName('SC7') +" SC7DI, "+ RetSqlName('SD1') +" SD1DDI "
_cquery +=                                   " WHERE ZLXDI.D_E_L_E_T_  = ' ' "
_cquery +=                                     " AND ZZXDI.D_E_L_E_T_  = ' ' "
_cquery +=                                     " AND SC7DI.D_E_L_E_T_  = ' ' "
_cquery +=                                     " AND SD1DDI.D_E_L_E_T_ = ' ' "
_cQuery +=                                     " AND ZLXDI.ZLX_FILIAL IN "+ FormatIn( Alltrim( _cFilis ) , ';' ) 
_cQuery +=                                     " AND ZZXDI.ZZX_FILIAL IN "+ FormatIn( Alltrim( _cFilis ) , ';' ) 
_cQuery +=                                     " AND SC7DI.C7_FILIAL IN "+  FormatIn( Alltrim( _cFilis ) , ';' ) 
_cQuery +=                                     " AND SD1DDI.D1_FILIAL IN "+ FormatIn( Alltrim( _cFilis ) , ';' ) 
_cquery +=                                     " AND ZLXDI.ZLX_FILIAL = ZZXDI.ZZX_FILIAL"
_cquery +=                                     " AND ZZXDI.ZZX_FILIAL = SC7DI.C7_FILIAL"
_cquery +=                                     " AND SC7DI.C7_FILIAL = SD1DDI.D1_FILIAL"
_cquery +=                                     " AND SD2DI.D2_FILIAL = SD1DDI.D1_FILIAL"
_cquery +=                                     " AND SD2DI.D2_CLIENTE = ZLXDI.ZLX_FORNEC "
_cquery +=                                     " AND SD2DI.D2_LOJA = ZLXDI.ZLX_LJFORN "
_cquery +=                                     " AND SD2DI.D2_NFORI = ZLXDI.ZLX_NRONF "
_cquery +=                                     " AND SD2DI.D2_SERIORI = ZLXDI.ZLX_SERINF "
_cquery +=                                     " AND SD2DI.D2_CLIENTE = SD1DDI.D1_FORNECE "
_cquery +=                                     " AND SD2DI.D2_LOJA = SD1DDI.D1_LOJA "
_cquery +=                                     " AND SD2DI.D2_NFORI = SD1DDI.D1_DOC "
_cquery +=                                     " AND SD2DI.D2_SERIORI = SD1DDI.D1_SERIE "
_cquery +=                                     " AND ZLXDI.ZLX_DTENTR BETWEEN '"+ _cDtini +"' AND '"+ _cDtfim +"' "
_cquery +=                                     " AND SD2DI.D2_CLIENTE = ZLX.ZLX_FORNEC "
_cquery +=                                     " AND SD2DI.D2_LOJA = ZLX.ZLX_LJFORN "
_cquery +=                                     " AND ZZXDI.ZZX_CODIGO = ZLXDI.ZLX_CODANA "
_cquery +=                                     " AND ZZXDI.ZZX_CODPRD = ZZX_CODPRD "
_cquery +=                                     " AND SC7DI.C7_L_EXEMG = SC7.C7_L_EXEMG "
_cquery +=                                     " AND SC7DI.C7_L_PMGB = SC7.C7_L_PMGB "
_cquery +=                                     " AND SC7DI.C7_PRECO = SC7.C7_PRECO "
_cquery +=                                     " AND SD1DDI.D1_PEDIDO = SC7DI.C7_NUM "
_cquery +=                                     " AND SD1DDI.D1_ITEMPC = SC7DI.C7_ITEM)),0) VL_ICMS_NF_D "//,"
_cquery +=         " FROM "+ RETSQLNAME("ZLX") +" ZLX, "+RETSQLNAME("ZZX") +" ZZX, "
_cquery +=                   RETSQLNAME("ZZV") +" ZZV, "+RETSQLNAME("SC7") +" SC7 ,"+ RETSQLNAME("SD1") +" SD1 "
_cquery +=         " WHERE ZLX.D_E_L_E_T_ = ' ' "
_cquery +=           " AND ZZX.D_E_L_E_T_ = ' ' "
_cquery +=           " AND ZZV.D_E_L_E_T_ = ' ' "
_cquery +=           " AND SC7.D_E_L_E_T_ = ' ' "
_cquery +=           " AND SD1.D_E_L_E_T_ = ' ' "
_cQuery +=           " AND ZLX.ZLX_FILIAL IN "+ FormatIn( Alltrim( _cFilis ) , ';' ) 
_cQuery +=           " AND ZZX.ZZX_FILIAL IN "+ FormatIn( Alltrim( _cFilis ) , ';' ) 
_cQuery +=           " AND ZZV.ZZV_FILIAL IN "+ FormatIn( Alltrim( _cFilis ) , ';' ) 
_cQuery +=           " AND SC7.C7_FILIAL  IN "+ FormatIn( Alltrim( _cFilis ) , ';' ) 
_cQuery +=           " AND SD1.D1_FILIAL  IN "+ FormatIn( Alltrim( _cFilis ) , ';' ) 
_cquery +=           " AND ZLX.ZLX_FILIAL = ZZX.ZZX_FILIAL"
_cquery +=           " AND ZZX.ZZX_FILIAL = ZZV.ZZV_FILIAL"
_cquery +=           " AND ZZV.ZZV_FILIAL = SC7.C7_FILIAL"
_cquery +=           " AND SC7.C7_FILIAL = SD1.D1_FILIAL"
_cquery +=           " AND ZZX.ZZX_CODIGO = ZLX.ZLX_CODANA "
_cquery +=           " AND ZZX.ZZX_PLACA = ZZV.ZZV_PLACA "
_cquery +=           " AND ZZV.ZZV_TRANSP = ZLX.ZLX_TRANSP "
_cquery +=           " AND ZZV.ZZV_LJTRAN = ZLX.ZLX_LJTRAN "
_cquery +=           " AND SD1.D1_PEDIDO = SC7.C7_NUM "
_cquery +=           " AND SD1.D1_ITEMPC = SC7.C7_ITEM "
_cquery +=           " AND ZLX.ZLX_NRONF = SD1.D1_DOC "
_cquery +=           " AND ZLX.ZLX_SERINF = SD1.D1_SERIE "
_cquery +=           " AND ZLX.ZLX_FORNEC = SD1.D1_FORNECE "
_cquery +=           " AND ZLX.ZLX_LJFORN = SD1.D1_LOJA "
_cquery +=           " AND SD1.D1_FORMUL <> 'S' "
_cquery +=           " AND ZLX.ZLX_TIPOLT = 'T' "
_cquery +=           " AND ZLX.ZLX_DTENTR BETWEEN '"+ _cDtini +"' AND '"+ _cDtfim +"' "
_cquery +="      GROUP BY ZZX.ZZX_CODPRD,ZLX.ZLX_TIPOLT,ZLX.ZLX_FORNEC,ZLX.ZLX_LJFORN,ZLX.ZLX_CODANA,SC7.C7_L_EXEMG,SC7.C7_L_PMGB,SC7.C7_PRECO) RES "//*RES*
_cquery +="GROUP BY RES.ZZX_CODPRD, RES.ZLX_TIPOLT 

nHandle := FCreate(_cdir+"QUERY_G_"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
FWrite(nHandle, _cquery)
FClose(nHandle)

AADD(_aRet,{0,0,0})//"001"
AADD(_aRet,{X,X,0})//"002"// X posiçoes que podem vir a ser usadas
AADD(_aRet,{X,X,0})//"003"// X posiçoes que podem vir a ser usadas
AADD(_aRet,{X,X,0})//"004"// X posiçoes que podem vir a ser usadas

IF MV_PAR13 = 2 //NÃO
   Return(_aRet)
ENDIF

MPSysOpenQuery( _cQuery , _cAlias ) 

DO While (_cAlias)->( !Eof() )

   IF (_cAlias)->ZZX_CODPRD = "001"    //001 - LEITE IN-NATURA
      _aRet[1,1] += (_cAlias)->QTD_EMGKG
      _aRet[1,2] += (_cAlias)->VLR_PGMG
      _aRet[1,3] +=((_cAlias)->ZLX_ICMSNF + (_cAlias)->VLR_ICMSC - (_cAlias)->VLR_ICMSD)
   ELSEIF (_cAlias)->ZZX_CODPRD = "002"//002 - SORO LIQUIDO
      _aRet[2,3] +=((_cAlias)->ZLX_ICMSNF + (_cAlias)->VLR_ICMSC - (_cAlias)->VLR_ICMSD)
   ELSEIF (_cAlias)->ZZX_CODPRD = "003"//003 - SORO CONCENTRADO
      _aRet[3,3] +=((_cAlias)->ZLX_ICMSNF + (_cAlias)->VLR_ICMSC - (_cAlias)->VLR_ICMSD)
   ELSEIF (_cAlias)->ZZX_CODPRD = "004"//004 - CREME
      _aRet[4,3] +=((_cAlias)->ZLX_ICMSNF + (_cAlias)->VLR_ICMSC - (_cAlias)->VLR_ICMSD)
   ENDIF   

	(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

RestArea(_aArea)

_aSalvaCusMGCMS:=_aRet

Return(_aRet)

/*
===============================================================================================================================
Programa----------: MEST9ICMS
Autor-------------: Alex Walaluer
Data da Criacao---: 02/04/2019
Descricao---------: Retorna valores de cada ICMS e carga nas variaveis private
Parametros--------: Tipo do ICMS,_cChave
Retorno-----------: VALORES DO PREÇO MEDIO de cada ICMS
===============================================================================================================================
*/
Static Function MEST9ICMS(cTipoICMS,_cChave,_cFilis)
Local _cQuery1   := ""
Local _cQuery2   := ""
Local _cQuery3   := ""
Local _caRIcmEst := ""
Local _caRIcmInt := ""
Local _caRIcmTrs := ""
Local _cGrpCus   := ""
Local _cEstFilAnt:= ""
Local _nValor    := _nQtde := 0 , I
Local _lAtivaLOG := .F.

IF cTipoICMS == "CARGA_VARIAVEIS_ICMS"

	_nVlrIcm :=_nVIcmEst:=_nVIcmInt:=_nVIcmTrs:=_nDifAlq:=0//Variaveis antigas
    _nICMSEst:=_nICMSInt:=_nICMSTrs:=0//Variaveis novas valores preco medio
    nDespEst := nOprsEst:=0//Variaveis novas para calcular o percentual
    nDespInt := nOprsInt:=0//Variaveis novas para calcular o percentual
    nDespTrs := nOprsTrs:=0//Variaveis novas para calcular o percentual

    _cProduto := ALLTRIM(Posicione("ZL6",8,_cChave,"ZL6_CODPRO"))//TEM QUE SER PRIVATE PQ É UMA FUNÇÃO MEST9ICMS() RECURSIVA
	_caRIcmEst:= ALLTRIM(Posicione("ZL6",8,_cChave,"ZL6_REGICE"))
	_caRIcmInt:= ALLTRIM(Posicione("ZL6",8,_cChave,"ZL6_REGICI"))
	_caRIcmTrs:= ALLTRIM(Posicione("ZL6",8,_cChave,"ZL6_REGICT"))
    _cSegUni  := ALLTRIM(Posicione("ZL6",8,_cChave,"ZL6_TUNID" ))

//  _nDifAlq  := ALLTRIM(Posicione("ZL6",8,_cChave,"ZL6_DIFALQ")//NÃO USA MAIS ESSE CAMPO
    _nDifAlq  := MEST9ICMS("DIFERENCIAL",_cChave)

    _cValores:=_caRIcmEst+CHR(13)+CHR(10)
    _cValores+=_caRIcmInt+CHR(13)+CHR(10)
    _cValores+=_caRIcmTrs+CHR(13)+CHR(10)    

    IF EMPTY(_caRIcmEst)
	   _nVIcmEst:= Posicione("ZL6",8,_cChave,"ZL6_VICMSE")//valor do jeito antigo
	ELSE   
	   _caRIcmEst:=STRTOKARR(_caRIcmEst,";")
       _nICMSEst :=MEST9ICMS("ESTADUAL",_cChave)

       _dDtSeek:=STRZERO(MONTH(MV_PAR05),2)+ALLTRIM(STR(YEAR(MV_PAR05)))
       FOR I := 1 TO LEN(_caRIcmEst)
           IF ZM1->(DBSEEK(xFilial()+_dDtSeek+_caRIcmEst[I] ))
              nDespEst += ZM1->ZM1_DESP
   	          nOprsEst +=(ZM1->ZM1_VLROP - ZM1->ZM1_VLROPD)
	       ENDIF   
           _cValores+=_dDtSeek+" "+_caRIcmEst[I]+" D: "+STR(ZM1->ZM1_DESP,22,7)+CHR(13)+CHR(10)
           _cValores+=_dDtSeek+" "+_caRIcmEst[I]+" O: "+STR((ZM1->ZM1_VLROP - ZM1->ZM1_VLROPD),22,7)+CHR(13)+CHR(10)
       NEXT
       _cValores+=_dDtSeek+" T. D.: "+STR((nDespEst),22,7)+CHR(13)+CHR(10)
       _cValores+=_dDtSeek+" T. O.: "+STR((nOprsEst),22,7)+CHR(13)+CHR(10)

       IF  nDespEst > 0
	      _nVIcmEst:=(nDespEst/nOprsEst)*_nICMSEst//Falta multiplicar pela quantidade
	   ENDIF   

	ENDIF   

    IF EMPTY(_caRIcmInt)
	   _nVIcmInt:= Posicione("ZL6",8,_cChave,"ZL6_VICMSI")//valor do jeito antigo
	ELSE   
	   _nVIcmInt :=0
	   _caRIcmInt:=STRTOKARR(_caRIcmInt,";") 
       _nICMSInt :=MEST9ICMS("INTERESTADUAL",_cChave)

       _dDtSeek:=STRZERO(MONTH(MV_PAR05),2)+ALLTRIM(STR(YEAR(MV_PAR05)))
       FOR I := 1 TO LEN(_caRIcmInt)
           IF ZM1->(DBSEEK(xFilial()+_dDtSeek+_caRIcmInt[I] ))
              nDespInt += ZM1->ZM1_DESP
	          nOprsInt +=(ZM1->ZM1_VLROP - ZM1->ZM1_VLROPD)
	       ENDIF   
           _cValores+=_dDtSeek+" "+_caRIcmInt[I]+" D: "+STR(ZM1->ZM1_DESP,22,7)+CHR(13)+CHR(10)
           _cValores+=_dDtSeek+" "+_caRIcmInt[I]+" O: "+STR((ZM1->ZM1_VLROP - ZM1->ZM1_VLROPD),22,7)+CHR(13)+CHR(10)
       NEXT
       _cValores+=_dDtSeek+" T. D.: "+STR((nDespInt),22,7)+CHR(13)+CHR(10)
       _cValores+=_dDtSeek+" T. O.: "+STR((nOprsInt),22,7)+CHR(13)+CHR(10)

       IF nDespInt > 0
	      _nVIcmInt :=(nDespInt/nOprsInt)*_nICMSInt//Falta multiplicar pela quantidade
       ENDIF
	ENDIF   

    IF EMPTY(_caRIcmTrs)
	   _nVIcmTrs:= Posicione("ZL6",8,_cChave,"ZL6_VICMST")//valor do jeito antigo
	ELSE   
	   _nVIcmTrs :=0
	   _caRIcmTrs:=STRTOKARR(_caRIcmTrs,";")
       _nICMSTrs :=MEST9ICMS("TRANSFERENCIA",_cChave)

       _dDtSeek:=STRZERO(MONTH(MV_PAR05),2)+ALLTRIM(STR(YEAR(MV_PAR05)))
        FOR I := 1 TO LEN(_caRIcmTrs)
            IF ZM1->(DBSEEK(xFilial()+_dDtSeek+_caRIcmTrs[I] ))
               nDespTrs += ZM1->ZM1_DESP
	           nOprsTrs +=(ZM1->ZM1_VLROP - ZM1->ZM1_VLROPD)
	        ENDIF   
            _cValores+=_dDtSeek+" "+_caRIcmTrs[I]+" D: "+STR(ZM1->ZM1_DESP,22,7)+CHR(13)+CHR(10)
            _cValores+=_dDtSeek+" "+_caRIcmTrs[I]+" O: "+STR((ZM1->ZM1_VLROP - ZM1->ZM1_VLROPD),22,7)+CHR(13)+CHR(10)
        NEXT
        _cValores+=_dDtSeek+" T. D.: "+STR((nDespTrs),22,7)+CHR(13)+CHR(10)
        _cValores+=_dDtSeek+" T. O.: "+STR((nOprsTrs),22,7)+CHR(13)+CHR(10)

       IF nDespTrs > 0
	      _nVIcmTrs :=(nDespTrs/nOprsTrs)*_nICMSTrs//Falta multiplicar pela quantidade
	   ENDIF   

	ENDIF   

    IF _lAtivaLOG
       nHandle := FCreate(_cdir+"VAL_ICMS_"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
       FWrite(nHandle, _cValores )
       FClose(nHandle)
	ENDIF   
    
    RETURN 0 //RETORNO DO "CARGA_VARIAVEIS_ICMS"

ELSEIF cTipoICMS == "ESTADUAL"

   //Preço médio Estadual (quant e valor)
   //Select Vendas:
/*   "SELECT SUM(D2_TOTAL) as VLR, SUM(D2_QUANT) as QTD FROM "
	            "SD2010 SD2 JOIN ZAY010 ZAY ON D2_CF = ZAY_CF " 
	            "WHERE D2_FILIAL = '01' AND  D2_EMISSAO BETWEEN '20181201' AND '20181231' AND   D2_TP = 'PA' " 
	            "AND D2_GRUPO     IN ('0001') AND ZAY_TPOPER = 'V' AND  D2_EST = '"+_cEstFilAnt+"' " 
	            "AND  SD2.D_E_L_E_T_ = ' ' AND  ZAY.D_E_L_E_T_ = ' ' "*/
   _cEstFilAnt:= Posicione("ZZM",1,xFilial("ZZM")+cFilAnt,"ZZM_EST")

   _cQuery1 := " SELECT SUM(D2_TOTAL) AS VLR, "
   IF _cSegUni = "S"
      _cQuery1 += " SUM(D2_QTSEGUM) as QTD "
   ELSE   
      _cQuery1 += " SUM(D2_QUANT) as QTD "
   ENDIF
   _cQuery1 += " FROM "+ RETSQLNAME("SD2")+" SD2 "  
   _cQuery1 += " JOIN  "+RETSQLNAME("ZAY")+" ZAY ON D2_CF = ZAY_CF "
   _cQuery1 += "  WHERE SD2.D_E_L_E_T_ = ' ' AND ZAY.D_E_L_E_T_ = ' ' "
   _cQuery1 += "    AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
   _cQuery1 += "    AND SD2.D2_FILIAL = '" + xfilial("SD2") + "'"
   _cQuery1 += "    AND ZAY_TPOPER = 'V' AND  D2_EST = '"+_cEstFilAnt+"' "
   _cQuery1 += "    AND D2_TP = 'PA'" 
   IF !EMPTY(_cProduto)
      _cQuery1 += " AND SD2.D2_COD IN " + FormatIn(ALLTRIM(_cproduto),";")
   ENDIF   
   IF !EMPTY(_cGrpCus)
      _cQuery1 += " AND SD2.D2_GRUPO IN " + FormatIn(ALLTRIM(_cGrpCus),";")
   ENDIF   

//	+ 
//	Select Bonificações
/*   "SELECT 0 as VLR, SUM(D2_QUANT) as QTD FROM " & _
	            "SD2010 SD2 JOIN ZAY010 ZAY ON D1_CF = ZAY_CF " & _
	            "WHERE D2_FILIAL = '01' AND  D2_EMISSAO BETWEEN '20181201' AND '20181231' AND   D2_TP = 'PA' " & _
	            "AND D2_GRUPO     IN ('0001') AND ZAY_TPOPER = 'B' AND  D2_EST = 'GO' " & _
	            "AND  SD1.D_E_L_E_T_ = ' ' AND  ZAY.D_E_L_E_T_ = ' ' "*/
   _cQuery2 := " SELECT 0 AS VLR, "
   IF _cSegUni = "S"
      _cQuery2 += " SUM(D2_QTSEGUM) as QTD "
   ELSE   
      _cQuery2 += " SUM(D2_QUANT) as QTD "
   ENDIF
   _cQuery2 += " FROM "+ RETSQLNAME("SD2")+" SD2 "  
   _cQuery2 += " JOIN  "+RETSQLNAME("ZAY")+" ZAY ON D2_CF = ZAY_CF "
   _cQuery2 += "  WHERE SD2.D_E_L_E_T_ = ' ' AND ZAY.D_E_L_E_T_ = ' ' "
   _cQuery2 += "    AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
   _cQuery2 += "    AND SD2.D2_FILIAL = '" + xfilial("SD2") + "'"
   _cQuery2 += "    AND ZAY_TPOPER = 'B' AND  D2_EST = '"+_cEstFilAnt+"' "
   _cQuery2 += "    AND D2_TP = 'PA'" 
   IF !EMPTY(_cProduto)
      _cQuery2 += " AND SD2.D2_COD IN " + FormatIn(ALLTRIM(_cproduto),";")
   ENDIF   
   IF !EMPTY(_cGrpCus)
      _cQuery2 += " AND SD2.D2_GRUPO IN " + FormatIn(ALLTRIM(_cGrpCus),";")
   ENDIF   

//	(-)
//	Select Devoluções
/*	    "SELECT SUM(D1_TOTAL) as VLR, SUM(D1_QUANT) as QTD FROM " & _
	            "SD1010 SD1 JOIN SF1010 SF1 ON F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA " & _
	            "WHERE D1_FILIAL = '01' AND  D1_DTDIGIT BETWEEN '20181201' AND '20181231' " & _
	            "AND D1_TP = 'PA' AND D1_TIPO = 'D' AND D1_FORMUL = 'S' " & _
	            "AND D1_GRUPO IN ('0001') AND  F1_EST = 'GO' " & _
	            "AND  SD1.D_E_L_E_T_ = ' ' AND  SF1.D_E_L_E_T_ = ' ' "*/

	_cQuery3:="SELECT SUM(D1_TOTAL) AS VLR, "
    IF _cSegUni = "S"
       _cQuery3 += " SUM(D1_QTSEGUM) as QTD "
    ELSE   
       _cQuery3 += " SUM(D1_QUANT) as QTD "
    ENDIF
	_cQuery3+="       FROM "+RETSQLNAME("SD1")+" SD1"
	_cQuery3+="       JOIN "+RETSQLNAME("SF1")+" SF1 ON D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA "  
	_cQuery3+=" WHERE SD1.D1_FILIAL = '"+cFilAnt+"'"
	_cQuery3+="   AND SD1.D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
	_cQuery3+="   AND SD1.D1_TP = 'PA' AND D1_TIPO = 'D' AND D1_FORMUL = 'S' " 
	_cQuery3+="   AND SF1.F1_EST = '"+_cEstFilAnt+"' "
	_cQuery3+="   AND SD1.D_E_L_E_T_ = ' ' AND  SF1.D_E_L_E_T_ = ' ' "
	_cQuery3+="   AND SD1.D1_CF NOT IN ('1208','1209','2208','2209') "
    IF !EMPTY(_cProduto)
        _cQuery3 += " AND SD1.D1_COD IN " + FormatIn(ALLTRIM(_cproduto),";")
     ENDIF   
     IF !EMPTY(_cGrpCus)
        _cQuery3 += " AND SD1.D1_GRUPO IN " + FormatIn(ALLTRIM(_cGrpCus),";")
     ENDIF   
//	=
//	Resultado = soma(VLR) / soma(QTD) 

ELSEIF cTipoICMS == "INTERESTADUAL"
   //Preço médio Estadual (quant e valor)
   //Select Vendas:
   _cEstFilAnt:= Posicione("ZZM",1,xFilial("ZZM")+cFilAnt,"ZZM_EST")

   _cQuery1 := " SELECT SUM(D2_TOTAL) AS VLR,  "
   IF _cSegUni = "S"
      _cQuery1 += " SUM(D2_QTSEGUM) as QTD "
   ELSE   
      _cQuery1 += " SUM(D2_QUANT) as QTD "
   ENDIF
   _cQuery1 += " FROM "+ RETSQLNAME("SD2")+" SD2 "  
   _cQuery1 += " JOIN  "+RETSQLNAME("ZAY")+" ZAY ON D2_CF = ZAY_CF "
   _cQuery1 += "  WHERE SD2.D_E_L_E_T_ = ' ' AND ZAY.D_E_L_E_T_ = ' ' "
   _cQuery1 += "    AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
   _cQuery1 += "    AND SD2.D2_FILIAL = '" + xfilial("SD2") + "'"
   _cQuery1 += "    AND ZAY_TPOPER = 'V' AND  D2_EST <> '"+_cEstFilAnt+"' "
   _cQuery1 += "    AND D2_TP = 'PA'" 
   IF !EMPTY(_cProduto)
      _cQuery1 += " AND SD2.D2_COD IN " + FormatIn(ALLTRIM(_cproduto),";")
   ENDIF   
   IF !EMPTY(_cGrpCus)
      _cQuery1 += " AND SD2.D2_GRUPO IN " + FormatIn(ALLTRIM(_cGrpCus),";")
   ENDIF   

//	+ 
//	Select Bonificações
   _cQuery2 := " SELECT 0 AS VLR, "
   IF _cSegUni = "S"
      _cQuery2 += " SUM(D2_QTSEGUM) as QTD "
   ELSE   
      _cQuery2 += " SUM(D2_QUANT) as QTD "
   ENDIF
   _cQuery2 += " FROM "+ RETSQLNAME("SD2")+" SD2 "  
   _cQuery2 += " JOIN  "+RETSQLNAME("ZAY")+" ZAY ON D2_CF = ZAY_CF "
   _cQuery2 += "  WHERE SD2.D_E_L_E_T_ = ' ' AND ZAY.D_E_L_E_T_ = ' ' "
   _cQuery2 += "    AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
   _cQuery2 += "    AND SD2.D2_FILIAL = '" + xfilial("SD2") + "'"
   _cQuery2 += "    AND ZAY_TPOPER = 'B' AND  D2_EST <> '"+_cEstFilAnt+"' "
   _cQuery2 += "    AND D2_TP = 'PA'" 
   IF !EMPTY(_cProduto)
      _cQuery2 += " AND SD2.D2_COD IN " + FormatIn(ALLTRIM(_cproduto),";")
   ENDIF   
   IF !EMPTY(_cGrpCus)
      _cQuery2 += " AND SD2.D2_GRUPO IN " + FormatIn(ALLTRIM(_cGrpCus),";")
   ENDIF   

//	(-)
//	Select Devoluções
	_cQuery3:="SELECT SUM(D1_TOTAL) AS VLR, "
    IF _cSegUni = "S"
       _cQuery3 += " SUM(D1_QTSEGUM) as QTD "
    ELSE   
       _cQuery3 += " SUM(D1_QUANT) as QTD "
    ENDIF
	_cQuery3+="       FROM "+RETSQLNAME("SD1")+" SD1"
	_cQuery3+="       JOIN "+RETSQLNAME("SF1")+" SF1 ON D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA "  
	_cQuery3+=" WHERE SD1.D1_FILIAL = '"+cFilAnt+"'"
	_cQuery3+="   AND SD1.D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
	_cQuery3+="   AND SD1.D1_TP = 'PA' AND D1_TIPO = 'D' AND D1_FORMUL = 'S' " 
	_cQuery3+="   AND SF1.F1_EST <> '"+_cEstFilAnt+"' "
	_cQuery3+="   AND SD1.D_E_L_E_T_ = ' ' AND  SF1.D_E_L_E_T_ = ' ' "
	_cQuery3+="   AND SD1.D1_CF NOT IN ('1208','1209','2208','2209') "
    IF !EMPTY(_cProduto)
        _cQuery3 += " AND SD1.D1_COD IN " + FormatIn(ALLTRIM(_cproduto),";")
     ENDIF   
     IF !EMPTY(_cGrpCus)
        _cQuery3 += " AND SD1.D1_GRUPO IN " + FormatIn(ALLTRIM(_cGrpCus),";")
     ENDIF   
//	=
//	Resultado = soma(VLR) / soma(QTD) 

ELSEIF cTipoICMS == "TRANSFERENCIA"
	
	//Preço médio Transferencia
	//	select saídas:
	/*   "SELECT SUM(D2_TOTAL) as VLR, SUM(D2_QUANT) as QTD FROM " & _
	"SD2010 SD2 JOIN ZAY010 ZAY ON D1_CF = ZAY_CF " & _
	"WHERE D2_FILIAL = '01' AND  D2_EMISSAO BETWEEN '20181201' AND '20181231' AND   D2_TP = 'PA' " & _
	"AND D2_GRUPO     IN ('0001') AND ZAY_TPOPER = 'T' " & _
	"AND  SD1.D_E_L_E_T_ = ' ' AND  ZAY.D_E_L_E_T_ = ' ' "*/
	
	_cQuery1 := " SELECT SUM(D2_TOTAL) AS VLR,  "
    IF _cSegUni = "S"
       _cQuery1 += " SUM(D2_QTSEGUM) as QTD "
    ELSE   
       _cQuery1 += " SUM(D2_QUANT) as QTD "
    ENDIF
	_cQuery1 += " FROM "+ RETSQLNAME("SD2")+" SD2 "
	_cQuery1 += " JOIN  "+RETSQLNAME("ZAY")+" ZAY ON D2_CF = ZAY_CF "
	_cQuery1 += "  WHERE SD2.D_E_L_E_T_ = ' ' AND ZAY.D_E_L_E_T_ = ' ' "
	_cQuery1 += "    AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
	_cQuery1 += "    AND SD2.D2_FILIAL = '" + xfilial("SD2") + "'"
	_cQuery1 += "    AND ZAY_TPOPER = 'T' "
	_cQuery1 += "    AND D2_TP = 'PA'"
	IF !EMPTY(_cProduto)
		_cQuery1 += " AND SD2.D2_COD IN " + FormatIn(ALLTRIM(_cproduto),";")
	ENDIF
	IF !EMPTY(_cGrpCus)
		_cQuery1 += " AND SD2.D2_GRUPO IN " + FormatIn(ALLTRIM(_cGrpCus),";")
	ENDIF
	
	//	(-)
	//	Select Devoluções:
	/*	    "SELECT SUM(D1_TOTAL) as VLR, SUM(D1_QUANT) as QTD FROM " & _
	"SD1010 SD1 JOIN SF1010 SF1 ON F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA " & _
	"WHERE D1_FILIAL = '01' AND  D1_DTDIGIT BETWEEN '20181201' AND '20181231' " & _
	"AND D1_TP = 'PA' AND D1_TIPO = 'D' AND D1_FORMUL = 'S' " & _
	"AND D1_GRUPO IN ('0001') " & _
	"AND  SD1.D_E_L_E_T_ = ' ' AND  SF1.D_E_L_E_T_ = ' ' "*/
	
	_cQuery2:="SELECT SUM(D1_TOTAL) AS VLR, "
    IF _cSegUni = "S"
       _cQuery2 += " SUM(D1_QTSEGUM) as QTD "
    ELSE   
       _cQuery2 += " SUM(D1_QUANT) as QTD "
    ENDIF
	_cQuery2+="       FROM "+RETSQLNAME("SD1")+" SD1"
	_cQuery2+="       JOIN "+RETSQLNAME("SF1")+" SF1 ON D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA "
	_cQuery2+=" WHERE SD1.D1_FILIAL = '"+cFilAnt+"'"
	_cQuery2+="   AND SD1.D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
	_cQuery2+="   AND SD1.D1_TP = 'PA' AND D1_TIPO = 'D' AND D1_FORMUL = 'S' "
	_cQuery2+="   AND SD1.D_E_L_E_T_ = ' ' AND  SF1.D_E_L_E_T_ = ' ' "
	_cQuery2+="   AND SD1.D1_CF IN ('1208','1209','2208','2209') "
	IF !EMPTY(_cProduto)
		_cQuery2 += " AND SD1.D1_COD IN " + FormatIn(ALLTRIM(_cproduto),";")
	ENDIF
	IF !EMPTY(_cGrpCus)
		_cQuery2 += " AND SD1.D1_GRUPO IN " + FormatIn(ALLTRIM(_cGrpCus),";")
	ENDIF
	//	=
	//	Resultado = soma(VLR) / soma(QTD)
	_cValores:=_cQuery1+ENTER+ENTER
	_cValores+=_cQuery2+ENTER+ENTER
	
    IF _lAtivaLOG
	nHandle := FCreate(_cdir+"SELECT_ICMS__"+cTipoICMS+"__"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
	FWrite(nHandle, _cValores )
	FClose(nHandle)
	ENDIF
	
	MPSysOpenQuery( _cQuery1 ,"Q1" )
	
	MPSysOpenQuery( _cQuery2 ,"Q2" )
	
	_cValores:=_cQuery1+ENTER+ENTER
	If .NOT. Q1->( Eof() )
		_nValor+=Q1->VLR
		_nQtde+=Q1->QTD
	Endif
	_cValores+=STR(Q1->VLR,22,7)+ENTER
	_cValores+=STR(Q1->QTD,22,7)+ENTER+ENTER
	
	_cValores+=_cQuery2+ENTER+ENTER
	If .NOT. Q2->( Eof() )
		_nValor-=Q2->VLR
		_nQtde-=Q2->QTD
	Endif
	_cValores+=STR(Q2->VLR,22,7)+ENTER
	_cValores+=STR(Q2->QTD,22,7)+ENTER+ENTER
	
	_cValores+=STR(_nValor,22,7)+ENTER
	_cValores+=STR(_nQtde,22,7)+ENTER
	
	_nValor:=(_nValor/_nQtde)
	
	_cValores+=STR(_nValor,22,7)+ENTER
	
    IF _lAtivaLOG
	nHandle := FCreate(_cdir+"SELECT_VAL_ICMS__"+cTipoICMS+"__"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
	FWrite(nHandle, _cValores )
	FClose(nHandle)
	ENDIF
	Q1->( DbClosearea() )
	Q2->( DbClosearea() )
	
	RETURN _nValor//RETORNO DO "TRANSFERENCIA"

ELSEIF cTipoICMS == "DIFERENCIAL"

	_cQuery1:="SELECT SUM(D1_ICMSCOM) AS VLR  FROM "+RETSQLNAME("SD1")+" SD1"
	_cQuery1+=" WHERE SD1.D1_FILIAL = '"+cFilAnt+"'"
	_cQuery1+="   AND SD1.D_E_L_E_T_ = ' ' AND D1_ICMSCOM > 0 "
	_cQuery1+="   AND SD1.D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
	_cQuery1+="   AND SD1.D1_TP = 'PA' AND D1_TIPO = 'N'  " 
	_cQuery1+="   AND SD1.D1_CF IN ('1151','1152','2151','2152') "
    IF !EMPTY(_cProduto)
        _cQuery1 += " AND SD1.D1_COD IN " + FormatIn(ALLTRIM(_cproduto),";")
     ENDIF   
     IF !EMPTY(_cGrpCus)
        _cQuery1 += " AND SD1.D1_GRUPO IN " + FormatIn(ALLTRIM(_cGrpCus),";")
     ENDIF   

	MPSysOpenQuery( _cQuery1 ,"Q1" )
	
	_cValores:=_cQuery1+ENTER+ENTER
	If .NOT. Q1->( Eof() )
		_nValor:=Q1->VLR
	Endif
	
	_cValores+=STR(_nValor,22,7)+ENTER
	
    IF _lAtivaLOG
	nHandle := FCreate(_cdir+"SELECT_VAL_ICMS__"+cTipoICMS+"__"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
	FWrite(nHandle, _cValores )
	FClose(nHandle)
	ENDIF
	Q1->( DbClosearea() )

	RETURN _nValor//RETORNO DO "DIFERENCIAL"

ELSEIF cTipoICMS == "FUNDOLEITE"// = FUNDOPEM

/* SELECT SUM(E5_VALOR) FROM siga.SE5010 WHERE siga.SE5010.D_E_L_E_T_ = ' ' AND E5_FILIAL IN ('parâmetro')  
   AND E5_DATA BETWEEN '20190201' AND '20190228'
   AND E5_LA = 'S' AND E5_CLIFOR = 'F02069' AND E5_HISTOR like '%FUNDOLEITE%'*/   
	_cQuery1:="SELECT SUM(E5_VALOR) AS VLR  FROM "+RETSQLNAME("SE5")+" SE5"
	_cQuery1+=" WHERE SE5.E5_FILIAL IN "+FormatIn(ALLTRIM(_cFilis),";") 
	_cQuery1+="   AND SE5.D_E_L_E_T_ = ' ' "
	_cQuery1+="   AND SE5.E5_DATA BETWEEN '"+DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
	_cQuery1+="   AND SE5.E5_LA = 'S' AND E5_HISTOR LIKE '%FUNDOLEITE%'" //E5_CLIFOR = 'F02069' AND 

	MPSysOpenQuery( _cQuery1 ,"Q1" )
	
	_cValores:=_cQuery1+ENTER+ENTER
	If .NOT. Q1->( Eof() )
		_nValor:=Q1->VLR
	Endif
	
	IF TYPE("_nPerc") = "N"
	   _cValores+="_nPerc :"+STR(_nPerc,22,7)+ENTER
	ENDIF   
	_cValores+=STR(_nValor,22,7)+ENTER
	
    IF _lAtivaLOG
  	   nHandle := FCreate(_cdir+"SELECT_VAL_ICMS__"+cTipoICMS+"__"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
  	   FWrite(nHandle, _cValores )
  	   FClose(nHandle)
  	ENDIF
	
	Q1->( DbClosearea() )

	RETURN _nValor//RETORNO DO "DIFERENCIAL"
	
ENDIF

_cValores:=_cQuery1+ENTER+ENTER
_cValores+=_cQuery2+ENTER+ENTER
_cValores+=_cQuery3+ENTER+ENTER

IF _lAtivaLOG
  nHandle := FCreate(_cdir+"SELECT_ICMS__"+cTipoICMS+"__"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
  FWrite(nHandle, _cValores )
  FClose(nHandle)
ENDIF

MPSysOpenQuery( _cQuery1 ,"Q1" ) 
MPSysOpenQuery( _cQuery2 ,"Q2" ) 
MPSysOpenQuery( _cQuery3 ,"Q3" ) 

_cValores:=_cQuery1+ENTER+ENTER
If .NOT. Q1->( Eof() )
   _nValor+=Q1->VLR
   _nQtde+=Q1->QTD
Endif	
_cValores+=STR(Q1->VLR,22,7)+ENTER
_cValores+=STR(Q1->QTD,22,7)+ENTER+ENTER

_cValores+=_cQuery2+ENTER+ENTER
If .NOT. Q2->( Eof() )
   _nValor+=Q2->VLR
   _nQtde+=Q2->QTD
Endif	     
_cValores+=STR(Q2->VLR,22,7)+ENTER
_cValores+=STR(Q2->QTD,22,7)+ENTER+ENTER

_cValores+=_cQuery3+ENTER+ENTER
If .NOT. Q3->( Eof() )
   _nValor-=Q3->VLR
   _nQtde-=Q3->QTD
Endif	
_cValores+=STR(Q3->VLR,22,7)+ENTER
_cValores+=STR(Q3->QTD,22,7)+ENTER+ENTER

Q1->( DbClosearea() )
Q2->( DbClosearea() )
Q3->( DbClosearea() )

_cValores+=STR(_nValor,22,7)+ENTER
_cValores+=STR(_nQtde,22,7)+ENTER
	
_nValor:=(_nValor/_nQtde)

_cValores+=STR(_nValor,22,7)+ENTER

IF _lAtivaLOG
	nHandle := FCreate(_cdir+"SELECT_VAL_ICMS__"+cTipoICMS+"__"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
	FWrite(nHandle, _cValores )
	FClose(nHandle)
ENDIF

RETURN _nValor//RETORNO DO "INTERESTADUAL" E "ESTADUAL"

/*
===============================================================================================================================
Programa----------: MEST9Rateio
Autor-------------: Alex Walaluer
Data da Criacao---: 02/04/2019
Descricao---------: Retorna Percentual de rateio que sera aplicado nas regras com Ratear Custo? = Sim
Parametros--------: Codigo do produto para buscar o percentual
Retorno-----------: Percentual de rateio
===============================================================================================================================
*/
Static Function MEST9Rateio(_CodProd)
LOCAL _cQuery:= ""
LOCAL nPos := 0

IF (nPos:=ASCAN(_aProdsRateio , {|A| A[1] == _CodProd })) <> 0
	RETURN  _aProdsRateio[nPos,2]
ENDIF

IF !_CodProd $ ZL6->ZL6_PRDRAT
   RETURN 0
ENDIF

_cQuery+= " SELECT D3_COD, SUM(D3_QUANT) * B1_PESO, ROUND(RATIO_TO_REPORT(SUM(D3_QUANT) * B1_PESO) OVER(),2)  PER_RAT "
_cQuery+= " FROM " + RetSqlName("SD3") + " SD3  JOIN " + RetSqlName("SB1") + " SB1  ON D3_COD = B1_COD "
_cQuery+= " WHERE SD3.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' "
_cQuery+= " AND D3_FILIAL = '"+cFilAnt+"'"
_cQuery+= " AND D3_ESTORNO <> 'S' "
_cQuery+= " AND D3_CF = 'PR0' "
_cQuery+= " AND D3_COD IN "+FormatIn(ALLTRIM(ZL6->ZL6_PRDRAT),";") 
_cQuery+= " AND D3_EMISSAO BETWEEN '"+DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"
_cQuery+= " GROUP BY D3_COD, B1_PESO "

MPSysOpenQuery( _cQuery ,"Rateio" )
	
_cValores+=_cQuery+ENTER+ENTER
DO WHILE .NOT. Rateio->( Eof() )

    AADD(_aProdsRateio,{ALLTRIM(Rateio->D3_COD),Rateio->PER_RAT})

    IF _CodProd ==ALLTRIM(Rateio->D3_COD)
        _cValores+="* "+Rateio->D3_COD+" - "+STR(Rateio->PER_RAT,22,7)+ENTER
	ELSE	
        _cValores+=Rateio->D3_COD+" - "+STR(Rateio->PER_RAT,22,7)+ENTER
	ENDIF	

	Rateio->( DBSKIP() )
ENDDO

Rateio->( DbClosearea() )

IF (nPos:=ASCAN(_aProdsRateio , {|A| A[1] == _CodProd })) <> 0
    RETURN _aProdsRateio[nPos,2]
ENDIF

RETURN  0

/*
===============================================================================================================================
Programa----------: MEST9PMedio
Autor-------------: Alex Walaluer
Data da Criacao---: 10/07/2019
Descricao---------:  Baseado no Relatório de Faturamento de Vendas
Parametros--------: _cFilis,_cCodProd,_cClientes
Retorno-----------: Valor do Preço Medio
===============================================================================================================================
*/
Static Function MEST9PMedio(_cFilis,_cCodProd,_cClientes)
LOCAL _cQuery:= ""
LOCAL _cAlias := GetNextAlias()
LOCAL _nPrecoMedia:=0
/* PARAMETROS DO RELATORIO CONSIDERADOS
ORDEM 3 e SINTETICO
DATA EMISSA DO MEST009
PRODUTO ZL6_PRODUTO
MV_PAR20: CFOPS = "V" E/OU "B"
FILTRA NF: SEDEX = 1 TODOS
MV_PAR22: ABATE DEVOLUCAO = SIM 
MV_PAR23: TIPO DEVOLUCAO = 1 
MV_PAR24: DATAS = DE CIMA STA
MV_PAR25: DATAS = DE CIMA STA
MV_PAR26: 1 - AMBAS 
MV_PAR28: 1 = AMBAS
MV_PAR29: 1 - AMBAS
*/                       
//_cQuery+= "   SELECT S.D2_QUANT, S.D2_VALBRUT, E.D1_QUANT, E.D1_TOTAL FROM "
_cQuery+= " SELECT TT.QT D2_QUANT , TT.VBT D2_VALBRUT, E.QTE D1_QUANT, E.TOTE D1_TOTAL FROM ( "+ENTER
_cQuery+= " SELECT T.QUANT QT,  T.VALBRUT VBT, T.FILIAL FT FROM ( "+ENTER
_cQuery+= " SELECT S.D2_FILIAL FILIAL, S.D2_QUANT QUANT , V.D2_VALBRUT VALBRUT FROM  "+ENTER
_cQuery+= " (SELECT D2_FILIAL, SUM(SD2.D2_QUANT) AS D2_QUANT  "+ENTER
_cQuery+= "    FROM " + RetSqlName("SF2") + " SF2 " +ENTER
_cQuery+= "    JOIN " + RetSqlName("SD2") + " SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL "+ENTER
_cQuery+= "   WHERE SF2.D_E_L_E_T_ = ' ' AND SD2.D_E_L_E_T_ = ' '" +ENTER
_cQuery+= "     AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"+ENTER
_cQuery+= "     AND SD2.D2_FILIAL = '"+cFilAnt+"' "+ENTER
_cQuery+= "     AND SD2.D2_COD IN " + FormatIn(ALLTRIM(_cCodProd),";")	 +ENTER
_cQuery+= "     AND (SD2.D2_CF IN " + FormatIn(U_ITCFOPS("V"),";")	+ENTER
_cQuery+= "       OR SD2.D2_CF IN " + FormatIn(ALLTRIM(U_ITCFOPS("B")),";")	+ENTER
_cQuery+= "          ) GROUP BY D2_FILIAL) S "+ENTER
_cQuery+= "   INNER JOIN "+ENTER
_cQuery+= " ( SELECT D2_FILIAL,  SUM(SD2.D2_VALBRUT) AS D2_VALBRUT"+ENTER
_cQuery+= "    FROM " + RetSqlName("SF2") + " SF2 " +ENTER
_cQuery+= "    JOIN " + RetSqlName("SD2") + " SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL "+ENTER
_cQuery+= "   WHERE SF2.D_E_L_E_T_ = ' ' AND SD2.D_E_L_E_T_ = ' '" +ENTER
_cQuery+= "     AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"+ENTER
_cQuery+= "     AND SD2.D2_FILIAL = '"+cFilAnt+"' "+ENTER
_cQuery+= "     AND SD2.D2_COD IN " + FormatIn(ALLTRIM(_cCodProd),";")	 +ENTER
_cQuery+= "     AND SD2.D2_CF IN " + FormatIn(U_ITCFOPS("V"),";")	+ENTER
_cQuery+= "     GROUP BY D2_FILIAL) V "+ENTER
_cQuery+= "     ON V.D2_FILIAL = S.D2_FILIAL) T) TT"+ENTER
_cQuery+= "   FULL OUTER JOIN "+ENTER
_cQuery+= " ( SELECT D1_FILIAL FILIE, SUM(D1_QUANT)   AS QTE, SUM(D1_TOTAL+D1_ICMSRET) AS TOTE "+ENTER
_cQuery+= "    FROM " + RetSqlName("SD1") + " SD1 " +ENTER
_cQuery+= "    JOIN " + RetSqlName("SF1") + " SF1 ON D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE "+ENTER
_cQuery+= "    WHERE SD1.D_E_L_E_T_ = ' '"+ENTER
_cQuery+= "      AND D1_TIPO = 'D'   "+ENTER
_cQuery+= "      AND F1_FORMUL = 'S' "+ENTER
_cQuery+= "      AND SD1.D1_FILIAL = '"+cFilAnt+"' "+ENTER
_cQuery+= "      AND SF1.F1_DTDIGIT BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"+ENTER//  D1_EMISSAO  BETWEEN '20190601' AND '20190630'
_cQuery+= "      AND    TRIM(SD1.D1_NFORI)||TRIM(D1_SERIORI)||TRIM(D1_ITEMORI) IN  "+ENTER
_cQuery+= "    ( SELECT TRIM(SD2.D2_DOC  )||TRIM(D2_SERIE  )||TRIM(D2_ITEM)    FROM " + RetSqlName("SF2") + " SF2 " +ENTER
_cQuery+= "                               JOIN " + RetSqlName("SD2") + " SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL "+ENTER
_cQuery+= "         WHERE SF2.D_E_L_E_T_ = ' ' AND SD2.D_E_L_E_T_ = ' ' 
_cQuery+= "           AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05)+ "' AND '" + DTOS(MV_PAR06) + "'"+ENTER
_cQuery+= "           AND SD2.D2_FILIAL = '"+cFilAnt+"' "+ENTER
_cQuery+= "           AND SD2.D2_COD IN " + FormatIn(ALLTRIM(_cCodProd),";")	 +ENTER
_cQuery+= "           AND SD2.D2_CF IN " + FormatIn(U_ITCFOPS("V")+";"+ALLTRIM(U_ITCFOPS("B")),";")	+ENTER
_cQuery+= "     ) GROUP BY D1_FILIAL) E " +ENTER
_cQuery+= "      ON TT.FT = E.FILIE " +ENTER

_cValores:=_cQuery+ENTER+ENTER
nHandle := FCreate(_cdir+"SELECT_PRECO_MEDIO_Q_"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
FWrite(nHandle, _cValores )
FClose(nHandle)

MPSysOpenQuery( _cQuery,_cAlias )

_cValores+=STR((_cAlias)->D2_QUANT,22,7)+ENTER
_cValores+=STR((_cAlias)->D1_QUANT,22,7)+ENTER
_nQTDE:=0
IF .NOT. (_cAlias)->( Eof() )
   _nQTDE:=(_cAlias)->D2_QUANT - (_cAlias)->D1_QUANT
ENDIF

/*
(_cAlias)->( DbClosearea() )
_cValores:=_cQuery2+ENTER+ENTER
nHandle := FCreate(_cdir+"SELECT_PRECO_MEDIO_V_"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
FWrite(nHandle, _cValores )
FClose(nHandle)
MPSysOpenQuery( _cQuery2,_cAlias )*/

_cValores+=STR((_cAlias)->D2_VALBRUT,22,7)+ENTER
_cValores+=STR((_cAlias)->D1_TOTAL,22,7)+ENTER
_nValor:=0
IF .NOT. (_cAlias)->( Eof() )
   _nValor:=(_cAlias)->D2_VALBRUT-(_cAlias)->D1_TOTAL
ENDIF
IF _nValor > 0 .AND. _nQTDE > 0
   _nPrecoMedia:=_nValor/_nQTDE
ENDIF   
_cValores+=STR(_nPrecoMedia,22,7)+ENTER

(_cAlias)->( DbClosearea() )

nHandle := FCreate(_cdir+"SELECT_PRECO_MEDIO_PM_"+cFilant+"__"+STRTRAN(TIME(),":","_")+".txt")
FWrite(nHandle, _cValores )
FClose(nHandle)

RETURN  _nPrecoMedia


/*
===============================================================================================================================
Programa----------: MEST2BuscaZE0
Autor-------------: Alex Walaluer
Data da Criacao---: 02/04/2019
Descricao---------: Retorna valor do mes anterior de perda valorizado
Parametros--------: nInd,_cChave,_cGrpCus,_cDSECT,_aTab
Retorno-----------: Valor do mes anterior de perda valorizado
===============================================================================================================================
*/
Static Function MEST2BuscaZE0(_cTPCUS,_cDGRPCT,_cDSECT,_aTab)

Local  _cMes:=VAL(SUBSTR(DTOS(MV_PAR05),5,2))//MES
LOCAL _nVLRLT:=0

IF _cMes = 1//JANEIRO
   _cMes:=STR( VAL(SUBSTR(DTOS(MV_PAR05),1,4)) - 1 , 4)+"12"
ELSE//FEV A DEZ
   _cMes:=SUBSTR(DTOS(MV_PAR05),1,4) + STRZERO(_cMes - 1 ,2)
ENDIF
_cQuery := " SELECT ZE0_DATARQ , SUM(ZE0_VLRLT) ZE0_VLRLT FROM "+ RETSQLNAME("ZE0")+" ZE0"
_cQuery += " WHERE ZE0.D_E_L_E_T_ = ' ' "
_cQuery += " AND ZE0_DGRPCT = '"+_cDGRPCT+"' "
_cQuery += " AND ZE0_DEVCT = 'EMBALAGENS'
_cQuery += " AND SUBSTR(ZE0_DATARQ,3,4)||SUBSTR(ZE0_DATARQ,1,2)  <= '"+_cMes+"' "
_cQuery += " AND ZE0_TPCUS = '"+_cTPCUS+"' "
_cQuery += " GROUP BY ZE0_DATARQ "
_cQuery += " ORDER BY SUBSTR(ZE0_DATARQ,3,4) DESC, SUBSTR(ZE0_DATARQ,1,2) DESC "
MPSysOpenQuery( _cQuery, "ZE0T" ) 
ZE0T->(DBGOTOP())
DO WHILE ZE0T->(!EOF() )
   IF !EMPTY(ZE0T->ZE0_VLRLT)
      _nVLRLT:=ZE0T->ZE0_VLRLT
      EXIT
   ENDIF   
   ZE0T->(DBSKIP())
ENDDO 
RETURN _nVLRLT
