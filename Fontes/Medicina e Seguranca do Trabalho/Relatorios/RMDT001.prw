/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich      | 26/06/2019 | Ajustes para loboguara - Chamado 28886
-------------------------------------------------------------------------------------------------------------------------------
Lucas B. Ferreira | 16/09/2019 | Retirado uso não permitido de chamada de API de Console. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas B. Ferreira | 02/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 20/03/2020 | Mensagem na geração do recibo de entrega do EPI X geração da SA. Chamado 32334
 -------------------------------------------------------------------------------------------------------------------------------
Jonathan          | 16/07/2020 | Ajuste da impressão do recibo de entrega. Chamado 33416
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "TOTVS.CH"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MDTR805.ch"
/*
===============================================================================================================================
Programa----------: RMDT001
Autor-------------: Josué Danich Prestes
Data da Criacao---: 01/09/2015
===============================================================================================================================
Descrição---------: Recibo de entrega de EPI copiado e ajustado do fonte padrão MDTR805
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RMDT001()

//=======================================================================
// Define Variaveis                                             
//=======================================================================
LOCAL _cwnrel   := "MDTR805"
Local _aArea := GetArea()
LOCAL _cDesc1  := STR0001 //"Relatorio de Comprovante de Entrega de EPI.                                     "
LOCAL _cDesc2  := STR0002 //"Conforme parametros o usuario pode selecionar os funcionarios, periodo desejado "
LOCAL _cDesc3  := STR0003 //"e indicar se deseja imprimir apenas epi's nao impressos ou para todos.          "
LOCAL _cString := "TNF"
Local _cQry  , D
PRIVATE nomeprog 	:= "MDTR805"
PRIVATE tamanho  	:= "M"
PRIVATE  aReturn  	:= { STR0004, 1,STR0005, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE titulo   	:= STR0006 //"Comprovante de Entrega de EPI"
PRIVATE _ntipo    	:= 0
PRIVATE nLastKey 	:= 0
PRIVATE cPerg    	:= "MDT805    "
PRIVATE cabec1	 	:= " "
PRIVATE cabec2   	:= " "
PRIVATE nSizeSI3, nSizeSRJ
PRIVATE cFuncMat  	:= " "
PRIVATE _cULIT		:= '01'
PRIVATE _cUlSC		:= CA105NUM

_l655CTR := .F.
//filtra só entregas da filial sem recibo impresso
_cQry := "SELECT TNF.R_E_C_N_O_ AS NRRECNO FROM " + RetSqlName("TNF") + " TNF " 
_cQry += " WHERE TNF.D_E_L_E_T_ <> '*' AND TNF_FILIAL = '" + xFilial("TNF") + "' "
_cQry += " AND TNF_MAT = '" +M->RA_MAT+ "' AND TNF_DTRECI = '        ' "

If Select("QRYTNF") > 0
	QRYTNF->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "QRYTNF" , .T. , .F. )

QRYTNF->(DbGoTop())

_aDados:={} 
lTemErro:=.F.
SCP->(Dbsetorder(1))
Do While ! QRYTNF->(Eof())  
   
   TNF->(DbGoTo(QRYTNF->NRRECNO))
   aItem:={}
   AADD(aItem,.T.)
   cMens:="SA Gerada com sucesso"
   If EMPTY(TNF->TNF_NUMSA)

      AADD(aItem,_cUlSC+"*")
      If !SCP->(Dbseek(cFilAnt+_cUlSC))
         aItem[1]:=.F.    
         lTemErro:=.T.
         cMens:="Não gerou a SA corretamente"
      ENDIF

   Else

      AADD(aItem,TNF->TNF_NUMSA)
      If !SCP->(Dbseek(cFilAnt+TNF->TNF_NUMSA))
         aItem[1]:=.F.
         lTemErro:=.T.
         cMens:="Não gerou a SA corretamente"
      ENDIF

   EndIf
   AADD(aItem,TNF->TNF_MAT+"-"+NgSeek('SRA',TNF->TNF_MAT,1,'SRA->RA_NOME'))
// AADD(aItem,SRA->RA_RG)
// AADD(aItem,SRA->RA_NASC)
// AADD(aItem,SRA->RA_ADMISSA)
// AADD(aItem,Alltrim( Str( YEAR(DATE())-YEAR(SRA->RA_ADMISSA),3 ) )  )
   AADD(aItem,SRA->RA_CC+ "-"+NgSeek('SI3',SRA->RA_CC,1,'SI3->I3_DESC') )
// AADD(aItem,TNF->TNF_CODFUN+"-"+Alltrim (NgSeek('SRJ',TNF->TNF_CODFUN,1,'SRJ->RJ_DESC')) )      
   AADD(aItem,ALLTRIM(TNF->TNF_CODEPI)+"-"+NgSeek('SB1',TNF->TNF_CODEPI,1,'SB1->B1_DESC'))
   AADD(aItem,DTOC(TNF->TNF_DTENTR))			 
   AADD(aItem,TNF->TNF_HRENTR)
   AADD(aItem,TNF->TNF_QTDENT) 
   AADD(aItem,IF(TNF->TNF_INDDEV = "1","SIM","NAO"))
   AADD(aItem,cMens)
   AADD(aItem,QRYTNF->NRRECNO)
   
   AADD(_aDados,aItem)
   QRYTNF->(DBSKIP()) 

ENDDO

DO WHILE LEN(_aDados) > 0 .AND. lTemErro
   _aTit:={}
   _aSiz:={}
   AADD(_aTit,' ') 
   AADD(_aSiz,10)
   AADD(_aTit,'S.A.') 
   AADD(_aSiz,10)
   AADD(_aTit,'FUNCIONARIO') 
   AADD(_aSiz,120)
/* AADD(_aTit,'RG')
   AADD(_aSiz,35)
   AADD(_aTit,'NASC')
   AADD(_aSiz,35)
   AADD(_aTit,'ADMIS')
   AADD(_aSiz,30)
   AADD(_aTit,'IDADE')
   AADD(_aSiz,20)*/
   AADD(_aTit,'CENTRO DE CUSTO')
   AADD(_aSiz,100)
// AADD(_aTit,'FUNCAO')
// AADD(_aSiz,100)
   AADD(_aTit,'EPI')
   AADD(_aSiz,120)
   AADD(_aTit,'DT ENT')
   AADD(_aSiz,20)
   AADD(_aTit,'HORA')
   AADD(_aSiz,20)
   AADD(_aTit,'QTDE')
   AADD(_aSiz,20)
   AADD(_aTit,'DEVOLUCAO')
   AADD(_aSiz,20)
   AADD(_aTit,'RESULTADO')
   AADD(_aSiz,20)

   _cTitulo:="EPIs SEM SA"

   _cMsgTop:="ATENÇÃO: Não foi possível gerar a Solicitação ao Armazém, desta forma os EPIs entregues serão EXCLUIDOS do Funcionário. SOLUÇÃO: Refaça o processo de entrega de EPIs ao funcionário." 
   
   LDEL:=.F.

   bOk    :={|oDlg| IF(U_ITMSG("Confirma EXCLUIR os EPIs ENTREGUES ?"         ,'Atenção!',,2,2,2) , (LDEL:=.T. ,oDlg:End() ), )    }
   bCancel:={|oDlg| IF(U_ITMSG("Confirma SAIR SEM excluir os EPIs ENTREGUES ?",'Atenção!',,3,2,2) , (LDEL:=.F. ,oDlg:End() ), )    }

   //                           , _aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
      U_ITListBox(_cTitulo,_aTit,_aDados  , .T.    , 4    ,_cMsgTop,          ,_aSiz   ,         , bOk ,bCancel, )
                                                                                                  
   IF LDEL
      nConta:=0
      FOR D := 1 TO LEN(_aDados)  
         IF !_aDados[ D , 1 ]
            TNF->(DBGOTO( _aDados[ D , LEN( _aDados[D] ) ] ))
            TNF->(RECLOCK("TNF",.F.))
            TNF->(DBDELETE())
            nConta++
         ENDIF
      NEXT   
      
      U_ITMSG(ALLTRIM(STR(nConta))+" REGISTROS APAGADOS COM SUCESSO",'Atenção!',,2)
      
      IF LEN(_aDados) <> nConta
         EXIT
      ENDIF

   ENDIF

   RETURN .F.

ENDDO

nSizeSI3 := If((TAMSX3("I3_CUSTO")[1]) < 1,9,(TAMSX3("I3_CUSTO")[1]))
nSizeSRJ := If((TAMSX3("RJ_FUNCAO")[1]) < 1,4,(TAMSX3("RJ_FUNCAO")[1])) 



//=======================================================================
// Verifica as perguntas selecionadas                           
//=======================================================================

pergunte(cPerg,.F.)
MV_PAR01 := '      '
MV_PAR02 := 'ZZZZZZ'
MV_PAR03 := STOD('19900101')
MV_PAR04 := STOD('20301231')
MV_PAR05 := 1
MV_PAR06 := '     '
MV_PAR07 := 1
MV_PAR08 := 1
MV_PAR09 := '      '
MV_PAR10 := 'ZZZZZZ'
MV_PAR11 := 2
MV_PAR12 := 1
MV_PAR13 := STOD('19900101')
MV_PAR14 := STOD('20301231')
MV_PAR15 := XFILIAL("TNF")
MV_PAR16 := XFILIAL("TNF")
MV_PAR17 := 1
MV_PAR18 := 2

//=======================================================================
// Variaveis utilizadas para parametros                                     
// mv_par01             // De Funcionario                                   
// mv_par02             // Ate Funcionario                                  
// mv_par03             // De Data Entrega                                  
// mv_par04             // Ate Data Entrega                                 
// mv_par05             // So nao Impresos / Todos / Ultima retirada        
// mv_par06             // Termo de Responsabilidade                        
// mv_par07             // Duas vias                                        
// mv_par08             // Ordenar por                                      
// mv_par09             // De Centro de Custo                               
// mv_par10             // Ate Centro de Custo                              
// mv_par11             // Considerar funcionarios demitidos                
//                            1 - Sim                                       
//                            2 - Nao                                       
//=======================================================================


//=======================================================================
// Envia controle para a funcao SETPRINT                        
//=======================================================================
_cwnrel:="RMDT001"

//            cAlias,cProgram [ cPergunte ] [ cTitle ] [ cDesc1 ] [ cDesc2 ] [ cDesc3 ] [ lDic ] [ aOrd ] [ lCompres ] [ cSize ] [ uParm12 ] [ lFilter ] [ lCrystal ] [ cNameDrv ] [ uParm16 ] [ lServer ] [ cPortPrint ]  
// 
_cwnrel := SetPrint(_cString,_cwnrel ,              ,titulo    ,_cDesc1   ,_cDesc2  ,_cDesc3    ,.F.     ,""       ,           ,          ,           ,           ,             ,         ,          ,   .F.       ,             )

//_cwnrel:=SetPrint(_cString,_cwnrel,,titulo,_cDesc1,_cDesc2,_cDesc3,.F.,"")

If nLastKey == 27
If Select("QRYTNF") > 0
	QRYTNF->( DBCloseArea() )
EndIf
    Set Filter to
    Return

Endif

SetDefault(aReturn,_cString)

If nLastKey == 27
If Select("QRYTNF") > 0
	QRYTNF->( DBCloseArea() )
EndIf
   Set Filter to
   Return

Endif

RptStatus({|lEnd| RMDT001R(@lEnd,_cwnrel,titulo,tamanho)},titulo)

If Select("QRYTNF") > 0
	QRYTNF->( DBCloseArea() )
EndIf

RestArea(_aArea)

Return

/*
===============================================================================================================================
Programa----------: RMDT001R
Autor-------------: Josué Danich Prestes
Data da Criacao---: 01/09/2015
===============================================================================================================================
Descrição---------: Chamada do Relat¢rio 
===============================================================================================================================
Parametros--------: 	lEnd - controle de sucesso do relatório
						_cwnrel - objeto de impressão
						titulo - Título do relatório
						tamanho - se é condensado ou não
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RMDT001R(lEnd,_cwnrel,titulo,tamanho)

//=======================================================================
// Define Variaveis                                             
//=======================================================================
LOCAL _cCC := ""

//=======================================================================
// Variaveis para controle do cursor de progressao do relatorio 
//=======================================================================
LOCAL _nTotRegs := 0

//=======================================================================
// Variaveis locais exclusivas deste programa                   
//=======================================================================
LOCAL _aDBF := {}

//=======================================================================
// Contadores de linha e pagina                                 
//=======================================================================
PRIVATE li := 80 ,m_pag := 1
PRIVATE lCPONumcap := .t.,lCPODtVenc := .t.

If TNF->(FieldPos("TNF_NUMCAP")) <= 0

	lCPONumcap := .f.

Endif

AADD(_aDBF,{"FUNCI"  , "C", 06,0})           
AADD(_aDBF,{"NOME"   , "C", 40,0})           
AADD(_aDBF,{"RG"     , "C", 15,0})           
AADD(_aDBF,{"NASC"   , "D", 08,0})           
AADD(_aDBF,{"ADMIS"  , "D", 08,0})           
AADD(_aDBF,{"IDADE"  , "C", 03,0})           
AADD(_aDBF,{"CC"     , "C", nSizeSI3,0})
AADD(_aDBF,{"DESCC"  , "C", 60,0})  
AADD(_aDBF,{"FUNCAO" , "C", nSizeSRJ,0})
AADD(_aDBF,{"DESCFUN", "C", 20,0})   
AADD(_aDBF,{"CODEPI" , "C", 15,0}) 
AADD(_aDBF,{"DESEPI" , "C", 40,0}) 
AADD(_aDBF,{"DTENT"  , "D", 08,0}) 
AADD(_aDBF,{"HRENT"  , "C", 05,0}) 
AADD(_aDBF,{"QTDE"   , "N", 06,2}) 
AADD(_aDBF,{"DEV"    , "C", 01,0}) 
AADD(_aDBF,{"NUMCAP" , "C", 12,0}) 
AADD(_aDBF,{"NUMCRI" , "C", 12,0})
AADD(_aDBF,{"NUMCRF" , "C", 12,0})
AADD(_aDBF,{"DTDEVO" , "D", 08,0})
AADD(_aDBF,{"NUMSA"  , "C", 12,0})
AADD(_aDBF,{"ITEMSA" , "C", 12,0}) 
AADD(_aDBF,{"NRRECNO", "N", 10,0})

If Select("TRB") <> 0
	TRB->( DBCloseArea() )
EndIf

_otemp := FWTemporaryTable():New( "TRB", _aDBF )

If mv_par12 == 1  //Cod EPI

	_otemp:AddIndex( "01", {"FUNCI","CODEPI","DTENT"} )
	_otemp:AddIndex( "02", {"NOME","CODEPI","DTENT"} )
	_otemp:AddIndex( "03", {"CC","FUNCI","CODEPI","DTENT"} )
	_otemp:AddIndex( "04", {"DESCC","FUNCI","CODEPI","DTENT"} )

Else  //Nome EPI

	_otemp:AddIndex( "01", {"FUNCI","DESEPI","DTENT"} )
	_otemp:AddIndex( "02", {"NOME","DESEPI","DTENT"} )
	_otemp:AddIndex( "03", {"CC","FUNCI","DESEPI","DTENT"} )
	_otemp:AddIndex( "04", {"DESCC","FUNCI","DESEPI","DTENT"} )

Endif

_otemp:Create()

//=======================================================================
// Verifica se deve comprimir ou nao                            
//=======================================================================
_ntipo  := IIF(aReturn[4]==1,15,18)


Count to _nTotRegs

SetRegua(_nTotRegs)

QRYTNF->(DbGoTop())

//=======================================================================
// Efeuta a leitura dos dados da tabela TNF, com base no resultado da
// query para ler os  EPI's Entregues aos Funcionarios.
//=======================================================================
Do While ! QRYTNF->(Eof())  
   
   TNF->(DbGoTo(QRYTNF->NRRECNO))
	
	IncRegua()
	
	DbSelectArea("SRA")
	SRA->(DbSetOrder(1))
	SRA->(DbSeek(xFilial("SRA")+TNF->TNF_MAT))
	
	_cCC := SRA->RA_CC
 	cFuncMat := TNF->TNF_MAT
 	
   	dbSelectArea("TNF")       
	Reclock("TNF",.f.)
	TNF->TNF_DTRECI := Date()
	MsUnlock("TNF")
	
  	U_RMDT001G()
  	 
	QRYTNF->(DbSkip())	
	
EndDo

If Select("QRYTNF") > 0 
   QRYTNF->( DBCloseArea() )
EndIf

u_RMDT001I() 

DBSELECTAREA("TRB")
USE
      
//=======================================================================
// Devolve a condicao original do arquivo principal             
//=======================================================================
RetIndex("TNF")

Set Filter To

Set device to Screen

If aReturn[5] = 1

	Set Printer To
 	dbCommitAll()
  	OurSpool(_cwnrel)

Endif

MS_FLUSH()
DBSELECTAREA("TNF")
DBSETORDER(2)

Return NIL

/*
===============================================================================================================================
Programa----------: RMDT001S
Autor-------------: Josué Danich Prestes
Data da Criacao---: 01/09/2015
===============================================================================================================================
Descrição---------: Incrementa Linha e Controla Salto de Pagina
===============================================================================================================================
Parametros--------: 	Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RMDT001S()
  
li++

If li > 58   
 
     Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,_ntipo)

EndIf

Return
/*
          1         2         3         4         5         6         7         8         9         0         1         2         3
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
=====================================================================================================================================
XXXXXXXXXXXXX                                      COMPROVANTE DE ENTREGA DE EPI'S                                                 
SIGA/RMDT001                                    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                Emissao: 99/99/99   hh:mm    
=====================================================================================================================================
Funcionario.....: xxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                         RG.: xxx.xxx.xxx			        		
Centro de Custo.: xxxxxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx						 		                                    
Funcao..........: xxxx  -  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   					                                     		
Nascimento......: xx/xx/xx                                                               Admissao.: xx/xx/xx     Idade.: xx  		
=====================================================================================================================================
EPI              Nome do EPI                        Dt. Entr  Hora     Qtde  Dev. Dt. Devo  Num. CA 	                            
  Num. CRF      Num. CRI                           													                            
xxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xx/xx/xx  xx:xx  xxx,xx  xxx  xx/xx/xx  xxxxxxxxxxxx  Ass.: _________________  
  xxxxxxxxxxxx  xxxxxxxxxxxx                                                                                                       
xxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xx/xx/xx  xx:xx  xxx,xx  xxx  xx/xx/xx  xxxxxxxxxxxx  Ass.: _________________  
xxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xx/xx/xx  xx:xx  xxx,xx  xxx  xx/xx/xx  xxxxxxxxxxxx  Ass.: _________________  
                                                                               													
=====================================================================================================================================
       Data : ___/___/___                                                           							              	    
                                                                               													
|       Assinatura: _______________________                                   Resp Empr: _______________________                     
                                                                               													
=====================================================================================================================================
*/             

/*
===============================================================================================================================
Programa----------: RMDT001I
Autor-------------: Josué Danich Prestes
Data da Criacao---: 01/09/2015
===============================================================================================================================
Descrição---------: Impressão do Relatório
===============================================================================================================================
Parametros--------: 	Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RMDT001I()

Local linhaCorrente
Local _lPrimvez := .t.
Local _cDt := ""

DBSELECTAREA("TRB")
If mv_par08 == 1  //Matricula
	dbSetOrder(1)
Elseif mv_par08 == 2  //Nome Funcionario
	dbSetOrder(2)
Elseif mv_par08 == 3  //Cod. C. Custo
	dbSetOrder(3)
Elseif mv_par08 == 4  //Nome C. Custo
	dbSetOrder(4)	
Endif

Dbgotop()
DO WHILE !EOF()

	CFUNC := TRB->FUNCI
	nVolta := 0
	RMDT001S()
	@ li,000 PSay " "+Replicate("_",131)
	RMDT001S()
	@ li,000 PSay "|"
	@ li,001 Psay STR0027+ Substr(SM0->M0_NOMECOM,1,60) //"Empresa...:"
	@ li,083 Psay "CGC..:"+ SM0->M0_CGC
	@ li,132 PSay "|"
	RMDT001S()
	
	@ li,000 PSay "|"
	@ li,001 Psay STR0028+ SM0->M0_ENDENT //"Endereco..:"
	@ li,083 Psay STR0029 + SM0->M0_CIDCOB //"Cidade..:"
	@ li,118 Psay STR0030 +":"+ SM0->M0_ESTCOB //"Estado.."
	@ li,132 PSay "|"
	RMDT001S()
	@ li,000 PSay "|"
	@ li,001 PSay Replicate("_",131)
	@ li,132 PSay "|"
	
	RMDT001S()
	@ li,000 PSay STR0010 //"|Funcionario.....:"
	@ li,019 PSay CFUNC PICTURE "@!"
	@ li,026 PSAY " - " + TRB->NOME
	@ li,090 PSay STR0011 //"RG.:"
	@ li,095 PSay TRB->RG PICTURE "@!"
	@ li,132 PSay "|"
	
	RMDT001S()
	@ li,000 PSay STR0012 //"|Centro de Custo.:"

	@ li,019 PSay Alltrim(TRB->CC) +" - "+ Alltrim(TRB->DESCC)
	@ li,132 PSay "|"
	
	RMDT001S()                                 
	@ li,000 PSay STR0013 //"|Funcao..........:"
	@ li,019 PSay Alltrim(TRB->FUNCAO) +" - "+ Alltrim(TRB->DESCFUN) PICTURE "@!"
	@ li,132 PSay "|"
	
	RMDT001S()
	@ li,000 PSay STR0014 //"|Nascimento......:"
	@ li,019 PSay TRB->NASC PICTURE '99/99/99'
	@ li,090 PSay STR0015 //"Admissao.:"
	@ li,101 PSay TRB->ADMIS PICTURE '99/99/99'
	@ li,114 PSay STR0016 //"Idade.:"
	@ li,121 PSay TRB->IDADE +" "+ STR0039 //"anos"
	@ li,132 PSay "|"
	
	llinha := .f. 
	lFirst := .t.
	
	RMDT001S()
	@ li,000 PSay "|"
	@ li,001 PSay Replicate("_",131)
	@ li,132 PSay "|"
	RMDT001S()
	@ li,000 Psay "|"
	@ li,001 PSay STR0017     //"EPI"
	@ li,017 PSay STR0018     //"Nome do EPI"
	@ li,053 PSay STR0019     //"Dt. Entr"
	@ li,063 PSay STR0040     //"Hora"
	@ li,072 PSay STR0025     //"Qtde"
	@ li,078 PSay STR0020     //"Dev."

	If TNF->(FieldPos("TNF_DTDEVO")) > 0

		@ li,083 PSay STR0042 //"Dt. Devo"

	EndIf	

	@ li,093 PSay STR0026	  //"Num C.A."
	@ li,132 Psay "|"    
	RMDT001S()
	@ li,000 Psay "|"
	DbSelectArea("TN3")

	If TN3->(FieldPos("TN3_NUMCRF")) > 0

		@ li,002 PSay STR0033  //"Num. CRF"
		lLinha := .t.

	EndIf

	If TN3->(FieldPos("TN3_NUMCRI")) > 0

		@ li,016 PSay STR0034  //"Num. CRI"
		lLinha := .t.

	EndIf
	
	
	@ li,030 PSay "Num. SA"
	@ li,044 PSay "Item"


	DBSELECTAREA('TRB')

	While !Eof() .AND. TRB->FUNCI == CFUNC

			If lLinha .and. lFirst

				@ li,132 Psay "|"
				RMDT001S()
				@ li,000 PSay "|"

			EndIf

			If !lFirst

				RMDT001S()
				@ li,000 PSay "|"

			EndIf	

			lFirst := .f.
			_cDt := Strzero(Day(TRB->DTENT),2)+"/"+Strzero(Month(TRB->DTENT),2)+"/"+Substr(Str(Year(TRB->DTENT),4),3,2)
			
			@ li,001 PSAY TRB->CODEPI
			@ li,017 PSay substr(alltrim(TRB->DESEPI),1,32) PICTURE "@!"
			@ li,053 PSay _cDt PICTURE "99/99/99"
			@ li,063 PSay TRB->HRENT PICTURE "99:99"
			@ li,070 PSay TRB->QTDE  PICTURE "@E 999.99"

			IF TRB->DEV = "1"

				@ li,078 PSAY STR0021 //"SIM"

			ELSE

				@ li,078 PSAY STR0022  //"NAO"

			ENDIF

			_cDt := Strzero(Day(TRB->DTDEVO),2)+"/"+Strzero(Month(TRB->DTDEVO),2)+"/"+Substr(Str(Year(TRB->DTDEVO),4),3,2)

			If TNF->(FieldPos("TNF_DTDEVO")) > 0

				@ li,083 PSay _cDt PICTURE "99/99/99"

			ENDIF			

			If !Empty(TRB->NUMCAP)

				@ li,093 PSay Alltrim(SUBSTR(TRB->NUMCAP,1,12))    

			EndIf

			If llinha        

				@ li,132 Psay "|"
				RMDT001S()
				@ li,000 Psay "|"

			EndIf	

			DbSelectArea("TN3")

			IF TN3->(FieldPos("TN3_NUMCRF") > 0)

				@ li,002 PSay TRB->NUMCRF

			ENDIF

			IF TN3->(FieldPos("TN3_NUMCRI") > 0)

				@ li,016 PSay TRB->NUMCRI

			ENDIF
			
			//@ li,030 PSay TRB->NUMSA  
			//@ li,044 PSay TRB->ITEMSA 
			
			_nRegAtu := TNF->(Recno()) 	 
			TNF->(DbGoTo(TRB->NRRECNO)) 
			   
            @ li,030 PSay TNF->TNF_NUMSA   
			@ li,044 PSay TNF->TNF_ITEMSA			
			
			TNF->(DbGoTo(_nRegAtu)) 

			@ li,107 PSay "Ass.: _________________"
			@ li,132 PSay "|"
			nVolta++
			DBSELECTAREA("TRB")
			DBSKIP()

	ENDDO

	DBSKIP(-1)
	    	
	//termo
	dbSelectArea("TMZ")
	dbSetOrder(01)

	If dbSeek(xFilial("TMZ")+MV_PAR06)

		RMDT001S()
		@ li,000 PSay "|"
		@ li,001 PSay Replicate("_",131)
		@ li,132 PSay "|"
		RMDT001S()
		@ li,000 PSay "|"
		@ li,048 PSay STR0041 //"TERMO DE RESPONSABILIDADE"
		@ li,132 PSay "|"
		RMDT001S()
		@ li,000 PSay "|"
		lPrimeiro := .T.
		
		nLinhasMemo := MLCOUNT(TMZ->TMZ_DESCRI,130)

		For linhaCorrente := 1 to nLinhasMemo

			If lPrimeiro

				if !empty((MemoLine(TMZ->TMZ_DESCRI,56,linhaCorrente)))

					@ li,001 PSAY (MemoLine(TMZ->TMZ_DESCRI,130,linhaCorrente))
					@ li,132 PSay "|"
					lPrimeiro := .f.

				Else

					Exit

				Endif

			Else

				@ li,000 PSay "|"
				@ li,001 PSAY (MemoLine(TMZ->TMZ_DESCRI,130,linhaCorrente))
				@ li,132 PSay "|"

			EndIf

			RMDT001S()

		Next

		If !lPrimeiro

			@ li,000 PSay "|"

		Endif

		@ li,132 PSay "|"

	EndIf

	// fim do termo
	
	RMDT001S()
	@ li,000 PSay "|"
	@ li,001 PSay Replicate("_",131)
	@ li,132 PSay "|"
	RMDT001S()
	@ li,000 PSay "|"
	@ li,132 PSay "|"
	RMDT001S()
	@ li,000 PSay STR0036 //"|       Data : ____/____/____"
	@ li,132 PSay "|"
	RMDT001S()
	@ li,000 PSay "|"
	@ li,132 PSay "|"
	RMDT001S()
	@ li,000 PSay STR0037 //"|       Assinatura: _______________________                                   Resp Empr: _______________________"
	@ li,132 Psay "|"
	RMDT001S()
	@ li,000 Psay "|"
	@ li,132 Psay "|"
	RMDT001S()
	@ li,000 PSay "|"
	@ li,001 PSay Replicate("_",131)
	@ li,132 PSay "|"        
	li := 80

	If mv_par07 == 2 .and. _lPrimvez

		DbSelectArea("TRB")
		DbSkip(-(nVolta-1))
		_lPrimvez := .f.

	Else

		DbSelectArea("TRB")     
		DbSkip()
		_lPrimvez := .t.

	EndIf
	
EndDo

Return

/*
===============================================================================================================================
Programa----------: RMDT001G
Autor-------------: Josué Danich Prestes
Data da Criacao---: 01/09/2015
===============================================================================================================================
Descrição---------: Armazena informacoes de um recibo para impressao.
===============================================================================================================================
Parametros--------: 	Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RMDT001G()

DBSelectArea("TN3")
TN3->(DBSetorder(1))
TN3->(DBSeek(XFILIAL("TN3")+TNF->TNF_FORNEC+TNF->TNF_LOJA+TNF->TNF_CODEPI+TNF->TNF_NUMCAP))

DBSelectArea("TRB")
TRB->(DbAppend())
TRB->FUNCI    := cFuncMat
TRB->NOME     := SubStr(NgSeek('SRA',cFuncMat,1,'SRA->RA_NOME'),1,40)
TRB->RG       := NgSeek('SRA',cFuncMat,1,'SRA->RA_RG')
TRB->NASC     := NgSeek('SRA',cFuncMat,1,'SRA->RA_NASC')
TRB->ADMIS    := NgSeek('SRA',cFuncMat,1,'SRA->RA_ADMISSA')
TRB->IDADE    := Alltrim( Str( YEAR(DATE())-YEAR(TRB->NASC),3 ) )
TRB->CC       := NgSeek('SRA',cFuncMat,1,'SRA->RA_CC')
TRB->DESCC    := NgSeek('SI3',TRB->CC,1,'SI3->I3_DESC')
TRB->FUNCAO   := TNF->TNF_CODFUN
TRB->DESCFUN  := Alltrim (NgSeek('SRJ',TRB->FUNCAO,1,'SRJ->RJ_DESC'))       
TRB->CODEPI   := TNF->TNF_CODEPI
TRB->DESEPI   := NgSeek('SB1',TNF->TNF_CODEPI,1,'SB1->B1_DESC')
TRB->DTENT    := TNF->TNF_DTENTR			 
TRB->HRENT    := TNF->TNF_HRENTR
TRB->QTDE     := TNF->TNF_QTDENT
TRB->DEV      := TNF->TNF_INDDEV
TRB->NUMCAP   := If(lCPONumcap,TNF->TNF_NUMCAP,TN3->TN3_NUMCAP)
TRB->NRRECNO  := TNF->(Recno())

If  empty(TNF->TNF_NUMSA)
	//grava SCP gravada nessa liberação e controla item da SCP
	TRB->NUMSA 	:= _cUlSC+"*"
	TRB->ITEMSA	:= strzero(val(_cULIT),2)
	_cUlit := strzero(val(_cULIT)+1,2)
Else
	//Grava SCP já salva anteriormente
	TRB->NUMSA		:= TNF->TNF_NUMSA
	TRB->ITEMSA	:= strzero(val(_cULIT),2)
	_cUlit := strzero(val(_cULIT)+1,2)
	_cUlSC := TNF->TNF_NUMSA
EndIf

IF TN3->(FieldPos("TN3_NUMCRI")) > 0 
	TRB->NUMCRI    := TN3->TN3_NUMCRI
EndIf

IF TN3->(FieldPos("TN3_NUMCRF")) > 0 
	TRB->NUMCRF    := TN3->TN3_NUMCRF
EndIf

If TNF->(FieldPos("TNF_DTDEVO")) > 0
	TRB->DTDEVO    := TNF->TNF_DTDEVO
EndIf

Return