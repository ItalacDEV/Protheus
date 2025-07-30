/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     |08/03/2024| Chamado 45006 - Ajustar vari�vel __cUserId em ambiente Scheduller p/ Protheus criar e preencher.
Igor Melga�o  |23/08/2024| Chamado 47047 - Retirada de dados de email do Fernando no fonte.
Lucas Borges  |13/10/2024| Chamado 48465. Retirada da fun��o de conout
Lucas Borges  |23/07/2025| Chamado 51340. Ajustar fun��o para valida��o de ambiente de teste
=============================================================================================================================== 
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "TopConn.ch"
#include "APWEBSRV.CH" 
#INCLUDE "TBICONN.CH" 
  
/*
===============================================================================================================================
Programa----------: AGPE007()//U_AGPE007
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/08/2021
Descri��o---------: Cadastro de Classifica��o de Funcion�rios. Chamado 37366.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGPE007()
Local _aArea   := GetArea()
Local _oBrowse
Private _cTitulo  
Private _aItalac_F3 := {}

_cSelectX5 := " SELECT X5_DESCRI FROM "+ RetSQLName("SX5") +" WHERE D_E_L_E_T_ = ' ' " 
_cSelectX5 += " AND X5_TABELA = '41'"

//AD(_aItalac_F3,{"MV_PAR15"    ,_cTabela   ,_nCpoChave                , _nCpoDesc               ,_bCondTab , _cTitAux         , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"M->ZGZ_MOTIVO"  ,_cSelectX5,{|Tab| (Tab)->X5_DESCRI} ,{|Tab|(Tab)->X5_DESCRI} ,          ,"Lista de Motivos de Aumento", 2        ,          , 1   } ) 

Begin Sequence   
   _cTitulo := "Cadastro de Classifica��o de Funcion�rios"   

   _oBrowse := FWMBrowse():New()
   _oBrowse:SetAlias("ZGZ")
   _oBrowse:SetMenuDef('AGPE007')
   _oBrowse:SetDescription(_cTitulo)

   _oBrowse:AddLegend("ZGZ->ZGZ_SITUAC == 'A'", "GREEN" ,"Aprovado")
   _oBrowse:AddLegend("ZGZ->ZGZ_SITUAC == 'P'", "RED"   ,"Pendente Aprova��o")
   _oBrowse:AddLegend("ZGZ->ZGZ_SITUAC == 'R'", "ORANGE","Reprovado")

   _oBrowse:Activate()

End Sequence       

RestArea(_aArea)

Return Nil

/*
===============================================================================================================================
Programa----------: MenuDef()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/08/2021
Descri��o---------: Define o Menu do fonte AGPE007.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MenuDef()

Local _aRotina := {}
      
ADD OPTION _aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.AGPE007' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION _aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.AGPE007' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION _aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.AGPE007' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION _aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.AGPE007' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
ADD OPTION _aRotina TITLE 'Reenvia WF' ACTION 'U_AGPE007S()'    OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION _aRotina TITLE 'Legenda'    ACTION 'U_AGPE007L()'    OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1

Return _aRotina

/*
===============================================================================================================================
Programa----------: ModelDef()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/08/2021
Descri��o---------: Define o modelo de dados do fonte AGPE007.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ModelDef()

Local _oModel    := Nil 
Local _oStruCab  := FWFormStruct(1, 'ZGZ', {|cCampo| AllTRim(cCampo) $ "ZGZ_DTOCOR;"})
Local _oStruGrid := FWFormStruct(1, 'ZGZ', {|cCampo| AllTRim(cCampo) $ "ZGZ_MAT;ZGZ_NOME;ZGZ_CARGO;ZGZ_SALARI;ZGZ_CODMOT;ZGZ_MOTIVO;ZGZ_TIPO;ZGZ_TMPFUN;ZGZ_CODCAR;ZGZ_DESCAR;ZGZ_SALPRO;ZGZ_OBSERV;ZGZ_SITUAC;ZGZ_OBSAPR;ZGZ_USRNMI;ZGZ_DTINCL;ZGZ_HRINCL;ZGZ_USRNMA;ZGZ_DTALT;ZGZ_HRALT;"}) //fModStruct()
 
_oModel := MPFormModel():New('AGPE007M', {||U_AGPE007I()} /*bPreValidacao*/, /*{|| fValidGrid()}*/, /*bCommit*/, /*bCancel*/ )
 
_oModel:AddFields('MdFieldZGZ', NIL, _oStruCab)
//oModel:AddGrid( 'ZA2DETAIL ', 'ZA1MASTER', oStruZA2, , { |oModelGrid| COMP021LPOS(oModelGrid) }
_oModel:AddGrid('MdGridZGZ', 'MdFieldZGZ', _oStruGrid, , { |_oModelGrid| U_AGPE007U(_oModelGrid) } )
 
_oModel:SetRelation('MdGridZGZ', {;
            {'ZGZ_FILIAL', 'xFilial("ZGZ")'},;
            {"ZGZ_DTOCOR", "ZGZ_DTOCOR"}}, ZGZ->(IndexKey(1)))
     
_oModel:GetModel("MdGridZGZ"):SetMaxLine(9999)
_oModel:SetDescription("Cadastro de Classifica��o de Funcion�rios")
_oModel:SetPrimaryKey({"ZGZ_FILIAL","ZGZ_DTOCOR","ZGZ_MAT"})
_oModel:GetModel( 'MdGridZGZ' ):SetUniqueLine( { 'ZGZ_MAT' } )
 
Return _oModel

/*
===============================================================================================================================
Programa----------: ViewDef()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/08/2021
Descri��o---------: Define a View de dados do fonte AGPE007.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/ 
Static Function ViewDef()
Local _oView     := NIL
Local _oModel    := FWLoadModel('AGPE007')
Local _oStruCab  := FWFormStruct(2, "ZGZ", {|cCampo| AllTRim(cCampo) $ "ZGZ_DTOCOR;"})
Local _oStruGRID := FWFormStruct(2, "ZGZ", {|cCampo| AllTRim(cCampo) $ "ZGZ_MAT;ZGZ_NOME;ZGZ_CARGO;ZGZ_SALARI;ZGZ_CODMOT;ZGZ_MOTIVO;ZGZ_TIPO;ZGZ_TMPFUN;ZGZ_CODCAR;ZGZ_DESCAR;ZGZ_SALPRO;ZGZ_OBSERV;ZGZ_SITUAC;ZGZ_OBSAPR;ZGZ_USRNMI;ZGZ_DTINCL;ZGZ_HRINCL;ZGZ_USRNMA;ZGZ_DTALT;ZGZ_HRALT;"}) //FViewStruct()
 
_oStruCab:SetNoFolder()
 
_oView:= FWFormView():New() 
_oView:SetModel(_oModel)              
 
_oView:AddField('VIEW_ZGZ', _oStruCab, 'MdFieldZGZ')
_oView:AddGrid ('GRID_ZGZ', _oStruGRID, 'MdGridZGZ' )
 
_oView:CreateHorizontalBox("MAIN", 15)
_oView:CreateHorizontalBox("GRID", 85)
 
_oView:SetOwnerView('VIEW_ZGZ', 'MAIN')
_oView:SetOwnerView('GRID_ZGZ', 'GRID')
_oView:EnableControlBar(.T.)
 
Return _oView

/*
===============================================================================================================================
Programa----------: AGPE007G
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/08/2021
Descri��o---------: Fun��o chamada no gatilho dos campos para preenchimento de dados.
Parametros--------: _cCampo = Campo que chamou o gatilho.
Retorno-----------: _cRet conte�do de retorno do gatiolho.
===============================================================================================================================
*/  
User Function AGPE007G(_cCampo)
Local _oModel     := FWModelActive()
Local _oModelGRID := _oModel:GetModel('MdGridZGZ')
//Local _oModelMain := _oModel:GetModel('MdFieldZGZ')
Local _cRet := ""
Local _cCod

Begin Sequence

   If _cCampo == "ZGZ_NOME"
      _cCod     := _oModelGRID:GetValue('ZGZ_MAT')
      _cRet     := Posicione("SRA",1,xFilial("SRA")+_cCod,"RA_NOMECMP")
      
   ElseIf _cCampo == "ZGZ_CARGO"
      _cCod     := _oModelGRID:GetValue('ZGZ_MAT')
      _cCod     := Posicione("SRA",1,xFilial("SRA")+_cCod,"RA_CARGO")
      _cRet     := Posicione("SQ3",1,xFilial("SQ3")+_cCod,"Q3_DESCSUM")
    
   ElseIf _cCampo == "ZGZ_SALARI"
      _cCod     := _oModelGRID:GetValue('ZGZ_MAT')
      _cRet     := Posicione("SRA",1,xFilial("SRA")+_cCod,"RA_SALARIO")

   EndIf 

End Sequence 

Return _cRet 

/*
===============================================================================================================================
Programa----------: AGPE007V
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/08/2021
Descri��o---------: Valida o preenchimento dos dados conforme campo passado por par�metro.
Parametros--------: _cCampo = Campo que chamou a valida��o.
Retorno-----------: _lRet == .T. = Valida��o Ok.
                             .F. = n�o conformidade na valida��o.
===============================================================================================================================
*/  
User Function AGPE007V(_cCampo)
Local _lRet := .T.
Local _oModel     := FWModelActive()
Local _oModelGRID := _oModel:GetModel('MdGridZGZ')
//Local _oModelMain := _oModel:GetModel('MdFieldZGZ')
Local _cCod, _cSelectX5, _cMotivo, _cDescCargo

Begin Sequence

   If _cCampo == "ZGZ_CODMOT"
      _cCod := AllTrim(_oModelGRID:GetValue('ZGZ_CODMOT'))
      _cCod := Upper(_cCod)

      _cSelectX5 := " SELECT X5_CHAVE,X5_DESCRI  FROM "+ RetSQLName("SX5") +" WHERE D_E_L_E_T_ = ' ' " 
      _cSelectX5 += " AND X5_TABELA = '41'"
      
      If Select("QRYSX5") > 0
	      QRYSX5->( DBCloseArea() )
      EndIf
	
      DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cSelectX5) , "QRYSX5" , .T. , .F. )  
      
      _lRet := .F.
      Do While ! QRYSX5->(Eof())
         If _cCod == Upper(AllTrim(QRYSX5->X5_CHAVE))
            _lRet := .T.
            _cMotivo := AllTrim(QRYSX5->X5_DESCRI)
            _oModelGRID:LoadValue('ZGZ_MOTIVO',_cMotivo)
            Exit 
         EndIf 

         QRYSX5->(DbSkip())
      EndDo

   ElseIf _cCampo == "ZGZ_CODCAR"
      _cCod     := _oModelGRID:GetValue('ZGZ_CODCAR')

      If ! ExistCpo("SQ3", _cCod)
         _lRet := .F.
      Else 
         _cDescCargo := Posicione("SQ3",1,xFilial("SQ3")+_cCod,"Q3_DESCSUM")
         _oModelGRID:LoadValue('ZGZ_DESCAR',_cDescCargo)
      EndIf   

   EndIf 

End Sequence 

Return _lRet

/*
===============================================================================================================================
Programa----------: AGPE007W
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/08/2021
Descri��o---------: Determina se um campo ser� edit�vel ou n�o.
Parametros--------: _cCampo = Campo que chamou a fun��o.
Retorno-----------: _lRet == .T. = o campo pode ser editado.
                             .F. = o campo n�o pode ser editado.
===============================================================================================================================
*/  
User Function AGPE007W(_cCampo)
Local _lRet := .T.
Local _oModel     
Local _oModelGRID 

Begin Sequence
   If ISINCALLSTACK("U_AGPE008")
      _lRet := .T.
      Break
   EndIf 

   _oModel     := FWModelActive()
   _oModelGRID := _oModel:GetModel('MdGridZGZ')
   
   If ! _oModelGRID:IsInserted() 
         
      U_Itmsg("Este campo n�o pode ser alterado.","Aten��o",,1)  

      _lRet := .F.  
   EndIf 

   If _cCampo == "ZGZ_SITUAC" 
      _lRet := .F.
   EndIf 

   If _cCampo == "ZGZ_OBSAPR"
      _lRet := .F.
   EndIf 

End Sequence

Return _lRet 

/*
===============================================================================================================================
Programa----------: AGPE007L
Autor-------------: Julio de Paula Paz
Data da Criacao---: 05/08/2021
Descri��o---------: Mostra a tela de legendas
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGPE007L()

Local _aLegenda  := {}

_aLegenda := {{"BR_VERDE"		, "Aprovado"				      },;
   			  {"BR_VERMELHO"	, "Pendente de Aprova��o"  	},;
				  {"BR_LARANJA"	, "Reprovado"	 		         }}

BrwLegenda( "Classifica��o de Funcion�rios" , "Legenda" , _aLegenda )

Return(.T.)

/*
===============================================================================================================================
Programa----------: AGPE007I
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/08/2021
Descri��o---------: Valida o preenchimento dos dados conforme campo passado por par�metro.
Parametros--------: _cCampo = Campo que chamou a valida��o.
Retorno-----------: _lRet == .T. = Valida��o Ok.
                             .F. = n�o conformidade na valida��o.
===============================================================================================================================
*/  
User Function  AGPE007I()
Local _lRet := .T.
Local _oModel     
Local _oModelGRID 
Local _cSituacao

Begin Sequence

   _oModel     := FWModelActive()
   _oModelGRID := _oModel:GetModel('MdGridZGZ')
   _cSituacao  := _oModelGRID:GetValue('ZGZ_SITUAC')

   If _cSituacao <> "P"
      _lRet := .F.
   EndIf 

End Sequence

Return _lRet 

/*
===============================================================================================================================
Programa----------: AGPE007U
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/08/2021
Descri��o---------: Valida os dados do grid.
Parametros--------: _oModelGrid = Objeto de modelo do Grid.
Retorno-----------: _lRet == .T. = Valida��o Ok.
                             .F. = n�o conformidade na valida��o.
===============================================================================================================================
*/  
User Function AGPE007U(_oModelGrid)
Local _lRet := .T. 
Local _cUserName, _cTempoFunc 
Local _cCodMatric

Begin Sequence 
  If Type("__CUSERID") = "C" .And. ! Empty(__CUSERID)
     _cUserName := UsrFullName(__cUserID)
  Else 
     _cUserName := "  "
  EndIf 
 
   If _oModelGRID:IsInserted() 
      _oModelGrid:LoadValue('ZGZ_DTINCL',Date())
      _oModelGrid:LoadValue('ZGZ_HRINCL',Time())
      _oModelGrid:LoadValue('ZGZ_DTALT',Date())
      _oModelGrid:LoadValue('ZGZ_HRALT',Time()) 
      _oModelGrid:LoadValue('ZGZ_USRNMI', _cUserName )
      _oModelGrid:LoadValue('ZGZ_USRNMA', _cUserName )    
   Else 
      _oModelGrid:LoadValue('ZGZ_DTALT',Date())
      _oModelGrid:LoadValue('ZGZ_HRALT',Time()) 
      _oModelGrid:LoadValue('ZGZ_USRNMA', _cUserName ) 
   EndIf 

   //====================================================
   // Calcula e obtem o tempo do funcion�rio na fun��o.
   //====================================================
   If _oModelGRID:IsInserted() .Or. _oModelGRID:IsUpdated()
      _cCodMatric := _oModelGrid:GetValue("ZGZ_MAT") 
      _cTempoFunc := U_AGPE007T(_cCodMatric)
      _oModelGrid:LoadValue('ZGZ_TMPFUN',_cTempoFunc) 
   EndIf 

End Sequence

Return _lRet 

/*
===============================================================================================================================
Programa----------: AGPE007S
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/08/2021
Descri��o---------: Rotina de Workflow de envio de e-mails com as listas de classifica��o de funcion�rios pendentes de 
                    aprova��o.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AGPE007S()//U_AGPE007S
Private _cFilial 
Private _lSchedule := FWGetRunSchedule()

IF _lSchedule

   //=============================================================================
   // Ativa a filial "01" apenas para leitura das filiais do par�metro.
   //=============================================================================
   RpcSetType(3)
   
   //===========================================================================================
   // Preparando o ambiente com a filial da carga recebida
   //===========================================================================================
   PREPARE ENVIRONMENT EMPRESA '01' FILIAL "01" ; //USER 'Administrador' PASSWORD '' ;
               TABLES 'ZGZ','SRA',"SQ3" MODULO 'GPE'
    
   Sleep( 5000 ) //Aguarda 5 segundos para subam as configura��es do ambiente.
                   
   _cfilial := "01"
    
   cFilAnt := _cfilial 
    
   U_AGPE007C()

ELSE
   
   FWMSGRUN(,{|oProc| U_AGPE007C(oProc) },"Aguarde! Enviando WF...","Aguarde! Enviando WF...")

ENDIF

Return NIL

/*
===============================================================================================================================
Programa----------: AGPE007C
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/08/2021
Descri��o---------: Rotina de Leitura do cadastro de classifica��o de funcion�rios pendentes de aprova��o e envio de e-mails.
Parametros--------: oProc
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AGPE007C(oProc,_cfil)
Local _cQry , F
Local _nDifSalario, _nPercAumento
Local  _aDados
Local _cEmailDest := U_ITGETMV( "IT_EMAILAPR", "")
Local _cTitulo    := "Listagem Classifica��o de Funcion�rios Pendentes de Aprova��o"
LOCAL _cPict  :="@E 999,999,999,999.99"
Local _cSituacao
//Local _cDirExcel  := "\spool"

IF !_lSchedule
   PswOrder(1)
   PswSeek(__cUserID,.T.)
   aUsuario:=PswRet()	
   _cEmailDest :=Alltrim(aUsuario[1,14])
ENDIF

IF EMPTY(_cEmailDest)
   FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "AGPE007"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "AGPE00701"/*cMsgId*/, "AGPE00701 - Parametro IT_EMAILAPR n�o preenchido para a essa filial: "+cFilAnt/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
   RETURN .F.
ENDIF

Begin Sequence
   //=================================================================
   // Monta a query de dados
   //=================================================================
   _cQry := "SELECT * "
   _cQry += " FROM " + RetSqlName("ZGZ") + " ZGZ "
   _cQry += " WHERE ZGZ.D_E_L_E_T_ = ' ' "
   _cQry += " AND ZGZ_SITUAC = 'P' "
   _cQry += " ORDER BY ZGZ_FILIAL , ZGZ_DTOCOR , ZGZ_MAT "
 
   If Select("QRYZGZ") <> 0
	  QRYZGZ->(DbCloseArea())
   EndIf
	
   TCQUERY _cQry NEW ALIAS "QRYZGZ"	
   TCSetField( "QRYZGZ", "ZGZ_DTOCOR", "D", 8, 0)	

   DbSelectArea("QRYZGZ")
   Count To _nTotRegs

   QRYZGZ->(dbGoTop())

   If _nTotRegs == 0 
      Break 
   EndIf 
   
   //======================================================================
   // Monta cabe�alho do relat�rio em Excel.
   //======================================================================

   _aDados  := {}
   _aTotais := {0,0,0}
   _aFiliais:= {}
   _cFilQ:=QRYZGZ->ZGZ_FILIAL
   Do While !QRYZGZ->(Eof())
      
      _nDifSalario  := QRYZGZ->ZGZ_SALPRO - QRYZGZ->ZGZ_SALARI
      If QRYZGZ->ZGZ_SALARI == 0
         _nPercAumento := 100
      ELSEIf _nDifSalario == 0
         _nPercAumento := 0
      Else    
         _nPercAumento := _nDifSalario / QRYZGZ->ZGZ_SALARI * 100 
      EndIf
      
      If QRYZGZ->ZGZ_SITUAC == "P"
         _cSituacao := "Pendente"
         _aTotais[1]+=QRYZGZ->ZGZ_SALARI
         _aTotais[2]+=QRYZGZ->ZGZ_SALPRO 
         _aTotais[3]+=_nDifSalario
      ElseIf QRYZGZ->ZGZ_SITUAC == "A"
         _cSituacao := "Aprovado"
      ElseIf QRYZGZ->ZGZ_SITUAC == "R" 
         _cSituacao := "Rejeitado" 
      EndIf 

      Aadd(_aDados,{QRYZGZ->ZGZ_FILIAL,;
                    DTOC(QRYZGZ->ZGZ_DTOCOR),; 
                    QRYZGZ->ZGZ_MAT,;
                    QRYZGZ->ZGZ_NOME,;
                    QRYZGZ->ZGZ_CARGO,;
                    "R$ "+TRANSFORM(QRYZGZ->ZGZ_SALARI,_cPict),;
                    QRYZGZ->ZGZ_CODMOT,;
                    QRYZGZ->ZGZ_MOTIVO,;
                    QRYZGZ->ZGZ_CODCAR,;
                    QRYZGZ->ZGZ_DESCAR,;
                    "R$ "+TRANSFORM(QRYZGZ->ZGZ_SALPRO,_cPict),;
                    "R$ "+TRANSFORM(_nDifSalario,_cPict),;
                    TRANSFORM(_nPercAumento,_cPict)+" %",;
                    _cSituacao,;
                    QRYZGZ->ZGZ_OBSERV})

      QRYZGZ->(DbSkip())
      IF _cFilQ <> QRYZGZ->ZGZ_FILIAL
         AADD(_aFiliais,{ACLONE(_aDados),ACLONE(_aTotais),_cFilQ})
         _aDados  := {}
         _aTotais := {0,0,0}
         _cFilQ:=QRYZGZ->ZGZ_FILIAL
      ENDIF
      
   EndDo
   
   //=============================================================
   // Envia e-mail de WorkFlow POR FILIAL
   //=============================================================
   _cMenEnvio  := ""
   FOR F := 1 TO LEN(_aFiliais)
       _cNomeFilial:= _aFiliais[F,3] + "-" + AllTrim( Posicione('SM0',1,cEmpAnt+_aFiliais[F,3],'M0_FILIAL') )
       U_AGPE007E(_lSchedule,oProc,_cEmailDest,_cTitulo+" - "+_cNomeFilial,"Listagem dos Funcion�rios Pendentes de Aprova��o.",_aFiliais[F,1],_aFiliais[F,2])
   Next
   
   IF !_lSchedule
      bBloco:={|| U_ITMsgLog( _cMenEnvio , "ATENCAO") }
      U_Itmsg(_cMenEnvio,"Aten��o","Clique em Ver Detalhes para conferir todos os envios de e-mail",2,,,,,,bBloco)  
   ENDIF

End Sequence

If Select("QRYZGZ") <> 0
   QRYZGZ->(DbCloseArea())
EndIf

Return Nil 

/*
===============================================================================================================================
Programa----------: AGPE007E
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/08/2021
Descri��o---------: Rotina de Envio de Email
Parametros--------: _lSchedule,oProc,_cEmailDest,_cAssunto,_cMensagem,_aLog,_aTotais
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AGPE007E(_lSchedule,oProc,_cEmailDest,_cAssunto,_cMensagem,_aLog,_aTotais)
Local _aConfig	:= U_ITCFGEML('') // Configura��es do servidor de envio de e-mail.
Local _cEmlLog := ""
Local _cMsgEml := ""
Local _nPCriado:=0
Local _nACriado:=0
Local _nRCriado:=0 , _nI
LOCAL _cPict   :="@E 999,999,999,999.99"
LOCAL _aCab    := {} // Array com o cabe�alho das colunas do relat�rio.

    
Begin Sequence 

// Alinhamento( 1-Left,2-Center,3-Right )
Aadd(_aCab,{"Filial"			       ,2})//01
Aadd(_aCab,{"Dt.Reajuste"	       ,2})//02 
Aadd(_aCab,{"Matricula"			    ,2})//03
Aadd(_aCab,{"Nome"			       ,1})//04
Aadd(_aCab,{"Cargo Atual"			 ,1})//05
Aadd(_aCab,{"Salario Atual"		 ,3})//06
Aadd(_aCab,{"Motivo"		          ,2})//07 xx
Aadd(_aCab,{"Desc.Motivo Reajuste",1})//08
Aadd(_aCab,{"Novo Cargo"			 ,1})//09 xx
Aadd(_aCab,{"Desc.Novo Cargo"		 ,1})//10
Aadd(_aCab,{"Salario Proposto"	 ,3})//11
Aadd(_aCab,{"Diferen�a Salarial"	 ,3})//12
Aadd(_aCab,{"% Aumento"	          ,3})//13
Aadd(_aCab,{"Situa��o"			    ,1})//14
Aadd(_aCab,{"Observa��o"			 ,1})//15
//Aadd(_aCab,{"Observa��o " ,1})//16

_cMsgEml := '<html>'
_cMsgEml += '<head><title>'+_cAssunto+'</title></head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:13px; V-align:middle; margin-right: 14px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += 'td.aceito	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #00CC00; }'
_cMsgEml += 'td.recusa  { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FF0000; }'
_cMsgEml += 'td.AZUL    { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #0000FF; }'
_cMsgEml += 'td.amarelo { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFF00; }'
_cMsgEml += '--></style>'
_cMsgEml += '<center>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="700" height="50"><br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '	<td class="titulos"><center>'+_cMensagem+'</center></td>'
_cMsgEml += '	</tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos">Classifica��o de Funcion�rios</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Tipo de Listagem:</b></td>'
_cMsgEml += '      <td class="itens" >'+ _cMensagem +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Data:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ Dtoc(Date()) +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Hora:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ Time() +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Observa��o:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >#OBS#</td>'
_cMsgEml += '    </tr>'

If _aTotais # NIL .AND. !Empty(_aTotais)  .AND. Len( _aTotais ) > 0
   _cObsT:='<b>ATUAL......:</b> R$ '   +TRANSFORM(_aTotais[1],_cPict)+CHR(13)+CHR(10)
   _cObsT+='<b>PROPOSTO:</b> R$ ' +TRANSFORM(_aTotais[2],_cPict)+CHR(13)+CHR(10)
   _cObsT+='<b>DIFEREN�A:</b> R$ '+TRANSFORM(_aTotais[3],_cPict)+CHR(13)+CHR(10)

   _cMsgEml += '    <tr>'
   _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Totais dos Salarios:</b></td>'
   _cMsgEml += '      <td class="itens" >'+_cObsT +'</td>'
   _cMsgEml += '    </tr>'
ENDIF

If _lSchedule
    _cAssunto += ' - Processamento agendado (Schedule)'
   _cMsgEml += ' <tr>'
   _cMsgEml += '   <td class="titulos" align="center" colspan="2"><font color="red">Esta � uma mensagem autom�tica. Por favor n�o responder!</font></td>'
   _cMsgEml += ' </tr>'
ENDIF
_cMsgEml += '</table>'


////////////////////////    DETALHAMENTO DOS PRODUTOS   /////////////////////////////////////////////
If _aLog # NIL .AND. !Empty(_aLog)  .AND. Len( _aLog ) > 0
	//         01  02  03  04   05  06        07       08  09  10   11  12   13   14   15   16 
	_aSizes:={"1","1","1","10","10","6","xx","9","xx","10","6","6","4","01","13","xx"}

	_cMsgEml += '<br>'
	_cMsgEml += '<table class="bordasimples" width="2300">'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td align="center" colspan="'+ALLTRIM(STR(Len(_aSizes)-3))+'" class="grupos"><b>Classifica��o de Funcion�rios - '+_cMensagem+'</b></td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[14]+'%"><b>Status</b></td>'
  	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[01]+'%"><b>'+_aCab[01,1]+'</b></td>'
  	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[02]+'%"><b>'+_aCab[02,1]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[03]+'%"><b>'+_aCab[03,1]+'</b></td>'
  	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[04]+'%"><b>'+_aCab[04,1]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[05]+'%"><b>'+_aCab[05,1]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[06]+'%"><b>'+_aCab[06,1]+'</b></td>'
//	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[07]+'%"><b>'+_aCab[07,1]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[08]+'%"><b>'+_aCab[08,1]+'</b></td>'
//	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[09]+'%"><b>'+_aCab[09,1]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[10]+'%"><b>'+_aCab[10,1]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[11]+'%"><b>'+_aCab[11,1]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[12]+'%"><b>'+_aCab[12,1]+'</b></td>'
  	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[13]+'%"><b>'+_aCab[13,1]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[15]+'%"><b>'+_aCab[15,1]+'</b></td>'
	//_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[16]+'%"><b>'+_aCab[16,1]+'</b></td>'
	_cMsgEml += '    </tr>'
	
	If !_lSchedule
       _nConta:= Len( _aLog )
       _cTot  :=ALLTRIM(STR(_nConta))
       _nTam  :=LEN(_cTot)
       _nConta:=0
	EndIf

	For _nI := 1 To Len( _aLog )

	    If !_lSchedule
         _nConta++
         If oProc <> Nil  
		      oProc:cCaption := ("Enviando : "+ALLTRIM(STRZERO(_nConta,_nTam)) +" de "+ _cTot)
		      ProcessMessages()
         EndIf 
	    EndIf

		_cMsgEml += '    <tr>'
        
		 If _aLog[_nI][014] = "Pendente"
   	    _cMsgEml += '      <td class="amarelo" align="center" width="'+_aSizes[14]+'%"><b>'+_aLog[_nI][14]+'</b></td>'
          _nPCriado++
		 ELSEIf _aLog[_nI][014] = "Aprovado"
          _cMsgEml += '      <td class="aceito"  align="center" width="'+_aSizes[14]+'%"><b>'+_aLog[_nI][14]+'</b></td>'
          _nACriado++
		 ELSEIf _aLog[_nI][014] = "Rejeitado"
   	    _cMsgEml += '      <td class="recusa"  align="center" width="'+_aSizes[14]+'%"><b>'+_aLog[_nI][14]+'</b></td>'
          _nRCriado++
		 EndIf
       _aAlign:={"left","center","right"}
       _cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[01,2]]+'" width="'+_aSizes[01]+'%">'+_aLog[_nI][01]+'</td>'
       _cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[02,2]]+'" width="'+_aSizes[02]+'%">'+_aLog[_nI][02]+'</td>'
       _cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[03,2]]+'" width="'+_aSizes[03]+'%">'+_aLog[_nI][03]+'</td>'
  	    _cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[04,2]]+'" width="'+_aSizes[04]+'%">'+_aLog[_nI][04]+'</td>'
	    _cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[05,2]]+'" width="'+_aSizes[05]+'%">'+_aLog[_nI][05]+'</td>'
	    _cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[06,2]]+'" width="'+_aSizes[06]+'%">'+_aLog[_nI][06]+'</td>'
//	    _cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[07,2]]+'" width="'+_aSizes[07]+'%">'+_aLog[_nI][07]+'</td>'
    	 _cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[08,2]]+'" width="'+_aSizes[08]+'%">'+_aLog[_nI][08]+'</td>'
//	    _cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[09,2]]+'" width="'+_aSizes[09]+'%">'+_aLog[_nI][09]+'</td>'
    	 _cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[10,2]]+'" width="'+_aSizes[10]+'%">'+_aLog[_nI][10]+'</td>'
	    _cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[11,2]]+'" width="'+_aSizes[11]+'%">'+_aLog[_nI][11]+'</td>'
    	 _cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[12,2]]+'" width="'+_aSizes[12]+'%">'+_aLog[_nI][12]+'</td>'
       _cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[13,2]]+'" width="'+_aSizes[13]+'%">'+_aLog[_nI][13]+'</td>'
   	 _cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[15,2]]+'" width="'+_aSizes[15]+'%">'+_aLog[_nI][15]+'</td>'
   	 //_cMsgEml += '      <td class="itens" align="'+_aAlign[_aCab[16,2]]+'" width="'+_aSizes[16]+'%">'+_aLog[_nI][16]+'</td>'
		 _cMsgEml += '    </tr>'        
    	
	Next _nI
////////////////////////    DETALHAMENTO DOS PRODUTOS   /////////////////////////////////////////////
	
	_cMsgEml += '</table>'

EndIf

_cObsT:=STRZERO(_nPCriado,2)+' Pendentes (Amarelo) '+CHR(13)+CHR(10)
_cObsT+=STRZERO(_nACriado,2)+' Aprovados (Verde) '+CHR(13)+CHR(10)
_cObsT+=STRZERO(_nRCriado,2)+' Rejeitados (Vermelho) '+CHR(13)+CHR(10)

_cMsgEml:=STRTRAN(_cMsgEml,"#OBS#",_cObsT)

_cMsgEml += '</center>'
_cMsgEml += '    <br>'
_cMsgEml += '    <br>'
_cMsgEml += '    <br>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [AGPE007]</td>'
_cMsgEml += '    </tr>'

_cMsgEml += '</body>'
_cMsgEml += '</html>'
// on ITEnvMail(cFrom,cEmailTo    ,cEmailCo,cEmailBcc,cAssunto ,cMensagem ,cAttach,cAccount    ,cPassword    ,cServer      ,cPortCon     ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro  ,lExibeAmb)
    U_ITENVMAIL(_aConfig[01], _cEmailDest,        ,         ,_cAssunto, _cMsgEml ,       ,_aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

    If !Empty( _cEmlLog )
       If !_lSchedule
          _cMenEnvio+="E-mail para: "+_cEmailDest+CHR(13)+CHR(10)+_cEmlLog+CHR(13)+CHR(10)
       Else
          FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "AGPE007"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "AGPE00702"/*cMsgId*/, "AGPE00702 - E-mail para: "+_cEmailDest+CHR(13)+CHR(10)+_cEmlLog/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
       EndIf
    EndIf

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: AGPE007T
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/03/2022
Descri��o---------: Calcula e retorna o tempo do funcion�rio na fun��o.
Parametros--------: _cCodMatr = C�digo de matr�cula do funcion�rio.
Retorno-----------: _cRet = Tempo do Funcio�rio na fun��o.
===============================================================================================================================
*/  
User Function AGPE007T(_cCodMatr)
Local _cRet := ""
Local _dUltmaDt := Ctod("  /  /  ") 
Local _nDias, _nAnos, _nMeses, _nDiasMeses
Local _cFuncao := Space(5)
Local _aFuncoes := {}
Local _nI 

// 1) R7_FILIAL+R7_MAT+DTOS(R7_DATA)+R7_TIPO // Matricula + Data Aumento + Tipo Aumento

// 2) R7_FILIAL+R7_MAT+DTOS(R7_DATA)+R7_SEQ+R7_TIPO // Matricula + Data Aumento + Sequencia + Tipo Aumento 

Begin Sequence 
   
   SR7->(DbSetOrder(2)) // R7_FILIAL+R7_MAT+DTOS(R7_DATA)+R7_SEQ+R7_TIPO // Matricula + Data Aumento + Sequencia + Tipo Aumento 
   SR7->(MsSeek(xFilial("SR7")+_cCodMatr))
   
   Do While ! SR7->(Eof()) .And. SR7->(R7_FILIAL+R7_MAT) == xFilial("SR7")+_cCodMatr
      Aadd(_aFuncoes,{Dtos(SR7->R7_DATA),SR7->R7_FUNCAO,SR7->R7_DATA,SR7->(Recno())}) 
      SR7->(DbSkip())
   EndDo 

   ASort(_aFuncoes, , , { | x,y | x[1]+x[2] < y[1]+y[2] } )

   For _nI := 1 To Len(_aFuncoes)
       If _cFuncao <> _aFuncoes[_nI,2]  // SR7->R7_FUNCAO
          _dUltmaDt := _aFuncoes[_nI,3] // SR7->R7_DATA 
          _cFuncao  := _aFuncoes[_nI,2] // SR7->R7_FUNCAO
       EndIf 
   Next 

   If Empty(_dUltmaDt)
      _cRet := "1 dia"
      Break 
   EndIf 

   _nDias := Date() - _dUltmaDt

   If _nDias <= 31
      _cRet := StrZero(_nDias,2) + " dias "
      Break
   EndIf 

   If _nDias < 365 
      _nMeses     := Int( _nDias / 30 )
      _nDiasMeses := Mod( _nDias, 30 ) 
      _cRet := StrZero(_nMeses,2) + " meses e " +  StrZero(_nDiasMeses,2) + " dias"  
      Break 
   EndIf 

   If _nDias < 396
      _nDiasMeses := Mod( _nDias, 365) 
      _cRet := " 1 ano e " +  StrZero(_nDiasMeses,2) + " dias"  
      Break 
   EndIf 

   _nAnos      := Int( _nDias / 365 )
   _nDiasMeses := Mod( _nDias, 365)
   
   _nMeses     := Int( _nDiasMeses / 30 )
   _cRet       := StrZero(_nAnos,2) + " anos e " + StrZero(_nMeses,2) + " meses "

End Sequence

Return _cRet 

/*
===============================================================================================================================
Programa----------: AGPE007Z
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/03/2022
Descri��o---------: Habilita ou n�o a edi��o de campos.
Parametros--------: _cCampo =  Campo que chamou a fun��o
Retorno-----------: _lRet = .T. = Campo habilitado para edi��o.
                            .F. = Campo n�o habilitado para edi��o.
===============================================================================================================================
*/  
User Function AGPE007Z(_cCampo)
Local _lRet := .T. 

Begin Sequence 
   
   If ISINCALLSTACK("U_AGPE008")
      _lRet := .F.
      Break
   EndIf 

   _oModel     := FWModelActive()
   _oModelGRID := _oModel:GetModel('MdGridZGZ')
   
   If _cCampo == "ZGZ_TIPO" 
      _lRet := .T.
   EndIf 

End Sequence 

Return _lRet 
