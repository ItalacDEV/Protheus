/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
      utor    |   Data   |                                             Motivo                                           
-----------------------------------------------------------------------------------------------------------------------------
 Jerry        | 14/01/21 | Chamado 35195. Ajustar a validação do Preço para quando o produto for Queijo. 
 Alex Wallauer| 12/08/21 | Chamado 37359. Limpar campos:C5_I_TABELA/CC5_CODA1U/CC5_I_ARQOP/C5_I_MTBON/C5_I_DLIBE/C5_I_STAWF. 
 Alex Wallauer| 12/08/21 | Chamado 37359. Alterados para Inicializar todos os campos caracteres com SPACE(LEN(CAMPO)). 
 Jerry        | 03/09/21 | Chamado 37673. Acrescentados os campos C5_VOLUME1 , C5_ESPECI1 para limpar - 
 Julio Paz    | 24/09/21 | Chamado 37814. Inclusão novas regras para definir transit time na validação da data de entrega.  
 Jerry        | 07/04/22 | Chamado 39705. Acrescentados os campos C5_PBRUTO/C5_I_HRUWF,C5_I_DTUWF,C5_I_ENVML para limpar. 
 Jerry        | 08/04/22 | Chamado 39705. Correção da incializacao do campo C5_I_DTUWF. 
 Julio Paz    | 19/04/22 | Chamado 36404. Zerar pesos dos itens/capa na cópia do pedido, para o sistema recalcular. 
 Igor Melgaço | 25/05/22 | Chamado 39908. Ajuste para zerar deconto ao copiar. 
 Alex Wallauer| 12/08/22 | Chamado 40644. Acrescentado o campo C5_I_HREMI para limpar.  
 Alex Wallauer| 14/04/23 | Chamado 43562. Alterado o campo C5_I_HREMI para reiniciar com TIME().
 Alex Wallauer| 08/02/24 | Chamado 44782. Jerry. Ajustes para a nova opcao de tipo de entrega: O = Agendado pelo Op.Log.
 Alex Wallauer| 04/06/24 | Chamado 47445. Se o Pedido original for C5_TPFRETE = R gravar o novo Pedido com o tipo = C-"CIF".
 Igor Melgaço | 01/07/24 | Chamado 47184. Jerry. Ajustes para gravação do campo C6_I_PRMIN
 Julio Paz    | 14/08/24 | Chamado 46163. Vanderlei. Ajustes para não copiar conteúdo campo Protocolo Pedido TMS( C5_I_CDTMS)
==============================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Vanderlei   - Alex Wallauer - 19/03/25 - 21/03/25 - 50197   - Novo tratamento para cortes e desmembramentos de pedidos - INICIAR: M->C5_I_BLSLD = "N"
==============================================================================================================================================================
*/ 

#Include "RwMake.ch"
#Include "TopConn.ch"

/*
===============================================================================================================================
Programa----------: MT410CPY
Autor-------------: Frederico O. C. Jr
Data da Criacao---: 22/09/2008
===============================================================================================================================
Descrição---------: Ponto de Entrada na chamada da copia do Pedido de Venda
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION MT410CPY()   

Local _nX		:= 0
Local _nPos		:= 0
Local _nPosLib	:= 0
Local _nPosBl	:= 0
Local _nProd	:= 0
Local _nPrcVen	:= 0
Local _nComis1	:= 0
Local _nComis2	:= 0
Local _nComis3	:= 0
Local _nComis4	:= 0
Local _nComis5	:= 0
Local _cFilCarreg := ""
Local _nPosPBTI := 0

//====================================================================================================
// Guarda os dados do usuário
//====================================================================================================
M->C5_I_CDUSU := U_UCFG001(1)

//====================================================================================================
// Tratamento para PV vinculados
//====================================================================================================
IF M->C5_I_AGEND $ 'I/O' //Faz antes de limpar os campos pq usa a variavel M->C5_I_OPER para calcular
   _cFilCarreg := xFilial("SC5")
   If ! Empty(M->C5_I_FLFNC)
      _cFilCarreg := M->C5_I_FLFNC
   EndIf 

   M->C5_I_DTENT:=DATE()+U_OMSVLDENT(DATE(),M->C5_CLIENT,M->C5_LOJACLI,M->C5_I_FILFT,M->C5_NUM,1,.F.,_cFilCarreg,M->C5_I_OPER,M->C5_I_TPVEN)
   
ENDIF

//====================================================================================================
// Configura na cópia de pedidos os campos customizados que devem inicializar vazios
//====================================================================================================

M->C5_I_LIBL  := CTOD(" ")
M->C5_I_LIBCD := CTOD(" ") 
M->C5_I_DTLIC := CTOD(" ")
M->C5_I_DTLIB := CTOD(" ")	// inicializar o campo refrente de dt. liberação vazio
M->C5_I_DTLIP := CTOD(" ")
M->C5_I_PLIBP := CTOD(" ")
M->C5_I_DTRET := CTOD(" ")
M->C5_I_DTSAG := CTOD(" ")
M->C5_I_DTCLI := CTOD(" ")
M->C5_I_DTPRV := CTOD(" ")
M->C5_I_DLIBE := CTOD(" ")
M->C5_I_QTPA  := 0
M->C5_I_LIBCV := 0
M->C5_I_LIBC  := 0
M->C5_I_VLIBB := 0
M->C5_I_QLIBB := 0
M->C5_I_VLIBP := 0
M->C5_I_QLIBP := 0
M->C5_I_PSORI := 0
M->C5_PBRUTO  := 0
M->C5_VOLUME1 := 0
M->C5_I_ENVRD := "N" 
M->C5_I_BLSLD := "N" 

// \/\/\/\/\/\/\/\/\/ *!! ATENCAO !!* SEMPRE INICIAR AS VARIAVEIS DE MEMORIA CARACTERES COM SPACE(LEN(CAMPO)) PQ COM "" O CAMPO FICA INDIGITAVEL ******************************//
M->C5_I_MTBON := SPACE(LEN(SC5->C5_I_MTBON))
M->C5_I_STAWF := SPACE(LEN(SC5->C5_I_STAWF))
M->CC5_CODA1U := SPACE(LEN(SC5->C5_I_NFSED))
M->CC5_I_ARQOP:= SPACE(LEN(SC5->C5_I_NFSED))
M->C5_I_NFSED := SPACE(LEN(SC5->C5_I_NFSED))
M->C5_I_NFREF := SPACE(LEN(SC5->C5_I_NFREF))
M->C5_I_SERNF := SPACE(LEN(SC5->C5_I_SERNF))
M->C5_I_PVREF := SPACE(LEN(SC5->C5_I_PVREF))
M->C5_I_TAB   := SPACE(LEN(SC5->C5_I_TAB  ))// inicializar o campo Tabela de Preço a bloqueio vazio
M->C5_TABELA  := SPACE(LEN(SC5->C5_TABELA ))// Esse campo dever ser sempre limpo pq ele é usado na validacao da condicao de pagamento 
M->C5_I_IDPED := SPACE(LEN(SC5->C5_I_IDPED))
M->C5_I_OPER  := SPACE(LEN(SC5->C5_I_OPER ))
M->C5_I_NPALE := SPACE(LEN(SC5->C5_I_NPALE))// não preencher o código do pedido de Pallet com o código do Pedido original
M->C5_I_LIBCT := SPACE(LEN(SC5->C5_I_LIBCT))
M->C5_I_LIBCA := SPACE(LEN(SC5->C5_I_LIBCA))
M->C5_I_MOTLB := SPACE(LEN(SC5->C5_I_MOTLB))
M->C5_I_LLIBB := SPACE(LEN(SC5->C5_I_LLIBB))
M->C5_I_CLILB := SPACE(LEN(SC5->C5_I_CLILB))
M->C5_I_ULIBB := SPACE(LEN(SC5->C5_I_ULIBB))
M->C5_I_MOTBL := SPACE(LEN(SC5->C5_I_MOTBL))
M->C5_I_BLCRE := SPACE(LEN(SC5->C5_I_BLCRE))
M->C5_I_BLOQ  := SPACE(LEN(SC5->C5_I_BLOQ ))
M->C5_I_MOTLP := SPACE(LEN(SC5->C5_I_MOTLP))
M->C5_I_LLIBP := SPACE(LEN(SC5->C5_I_LLIBP))
M->C5_I_CLILP := SPACE(LEN(SC5->C5_I_CLILP))
M->C5_I_ULIBP := SPACE(LEN(SC5->C5_I_ULIBP))
M->C5_I_HLIBP := SPACE(LEN(SC5->C5_I_HLIBP))
M->C5_I_HLIBE := SPACE(LEN(SC5->C5_I_HLIBE))
M->C5_I_BLPRC := SPACE(LEN(SC5->C5_I_BLPRC))
M->C5_I_MLIBP := SPACE(LEN(SC5->C5_I_MLIBP))
M->C5_I_PDFT  := SPACE(LEN(SC5->C5_I_PDFT ))    
M->C5_I_PDPR  := SPACE(LEN(SC5->C5_I_PDPR ))
M->C5_I_CARGA := SPACE(LEN(SC5->C5_I_CARGA))
M->C5_I_PODES := SPACE(LEN(SC5->C5_I_PODES))
M->C5_I_HRRET := SPACE(LEN(SC5->C5_I_HRRET))
M->C5_I_STATU := SPACE(LEN(SC5->C5_I_STATU))
M->C5_VEICULO := SPACE(LEN(SC5->C5_VEICULO))
M->C5_I_PVDUE := SPACE(LEN(SC5->C5_I_PVDUE))
M->C5_I_PEDOP := SPACE(LEN(SC5->C5_I_PEDOP))
M->C5_I_EXPOP := SPACE(LEN(SC5->C5_I_EXPOP))
M->C5_I_PEDDW := SPACE(LEN(SC5->C5_I_PEDDW)) 
M->C5_I_ENVML := SPACE(LEN(SC5->C5_I_ENVML))
M->C5_I_BLOG  := SPACE(LEN(SC5->C5_I_BLOG ))
M->C5_I_PEDPA := SPACE(LEN(SC5->C5_I_PEDPA))
M->C5_I_PEDGE := SPACE(LEN(SC5->C5_I_PEDGE))
M->C5_I_OPTRI := SPACE(LEN(SC5->C5_I_OPTRI))// Tratamento da Operação Triangular
M->C5_I_PVREM := SPACE(LEN(SC5->C5_I_PVREM))// Tratamento da Operação Triangular
M->C5_I_PVFAT := SPACE(LEN(SC5->C5_I_PVFAT))// Tratamento da Operação Triangular
M->C5_I_CLIEN := SPACE(LEN(SC5->C5_I_CLIEN))// Tratamento da Operação Triangular
M->C5_I_LOJEN := SPACE(LEN(SC5->C5_I_LOJEN))// Tratamento da Operação Triangular
M->C5_I_PEVIN := SPACE(LEN(SC5->C5_I_PEVIN))// Tratamento para PV vinculados
M->C5_ESPECI1 := SPACE(LEN(SC5->C5_ESPECI1))// Tratamento para PV vinculados
M->C5_I_HREMI := TIME()//SPACE(LEN(SC5->C5_I_HREMI))

M->C5_I_HRUWF := SPACE(LEN(SC5->C5_I_HRUWF))
M->C5_I_DTUWF := CTOD(" ")
M->C5_I_ENVML := SPACE(LEN(SC5->C5_I_ENVML))

M->C5_I_PESBR := 0 
M->C5_PBRUTO  := 0
M->C5_DESCONT := 0

IF M->C5_TPFRETE = "R"
   M->C5_TPFRETE:="C"
ENDIF
If SC5->(FIELDPOS("C5_I_CDTMS")) > 0 
   M->C5_I_CDTMS:= SPACE(LEN(SC5->C5_I_CDTMS)) // Protocolo de integração de Pedidos TMS Multiembarcador.  
EndIf
// /\/\/\/\/\/\/\/\/\ *!! ATENCAO !!* SEMPRE INICIAR AS VARIAVEIS DE MEMORIA CARACTERES COM SPACE(LEN(CAMPO)) PQ COM "" O CAMPO FICA INDIGITAVEL ******************************//

//====================================================================================================
// Configura os campos do GRID (SC6) para que inicializem vazios na cópia de pedidos
//====================================================================================================
_nPos		:= aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_I_LIBPE' } )
_nPosLib	:= aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_I_LIBPR' } )
_nPosBl	    := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_I_BLPRC' } ) // Para Limpar ou popular o campo de bloqueio de preço
_nProd		:= aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_PRODUTO' } ) // Para Limpar ou popular o campo de bloqueio de preço
_nPrcVen	:= aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_PRCVEN'  } ) // Para Limpar ou popular o campo de bloqueio de preço
_nPrcOri 	:= Ascan( aHeader , {|x| Alltrim( Upper(x[2]) ) == "C6_I_VLIBP"	} ) // AWF - 09/11/2016 
_nPLIBP 	:= Ascan( aHeader , {|x| Alltrim( Upper(x[2]) ) == "C6_I_PLIBP"	} ) // AWF - 22/12/2016 
_nDLIBP 	:= Ascan( aHeader , {|x| Alltrim( Upper(x[2]) ) == "C6_I_DLIBP"	} ) // AWF - 22/12/2016 

_nComis1	:= Ascan( aHeader , {|x| Alltrim( Upper(x[2]) ) == "C6_COMIS1"	} )
_nComis2 	:= Ascan( aHeader , {|x| Alltrim( Upper(x[2]) ) == "C6_COMIS2"	} )
_nComis3 	:= Ascan( aHeader , {|x| Alltrim( Upper(x[2]) ) == "C6_COMIS3"	} )
_nComis4 	:= Ascan( aHeader , {|x| Alltrim( Upper(x[2]) ) == "C6_COMIS4"	} )
_nComis5 	:= Ascan( aHeader , {|x| Alltrim( Upper(x[2]) ) == "C6_COMIS5"	} )


_nPrnet := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_I_PRNET' } )
_nVflet := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_I_VFLET' } )
_nVflex := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_I_VFLEX' } )
_nVltab := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_I_VLTAB' } )
_nPrMin := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_I_PRMIN' } )
_cItdw  := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_I_ITDW'  } )

_cLlibp  := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_I_LLIBP' } )
_cClilp  := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_I_CLILP' } )
_nQtlop  := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_I_QTLIP' } )
_cMotlp  := aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_I_MOTLP' } )
 
_nPosPBTI := Ascan(aHeader,{|x| alltrim(x[2])=="C6_I_PTBRU"})  

For _nX := 1 To Len( aCols )

// \/\/\/\/\/\/\/\/\/  *!! ATENCAO !!* SEMPRE INICIAR AS VARIAVEIS DE MEMORIA CARACTERES COM SPACE(LEN(CAMPO)) PQ COM "" O CAMPO FICA INDIGITAVEL ******************************//
	aCols[_nX][_nPos   ] := SPACE(LEN(SC6->C6_I_LIBPE))
	aCols[_nX][_nPosLib] := SPACE(LEN(SC6->C6_I_LIBPR))
	aCols[_nX][_nPosBl ] := SPACE(LEN(SC6->C6_I_BLPRC))
	aCols[_nX][_cItdw  ] := SPACE(LEN(SC6->C6_I_ITDW ))
	aCols[_nX][_cLlibp ] := SPACE(LEN(SC6->C6_I_LLIBP))
	aCols[_nX][_cClilp ] := SPACE(LEN(SC6->C6_I_CLILP))
	aCols[_nX][_cMotlp ] := SPACE(LEN(SC6->C6_I_MOTLP))
// /\/\/\/\/\/\/\/\/\  *!! ATENCAO !!* SEMPRE INICIAR AS VARIAVEIS DE MEMORIA CARACTERES COM SPACE(LEN(CAMPO)) PQ COM "" O CAMPO FICA INDIGITAVEL ******************************//

	aCols[_nX][_nPLIBP]  := CTOD("")// AWF - 22/12/2016  
	aCols[_nX][_nDLIBP]  := CTOD("")// AWF - 22/12/2016 
	aCols[_nX][_nPrcOri] := 0// AWF - 09/11/2016 
	aCols[_nX][_nComis1] := 0
	aCols[_nX][_nComis2] := 0
	aCols[_nX][_nComis3] := 0
	aCols[_nX][_nComis4] := 0
	aCols[_nX][_nComis5] := 0
	aCols[_nX][_nPrnet ] := 0 
	aCols[_nX][_nVflet ] := 0
	aCols[_nX][_nVflex ] := 0
	aCols[_nX][_nVltab ] := 0
   aCols[_nX][_nPrMin ] := 0
	aCols[_nX][_nQtlop ] := 0
 
	aCols[_nX][_nPosPBTI] := 0 
 
Next _nX

//Marca se tem bloqueio de bonificação
If u_vldPedBon( aCols )
	
	M->C5_I_BLOQ := "B"
	
Endif 
	
Return()

