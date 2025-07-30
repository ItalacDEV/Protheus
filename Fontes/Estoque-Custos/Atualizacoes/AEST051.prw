/*
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
     Autor    |    Data    |                              Motivo                                                          |
-------------------------------------------------------------------------------------------------------------------------------
              |            | 
=============================================================================================================================== 
*/
#INCLUDE 'PROTHEUS.CH'
/*
===============================================================================================================================
Programa----------: AEST051
Autor-------------: Julio de Paula Paz
Data da Criacao---: 20/05/2024
===============================================================================================================================
Descri��o---------: Rotina de manuten��o no Cadastro de Origem e Destino de Transfer�ncia de Produtos. Chamado 46556.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AEST051()

Local _cVldAlt
Local _cVldExc

Begin Sequence 
   DbSelectArea("ZCF")
   ZCF->(dbSetOrder(1))
   
   _cVldAlt := "U_AEST051V('BOK')" // Validacao para permitir a inclusao. Pode-se utilizar ExecBlock.
   _cVldExc := ".T."          // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

   //AxCadastro("SA1", "Clientes", "U_DelOk()", "U_COK()", aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , )
   AxCadastro("ZCF","Cadastro de Origem e Destino para Transfer�ncia de Produtos",_cVldExc,_cVldAlt)

End Sequence

Return Nil 

/*
===============================================================================================================================
Programa--------: AEST051V
Autor-----------: Julio de Paula Paz
Data da Criacao-: 20/05/2024
===============================================================================================================================
Descri��o-------: Valida a grava��o da inclus�o e da altera��o.
===============================================================================================================================
Parametros------: _cCampo = Campo que chamou a valida��o.
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AEST051V(_cCampo)  
Local _lRet   := .T.

Begin Sequence 
   If _cCampo == "BOK"
      If Inclui
         If Empty(M->ZCF_CODIGO)
            U_ITMSG("O Preenchimento do codigo de Origem/Destino � obrigat�rio.","Aten��o",,1) 
            _lRet :=.F.
            Break
         Else 
            ZCF->(DbSetOrder(1))
            IF ZCF->(MsSeek(xFilial("ZCF")+M->ZCF_CODIGO))
               U_ITMSG("J� existe uma Origem/Destino com este c�digo.","Aten��o",,1) 
               _lRet :=.F.
               Break
            EndIf 
         EndIf

         If Empty(M->ZCF_ORIGDE)
            U_ITMSG("O Preenchimento da descri��o do C�digo de Origem/Destino  � obrigat�rio.","Aten��o",,1) 
            _lRet :=.F.
            Break 
         EndIf 

         If Empty(M->ZCF_MOTTRA)
            U_ITMSG("O Preenchimento do Tipo de Transfer�ncia � obrigat�rio.","Aten��o",,1) 
            _lRet :=.F.
            Break
         Else 
            CYO->(DbSetOrder(1)) // CYO_FILIAL+CYO_CDRF
            
            If ! CYO->(MsSeek(xFilial('CYO')+M->ZCF_MOTTRA))
               U_ITMSG("O C�digo do Tipo de Transfer�ncia informado n�o existe.","Aten��o",,1) 
               _lRet :=.F.
               Break
            ElseIf Left(M->ZCF_MOTTRA,1) <> "T"
               U_ITMSG("Os C�digos dos Tipos de Transfer�ncias devem iniciar com T.","Aten��o","O c�digos iniciados com T s�o exclusivos para as transfer�ncias de descarte.",1) 
               _lRet :=.F.
               Break  
            EndIf 

         EndIf 

         M->ZCF_DESMOT := CYO->CYO_DSRF 

      ElseIf Altera 
 
         If Empty(M->ZCF_ORIGDE)
            U_ITMSG("O Preenchimento da descri��o do C�digo de Origem/Destino  � obrigat�rio.","Aten��o",,1) 
            _lRet :=.F.
            Break 
         EndIf 

         If Empty(M->ZCF_MOTTRA)
            U_ITMSG("O Preenchimento do Tipo de Transfer�ncia � obrigat�rio.","Aten��o",,1) 
            _lRet :=.F.
            Break
         Else 
            
            CYO->(DbSetOrder(1)) // CYO_FILIAL+CYO_CDRF
            If ! CYO->(MsSeek(xFilial('CYO')+M->ZCF_MOTTRA))
               U_ITMSG("O C�digo do Tipo de Transfer�ncia informado n�o existe.","Aten��o",,1) 
               _lRet :=.F.
               Break
            ElseIf Left(M->ZCF_MOTTRA,1) <> "T"
               U_ITMSG("Os C�digos dos Tipos de Transfer�ncias devem iniciar com T.","Aten��o","O c�digos iniciados com T s�o exclusivos para as transfer�ncias de descarte.",1) 
               _lRet :=.F.
               Break  
            EndIf 

         EndIf 

         M->ZCF_DESMOT := CYO->CYO_DSRF 

      EndIf 
   
   ElseIf _cCampo == "ZCF_CODIGO"
      If Inclui
         If Empty(M->ZCF_CODIGO)
            U_ITMSG("O Preenchimento do codigo de Origem/Destino � obrigat�rio.","Aten��o",,1) 
            _lRet :=.F.
            Break
         Else 
            ZCF->(DbSetOrder(1))
            IF ZCF->(MsSeek(xFilial("ZCF")+M->ZCF_CODIGO))
               U_ITMSG("J� existe uma Origem/Destino com este c�digo.","Aten��o",,1) 
               _lRet :=.F.
               Break
            EndIf 
         EndIf
      EndIf 
    
   ElseIf _cCampo == "ZCF_ORIGDE"

      If Empty(M->ZCF_ORIGDE)
         U_ITMSG("O Preenchimento da descri��o do C�digo de Origem/Destino  � obrigat�rio.","Aten��o",,1) 
         _lRet :=.F.
         Break 
     EndIf 
  
   ElseIf _cCampo == "ZCF_MOTTRA" 
        
     If Empty(M->ZCF_MOTTRA)
        U_ITMSG("O Preenchimento do Tipo de Transfer�ncia � obrigat�rio.","Aten��o",,1) 
        _lRet :=.F.
        Break
     Else 
        CYO->(DbSetOrder(1)) // CYO_FILIAL+CYO_CDRF
        If ! CYO->(MsSeek(xFilial('CYO')+M->ZCF_MOTTRA))
           U_ITMSG("O C�digo do Tipo de Transfer�ncia informado n�o existe.","Aten��o",,1) 
           _lRet :=.F.
           Break
        ElseIf Left(M->ZCF_MOTTRA,1) <> "T"
           U_ITMSG("Os C�digos dos Tipos de Transfer�ncias devem iniciar com T.","Aten��o","O c�digos iniciados com T s�o exclusivos para as transfer�ncias de descarte.",1) 
           _lRet :=.F.
           Break  
        EndIf 

     EndIf 

     M->ZCF_DESMOT := CYO->CYO_DSRF 

  EndIf 

End Sequence

Return _lRet

/*
===============================================================================================================================
Programa--------: AEST051N
Autor-----------: Julio de Paula Paz
Data da Criacao-: 20/05/2024
===============================================================================================================================
Descri��o-------: Valida a grava��o da inclus�o e da altera��o.
===============================================================================================================================
Parametros------: _cCampo = Campo que chamou a valida��o.
===============================================================================================================================
Retorno---------: _cNum = Novo numero para o c�digo da tabela ZCF.
===============================================================================================================================
*/
User Function AEST051N()
Local _cQry := ""
Local _aArea  := GetArea()
Local _cNum := ""

Begin Sequence 

   _cQry := " SELECT max(ZCF_CODIGO) MAXIMO FROM " + RetSqlName("ZCF") +" ZCF WHERE ZCF.D_E_L_E_T_ <> '*' "
	_cQry += " AND ZCF_FILIAL = '" + xFilial("ZCF") + "'"
	
   If Select("TRBZCF") > 0
	   TRBZCF->(Dbclosearea())
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry) , "TRBZCF" , .T. , .F. )
   
   If !TRBZCF->(Eof())
      _cNumZCF := ALLTRIM(TRBZCF->MAXIMO)
   EndIf 

   _cNum   := GetSXENum("ZCF","ZCF_CODIGO")
   Confirmsx8(.F.)
   
   If _cNum < _cNumZCF
       Processa( {|| _cNum := U_AEST051A(_cNumZCF)}, "Aguarde...","Atualizando hardlock para tabela ZCF...",.T.)
   EndIf 

   TRBZCF->(Dbclosearea())	

End Sequence 

If Select("TRBZCF") > 0
	TRBZCF->(Dbclosearea())
EndIf

RestArea(_aArea)

Return _cNum

/*
===============================================================================================================================
Programa----------: AEST051A
Autor-------------: Julio de Paula Paz
Data da Criacao---: 24/05/2024
===============================================================================================================================
Descri��o---------: Roda atualiza��o de hardlock para o cadastro ZCF.
===============================================================================================================================
Parametros--------: _cUltmoCod = Ultimo c�digo da tabela ZCF.
===============================================================================================================================
Retorno-----------: _cRet = Ultimo c�digo dispon�vel para a tabela ZCF.
===============================================================================================================================
*/
Static Function AEST051A(_cUltmoCod)
Local _cNumZCF 

Begin Sequence
   
   _cNumZCF := GetSXENum("ZCF","ZCF_CODIGO")
   Confirmsx8(.F.)
   
   Do while AllTrim(_cNumZCF) <= AllTrim(_cUltmoCod)
	
	   IncProc("Atualizando Hardlock -Tabela ZCF - Registro: " + ALLTRIM(_cNumZCF) + " de " + AllTrim(_cUltmoCod))
	
      _cNumZCF   := GetSXENum("ZCF","ZCF_CODIGO")

      Confirmsx8(.F.)
  
   Enddo

End Sequence 

Return _cNumZCF


