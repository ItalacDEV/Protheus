/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data     |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
                  |             | 
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.Ch"
#Include "FWMVCDef.Ch"

/*
===============================================================================================================================
Programa----------: AOMS131
Autor-------------: Julio de Paula Paz
Data da Criacao---: 05/01/2022
===============================================================================================================================
Descrição---------: Rotina de Cadastro de Cadastro Clientes x Tipo de Veiculos.
                    Esta rotina considera estar posicionada no cadastro de clientes (SA1). Chamado 37652.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS131()
Local aArea   := GetArea()
Local _bCond, _cCond
Local _aRotBack := AClone(aRotina)

Private _cTitulo 
Private _oBrowse 

Begin Sequence 
   DbSelectArea("ZBB")

   aRotina := {}
   aAdd(aRotina,{ "Pesquisar"    ,"AxPesqui"                , 0, 1})
   aAdd(aRotina,{ "Visualizar"   ,"AxVisual"                , 0, 2})
   aAdd(aRotina,{ "Incluir"      ,"U_AOMS131I()"            , 0, 3})
   aAdd(aRotina,{ "Excluir"      ,"U_AOMS131E()"            , 0, 5})

   _bCond := { || SA1->A1_COD = ZBB_CLIENT .And. SA1->A1_LOJA = ZBB_LOJA }
   _cCond := "SA1->A1_COD = ZBB_CLIENT .And. SA1->A1_LOJA = ZBB_LOJA"
   _cTitulo := "Clientes x Tipos de Veiculos: "+ SA1->A1_COD + "/" +SA1->A1_LOJA + "-" + SA1->A1_NOME
   
   ZBB->(DBSetFilter( _bCond , _cCond )) 


    //Instânciando FWMBrowse - Somente com dicionário de dados
    _oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    _oBrowse:SetAlias("ZBB")
 
    //Setando a descrição da rotina
    _oBrowse:SetDescription(_cTitulo)
     
    //Ativa a Browse
    _oBrowse:Activate()

End Sequence 

aRotina := AClone(_aRotBack)

DbSelectArea("SA1")

RestArea(aArea)

Return Nil
 
/*
===============================================================================================================================
Programa----------: AOMS131P
Autor-------------: Julio de Paula Paz
Data da Criacao---: 05/01/2022
===============================================================================================================================
Descrição---------: Rotina de preenchimento de campos obrigatórios.
                    Esta rotina considera estar posicionada no cadastro de clientes (SA1).
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS131P()
Local _cRet := SA1->A1_COD

Begin Sequence 
   
   M->ZBB_CLIENT := SA1->A1_COD
   M->ZBB_LOJA   := SA1->A1_LOJA
   M->ZBB_NOMCLI := SA1->A1_NOME

End Sequence 

Return _cRet 

/*
===============================================================================================================================
Programa----------: AOMS131E
Autor-------------: Julio de Paula Paz
Data da Criacao---: 05/01/2022
===============================================================================================================================
Descrição---------: Rotina de preenchimento de campos obrigatórios.
                    Esta rotina considera estar posicionada no cadastro de clientes (SA1).
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS131E()
Local _cTpVeic, _cNomeVeic 

Begin Sequence 
   _cTpVeic   := ZBB->ZBB_TPVEIC
   _cNomeVeic := AllTrim(ZBB->ZBB_NOMVEI)

   If U_ItMsg("Confirma a Exclusão do Tipo de Veiculo: " + _cTpVeic + " - " + _cNomeVeic + " ?" ,"Atenção", , ,2, 2)
      
      ZBB->(RecLock("ZBB",.F.))
      ZBB->(DbDelete())
      ZBB->(MsUnLock())
      _oBrowse:Refresh()

      U_ItMsg("Tipo de Veiculo :" + _cTpVeic + " - " + _cNomeVeic + ", excluido com sucesso!","Atenção",,1)

   EndIf 

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS131I
Autor-------------: Julio de Paula Paz
Data da Criacao---: 05/01/2022
===============================================================================================================================
Descrição---------: Rotina de inclusão dos tipos de transportes vinculados ao cadastro de clientes.
                    Esta rotina considera estar posicionada no cadastro de clientes (SA1).
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS131I()

Begin Sequence 

   AxInclui( 'ZBB', /*<nReg>*/, /*<nOpc>*/, /*<aAcho>*/, /*<cFunc>*/, /*<aCpos>*/, "U_AOMS131V()")

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS131V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 05/01/2022
===============================================================================================================================
Descrição---------: Rotina de Validação do Cadastro de Cadastro Clientes x Tipo de Veiculos.
                    Esta rotina considera estar posicionada no cadastro de clientes (SA1).
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS131V(_oModel)
Local _lRet := .T.

Begin Sequence 
   
   ZBB->(DbSetOrder(1))
   If ZBB->(MsSeek(xFilial("ZBB")+SA1->A1_COD+SA1->A1_LOJA+M->ZBB_TPVEIC))
      U_ItMsg("Já existe o tipo de veiculo cadastrado para este Cliente e Loja.","Atenção",,1)
      _lRet := .F.
   EndIf 
   
End Sequence 

Return _lRet 
