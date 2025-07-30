/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço  |31/07/2024| Chamado 47132. Jerry. Inclusão dos campos C5_I_OPER,C5_I_NFSED na ordem 8
Julio Paz     |13/08/2024| Chamado 47782. Jerry. Incluir nova coluna para exibir o novo campo Tipo Averb. Carga (A2_I_TPAVE).
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipulação do SX1
Lucas Borges  |23/07/2025| Chamado 51340. Ajustar função para validação de ambiente de teste
=========================================================================================================================================================
Analista         - Programador       - Inicio     - Envio    - Chamado - Motivo da Alteração
---------------------------------------------------------------------------------------------------------------------------------------------------------
Jerry Santiago   - Igor Melgaço      - 03/02/2025 - 20/03/25 - 39201   - Ajustes para inclusão do campo C5_I_QTDA
=========================================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include "Report.ch"
#Include "Protheus.ch"

Static ST_EMISSAO, ST_PEDIDO, ST_CARGA, ST_DOCNTO, ST_CODCLI, ST_CLIENTE, ST_FILIAL
Static ST_PEDCLI, ST_PEDITA, ST_DTENT, ST_TPAGEN, ST_PEDPOR, ST_OBSNF, ST_PEDDW 
 
/*
===============================================================================================================================
Programa--------: ROMS003
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Relatório de Faturamento de Vendas
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
User function ROMS003()

private oBrkPed
Private oBrkSup
Private oBrkRede
Private oBrkNF
Private oBrkDtEmis
Private oBrkProdut
Private oReport   
Private oSF2FIL_1
Private oSF2_1
Private oSF2_1A
Private oSF2S_1
Private oSF2A_1
Private oSF2FIL_3
Private oSF2_3
Private oSF2S_3
Private oSF2A_3
Private oSF2FIL_4
Private oSF2_4
Private oSF2S_4
Private oSF2A_4
Private oSF2FIL_5
Private oSF2_5
Private oSF2S_5
Private oSF2A_5
Private oSF2FIL_6
Private oSF2_6
Private oSF2S_6
Private oSF2A_6
Private oSF2FIL_8
Private oSF2_8
Private oSF2A_8
Private oSF2S_8
Private oSF2FIL_9
Private oSF2_9
Private oSF2S_9
Private oSF2FIL_13
Private oSF2DT_13
Private oSF2_13
Private oSF2A_13
Private _cPerg := "ROMS003"
Private QRY1
Private QRY2
Private QRY3
Private QRY4
Private QRY5
Private QRY6
Private QRY7
Private QRY8
Private QRY9
Private QRY13                                     // 24 RELATORIOS NO TOTAL:
Private aOrd:= {"01 -Coordenador",;               // ORDEM 01 Analitivo e Sintetico//14   
                "02 -Coordenador x Produto*",;    // ORDEM 02 Sintetico com U_ITListBox e TMSPrinter()//15   
		    	"03 -Produto",;                   // ORDEM 03 Analitivo e Sintetico//16   
		    	"04 -Rede",;                      // ORDEM 04 Analitivo e Sintetico//17  
		    	"05 -Estado x Produto",;          // ORDEM 05 Analitivo e Sintetico//18   
		    	"06 -Municipio",;                 // ORDEM 06 Analitivo e Sintetico//19   
		    	"07 -Cliente" ,;                  // ORDEM 07 Analitivo e Sintetico//20   
		    	"08 -Emissão",;                   // ORDEM 08 Analitivo e Sintetico//21   
		    	"09 -Estado x Grupo de Produtos",;// ORDEM 09 Sintetico            
		    	"10 -Produto Sintetico*",;        // ORDEM 10 Sintetico com U_ITListBox e TMSPrinter()//22
		    	"11 -Sub Grupo Sintetico*",;      // ORDEM 11 Sintetico com U_ITListBox e TMSPrinter()//23    
		    	"12 -Estado x Sub-Grupo*",;       // ORDEM 12 Sintetico com U_ITListBox e TMSPrinter()//24   
		    	"13 -Dia X Estado x Produto"}     // ORDEM 13 Sintetico          
private cVendedor  := " "
private cCoordenador:= " "
private cRede      := " " 
private cDataEntr  := " "  
private cProduto   := " "
private cEstado    := " "
private cMunicipio := " "
private cCliente   := " "
private cNF		   := " "
private cNomeFil   := " " 
private cDtEmissao := " "  
Private _cDia      := " "
private nqtdeCor   := 0        
Private _nVlrTotal := 0
Private _cClassEnt := " "//A1_I_CLABC
private _aItalac_F3:={}     //    1           2         3                        4                            5            6             7         8               9         10             11        12

MV_PAR32 := ""
_cCombo := Getsx3cache("B1_I_BIMIX","X3_CBOX")
_aDados := STRTOKARR(_cCombo, ';')
//Italac_F3:={}         1           2         3                        4                            5            6             7         8        9         10       11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave              , nCpoDesc                   ,bCondTab , cTitAux      , nTamChv , aDados  , nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR32",           ,                        ,                             ,          ,"Grupo Mix",2       ,_aDados  ,Len(_aDados)} )
AADD(_aItalac_F3,{"MV_PAR33","ZB4"		,                        ,                             ,          ,"Tipo de Operacao"} )

IF !Pergunte(_cPerg,.T.)
   RETURN .F.
ENDIF

DEFINE REPORT oReport NAME "ROMS003" TITLE "Relação de Vendas Faturadas" PARAMETER _cPerg ACTION {|oReport| ROM003P(oReport)} 

//Seta Padrao de impressao Paisagem.
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

//====================================================================================================
//Define secoes para primeira ORDEM 01 - Coordenador
//====================================================================================================
//Secao Filial
DEFINE SECTION oSF2FIL_1 OF oReport TITLE "Filial Coordenador" TABLES "SB1","SD2","SF2","SA3"  ORDERS aOrd
DEFINE CELL NAME "D2_FILIAL"	OF oSF2FIL_1 ALIAS "SD2"  TITLE "Cod "
DEFINE CELL NAME "NOMFIL"	    OF oSF2FIL_1 ALIAS "" BLOCK{|| FWFilialName(,QRY1->D2_FILIAL)} TITLE "Filial" SIZE 20

oSF2FIL_1:OnPrintLine({|| cNomeFil := QRY1->D2_FILIAL  + " -  " + FWFilialName(,QRY1->D2_FILIAL)  })
oSF2FIL_1:SetTotalText({|| "SUBTOTAL FILIAL: " + cNomeFil})                                                        
oSF2FIL_1:Disable()

//Secao Coordenador
DEFINE SECTION oSF2_1 OF oSF2FIL_1 TITLE "Coordenador" TABLES "SB1","SD2","SF2","SA3"  
DEFINE CELL NAME "F2_VEND2"	      OF oSF2_1 ALIAS "SF2" TITLE "Cod.Coordenador"
DEFINE CELL NAME "Coordenador"    OF oSF2_1 ALIAS "SF2" TITLE "Nome"            BLOCK{|| if(EMPTY(QRY1->F2_VEND2),"VENDEDOR SEM Coordenador", QRY1->A3_NOMEC )} SIZE 40
DEFINE CELL NAME "TIPO"           OF oSF2_1 ALIAS "SF2" TITLE "Tipo Coord."     BLOCK{|| if(EMPTY(QRY1->F2_VEND2),"",ROMS03TR(QRY1->A3_TIPOC))} SIZE 20
DEFINE CELL NAME "REGIAO"         OF oSF2_1 ALIAS "SF2" TITLE "Regiao Gerente"  BLOCK{|| if(EMPTY(QRY1->F2_VEND2),"",ROMS03TR("REGIAO"))      } SIZE 40

oSF2_1:SetTotalText({|| "SUBTOTAL Coordenador: " + POSICIONE("SA3",1,xFilial("SA3")+QRY1->F2_VEND2,"A3_NOME")})    
oSF2_1:Disable()

DEFINE BREAK oBrkSup OF oSF2_1 WHEN oSF2_1:Cell("F2_VEND2") TITLE {|| "SUBTOTAL Coordenador: " + cCoordenador}

oBrkSup:OnPrintTotal({|| oReport:SkipLine(4)})

//Secao Vendedor - SubSecao da Secao SF2_1
DEFINE SECTION oSF2_1A OF oSF2_1 TITLE "Vendedor" TABLES "SA3","SF2"
DEFINE CELL NAME "F2_VEND1"  	OF oSF2_1A ALIAS "SF2" TITLE "Vendedor"
DEFINE CELL NAME "A3_NOME" 		OF oSF2_1A ALIAS "SA3"
DEFINE CELL NAME "TIPOV"        OF oSF2_1A ALIAS "SF2" TITLE "Tipo Representante" BLOCK{|| if(EMPTY(QRY1->F2_VEND1),"",ROMS03TR(QRY1->A3_TIPOV))} SIZE 20

oSF2_1A:SetTotalInLine(.F.)
oSF2_1A:SetTotalText({||"SUBTOTAL VENDEDOR: " + cVendedor  })
oSF2_1A:OnPrintLine({|| cVendedor := QRY1->F2_VEND1 + " - " + QRY1->A3_NOME, cCoordenador := QRY1->F2_VEND2 + " - " + if(empty(QRY1->F2_VEND2),"VENDEDOR SEM Coordenador", POSICIONE("SA3",1,xFilial("SA3")+QRY1->F2_VEND2,"A3_NOME")),AllwaysTrue()}) //Atualiza Variavel do Subtotal
oSF2_1A:Disable()

//Secao Detalhes SINTETICO - SubSecao da Secao SF2_1A
DEFINE SECTION oSF2S_1          OF oSF2_1A TITLE "Sintetico Ordem 1 - Coordenador" TABLES "SD2","SB1" 
DEFINE CELL NAME "B1_COD"	    OF oSF2S_1 ALIAS "SD2" TITLE "Produto"
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2S_1 ALIAS "SB1" TITLE "Descricao" SIZE 40 //BLOCK {|| if (!empty(QRY1->D2_I_DQESP),QRY1->D2_I_DQESP,QRY1->B1_I_DESCD)}
DEFINE CELL NAME "D2_QUANT"	    OF oSF2S_1 ALIAS "SD2" PICTURE "@E 999,999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY1->D2_QUANT,QRY1->D2_QUANT-QRY1->D2_QTDEDEV/*ROMS003Q1(QRY1->D2_UM,QRY1->D2_SEGUM,QRY1->B1_COD,QRY1->D2_FILIAL,QRY1->F2_VEND1,QRY1->F2_VEND2,'D2_QTDEDEV')*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2S_1 ALIAS "SD2" TITLE "Un. M" SIZE 5
DEFINE CELL NAME "D2_QTSEGUM" 	OF oSF2S_1 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 14 BLOCK{|| If(MV_PAR22 == 2,QRY1->D2_QTSEGUM,QRY1->D2_QTSEGUM - ROMS003L(QRY1->D2_QUANT,QRY1->D2_QTDEDEV,QRY1->D2_QTSEGUM)/*ROMS003Q1(QRY1->D2_UM,QRY1->D2_SEGUM,QRY1->B1_COD,QRY1->D2_FILIAL,QRY1->F2_VEND1,QRY1->F2_VEND2,'D2_QTSEGUM')*/)}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2S_1 ALIAS "SD2" TITLE "Seg. UM" SIZE 5   
DEFINE CELL NAME "D2_TOTAUX" 	OF oSF2S_1 ALIAS "SD2" PICTURE "@E 999,999,999,999.99" SIZE 17 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY1->D2_TOTAL,QRY1->D2_TOTAL-QRY1->D2_VALDEV/*ROMS003QD(QRY1->D2_UM,QRY1->D2_SEGUM,QRY1->B1_COD,QRY1->D2_FILIAL,QRY1->F2_VEND1,QRY1->F2_VEND2,.F.)*/) }  //MV_PAR22 == 2 Nao considera devolucoes 
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2S_1 ALIAS "SD2" PICTURE "@E 999,999.9999" SIZE 08 TITLE "Vlr. Uni." BLOCK {||If(nqtdeCor >0,_nVlrTotal/nqtdeCor,0) }
DEFINE CELL NAME "D2_TOTAL" 	OF oSF2S_1 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal }  
DEFINE CELL NAME "D2_VALBRUT" 	OF oSF2S_1 ALIAS "SD2" PICTURE "@E 999,999,999,999.99" SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY1->D2_VALBRUT,QRY1->VLRBRUTDEV/*QRY1->D2_VALBRUT-ROMS003QD(QRY1->D2_UM,QRY1->D2_SEGUM,QRY1->B1_COD,QRY1->D2_FILIAL,QRY1->F2_VEND1,QRY1->F2_VEND2,.T.)*/) }  //MV_PAR22 == 2 Nao considera devolucoes 
DEFINE CELL NAME "C5_I_PEDDW"	OF oSF2S_1 ALIAS "SC5" TITLE "Pedido Externo." 
DEFINE CELL NAME "C5_ASSNOM"	OF oSF2S_1 ALIAS "SC5" TITLE "Assistente Comercial Resp." 
DEFINE CELL NAME "ASSI_EMAIL"	OF oSF2S_1 ALIAS ""    TITLE "E-MAIL Assistente Comercial Resp." BLOCK {|| IF(!EMPTY(QRY1->C5_ASSCOD),POSICIONE("ZPG",1,xFilial("ZPG")+QRY1->C5_ASSCOD,"ZPG_EMAIL")," ") } PICTURE ""  SIZE 40
DEFINE CELL NAME "LOC_EMB"	    OF oSF2S_1 ALIAS ""    TITLE "Local de Embarque"                 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY1->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" SIZE 40
DEFINE CELL NAME "ZY4_DESCRI"   OF oSF2S_1 ALIAS ""    TITLE "Evento Comercial"                  BLOCK {|| POSICIONE("ZY4",1,XFILIAL("ZY4")+QRY1->C5_I_EVENT,"ZY4_DESCRI") } SIZE 50 
DEFINE CELL NAME "F2_I_DTRC"    OF oSF2S_1 ALIAS "SF2" TITLE "Data Canhoto" SIZE 10  

oSF2S_1:Cell("D2_TOTAUX"):Disable()
 
oSF2S_1:SetTotalInLine(.F.)
oSF2S_1:SetTotalText({||"SUBTOTAL VENDEDOR:" + cVendedor })
oSF2S_1:OnPrintLine({|| cVendedor := QRY1->F2_VEND1 + " - " + QRY1->A3_NOME, cCoordenador := QRY1->F2_VEND2 + " - " + if(empty(QRY1->F2_VEND2),"VENDEDOR SEM Coordenador", POSICIONE("SA3",1,xFilial("SA3")+QRY1->F2_VEND2,"A3_NOME")),AllwaysTrue()}) //Atualiza Variavel do Subtotal
oSF2S_1:Disable()
 
//Secao Detalhes ANALITICO - SubSecao da Secao SF2_1A
DEFINE SECTION oSF2A_1          OF oSF2_1A TITLE "Analitico Ordem 1 - Coordenador" TABLES "SD2","SB1" 
DEFINE CELL NAME "B1_COD"	    OF oSF2A_1 ALIAS "SD2" TITLE "Produto"  SIZE 10
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2A_1 ALIAS "SB1" TITLE "Descricao" SIZE 30 
DEFINE CELL NAME "D2_CLIENTE" 	OF oSF2A_1 ALIAS "SD2" SIZE 6
DEFINE CELL NAME "D2_LOJA" 		OF oSF2A_1 ALIAS "SD2" SIZE 05
DEFINE CELL NAME "A1_NREDUZ" 	OF oSF2A_1 ALIAS "SA1" SIZE 20
DEFINE CELL NAME "F2_DOC" 		OF oSF2A_1 ALIAS "SF2" TITLE "Documento" SIZE 12
DEFINE CELL NAME "F2_EMISSAO"   OF oSF2A_1 ALIAS "SF2" TITLE "Emissão NFe" SIZE 10  
DEFINE CELL NAME "D2_QUANT"	    OF oSF2A_1 ALIAS "SD2" PICTURE "@E 99999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY1->D2_QUANT,QRY1->D2_QUANT-QRY1->D2_QTDEDEV/*ROMS003Q(QRY1->F2_DOC,QRY1->F2_SERIE,QRY1->D2_QTDEDEV,QRY1->D2_FILIAL,QRY1->B1_COD)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2A_1 ALIAS "SD2" TITLE "U.M." SIZE 5
DEFINE CELL NAME "D2_QTSEGUM" 	OF oSF2A_1 ALIAS "SD2" PICTURE "@E 999,999.999" SIZE 12 BLOCK{|| If(MV_PAR22 == 2,QRY1->D2_QTSEGUM,QRY1->D2_QTSEGUM-ROMS003L(QRY1->D2_QUANT,QRY1->D2_QTDEDEV,QRY1->D2_QTSEGUM)/* - ROMS003L(QRY1->D2_QUANT,ROMS003Q(QRY1->F2_DOC,QRY1->F2_SERIE,QRY1->D2_QTDEDEV,QRY1->D2_FILIAL,QRY1->B1_COD),QRY1->D2_QTSEGUM)*/)}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2A_1 ALIAS "SD2" TITLE "2 U.M." SIZE 6

DEFINE CELL NAME "PESOUNI" 		OF oSF2A_1 ALIAS "SC6" TITLE "Peso Unitário" SIZE 11 BLOCK {|| RETPESOU(QRY1->D2_FILIAL,QRY1->D2_DOC,QRY1->D2_SERIE,QRY1->B1_COD)} PICTURE "@E 999,999.9999"
DEFINE CELL NAME "PESBRU" 		OF oSF2A_1 ALIAS "SC5" TITLE "P.Bruto PDV" 	 SIZE 11 BLOCK {|| POSICIONE("SC5",1,QRY1->D2_FILIAL+QRY1->D2_PEDIDO,"C5_I_PESBR")} PICTURE "@E 999,999.9999"

DEFINE CELL NAME "D2_TOTAUX" 	OF oSF2A_1 ALIAS "SD2" PICTURE "@E 999,999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY1->D2_TOTAL,QRY1->D2_TOTAL-QRY1->D2_VALDEV/*-ROMS003V(QRY1->F2_DOC,QRY1->F2_SERIE,QRY1->D2_VALDEV,QRY1->D2_FILIAL,0,0,'D2_TOTAL',QRY1->B1_COD)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2A_1 ALIAS "SD2" PICTURE "@E 99,999.9999" SIZE 12 TITLE "Vlr. Uni." BLOCK {|| if(nqtdeCor > 0,_nVlrTotal/nqtdeCor,0) }
DEFINE CELL NAME "CUSTNET" 		OF oSF2A_1 ALIAS "SZW" TITLE "Cust. Net" SIZE 11 BLOCK {|| RCUSTNET(QRY1->D2_FILIAL, QRY1->D2_CLIENTE, QRY1->D2_LOJA, QRY1->B1_COD, QRY1->D2_PEDIDO)} PICTURE "@E 999,999.9999"
DEFINE CELL NAME "D2_TOTAL" 	OF oSF2A_1 ALIAS "SD2" PICTURE "@E 999,999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_VALBRUT" 	OF oSF2A_1 ALIAS "SD2" PICTURE "@E 999,999,999,999.99" SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY1->D2_VALBRUT,QRY1->VLRBRUTDEV/*QRY1->D2_VALBRUT - ROMS003V(QRY1->F2_DOC,QRY1->F2_SERIE,QRY1->D2_VALDEV,QRY1->D2_FILIAL,QRY1->D2_TOTAL,QRY1->D2_ICMSRET,'D2_VALDEV',QRY1->B1_COD)*/) }  //MV_PAR22 == 2 Nao considera devolucoes

DEFINE CELL NAME "D2_LOCAL" 	OF oSF2A_1 ALIAS "SD2" TITLE "Armazem"      SIZE 07 // Armazem
DEFINE CELL NAME "NNR_DESCRI" 	OF oSF2A_1 ALIAS "SD2" TITLE "Desc.Armazem" SIZE 20 BLOCK {|| Posicione("NNR",1,xfilial("NNR") + QRY1->D2_LOCAL,"NNR_DESCRI")}  // Descrição Armazem

DEFINE CELL NAME "C5_I_TRCNF" 	OF oSF2A_1 ALIAS "SC5" TITLE "Troca NF?"    SIZE 8 BLOCK {|| If(QRY1->C5_I_TRCNF=="S","SIM","NAO")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_FILFT" 	OF oSF2A_1 ALIAS "SC5" TITLE "Filial Fat."  SIZE 8 BLOCK {|| If(QRY1->C5_I_TRCNF=="S",QRY1->C5_I_FILFT+"-"+U_ROMS003F(QRY1->C5_I_FILFT)," ")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_FLFNC" 	OF oSF2A_1 ALIAS "SC5" TITLE "Filial Carr." SIZE 8 BLOCK {|| If(QRY1->C5_I_TRCNF=="S",QRY1->C5_I_FLFNC+"-"+U_ROMS003F(QRY1->C5_I_FLFNC)," ")}  PICTURE "@!"

DEFINE CELL NAME "DAI_I_OPLO"   OF oSF2A_1 ALIAS "DAI" TITLE "Op. Log."     SIZE 8 BLOCK {|| QRY1->DAI_I_OPLO} PICTURE "@!"
DEFINE CELL NAME "DAI_I_OPLO" 	OF oSF2A_1 ALIAS "DAI" TITLE "Nome Op Log"  SIZE 8 BLOCK {||  If(!Empty(Alltrim(QRY1->DAI_I_OPLO)),posicione("SA2",1,xfilial("SA2") + QRY1->DAI_I_OPLO,"A2_NREDUZ")," ")}  PICTURE "@!"

   DEFINE CELL NAME "WK_FILIAL"  OF oSF2A_1 ALIAS "SC5" TITLE "Filial TNF"   SIZE 30  BLOCK {|| U_ROMS003J("WK_FILIAL", QRY1->D2_FILIAL,QRY1->C5_NUM) }
   DEFINE CELL NAME "WK_EMISSAO" OF oSF2A_1 ALIAS "SF2" TITLE "Emissão PV"   SIZE 10  BLOCK {|| U_ROMS003J("WK_EMISSAO")}
   DEFINE CELL NAME "WK_PEDIDO"  OF oSF2A_1 ALIAS "SD2" TITLE "Pedido"       SIZE 10  BLOCK {|| U_ROMS003J("WK_PEDIDO") }
   DEFINE CELL NAME "WK_CARGA"   OF oSF2A_1 ALIAS "SF2" TITLE "Carga"        SIZE 10  BLOCK {|| U_ROMS003J("WK_CARGA")  }
   DEFINE CELL NAME "WK_DOCNTO"  OF oSF2A_1 ALIAS "SF2" TITLE "Documento"    SIZE 15  BLOCK {|| U_ROMS003J("WK_DOCNTO")  }
   DEFINE CELL NAME "WK_CODCLI"  OF oSF2A_1 ALIAS "SA1" TITLE "Cod.Cliente"  SIZE 11  BLOCK {|| U_ROMS003J("WK_CODCLI") }
   DEFINE CELL NAME "WK_CLIENTE" OF oSF2A_1 ALIAS "SA1" TITLE "Nome Cliente" SIZE 60  BLOCK {|| U_ROMS003J("WK_CLIENTE") }
 
DEFINE CELL NAME "WK_PEDCLI"  OF oSF2A_1 ALIAS "SF2" TITLE "Ped Cliente"  SIZE 15  BLOCK {|| U_ROMS003J("WK_PEDCLI")  }
DEFINE CELL NAME "WK_PEDITA"  OF oSF2A_1 ALIAS "SF2" TITLE "Ped Italac"   SIZE 15  BLOCK {|| U_ROMS003J("WK_PEDITA") }
DEFINE CELL NAME "WK_DTENT"   OF oSF2A_1 ALIAS "SF2" TITLE "Dt Entrega"   SIZE 15  BLOCK {|| U_ROMS003J("WK_DTENT") }
DEFINE CELL NAME "WK_TPAGEN"  OF oSF2A_1 ALIAS "SF2" TITLE "Tipo Agenda"  SIZE 15  BLOCK {|| U_ROMS003J("WK_TPAGEN") }
DEFINE CELL NAME "WK_PEDPOR"  OF oSF2A_1 ALIAS "SF2" TITLE "Ped Portal"   SIZE 15  BLOCK {|| U_ROMS003J("WK_PEDPOR") }
DEFINE CELL NAME "WK_PEDDW"	  OF oSF2A_1 ALIAS "SC5" TITLE "Pedido Externo" SIZE 15  BLOCK {|| U_ROMS003J("WK_PEDDW") }
DEFINE CELL NAME "WK_OBSNF"   OF oSF2A_1 ALIAS "SF2" TITLE "Obs NF"         SIZE 60  BLOCK {|| U_ROMS003J("WK_OBSNF") }

DEFINE CELL NAME "B1_I_BIMIX"   OF oSF2A_1 ALIAS "SB1" TITLE "Grupo Mix"      SIZE 2   BLOCK {|| Posicione("SB1",1,xFilial("SB1")+QRY1->B1_COD,"B1_I_BIMIX")} PICTURE "@!"
DEFINE CELL NAME "C5_I_OPER" 	OF oSF2A_1 ALIAS "SC5" TITLE "Oper."          SIZE 5  
DEFINE CELL NAME "C5_I_OPTRI"	OF oSF2A_1 ALIAS "SC5" TITLE "Tp PV Op Tri?"  SIZE 13
DEFINE CELL NAME "C5_I_PVREM"   OF oSF2A_1 ALIAS "SC5" TITLE "PV Remessa"     SIZE 10 
DEFINE CELL NAME "C5_I_PVFAT"   OF oSF2A_1 ALIAS "SC5" TITLE "PV Faturamento" SIZE 14
DEFINE CELL NAME "C5_I_CLIEN"   OF oSF2A_1 ALIAS "SC5" TITLE "Cliente Rem."   SIZE 11
DEFINE CELL NAME "C5_I_LOJEN"   OF oSF2A_1 ALIAS "SC5" TITLE "Loja Rem."      SIZE 10
DEFINE CELL NAME "A1_NOME"      OF oSF2A_1 ALIAS ""    TITLE "Razao Social Cli.Rem."  SIZE 40 BLOCK {|| QRY1->NOME_CLIREM} PICTURE "@!"
DEFINE CELL NAME "A1_NREDUZ"    OF oSF2A_1 ALIAS "SA1" TITLE "Nome Fantasia Cli.Rem." SIZE 30 BLOCK {|| QRY1->FANTASIA_CLIREM} PICTURE "@!"
DEFINE CELL NAME "F2_I_NTRIA"   OF oSF2A_1 ALIAS "SF2" TITLE "Nfe Adquiren"   SIZE 12
DEFINE CELL NAME "F2_I_STRIA"   OF oSF2A_1 ALIAS "SF2" TITLE "Ser Adquiren"   SIZE 5
DEFINE CELL NAME "F2_I_DTRIA"   OF oSF2A_1 ALIAS "SF2" TITLE "Data Nfe Adq"   SIZE 12
DEFINE CELL NAME "C5_ASSNOM"	OF oSF2A_1 ALIAS "SC5" TITLE "Assistente Comercial Resp." 
DEFINE CELL NAME "ASSI_EMAIL"	OF oSF2A_1 ALIAS ""    TITLE "E-MAIL Assistente Comercial Resp." BLOCK {|| IF(!EMPTY(QRY1->C5_ASSCOD),POSICIONE("ZPG",1,xFilial("ZPG")+QRY1->C5_ASSCOD,"ZPG_EMAIL")," ") } PICTURE ""  SIZE 40
DEFINE CELL NAME "LOC_EMB"	    OF oSF2A_1 ALIAS ""    TITLE "Local de Embarque"                 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY1->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" SIZE 40
DEFINE CELL NAME "DIASVIAGEM"   OF oSF2A_1 ALIAS ""    TITLE "Dias de Viagem"                    BLOCK {|| U_ROMS3DLT("DIASVIAGEM") } PICTURE "@E 9,999,999" SIZE 15
DEFINE CELL NAME "DIASOPERAC"   OF oSF2A_1 ALIAS ""    TITLE "Dias Operacional"                  BLOCK {|| U_ROMS3DLT("DIASOPERAC") } PICTURE "@E 9,999,999" SIZE 15
DEFINE CELL NAME "LEADTIME"     OF oSF2A_1 ALIAS ""    TITLE "Lead Time"                         BLOCK {|| U_ROMS3DLT("LEADTIME"  ) } PICTURE "@E 9,999,999" SIZE 15
If SuperGetMV("IT_AMBTEST",.F.,.T.)
   DEFINE CELL NAME "REGRA"     OF oSF2A_1 ALIAS ""    TITLE "Regra encontrada"                  BLOCK {|| U_ROMS3DLT("REGRA"  ) } SIZE 200
ENDIF
DEFINE CELL NAME "CLASSENT"     OF oSF2A_1 ALIAS ""    TITLE "Classificacao Entrega"             BLOCK {|| _cClassEnt} SIZE 60  //Variavel preenchida na funçao U_ROMS3DLT - A1_I_CLABC
DEFINE CELL NAME "MESOREGI"     OF oSF2A_1 ALIAS ""    TITLE "Mesorregiao"  BLOCK {|| POSICIONE("Z21",4,XFILIAL("Z21")+QRY1->CC2_EST+QRY1->CC2_I_MESO,"Z21_NOME")                  } SIZE 60//MESORREGIÃO   - Z21_NOME "MESORREGIÃO",  //Z21_FILIAL+Z21_EST+Z21_COD
DEFINE CELL NAME "MICROREG"     OF oSF2A_1 ALIAS ""    TITLE "Microrregiao" BLOCK {|| POSICIONE("Z22",4,XFILIAL("Z22")+QRY1->CC2_EST+QRY1->CC2_I_MESO+QRY1->CC2_I_MICR,"Z22_NOME") } SIZE 60//MICRORREGIÃO -  Z22_NOME "MICRORREGIÃO", //Z22_FILIAL+Z22_EST+Z22_MESO+Z22_COD
DEFINE CELL NAME "ZY4_DESCRI"   OF oSF2A_1 ALIAS ""    TITLE "Evento Comercial" BLOCK {|| POSICIONE("ZY4",1,XFILIAL("ZY4")+QRY1->C5_I_EVENT,"ZY4_DESCRI") } SIZE 50 
DEFINE CELL NAME "F2_I_DTRC"    OF oSF2A_1 ALIAS "SF2" TITLE "Data Canhoto" SIZE 10  
DEFINE CELL NAME "C5_I_QTDA" 	OF oSF2A_1 ALIAS "SC5" TITLE   "Qtd Agendamento"       SIZE 10 BLOCK {|| QRY1->C5_I_QTDA }  PICTURE "@E 999,999,999.99"

oSF2A_1:Cell("D2_TOTAUX"):Disable()

oSF2A_1:SetTotalInLine(.F.)
oSF2A_1:SetTotalText({||"SUBTOTAL VENDEDOR:" + cVendedor })
oSF2A_1:OnPrintLine({|| cVendedor := QRY1->F2_VEND1 + " - " + QRY1->A3_NOME, cCoordenador := QRY1->F2_VEND2 + " - " + if(empty(QRY1->F2_VEND2),"VENDEDOR SEM Coordenador", POSICIONE("SA3",1,xFilial("SA3")+QRY1->F2_VEND2,"A3_NOME")),AllwaysTrue()}) //Atualiza Variavel do Subtotal
oSF2A_1:Disable()

//====================================================================================================
//Define secoes para terceira ORDEM 03 - Produto       
//====================================================================================================
//Secao Filial
DEFINE SECTION oSF2FIL_3 OF oReport TITLE "Filial Produto" TABLES "SB1","SD2","SF2","SA3","SA1"  ORDERS aOrd
DEFINE CELL NAME "D2_FILIAL"	OF oSF2FIL_3 ALIAS "SD2"  TITLE "Cod "
DEFINE CELL NAME "NOMFIL"	    OF oSF2FIL_3 ALIAS "" BLOCK{|| FWFilialName(,QRY3->D2_FILIAL)} TITLE "Filial" SIZE 20

oSF2FIL_3:OnPrintLine({|| cNomeFil := QRY3->D2_FILIAL  + " -  " + FWFilialName(,QRY3->D2_FILIAL)  })
oSF2FIL_3:SetTotalText({|| "SUBTOTAL FILIAL: " + cNomeFil})                                                        
oSF2FIL_3:Disable()

//Secao para ordem Produto
DEFINE SECTION oSF2_3 OF oSF2FIL_3 TITLE "Produto" TABLES "SB1","SD2","SF2","SA3","SA1"  
DEFINE CELL NAME "D2_COD"    	OF oSF2_3 ALIAS "SD2"
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2_3 ALIAS "SB1" SIZE 40 //BLOCK {|| if (!empty(QRY3->D2_I_DQESP),QRY3->D2_I_DQESP,QRY3->B1_I_DESCD)}

oSF2_3:Disable()
oSF2_3:SetLinesBefore(4)
//ANALITICO ORDEM 3 - PRODUTO
DEFINE SECTION oSF2A_3 OF oSF2_3 TITLE "Analitico ORDEM 3 - Produto" TABLES "SD2","SB1"
DEFINE CELL NAME "F2_EMISSAO"   OF oSF2A_3 ALIAS "SF2"  TITLE "Emissão NFe"
DEFINE CELL NAME "D2_PEDIDO"    OF oSF2A_3 ALIAS "SF2" //PICTURE "@E 999,999,999.99"
DEFINE CELL NAME "F2_DOC" 		OF oSF2A_3 ALIAS "SF2" TITLE "Documento" SIZE 12
DEFINE CELL NAME "D2_CLIENTE" 	OF oSF2A_3 ALIAS "SD2"
DEFINE CELL NAME "D2_LOJA" 		OF oSF2A_3 ALIAS "SD2" SIZE 05
DEFINE CELL NAME "A1_NREDUZ" 	OF oSF2A_3 ALIAS "SA1" SIZE 30       
DEFINE CELL NAME "D2_QUANT"	    OF oSF2A_3 ALIAS "SD2" PICTURE "@E 999,999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY3->D2_QUANT,QRY3->D2_QUANT-QRY3->D2_QTDEDEV/*ROMS003Q(QRY3->F2_DOC,QRY3->F2_SERIE,QRY3->D2_QTDEDEV,QRY3->D2_FILIAL,QRY3->D2_COD)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2A_3 ALIAS "SD2" TITLE "Un. M" SIZE 5
DEFINE CELL NAME "D2_QTSEGUM" 	OF oSF2A_3 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 14 BLOCK{||if(MV_PAR22 == 2,QRY3->D2_QTSEGUM,QRY3->D2_QTSEGUM-ROMS003L(QRY3->D2_QUANT,QRY3->D2_QTDEDEV,QRY3->D2_QTSEGUM)/* - ROMS003L(QRY3->D2_QUANT,ROMS003Q(QRY3->F2_DOC,QRY3->F2_SERIE,QRY3->D2_QTDEDEV,QRY3->D2_FILIAL,QRY3->D2_COD),QRY3->D2_QTSEGUM)*/)}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2A_3 ALIAS "SD2" TITLE "Seg. UM" SIZE 5
DEFINE CELL NAME "D2_TOTAUX" 	OF oSF2A_3 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY3->D2_TOTAL,QRY3->D2_TOTAL-QRY3->D2_VALDEV/*-ROMS003V(QRY3->F2_DOC,QRY3->F2_SERIE,QRY3->D2_VALDEV,QRY3->D2_FILIAL,0,0,'D2_TOTAL',QRY3->D2_COD)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2A_3 ALIAS "SD2" PICTURE "@E 999,999.9999" SIZE 8 TITLE "Vlr. Uni." BLOCK {|| if(nqtdeCor > 0,_nVlrTotal/nqtdeCor,0) }
DEFINE CELL NAME "D2_TOTAL" 	OF oSF2A_3 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal }  //MV_PAR22 == 2 Nao considera devolucoes
//DEFINE CELL NAME "D2_VALDEV" 	OF oSF2A_3 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 //PARA TESTES
DEFINE CELL NAME "D2_VALBRUT" 	OF oSF2A_3 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY3->D2_VALBRUT,QRY3->VLRBRUTDEV/*QRY3->D2_VALBRUT-ROMS003V(QRY3->F2_DOC,QRY3->F2_SERIE,QRY3->D2_VALDEV,QRY3->D2_FILIAL,QRY3->D2_TOTAL,QRY3->D2_ICMSRET,'D2_VALDEV',QRY3->D2_COD)*/ ) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "QBREMISS"	    OF oSF2A_3 ALIAS "" BLOCK{|| QRY3->D2_FILIAL + QRY3->D2_COD + DtoS(QRY3->F2_EMISSAO) }                                                                                                       

DEFINE CELL NAME "D2_LOCAL" 	OF oSF2A_3 ALIAS "SD2" TITLE "Armazem"      SIZE 07 // Armazem
DEFINE CELL NAME "NNR_DESCRI" 	OF oSF2A_3 ALIAS "SD2" TITLE "Desc.Armazem" SIZE 20 BLOCK {|| Posicione("NNR",1,xfilial("NNR") + QRY3->D2_LOCAL,"NNR_DESCRI")}  // Descrição Armazem

DEFINE CELL NAME "C5_I_TRCNF" 	OF oSF2A_3 ALIAS "SC5" TITLE "Troca NF?"    SIZE 8 BLOCK {|| If(QRY3->C5_I_TRCNF=="S","SIM","NAO")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_FILFT" 	OF oSF2A_3 ALIAS "SC5" TITLE "Filial Fat.?" SIZE 8 BLOCK {|| If(QRY3->C5_I_TRCNF=="S",QRY3->C5_I_FILFT+"-"+U_ROMS003F(QRY3->C5_I_FILFT)," ")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_FLFNC" 	OF oSF2A_3 ALIAS "SC5" TITLE "Filial Carr." SIZE 8 BLOCK {|| If(QRY3->C5_I_TRCNF=="S",QRY3->C5_I_FLFNC+"-"+U_ROMS003F(QRY3->C5_I_FLFNC)," ")}  PICTURE "@!"
DEFINE CELL NAME "LOC_EMB"	    OF oSF2A_3 ALIAS ""    TITLE "Local de Embarque"   BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY3->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" SIZE 40
DEFINE CELL NAME "C5_I_QTDA" 	OF oSF2A_3 ALIAS "SC5" TITLE   "Qtd Agendamento"       SIZE 10 BLOCK {|| QRY3->C5_I_QTDA }  PICTURE "@E 999,999,999.99"

oSF2A_3:Cell("QBREMISS"):Disable()  
oSF2A_3:Cell("D2_TOTAUX"):Disable()
oSF2A_3:SetTotalInLine(.F.)
oSF2A_3:OnPrintLine({|| cProduto := alltrim(QRY3->D2_COD) +  " - " + QRY3->B1_I_DESCD,AllwaysTrue()}) //Atualiza Variavel do Subtotal
oSF2A_3:SetTotalText({|| "SUBTOTAL PRODUTO: " + cProduto})
oSF2A_3:Disable()

//Ordem Produto - SINTETICO - Este nao tem secao/subsecao
DEFINE SECTION oSF2S_3          OF oSF2FIL_3 TITLE "Sintetico ORDEM 3 - Produto" TABLES "SD2","SB1"  
DEFINE CELL NAME "B1_COD"     	OF oSF2S_3 ALIAS "SD2" TITLE   "Produto"
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2S_3 ALIAS "SB1" TITLE   "Descricao" SIZE 40 //BLOCK {|| if (!empty(QRY3->D2_I_DQESP),QRY3->D2_I_DQESP,QRY3->B1_I_DESCD)}
DEFINE CELL NAME "D2_QUANT"	    OF oSF2S_3 ALIAS "SD2" PICTURE "@E 999,999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY3->D2_QUANT,QRY3->D2_QUANT-QRY3->D2_QTDEDEV/*ROMS003Q3(QRY3->D2_UM,QRY3->D2_SEGUM,QRY3->D2_COD,QRY3->D2_FILIAL,'D2_QTDEDEV')*/ ) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2S_3 ALIAS "SD2" TITLE   "Un. M" SIZE 5
DEFINE CELL NAME "D2_QTSEGUM"   OF oSF2S_3 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 14 BLOCK{|| if(MV_PAR22 == 2,QRY3->D2_QTSEGUM,QRY3->D2_QTSEGUM-ROMS003L(QRY3->D2_QUANT,QRY3->D2_QTDEDEV,QRY3->D2_QTSEGUM)/* - ROMS003Q3(QRY3->D2_UM,QRY3->D2_SEGUM,QRY3->D2_COD,QRY3->D2_FILIAL,'D2_QTSEGUM')*/)}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2S_3 ALIAS "SD2" TITLE   "Seg. UM" SIZE 5 
DEFINE CELL NAME "D2_TOTAUX" 	OF oSF2S_3 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY3->D2_TOTAL,QRY3->D2_TOTAL-QRY3->D2_VALDEV/*-ROMS003QG(QRY3->D2_UM,QRY3->D2_SEGUM,QRY3->D2_COD,QRY3->D2_FILIAL,.F.)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2S_3 ALIAS "SD2" PICTURE "@E 999,999.9999"   SIZE 08 BLOCK {|| if(nqtdeCor > 0,_nVlrTotal/nqtdeCor,0)} TITLE "Vlr. Uni."
DEFINE CELL NAME "D2_TOTAL" 	OF oSF2S_3 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal }  
DEFINE CELL NAME "D2_VALBRUT" 	OF oSF2S_3 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY3->D2_VALBRUT,QRY3->VLRBRUTDEV/*QRY3->D2_VALBRUT-ROMS003QG(QRY3->D2_UM,QRY3->D2_SEGUM,QRY3->D2_COD,QRY3->D2_FILIAL,.T.)*/ ) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "LOC_EMB"	    OF oSF2S_3 ALIAS ""    TITLE   "Local de Embarque" SIZE 40 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY3->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" 

oSF2S_3:Cell("D2_TOTAUX"):Disable()
oSF2S_3:SetTotalInLine(.F.)
oSF2S_3:Disable()

//====================================================================================================
//Define secoes para quarta ORDEM 04 - Rede           
//====================================================================================================
//Secao Filial
DEFINE SECTION oSF2FIL_4 OF oReport TITLE "Filial Rede" TABLES "SB1","SD2","SF2","SA3"  ORDERS aOrd
DEFINE CELL NAME "D2_FILIAL"	OF oSF2FIL_4 ALIAS "SD2"  TITLE "Cod "
DEFINE CELL NAME "NOMFIL"	    OF oSF2FIL_4 ALIAS "" BLOCK{|| FWFilialName(,QRY4->D2_FILIAL)} TITLE "Filial" SIZE 20

oSF2FIL_4:OnPrintLine({|| cNomeFil := QRY4->D2_FILIAL  + " -  " + FWFilialName(,QRY4->D2_FILIAL)  })
oSF2FIL_4:SetTotalText({|| "SUBTOTAL FILIAL: " + cNomeFil})                                                        
oSF2FIL_4:Disable()

DEFINE SECTION oSF2_4 OF oSF2FIL_4 TITLE "Rede" TABLES "SB1","SD2","SF2","SA3"  
DEFINE CELL NAME "A1_GRPVEN" 	OF oSF2_4 ALIAS "SA1"
DEFINE CELL NAME "ACY_DESCRI" 	OF oSF2_4 ALIAS "SA1"

oSF2_4:Disable()

//SECAO SINTETICA
DEFINE SECTION oSF2S_4 OF oSF2_4 TITLE "Sintetico ORDEM 4 - Rede" TABLES "SD2","SB1"
DEFINE CELL NAME "D2_COD"	OF oSF2S_4 ALIAS "SD2" TITLE "Produto"
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2S_4 ALIAS "SB1" TITLE "Descricao" SIZE 40 //BLOCK {|| if (!empty(QRY4->D2_I_DQESP),QRY4->D2_I_DQESP,QRY4->B1_I_DESCD)}
DEFINE CELL NAME "D2_QUANT"	    OF oSF2S_4 ALIAS "SD2" PICTURE "@E 999,999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY4->D2_QUANT,QRY4->D2_QUANT-QRY4->D2_QTDEDEV/*-ROMS003Q4(QRY4->D2_UM,QRY4->D2_SEGUM,QRY4->D2_COD,QRY4->D2_FILIAL,QRY4->ACY_GRPVEN,'D2_QTDEDEV')*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2S_4 ALIAS "SD2" TITLE "Un. M" SIZE 5
DEFINE CELL NAME "D2_QTSEGUM"   OF oSF2S_4 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 14 BLOCK{|| if(MV_PAR22 == 2,QRY4->D2_QTSEGUM,QRY4->D2_QTSEGUM-ROMS003L(QRY4->D2_QUANT,QRY4->D2_QTDEDEV,QRY4->D2_QTSEGUM)/* - ROMS003Q4(QRY4->D2_UM,QRY4->D2_SEGUM,QRY4->D2_COD,QRY4->D2_FILIAL,QRY4->ACY_GRPVEN,'D2_QTSEGUM')*/)}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2S_4 ALIAS "SD2" TITLE "Seg. UM" SIZE 5
DEFINE CELL NAME "D2_TOTAUX" 	OF oSF2S_4 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY4->D2_TOTAL,QRY4->D2_TOTAL-QRY4->D2_VALDEV/*-ROMS003QH(QRY4->D2_UM,QRY4->D2_SEGUM,QRY4->D2_COD,QRY4->D2_FILIAL,QRY4->ACY_GRPVEN,.F.)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2S_4 ALIAS "SD2" PICTURE "@E 999,999.9999" SIZE 08 TITLE "Vlr. Uni."BLOCK {|| if(nqtdeCor > 0,_nVlrTotal/nqtdeCor,0)}
DEFINE CELL NAME "D2_TOTAL" 	OF oSF2S_4 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_VALBRUT" 	OF oSF2S_4 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY4->D2_VALBRUT,QRY4->VLRBRUTDEV/*QRY4->D2_VALBRUT-ROMS003QH(QRY4->D2_UM,QRY4->D2_SEGUM,QRY4->D2_COD,QRY4->D2_FILIAL,QRY4->ACY_GRPVEN,.T.)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "LOC_EMB"	    OF oSF2S_4 ALIAS ""    TITLE   "Local de Embarque" SIZE 40 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY4->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" 

oSF2S_4:Cell("D2_TOTAUX"):Disable()
oSF2S_4:SetTotalInLine(.F.)
oSF2S_4:SetTotalText({||"SUBTOTAL REDE: " + cRede})
oSF2S_4:OnPrintLine({|| cRede := QRY4->A1_GRPVEN + " - " + QRY4->ACY_DESCRI })
oSF2S_4:Disable()
 
//SECAO ANALITICA
DEFINE SECTION oSF2A_4 OF oSF2_4 TITLE "Analitico ORDEM 4 - Rede" TABLES "SD2","SB1"
DEFINE CELL NAME "D2_COD"	    OF oSF2A_4 ALIAS "SD2" TITLE "Produto"
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2A_4 ALIAS "SB1" TITLE "Descricao" SIZE 40 //BLOCK {|| if (!empty(QRY4->D2_I_DQESP),QRY4->D2_I_DQESP,QRY4->B1_I_DESCD)}
DEFINE CELL NAME "D2_CLIENTE" 	OF oSF2A_4 ALIAS "SD2"
DEFINE CELL NAME "D2_LOJA" 		OF oSF2A_4 ALIAS "SD2" SIZE 05
DEFINE CELL NAME "A1_NREDUZ" 	OF oSF2A_4 ALIAS "SA1" SIZE 30
DEFINE CELL NAME "F2_DOC" 		OF oSF2A_4 ALIAS "SF2" TITLE "Documento" SIZE 12
DEFINE CELL NAME "F2_EMISSAO"   OF oSF2A_4 ALIAS "SF2" TITLE "Emissão NFe"
DEFINE CELL NAME "D2_QUANT"	    OF oSF2A_4 ALIAS "SD2" PICTURE "@E 999,999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY4->D2_QUANT,QRY4->D2_QUANT-QRY4->D2_QTDEDEV/*-ROMS003Q(QRY4->F2_DOC,QRY4->F2_SERIE,QRY4->D2_QTDEDEV,QRY4->D2_FILIAL,QRY4->D2_COD)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2A_4 ALIAS "SD2" TITLE "Un. M" SIZE 5
DEFINE CELL NAME "D2_QTSEGUM"   OF oSF2A_4 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 14 BLOCK{|| if(MV_PAR22 == 2,QRY4->D2_QTSEGUM,QRY4->D2_QTSEGUM-ROMS003L(QRY4->D2_QUANT,QRY4->D2_QTDEDEV,QRY4->D2_QTSEGUM)/* - ROMS003L(QRY4->D2_QUANT,ROMS003Q(QRY4->F2_DOC,QRY4->F2_SERIE,QRY4->D2_QTDEDEV,QRY4->D2_FILIAL,QRY4->D2_COD),QRY4->D2_QTSEGUM)*/)}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2A_4 ALIAS "SD2" TITLE "Seg. UM" SIZE 5
DEFINE CELL NAME "D2_TOTAUX"  	OF oSF2A_4 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY4->D2_TOTAL,QRY4->D2_TOTAL-QRY4->D2_VALDEV/*-ROMS003V(QRY4->F2_DOC,QRY4->F2_SERIE,QRY4->D2_VALDEV,QRY4->D2_FILIAL,0,0,'D2_TOTAL',QRY4->D2_COD)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2A_4 ALIAS "SD2" PICTURE "@E 999,999.9999" SIZE 08 TITLE "Vlr. Uni."BLOCK {|| if(nqtdeCor > 0,_nVlrTotal/nqtdeCor,0)}
DEFINE CELL NAME "D2_TOTAL"  	OF oSF2A_4 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_VALBRUT"  	OF oSF2A_4 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY4->D2_VALBRUT,QRY4->VLRBRUTDEV/*QRY4->D2_VALBRUT-ROMS003V(QRY4->F2_DOC,QRY4->F2_SERIE,QRY4->D2_VALDEV,QRY4->D2_FILIAL,QRY4->D2_TOTAL,QRY4->D2_ICMSRET,'D2_VALDEV',QRY4->D2_COD)*/) }  //MV_PAR22 == 2 Nao considera devolucoes

DEFINE CELL NAME "D2_LOCAL" 	OF oSF2A_4 ALIAS "SD2" TITLE "Armazem"      SIZE 07 // Armazem
DEFINE CELL NAME "NNR_DESCRI" 	OF oSF2A_4 ALIAS "SD2" TITLE "Desc.Armazem" SIZE 20 BLOCK {|| Posicione("NNR",1,xfilial("NNR") + QRY4->D2_LOCAL,"NNR_DESCRI")}  // Descrição Armazem

DEFINE CELL NAME "C5_I_TRCNF" 	OF  oSF2A_4 ALIAS "SC5" TITLE "Troca NF?"    SIZE 8 BLOCK {|| If(QRY4->C5_I_TRCNF=="S","SIM","NAO")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_FILFT" 	OF  oSF2A_4 ALIAS "SC5" TITLE "Filial Fat.?" SIZE 8 BLOCK {|| If(QRY4->C5_I_TRCNF=="S",QRY4->C5_I_FILFT+"-"+U_ROMS003F(QRY4->C5_I_FILFT)," ")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_FLFNC" 	OF  oSF2A_4 ALIAS "SC5" TITLE "Filial Carr." SIZE 8 BLOCK {|| If(QRY4->C5_I_TRCNF=="S",QRY4->C5_I_FLFNC+"-"+U_ROMS003F(QRY4->C5_I_FLFNC)," ")}  PICTURE "@!"

DEFINE CELL NAME "DAI_I_OPLO"   OF oSF2A_4 ALIAS "DAI" TITLE "Op. Log."          SIZE 08 BLOCK {|| QRY4->DAI_I_OPLO} PICTURE "@!"
DEFINE CELL NAME "DAI_I_OPLO" 	OF oSF2A_4 ALIAS "DAI" TITLE "Nome Op Log"       SIZE 08 BLOCK {||  If(!Empty(Alltrim(QRY4->DAI_I_OPLO)),posicione("SA2",1,xfilial("SA2") + QRY4->DAI_I_OPLO,"A2_NREDUZ")," ")}  PICTURE "@!"
DEFINE CELL NAME "LOC_EMB"	    OF oSF2A_4 ALIAS ""    TITLE "Local de Embarque" SIZE 40 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY4->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" 
DEFINE CELL NAME "C5_I_QTDA" 	OF oSF2A_4 ALIAS "SC5" TITLE   "Qtd Agendamento" SIZE 10 BLOCK {|| QRY4->C5_I_QTDA }  PICTURE "@E 999,999,999.99"


oSF2A_4:Cell("D2_TOTAUX"):Disable()
oSF2A_4:SetTotalInLine(.F.)
oSF2A_4:SetTotalText({||"SUBTOTAL REDE: " + cRede})
oSF2A_4:OnPrintLine({|| cRede := QRY4->A1_GRPVEN + " - " + QRY4->ACY_DESCRI })
oSF2A_4:Disable()
                 
//====================================================================================================
//Define secoes para ORDEM 05 - Estado x Produto        
//====================================================================================================
//Secao Filial
DEFINE SECTION oSF2FIL_5 OF oReport TITLE "Filial Estado" TABLES "SB1","SD2","SF2","SA3"  ORDERS aOrd
DEFINE CELL NAME "D2_FILIAL"	OF oSF2FIL_5 ALIAS "SD2"  TITLE "Cod "
DEFINE CELL NAME "NOMFIL"	    OF oSF2FIL_5 ALIAS "" BLOCK{|| FWFilialName(,QRY5->D2_FILIAL)} TITLE "Filial" SIZE 20

oSF2FIL_5:OnPrintLine({|| cNomeFil := QRY5->D2_FILIAL  + " -  " + FWFilialName(,QRY5->D2_FILIAL)  })
oSF2FIL_5:SetTotalText({|| "SUBTOTAL FILIAL: " + cNomeFil})                                                        
oSF2FIL_5:Disable()

//Secao Estado
DEFINE SECTION oSF2_5 OF oSF2FIL_5 TITLE "Estado" TABLES "SB1","SD2","SF2","SA3"  
DEFINE CELL NAME "D2_EST"   	OF oSF2_5 ALIAS "SD2" TITLE "Estado"
DEFINE CELL NAME "ESTADO"   	OF oSF2_5 ALIAS "" TITLE "Descrição" SIZE 40 BLOCK {|| POSICIONE("SX5",1,XFILIAL("SX5")+"12"+QRY5->D2_EST,"X5_DESCRI")}

oSF2_5:Disable()

//====================================================================================================
//SECAO SINTETICA // ORDEM 5 - Estado x Produto  
//====================================================================================================
DEFINE SECTION oSF2S_5          OF oSF2_5 TITLE "Sintetico ORDEM 5 - Estado x Produto" TABLES "SD2","SB1"
DEFINE CELL NAME "D2_COD"	    OF oSF2S_5 ALIAS "SD2" TITLE "Produto"  
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2S_5 ALIAS "SB1" TITLE "Descricao" SIZE 40 //BLOCK {|| if (!empty(QRY5->D2_I_DQESP),QRY5->D2_I_DQESP,QRY5->B1_I_DESCD)}
DEFINE CELL NAME "D2_QUANT"	    OF oSF2S_5 ALIAS "SD2" PICTURE "@E 999,999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY5->D2_QUANT,QRY5->D2_QUANT-QRY5->D2_QTDEDEV/*ROMS003Q5(QRY5->D2_UM,QRY5->D2_SEGUM,QRY5->B1_COD,QRY5->D2_FILIAL,QRY5->D2_EST,'D2_QTDEDEV')*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2S_5 ALIAS "SD2" TITLE "Un. M" SIZE 5
DEFINE CELL NAME "D2_QTSEGUM"   OF oSF2S_5 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 14 BLOCK{|| if(MV_PAR22 == 2,QRY5->D2_QTSEGUM,QRY5->D2_QTSEGUM-ROMS003L(QRY5->D2_QUANT,QRY5->D2_QTDEDEV,QRY5->D2_QTSEGUM)/*ROMS003Q5(QRY5->D2_UM,QRY5->D2_SEGUM,QRY5->B1_COD,QRY5->D2_FILIAL,QRY5->D2_EST,'D2_QTSEGUM')*/)}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2S_5 ALIAS "SD2" TITLE "Seg. UM" SIZE 5
DEFINE CELL NAME "D2_TOTAUX" 	OF oSF2S_5 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY5->D2_TOTAL,QRY5->D2_TOTAL-QRY5->D2_VALDEV/*ROMS003QI(QRY5->D2_UM,QRY5->D2_SEGUM,QRY5->B1_COD,QRY5->D2_FILIAL,QRY5->D2_EST,.F.)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2S_5 ALIAS "SD2" PICTURE "@E 999,999.9999"   SIZE 08 TITLE "Vlr. Uni." BLOCK {|| if(nqtdeCor > 0,_nVlrTotal/nqtdeCor,0)}
DEFINE CELL NAME "D2_TOTAL" 	OF oSF2S_5 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_VALBRUT" 	OF oSF2S_5 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY5->D2_VALBRUT,QRY5->VLRBRUTDEV /*ROMS003QI(QRY5->D2_UM,QRY5->D2_SEGUM,QRY5->B1_COD,QRY5->D2_FILIAL,QRY5->D2_EST,.T.)*/ ) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "LOC_EMB"	    OF oSF2S_5 ALIAS ""    TITLE   "Local de Embarque" SIZE 40 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY5->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" 

oSF2S_5:Cell("D2_TOTAUX"):Disable()
oSF2S_5:SetTotalInLine(.F.)
oSF2S_5:SetTotalText({||"SUBTOTAL ESTADO: " + cEstado})
oSF2S_5:OnPrintLine({|| cEstado := QRY5->D2_EST + " - " + POSICIONE("SX5",1,XFILIAL("SX5")+"12"+QRY5->D2_EST,"X5_DESCRI") })
oSF2S_5:Disable()

//====================================================================================================
//SECAO ANALITICA // ORDEM 5 - Estado x Produto  
//====================================================================================================
DEFINE SECTION oSF2A_5 OF oSF2_5 TITLE "Analitico ORDEM 5 - Estado x Produto" TABLES "SD2","SB1"
DEFINE CELL NAME "D2_COD"	    OF oSF2A_5 ALIAS "SD2" TITLE "Produto"
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2A_5 ALIAS "SB1" TITLE "Descricao" SIZE 50 //BLOCK {|| if (!empty(QRY5->D2_I_DQESP),QRY5->D2_I_DQESP,QRY5->B1_I_DESCD)}
DEFINE CELL NAME "D2_CLIENTE" 	OF oSF2A_5 ALIAS "SD2" SIZE 10
DEFINE CELL NAME "D2_LOJA" 		OF oSF2A_5 ALIAS "SD2" SIZE 06
DEFINE CELL NAME "A1_NREDUZ" 	OF oSF2A_5 ALIAS "SA1" SIZE 30
DEFINE CELL NAME "F2_DOC" 		OF oSF2A_5 ALIAS "SF2" TITLE "Documento" SIZE 12
DEFINE CELL NAME "F2_EMISSAO"   OF oSF2A_5 ALIAS "SF2" TITLE "Emissão NFe" SIZE 13
DEFINE CELL NAME "D2_QUANT"	    OF oSF2A_5 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY5->D2_QUANT,QRY5->D2_QUANT-QRY5->D2_QTDEDEV/*ROMS003Q(QRY5->F2_DOC,QRY5->F2_SERIE,QRY5->D2_QTDEDEV,QRY5->D2_FILIAL,QRY5->D2_COD)*/)}  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2A_5 ALIAS "SD2" TITLE "Un. M" SIZE 5
DEFINE CELL NAME "D2_QTSEGUM"   OF oSF2A_5 ALIAS "SD2" PICTURE "@E 999,999.999" SIZE 14 BLOCK{|| if(MV_PAR22 == 2,QRY5->D2_QTSEGUM,QRY5->D2_QTSEGUM - ROMS003L(QRY5->D2_QUANT,QRY5->D2_QTDEDEV,QRY5->D2_QTSEGUM) /*- ROMS003L(QRY5->D2_QUANT,ROMS003Q(QRY5->F2_DOC,QRY5->F2_SERIE,QRY5->D2_QTDEDEV,QRY5->D2_FILIAL,QRY5->D2_COD),QRY5->D2_QTSEGUM)*/)}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2A_5 ALIAS "SD2" TITLE "Seg. UM" SIZE 5
DEFINE CELL NAME "D2_TOTAUX"  	OF oSF2A_5 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY5->D2_TOTAL,QRY5->D2_TOTAL-QRY5->D2_VALDEV/*ROMS003V(QRY5->F2_DOC,QRY5->F2_SERIE,QRY5->D2_VALDEV,QRY5->D2_FILIAL,0,0,'D2_TOTAL',QRY5->D2_COD)*/)}  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2A_5 ALIAS "SD2" PICTURE "@E 999,999.9999" SIZE 08 TITLE "Vlr. Uni."BLOCK {|| if(nqtdeCor > 0,_nVlrTotal/nqtdeCor,0)}
DEFINE CELL NAME "D2_TOTAL"  	OF oSF2A_5 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| _nVlrTotal }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_VALBRUT"  	OF oSF2A_5 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY5->D2_VALBRUT,QRY5->VLRBRUTDEV ) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_LOCAL" 	OF oSF2A_5 ALIAS "SD2" TITLE "Armazem"      SIZE 07 // Armazem
DEFINE CELL NAME "NNR_DESCRI" 	OF oSF2A_5 ALIAS "SD2" TITLE "Desc.Armazem" SIZE 20 BLOCK {|| Posicione("NNR",1,xfilial("NNR") + QRY5->D2_LOCAL,"NNR_DESCRI")}  // Descrição Armazem
DEFINE CELL NAME "C5_I_TRCNF" 	OF oSF2A_5 ALIAS "SC5" TITLE "Troca NF?"    SIZE 8 BLOCK {|| If(QRY5->C5_I_TRCNF=="S","SIM","NAO")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_FILFT" 	OF oSF2A_5 ALIAS "SC5" TITLE "Filial Fat.?" SIZE 8 BLOCK {|| If(QRY5->C5_I_TRCNF=="S",QRY5->C5_I_FILFT+"-"+U_ROMS003F(QRY5->C5_I_FILFT)," ")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_FLFNC" 	OF oSF2A_5 ALIAS "SC5" TITLE "Filial Carr." SIZE 8 BLOCK {|| If(QRY5->C5_I_TRCNF=="S",QRY5->C5_I_FLFNC+"-"+U_ROMS003F(QRY5->C5_I_FLFNC)," ")}  PICTURE "@!"
DEFINE CELL NAME "A1_MUN"      	OF oSF2A_5 ALIAS "SA1" SIZE 30
DEFINE CELL NAME "OPERACAO"    	OF oSF2A_5 ALIAS "SD2" TITLE "Tipo de Opercao"   SIZE 20 BLOCK {|| Posicione("ZAY",1,xfilial("ZAY")+QRY5->D2_CF,"ZAY_TPOPER")+" - "+ALLTRIM(ZAY->ZAY_DESCRI)}  // Descrição Armazem
DEFINE CELL NAME "LOC_EMB"	    OF oSF2A_5 ALIAS ""    TITLE "Local de Embarque" SIZE 40 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY5->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" 
DEFINE CELL NAME "C5_I_QTDA" 	OF oSF2A_5 ALIAS "SC5" TITLE   "Qtd Agendamento" SIZE 10 BLOCK {|| QRY5->C5_I_QTDA }  PICTURE "@E 999,999,999.99"

oSF2A_5:Cell("D2_TOTAUX"):Disable()
oSF2A_5:SetTotalInLine(.F.)
oSF2A_5:SetTotalText({||"SUBTOTAL ESTADO: " + cEstado})
oSF2A_5:OnPrintLine({|| cEstado := QRY5->D2_EST + " - " + POSICIONE("SX5",1,XFILIAL("SX5")+"12"+QRY5->D2_EST,"X5_DESCRI") })
oSF2A_5:Disable()

//====================================================================================================
//Define secoes para sexta ORDEM 06 - Municipio       
//====================================================================================================
//Secao Filial
DEFINE SECTION oSF2FIL_6 OF oReport TITLE "Filial Municipio" TABLES "SB1","SD2","SF2","SA3"  ORDERS aOrd
DEFINE CELL NAME "D2_FILIAL"	OF oSF2FIL_6 ALIAS "SD2"  TITLE "Cod "
DEFINE CELL NAME "NOMFIL"	    OF oSF2FIL_6 ALIAS "" BLOCK{|| FWFilialName(,QRY6->D2_FILIAL)} TITLE "Filial" SIZE 20

oSF2FIL_6:OnPrintLine({|| cNomeFil := QRY6->D2_FILIAL  + " -  " + FWFilialName(,QRY6->D2_FILIAL)  })
oSF2FIL_6:SetTotalText({|| "SUBTOTAL FILIAL: " + cNomeFil})                                                        
oSF2FIL_6:Disable()

DEFINE SECTION oSF2_6 OF oSF2FIL_6 TITLE "Municipio" TABLES "SA1"  
DEFINE CELL NAME "A1_COD_MUN" 	OF oSF2_6 ALIAS "SA1"
DEFINE CELL NAME "A1_MUN"      	OF oSF2_6 ALIAS "SA1" 
DEFINE CELL NAME "A1_EST"      	OF oSF2_6 ALIAS "SA1" 

oSF2_6:Disable()

DEFINE BREAK oBrkMun OF oSF2_6 WHEN oSF2_6:Cell("A1_MUN") TITLE {|| "SUBTOTAL MUNICIPIO: " + cMunicipio}

oBrkMun:OnPrintTotal({|| oReport:SkipLine(4)})

//Secao Vendedor - SubSecao da Secao SF2_1
DEFINE SECTION oSF2_6A OF oSF2_6 TITLE "Vendedor" TABLES "SA3"
DEFINE CELL NAME "F2_VEND1"  	OF oSF2_6A ALIAS "SF2" TITLE "Vendedor"
DEFINE CELL NAME "A3_NOME" 		OF oSF2_6A ALIAS "SA3"

oSF2_6A:SetTotalInLine(.F.)
oSF2_6A:SetTotalText({||"SUBTOTAL VENDEDOR: " + cVendedor  })
oSF2_6A:OnPrintLine({|| cVendedor := QRY6->F2_VEND1 + " - " + QRY6->A3_NOME,AllwaysTrue(),cMunicipio := QRY6->A1_COD_MUN + " - " + QRY6->A1_MUN }) //Atualiza Variavel do Subtotal
oSF2_6A:Disable()

//Secao SINTETICA ORDEM 06 - Municipio   
DEFINE SECTION oSF2S_6          OF oSF2_6A TITLE "Sintetico ORDEM 6 - Municipio" TABLES "SD2","SB1"
DEFINE CELL NAME "D2_COD"	    OF oSF2S_6 ALIAS "SD2" TITLE   "Produto"
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2S_6 ALIAS "SB1" TITLE   "Descricao"          SIZE 40 //BLOCK {|| if (!empty(QRY6->D2_I_DQESP),QRY6->D2_I_DQESP,QRY6->B1_I_DESCD)}
DEFINE CELL NAME "D2_QUANT"	    OF oSF2S_6 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY6->D2_QUANT,QRY6->D2_QUANT-QRY6->D2_QTDEDEV/*-ROMS003Q6(QRY6->D2_UM,QRY6->D2_SEGUM,QRY6->B1_COD,QRY6->D2_FILIAL,QRY6->A1_EST,QRY6->A1_COD_MUN,QRY6->F2_VEND1,'D2_QTDEDEV')*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2S_6 ALIAS "SD2" TITLE   "Un. M"              SIZE 05
DEFINE CELL NAME "D2_QTSEGUM"   OF oSF2S_6 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 14 BLOCK{|| if(MV_PAR22 == 2,QRY6->D2_QTSEGUM,QRY6->D2_QTSEGUM-ROMS003L(QRY6->D2_QUANT,QRY6->D2_QTDEDEV,QRY6->D2_QTSEGUM)/* - ROMS003Q6(QRY6->D2_UM,QRY6->D2_SEGUM,QRY6->B1_COD,QRY6->D2_FILIAL,QRY6->A1_EST,QRY6->A1_COD_MUN,QRY6->F2_VEND1,'D2_QTSEGUM')*/)}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2S_6 ALIAS "SD2" TITLE   "Seg. UM"            SIZE 05
DEFINE CELL NAME "D2_TOTAUX" 	OF oSF2S_6 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY6->D2_TOTAL,QRY6->D2_TOTAL-QRY6->D2_VALDEV/*-ROMS003QJ(QRY6->D2_UM,QRY6->D2_SEGUM,QRY6->B1_COD,QRY6->D2_FILIAL,QRY6->A1_EST,QRY6->A1_COD_MUN,QRY6->F2_VEND1,.F.)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2S_6 ALIAS "SD2" PICTURE "@E 999,999.9999"    SIZE 08 TITLE "Vlr. Uni."BLOCK {|| if(nqtdeCor > 0,_nVlrTotal/nqtdeCor,0)}
DEFINE CELL NAME "D2_TOTAL" 	OF oSF2S_6 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| _nVlrTotal }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_VALBRUT" 	OF oSF2S_6 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY6->D2_VALBRUT,QRY6->VLRBRUTDEV/*QRY6->D2_VALBRUT-ROMS003QJ(QRY6->D2_UM,QRY6->D2_SEGUM,QRY6->B1_COD,QRY6->D2_FILIAL,QRY6->A1_EST,QRY6->A1_COD_MUN,QRY6->F2_VEND1,.T.)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "LOC_EMB"	    OF oSF2S_6 ALIAS ""    TITLE   "Local de Embarque"  SIZE 40 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY6->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" 

oSF2S_6:Cell("D2_TOTAUX"):Disable()
oSF2S_6:SetTotalInLine(.F.)
oSF2S_6:SetTotalText({||"SUBTOTAL VENDEDOR: " + cVendedor})
oSF2S_6:OnPrintLine({|| cVendedor := QRY6->F2_VEND1 + " - " + QRY6->A3_NOME })
oSF2S_6:Disable()

//Secao ANALITICA ORDEM 06 - Municipio   
DEFINE SECTION oSF2A_6 OF oSF2_6A TITLE "Analitico ORDEM 6 - Municipio" TABLES "SD2","SB1"
DEFINE CELL NAME "D2_COD"	    OF oSF2A_6 ALIAS "SD2" TITLE "Produto"
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2A_6 ALIAS "SB1" TITLE "Descricao" SIZE 40 //BLOCK {|| if (!empty(QRY6->D2_I_DQESP),QRY6->D2_I_DQESP,QRY6->B1_I_DESCD)}
DEFINE CELL NAME "D2_CLIENTE" 	OF oSF2A_6 ALIAS "SD2"
DEFINE CELL NAME "D2_LOJA" 		OF oSF2A_6 ALIAS "SD2" SIZE 05
DEFINE CELL NAME "A1_NREDUZ" 	OF oSF2A_6 ALIAS "SA1" SIZE 30
DEFINE CELL NAME "F2_DOC" 		OF oSF2A_6 ALIAS "SF2" TITLE   "Documento"          SIZE 12
DEFINE CELL NAME "F2_EMISSAO"   OF oSF2A_6 ALIAS "SF2" TITLE   "Emissão NFe"         SIZE 12
DEFINE CELL NAME "D2_QUANT"	    OF oSF2A_6 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY6->D2_QUANT,QRY6->D2_QUANT-QRY6->D2_QTDEDEV/*-ROMS003Q(QRY6->F2_DOC,QRY6->F2_SERIE,QRY6->D2_QTDEDEV,QRY6->D2_FILIAL,QRY6->D2_COD)*/)}  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2A_6 ALIAS "SD2" TITLE   "Un. M"              SIZE 05
DEFINE CELL NAME "D2_QTSEGUM"   OF oSF2A_6 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 14 BLOCK{|| if(MV_PAR22 == 2,QRY6->D2_QTSEGUM,QRY6->D2_QTSEGUM-ROMS003L(QRY6->D2_QUANT,QRY6->D2_QTDEDEV,QRY6->D2_QTSEGUM)/* - ROMS003L(QRY6->D2_QUANT,ROMS003Q(QRY6->F2_DOC,QRY6->F2_SERIE,QRY6->D2_QTDEDEV,QRY6->D2_FILIAL,QRY6->D2_COD),QRY6->D2_QTSEGUM)*/)}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2A_6 ALIAS "SD2" TITLE   "Seg. UM"            SIZE 05
DEFINE CELL NAME "D2_TOTAUX"  	OF oSF2A_6 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY6->D2_TOTAL,QRY6->D2_TOTAL-QRY6->D2_VALDEV/*-ROMS003V(QRY6->F2_DOC,QRY6->F2_SERIE,QRY6->D2_VALDEV,QRY6->D2_FILIAL,0,0,'D2_TOTAL',QRY6->D2_COD)*/)}  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2A_6 ALIAS "SD2" PICTURE "@E 999,999.9999"    SIZE 08 TITLE "Vlr. Uni."BLOCK {|| if(nqtdeCor > 0,_nVlrTotal/nqtdeCor,0)}
DEFINE CELL NAME "D2_TOTAL"  	OF oSF2A_6 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| _nVlrTotal }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_VALBRUT"  	OF oSF2A_6 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY6->D2_VALBRUT,QRY6->VLRBRUTDEV/*QRY6->D2_VALBRUT-ROMS003V(QRY6->F2_DOC,QRY6->F2_SERIE,QRY6->D2_VALDEV,QRY6->D2_FILIAL,QRY6->D2_TOTAL,QRY6->D2_ICMSRET,'D2_VALDEV',QRY6->D2_COD)*/)}  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_LOCAL" 	OF oSF2A_6 ALIAS "SD2" TITLE "Armazem"              SIZE 07 // Armazem
DEFINE CELL NAME "NNR_DESCRI" 	OF oSF2A_6 ALIAS "SD2" TITLE "Desc.Armazem"         SIZE 20 BLOCK {|| Posicione("NNR",1,xfilial("NNR") + QRY6->D2_LOCAL,"NNR_DESCRI")}  // Descrição Armazem
DEFINE CELL NAME "C5_I_TRCNF" 	OF oSF2A_6 ALIAS "SC5" TITLE "Troca NF?"            SIZE 08 BLOCK {|| If(QRY6->C5_I_TRCNF=="S","SIM","NAO")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_FILFT" 	OF oSF2A_6 ALIAS "SC5" TITLE "Filial Fat.?"         SIZE 08 BLOCK {|| If(QRY6->C5_I_TRCNF=="S",QRY6->C5_I_FILFT+"-"+U_ROMS003F(QRY6->C5_I_FILFT)," ")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_FLFNC" 	OF oSF2A_6 ALIAS "SC5" TITLE "Filial Carr."         SIZE 08 BLOCK {|| If(QRY6->C5_I_TRCNF=="S",QRY6->C5_I_FLFNC+"-"+U_ROMS003F(QRY6->C5_I_FLFNC)," ")}  PICTURE "@!"
DEFINE CELL NAME "DAI_I_OPLO"   OF oSF2A_6 ALIAS "DAI" TITLE "Op. Log."             SIZE 08 BLOCK {|| QRY6->DAI_I_OPLO} PICTURE "@!"
DEFINE CELL NAME "DAI_I_OPLO" 	OF oSF2A_6 ALIAS "DAI" TITLE "Nome Op Log"          SIZE 08 BLOCK {||  If(!Empty(Alltrim(QRY6->DAI_I_OPLO)),posicione("SA2",1,xfilial("SA2") + QRY6->DAI_I_OPLO,"A2_NREDUZ")," ")}  PICTURE "@!"
DEFINE CELL NAME "LOC_EMB"	    OF oSF2A_6 ALIAS ""    TITLE "Local de Embarque"    SIZE 40 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY6->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" 
DEFINE CELL NAME "C5_I_QTDA" 	OF oSF2A_6 ALIAS "SC5" TITLE   "Qtd Agendamento" SIZE 10 BLOCK {|| QRY6->C5_I_QTDA }  PICTURE "@E 999,999,999.99"

oSF2A_6:Cell("D2_TOTAUX"):Disable()
oSF2A_6:SetTotalInLine(.F.)
oSF2A_6:SetTotalText({||"SUBTOTAL VENDEDOR: " + cVendedor})
oSF2A_6:OnPrintLine({|| cVendedor := QRY6->F2_VEND1 + " - " + QRY6->A3_NOME })
oSF2A_6:Disable()

//====================================================================================================
//Define secoes para setima ORDEM 07 - Cliente
//====================================================================================================
//Secao Filial
DEFINE SECTION oSF2FIL_7 OF oReport TITLE "Filial Cliente" TABLES "SB1","SD2","SF2","SA3"  ORDERS aOrd
DEFINE CELL NAME "D2_FILIAL"	OF oSF2FIL_7 ALIAS "SD2"  TITLE "Cod "
DEFINE CELL NAME "NOMFIL"	    OF oSF2FIL_7 ALIAS "" BLOCK{|| FWFilialName(,QRY7->D2_FILIAL)} TITLE "Filial" SIZE 20

oSF2FIL_7:OnPrintLine({|| cNomeFil := QRY7->D2_FILIAL  + " -  " + FWFilialName(,QRY7->D2_FILIAL)  })
oSF2FIL_7:SetTotalText({|| "SUBTOTAL FILIAL: " + cNomeFil})                                                        
oSF2FIL_7:Disable()

DEFINE SECTION oSF2_7 OF oSF2FIL_7 TITLE "Rede" TABLES "SA1"  
DEFINE CELL NAME "A1_GRPVEN" 	OF oSF2_7 ALIAS "SA1"
DEFINE CELL NAME "ACY_DESCRI" 	OF oSF2_7 ALIAS "ACY"

oSF2_7:Disable()

DEFINE BREAK oBrkRede OF oSF2_7 WHEN oSF2_7:Cell("A1_GRPVEN") TITLE {|| "SUBTOTAL REDE: " + cRede}

oBrkRede:OnPrintTotal({|| oReport:SkipLine(4)})

//Secao Cliente - SubSecao da Secao SF2_7
DEFINE SECTION oSF2_7A OF oSF2_7 TITLE "Vendedor" TABLES "SA3"
DEFINE CELL NAME "A1_COD"  	 OF oSF2_7A ALIAS "SA1"
DEFINE CELL NAME "A1_LOJA"   OF oSF2_7A ALIAS "SA1"  SIZE 05
DEFINE CELL NAME "A1_NREDUZ" OF oSF2_7A ALIAS "SA1"
DEFINE CELL NAME "A1_NOME"   OF oSF2_7A ALIAS "SA1"

oSF2_7A:SetTotalInLine(.F.)
oSF2_7A:SetTotalText({||"SUBTOTAL CLIENTE: " + cCliente  })
oSF2_7A:OnPrintLine({|| cCliente := QRY7->A1_COD + " - " + QRY7->A1_NREDUZ,AllwaysTrue(),cRede := QRY7->A1_GRPVEN + " - " + QRY7->ACY_DESCRI }) //Atualiza Variavel do Subtotal
oSF2_7A:Disable()

//Secao SINTETICA ORDEM 07 - Cliente
DEFINE SECTION oSF2S_7          OF oSF2_7A TITLE "Sintetico ORDEM 7 - Cliente" TABLES "SD2","SB1"
DEFINE CELL NAME "D2_COD"	    OF oSF2S_7 ALIAS "SD2" TITLE   "Produto"
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2S_7 ALIAS "SB1" TITLE   "Descricao"          SIZE 40 //BLOCK {|| if (!empty(QRY7->D2_I_DQESP),QRY7->D2_I_DQESP,QRY7->B1_I_DESCD)}
DEFINE CELL NAME "D2_QUANT"	    OF oSF2S_7 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY7->D2_QUANT,QRY7->D2_QUANT-QRY7->D2_QTDEDEV/* - ROMS003Q7(QRY7->D2_UM,QRY7->D2_SEGUM,QRY7->B1_COD,QRY7->D2_FILIAL,QRY7->A1_COD_MUN,QRY7->F2_VEND1,QRY7->A1_GRPVEN,QRY7->A1_COD,QRY7->A1_LOJA,'D2_QTDEDEV')*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2S_7 ALIAS "SD2" TITLE   "Un. M"              SIZE 05
DEFINE CELL NAME "D2_QTSEGUM"   OF oSF2S_7 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 14 BLOCK{|| if(MV_PAR22 == 2,QRY7->D2_QTSEGUM,QRY7->D2_QTSEGUM-ROMS003L(QRY7->D2_QUANT,QRY7->D2_QTDEDEV,QRY7->D2_QTSEGUM)/* - ROMS003Q7(QRY7->D2_UM,QRY7->D2_SEGUM,QRY7->B1_COD,QRY7->D2_FILIAL,QRY7->A1_COD_MUN,QRY7->F2_VEND1,QRY7->A1_GRPVEN,QRY7->A1_COD,QRY7->A1_LOJA,'D2_QTSEGUM')*/)}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2S_7 ALIAS "SD2" TITLE   "Seg. UM"            SIZE 05
DEFINE CELL NAME "D2_TOTAUX" 	OF oSF2S_7 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY7->D2_TOTAL,QRY7->D2_TOTAL-QRY7->D2_VALDEV/*-ROMS003QK(QRY7->D2_UM,QRY7->D2_SEGUM,QRY7->B1_COD,QRY7->D2_FILIAL,QRY7->A1_COD_MUN,QRY7->F2_VEND1,QRY7->A1_GRPVEN,QRY7->A1_COD,QRY7->A1_LOJA,.F.)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2S_7 ALIAS "SD2" PICTURE "@E 999,999.9999"    SIZE 08 TITLE "Vlr. Uni."BLOCK {|| if(nqtdeCor > 0,_nVlrTotal/nqtdeCor,0) }
DEFINE CELL NAME "D2_TOTAL" 	OF oSF2S_7 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| _nVlrTotal }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_VALBRUT" 	OF oSF2S_7 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY7->D2_VALBRUT,QRY7->VLRBRUTDEV/*QRY7->D2_VALBRUT-ROMS003QK(QRY7->D2_UM,QRY7->D2_SEGUM,QRY7->B1_COD,QRY7->D2_FILIAL,QRY7->A1_COD_MUN,QRY7->F2_VEND1,QRY7->A1_GRPVEN,QRY7->A1_COD,QRY7->A1_LOJA,.T.)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "LOC_EMB"	    OF oSF2S_7 ALIAS ""    TITLE   "Local de Embarque"  SIZE 40 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY7->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" 

oSF2S_7:Cell("D2_TOTAUX"):Disable()
oSF2S_7:SetTotalInLine(.F.)
oSF2S_7:SetTotalText({||"SUBTOTAL CLIENTE: " + cCliente})
oSF2S_7:OnPrintLine({|| cCliente := QRY7->A1_COD + " - " + QRY7->A1_NREDUZ })
oSF2S_7:Disable()

//Secao ANALITICA ORDEM 07 - Cliente
DEFINE SECTION oSF2A_7 OF oSF2_7A TITLE "Analitico ORDEM 7 - Cliente" TABLES "SD2","SB1"
DEFINE CELL NAME "D2_COD"	    OF oSF2A_7 ALIAS "SD2" TITLE   "Produto"
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2A_7 ALIAS "SB1" TITLE   "Descricao"          SIZE 40 //BLOCK {|| if (!empty(QRY7->D2_I_DQESP),QRY7->D2_I_DQESP,QRY7->B1_I_DESCD)}
DEFINE CELL NAME "F2_DOC" 		OF oSF2A_7 ALIAS "SF2" TITLE   "Documento"          SIZE 12
DEFINE CELL NAME "F2_EMISSAO"   OF oSF2A_7 ALIAS "SF2" TITLE   "Emissão NFe"         SIZE 12
DEFINE CELL NAME "D2_QUANT"	    OF oSF2A_7 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY7->D2_QUANT,QRY7->D2_QUANT-QRY7->D2_QTDEDEV/*ROMS003Q(QRY7->F2_DOC,QRY7->F2_SERIE,QRY7->D2_QTDEDEV,QRY7->D2_FILIAL,QRY7->D2_COD)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2A_7 ALIAS "SD2" TITLE   "Un. M"              SIZE 05
DEFINE CELL NAME "D2_QTSEGUM"   OF oSF2A_7 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 14 BLOCK{|| if(MV_PAR22 == 2,QRY7->D2_QTSEGUM,QRY7->D2_QTSEGUM-ROMS003L(QRY7->D2_QUANT,QRY7->D2_QTDEDEV,QRY7->D2_QTSEGUM)/* - ROMS003L(QRY7->D2_QUANT,ROMS003Q(QRY7->F2_DOC,QRY7->F2_SERIE,QRY7->D2_QTDEDEV,QRY7->D2_FILIAL,QRY7->D2_COD),QRY7->D2_QTSEGUM)*/ )}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2A_7 ALIAS "SD2" TITLE   "Seg. UM"            SIZE 05
DEFINE CELL NAME "D2_TOTAUX"  	OF oSF2A_7 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY7->D2_TOTAL,QRY7->D2_TOTAL-QRY7->D2_VALDEV/*ROMS003V(QRY7->F2_DOC,QRY7->F2_SERIE,QRY7->D2_VALDEV,QRY7->D2_FILIAL,0,0,'D2_TOTAL',QRY7->D2_COD)*/ ) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2A_7 ALIAS "SD2" PICTURE "@E 999,999.9999"    SIZE 08 TITLE "Vlr. Uni."BLOCK {|| if(nqtdeCor > 0,_nVlrTotal/nqtdeCor,0) }
DEFINE CELL NAME "D2_TOTAL"  	OF oSF2A_7 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| _nVlrTotal }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_VALBRUT"  	OF oSF2A_7 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY7->D2_VALBRUT,QRY7->VLRBRUTDEV/*QRY7->D2_VALBRUT-ROMS003V(QRY7->F2_DOC,QRY7->F2_SERIE,QRY7->D2_VALDEV,QRY7->D2_FILIAL,QRY7->D2_TOTAL,QRY7->D2_ICMSRET,'D2_VALDEV',QRY7->D2_COD)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_LOCAL" 	OF oSF2A_7 ALIAS "SD2" TITLE   "Armazem"            SIZE 07 // Armazem
DEFINE CELL NAME "NNR_DESCRI" 	OF oSF2A_7 ALIAS "SD2" TITLE   "Desc.Armazem"       SIZE 20 BLOCK {|| Posicione("NNR",1,xfilial("NNR") + QRY7->D2_LOCAL,"NNR_DESCRI")}  // Descrição Armazem
DEFINE CELL NAME "C5_I_TRCNF" 	OF oSF2A_7 ALIAS "SC5" TITLE   "Troca NF?"          SIZE 08 BLOCK {|| If(QRY7->C5_I_TRCNF=="S","SIM","NAO")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_FILFT" 	OF oSF2A_7 ALIAS "SC5" TITLE   "Filial Fat.?"       SIZE 08 BLOCK {|| If(QRY7->C5_I_TRCNF=="S",QRY7->C5_I_FILFT+"-"+U_ROMS003F(QRY7->C5_I_FILFT)," ")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_FLFNC" 	OF oSF2A_7 ALIAS "SC5" TITLE   "Filial Carr."       SIZE 08 BLOCK {|| If(QRY7->C5_I_TRCNF=="S",QRY7->C5_I_FLFNC+"-"+U_ROMS003F(QRY7->C5_I_FLFNC)," ")}  PICTURE "@!"
DEFINE CELL NAME "DAI_I_OPLO"   OF oSF2A_7 ALIAS "DAI" TITLE   "Op. Log."           SIZE 08 BLOCK {|| QRY7->DAI_I_OPLO} PICTURE "@!"
DEFINE CELL NAME "DAI_I_OPLO" 	OF oSF2A_7 ALIAS "DAI" TITLE   "Nome Op Log"        SIZE 08 BLOCK {||  If(!Empty(Alltrim(QRY7->DAI_I_OPLO)),posicione("SA2",1,xfilial("SA2") + QRY7->DAI_I_OPLO,"A2_NREDUZ")," ")}  PICTURE "@!"
DEFINE CELL NAME "LOC_EMB"	    OF oSF2A_7 ALIAS ""    TITLE   "Local de Embarque"  SIZE 40 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY7->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" 
DEFINE CELL NAME "C5_I_QTDA" 	OF oSF2A_7 ALIAS "SC5" TITLE   "Qtd Agendamento" SIZE 10 BLOCK {|| QRY7->C5_I_QTDA }  PICTURE "@E 999,999,999.99"


oSF2A_7:Cell("D2_TOTAUX"):Disable()
oSF2A_7:SetTotalInLine(.F.)
oSF2A_7:SetTotalText({||"SUBTOTAL CLIENTE: " + cCliente})
oSF2A_7:OnPrintLine({|| cVendedor := QRY7->A1_COD + " - " + QRY7->A1_NREDUZ })
oSF2A_7:Disable()

//====================================================================================================
//Define secoes para Oitava ORDEM 08 - Emissao-Sedex
//====================================================================================================
//Secao Filial
DEFINE SECTION oSF2FIL_8 OF oReport TITLE "Filial Emissao-Sedex" TABLES "SB1","SD2","SF2","SA3"  ORDERS aOrd
DEFINE CELL NAME "D2_FILIAL"	OF oSF2FIL_8 ALIAS "SD2"  TITLE "Cod "
DEFINE CELL NAME "NOMFIL"	    OF oSF2FIL_8 ALIAS "" BLOCK{|| FWFilialName(,QRY8->D2_FILIAL)} TITLE "Filial" SIZE 20

oSF2FIL_8:OnPrintLine({|| cNomeFil := QRY8->D2_FILIAL  + " -  " + FWFilialName(,QRY8->D2_FILIAL)  })
oSF2FIL_8:SetTotalText({|| "SUBTOTAL FILIAL: " + cNomeFil})                                                        
oSF2FIL_8:Disable()

//Secao Cabecalho NF - ANALITICO ORDEM 08 - Emissao-Sedex
DEFINE SECTION oSF2_8 OF oSF2FIL_8 TITLE "Vendedor" TABLES "SA3"
DEFINE CELL NAME "F2_EMISSAO"  	 OF oSF2_8 ALIAS "SA1" TITLE "Emissão NFe"
DEFINE CELL NAME "F2_CARGA"  	 OF oSF2_8 ALIAS "SA1"
DEFINE CELL NAME "F2_DOC"        OF oSF2_8 ALIAS "SA1"  
DEFINE CELL NAME "F2_SERIE"      OF oSF2_8 ALIAS "SA1" 
DEFINE CELL NAME "F2_I_NFREF"    OF oSF2_8 ALIAS "SA1"  
DEFINE CELL NAME "F2_I_SERNF"    OF oSF2_8 ALIAS "SA1"  
DEFINE CELL NAME "F2_CLIENTE"    OF oSF2_8 ALIAS "SA1"
DEFINE CELL NAME "F2_LOJA"       OF oSF2_8 ALIAS "SA1"
DEFINE CELL NAME "A1_NREDUZ"     OF oSF2_8 ALIAS "SA1"
DEFINE CELL NAME "A1_MUN"        OF oSF2_8 ALIAS "SA1"
DEFINE CELL NAME "A1_EST"        OF oSF2_8 ALIAS "SA1"
 
oSF2_8:SetTotalInLine(.F.)
oSF2_8:SetTotalText({||"SUBTOTAL NF: " + cNF  })
oSF2_8:OnPrintLine({|| cNF := QRY8->F2_DOC+ " - " + QRY8->F2_SERIE,AllwaysTrue() }) //Atualiza Variavel do Subtotal
oSF2_8:Disable()

DEFINE BREAK oBrkNF OF oSF2_8 WHEN oSF2_8:Cell("F2_DOC")  TITLE {|| "SUBTOTAL NF: " + cNF}

oBrkNF:OnPrintTotal({|| oReport:SkipLine(2)})

//Secao ANALITICA ORDEM 08 - Emissao-Sedex    
DEFINE SECTION oSF2A_8 OF oSF2_8 TITLE "Analitico ORDEM 8 - Emissao-Sedex" TABLES "SD2","SB1"
DEFINE CELL NAME "D2_ITEM"	    OF oSF2A_8 ALIAS "SD2" TITLE   "Item"
DEFINE CELL NAME "D2_COD"	    OF oSF2A_8 ALIAS "SD2" TITLE   "Produto"
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2A_8 ALIAS "SB1" TITLE   "Descricao"          SIZE 40 //BLOCK {|| if (!empty(QRY8->D2_I_DQESP),QRY8->D2_I_DQESP,QRY8->B1_I_DESCD)}
DEFINE CELL NAME "D2_QUANT"	    OF oSF2A_8 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY8->D2_QUANT,QRY8->D2_QUANT-QRY8->D2_QTDEDEV/*ROMS003Q(QRY8->F2_DOC,QRY8->F2_SERIE,QRY8->D2_QTDEDEV,QRY8->D2_FILIAL,QRY8->D2_COD)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2A_8 ALIAS "SD2" TITLE   "Un. M"              SIZE 05
DEFINE CELL NAME "D2_QTSEGUM"   OF oSF2A_8 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 14 BLOCK {|| if(MV_PAR22 == 2,QRY8->D2_QTSEGUM,QRY8->D2_QTSEGUM-ROMS003L(QRY8->D2_QUANT,QRY8->D2_QTDEDEV,QRY8->D2_QTSEGUM)/*-ROMS003L(QRY7->D2_QUANT,QRY7->D2_QTDEDEV,QRY7->D2_QTSEGUM)/* - ROMS003L(QRY8->D2_QUANT,ROMS003Q(QRY8->F2_DOC,QRY8->F2_SERIE,QRY8->D2_QTDEDEV,QRY8->D2_FILIAL,QRY8->D2_COD),QRY8->D2_QTSEGUM)*/ )}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2A_8 ALIAS "SD2" TITLE   "Seg. UM"            SIZE 05
DEFINE CELL NAME "D2_TOTAUX"  	OF oSF2A_8 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY8->D2_TOTAL,QRY8->D2_TOTAL-QRY8->D2_VALDEV/*ROMS003V(QRY8->F2_DOC,QRY8->F2_SERIE,QRY8->D2_VALDEV,QRY8->D2_FILIAL,0,0,'D2_TOTAL',QRY8->D2_COD)*/ ) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2A_8 ALIAS "SD2" PICTURE "@E 999,999.9999"    SIZE 08 TITLE "Vlr. Uni."BLOCK {|| if(nqtdeCor > 0,_nVlrTotal/nqtdeCor,0) }
DEFINE CELL NAME "D2_TOTAL"  	OF oSF2A_8 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| _nVlrTotal }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_VALBRUT"  	OF oSF2A_8 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY8->D2_VALBRUT,QRY8->VLRBRUTDEV/*QRY8->D2_VALBRUT-ROMS003V(QRY8->F2_DOC,QRY8->F2_SERIE,QRY8->D2_VALDEV,QRY8->D2_FILIAL,QRY8->D2_TOTAL,QRY8->D2_ICMSRET,'D2_VALDEV',QRY8->D2_COD)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_LOCAL" 	OF oSF2A_8 ALIAS "SD2" TITLE   "Armazem"            SIZE 07 // Armazem
DEFINE CELL NAME "NNR_DESCRI" 	OF oSF2A_8 ALIAS "SD2" TITLE   "Desc.Armazem"       SIZE 20 BLOCK {|| Posicione("NNR",1,xfilial("NNR") + QRY8->D2_LOCAL,"NNR_DESCRI")}  // Descrição Armazem
DEFINE CELL NAME "C5_I_TRCNF" 	OF oSF2A_8 ALIAS "SC5" TITLE   "Troca NF?"          SIZE 08 BLOCK {|| If(QRY8->C5_I_TRCNF=="S","SIM","NAO")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_FILFT" 	OF oSF2A_8 ALIAS "SC5" TITLE   "Filial Fat.?"       SIZE 08 BLOCK {|| If(QRY8->C5_I_TRCNF=="S",QRY8->C5_I_FILFT+"-"+U_ROMS003F(QRY8->C5_I_FILFT)," ")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_FLFNC" 	OF oSF2A_8 ALIAS "SC5" TITLE   "Filial Carr."       SIZE 08 BLOCK {|| If(QRY8->C5_I_TRCNF=="S",QRY8->C5_I_FLFNC+"-"+U_ROMS003F(QRY8->C5_I_FLFNC)," ")}  PICTURE "@!"
DEFINE CELL NAME "DAI_I_OPLO"   OF oSF2A_8 ALIAS "DAI" TITLE   "Op. Log."           SIZE 08 BLOCK {|| QRY8->DAI_I_OPLO} PICTURE "@!"
DEFINE CELL NAME "DAI_I_OPLO" 	OF oSF2A_8 ALIAS "DAI" TITLE   "Nome Op Log"        SIZE 08 BLOCK {||  If(!Empty(Alltrim(QRY8->DAI_I_OPLO)),posicione("SA2",1,xfilial("SA2") + QRY8->DAI_I_OPLO,"A2_NREDUZ")," ")}  PICTURE "@!"
DEFINE CELL NAME "F2_I_PEDID" 	OF oSF2A_8 ALIAS "SF2" TITLE   "Local Entrega"      SIZE 08 BLOCK {|| U_ROMS003H(QRY8->F2_FILIAL,QRY8->F2_I_PEDID)  }  
DEFINE CELL NAME "LOC_EMB"	    OF oSF2A_8 ALIAS ""    TITLE   "Local de Embarque"  SIZE 40 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY8->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" 
DEFINE CELL NAME "C5_I_OPER" 	OF oSF2A_8 ALIAS "SC5" TITLE   "Cod Oper."       SIZE 08 
DEFINE CELL NAME "C5_NOPER" 	OF oSF2A_8 ALIAS "SC5" TITLE   "Nome Oper."       SIZE 20 BLOCK {|| POSICIONE("ZB4",1,xFilial("ZB4")+QRY8->C5_I_OPER, "ZB4_DESCRI")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_NFSED" 	OF oSF2A_8 ALIAS "SC5" TITLE   "NF. Sedex?"       SIZE 10 BLOCK {|| Iif(QRY8->C5_I_NFSED=="S","SIM","NAO")}  PICTURE "@!"

DEFINE CELL NAME "F2_I_PEDID" 	OF oSF2A_8 ALIAS "SF2" TITLE   "Tipo Averb.Carga" SIZE 08 BLOCK {|| If(QRY8->A2_I_TPAVE=="E","EMBARCADOR",If(QRY8->A2_I_TPAVE=="T","TRANSPORTADOR",""))}  
DEFINE CELL NAME "C5_I_QTDA" 	OF oSF2A_8 ALIAS "SC5" TITLE   "Qtd Agendamento"       SIZE 10 BLOCK {|| QRY8->C5_I_QTDA }  PICTURE "@E 999,999,999.99"

oSF2A_8:Cell("D2_TOTAUX"):Disable()
oSF2A_8:SetTotalInLine(.F.)
oSF2A_8:Disable()

//Secao SINTETICA  ORDEM 08 - Emissao-Sedex
DEFINE SECTION oSF2S_8 OF oSF2FIL_8 TITLE "Sintetico ORDEM 8 - Emissao-Sedex" TABLES "SF2","SD2"
DEFINE CELL NAME "F2_EMISSAO"  	 OF oSF2S_8 ALIAS "SF2" TITLE   "Emissão NFe"
DEFINE CELL NAME "D2_PEDIDO"  	 OF oSF2S_8 ALIAS "SD2" TITLE   "Pedido"
DEFINE CELL NAME "F2_CARGA"  	 OF oSF2S_8 ALIAS "SF2" TITLE   "Carga"
DEFINE CELL NAME "DOCUMENTO"     OF oSF2S_8 ALIAS "SF2" TITLE   "Documento"         SIZE 15 BLOCK {|| QRY8->F2_DOC + '-' + QRY8->F2_SERIE }
DEFINE CELL NAME "COD CLI"       OF oSF2S_8 ALIAS "SA1" TITLE   "Cliente"           SIZE 11 BLOCK {|| QRY8->F2_CLIENTE + '/' + QRY8->F2_LOJA}
DEFINE CELL NAME "CLIENTE"       OF oSF2S_8 ALIAS "SA1" TITLE   "Cliente"           SIZE 60 BLOCK {|| QRY8->A1_NOME}
DEFINE CELL NAME "D2_TOTAL"  	 OF oSF2S_8 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY8->D2_TOTAL  ,QRY8->D2_TOTAL-QRY8->D2_VALDEV/*ROMS003V(QRY8->F2_DOC,QRY8->F2_SERIE,QRY8->D2_VALDEV,QRY8->D2_FILIAL,0,0,'D2_TOTAL','')*/ ) }  
DEFINE CELL NAME "D2_VALBRUT"  	 OF oSF2S_8 ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY8->D2_VALBRUT,QRY8->VLRBRUTDEV              /*ROMS003V(QRY8->F2_DOC,QRY8->F2_SERIE,QRY8->D2_VALDEV,QRY8->D2_FILIAL,QRY8->D2_TOTAL,QRY8->D2_ICMSRET,'D2_VALDEV','')*/) }  
DEFINE CELL NAME "D2_LOCALIZ" 	 OF oSF2S_8 ALIAS "SD2" TITLE   "Local Entrega"     SIZE 20 BLOCK {|| U_ROMS003H(QRY8->D2_FILIAL,QRY8->D2_PEDIDO)  }  
DEFINE CELL NAME "WK_PEDDW"	     OF oSF2S_8 ALIAS "SC5" TITLE   "Pedido Externo"    SIZE 15 BLOCK {|| U_ROMS003J("WK_PEDDW") }

If MV_PAR31 == 1 
 
   DEFINE CELL NAME "WK_FILIAL"  OF oSF2S_8 ALIAS "SC5" TITLE "Filial TNF"   SIZE 30  BLOCK {|| U_ROMS003J("WK_FILIAL", QRY8->D2_FILIAL,QRY8->D2_PEDIDO) }
   DEFINE CELL NAME "WK_EMISSAO" OF oSF2S_8 ALIAS "SF2" TITLE "Emissão PV"      SIZE 10  BLOCK {|| U_ROMS003J("WK_EMISSAO")}
   DEFINE CELL NAME "WK_PEDIDO"  OF oSF2S_8 ALIAS "SD2" TITLE "Pedido"       SIZE 10  BLOCK {|| U_ROMS003J("WK_PEDIDO") }
   DEFINE CELL NAME "WK_CARGA"   OF oSF2S_8 ALIAS "SF2" TITLE "Carga"        SIZE 10  BLOCK {|| U_ROMS003J("WK_CARGA")  }
   DEFINE CELL NAME "WK_DOCNTO"  OF oSF2S_8 ALIAS "SF2" TITLE "Documento"    SIZE 15  BLOCK {|| U_ROMS003J("WK_DOCNTO") }
   DEFINE CELL NAME "WK_CODCLI"  OF oSF2S_8 ALIAS "SA1" TITLE "Cod.Cliente"  SIZE 11  BLOCK {|| U_ROMS003J("WK_CODCLI") }
   DEFINE CELL NAME "WK_CLIENTE" OF oSF2S_8 ALIAS "SA1" TITLE "Nome Cliente" SIZE 60  BLOCK {|| U_ROMS003J("WK_CLIENTE")}
   DEFINE CELL NAME "WK_PEDCLI"  OF oSF2S_8 ALIAS "SF2" TITLE "Ped Cliente"  SIZE 15  BLOCK {|| U_ROMS003J("WK_PEDCLI") }
   DEFINE CELL NAME "WK_PEDITA"  OF oSF2S_8 ALIAS "SF2" TITLE "Ped Italac"   SIZE 15  BLOCK {|| U_ROMS003J("WK_PEDITA") }
   DEFINE CELL NAME "WK_DTENT"   OF oSF2S_8 ALIAS "SF2" TITLE "Dt Entrega"   SIZE 15  BLOCK {|| U_ROMS003J("WK_DTENT")  }
   DEFINE CELL NAME "WK_TPAGEN"  OF oSF2S_8 ALIAS "SF2" TITLE "Tipo Agenda"  SIZE 15  BLOCK {|| U_ROMS003J("WK_TPAGEN") }
   DEFINE CELL NAME "WK_PEDPOR"  OF oSF2S_8 ALIAS "SF2" TITLE "Ped Portal"   SIZE 15  BLOCK {|| U_ROMS003J("WK_PEDPOR") }
   DEFINE CELL NAME "WK_OBSNF"   OF oSF2S_8 ALIAS "SF2" TITLE "Obs NF"       SIZE 60  BLOCK {|| U_ROMS003J("WK_OBSNF")  }

 EndIf
DEFINE CELL NAME "LOC_EMB"	     OF oSF2S_8 ALIAS ""    TITLE "Local de Embarque" SIZE 40 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY8->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" 
DEFINE CELL NAME "C5_I_OPER" 	OF oSF2S_8 ALIAS "SC5" TITLE   "Cod Oper."        SIZE 08 
DEFINE CELL NAME "C5_NOPER" 	OF oSF2S_8 ALIAS "SC5" TITLE   "Nome Oper."       SIZE 20 BLOCK {|| POSICIONE("ZB4",1,xFilial("ZB4")+QRY8->C5_I_OPER, "ZB4_DESCRI")}  PICTURE "@!"
DEFINE CELL NAME "C5_I_NFSED" 	OF oSF2S_8 ALIAS "SC5" TITLE   "NF. Sedex?"       SIZE 10 BLOCK {|| Iif(QRY8->C5_I_NFSED=="S","SIM","NAO")}  PICTURE "@!"

DEFINE CELL NAME "A2_I_TPAVE"   OF oSF2S_8 ALIAS ""    TITLE "Tipo Averb.Carga"   SIZE 12 BLOCK {|| If(QRY8->A2_I_TPAVE=="E","EMBARCADOR",If(QRY8->A2_I_TPAVE=="T","TRANSPORTADOR",""))}  

oSF2S_8:SetTotalInLine(.F.)
oSF2S_8:Disable()

//====================================================================================================
//ORDEM 09 - Estado X Grupo de Produtos - SÓ TEM SINTETICO
//====================================================================================================
//Secao Filial
DEFINE SECTION oSF2FIL_9 OF oReport TITLE "Filial Est x Grupo Prod" TABLES "SB1","SD2","SF2","SA3"  ORDERS aOrd

DEFINE CELL NAME "D2_FILIAL"	OF oSF2FIL_9 ALIAS "SD2"  TITLE "Cod "
DEFINE CELL NAME "NOMFIL"	    OF oSF2FIL_9 ALIAS ""                  BLOCK{|| FWFilialName(,QRY9->D2_FILIAL)} TITLE "Filial" SIZE 20

oSF2FIL_9:OnPrintLine({|| cNomeFil := QRY9->D2_FILIAL  + " -  " + FWFilialName(,QRY9->D2_FILIAL)  })
oSF2FIL_9:SetTotalText({|| "SUBTOTAL FILIAL: " + cNomeFil})                                                        
oSF2FIL_9:Disable()

DEFINE SECTION oSF2_9 OF oSF2FIL_9 TITLE "Estado" TABLES "SB1","SD2","SF2","SA3"  
DEFINE CELL NAME "D2_EST"   	OF oSF2_9 ALIAS "SD2" TITLE "Estado"
DEFINE CELL NAME "ESTADO"   	OF oSF2_9 ALIAS ""    TITLE "Descrição" SIZE 40 BLOCK {|| POSICIONE("SX5",1,XFILIAL("SX5")+"12"+QRY9->D2_EST,"X5_DESCRI")}       

oSF2_9:Disable()                                                 
oSF2_9:SetLinesBefore(4)

//Secao SINTETICA
DEFINE SECTION oSF2S_9          OF oSF2_9 TITLE "Sintetico ORDEM 9-Estado X Grupo de Produtos" TABLES "SD2","SBM","SB1"
DEFINE CELL NAME "BM_DESC"   	OF oSF2S_9 ALIAS "SBM" TITLE   "Grupo de Produtos"  SIZE 25 
DEFINE CELL NAME "D2_QUANT"	    OF oSF2S_9 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY9->D2_QUANT,QRY9->D2_QUANT-QRY9->D2_QTDEDEV/*-ROMS003Q9(QRY9->D2_UM,QRY9->D2_SEGUM,QRY9->B1_GRUPO,QRY9->D2_FILIAL,QRY9->D2_EST,'D2_QTDEDEV')*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2S_9 ALIAS "SD2" TITLE   "Un. M"              SIZE 05
DEFINE CELL NAME "D2_QTSEGUM"   OF oSF2S_9 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 14 BLOCK {|| if(MV_PAR22 == 2,QRY9->D2_QTSEGUM,QRY9->D2_QTSEGUM-ROMS003L(QRY9->D2_QUANT,QRY9->D2_QTDEDEV,QRY9->D2_QTSEGUM)/*-ROMS003Q9(QRY9->D2_UM,QRY9->D2_SEGUM,QRY9->B1_GRUPO,QRY9->D2_FILIAL,QRY9->D2_EST,'D2_QTSEGUM')*/)}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2S_9 ALIAS "SD2" TITLE   "Seg. UM"            SIZE 05
DEFINE CELL NAME "D2_TOTAUX" 	OF oSF2S_9 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY9->D2_TOTAL,QRY9->D2_TOTAL-QRY9->D2_VALDEV/*-ROMS003QL(QRY9->D2_UM,QRY9->D2_SEGUM,QRY9->B1_GRUPO,QRY9->D2_FILIAL,QRY9->D2_EST,.F.)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2S_9 ALIAS "SD2" PICTURE "@E 999,999.9999"    SIZE 08 BLOCK {|| if(nqtdeCor > 0,_nVlrTotal/nqtdeCor,0)} TITLE "Vlr. Uni." 
DEFINE CELL NAME "D2_TOTAL" 	OF oSF2S_9 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| _nVlrTotal }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_VALBRUT" 	OF oSF2S_9 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY9->D2_VALBRUT,QRY9->VLRBRUTDEV/*QRY9->D2_VALBRUT - ROMS003QL(QRY9->D2_UM,QRY9->D2_SEGUM,QRY9->B1_GRUPO,QRY9->D2_FILIAL,QRY9->D2_EST,.T.)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "LOC_EMB"	    OF oSF2S_9 ALIAS ""    TITLE   "Local de Embarque"  SIZE 40 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY9->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" 

oSF2S_9:Cell("D2_TOTAUX"):Disable()
oSF2S_9:SetTotalInLine(.F.)
oSF2S_9:SetTotalText({||"SUBTOTAL ESTADO: " + cEstado})
oSF2S_9:OnPrintLine({|| cEstado := QRY9->D2_EST + " - " + POSICIONE("SX5",1,XFILIAL("SX5")+"12"+QRY9->D2_EST,"X5_DESCRI") })
oSF2S_9:Disable()             


//====================================================================================================
//ORDEM 13 - Filial X Dia X Estado - SÓ TEM SINTETICO
//====================================================================================================
//Secao Filial
DEFINE SECTION oSF2FIL_13 OF oReport TITLE "Filial Estado" TABLES "SB1","SD2","SF2","SA3"  ORDERS aOrd
DEFINE CELL NAME "D2_FILIAL"	OF oSF2FIL_13 ALIAS "SD2"  TITLE "Cod "
DEFINE CELL NAME "NOMFIL"	    OF oSF2FIL_13 ALIAS "" BLOCK{|| FWFilialName(,QRY13->D2_FILIAL)} TITLE "Filial" SIZE 20  

oSF2FIL_13:OnPrintLine({|| cNomeFil := QRY13->D2_FILIAL  + " -  " + FWFilialName(,QRY13->D2_FILIAL)  })
oSF2FIL_13:SetTotalText({|| "SUBTOTAL FILIAL: " + cNomeFil})                                                        
oSF2FIL_13:Disable()  

DEFINE SECTION oSF2DT_13 OF oSF2FIL_13 TITLE "Data Faturamento" TABLES "SF2"
DEFINE CELL NAME "Data"   	OF oSF2DT_13 ALIAS "" SIZE 40 BLOCK {|| DtoC(QRY13->F2_EMISSAO)}  
DEFINE CELL NAME "QBRDATA"  OF oSF2DT_13 ALIAS "" SIZE 40 BLOCK {|| QRY13->D2_FILIAL  + DtoS(QRY13->F2_EMISSAO)}  

oSF2DT_13:Cell("QBRDATA"):Disable()
oSF2DT_13:Disable()

DEFINE SECTION oSF2_13 OF oSF2DT_13 TITLE "Estado" TABLES "SD2"
DEFINE CELL NAME "D2_EST"   	OF oSF2_13 ALIAS "SD2" TITLE "Estado"
DEFINE CELL NAME "ESTADO"   	OF oSF2_13 ALIAS "" TITLE "Descrição" SIZE 40 BLOCK {|| POSICIONE("SX5",1,XFILIAL("SX5")+"12"+QRY13->D2_EST,"X5_DESCRI")} 

oSF2_13:Disable()

//Secao SINTETICA
DEFINE SECTION oSF2A_13 OF oSF2_13 TITLE "Sintetico ORDEM 13-Filial X Dia X Estado" TABLES "SD2","SB1"  
DEFINE CELL NAME "D2_COD"	    OF oSF2A_13 ALIAS "SD2" TITLE   "Produto"
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2A_13 ALIAS "SB1" TITLE   "Descricao"          SIZE 50 
DEFINE CELL NAME "D2_QUANT"	    OF oSF2A_13 ALIAS "SD2" PICTURE "@E 999,999,999.999" SIZE 17 BLOCK {|| nqtdeCor:=if(MV_PAR22 == 2,QRY13->D2_QUANT,QRY13->D2_QUANT-QRY13->D2_QTDEDEV/* - ROMS003QC(QRY13->D2_UM,QRY13->D2_SEGUM,QRY13->D2_COD,QRY13->D2_FILIAL,QRY13->D2_EST,QRY13->F2_EMISSAO,'D2_QTDEDEV')*/)}  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_UM"      	OF oSF2A_13 ALIAS "SD2" TITLE   "Un. M"              SIZE 05
DEFINE CELL NAME "D2_QTSEGUM"   OF oSF2A_13 ALIAS "SD2" PICTURE "@E 999,999.999"     SIZE 14 BLOCK {|| if(MV_PAR22 == 2,QRY13->D2_QTSEGUM,QRY13->D2_QTSEGUM-ROMS003L(QRY13->D2_QUANT,QRY13->D2_QTDEDEV,QRY13->D2_QTSEGUM)/* - ROMS003QC(QRY13->D2_UM,QRY13->D2_SEGUM,QRY13->D2_COD,QRY13->D2_FILIAL,QRY13->D2_EST,QRY13->F2_EMISSAO,'D2_QTSEGUM')*/)}
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2A_13 ALIAS "SD2" TITLE   "Seg. UM"            SIZE 05
DEFINE CELL NAME "D2_TOTAUX"  	OF oSF2A_13 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| _nVlrTotal:=if(MV_PAR22 == 2,QRY13->D2_TOTAL,QRY13->D2_TOTAL-QRY13->D2_VALDEV/* - ROMS003QN(QRY13->D2_UM,QRY13->D2_SEGUM,QRY13->D2_COD,QRY13->D2_FILIAL,QRY13->D2_EST,QRY13->F2_EMISSAO,.F.)*/)}  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2A_13 ALIAS "SD2" PICTURE "@E 999,999.9999"    SIZE 08 BLOCK {|| if(nqtdeCor > 0,_nVlrTotal/nqtdeCor,0)} TITLE "Vlr. Uni."
DEFINE CELL NAME "D2_TOTAL"  	OF oSF2A_13 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| _nVlrTotal }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "D2_VALBRUT"  	OF oSF2A_13 ALIAS "SD2" PICTURE "@E 999,999,999.99"  SIZE 20 BLOCK {|| if(MV_PAR22 == 2,QRY13->D2_VALBRUT,QRY13->VLRBRUTDEV/*QRY13->D2_VALBRUT - ROMS003QN(QRY13->D2_UM,QRY13->D2_SEGUM,QRY13->D2_COD,QRY13->D2_FILIAL,QRY13->D2_EST,QRY13->F2_EMISSAO,.T.)*/) }  //MV_PAR22 == 2 Nao considera devolucoes
DEFINE CELL NAME "LOC_EMB"	    OF oSF2A_13 ALIAS ""    TITLE   "Local de Embarque"  SIZE 40 BLOCK {|| POSICIONE("ZEL",1,xFilial("ZEL")+QRY13->C5_I_LOCEM,"ZEL_DESCRI") } PICTURE "@!" 

oSF2A_13:Cell("D2_TOTAUX"):Disable()
oSF2A_13:SetTotalInLine(.F.)
oSF2A_13:SetTotalText({||"SUBTOTAL ESTADO: " + cEstado})
oSF2A_13:OnPrintLine({|| cEstado := QRY13->D2_EST + " - " + POSICIONE("SX5",1,XFILIAL("SX5")+"12"+QRY13->D2_EST,"X5_DESCRI"),_cDia:= DtoC(QRY13->F2_EMISSAO) })
oSF2A_13:Disable()

oReport:PrintDialog()

Return()

/*
===============================================================================================================================
Programa--------: ROM003P
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Rotina de processamento do relatório
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROM003P(oReport)

Private _cfiltro := "%"
Private _nOrdem := oSF2FIL_1:GetOrder() //Busca ordem selecionada pelo usuario  
 
PRIVATE _aFilSM0 := FWLoadSM0() 

//Muda titulo do relatorio de acordo com ordem escolhida pelo usuario
oReport:SetTitle(oReport:Title() + " - " + If(_nOrdem <> 2 .And. _nOrdem <> 9 .And. _nOrdem <> 13,if(mv_par19 == 1,"Sintetico.","Analitico." ),"")+ " Ordem "  + aOrd[_nOrdem] + ". De " +  dtoc(mv_par02) + " até " + dtoc(mv_par03))

//Define o filtro de acordo com os parametros digitados
//Filtra Filial da SF2,SD2,SA1,SB1,SBM,SA3,ACY  

If Len(alltrim(mv_par01)) = 2
	if !empty(xFilial("SF2"))
		_cfiltro += " AND SF2.F2_FILIAL = '" + (Alltrim(mv_par01)) + "' " 
	endif	  
	if !empty(xFilial("SF4"))
		_cfiltro += " AND SF4.F4_FILIAL = '" + (Alltrim(mv_par01)) + "' " 
	endif	                       
	if !empty(xFilial("SD2"))
		_cfiltro += " AND SD2.D2_FILIAL = '" + (Alltrim(mv_par01)) + "' " 
	endif 
Elseif !empty(alltrim(mv_par01))	
	if !empty(xFilial("SF2"))
		_cfiltro += " AND SF2.F2_FILIAL IN " + FormatIn(ALLTRIM(mv_par01),";")
	endif	  
	if !empty(xFilial("SF4"))
		_cfiltro += " AND SF4.F4_FILIAL IN " + FormatIn(ALLTRIM(mv_par01),";")
	endif	                       
	if !empty(xFilial("SD2"))
		_cfiltro += " AND SD2.D2_FILIAL IN " + FormatIn(ALLTRIM(mv_par01),";")
	endif             	
endif 

if !empty(xFilial("SA1"))
	_cfiltro += " AND SA1.A1_FILIAL = ' ' "
endif
if !empty(xFilial("SB1"))	
	_cfiltro += " AND SB1.B1_FILIAL = ' ' " 
endif
if !empty(xFilial("SA3"))
	_cfiltro += " AND SA3.A3_FILIAL = ' ' "  
endif
if !empty(xFilial("SBM"))
	_cfiltro += " AND SBM.BM_FILIAL = ' ' "  
endif
if !empty(xFilial("ACY"))
	_cfiltro += " AND ACY.ACY_FILIAL = ' ' " 
endif

//Filtra Emissao da SD2
if !empty(mv_par02) .and. !empty(mv_par03)
	_cfiltro += " AND SD2.D2_EMISSAO BETWEEN '" + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "'"
endif

//Filtra Produto
if !empty(mv_par04) .and. !empty(mv_par05)
	_cfiltro += " AND SD2.D2_COD BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "'"
endif

//Filtra Cliente
if !empty(mv_par06) .and. !empty(mv_par08)
	_cfiltro += " AND SD2.D2_CLIENTE BETWEEN '" + mv_par06 + "' AND '" + mv_par08 + "'"
endif

//Filtra Loja Cliente
if !empty(mv_par07) .and. !empty(mv_par09)
	_cfiltro += " AND SD2.D2_LOJA BETWEEN '" + mv_par07 + "' AND '" + mv_par09 + "'"
endif

//Filtra Rede Cliente
if !empty(mv_par10)
	_cfiltro += " AND SA1.A1_GRPVEN IN " + FormatIn(ALLTRIM(mv_par10),";")
endif
     
//Filtra Estado Cliente
if !empty(mv_par11) 
	_cfiltro += " AND SA1.A1_EST IN " + FormatIn(ALLTRIM(mv_par11),";")
endif

//Filtra Cod Municipio Cliente
if !empty(mv_par12) 
	_cfiltro += " AND SA1.A1_COD_MUN IN " + FormatIn(ALLTRIM(mv_par12),";")
endif

If MV_PAR35 <> 4
	_cfiltro += " AND SA1.A1_I_CLABC  = '"+STR(MV_PAR35,1)+"' "
ELSEIf SuperGetMV("IT_AMBTEST",.F.,.T.)
	_cfiltro += " AND SA1.A1_I_CLABC  <> ' ' "
EndIf

//Filtra Vendedor
if !empty(mv_par13) 
	_cfiltro += " AND SF2.F2_VEND1 IN " + FormatIn(ALLTRIM(mv_par13),";")
endif

//Filtra Coordenador
if !empty(mv_par14)
	_cfiltro += " AND SF2.F2_VEND2 IN " + FormatIn(ALLTRIM(mv_par14),";")
endif 

//Filtra Gerente
if !empty(MV_PAR34)
	_cfiltro += " AND SF2.F2_VEND3 IN " + FormatIn(ALLTRIM(MV_PAR34),";")
endif 


//Filtra Grupo de Produtos
if !empty(mv_par15)
	_cfiltro += " AND SBM.BM_GRUPO IN " + FormatIn(ALLTRIM(mv_par15),";")
endif

//Filtra Produto Nivel 2
if !empty(mv_par16)
	_cfiltro += " AND SB1.B1_I_NIV2 IN " + FormatIn(ALLTRIM(mv_par16),";")
endif

//Filtra Produto Nivel 3
if !empty(mv_par17)
	_cfiltro += " AND SB1.B1_I_NIV3 IN " + FormatIn(ALLTRIM(mv_par17),";")
endif

//Filtra Produto Nivel 4
if !empty(mv_par18)
	_cfiltro += " AND SB1.B1_I_NIV4 IN " + FormatIn(ALLTRIM(mv_par18),";")
endif  

if !EMPTY(mv_par32)
	if LEN(mv_par32) = 2
		_cFiltro += " AND SB1.B1_I_BIMIX = '" + mv_par32 + "'"
	else
		_cFiltro += " AND SB1.B1_I_BIMIX IN " + FormatIn(ALLTRIM(mv_par32),";")
	endif
endif

IF !EMPTY(MV_PAR33)
	MV_PAR33 := ALLTRIM(MV_PAR33)
	IF LEN(MV_PAR33) = 2
		_cFiltro += " AND SC5.C5_I_OPER = '"+MV_PAR33+"' "
	ELSE
		_cFiltro += " AND SC5.C5_I_OPER IN " + FormatIn(ALLTRIM(MV_PAR33),";") + " "
	ENDIF
ENDIF

//busca CFOPS de acordo com parametro definido por usuario	
IF !EMPTY(MV_PAR20)
	//Senao tiver escolhido a opcao todos
	IF !("A" $ MV_PAR20 )       	
		cCfops := U_ITCFOPS(ALLTRIM(UPPER(MV_PAR20)))
		//_cFiltro += " AND SD2.D2_CF IN " + FormatIn(ALLTRIM(cCfops),";")	

        _cFiltro += " AND SC5.C5_I_OPER <> '05' "
	    IF ("V" $ MV_PAR20 ) .AND. !("R" $ MV_PAR20 )
		   _cFiltro += " AND ( SD2.D2_CF IN " + FormatIn(ALLTRIM(cCfops),";")
		   cCfopsR := U_ITCFOPS("R")
		   _cFiltro += " OR ( SD2.D2_CF IN " + FormatIn(ALLTRIM(cCfopsR),";") + " AND SC5.C5_I_OPER = '42' ) ) "
	    ELSE//IF !("V" $ MV_PAR20 ) 
		   _cFiltro += " AND SD2.D2_CF IN " + FormatIn(ALLTRIM(cCfops),";")
		ENDIF
	ENDIF
ENDIF

//Filtra NF - Sedex
if MV_PAR21 == 2 //Nao  - Nao Considera NF Sedex no Filtro
	_cfiltro += " AND SF2.F2_I_NFSED <> 'S' " 
elseif MV_PAR21 == 3 //Somente NF Sedex
	_cfiltro += " AND SF2.F2_I_NFSED = 'S' " 
endif   
                       
//Filtra se tes gera financeiro
IF MV_PAR26 == 2
     
   _cfiltro += " AND SF4.F4_DUPLIC = 'S'"

//Nao gera Financeiro
ELSEIF MV_PAR26 == 3

  _cfiltro += " AND SF4.F4_DUPLIC = 'N'"

ENDIF

//Filtra Sub Grupo de Produto
if !empty(mv_par27)
	_cfiltro += " AND SB1.B1_I_SUBGR IN " + FormatIn(ALLTRIM(mv_par27),";")
endif
     
//Considera somente cargas montadas 

If MV_PAR28 == 2
  
 	_cfiltro += " AND SF2.F2_CARGA <> ' ' "                  

//Considera somente o faturamente que nao houve montagem de carga
ElseIf MV_PAR28 == 3

		_cfiltro += " AND SF2.F2_CARGA = ' ' "     
EndIf

//Considera somente com operador logistico 

If MV_PAR29 == 2

	//Filtra operador logistico
	If !Empty(mv_par30)
		If LEN(ALLTRIM(MV_PAR30)) < 5
	    	MV_PAR30:=LEFT(MV_PAR30,6)
	     	cFiltro += " AND DAI.DAI_I_OPLO = '"+MV_PAR30+"' "
      	Else
			_cfiltro += " AND DAI.DAI_I_OPLO  IN " + FormatIn(ALLTRIM(mv_par30),";")
      	Endif
    Else
		_cfiltro += "  AND DAI.DAI_I_OPLO  <> ' ' "             	
	Endif  	           
	//Considera somente o faturamente que nao houve montagem de carga
ElseIf MV_PAR29 == 3

		_cfiltro += "  AND DAI.DAI_I_OPLO = ' ' "
		
EndIf

//==============================================================
// Filtro por código de evento comercial
//==============================================================
If !EMPTY(MV_PAR36) 
   _cfiltro += " AND SC5.C5_I_EVENT  = '" + MV_PAR36 + "' " 
EndIf

_cfiltro += "%"

_cJOIN_SF1 := "%"
_cJOIN_SF1 += " INNER JOIN SF1010 SF1 ON D1.D1_DOC     = SF1.F1_DOC     AND "
_cJOIN_SF1 += "                          D1.D1_SERIE   = SF1.F1_SERIE   AND "
_cJOIN_SF1 += "                          D1.D1_FILIAL  = SF1.F1_FILIAL  AND "
_cJOIN_SF1 += "                          D1.D1_FORNECE = SF1.F1_FORNECE AND "
_cJOIN_SF1 += "                          D1.D1_LOJA    = SF1.F1_LOJA    AND "
_cJOIN_SF1 += "                          SF1.F1_TIPO   = 'D'            AND "
_cJOIN_SF1 += RetSqlDel('SF1')
//Tipo de Formulario
If MV_PAR23 == 1 //Se formulario proprio = sim 
   _cJOIN_SF1 += " AND SF1.F1_FORMUL = 'S' "
ElseIf MV_PAR23 == 2 //Se formulario proprio = nao
   _cJOIN_SF1 += " AND SF1.F1_FORMUL <> 'S' "
EndIf
If !Empty(MV_PAR25)
   _cJOIN_SF1 += " AND SF1.F1_DTDIGIT BETWEEN '" + DTOS(MV_PAR24) + "' AND '" + DTOS(MV_PAR25) + "'"
ENDIF
_cJOIN_SF1 += "%"


//Imprime relatorio da Ordem Produto ou Sub Grupo Sintetico em modo grafico, Coordenador X Produto , estado x Sub-Grupo
If _nOrdem == 2 .Or. _nOrdem == 10 .Or. _nOrdem == 11 .Or. _nOrdem == 12
     ROMS003G()   //IMPRIMI COM O U_ITListBox QUANDO ENVIADO PARA PLANILHA SENÃO VIA TMSPrinter()
     oReport:CancelPrint() 
EndIf

//Verifica qual ordem usuario definiu
if _nOrdem == 1 //COORDENADOR / VENDEDOR ORDEM 01
	//Habilita Secoes
	
    //Define break para Filial para sumarizar campos
	DEFINE BREAK oBrkFil OF oSF2FIL_1 WHEN oSF2FIL_1:CELL("D2_FILIAL") TITLE {|| "SUBTOTAL FILIAL: " + cNomeFil}
	oSF2FIL_1:Enable()
	oSF2_1:Enable()
	oSF2_1A:Enable()
	if mv_par19 == 1 //SINTETICO
		oSF2S_1:Enable()		
		
		DEFINE FUNCTION FROM oSF2S_1:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkSup //coloca o Break aqui para sumarizar a secao do Coordenador 
		DEFINE FUNCTION FROM oSF2S_1:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkSup
		DEFINE FUNCTION FROM oSF2S_1:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkSup	  		
		DEFINE FUNCTION FROM oSF2S_1:Cell("D2_VALBRUT") FUNCTION SUM BREAK oBrkSup 
		
		//Funcoes para sumarizacao do grupo filial
		DEFINE FUNCTION FROM oSF2S_1:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT
		DEFINE FUNCTION FROM oSF2S_1:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT
		DEFINE FUNCTION FROM oSF2S_1:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT			
		DEFINE FUNCTION FROM oSF2S_1:Cell("D2_VALBRUT") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT		
		
	ELSE//ANALITICO

		DEFINE FUNCTION FROM oSF2A_1:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkSup //coloca o Break aqui para sumarizar a secao do Coordenador 
		DEFINE FUNCTION FROM oSF2A_1:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkSup	
		DEFINE FUNCTION FROM oSF2A_1:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkSup	
		DEFINE FUNCTION FROM oSF2A_1:Cell("D2_VALBRUT") FUNCTION SUM BREAK oBrkSup			
		
		DEFINE FUNCTION FROM oSF2A_1:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT
		DEFINE FUNCTION FROM oSF2A_1:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_1:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_1:Cell("D2_VALBRUT") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
				
		oSF2A_1:Enable()//SÓ ANALITICO

	endif
	
//Ordem Por Produto
elseif _nOrdem == 3
	oSF2FIL_3:Enable()
    //Define break para Filial para sumarizar campos
	DEFINE BREAK oBrkFil OF oSF2FIL_3 WHEN oSF2FIL_3:CELL("D2_FILIAL") TITLE {|| "SUBTOTAL FILIAL: " + cNomeFil}
	
	
	//Define funcoes de soma para secao Produto  - Sintetico
	if mv_par19 == 1 //Sintetico
		DEFINE FUNCTION FROM oSF2S_3:Cell("D2_QUANT")   FUNCTION SUM NO END SECTION 
		DEFINE FUNCTION FROM oSF2S_3:Cell("D2_QTSEGUM") FUNCTION SUM NO END SECTION 
		DEFINE FUNCTION FROM oSF2S_3:Cell("D2_TOTAL")   FUNCTION SUM NO END SECTION 
		DEFINE FUNCTION FROM oSF2S_3:Cell("D2_VALBRUT")   FUNCTION SUM NO END SECTION 
		
		DEFINE FUNCTION FROM oSF2S_3:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_3:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_3:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_3:Cell("D2_VALBRUT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		
	else                                                                    
		
		//Define funcoes de soma para secao Produto  - Analitico
		DEFINE FUNCTION FROM oSF2A_3:Cell("D2_QUANT")   FUNCTION SUM //BREAK oBrkProdut NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_3:Cell("D2_QTSEGUM") FUNCTION SUM //BREAK oBrkProdut NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_3:Cell("D2_TOTAL")   FUNCTION SUM //BREAK oBrkProdut NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_3:Cell("D2_VALBRUT") FUNCTION SUM //BREAK oBrkProdut NO END SECTION NO END REPORT			
		
		DEFINE FUNCTION FROM oSF2A_3:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_3:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_3:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_3:Cell("D2_VALBRUT") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		
		//Define break para data Emissao
		DEFINE BREAK oBrkDtEmis OF oSF2A_3 WHEN oSF2A_3:CELL("QBREMISS") TITLE {||"Total do Dia: " }
		
		DEFINE FUNCTION FROM oSF2A_3:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkDtEmis NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_3:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkDtEmis NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_3:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkDtEmis NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_3:Cell("D2_VALBRUT") FUNCTION SUM BREAK oBrkDtEmis NO END SECTION NO END REPORT
		
		oSF2_3:Enable()
		
	endif
		
//ORDEM 04 POR REDE
elseif _nOrdem == 4

	oSF2FIL_4:Enable()
	
    //Define break para Filial para sumarizar campos
	DEFINE BREAK oBrkFil OF oSF2FIL_4 WHEN oSF2FIL_4:CELL("D2_FILIAL") TITLE {|| "SUBTOTAL FILIAL: " + cNomeFil}

	//Define funcoes de soma para secao
	if mv_par19 == 1 //Sintetico
		oSF2S_4:Enable()	
		DEFINE FUNCTION FROM oSF2S_4:Cell("D2_QUANT")   FUNCTION SUM 
		DEFINE FUNCTION FROM oSF2S_4:Cell("D2_QTSEGUM") FUNCTION SUM 
		DEFINE FUNCTION FROM oSF2S_4:Cell("D2_TOTAL")   FUNCTION SUM 
		DEFINE FUNCTION FROM oSF2S_4:Cell("D2_VALBRUT")   FUNCTION SUM 
				
		
		DEFINE FUNCTION FROM oSF2S_4:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_4:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_4:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_4:Cell("D2_VALBRUT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		
	else	
		oSF2A_4:Enable()	
		DEFINE FUNCTION FROM oSF2A_4:Cell("D2_QUANT")   FUNCTION SUM 
		DEFINE FUNCTION FROM oSF2A_4:Cell("D2_QTSEGUM") FUNCTION SUM 
		DEFINE FUNCTION FROM oSF2A_4:Cell("D2_TOTAL")   FUNCTION SUM 
		DEFINE FUNCTION FROM oSF2A_4:Cell("D2_VALBRUT")   FUNCTION SUM 		
		
		DEFINE FUNCTION FROM oSF2A_4:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_4:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_4:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_4:Cell("D2_VALBRUT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		
	endif

	oSF2_4:Enable()	


// ORDEM 05 - Estado x Produto  
elseif _nOrdem == 5

	oSF2FIL_5:Enable()

    //Define break para Filial para sumarizar campos
	DEFINE BREAK oBrkFil OF oSF2FIL_5 WHEN oSF2FIL_5:CELL("D2_FILIAL") TITLE {|| "SUBTOTAL FILIAL: " + cNomeFil}

	//Define funcoes de soma para secao
	if mv_par19 == 1 //SECAO SINTETICA // ORDEM 5 - Estado x Produto  

		oSF2S_5:Enable()	

		DEFINE FUNCTION FROM oSF2S_5:Cell("D2_QUANT")   FUNCTION SUM 
		DEFINE FUNCTION FROM oSF2S_5:Cell("D2_QTSEGUM") FUNCTION SUM 
		DEFINE FUNCTION FROM oSF2S_5:Cell("D2_TOTAL")   FUNCTION SUM 
		DEFINE FUNCTION FROM oSF2S_5:Cell("D2_VALBRUT")   FUNCTION SUM 
		
		DEFINE FUNCTION FROM oSF2S_5:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_5:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_5:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_5:Cell("D2_VALBRUT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		
	else	//ANALITICO

		oSF2A_5:Enable()	

		DEFINE FUNCTION FROM oSF2A_5:Cell("D2_QUANT")   FUNCTION SUM 
		DEFINE FUNCTION FROM oSF2A_5:Cell("D2_QTSEGUM") FUNCTION SUM 
		DEFINE FUNCTION FROM oSF2A_5:Cell("D2_TOTAL")   FUNCTION SUM 
		DEFINE FUNCTION FROM oSF2A_5:Cell("D2_VALBRUT")   FUNCTION SUM 
		
		DEFINE FUNCTION FROM oSF2A_5:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_5:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_5:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_5:Cell("D2_VALBRUT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	

	endif

	oSF2_5:Enable()	

//ORDEM 06 POR Municipio
elseif _nOrdem == 6

	oSF2FIL_6:Enable()

    //Define break para Filial para sumarizar campos
	DEFINE BREAK oBrkFil OF oSF2FIL_6 WHEN oSF2FIL_6:CELL("D2_FILIAL") TITLE {|| "SUBTOTAL FILIAL: " + cNomeFil}

	//Define funcoes de soma para secao
	if mv_par19 == 1 //Sintetico

		oSF2S_6:Enable() 

		DEFINE FUNCTION FROM oSF2S_6:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkMun
		DEFINE FUNCTION FROM oSF2S_6:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkMun
		DEFINE FUNCTION FROM oSF2S_6:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkMun
		DEFINE FUNCTION FROM oSF2S_6:Cell("D2_VALBRUT")   FUNCTION SUM BREAK oBrkMun
				
		DEFINE FUNCTION FROM oSF2S_6:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_6:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_6:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_6:Cell("D2_VALBRUT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		
	else	

		oSF2A_6:Enable()			

		DEFINE FUNCTION FROM oSF2A_6:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkMun
		DEFINE FUNCTION FROM oSF2A_6:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkMun
		DEFINE FUNCTION FROM oSF2A_6:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkMun
		DEFINE FUNCTION FROM oSF2A_6:Cell("D2_VALBRUT")   FUNCTION SUM BREAK oBrkMun
		
		DEFINE FUNCTION FROM oSF2A_6:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_6:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_6:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_6:Cell("D2_VALBRUT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		
	endif

	oSF2_6:Enable()	
	oSF2_6A:Enable()

//ORDEM 07 POR CLIENTE
elseif _nOrdem == 7

	oSF2FIL_7:Enable()

    //Define break para Filial para sumarizar campos
	DEFINE BREAK oBrkFil OF oSF2FIL_7 WHEN oSF2FIL_7:CELL("D2_FILIAL") TITLE {|| "SUBTOTAL FILIAL: " + cNomeFil}

	//Define funcoes de soma para secao
	if mv_par19 == 1 //SINTETICO ORDEM 07 - Cliente

		oSF2S_7:Enable() 

		DEFINE FUNCTION FROM oSF2S_7:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkRede
		DEFINE FUNCTION FROM oSF2S_7:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkRede
		DEFINE FUNCTION FROM oSF2S_7:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkRede
		DEFINE FUNCTION FROM oSF2S_7:Cell("D2_VALBRUT")   FUNCTION SUM BREAK oBrkRede		
		
		DEFINE FUNCTION FROM oSF2S_7:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_7:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_7:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_7:Cell("D2_VALBRUT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	

	else// ANALITICO ORDEM 07 - Cliente

		oSF2A_7:Enable()			

		DEFINE FUNCTION FROM oSF2A_7:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkRede
		DEFINE FUNCTION FROM oSF2A_7:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkRede
		DEFINE FUNCTION FROM oSF2A_7:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkRede
		DEFINE FUNCTION FROM oSF2A_7:Cell("D2_VALBRUT")   FUNCTION SUM BREAK oBrkRede		
		
		DEFINE FUNCTION FROM oSF2A_7:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_7:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_7:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_7:Cell("D2_VALBRUT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	

	endif	

	oSF2_7:Enable()	
	oSF2_7A:Enable()
	
elseif _nOrdem == 8  // ORDEM 08
	                   
	if mv_par19 == 2 //ANALITICO
	
		oSF2FIL_8:Enable()
		oSF2_8:Enable()
		oSF2A_8:Enable() 
	                             
		//Define break para Filial para sumarizar campos
		DEFINE BREAK oBrkFil OF oSF2FIL_8 WHEN oSF2FIL_8:CELL("D2_FILIAL") TITLE {|| "SUBTOTAL FILIAL: " + cNomeFil}   
		
		DEFINE FUNCTION FROM oSF2A_8:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkNF NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_8:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkNF NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_8:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkNF NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_8:Cell("D2_VALBRUT") FUNCTION SUM BREAK oBrkNF NO END SECTION NO END REPORT	
		
		DEFINE FUNCTION FROM oSF2A_8:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_8:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_8:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2A_8:Cell("D2_VALBRUT") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		    
	Else//ORDEM 08 - SINTETICO
	
		oSF2FIL_8:Enable()
		oSF2S_8:Enable() 
		
		DEFINE BREAK oBrkEmis OF oSF2S_8 WHEN oSF2S_8:CELL("F2_EMISSAO") TITLE {|| "Total do Dia: " }
		
		DEFINE FUNCTION FROM oSF2S_8:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkEmis NO END SECTION 
		DEFINE FUNCTION FROM oSF2S_8:Cell("D2_VALBRUT") FUNCTION SUM BREAK oBrkEmis NO END SECTION 
		
		//Define break para Filial para sumarizar campos
		DEFINE BREAK oBrkFil OF oSF2FIL_8 WHEN oSF2FIL_8:CELL("D2_FILIAL") TITLE {|| "SUBTOTAL FILIAL: " + cNomeFil}   
		
		DEFINE FUNCTION FROM oSF2S_8:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		DEFINE FUNCTION FROM oSF2S_8:Cell("D2_VALBRUT") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
	
	//--------------------------------------------------------------------
	// Alterar aqui os dados para troca nf.
	//--------------------------------------------------------------------
	 
	EndIf
	
elseif _nOrdem == 9

	oSF2FIL_9:Enable()
	oSF2_9:Enable()
	oSF2S_9:Enable()
	
    //Define break para Filial para sumarizar campos
	DEFINE BREAK oBrkFil OF oSF2FIL_9 WHEN oSF2FIL_9:CELL("D2_FILIAL") TITLE {|| "SUBTOTAL FILIAL: " + cNomeFil}

	//Define funcoes de soma para secao
	DEFINE FUNCTION FROM oSF2S_9:Cell("D2_QUANT")   FUNCTION SUM 
	DEFINE FUNCTION FROM oSF2S_9:Cell("D2_QTSEGUM") FUNCTION SUM 
	DEFINE FUNCTION FROM oSF2S_9:Cell("D2_TOTAL")   FUNCTION SUM 
	DEFINE FUNCTION FROM oSF2S_9:Cell("D2_VALBRUT") FUNCTION SUM 
		
	DEFINE FUNCTION FROM oSF2S_9:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
	DEFINE FUNCTION FROM oSF2S_9:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
	DEFINE FUNCTION FROM oSF2S_9:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
	DEFINE FUNCTION FROM oSF2S_9:Cell("D2_VALBRUT") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
		
//Ordem - Dia x Estado x Produto
elseif _nOrdem == 13 

	oSF2FIL_13:Enable()
	oSF2DT_13:Enable()
	oSF2_13:Enable()
	oSF2A_13:Enable()
	
    //Define break para Filial para sumarizar campos
	DEFINE BREAK oBrkFil OF oSF2FIL_13 WHEN oSF2FIL_13:CELL("D2_FILIAL") TITLE {|| "SUBTOTAL FILIAL: " + cNomeFil}       
	
	//Define break para Filial para dia de quebra
	DEFINE BREAK oBrkDtEmis OF oSF2DT_13 WHEN oSF2DT_13:CELL("QBRDATA") TITLE {|| "SUBTOTAL DO DIA: " + _cDia} 
	
	DEFINE FUNCTION FROM oSF2A_13:Cell("D2_QUANT")   FUNCTION SUM 
	DEFINE FUNCTION FROM oSF2A_13:Cell("D2_QTSEGUM") FUNCTION SUM 
	DEFINE FUNCTION FROM oSF2A_13:Cell("D2_TOTAL")   FUNCTION SUM 
	DEFINE FUNCTION FROM oSF2A_13:Cell("D2_VALBRUT") FUNCTION SUM 
	
	DEFINE FUNCTION FROM oSF2A_13:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
	DEFINE FUNCTION FROM oSF2A_13:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
	DEFINE FUNCTION FROM oSF2A_13:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT	
	DEFINE FUNCTION FROM oSF2A_13:Cell("D2_VALBRUT") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT 
	
	DEFINE FUNCTION FROM oSF2A_13:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkDtEmis NO END SECTION NO END REPORT	
	DEFINE FUNCTION FROM oSF2A_13:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkDtEmis NO END SECTION NO END REPORT	
	DEFINE FUNCTION FROM oSF2A_13:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkDtEmis NO END SECTION NO END REPORT	
	DEFINE FUNCTION FROM oSF2A_13:Cell("D2_VALBRUT") FUNCTION SUM BREAK oBrkDtEmis NO END SECTION NO END REPORT

endif

//************************************  QUERYS  *******************************************************************************

//Define query para ordem COORDENADOR
if _nOrdem == 1 //ORDEM 01

	//Verifica para ver se relatorio sintetico ou analitico, 1 = sintetico
	if mv_par19 == 1 //SINTETICO - ORDEM 01

		BEGIN REPORT QUERY oSF2FIL_1
	                               
		BeginSql alias "QRY1"   	   	
		   	SELECT 			
					SUM(T.D2_QUANT)   AS D2_QUANT,
					AVG(T.D2_PRCVEN)  AS D2_PRCVEN,
					SUM(T.D2_TOTAL)   AS D2_TOTAL,				
					SUM(T.D2_VALBRUT) AS D2_VALBRUT,								
					SUM(T.D2_QTSEGUM) AS D2_QTSEGUM,
					SUM(T.D2_COMIS1)  AS D2_COMIS1,  
					SUM(T.D2_I_FRET)  AS D2_I_FRET,				
					SUM(T.D2_CUSTO1)  AS D2_CUSTO1,
					SUM(T.D2_QTDEDEV) AS D2_QTDEDEV,
					SUM(T.D2_VALDEV)  AS D2_VALDEV,				
					SUM(T.D2_ICMSRET) AS D2_ICMSRET,				
				    SUM(T.VLRBRUTDEV) AS VLRBRUTDEV,
				    T.A3_NOMEC,T.A3_TIPOC,T.A3_TIPOV,
				    T.D2_UM,T.D2_SEGUM,T.B1_I_DESCD,T.B1_COD,T.F2_VEND1,T.F2_VEND2,T.F2_VEND3,
				    T.A3_COD,T.A3_NOME,T.D2_FILIAL, T.C5_ASSNOM,T.C5_I_LOCEM,T.C5_ASSCOD,
					T.C5_I_PEDDW, T.C5_I_EVENT, T.F2_I_DTRC
            FROM
		   	(	SELECT 		
				SUM(SD2.D2_QUANT)   AS D2_QUANT,
				AVG(SD2.D2_PRCVEN)  AS D2_PRCVEN,
				SUM(SD2.D2_TOTAL)   AS D2_TOTAL,
				SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,				
				SUM(SD2.D2_QTSEGUM) AS D2_QTSEGUM,
				SUM(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
				SUM(SD2.D2_I_FRET)  AS D2_I_FRET,
				SUM(SD2.D2_CUSTO1)  AS D2_CUSTO1,
				SUM(SD2.D2_ICMSRET) AS D2_ICMSRET,
				SA3C.A3_NOME AS A3_NOMEC,
				SA3C.A3_TIPO AS A3_TIPOC,
				SA3.A3_TIPO AS A3_TIPOV,
				SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SF2.F2_VEND1,SF2.F2_VEND2,SF2.F2_VEND3,
				SA3.A3_COD,SA3.A3_NOME,SD2.D2_FILIAL, SC5.C5_ASSNOM,SC5.C5_I_LOCEM,SC5.C5_ASSCOD,SC5.C5_I_PEDDW, SC5.C5_I_EVENT,SF2.F2_I_DTRC, 
				SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_COD,
				(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			       FROM SD1010 D1
				   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			       WHERE D1.D_E_L_E_T_ = ' '
			         AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			         AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			         AND D1.D1_NFORI   = SD2.D2_DOC
			         AND D1.D1_SERIORI = SD2.D2_SERIE
			         AND D1.D1_FORNECE = SD2.D2_CLIENTE
			         AND D1.D1_LOJA    = SD2.D2_LOJA    
			         AND D1.D1_COD     = SD2.D2_COD 
				   ) AS D2_QTDEDEV,///*************************** D2_QTDEDEV
				(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			       FROM SD1010 D1
				   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			       WHERE D1.D_E_L_E_T_ = ' '
			         AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			         AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			         AND D1.D1_NFORI   = SD2.D2_DOC
			         AND D1.D1_SERIORI = SD2.D2_SERIE
			         AND D1.D1_FORNECE = SD2.D2_CLIENTE
			         AND D1.D1_LOJA    = SD2.D2_LOJA    
			         AND D1.D1_COD     = SD2.D2_COD
		           ) AS D2_VALDEV ,///*************************** D2_VALDEV
				(SUM(SD2.D2_VALBRUT)  -
				(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			       FROM SD1010 D1
				   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			       WHERE D1.D_E_L_E_T_ = ' '
			         AND D1.D1_TIPO    = 'D'// AND D1_TES        <> ' ' "
			         AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			         AND D1.D1_NFORI   = SD2.D2_DOC
			         AND D1.D1_SERIORI = SD2.D2_SERIE
			         AND D1.D1_FORNECE = SD2.D2_CLIENTE
			         AND D1.D1_LOJA    = SD2.D2_LOJA    
			         AND D1.D1_COD     = SD2.D2_COD
		        )) AS VLRBRUTDEV ///*************************** VLRBRUTDEV
			FROM 
				%table:SF2% SF2
				JOIN %table:SD2% SD2  ON SD2.D2_FILIAL  = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE 
				JOIN %table:SA1% SA1  ON SA1.A1_FILIAL  = ' ' AND SA1.A1_COD   = SD2.D2_CLIENTE  AND SD2.D2_LOJA = SA1.A1_LOJA
				JOIN %table:SB1% SB1  ON SB1.B1_FILIAL  = ' ' AND SB1.B1_COD   = SD2.D2_COD 
				JOIN %table:SA3% SA3  ON SA3.A3_FILIAL  = ' ' AND SA3.A3_COD   = SF2.F2_VEND1 
				JOIN %table:SA3% SA3C ON SA3C.A3_FILIAL = ' ' AND SA3C.A3_COD  = SF2.F2_VEND2 
				JOIN %table:SBM% SBM  ON SBM.BM_FILIAL  = ' ' AND SBM.BM_GRUPO = SB1.B1_GRUPO 
				JOIN %table:ACY% ACY  ON ACY.ACY_FILIAL = ' ' AND ACY.ACY_GRPVEN = SA1.A1_GRPVEN  
				JOIN %table:SF4% SF4  ON SF4.F4_FILIAL  = SD2.D2_FILIAL AND SF4.F4_CODIGO = SD2.D2_TES
				JOIN %table:SC5% SC5  ON SC5.C5_FILIAL  = SF2.F2_FILIAL AND SC5.C5_NUM    = SF2.F2_I_PEDID
				LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
			WHERE 
				SF2.%notDel%  
				AND SD2.%notDel%  
				AND SA1.%notDel%  		
				AND SB1.%notDel%  					
				AND SA3.%notDel%  											
				AND SBM.%notDel%				
				AND ACY.%notDel%
				AND SF4.%notDel%
				AND SC5.%notDel%
			    %exp:_cfiltro%
			 GROUP BY 
				SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SF2.F2_VEND1,SF2.F2_VEND2,SF2.F2_VEND3,SA3.A3_COD,SA3.A3_NOME,
				SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_COD,SC5.C5_ASSNOM,SC5.C5_I_LOCEM,
				SC5.C5_ASSCOD,SC5.C5_I_PEDDW,SC5.C5_I_EVENT,SA3C.A3_NOME,SA3C.A3_TIPO,SA3.A3_TIPO, SF2.F2_I_DTRC
             ) T
			 GROUP BY 
				D2_UM,D2_SEGUM,B1_I_DESCD,B1_COD,F2_VEND1,F2_VEND2,F2_VEND3,A3_COD,A3_NOME,D2_FILIAL, C5_ASSNOM,C5_I_LOCEM, 
				C5_ASSCOD,C5_I_PEDDW,C5_I_EVENT,A3_NOMEC,A3_TIPOC,A3_TIPOV, F2_I_DTRC
			ORDER BY 
				D2_FILIAL,F2_VEND2,F2_VEND1,D2_QUANT DESC		
		EndSql
		 
		END REPORT QUERY oSF2FIL_1
		
	else //ANALITICO - ORDEM 01
	
		BEGIN REPORT QUERY oSF2FIL_1
		
		BeginSql alias "QRY1"   	   	
	   		SELECT 
				SF2.F2_DOC,SF2.F2_SERIE,SD2.D2_ITEM,SF2.F2_EMISSAO,SF2.F2_I_NTRIA, SF2.F2_I_STRIA,SF2.F2_I_DTRIA,
				SD2.D2_CLIENTE,SD2.D2_LOJA,SC5.R_E_C_N_O_ SC5RECNO,SA1.A1_I_CLABC,
				SA1.A1_NREDUZ, SD2.D2_COD,SD2.D2_SERIE, SD2.D2_QUANT,SD2.D2_PRCVEN,SD2.D2_TOTAL,SD2.D2_UM,SD2.D2_VALBRUT,
				SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SF2.F2_VEND1,SF2.F2_VEND2,SF2.F2_VEND3,SD2.D2_QTSEGUM,
				SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_PEDIDO,SA3.A3_NOME,SA3.A3_COD,SD2.D2_I_FRET,
				(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
				SD2.D2_CUSTO1,SD2.D2_FILIAL,SD2.D2_ICMSRET, SC5.C5_I_TRCNF,	SC5.C5_I_FILFT, SC5.C5_I_FLFNC,
				DAI.DAI_I_OPLO, SC5.C5_NUM, SD2.D2_LOCAL, SC5.C5_ASSNOM,SC5.C5_I_LOCEM,SC5.C5_ASSCOD, SC5.C5_I_PEDDW,
				SC5.C5_I_OPER,SC5.C5_I_OPTRI,SC5.C5_I_PVREM,SC5.C5_I_PVFAT,	SC5.C5_I_CLIEN, SC5.C5_I_LOJEN, SC5.C5_I_EVENT, SC5.C5_I_QTDA,
				SA1R.A1_NOME   AS NOME_CLIREM,
				SA1R.A1_NREDUZ AS FANTASIA_CLIREM,
			    SA3C.A3_NOME   AS A3_NOMEC,
				SA3C.A3_TIPO   AS A3_TIPOC,
				SA3.A3_TIPO    AS A3_TIPOV,
				CC2.CC2_EST   ,
			    CC2.CC2_I_MESO,
                CC2.CC2_I_MICR, SF2.F2_I_DTRC,
				(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			       FROM SD1010 D1
				   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			       WHERE D1.D_E_L_E_T_ = ' '
			         AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			         AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			         AND D1.D1_NFORI   = SD2.D2_DOC
			         AND D1.D1_SERIORI = SD2.D2_SERIE
			         AND D1.D1_FORNECE = SD2.D2_CLIENTE
			         AND D1.D1_LOJA    = SD2.D2_LOJA    
			         AND D1.D1_COD     = SD2.D2_COD 
				   ) AS D2_QTDEDEV,///*************************** D2_QTDEDEV
				(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			       FROM SD1010 D1
				   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			       WHERE D1.D_E_L_E_T_ = ' '
			         AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			         AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			         AND D1.D1_NFORI   = SD2.D2_DOC
			         AND D1.D1_SERIORI = SD2.D2_SERIE
			         AND D1.D1_FORNECE = SD2.D2_CLIENTE
			         AND D1.D1_LOJA    = SD2.D2_LOJA    
			         AND D1.D1_COD     = SD2.D2_COD
		           ) AS D2_VALDEV ,///*************************** D2_VALDEV
				(SD2.D2_VALBRUT  -
				(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			       FROM SD1010 D1
				   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			       WHERE D1.D_E_L_E_T_ = ' '
			         AND D1.D1_TIPO    = 'D'// AND D1_TES        <> ' ' "
			         AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			         AND D1.D1_NFORI   = SD2.D2_DOC
			         AND D1.D1_SERIORI = SD2.D2_SERIE
			         AND D1.D1_FORNECE = SD2.D2_CLIENTE
			         AND D1.D1_LOJA    = SD2.D2_LOJA    
			         AND D1.D1_COD     = SD2.D2_COD
		        )) AS VLRBRUTDEV ///*************************** VLRBRUTDEV

			FROM %table:SF2% SF2
				JOIN %table:SD2% SD2  ON SD2.D2_FILIAL  = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE
			    JOIN %table:SA1% SA1  ON SA1.A1_FILIAL  = ' ' AND SA1.A1_COD   = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA 
				JOIN %table:SB1% SB1  ON SB1.B1_FILIAL  = ' ' AND SB1.B1_COD   = SD2.D2_COD 
				JOIN %table:SA3% SA3  ON SA3.A3_FILIAL  = ' ' AND SA3.A3_COD   = SF2.F2_VEND1 
				JOIN %table:SA3% SA3C ON SA3C.A3_FILIAL = ' ' AND SA3C.A3_COD  = SF2.F2_VEND2 
				JOIN %table:SBM% SBM  ON SBM.BM_FILIAL  = ' ' AND SBM.BM_GRUPO = SB1.B1_GRUPO 
				JOIN %table:ACY% ACY  ON ACY.ACY_FILIAL = ' ' AND ACY.ACY_GRPVEN  = SA1.A1_GRPVEN
				JOIN %table:SF4% SF4  ON SF4.f4_filial  = SD2.d2_filial AND SF4.F4_CODIGO = SD2.D2_TES
				JOIN %table:SC5% SC5  ON SC5.C5_FILIAL  = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
				LEFT JOIN %table:DAI% DAI  ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
				LEFT JOIN %table:SA1% SA1R ON SA1R.A1_FILIAL = ' ' AND SA1R.A1_COD = SC5.C5_I_CLIEN AND SA1R.A1_LOJA   = SC5.C5_I_LOJEN AND SA1R.%notDel% 								
			    LEFT JOIN %table:CC2% CC2  ON CC2.CC2_FILIAL = ' ' AND CC2.CC2_EST = SA1.A1_EST     AND CC2.CC2_CODMUN = SA1.A1_COD_MUN AND CC2.%notDel%
			WHERE 
				SF2.%notDel%  
				AND SD2.%notDel%  
				AND SA1.%notDel%  
				AND SB1.%notDel%  					
				AND SA3.%notDel%  											
				AND SBM.%notDel%				
				AND ACY.%notDel%
				AND SF4.%notDel%
				AND SC5.%notDel%
			    %exp:_cfiltro% 
			ORDER BY 
				SD2.D2_FILIAL,SF2.F2_VEND2,SF2.F2_VEND1,SD2.D2_CLIENTE,SA3.A3_NOME,SA3.A3_COD
		EndSql
		
		END REPORT QUERY oSF2FIL_1
		
	endif
	
elseif _nOrdem == 3  //ORDEM 03  - Produto       
	//Define query para o relatorio  ordem produtos
	
	//verifica se relatorio vai ser analitico ou SINTETICO
	
	if MV_PAR19 == 1 //1 == SINTETICO - ORDEM 03
	
		oSF2S_3:Enable()
		
		BEGIN REPORT QUERY oSF2FIL_3
		
			BeginSql alias "QRY3"  //1 == SINTETICO  - ORDEM 3  - Produto   
			
		   	SELECT 			
					SUM(T.D2_QUANT)   AS D2_QUANT,
					AVG(T.D2_PRCVEN)  AS D2_PRCVEN,
					SUM(T.D2_TOTAL)   AS D2_TOTAL,				
					SUM(T.D2_VALBRUT) AS D2_VALBRUT,								
					SUM(T.D2_QTSEGUM) AS D2_QTSEGUM,
					SUM(T.D2_COMIS1)  AS D2_COMIS1,  
					SUM(T.D2_I_FRET)  AS D2_I_FRET,				
					SUM(T.D2_CUSTO1)  AS D2_CUSTO1,
					SUM(T.D2_ICMSRET) AS D2_ICMSRET,				
					SUM(T.D2_QTDEDEV) AS D2_QTDEDEV,
					SUM(T.D2_VALDEV)  AS D2_VALDEV,				
				    SUM(T.VLRBRUTDEV) AS VLRBRUTDEV,
					T.D2_UM,
					T.D2_SEGUM,
					T.B1_I_DESCD,
					T.B1_COD,
					T.D2_COD,
					T.C5_I_LOCEM,
					T.D2_FILIAL
            FROM
		   	(	SELECT 			
					SUM(SD2.D2_QUANT)   AS D2_QUANT,
					AVG(SD2.D2_PRCVEN)  AS D2_PRCVEN,
					SUM(SD2.D2_TOTAL)   AS D2_TOTAL,				
					SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,								
					SUM(SD2.D2_QTSEGUM) AS D2_QTSEGUM,
					SUM(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
					SUM(SD2.D2_I_FRET)  AS D2_I_FRET,
					SUM(SD2.D2_CUSTO1)  AS D2_CUSTO1,
					SUM(SD2.D2_ICMSRET) AS D2_ICMSRET,				
					SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SD2.D2_COD,SD2.D2_FILIAL,
					SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SC5.C5_I_LOCEM,
					(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD 
					   ) AS D2_QTDEDEV,///*************************** D2_QTDEDEV
					(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		               ) AS D2_VALDEV ,///*************************** D2_VALDEV
					(SUM(SD2.D2_VALBRUT)  -
					(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO    = 'D'// AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		            )) AS VLRBRUTDEV ///*************************** VLRBRUTDEV

			     FROM 
					%table:SF2% SF2
					JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
					JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
					JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
					JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
					JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
					JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
					JOIN %table:SF4% SF4 ON SD2.D2_FILIAL = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo
					JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
     				LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
			     WHERE 
					SF2.%notDel%  
					AND SD2.%notDel%  
					AND SA1.%notDel%  		
					AND SB1.%notDel%  					
					AND SA3.%notDel%  											
					AND SBM.%notDel%				
					AND ACY.%notDel%
					AND SF4.%notDel%
					AND SC5.%notDel%
			    	%exp:_cfiltro% 

				 GROUP BY 
	 				SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SD2.D2_COD,SD2.D2_FILIAL,
					SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SC5.C5_I_LOCEM,SD2.D2_LOJA
					
					) T

				 GROUP BY 
	 				D2_UM,D2_SEGUM,B1_I_DESCD,B1_COD,D2_COD,D2_FILIAL,C5_I_LOCEM
				ORDER BY 
					D2_FILIAL,D2_COD
			EndSql
			
		END REPORT QUERY oSF2FIL_3
		
	ELSE // ANALITICO  - ORDEM 03  - PRODUTO   ************************************************************
	
		oSF2A_3:Enable()	

		
		BEGIN REPORT QUERY oSF2FIL_3
		
			BeginSql alias "QRY3"   	   	
		   		SELECT 
					SF2.F2_DOC,SF2.F2_SERIE,SD2.D2_ITEM,SF2.F2_EMISSAO, SD2.D2_CLIENTE,SD2.D2_LOJA,
					SA1.A1_NREDUZ, SD2.D2_QUANT,SD2.D2_PRCVEN,SD2.D2_TOTAL,SD2.D2_UM,
					SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SF2.F2_VEND1,SA3.A3_SUPER,SA3.A3_COD,
					SA3.A3_NOME,ACY.ACY_DESCRI,ACY.ACY_GRPVEN,SD2.D2_COD,
					SD2.D2_QTSEGUM,
					SD2.D2_FILIAL,
					SD2.D2_DOC,SD2.D2_I_FRET,
					(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
					SD2.D2_PEDIDO,SF2.F2_EMISSAO,
					SD2.D2_CUSTO1,
					SD2.D2_FILIAL,SD2.D2_VALBRUT,SD2.D2_ICMSRET, SC5.C5_I_TRCNF, SC5.C5_I_FILFT, SC5.C5_I_FLFNC,
					SD2.D2_LOCAL,SC5.C5_I_LOCEM,SC5.C5_I_QTDA,
					(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD 
					   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
					(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		               ) AS D2_VALDEV, ///*************************** D2_VALDEV
					(SD2.D2_VALBRUT  -
					(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		            )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV
				FROM 
					%table:SF2% SF2
					JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
					JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
					JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
					JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
					JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
					JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
					JOIN %table:SF4% SF4 ON sd2.d2_filial = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo  
					JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
     				LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
				WHERE 
					SF2.%notDel%  
					AND SD2.%notDel%  
					AND SA1.%notDel%  		
					AND SB1.%notDel%  					
					AND SA3.%notDel%  											
					AND SBM.%notDel%				
					AND ACY.%notDel%
					AND SF4.%notDel%   
					AND SC5.%notDel%
				    %exp:_cfiltro%
				ORDER BY 
					SD2.D2_FILIAL,SD2.D2_COD,SF2.F2_EMISSAO,SD2.D2_CLIENTE
			EndSql
			
		END REPORT QUERY oSF2FIL_3
		
	endif

elseif _nOrdem == 4//SINTETICO

	//Define query para o relatorio - ORDEM 04 REDE
	if mv_par19 == 1 //SINTETICO
		oSF2S_4:Enable()	
		BEGIN REPORT QUERY oSF2FIL_4
			BeginSql alias "QRY4"   	   	
		SELECT 			
				SUM(T.D2_QUANT)   AS D2_QUANT,
				AVG(T.D2_PRCVEN)  AS D2_PRCVEN,
				SUM(T.D2_QTSEGUM) AS D2_QTSEGUM,
				SUM(T.D2_TOTAL)   AS D2_TOTAL,				
				SUM(T.D2_VALBRUT) AS D2_VALBRUT,								
				SUM(T.D2_COMIS1)  AS D2_COMIS1,  
				SUM(T.D2_I_FRET)  AS D2_I_FRET,				
				SUM(T.D2_CUSTO1)  AS D2_CUSTO1,
				SUM(T.D2_QTDEDEV) AS D2_QTDEDEV,
				SUM(T.D2_VALDEV)  AS D2_VALDEV,				
				SUM(T.D2_ICMSRET) AS D2_ICMSRET,				
			    SUM(T.VLRBRUTDEV) AS VLRBRUTDEV,
				T.D2_UM,T.D2_SEGUM,T.ACY_DESCRI,T.ACY_GRPVEN,T.A1_GRPVEN,T.D2_COD,
				T.B1_I_DESCD,T.D2_FILIAL, T.DAI_I_OPLO,T.C5_I_LOCEM
        FROM
		(SELECT 			
					SUM(SD2.D2_QUANT)   AS D2_QUANT,
					AVG(SD2.D2_PRCVEN)  AS D2_PRCVEN,
					SUM(SD2.D2_QTSEGUM) AS D2_QTSEGUM,
					SUM(SD2.D2_TOTAL)   AS D2_TOTAL,
					SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,
					SUM(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
					SUM(SD2.D2_I_FRET)  AS D2_I_FRET,
					SUM(SD2.D2_CUSTO1)  AS D2_CUSTO1,
					SUM(SD2.D2_ICMSRET) AS D2_ICMSRET,				
					SD2.D2_UM,SD2.D2_SEGUM,ACY.ACY_DESCRI,ACY.ACY_GRPVEN,SA1.A1_GRPVEN,
					SD2.D2_COD,SB1.B1_I_DESCD,SD2.D2_FILIAL, DAI.DAI_I_OPLO,
					SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SC5.C5_I_LOCEM,
					(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD 
					   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
					(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		               ) AS D2_VALDEV, ///*************************** D2_VALDEV
					(SUM(SD2.D2_VALBRUT) -
					(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		            )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV
				FROM 
					%table:SF2% SF2
					JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
					JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
					JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
					JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
					JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
					JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN				
					JOIN %table:SF4% SF4 ON sd2.d2_filial = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo
					JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
					LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%

				WHERE 
					SF2.%notDel%  
					AND SD2.%notDel%  
					AND SA1.%notDel%  		
					AND SB1.%notDel%  					
					AND SA3.%notDel%  											
					AND SBM.%notDel%				
					AND ACY.%notDel%
					AND SF4.%notDel%
					AND SC5.%notDel%
				    %exp:_cfiltro%
				 GROUP BY 		 		    
					SD2.D2_UM,SD2.D2_SEGUM,ACY.ACY_DESCRI,ACY.ACY_GRPVEN,SA1.A1_GRPVEN,SD2.D2_COD,
					SB1.B1_I_DESCD,SD2.D2_FILIAL, DAI.DAI_I_OPLO,
					SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SC5.C5_I_LOCEM
        ) T
				 GROUP BY 		 		    
					D2_UM,D2_SEGUM,ACY_DESCRI,ACY_GRPVEN,A1_GRPVEN,D2_COD,
					B1_I_DESCD,D2_FILIAL, DAI_I_OPLO , C5_I_LOCEM
				ORDER BY 
					D2_FILIAL,ACY_GRPVEN,D2_COD
			EndSql
		END REPORT QUERY oSF2FIL_4
		
	else // ANALITICO ORDEM 04
	
		oSF2A_4:Enable()	
		BEGIN REPORT QUERY oSF2FIL_4
			BeginSql alias "QRY4"   	   	
		   		SELECT 			
					SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_EMISSAO, SD2.D2_CLIENTE,SD2.D2_LOJA,
					SA1.A1_NREDUZ, SD2.D2_QUANT,SD2.D2_PRCVEN,SD2.D2_TOTAL,SD2.D2_UM,SD2.D2_QTSEGUM,SD2.D2_VALBRUT,
					SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SF2.F2_VEND1,ACY.ACY_DESCRI,
					SA1.A1_GRPVEN,SD2.D2_COD,SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_ITEM,SD2.D2_I_FRET,
					(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
					SD2.D2_CUSTO1,SD2.D2_FILIAL,SD2.D2_ICMSRET,SC5.C5_I_TRCNF, SC5.C5_I_FILFT, 
					SC5.C5_I_FLFNC,DAI.DAI_I_OPLO,SD2.D2_LOCAL, SC5.C5_I_LOCEM , SC5.C5_I_QTDA,
					(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD 
					   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
					(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		               ) AS D2_VALDEV, ///*************************** D2_VALDEV
					(SD2.D2_VALBRUT  -
					(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		            )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV
					FROM 
					%table:SF2% SF2
					JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
					JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
					JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
					JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
					JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
					JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
					JOIN %table:SF4% SF4 ON sd2.d2_filial = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo  
					JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
					LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
				WHERE 			
					SF2.%notDel%  
					AND SD2.%notDel%  
					AND SA1.%notDel%  		
					AND SB1.%notDel%  					
					AND SA3.%notDel%  											
					AND SBM.%notDel%				
					AND ACY.%notDel%
					AND SF4.%notDel%
					AND SC5.%notDel%
				    %exp:_cfiltro%
				ORDER BY 
			  		SD2.D2_FILIAL,SA1.A1_GRPVEN,SD2.D2_DOC,SD2.D2_ITEM
		EndSql
		END REPORT QUERY oSF2FIL_4
		
	endif

elseif _nOrdem == 5//ORDEM 05 Estado X Produto

	if mv_par19 == 1//SINTETICA // ORDEM 05 - Estado x Produto  
		oSF2S_5:Enable()				
		BEGIN REPORT QUERY oSF2FIL_5
			BeginSql alias "QRY5"   	   	

		   	SELECT 			
					SUM(T.D2_QUANT)   AS D2_QUANT,
					AVG(T.D2_PRCVEN)  AS D2_PRCVEN,
					SUM(T.D2_TOTAL)   AS D2_TOTAL,				
					SUM(T.D2_VALBRUT) AS D2_VALBRUT,								
					SUM(T.D2_QTSEGUM) AS D2_QTSEGUM,
					SUM(T.D2_COMIS1)  AS D2_COMIS1,  
					SUM(T.D2_I_FRET)  AS D2_I_FRET,				
					SUM(T.D2_CUSTO1)  AS D2_CUSTO1,
					SUM(T.D2_QTDEDEV) AS D2_QTDEDEV,
					SUM(T.D2_VALDEV)  AS D2_VALDEV,				
					SUM(T.D2_ICMSRET) AS D2_ICMSRET,				
				    SUM(T.VLRBRUTDEV) AS VLRBRUTDEV,
					T.D2_UM,T.D2_SEGUM,T.B1_I_DESCD,T.B1_COD,
					T.D2_COD,T.D2_EST,T.D2_FILIAL,T.C5_I_LOCEM
            FROM
		   	(	SELECT 			
					SUM(SD2.D2_QUANT)   AS D2_QUANT,
					AVG(SD2.D2_PRCVEN)  AS D2_PRCVEN,
					SUM(SD2.D2_TOTAL)   AS D2_TOTAL,				
					SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,								
					SUM(SD2.D2_QTSEGUM) AS D2_QTSEGUM,
					SUM(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
					SUM(SD2.D2_I_FRET)  AS D2_I_FRET,				
					SUM(SD2.D2_CUSTO1)  AS D2_CUSTO1,
					SUM(SD2.D2_ICMSRET) AS D2_ICMSRET,				
					SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SC5.C5_I_LOCEM,
					SD2.D2_COD,SD2.D2_EST,SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,
					(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD 
					   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
					(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		               ) AS D2_VALDEV, ///*************************** D2_VALDEV
					(SUM(SD2.D2_VALBRUT)  -
					(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		            )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV
				FROM 
					%table:SF2% SF2
					JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
					JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
					JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
					JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
					JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
					JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
					JOIN %table:SF4% SF4 ON sd2.d2_filial = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo
					JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
    				LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%

				WHERE 
					SF2.%notDel%  
					AND SD2.%notDel%  
					AND SA1.%notDel%  		
					AND SB1.%notDel%  					
					AND SA3.%notDel%  											
					AND SBM.%notDel%				
					AND ACY.%notDel%
					AND SF4.%notDel%
					AND SC5.%notDel%
			    	%exp:_cfiltro%

				 GROUP BY 
	 				SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,C5_I_LOCEM,
					SD2.D2_COD,SD2.D2_EST,SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA 
			) T

				 GROUP BY 
	 				T.D2_UM,T.D2_SEGUM,T.B1_I_DESCD,T.B1_COD,
					T.D2_COD,T.D2_EST,T.D2_FILIAL,T.C5_I_LOCEM
				ORDER BY 
					T.D2_FILIAL,T.D2_EST,T.D2_COD
			EndSql
		END REPORT QUERY oSF2FIL_5
	Else//ANALITICO ORDEM 05 Estado X Produto
		oSF2A_5:Enable()	
		BEGIN REPORT QUERY oSF2FIL_5
			BeginSql alias "QRY5"   	   	
		   		SELECT 
					SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_EMISSAO, SD2.D2_ITEM,SF2.F2_EMISSAO, SD2.D2_CLIENTE,SD2.D2_LOJA,
					SA1.A1_NREDUZ, SA1.A1_MUN,SD2.D2_QUANT,SD2.D2_PRCVEN,SD2.D2_TOTAL,SD2.D2_UM,SD2.D2_VALBRUT,
					SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SF2.F2_VEND1,SD2.D2_CF,
					SD2.D2_EST,SD2.D2_COD,SD2.D2_QTSEGUM,SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_I_FRET,
					(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
					SD2.D2_CUSTO1,SD2.D2_FILIAL,SD2.D2_ICMSRET, SC5.C5_I_TRCNF, SC5.C5_I_FILFT, SC5.C5_I_FLFNC,
                    SD2.D2_LOCAL,SC5.C5_I_LOCEM,SC5.C5_I_QTDA,
					(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD 
					   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
					(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		               ) AS D2_VALDEV, ///*************************** D2_VALDEV
					(SD2.D2_VALBRUT  -
					(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		            )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV
				FROM 
					%table:SF2% SF2
					JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
					JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
					JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
					JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
					JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
					JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
					JOIN %table:SF4% SF4 ON sd2.d2_filial = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo
					JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
     				LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
					
				WHERE 
					SF2.%notDel%  
					AND SD2.%notDel%  
					AND SA1.%notDel%  		
					AND SB1.%notDel%  					
					AND SA3.%notDel%  											
					AND SBM.%notDel%				
					AND ACY.%notDel%
					AND SF4.%notDel%
					AND SC5.%notDel%
				    %exp:_cfiltro%
				ORDER BY 
					SD2.D2_FILIAL,SD2.D2_EST,SD2.D2_COD
			EndSql
		END REPORT QUERY oSF2FIL_5
	endif

elseif _nOrdem == 6//ORDEM 06 - Municipio

	if mv_par19 == 1//SINTETICO
	
		oSF2S_6:Enable()				
		
		BEGIN REPORT QUERY oSF2FIL_6
			BeginSql alias "QRY6"   	   	
		SELECT 			
				SUM(T.D2_QUANT)   AS D2_QUANT,
				AVG(T.D2_PRCVEN)  AS D2_PRCVEN,
				SUM(T.D2_TOTAL)   AS D2_TOTAL,				
				SUM(T.D2_VALBRUT) AS D2_VALBRUT,								
				SUM(T.D2_QTSEGUM) AS D2_QTSEGUM,
				SUM(T.D2_COMIS1)  AS D2_COMIS1,  
				SUM(T.D2_I_FRET)  AS D2_I_FRET,				
				SUM(T.D2_CUSTO1)  AS D2_CUSTO1,
				SUM(T.D2_QTDEDEV) AS D2_QTDEDEV,
				SUM(T.D2_VALDEV)  AS D2_VALDEV,				
				SUM(T.D2_ICMSRET) AS D2_ICMSRET,				
			    SUM(T.VLRBRUTDEV) AS VLRBRUTDEV,
				T.D2_UM,T.D2_SEGUM,T.B1_I_DESCD,T.B1_COD,
				T.A1_EST,T.D2_FILIAL, T.DAI_I_OPLO,T.C5_I_LOCEM,
				T.D2_COD,T.A1_COD_MUN,T.A1_MUN,T.A3_COD,T.A3_NOME,T.F2_VEND1
        FROM
		(SELECT 			
					SUM(SD2.D2_QUANT)   AS D2_QUANT,
					AVG(SD2.D2_PRCVEN)  AS D2_PRCVEN,
					SUM(SD2.D2_TOTAL)   AS D2_TOTAL,				
					SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,								
					SUM(SD2.D2_QTSEGUM) AS D2_QTSEGUM,
					SUM(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
					SUM(SD2.D2_I_FRET)  AS D2_I_FRET,
					SUM(SD2.D2_CUSTO1)  AS D2_CUSTO1,
					SUM(SD2.D2_ICMSRET) AS D2_ICMSRET,				
					SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SC5.C5_I_LOCEM,
					SD2.D2_COD,SA1.A1_COD_MUN,SA1.A1_MUN,SA3.A3_COD,SA3.A3_NOME,SF2.F2_VEND1,SD2.D2_FILIAL,
					SA1.A1_EST, DAI.DAI_I_OPLO,
					(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD 
					   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
					(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		               ) AS D2_VALDEV, ///*************************** D2_VALDEV
					(SUM(SD2.D2_VALBRUT)  -
					(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		            )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV
				FROM 
					%table:SF2% SF2
					JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
					JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
					JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
					JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
					JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
					JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
					JOIN %table:SF4% SF4 ON sd2.d2_filial = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo
					JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
					LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%

				WHERE 
					SF2.%notDel%  
					AND SD2.%notDel%  
					AND SA1.%notDel%  		
					AND SB1.%notDel%  					
					AND SA3.%notDel%  											
					AND SBM.%notDel%				
					AND ACY.%notDel%        
					AND SF4.%notDel%
					AND SC5.%notDel%
			    	%exp:_cfiltro%
				 GROUP BY 
	 				SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SC5.C5_I_LOCEM,
					SD2.D2_COD,SA1.A1_MUN,SA1.A1_COD_MUN,SA3.A3_COD,SA3.A3_NOME,SF2.F2_VEND1,SD2.D2_FILIAL,SA1.A1_EST, DAI.DAI_I_OPLO,
					SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA    
		) T
				 GROUP BY 
	 				D2_UM,D2_SEGUM,B1_I_DESCD,B1_COD,C5_I_LOCEM,
					D2_COD,A1_MUN,A1_COD_MUN,A3_COD,A3_NOME,F2_VEND1,D2_FILIAL,A1_EST, DAI_I_OPLO
				ORDER BY 
					D2_FILIAL,A1_MUN,F2_VEND1,D2_COD
			EndSql
		END REPORT QUERY oSF2FIL_6
		
	else//ANALITICO ORDEM 06 - Municipio
	
		oSF2A_6:Enable()	
	
		BEGIN REPORT QUERY oSF2FIL_6
			BeginSql alias "QRY6"   	   	
		   		SELECT  
					SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_EMISSAO,SD2.D2_ITEM,SF2.F2_EMISSAO, SD2.D2_CLIENTE,SD2.D2_LOJA,
					SA1.A1_NREDUZ, SD2.D2_QUANT,SD2.D2_PRCVEN,SD2.D2_TOTAL,SD2.D2_UM,SD2.D2_VALBRUT,
					SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SF2.F2_VEND1,
					SA1.A1_MUN,SD2.D2_COD,SD2.D2_QTSEGUM,SD2.D2_FILIAL,SD2.D2_DOC,
					SA1.A1_COD_MUN,SA3.A3_COD,SA3.A3_NOME,SD2.D2_I_FRET,
					(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
					SD2.D2_CUSTO1,SD2.D2_FILIAL,SA1.A1_EST,SD2.D2_ICMSRET, SC5.C5_I_TRCNF, 
					SC5.C5_I_FILFT, SC5.C5_I_FLFNC,DAI_I_OPLO,SD2.D2_LOCAL,SC5.C5_I_LOCEM,SC5.C5_I_QTDA,
					(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD 
					   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
					(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		               ) AS D2_VALDEV, ///*************************** D2_VALDEV
					(SD2.D2_VALBRUT  -
					(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		            )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV

				FROM 
					%table:SF2% SF2
					JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
					JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
					JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
					JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
					JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
					JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
					JOIN %table:SF4% SF4 ON sd2.d2_filial = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo  
					JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
					LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
				WHERE 
					SF2.%notDel%  
					AND SD2.%notDel%  
					AND SA1.%notDel%  		
					AND SB1.%notDel%  					
					AND SA3.%notDel%  											
					AND SBM.%notDel%				
					AND ACY.%notDel%     
					AND SF4.%notDel%     
					AND SC5.%notDel%
				    %exp:_cfiltro%
				ORDER BY 
					SD2.D2_FILIAL,SA1.A1_MUN,SB1.B1_COD
			EndSql
		END REPORT QUERY oSF2FIL_6
		
	endif
	
elseif _nOrdem == 7 //ORDEM 07 - Cliente

	if mv_par19 == 1//SINTETICO
	
		oSF2S_7:Enable()				
		
		BEGIN REPORT QUERY oSF2FIL_7 //SINTETICO - Cliente
			BeginSql alias "QRY7"   	   	
		    SELECT 			
		    		SUM(T.D2_QUANT)   AS D2_QUANT,
		    		AVG(T.D2_PRCVEN)  AS D2_PRCVEN,
		    		SUM(T.D2_TOTAL)   AS D2_TOTAL,				
		    		SUM(T.D2_VALBRUT) AS D2_VALBRUT,								
		    		SUM(T.D2_QTSEGUM) AS D2_QTSEGUM,
		    		SUM(T.D2_COMIS1)  AS D2_COMIS1,  
		    		SUM(T.D2_I_FRET)  AS D2_I_FRET,				
		    		SUM(T.D2_CUSTO1)  AS D2_CUSTO1,
		    		SUM(T.D2_QTDEDEV) AS D2_QTDEDEV,
		    		SUM(T.D2_VALDEV)  AS D2_VALDEV,				
		    		SUM(T.D2_ICMSRET) AS D2_ICMSRET,				
		    	    SUM(T.VLRBRUTDEV) AS VLRBRUTDEV,
					T.D2_UM,T.D2_SEGUM,T.B1_I_DESCD,T.B1_COD,T.C5_I_LOCEM,
					T.D2_COD,T.A1_COD_MUN,T.A1_MUN,T.A3_COD,T.A3_NOME,T.F2_VEND1,
					T.A1_COD,T.A1_NREDUZ,T.A1_GRPVEN,T.ACY_DESCRI,T.A1_LOJA,T.D2_FILIAL,
					T.A1_NOME, T.DAI_I_OPLO
            FROM
		    (SELECT 			
					SUM(SD2.D2_QUANT)   AS D2_QUANT,
					AVG(SD2.D2_PRCVEN)  AS D2_PRCVEN,
					SUM(SD2.D2_TOTAL)   AS D2_TOTAL,				
					SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,								
					SUM(SD2.D2_QTSEGUM) AS D2_QTSEGUM,
					SUM(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
					SUM(SD2.D2_I_FRET)  AS D2_I_FRET,
					SUM(SD2.D2_CUSTO1)  AS D2_CUSTO1,
					SUM(SD2.D2_ICMSRET) AS D2_ICMSRET,				
					SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SC5.C5_I_LOCEM,
					SD2.D2_COD,SA1.A1_COD_MUN,SA1.A1_MUN,SA3.A3_COD,SA3.A3_NOME,SF2.F2_VEND1,
					SA1.A1_COD,SA1.A1_NREDUZ,SA1.A1_GRPVEN,ACY.ACY_DESCRI,SA1.A1_LOJA,SD2.D2_FILIAL,
					SA1.A1_NOME, DAI.DAI_I_OPLO,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA, 
					(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD 
					   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
					(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		               ) AS D2_VALDEV, ///*************************** D2_VALDEV
					(SUM(SD2.D2_VALBRUT)  -
					(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		            )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV
				FROM 
					%table:SF2% SF2
					JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
					JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
					JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
					JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
					JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
					JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
					JOIN %table:SF4% SF4 ON sd2.d2_filial = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo
					JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
					LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
				WHERE 
					SF2.%notDel%  
					AND SD2.%notDel%  
					AND SA1.%notDel%  		
					AND SB1.%notDel%  					
					AND SA3.%notDel%  											
					AND SBM.%notDel%				
					AND ACY.%notDel%
					AND SF4.%notDel%
					AND SC5.%notDel%
			    	%exp:_cfiltro%
				 GROUP BY 
	 				SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SC5.C5_I_LOCEM,
					SD2.D2_COD,SA1.A1_MUN,SA1.A1_COD_MUN,SA3.A3_COD,SA3.A3_NOME,SF2.F2_VEND1,
					SA1.A1_COD,SA1.A1_NREDUZ,SA1.A1_GRPVEN,ACY.ACY_DESCRI,SA1.A1_LOJA,SD2.D2_FILIAL,SA1.A1_NOME, DAI.DAI_I_OPLO,
                    SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA
                ) T
				 GROUP BY 
	 				D2_UM,D2_SEGUM,B1_I_DESCD,B1_COD,C5_I_LOCEM,
					D2_COD,A1_MUN,A1_COD_MUN,A3_COD,A3_NOME,F2_VEND1,
					A1_COD,A1_NREDUZ,A1_GRPVEN,ACY_DESCRI,A1_LOJA,D2_FILIAL,A1_NOME, DAI_I_OPLO
				ORDER BY 
					D2_FILIAL,A1_GRPVEN,A1_COD,A1_LOJA
			EndSql
		END REPORT QUERY oSF2FIL_7
		
	else //ANALITICO ORDEM 07 - Cliente
	
		oSF2A_7:Enable()	
		
		BEGIN REPORT QUERY oSF2FIL_7
			BeginSql alias "QRY7"   	   	
		   		SELECT 
					SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_EMISSAO,SD2.D2_ITEM,SF2.F2_EMISSAO, SD2.D2_CLIENTE,SD2.D2_LOJA,
					SA1.A1_NREDUZ, SD2.D2_QUANT,SD2.D2_PRCVEN,SD2.D2_TOTAL,SD2.D2_UM,SD2.D2_VALBRUT,
					SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SF2.F2_VEND1,
					SA1.A1_MUN,SD2.D2_COD,SD2.D2_QTSEGUM,SD2.D2_FILIAL,SD2.D2_DOC,
					SA1.A1_COD_MUN,SA3.A3_COD,SA3.A3_NOME,SD2.D2_I_FRET,
					(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
					SA1.A1_COD,SA1.A1_NREDUZ,SA1.A1_GRPVEN,ACY.ACY_DESCRI,SA1.A1_LOJA,
					SD2.D2_CUSTO1,SD2.D2_FILIAL,SA1.A1_NOME,SD2.D2_ICMSRET,SC5.C5_I_TRCNF, SC5.C5_I_FILFT,;
					SC5.C5_I_FLFNC,DAI.DAI_I_OPLO, SD2.D2_LOCAL,SC5.C5_I_LOCEM,SC5.C5_I_QTDA,
					(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD 
					   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
					(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		               ) AS D2_VALDEV, ///*************************** D2_VALDEV
					(SD2.D2_VALBRUT  -
					(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		            )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV

				FROM 
					%table:SF2% SF2
					JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
					JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
					JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
					JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
					JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
					JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
					JOIN %table:SF4% SF4 ON sd2.d2_filial = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo 
					JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
					LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
				WHERE 
					SF2.%notDel%  
					AND SD2.%notDel%  
					AND SA1.%notDel%  		
					AND SB1.%notDel%  					
					AND SA3.%notDel%  											
					AND SBM.%notDel%				
					AND ACY.%notDel%
					AND SF4.%notDel%   
					AND SC5.%notDel%
				    %exp:_cfiltro%
				ORDER BY 
					SD2.D2_FILIAL,SA1.A1_GRPVEN,SA1.A1_COD,SA1.A1_LOJA
			EndSql
		END REPORT QUERY oSF2FIL_7
	endif

// ORDEM 08 Emissao - Sedex   
elseif _nOrdem == 8

	if mv_par19 == 2 //ANALITICO - ORDEM 08 Emissao - Sedex
	
		BEGIN REPORT QUERY oSF2FIL_8
			BeginSql alias "QRY8"   	   	
		   		SELECT 
			   		SF2.F2_EMISSAO,SF2.F2_CARGA,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_I_NFREF,SF2.F2_I_SERNF,SF2.F2_CLIENTE,SF2.F2_LOJA,
			   		SA1.A1_MUN,SA1.A1_EST,SA1.A1_NREDUZ,SA1.A1_NOME,SD2.D2_ITEM,SB1.B1_DESC,SD2.D2_QUANT,SD2.D2_UM,SD2.D2_SEGUM,
			   		SD2.D2_QTSEGUM,SD2.D2_PRCVEN,SD2.D2_TOTAL,SD2.D2_VALBRUT,SB1.B1_I_DESCD,SB1.B1_I_DESCD,
			   		SD2.D2_FILIAL,SD2.D2_COD,SD2.D2_ICMSRET, SC5.C5_I_TRCNF, SC5.C5_I_FILFT, SC5.C5_I_FLFNC,DAI.DAI_I_OPLO,
			   		SF2.F2_I_PEDID, SF2.F2_FILIAL,DAI.DAI_I_OPLO, SD2.D2_LOCAL,SC5.C5_I_LOCEM,SC5.C5_I_OPER,SC5.C5_I_NFSED,SC5.C5_I_QTDA,
					SF2.F2_I_CTRA,SF2.F2_I_LTRA, SA2.A2_I_TPAVE,   
					(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD 
					   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
					(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		               ) AS D2_VALDEV, ///*************************** D2_VALDEV
					(SD2.D2_VALBRUT  -
					(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		            )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV
					FROM %table:SF2% SF2
					JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
					JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
					JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
					JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
					JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
					JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
					JOIN %table:SF4% SF4 ON sd2.d2_filial = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo 
					JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
                    JOIN %table:SA2% SA2 ON SA2.A2_COD = SF2.F2_I_CTRA AND SA2.A2_LOJA = SF2.F2_I_LTRA
					LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
				WHERE 
					SF2.%notDel%  
					AND SD2.%notDel%  
					AND SA1.%notDel%  		
					AND SB1.%notDel%  					
					AND SA3.%notDel%  											
					AND SBM.%notDel%				
					AND ACY.%notDel%
					AND SF4.%notDel%
					AND SC5.%notDel%
					AND SA2.%notDel%
				    %exp:_cfiltro%
				ORDER BY 
					SD2.D2_FILIAL,SF2.F2_DOC,SF2.F2_EMISSAO,SD2.D2_ITEM
			EndSql
		
		END REPORT QUERY oSF2FIL_8
		
	Else  //SINTETICO ORDEM 08 Emissao - Sedex       
			
		BEGIN REPORT QUERY oSF2FIL_8
			BeginSql alias "QRY8"   	   	
		      SELECT 			
		      		SUM(T.D2_TOTAL)   AS D2_TOTAL,				
		      		SUM(T.D2_VALBRUT) AS D2_VALBRUT,								
		      		SUM(T.D2_VALDEV)  AS D2_VALDEV,				
		      		SUM(T.D2_ICMSRET) AS D2_ICMSRET,				
		      	    SUM(T.VLRBRUTDEV) AS VLRBRUTDEV,
					T.D2_FILIAL,T.F2_DOC,T.F2_SERIE,T.F2_CARGA,T.D2_PEDIDO,T.F2_CLIENTE,T.F2_LOJA,
					T.A1_NREDUZ,T.A1_NOME,T.F2_EMISSAO,T.DAI_I_OPLO,T.C5_I_LOCEM,T.C5_I_OPER,T.C5_I_NFSED,
					T.F2_I_CTRA,T.F2_I_LTRA,T.A2_I_TPAVE 
              FROM
		      (SELECT 			
					SUM(SD2.D2_TOTAL)   AS D2_TOTAL,				
					SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,								
					SUM(SD2.D2_ICMSRET) AS D2_ICMSRET,				
					SD2.D2_FILIAL,
					SF2.F2_DOC,
					SF2.F2_SERIE,
					SF2.F2_CARGA,
					SD2.D2_PEDIDO,
					SF2.F2_CLIENTE,
					SF2.F2_LOJA,
					SA1.A1_NREDUZ,
					SA1.A1_NOME,
					SF2.F2_EMISSAO, 
					DAI.DAI_I_OPLO,
					SD2.D2_COD,
					SC5.C5_I_LOCEM,
                    SC5.C5_I_OPER,
                    SC5.C5_I_NFSED,
			        SF2.F2_I_CTRA, 
					SF2.F2_I_LTRA, 
					SA2.A2_I_TPAVE,
					(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			           FROM SD1010 D1	       //%exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO    = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SF2.F2_DOC
			             AND D1.D1_SERIORI = SF2.F2_SERIE
			             AND D1.D1_FORNECE = SF2.F2_CLIENTE
			             AND D1.D1_LOJA    = SF2.F2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		               ) AS D2_VALDEV , ///*************************** D2_VALDEV
					(SUM(SD2.D2_VALBRUT) -
					(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			           FROM SD1010 D1				       //%exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO    = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SF2.F2_DOC
			             AND D1.D1_SERIORI = SF2.F2_SERIE
			             AND D1.D1_FORNECE = SF2.F2_CLIENTE
			             AND D1.D1_LOJA    = SF2.F2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		            )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV				
					FROM %table:SF2% SF2
					JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
					JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
					JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
					JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
					JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
					JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
					JOIN %table:SF4% SF4 ON SD2.D2_FILIAL = SF4.F4_FILIAL AND SD2.D2_TES = SF4.F4_CODIGO
					JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
                    JOIN %table:SA2% SA2 ON SA2.A2_COD = SF2.F2_I_CTRA AND SA2.A2_LOJA = SF2.F2_I_LTRA
					LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
				WHERE 
					SF2.%notDel%  
					AND SD2.%notDel%  
					AND SA1.%notDel%  		
					AND SB1.%notDel%  					
					AND SA3.%notDel%  											
					AND SBM.%notDel%				
					AND ACY.%notDel%
					AND SF4.%notDel%
					AND SC5.%notDel%
					AND SA2.%notDel%
			    	%exp:_cfiltro%
				 GROUP BY 
					SD2.D2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_CARGA,SD2.D2_PEDIDO,SF2.F2_CLIENTE,SF2.F2_LOJA,SA1.A1_NREDUZ,SA1.A1_NOME,
					SF2.F2_EMISSAO,DAI.DAI_I_OPLO,SD2.D2_COD,SC5.C5_I_LOCEM,SC5.C5_I_OPER,SC5.C5_I_NFSED,SF2.F2_I_CTRA,SF2.F2_I_LTRA, A2_I_TPAVE 
		      ) T
				 GROUP BY 
					D2_FILIAL,F2_DOC,F2_SERIE,F2_CARGA,D2_PEDIDO,F2_CLIENTE,F2_LOJA,A1_NREDUZ,A1_NOME,
					F2_EMISSAO,DAI_I_OPLO,C5_I_LOCEM,C5_I_OPER,C5_I_NFSED,F2_I_CTRA,F2_I_LTRA,A2_I_TPAVE 

				ORDER BY 
					D2_FILIAL,F2_EMISSAO,F2_DOC,F2_SERIE
			EndSql
		END REPORT QUERY oSF2FIL_8	
	
	EndIf
		
//Estado X Grupo de Produtos	
elseif _nOrdem == 9 // ORDEM 09 - SÓ SINTETICO

	BEGIN REPORT QUERY oSF2FIL_9
		BeginSql alias "QRY9"   	   	
		SELECT 			
				SUM(T.D2_QUANT)   AS D2_QUANT,
				AVG(T.D2_PRCVEN)  AS D2_PRCVEN,
				SUM(T.D2_TOTAL)   AS D2_TOTAL,				
				SUM(T.D2_VALBRUT) AS D2_VALBRUT,								
				SUM(T.D2_QTSEGUM) AS D2_QTSEGUM,
				SUM(T.D2_QTDEDEV) AS D2_QTDEDEV,
				SUM(T.D2_VALDEV)  AS D2_VALDEV,				
				SUM(T.D2_ICMSRET) AS D2_ICMSRET,				
			    SUM(T.VLRBRUTDEV) AS VLRBRUTDEV,
				T.D2_UM,T.D2_SEGUM,T.BM_DESC,T.B1_GRUPO,
				T.D2_EST,T.D2_FILIAL, T.DAI_I_OPLO, T.C5_I_LOCEM
        FROM
		(SELECT 			
				SUM(SD2.D2_QUANT)   AS D2_QUANT,
				AVG(SD2.D2_PRCVEN)  AS D2_PRCVEN,
				SUM(SD2.D2_TOTAL)   AS D2_TOTAL,				
				SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,								
				SUM(SD2.D2_QTSEGUM) AS D2_QTSEGUM,
				SUM(SD2.D2_ICMSRET) AS D2_ICMSRET,				
				SD2.D2_UM,SD2.D2_SEGUM,SBM.BM_DESC,SB1.B1_GRUPO,
				SD2.D2_EST,SD2.D2_FILIAL, DAI.DAI_I_OPLO,
				SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_COD,SC5.C5_I_LOCEM,
					(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD 
					   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
					(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		               ) AS D2_VALDEV, ///*************************** D2_VALDEV
					(SUM(SD2.D2_VALBRUT) -
					(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			           FROM SD1010 D1
				       %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			           WHERE D1.D_E_L_E_T_ = ' '
			             AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			             AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			             AND D1.D1_NFORI   = SD2.D2_DOC
			             AND D1.D1_SERIORI = SD2.D2_SERIE
			             AND D1.D1_FORNECE = SD2.D2_CLIENTE
			             AND D1.D1_LOJA    = SD2.D2_LOJA    
			             AND D1.D1_COD     = SD2.D2_COD
		            )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV

			FROM 
				%table:SF2% SF2
				JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
				JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
				JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
				JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
				JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
				JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
				JOIN %table:SF4% SF4 ON SD2.D2_FILIAL = SF4.F4_FILIAL AND SD2.D2_TES = SF4.f4_codigo
				JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
				LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
			WHERE 
				SF2.%notDel%  
				AND SD2.%notDel%  
				AND SA1.%notDel%  		
				AND SB1.%notDel%  					
				AND SA3.%notDel%  											
				AND SBM.%notDel%				
				AND ACY.%notDel%
				AND SF4.%notDel%
				AND SC5.%notDel%
		    	%exp:_cfiltro%
			 GROUP BY 
 				SD2.D2_FILIAL,SB1.B1_GRUPO,SD2.D2_EST,SD2.D2_UM,SD2.D2_SEGUM,SBM.BM_DESC,DAI.DAI_I_OPLO,
				SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_COD,SC5.C5_I_LOCEM
		) T  
			 GROUP BY 
 				D2_FILIAL,B1_GRUPO,D2_EST,D2_UM,D2_SEGUM,BM_DESC,DAI_I_OPLO,C5_I_LOCEM
			ORDER BY 
				D2_FILIAL,D2_EST,B1_GRUPO,BM_DESC
		EndSql
	END REPORT QUERY oSF2FIL_9	

//ORDEM 13 - Dia x Estado x Produto	 - SÓ SINTETICO
ElseIf _nOrdem == 13	            

	BEGIN REPORT QUERY oSF2FIL_13
		BeginSql alias "QRY13"   	   	
		SELECT 	SUM(T.D2_QUANT)   AS D2_QUANT,
				SUM(T.D2_QTSEGUM) AS D2_QTSEGUM,
				SUM(T.D2_TOTAL)   AS D2_TOTAL,				
				SUM(T.D2_VALBRUT) AS D2_VALBRUT,								
				SUM(T.D2_QTDEDEV) AS D2_QTDEDEV,
				SUM(T.D2_VALDEV)  AS D2_VALDEV,		
			    SUM(T.VLRBRUTDEV) AS VLRBRUTDEV,		
				T.D2_FILIAL,T.F2_EMISSAO,T.D2_EST,T.D2_COD,T.B1_I_DESCD,T.D2_UM,T.D2_SEGUM,T.DAI_I_OPLO,T.C5_I_LOCEM
        FROM
		(SELECT 			
				SUM(SD2.D2_QUANT)   AS D2_QUANT,  
				SUM(SD2.D2_QTSEGUM) AS D2_QTSEGUM,
				SUM(SD2.D2_TOTAL)   AS D2_TOTAL,
				SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,					
				SD2.D2_FILIAL,SF2.F2_EMISSAO,SD2.D2_EST,SD2.D2_COD,SB1.B1_I_DESCD,SD2.D2_UM,SD2.D2_SEGUM,DAI.DAI_I_OPLO,
				SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SC5.C5_I_LOCEM,
				(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			       FROM SD1010 D1
				   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			       WHERE D1.D_E_L_E_T_ = ' '
			         AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			         AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			         AND D1.D1_NFORI   = SD2.D2_DOC
			         AND D1.D1_SERIORI = SD2.D2_SERIE
			         AND D1.D1_FORNECE = SD2.D2_CLIENTE
			         AND D1.D1_LOJA    = SD2.D2_LOJA    
			         AND D1.D1_COD     = SD2.D2_COD 
				   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
				(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			       FROM SD1010 D1
				   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			       WHERE D1.D_E_L_E_T_ = ' '
			         AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			         AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			         AND D1.D1_NFORI   = SD2.D2_DOC
			         AND D1.D1_SERIORI = SD2.D2_SERIE
			         AND D1.D1_FORNECE = SD2.D2_CLIENTE
			         AND D1.D1_LOJA    = SD2.D2_LOJA    
			         AND D1.D1_COD     = SD2.D2_COD
		           ) AS D2_VALDEV, ///*************************** D2_VALDEV
				(SUM(SD2.D2_VALBRUT)  -
				(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			       FROM SD1010 D1
				   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			       WHERE D1.D_E_L_E_T_ = ' '
			         AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			         AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			         AND D1.D1_NFORI   = SD2.D2_DOC
			         AND D1.D1_SERIORI = SD2.D2_SERIE
			         AND D1.D1_FORNECE = SD2.D2_CLIENTE
			         AND D1.D1_LOJA    = SD2.D2_LOJA    
			         AND D1.D1_COD     = SD2.D2_COD
		        )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV
			FROM 
				%table:SF2% SF2
				JOIN %table:SD2% SD2 ON SD2.D2_DOC     = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
				JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
				JOIN %table:SB1% SB1 ON SD2.D2_COD     = SB1.B1_COD 
				JOIN %table:SA3% SA3 ON SF2.F2_VEND1   = SA3.A3_COD
				JOIN %table:SBM% SBM ON SB1.B1_GRUPO   = SBM.BM_GRUPO
				JOIN %table:ACY% ACY ON SA1.A1_GRPVEN  = ACY.ACY_GRPVEN
				JOIN %table:SF4% SF4 ON sd2.d2_filial  = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo
				JOIN %table:SC5% SC5 ON SC5.C5_FILIAL  = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
				LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
			WHERE 
				SF2.%notDel%  
				AND SD2.%notDel%  
				AND SA1.%notDel%  		
				AND SB1.%notDel%  					
				AND SA3.%notDel%  											
				AND SBM.%notDel%				
				AND ACY.%notDel%
				AND SF4.%notDel%
				AND SC5.%notDel%
			    %exp:_cfiltro%
			GROUP BY
			    SD2.D2_FILIAL,SF2.F2_EMISSAO,SD2.D2_EST,SD2.D2_COD,SB1.B1_I_DESCD,SD2.D2_UM,SD2.D2_SEGUM, DAI.DAI_I_OPLO,
				SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SC5.C5_I_LOCEM
		) T  

			GROUP BY
			    D2_FILIAL,F2_EMISSAO,D2_EST,D2_COD,B1_I_DESCD,D2_UM,D2_SEGUM, DAI_I_OPLO,C5_I_LOCEM
			ORDER BY 
				D2_FILIAL,F2_EMISSAO,D2_EST,D2_COD
		EndSql
	END REPORT QUERY oSF2FIL_13
	
endif

//**************************************** FINAL DAS QUERYS ***********************************************************************

//Secao Coordenador/Vendedor
oSF2_1:SetParentQuery()
oSF2_1:SetParentFilter({|cParam| QRY1->D2_FILIAL == cParam },{|| QRY1->D2_FILIAL })
 
oSF2_1A:SetParentQuery()
oSF2_1A:SetParentFilter({|cParam| QRY1->D2_FILIAL+QRY1->F2_VEND2 == cParam },{|| QRY1->D2_FILIAL+QRY1->F2_VEND2 })

oSF2A_1:SetParentQuery()
oSF2A_1:SetParentFilter({|cParam| QRY1->D2_FILIAL + QRY1->F2_VEND2 + QRY1->F2_VEND1 == cParam },{|| QRY1->D2_FILIAL + QRY1->F2_VEND2 + QRY1->F2_VEND1 })

oSF2S_1:SetParentQuery()
oSF2S_1:SetParentFilter({|cParam| QRY1->D2_FILIAL + QRY1->F2_VEND2 + QRY1->F2_VEND1 == cParam },{|| QRY1->D2_FILIAL + QRY1->F2_VEND2 + QRY1->F2_VEND1 })

//Secao Produto - analitico - grupo por produto 
oSF2_3:SetParentQuery()
oSF2_3:SetParentFilter({|cParam| QRY3->D2_FILIAL == cParam },{|| QRY3->D2_FILIAL })                      

oSF2A_3:SetParentQuery()
oSF2A_3:SetParentFilter({|cParam| QRY3->D2_COD == cParam },{|| QRY3->D2_COD })                       

//Secao Produto - sintetico - grupo por Coordenador
oSF2S_3:SetParentQuery()
oSF2S_3:SetParentFilter({|cParam| QRY3->D2_FILIAL == cParam },{|| QRY3->D2_FILIAL })                       

//Secao Rede
oSF2_4:SetParentQuery()
oSF2_4:SetParentFilter({|cParam| QRY4->D2_FILIAL == cParam },{|| QRY4->D2_FILIAL })

oSF2S_4:SetParentQuery()
oSF2S_4:SetParentFilter({|cParam| QRY4->D2_FILIAL + QRY4->A1_GRPVEN == cParam },{|| QRY4->D2_FILIAL + QRY4->A1_GRPVEN })                       

oSF2A_4:SetParentQuery()
oSF2A_4:SetParentFilter({|cParam| QRY4->D2_FILIAL + QRY4->A1_GRPVEN == cParam },{|| QRY4->D2_FILIAL + QRY4->A1_GRPVEN })                       

//Secao Estado
oSF2_5:SetParentQuery()
oSF2_5:SetParentFilter({|cParam| QRY5->D2_FILIAL == cParam },{|| QRY5->D2_FILIAL })

oSF2S_5:SetParentQuery()
oSF2S_5:SetParentFilter({|cParam| QRY5->D2_FILIAL+QRY5->D2_EST == cParam },{|| QRY5->D2_FILIAL+QRY5->D2_EST })                       

//Secao Estado
oSF2A_5:SetParentQuery()
oSF2A_5:SetParentFilter({|cParam| QRY5->D2_FILIAL+QRY5->D2_EST == cParam },{|| QRY5->D2_FILIAL+QRY5->D2_EST })                       

//Secao Municipio
oSF2_6:SetParentQuery()
oSF2_6:SetParentFilter({|cParam| QRY6->D2_FILIAL == cParam },{|| QRY6->D2_FILIAL })

oSF2_6A:SetParentQuery()
oSF2_6A:SetParentFilter({|cParam | QRY6->A1_MUN == cParam },{|| QRY6->A1_MUN })

//Secao Municipio
oSF2S_6:SetParentQuery()
oSF2S_6:SetParentFilter({|cParam| QRY6->A1_MUN+QRY6->F2_VEND1 == cParam },{|| QRY6->A1_MUN+QRY6->F2_VEND1 })                       

//Secao Estado
oSF2A_6:SetParentQuery()
oSF2A_6:SetParentFilter({|cParam| QRY6->A1_MUN+QRY6->F2_VEND1 == cParam },{|| QRY6->A1_MUN+QRY6->F2_VEND1 })                       

//Secao Municipio
oSF2_7:SetParentQuery()
oSF2_7:SetParentFilter({|cParam| QRY7->D2_FILIAL == cParam },{|| QRY7->D2_FILIAL })

oSF2_7A:SetParentQuery()
oSF2_7A:SetParentFilter({|cParam| QRY7->A1_GRPVEN == cParam },{|| QRY7->A1_GRPVEN })

//Secao Municipio
oSF2S_7:SetParentQuery()
oSF2S_7:SetParentFilter({|cParam| QRY7->A1_COD+QRY7->A1_LOJA == cParam },{|| QRY7->A1_COD+QRY7->A1_LOJA })                       

//Secao Estado
oSF2A_7:SetParentQuery()
oSF2A_7:SetParentFilter({|cParam| QRY7->A1_COD+QRY7->A1_LOJA == cParam },{|| QRY7->A1_COD+QRY7->A1_LOJA })                       

//Secao Emissao NF-Sedex                                                                         
oSF2_8:SetParentQuery()
oSF2_8:SetParentFilter({|cParam| QRY8->D2_FILIAL == cParam },{|| QRY8->D2_FILIAL })
			
oSF2A_8:SetParentQuery()
oSF2A_8:SetParentFilter({|cParam| QRY8->F2_DOC+QRY8->F2_SERIE == cParam },{|| QRY8->F2_DOC+QRY8->F2_SERIE })  
	    	
oSF2S_8:SetParentQuery()
oSF2S_8:SetParentFilter({|cParam| QRY8->D2_FILIAL == cParam },{|| QRY8->D2_FILIAL })       
	
//Secao estado x Grupo de Produtos
//Secao Estado
oSF2_9:SetParentQuery()
oSF2_9:SetParentFilter({|cParam| QRY9->D2_FILIAL == cParam },{|| QRY9->D2_FILIAL })

oSF2S_9:SetParentQuery()
oSF2S_9:SetParentFilter({|cParam| QRY9->D2_FILIAL + QRY9->D2_EST == cParam },{|| QRY9->D2_FILIAL + QRY9->D2_EST })  

//Secao Dia x Estado x Produto
oSF2DT_13:SetParentQuery()
oSF2DT_13:SetParentFilter({|cParam| QRY13->D2_FILIAL == cParam },{|| QRY13->D2_FILIAL })

oSF2_13:SetParentQuery()
oSF2_13:SetParentFilter({|cParam| QRY13->D2_FILIAL + DtoS(QRY13->F2_EMISSAO) == cParam },{|| QRY13->D2_FILIAL + DtoS(QRY13->F2_EMISSAO) })                          

oSF2A_13:SetParentQuery()
oSF2A_13:SetParentFilter({|cParam| QRY13->D2_FILIAL + DtoS(QRY13->F2_EMISSAO) + QRY13->D2_EST == cParam },{|| QRY13->D2_FILIAL + DtoS(QRY13->F2_EMISSAO)+ QRY13->D2_EST })  

if _nOrdem == 1    
   	oSF2FIL_1:Print(.T.) 	
//elseif _nOrdem == 2
//	oSF2FIL_2:Print(.T.)
elseif _nOrdem == 3
	oSF2FIL_3:Print(.T.)
elseif _nOrdem == 4
    oSF2FIL_4:Print(.T.) 
elseif _nOrdem == 5
	oSF2FIL_5:Print(.T.)
elseif _nOrdem == 6
	oSF2FIL_6:Print(.T.)	
elseif _nOrdem == 7
	oSF2FIL_7:Print(.T.)	
elseif _nOrdem == 8
	oSF2FIL_8:Print(.T.)		
elseif _nOrdem == 9
	oSF2FIL_9:Print(.T.) 
elseif _nOrdem == 13
	oSF2FIL_13:Print(.T.)		
endif

Return()

/*
===============================================================================================================================
Programa--------: ROMS003L
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para buscar quantidade da segunda unidade de medida
Parametros------: nQtd:    Quantidade do Item 1um
----------------: nQtdDev: Quantidade do Item devolvida 1um
----------------: nQtd2Um: Quantidade do Item 2um
Retorno---------: _nRet - Quantidade do Item devolvida 2um
===============================================================================================================================
*/
Static Function ROMS003L( _nQtd , _nQtdDev , _nQtd2Um )
Local _nRet := 0

If _nQtdDev == 0
   Return 0 
EndIf

_nRet := ( _nQtd2Um * ( _nQtdDev / _nQtd ) )

Return( _nRet )

/*
===============================================================================================================================
Programa--------: ROMS003Q
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar quantidade de devoluções
Parametros------: _cDoc		- Documento fiscal de saída
----------------: _cSerie	- Série do documento
----------------: _nQtdDev	- Quantidade devolvida
----------------: _cFil		- Filial do documento
----------------: _cProduto	- Código do Produto
Retorno---------: _nRet		- Quantidade devolvida de acordo com os parâmetros
===============================================================================================================================
*/
Static Function ROMS003Q( _cDoc , _cSerie , _nQtdDev , _cFil , _cProduto )

Local _nRet			:= 0
Local _aDadosDev	:= {}

//Chama funcao filDev que retorna os dados da devolucao das notas fiscais de saida, caso estas possuam devolucao
_aDadosDev := ROMS003I( _cDoc , _cSerie , _cFil , _cProduto )

//Se existe uma devolucao e ela se enquadra nos filtros dispostos na funcao fildev
If _aDadosDev[1][1]	

	//D1_QUANT
	_nRet := _aDadosDev[1][2]

EndIf

Return( _nRet )

/*
===============================================================================================================================
Programa--------: ROMS003V
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar valores de devoluções
Parametros------: _cDoc			- Documento fiscal de saída
----------------: _cSerie		- Série do documento
----------------: _nValDev		- Valor da devolução
----------------: _cFil			- Filial do documento
----------------: _nValTotal	- Valor Total
----------------: _nIcmRet		- Valor de ICMS
----------------: _cCampo		- Nome do Campo
----------------: _cProduto		- Código do produto
Retorno---------: _nRet			- Valor devolvido de acordo com os parâmetros
===============================================================================================================================
*/
Static Function ROMS003V( _cDoc , _cSerie , _nValDev , _cFil , _nValTotal , _nicmRet , _cCampo , _cProduto )

Local _nRet      := 0
Local _cFilLocal := "%"
Local _aDadosDev := {}
Local _lValBrut  := IIF( _cCampo == 'D2_VALDEV' , .T. , .F. )

//====================================================================================================
//Para a ordem oito sintetica como nao se sabe o produto e como pode haver um filtro por produto pelo
// usuario informado no parametro esta ordem nao faz calculo de quantidade, por isso somente aqui tem
// essas consideracoes para que possa agilizar o relatorio nao sendo necessario realizar busca na SD2
//====================================================================================================
If Len( AllTrim( _cProduto ) ) == 0

	_cFilLocal += " AND SF2.F2_DOC    = '"+ _cDoc   +"' "
	_cFilLocal += " AND SF2.F2_SERIE  = '"+ _cSerie +"' "
	_cFilLocal += " AND SD2.D2_FILIAL = '"+ _cFil   +"' "
	_cFilLocal += " %"
	
	_nRet := ROMS003Y( _cFilLocal , 'D2_VALDEV' , _lValBrut )
	
Else

	//Chama funcao filDev que retorna os dados da devolucao das notas fiscais de saida, caso estas possuam devolucao
	//estes dados sao buscados na TABELA SD1
	_aDadosDev := ROMS003I( _cDoc , _cSerie , _cFil , _cProduto )
                    
	//Se existe uma devolucao e ela se enquadra nos filtros dispostos na funcao fildev
	If _aDadosDev[1][1]
			   
		If _cCampo == "D2_VALDEV"
				                                               
			//D1_TOTAL + D1_ICMSRET
			_nRet := _aDadosDev[1][3] + _aDadosDev[1][4]
		
		Else
		
			//D1_TOTAL
			_nRet := _aDadosDev[1][3]
							
		EndIf
		
	EndIf	 

EndIf

Return( _nRet )

/*
===============================================================================================================================
Programa--------: ROMS003I
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar dados de devoluções
Parametros------: _cDoc			- Documento fiscal de saída
----------------: _cSerie		- Série do documento
----------------: _nValDev		- Valor da devolução
----------------: _cFil			- Filial do documento
----------------: _cProduto		- Código do produto
Retorno---------: _aDadosDev	- Dados das devoluções
===============================================================================================================================
*/
Static function ROMS003I( _cDoc , _cSerie , _cFil , _cProduto )

Local _lRet 		:= .F.
Local _cQuant1		:= 0
Local _cTotal		:= 0
Local _cICMSRet		:= 0
Local _cQuant2		:= 0
local _aAreaSF1 	:= SF1->(getArea()) 
local _aAreaSD1 	:= SD1->(getArea())   
local _cQuery		:= " "
local _cDocEnt		:= " "
local _cSerieEnt	:= " "  
Local _aDadosDev	:= {}
Local _cFornece     := " "
Local _cLoja        := " "    
Local _cTipo        := "D"

//Adicionado por Fabiano Dias no dia 31/03/10 para solucionar o problema dos dados da devolucao
//Define query para buscar documento de entrada referente a devolucao a partir do doc. de saida
_cQuery := " SELECT " 
_cQuery += "     D1_DOC,"
_cQuery += "     D1_SERIE,"
_cQuery += "     D1_FORNECE,"
_cQuery += "     D1_LOJA,"
_cQuery += "     D1_TIPO,"
_cQuery += "     SUM(D1_QUANT)   AS D1_QUANT,"
_cQuery += "     SUM(D1_TOTAL)   AS D1_TOTAL,"
_cQuery += "     SUM(D1_ICMSRET) AS D1_ICMSRET,"
_cQuery += "     SUM(D1_QTSEGUM) AS D1_QTSEGUM "
_cQuery += " FROM  "+ RetSqlName("SD1") +" SD1 "
_cQuery += " WHERE "+ RetSqlDel('SD1')
_cQuery += " AND   D1_NFORI   = '"+ _cDoc     +"' "
_cQuery += " AND   D1_SERIORI = '"+ _cSerie   +"' "
_cQuery += " AND   D1_FILIAL  = '"+ _cFil     +"' "
_cQuery += " AND   D1_COD     = '"+ _cProduto +"' "
_cQuery += " AND   D1_TIPO    = 'D' "
_cQuery += " GROUP BY D1_DOC , D1_SERIE, D1_FORNECE,   D1_LOJA, D1_TIPO   "

If Select("TRB") > 0 
    TRB->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TCGenQry(,, _cQuery ) , 'TRB' , .F. , .T. )

DBSelectArea("TRB")
TRB->( DBGotop() )
While TRB->( !Eof() )
	
	_cDocEnt	:= TRB->D1_DOC
    _cSerieEnt	:= TRB->D1_SERIE 
    _cFornece 	:= TRB->D1_FORNECE
    _cLoja      := TRB->D1_LOJA   
    _cTipo      := TRB->D1_TIPO
    
    _lRet		:= .T.
	
	//Posicione SF1
	DBSelectArea("SF1")
	SF1->( DBSetOrder(1) )
	If SF1->( DBSeek( _cFil + _cDocEnt + _cSerieEnt + _cFornece + _cLoja + _cTipo ) )
	
		//Tipo de Formulario
		If MV_PAR23 == 1 //Se formulario proprio = sim 
			_lRet := SF1->F1_FORMUL == "S"
		ElseIf MV_PAR23 == 2 //Se formulario proprio = nao
			_lRet := SF1->F1_FORMUL != "S"
		EndIf
		
		//Verifica data de digitacao da nf de compra esta entre MV_PAR24 e MV_PAR25
		If _lRet
		
			If !Empty(MV_PAR24) .And. !Empty(MV_PAR25)
				_lRet := ( SF1->F1_DTDIGIT >= MV_PAR24 .And. SF1->F1_DTDIGIT <= MV_PAR25 )
			EndIf
			
		EndIf    
		
		If _lRet
		    _cQuant1	+= TRB->D1_QUANT
		    _cTotal		+= TRB->D1_TOTAL
		    _cICMSRet	+= TRB->D1_ICMSRET
		    _cQuant2	+= TRB->D1_QTSEGUM
		EndIf
	
	EndIf
	
TRB->( DBSkip() )
EndDo

TRB->( DBCloseArea() )

If _cQuant1 > 0  
	_lRet := .T.
Else
   	_lRet := .F.
EndIf

//Restaura ambiente
RestArea( _aAreaSF1 )
RestArea( _aAreaSD1 )

//Adiciona os dados devolvios ao array
aAdd( _aDadosDev , { _lRet , _cQuant1 , _cTotal , _cICMSRet , _cQuant2 } )

Return( _aDadosDev )

/*
===============================================================================================================================
Programa--------: ROMS003Q1
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar a quantidade de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cVend		- Código do Vendedor
----------------: _cSuper		- Código do Coordenador
----------------: _cCampo		- Campo da tabela
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003Q1( _cUm , _cSegUm , _cCod , _cFil , _cVend , _cSuper , _cCampo )

Local _nRet			:= 0
Local _cFilLocal	:= "%"

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM     = '"+ _cUm    +"' "
_cFilLocal += " AND SD2.D2_SEGUM  = '"+ _cSegUm +"' "
_cFilLocal += " AND SB1.B1_COD    = '"+ _cCod   +"' "
_cFilLocal += " AND SD2.D2_FILIAL = '"+ _cFil   +"' "
_cFilLocal += " AND SF2.F2_VEND1  = '"+ _cVend  +"' "
_cFilLocal += " AND SF2.F2_VEND2  = '"+ _cSuper +"' "
_cFilLocal += "%"

_nRet := ROMS003Y( _cFilLocal , _cCampo , .F. )

Return( _nRet )

/*
===============================================================================================================================
Programa--------: ROMS003Q2
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar a quantidade de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cSuper		- Código do Coordenador
----------------: _cCampo		- Campo da tabela
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003Q2( _cUm , _cSegUm , _cCod , _cFil , _cSuper , _cCampo )

Local _nRet			:= 0
Local _cFilLocal	:= "%"

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM     = '"+ _cUm    +"' "
_cFilLocal += " AND SD2.D2_SEGUM  = '"+ _cSegUm +"' "
_cFilLocal += " AND SB1.B1_COD    = '"+ _cCod   +"' "
_cFilLocal += " AND SD2.D2_FILIAL = '"+ _cFil   +"' "
_cFilLocal += " AND SF2.F2_VEND2  = '"+ _cSuper +"' "
_cFilLocal += "%"

_nRet := ROMS003Y( _cFilLocal , _cCampo , .F. )

Return( _nRet )

/*
===============================================================================================================================
Programa--------: ROMS003Q3
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar a quantidade de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cCampo		- Campo da tabela
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003Q3( _cUm , _cSegUm , _cCod , _cFil , _cCampo )

Local _nRet			:= 0
Local _cFilLocal	:= "%"

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM     = '"+ _cUm    +"' "
_cFilLocal += " AND SD2.D2_SEGUM  = '"+ _cSegUm +"' "
_cFilLocal += " AND SB1.B1_COD    = '"+ _cCod   +"' "
_cFilLocal += " AND SD2.D2_FILIAL = '"+ _cFil   +"' "
_cFilLocal += "%"

_nRet := ROMS003Y( _cFilLocal , _cCampo , .F. )

Return( _nRet )
         
/*
===============================================================================================================================
Programa--------: ROMS003Q4
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar a quantidade de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cGrpVen		- Código do grupo de vendas
----------------: _cCampo		- Campo da tabela
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003Q4( _cUm , _cSegUm , _cCod , _cFil , _cGrpVen , _cCampo )

Local _nRet			:= 0
Local _cFilLocal	:= "%"

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM      = '"+ _cUm     +"' "
_cFilLocal += " AND SD2.D2_SEGUM   = '"+ _cSegUm  +"' "
_cFilLocal += " AND SB1.B1_COD     = '"+ _cCod    +"' "
_cFilLocal += " AND SD2.D2_FILIAL  = '"+ _cFil    +"' "
_cFilLocal += " AND ACY.ACY_GRPVEN = '"+ _cGrpVen +"' "
_cFilLocal += "%"

_nRet := ROMS003Y( _cFilLocal , _cCampo , .F. )

Return( _nRet )

/*
===============================================================================================================================
Programa--------: ROMS003Q5
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar a quantidade de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cEst			- Sigla da UF
----------------: _cCampo		- Campo da tabela
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003Q5( _cUm , _cSegUm , _cCod , _cFil , _cEst , _cCampo )

Local _nRet			:= 0
Local _cFilLocal	:= "%"

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM     = '"+ _cUm    +"' "
_cFilLocal += " AND SD2.D2_SEGUM  = '"+ _cSegUm +"' "
_cFilLocal += " AND SB1.B1_COD    = '"+ _cCod   +"' "
_cFilLocal += " AND SD2.D2_FILIAL = '"+ _cFil   +"' "
_cFilLocal += " AND SD2.D2_EST    = '"+ _cEst   +"' "
_cFilLocal += "%"

_nRet := ROMS003Y( _cFilLocal , _cCampo , .F. )

Return( _nRet )
   
/*
===============================================================================================================================
Programa--------: ROMS003Q6
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar a quantidade de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cEst			- Sigla da UF
----------------: _cCampo		- Campo da tabela
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003Q6( _cUm , _cSegUm , _cCod , _cFil , _cEst , _cMun , _cVend , _cCampo )

Local _nRet			:= 0
Local _cFilLocal	:= "%"

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM      = '"+ _cUm    +"' "
_cFilLocal += " AND SD2.D2_SEGUM   = '"+ _cSegUm +"' "
_cFilLocal += " AND SB1.B1_COD     = '"+ _cCod   +"' "
_cFilLocal += " AND SD2.D2_FILIAL  = '"+ _cFil   +"' "
_cFilLocal += " AND SA1.A1_EST     = '"+ _cEst   +"' "
_cFilLocal += " AND SA1.A1_COD_MUN = '"+ _cMun   +"' "
_cFilLocal += " AND SF2.F2_VEND1   = '"+ _cVend  +"' "
_cFilLocal += "%"

_nRet := ROMS003Y( _cFilLocal , _cCampo , .F. )

Return( _nRet )
   
/*
===============================================================================================================================
Programa--------: ROMS003Q7
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar a quantidade de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cMun			- Código do municipio
----------------: _cVend		- Código do Vendedor
----------------: _cGrpVen		- Código do Grupo de Vendas
----------------: _cCodCli		- Código do Cliente
----------------: _cLojaCli		- Loja do Cliente
----------------: _cCampo		- Campo da tabela
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003Q7( _cUm , _cSegUm , _cCod , _cFil , _cMun , _cVend , _cGrpVen , _cCodCli , _cLojaCli , _cCampo )

Local _nRet			:= 0
Local _cFilLocal	:= "%"

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM      = '"+ _cUm      +"' "
_cFilLocal += " AND SD2.D2_SEGUM   = '"+ _cSegUm   +"' "
_cFilLocal += " AND SB1.B1_COD     = '"+ _cCod     +"' "
_cFilLocal += " AND SD2.D2_FILIAL  = '"+ _cFil     +"' "
_cFilLocal += " AND SA1.A1_COD_MUN = '"+ _cMun     +"' "
_cFilLocal += " AND SF2.F2_VEND1   = '"+ _cVend    +"' "
_cFilLocal += " AND SA1.A1_GRPVEN  = '"+ _cGrpVen  +"' "
_cFilLocal += " AND SA1.A1_COD     = '"+ _cCodCli  +"' "
_cFilLocal += " AND SA1.A1_LOJA    = '"+ _cLojaCli +"' "
_cFilLocal += "%"

_nRet := ROMS003Y( _cFilLocal , _cCampo , .F. )

Return( _nRet )

/*
===============================================================================================================================
Programa--------: ROMS003Q9
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar a quantidade de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cEst			- Sigla da UF
----------------: _cCampo		- Campo da tabela
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003Q9( _cUm , _cSegUm , _cCod , _cFil , _cEst , _cCampo )

Local _nRet			:= 0
Local _cFilLocal	:= "%"

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM     = '"+ _cUm    +"' "
_cFilLocal += " AND SD2.D2_SEGUM  = '"+ _cSegUm +"' "
_cFilLocal += " AND SB1.B1_GRUPO  = '"+ _cCod   +"' "
_cFilLocal += " AND SD2.D2_FILIAL = '"+ _cFil   +"' "
_cFilLocal += " AND SD2.D2_EST    = '"+ _cEst   +"' "
_cFilLocal += "%"

_nRet := ROMS003Y( _cFilLocal , _cCampo , .F. )

Return( _nRet )

/*
===============================================================================================================================
Programa--------: ROMS003QC
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar a quantidade de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cEst			- Sigla da UF
----------------: _dDtEmis		- Data de Emissão
----------------: _cCampo		- Campo da tabela
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003QC( _cUm , _cSegUm , _cCod , _cFil , _cEst , _dDtEmis , _cCampo )

Local _nRet			:= 0
Local _cFilLocal	:= "%"

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM      = '"+ _cUm             +"' "
_cFilLocal += " AND SD2.D2_SEGUM   = '"+ _cSegUm          +"' "
_cFilLocal += " AND SB1.B1_COD     = '"+ _cCod            +"' "
_cFilLocal += " AND SD2.D2_FILIAL  = '"+ _cFil            +"' "
_cFilLocal += " AND SD2.D2_EST     = '"+ _cEst            +"' "
_cFilLocal += " AND SD2.D2_EMISSAO = '"+ DtoS( _dDtEmis ) +"' "
_cFilLocal += "%"

_nRet := ROMS003Y( _cFilLocal , _cCampo , .F. )

Return( _nRet )

/*
===============================================================================================================================
Programa--------: ROMS003QD
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar o valor de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cVend		- Código do Vendedor
----------------: _cSuper		- Código do Coordenador
----------------: _lValBrut		- Flag de Valor Bruto
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003QD( _cUm , _cSegUm , _cCod , _cFil , _cVend , _cSuper , _lValBrut )

Local _nRet			:= 0
Local _cFilLocal	:= "%"

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM     = '"+ _cUm    +"' "
_cFilLocal += " AND SD2.D2_SEGUM  = '"+ _cSegUm +"' "
_cFilLocal += " AND SB1.B1_COD    = '"+ _cCod   +"' "
_cFilLocal += " AND SD2.D2_FILIAL = '"+ _cFil   +"' "
_cFilLocal += " AND SF2.F2_VEND1  = '"+ _cVend  +"' "
_cFilLocal += " AND SF2.F2_VEND2  = '"+ _cSuper +"' "
_cFilLocal += "%"

_nRet := ROMS003Y( _cFilLocal , "D2_VALDEV" , _lValBrut )

Return( _nRet )

/*
===============================================================================================================================
Programa--------: ROMS003QF
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar o valor de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cVend		- Código do Vendedor
----------------: _cSuper		- Código do Coordenador
----------------: _lValBrut		- Flag de Valor Bruto
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003QF( _cUm , _cSegUm , _cCod , _cFil , _cSuper , _lValBrut )

Local _nRet      := 0
Local _cFilLocal := "%"

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM     = '"+ _cUm    +"' "
_cFilLocal += " AND SD2.D2_SEGUM  = '"+ _cSegUm +"' "
_cFilLocal += " AND SB1.B1_COD    = '"+ _cCod   +"' "
_cFilLocal += " AND SD2.D2_FILIAL = '"+ _cFil   +"' "
_cFilLocal += " AND SF2.F2_VEND2  = '"+ _cSuper +"' "
_cFilLocal += "%"

_nRet := ROMS003Y( _cFilLocal , "D2_VALDEV" , _lValBrut )

return _nRet 

/*
===============================================================================================================================
Programa--------: ROMS003QG
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar o valor de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _lValBrut		- Flag de Valor Bruto
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
static function ROMS003QG(_cUm, _cSegUm, _cCod, _cFil, _lValBrut)

local _nRet := 0
local _cFilLocal := "%"

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM = '"     + _cUm    + "' "
_cFilLocal += " AND SD2.D2_SEGUM = '"  + _cSegUm + "' "
_cFilLocal += " AND SB1.B1_COD = '"    + _cCod   + "' "
_cFilLocal += " AND SD2.D2_FILIAL = '" + _cFil   + "' "   

_cFilLocal += "%"
_nRet := ROMS003Y(_cFilLocal,"D2_VALDEV",_lValBrut)

return _nRet 

/*
===============================================================================================================================
Programa--------: ROMS003QH
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar o valor de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cGrpVen		- Código do Grupo de Vendas
----------------: _lValBrut		- Flag de Valor Bruto
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
static function ROMS003QH(_cUm, _cSegUm, _cCod, _cFil, _cGrpVen, _lValBrut)

local _nRet := 0
local _cFilLocal := "%"

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM = '"       + _cUm     + "' "
_cFilLocal += " AND SD2.D2_SEGUM = '"    + _cSegUm  + "' "
_cFilLocal += " AND SB1.B1_COD = '"      + _cCod    + "' "
_cFilLocal += " AND SD2.D2_FILIAL = '"   + _cFil    + "' "   
_cFilLocal += " AND ACY.ACY_GRPVEN = '"  + _cGrpVen + "' " 


_cFilLocal += "%"

_nRet := ROMS003Y(_cFilLocal,"D2_VALDEV",_lValBrut)

return _nRet 

/*
===============================================================================================================================
Programa--------: ROMS003QI
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar o valor de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cEst			- Sigla da UF
----------------: _lValBrut		- Flag de Valor Bruto
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
static function ROMS003QI(_cUm, _cSegUm, _cCod, _cFil, _cEst, _lValBrut)

local _nRet := 0
local _cFilLocal := "%"		

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM = '"      + _cUm + "' "
_cFilLocal += " AND SD2.D2_SEGUM = '"   + _cSegUm + "' "
_cFilLocal += " AND SB1.B1_COD = '"     + _cCod + "' "
_cFilLocal += " AND SD2.D2_FILIAL = '"  + _cFil + "' "   
_cFilLocal += " AND SD2.D2_EST = '"     + _cEst + "' " 


_cFilLocal += "%"

_nRet := ROMS003Y(_cFilLocal, "D2_VALDEV", _lValBrut)

return _nRet 

/*
===============================================================================================================================
Programa--------: ROMS003QJ
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar o valor de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cEst			- Sigla da UF
----------------: _cMun			- Código do Município
----------------: _cVend		- Código do Vendedor
----------------: _lValBrut		- Flag de Valor Bruto
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003QJ( _cUm , _cSegUm , _cCod , _cFil , _cEst , _cMun , _cVend , _lValBrut )

local _nRet		:= 0
local _cFilLocal	:= "%"			

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM      = '"+ _cUm    +"' "
_cFilLocal += " AND SD2.D2_SEGUM   = '"+ _cSegUm +"' "
_cFilLocal += " AND SB1.B1_COD     = '"+ _cCod   +"' "
_cFilLocal += " AND SD2.D2_FILIAL  = '"+ _cFil   +"' "
_cFilLocal += " AND SA1.A1_EST     = '"+ _cEst   +"' "
_cFilLocal += " AND SA1.A1_COD_MUN = '"+ _cMun   +"' "
_cFilLocal += " AND SF2.F2_VEND1   = '"+ _cVend  +"' "
_cFilLocal += "%"

_nRet := ROMS003Y( _cFilLocal , "D2_VALDEV" , _lValBrut )

Return( _nRet )

/*
===============================================================================================================================
Programa--------: ROMS003QK
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar o valor de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cEst			- Sigla da UF
----------------: _cMun			- Código do Município
----------------: _cVend		- Código do Vendedor
----------------: _cGrpVen		- Código do Grupo de Vendas
----------------: _cCodCli		- Código do Cliente
----------------: _cLojaCli		- Loja do Cliente
----------------: _lValBrut		- Flag de Valor Bruto
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003QK( _cUm , _cSegUm , _cCod , _cFil , _cMun , _cVend , _cGrpVen , _cCodCli , _cLojaCli , _lValBrut )

Local _nRet		:= 0
Local _cFilLocal	:= "%"

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM      = '"+ _cUm      +"' "
_cFilLocal += " AND SD2.D2_SEGUM   = '"+ _cSegUm   +"' "
_cFilLocal += " AND SB1.B1_COD     = '"+ _cCod     +"' "
_cFilLocal += " AND SD2.D2_FILIAL  = '"+ _cFil     +"' "
_cFilLocal += " AND SA1.A1_COD_MUN = '"+ _cMun     +"' "
_cFilLocal += " AND SF2.F2_VEND1   = '"+ _cVend    +"' "
_cFilLocal += " AND SA1.A1_GRPVEN  = '"+ _cGrpVen  +"' "
_cFilLocal += " AND SA1.A1_COD     = '"+ _cCodCli  +"' "
_cFilLocal += " AND SA1.A1_LOJA    = '"+ _cLojaCli +"' "
_cFilLocal += "%"

_nRet := ROMS003Y( _cFilLocal , "D2_VALDEV" , _lValBrut )

Return( _nRet )

/*
===============================================================================================================================
Programa--------: ROMS003QL
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar o valor de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cEst			- Sigla da UF
----------------: _lValBrut		- Flag de Valor Bruto
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003QL(_cUm, _cSegUm, _cCod, _cFil, _cEst, _lValBrut)

Local _nRet		:= 0
Local _cFilLocal	:= "%"		

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM = '"     + _cUm    + "' "
_cFilLocal += " AND SD2.D2_SEGUM = '"  + _cSegUm + "' "
_cFilLocal += " AND SB1.B1_GRUPO = '"  + _cCod   + "' "
_cFilLocal += " AND SD2.D2_FILIAL = '" + _cFil   + "' "   
_cFilLocal += " AND SD2.D2_EST = '"    + _cEst   + "' " 
_cFilLocal += "%"

nRet := ROMS003Y(_cFilLocal, "D2_VALDEV", _lValBrut)

Return( _nRet )

/*
===============================================================================================================================
Programa--------: ROMS003QN
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar o valor de devoluções
Parametros------: _cUm			- Primeira unidade de medida
----------------: _cSegUm		- Segunda unidade de medida
----------------: _cCod			- Código do Produto
----------------: _cFil			- Filial do documento
----------------: _cEst			- Sigla da UF
----------------: _dDtEmis		- Loja do Cliente
----------------: _lValBrut		- Flag de Valor Bruto
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003QN( _cUm , _cSegUm , _cCod , _cFil , _cEst , _dDtEmis , _lValBrut )

Local _nRet		:= 0
Local _cFilLocal	:= "%"			

//Filtro do agrupamento da linha do report
_cFilLocal += " AND SD2.D2_UM = '"       + _cUm           + "' "
_cFilLocal += " AND SD2.D2_SEGUM = '"    + _cSegUm        + "' "
_cFilLocal += " AND SB1.B1_COD = '"      + _cCod          + "' "
_cFilLocal += " AND SD2.D2_FILIAL = '"   + _cFil          + "' "   
_cFilLocal += " AND SD2.D2_EST = '"      + _cEst          + "' "   
_cFilLocal += " AND SD2.D2_EMISSAO = '"  + DtoS(_dDtEmis) + "' "
_cFilLocal += "%"

_nRet := ROMS003Y(_cFilLocal, "D2_VALDEV", _lValBrut) 

Return( _nRet )

/*
===============================================================================================================================
Programa--------: ROMS003Y
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao usada para verificar e retornar o valor de devoluções
Parametros------: _cFil			- Filial do documento
----------------: _cCampo		- Campo do Formulário
----------------: _lValBrut		- Flag de Valor Bruto
Retorno---------: _nRet			- Quantidade das devoluções
===============================================================================================================================
*/
Static Function ROMS003Y( _cFilLocal , _cCampo , _lValBrut )

local _nRet     := 0       
Local _aDadosDev:= {}//Array que armazenara os dados da devolucao 

if Select("QRYTMP") > 0
	QRYTMP->( dbCloseArea() )
endif

//Executa a mesma query principal, com as colunas numdoc e serie para filtrar as devolucoes contidas no grupo
BeginSql alias "QRYTMP"   	   	
	SELECT 			
	    SF2.F2_DOC,SF2.F2_SERIE,SD2.D2_VALDEV,SD2.D2_QTDEDEV,SD2.D2_FILIAL,SD2.D2_ICMSRET,SD2.D2_TOTAL,SD2.D2_QTSEGUM,SD2.D2_QUANT,SD2.D2_COD
	FROM 
		%table:SF2% SF2
		JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
		JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
		JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
		JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
		JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
		JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN 
		JOIN %table:SF4% SF4 ON sd2.d2_filial = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo
		JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
		LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
	WHERE 
		SF2.%notDel%  
		AND SD2.%notDel%  
		AND SA1.%notDel%  		
		AND SB1.%notDel%  					
		AND SA3.%notDel%  											
    	%exp:_cFilLocal%
		AND SBM.%notDel%				
		AND ACY.%notDel%		
		AND SF4.%notDel%
		AND SC5.%notDel%
    	%exp:_cfiltro%    	
EndSql
    
DBSelectArea("QRYTMP") 
QRYTMP->(dbGoTop())   
while QRYTMP->(!eof())          
                       
	//Chama funcao filDev que retorna os dados da devolucao das notas fiscais de saida, caso estas possuam devolucao
	_aDadosDev:= ROMS003I(QRYTMP->F2_DOC,QRYTMP->F2_SERIE,QRYTMP->D2_FILIAL,QRYTMP->D2_COD)
                    
   	//Se existe uma devolucao e ela se enquadra nos filtros dispostos na funcao fildev
   If _aDadosDev[1,1]
		   
		if 	_cCampo == "D2_VALDEV" .and. _lValBrut
	                                               
	        //D1_TOTAL + D1_ICMSRET
			_nRet += _aDadosDev[1,3] + _aDadosDev[1,4]
			
		ElseIf _cCampo == "D2_VALDEV" .and. !_lValBrut
		    
			//D1_TOTAL
			_nRet += _aDadosDev[1,3]
			
		ElseIf _cCampo == 'D2_QTDEDEV'   
	         
			//D1_QUANT
			_nRet += _aDadosDev[1,2]
		
		ElseIf _cCampo == 'D2_QTSEGUM'
	                            
			//D1_QTSEGUM
			_nRet += _aDadosDev[1,5]
			
		endif
		
	endif	 
  	
QRYTMP->(dbSkip())
enddo      

dbSelectArea("QRYTMP")
QRYTMP->(dbCloseArea())

return _nRet

/*
===============================================================================================================================
Programa--------: ROMS003G
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que monta o relatório no modelo gráfico
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003G()
    
Private oFont10
Private oFont10b
Private oFont12
Private oFont12b  
Private oFont16b           
Private oFont14
Private oFont14b

Private oPrint

Private nPagina     := 1

Private nLinha      := 0100
Private nLinhaInic  := 0100
Private nColInic    := 0030
Private nColFinal   := 3360 
Private nqbrPagina  := 2200 
Private nLinInBox   
Private nSaltoLinha := 50     
Private nAjuAltLi1  := 11 //ajusta a altura de impressao dos dados do relatorio 

Private oBrush      // := TBrush():New( ,CLR_LIGHTGRAY)
 
Private _lGeraEmExcel := .F. 

Begin Sequence
   If Valtype(oReport:oExcel) == "O" .Or. Valtype(oReport:nExcel) == "N" // Se True, indica que foi selecionado a opção pera gerar relatório em Excel.
      _lGeraEmExcel := .T. 
   EndIf

   If ! _lGeraEmExcel 
      oBrush := TBrush():New( ,CLR_LIGHTGRAY)
      Define Font oFont10    Name "Courier New"       Size 0,-08       // Tamanho 14    
      Define Font oFont10b   Name "Courier New"       Size 0,-08 Bold  // Tamanho 14 
      Define Font oFont12    Name "Courier New"       Size 0,-10       // Tamanho 12
      Define Font oFont12b   Name "Courier New"       Size 0,-10 Bold  // Tamanho 12 Negrito  

      Define Font oFont14    Name "Courier New"       Size 0,-10       // Tamanho 14
      Define Font oFont14b   Name "Courier New"       Size 0,-10 Bold  // Tamanho 14         
      Define Font oFont14Pr  Name "Courier New"       Size 0,-12       // Tamanho 14
      Define Font oFont14Prb Name "Courier New"       Size 0,-12 Bold  // Tamanho 14 Negrito
      Define Font oFont16b   Name "Helvetica"         Size 0,-14 Bold  // Tamanho 16 Negrito  

      oPrint:= TMSPrinter():New("PRODUTO/SUB GRUPO SINTETICO") 
      oPrint:SetPaperSize(9)	// Seta para papel A4
	                 		
      /// startando a impressora
      oPrint:Say(0,0," ",oFont12,100)        

      oPrint:StartPage() 
      //0 - para nao imprimir a numeracao de pagina na emissao da pagina de parametros
      ROMS003C(0)
      ROMS003P(oPrint)
   EndIf

   If _nOrdem == 12	//ORDEM 12
	  FWMSGRUN( ,{|oproc|  ROMS00312(oproc) } , "Aguarde!", "Lendo dados..."  )
   Else//_nOrdem 02 / _nOrdem 10 / _nOrdem 11
   	  FWMSGRUN( ,{|oproc|  ROMS003DR(oproc) } , "Aguarde!", "Lendo dados..."  )
   EndIf		

   If ! _lGeraEmExcel 
      oPrint:EndPage()	// Finaliza a Pagina.
      oPrint:Preview()	// Visualiza antes de Imprimir.
   EndIf

End Sequence

Return       

/*
===============================================================================================================================
Programa--------: ROMS003P
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime a pagina de parametros do relatório
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003P(oPrint)      

Local nAux     := 1   


IF oPrint <> NIL
	nLinha+= 60                                    
	oPrint:Line(nLinha,nColInic,nLinha,nColFinal)
	nLinha+= 55
ENDIF
    _aDadosParam := {}
    Aadd(_aDadosParam,{"01","Da Filial",mv_par01})
    Aadd(_aDadosParam,{"02","De Emissão",DTOC(mv_par02)})
    Aadd(_aDadosParam,{"03","Ate Emissão",DTOC(mv_par03)})
    Aadd(_aDadosParam,{"04","De Produto",mv_par04})
    Aadd(_aDadosParam,{"05","Ate Produto",mv_par05})
    Aadd(_aDadosParam,{"06","De Cliente",mv_par06})
    Aadd(_aDadosParam,{"07","Loja ",mv_par07})
    Aadd(_aDadosParam,{"08","Ate Cliente",mv_par08})
    Aadd(_aDadosParam,{"09","Loja ",mv_par09})
    Aadd(_aDadosParam,{"10","Rede",mv_par10})
    Aadd(_aDadosParam,{"11","Estado",mv_par11})
    Aadd(_aDadosParam,{"12","Municipio",mv_par12})
    Aadd(_aDadosParam,{"13","Vendedor",mv_par13})
    Aadd(_aDadosParam,{"14","Coordenador",mv_par14})
    Aadd(_aDadosParam,{"15","Grupo Produto",mv_par15})
    Aadd(_aDadosParam,{"16","Produto Nivel 2",mv_par16})
    Aadd(_aDadosParam,{"17","Produto Nivel 3",mv_par17})
    Aadd(_aDadosParam,{"18","Produto Nivel 4",mv_par18})


	If MV_PAR19 == 1
		_cmvpar19 := "Sintético"
	Elseif MV_PAR19 == 2
		_cmvpar19 := "Analítico"
	Else
		_cmvpar19 := "  "
	Endif

    Aadd(_aDadosParam,{"19","Relatorio",_cmvpar19})
    Aadd(_aDadosParam,{"20","CFOP's",mv_par20})

	If MV_PAR21 == 1
		_cmvpar21 := "Sim"
	Elseif MV_PAR21 == 2
		_cmvpar21 := "Não"
	Else
		_cmvpar21 := "Somente NF's SE"
	Endif

    Aadd(_aDadosParam,{"21","NF Sedex",_cmvpar21})

	If MV_PAR22 == 1
		_cmvpar22 := "Sim"
	Elseif MV_PAR22 == 2
		_cmvpar22 := "Não"
	Else
		_cmvpar22 := "   "
	Endif

    Aadd(_aDadosParam,{"22","Abate Devolucao",_cmvpar22})

	If MV_PAR23 == 1
		_cmvpar23 := "Form. Próprio"
	Elseif MV_PAR23 == 2
		_cmvpar23 := "Form. Cliente"
	Else
		_cmvpar23 := "Ambos"
	Endif

    Aadd(_aDadosParam,{"23","Tipo Devolucao",_cmvpar23})
    Aadd(_aDadosParam,{"24","Devolução de",DTOC(MV_PAR24)})
    Aadd(_aDadosParam,{"25","Devolução ate",DTOC(MV_PAR25)})

	If MV_PAR26 == 2
		_cmvpar26 := "Sim"
	Elseif MV_PAR26 == 3
		_cmvpar26 := "Não"
	Else
		_cmvpar26 := "Ambos"
	Endif

    Aadd(_aDadosParam,{"26","TES gera financeiro",_cmvpar26})
    Aadd(_aDadosParam,{"27","Sub Grupo Produto",mv_par27})


	If MV_PAR28 == 2
		_cmvpar28 := "Sim"
	Elseif MV_PAR28 == 3
		_cmvpar28 := "Não"
	Else
		_cmvpar28 := "Ambos"
	Endif

    Aadd(_aDadosParam,{"28","Considera Carga",_cmvpar28})

	If MV_PAR29 == 2
		_cmvpar29 := "Sim"
	Elseif MV_PAR29 == 3
		_cmvpar29 := "Não"
	Else
		_cmvpar29 := "Ambos"
	Endif

    Aadd(_aDadosParam,{"29","Somente com op logistico?",_cmvpar29})
    Aadd(_aDadosParam,{"30","Operadores Logisticos",MV_PAR30})

	If MV_PAR31 == 1
		_cmvpar31 := "Sim"
	Elseif MV_PAR31 == 2
		_cmvpar31 := "Não"
	Endif

    Aadd(_aDadosParam,{"31","Impr.Campos de Troca Nota",_cmvpar31})
	Aadd(_aDadosParam,{"32","Grupo Mix"                ,MV_PAR32})
	Aadd(_aDadosParam,{"33","Tipo de Operacao"         ,MV_PAR33})
	Aadd(_aDadosParam,{"34","Gerente"                  ,MV_PAR34})
	
    _aPergunte:={}
    For nAux := 1 To Len(_aDadosParam)
        
        IF oPrint <> NIL
		   oPrint:Say (nLinha,nColInic + 10  ,"Pergunta " + AllTrim(_aDadosParam[nAux,1]) + ' : ' + AllTrim(_aDadosParam[nAux,2]),oFont14Prb)    
           oPrint:Say (nLinha,nColInic + 1055  ,_aDadosParam[nAux,3],oFont14Prb) 
		   nlinha += 57   
        ENDIF

        AADD(_aPergunte,{"Pergunta " + _aDadosParam[nAux,1] + ':',_aDadosParam[nAux,2],_aDadosParam[nAux,3] })

    Next
	  
IF oPrint <> NIL
	nLinha += 57
	oPrint:Line(nLinha,nColInic,nLinha,nColFinal)
	oPrint:EndPage()     // Finaliza a página
ENDIF

Return _aPergunte
            
/*
===============================================================================================================================
Programa--------: ROMS003C
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime o cabeçalho das paginas do relatório
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003C(impNrPag)

Local cRaizServer := If(issrvunix(), "/", "\")    
Local cTitulo     := "Relação de Vendas Faturadas - Ordem " + aOrd[_nOrdem] + ". De " +  dtoc(mv_par02) + " até " + dtoc(mv_par03)
 
nLinha:=0100

oPrint:SayBitmap(nLinha,nColInic,cRaizServer + "system/lgrl01.bmp",250,100)        

If impNrPag <> 0
	oPrint:Say (nlinha,(nColInic + 2750),"PÁGINA: " + AllTrim(Str(nPagina)),oFont12b)
Else
	oPrint:Say (nlinha,(nColInic + 2750),"SIGA/ROMS003",oFont12b)
	oPrint:Say (nlinha + 100,(nColInic + 2750),"EMPRESA: " + AllTrim(SM0->M0_NOME) + '/' + AllTrim(SM0->M0_FILIAL),oFont12b)
EndIf

oPrint:Say (nlinha + 50,(nColInic + 2750),"DATA DE EMISSÃO: " + DtoC(DATE()),oFont12b)
nlinha+=(nSaltoLinha * 3)           
                                                   
oPrint:Say (nlinha,nColFinal / 2,cTitulo,oFont16b,nColFinal,,,2)

nlinha+=nSaltoLinha 
nlinha+=nSaltoLinha        

oPrint:Line(nLinha,nColInic,nLinha,nColFinal) 

Return()

/*
===============================================================================================================================
Programa--------: ROMS003CF
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime a pagina de cabeçalho por filial
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003CF(cCodFilial)

nLinha:= 0400
                                                                            
oPrint:FillRect({(nlinha+3),nColInic,nlinha + nSaltoLinha,nColFinal - 1270},oBrush)                    
oPrint:Box(nlinha,nColInic,nLinha + nSaltoLinha,nColFinal - 1270)
oPrint:Say (nlinha,nColInic + 25  ,"Filial:",oFont14Prb)
oPrint:Say (nlinha,nColInic + 230  ,SubStr(AllTrim(cCodFilial) + '-' + FWFilialName(,cCodFilial),1,50),oFont14Prb)

Return   

/*
===============================================================================================================================
Programa--------: ROMS003CS
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime a pagina de cabeçalho dos subgrupos
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003CS(cCodSubGru,cDesSubGru)

oPrint:FillRect({(nlinha+3),nColInic,nlinha + nSaltoLinha,nColFinal - 1270},oBrush)                    
oPrint:Box(nlinha,nColInic,nLinha + nSaltoLinha,nColFinal - 1270)
oPrint:Say (nlinha,nColInic + 25  ,"Sub Grupo: ",oFont14Prb)
oPrint:Say (nlinha,nColInic + 280  ,SubStr(AllTrim(cCodSubGru) + '-' + AllTrim(cDesSubGru),1,50),oFont14Prb)

Return                 

/*
===============================================================================================================================
Programa--------: ROMS003CP
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime a pagina de cabeçalho dos Coordenadores
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003CP(cCodSuperv,cDesSuupev)

oPrint:FillRect({(nlinha+3),nColInic,nlinha + nSaltoLinha,nColFinal - 1270},oBrush)                    
oPrint:Box(nlinha,nColInic,nLinha + nSaltoLinha,nColFinal - 1270)
oPrint:Say (nlinha,nColInic + 25  ,"Coordenador: ",oFont14Prb)
oPrint:Say (nlinha,nColInic + 325 ,SubStr(AllTrim(cCodSuperv) + '-' + AllTrim(cDesSuupev),1,50),oFont14Prb)

Return                 

/*
===============================================================================================================================
Programa--------: ROMS003CD
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime a pagina de cabeçalho dos dados do relatório
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003CD()        

nLinInBox:= nlinha

oPrint:FillRect({(nlinha+3),nColInic,nlinha + nSaltoLinha,nColFinal},oBrush)                    
                                    
oPrint:Say (nlinha,nColInic + 10  ,"Produto"	    ,oFont12b) 
oPrint:Say (nlinha,nColInic + 1190,"Quantidade"		,oFont12b)
oPrint:Say (nlinha,nColInic + 1440,"1a U.M."		,oFont12b)
oPrint:Say (nlinha,nColInic + 1720,"Qtde 2a U.M."	,oFont12b)
oPrint:Say (nlinha,nColInic + 2000,"2a U.M."		,oFont12b)
oPrint:Say (nlinha,nColInic + 2310,"Vlr.Unit"		,oFont12b)
oPrint:Say (nlinha,nColInic + 2690,"Vlr.Total"		,oFont12b)
oPrint:Say (nlinha,nColInic + 3100,"Vlr.Bruto"		,oFont12b)

Return     

/*
===============================================================================================================================
Programa--------: ROMS003SG
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime a pagina de cabeçalho dos subgrupos
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003SG()        

nLinInBox:= nlinha

oPrint:FillRect({(nlinha+3),nColInic,nlinha + nSaltoLinha,nColFinal},oBrush)                    
                                    
oPrint:Say (nlinha,nColInic + 10  ,"Sub Grupo"	    ,oFont12b) 
oPrint:Say (nlinha,nColInic + 1190,"Quantidade"		,oFont12b)
oPrint:Say (nlinha,nColInic + 1440,"1a U.M."		,oFont12b)
oPrint:Say (nlinha,nColInic + 1720,"Qtde 2a U.M."	,oFont12b)
oPrint:Say (nlinha,nColInic + 2000,"2a U.M."		,oFont12b)
oPrint:Say (nlinha,nColInic + 2310,"Vlr.Unit"		,oFont12b)
oPrint:Say (nlinha,nColInic + 2690,"Vlr.Total"		,oFont12b)
oPrint:Say (nlinha,nColInic + 3100,"Vlr.Bruto"		,oFont12b)

Return

/*
===============================================================================================================================
Programa--------: ROMS003N
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime os dados do relatório
Parametros------: cProduto,nqtde1um,um1,nqtde2um,um2,nVlrTotal,nVlrBruto
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003N(cProduto,nqtde1um,um1,nqtde2um,um2,nVlrTotal,nVlrBruto)

oPrint:Say (nlinha,nColInic + 10  ,SubStr(cProduto,1,58)				                ,oFont10) 
oPrint:Say (nlinha,nColInic + 1120,Transform(nqtde1um,"@E 9,999,999,999.99")			,oFont10)
oPrint:Say (nlinha,nColInic + 1440,um1													,oFont10)
oPrint:Say (nlinha,nColInic + 1680,Transform(nqtde2um,"@E 9,999,999,999.99")			,oFont10)
oPrint:Say (nlinha,nColInic + 2000,um2													,oFont10)
oPrint:Say (nlinha,nColInic + 2200,Transform(nVlrTotal / nqtde1um,"@E 99,999,999.9999")	,oFont10)
oPrint:Say (nlinha,nColInic + 2595,Transform(nVlrTotal,"@E 9,999,999,999.99")			,oFont10)
oPrint:Say (nlinha,nColInic + 3010,Transform(nVlrBruto,"@E 9,999,999,999.99")			,oFont10)

Return                    

/*
===============================================================================================================================
Programa--------: ROMS003PT
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime os totalizadores do relatório
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003PT(cProduto,nqtde1um,nqtde2um,nVlrTotal,nVlrBruto)

oPrint:Say (nlinha,nColInic + 10  ,SubStr(cProduto,1,58)				                    ,oFont10b) 
oPrint:Say (nlinha,nColInic + 1120,Transform(nqtde1um,"@E 9,999,999,999.99")				,oFont10b)
oPrint:Say (nlinha,nColInic + 1680,Transform(nqtde2um,"@E 9,999,999,999.99")				,oFont10b)
oPrint:Say (nlinha,nColInic + 2200,Transform(nVlrTotal / nqtde1um,"@E 99,999,999.9999")	,oFont10b)
oPrint:Say (nlinha,nColInic + 2595,Transform(nVlrTotal,"@E 9,999,999,999.99")				,oFont10b)
oPrint:Say (nlinha,nColInic + 3010,Transform(nVlrBruto,"@E 9,999,999,999.99")				,oFont10b)

Return                    

/*
===============================================================================================================================
Programa--------: ROMS003BD
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime o box de divisão dos dados do relatório
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003BD()

oPrint:Line(nLinInBox,1100,nLinha,1100)//PRODUTO   
oPrint:Line(nLinInBox,1450,nLinha,1450)//QUANTIDADE
oPrint:Line(nLinInBox,1620,nLinha,1620)//1 U.M.   
oPrint:Line(nLinInBox,2010,nLinha,2010)//QUANTIDADE 2 U.M.
oPrint:Line(nLinInBox,2190,nLinha,2190)//2a U.M.     
oPrint:Line(nLinInBox,2530,nLinha,2530)//VALOR UNITARIO
oPrint:Line(nLinInBox,2930,nLinha,2930)//VALOR TOTAL

oPrint:Box(nLinInBox,nColInic,nLinha,nColFinal)

Return    

/*
===============================================================================================================================
Programa--------: ROMS003DR
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que consulta e prepara os dados para serem impressos no relatório
Parametros------: oproc
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003DR(oproc)     

Local oAlias       :=GetNextAlias()
Local aFilial      := {} //Para controlar a quebra por Filial do Relatorio
Local aProduto     := {} //Para controla a quebra de grupo de produto/Produto por Filial  
Local aSubGrupo    := {} //Para controla a quebra de grupo de sub grupo por Filial  
Local nPosFilial       
Local nPosProdut                    

Local nTotSQtde1    := 0 
Local nTotSQtde2    := 0   
Local nTotSVlTot    := 0
Local nTotSVlBru    := 0                         

Local nTotQtde1    := 0 
Local nTotQtde2    := 0   
Local nTotVlTot    := 0
Local nTotVlBru    := 0   

Local nTotGQtde1   := 0  
Local nTotGQtde2   := 0   
Local nTotGVlTot   := 0
Local nTotGVlBru   := 0

Local nQtde1       := 0 
Local nQtde2       := 0
Local nTotal       := 0
Local nVlBru       := 0              

Local nPosSuperv   := 0
Local cDesSuperv   := ""
Local aSupevisor   := {}
Local aProdSuprv   := {}
Local nPosSuprv    := 0
Local _cDescSubg   := ""

Local _aTitulos := {}, _aDadosExcel := {}
Local _cTitulo, _cNomeFil, _nI

Begin Sequence
   //========================================== 
   // ORDEM PRODUTO - ORDEM 10 - Só Sintetico
   //==========================================
    If _nOrdem == 10 // ORDEM 10 - Só Sintetico	

      oproc:cCaption := ("Lendo Dados - Pre-processamento 1/2" )
      ProcessMessages()

	  BeginSql alias oAlias   	   	
		SELECT 			
				SUM(T.D2_QUANT)   AS D2_QUANT,
				AVG(T.D2_PRCVEN)  AS D2_PRCVEN,
				SUM(T.D2_TOTAL)   AS D2_TOTAL,				
				SUM(T.D2_VALBRUT) AS D2_VALBRUT,								
				SUM(T.D2_QTSEGUM) AS D2_QTSEGUM,
				SUM(T.D2_COMIS1)  AS D2_COMIS1,  
				SUM(T.D2_I_FRET)  AS D2_I_FRET,				
				SUM(T.D2_CUSTO1)  AS D2_CUSTO1,
				SUM(T.D2_QTDEDEV) AS D2_QTDEDEV,
				SUM(T.D2_VALDEV)  AS D2_VALDEV,				
				SUM(T.D2_ICMSRET) AS D2_ICMSRET,				
			    SUM(T.VLRBRUTDEV) AS VLRBRUTDEV,
				T.D2_UM,T.D2_SEGUM,T.B1_I_DESCD,T.B1_COD,T.D2_FILIAL,T.C5_I_LOCEM
        FROM
		(SELECT 			

			SUM(SD2.D2_QUANT)   AS D2_QUANT,
			AVG(SD2.D2_PRCVEN)  AS D2_PRCVEN,
			SUM(SD2.D2_TOTAL)   AS D2_TOTAL,				
			SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,								
			SUM(SD2.D2_QTSEGUM) AS D2_QTSEGUM,
			SUM(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
			SUM(SD2.D2_I_FRET)  AS D2_I_FRET,
			SUM(SD2.D2_CUSTO1)  AS D2_CUSTO1,
			SUM(SD2.D2_ICMSRET) AS D2_ICMSRET,	  		
			SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SD2.D2_FILIAL,SC5.C5_I_LOCEM,
			SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD,
			(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			   FROM SD1010 D1
			   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			   WHERE D1.D_E_L_E_T_ = ' '
			     AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			     AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			     AND D1.D1_NFORI   = SD2.D2_DOC
			     AND D1.D1_SERIORI = SD2.D2_SERIE
			     AND D1.D1_FORNECE = SD2.D2_CLIENTE
			     AND D1.D1_LOJA    = SD2.D2_LOJA    
			     AND D1.D1_COD     = SD2.D2_COD 
			   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
			(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			   FROM SD1010 D1
			   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			   WHERE D1.D_E_L_E_T_ = ' '
			     AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			     AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			     AND D1.D1_NFORI   = SD2.D2_DOC
			     AND D1.D1_SERIORI = SD2.D2_SERIE
			     AND D1.D1_FORNECE = SD2.D2_CLIENTE
			     AND D1.D1_LOJA    = SD2.D2_LOJA    
			     AND D1.D1_COD     = SD2.D2_COD
		       ) AS D2_VALDEV, ///*************************** D2_VALDEV
			(SUM(SD2.D2_VALBRUT)  -
			(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			   FROM SD1010 D1
			   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			   WHERE D1.D_E_L_E_T_ = ' '
			     AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			     AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			     AND D1.D1_NFORI   = SD2.D2_DOC
			     AND D1.D1_SERIORI = SD2.D2_SERIE
			     AND D1.D1_FORNECE = SD2.D2_CLIENTE
			     AND D1.D1_LOJA    = SD2.D2_LOJA    
			     AND D1.D1_COD     = SD2.D2_COD
		    )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV

		 FROM 
			%table:SF2% SF2
			JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
			JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
			JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
			JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
			JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
			JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
			JOIN %table:SF4% SF4 ON sd2.d2_filial = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo
			JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
			LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
		 WHERE 
			SF2.%notDel%  
			AND SD2.%notDel%  
			AND SA1.%notDel%  		
			AND SB1.%notDel%  					
			AND SA3.%notDel%  											
			AND SBM.%notDel%				
			AND ACY.%notDel%
			AND SF4.%notDel%
			AND SC5.%notDel%
		   	%exp:_cfiltro%
		 GROUP BY 
 			SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SD2.D2_FILIAL,SC5.C5_I_LOCEM,
			SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD
		) T
		 GROUP BY 
 			T.D2_UM,T.D2_SEGUM,T.B1_I_DESCD,T.B1_COD,T.D2_FILIAL,T.C5_I_LOCEM

		 ORDER BY 
			T.D2_FILIAL,T.B1_COD,T.C5_I_LOCEM
	  EndSql                       
		    
      //ProcRegua((oAlias)->(RecCount())) 	
      _nTot:=nConta:=0
      COUNT TO _nTot
      _cTotGeral:=ALLTRIM(STR(_nTot))
	  (oAlias)->(DBGOTOP())

      //==========================================================================
      // Imprime Relatório em Excel
      //==========================================================================
      If _lGeraEmExcel 
         _aTitulos := {"Filial",;            // 01                          
                       "Nome Filial",;       // 02                            
                       "Fil. Embarque",;     // 03                   
                       "Produto",;           // 04                        
                        "Descrição Produto",;// 05                                   
                       "Quantidade",;        // 06                           
                       "1a U.M.",;           // 07                        
                       "Qtde 2a U.M.",;      // 08                             
                       "2a U.M.",;           // 09                        
                       "Vlr.Unit",;          // 10                         
                       "Vlr.Total",;         // 11                          
                       "Vlr.Bruto"}          // 12              
					              
	// Alinhamento: 1-Left   ,2-Center,3-Right           
	// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
	//             Titulo das Colunas   ,Alinhamento ,Formatação, Totaliza?
	//               Titulo             ,1           ,1         ,.F./.T.   })
      aCabXML   := {{"Filial"           ,2           ,1         ,.F. },;// 01
                    {"Nome Filial"      ,1           ,1         ,.F. },;// 02
                    {"Fil. Embarque"    ,1           ,1         ,.F. },;// 03
                    {"Produto"          ,2           ,1         ,.F. },;// 04
                    {"Descrição Produto",1           ,1         ,.F. },;// 05
                    {"Quantidade"       ,3           ,2         ,.F. },;// 06
                    {"1a U.M."          ,2           ,1         ,.F. },;// 07
                    {"Qtde 2a U.M."     ,3           ,2         ,.F. },;// 08
                    {"2a U.M."          ,2           ,1         ,.F. },;// 09
                    {"Vlr.Unit"         ,3           ,3         ,.F. },;// 10
					{"Vlr.Total"        ,3           ,3         ,.F. },;// 11
                    {"Vlr.Bruto"        ,3           ,3         ,.F. } }// 12


          _cTitulo := "Relação de Vendas Faturadas - Ordem 10 - Produto Sintético"

          Do While (oAlias)->(!Eof())  
//             IncProc("Os dados do Relatorio estado sendo Processados...")   
             IF oproc <> NIL
                nConta++
                oproc:cCaption := ("Lendo : "+STRZERO(nConta,5) +" de "+ _cTotGeral )
                ProcessMessages()
             ENDIF

	         //Efetua o somatorio dos dados de acordo com o parametro considera devolucoes 
	         //MV_PAR22 == 2 Nao considera devolucoes
	         nQtde1:= IF(MV_PAR22 == 2,(oAlias)->D2_QUANT  ,(oAlias)->D2_QUANT  -(oAlias)->D2_QTDEDEV                                                  )
	         nQtde2:= IF(MV_PAR22 == 2,(oAlias)->D2_QTSEGUM,(oAlias)->D2_QTSEGUM-ROMS003L((oAlias)->D2_QUANT,(oAlias)->D2_QTDEDEV,(oAlias)->D2_QTSEGUM))
	         nTotal:= IF(MV_PAR22 == 2,(oAlias)->D2_TOTAL  ,(oAlias)->D2_TOTAL  -(oAlias)->D2_VALDEV                                                   )
	         nVlBru:= IF(MV_PAR22 == 2,(oAlias)->D2_VALBRUT,(oAlias)->VLRBRUTDEV                                                                       )

			 _cNomeFil := FWFilialName(,(oAlias)->D2_FILIAL)
			 _cFilEmba := POSICIONE("ZEL",1,xFilial("ZEL")+(oAlias)->C5_I_LOCEM,"ZEL_DESCRI")

		     Aadd(_aDadosExcel,{(oAlias)->D2_FILIAL,;    // 01 - Filial
		                        _cNomeFil,;              // 02 - Nome Filial
                                _cFilEmba,;              // 03 - "Fil. Embarq"     
                                (oAlias)->B1_COD,;       // 04 - Produto
                                (oAlias)->B1_I_DESCD,;   // 05 - Descrição Produto
							    nQtde1,;                 // 06 - Quantidade na primeira unidade de Medida
						  	    (oAlias)->D2_UM,;        // 07 - Primeira unidade de Medida  
						  	    nQtde2,;                 // 08 - Quantidade na segunda unidade de Medida 
						  	    (oAlias)->D2_SEGUM,;     // 09 - Segunda unidade de Medida  
							    nTotal / nQtde1 ,;       // 10 - Valor Unitario 
						  	    nTotal,;                 // 11 - Valor Total 
						  	    nVlBru;                  // 12 - Valor Bruto 
						  	    })      

	        (oAlias)->(dbSkip())	 
	     EndDo
 
         If Empty(_aDadosExcel)
            U_ITMSG("Não foram encontrados dados para emissão do relatório em Excel que satisfaçam as condições de filtro.","Atenção", ,1)
	     Else
	        _aSX1:=ROMS003P()     
		    _cMsgTop:= _cTitulo+" / Exportação disponiveis: XML / CSV / EXCEL / ARQUIVO"
		                             //      ,_aCols     ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab  , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1 )
	        U_ITListBox(_cTitulo , _aTitulos , _aDadosExcel , .T.    , 1    ,_cMsgTop,          ,        ,         ,     ,        ,          ,aCabXML,         ,          ,           ,         ,       ,          ,_aSX1)
         EndIf

	     Break  // Finaliza a emissão do relatóriio em Excel de Produtos Sintético.
      EndIf

      oproc:cCaption := ("Lendo Dados - Pre-processamento 2/2" )
      ProcessMessages()
      //==========================================================================
      // Imprime Relatório Impresso.
      //==========================================================================
      If (oAlias)->(!Eof())
  	     ROMS003C(1)
      EndIf       
		
      Do While (oAlias)->(!Eof())	
         //IncProc("Os dados estão sendo processados, favor aguardar...") 
         IF oproc <> NIL
            nConta++
            oproc:cCaption := ("Lendo : "+STRZERO(nConta,5) +" de "+ _cTotGeral )
            ProcessMessages()
         ENDIF
	
	     nPosFilial:=aScan(aFilial,{|x| x[1] == AllTrim((oAlias)->D2_FILIAL)})   
	                                            
	     //Efetua o somatorio dos dados de acordo com o parametro considera devolucoes 
	     //MV_PAR22 == 2 Nao considera devolucoes
	     nQtde1:= IIF(MV_PAR22 == 2,(oAlias)->D2_QUANT  ,(oAlias)->D2_QUANT  -(oAlias)->D2_QTDEDEV                                                  )
	     nQtde2:= IIF(MV_PAR22 == 2,(oAlias)->D2_QTSEGUM,(oAlias)->D2_QTSEGUM-ROMS003L((oAlias)->D2_QUANT,(oAlias)->D2_QTDEDEV,(oAlias)->D2_QTSEGUM))
	     nTotal:= IIF(MV_PAR22 == 2,(oAlias)->D2_TOTAL  ,(oAlias)->D2_TOTAL  -(oAlias)->D2_VALDEV                                                   )
	     nVlBru:= IIF(MV_PAR22 == 2,(oAlias)->D2_VALBRUT,(oAlias)->VLRBRUTDEV                                                                       )
	
	     //Efetua somatorio dos totalizadores geral
	     nTotGQtde1 += nQtde1
	     nTotGQtde2 += nQtde2  
	     nTotGVlTot += nTotal
	     nTotGVlBru += nVlBru       
	
	     //Efetua o somatorio dos dados do Produtos para o Resumo Geral
	     nPosProdut:=aScan(aProduto,{|x| x[1] == AllTrim((oAlias)->B1_COD)})     
	
	     If nPosProdut > 0   
		    aProduto[nPosProdut,2]+= nQtde1 //Quantidade primeira unidade de medida
		    aProduto[nPosProdut,4]+= nQtde2 //Quantidade segunda unidade de medida
		    aProduto[nPosProdut,6]+= nTotal //Valor total 
		    aProduto[nPosProdut,7]+= nVlBru //Valor Bruto
		 Else                         
		    aAdd(aProduto,{AllTrim((oAlias)->B1_COD),;//01
			                                  nQtde1,;//02
							  (oAlias)->D2_UM,nQtde2,;//03
							      (oAlias)->D2_SEGUM,;//04
								              nTotal,;//05
											  nVlBru,;//06
								(oAlias)->B1_I_DESCD})//07
  	     EndIf
		      
	     //Verifica se ja existe dados da Filial Lancados anteriormente
	     If nPosFilial > 0                
		    //Efetua somatorio dos totalizadores por Filial
		    nTotQtde1 += nQtde1
		    nTotQtde2 += nQtde2  
		    nTotVlTot += nTotal
		    nTotVlBru += nVlBru
		                                
		    nlinha+=nSaltoLinha   
		    oPrint:Line(nLinha,nColInic,nLinha,nColFinal)             
		    ROMS003QP(0,0)
		     //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
		    //       cProduto                                              ,nqtde1um,um1            ,nqtde2um,um2               ,nVlrTotal,nVlrBruto
		    ROMS003N(AllTrim((oAlias)->B1_COD) + '-' + (oAlias)->B1_I_DESCD,nQtde1  ,(oAlias)->D2_UM,nQtde2  ,(oAlias)->D2_SEGUM,nTotal   ,nVlBru)
		     //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
		 Else
			//Imprime o box e divisorias do produto anterior
		 	If Len(aFilial) > 0
		 	   nlinha+=nSaltoLinha                                  
		 	   oPrint:Line(nLinha,nColInic,nLinha,nColFinal)   
		 	   ROMS003QP(0,0)
		 	   //Imprime totalizador por Produto          
		 	   ROMS003PT('TOTAL:',nTotQtde1,nTotQtde2,nTotVlTot,nTotVlBru)
		 	   nlinha+=nSaltoLinha
		 	   ROMS003BD()   	 
		 			
		 	   //Forca quebra de pagina por Filial
		 	   nlinha:= 5000     
		 	   ROMS003QP(0,1)
		 	EndIf  
		 	                                                   
		 	//Adiciona ao controle de filiais a nova filial
		 	aAdd(aFilial,{AllTrim((oAlias)->D2_FILIAL)})      
		 	
			//Efetua somatorio dos totalizadores por Filial - setando
			nTotQtde1 := nQtde1
			nTotQtde2 := nQtde2  
			nTotVlTot := nTotal
			nTotVlBru := nVlBru
		 			
		    nlinha+=nSaltoLinha                
			ROMS003QP(0,1)
		    //Imprime cabecalho da Filial
			ROMS003CF((oAlias)->D2_FILIAL)        
					                                        
			nlinha+=nSaltoLinha
			nlinha+=nSaltoLinha                
			ROMS003QP(0,1)   
			//Imprime cabecalho dos dados do produto
			ROMS003CD()
					
			nlinha+=nSaltoLinha   
			oPrint:Line(nLinha,nColInic,nLinha,nColFinal)             
			ROMS003QP(0,0)
		     //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
		    //       cProduto                                              ,nqtde1um,um1          ,nqtde2um,um2             ,nVlrTotal,nVlrBruto
			ROMS003N(AllTrim((oAlias)->B1_COD) + '-' + (oAlias)->B1_I_DESCD,nQtde1,(oAlias)->D2_UM,nQtde2,(oAlias)->D2_SEGUM,nTotal,nVlBru)
		     //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
	     EndIf	

         (oAlias)->(dbSkip())
      EndDo	        
                 
      If Len(aFilial) > 0
	     //Imprime o ultimo totalizador
	     nlinha+=nSaltoLinha                                  
	     oPrint:Line(nLinha,nColInic,nLinha,nColFinal)
	     ROMS003QP(1,0)
	     //Imprime totalizador por Filial                  
	     ROMS003PT('TOTAL:',nTotQtde1,nTotQtde2,nTotVlTot,nTotVlBru)
	     nlinha+=nSaltoLinha
	     ROMS003BD()   	
	
	     nlinha+=nSaltoLinha     
	     ROMS003QP(0,0)  
	     //Imprime totalizador por Filial                  
	     ROMS003PT('TOTAL GERAL:',nTotGQtde1,nTotGQtde2,nTotGVlTot,nTotGVlBru)
      EndIf           

      //EMITE A PARTE DE RESUMO GERAL ONDE TOTALIZA OS PRODUTOS SEM DISTINCAO DE FILIAL, CASO TENHA MAIS DE UMA FILIAL,
      //POIS SENAO OS DADOS SERAO OS MESMOS DA FILIAL
      If Len(aFilial) > 1
	     //Ordena por codigo do produto os dados do resumo geral
	     aProduto:= aSort(aProduto,,,{|x, y| x[1] < y[1]})  
	
	     oPrint:EndPage()					// Finaliza a Pagina.
	     oPrint:StartPage()					//Inicia uma nova Pagina					
	     nPagina++
	     ROMS003C(1)//Chama cabecalho                       
	     nLinInBox:= nLinha 
	                                 
	     nlinha+=nSaltoLinha
	     oPrint:FillRect({(nlinha+3),nColInic,nlinha + nSaltoLinha,nColFinal},oBrush)  
	     oPrint:Box(nlinha,nColInic,nLinha + nSaltoLinha,nColFinal)
	     oPrint:Say (nlinha,nColFinal / 2,"RESUMO GERAL",oFont16b,nColFinal,,,2)  
	     nlinha+=nSaltoLinha                             
	     //Imprime cabecalho dos dados do produto
	     ROMS003CD()
	
	     For _nI:=1 to Len(aProduto)
		     nlinha+=nSaltoLinha   
		     oPrint:Line(nLinha,nColInic,nLinha,nColFinal)             
		     ROMS003QP(0,0)
		     //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
			 //       cProduto                               ,nqtde1um       ,um1            ,nqtde2um       ,um2            ,nVlrTotal      ,nVlrBruto
		     ROMS003N(aProduto[_nI,1] + '-' + aProduto[_nI,8],aProduto[_nI,2],aProduto[_nI,3],aProduto[_nI,4],aProduto[_nI,5],aProduto[_nI,6],aProduto[_nI,7])
		     //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
	     Next _nI
	
         nlinha+=nSaltoLinha
         oPrint:Line(nLinha,nColInic,nLinha,nColFinal)                  
         ROMS003QP(0,0)  
         //Imprime totalizador por Filial                  
         ROMS003PT('TOTAL GERAL:',nTotGQtde1,nTotGQtde2,nTotGVlTot,nTotGVlBru)     
         nlinha+=nSaltoLinha 
         ROMS003BD()
      EndIf       
   
   //==============================================
   // Orderm Sub Grupo Sintetico
   //==============================================
   ElseIf _nOrdem == 11 // ORDEM 11 - Só Sintetico

      oproc:cCaption := ("Lendo Dados - Pre-processamento 1/2" )
      ProcessMessages()

      BeginSql alias oAlias   	   	
		SELECT 			
				SUM(T.D2_QUANT)   AS D2_QUANT,
				AVG(T.D2_PRCVEN)  AS D2_PRCVEN,
				SUM(T.D2_TOTAL)   AS D2_TOTAL,				
				SUM(T.D2_VALBRUT) AS D2_VALBRUT,								
				SUM(T.D2_QTSEGUM) AS D2_QTSEGUM,
				SUM(T.D2_COMIS1)  AS D2_COMIS1,  
				SUM(T.D2_I_FRET)  AS D2_I_FRET,				
				SUM(T.D2_CUSTO1)  AS D2_CUSTO1,
				SUM(T.D2_QTDEDEV) AS D2_QTDEDEV,
				SUM(T.D2_VALDEV)  AS D2_VALDEV,				
				SUM(T.D2_ICMSRET) AS D2_ICMSRET,				
			    SUM(T.VLRBRUTDEV) AS VLRBRUTDEV,
				T.D2_UM,T.D2_SEGUM,T.B1_I_DESCD,T.B1_COD,T.B1_I_SUBGR,T.D2_FILIAL
        FROM
		(SELECT 			
		    SUM(SD2.D2_QUANT)   AS D2_QUANT,
			AVG(SD2.D2_PRCVEN)  AS D2_PRCVEN,
			SUM(SD2.D2_TOTAL)   AS D2_TOTAL,				
			SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,								
			SUM(SD2.D2_QTSEGUM) AS D2_QTSEGUM,
			SUM(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
			SUM(SD2.D2_I_FRET)  AS D2_I_FRET,
			SUM(SD2.D2_CUSTO1)  AS D2_CUSTO1,
			SUM(SD2.D2_ICMSRET) AS D2_ICMSRET,	  		
			SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SB1.B1_I_SUBGR,SD2.D2_FILIAL,
			SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD,
			(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			   FROM SD1010 D1
			   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			   WHERE D1.D_E_L_E_T_ = ' '
			     AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			     AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			     AND D1.D1_NFORI   = SD2.D2_DOC
			     AND D1.D1_SERIORI = SD2.D2_SERIE
			     AND D1.D1_FORNECE = SD2.D2_CLIENTE
			     AND D1.D1_LOJA    = SD2.D2_LOJA    
			     AND D1.D1_COD     = SD2.D2_COD 
			   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
			(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			   FROM SD1010 D1
			   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			   WHERE D1.D_E_L_E_T_ = ' '
			     AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			     AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			     AND D1.D1_NFORI   = SD2.D2_DOC
			     AND D1.D1_SERIORI = SD2.D2_SERIE
			     AND D1.D1_FORNECE = SD2.D2_CLIENTE
			     AND D1.D1_LOJA    = SD2.D2_LOJA    
			     AND D1.D1_COD     = SD2.D2_COD
		       ) AS D2_VALDEV, ///*************************** D2_VALDEV
			(SUM(SD2.D2_VALBRUT)  -
			(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			   FROM SD1010 D1
			   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			   WHERE D1.D_E_L_E_T_ = ' '
			     AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			     AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			     AND D1.D1_NFORI   = SD2.D2_DOC
			     AND D1.D1_SERIORI = SD2.D2_SERIE
			     AND D1.D1_FORNECE = SD2.D2_CLIENTE
			     AND D1.D1_LOJA    = SD2.D2_LOJA    
			     AND D1.D1_COD     = SD2.D2_COD
		    )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV
		 FROM 
			%table:SF2% SF2
		       JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
		       JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
		       JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
		       JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
		       JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
		       JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
		       JOIN %table:SF4% SF4 ON sd2.d2_filial = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo
			   JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
		       LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
		 WHERE 
		    SF2.%notDel%  
			AND SD2.%notDel%  
			AND SA1.%notDel%  		
			AND SB1.%notDel%  					
			AND SA3.%notDel%  											
			AND SBM.%notDel%				
			AND ACY.%notDel%
			AND SF4.%notDel%
			AND SC5.%notDel%
		    %exp:_cfiltro%
		 GROUP BY 
 			SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SB1.B1_I_SUBGR,SD2.D2_FILIAL,
			SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD
		) T
		 GROUP BY 
 			T.D2_UM,T.D2_SEGUM,T.B1_I_DESCD,T.B1_COD,T.B1_I_SUBGR,T.D2_FILIAL
		 ORDER BY 
			T.D2_FILIAL,T.B1_I_SUBGR,T.B1_COD
	  EndSql    
		
	  //ProcRegua((oAlias)->(RecCount())) 	
      _nTot:=nConta:=0
      COUNT TO _nTot
      _cTotGeral:=ALLTRIM(STR(_nTot))
	  (oAlias)->(DBGOTOP())

	  //==========================================================================
      // Imprime Relatório em Excel
      //==========================================================================
      If _lGeraEmExcel 
         _aTitulos := {"Filial",;              // 01
                       "Desc.Filial",;         // 02
                       "Codigo Grupo",;        // 03
                       "Descrição Grupo",;     // 04  
                       "Quantidade",;          // 05
                       "1a U.M.",;             // 06
                       "Qtde 2a U.M.",;        // 07
                       "2a U.M.",;	           // 08
                       "Vlr.Unit",;	           // 09
                       "Vlr.Total",;	       // 10
                       "Vlr.Bruto"}	           // 11

	// Alinhamento: 1-Left   ,2-Center,3-Right
	// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
	//             Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
	//               Titulo           ,1           ,1         ,.F./.T.   })
      aCabXML   := {{"Filial"         ,2           ,1         ,.F. },;
                    {"Desc.Filial"    ,1           ,1         ,.F. },;
                    {"Codigo Grupo"   ,2           ,1         ,.F. },;
                    {"Descrição Grupo",1           ,1         ,.F. },;
                    {"Quantidade"     ,3           ,2         ,.F. },;
                    {"1a U.M."        ,2           ,1         ,.F. },;
                    {"Qtde 2a U.M."   ,3           ,2         ,.F. },;
                    {"2a U.M."        ,2           ,1         ,.F. },;
                    {"Vlr.Unit"       ,3           ,3         ,.F. },;
					{"Vlr.Total"      ,3           ,3         ,.F. },;
                    {"Vlr.Bruto"      ,3           ,3         ,.F. }}
                       
          _cTitulo := "Relação de Vendas Faturadas - Ordem 11 - SubGrupo Sintético"

          Do While (oAlias)->(!Eof())  
             //IncProc("Os dados do Relatorio estado sendo Processados...")   
             IF oproc <> NIL
                nConta++
                oproc:cCaption := ("Lendo : "+STRZERO(nConta,5) +" de "+ _cTotGeral )
                ProcessMessages()
             ENDIF

	         // Efetua o somatorio dos dados de acordo com o parametro considera devolucoes 
		     // MV_PAR22 == 2 Nao considera devolucoes
	         nQtde1:= IIF(MV_PAR22 == 2,(oAlias)->D2_QUANT  ,(oAlias)->D2_QUANT  -(oAlias)->D2_QTDEDEV                                                  )
	         nQtde2:= IIF(MV_PAR22 == 2,(oAlias)->D2_QTSEGUM,(oAlias)->D2_QTSEGUM-ROMS003L((oAlias)->D2_QUANT,(oAlias)->D2_QTDEDEV,(oAlias)->D2_QTSEGUM))
	         nTotal:= IIF(MV_PAR22 == 2,(oAlias)->D2_TOTAL  ,(oAlias)->D2_TOTAL  -(oAlias)->D2_VALDEV                                                   )
	         nVlBru:= IIF(MV_PAR22 == 2,(oAlias)->D2_VALBRUT,(oAlias)->VLRBRUTDEV                                                                       )
             
			 _cNomeFil  := FWFilialName(,(oAlias)->D2_FILIAL)
			 _cDescSubg := POSICIONE("ZB9",1,xFilial("ZB9")+(oAlias)->B1_I_SUBGR,"ZB9_DESSUB")

             _nI := Ascan(_aDadosExcel, {|x| x[1]+x[3] == (oAlias)->D2_FILIAL+(oAlias)->B1_I_SUBGR} ) 
             If _nI == 0
			    // Filial	Desc.Filial	Codigo Grupo	Descrição Grupo	Quantidade	1a U.M.	Qtde 2a U.M.	2a U.M.	Vlr.Unit	Vlr.Total	Vlr.Bruto
		        Aadd(_aDadosExcel,{(oAlias)->D2_FILIAL,;    // 01 - Filial
		                           _cNomeFil,;              // 02 - Nome Filial
                                   (oAlias)->B1_I_SUBGR,;   // 03 - SubGrupo  
					 	           _cDescSubg,;             // 04 - Descrição SubGrupo
							       nQtde1,;                 // 05 - Quantidade na primeira unidade de Medida
						  	       (oAlias)->D2_UM,;        // 06 - Primeira unidade de Medida  
						  	       nQtde2,;                 // 07 - Quantidade na segunda unidade de Medida 
						  	       (oAlias)->D2_SEGUM,;     // 08 - Segunda unidade de Medida  
							       nTotal / nQtde1 ,;       // 09 - Valor Unitario 
						  	       nTotal,;                 // 10 - Valor Total 
						  	       nVlBru;                  // 11 - Valor Bruto 
						  	       })      
			 Else
                _aDadosExcel[_nI,5]  += nQtde1              // 05 - Quantidade na primeira unidade de Medida
				_aDadosExcel[_nI,7]  += nQtde2              // 07 - Quantidade na segunda unidade de Medida 
                _aDadosExcel[_nI,10] += nTotal              // 10 - Valor Total 
				_aDadosExcel[_nI,11] += nVlBru              // 11 - Valor Bruto    
				_aDadosExcel[_nI,9]  := _aDadosExcel[_nI,10] / _aDadosExcel[_nI,5] // 9  - Valor Unitario 
			 EndIf

	        (oAlias)->(dbSkip())	 
	     EndDo
 
         If Empty(_aDadosExcel)
            U_ITMSG("Não foram encontrados dados para emissão do relatório em Excel que satisfaçam as condições de filtro.","Atenção", ,1)
	     Else
	        _aSX1:=ROMS003P()     
		    _cMsgTop:= _cTitulo+" / Exportação disponiveis: XML / CSV / EXCEL / ARQUIVO"
		                             //      ,_aCols     ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab  , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1 )
	        U_ITListBox(_cTitulo , _aTitulos , _aDadosExcel , .T.    , 1    ,_cMsgTop,          ,        ,         ,     ,        ,          ,aCabXML,         ,          ,           ,         ,       ,          ,_aSX1)
         EndIf

	     BREAK  // FINALIZA A EMISSÃO DO RELATÓRIIO EM EXCEL ORDERM SUB GRUPO SINTETICO.
      EndIf

      //==========================================================================
      // Imprime Relatório Impresso.
      //==========================================================================	   

      oproc:cCaption := ("Lendo Dados - Pre-processamento 2/2" )
      ProcessMessages()
	  If (oAlias)->(!Eof())
		 ROMS003C(1)
	  EndIf       
		
	  Do While (oAlias)->(!Eof())	
//		 IncProc("Os dados estão sendo processados, favor aguardar...") 
         IF oproc <> NIL
            nConta++
            oproc:cCaption := ("Lendo : "+STRZERO(nConta,5) +" de "+ _cTotGeral )
            ProcessMessages()
         ENDIF
		 
		 nPosFilial:=aScan(aFilial,{|x| x[1] == AllTrim((oAlias)->D2_FILIAL)})   
		                                            
		 //Efetua o somatorio dos dados de acordo com o parametro considera devolucoes 
		 //MV_PAR22 == 2 Nao considera devolucoes
	     nQtde1:= IIF(MV_PAR22 == 2,(oAlias)->D2_QUANT  ,(oAlias)->D2_QUANT  -(oAlias)->D2_QTDEDEV                                                  )
	     nQtde2:= IIF(MV_PAR22 == 2,(oAlias)->D2_QTSEGUM,(oAlias)->D2_QTSEGUM-ROMS003L((oAlias)->D2_QUANT,(oAlias)->D2_QTDEDEV,(oAlias)->D2_QTSEGUM))
	     nTotal:= IIF(MV_PAR22 == 2,(oAlias)->D2_TOTAL  ,(oAlias)->D2_TOTAL  -(oAlias)->D2_VALDEV                                                   )
	     nVlBru:= IIF(MV_PAR22 == 2,(oAlias)->D2_VALBRUT,(oAlias)->VLRBRUTDEV                                                                       )

		 //Efetua somatorio dos totalizadores geral
		 nTotGQtde1 += nQtde1
		 nTotGQtde2 += nQtde2  
		 nTotGVlTot += nTotal
		 nTotGVlBru += nVlBru       
		
		 //Efetua o somatorio dos dados do SubGrupo para o Resumo Geral
		 nPosProdut:=aScan(aProduto,{|x| x[1] == AllTrim((oAlias)->B1_I_SUBGR)})     
	
		 If nPosProdut > 0   
			aProduto[nPosProdut,2]+= nQtde1 //Quantidade primeira unidade de medida
			aProduto[nPosProdut,4]+= nQtde2 //Quantidade segunda unidade de medida
			aProduto[nPosProdut,6]+= nTotal //Valor total 
			aProduto[nPosProdut,7]+= nVlBru //Valor Bruto
		 Else                         
			_cDescSubg := POSICIONE("ZB9",1,xFilial("ZB9")+(oAlias)->B1_I_SUBGR,"ZB9_DESSUB")
		    aAdd(aProduto,{AllTrim((oAlias)->B1_I_SUBGR),;//01
			                                      nQtde1,;//02
			                             (oAlias)->D2_UM,;//03
			                                      nQtde2,;//04
			                          (oAlias)->D2_SEGUM,;//05
			                                      nTotal,;//06
			                                      nVlBru,;//07
			                                  _cDescSubg})//08
		 EndIf
		      
    	 //Verifica se ja existe dados da Filial Lancados anteriormente
		 If nPosFilial > 0                
			//Efetua somatorio dos totalizadores por Filial
			nTotQtde1 += nQtde1
			nTotQtde2 += nQtde2  
			nTotVlTot += nTotal
			nTotVlBru += nVlBru
			                             
			//Verifica quebra por Sub Grupo
			nPosSubGr:= aScan(aSubGrupo,{|x| x[1] == AllTrim((oAlias)->D2_FILIAL) + AllTrim((oAlias)->B1_I_SUBGR) })     
	
			If nPosSubGr == 0   
			   
			   nlinha+=nSaltoLinha 
			   ROMS003BD()   
				
			   If Len(aSubGrupo) > 0
				  nlinha+=nSaltoLinha
				  ROMS003QP(0,1)
		 		  //Imprime totalizador por Filial          
		 		  ROMS003PT(SubStr('TOTAL SUB GRUPO: ' + aSubGrupo[Len(aSubGrupo),2],1,50) ,nTotSQtde1,nTotSQtde2,nTotSVlTot,nTotSVlBru)
		 			
		 		  //nlinha+=nSaltoLinha
			   EndIf	
				
			   _cDescSubg := POSICIONE("ZB9",1,xFilial("ZB9")+(oAlias)->B1_I_SUBGR,"ZB9_DESSUB")

			   nlinha+=nSaltoLinha 
			   nlinha+=nSaltoLinha   
			   ROMS003QP(2,1)  
			   //ROMS003CS(AllTrim((oAlias)->B1_I_SUBGR),AllTrim((oAlias)->DESCSUBGR))
			   ROMS003CS(AllTrim((oAlias)->B1_I_SUBGR),AllTrim(_cDescSubg))
			   nlinha+=nSaltoLinha 
				
			   //nlinha+=nSaltoLinha
			   nlinha+=nSaltoLinha                
			   ROMS003QP(2,1)   
			   //Imprime cabecalho dos dados do produto
			   ROMS003CD()     
				
			   aAdd(aSubGrupo,{ AllTrim((oAlias)->D2_FILIAL) + AllTrim((oAlias)->B1_I_SUBGR),AllTrim((oAlias)->B1_I_SUBGR) + '-' + AllTrim(_cDescSubg)})
				
			   //setas as variaves responsaveis por realizar o controle do somatorio por subGrupo de Produto
			   nTotSQtde1 := nQtde1
			   nTotSQtde2 := nQtde2  
			   nTotSVlTot := nTotal
			   nTotSVlBru := nVlBru     
			Else
		       //Efetua o somatorio por Sub Grupo de Produto
			   nTotSQtde1 += nQtde1
			   nTotSQtde2 += nQtde2  
			   nTotSVlTot += nTotal
			   nTotSVlBru += nVlBru 
			EndIf   
						                                
			nlinha+=nSaltoLinha   
			oPrint:Line(nLinha,nColInic,nLinha,nColFinal)             
			ROMS003QP(0,0)                  
		     //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
		    //       cProduto                                              ,nqtde1um,um1          ,nqtde2um,um2             ,nVlrTotal,nVlrBruto
			ROMS003N(AllTrim((oAlias)->B1_COD) + '-' + (oAlias)->B1_I_DESCD,nQtde1,(oAlias)->D2_UM,nQtde2,(oAlias)->D2_SEGUM,nTotal,nVlBru)
		     //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
		 Else
			//Imprime total sub Grupo 		
			If Len(aSubGrupo) > 0
		 	   nlinha+=nSaltoLinha
		 	   ROMS003BD() 
				
			   nlinha+=nSaltoLinha 
			   ROMS003QP(0,1)
		 	   //Imprime totalizador por Filial          
		 	   ROMS003PT(SubStr('TOTAL SUB GRUPO: ' + aSubGrupo[Len(aSubGrupo),2],1,50) ,nTotSQtde1,nTotSQtde2,nTotSVlTot,nTotSVlBru)
		 			
		 	   nlinha+=nSaltoLinha     
		    EndIf	 		                                        
			 		
			//Imprime o box e divisorias do produto anterior
		 	If Len(aFilial) > 0  	 
		 	   nlinha+=nSaltoLinha      
		 	   ROMS003QP(0,1)
		 	   //Imprime totalizador por Filial          
		 	   ROMS003PT(SubStr('TOTAL FILIAL: ' + aFilial[Len(aFilial),1] + '-' + FWFilialName(,aFilial[Len(aFilial),1]),1,50),nTotQtde1,nTotQtde2,nTotVlTot,nTotVlBru)
		 			
		 	   nlinha+=nSaltoLinha
		 	   nlinha+=nSaltoLinha     
		 			
		 	   //Forca quebra de pagina por Filial
		 	   nlinha:= 5000     
		 	   ROMS003QP(0,1)
		 	EndIf  

			_cDescSubg := POSICIONE("ZB9",1,xFilial("ZB9")+(oAlias)->B1_I_SUBGR,"ZB9_DESSUB")

		 	//Adiciona ao controle de filiais a nova filial
		 	aAdd(aFilial,{AllTrim((oAlias)->D2_FILIAL)})      
		 	//Adiciona ao controle de sub Grupo o sub Grupo da Nova Filial
			aAdd(aSubGrupo,{ AllTrim((oAlias)->D2_FILIAL) + AllTrim((oAlias)->B1_I_SUBGR),AllTrim((oAlias)->B1_I_SUBGR) + '-' + AllTrim(_cDescSubg)}) 
			//Efetua somatorio dos totalizadores por Filial - setando
			nTotQtde1 := nQtde1
			nTotQtde2 := nQtde2  
			nTotVlTot := nTotal
			nTotVlBru := nVlBru 
			//Efetua o somatorio dos totalizadores por Sub Grupo de Produto - Setando
			nTotSQtde1 := nQtde1
			nTotSQtde2 := nQtde2  
			nTotSVlTot := nTotal
			nTotSVlBru := nVlBru    
		 			
		    nlinha+=nSaltoLinha                
			ROMS003QP(1,1)
		    //Imprime cabecalho da Filial
			ROMS003CF((oAlias)->D2_FILIAL)        
			
			nlinha+=nSaltoLinha 
			nlinha+=nSaltoLinha     
			ROMS003QP(2,1)   
			//Imprime cabecalho do SubGrupo
			ROMS003CS(AllTrim((oAlias)->B1_I_SUBGR),AllTrim(_cDescSubg))
			
			nlinha+=nSaltoLinha
			nlinha+=nSaltoLinha                
			ROMS003QP(2,1)   
			//Imprime cabecalho dos dados do produto
			ROMS003CD()
					
			nlinha+=nSaltoLinha   
			oPrint:Line(nLinha,nColInic,nLinha,nColFinal)             
			ROMS003QP(0,0)
	        //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
		    //       cProduto                                              ,nqtde1um,um1          ,nqtde2um,um2             ,nVlrTotal,nVlrBruto
			ROMS003N(AllTrim((oAlias)->B1_COD) + '-' + (oAlias)->B1_I_DESCD,nQtde1,(oAlias)->D2_UM,nQtde2,(oAlias)->D2_SEGUM,nTotal,nVlBru)
		    //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
	     EndIf	

         (oAlias)->(dbSkip())
      EndDo	                                                  

      If Len(aSubGrupo) > 0   
	     nlinha+=nSaltoLinha
	     ROMS003BD()      

	     nlinha+=nSaltoLinha 
	     ROMS003QP(0,1)
	     //Imprime totalizador por Filial          
	     ROMS003PT(SubStr('TOTAL SUB GRUPO: ' + aSubGrupo[Len(aSubGrupo),2],1,50),nTotSQtde1,nTotSQtde2,nTotSVlTot,nTotSVlBru)
	     nlinha+=nSaltoLinha    
      EndIf 

      If Len(aFilial) > 0            
         nlinha+=nSaltoLinha  
         ROMS003QP(0,1)
         //Imprime totalizador por Filial          
         ROMS003PT(SubStr('TOTAL FILIAL: ' + aFilial[Len(aFilial),1] + '-' + FWFilialName(,aFilial[Len(aFilial),1]),1,50),nTotQtde1,nTotQtde2,nTotVlTot,nTotVlBru)

         //Imprime o total geral		 			
         nlinha+=nSaltoLinha
         nlinha+=nSaltoLinha
     
         ROMS003QP(0,1)  
         //Imprime totalizador por Filial                  
         ROMS003PT('TOTAL GERAL:',nTotGQtde1,nTotGQtde2,nTotGVlTot,nTotGVlBru)                              
      EndIf

      //EMITE A PARTE DE RESUMO GERAL ONDE TOTALIZA OS PRODUTOS SEM DISTINCAO DE FILIAL, CASO TENHA MAIS DE UMA FILIAL,
      //POIS SENAO OS DADOS SERAO OS MESMOS DA FILIAL
      If Len(aFilial) > 1
  	     //Ordena por codigo do produto os dados do resumo geral
	     aProduto:= aSort(aProduto,,,{|x, y| x[1] < y[1]})  
	
	     oPrint:EndPage()					// Finaliza a Pagina.
	     oPrint:StartPage()					//Inicia uma nova Pagina					
	     nPagina++
	     ROMS003C(1)//Chama cabecalho                       
	     nLinInBox:= nLinha 
	                                 
	     nlinha+=nSaltoLinha
	     oPrint:FillRect({(nlinha+3),nColInic,nlinha + nSaltoLinha,nColFinal},oBrush)  
	     oPrint:Box(nlinha,nColInic,nLinha + nSaltoLinha,nColFinal)
	     oPrint:Say (nlinha,nColFinal / 2,"RESUMO GERAL",oFont16b,nColFinal,,,2)  
	     nlinha+=nSaltoLinha                             
	     //Imprime cabecalho dos dados do produto
	     ROMS003SG()   
	
	     For _nI:=1 to Len(aProduto)
		     nlinha+=nSaltoLinha   
		     oPrint:Line(nLinha,nColInic,nLinha,nColFinal)             
		     ROMS003QP(0,0)
		     //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
			 //       cProduto                               ,nqtde1um       ,um1            ,nqtde2um       ,um2            ,nVlrTotal      ,nVlrBruto
		     ROMS003N(aProduto[_nI,1] + '-' + aProduto[_nI,8],aProduto[_nI,2],aProduto[_nI,3],aProduto[_nI,4],aProduto[_nI,5],aProduto[_nI,6],aProduto[_nI,7])
		     //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
	     Next _nI
	
	     nlinha+=nSaltoLinha
	     oPrint:Line(nLinha,nColInic,nLinha,nColFinal)                  
	     ROMS003QP(0,0)  
	     //Imprime totalizador por Filial                  
	     ROMS003PT('TOTAL GERAL:',nTotGQtde1,nTotGQtde2,nTotGVlTot,nTotGVlBru)     
	     nlinha+=nSaltoLinha 
	     ROMS003BD()
      EndIf    
   
   //=====================================================	  
   // Orderm Coordenador x Produto
   //=====================================================	  
   ElseIf _nOrdem == 2// ORDEM 02 

      oproc:cCaption := ("Lendo Dados - Pre-processamento 1/2" )
      ProcessMessages()

      BeginSql alias oAlias   	   	
		SELECT 			
				SUM(T.D2_QUANT)   AS D2_QUANT,
				AVG(T.D2_PRCVEN)  AS D2_PRCVEN,
				SUM(T.D2_TOTAL)   AS D2_TOTAL,				
				SUM(T.D2_VALBRUT) AS D2_VALBRUT,								
				SUM(T.D2_QTSEGUM) AS D2_QTSEGUM,
				SUM(T.D2_COMIS1)  AS D2_COMIS1,  
				SUM(T.D2_I_FRET)  AS D2_I_FRET,				
				SUM(T.D2_CUSTO1)  AS D2_CUSTO1,
				SUM(T.D2_QTDEDEV) AS D2_QTDEDEV,
				SUM(T.D2_VALDEV)  AS D2_VALDEV,				
				SUM(T.D2_ICMSRET) AS D2_ICMSRET,				
			    SUM(T.VLRBRUTDEV) AS VLRBRUTDEV,
				T.D2_UM,T.D2_SEGUM,T.B1_I_DESCD,T.B1_COD,T.F2_VEND2,T.D2_FILIAL,T.C5_I_LOCEM, T.C5_I_QTDA
        FROM
		(SELECT 			
			SUM(SD2.D2_QUANT)   AS D2_QUANT ,
			AVG(SD2.D2_PRCVEN)  AS D2_PRCVEN,
			SUM(SD2.D2_TOTAL)   AS D2_TOTAL,
			SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,
			SUM(SD2.D2_QTSEGUM) AS D2_QTSEGUM,
			SUM(((SD2.D2_COMIS1+SD2.D2_COMIS2+SD2.D2_COMIS3)/100)*SD2.D2_TOTAL) AS D2_COMIS1,
			SUM(SD2.D2_I_FRET)  AS D2_I_FRET,
			SUM(SD2.D2_CUSTO1)  AS D2_CUSTO1,
			SUM(SD2.D2_ICMSRET) AS D2_ICMSRET,			
			SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SF2.F2_VEND2,SD2.D2_FILIAL,SC5.C5_I_LOCEM,SC5.C5_I_QTDA,
            SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_COD,
			(SELECT COALESCE(SUM(D1.D1_QUANT),0)
			   FROM SD1010 D1
			   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			   WHERE D1.D_E_L_E_T_ = ' '
			     AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			     AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			     AND D1.D1_NFORI   = SD2.D2_DOC
			     AND D1.D1_SERIORI = SD2.D2_SERIE
			     AND D1.D1_FORNECE = SD2.D2_CLIENTE
			     AND D1.D1_LOJA    = SD2.D2_LOJA    
			     AND D1.D1_COD     = SD2.D2_COD 
			   ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
			(SELECT COALESCE(SUM(D1.D1_TOTAL),0)
			   FROM SD1010 D1
			   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			   WHERE D1.D_E_L_E_T_ = ' '
			     AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			     AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			     AND D1.D1_NFORI   = SD2.D2_DOC
			     AND D1.D1_SERIORI = SD2.D2_SERIE
			     AND D1.D1_FORNECE = SD2.D2_CLIENTE
			     AND D1.D1_LOJA    = SD2.D2_LOJA    
			     AND D1.D1_COD     = SD2.D2_COD
		       ) AS D2_VALDEV, ///*************************** D2_VALDEV
			(SUM(SD2.D2_VALBRUT)  -
			(SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
			   FROM SD1010 D1
			   %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
			   WHERE D1.D_E_L_E_T_ = ' '
			     AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
			     AND D1.D1_FILIAL  = SD2.D2_FILIAL 
			     AND D1.D1_NFORI   = SD2.D2_DOC
			     AND D1.D1_SERIORI = SD2.D2_SERIE
			     AND D1.D1_FORNECE = SD2.D2_CLIENTE
			     AND D1.D1_LOJA    = SD2.D2_LOJA    
			     AND D1.D1_COD     = SD2.D2_COD
		    )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV

		 FROM   
			%table:SF2% SF2
			JOIN %table:SD2% SD2 ON SD2.D2_DOC     = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
			JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
			JOIN %table:SB1% SB1 ON SD2.D2_COD     = SB1.B1_COD 
			JOIN %table:SA3% SA3 ON SF2.F2_VEND1   = SA3.A3_COD
			JOIN %table:SBM% SBM ON SB1.B1_GRUPO   = SBM.BM_GRUPO
			JOIN %table:ACY% ACY ON SA1.A1_GRPVEN  = ACY.ACY_GRPVEN
			JOIN %table:SF4% SF4 ON SD2.D2_FILIAL  = SF4.F4_FILIAL AND SD2.D2_TES = SF4.F4_CODIGO
			JOIN %table:SC5% SC5 ON SC5.C5_FILIAL  = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
			LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
         WHERE 
			SF2.%notDel%  
			AND SD2.%notDel%  
			AND SA1.%notDel%  		
			AND SB1.%notDel%  					
			AND SA3.%notDel%  											
			AND SBM.%notDel%				
			AND ACY.%notDel%
			AND SF4.%notDel%
			AND SC5.%notDel%
		    %exp:_cfiltro%
		 GROUP BY 
			SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_DESCD,SB1.B1_COD,SF2.F2_VEND2,SD2.D2_FILIAL,SC5.C5_I_LOCEM,SC5.C5_I_QTDA,
            SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_COD
		) T
		 GROUP BY 
		 
			 D2_UM,D2_SEGUM,B1_I_DESCD,B1_COD,F2_VEND2,D2_FILIAL,C5_I_LOCEM,C5_I_QTDA
		 ORDER BY 
			 D2_FILIAL,F2_VEND2,B1_COD,C5_I_LOCEM
	  EndSql		
		
      _nTot:=nConta:=0
      COUNT TO _nTot
      _cTotGeral:=ALLTRIM(STR(_nTot))
	  (oAlias)->(DBGOTOP())

      //==========================================================================
      // Imprime Relatório em Excel
      //==========================================================================

      If _lGeraEmExcel
         _aTitulos := { "Filial",;            // 01
                        "Nome Filial",;       // 02
                        "Fil. Embarque",;     // 03
                        "Coordenador",;       // 04
                        "Nome Coordenador",;  // 05 
                        "Produto",;           // 06
                        "Desc.Produto",;      // 07
                        "Quantidade",;        // 08
                        "1a U.M.",;           // 09
                        "Qtde 2a U.M.",;      // 10
                        "2a U.M.",;           // 11
                        "Vlr.Unit",;          // 12
                        "Vlr.Total",;         // 13
                        "Vlr.Bruto"}          // 14

	// Alinhamento: 1-Left   ,2-Center,3-Right
	// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
	//             Titulo das Colunas  ,Alinhamento ,Formatação, Totaliza?
	//               Titulo            ,1           ,1         ,.F./.T.   })
      aCabXML   := {{"Filial"          ,2           ,1         ,.F. },;// 01
                    {"Nome Filial"     ,1           ,1         ,.F. },;// 02
                    {"Fil. Embarque"   ,1           ,1         ,.F. },;// 03
                    {"Coordenador"     ,2           ,1         ,.F. },;// 04
                    {"Nome Coordenador",1           ,1         ,.F. },;// 05
                    {"Produto"         ,2           ,1         ,.F. },;// 06
                    {"Desc.Produto"    ,1           ,1         ,.F. },;// 07
                    {"Quantidade"      ,3           ,2         ,.F. },;// 08
                    {"1a U.M."         ,2           ,1         ,.F. },;// 09
                    {"Qtde 2a U.M."    ,3           ,2         ,.F. },;// 10
					{"2a U.M."         ,2           ,1         ,.F. },;// 11
                    {"Vlr.Unit"        ,3           ,3         ,.F. },;// 12
					{"Vlr.Total"       ,3           ,3         ,.F. },;// 13
                    {"Vlr.Bruto"       ,3           ,3         ,.F. }} // 14


          _cTitulo := "Relação de Vendas Faturadas - Ordem 02 - Coordenador x Produto"

          Do While (oAlias)->(!Eof())  
             //IncProc("Os dados do Relatorio estado sendo Processados...")   
             IF oproc <> NIL
                nConta++
                oproc:cCaption := ("Lendo : "+STRZERO(nConta,5) +" de "+ _cTotGeral )
                ProcessMessages()
             ENDIF

	         // Efetua o somatorio dos dados de acordo com o parametro considera devolucoes 
		     // MV_PAR22 == 2 Nao considera devolucoes
		     nQtde1:= IIF(MV_PAR22 == 2,(oAlias)->D2_QUANT  ,(oAlias)->D2_QUANT  -(oAlias)->D2_QTDEDEV                                                  /* -ROMS003Q2((oAlias)->D2_UM,(oAlias)->D2_SEGUM,(oAlias)->B1_COD,(oAlias)->D2_FILIAL,(oAlias)->F2_VEND2,'D2_QTDEDEV')*/)//MV_PAR22 == 2 Nao considera devolucoes			
		     nQtde2:= IIF(MV_PAR22 == 2,(oAlias)->D2_QTSEGUM,(oAlias)->D2_QTSEGUM-ROMS003L((oAlias)->D2_QUANT,(oAlias)->D2_QTDEDEV,(oAlias)->D2_QTSEGUM)/* -ROMS003Q2((oAlias)->D2_UM,(oAlias)->D2_SEGUM,(oAlias)->B1_COD,(oAlias)->D2_FILIAL,(oAlias)->F2_VEND2,'D2_QTSEGUM')*/)//MV_PAR22 == 2 Nao considera devolucoes						
		     nTotal:= IIF(MV_PAR22 == 2,(oAlias)->D2_TOTAL  ,(oAlias)->D2_TOTAL  -(oAlias)->D2_VALDEV                                                   /* -ROMS003QF((oAlias)->D2_UM,(oAlias)->D2_SEGUM,(oAlias)->B1_COD,(oAlias)->D2_FILIAL,(oAlias)->F2_VEND2,.F.)*/)         //MV_PAR22 == 2 Nao considera devolucoes			
		     nVlBru:= IIF(MV_PAR22 == 2,(oAlias)->D2_VALBRUT,(oAlias)->VLRBRUTDEV                                                                       /* -ROMS003QF((oAlias)->D2_UM,(oAlias)->D2_SEGUM,(oAlias)->B1_COD,(oAlias)->D2_FILIAL,(oAlias)->F2_VEND2,.T.)*/)         //MV_PAR22 == 2 Nao considera devolucoes

			 _cNomeFil:= FWFilialName(,(oAlias)->D2_FILIAL)
			 _cFilEmba:= POSICIONE("ZEL",1,xFilial("ZEL")+(oAlias)->C5_I_LOCEM,"ZEL_DESCRI")
             
			 cDesSuperv := IF(empty((oAlias)->F2_VEND2),"SEM Coordenador", POSICIONE("SA3",1,xFilial("SA3")+(oAlias)->F2_VEND2,"A3_NOME"))

             Aadd(_aDadosExcel,{(oAlias)->D2_FILIAL,;  // "Filial"            // 01
                                _cNomeFil,;            // "Nome Filial"       // 02
                                _cFilEmba,;            // "Fil. Embarq"       // 03
                                (oAlias)->F2_VEND2,;   // "Coordenador"       // 04
                                cDesSuperv,;           // "Nome Coordenador"  // 05 
                                (oAlias)->B1_COD,;     // "Produto"           // 06
                                (oAlias)->B1_I_DESCD,; // "Desc.Produto"      // 07
                                nQtde1,;               // "Quantidade"        // 08
                                (oAlias)->D2_UM,;      // "1a U.M."           // 09
                                nQtde2,;               // "Qtde 2a U.M."      // 10
                                (oAlias)->D2_SEGUM,;   // "2a U.M."           // 11
                                nTotal / nQtde1 ,;     // "Vlr.Unit"          // 12
                                nTotal,;               // "Vlr.Total"         // 13
                                nVlBru;                // "Vlr.Bruto"         // 14
                                })
                      
	        (oAlias)->(dbSkip())	 
	     EndDo
 
         If Empty(_aDadosExcel)
            U_ITMSG("Não foram encontrados dados para emissão do relatório em Excel que satisfaçam as condições de filtro.","Atenção", ,1)
	     Else
	        _aSX1:=ROMS003P()     
		    _cMsgTop:= _cTitulo+" / Exportação disponiveis: XML / CSV / EXCEL / ARQUIVO"
		                             //      ,_aCols        ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1 )
	        U_ITListBox(_cTitulo , _aTitulos , _aDadosExcel , .T.    , 1    ,_cMsgTop,          ,        ,         ,     ,        ,          ,aCabXML,         ,          ,           ,         ,       ,         ,_aSX1)
         EndIf

	     BREAK  // FINALIZA A EMISSÃO DO RELATÓRIIO EM EXCEL ORDERM COORDENADOR X PRODUTO
      EndIf
      
      oproc:cCaption := ("Lendo Dados - Pre-processamento 2/2" )
      ProcessMessages()
	  //==============================================
	  // Imprime relatório impresso
	  //==============================================
	  If (oAlias)->(!Eof())
		 ROMS003C(1)
	  EndIf       
		
	  Do While (oAlias)->(!Eof())	
		 //IncProc("Os dados estão sendo processados, favor aguardar...") 
         IF oproc <> NIL
            nConta++
            oproc:cCaption := ("Lendo : "+STRZERO(nConta,5) +" de "+ _cTotGeral )
            ProcessMessages()
         ENDIF
	
		 nPosFilial:=aScan(aFilial,{|x| x[1] == AllTrim((oAlias)->D2_FILIAL)})   
		                                            
		 // Efetua o somatorio dos dados de acordo com o parametro considera devolucoes 
		 // MV_PAR22 == 2 Nao considera devolucoes
		 nQtde1:= IIF(MV_PAR22 == 2,(oAlias)->D2_QUANT  ,(oAlias)->D2_QUANT  -(oAlias)->D2_QTDEDEV                                                  /* -ROMS003Q2((oAlias)->D2_UM,(oAlias)->D2_SEGUM,(oAlias)->B1_COD,(oAlias)->D2_FILIAL,(oAlias)->F2_VEND2,'D2_QTDEDEV')*/)//MV_PAR22 == 2 Nao considera devolucoes			
		 nQtde2:= IIF(MV_PAR22 == 2,(oAlias)->D2_QTSEGUM,(oAlias)->D2_QTSEGUM-ROMS003L((oAlias)->D2_QUANT,(oAlias)->D2_QTDEDEV,(oAlias)->D2_QTSEGUM)/* -ROMS003Q2((oAlias)->D2_UM,(oAlias)->D2_SEGUM,(oAlias)->B1_COD,(oAlias)->D2_FILIAL,(oAlias)->F2_VEND2,'D2_QTSEGUM')*/)//MV_PAR22 == 2 Nao considera devolucoes						
		 nTotal:= IIF(MV_PAR22 == 2,(oAlias)->D2_TOTAL  ,(oAlias)->D2_TOTAL  -(oAlias)->D2_VALDEV                                                   /* -ROMS003QF((oAlias)->D2_UM,(oAlias)->D2_SEGUM,(oAlias)->B1_COD,(oAlias)->D2_FILIAL,(oAlias)->F2_VEND2,.F.)*/)         //MV_PAR22 == 2 Nao considera devolucoes			
		 nVlBru:= IIF(MV_PAR22 == 2,(oAlias)->D2_VALBRUT,(oAlias)->VLRBRUTDEV                                                                       /* -ROMS003QF((oAlias)->D2_UM,(oAlias)->D2_SEGUM,(oAlias)->B1_COD,(oAlias)->D2_FILIAL,(oAlias)->F2_VEND2,.T.)*/)         //MV_PAR22 == 2 Nao considera devolucoes

		 //Efetua somatorio dos totalizadores geral
		 nTotGQtde1 += nQtde1
		 nTotGQtde2 += nQtde2  
		 nTotGVlTot += nTotal
		 nTotGVlBru += nVlBru       
		
		 //Efetua o somatorio dos dados do Coordenador + Produto(Desconsiderando a Filial) - Utilizado no Resumo Geral 
		 nPosProdut:=aScan(aProduto,{|x| x[1] == (oAlias)->F2_VEND2 .And. x[2] == AllTrim((oAlias)->B1_COD)})     
	
		 If nPosProdut > 0   
			aProduto[nPosProdut,03]+= nQtde1 // 03 - Quantidade primeira unidade de medida
			aProduto[nPosProdut,05]+= nQtde2 // 05 - Quantidade segunda unidade de medida
			aProduto[nPosProdut,07]+= nTotal // 07 - Valor total 
			aProduto[nPosProdut,08]+= nVlBru // 08 - Valor Bruto
		 Else                         
		    aAdd(aProduto,{(oAlias)->F2_VEND2,; // 01
			        AllTrim((oAlias)->B1_COD),; // 02
					                   nQtde1,; // 03
					          (oAlias)->D2_UM,; // 04
				    nQtde2,(oAlias)->D2_SEGUM,; // 05
					                   nTotal,; // 06
									   nVlBru,; // 07
						 (oAlias)->B1_I_DESCD}) // 08
		 EndIf
		      
    	 //Verifica se ja existe dados da Filial Lancados anteriormente
		 If nPosFilial > 0                
			//Efetua somatorio dos totalizadores por Filial
			nTotQtde1 += nQtde1
			nTotQtde2 += nQtde2  
			nTotVlTot += nTotal
			nTotVlBru += nVlBru
			                             
			//Verifica quebra por Coordenador
			nPosSuperv:= aScan(aSupevisor,{|x| x[1] == AllTrim((oAlias)->D2_FILIAL) + (oAlias)->F2_VEND2 })     
	
			If nPosSuperv == 0
			   //Pega a descricao do Coordenador
			   cDesSuperv:=IIF(empty((oAlias)->F2_VEND2),"SEM Coordenador", POSICIONE("SA3",1,xFilial("SA3")+(oAlias)->F2_VEND2,"A3_NOME"))
   		       nlinha+= nSaltoLinha 
			   ROMS003BD()   
				
			   If Len(aSupevisor) > 0
				  nlinha += nSaltoLinha
				  ROMS003QP(0,1)
		 		  //Imprime totalizador por Filial          
		 		  ROMS003PT(SubStr('TOTAL Coordenador: ' + aSupevisor[Len(aSupevisor),2],1,50) ,nTotSQtde1,nTotSQtde2,nTotSVlTot,nTotSVlBru)
		 			
		 		  //nlinha+=nSaltoLinha
			   EndIf	
				
			   nlinha+=nSaltoLinha 
			   nlinha+=nSaltoLinha   
			   ROMS003QP(2,1)   
			   ROMS003CP((oAlias)->F2_VEND2,cDesSuperv)
			   nlinha += nSaltoLinha 
				
			   //nlinha+=nSaltoLinha
			   nlinha+=nSaltoLinha                
			   ROMS003QP(2,1)   
			   //Imprime cabecalho dos dados do produto
			   ROMS003CD()     
				
			   aAdd(aSupevisor,{ AllTrim((oAlias)->D2_FILIAL) + (oAlias)->F2_VEND2,AllTrim((oAlias)->F2_VEND2) + '-' + AllTrim(cDesSuperv) })
				
			   //setas as variaves responsaveis por realizar o controle do somatorio por Coordenador
			   nTotSQtde1 := nQtde1
			   nTotSQtde2 := nQtde2  
			   nTotSVlTot := nTotal
			   nTotSVlBru := nVlBru     
			Else
			   //Efetua o somatorio por Coordenador
			   nTotSQtde1 += nQtde1
			   nTotSQtde2 += nQtde2  
			   nTotSVlTot += nTotal
			   nTotSVlBru += nVlBru 
			EndIf   

			nlinha+=nSaltoLinha   
			oPrint:Line(nLinha,nColInic,nLinha,nColFinal)             
			ROMS003QP(0,0)                  
		     //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
		    //       cProduto                                              ,nqtde1um,um1          ,nqtde2um,um2             ,nVlrTotal,nVlrBruto
			ROMS003N(AllTrim((oAlias)->B1_COD) + '-' + (oAlias)->B1_I_DESCD,nQtde1,(oAlias)->D2_UM,nQtde2,(oAlias)->D2_SEGUM,nTotal,nVlBru)
		     //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
		 Else
		    //Imprime total sub Grupo 		
		    If Len(aSupevisor) > 0
			   nlinha+=nSaltoLinha
			   ROMS003BD() 
				
			   nlinha+=nSaltoLinha 
			   ROMS003QP(0,1)
			   //Imprime totalizador por Filial          
			   ROMS003PT(SubStr('TOTAL Coordenador: ' + aSupevisor[Len(aSupevisor),2],1,50) ,nTotSQtde1,nTotSQtde2,nTotSVlTot,nTotSVlBru)
		 			
			   nlinha+=nSaltoLinha     
		    EndIf	 		                                        
			 		
		    //Imprime o box e divisorias do produto anterior
		    If Len(aFilial) > 0  	 
			   nlinha+=nSaltoLinha      
			   ROMS003QP(0,1)
			   //Imprime totalizador por Filial          
			   ROMS003PT(SubStr('TOTAL FILIAL: ' + aFilial[Len(aFilial),1] + '-' + FWFilialName(,aFilial[Len(aFilial),1]),1,50),nTotQtde1,nTotQtde2,nTotVlTot,nTotVlBru)
		 			
			   nlinha+=nSaltoLinha
			   nlinha+=nSaltoLinha     
		 			
			   //Forca quebra de pagina por Filial
			   nlinha:= 5000     
			   ROMS003QP(0,1)
		    EndIf  
		 	                                                   
		    //Adiciona ao controle de filiais a nova filial
		    aAdd(aFilial,{AllTrim((oAlias)->D2_FILIAL)})      
		    //Adiciona ao controle de sub Grupo o sub Grupo da Nova Filial
		    //Pega a descricao do Coordenador
		    cDesSuperv:=IIF(empty((oAlias)->F2_VEND2),"SEM Coordenador", POSICIONE("SA3",1,xFilial("SA3")+(oAlias)->F2_VEND2,"A3_NOME"))
		    aAdd(aSupevisor,{ AllTrim((oAlias)->D2_FILIAL) + (oAlias)->F2_VEND2,AllTrim((oAlias)->F2_VEND2) + '-' + AllTrim(cDesSuperv) })
		    //Efetua somatorio dos totalizadores por Filial - setando
		    nTotQtde1 := nQtde1
		    nTotQtde2 := nQtde2  
		    nTotVlTot := nTotal
		    nTotVlBru := nVlBru 
		    //Efetua o somatorio dos totalizadores por Sub Grupo de Produto - Setando
		    nTotSQtde1 := nQtde1
		    nTotSQtde2 := nQtde2  
		    nTotSVlTot := nTotal
		    nTotSVlBru := nVlBru    
		 			
		    nlinha+=nSaltoLinha                
		    ROMS003QP(1,1)
		    //Imprime cabecalho da Filial
		    ROMS003CF((oAlias)->D2_FILIAL)        
			
		    nlinha+=nSaltoLinha 
		    nlinha+=nSaltoLinha     
		    ROMS003QP(2,1)   
		    //Imprime cabecalho do Coordenador
		    ROMS003CP((oAlias)->F2_VEND2,cDesSuperv)
					                                        
		    nlinha+=nSaltoLinha
		    nlinha+=nSaltoLinha                
		    ROMS003QP(2,1)   
		    //Imprime cabecalho dos dados do produto
		    ROMS003CD()
					
		    nlinha+=nSaltoLinha   
		    oPrint:Line(nLinha,nColInic,nLinha,nColFinal)             
		    ROMS003QP(0,0)
	        //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
		    //       cProduto                                              ,nqtde1um,um1          ,nqtde2um,um2             ,nVlrTotal,nVlrBruto
		    ROMS003N(AllTrim((oAlias)->B1_COD) + '-' + (oAlias)->B1_I_DESCD,nQtde1,(oAlias)->D2_UM,nQtde2,(oAlias)->D2_SEGUM,nTotal,nVlBru)
		    //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
	     EndIf	
      
	     (oAlias)->(dbSkip())
      EndDo	                                    

      If Len(aSupevisor) > 0                      
	     nlinha+=nSaltoLinha
	     ROMS003BD()        
	
	     nlinha+=nSaltoLinha 
	     ROMS003QP(0,1)
	     //Imprime totalizador por Filial          
	     ROMS003PT(SubStr('TOTAL Coordenador: ' + aSupevisor[Len(aSupevisor),2],1,50) ,nTotSQtde1,nTotSQtde2,nTotSVlTot,nTotSVlBru)
	     nlinha+=nSaltoLinha     
	
	     nlinha+=nSaltoLinha  
	     ROMS003QP(0,1)
	     //Imprime totalizador por Filial          
	     ROMS003PT(SubStr('TOTAL FILIAL: ' + aFilial[Len(aFilial),1] + '-' + FWFilialName(,aFilial[Len(aFilial),1]),1,50),nTotQtde1,nTotQtde2,nTotVlTot,nTotVlBru)
	
	     //Imprime o total geral		 			
	     nlinha+=nSaltoLinha
	     nlinha+=nSaltoLinha
	     
	     ROMS003QP(0,1)  
	     //Imprime totalizador por Filial                  
	     ROMS003PT('TOTAL GERAL:',nTotGQtde1,nTotGQtde2,nTotGVlTot,nTotGVlBru)                              
      EndIf

      //EMITE A PARTE DE RESUMO GERAL ONDE TOTALIZA OS PRODUTOS SEM DISTINCAO DE FILIAL POR Coordenador
      If Len(aProduto) > 1
	     //Ordena por codigo do produto os dados do resumo geral
	     aProduto:= aSort(aProduto,,,{|x, y| x[1] + x[2] < y[1] + y[2]})  
	
	     oPrint:EndPage()					// Finaliza a Pagina.
	     oPrint:StartPage()					//Inicia uma nova Pagina					
	     nPagina++
	     ROMS003C(1)//Chama cabecalho                       
	                                 
	     nlinha+=nSaltoLinha
	     oPrint:FillRect({(nlinha+3),nColInic,nlinha + nSaltoLinha,nColFinal},oBrush)  
	     oPrint:Box(nlinha,nColInic,nLinha + nSaltoLinha,nColFinal)
 	     oPrint:Say (nlinha,nColFinal / 2,"RESUMO GERAL",oFont16b,nColFinal,,,2)  
	     nlinha+=nSaltoLinha               
	
	     For _nI:=1 to Len(aProduto)
		     //Verifica a necessidade de imprimir o cabecalho do Coordenador
		     nPosSuprv:=aScan(aProdSuprv,{|z| z[1] == aProduto[_nI,1]})  
		
		     If nPosSuprv == 0             
		 	    cDesSuperv:=IIF(empty(aProduto[_nI,1]),"SEM Coordenador", POSICIONE("SA3",1,xFilial("SA3")+aProduto[_nI,1],"A3_NOME"))
		
			    //Imprime total Coordenador
			    If Len(aProdSuprv) > 0
	 			   nlinha+=nSaltoLinha
	 			   ROMS003BD() 
				
				   nlinha+=nSaltoLinha 
				   ROMS003QP(0,1)
				   //Imprime totalizador por Coordenador          
				   ROMS003PT(SubStr('TOTAL Coordenador: ' + aProdSuprv[Len(aProdSuprv),9],1,50) ,nTotSQtde1,nTotSQtde2,nTotSVlTot,nTotSVlBru)
		 			
				   nlinha+=nSaltoLinha     
			    EndIf
		
		        nlinha+=nSaltoLinha 
			    nlinha+=nSaltoLinha     
			    ROMS003QP(2,1)   
			    //Imprime cabecalho do Coordenador
			    ROMS003CP(aProduto[_nI,1],cDesSuperv) 
			
			    nlinha+=nSaltoLinha
			    nlinha+=nSaltoLinha                
			    ROMS003QP(2,1)   
			    //Imprime cabecalho dos dados do produto
			    ROMS003CD()
			
		        aAdd(aProdSuprv,{aProduto[_nI,1],aProduto[_nI,2],aProduto[_nI,3],aProduto[_nI,4],aProduto[_nI,5],aProduto[_nI,6],aProduto[_nI,7],aProduto[_nI,8],AllTrim(aProduto[_nI,1])+'-'+AllTrim(cDesSuperv)})
			
			    //Seta Variaveis responsaveis pelo controle do somatorio
			    nTotSQtde1:= aProduto[_nI,3]
			    nTotSQtde2:= aProduto[_nI,5]
			    nTotSVlTot:= aProduto[_nI,7]
			    nTotSVlBru:= aProduto[_nI,8]
		     Else
			    //Incrementa Totalizador
			    nTotSQtde1+= aProduto[_nI,3]
			    nTotSQtde2+= aProduto[_nI,5]
			    nTotSVlTot+= aProduto[_nI,7]
			    nTotSVlBru+= aProduto[_nI,8]
		     EndIf 
	
		     nlinha+=nSaltoLinha   
		     oPrint:Line(nLinha,nColInic,nLinha,nColFinal)             
		     ROMS003QP(0,0)
		     //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
			 //       cProduto                               ,nqtde1um       ,um1            ,nqtde2um       ,um2            ,nVlrTotal      ,nVlrBruto
		     ROMS003N(aProduto[_nI,2] + '-' + aProduto[_nI,9],aProduto[_nI,3],aProduto[_nI,4],aProduto[_nI,5],aProduto[_nI,6],aProduto[_nI,7],aProduto[_nI,8])
		     //**** DETALHAS - IMPRIME OS DADOS DO PRODUTO  *****
	     Next _nI
	
	     nlinha+=nSaltoLinha
	     ROMS003BD() // LINHAS DAS COLUNAS           
				
	     nlinha+=nSaltoLinha 
	     nlinha+=nSaltoLinha 
	     ROMS003QP(0,1)
	     //Imprime totalizador por Coordenador          
	     ROMS003PT(SubStr('TOTAL Coordenador: ' + aProdSuprv[Len(aProdSuprv),9],1,50) ,nTotSQtde1,nTotSQtde2,nTotSVlTot,nTotSVlBru)
	
	     //Imprime o total geral		 			
	     nlinha+=nSaltoLinha
	     nlinha+=nSaltoLinha
	     
	     ROMS003QP(0,1)  
	     //Imprime totalizador por Filial                  
	     ROMS003PT('TOTAL GERAL:',nTotGQtde1,nTotGQtde2,nTotGVlTot,nTotGVlBru)                              
      EndIf    
   EndIf

End Sequence 

Return             

/*
===============================================================================================================================
Programa--------: ROMS003QP
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que processa a quebra de paginas do relatorio
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003QP(nLinhas,impBox)   

	//Quebra de pagina
	If nLinha > nqbrPagina
				
		nlinha:= nlinha - (nSaltoLinha * nLinhas)
		
		If impBox == 0
			ROMS003BD()	  
		EndIf	 
		
		oPrint:EndPage()					// Finaliza a Pagina.
		oPrint:StartPage()					//Inicia uma nova Pagina					
		nPagina++
		ROMS003C(1)//Chama cabecalho    
		nlinha+=nSaltoLinha                   
		nLinInBox:= nLinha
		
	EndIf  
	
Return    

/*
===============================================================================================================================
Programa--------: ROMS00312
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que consulta os dados utilizando a ORDEM 12
Parametros------: oproc
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS00312(oproc)

Local _nPosFil  := 0  
Local _cDescSubg  := ""
Local _aTitulos := {}, _aDadosExcel := {}
Local _cRegiao 
Local _cTitulo
Local _nI

Private cAliasOr12:= GetNextAlias() 
 
Private _aRegioes := {}  
  
Private _aSubGrupo:= {}
Private _aDadosReg:= {}     
Private _aDadosRes:= {}

Private _aPorcSubG:= {}    
Private _aPorcRegi:= {}    
Private _aPorcResu:= {}  
Private _aQtdeMun := {}

Private _aFiliais := {}
        
//Totalizadores por Filial
Private _nTFilQtd1:= 0
Private _nTFilQtd2:= 0
Private _nTFilVlTo:= 0
Private _nTFilPeso:= 0     

Private nQtde1    := 0
Private nQtde2    := 0
Private nTotal    := 0 

Begin Sequence
   //Seta aRegios com o nome da regiao e os estados que a compoem  

   aAdd(_aRegioes,{" Sem estado informado no pedido de venda","  "})

   aAdd(_aRegioes,{"Centro-Oeste","GO"})  	  
   aAdd(_aRegioes,{"Centro-Oeste","MT"}) 
   aAdd(_aRegioes,{"Centro-Oeste","MS"}) 
   aAdd(_aRegioes,{"Centro-Oeste","DF"}) 

   aAdd(_aRegioes,{"Nordeste"    ,"MA"}) 
   aAdd(_aRegioes,{"Nordeste"    ,"PI"}) 
   aAdd(_aRegioes,{"Nordeste"    ,"CE"}) 
   aAdd(_aRegioes,{"Nordeste"    ,"RN"}) 
   aAdd(_aRegioes,{"Nordeste"    ,"PB"}) 
   aAdd(_aRegioes,{"Nordeste"    ,"PE"}) 
   aAdd(_aRegioes,{"Nordeste"    ,"AL"}) 
   aAdd(_aRegioes,{"Nordeste"    ,"SE"}) 
   aAdd(_aRegioes,{"Nordeste"    ,"BA"}) 

   aAdd(_aRegioes,{"Norte"       ,"AC"})
   aAdd(_aRegioes,{"Norte"       ,"AM"})
   aAdd(_aRegioes,{"Norte"       ,"RR"})
   aAdd(_aRegioes,{"Norte"       ,"RO"})
   aAdd(_aRegioes,{"Norte"       ,"PA"})
   aAdd(_aRegioes,{"Norte"       ,"AP"})
   aAdd(_aRegioes,{"Norte"       ,"TO"}) 

   aAdd(_aRegioes,{"Sudeste"     ,"MG"})      
   aAdd(_aRegioes,{"Sudeste"     ,"ES"})      
   aAdd(_aRegioes,{"Sudeste"     ,"RJ"})      
   aAdd(_aRegioes,{"Sudeste"     ,"SP"})      

   aAdd(_aRegioes,{"Sul"         ,"PR"}) 
   aAdd(_aRegioes,{"Sul"         ,"SC"}) 
   aAdd(_aRegioes,{"Sul"         ,"RS"})
	
	//ORDEM 12 - Estado x Sub-Grupo - SINTETICO

   BeginSql alias cAliasOr12   	   	
		SELECT 			
				SUM(T.D2_QUANT)   AS D2_QUANT,
				AVG(T.D2_PRCVEN)  AS D2_PRCVEN,
				SUM(T.D2_TOTAL)   AS D2_TOTAL,				
				SUM(T.D2_VALBRUT) AS D2_VALBRUT,								
				SUM(T.D2_QTSEGUM) AS D2_QTSEGUM,
				SUM(T.D2_QTDEDEV) AS D2_QTDEDEV,
				SUM(T.D2_VALDEV)  AS D2_VALDEV,				
			    SUM(T.PESTOTAL)   AS PESTOTAL,
			    SUM(T.VLRBRUTDEV) AS VLRBRUTDEV,
		        T.D2_FILIAL,T.D2_EST,T.A1_COD_MUN,T.D2_UM,T.D2_SEGUM,T.B1_I_SUBGR
        FROM
		(SELECT 			
	     SUM(SD2.D2_QUANT)   AS D2_QUANT,
		 AVG(SD2.D2_PRCVEN)  AS D2_PRCVEN,
		 SUM(SD2.D2_TOTAL)   AS D2_TOTAL,		
		 SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,
		 SUM(SD2.D2_QTSEGUM) AS D2_QTSEGUM,
		 COALESCE(SUM(SB1.B1_PESBRU * SD2.D2_QUANT),0) AS PESTOTAL,							
		 SD2.D2_FILIAL,SD2.D2_EST,SA1.A1_COD_MUN,SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_SUBGR,
		 SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_COD,
		 (SELECT COALESCE(SUM(D1.D1_QUANT),0)
		    FROM SD1010 D1
		    %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
		    WHERE D1.D_E_L_E_T_ = ' '
		      AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
		      AND D1.D1_FILIAL  = SD2.D2_FILIAL 
		      AND D1.D1_NFORI   = SD2.D2_DOC
		      AND D1.D1_SERIORI = SD2.D2_SERIE
		      AND D1.D1_FORNECE = SD2.D2_CLIENTE
		      AND D1.D1_LOJA    = SD2.D2_LOJA    
		      AND D1.D1_COD     = SD2.D2_COD 
		    ) AS D2_QTDEDEV, ///*************************** D2_QTDEDEV
		 (SELECT COALESCE(SUM(D1.D1_TOTAL),0)
		    FROM SD1010 D1
		    %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
		    WHERE D1.D_E_L_E_T_ = ' '
		      AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
		      AND D1.D1_FILIAL  = SD2.D2_FILIAL 
		      AND D1.D1_NFORI   = SD2.D2_DOC
		      AND D1.D1_SERIORI = SD2.D2_SERIE
		      AND D1.D1_FORNECE = SD2.D2_CLIENTE
		      AND D1.D1_LOJA    = SD2.D2_LOJA    
		      AND D1.D1_COD     = SD2.D2_COD
		    ) AS D2_VALDEV, ///*************************** D2_VALDEV
		 (SUM(SD2.D2_VALBRUT)  -
		 (SELECT COALESCE(SUM(D1.D1_TOTAL - D1_VALDESC + D1.D1_ICMSRET),0)
		    FROM SD1010 D1
		    %exp:_cJOIN_SF1% //JOIN SF1010 SF1 ON D1.D1_DOC = SF1.F1_DOC AND D1.D1_SERIE = SF1.F1_SERIE AND D1.D1_FILIAL = SF1.F1_FILIAL 
		    WHERE D1.D_E_L_E_T_ = ' '
		      AND D1.D1_TIPO = 'D'//AND D1_TES        <> ' ' "
		      AND D1.D1_FILIAL  = SD2.D2_FILIAL 
		      AND D1.D1_NFORI   = SD2.D2_DOC
		      AND D1.D1_SERIORI = SD2.D2_SERIE
		      AND D1.D1_FORNECE = SD2.D2_CLIENTE
		      AND D1.D1_LOJA    = SD2.D2_LOJA    
		      AND D1.D1_COD     = SD2.D2_COD
		    )) AS VLRBRUTDEV  ///*************************** VLRBRUTDEV
		 FROM %table:SF2% SF2
		 JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
		 JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA
		 JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD 
		 JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
		 JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO
		 JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN
		 JOIN %table:SF4% SF4 ON SD2.d2_filial = SF4.f4_filial AND sd2.d2_tes = SF4.f4_codigo
		 JOIN %table:SC5% SC5 ON SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SF2.F2_I_PEDID
		 LEFT JOIN %table:DAI% DAI ON DAI.DAI_FILIAL = SF2.F2_FILIAL AND DAI.DAI_PEDIDO = SF2.F2_I_PEDID AND DAI.DAI_NFISCA = SF2.F2_DOC AND DAI.DAI_SERIE = SF2.F2_SERIE AND DAI.%notDel%
	  WHERE 
		 SF2.%notDel%  
		 AND SD2.%notDel%  
		 AND SA1.%notDel%  		
		 AND SB1.%notDel%  					
		 AND SA3.%notDel%  											
		 AND SBM.%notDel%				
		 AND ACY.%notDel%
		 AND SF4.%notDel%
		 AND SC5.%notDel%
		 %exp:_cfiltro%
      GROUP BY 
 	     SD2.D2_FILIAL,SD2.D2_EST,SA1.A1_COD_MUN,SD2.D2_UM,SD2.D2_SEGUM,SB1.B1_I_SUBGR,
		 SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_COD    
		) T
      GROUP BY 
 	    T.D2_FILIAL,T.D2_EST,T.A1_COD_MUN,T.D2_UM,T.D2_SEGUM,T.B1_I_SUBGR
	  ORDER BY 
		T.D2_FILIAL,T.D2_EST
   EndSql       
		
   //ProcRegua(0)               
   _nTot:=nConta:=0
   COUNT TO _nTot
   _cTotGeral:=ALLTRIM(STR(_nTot))
		     
   dbSelectArea(cAliasOr12)
   (cAliasOr12)->(dbGotop())

   //==========================================================================
   // Relatório em Excel
   //==========================================================================
   If _lGeraEmExcel 
      _aTitulos := {"Filial",;
                    "Estado",;
                    "Região",;
                    "Cod. Sub Grupo",;
                    "Desc. Sub Grupo",;
                    "Qtde.1 UM",;
                    "1 UM",;
                    "Qtde.2 UM",;
                    "2 UM",;
					"Preco Unit",;
                    "Valor Total",;
                    "Valor Bruto",;
                    "Peso Total"}
	// Alinhamento: 1-Left   ,2-Center,3-Right
	// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
	//             Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
	//               Titulo           ,1           ,1         ,.F./.T.   })
      aCabXML   := {{"Filial"         ,2           ,1         ,.F. },;
                    {"Estado"         ,2           ,1         ,.F. },;
                    {"Região"         ,1           ,1         ,.F. },;
                    {"Cod. Sub Grupo" ,2           ,1         ,.F. },;
                    {"Desc. Sub Grupo",1           ,1         ,.F. },;
                    {"Qtde.1 UM"      ,3           ,2         ,.F. },;
                    {"1 UM"           ,2           ,1         ,.F. },;
                    {"Qtde.2 UM"      ,3           ,2         ,.F. },;
                    {"2 UM"           ,2           ,1         ,.F. },;
					{"Preco Unit"     ,3           ,3         ,.F. },;
                    {"Valor Total"    ,3           ,3         ,.F. },;
                    {"Valor Bruto"    ,3           ,3         ,.F. },;
                    {"Peso Total"     ,2           ,2         ,.F. }}


	  _cTitulo := "Relação de Vendas Faturadas - Ordem 12 - Estados x Sub-Grupos"

      Do While (cAliasOr12)->(!Eof())  
         //IncProc("Os dados do Relatorio estado sendo Processados...")   
         IF oproc <> NIL
            nConta++
            oproc:cCaption := ("Lendo : "+STRZERO(nConta,5) +" de "+ _cTotGeral )
            ProcessMessages()
         ENDIF
      
	    // Retorna a regiao pertencente ao estado do cliente informado no pedido de venda
		_nPosReg := aScan( _aRegioes,{|x| x[2] == (cAliasOr12)->D2_EST }) 
		
		_cRegiao := ""
		If _nPosReg > 0
		   _cRegiao := _aRegioes[_nPosReg,1]
		EndIf
        
	    _cDescSubg := POSICIONE("ZB9",1,xFilial("ZB9")+(cAliasOr12)->B1_I_SUBGR,"ZB9_DESSUB")

	     //MV_PAR22 == 2 Nao considera devolucoes
         nQtde1:= IIF(MV_PAR22 == 2,(cAliasOr12)->D2_QUANT  ,(cAliasOr12)->D2_QUANT   - (cAliasOr12)->D2_QTDEDEV)                                                          //MV_PAR22 == 2 Nao considera devolucoes			
	     nQtde2:= IIF(MV_PAR22 == 2,(cAliasOr12)->D2_QTSEGUM,(cAliasOr12)->D2_QTSEGUM - ROMS003L((cAliasOr12)->D2_QUANT,(cAliasOr12)->D2_QTDEDEV,(cAliasOr12)->D2_QTSEGUM))//MV_PAR22 == 2 Nao considera devolucoes						
         nTotal:= IIF(MV_PAR22 == 2,(cAliasOr12)->D2_TOTAL  ,(cAliasOr12)->D2_TOTAL   - (cAliasOr12)->D2_VALDEV)                                                           //MV_PAR22 == 2 Nao considera devolucoes					
		 nVlBru:= IIF(MV_PAR22 == 2,(cAliasOr12)->D2_VALBRUT,(cAliasOr12)->VLRBRUTDEV)

		 _nI := Ascan(_aDadosExcel,{|x| x[1]+x[2]+x[4] == (cAliasOr12)->D2_FILIAL + (cAliasOr12)->D2_EST + (cAliasOr12)->B1_I_SUBGR })

		 If _nI == 0
		    Aadd(_aDadosExcel,{(cAliasOr12)->D2_FILIAL,;  // 01
		                       (cAliasOr12)->D2_EST,;     // 02
                               _cRegiao,;                 // 03
                               (cAliasOr12)->B1_I_SUBGR,; // 04  - Codigo do Sub Grupo
							   _cDescSubg ,;              // 05  - (cAliasOr12)->DESCSUBGR - Descricao do Sub Grupo
						  	   nQtde1,;                   // 06  - Quantidade na primeira unidade de Medida
						  	   (cAliasOr12)->D2_UM,;      // 07  - Primeira unidade de Medida  
						  	   nQtde2,;                   // 08  - Quantidade na segunda unidade de Medida 
						  	   (cAliasOr12)->D2_SEGUM,;   // 09  - Segunda unidade de Medida  
							   nTotal/nQtde1,;	          // 10 
						  	   nTotal,;                   // 11 - valor total 
						  	   nVlBru,;                   // 12
						  	   (cAliasOr12)->PESTOTAL;    // 13 - Peso total 
						  	   })      
         Else
            _aDadosExcel[_nI,6]  += nQtde1                   // 6  - Quantidade na primeira unidade de Medida
			_aDadosExcel[_nI,8]	 += nQtde2                   // 8  - Quantidade na segunda unidade de Medida 
			_aDadosExcel[_nI,11] +=	nTotal                   // 11 - valor total 
			_aDadosExcel[_nI,12] += (cAliasOr12)->PESTOTAL   // 12 - Peso total 
			_aDadosExcel[_nI,10] :=  _aDadosExcel[_nI,11] / _aDadosExcel[_nI,6] // Preço Unit
		 EndIf

	     (cAliasOr12)->(dbSkip())	 
	  EndDo
 
      If Empty(_aDadosExcel)
         U_ITMSG("Não foram encontrados dados para emissão do relatório em Excel que satisfaçam as condições de filtro.","Atenção", ,1)
	  Else
	     _aSX1:=ROMS003P()     
		 _cMsgTop:= _cTitulo+" / Exportação disponiveis: XML / CSV / EXCEL / ARQUIVO"
		                             //      ,_aCols     ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab  , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1 )
	     U_ITListBox(_cTitulo , _aTitulos , _aDadosExcel , .T.    , 1    ,_cMsgTop,          ,        ,         ,     ,        ,          ,aCabXML,         ,          ,           ,         ,       ,          ,_aSX1)
      EndIf

	  BREAK  // FINALIZA A EMISSÃO DO RELATÓRIIO EM EXCEL DE ESTADOS E SUBGRUPOS.

   EndIf

   oproc:cCaption := ("Lendo Dados - Pre-processamento 2/2" )
   ProcessMessages()
   //==========================================================================
   // Relatório Impresso 
   //==========================================================================
   Do While (cAliasOr12)->(!Eof())  
      //IncProc("Os dados do Relatorio estado sendo Processados...")   
      IF oproc <> NIL
         nConta++
         oproc:cCaption := ("Lendo : "+STRZERO(nConta,5) +" de "+ _cTotGeral )
         ProcessMessages()
      ENDIF
      
	  //MV_PAR22 == 2 Nao considera devolucoes
      nQtde1:= IIF(MV_PAR22 == 2,(cAliasOr12)->D2_QUANT  ,(cAliasOr12)->D2_QUANT   - (cAliasOr12)->D2_QTDEDEV)                                                          //MV_PAR22 == 2 Nao considera devolucoes			
	  nQtde2:= IIF(MV_PAR22 == 2,(cAliasOr12)->D2_QTSEGUM,(cAliasOr12)->D2_QTSEGUM - ROMS003L((cAliasOr12)->D2_QUANT,(cAliasOr12)->D2_QTDEDEV,(cAliasOr12)->D2_QTSEGUM))//MV_PAR22 == 2 Nao considera devolucoes						
      nTotal:= IIF(MV_PAR22 == 2,(cAliasOr12)->D2_TOTAL  ,(cAliasOr12)->D2_TOTAL   - (cAliasOr12)->D2_VALDEV)                                                           //MV_PAR22 == 2 Nao considera devolucoes					
	  nVlBru:= IIF(MV_PAR22 == 2,(cAliasOr12)->D2_VALBRUT,(cAliasOr12)->VLRBRUTDEV)

      //Alimenta array contendo todas as Filiais
      _nPosFil := aScan( _aFiliais,{|x| x[1] == (cAliasOr12)->D2_FILIAL })        
			
      If _nPosFil == 0
         aAdd(_aFiliais,{(cAliasOr12)->D2_FILIAL})     
      EndIf
	        
      //Alimenta array para geracao do relatorio por Filial + Estado + Sub Grupo
      ROMS003CG(nQtde1,nQtde2,nTotal)     
      //Alimenta arrya para geracao do relatorio por Filial + Regiao + Sub Grupo
      ROMS003RE(nQtde1,nQtde2,nTotal)
      //Alimenta array para geracao do relatorio por Filial + Sub Grupo
      ROMS003RS(nQtde1,nQtde2,nTotal)
				         
      dbSelectArea(cAliasOr12)
      (cAliasOr12)->(dbSkip())
   EndDo

   dbSelectArea(cAliasOr12)
   (cAliasOr12)->(dbCloseArea())
		                   
   //Ordena os dados por Filial + Regiao + Sub-Grupo de Produto
   _aSubGrupo := ASORT(_aSubGrupo,,, { |x, y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] }) //CRESCENTE Alfabetica  	  
	
   //Ordena os dados por Filial + Regiao + Sub-Grupo de Produto
   _aDadosReg := ASORT(_aDadosReg,,, { |x, y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] }) //CRESCENTE Alfabetica     
	
   //Efetua a impressao dos dados do Relatorio
   For _nI:=1 to Len(_aFiliais)      
       //Quebra de Pagina
       ROMS003QX()  
       nlinha+=nSaltoLinha 
       nlinha+=nSaltoLinha      
		
       //Seta variaveis de controle dos totalizadores por Filial
       _nTFilQtd1:= 0
       _nTFilQtd2:= 0
       _nTFilVlTo:= 0
       _nTFilPeso:= 0
		
       //Imprime os dados por Filial + Estado + Sub Grupo
       ROMS003IS(_aFiliais[_nI,1])
		                                		                        
       //Quebra de Pagina
       ROMS003QX() 
	   //Imprime os dados das Regios por Filial + Regiao + Sub Grupo
       ROMS003ID(_aFiliais[_nI,1])    
		
       //Imprime os dados Resumidos por Filial + Sub Grupo 
       ROMS003IR(_aFiliais[_nI,1])               
		
       nlinha+=nSaltoLinha                   
       nlinha+=nSaltoLinha        
       ROMS003QE(0,0,0)
       //Imprime o Totalizador por Filial
       ROMS003PE("TOTAL FILIAL: " + _aFiliais[_nI,1] + '-' + FWFilialName(,_aFiliais[_nI,1]),_nTFilQtd1,_nTFilQtd2,_nTFilVlTo,_nTFilPeso)
   Next _nI

End Sequence

Return    

/*
===============================================================================================================================
Programa--------: ROMS003CG
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que consulta os dados de subgrupos
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003CG(nQtde1,nQtde2,nTotal)  

Local _nPosSubGr:= 0   
Local _nPosMun  := 0 
                         
	//Efetua o grupamento dos dados do relatorio por Filial + Estado + Sub-Grupo
	_nPosSubGr := aScan( _aSubGrupo,{|x| x[1] + x[2] + x[3] == (cAliasOr12)->D2_FILIAL + (cAliasOr12)->D2_EST +  (cAliasOr12)->B1_I_SUBGR }) 
	
	If  _nPosSubGr > 0                 
	
		_aSubGrupo[_nPosSubGr,05]+= nQtde1
		_aSubGrupo[_nPosSubGr,07]+= nQtde2
		_aSubGrupo[_nPosSubGr,09]+= nTotal
		_aSubGrupo[_nPosSubGr,10]+= (cAliasOr12)->PESTOTAL
		_aSubGrupo[_nPosSubGr,11]+= nVlBru
	     
		Else    
            _cDescSubg := POSICIONE("ZB9",1,xFilial("ZB9")+(cAliasOr12)->B1_I_SUBGR,"ZB9_DESSUB")

		   	aAdd(_aSubGrupo,{ (cAliasOr12)->D2_FILIAL,;    //01 - Filial
							  (cAliasOr12)->D2_EST ,;      //02 - Estado
							  (cAliasOr12)->B1_I_SUBGR,;   //03 - Codigo do Sub Grupo
							  _cDescSubg,;                 //04 - Descricao do Sub Grupo //(cAliasOr12)->DESCSUBGR,;    
						  	  nQtde1,;                     //05 - Quantidade na primeira unidade de Medida
						  	  (cAliasOr12)->D2_UM,;        //06 - Primeira unidade de Medida  
						  	  nQtde2,;                     //07 - Quantidade na segunda unidade de Medida 
						  	  (cAliasOr12)->D2_SEGUM,;     //08 - Segunda unidade de Medida  
						  	  nTotal,;                     //09 - valor total 
						  	  (cAliasOr12)->PESTOTAL,;     //10 - Peso total 
							  nVlBru ;                     //11 - VALOR BRUTO
						  	})   						  	  					  	  						  	             
	
	EndIf 
	               
	//Considera somente os municipio que nao foram lancados para depois saber quantos municipos por Filial + estado foram abrangidos
	_nPosMun := aScan( _aQtdeMun,{|x| x[1] + x[2] + x[3] == (cAliasOr12)->D2_FILIAL + (cAliasOr12)->D2_EST + (cAliasOr12)->A1_COD_MUN })  
	
	If _nPosMun == 0  
	
			aAdd(_aQtdeMun, {   (cAliasOr12)->D2_FILIAL,;  //1  - Filial
							    (cAliasOr12)->D2_EST,;   //2  - Estado
						  	    (cAliasOr12)->A1_COD_MUN;  //3  - Codigo do Municipio
						  	 })  
	
	EndIf 
	
Return

/*
===============================================================================================================================
Programa--------: ROMS003RE
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que consulta os dados por região
Parametros------: nQtde1 = Quantidade 1 unidade
                  nQtde2 = Quantidade 2 unidade
				  nTotal = Valor total
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003RE(nQtde1,nQtde2,nTotal)

Local _nPosReg  := 0  
Local _nPosDados:= 0          
Local _cRegiao  := ""
Local _cDescSubg

      	//Retorna a regiao pertencente ao estado do cliente informado no pedido de venda
		_nPosReg := aScan( _aRegioes,{|x| x[2] == (cAliasOr12)->D2_EST }) 
		
		If _nPosReg > 0
		
			_cRegiao:= _aRegioes[_nPosReg,1]
			
		EndIf
		
	//Efetua o grupamento dos dados do relatorio por Filial + Regiao + Sub-Grupo
	_nPosDados := aScan( _aDadosReg,{|x| x[1] + x[2] + x[3] == (cAliasOr12)->D2_FILIAL + _cRegiao +  (cAliasOr12)->B1_I_SUBGR }) 
	
	If  _nPosDados > 0                 
	
		_aDadosReg[_nPosDados,05] += nQtde1
		_aDadosReg[_nPosDados,07] += nQtde2
		_aDadosReg[_nPosDados,09] += nTotal
		_aDadosReg[_nPosDados,10] += (cAliasOr12)->PESTOTAL
		_aDadosReg[_nPosDados,11] += nVlBru
	     
		Else    
		    
            _cDescSubg := POSICIONE("ZB9",1,xFilial("ZB9")+(cAliasOr12)->B1_I_SUBGR,"ZB9_DESSUB")
			aAdd(_aDadosReg,{ (cAliasOr12)->D2_FILIAL,;  //01  - Filial
							  _cRegiao,;                 //02  - Regiao
							  (cAliasOr12)->B1_I_SUBGR,; //03  - Codigo do Sub Grupo
							  _cDescSubg ,;              //04  - (cAliasOr12)->DESCSUBGR,;  //4  - Descricao do Sub Grupo
						  	   nQtde1,;                  //05  - Quantidade na primeira unidade de Medida
						  	  (cAliasOr12)->D2_UM,;      //06  - Primeira unidade de Medida  
						  	   nQtde2,;                  //07  - Quantidade na segunda unidade de Medida 
						  	  (cAliasOr12)->D2_SEGUM,;   //08  - Segunda unidade de Medida  
						  	   nTotal,;                  //09  - valor total 
						  	  (cAliasOr12)->PESTOTAL,;   //10 - Peso total 
							  nVlBru;                    //11 - valor BRUTO
						  	 })            
	
	EndIf 
	
Return
          
/*
===============================================================================================================================
Programa--------: ROMS003RS
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que consulta os dados de forma resumida
Parametros------: nQtde1 = Quantidade 1 unidade
                  nQtde2 = Quantidade 2 unidade
				  nTotal = Valor total
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003RS(nQtde1,nQtde2,nTotal)

Local _nPosRes := 0
Local _nPosPorc:= 0
Local _cDescSubg := ""

	//Efetua o grupamento dos dados do relatorio por Filial + Regiao + Sub-Grupo
	_nPosRes := aScan( _aDadosRes,{|x| x[1] + x[2] == (cAliasOr12)->D2_FILIAL + (cAliasOr12)->B1_I_SUBGR }) 
	
	If  _nPosRes > 0                 
	
		_aDadosRes[_nPosRes,04] += nQtde1
		_aDadosRes[_nPosRes,06] += nQtde2
		_aDadosRes[_nPosRes,08] += nTotal
		_aDadosRes[_nPosRes,09] += (cAliasOr12)->PESTOTAL
		_aDadosRes[_nPosRes,10] += nVlBru
	     
		Else    
		    _cDescSubg := POSICIONE("ZB9",1,xFilial("ZB9")+(cAliasOr12)->B1_I_SUBGR,"ZB9_DESSUB")

			aAdd(_aDadosRes,{ (cAliasOr12)->D2_FILIAL,;  //01 - Filial
							  (cAliasOr12)->B1_I_SUBGR,; //02 - Codigo do Sub Grupo
							  _cDescSubg,;               //03 - (cAliasOr12)->DESCSUBGR,;  //3  - Descricao do Sub Grupo
						  	   nQtde1,;  			     //04 - Quantidade na primeira unidade de Medida
						  	  (cAliasOr12)->D2_UM,;      //05 - Primeira unidade de Medida  
						  	   nQtde2,;                  //06 - Quantidade na segunda unidade de Medida 
						  	  (cAliasOr12)->D2_SEGUM,;   //07 - Segunda unidade de Medida  
						  	   nTotal,;                  //08 - valor total 
						  	  (cAliasOr12)->PESTOTAL,;   //09 - Peso total 
							  nVlBru;                    //10 - valor BRUTO
						  	 })            
	
	EndIf     
	
	
	//Array utilizado para calculo da quantidade total do peso por Filial do Produto utilizada para gerar a porcentagem
	_nPosPorc := aScan( _aPorcResu,{|x| x[1] + x[2] == (cAliasOr12)->D2_FILIAL + (cAliasOr12)->B1_I_SUBGR }) 
	
	If _nPosPorc > 0          
		 
			_aPorcResu[_nPosPorc,3]+= (cAliasOr12)->PESTOTAL	
	
		Else    
		
				aAdd(_aPorcResu,{ (cAliasOr12)->D2_FILIAL,;   //1  - Filial      
								   (cAliasOr12)->B1_I_SUBGR,; //2  - Codigo do Sub Grupo
						  	       (cAliasOr12)->PESTOTAL;    //3  - Peso total 
						  	 })             
	
	EndIf	
	    

Return

/*
===============================================================================================================================
Programa--------: ROMS003IS
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime os dados de subgrupos
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003IS(_cFilial)
             
Local _cEst     := ""    
Local _nTotPeEst:= 0                   
Local _nPosPeso := 0

//Totalizadores
Local _nTEstQtd1:= 0
Local _nTEstQtd2:= 0
Local _nTEstVlTo:= 0
Local _nTEstPeso:= 0
Local z			:= 0
//Imprime cabecalho da Filial corrente
ROMS003CF(_cFilial)

	For z:=1 to Len(_aSubGrupo)
	
		//Verifica se eh a mesma filial
		If _aSubGrupo[z,1] == _cFilial 
		         
			If _cEst <> _aSubGrupo[z,2]       
			
				//Imprime Box caso nao seja o primeiro estado de uma filial 
				//If z > 1
				If Len(AllTrim(_cEst)) > 0 
					
					ROMS003BR()
					
					nlinha+=nSaltoLinha  
					ROMS003QE(0,0,0)
					//Imprime totalizador por Filial
					ROMS003PE("SUB-TOTAL ESTADO: " + _cEst,_nTEstQtd1,_nTEstQtd2,_nTEstVlTo,_nTEstPeso)
					nlinha+=nSaltoLinha
					
				EndIf 
			                     
				nlinha+=nSaltoLinha 
				nlinha+=nSaltoLinha 
				ROMS003QE(0,0,0)
			   //Imprime cabecalho do Estado
				ROMS003CE(_aSubGrupo[z,2])
				    
				nlinha+=nSaltoLinha 
				nlinha+=nSaltoLinha  
				ROMS003QE(0,0,0)
				//Imprime o total de Municipios Abrangidos
				oPrint:Say (nlinha,nColInic,"Municípios Abrangidos: " + ROMS003RM(_aSubGrupo[z,1],_aSubGrupo[z,2]),oFont12b)

				
				nlinha+=nSaltoLinha 
				nlinha+=nSaltoLinha  
				ROMS003QE(0,0,0)
				//Imprime cabecalho dos Dados
				ROMS003CM()    
							 
				 //Seta Totalizadores
				 _nTEstQtd1:= _aSubGrupo[z,5]
				 _nTEstQtd2:= _aSubGrupo[z,7]
				 _nTEstVlTo:= _aSubGrupo[z,9]
				 _nTEstPeso:= _aSubGrupo[z,10]
				 
				 Else
				 	
				 	    //Incrementa Totalizadores por Estado
						_nTEstQtd1+= _aSubGrupo[z,5]
					    _nTEstQtd2+= _aSubGrupo[z,7]
					    _nTEstVlTo+= _aSubGrupo[z,9]
					    _nTEstPeso+= _aSubGrupo[z,10]
				
			EndIf                              
			    
			//Funcao responsavel por retornar o Peso total da Filial + Estado Corrente, utlizado para gerar a porcentagem 
			 _nPosPeso := aScan( _aPorcResu,{|x| x[1] + x[2] == _aSubGrupo[z,1] + _aSubGrupo[z,3]})   
			                     
			If _nPosPeso > 0
			 	_nTotPeEst:= _aPorcResu[_nPosPeso,3]
			EndIf            
			
			//Imprime os dados do Sub Grupo
			nlinha+=nSaltoLinha
			ROMS003QE(1,1,1)    		
			oPrint:Line(nLinha,nColInic,nLinha,nColFinal) 
			
			ROMS003PD(_aSubGrupo[z,3],_aSubGrupo[z,4],_aSubGrupo[z,5],_aSubGrupo[z,6],_aSubGrupo[z,7],;
			           _aSubGrupo[z,8],_aSubGrupo[z,9],_aSubGrupo[z,10],IIF(_nTotPeEst > 0,((_aSubGrupo[z,10]/_nTotPeEst)*100),0))
			
			_cEst:=	_aSubGrupo[z,2] 			
			
			//Incrementa Totalizadores por Filial
			_nTFilQtd1+= _aSubGrupo[z,5]
			_nTFilQtd2+= _aSubGrupo[z,7]
			_nTFilVlTo+= _aSubGrupo[z,9]
			_nTFilPeso+= _aSubGrupo[z,10]
		
		EndIf	
	
	Next z          
	  
	//Fecha o box do ultimo estado impresso  
	ROMS003BR() 
	
	nlinha+=nSaltoLinha 
	ROMS003QE(0,0,0)				
	//Imprime totalizador por Filial
	ROMS003PE("SUB-TOTAL ESTADO: " + _cEst,_nTEstQtd1,_nTEstQtd2,_nTEstVlTo,_nTEstPeso)
	nlinha+=nSaltoLinha 

Return
                                            
/*
===============================================================================================================================
Programa--------: ROMS003RM
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que retorna a quantidade de municipios abrangidos pelo estado
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003RM(_cFilial,_cEstado)   

Local _nCont:= 0
Local _nX	:= 0
	For _nX:=1 to Len(_aQtdeMun)  
	
		If _aQtdeMun[_nX,1] == _cFilial .And. _aQtdeMun[_nX,2] == _cEstado
		
			++_nCont     
		
		EndIf
	
	Next _nX
	
	_nCont:= AllTrim(Str(_nCont))

Return _nCont
                                   
/*
===============================================================================================================================
Programa--------: ROMS003ID
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime os dados por regiões
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003ID(_cFilial) 

Local _cRegiao  := ""    
Local _nPosPeso := 0
Local _nTotPeEst:= 0   
Local w			:= 0

//Totalizadores
Local _nTEstQtd1:= 0
Local _nTEstQtd2:= 0
Local _nTEstVlTo:= 0
Local _nTEstPeso:= 0    

For w:=1 to Len(_aDadosReg)
	
		//Verifica se eh a mesma filial
		If _aDadosReg[w,1] == _cFilial 
		         
			If _cRegiao <> _aDadosReg[w,2]       
			
				//Imprime Box caso nao seja o primeiro estado de uma filial
				If Len(AllTrim(_cRegiao)) > 0
					
					ROMS003BR()
					
					nlinha+=nSaltoLinha  
					ROMS003QE(0,0,0)
					//Imprime totalizador por Filial
					ROMS003PE("SUB-TOTAL REGIÃO: " + _cRegiao,_nTEstQtd1,_nTEstQtd2,_nTEstVlTo,_nTEstPeso)
					nlinha+=nSaltoLinha
					
				EndIf 
			                     
				nlinha+=nSaltoLinha 
				nlinha+=nSaltoLinha 
				ROMS003QE(0,0,0)
			   //Imprime cabecalho da Regiao
				ROMS003CI(_aDadosReg[w,2])				    
				
				nlinha+=nSaltoLinha 
				nlinha+=nSaltoLinha  
				ROMS003QE(0,0,0)
				//Imprime cabecalho dos Dados
				ROMS003CM()    						                 
				 
				 //Seta Totalizadores
				 _nTEstQtd1:= _aDadosReg[w,5]
				 _nTEstQtd2:= _aDadosReg[w,7]
				 _nTEstVlTo:= _aDadosReg[w,9]
				 _nTEstPeso:= _aDadosReg[w,10]
				 
				 Else
				 	
				 	    //Incrementa Totalizadores por Estado
						_nTEstQtd1+= _aDadosReg[w,5]
					    _nTEstQtd2+= _aDadosReg[w,7]
					    _nTEstVlTo+= _aDadosReg[w,9]
					    _nTEstPeso+= _aDadosReg[w,10]
				
			EndIf               
			
			//Funcao responsavel por retornar o Peso total da Filial + Estado Corrente, utlizado para gerar a porcentagem 
			 _nPosPeso := aScan( _aPorcResu,{|x| x[1] + x[2] == _aDadosReg[w,1] + _aDadosReg[w,3]})   
				                     
			 If _nPosPeso > 0
				_nTotPeEst:= _aPorcResu[_nPosPeso,3]
			EndIf                      
			
			//Imprime os dados do Sub Grupo
			nlinha+=nSaltoLinha
			ROMS003QE(1,1,1)    		
			oPrint:Line(nLinha,nColInic,nLinha,nColFinal) 
			
			ROMS003PD(_aDadosReg[w,3],_aDadosReg[w,4],_aDadosReg[w,5],_aDadosReg[w,6],_aDadosReg[w,7],;
			           _aDadosReg[w,8],_aDadosReg[w,9],_aDadosReg[w,10],IIF(_nTotPeEst > 0,((_aDadosReg[w,10]/_nTotPeEst)*100),0),_aDadosReg[w,11])
			
			_cRegiao:=	_aDadosReg[w,2] 			
					
		EndIf	
	
	Next w          
	  
	//Fecha o box do ultimo estado impresso  
	ROMS003BR() 
	
	nlinha+=nSaltoLinha 
	ROMS003QE(0,0,0)				
	//Imprime totalizador por Filial
	ROMS003PE("SUB-TOTAL REGIÃO: " + _cRegiao,_nTEstQtd1,_nTEstQtd2,_nTEstVlTo,_nTEstPeso)
	nlinha+=nSaltoLinha 

Return

/*
===============================================================================================================================
Programa--------: ROMS003IR
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime os dados resumidos
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/

Static Function ROMS003IR(_cFilial)
             
Local _nPosPeso:= 0    
Local _nTotPeso:= 0
Local v			:= 0
//Ordena os dados por Filial + Sub-Grupo de Produto
_aDadosRes := ASORT(_aDadosRes,,, { |x, y| x[1]+x[2] < y[1]+y[2] }) //CRESCENTE Alfabetica
    
	nlinha+=nSaltoLinha 
	nlinha+=nSaltoLinha  
	ROMS003QE(0,0,0)
	ROMS003CA(_cFilial)     

	nlinha+=nSaltoLinha 
	nlinha+=nSaltoLinha  
	ROMS003QE(0,0,0)
	//Imprime cabecalho dos Dados
	ROMS003CM()   
				
	For v:=1 to Len(_aDadosRes)  
	
		If _aDadosRes[v,1] == _cFilial	                                 
			
			//Funcao responsavel por retornar o Peso total da Filial + Estado Corrente, utlizado para gerar a porcentagem 
			 _nPosPeso := aScan( _aPorcResu,{|x| x[1] == _aDadosRes[v,1] })   
				                     
			 If _nPosPeso > 0
			 	_nTotPeso:= _aPorcResu[_nPosPeso,2]
			 EndIf   
			            
			nlinha+=nSaltoLinha
			ROMS003QE(1,1,1)    		
			oPrint:Line(nLinha,nColInic,nLinha,nColFinal)   
			//Imprime os dados resumido por Filial + Sub-Grupo
			ROMS003PD(_aDadosRes[v,2],_aDadosRes[v,3],_aDadosRes[v,4],_aDadosRes[v,5],_aDadosRes[v,6],;
			           _aDadosRes[v,7],_aDadosRes[v,8],_aDadosRes[v,9],100,_aDadosRes[v,10])                              
	                                  
		EndIf
	
	Next v
	
	//Fecha o box 
	ROMS003BR() 

Return

/*
===============================================================================================================================
Programa--------: ROMS003CE
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime os dados do cabeçalho dos estados
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003CE(cCodEstado)
                                                                           
oPrint:FillRect({(nlinha+3),nColInic,nlinha + nSaltoLinha,nColFinal - 1270},oBrush)                    
oPrint:Box(nlinha,nColInic,nLinha + nSaltoLinha,nColFinal - 1270)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 25  ,"Estado:",oFont14Prb)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 230  ,cCodEstado + '-' + POSICIONE("SX5",1,XFILIAL("SX5")+"12" + cCodEstado,"X5_DESCRI"),oFont14Prb)

Return   

/*
===============================================================================================================================
Programa--------: ROMS003CI
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime os dados do cabeçalho de regiões
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003CI(cRegiao)
                                                                           
oPrint:FillRect({(nlinha+3),nColInic,nlinha + nSaltoLinha,nColFinal - 1270},oBrush)                    
oPrint:Box(nlinha,nColInic,nLinha + nSaltoLinha,nColFinal - 1270)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 25   ,"Regiao:",oFont14Prb)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 230  ,cRegiao  ,oFont14Prb)

Return       

/*
===============================================================================================================================
Programa--------: ROMS003CA
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime os dados do cabeçalho resumido
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003CA(_cFil)
                                                                           
oPrint:FillRect({(nlinha+3),nColInic,nlinha + nSaltoLinha,nColFinal - 1270},oBrush)                    
oPrint:Box(nlinha,nColInic,nLinha + nSaltoLinha,nColFinal - 1270)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 25   ,"Total por Sub-Grupo da Filial: " + _cFil + '-' + FWFilialName(,_cFil),oFont14Prb)

Return           
      
/*
===============================================================================================================================
Programa--------: ROMS003CM
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime os dados do cabeçalho por subgrupo
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003CM()

nLinInBox:= nlinha

oPrint:Say (nlinha + nAjuAltLi1,nColInic + 10   ,"Sub-Grupo"         ,oFont12b)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 244  ,"Descrição"         ,oFont12b)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 994  ,"Quantidade 1a(UN)" ,oFont12b)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 1388 ,"Quantidade 2a(UN)" ,oFont12b)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 1842 ,"Preço Unitário"    ,oFont12b)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 2306 ,"Valor Total"       ,oFont12b)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 2640 ,"Peso Total(KG)"    ,oFont12b)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 3080 ,"Percentual"        ,oFont12b)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 3500 ,"Valor Bruto"       ,oFont12b)

Return

/*
===============================================================================================================================
Programa--------: ROMS003PD
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime os dados do relatório
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003PD(cCodSubGr,cDesSubGr,nQtde1,cUm1,nQtde2,cUm2,nVlrTotal,nPesoTotal,nPercent,nVlrBruto)
//DEFAULT nVlrBruto:=nVlrTotal
oPrint:Say(nlinha + nAjuAltLi1,nColInic + 10   ,cCodSubGr	         									             ,oFont10)
oPrint:Say(nlinha + nAjuAltLi1,nColInic + 244  ,IIF(Len(AllTrim(cDesSubGr)) > 0,SubStr(cDesSubGr,1,40),'Sem Sub-Grupo'),oFont10)
oPrint:Say(nlinha + nAjuAltLi1,nColInic + 994  ,Transform(nQtde1    	   ,"@E 99,999,999,999.99") + '-' + cUm1    ,oFont10)
oPrint:Say(nlinha + nAjuAltLi1,nColInic + 1388 ,Transform(nQtde2    	   ,"@E 99,999,999,999.99") + '-' + cUm2    ,oFont10)
oPrint:Say(nlinha + nAjuAltLi1,nColInic + 1800 ,Transform(nVlrTotal/nQtde1,"@E 99,999,999,999.9999")              ,oFont10)
oPrint:Say(nlinha + nAjuAltLi1,nColInic + 2236 ,Transform(nVlrTotal       ,"@E 99,999,999,999.99")			    ,oFont10)
oPrint:Say(nlinha + nAjuAltLi1,nColInic + 2630 ,Transform(nPesoTotal      ,"@E 99,999,999,999.99")			    ,oFont10)
oPrint:Say(nlinha + nAjuAltLi1,nColInic + 3144 ,Transform(nPercent        ,"@E 999.999")+ ' %' 		            ,oFont10)
//oPrint:Say(nlinha + nAjuAltLi1,nColInic + 3658 ,Transform(nVlrBruto,"@E 99,999,999,999.99"),oFont10)//NÃO TEM ESPAÇO NA IMPRESSAO

Return 

/*
===============================================================================================================================
Programa--------: ROMS003PE
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime os dados de totalizadores do relatório
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003PE(cDescri,nQtde1,nQtde2,nVlrTotal,nPesoTotal,nVlrBruto)
//DEFAULT nVlrBruto:=nVlrTotal

oPrint:Say (nlinha + nAjuAltLi1,nColInic + 10   ,SubStr(cDescri,1,49)      									    ,oFont10b)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 994  ,Transform(nQtde1    	   ,"@E 99,999,999,999.99") + '   '     ,oFont10b)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 1388 ,Transform(nQtde2    	   ,"@E 99,999,999,999.99") + '   '     ,oFont10b)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 2236 ,Transform(nVlrTotal       ,"@E 99,999,999,999.99")			    ,oFont10b)
oPrint:Say (nlinha + nAjuAltLi1,nColInic + 2630 ,Transform(nPesoTotal      ,"@E 99,999,999,999.99")			    ,oFont10b)
//oPrint:Say (nlinha + nAjuAltLi1,nColInic + 3024 ,Transform(nVlrBruto     ,"@E 99,999,999,999.99")			    ,oFont10b) //NÃO TEM ESPAÇO NA IMPRESSAO

Return       

/*
===============================================================================================================================
Programa--------: ROMS003BR
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que imprime os box de divisão do relatório
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003BR()

//Para que o Box pegue a ultima linha
nlinha+=nSaltoLinha  
      
oPrint:Line(nLinInBox,nColInic + 239 ,nLinha,nColInic + 239 ) //SubGrupo | Descricao
oPrint:Line(nLinInBox,nColInic + 989 ,nLinha,nColInic + 989 ) //Descricac | Quantidade 1
oPrint:Line(nLinInBox,nColInic + 1383,nLinha,nColInic + 1383) //Quantidade 1 | Quantidade 2
oPrint:Line(nLinInBox,nColInic + 1777,nLinha,nColInic + 1777) //Quantidade 2 | Preco Unitario
oPrint:Line(nLinInBox,nColInic + 2171,nLinha,nColInic + 2171) //Preco Unitario | Valor Total
oPrint:Line(nLinInBox,nColInic + 2565,nLinha,nColInic + 2565) //Valor Total | Peso Total 
oPrint:Line(nLinInBox,nColInic + 2959,nLinha,nColInic + 2959) //Peso Total | Percentual

oPrint:Box(nLinInBox,nColInic,nLinha,nColFinal)

Return 

/*
===============================================================================================================================
Programa--------: ROMS003QE
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que processa as quebras de paginas
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003QE(nLinhas,impBox,impCabec)   

	//Quebra de pagina
	If nLinha > nqbrPagina
				
		nlinha:= nlinha - (nSaltoLinha * nLinhas)
		
		If impBox == 1
			ROMS003BR()	
		EndIf	 
		
		oPrint:EndPage()					// Finaliza a Pagina.
		oPrint:StartPage()					//Inicia uma nova Pagina					
		
		nPagina++
		
		ROMS003C(1)//Chama cabecalho    
		
		nlinha+=nSaltoLinha                   
		nlinha+=nSaltoLinha  
		  
		If impCabec == 1
			ROMS003CM()    
			nlinha+=nSaltoLinha
		EndIf   
		
	EndIf  
	
Return

/*
===============================================================================================================================
Programa--------: ROMS003QX
Autor-----------: Jeovane
Data da Criacao-: 12/03/2009
Descrição-------: Funcao que processa as quebras de paginas
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS003QX()    

	//Para que cada pagina comece em uma nova pagian
	oPrint:EndPage()		// Finaliza a Pagina.
	oPrint:StartPage()		//Inicia uma nova Pagina					
		
	nPagina++
		
	ROMS003C(1)//Chama cabecalho 

Return


/*
===============================================================================================================================
Programa----------: ROMS003F
Autor-------------: Julio de Paula Paz
Data da Criacao---: 23/11/2016
Descrição---------: Retornar o nome da filial 
Parametros--------: _cCodFilial = Codigo da Filial
Retorno-----------: Nome da Filial
===============================================================================================================================
*/
User Function ROMS003F(_cCodFilial)
Local _cRet := ""    
Local _aFilial := _aFilSM0
Local _nI
Local _cSM0_NOME := 7 // Nome da filial 

Begin Sequence                                  
   If Empty(_cCodFilial)
      Break
   EndIf
   
   _nI := Ascan(_aFilial,{|x| x[5] = _cCodFilial})   
   If _nI > 0
      _cRet := _aFilial[_nI,_cSM0_NOME]
   EndIf   

End Sequence

Return _cRet 

/*
===============================================================================================================================
Programa----------: ROMS003H
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/10/2017
Descrição---------: Retorna o local de entrega do pedido de vendas, levando em consideração os pedidos de compras dos 
                    funcionários Italac (Tabela Z12). 
Parametros--------: _cCodFil = Filial da nota fiscal
                    _cNumPed = Numero do pedido de vendas gravado na tabela SF2.
Retorno-----------: Nome do local de entrega.
===============================================================================================================================
*/
User Function ROMS003H(_cCodFil,_cNumPed)
Local _cRet := ""    
Local _aOrd := SaveOrd({"SC5","Z12"})

Begin Sequence     
   Z12->(DbSetOrder(3))
   
   If Z12->(DbSeek(_cCodFil+_cNumPed))
      _cRet := AllTrim(Upper(U_ITRetBox( Z12->Z12_LOCENT ,"Z12_LOCENT")))
      Break
   EndIf
   
   SC5->(DbSetOrder(1))
   If SC5->(DbSeek(_cCodFil+_cNumPed))
      _cRet :=  AllTrim(SC5->C5_I_MUN) +"/"+ Alltrim(SC5->C5_I_EST)
   EndIf

End Sequence

RestOrd(_aOrd)

Return _cRet 

/*
===============================================================================================================================
Programa----------: ROMS003J
Autor-------------: Julio de Paula Paz
Data da Criacao---: 30/11/2018
Descrição---------: Retornar os dados referentes aos pedidos do tipo troca nota fiscal, caso sejs um pedido troca nota,
                    para serem impressos no relatório.
Parametros--------: _cCampoRel = Campo do relatório que chamou a função e receberá a informação referente a pedidos Troca nota.
                    _cCodFil = Filial da nota fiscal
                    _cNumPed = Numero do pedido de vendas 
Retorno-----------: _cRet = Informação referente a pedido troca nota fiscal, conforme campo psssado como parâmetro.
===============================================================================================================================
*/
User Function ROMS003J(_cCampoRel, _cCodFil, _cNumPed)
Local _cRet := ""
Local _cFilPed, _cNrPed 
Local _cNomeFil, _nI
Local _aFiliais := _aFilSM0
Begin Sequence

	If _cCampoRel == "WK_FILIAL" 
   		
		ST_EMISSAO := Ctod("  /  /  ")
    	ST_PEDIDO  := ""
      	ST_CARGA   := ""
      	ST_DOCNTO  := ""
      	ST_CODCLI  := ""
      	ST_CLIENTE := ""
      	ST_FILIAL  := ""

		SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM 
		SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM
	
		// Posiciona no atual pedido de vendas do relatório.
		If !SC5->(DbSeek(_cCodFil + _cNumPed))
			Break
		ELSEIF !SC6->(DbSeek(_cCodFil + _cNumPed))
			Break
		Endif  

		ST_OBSNF   := SC5->C5_MENNOTA
		ST_PEDCLI  := SC6->C6_PEDCLI
		ST_PEDITA  := SC5->C5_NUM
		ST_PEDPOR  := SC5->C5_I_IDPED
		ST_PEDDW   := SC5->C5_I_PEDDW
		ST_DTENT   := DTOC(SC5->C5_I_DTENT)
		ST_TPAGEN  := U_TipoEntrega(SC5->C5_I_AGEND)
		
		If SC5->C5_I_TRCNF == "S"
               
      		If _cCodFil == SC5->C5_I_FLFNC .And. _cNumPed == SC5->C5_I_PDPR  
     
	    		_cFilPed := SC5->C5_I_FILFT // Filial de Faturamento
         		_cNrPed := SC5->C5_I_PDFT  // Pedido de Vendas Faturamento
      	
			Else
        
				_cFilPed := SC5->C5_I_FLFNC // Filial de carregamente.
    	     	_cNrPed := SC5->C5_I_PDPR  // Pedido de Vendas Carregamento
      	
		  	EndIf

		Else

			_cFilPed := SC5->C5_FILIAL // Filial 
    	   	_cNrPed := SC5->C5_NUM  // Pedido de Vendas 
      	
		Endif
      
      	SA1->(DbSetOrder(1))  // A1_FILIAL+A1_COD+A1_LOJA  
      	SF2->(DbSetOrder(20)) // K = F2_FILIAL+F2_I_PEDID 
      	SF2->(DbSeek(_cFilPed + _cNrPed))
      
      	SC5->(DbSeek(_cFilPed + _cNrPed))  // Posiciona no pedido de origem do Troca Nota.
		SC6->(DbSeek(_cFilPed + _cNrPed))
      	SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
        
      	ST_EMISSAO := SC5->C5_EMISSAO  // SF2->F2_EMISSAO  
      	ST_PEDIDO  := _cNrPed
      	ST_CARGA   := SF2->F2_CARGA  
      	ST_DOCNTO  := SF2->F2_DOC  + "-" + SF2->F2_SERIE
      	ST_CODCLI  := SC5->C5_CLIENTE
      	ST_CLIENTE := SA1->A1_NOME
			  
      	_nI := AsCan(_aFiliais, {|x| x[5] == _cFilPed })
      	_cNomeFil := AllTrim(_aFiliais[_nI,7])
      
	    ST_FILIAL := _cFilPed + "-" + _cNomeFil
      
    	_cRet :=  ST_FILIAL   
   
   	ElseIf _cCampoRel == "WK_EMISSAO"    
    	_cRet :=  ST_EMISSAO
   	ElseIf _cCampoRel == "WK_PEDIDO"
    	_cRet :=  ST_PEDIDO
	ElseIf _cCampoRel == "WK_CARGA"
    	_cRet :=  ST_CARGA
   	ElseIf _cCampoRel == "WK_DOCNTO"
    	_cRet :=  ST_DOCNTO
    ElseIf _cCampoRel == "WK_CODCLI" 
    	_cRet :=  ST_CODCLI
    ElseIf _cCampoRel == "WK_CLIENTE"
    	_cRet :=  ST_CLIENTE
	Elseif _cCampoRel == "WK_PEDCLI"
		_cRet :=  ST_PEDCLI
	Elseif _cCampoRel == "WK_PEDITA"
		_cRet :=  ST_PEDITA
	Elseif _cCampoRel == "WK_PEDDW"
		_cRet :=  ST_PEDDW
	Elseif _cCampoRel == "WK_DTENT"
		_cRet :=  ST_DTENT
	Elseif _cCampoRel == "WK_TPAGEN"
		_cRet :=  ST_TPAGEN
	Elseif _cCampoRel == "WK_PEDPOR"
		_cRet :=  ST_PEDPOR
	Elseif _cCampoRel == "WK_OBSNF"
		_cRet :=  ST_OBSNF
  	EndIf

End Sequence

Return _cRet

/*
===============================================================================================================================
Programa----------: RETPESOU
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 05/03/2020
Descrição---------: Retorna peso unitário
Parametros--------: cFilial = Filial de pesquisa.
                    cNota = Número da nota
					_cSerie = Série da nota
                    cProd = Código do produto
Retorno-----------: _cRet = Peso bruto do produto.
===============================================================================================================================
*/
Static Function RETPESOU(_cFilial, _cNota,_cSerie, _cProd)
	Local cRet := ""

	SC6->(DBSETORDER(4)) //C6_FILIAL+C6_NOTA+C6_SERIE                                                                                                                                      
	IF SC6->(dbSeek(_cFilial+_cNota+_cSerie))
		DO WHILE !EOF() .AND. SC6->C6_FILIAL == _cFilial .AND. SC6->C6_NOTA == _cNota
			IF SC6->C6_PRODUTO == _cProd
				cRet := SC6->C6_QTDVEN * POSICIONE("SB1",1,xFilial("SB1")+_cProd,"B1_PESBRU")
			ENDIF
		SC6->(DBSKIP())
		ENDDO
	ENDIF
Return cRet

/*
===============================================================================================================================
Programa----------: RCUSTNET
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 05/03/2020
Descrição---------: Retorna peso unitário
Parametros--------: _cFil = Filial de pesquisa.
                    _cCLi = Código do Cliente
					_cLojaCli = Loja do cliente
                    _cProd = Código do produto
					_cNumPed
Retorno-----------: _cRet = Peso bruto do produto.
===============================================================================================================================
*/
Static Function RCUSTNET(_cFil,_cCli, _cLojaCli,_cProd,_cNumPed)
	Local _nRet := 0
	Local _aVlrDesc := {}
	SZW->(DBSETORDER(12)) //ZW_NUMPED
	IF SZW->(DBSEEK(_cNumPed))
		_aVlrDesc := U_veriContrato(_cCli , _cLojaCli , _cProd ) //SZW->ZW_CLIENTE , SZW->ZW_LOJACLI , SZW->ZW_PRODUTO
		_nRet := SZW->ZW_PRCVEN - ( SZW->ZW_PRCVEN * (_aVlrDesc[1] / 100 ))
	ENDIF
Return _nRet

/*
===============================================================================================================================
Programa----------: ROMS03TR
Autor-------------: Alex Wallauer
Data da Criacao---: 14/03/2023
Descrição---------: Retorna o tipo do Coordenador e a reigao do gerente
Parametros--------: Tipo do Coordenador
Retorno-----------: Retorna o tipo do Coordenador e a reigao do gerente
===============================================================================================================================
*/
*
static function ROMS03TR(_cTipoRet)
LOCAL _cRet:=""

If _cTipoRet == "REGIAO"
   _cRet := POSICIONE("ZAM",1,xFilial("ZAM")+QRY1->F2_VEND2+QRY1->F2_VEND3,"ZAM_REGCOD")
   _cRet := ALLTRIM(POSICIONE("SX5",1,xFilial("SX5")+"ZC"+_cRet,"X5_DESCRI"))
ELSEIf _cTipoRet== "I"
  _cRet := "Interno"
ELSEIF _cTipoRet == "E"
  _cRet := "Externo"
ELSEIF _cTipoRet == "P"
  _cRet := "Parceiro"
ENDIF

RETURN _cRet

/*
===============================================================================================================================
Programa----------: ROMS3DLT
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 22/01/2018
Descrição---------: Função para conversão entre unidades de medida - COPIA DA ROMS004CNV
Parametros--------: _nQtdAux , _nUMOri , _nUMDes
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ROMS3DLT(_cColuna)
Local _nRet      := 0
Local _lAchou    := .F.
Local _cFilCarreg:= " "
STATIC nRenoSZG5 := 0
STATIC cTipofrete:= " "
STATIC _cRegra   := " "

If _cColuna == "DIASVIAGEM"
   
   SC5->(DBGOTO(QRY1->SC5RECNO))
   _cFilCarreg := SC5->C5_FILIAL 
   If !Empty(SC5->C5_I_FLFNC)
      _cFilCarreg := SC5->C5_I_FLFNC
   EndIf 
   _cFilFt := SC5->C5_FILIAL 
   If !EMPTY(SC5->C5_I_FILFT)
	  _cFilFt := SC5->C5_I_FILFT
	EndIf

   aHeader   :={}
   aCols     :={}
   _lAchouZG5:=.F.
   _lAchou:= (U_OMSVLDENT(DATE(),SC5->C5_CLIENTE,SC5->C5_LOJACLI,_cFilFt,SC5->C5_NUM,0,.F.,_cFilCarreg,SC5->C5_I_OPER,SC5->C5_I_TPVEN,@_lAchouZG5,@_cRegra))

   If _lAchouZG5
      cTipofrete:= SC5->C5_I_TPVEN
      nRenoSZG5 := ZG5->(RECNO())
      If cTipofrete = "F"
         _nRet :=ZG5->ZG5_DIASV
      ElseIf cTipofrete = "V"
         _nRet :=ZG5->ZG5_FRDIAV
      EndIf
   Else
      nRenoSZG5:=0
   EndIf

ElseIf _cColuna == "DIASOPERAC" .AND. nRenoSZG5 <> 0
   
   ZG5->(DBGOTO(nRenoSZG5))
   If cTipofrete = "F"
      _nRet :=ZG5->ZG5_TMPOPE
   ElseIf cTipofrete = "V"
      _nRet :=ZG5->ZG5_FRTOP
   EndIf

ElseIf _cColuna == "LEADTIME" 

   _cClassEnt:=QRY1->A1_I_CLABC
   IF _cClassEnt = '1'
      _cClassEnt:="1-TOP 1 NACIONAL"
   ELSEIF _cClassEnt = '2'
      _cClassEnt:="2-TOP 5 Reg. SP "
   ELSEIF _cClassEnt = '3'
      _cClassEnt:="3-TOP 5 Reg. RS "
   ENDIF

   IF  nRenoSZG5 <> 0
       ZG5->(DBGOTO(nRenoSZG5))
       If cTipofrete = "F"
          _nRet :=(ZG5->ZG5_DIASV+ZG5->ZG5_TMPOPE)
       ElseIf cTipofrete = "V"
          _nRet :=ZG5->ZG5_DIASV+ZG5->ZG5_FRTOP
       EndIf
       cTipofrete:=" "
       nRenoSZG5:=0
   EndIf

ElseIf _cColuna == "REGRA" 

   _nRet:=_cRegra
   _cRegra:=""

EndIf

RETURN _nRet
