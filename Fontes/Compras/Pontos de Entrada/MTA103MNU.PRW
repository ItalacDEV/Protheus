/*
=================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=================================================================================================================================
     Autor     |    Data    |                                             Motivo                                           
---------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges  | 17/05/2022 | Chamado 40131 e 40132. Incluída função MCOM018. 
 Alex Wallauer | 07/11/2023 | Chamado 45377 - Antonio. Follow-Up de Cobrança. ( Workflow 4 ).
 Lucas Borges  | 16/05/2024 | Incluída chamada da rotina MCOM023D. Chamado 47282
 Lucas Borges  | 23/07/2025 | Chamado 51340. Ajustar função para validação de ambiente de teste
=================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MTA103MNU
Autor-------------: Josué Danich Prestes
Data da Criacao---: 19/06/2018
===============================================================================================================================
Descrição---------: PE pra adicionar itens no menu da browse de documento de entrada - Chamado 23086
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MTA103MNU()

aAdd(aRotina,{"Excluir (Italac)"             , "U_ITEXCNF()", 3, 5, 0, nil})//"Excluir"
aAdd(aRotina,{'Titulos Amarrados de Impostos', 'U_CTITFIN'  , 0, 5, 0, nil})
aAdd(aRotina,{'Reenvio WorkFlow'             , 'U_ITEnvia'  , 0, 5, 0, nil})//Essa função esta no rdmake MT103FIM.PRW
aAdd(aRotina,{'Inf. Chave CT-e'              , 'U_MCOM018'  , 0, 4, 0, nil})
aAdd(aRotina,{'Danfe/Dacte'              	 , 'U_MCOM023D'  , 0, 4, 0, nil})

Return

/*
===============================================================================================================================
Programa--------: ITEnvia()
Autor-----------: Alex Wallauer
Data da Criacao-: 13/08/2019
===============================================================================================================================
Descrição-------: Monta e dispara o WF para avisar o solicitante de uma compra que seu produto já chegou na empresa
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function ITEnvia()

IF SuperGetMV("IT_AMBTEST",.F.,.T.)
   FWMSGRUN( ,{|oProc| U_EnviaWF4(.T.,oProc) },"Aguarde...","Enviando Workflow 4-NF fora do prazo...")
ENDIF

If SF1->F1_TIPO == "N" 
   FWMSGRUN( ,{|oProc| U_EnviaWF3(.T.,oProc) },"Aguarde...","Enviando Workflow 3-Solicitante...")
EndIf	

Return

/*
===============================================================================================================================
Programa----------: ITEXCNF
Autor-------------: Josué Danich Prestes
Data da Criacao---: 19/06/2018
===============================================================================================================================
Descrição---------: Rotina italac de exclusão de documento de entrada
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITEXCNF()

fwmsgrun(, { |oproc| U_ITEXCNFP(oproc)}, 'Aguarde...','Iniciando exclusão de nota de entrada...')

Return .T.

User Function ITEXCNFP(oproc)

Local _lret := .T.
Private _lcanc := .F.

BEGIN TRANSACTION

//============================================
//Estorna transferências de leite cru
//============================================
//Localiza movimento de estorno
SD3->(Dbsetorder(13)) //D3_FILIAL + D3_CHAVEF1
If SD3->(Dbseek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO)) 

 	Do while alltrim(SD3->D3_FILIAL + SD3->D3_CHAVEF1) == alltrim(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO)
		
 		If SD3->D3_ESTORNO != 'S'
	
 			//Faz estorno
 			_ddataori := ddatabase
 			ddatabase := SD3->D3_EMISSAO
 			aAuto := {}   
 			lMsErroAuto  := .F.                       
 			MSExecAuto({|x,y| mata261(x,y)},aAuto,6) 
			
 			ddatabase := _ddataori
			
 			If lMsErroAuto .OR. SD3->D3_ESTORNO != 'S'  
			
 				u_itmsg( 'Existe transferência de leite cru a granel e não foi possível estornar', 'MTA103MNU001',;
				'Realize o estorno da transferência manualmente -> DOC ' + SD3->D3_DOC  , 1 )
				_lret := .F.			
			
			Endif
			
		Else
		
		     SD3->(Dbskip())
		     
		Endif
		
	Enddo
			
Endif

If _lret

	oproc:cCaption := ("Executando exclusão de documento de entrada...")
	ProcessMessages()
	
	_lret := A103NFiscal("SF1",SF1->(Recno()),5)  //Chama tela de exclusão padrão
	
Endif

If !_lret .or. _lcanc 

	disarmtransaction() //Se falhou estorno de transferência ou não completou eexclusão do documento de entrada faz rollback
	
Endif

END TRANSACTION

//Garante final da transação e unlock de registros
If !IsInCallStack("U_MGLT009") .and. u_itgetmv("ITF1UNL",.T.)
	
	Dbcommit()
	Dbcommitall()
	Dbunlock()

EndIf

Return

/*
===============================================================================================================================
Programa----------: CTITFIN
Autor-------------: Josué Danich Prestes
Data da Criacao---: 19/06/2018
===============================================================================================================================
Descrição---------: Tela consulta titulo amarrados de impostos  
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CTITFIN()

Local _cTitPai   := SF1->F1_SERIE+SF1->F1_DOC+"  NF "+SF1->F1_FORNECE+SF1->F1_LOJA     
Local _cPrefixo  := SF1->F1_SERIE
Local _cFil      := SF1->F1_FILIAL  

Local _FiltraSE2 := "E2_FILIAL ='"+_cFil+"' And E2_TITPAI = '"+_cTitPai+"' And E2_PREFIXO = '"+_cPrefixo+"'"       


PRIVATE CCADASTRO:=OemToAnsi("Titulos de Impostos")
PRIVATE aRotina := {}    

Private aFixe :=   { 	{ "Prefixo"   , "E2_PREFIXO"},;
						{ "Numero"    , "E2_NUM" },;
						{ "Parcela"   , "E2_PARCELA"},;
						{ "Tipo"      , "E2_TIPO"},;
						{ "Natureza"  , "E2_NATUREZ"},;   
						{ "Fornecedor", "E2_FORNECE"},;
						{ "Loja"      , "E2_LOJA"},;
						{ "Nome"      , "E2_NOMFOR"},;
						{ "Emissao"   , "E2_EMISSAO"},;
						{ "Vencimento Real", "E2_VENCREA"},;
						{ "Valor"     , "E2_VALOR"} }

	
aAdd( aRotina, {"Pesquisar","AxPesqui",0,1})
aAdd( aRotina, {"Visualizar","AxVisual",0,2})

DbSelectArea("SE2")   

mBrowse( 6, 1,22,75,"SE2",aFixe,,,,,,,,,,,,,_FiltraSE2)    

Return(.T.)
