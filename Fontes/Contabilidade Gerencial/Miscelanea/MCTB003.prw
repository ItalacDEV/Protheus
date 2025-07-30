/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/05/2024 | Corrigir par�metro do Directory. Chamado 47130
===============================================================================================================================
*/

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MCTB003
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 04/01/2024
===============================================================================================================================
Descri��o---------: Contabiliza��o TXT por data. Desmembra o TXT utilizado na contabiliza��o para permitir importa��o por data
					Essa fun��o deve ser inclu�da no menu como Fun��o de sistema e com o U_. Caso seja inclu�da como fun��o de
					usu�rio, ser� gerado o seguinte erro: ERROR: _SetNamedPrvt : owner private environment not found
           			CTBINILAN - CTBA105.PRW(8829)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MCTB003

Local _oSelf as Object
Local _cPerg := "CTB500"

//============================================
//Cria interface principal
//============================================
tNewProcess():New(	"MCTB003"										,; // Fun��o inicial
					"Importa Cadastros"								,; // Descri��o da Rotina
					{|_oSelf| MCTB03P(_oSelf,_cPerg) }					,; // Fun��o do processamento
					"Esta rotina ir� desmembrar o arquivo informado em v�rios arquivos "+;
					"de acordo com a data do movimento a ser importada na Contabiliza��o por TXT (CTBA500))",; // Descri��o da Funcionalidade
					_cPerg											,; // Configura��o dos Par�metros
					{}												,; // Op��es adicionais para o painel lateral
					.F.												,; // Define cria��o do Painel auxiliar
					0												,; // Tamanho do Painel Auxiliar
					''												,; // Descri��o do Painel Auxiliar
					.T.												,; // Se .T. exibe o painel de execu��o. Se falso, apenas executa a fun��o sem exibir a r�gua de processamento.
                    .T.                                              ) // Se .T. cria apenas uma regua de processamento.

Return

/*
===============================================================================================================================
Programa----------: MCTB03P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 04/01/2024
===============================================================================================================================
Descri��o---------: Realiza o processamento da rotina.
===============================================================================================================================
Parametros--------: _oSelf, _cPerg
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MCTB03P(_oSelf,_cPerg)

Local _oFile	:= Nil
Local _aAux		:= {}
Local _nX,_nI	:= 0
Local _aFiles	:= {}
Local _cQuery	:= ""
Local _cNxtData	:= ""
Local _cPadrao	:= ""
Local _cData	:= ""
Local _cArquivo := ""
Local _cDir 	:= GetMv("MV_CTBTPAT")

If MV_PAR08 == 1 // Arquivo ou parametro
	aAdd(_aFiles,AllTrim(MV_PAR03))
Else
	_aFiles := Directory(_cDir+"\*.txt")
EndIf
If Empty(_aFiles)
	MsgStop("N�o foram encontrados arquivos v�lidos no diret�rio informado.", "MCTB00301")
	Return
EndIf

For _nX := 1 to Len(_aFiles)
	//Abre arquivo de text
	_oFile	:= FwFileReader():New(_aFiles[_nX])
	
	If _oFile:Open()
		_oSelf:SetRegua1(1)
		_oSelf:IncRegua1("Lendo arquivo... ["+ StrZero(_nX,6) +"] de ["+ StrZero(Len(_aFiles),6) +"]")
		_aAux := _oFile:GetAllLines() //Acessa todas as Linhas
		_oFile:Close()
		_oFile:= FWFileWriter():New(_aFiles[_nX])
		_cArquivo := ""
		If __CopyFile(_aFiles[_nX], Substr(_aFiles[_nX],1,Len(_aFiles[_nX])-4)+"_bkp.txt")

			If MV_PAR07 == 2 //Sem ser Por Filial
				_cPadrao := SubStr(_aAux[1],1,3)
			Else // mv_par07 = 1 ->Por Filial				
				_cPadrao	:= SubStr(_aAux[1],13,3)
			EndIf
			_cQuery := "SELECT CT5_HAGLUT FROM " + RetSqlName("CT5") + " WHERE D_E_L_E_T_ = ' ' AND CT5_LANPAD = '"+_cPadrao+"'"
			_cData := FwExecCachedQuery():ExecScalar(_cQuery, "CT5_HAGLUT", "120", "60")
			_cData := Replace(Upper(AllTrim(_cData)),"LERDATA(","Substr(_aAux[_nI],")
			
			For _nI := 1 To Len(_aAux)
				_cArquivo +=_aAux[_nI]+CRLF
				//Incremento uma linha para ver se a pr�xima data � diferente ou se acabou o arquivo
				_nI++
				_cNxtData := IIf(_nI>Len(_aAux),"",&(_cData))
				_nI--
	
				If _cNxtData <> &(_cData) 
					//Se trocou a data, limpo o arquivo com os dados acumulados e gravo os novos
					If _oFile:Clear()
						_oFile:Write(_cArquivo)
						_oFile:Close()
						If _oFile:Exists()
							CTBA500()
							_cArquivo := ""
						Else
							MsgStop("Arquivo n�o localizado. O processo ser� abortado. Erro: "+ _oFile:Error():Message,"MCTB00302")
							Exit
						EndIf
					Else
						MsgStop("N�o foi poss�vel apagar o conte�do do arquivo. O processo ser� abortado. Erro: "+ _oFile:Error():Message,"MCTB00302")
						Exit
					EndIf
				EndIf
			Next _nI
		Else
			MsgStop("Backup do arquivo n�o realizado. O arquivo "+_aFiles[_nX]+" ser� ignorado.","MCTB00304")
		EndIf
		_oFile:Erase()
		_oFile:Close()
	Else
		MsgAlert("Arquivo: "+_aFiles[_nX]+". O arquivo est� vazio ou � inv�lido para an�lise! Verifique o arquivo e tente novamente.","MCTB0303")
	EndIf
Next _nJ
Return
