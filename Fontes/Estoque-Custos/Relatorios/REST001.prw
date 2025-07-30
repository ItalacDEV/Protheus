/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 02/05/2017 | Inclus�o da fun��o de Log ITLOGACS(). - Chamado 19813      
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 26/07/2018 | Inclus�o de coluna de armaz�m da SA - Chamado 25637 
 -------------------------------------------------------------------------------------------------------------------------------
 Jonathan         | 16/07/2020 | Alterado data de necessidade para NUM C.A. - Chamado 33416 
 -------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 24/08/2020 | Corre��o da impress�o das 3 ultimas colunas e nova coluna de saldo atual - Chamado 33915
===============================================================================================================================
*/
#INCLUDE "rwmake.ch"  
#include "protheus.ch"
#include "report.ch"

/*/
===============================================================================================================================
Programa----------: 	
Autor-------------: Tiago Correa Castro
Data da Criacao---: 05/03/2009
===============================================================================================================================
Descricao---------:  Impress�o de SA a partir do browse de SAs
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
/*/
User Function REST001

	//=======================================================================
	// Declaracao de Variaveis                                             
	//=======================================================================
	Local aOrd 			:= 	{}
	Local cDesc1        := 	"Este programa tem como objetivo imprimir relatorio "
	Local cDesc2        := 	"de acordo com os parametros informados pelo usuario."
	Local cDesc3        := 	"Requisicao ao Almoxarifado"
	//Local cPict         := 	""
	Local ctitulo       := 	"Solicitacao ao Almoxarifado"
	//Local nLin          := 	80
	//Local _lok			:= 	.T.	
	Local wnrel      	:= 	'REST001' //Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString
	Private lEnd        := 	.F.
	Private lAbortPrint	:= 	.F.
	Private limite      := 	80
	Private tamanho     := 	"G"
	Private nomeprog    := 	"REST001" //Coloque aqui o nome do programa para impressao no cabecalho
	Private aReturn     := 	{"Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey    := 	0
	Private cPerg       := 	""
	Private m_pag      	:= 	01
	//Private cString 	:= 	"SCP"
	
	pergunte(cPerg,.F.)
	
	//=======================================================================
	// Monta a interface padrao com o usuario...                           
	//=======================================================================
	WnRel   :=  SetPrint(cString,WnRel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)	
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	   Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	//=======================================================================
	// Processamento. RPTSTATUS monta janela com a regua de processamento. 
	//=======================================================================
	RptStatus({|lEnd| REST001R(aOrd,@lEnd,WnRel,ctitulo,Tamanho)},ctitulo)
	
	//========================================================================
    // Grava log da Solicitacao ao Almoxarifado 
    //======================================================================== 
    U_ITLOGACS('REST001')
    
Return

/*/
===============================================================================================================================
Programa----------: REST001R
Autor-------------: Tiago Correa Castro
Data da Criacao---: 05/03/2009
===============================================================================================================================
Descricao---------: Funcao auxiliar chamada pela RPTSTATUS
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
/*/
Static Function REST001R(aOrd,lEnd,WnRel,ctitulo,Tamanho)   

	Local _cQuery 
	Local _cReq			:=	SCP->CP_NUM   
	Local _cSoliNumero  :=	""
	Local Cabec1		:= 	"Numero Item Codigo       Descricao                          Descricao Detalhada                               Quantidade    UM  Centro de Custo               Saldo Atual              C.A.    Arm.   Localizacao " 
    	   	//               012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
			//         	               1         2         3         4         5         6         7         8         9         100       110       120       13        14        15        16        17        18        19                  20        21
	Local Cabec2 :=""
	Local nTipo	 :=018   
	Local nLin	 :=080
    Local nCol   :=151

	_cQuery := " SELECT A.CP_NUM, A.CP_ITEM, A.CP_PRODUTO, B.b1_desc, B.b1_i_descd, A.CP_QUANT, A.CP_UM, A.CP_CC, a.cp_emissao, " 
	_cQuery += "a.cp_i_dtsol, a.cp_i_rssol, a.cp_i_cdusu, A.CP_DATPRF, A.CP_LOCAL, A.CP_I_NUMCA " 
	_cQuery += "FROM SCP"+substr(cNumEmp,1,2)+"0 A INNER JOIN SB1"+substr(cNumEmp,1,2)+"0 B " 
	_cQuery += "ON A.CP_PRODUTO = B.B1_COD "
	_cQuery += "WHERE A.D_E_L_E_T_ = ' ' AND B.D_E_L_E_T_ = ' ' AND A.CP_NUM = '"+_cReq+"' AND A.CP_FILIAL = '"+xfilial("SCP")+"' "
	_cQuery += "ORDER BY A.CP_ITEM "
	dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TEMP", .F., .T.)
	
	DbselectArea("TEMP")
	dbGoTop()
	
	While !EOF()
    	
		//=======================================================================
	   	// Verifica o cancelamento pelo usuario...                             
	   	//=======================================================================
	   	If lAbortPrint
	    	@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
	      	Exit
	   	Endif
	
	   	//=======================================================================
	   	// Impressao do cabecalho do relatorio. . .                            
	   	//=======================================================================
	   	If nLin > 55 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
	      	Cabec(ctitulo,Cabec1,Cabec2,WnRel,tamanho,nTipo)
	      	nLin := 8
	   	Endif
	   	_cSoliNumero:=	TEMP->CP_NUM
	   	_cData		:=	DTOC(STOD(TEMP->CP_I_DTSOL))
	    _cHora		:=	TEMP->CP_I_RSSOL  
	    _cUsuar		:=	TEMP->CP_I_CDUSU 
		_aSaldos    :=  {}		
	   
		DO While !EOF() .and. TEMP->CP_NUM == _cSoliNumero
             
           IF (nPos:=ASCAN(_aSaldos,{|S| S[1] == TEMP->CP_PRODUTO+TEMP->CP_LOCAL})) = 0
		      aSaldos:=CalcEst( TEMP->CP_PRODUTO,TEMP->CP_LOCAL,DATE()+1,cFilAnt )
			  nSaldo:=aSaldos[1]
			  AADD(_aSaldos,{TEMP->CP_PRODUTO+TEMP->CP_LOCAL,nSaldo})
		   ELSE
		      nSaldo:=_aSaldos[nPos,2]
		   ENDIF

	   		@ nLin, 00 	PSAY	AllTrim(TEMP->CP_NUM)
	   		@ nLin, 07 	PSAY 	AllTrim(TEMP->CP_ITEM)
	   		@ nLin, 12 	PSAY 	AllTrim(TEMP->CP_PRODUTO)
	   		@ nLin, 24 	PSAY 	" " + SubStr(Alltrim(TEMP->B1_DESC),1,35)
	   		@ nLin, 60 	PSAY 	SubStr(Alltrim(TEMP->B1_I_DESCD),1,50)
		   	@ nLin, 110 PSAY 	TEMP->CP_QUANT picture "@E 999999999.99"
	   		@ nLin, 124 PSAY 	TEMP->CP_UM 
   			@ nLin, 128 PSAY  	(TEMP->CP_CC) //+ " - " + (SUBSTR(Posicione("CTT",1,xfilial("CTT")+TEMP->CP_CC,"CTT_DESC01"),1,30)) 
   			@ nLin,nCol PSAY  	nSaldo PICTURE "@E 999,999,999,999.99"
	   		@ nLin, 183 PSAY 	TEMP->CP_I_NUMCA+"   " +(TEMP->CP_LOCAL)+"    "+Alltrim(Posicione("SBZ",1,xfilial("SBZ")+TEMP->CP_PRODUTO,"BZ_I_LOCAL"))
	   	//	@ nLin, 192 PSAY 	AllTrim(TEMP->CP_LOCAL)//TEMP->CP_I_NUMCA
	   	//	@ nLin, 198 PSAY 	Alltrim(Posicione("SBZ",1,xfilial("SBZ")+TEMP->CP_PRODUTO,"BZ_I_LOCAL"))  		

		   	nLin++
	    	DbselectArea("TEMP")
			dbSkip() // Avanca o ponteiro do registro no arquivo
		EndDo           
		@ nLin, 00 PSAY Replicate("-",220)  
		nLin :=	nLin + 5
		@ nLin, 90 PSAY Replicate("-",50)  		
	   	nLin++
		@ nLin, 90 PSAY _cUsuar + "-" + SUBSTR(ALLTRIM(Posicione("SRA",1,_cUsuar,"RA_NOME")),1,25)	
	   	nLin++
		@ nLin, 90 PSAY "Emissao: " + _cData	
	   	nLin++
		@ nLin, 90 PSAY "Hora: " + _cHora	
	   	nLin:=	nLin + 7
		@ nLin, 20 PSAY Replicate("-",50)  		
		@ nLin,120 PSAY Replicate("-",50)  		
	   	nLin++
		@ nLin, 20 PSAY "Autorizado Por"
		@ nLin,120 PSAY "Entregue Por"  		

	EndDo
	TEMP->(DbCloseArea())
	DbselectArea("SCP")
	//=======================================================================
	// Finaliza a execucao do relatorio...                                 
	//=======================================================================
	
	SET DEVICE TO SCREEN
	
	//=======================================================================
	// Se impressao em disco, chama o gerenciador de impressao...          
	//=======================================================================
	
	If aReturn[5]==1
	   dbCommitAll()
	   SET PRINTER TO
	   OurSpool(wnrel)
	Endif
	
	//=======================================================================
	// Remove filtros do contas a receber...                               
	//=======================================================================
	
	MS_FLUSH()
Return
