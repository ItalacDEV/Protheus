/*
================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
================================================================================================================================
     Autor      |    Data    |                                             Motivo                                           
--------------------------------------------------------------------------------------------------------------------------------
================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'


/*
===============================================================================================================================
Programa----------: RGPE025P
Autor-------------: Igor Melgaço
Data da Criacao---: 24/10/2024
===============================================================================================================================
Descrição---------: Planilha para Dia do Comerciário - Chamado 48928 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function RGPE025() As Logical
Local _aDados As Array
Local _aDadosExc As Array
Local _aCab As Array
Local _aCabExc As Array
Local _cTitulo As Character
Local _cMsgTop As Character
Local _lRet As Logical
Local _nI As Numeric
Local _cDataHora As Character
Local _cNomeArq As Character
Local _cDir As Character
Local oProc As Object
Local _aParRet As Array
Local _aParAux As Array
LOcal _bOK As Block

_aDados    := {}
_aCab      := {}
_aCabExc   := {}
_aDadosExc := {}
_cTitulo   := ""
_cMsgTop   := ""
_lRet      := .F.
_nI        := 0
_cDataHora := ""
_cNomeArq  := ""
_cDir      := ""
_aParRet   := {}
_aParAux   := {}
_bOK       := {||.T.  }
_nI        := 0

MV_PAR01 := Space(2)

AADD( _aParAux , { 1 , "Filial"             , MV_PAR01, "@!"  , ""  ,"SM0", "" , 060 , .T. } ) 

For _nI := 1 To Len( _aParAux )
	aAdd( _aParRet , _aParAux[_nI][03] )
Next _nI

If ParamBox( _aParAux , " Integração de Dados com o sistema Kairos DIMEP " , @_aParRet, _bOK )
   //Processa a Query
   FWMSGRUN(,{|oProc|  _aDados := RGPE025D(oProc) },'Aguarde processamento...','Lendo dados...')

   If Len(_aDados) > 0

      AADD(_aCab," ")
      AADD(_aCab,"Filial")
      AADD(_aCab,"Matricula")
      AADD(_aCab,"Nome")
      AADD(_aCab,"Verba")
      AADD(_aCab,"Valor")

         // Array com o cabeçalho das colunas do relatório. 
         // Alinhamento( 1-Left,2-Center,3-Right )
         // Formatação( 1-General,2-Number,3-Monetário,4-DateTime )
         //                     Titulo das Colunas ,Alinhamento ,Formatação, Totaliza? 
      AADD(_aCabExc,{"Filial"                      ,1           ,1         ,.F.}) 
      AADD(_aCabExc,{"Matricula"                   ,1           ,1         ,.F.}) 
      AADD(_aCabExc,{"Verba"                       ,1           ,1         ,.F.}) 
      AADD(_aCabExc,{"Valor"                       ,1           ,2         ,.F.}) 

      _cTitulo := 'Lista de Funcionários'

      _bCondMarca := {|oLbxAux,nAt| oLbxAux:aArray[nAt][1] }

      _cMsgTop := "Clique em OK para confirmar a seleções dos niveis (Todos os niveis 3 serão selecinados)"//(Marque pelo menos 1 nivel 3 p/ cada nivel 2)"
                                     //  , _aCols,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca )
      _lRet := U_ITListBox(_cTitulo,_aCab,_aDados, .T.    , 2    ,_cMsgTop,          ,        ,         ,     ,        ,          ,       ,         ,          , _bCondMarca)

      If _lRet

         For _nI := 1 To Len(_aDados)
            If _aDados[_nI,1]
               AADD(_aDadosExc,{_aDados[_nI,2],_aDados[_nI,3],_aDados[_nI,5],_aDados[_nI,6]})
            EndIf
         Next

         _cDataHora := "_Dt_" + StrZero(Day(Date()),2) + "_" + StrZero(Month(Date()),2) + "_" + StrZero(Year(Date()),4) + "_Hr_" + StrTran(Time(),":","_")
         _cNomeArq  := "Comerciario_" +  _cDataHora + ".xlsx"//XLSX 
         _cDir := GetTempPath() 

         FWMSGRUN( ,{|oProc| U_ITGEREXCEL(_cNomeArq,_cDir,_cTitulo,_cTitulo,_aCabExc,_aDadosExc,,,,.T.,,,.F.,.T.,oProc) },"H.I. : "+TIME()+" - Aguarde...","Gerando Excel (.XML)..."  )
         
         //Tentando abrir o objeto
         nRet := ShellExecute("open", _cNomeArq, "", _cDir, 1)

      EndIf

   Else
   	U_ITMSG("Consulta não retornou dados",;
              "",;
              "Selecione outra filial.",2, , , .T.)
   EndIf

EndIf



Return _lRet


/*
===============================================================================================================================
Programa----------: RGPE025D
Autor-------------: Igor Melgaço
Data da Criacao---: 24/10/2024
===============================================================================================================================
Descrição---------: Processamento da Query
===============================================================================================================================
Parametros--------: _oProc
===============================================================================================================================
Retorno-----------: _aDados
===============================================================================================================================
*/  
Static Function RGPE025D(oProc As Object) As Array
   Local _cQry As Character
   Local _aLinha As Array
   Local _aDados As Array

   _cQry   := ""
   _aLinha := {}
   _aDados := {}

   _cQry := " SELECT RA_FILIAL , RA_MAT, RA_NOME, RA_SITFOLH, RA_I_COMER, RA_ADMISSA, RA_SALARIO  "
   _cQry += "  ,'      ' AS RGB_PERIOD , 'V' AS RGB_TIPO1, 0 AS RGB_VALOR "
   _cQry += " FROM " + RetSqlName("SRA") + " SRA " 
   _cQry += " WHERE RA_FILIAL = '"+MV_PAR01+"' "
   _cQry += "   AND RA_SITFOLH <> 'D' "
   _cQry += "   AND RA_I_COMER = 'S' "
   _cQry += "   AND SRA.D_E_L_E_T_ = ' ' "

   If Select("QRY025") > 0
      QRY025->(DbCloseArea())
   EndIf

   _cQry := ChangeQuery(_cQry) 

   MPSysOpenQuery( _cQry,"QRY025" )

   Do While QRY025->(!EOF())
      _aLinha := {}

      If (CTOD('31/10/2024') - STOD(QRY025->RA_ADMISSA) ) >= 90

         If CTOD('31/10/2024') - STOD(QRY025->RA_ADMISSA)  > 180
            _nValor := QRY025->RA_SALARIO / 30 * 2
         Else
            _nValor := QRY025->RA_SALARIO / 30
         EndIf

         _nValor := Round(NoRound(_nValor,3),2)

         AADD(_aLinha,.T.)
         AADD(_aLinha,QRY025->RA_FILIAL)
         AADD(_aLinha,QRY025->RA_MAT)
         AADD(_aLinha,QRY025->RA_NOME)
         AADD(_aLinha,"200")
         AADD(_aLinha,_nValor)

         AADD(_aDados,_aLinha)

      EndIf

      QRY025->(DbSkip())
   EndDo

   If Select("QRY025") > 0
      QRY025->(DbCloseArea())
   EndIf

Return _aDados
