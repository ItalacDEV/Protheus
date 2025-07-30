/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 29/12/2021 | Inclusão de rotina para visualizar legendas dos cadastro clientes. Chamado 30177.
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 17/02/2022 | Inclusão da Opção Vinculação Clientes X Tipos de Transporte no menu. Chamado 37652. 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 02/12/2022 | Desenvolver rotina para listar Cadastro de Condições de Pagamento Personalizada. Chamado 41566
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
===============================================================================================================================
Programa--------: CRM980MDef
Autor-----------: Igor Melgaço
Data da Criacao-: 24/08/2021
===============================================================================================================================
Descrição---------: Ponto de entrada para inclusão de opções de menu, no MBrowse do cadastro de clientes. Permite a inclusão de
                    opções de menu no array arotina do cadastro de clientes. Substitui o ponto MA030ROT.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _aRot = Array com as opções de menu a serem adicinadas no array aRotina do cadastro de clientes.
===============================================================================================================================
*/
User Function CRM980MDef()
Local aRotina := {}
//----------------------------------------------------------------------------------------------------------
// [n][1] - Nome da Funcionalidade
// [n][2] - Função de Usuário
// [n][3] - Operação (1-Pesquisa; 2-Visualização; 3-InclusÃ£o; 4-Alteração; 5-ExclusÃ£o)
// [n][4] - Acesso relacionado a rotina, se esta posição nÃ£o for informada nenhum acesso será validado
//----------------------------------------------------------------------------------------------------------

Begin Sequence
   
   Aadd(aRotina,{"Clientes x Tipos Transportes" ,"U_AOMS131"     ,MODEL_OPERATION_UPDATE,0})
   Aadd(aRotina,{"WF Lib.Clientes"              ,"U_MOMS041"     ,MODEL_OPERATION_VIEW  ,0})
   Aadd(aRotina,{"Listagem Cond.Pagto"          ,"U_ROMS072"     ,MODEL_OPERATION_VIEW  ,0})
   Aadd(aRotina,{"Legenda"                      ,"U_CRM980LEG()" ,MODEL_OPERATION_VIEW  ,0})

End Sequence

Return( aRotina )

/*
===============================================================================================================================
Programa----------: CRM980LEG()
Autor-------------: Julio de Paula Paz
Data--------------: 23/12/2021
===============================================================================================================================
Descrição---------: Função utilizada para exibir a legenda.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CRM980LEG()
aLegenda :=	{	{"BR_VERDE"		, "Ativo"	},;
					{"BR_VERMELHO"	, "Inativo"	},;
				   {"BR_CINZA"	   , "Bloq. Validação Desc Contratual"	} }

BrwLegenda("Status Cadastro de Clientes.","Legenda",aLegenda)

Return Nil 


