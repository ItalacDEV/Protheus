/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço  |27/08/2024| Chamado 47913. Jerry. Ajustes para alteração de campos em seleção multipla.
Igor Melgaço  |03/09/2024| Chamado 48190. Jerry. Ajustes para alteração do campo senha.
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipulação do SX1
====================================================================================================================================================================================================================
Analista        - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
====================================================================================================================================================================================================================
Jerry Santiago  - Igor Melgaço  - 23/10/24 - 24/10/24 - 48860   - Ajuste para exibição do F3 do MV_PAR16.
Alex Wallauer   - Alex Wallauer - 25/03/25 - 26/03/25 - 49966   - CORREÇÃO DE ERROR.LOG: SC6010: DB error (Update): -29 File: SC6010 - Error : 1 - ORA-00001: unique constraint (SIGA.SC6010_UNQ) violated
Alex Wallauer   - Alex Wallauer - 25/03/25 - 26/03/25 - 49966   - CORREÇÃO DE ERROR.LOG: F3 LSTCAR com erro , alterado para ZLSTCA
Jerry           - Julio Paz     - 08/04/25 - 14/04/25 - 49837   - Inclusão da nova Tag ITEMKITPORTAL e gravação nos campos ZW_KIT e C6_I_KIT.
Jerry           - Julio Paz     - 10/04/25 - 14/04/25 - 41527   - Inclusão da nova Tag RECEBE_SABADO e gravação nos campos ZW_I_RECSA no C5_I_RECSA.
Jerry           - Julio Paz     - 08/04/25 - 14/04/25 - 48275   - Inclusão de validação de produtos bloqueados por filial, com base no cadastro de produtos bloqueados por filial.
Jerry           - Julio Paz     - 08/04/25 - 02/05/25 - 48275   - Alterações nas regras de validação de produtos bloqueados por filial, com base no cadastro de produtos bloqueados por filial.
Jerry           - Julio Paz     - 02/07/25 - 18/07/25 - 50758   - Alterar a rotina de validação de produtos bloqueados por filial, para não validar na efetivação da carga.
Jerry           - Julio Paz     - 14/07/25 - 18/07/25 - 50433   - Realização de Ajustes nas Regras para Determinar o Armazém de Pedidos de Vendas do Portal - ZW_LOCAL. 
====================================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina  
//==================================================================================================== 
#Include "RWMAKE.CH"
#Include "TopConn.ch"
#Include "ap5mail.ch"
#Include "Protheus.ch"
#DEFINE CRLF	CHR(13)+CHR(10)

Static _cPictQtv  := PesqPict("SZW","ZW_QTDVEN")
Static _cArmazMat := U_ITGETMV("IT_TRAMZPM","40") // Armazem para Troca de produtos matinais qdo peso do pedido ultrapassar o Peso Max
Static _nPesoMat  := U_ITGETMV("IT_PESMAT",22000) // Peso Máximo para Produtos Matinais
Static _cProdMat  := U_ITGETMV("IT_PROMAT","15") // Produtos Matinais (B1_I_BIFAM)
/* 
===============================================================================================================================
Programa----------: AOMS112
Autor-------------: Josué Danich Prestes
Data da Criacao---: 12/03/2013
===============================================================================================================================
Descrição---------: Central de  pedidos de vendas do Portal  - Chamado 28586
===============================================================================================================================
Parametros--------: _ccodcli - código de cliente para filtro automático
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS112(_ccodcli)

	Default _ccodcli := ""

	Private _alista := {}
	Private _otemp := nil
	Private _ccodclip := _ccodcli
	Private _cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))// Tipos de operações da operação trigular
	Private _cOperFat       := LEFT(_cOperTriangular,2)
	Private _cOperRemessa   := RIGHT(_cOperTriangular,2)
	Private aarr := {}
	Private aheader := {}

	//============================================================================================
	// Variáveis abaixo utilizadas na efetivação do pedido do portal. Na chamada do MSEXECAUTO.
	//============================================================================================
	Private _cOperTri   := Space(1)  // Esta variável será utilizada no fonte MT410TOK para peencher o campo operação triangular.
	Private _cCodClien  := Space(6)  // Esta variável será utilizada no fonte MT410TOK para peencher o campo codigo Cliente/Venda.
	Private _cLojaClie  := Space(4)  // Esta variável será utilizada no fonte MT410TOK para peencher o campo loja Cliente/Venda.

	AOMS112INI()

Return()

/*
===============================================================================================================================
Programa----------: U_AOMSLambert()
Autor-------------: Alex Wallauer
Data da Criacao---: 17/02/2020
===============================================================================================================================
Descrição---------: Para chamar do MENU DIRETO
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER Function AOMSLambert()
RETURN AOMS112I()
/*
===============================================================================================================================
Programa----------: AOMS112INI
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Funcao que controla o processamento 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112INI()

	Private lInverte	:= .F.
	Private cPerg		:= 'AOMS112'
	Private aCampos		:= {}

	AOMS112PRC()

Return()

/*
===============================================================================================================================
Programa----------: AOMS112PRC
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Função que processa os pedidos do portal
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS112PRC()

	Local _nControle := 0
	Local _nopc      := 1
	Private cMarca   := GetMark()
	Private aCampos  := {}
	Private cPerg	  := 'AOMS112'
   Private _aItalac_F3 := {}

   //   _aItalac_F3:={}         1      2         3         4          5         6                  7        8            9         10         11        12
   //  (_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave,_nCpoDesc,_bCondTab, _cTitAux         , _nTamChv,_aDados     , _nMaxSel , _lFilAtual,_cMVRET,_bValida})  
	AADD(_aItalac_F3,{"MV_PAR16"   ,        ,          ,         ,         ,"Tipos de pedidos",2        ,U_AOM112F3()           } )//'F3ITLC'

    _cPerg := PadR( cPerg , 10 , " " ) 
    SET DATE FORMAT TO "DD/MM/YYYY"

	If Pergunte( cPerg , .T. )
		//================================================================================
		// Cria o arquivo Temporario para insercao dos dados selecionados.
		//================================================================================
		FWMSGRUN( , {|oproc| _nControle := AOMS112ARQ(oproc, .T., .F.) }, "Aguarde!" , 'Lendo Dados dos pedidos...' )
		_nopc := AOMS112TRS()//Função que monta a tela para processar
	Endif

    SET DATE FORMAT TO "DD/MM/YY"

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS112TRS
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Função que monta a tela para processar
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS112TRS()

	Local oPanel		:= Nil
	Local aSize			:= {}
	Local aBotoes		:= {}
	Local aCoors		:= {}
	Local lHtml         := (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml


   _lLoop := .F.

	DO WHILE .T.

      //----------------
         oPanel		:= Nil
         aSize			:= {}
         aBotoes		:= {}
         aCoors		:= {}

      	Private oDlg1			:= Nil
      	Private nHeight		:= 0
      	Private nWidth		:= 0
      	Private oOK := LoadBitmap(GetResources(),'LBOK')
      	Private oNO := LoadBitmap(GetResources(),'LBNO')
      	Private nOpca		 		:= 0
      	Private cFiltro			:= "%"
      	Private _aAreaCabec	:= {}
      	Private _cFilPed		:= ""
      	Private _cNumPed		:= ""
      	Private oMark				:= Nil
      	Private nQtdTit			:= 0
      	Private nValTit     := 0
      	Private oQtda				:= Nil
      	Private oValor      := Nil
      	Private _ahead  		:= { }
      	Private _atams      := { }
      	Private _aArmap		:= {}
      	PRIVATE _aColuns 	:= {}

      //================================================================================
      // Botoes da tela.
      //================================================================================
         IF MV_PAR23 <> 1 //SEM REJEITADOS
            Aadd( aBotoes , { "" , {|| AOMS112C(01),         (_lLoop:=.T.,oDlg1:End())  },"","Atualizar"		             })
            Aadd( aBotoes , { "" , {|| AOMS112C(02) 	                                },"","Pesquisar"		             })
            Aadd( aBotoes , { "" , {|| AOMS112C(03),         (_lLoop:=.T.,oDlg1:End())  },"","Filtro"                        })
            //Aadd( aBotoes , { "" , {|| AOMS112C(04) 	                                },"","Alterar filiais"               })
         ENDIF	
         
         Aadd( aBotoes , { "" , {|| AOMS112C(05) 	                                },"","Visualizar Pedido"             })
         Aadd( aBotoes , { "" , {|| AOMS112C(07) 	                                },"","Legenda"                       })
         
         IF MV_PAR23 <> 1 //SEM REJEITADOS
            Aadd( aBotoes , { "" , {|| AOMS112C(06),IF(lHtml,(_lLoop:=.T.,oDlg1:End()),)},"","Alterar"	                     })
            Aadd( aBotoes , { "" , {|| AOMS112X(),IF(lHtml,(_lLoop:=.T.,oDlg1:End()),)},"","Alterar Selecionados"	                     })
            Aadd( aBotoes , { "" , {|| AOMS112C(09),IF(lHtml,(_lLoop:=.T.,oDlg1:End()),)},"","Recusar"                       })
            Aadd( aBotoes , { "" , {|| AOMS112C(08),IF(lHtml,(_lLoop:=.T.,oDlg1:End()),)},"","Marcar não impresso"           })
            Aadd( aBotoes , { "" , {|| AOMS112I(  ),IF(lHtml,(_lLoop:=.T.,oDlg1:End()),)},"","Importa PV TXT"                })
            Aadd( aBotoes , { "" , {|| REENVAPR(  )                                     },"","Reenv. Aprovação"              })
            Aadd( aBotoes , { "" , {|| U_AOM112AP()                                     },"","Visualização das Aprovações"   })
         ENDIF	

         Aadd( aBotoes , { "" , {|| AOMS112C(10) 	                                },"","Exporta Excel"                 })
         Aadd( aBotoes , { "" , {|| AMS112PE(  )                                    },"","Listagem Pendencias"           })


      //================================================================================
      // Faz o calculo automatico de dimensoes de objetos
      //================================================================================
      	aSize := MSADVSIZE()

      //================================================================================
      // Cria a tela para selecao dos pedidos
      //================================================================================
      	_ctitulo := "CENTRAL DE PEDIDOS DO PORTAL"



      //----------------


		DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(_ctitulo) From 0,0 To aSize[6],aSize[5] PIXEL

		oPanel := TPanel():New(30,0,'',oDlg1,, .T., .T.,, ,315,20,.T.,.T. )
		oFont := TFont():New('Times New Roman',,-18,.T.)

     IF MV_PAR23 <> 1 //SEM REJEITADOS
		oQtda:= TSay():New(05,450,{||'Quantidade pedidos:  ' + ALLTRIM(transform(nQtdTit, "@E 9,999" ))},;
		oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
	 ELSE
	    _nColRej:=360
		oQtda:= TSay():New(05,_nColRej,{||'Quantidade de Pedidos REJEITADOS:  ' + ALLTRIM(transform(nQtdTit, "@E 9,999" ))},;
		oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
	 ENDIF

		oValor:= TSay():New(05,550,{||'Valor pedidos:   ' + ALLTRIM(transform(nValTit, "@E 999,999,999.99" ))},;
		oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

     IF MV_PAR23 <> 1 //SEM REJEITADOS
		@003,012 BUTTON "Efetivar" SIZE 060, 015 PIXEL OF oPanel ACTION (AOMS112C(11), IF(lHtml,(_lLoop:=.T.,oDlg1:End()),) )
		@003,090 BUTTON "Imprimir" SIZE 060, 015 PIXEL OF oPanel ACTION (AOMS112C(12))
     ELSE
		@003,012 BUTTON "Imprimir" SIZE 060, 015 PIXEL OF oPanel ACTION (AOMS112C(12))
	 ENDIF


		If FlatMode()

			aCoors	:= GetScreenRes()
			nHeight	:= aCoors[2]
			nWidth	:= aCoors[1]

		Else

			nHeight	:= 143
			nWidth	:= 315

		Endif

		A112OMK() //REALIZA MONTAGEM DO OMARK PARA SMARTCLIENT OU HTML

		A112MAP(,.F.) //REALIZA O MAPEAMENTO DAS COLUNAS PARA ORDENAR NA A112RA()

		//QUANDO FOR HTML O AARR DEVE SER ORDENADO MANUALMENTE
		IF !lHtml .and. !_lLoop
			A112RA() //REORDENA O AARR PARA PERMITIR AS MODIFICAÇOES NAS COLUNAS
		ENDIF

      _lLoop := .F.

		oDlg1:lMaximized:=.T.

		ACTIVATE MSDIALOG oDlg1 ON INIT ( EnchoiceBar(oDlg1,{|| nOpca := 2,},{|| nOpca := 2,oDlg1:End()},,aBotoes),;
			oPanel:Align:=CONTROL_ALIGN_TOP , oMark:Align:=CONTROL_ALIGN_ALLCLIENT, oMark:Refresh()) //
		IF !_lLoop
			EXIT
		ENDIF

	ENDDO

Return nOpca

/*
===============================================================================================================================
Programa----------: AOMS112N
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Rotina de duplo clique na linha do browse
===============================================================================================================================
Parametros--------: cmarca - string de marcação do registro da tabela
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS112N( cMarca As Character )
 Local _nlinpos := 0 As Numeric
 Local _coldfil := "" As Character
 Local _nDesc   := 0 As Numeric
 Local _lRet    := .T. As Logical

 IF MV_PAR23 = 1 //SÓ REJEITADOS
    RETURN .F.
 ENDIF
 
 If Len(aarr) = 0
    u_itmsg("Não há registros para marcar.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
    RETURN .F.
 EndIf
 
 _nlinpos := OMARK:NAT
 _coldfil := aarr[_nlinpos,omark:ncolpos]
 _nDesc   := aarr[oMark:Nat][A112MAP("Desconto")]

 TRBF->(Dbgoto(aarr[_nlinpos,LEN(aarr[OMARK:NAT])]))

	If omark:ncolpos == A112MAP(SPACE(2))
	   AOMS112LEG()//Legenda

	ELSEIf omark:ncolpos == A112MAP(SPACE(1))

		//Duplo clique na marcação
		If ALLTRIM(cmarca)==ALLTRIM(aarr[_nlinpos,A112MAP(SPACE(1))])
			nQtdTit--
			nValTit -= aarr[_nlinpos,A112MAP("Valor Pedido")]
			aarr[_nlinpos,01] := "  "
		Else
			nQtdTit++
			nValTit += aarr[_nlinpos,A112MAP("Valor Pedido")]
			aarr[_nlinpos,A112MAP(SPACE(1))] := cmarca
		EndIf

		Reclock("TRBF",.F.)
		TRBF->OK := aarr[_nlinpos,A112MAP(SPACE(1))]
		TRBF->(Msunlock())


		IF SubStr(omark:AARRAY[omark:NAT][A112MAP("Tipo")],1,2) $ "05;42" //.AND. Empty(ALLTRIM(omark:AARRAY[omark:NAT][A112MAP("Cliente/Venda")]))

			//Duplo clique para alterar o cliente de remessa de operação triangular
			_cclirem := TRBF->CLIREM //Depois da Mudança da Op Triangular de  05 para 42. Este campo agora é o cliente de faturamento.
			_clojrem := TRBF->LOJEN
			_bValid2:= {|| AOMS112K(_cclirem,_clojrem) }
			_oDlg := nil
			_lok := .F.

			DEFINE MSDIALOG _oDlg TITLE "Cliente/Venda para pedido " + aarr[_nlinpos,A112MAP("Id Pedido")] FROM 000,000 TO 150,300 PIXEL

			@ 005, 007 SAY "Cliente/Venda:" PIXEL
			@ 017, 009 MSGET _cclirem SIZE 40,11 OF _oDlg F3 "SA1" PIXEL
			@ 017, 060 MSGET _clojrem SIZE 30,11 OF _oDlg PIXEL

			@ 050,020	BMPBUTTON TYPE 01 ACTION Eval({|| IF(EVAL(_bValid2),(_lok:=.T.,close(_oDlg)),) } )
			@ 050,060	BMPBUTTON TYPE 02 ACTION Eval({|| _lok := .F. , close(_oDlg)				} )

			Activate MSDialog _oDlg Centered

			If _lok

				If empty(_cclirem)

					_nRet:=TcSqlExec( "UPDATE SZW010 SET ZW_OPTRI = ' '" +;
						" WHERE ZW_IDPED = '"+ ALLTRIM(aarr[_nlinpos,A112MAP("Id Pedido")]) +;
						"' AND D_E_L_E_T_ = ' ' " )
				Else

					_nRet:=TcSqlExec( "UPDATE SZW010 SET ZW_OPTRI = 'F'" +;
						" WHERE ZW_IDPED = '"+ ALLTRIM(aarr[_nlinpos,A112MAP("Id Pedido")]) +;
						"' AND D_E_L_E_T_ = ' ' " )
				Endif

				_nRet:=TcSqlExec( "UPDATE SZW010 SET ZW_CLIREM = '" + _cclirem  + "'" +;
					" WHERE ZW_IDPED = '"+ ALLTRIM(aarr[_nlinpos,A112MAP("Id Pedido")]) +;
					"' AND D_E_L_E_T_ = ' ' " )

				_nRet:=TcSqlExec( "UPDATE SZW010 SET ZW_LOJEN = '" + _clojrem  + "'" +;
					" WHERE ZW_IDPED = '"+ ALLTRIM(aarr[_nlinpos,A112MAP("Id Pedido")]) +;
					"' AND D_E_L_E_T_ = ' ' " )

				_nRet:=TcSqlExec( "COMMIT" )

				TRBF->(Dbgoto(aarr[_nlinpos,LEN(aarr[OMARK:NAT])]))

				//Reclock("TRBF",.F.)
				TRBF->CLIREM := ALLTRIM(_cclirem)  //Depois da Mudança da Op Triangular de  05 para 42. Este campo agora é o cliente de faturamento.
				TRBF->LOJEN := ALLTRIM(_clojrem)
				//TRBF->(Msunlock())

				If Empty(_cclirem)
					aarr[_nlinpos,A112MAP("Cliente/Venda")] :=  "  "
				Else
					aarr[_nlinpos,A112MAP("Cliente/Venda")] := TRBF->CLIREM + "/" + TRBF->LOJEN + " - " + POSICIONE("SA1",1,xfilial("SA1")+ALLTRIM(TRBF->CLIREM)+ALLTRIM(TRBF->LOJEN),"A1_NOME") //Depois da Mudança da Op Triangular de  05 para 42. Este campo agora é o cliente de faturamento.
				Endif

			Endif

			omark:refresh()
		EndIf


	Elseif omark:ncolpos == A112MAP("Filial Faturamento")

		//Duplo clique para alterar a filial de faturamento

		_lRet:=leditcell(@aarr,omark,"",A112MAP("Filial Faturamento"))
		If _lRet .AND. U_AOM112Val('FilFatBrowse')
			omark:godown()
		ElseIf _lRet
			aarr[_nlinpos,omark:ncolpos] := 	_coldfil
		Endif
		omark:refresh()

	Elseif omark:ncolpos == A112MAP("Filial Carregamento")

		//Duplo clique para alterar a filial de carregamento
		_lRet:=leditcell(@aarr,omark,"",A112MAP("Filial Carregamento"))
		If _lRet .AND. U_AOM112Val('FilProBrowse')
			omark:godown()
		ElseIf _lRet
			aarr[_nlinpos,omark:ncolpos] := 	_coldfil
		Endif
		omark:refresh()
	Elseif omark:ncolpos == A112MAP("Tipo")

		//Duplo clique para alterar a filial de carregamento
		_lRet:=leditcell(@aarr,omark,"",A112MAP("Tipo"))
		If _lRet .AND. U_AOM112Val('TipoBrowse')
			omark:godown()
		ElseIf _lRet 
			aarr[_nlinpos,omark:ncolpos] := 	_coldfil
		Endif
		omark:refresh()
	ELSEIF omark:ncolpos == A112MAP("Desconto")
		//Duplo clique para alterar o valor do desconto
		IF AARR[oMark:Nat][A112MAP("Tp Frete")] == "FOB"
			_lRet:=leditcell(@aarr,omark,"@E 999,999,999.99",A112MAP("Desconto"))
			IF _lRet .AND. U_AOM112Val("DescBrowser")
				omark:godown()
			ELSEIf _lRet 
				AARR[oMark:Nat][A112MAP("Desconto")] := _nDesc
			ENDIF
		ENDIF
		omark:refresh()

	Elseif omark:ncolpos == A112MAP("Cliente/Venda")
		IF SubStr(omark:AARRAY[omark:NAT][A112MAP("Tipo")],1,2) $ "05;42"
			//Duplo clique para alterar o cliente de remessa de operação triangular
			_cclirem := TRBF->CLIREM //Depois da Mudança da Op Triangular de  05 para 42. Este campo agora é o cliente de faturamento.
			_clojrem := TRBF->LOJEN
			_bValid2:= {|| AOMS112K(_cclirem,_clojrem) }
			_oDlg := nil
			_lok := .F.

			DEFINE MSDIALOG _oDlg TITLE "Cliente/Venda para pedido " + aarr[_nlinpos,A112MAP("Id Pedido")] FROM 000,000 TO 150,300 PIXEL

			@ 005, 007 SAY "Cliente/Venda:" PIXEL
			@ 017, 009 MSGET _cclirem SIZE 40,11 OF _oDlg F3 "SA1" PIXEL
			@ 017, 060 MSGET _clojrem SIZE 30,11 OF _oDlg PIXEL

			@ 050,020	BMPBUTTON TYPE 01 ACTION Eval({|| IF(EVAL(_bValid2),(_lok:=.T.,close(_oDlg)),) } )
			@ 050,060	BMPBUTTON TYPE 02 ACTION Eval({|| _lok := .F. , close(_oDlg)				} )

			Activate MSDialog _oDlg Centered

			If _lok

				If empty(_cclirem)

					_nRet:=TcSqlExec( "UPDATE SZW010 SET ZW_OPTRI = ' '" +;
						" WHERE ZW_IDPED = '"+ ALLTRIM(aarr[_nlinpos,A112MAP("Id Pedido")]) +;
						"' AND D_E_L_E_T_ = ' ' " )
				Else

					_nRet:=TcSqlExec( "UPDATE SZW010 SET ZW_OPTRI = 'F'" +;
						" WHERE ZW_IDPED = '"+ ALLTRIM(aarr[_nlinpos,A112MAP("Id Pedido")]) +;
						"' AND D_E_L_E_T_ = ' ' " )
				Endif

				_nRet:=TcSqlExec( "UPDATE SZW010 SET ZW_CLIREM = '" + _cclirem  + "'" +;
					" WHERE ZW_IDPED = '"+ ALLTRIM(aarr[_nlinpos,A112MAP("Id Pedido")]) +;
					"' AND D_E_L_E_T_ = ' ' " )

				_nRet:=TcSqlExec( "UPDATE SZW010 SET ZW_LOJEN = '" + _clojrem  + "'" +;
					" WHERE ZW_IDPED = '"+ ALLTRIM(aarr[_nlinpos,A112MAP("Id Pedido")]) +;
					"' AND D_E_L_E_T_ = ' ' " )

				_nRet:=TcSqlExec( "COMMIT" )

				TRBF->(Dbgoto(aarr[_nlinpos,LEN(aarr[OMARK:NAT])]))

				Reclock("TRBF",.F.)
				TRBF->CLIREM := ALLTRIM(_cclirem)
				TRBF->LOJEN := ALLTRIM(_clojrem)
				TRBF->(Msunlock())

				If Empty(_cclirem)
					aarr[_nlinpos,A112MAP("Cliente/Venda")] :=  "  "
				Else
					aarr[_nlinpos,A112MAP("Cliente/Venda")] := TRBF->CLIREM + "/" + TRBF->LOJEN + " - " + POSICIONE("SA1",1,xfilial("SA1")+ALLTRIM(TRBF->CLIREM)+ALLTRIM(TRBF->LOJEN),"A1_NOME") //Depois da Mudança da Op Triangular de  05 para 42. Este campo agora é o cliente de faturamento.
				Endif

			Endif

			omark:refresh()
		EndIf

	ELSE

		//Duplo clique na marcação
		If ALLTRIM(cmarca)==ALLTRIM(aarr[_nlinpos,A112MAP(SPACE(1))])
			nQtdTit--
			nValTit -= aarr[_nlinpos,A112MAP("Valor Pedido")]
			aarr[_nlinpos,A112MAP(SPACE(1))] := "  "
		Else
			nQtdTit++
			nValTit += aarr[_nlinpos,A112MAP("Valor Pedido")]
			aarr[_nlinpos,A112MAP(SPACE(1))] := cmarca
		EndIf

		Reclock("TRBF",.F.)
		TRBF->OK := aarr[_nlinpos,A112MAP(SPACE(1))]
		TRBF->(Msunlock())
	Endif

	oQtda:Refresh()
	oValor:Refresh()

Return()

/*
===============================================================================================================================
Programa----------: AOMS112ALL
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Rotina para inverter a marcacao de todos os registros.
===============================================================================================================================
Parametros--------: cMarca - string de marcação da tabela
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS112ALL( cMarca  )

 Local _nlinpos := 0 As Numeric
 Local nReg     := 0 As Numeric
 Local _nnp     := 1 As Numeric

 If len(aarr) = 0
    u_itmsg("Não há registros para marcar.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
    Return .F.
 Endif
 
 _nlinpos := omark:nat
 nReg     := aarr[_nlinpos,LEN(aarr[OMARK:NAT])]
 
 For _nnp := 1 to len(aarr)
    TRBF->(Dbgoto(aarr[_nnp,LEN(aarr[OMARK:NAT])]))
    If ALLTRIM(aarr[_nnp,A112MAP(SPACE(1))]) == ALLTRIM(cmarca)
       TRBF->( RecLock( "TRBF" , .F. ) )
       TRBF->OK := Space(2)
       TRBF->( MsUnLock() )
       aarr[_nnp,A112MAP(SPACE(1))] := space(2)
       nQtdTit--
       nValTit -= aarr[_nnp,A112MAP("Valor Pedido")]
    Else
       TRBF->( RecLock( "TRBF" , .F. ) )
       TRBF->OK := cMarca
       TRBF->( MsUnLock() )
       aarr[_nnp][1] := cMarca
       nQtdTit++
       nValTit += aarr[_nnp,A112MAP("Valor Pedido")]
    EndIf
    nQtdTit := IIf( nQtdTit < 0 , 0 , nQtdTit )
 Next
 
 TRBF->( DBGoto(nReg) )
 oQtda:Refresh()
 oValor:Refresh()
 oMark:Refresh()
 processmessages()

Return()

/*
===============================================================================================================================
Programa----------: AOMS112arq
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Rotina para criação do arquivo temporário
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
										_lini - inicializa campos de data de necessidade
										_lcabec - inicializa campos de cabecalho
										_lmantem - mantem marcados
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112arq(oproc,_lini,_lcabec,_lmantem)

	Local aEstru		:= {}
	Local _lp			:= 0
	Local _cTempoPend, _cHoraPend, _nDiasPend
	Local lHtml:= (GetRemoteType() == 5)
	Local _cFilCarreg := ""
	Local _ndias      := 0
   Local nQtdRegs := 0

	Private aheader := {{1,"C6_ITEM"},{2,"C6_PRODUTO"},{3,"C6_LOCAL"}}
	Private acols := {}
	Default _lini := .F.
	Default _lcabec := .T.
	Default _lmantem := .F.

//garante que o pergunte está correto
	Pergunte( cPerg , .F. )

	MV_PAR06 := 2 //Desabilitar simulador

//================================================================================
// Armazena no array aEstru a estrutura dos campos da tabela.
//================================================================================
	aEstru := {	{ "OK"			, "C" , 002 , 0 } ,;
		{ "OK2"		    , "C" , 001 , 0 } ,;
		{ "IMPRIME"  	, "C" , 010 , 0 } ,;
		{ "FILIAL"	  	, "C" , 040 , 0 } ,;
		{ "FILPRO"	  	, "C" , 040 , 0 } ,;
		{ "FILCR"	    , "C" , 020 , 0 } ,;
		{ "RFILIAL"	  	, "C" , 002 , 0 } ,;
		{ "NUMPED"	   	, "C" , 025 , 0 } ,;
		{ "TIPO"	    , "C" , 002 , 0 } ,;
		{ "VEND1"       , "C" , 006 , 0 } ,;
		{ "NMVEND1"     , "C" , 020 , 0 } ,;
		{ "REDE"        , "C" , 006 , 0 } ,;
		{ "NMREDE"      , "C" , 030 , 0 } ,;
		{ "CODCLI"	  	, "C" , 006 , 0 } ,;
		{ "LOJA"	 	, "C" , 004 , 0 } ,;
		{ "NMCLI"	    , "C" , 060 , 0 } ,;
		{ "TIPOCLI"	  	, "C" , 001 , 0 } ,;
		{ "CONDPAGTO"  	, "C" , 003 , 0 } ,;
		{ "VEND2"     	, "C" , 006 , 0 } ,;
		{ "NMVEND2"   	, "C" , 060 , 0 } ,;
		{ "TAB_PREC"  	, "C" , 003 , 0 } ,;
		{ "DTEMISS"   	, "C" , 010 , 0 } ,;
		{ "TPFRETE"   	, "C" , 001 , 0 } ,;
		{ "TRANSP"	   	, "C" , 006 , 0 } ,;
		{ "DESPESA"     , "N" , 014 , 2 } ,;
		{ "VALOR"       , "N" , 014 , 2 } ,;
		{ "MENSANF"     , "C" , 300 , 0 } ,;
		{ "TPCAR"       , "C" , 001 , 0 } ,;
		{ "OBSCOMER"    , "C" , 300 , 0 } ,;
		{ "HORAENTR"    , "C" , 005 , 0 } ,;
		{ "SENHA"       , "C" , 014 , 0 } ,;
		{ "DT_ENTREG"   , "C" , 010 , 0 } ,;
		{ "BLQLCR" 	    , "C" , 001 , 0 } ,;
		{ "BLOPRC" 	    , "C" , 001 , 0 } ,;
		{ "BLOCLI" 	    , "C" , 001 , 0 } ,;
		{ "BLOQ" 	    , "C" , 001 , 0 } ,;
		{ "STAT_ZW"     , "C" , 002 , 0 },;
		{ "STATUS1"     , "C" , 020 , 0 },;
		{ "STATUS2"     , "C" , 020 , 0 },;
		{ "STATUS3"     , "C" , 020 , 0 },;
		{ "OPTRI"       , "C" , 001 , 0 },;
		{ "CLIREM"      , "C" , 006 , 0 },;
		{ "LOJEN"       , "C" , 004 , 0 },;
		{ "BLQPRC"      , "C" , 004 , 0 },;
		{ "ENVWF"       , "C" , 001 , 0 },;
		{ "NIVELWF"     , "C" , 001 , 0 },;
		{ "MOTLP"       , "C" , 004 , 0 },;
		{ "TEMPOPEND"   , "C" , 040 , 0 },;
		{ "PESO"		, "N" , 013 , 4 },;
		{ "DESCONTO"	, "N" , 014 , 2 },;
		{ "NMMVEND2"	, "C" , 060 , 0 },;
		{ "NMVEND3"		, "C" , 060 , 0 }}

//================================================================================
// Verifica se ja existe um arquivo com mesmo nome, se sim deleta.
//================================================================================
	If Select("TRBF") > 0
		oproc:cCaption := ("Apagando temporário...")
		ProcessMessages()
		If ValType(_otemp) == "O"
			TRBF->(DbCloseArea())
			_otemp:Delete()
		Else
			TRBF->(DbCloseArea())
		EndIf
	EndIf

	oproc:cCaption := ("Criando arquivo temporário...")
	ProcessMessages()
	_otemp := FWTemporaryTable():New( "TRBF", aEstru )

	oproc:cCaption := ("Criando indices do arquivo temporário...")
	ProcessMessages()
	_otemp:AddIndex( "PD", {"NUMPED"} )
	_otemp:AddIndex( "CL", {"CODCLI"} )
	_otemp:AddIndex( "NM", {"NMCLI"} )
	_otemp:AddIndex( "NR", {"NMREDE"} )

	_otemp:Create()

//================================================================================
// Query para selecao dos dados DOS PEDIDOS
//================================================================================
	_cQuery := " SELECT "
	_cQuery += " CASE WHEN ZW_TIPO = '10' THEN 'A ' ELSE 'B' END ORD , "
	_cQuery += "     SZW.ZW_FILIAL     FILIAL   ,"
	_cQuery += "     SZW.ZW_FILPRO     ZW_FILPRO,"
	_cQuery += "     SZW.ZW_TIPO       TIPO     ,"
	_cQuery += "     SZW.ZW_CLIENTE    CODCLI   ,"
	_cQuery += "     SZW.ZW_LOJACLI    LOJA     ,"
	_cQuery += "     SZW.ZW_CLIENT     CODCLIENT,"
	_cQuery += "     SZW.ZW_LOJAENT    LOJAENT  ,"
	_cQuery += "     SZW.ZW_TIPOCLI    TIPOCLI  ,"
	_cQuery += "     SZW.ZW_CONDPAG    CONDPAGTO,"
	_cQuery += "     SZW.ZW_VEND1      VEND1    ,"
	_cQuery += "     SA3.A3_SUPER      VEND2    ," // COORDENADOR
	_cQuery += "     SA3.A3_GEREN      VEND3    ," // GERENTE
	_cQuery += "     SA3.A3_I_SUPE     VEND4    ,"
	_cQuery += "     SUM(SZW.ZW_DESC1) DESC1    ,"
	_cQuery += "     SUM(SZW.ZW_DESC2) DESC2    ,"
	_cQuery += "     SUM(SZW.ZW_DESC3) DESC3    ,"
	_cQuery += "     SUM(SZW.ZW_DESC4) DESC4    ,"
	_cQuery += "     SZW.ZW_TABELA     TAB_PREC ,"
	_cQuery += "     SZW.ZW_EMISSAO    DTEMISS  ,"
	_cQuery += "     SZW.ZW_TPFRETE    TPFRETE  ,"
	_cQuery += "     SZW.ZW_TRANSP     TRANSP   ,"
	_cQuery += "     SZW.ZW_DESPESA    DESPESA  ,"
	_cQuery += "     SZW.ZW_MENNOTA    MENSANF  ,"
	_cQuery += "     SZW.ZW_I_AGEND     TPCAR    ,"
	_cQuery += "     SZW.ZW_OBSCOM     OBSCOMER ,"
	_cQuery += "     SZW.ZW_HOREN      HORAENTR ,"
	_cQuery += "     SZW.ZW_SENHA      SENHA    ,"
	_cQuery += "     SZW.ZW_FECENT     DT_ENTREG,"
	_cQuery += "     SZW.ZW_EVENTO     EVENTO   ,"
	_cQuery += "     SZW.ZW_STATUS     STAT_ZW  ,"
	_cQuery += "     SZW.ZW_IDPED      NUMPED   ,"
	_cQuery += "     SZW.ZW_BLQLCR     BLQLCR   ,"
	_cQuery += "     SZW.ZW_OPTRI      OPTRI    ,"
	_cQuery += "     SZW.ZW_CLIREM     CLIREM   ,"
	_cQuery += "     SZW.ZW_LOJEN      LOJEN    ,"
	_cQuery += "     SZW.ZW_BLOPRC     BLQPRC   ,"
	_cQuery += "     SZW.ZW_ENVWF      ENVWF    ,"
	_cQuery += "     SZW.ZW_NIVELWF    NIVELWF  ,"
	_cQuery += "     SZW.ZW_MOTLP      MOTLP    ,"

	_cQuery += "     (select SUM(SZW3.ZW_PRCVEN*SZW3.ZW_QTDVEN) from " + RETSQLNAME("SZW") + " SZW3  where SZW3.d_e_l_e_t_ = ' ' and SZW3.ZW_FILIAL = SZW.ZW_FILIAL and szw3.zw_idped = SZW.ZW_IDPED )   VALOR,"
	_cQuery += "     (SELECT SUM(B1_PESBRU * SZW4.ZW_QTDVEN ) FROM "+ RetSqlName("SZW")+" SZW4 JOIN "+RetSqlName("SB1")+" ON B1_COD = ZW_PRODUTO WHERE SZW4.ZW_IDPED =  SZW.ZW_IDPED AND SZW4.D_E_L_E_T_ = ' ') PESO,"
	//_cQuery += "   (SELECT SUM(ZW_FOBDESC) FROM "+RetSqlName("SZW")+" SZW5 WHERE SZW5.D_E_L_E_T_  = ' ' AND SZW5.ZW_IDPED = SZW.ZW_IDPED) DESCONTO,"
	_cQuery += "     ZW_FOBDESC DESCONTO,"

	_cQuery += "     (SELECT ZW_BLOPRC from "+ RETSQLNAME('SZW') + " SZW2  where SZW2.d_e_l_e_t_ = ' ' and SZW2.ZW_FILIAL = SZW.ZW_FILIAL and szw2.zw_idped = SZW.ZW_IDPED "
	_cQuery +=                              " and SZW2.ZW_BLOPRC <> ' ' and rownum = 1)     BLOPRC   ,"
	_cQuery += "     SZW.ZW_IMPRIME    IMPRIME  ,"
	_cQuery += "     SZW.ZW_BLOQ       BLOQ     , "
	_cQuery += "     SZW.ZW_TPVENDA    TPVENDA , SZW.ZW_HORAINC HORAINC  "
	_cQuery += " FROM  "+ RETSQLNAME('SZW') +" SZW , "+ RETSQLNAME('SA3') +" SA3 "
	_cQuery += " WHERE "+ RETSQLDEL('SZW,SA3')
	_cQuery += " AND SA3.A3_FILIAL = '"+ xFilial("SA3") +"' "
	_cQuery += " AND SA3.A3_COD = SZW.ZW_VEND1 "
    _cQuery += " AND SZW.ZW_ITEM = '1 ' "
	_cQuery += " AND SZW.ZW_NUMPED = ' '"

    IF MV_PAR23 = 1 //SÓ REJEITADOS
	   _cQuery += " AND SZW.ZW_STATUS IN ('	Q','R','E','C') "
	ELSE
	   _cQuery += " AND SZW.ZW_STATUS IN ('L','P','D','B','E','C') "
	   _cQuery += " AND ( SZW.ZW_ENVWF <> ' ' or SA3.A3_I_VBROK = 'B' ) " //Somente listar Pedido que já foi avaliado pela rotina MOMS050 - WF DE PREÇO
	ENDIF

//====================================================================================================
// Incluída chamada inicial filtrando por código do Cliente 
//====================================================================================================
	If Empty( _cCodClip )

		If !Empty(MV_PAR02)
			_cQuery += " AND SA3.A3_SUPER  IN "+ FormatIn( MV_PAR02 , ";" )
		EndIf

		If !Empty(MV_PAR01)
			_cQuery += " AND SA3.A3_GEREN  IN "+ FormatIn( MV_PAR01 , ";" )
		EndIf

		If !Empty(MV_PAR03)
			_cQuery += " AND SA3.A3_I_SUPE  IN "+ FormatIn( MV_PAR02 , ";" )
		EndIf

		If !Empty(MV_PAR04)
			_cQuery += " AND SZW.ZW_VEND1  IN "+ FormatIn( MV_PAR04 , ";" )
		EndIf

		If !Empty(MV_PAR05)
			_cQuery += " AND SZW.ZW_FILIAL IN "+ FormatIn( MV_PAR05 , ";" )
		EndIf

		If !Empty(MV_PAR07)
			_cQuery += " AND SZW.ZW_FECENT >= '"+ DTOS( MV_PAR07 ) + "' "
		EndIf

		If !Empty(MV_PAR08)
			_cQuery += " AND SZW.ZW_FECENT <= '"+ DTOS( MV_PAR08 ) + "' "
		EndIf

		If !Empty(MV_PAR09)
			_cQuery += " AND SZW.ZW_EMISSAO >= '"+ DTOS( MV_PAR09 ) + "' "
		EndIf

		If !Empty(MV_PAR10)
			_cQuery += " AND SZW.ZW_EMISSAO <= '"+ DTOS( MV_PAR10 ) + "' "
		EndIf

		If !Empty(MV_PAR11)
			_cQuery += " AND SZW.ZW_CLIENTE >= '"+  MV_PAR11 + "' "
		EndIf

		If !Empty(MV_PAR12)
			_cQuery += " AND SZW.ZW_LOJACLI >= '"+  MV_PAR12 + "' "
		EndIf

		If !Empty(MV_PAR13)
			_cQuery += " AND SZW.ZW_CLIENTE <= '"+  MV_PAR13  + "' "
		EndIf

		If !Empty(MV_PAR14)
			_cQuery += " AND SZW.ZW_LOJACLI <= '"+  MV_PAR14 + "' "
		EndIf

		If !Empty(MV_PAR15)
			_cQuery += " AND (SELECT A1_GRPVEN FROM "+ RETSQLNAME('SA1') +" SA1 "
			_cQuery += " WHERE SA1.D_E_L_E_T_ = ' ' AND SA1.A1_COD = SZW.ZW_CLIENTE AND SA1.A1_LOJA = SZW.ZW_LOJACLI "
			_cQuery += " AND ROWNUM = 1) IN "+ FormatIn( MV_PAR15 , ";" )
		EndIf

        If VALTYPE(MV_PAR18) <> "C" 
           MV_PAR18:=""
        Endif
		If !Empty(MV_PAR18)
			_cQuery += " AND SZW.ZW_I_AGEND IN "+ FormatIn( MV_PAR18 , ";" )
		EndIf

		If MV_PAR19 == 2
			_cQuery += " AND ZW_IMPRIME <> '1' "
		Elseif MV_PAR19 == 1
			_cQuery += " AND ZW_IMPRIME = '1' "
		Endif

		If MV_PAR20 == 1
			_cQuery += " AND ZW_TPFRETE = 'C' "
		Elseif MV_PAR20 == 2
			_cQuery += " AND ZW_TPFRETE = 'F' "
		Endif

		If MV_PAR21 <> 4
			_cQuery += " AND (SELECT A1_I_CLABC FROM "+ RETSQLNAME('SA1') +" SA1 "
			_cQuery += " WHERE SA1.D_E_L_E_T_ = ' ' AND SA1.A1_COD = SZW.ZW_CLIENTE AND SA1.A1_LOJA = SZW.ZW_LOJACLI "
			_cQuery += " AND ROWNUM = 1) = '"+STR(MV_PAR21,1)+"' "
		EndIf

	Else

		_cQuery += " AND SZW.ZW_CLIENTE = '"+ _cCodCli +"' "

	EndIf

	_cQuery += " AND SZW.ZW_VEND1 = SA3.A3_COD "
	_cQuery += " GROUP BY SZW.ZW_FILIAL , SZW.ZW_TIPO   , SZW.ZW_CLIENTE , SZW.ZW_LOJACLI , SZW.ZW_CLIENT  , SZW.ZW_LOJAENT , SZW.ZW_TIPOCLI , SZW.ZW_CONDPAG , SZW.ZW_VEND1   , SA3.A3_SUPER  , "
	_cQuery += "          SA3.A3_GEREN  , SA3.A3_I_SUPE , SZW.ZW_TABELA  , SZW.ZW_EMISSAO , SZW.ZW_TPFRETE , SZW.ZW_TRANSP  , SZW.ZW_DESPESA , SZW.ZW_MENNOTA , SZW.ZW_I_AGEND , SZW.ZW_FILPRO , "
	_cQuery += "          SZW.ZW_OBSCOM , SZW.ZW_HOREN  , SZW.ZW_SENHA   , SZW.ZW_FECENT  , SZW.ZW_EVENTO  , SZW.ZW_STATUS  , SZW.ZW_IDPED   , SZW.ZW_IMPRIME , SZW.ZW_BLOPRC  , SZW.ZW_BLQLCR , "
	_cQuery += "          SZW.ZW_OPTRI  , SZW.ZW_CLIREM , SZW.ZW_LOJEN   , SZW.ZW_ENVWF   , SZW.ZW_NIVELWF , SZW.ZW_MOTLP   , SZW.ZW_FOBDESC , SZW.ZW_TPVENDA , SZW.ZW_HORAINC , SZW.ZW_BLOQ     "
	_cQuery += " ORDER BY ORD, SZW.ZW_FILIAL, SZW.ZW_IDPED "


	oproc:cCaption := ("Carregando query de pedidos...")
	ProcessMessages()

	If select("TRB") > 0

		TRB->(Dbclosearea())

	Endif

	TCQUERY _cquery NEW ALIAS "TRB"

	oproc:cCaption := ("Contando os pedidos...")
	ProcessMessages()

	nQtdTit := 0
	COUNT TO nQtdTit

   nQtdRegs := nQtdTit
	TRB->(Dbgotop())
	_npv:=1

	If _lmantem

		//Guarda pedidos marcados
		_citens := ""
		For _lp := 1 to len(aarr)

			If !empty(aarr[_lp][1])
				_citens += ";" + ALLTRIM(aarr[_lp][8])
			Endif

		Next

	Endif

	aarr := {}


	Do While TRB->(!EOF())

		//Atualiza régua
		oproc:cCaption := ("Processando pedidos do portal... ["+ StrZero(_npv,6) +"] de ["+ StrZero(nQtdTit,6) +"]")
		ProcessMessages()

		//Se é entrega imediata força data de entrega para primeiro dia possível com transit time
		If	ALLTRIM(TRB->TPCAR) $ 'I/O'//I=Imediata //O=Agendada pelo Op.Log.
			_cFilCarreg := TRB->FILIAL
			If !EMPTY(TRB->ZW_FILPRO) .AND. !(ALLTRIM(TRB->ZW_FILPRO)=='0')
				_cFilCarreg := TRB->ZW_FILPRO
			EndIf
		Endif

		//Mantém registros marcados
		If _lmantem .and. ALLTRIM(TRB->NUMPED) $ _CITENS

			_cok := cmarca

		Else

			_cok := ""

		Endif

		//============================================================
		// Calcula o tempo pendente.
		//============================================================
		_cHoraPed    := TRB->HORAINC + ":00"
		_cTempoPend  := ""
		_cHoraPend   :=ElapTime(_cHoraPed,TIME() )
		_nDiasPend   := Date() - StoD( TRB->DTEMISS )
		If _nDiasPend == 0
			_cTempoPend  := _cHoraPend + " Horas  Hr. Incl: " + TRB->HORAINC
		Else
			_cTempoPend  := ALLTRIM(Str(_nDiasPend,10)) + " Dia(s) Hr. Incl: " + TRB->HORAINC
		EndIf

		//============================================================
		Reclock("TRBF",.T.)
		TRBF->OK		    		:= _cok
		TRBF->OK2		    		:= ""
		TRBF->IMPRIME				:= IIF( Empty( TRB->IMPRIME ) , "2" , TRB->IMPRIME ) +"-"+ IIF( TRB->IMPRIME == '1' , "SIM" , "NÃO" )
		TRBF->FILIAL	    		:= TRB->FILIAL   +" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(TRB->FILIAL,1,2),1,"")
		TRBF->FILPRO     			:= IF((EMPTY(TRB->ZW_FILPRO) .OR. (ALLTRIM(TRB->ZW_FILPRO)=='0')),TRB->FILIAL,TRB->ZW_FILPRO)//Se o FILPRO em branco ou errado preenche com o FILIAL
		TRBF->FILPRO     			:= SUBSTR(TRBF->FILPRO,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(TRBF->FILPRO,1,2),1,"")
		TRBF->FILCR     			:= TRB->FILIAL
		TRBF->RFILIAL    			:= TRB->FILIAL
		TRBF->NUMPED 				:= TRB->NUMPED
		TRBF->VALOR 				:= TRB->VALOR
		TRBF->TIPO   				:= TRB->TIPO
		TRBF->CODCLI 				:= TRB->CODCLI
		TRBF->LOJA 					:= TRB->LOJA
		TRBF->NMCLI					:= GetAdvFVal( "SA1" , "A1_NOME" , xFilial("SA1") + TRB->CODCLI + TRB->LOJA , 1 , "" )
		TRBF->TIPOCLI				:= TRB->TIPOCLI
		TRBF->CONDPAGTO  	    	:= TRB->CONDPAGTO
		TRBF->VEND1 				:= TRB->VEND1
		TRBF->NMVEND1				:= GetAdvFVal( "SA3" , "A3_NOME" , xFilial("SA3") + TRB->VEND1 , 1 , "" )
		TRBF->VEND2					:= TRB->VEND2
		TRBF->NMVEND2				:= GetAdvFVal( "SA3" , "A3_NOME" , xFilial("SA3") + TRB->VEND2 , 1 , "" )
		TRBF->TAB_PREC		    	:= TRB->TAB_PREC
		TRBF->DTEMISS				:= DtoC( StoD( TRB->DTEMISS ) )
		TRBF->TPFRETE				:= TRB->TPFRETE
		TRBF->TRANSP				:= TRB->TRANSP
		TRBF->DESPESA				:= TRB->DESPESA
		TRBF->MENSANF				:= TRB->MENSANF
		TRBF->TPCAR					:= TRB->TPCAR
		TRBF->OBSCOMER		    	:= TRB->OBSCOMER
		TRBF->HORAENTR		    	:= TRB->HORAENTR
		TRBF->SENHA					:= TRB->SENHA
		TRBF->DT_ENTREG		    	:= DtoC( StoD( TRB->DT_ENTREG ) )
		TRBF->STAT_ZW				:= TRB->STAT_ZW
		TRBF->BLQLCR				:= TRB->BLQLCR
		TRBF->BLOPRC				:= TRB->BLOPRC
		TRBF->BLOCLI				:= POSICIONE("SA1",1,xfilial("SA1")+TRB->CODCLI+TRB->LOJA,"A1_MSBLQL")
		TRBF->BLOQ    		    	:= TRB->BLOQ
		TRBF->OPTRI   		        := TRB->OPTRI
		TRBF->CLIREM				:= TRB->CLIREM //Depois da Mudança da Op Triangular de  05 para 42. Este campo agora é o cliente de faturamento.
		TRBF->LOJEN					:= TRB->LOJEN
		TRBF->BLQPRC				:= TRB->BLQPRC
		TRBF->ENVWF					:= ALLTRIM(TRB->ENVWF)
		TRBF->MOTLP					:= TRB->MOTLP
		TRBF->TEMPOPEND             := _cTempoPend
		TRBF->PESO					:= TRB->PESO
		TRBF->DESCONTO				:= TRB->DESCONTO
		TRBF->NMMVEND2				:= TRB->VEND2 + " - " + GetAdvFVal( "SA3" , "A3_NOME" , xFilial("SA3") + TRB->VEND2 , 1 , "" )
		TRBF->NMVEND3				:= TRB->VEND3 + " - " + GetAdvFVal( "SA3" , "A3_NOME" , xFilial("SA3") + TRB->VEND3 , 1 , "" )

		//Se cliente está bloqueado e status de crédito não está como Z atualiza a SZW
		If TRBF->BLOCLI == "1" .AND. TRBF->BLQLCR != "Z" .AND. TRBF->BLQLCR != "R"

			SZW->(Dbsetorder(1))
			If SZW->(Dbseek(TRB->FILIAL+TRB->NUMPED))

				Do while SZW->ZW_FILIAL == TRB->FILIAL .AND. SZW->ZW_IDPED == TRB->NUMPED

					Reclock("SZW",.F.)
					SZW->ZW_BLQLCR := "Z"
					SZW->ZW_I_MOTBL := "CLIENTE BLOQUEADO"
					SZW->ZW_DTAVAC := DATE()
					SZW->ZW_HRAVAC := TIME()
					SZW->(Msunlock())

					SZW->(Dbskip())

				Enddo

			Endif

		Endif

		_linclui := .T.

		IF MV_PAR06 == 1

			_ccor := U_AOMS1128(TRBF->(Recno()))

			Reclock("TRBF",.F.)
			TRBF->STATUS1 := _ccor
			TRBF->(Msunlock())

			If  (MV_PAR17 == 1 .AND. ALLTRIM(TRBF->STATUS1) != "VERDE") .OR. (MV_PAR17 == 2 .AND. ALLTRIM(TRBF->STATUS1) != "VERMELHO")
				Reclock("TRBF",.F.)
				TRBF->(Dbdelete())
				TRBF->(Msunlock())
				_linclui := .F.
			Endif

		Endif

		//Filtra status da legenda principal
		_acor := U_AOMS1129(TRBF->(Recno()),.T.)
		_ncor := _acor[1]
		_ccor := _acor[2]

		Reclock("TRBF",.F.)
		TRBF->STATUS2 := ALLTRIM(STRZERO(_ncor,2))
		TRBF->STATUS3 := ALLTRIM(_CCOR)
		TRBF->(Msunlock())

		If !empty(MV_PAR16)

			If MV_PAR23 <> 1 .AND. !(ALLTRIM(TRBF->STATUS2) $ MV_PAR16)//FILTRO POR LEGERNDA

				_linclui := .F.

				Reclock("TRBF",.F.)
				TRBF->(Dbdelete())
				TRBF->(Msunlock())

			Endif

		Endif

		_npv++

		If _linclui

			_cFilCarreg := TRB->FILIAL
			If !EMPTY(TRB->ZW_FILPRO) .AND. !(ALLTRIM(TRB->ZW_FILPRO)=='0')
				_cFilCarreg := TRB->ZW_FILPRO
			EndIf

			_cliremessa := iif(empty(TRBF->CLIREM),"  ",TRBF->CLIREM + "/" + TRBF->LOJEN + " - " + POSICIONE("SA1",1,xfilial("SA1")+ALLTRIM(TRBF->CLIREM)+ALLTRIM(TRBF->LOJEN),"A1_NOME") ) //Depois da Mudança da Op Triangular de  05 para 42. Este campo agora é o cliente de faturamento.
			IF !lHtml
				aadd(aarr,{	_cok,;                              // 01
				"  ",;                                          // 02
				"  ",;                                          // 03
				ALLTRIM(TRBF->IMPRIME),;                        // 04
				TRBF->TIPO + " - " + substr(POSICIONE("ZB4",1,XFILIAL("ZB4")+TRBF->TIPO,"ZB4_DESCRI"),1,20),;  // 05
				ALLTRIM(TRBF->FILIAL) ,;                        // 06
				TRBF->FILPRO ,;                                 // 07
				ALLTRIM(TRBF->NUMPED) ,;                        // 08
				ALLTRIM(TRBF->CODCLI) + "/" + ALLTRIM(TRBF->LOJA) + " - " + POSICIONE("SA1",1,xfilial("SA1")+ALLTRIM(TRBF->CODCLI)+ALLTRIM(TRBF->LOJA),"A1_NOME") ,;  // 09
				IIF(TRBF->TPCAR == 'A','AGENDADA',IF(TRBF->TPCAR = 'I','IMEDIATA',IF(TRBF->TPCAR = 'O','AGENDADA P/ O.LOG.',IIF(TRBF->TPCAR == 'M','AGENDADA C/MULTA','AGUARD. AGENDA')))) ,;// 10
				ALLTRIM(TRBF->DTEMISS),;                        // 11
				ALLTRIM(dtoc(ctod(TRBF->DT_ENTREG)-_ndias)),;   // 12
				strzero(_ndias,3) ,;                            // 13
				ALLTRIM(TRBF->DT_ENTREG),;                      // 14
				IIF(TRBF->TPFRETE=="C",'CIF','FOB') ,;          // 15
				TRBF->TAB_PREC + " - "  + ALLTRIM(POSICIONE("DA0",1,xFilial("DA0")+TRBF->TAB_PREC ,"DA0_DESCRI")),;  // 16
				TRBF->CONDPAGTO + " - " + ALLTRIM(POSICIONE("SE4",1,xfilial("SE4")+TRBF->CONDPAGTO,"E4_DESCRI")) ,;  // 17
				TRBF->VEND1 + " - " + ALLTRIM(POSICIONE("SA3",1,xfilial("SA3")+TRBF->VEND1,"A3_NREDUZ")) ,;          // 18
				ALLTRIM(TRBF->MENSANF) ,;                        // 19
				ALLTRIM(TRBF->OBSCOMER),;                        // 20
				TRBF->(Recno()),;                                // 21
				TRBF->STATUS1,;                                  // 22
				TRBF->STATUS2,;                                  // 23
				TRBF->STATUS3,;                                  // 24
				TRBF->VALOR,;                                    // 25
				TRBF->OPTRI,;                                    // 26
				_cliremessa,;                                    // 27
				_cTempoPend,;									 // 28
				TRBF->PESO,;                                     // 29
				TRBF->DESCONTO,;								 // 30
				TRBF->NMMVEND2,;								 // 31
				TRBF->NMVEND3})									 // 32
			ELSE// AO TROCAR AS ORDENS DOS CAMPOS NA TELA: TROQUE A ORDEM AQUI TB E TESTE VIA HTML "ACERTO MANUAL"
				    aadd(aarr,{	_cok,;            // 01
				    "  ",;                        // 02
				    "  ",;                        // 03
				    ALLTRIM(TRBF->IMPRIME),;      // 04
				    ALLTRIM(TRBF->DTEMISS),;      // 05
				    _cTempoPend,;				  // 06
				    IIF(TRBF->TPCAR='A','AGENDADA',IF(TRBF->TPCAR='I','IMEDIATA',IF(TRBF->TPCAR='O','AGENDADA P/ O.LOG.',IIF(TRBF->TPCAR='M','AGENDADA C/MULTA','AGUARD. AGENDA')))) ,;// 07
					ALLTRIM(TRBF->DT_ENTREG),;    // 08
					ALLTRIM(TRBF->FILIAL) ,;      // 09
					TRBF->FILPRO ,;               // 10
					TRBF->CONDPAGTO + " - " + ALLTRIM(POSICIONE("SE4",1,xfilial("SE4")+TRBF->CONDPAGTO,"E4_DESCRI")) ,; // 11
					ALLTRIM(TRBF->NUMPED) ,;                                                                            // 12
					TRBF->TIPO + " - " + substr(POSICIONE("ZB4",1,XFILIAL("ZB4")+TRBF->TIPO,"ZB4_DESCRI"),1,20),;       // 13
					_cliremessa,;                                                                                       // 14
					ALLTRIM(TRBF->CODCLI) + "/" + ALLTRIM(TRBF->LOJA) + " - " + POSICIONE("SA1",1,xfilial("SA1")+ALLTRIM(TRBF->CODCLI)+ALLTRIM(TRBF->LOJA),"A1_NOME") ,;  // 15
					TRBF->VALOR,;                                // 16
					IIF(TRBF->TPFRETE=="C",'CIF','FOB') ,;       // 17
					TRBF->PESO,;                                 // 18
					TRBF->DESCONTO,;			                 // 19
					ALLTRIM(TRBF->OBSCOMER),;                    // 20
					ALLTRIM(TRBF->MENSANF) ,;                    // 21
					strzero(_ndias,3) ,;                         // 22
					ALLTRIM(dtoc(ctod(TRBF->DT_ENTREG)-_ndias)),;// 23
					TRBF->TAB_PREC + " - " +  ALLTRIM(POSICIONE("DA0",1,xFilial("DA0")+TRBF->TAB_PREC,"DA0_DESCRI")),;  // 24
					TRBF->VEND1 + " - " + ALLTRIM(POSICIONE("SA3",1,xfilial("SA3")+TRBF->VEND1,"A3_NREDUZ")) ,;         // 25
					TRBF->NMMVEND2,;			  // 26
					TRBF->NMVEND3,;			      // 27
					TRBF->OPTRI,;                 // 28
					TRBF->STATUS3,;               // 29
					TRBF->STATUS2,;               // 30
					TRBF->STATUS1,;               // 31
					TRBF->(Recno())})	          // 32 <-- Garantir que o recno fique sempre na ultima posição no html

				ENDIF

			Endif

			TRB->( DBSkip() )

	EndDo

	TRB->( DBCloseArea())

	TRBF->(DbGotop())

	If _lcabec  //Inicializa cabecalho

        IF MV_PAR23 <> 1 //DE SÓ REJEITADOS
		  nQtdTit := 0
	   ENDIF
		nPesTit	:= 0
		nValTit := 0

		oQtda:Refresh()
		oValor:Refresh()

	Endif

    //Se browse já está montando garante que array está atualizado
    If TYPE("omark") == "O" 
      If nQtdRegs > 0 .AND. Len(aarr) > 0
   		IF !lHtml//QUANDO FOR HTML O ARRAY DEVE SER ORDENADO MANUALMENTE
   			A112RA()////REORDENA O AARR PARA PERMITIR AS MODIFICAÇOES NAS COLUNAS
   		ENDIF
   		omark:setarray(aarr)
   		omark:refresh()
   		TRBF->(Dbgoto(aarr[OMARK:NAT,LEN(aarr[OMARK:NAT])]))
      Else
         aarr := {}
         omark:setarray(aarr)
         omark:refresh()
         u_itmsg("Não há registros para o filtro atual.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
      Endif
   Endif

Return

/*
===============================================================================================================================
Programa----------: AOMS112()
Autor-------------: Josué Danich Prestes
Data da Criacao---: 02/10/2018
===============================================================================================================================
Descrição---------: Chamada de itens do menu
===============================================================================================================================
Parametros--------: _nopc - Opção do menu
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112C(_nopc)

	Local oproc

	If len(aarr) > 0

		TRBF->(Dbgoto(aarr[OMARK:NAT,LEN(aarr[OMARK:NAT])]))

	Endif

	Do Case

	Case _nopc == 1
		//Atualizar
		fwmsgrun(,{ |oproc| AOMS112arq(oproc) }, "Aguarde...","Carregando dados...")

	Case _nopc == 2
		//Pesquisa
        If len(aarr) > 0
           AOMS112PSQ()
        Else
           u_itmsg("Não há registros para pesquisar.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
        Endif

	Case _nopc == 3
		//Filtro
		fwmsgrun(,{ |oproc| AOMS112FIL(oproc) }, "Aguarde...","Carregando dados...")

	Case _nopc == 4
		//Altera filiais
		If len(aarr) > 0
			fwmsgrun(,{ |oproc| AOMS112AF() }, "Aguarde...","Carregando dados...")
		Else
			u_itmsg("Não há registros para alterar.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
		Endif

	Case _nopc == 5
		//Visualizar Pedido
		If len(aarr) > 0
			fwmsgrun(,{ || AOMS112VP() }, "Aguarde...","Carregando dados...")
		Else
			u_itmsg("Não há registros para visualizar.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
		Endif

	Case _nopc == 6
		//Alterar
		If len(aarr) > 0
			fwmsgrun(,{ || AOMS112AT() }, "Aguarde...","Carregando dados...")
		Else
			u_itmsg("Não há registros para alterar.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
		Endif

	Case _nopc == 7
		//Legenda
		AOMS112LEG()

	Case _nopc == 8
		//Marcar não impresso
		If len(aarr) > 0
			fwmsgrun(,{ |oproc| AOMS112DI(oproc) }, "Aguarde...","Carregando dados...")
		Else
			u_itmsg("Não há registros para marcar.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
		Endif

	Case _nopc == 9
		//Recusar
		If len(aarr) > 0
			fwmsgrun(,{ |oproc| AOMS112REC(oproc) }, "Aguarde...","Carregando dados...")
		Else
			u_itmsg("Não há registros para recusar.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
		Endif

	Case _nopc == 10
		//Exporta Excel
		If len(aarr) > 0
			fwmsgrun(,{ || AOMS112EC(oproc) }, "Aguarde...","Carregando dados...")
		Else
			u_itmsg("Não há registros para exportar.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
		Endif

	Case _nopc == 11
		//Efetivar
		If len(aarr) > 0
			fwmsgrun(,{ || AOMS112EFI(oproc) }, "Aguarde...","Carregando dados...")
		Else
			u_itmsg("Não há registros para efetivar.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
		Endif

	Case _nopc == 12
		//Imprimir
		If len(aarr) > 0
			fwmsgrun(,{ |oproc| AOMS112IM(oproc) }, "Aguarde...","Carregando dados...")
		Else
			u_itmsg("Não há registros para imprimir.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
		Endif

	Otherwise
		u_itmsg("Opção não existe","Atenção","Contate a area de TI",1)
	EndCase

	If len(aarr) > 0

		TRBF->(Dbgoto(aarr[OMARK:NAT,LEN(aarr[OMARK:NAT])]))

	Endif


Return

/*
===============================================================================================================================
Programa--------: AOMS1129
Autor-----------: Josué Danich Prestes
Data da Criacao-: 18/02/2014
===============================================================================================================================
Descrição-------: Retorna cor e legenda
===============================================================================================================================
Parametros------: _nlinha - linha a ser posicionada
									_lsimples - retorno simplificado para filtro
===============================================================================================================================
Retorno---------: string com cor da legenda da linha posicionada no TRBF
===============================================================================================================================
*/
User Function AOMS1129(_nlinha,_lsimples,lweb)

	Local _ccor := "BR_VERMELHO"
	Local _ncor := 11
	Local lHtml:= (GetRemoteType() == 5)
	Default _lsimples := .F.
	Default lweb := .F.
	Default _nlinha := aarr[OMARK:NAT,LEN(aarr[OMARK:NAT])]

	IF ValType(_nlinha) == "C" .AND. lHtml
		_nlinha := OMARK:NAT
	ENDIF

	Begin Sequence

		TRBF->(Dbgoto(_nlinha))

		If MV_PAR23 = 1 //SÓ REJEITADOS

			_ccor := "UPDERROR"//"QMT_NO"//"UPDERROR"
			_ncor := 12

		elseIf TRBF->BLQLCR == 'R'

			_ccor := "BR_LARANJA"
			_ncor := 1

		ElseIf TRBF->BLOPRC == 'B' .AND. ALLTRIM(TRBF->ENVWF) == 'C'

			_ccor := "BR_AMARELO"
			_ncor := 9

		ElseIf TRBF->BLOPRC == 'B' .AND. ALLTRIM(TRBF->ENVWF) == 'G'
			_ccor := "BR_VERDE_ESCURO"
			_ncor := 10

		ElseIf TRBF->STAT_ZW == 'L' .AND. Empty(ALLTRIM(TRBF->ENVWF))
			_ccor := "BR_VERDE_ESCURO"
			_ncor := 10

		ElseIf TRBF->BLOCLI == '1'

			_ccor := "BR_CANCEL"
			_ncor := 2

		ElseIf TRBF->TIPO = '10' .AND. TRBF->BLOQ != 'L' .AND. TRBF->BLOQ != 'R'

			_ccor := "BR_MARRON_OCEAN
			_ncor := 3

		ElseIf TRBF->TIPO = '10' .AND.  TRBF->BLOQ == 'R'

			_ccor := "BR_MARRON"
			_ncor := 4

		ElseIf ( TRBF->BLQLCR == 'C' .OR. TRBF->BLQLCR == 'L' .OR. Empty(TRBF->BLQLCR) ) .AND. TRBF->BLOPRC == 'R'

			_ccor := "BR_VIOLETA"
			_ncor := 5

		ElseIf ( TRBF->BLQLCR == 'C' .OR. TRBF->BLQLCR == 'L' .OR. Empty(TRBF->BLQLCR) ) .AND. TRBF->BLOPRC == 'B'

			_ccor := "BR_PRETO"
			_ncor := 6

		ElseIf ( TRBF->BLQLCR == 'C' .OR. TRBF->BLQLCR == 'L' .OR. Empty(TRBF->BLQLCR) ) .AND. TRBF->BLOPRC == 'L'

			_ccor := "BR_VERDE"
			_ncor := 7

		ElseIf TRBF->BLQLCR == 'B'

			_ccor := "BR_AZUL"
			_ncor := 8

		Else

			_ccor := "BR_VERMELHO"
			_ncor := 11

		Endif

	End Sequence

	IF lweb
		_ccor := SUBSTR(_ccor,4)
	ENDIF
	If _lsimples

		_xret := {}
		aadd(_xret,_ncor)
		aadd(_xret,_ccor)

	Else

		_xret := _ccor

	Endif

Return _xret

/*
===============================================================================================================================
Programa--------: AOMS1128
Autor-----------: Josué Danich Prestes
Data da Criacao-: 18/02/2014
===============================================================================================================================
Descrição-------: Retorna cor e legenda para simulador
===============================================================================================================================
Parametros------: _nlinha - linha do browse
===============================================================================================================================
Retorno---------: string com cor da legenda da linha posicionada no TRBF
===============================================================================================================================
*/
User Function AOMS1128(_nlinha,lweb)

	Local _ccor := "BR_BRANCO"
	Local cRet
	Local aArea  := GetArea()
	Local lHtml:= (GetRemoteType() == 5)

	DEFAULT _nlinha := aarr[OMARK:NAT,LEN(aarr[OMARK:NAT])]

	MV_PAR06 := 2 //DESABILITAR SIMULADOR por garantia aqui tb

	IF ValType(_nlinha) == "C" .AND. lHtml
		_nlinha := OMARK:NAT
	ENDIF

	TRBF->(Dbgoto(_nlinha))

	If MV_PAR06 == 2

		//Legenda em branco sem simulador de preços
		_ccor := "BPMTASK3"

		Return cret

	Endif

	If TRBF->BLOCLI == '1'

		_ccor := "VERMELHO"

	ElseIf TRBF->TIPO = '10' .AND. TRBF->BLOQ != 'L'

		_ccor := "VERMELHO"

	Else

		_ccor := "VERDE"

		//Valida preço para o pedido
		SZW->(Dbsetorder(1))
		If SZW->(Dbseek(substr(TRBF->FILIAL,1,2)+TRBF->NUMPED))


			Do while SZW->ZW_FILIAL == substr(TRBF->FILIAL,1,2) .AND. SZW->ZW_IDPED == TRBF->NUMPED

				If SZW->ZW_BLOPRC == "B"
					_ccor := "VERMELHO"
					Exit
				Endif

				SZW->(Dbskip())

			Enddo

		Endif


	Endif

	RestArea(aArea)

Return _ccor

/*
===============================================================================================================================
Programa----------: AOMS112FIL
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Função que refaz filtro da tela
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112FIL(oproc)

	If Pergunte( cPerg , .T. )

		//================================================================================
		// Cria o arquivo Temporario para insercao dos dados selecionados.
		//================================================================================
		FWMSGRUN( , {|oproc| AOMS112ARQ(oproc) }, "Aguarde!" , 'Lendo Dados dos pedidos...' )

	Endif

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS112PSQ
Autor-------------: Alex Wallauer
Data da Criacao---: 20/07/2018
===============================================================================================================================
Descrição---------: Funcao para pesquisa no arquivo temporario.
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS112PSQ( oproc)

	Local oGet1		:= Nil
	Local oDlg		:= Nil
	Local cGet1		:= Space(40)
	Local cComboBx1	:= ""
	Local aComboBx1	:= { "Pedido" , "Cliente/Remessa" , "Nome Cliente/Remessa" , "Nome Rede" }
	Local nOpca		:= 0
	Local nI		:= 0

	DEFINE MSDIALOG oDlg TITLE "Pesquisar" FROM 178,181 TO 259,697 PIXEL

	@004,003 ComboBox	cComboBx1	Items aComboBx1 Size 213,010 OF oDlg PIXEL
	@020,003 MsGet		oGet1		Var cGet1		Size 212,009 OF oDlg PIXEL COLOR CLR_BLACK Picture "@!"

	DEFINE SBUTTON FROM 004,227 TYPE 1 ENABLE ACTION ( nOpca := 1 , oDlg:End() ) OF oDlg
	DEFINE SBUTTON FROM 021,227 TYPE 2 ENABLE ACTION ( nOpca := 0 , oDlg:End() ) OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 1

		For nI := 1 To Len(aComboBx1)

			If cComboBx1 == aComboBx1[nI]

				DBSelectArea("TRBF")
				TRBF->( DBSetOrder(ni) )

				If TRBF->(DbSeek( cGet1 ))

					_npos := ascan(aarr,{|x| x[Len(x)] = TRBF->(Recno())})
					oMark:Goposition(_npos)
					oMark:Refresh()

				Else
					u_itmsg(cComboBx1+" não encontrado!")
				Endif

				TRBF->( DBSetOrder(1) )

			EndIf

		Next nI

	EndIf

Return()

/*
===============================================================================================================================
Programa----------: AOMS112VP
Autor-------------: Erich Buttner
Data da Criacao---: 12/03/2013
===============================================================================================================================
Descrição---------: Rotina para VISUALIZAÇÃO DOS PEDIDOS
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112VP()

	Local cTitulo	 := "Visualização de Pedido Portal"
	Local lRetMod2 	 := .F. // Retorno da função Modelo2 - .T. Confirmou / .F. Cancelou
	Local nLinha	 := 0,nColuna
	Local _cRede     := "999999"
	Local _cUFCli    := ""
	Local _lSimplNac := .F.
	Local _nPesoBrutoPedido := 0
	Local _aBlqprc := {}

	Public nOpcx	 := 7

	DBSelectArea("Sx3")
	SX3->( DBSetOrder(1) )
	SX3->( DBSeek("SZW") )

	nUsado		:= 0
	aHeader		:= {}
	aCols		:= {}
	cDescr		:= ""
	nQtd2UM		:= 0
	c2UM		:= ""
	nVlrTot		:= 0
	nVTot		:= 0

//====================================================================================================
// Montagem do aHeader
//====================================================================================================
	If MV_PAR06 == 1 //Simulador

		aHeader := {{ "Item"			, "ZW_ITEM"		    , "@!"						,010,0,"AllwaysTrue()","","C","","R"},;
                    { "Produto"			, "ZW_PRODUTO"	    , "@!"						,015,0,"AllwaysTrue()","","C","","R"},;
                    { "Descrição"		, "cDescr"			, "@!"						,020,0,"AllwaysTrue()","","C","","R"},;
                    { "Qtd Ven 2 UM"	, "nQtd2UM"		    , "@e 999,999,999.99"	    ,014,2,"AllwaysTrue()","","C","","R"},;
                    { "Segunda UM"		, "c2UM"			, "@!"						,002,0,"AllwaysTrue()","","C","","R"},;
                    { "Quantidade"		, "ZW_QTDVEN"		, "@e 999,999,999.99"	    ,014,2,"AllwaysTrue()","","C","","R"},;
                    { "Unidade"			, "ZW_UM"			, "@!"						,002,0,"AllwaysTrue()","","C","","R"},;
                    { "Prc Unitario"	, "ZW_PRCVEN"		, "@e 9,999,999.9999"	    ,014,4,"AllwaysTrue()","","C","","R"},;
                    { "Preco Net"		, "ZW_I_PRNET"      , "@e 9,999,999.9999"	    ,014,4,"AllwaysTrue()","","C","","R"},;
                    { "Vlr.Total "		, "nVlrTot"		    , "@e 999,999,999.99"	    ,014,2,"AllwaysTrue()","","C","","R"},;
                    { "Blq. Preço "		, "ZW_BLOPRC"		, "@!"						,001,0,"AllwaysTrue()","","C","","R"},;
                    { "Tab Preço "	    , "ZW_TABELA + ' - ' + posicione('DA0',1,xFilial('DA0')+ZW_TABELA,'DA0_DESCRI')", "@!", 004 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
                    { "Sit Preço "	    , "csituaca"	    , "@!"						, 020 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
                    { "Sel Tabela "	    , " "	            , "@!"						, 002 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
                    { "Reg Regra "	    , " "	            , "@99999999"				, 002 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
                    { "Local "		    , "ZW_LOCAL"	    , "@!"						, 002 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" } }

	Else

		aHeader := {{ "Item"		    , "ZW_ITEM"		      ,"@!"						,010,0,"AllwaysTrue()","","C","","R"},;
                    { "Produto"			, "ZW_PRODUTO"	      ,"@!"						,015,0,"AllwaysTrue()","","C","","R"},;
                    { "Descrição"		, "cDescr"			  ,"@!"						,020,0,"AllwaysTrue()","","C","","R"},;
                    { "Qtd Ven 2 UM"	, "nQtd2UM"		      ,"@e 999,999,999.99"	    ,014,2,"AllwaysTrue()","","C","","R"},;
                    { "Segunda UM"		, "c2UM"			  ,"@!"						,002,0,"AllwaysTrue()","","C","","R"},;
                    { "Quantidade"		, "ZW_QTDVEN"		  ,"@e 999,999,999.99"	    ,014,2,"AllwaysTrue()","","C","","R"},;
                    { "Unidade"			, "ZW_UM"			  ,"@!"						,002,0,"AllwaysTrue()","","C","","R"},;
                    { "Prc Unitario"	, "ZW_PRCVEN"		  ,"@e 9,999,999.9999"	    ,014,4,"AllwaysTrue()","","C","","R"},;
                    { "Preco Net "	    , "ZW_I_PRNET"        ,"@e 9,999,999.9999"	    ,014,4,"AllwaysTrue()","","C","","R"},;
                    { "Vlr.Total "		, "nVlrTot"		      ,"@e 999,999,999.99"	    ,014,2,"AllwaysTrue()","","C","","R"},;
                    { "Blq. Preço "		, "ZW_BLOPRC"		  ,"@!"						,001,0,"AllwaysTrue()","","C","","R"},;
                    { "Local "		    , "ZW_LOCAL"	      ,"@!"						,002,0,"AllwaysTrue()","","C","","R"} }

	Endif


	_nPesoBrutoPedido := AOMS112PES(TRBF->FILIAL,TRBF->NUMPED)

	DBSELECTAREA("SZW")
	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( SubStr( TRBF->FILIAL , 1 , 2 ) + TRBF->NUMPED ) )
	While SZW->( !Eof() ) .AND. SZW->( ZW_FILIAL + ZW_IDPED ) == SubStr( TRBF->FILIAL , 1 , 2 ) + TRBF->NUMPED

		//====================================================================================================
		// Montagem do Acols
		//====================================================================================================
		AADD( aCols , Array( Len(aHeader) + 1 ) )
		nLinha++


		cDescr      := Posicione('SB1',1,xFilial("SB1")+ALLTRIM(SZW->ZW_PRODUTO),'B1_DESC')
		nFatConv	:= SB1->B1_CONV
		cTpConv		:= SB1->B1_TIPCONV
		nNewFat		:= SB1->B1_I_FATCO
		c2UM		:= SB1->B1_SEGUM
		cGrupoP		:= SB1->B1_GRUPO


		If SZW->ZW_FILPRO != '0 ' .and. !empty(SZW->ZW_FILPRO) .and. SZW->ZW_FILPRO != SZW->ZW_FILIAL

			_cfilpro := SZW->ZW_FILPRO

		Else

			_cfilpro := SZW->ZW_FILIAL

		Endif
		_cRede  := Posicione('SA1',1,xFilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,'A1_GRPVEN')
		_cUFCli := SA1->A1_EST

		_lSimplNac  :=IF(SA1->A1_SIMPNAC="1",.T.,.F.)

		_csuper := posicione("SA3",1,xfilial("SA3")+SZW->ZW_VEND1,"A3_I_SUPE")
		_cCoord := SA3->A3_SUPER
		_cGeren := SA3->A3_GEREN

		//Posiciona a tabela de preço e verifica se preço está ok
		DA1->(Dbsetorder(1))
		If !DA1->(Dbseek(xFilial("DA1")+SZW->ZW_TABELA+SZW->ZW_PRODUTO))

			csituaca := "Produto não consta na tabela de preço"

		Elseif SZW->ZW_PRCVEN > DA1->DA1_PRCMAX

			csituaca    := "Preço acima do máximo: " + transform(DA1->DA1_PRCMAX,"@E 999,999,999.99")

		Elseif Round(SZW->ZW_PRCVEN,2) < DA1->DA1_I_PMF3 .And. SZW->ZW_KIT == ' ' 

			//Valida pela função padrão para pegar exceções
			_chistprec := "  "
			_aBlqprc := U_BLQPRC(SZW->ZW_PRODUTO,SZW->ZW_PRCVEN,SZW->ZW_FILIAL,   .F.,SZW->ZW_TABELA,    .T.,      .T.,        .T.,           ,  cGrupoP, _cUFCli,         ,SZW->ZW_TPVENDA,_lSimplNac,_nPesoBrutoPedido,SZW->ZW_I_FXPES)

			_lbloq   := _aBlqprc[1]

			If !_lbloq

				csituaca := "Pré Aprovado - " + _chistprec

			Else

				csituaca := "Preço abaixo do mínimo: " + transform(DA1->DA1_I_PMF3,"@E 999,999,999.99")

			Endif

		Else

			csituaca    := "Pré Aprovado"

		Endif

		If cTpConv == "M"
			nQtd2UM	:= IIf( nFatConv == 0 , nNewFat * SZW->ZW_QTDVEN	, nFatConv * SZW->ZW_QTDVEN	)
		Else
			nQtd2UM	:= IIf( nFatConv == 0 , SZW->ZW_QTDVEN / nNewFat	, SZW->ZW_QTDVEN / nFatConv	)
		EndIf

		nVlrTot		:= SZW->ZW_QTDVEN * SZW->ZW_PRCVEN
		nVtot		+= nVlrTot

		For nColuna := 1 to Len(aHeader)
			aCols[nLinha][nColuna] := &( aHeader[nColuna][2] )
		Next nColuna

		aCols[nLinha][Len(aHeader)+1] := .F. // Linha não deletada

		SZW->( DBSkip() )

	EndDo

	cFli		:= Space(20)
	cFilPro		:= Space(40)
	cTipPed		:= Space(15)
	cNumPed		:= Space(25)
	cCliente	:= Space(06)
	cNomCli		:= Space(60)
	cLojaCli	:= Space(04)
	cGrpCli		:= Space(30)
	cCond		:= Space(50)
	cVend1		:= Space(06)
	cTabelaPrc	:= Space(06)
	cDescTabela	:= Space(40)
	cPedCli		:= Space(09)
	dDtEnt		:= CtoD("")
	cTipoAg		:= Space(10)
	cHrEnt		:= Space(05)
	cSha		:= Space(14)
	cTipFre		:= Space(10)
	cClassEnt	:= Space(20)
	cTipCar		:= Space(15)
	cQtdCha		:= Space(03)
	cHrDes		:= Space(05)
	nCusDes		:= 0
	cObsCom		:= Space(300)
	cObsNF		:= Space(300)
	cObsALC		:= Space(300)
	cMotRec		:= Space(300)

	DBSELECTAREA("SZW")
	SZW->( DBSetOrder(1) )
	SZW->( DbSeek( SubStr( TRBF->FILIAL , 1 , 2 ) + TRBF->NUMPED ) )

	dDtEnt		:= SZW->ZW_FECENT
	_laltera := .T.

	If SZW->ZW_I_AGEND == 'P'

		//cTipoAg		:= SZW->ZW_I_AGEND+" - AGUARD AGENDA"

		If month(date()) != 12

			dDtEnt := STOD(ALLTRIM(STR((YEAR(DATE())+1)))+"0101")-1

		Else

			dDtEnt := STOD(ALLTRIM(STR((YEAR(DATE())+2)))+"0101")-1

		Endif

		_laltera := .F.

	Endif

	If SZW->ZW_I_AGEND $ 'I/O'//I=Imediata //O=Agendada pelo Op.Log.

		_cFilCarreg := SZW->ZW_FILIAL
		If !EMPTY(SZW->ZW_FILPRO) .AND. !(ALLTRIM(SZW->ZW_FILPRO)=='0')
			_cFilCarreg := SZW->ZW_FILPRO
		EndIf

		//cTipoAg		:= SZW->ZW_I_AGEND+" - IMEDIATO"
		dDtEnt := DATE()+u_omsvldent(DATE(),SZW->ZW_CLIENTE,SZW->ZW_LOJACLI,SZW->ZW_FILIAL,TRBF->NUMPED,1,.F.,_cFilCarreg,SZW->ZW_TIPO,SZW->ZW_TPVENDA)
		_laltera := .F.

	Endif

	//If SZW->ZW_I_AGEND == 'M'
	//	cTipoAg		:= SZW->ZW_I_AGEND+" - AGENDADA COM MULTA"
	//Endif
	//If SZW->ZW_I_AGEND == 'A'
	//	cTipoAg		:= SZW->ZW_I_AGEND+" - AGENDADA"
	//Endif

    cTipoAg:=SZW->ZW_I_AGEND+" - "+(U_TipoEntrega(SZW->ZW_I_AGEND))

//====================================================================================================
// Configuracao dos Campos
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
//====================================================================================================
	aC := {	{ "cFli"	, {015,003}	, "Filial                   " 	  	,"@!"   				,	,		,.F.	},;
		{ "cFilPro" 	, {015,203} , "Filial Carregamento   "         	,"@!"   				,   ,       ,.F.	},;
		{ "cTipPed"		, {030,003}	, "Tipo Pedido       " 				,"@!"   				,	,		,.F.	},;
		{ "cNumPed"		, {030,203}	, "Num. Pedido           " 			,"@!"   				,	,		,.F.	},;
		{ "cCliente"  	, {045,003}	, "Cliente/Remessa" 				,"@!"   				,	,		,.F.	},;
		{ "cLojaCli"	, {045,085}	, "Loja   "							,"@!"   				,	,		,.F.	},;
		{ "cNomCli"		, {045,140}	, "Nome Cliente/Remessa"			,"@!"   				,	,		,.F.	},;
		{ "cGrpCli"		, {060,003}	, "Grupo Cliente/Rem."				,"@!"   				,	,		,.F.	},;
		{ "cCond"		, {060,285}	, "Cond. Pagto" 					,"@!"   				,	,		,.F.	},;
		{ "cVend1"		, {075,003}	, "Vendedor 1       "  				,"@!"   				,	,		,.F.	},;
		{ "cNmVend1"	, {075,140}	, "Nome Vendedor 1" 				,"@!"   				,	,		,.F.	},;
		{ "nVTot"		, {075,500}	, "Valor Total   " 					,"@e 999,999,999.99"	,	,		,.F.	},;
		{ "cTabelaPrc"  , {090,003}	, "Cod.Tab.Prc       "  			,"@!"   				,	,		,.F.	},;
		{ "cDescTabela"	, {090,140}	, "Desc. Tabela   " 				,"@!"   				,	,		,.F.	},;
		{ "cPedCli"		, {105,003}	, "Pedido Cliente/Remessa"		    ,"@!"   				,	,		,.F.	},;
		{ "dDtEnt"		, {015,500}	, "Data Entrega          "			,"@!"   				,	,		,_laltera	},;
		{ "cTipoAg"		, {030,500}	, "Tipo Agendamento"				,"@!"   				,	,		,.F.	},;
		{ "cHrEnt"		, {105,245}	, "Hora Entrega   "					,"@!"   				,	,		,.F.	},;
		{ "cSha"		, {105,325}	, "Senha                "			,"@!"   				,	,		,.F.	},;
		{ "cTipFre"		, {105,500}	, "Tipo Frete    "					,"@!"   				,	,		,.F.	},;
		{ "cTipCar"		, {120,003}	, "Tipo de Carga     "				,"@!"   				,	,		,.F.	},;
		{ "cQtdCha"		, {120,140}	, "Qtd. Chapa"          			,"@!"   				,	,		,.F.	},;
		{ "cHrDes"		, {120,245}	, "Hora Descarga"					,"@!"   				,	,		,.F.	},;
		{ "nCusDes"		, {120,325}	, "Custo Descarga"					,"@e 999,999,999.99"	,	,		,.F.	},;
	    { "cClassEnt"   , {120,500}	, "Classif. Entrega"				,"@!"   				,	,		,.F.	},;
		{ "cObsCom"		, {135,003}	, "Obs. Comercial  "				,"@!"					,	,		,.F.	},;
		{ "cObsNf"		, {150,003}	, "Mensagem NF    "					,"@!"					,	,		,.F.	},;
		{ "cObsALC"		, {165,003}	, "Análise Lim. Cr. "				,"@!"					,	,		,.F.	} }
        _nLinha:=165
        _nLinha+=15
		AADD(aC,{ "cMotRec",{_nLinha,003},"Motivo da Recusa"	  		     ,"@!",,,.F.})
        _nLinha+=15
		AADD(aC,{ "_cGData",{_nLinha,003},"Data de Aprovação do Gerente"     ,"@D",,,.F.})
		AADD(aC,{ "_cCData",{_nLinha,203},"Data de Aprovação do Coordenador" ,"@D",,,.F.})
        _nLinha+=15
		AADD(aC,{ "_cGHora",{_nLinha,003},"Hora de Aprovação do Gerente"     ,"@!",,,.F.})
		AADD(aC,{ "_cCHora",{_nLinha,203},"Hora de Aprovação do Coordenador" ,"@!",,,.F.})

//====================================================================================================
// Conteudo dos Campos
// aR[n,1] = Nome da Variavel Ex.:"cCliente"
// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aR[n,3] = Titulo do Campo
// aR[n,4] = Picture
// aR[n,5] = Validacao
// aR[n,6] = F3
// aR[n,7] = Se campo e' editavel .t. se nao .f.
//====================================================================================================
	aR := {}
	DBSELECTAREA("SZW")
	SZW->( DBSetOrder (1) )
	If SZW->( DBSeek( SubStr( TRBF->FILIAL , 1 , 2 ) + TRBF->NUMPED ) )

  	    cClassEnt:=POSICIONE("SA1",1,xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,"A1_I_CLABC")
		IF cClassEnt = '1'
		   cClassEnt:="1-TOP 1 NACIONAL"
		ELSEIF cClassEnt = '2'
		   cClassEnt:="2-TOP 5 Reg. SP"
		ELSEIF cClassEnt = '3'
		   cClassEnt:="3-TOP 5 Reg. RS"
		ENDIF

		cFli		:= LEFT(SubStr(TRBF->FILIAL,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(TRBF->FILIAL,1,2),1,""),25)
		cFilPro		:= SubStr(TRBF->FILPRO,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(TRBF->FILPRO,1,2),1,"")
		cTipPed		:= SUBSTR(TRBF->TIPO+" - "+GetAdvFVal("ZB4","ZB4_DESCRI",xFilial("ZB4")+TRBF->TIPO,1,""),1,25)
		cNumPed  	:= TRBF->NUMPED
		cCliente 	:= SZW->ZW_CLIENTE
		cLojaCli 	:= SZW->ZW_LOJACLI
		cNomCli 	:= GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,1,"")
		cGrpCli		:= GetAdvFVal("SA1","A1_GRPVEN",xFilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,1,"")+" - "+GetAdvFVal("SA1","A1_I_NGRPC",xFilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,1,"")
		cVend1	 	:= SZW->ZW_VEND1
		cNmVend1 	:= GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+SZW->ZW_VEND1,1,"")
		cTabelaPrc  := SZW->ZW_TABELA
		cDescTabela := GetAdvFVal("DA0","DA0_DESCRI",xFilial("DA0")+SZW->ZW_TABELA,1,"")
		nVTot 		:= nVTot
		cPedCli		:= SZW->ZW_PEDCLI
		ccond       := SZW->ZW_CONDPAG
		cHrEnt		:= SZW->ZW_HOREN
		cSha		:= SZW->ZW_SENHA
		cTipFre		:= IF(SZW->ZW_TPFRETE == 'C',SZW->ZW_TPFRETE+" - CIF",SZW->ZW_TPFRETE+" - FOB")
		_cchep 		:= posicione("SA1",1,XFILIAL("SA1")+ccliente+cLojaCli,"A1_I_CCHEP")
		cTipCar		:= IF( !empty(_cchep) , "1 - Paletizada" , "2 - Batida" )
		cQtdCha		:= SZW->ZW_CHAPA
		cHrDes		:= SZW->ZW_HORDES
		nCusDes		:= SZW->ZW_CUSDES
		cObsCom		:= SZW->ZW_OBSCOM
		cObsNF		:= SZW->ZW_MENNOTA
		cObsALC		:= SZW->ZW_OBSAVAC
		cMotRec	    := ALLTRIM(SZW->ZW_MOTREC)
		cMotRec	    := cMotRec+SPACE(200-LEN(cMotRec))
        _cGData     := SZW->ZW_I_DLIBG
        _cGHora     := SZW->ZW_I_HLIBG
        _cCData     := SZW->ZW_DATAAPR 
        _cCHora     := SZW->ZW_HORAAPR 

		//====================================================================================================
		// Array com as Coordenadas da Tela para o GetDados
		//====================================================================================================
		aCGD:={350,06,26,74}


		//====================================================================================================
		// Chamada da Modelo2
		//====================================================================================================
		lRetMod2 := Modelo2( cTitulo , aC , aR , aCGD , nOpcx ,,,,,, 9999 ,,, .T. )

	Else
		u_itmsg(  'Não foi possível posicionar no pedido!' , 'Atenção!',,1)
	EndIf

Return()


/*
===============================================================================================================================
Programa--------: AOMS1125
Autor-----------: Josué Danich Prestes
Data da Criacao-: 28/03/2018
===============================================================================================================================
Descrição-------: Retorna condição de pagamento do pedido de vendas
                  
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _ccond - Condição de pagamento do pedido de vendas
===============================================================================================================================
*/
Static Function AOMS1125()

 Local _ccond := ""
 M->C5_CONDPAG:=SZW->ZW_CONDPAG//USA ESSA VARIAVEL DENTRO DA FUNÇÃO u_IT_conpg()
 _ccond := u_IT_conpg(ALLTRIM(SZW->ZW_CLIENTE),ALLTRIM(SZW->ZW_LOJACLI),ALLTRIM(SZW->ZW_PRODUTO),.F.)
 //Se achou regra de condição de pagamento usa a regra, senão achou regra pega do szw
 If !empty(_ccond)
    _cCond:=_ccond+" - "+GetAdvFVal("SE4","E4_DESCRI",xFilial("SE4")+_ccond,1,"")
 Else
    _cCond:=SZW->ZW_CONDPAG+" - "+GetAdvFVal("SE4","E4_DESCRI",xFilial("SE4")+SZW->ZW_CONDPAG,1,"")
 Endif


Return _ccond

/*
===============================================================================================================================
Programa--------: AOMS112AT
Autor-----------: Erich Buttner
Data da Criacao-: 09/09/2010
===============================================================================================================================
Descrição-------: Função de alteração do Tp de pedido antes da efetivação
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112AT()

	Local cTitulo	:= "Alterar Pedidos Portal"
	Local lRetMod2  := .F. // Retorno da função Modelo2 - .T. Confirmou / .F. Cancelou
	Local nLinha	:= 0
	Local _nI , nColuna
	Local lMuda		:= .F.
	Local lFrete	:= .F.

	Private _nPosLocal, _nPosProd, _nPosItem

	nUsado	:= 0
	aHeader	:= {}
	aCols	:= {}
	cDescr	:= ""
	nQtd2UM	:= 0
	c2UM	:= ""
	nVlrTot	:= 0
	nVTot	:= 0

	_aButtons := {}
	AADD(_aButtons,{"Alt.Armazem",{|| U_AOMS112B(N,_nPosLocal,_nPosProd) },"Altera Armazem","Altera Armazem"})

	// Montagem do aHeader
	aHeader := {{ "Item"		  	, "ZW_ITEM"		, "@!"						, 010 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
                { "Produto"	  		, "ZW_PRODUTO"	, "@!"						, 015 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
                { "Descrição"	  	, "cDescr" 		, "@!"						, 020 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
                { "Qtd Ven 2 UM"  	, "nQtd2UM"		, "@e 999,999,999.99"	    , 014 , 2 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
                { "Segunda UM"	   	, "c2UM"		, "@!"						, 002 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
                { "Quantidade"		, "ZW_QTDVEN"	, "@e 999,999,999.99"	    , 014 , 2 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
                { "Unidade"		   	, "ZW_UM"		, "@!"						, 002 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
                { "Prc Unitario" 	, "ZW_PRCVEN"	, "@e 9,999,999.9999"	    , 014 , 4 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
                { "Vlr.Total "		, "nVlrTot"		, "@e 999,999,999.99"	    , 014 , 2 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
                { "Blq. Preço "		, "ZW_BLOPRC"	, "@!"						, 001 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
                { "Local "		    , "ZW_LOCAL"	, "@!"						, 002 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" } }

	cFlVer := SubStr( TRBF->FILIAL , 1 , 2 )

	_nPosLocal := Ascan(aHeader,{|x| x[2] = "ZW_LOCAL"})
	_nPosProd  := Ascan(aHeader,{|x| x[2] = "ZW_PRODUTO"})
	_nPosItem  := Ascan(aHeader,{|x| x[2] = "ZW_ITEM"})

//Locka registros
	If !( AOMS112LO( cFlVer, TRBF->NUMPED ) )
		Return
	Endif

	DBSELECTAREA("SZW")
	SZW->( DbSetOrder(1) )
	IF SZW->( DbSeek( cFlVer + TRBF->NUMPED ) )

		// Montagem do aCols
		While SZW->( !Eof() ) .AND. SZW->( ZW_FILIAL + ZW_IDPED ) == cFlVer + TRBF->NUMPED

			AADD( aCols , Array( Len(aHeader) + 1 ) )
			nLinha++

			cDescr		:= GetAdvFVal( "SB1" , "B1_I_DESCD"	, xFilial("SB1") + ALLTRIM( SZW->ZW_PRODUTO )	, 1 , "" )
			nFatConv	:= GetAdvFVal( "SB1" , "B1_CONV"	, xFilial("SB1") + SZW->ZW_PRODUTO				, 1 , "" )
			cTpConv		:= GetAdvFVal( "SB1" , "B1_TIPCONV"	, xFilial("SB1") + SZW->ZW_PRODUTO				, 1 , "" )
			nNewFat		:= GetAdvFVal( "SB1" , "B1_I_FATCO"	, xFilial("SB1") + SZW->ZW_PRODUTO				, 1 , "" )

			If cTpConv == "M"
				nQtd2UM	:= IIf( nFatConv == 0 , nNewFat * SZW->ZW_QTDVEN , nFatConv * SZW->ZW_QTDVEN )
			Else
				nQtd2UM	:= IIf( nFatConv == 0 , SZW->ZW_QTDVEN / nNewFat , SZW->ZW_QTDVEN / nFatConv )
			EndIf

			c2UM		:= GetAdvFVal( "SB1" , "B1_SEGUM" , xFilial("SB1") + ALLTRIM( SZW->ZW_PRODUTO ) , 1 , "" )
			nVlrTot		:= SZW->ZW_QTDVEN * SZW->ZW_PRCVEN
			nVtot		+= nVlrTot

			For nColuna := 1 to Len(aHeader)
				aCols[nLinha][nColuna] := &( aHeader[nColuna][2] )
			Next nColuna

			aCols[nLinha][Len(aHeader)+1] := .F. // Linha não deletada

			SZW->( DBSkip() )
		EndDo

		cFli		:= Space(20)
		cFilPro		:= Space(40)
		cTipPed		:= Space(15)
		cNumPed		:= Space(25)
		cCliente	:= Space(06)
		cNomCli		:= Space(60)
		cLojaCli	:= Space(04)
		cGrpCli		:= Space(30)
		cCond		:= Space(50)
		cVend1		:= Space(06)
		cNmVend1	:= Space(40)
		cVend2		:= Space(06)
		cNmVend2	:= Space(40)
		cPedCli		:= Space(09)
		dDtEnt		:= CtoD("")
		cTipoAg		:= Space(10)
		cHrEnt		:= Space(05)
		cSha		:= Space(14)
		cTipFre		:= Space(10)
		cTipCar		:= Space(15)
		cQtdCha		:= Space(03)
		cHrDes		:= Space(05)
		nCusDes		:= 0
	    cClassEnt	:= Space(20)
		cObsCom		:= Space(300)
		cObsNF		:= Space(300)
		cMotRec		:= Space(300)
		nDescFob	:= TRBF->DESCONTO

		DBSELECTAREA("SZW")
		SZW->( DBSetOrder(1) )
		SZW->( DbSeek( SubStr( TRBF->FILIAL , 1 , 2 ) + TRBF->NUMPED ) )

		dDtEnt		:= SZW->ZW_FECENT
		_laltera := .T.

		If SZW->ZW_I_AGEND == 'P'

			//cTipoAg		:= SZW->ZW_I_AGEND+" - AGUARD AGENDA"

			If month(date()) != 12

				dDtEnt := STOD(ALLTRIM(STR((YEAR(DATE())+1)))+"0101")-1

			Else

				dDtEnt := STOD(ALLTRIM(STR((YEAR(DATE())+2)))+"0101")-1

			Endif

			_laltera := .F.

		Endif

		If SZW->ZW_I_AGEND $ 'I/O'//I=Imediata //O=Agendada pelo Op.Log.

			_cFilCarreg := SZW->ZW_FILIAL
			If !EMPTY(SZW->ZW_FILPRO) .AND. !(ALLTRIM(SZW->ZW_FILPRO)=='0')
				_cFilCarreg := SZW->ZW_FILPRO
			EndIf

			//cTipoAg		:= SZW->ZW_I_AGEND+" - IMEDIATO"
			dDtEnt := DATE()+u_omsvldent(DATE(),SZW->ZW_CLIENTE,SZW->ZW_LOJACLI,SZW->ZW_FILIAL,TRBF->NUMPED,1,.F.,_cFilCarreg,SZW->ZW_TIPO,SZW->ZW_TPVENDA)
			_laltera := .F.

		Endif

		//If SZW->ZW_I_AGEND == 'M'
		//	cTipoAg		:= SZW->ZW_I_AGEND+" - AGENDADA COM MULTA"
		//Endif
		//If SZW->ZW_I_AGEND == 'A'
		//	cTipoAg		:= SZW->ZW_I_AGEND+" - AGENDADA"
		//Endif

        cTipoAg:=SZW->ZW_I_AGEND+" - "+(U_TipoEntrega(SZW->ZW_I_AGEND))
		
		DBSELECTAREA("SZW")
		SZW->( DBSetOrder(1) )
		SZW->( DbSeek( cFlVer + TRBF->NUMPED ) )

		lMuda := (SUBSTR(TRBF->TIPO,1,2) == "05")
		lFrete := TRBF->TPFRETE == "F"
		//====================================================================================================
		// aC[n,1] = Nome da Variavel Ex.:"cCliente"
		// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
		// aC[n,3] = Titulo do Campo
		// aC[n,4] = Picture
		// aC[n,5] = Validacao
		// aC[n,6] = F3
		// aC[n,7] = Se campo e' editavel .t. se nao .f.
		//====================================================================================================
		_cclirem := TRBF->CLIREM   //Depois da Mudança da Op Triangular de  05 para 42. Este campo agora é o cliente de faturamento.
		_clojrem := TRBF->LOJEN
		cTipPed	 := SUBSTR(TRBF->TIPO+" - "+GetAdvFVal("ZB4","ZB4_DESCRI",xFilial("ZB4")+TRBF->TIPO,1,""),1,25)

		_cVal1:=" U_AOM112Val('cFli') "
		_cVal2:=" U_AOM112Val('cFilPro') "
		_cVal3:=" U_AOM112Val('cTipPed',LEFT(cFilPro,2),LEFT(cFli,2)) "
		_cVal4:=" U_AOM112Val('DescBrowser')"
		_cVal5:=" U_AOM112Val('CLIENTE_VENDA')"

		aC := {	{ "cFli"	,{015,003} 	,"Filial                   "   		,"@!"   				,_cVal1,"LSTFAT",.T.},;
			{ "cFilPro"     ,{015,203} 	,"Filial Carregamento"	       	    ,"@!"   				,_cVal2,"ZLSTCA",.T.},;
			{ "cTipPed"		,{030,003} 	,"Tipo Pedido       " 	  			,"@!"   				,_cVal3,"ZB4"	,.T.},;
			{ "cNumPed"		,{030,203} 	,"Num. Pedido           " 			,"@!"   				,	,		,.F.	},;
			{ "cCliente"	,{045,003} 	,"Cliente/Remessa" 	 				,"@!"   				,   ,"SA1"	,.F.	},;
			{ "cLojaCli"	,{045,085} 	,"Loja   "							,"@!"   				,	,		,.F.	},;
			{ "cNomCli"		,{045,140} 	,"Nome Cliente/Remessa"				,"@!"   				,	,		,.F.	},;
			{ "cGrpCli"		,{060,003} 	,"Grupo Cliente/Rem."				,"@!"   				,	,		,.F.	},;
			{ "cCond"		,{060,285} 	,"Cond. Pagto" 						,"@!"   				,	,		,.F.	},;
			{ "cVend1"		,{075,003} 	,"Vendedor 1       "  				,"@!"   				,	,		,.F.	},;
			{ "cNmVend1"	,{075,140} 	,"Nome Vendedor 1" 					,"@!"   				,	,		,.F.	},;
			{ "nVTot"		,{075,500} 	,"Valor Total   " 					,"@e 999,999,999.99"	,	,		,.F.	},;
			{ "cVend2"		,{090,003} 	,"Vendedor 2       "  				,"@!"   				,	,		,.F.	},;
			{ "cNmVend2"	,{090,140} 	,"Nome Vendedor 2" 					,"@!"   				,	,		,.F.	},;
			{ "cPedCli"		,{105,003} 	,"Pedido Cliente/Remessa    "		,"@!"   				,	,		,.F.	},;
			{ "cTipoAg"		,{030,500}	,"Tipo Agendamento"					,"@!"   				,	,		,.F.	},;
			{ "dDtEnt"		,{015,500} 	,"Data Entrega          "			,"@!"   				,	,		,_laltera 	},;
			{ "cHrEnt"		,{105,245} 	,"Hora Entrega   "					,"@E 99:99 "   		    ,	,		,.T. 	},;
			{ "cSha"		,{105,325} 	,"Senha                "			,"@!"   				,	,		,.T.	},;
			{ "cTipFre"		,{105,500} 	,"Tipo Frete    "					,"@!"   				,	,		,.F.	},;
			{ "cTipCar"		,{120,003} 	,"Tipo de Carga     "				,"@!"   				,	,		,.F.	},;
			{ "cQtdCha"		,{120,140} 	,"Qtd. Chapa           "			,"@!"   				,	,		,.F.	},;
			{ "cHrDes"		,{120,245} 	,"Hora Descarga"					,"@!"   				,	,		,.F.	},;
			{ "nCusDes"		,{120,325} 	,"Custo Descarga"					,"@e 999,999,999.99"	,	,		,.F.	},;
		    { "cClassEnt"   ,{120,500}	,"Classif. Entrega"					,"@!"   				,	,		,.F.	},;
			{ "cObsCom"		,{135,003} 	,"Obs. Comercial  "					,"@!"					,	,		,.F.	},;
			{ "cTabelaPrc"	,{150,003} 	,"Cod. Tab. Prc    "				,"@!"					,	,		,.F.	},;
			{ "cDescTabela"	,{150,080} 	,"Desc. Tabela    "					,"@!"					,	,		,.F.	},;
			{ "cVECliente"	,{150,270} 	,"Cliente / Venda"	   			    ,"@!"					,_cVal5,"SA1",.T.	},;
			{ "cVELojaCli"	,{150,355} 	,"    "								,"@!"					,   ,		,.F.	},;
			{ "nDescFob"	,{150,430}	,"Desconto"							,"@e 999,999,999.99"	,_cVal4,	,lFrete } }

        _nLinha:=150
        _nLinha+=15
		AADD(aC,{ "cMotRec",{_nLinha,003},"Motivo da Recusa"       			 ,"@!",,,.F.})
        _nLinha+=15
		AADD(aC,{ "_cGData",{_nLinha,003},"Data de Aprovação do Gerente"     ,"@D",,,.F.})
		AADD(aC,{ "_cCData",{_nLinha,203},"Data de Aprovação do Coordenador" ,"@D",,,.F.})
        _nLinha+=15
		AADD(aC,{ "_cGHora",{_nLinha,003},"Hora de Aprovação do Gerente"     ,"@!",,,.F.})
		AADD(aC,{ "_cCHora",{_nLinha,203},"Hora de Aprovação do Coordenador" ,"@!",,,.F.})

		//AADD(aC,{ "_cGData",{165,003},"Data de Aprovação do Gerente"     ,"@D",,,.F.})
		//AADD(aC,{ "_cGHora",{180,003},"Hora de Aprovação do Gerente"     ,"@!",,,.F.})
		//AADD(aC,{ "_cCData",{165,203},"Data de Aprovação do Coordenador" ,"@D",,,.F.})
		//AADD(aC,{ "_cCHora",{180,203},"Hora de Aprovação do Coordenador" ,"@!",,,.F.})

		//====================================================================================================
		// Array com descricao dos campos do Rodape do Modelo 2
		// aR[n,1] = Nome da Variavel Ex.:"cCliente"
		// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
		// aR[n,3] = Titulo do Campo
		// aR[n,4] = Picture
		// aR[n,5] = Validacao
		// aR[n,6] = F3
		// aR[n,7] = Se campo e' editavel .t. se nao .f.
		//====================================================================================================
		aR := {}

  	    cClassEnt:=POSICIONE("SA1",1,xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,"A1_I_CLABC")
		IF cClassEnt = '1'
		   cClassEnt:="1-TOP 1 NACIONAL"
		ELSEIF cClassEnt = '2'
		   cClassEnt:="2-TOP 5 Reg. SP"
		ELSEIF cClassEnt = '3'
		   cClassEnt:="3-TOP 5 Reg. RS"
		ENDIF

		cFli		:= LEFT(SubStr(TRBF->FILIAL,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(TRBF->FILIAL,1,2),1,Space(20)),25)
		cFilPro		:= IF(!EMPTY(TRBF->FILPRO),SubStr(TRBF->FILPRO,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(TRBF->FILPRO,1,2),1,Space(35)),Space(35))
		cTipPed	    := SUBSTR(TRBF->TIPO+" - "+GetAdvFVal("ZB4","ZB4_DESCRI",xFilial("ZB4")+TRBF->TIPO,1,""),1,25)
		cNumPed  	:= TRBF->NUMPED
		cCliente 	:= SZW->ZW_CLIENTE
		cLojaCli 	:= SZW->ZW_LOJACLI
		cNomCli 	:= GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,1,"")
		cGrpCli		:= GetAdvFVal("SA1","A1_GRPVEN",xFilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,1,"")+" - "+GetAdvFVal("SA1","A1_I_NGRPC",xFilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,1,"")
		ccond       := AOMS1125()
		cVend1	 	:= SZW->ZW_VEND1
		cNmVend1 	:= GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+SZW->ZW_VEND1,1,"")
		cVend2   	:= SZW->ZW_VEND2
		cNmVend2 	:= GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+SZW->ZW_VEND2,1,"")
		nVTot 		:= nVTot
		cPedCli		:= SZW->ZW_PEDCLI
		dDtEnt		:= SZW->ZW_FECENT
		cHrEnt		:= SZW->ZW_HOREN
		cSha		:= SZW->ZW_SENHA
		cTipFre		:= IF(SZW->ZW_TPFRETE == 'C',SZW->ZW_TPFRETE+" - CIF",SZW->ZW_TPFRETE+" - FOB")
		_cchep 		:= posicione("SA1",1,XFILIAL("SA1")+ccliente+cLojaCli,"A1_I_CCHEP")
		cTipCar		:= IF( !empty(_cchep) , "1 - Paletizada" , "2 - Batida" )
		cQtdCha		:= SZW->ZW_CHAPA
		cHrDes		:= SZW->ZW_HORDES
		nCusDes		:= SZW->ZW_CUSDES
		cObsCom		:= SZW->ZW_OBSCOM
		cObsNF		:= SZW->ZW_MENNOTA
		cMotRec	    := ALLTRIM(SZW->ZW_MOTREC)
		cMotRec	    := cMotRec+SPACE(300-LEN(cMotRec))

		aCGD		:= { 350 , 06 , 26 , 74 } // Array com coordenadas da GetDados no modelo2

		cTabelaPrc	:= SZW->ZW_TABELA //aTabPrc[1]
		cDescTabela	:= ALLTRIM(POSICIONE("DA0",1,xFilial("DA0")+SZW->ZW_TABELA,"DA0_DESCRI"))
		cVECliente	:= SZW->ZW_CLIREM //Depois da Mudança da Op Triangular de  05 para 42. Este campo agora é o cliente de faturamento.
		cVELojaCli	:= TRBF->LOJEN
        _cGData     := SZW->ZW_I_DLIBG
        _cGHora     := SZW->ZW_I_HLIBG
        _cCData     := SZW->ZW_DATAAPR 
        _cCHora     := SZW->ZW_HORAAPR 

		//====================================================================================================
		// Chamada da Modelo2
		//====================================================================================================
		//( cTitulo , aC , aR , aGd  , nOp   ,cLinhaOk,cTudoOk ,aGetsD,bF4,cIniCpos,nMax,aCordW,lDelGetD,lMaximazed ] [ aButtons ] )
		lRetMod2 := Modelo2( cTitulo , aC , aR , aCGD , 6 ,        ,  , aR   ,   ,        ,9999,      ,        , .T. ,_aButtons)

		If lRetMod2

			_cUpudate:= "UPDATE SZW010 SET ZW_FILIAL = '"+ SubStr(cFli   ,1,2) +;
				"',ZW_FILPRO  = '"+ SubStr(cFilPro,1,2) +;
				"',ZW_TIPO    = '"+ SubStr(cTipPed,1,2) +;
				"',ZW_FECENT  = '"+ DtoS(dDtEnt) +;
				"',ZW_HOREN   = '"+ cHrEnt +;
				"',ZW_CLIREM  = '"+ cVECliente +; //Depois da Mudança da Op Triangular de  05 para 42. Este campo agora é o cliente de faturamento.
			    "',ZW_LOJEN   = '"+ cVELojaCli +;
				"',ZW_CLIENTE = '"+ cCliente+;
				"',ZW_LOJACLI = '"+ cLojaCli+;
				"',ZW_FOBDESC = '"+ Str(nDescFob,14,2)+;
            "',ZW_SENHA = '"+ cSha+;
				"' WHERE ZW_IDPED = '"+ cNumPed +;
				"' AND D_E_L_E_T_ = ' ' "
			_nRet:=TcSqlExec( _cUpudate )
			_nRet:=TcSqlExec( "COMMIT"  )

			TRBF->FILIAL   := ALLTRIM(SubStr(cFli,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(cFli,1,2),1,""))
			TRBF->FILPRO   := IF(!EMPTY(cFilPro),ALLTRIM(SubStr(cFilPro,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(cFilPro,1,2),1,"")),"")
			TRBF->RFILIAL  := ALLTRIM(SubStr(cFli,1,2))
			TRBF->TIPO     := cTipPed+" - "+GetAdvFVal("ZB4","ZB4_DESCRI",xFilial("ZB4")+cTipPed,1,"")
			TRBF->DT_ENTREG:= dtoc(dDtEnt)
			TRBF->HORAENTR := cHrEnt
			TRBF->CLIREM	:= cVECliente //Depois da Mudança da Op Triangular de  05 para 42. Este campo agora é o cliente de faturamento.
			TRBF->LOJEN		:= cVELojaCli
			TRBF->CODCLI    := cCliente
			TRBF->LOJA      := cLojaCli
			TRBF->DESCONTO	:= nDescFob

			//===============================================================================================
			// GRAVAÇÃO DOS DADOS DO ARMAZEM
			//===============================================================================================
			SZW->( DbSetOrder(1) ) // ZW_FILIAL+ZW_IDPED
			IF SZW->( DbSeek( cFlVer + TRBF->NUMPED ) )
				Do While !SZW->(Eof()) .And. SZW->(ZW_FILIAL+ZW_IDPED) == cFlVer + TRBF->NUMPED
					_nI := AsCan(aCols,{|x| x[_nPosItem] == SZW->ZW_ITEM})  // _nPosLocal // ZW_ITEM

					If _nI > 0
						SZW->(RecLock("SZW",.F.))
						SZW->ZW_LOCAL 	:= aCols[_nI,_nPosLocal]
						SZW->(MsUnlock())
					EndIf

					SZW->(DbSkip())
				EndDo
			EndIf
			_cCliRem	:= cVECliente
			_cLojRen	:= cVELojaCli

			omark:aArray[omark:NAT,A112MAP("Tipo")] := cTipPed
			omark:aArray[omark:NAT,A112MAP("Filial Faturamento")] := cFli
			omark:aArray[omark:NAT,A112MAP("Filial Carregamento")] := cFilPro
			omark:aArray[omark:NAT,A112MAP("Cliente/Remessa")] := TRBF->CODCLI + "/" + TRBF->LOJA + " - " + POSICIONE("SA1",1,xfilial("SA1")+ALLTRIM(TRBF->CODCLI)+ALLTRIM(TRBF->LOJA),"A1_NOME")

			If Empty(_cclirem)
				omark:aArray[omark:NAT,A112MAP("Cliente/Venda")] :=  "  "
			Else
				omark:aArray[omark:NAT,A112MAP("Cliente/Venda")] := TRBF->CLIREM + "/" + TRBF->LOJEN + " - " + POSICIONE("SA1",1,xfilial("SA1")+ALLTRIM(TRBF->CLIREM)+ALLTRIM(TRBF->LOJEN),"A1_NOME") //Depois da Mudança da Op Triangular de  05 para 42. Este campo agora é o cliente de faturamento.
			Endif

			omark:aArray[omark:NAT,A112MAP("Desconto")] := nDescFob
			omark:aArray[omark:NAT,A112MAP("Dt Entrega")] := dDtEnt

			omark:refresh()
		EndIf
	Else
		u_itmsg( 'Falha ao posicionar no pedido!' , 'Atenção!',,1 )
	EndIf

	AOMS112UN( cFlVer, TRBF->NUMPED)

	_nposi := TRBF->(Recno())
	TRBF->(Dbgoto(_nposi))
	TRBF->(Dbskip())
Return()

/*
===============================================================================================================================
Programa--------: AOMS112LO
Autor-----------: Josué Danich
Data da Criacao-: 25/11/2015
===============================================================================================================================
Descrição-------: Locka registros do pedido
===============================================================================================================================
Parametros------: _cfilAux - Filial do pedido
					_cnumped - Numero do pedido
===============================================================================================================================
Retorno---------: _lret - se conseguiu ou não lockar os registros do pedido
===============================================================================================================================
*/
Static Function AOMS112LO(_cFilAux,_cNumPed,_lMen)

	Local _lret := .T.
	Local _aarea := getarea()

	DEFAULT _lTela := !FWGetRunSchedule()
	DEFAULT _lMen := .T.
//=======================================================================================================================
//Bloqueia o pedido na pesquisa, para que não seja possivel enquanto esta rotina estiver sendo utilizada a sua alteracao	
//=======================================================================================================================	
DBSelectArea("SZW")
SZW->( DBSetOrder(1) )

If SZW->( DBSeek( _cFilAux + _cNumPed ) )

		While SZW->(!Eof()) .And. SZW->( ZW_FILIAL + ZW_IDPED ) == _cFilAux + _cNumPed .and. _lret


			If SZW->( DBRLock() )

				SZW->( MsUnlock())
				RecLock("SZW",.F.)
				SZW->( DbSkip() )

			Else
				If _lTela
					IF(_lMen,U_ItMsg( "Falha ao reservar o pedido, está em uso por outra estação" , "Atenção!" , ,1 ),)
				ENDIF
				_lret  := .F.

			Endif

		EndDo

Else

	If _lTela
	   IF(_lMen,u_itmsg( "Pedido não localizado na base de Dados: " + _cNumPed   , "Atenção!","Informar a área de TI/ERP" ,1 ),)
    ENDIF
	_lret := .F.

Endif

Restarea( _aarea)

Return _lret

/*
===============================================================================================================================
Programa----------: AOM112Val()
Autor-------------: Alex Wallauer
Data da Criacao---: 12/08/2016
===============================================================================================================================
Descrição---------: Funcao utilizada para verificar os campos da tela
===============================================================================================================================
Parametros--------: cCampo := Origem da chamada
===============================================================================================================================
Retorno-----------: Lógico
===============================================================================================================================
*/
User Function AOM112Val( cCampo , _cFil_Carr , _cFil_Fat )

	Local _lRet	:= .T.,cFilsFat
	Local _nne	:= 0
	DO CASE

	CASE cCampo == 'WHEN_IMPRIME'
		_lRet:=( LEFT(aarr[oMark:naT,A112MAP(SPACE(3))],4) == "1" )

	CASE cCampo == 'VAL_IMPRIME'

		If LEFT(M->IMPRIME,1) <> "2"
			U_ITMSG("Só permitido prencher com 2 = Não",'Atenção',,1)
			_lRet:= .F.
		ELSE

			M->IMPRIME:="2-NÃO"

			TRBF->(Dbgoto(aarr[OMARK:NAT,LEN(aarr[OMARK:NAT])]))
			TRBF->( RecLock( "TRBF" , .F. ) )
			TRBF->IMPRIME:=M->IMPRIME
			TRBF->( MsUnlock() )

			aarr[oMark:naT,A112MAP(SPACE(3))]:=M->IMPRIME//Tem que atualizar o aarr Tb

			_nRet:=TcSqlExec( "UPDATE SZW010 SET ZW_IMPRIME = '2' " +;
				" WHERE ZW_IDPED = '"+ aarr[oMark:naT,A112MAP("Id Pedido")] +;
				"' AND D_E_L_E_T_ = ' ' ")
			_nRet:=TcSqlExec( "COMMIT" )

		ENDIF

	CASE cCampo == 'CLIENTE_VENDA'

		If ALLTRIM(SZW->ZW_CLIREM) == ALLTRIM(cVECliente)
			Return .T.
		Endif

		If Empty(cVECliente) .AND. LEFT(cTipPed,2) $ _cOperTriangular
			U_ITMSG("Cliente / Venda nao preenchida",'Atenção',,1)
			_lRet:= .F.
		ELSEIf !Empty(cVECliente) .AND. !LEFT(cTipPed,2) $ _cOperTriangular
			U_ITMSG("Cliente / Venda nao pode ser preenchido",'Atenção',,1)
   		cVELojaCli:=SPACE( LEN(SZW->ZW_LOJEN) )
			_lRet:= .F.
		ENDIF

		SA1->(DBSETORDER(1))
		If _lRet .AND. !(SA1->(DBSEEK(xfilial("SA1")+cVECliente+cVELojaCli)))
			u_itmsg("Cliente / Venda  não localizado no cadastro","Atenção",,1)
			_lRet := .F.
		Elseif _lRet .AND. SA1->A1_MSBLQL = '1'
			U_ITMSG("Cliente / Venda  bloqueado","Atenção",,1)
			_lRet := .F.
			//Não pode escolher mesmo cliente do pedido para remessa
		ELSEIf !EMPTY(cVECliente) .and. ALLTRIM(cVECliente)+ALLTRIM(cVELojaCli) == ALLTRIM(cCliente)+ALLTRIM(cLojaCli)
			u_itmsg("Não é permitido escolher mesmo Cliente/Remessa do pedido para remessa","Atenção",,1)
			_lret := .F.
		Endif

	CASE cCampo == 'cFli'//Filial de Faturamento

		If ALLTRIM(substr(cfli,1,2)) == ALLTRIM(SZW->ZW_FILIAL)
			cfli:= SubStr(cfli,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(cfli,1,2),1,"")
			Return .T.
		Endif

		If Empty(cFli)
			U_ITMSG("Filial nao preenchida",'Atenção',,1)
			_lRet:= .F.
		ELSE
			cFliDesc:=GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(cFli,1,2),1,"")

			IF EMPTY(cFliDesc)
				U_ITMSG("Filial nao cadastrada",'Atenção',,1)
				RETURN .F.
			ENDIF

			cFli:=SubStr(cFli,1,2)+" - "+cFliDesc

			_cFilSalva:= cFilAnt
			cFilAnt   := cFli
			If ALLTRIM(U_ITGETMV( "IT_FATNF" , "N")) == "N"
				cFilPro:= Space(02)
			ENDIF
			cFilAnt := _cFilSalva

			IF !EMPTY(cFilPro)               //Fil Carregamento Fil Faturamento
				RETURN U_AOM112Val( 'VAL_GRUPO' , LEFT(cFilPro,2) , LEFT(cFli,2) )
			ENDIF

		ENDIF

		If _lret

			//Atualiza armazéns
			SBZ->(Dbsetorder(1)) //BZ_FILIAL+BZ_COD

			For _nne := 1 to len(acols)

				_carmi := posicione("SB1",1,xfilial("SB1")+acols[_nne][2],"B1_LOCPAD")

				If empty(SubStr(cFilPro,1,2))

					_cfili := LEFT(cFli,2)

				Else

					_cfili := SubStr(cFilPro,1,2)

				Endif

				If SBZ->(Dbseek(_cfili+acols[_nne][2]))

					_carmi := SBZ->BZ_LOCPAD

				Endif

				if ALLTRIM(_carmi) != ALLTRIM(acols[_nne][11])

					acols[_nne][11] := ALLTRIM(_carmi)
					xObj := CallMod2Obj()
					xObj:oBrowse:Refresh()

				Endif

			Next

		Endif

	CASE cCampo == 'cFilPro'

		If ALLTRIM(substr(cFilPro,1,2)) == ALLTRIM(SZW->ZW_FILPRO)
			cFilPro:= SubStr(cFilPro,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(cFilPro,1,2),1,"")
			Return .T.
		Endif

		If !EMPTY(cFilPro)//Filial de Carregamento

			cFilDes:= GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(cFilPro,1,2),1,"")
			IF EMPTY(cFilDes)
				U_ITMSG("Filial nao cadastrada",'Atenção',,1)
				RETURN .F.
			ENDIF
			cFilPro:= SubStr(cFilPro,1,2)+" - "+cFilDes

			_cFilSalva:= cFilAnt
			cFilAnt   := LEFT(cFli,2)
			If ALLTRIM(U_ITGETMV( "IT_FATNF" , "N")) == "N"
				U_ITMSG("Filial do Pedido nao é troca nota: "+cFli,'Atenção',,1)
				_lRet	:= .F.
			ENDIF

			cFilAnt:=LEFT(cFilPro,2)
			If ALLTRIM(U_ITGETMV( "IT_PRONF" , "N")) == "N"
				U_ITMSG("Filial de Carregamento do Pedido seleciona nao é troca nota: "+cFilPro,'Atenção',,1)
				_lRet	:= .F.
			ENDIF
			cFilAnt := _cFilSalva

			IF _lRet                         //Fil Carregamento Fil Faturamento
				_lRet:=U_AOM112Val( 'VAL_GRUPO' , LEFT(cFilPro,2) , LEFT(cFli,2) )
			ENDIF


		Endif

		If _lret

			//Atualiza armazéns
			SBZ->(Dbsetorder(1)) //BZ_FILIAL+BZ_COD

			For _nne := 1 to len(acols)

				_carmi := posicione("SB1",1,xfilial("SB1")+acols[_nne][2],"B1_LOCPAD")

				If empty(SubStr(cFilPro,1,2))

					_cfili := LEFT(cFli,2)

				Else

					_cfili := SubStr(cFilPro,1,2)

				Endif

				If SBZ->(Dbseek(_cfili+acols[_nne][2]))

					_carmi := SBZ->BZ_LOCPAD

				Endif

				if ALLTRIM(_carmi) != ALLTRIM(acols[_nne][11])

					acols[_nne][11] := ALLTRIM(_carmi)
					xObj := CallMod2Obj()
					xObj:oBrowse:Refresh()

				Endif

			Next

		Endif


	CASE cCampo == 'cTipPed'

		If Empty(cTipPed)
			U_ITMSG("Tipo nao preenchida",'Atenção',,1)
			_lRet:= .F.
		ELSE

			cTipPeDesc:=GetAdvFVal("ZB4","ZB4_DESCRI",xFilial("ZB4")+LEFT(cTipPed,2),1,"")
			IF EMPTY(cTipPeDesc)
				U_ITMSG("Tipo nao cadastrado",'Atenção',,1)
				RETURN .F.
			ENDIF
			cTipPed:=LEFT(cTipPed,2)+" - "+cTipPeDesc

			IF cTipPed = _cOperRemessa// Tratamento da Operação Triangular
				U_ITMSG("Código do Tipo não pode ser "+_cOperRemessa,"Atenção!","Selecione um tipo diferente de "+_cOperRemessa,1)
				RETURN .F.
			ELSEIF ALLTRIM(cTipPed)  = _cOperFat .AND. !EMPTY(_cFil_Carr) .AND. _cFil_Carr <> _cFil_Fat//TROCA NOTA
				U_ITMSG("Pedidos de operação triangular "+_cOperTriangular+", não podem ser troca nota","Atenção!","Altere para o pedido não ser troca nota ou o tipo da operação não ser "+_cOperFat,1)
				RETURN .F.
			ENDIF

			IF !LEFT(cTipPed,2) $ _cOperTriangular
				cVECliente:=SPACE( LEN(SZW->ZW_CLIREM))
				cVELojaCli:=SPACE( LEN(SZW->ZW_LOJEN) )
			ELSEIF EMPTY(cVECliente)
				cVECliente:= SZW->ZW_CLIREM
				cVELojaCli:= SZW->ZW_LOJEN
			ENDIF

		ENDIF

	CASE cCampo == 'FilProBrowse'//Filial de Carregamento

		IF !EMPTY(aarr[oMark:nat,A112MAP("Filial Carregamento")])

			cFilDes:= GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+LEFT(aarr[oMark:nat,A112MAP("Filial Carregamento")],2),1,"")
			IF EMPTY(cFilDes)
				U_ITMSG("Filial nao cadastrada",'Atenção',,1)
				RETURN .F.
			ENDIF

			_cFilSalva:= cFilAnt
			cFilAnt   := LEFT(ALLTRIM(aarr[oMark:naT,A112MAP("Filial Faturamento")]),2)//Pega a Filial de Faturamento na sexta coluna
			If ALLTRIM(U_ITGETMV( "IT_FATNF" , "N")) == "N"
				U_ITMSG("Filial "+ALLTRIM(aarr[oMark:naT,A112MAP("Impresso")])+" nao é troca nota de Faturamento (IT_FATNF)",'Atenção',,1)
				_lRet:= .F.
			ENDIF

			cFilAnt:=LEFT(aarr[oMark:nat,A112MAP("Filial Carregamento")],2)
			If ALLTRIM(U_ITGETMV( "IT_PRONF" , "N")) == "N"
				U_ITMSG("Filial "+ALLTRIM(M->FILPRO)+" nao é troca nota de Carregamento (IT_PRONF)",'Atenção',,1)
				_lRet:= .F.
			ENDIF
			cFilAnt  := _cFilSalva

			IF _lRet                             //Fil Carregamento, Fil Faturamento
				_lRet:=U_AOM112Val( 'VAL_GRUPO' , LEFT(aarr[oMark:nat,A112MAP("Filial Carregamento")],2) , LEFT(aarr[oMark:naT,A112MAP("Filial Faturamento")],2) )
			ENDIF

			aarr[oMark:nat,A112MAP("Filial Carregamento")]:= LEFT(LEFT(aarr[oMark:nat,A112MAP("Filial Carregamento")],2)+" - "+cFilDes,40)

		ENDIF

		IF _lRet

			TRBF->(Dbgoto(aarr[OMARK:NAT,LEN(aarr[OMARK:NAT])]))
			TRBF->FILPRO:=aarr[oMark:nat,A112MAP("Filial Carregamento")]

			_nRet:=TcSqlExec( "UPDATE SZW010 SET ZW_FILPRO = '"+ SubStr(aarr[oMark:nat,A112MAP("Filial Carregamento")],1,2) +;
				"' WHERE ZW_IDPED = '"+ ALLTRIM(aarr[oMark:naT,A112MAP("Id Pedido")]) +;
				"' AND D_E_L_E_T_ = ' ' ")
			_nRet:=TcSqlExec( "COMMIT" )

			//Atualiza armazéns conforme filial de faturamento e carregamento
			SBZ->(Dbsetorder(1)) //BZ_FILIAL+BZ_COD
			SZW->(Dbsetorder(1)) //ZW_FILIAL+ZW_IDPED
			SZW->(Dbseek(substr(aarr[oMark:naT,A112MAP("Filial Faturamento")],1,2)+ALLTRIM(aarr[oMark:naT,A112MAP("Id Pedido")])))

			Do while SZW->ZW_FILIAL == substr(aarr[oMark:naT,A112MAP("Filial Faturamento")],1,2) .AND. ALLTRIM(SZW->ZW_IDPED) = ALLTRIM(aarr[oMark:naT,A112MAP("Id Pedido")])

				_carmi := posicione("SB1",1,xfilial("SB1")+SZW->ZW_PRODUTO,"B1_LOCPAD")

				If empty(SubStr(aarr[oMark:nat,A112MAP("Filial Carregamento")],1,2))

					_cfili := substr(aarr[oMark:naT,A112MAP("Filial Faturamento")],1,2)

				Else

					_cfili := SubStr(aarr[oMark:nat,A112MAP("Filial Carregamento")],1,2)

				Endif

				If SBZ->(Dbseek(_cfili+SZW->ZW_PRODUTO))

					_carmi := SBZ->BZ_LOCPAD

				Endif

				If ALLTRIM(_carmi) != ALLTRIM(SZW->ZW_LOCAL)

					Reclock("SZW", .F.)
					SZW->ZW_LOCAL := _carmi
					SZW->(Msunlock())

				Endif

				SZW->(Dbskip())

			Enddo

		ENDIF

	CASE cCampo == 'FilFatBrowse'//Filial de Faturamento

		IF !EMPTY(aarr[oMark:nat,A112MAP("Filial Faturamento")]) //"FILIAL"

			cFilDes:= GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+LEFT(aarr[oMark:nat,A112MAP("Filial Faturamento")],2),1,"")
			IF EMPTY(cFilDes)
				U_ITMSG("Filial nao cadastrada",'Atenção',,1)
				RETURN .F.
			ENDIF

			IF !EMPTY(LEFT(aarr[oMark:naT,A112MAP("Filial Carregamento")],2))//Se preenchida a Filial de Carregamento na quarta coluna faz as valdações
				_cFilSalva:= cFilAnt

				cFilAnt:=LEFT(aarr[oMark:nat,A112MAP("Filial Faturamento")],2)
				If ALLTRIM(U_ITGETMV("IT_FATNF","N")) == "N" //Se tá preenchida a coluna de Carregamento essa filial tem que ser TN de Faturamento
               U_ITMSG("Filial "+ALLTRIM(aarr[oMark:nat,A112MAP("Filial Faturamento")])+" nao é Troca Nota de Faturamento (IT_FATNF)",'Atenção',,1)
					_lRet:= .F.
				ENDIF

				//Se tá preenchida a coluna de Carregamento essa filial tem que ser do grupo dela
				IF _lRet                                  //Fil Carregamento        Fil Faturamento
					_lRet:=U_AOM112Val( 'VAL_GRUPO' , LEFT(aarr[oMark:naT,A112MAP("Filial Carregamento")],2)  , LEFT(aarr[oMark:nat,A112MAP("Filial Faturamento")],2) )
				ENDIF


			ENDIF

			aarr[oMark:nat,A112MAP("Filial Faturamento")]:= LEFT(LEFT(aarr[oMark:nat,A112MAP("Filial Faturamento")],2)+" - "+cFilDes,40)

		ELSE
			U_ITMSG("Filial de Faturamento nao Preenchida",'Atenção',,1)
			RETURN .F.

		ENDIF

		TRBF->(Dbgoto(aarr[OMARK:NAT,LEN(aarr[OMARK:NAT])]))
		TRBF->( RecLock( "TRBF" , .F. ) )
		TRBF->FILIAL:=aarr[oMark:nat,A112MAP("Filial Faturamento")]    //M->FILIAL
		TRBF->( MsUnlock() )

		_nRet:=TcSqlExec( "UPDATE SZW010 SET ZW_FILIAL = '"+ SubStr(aarr[oMark:nat,A112MAP("Filial Faturamento")],1,2) +;
			"' WHERE ZW_IDPED = '"+ ALLTRIM(aarr[oMark:naT,A112MAP("Id Pedido")]) +;
			"' AND D_E_L_E_T_ = ' ' " )
		_nRet:=TcSqlExec( "COMMIT" )

		//Atualiza armazéns conforme filial de faturamento e carregamento
		SBZ->(Dbsetorder(1)) //BZ_FILIAL+BZ_COD
		SZW->(Dbsetorder(1)) //ZW_FILIAL+ZW_IDPED
		SZW->(Dbseek(SubStr(aarr[oMark:nat,A112MAP("Filial Faturamento")],1,2)+aarr[oMark:naT,A112MAP("Filial Faturamento")]))

		Do while SZW->ZW_FILIAL == SubStr(aarr[oMark:nat,A112MAP("Filial Faturamento")],1,2) .AND. ALLTRIM(SZW->ZW_IDPED) = ALLTRIM(aarr[oMark:naT,A112MAP("Filial Faturamento")])

			_carmi := posicione("SB1",1,xfilial("SB1")+SZW->ZW_PRODUTO,"B1_LOCPAD")

			If SBZ->(Dbseek(SubStr(aarr[oMark:nat,A112MAP("Filial Faturamento")],1,2)+SZW->ZW_PRODUTO))

				_carmi := SBZ->BZ_LOCPAD

			Endif

			If ALLTRIM(_carmi) != ALLTRIM(SZW->ZW_LOCAL)

				Reclock("SZW", .F.)
				SZW->ZW_LOCAL := _carmi
				SZW->(Msunlock())

			Endif

			SZW->(Dbskip())

		Enddo


	CASE cCampo == "DescBrowser" //DESCONTO
		TRBF->(Dbgoto(aarr[OMARK:NAT,LEN(aarr[OMARK:NAT])]))
		If Type("nDescFob") == "N"
			IF nDescFob > TRBF->VALOR
				U_ITMSG("O valor do desconto não pode ser maior que o valor do pedido.",'Atenção',,1)
				nDescFob := TRBF->DESCONTO
				RETURN .F.
			ELSE
				RETURN .T.
			ENDIF
		ENDIF

		IF AARR[oMark:Nat][A112MAP("Desconto")] < AARR[oMark:Nat][A112MAP("Valor Pedido")]

			TRBF->( RecLock( "TRBF" , .F. ) )
			TRBF->DESCONTO := AARR[oMark:Nat][A112MAP("Desconto")]
			TRBF->( MsUnlock() )

			_nRet:=TcSqlExec( "UPDATE SZW010 SET ZW_FOBDESC = "+Str(AARR[oMark:Nat][A112MAP("Desconto")],14,2)+" " +;
				" WHERE ZW_IDPED = '"+ aarr[oMark:naT,A112MAP("Id Pedido")] +;
				"' AND D_E_L_E_T_ = ' ' ")
			_nRet:=TcSqlExec( "COMMIT" )
			RETURN .T.
		ELSE
			U_ITMSG("O valor do desconto não pode ser maior que o valor do pedido.",'Atenção',,1)
			RETURN .F.
		ENDIF


	CASE cCampo == 'VAL_GRUPO'

		IF _cFil_Carr == _cFil_Fat
			//U_ITMSG("Filiais nao podem serem iguais",'Atenção',,1)
			RETURN .T.
		ENDIF

		cFilsFat:= ALLTRIM(GetAdvFVal("ZZM","ZZM_FILFAT",xFilial("ZZM")+_cFil_Carr,1,""))
		IF EMPTY(cFilsFat)//Testa se a filial de faturamento esta no grupo do campo ZZM

			u_itmsg("Filial de Carregamento: "+_cFil_Carr+" não possui grupo de Filiais de Faturamento",;
				"Validação de filial","Entre em contato com a area de TI para cadastrar novas filiais no grupo no Configurador Italac \ Usuários \ Cad Filiais.",1)

			RETURN .F.
		ELSEIF !(_cFil_Fat $ cFilsFat)//Testa se a filial de faturamento esta no grupo do campo ZZM

			u_itmsg("Filial de Faturamento "+_cFil_Fat+" nao esta no grupo de filiais ("+cFilsFat+") da Filial de Carregamento: "+_cFil_Carr,;
				"Validação de filial","Entre em contato com a area de TI para cadastrar novas filiais no grupo no Configurador Italac \ Usuários \ Cad Filiais.",1)

			RETURN .F.
		ENDIF

	CASE cCampo == 'TipoBrowse'

		cTipPed:=LEFT(aarr[oMark:nat,A112MAP("Tipo")],2)
		TRBF->(Dbgoto(aarr[OMARK:NAT,LEN(aarr[OMARK:NAT])]))

		If ALLTRIM(TRBF->TIPO) == ALLTRIM(SUBSTR(cTipPed,1,2))
			aarr[oMark:nat,A112MAP("Tipo")]:= LEFT(cTipPed,2)+" - "+GetAdvFVal("ZB4","ZB4_DESCRI",xFilial("ZB4")+LEFT(cTipPed,2),1,"")
			Return .T.
		Endif

		If Empty(cTipPed)
			U_ITMSG("Tipo nao preenchida",'Atenção',,1)
			Return .F.

		ELSE//IF !EMPTY(cTipPed)

			cTipPeDesc:=GetAdvFVal("ZB4","ZB4_DESCRI",xFilial("ZB4")+cTipPed,1,"")
			IF EMPTY(cTipPeDesc)
				U_ITMSG("Tipo Operação nao cadastrada",'Atenção',,1)
				RETURN .F.
			ENDIF
			cTipPed := cTipPed+" - "+cTipPeDesc

			IF cTipPed = _cOperRemessa// Tratamento da Operação Triangular (42)
				U_ITMSG("Código do Tipo não pode ser "+_cOperRemessa,"Atenção!","Selecione um tipo diferente de "+_cOperRemessa,1)
				RETURN .F.
			ELSEIF ALLTRIM(cTipPed)  = _cOperFat .AND. !EMPTY(LEFT(TRBF->FILPRO,2)) .AND. LEFT(TRBF->FILPRO,2) <> LEFT(TRBF->FILIAL,2)//TROCA NOTA
				U_ITMSG("Pedidos de operação triangular "+_cOperTriangular+", não podem ser troca nota","Atenção!","Altere para o pedido não ser troca nota ou o tipo da operação não ser "+_cOperFat,1)
				RETURN .F.
			ENDIF

			aarr[oMark:nat,A112MAP("Tipo")]:= cTipPed
			IF !LEFT(cTipPed,2) $ _cOperTriangular
				aArr[oMark:nat,A112MAP("Cliente/Venda")]:= SPACE( 100 )
			ENDIF

		ENDIF

		IF _lRet

			TRBF->(Dbgoto(aarr[OMARK:NAT,LEN(aarr[OMARK:NAT])]))
			TRBF->TIPO:=cTipPed
			IF !LEFT(cTipPed,2) $ _cOperTriangular
				TRBF->CLIREM:= SPACE( LEN(SZW->ZW_CLIREM))
				TRBF->LOJEN := SPACE( LEN(SZW->ZW_LOJEN))
			ENDIF

			_cQueryAtu:="UPDATE SZW010 SET ZW_TIPO = '"+ LEFT(cTipPed,2) +"' "
			IF !LEFT(cTipPed,2) $ _cOperTriangular
				_cQueryAtu+=" ,ZW_CLIREM  = '"+SPACE( LEN(SZW->ZW_CLIREM))+"' "
				_cQueryAtu+=" ,ZW_LOJEN   = '"+SPACE( LEN(SZW->ZW_LOJEN)) +"' "
			ENDIF
			_cQueryAtu+=" WHERE ZW_IDPED = '"+ ALLTRIM(aarr[oMark:naT,A112MAP("Id Pedido")]) +"' "
			_cQueryAtu+=" AND D_E_L_E_T_ = ' ' "
			_nRet:=TcSqlExec( _cQueryAtu )
			_nRet:=TcSqlExec( "COMMIT" )

		ENDIF

	ENDCASE

Return( _lRet )

/*
===============================================================================================================================
Programa--------: AOMS112UN
Autor-----------: Josué Danich
Data da Criacao-: 25/11/2015
===============================================================================================================================
Descrição-------: UnLocka registros do pedido
===============================================================================================================================
Parametros------: _cfilAux - Filial do pedido
					_cnumped - Numero do pedido
===============================================================================================================================
Retorno---------: _lret - se conseguiu ou não lockar os registros do pedido
===============================================================================================================================
*/
Static Function AOMS112UN(_cFilAux,_cNumPed)

	Local _aarea := getarea("SZW")


	DBSelectArea("SZW")
	SZW->( DBSetOrder(1) )

	If SZW->( DBSeek( _cFilAux + _cNumPed ) )

		While SZW->(!Eof()) .And. SZW->( ZW_FILIAL + ZW_IDPED ) == _cFilAux + _cNumPed


			SZW->( MsUnlock())
			SZW->( DbSkip() )

		EndDo

	Endif

	Restarea( _aarea)

Return

/*
===============================================================================================================================
Programa--------: AOMS112IM
Autor-----------: Erich Buttner
Data da Criacao-: 09/09/2010
===============================================================================================================================
Descrição-------: Função que chama a impressão e controla a atualização do status de impresso
===============================================================================================================================
Parametros------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112IM(oproc)

	Local _nposi := TRBF->(Recno())
	Private _aPed			:= {}
	Private _nRadMnu1    := 1

	TRBF->( DBGoTop() )

//================================================================================
//Imprime todos os pedidos selecionados
//================================================================================
	Do While TRBF->(!EOF())

		//================================================================================
		// Somente pedidos selecionados pelo usuario
		//================================================================================
		If (TRBF->OK == cmarca .and. !linverte) .or. (TRBF->OK != cmarca .and. linverte)

			SZW->(Dbsetorder(1))
			If SZW->(Dbseek(substr(TRBF->FILIAL,1,2)+TRBF->NUMPED))
				aadd(_aped,{ALLTRIM(SZW->ZW_FILIAL) ,ALLTRIM(SZW->ZW_IDPED) , ALLTRIM(SZW->ZW_CLIENTE) , ALLTRIM(SZW->ZW_LOJACLI) ,  SZW->ZW_VEND1 })

				TRBF->( Reclock( "TRBF", .F. ) )
				TRBF->IMPRIME := '1-SIM'
				TRBF->( MsUnlock() )

				//aarr[ascan(aarr,{|x| x[21] == TRBF->(Recno())}),04] := '1-SIM'
				aarr[ascan(aarr,{|x| x[Len(x)] == TRBF->(Recno())}),04] := '1-SIM'

				SZW->( Reclock( "SZW", .F. ) )
				SZW->ZW_IMPRIME := '1'
				SZW->( MsUnlock() )

			Endif

		Endif

		TRBF->(DBSKIP())

	Enddo

	If len(_aped) = 0

		//Imprime somente pedido posicionado
		TRBF->(Dbgoto(_nposi))
		SZW->(Dbsetorder(1))
		If SZW->(Dbseek(substr(TRBF->FILIAL,1,2)+TRBF->NUMPED))

			_aPed			:= {{ALLTRIM(SZW->ZW_FILIAL) ,ALLTRIM(SZW->ZW_IDPED) , ALLTRIM(SZW->ZW_CLIENTE) , ALLTRIM(SZW->ZW_LOJACLI) ,  SZW->ZW_VEND1 }}

			U_ROMS035R(oproc)

			TRBF->(Dbgoto(_nposi))
			TRBF->( Reclock( "TRBF", .F. ) )
			TRBF->IMPRIME := '1-SIM'
			TRBF->( MsUnlock() )

			aarr[ascan(aarr,{|x| x[Len(x)] == TRBF->(Recno())}),04] := '1-SIM'

			SZW->( Reclock( "SZW", .F. ) )
			SZW->ZW_IMPRIME := '1'
			SZW->( MsUnlock() )

		Endif

	Else

		U_ROMS035R(oproc)

	Endif

//Atualiza tela
//	fwmsgrun(,{|| AOMS112arq(oproc)},"1 - Aguarde...","Atualizando tela...")

//	omark:setarray(aarr)
	omark:refresh()
	ProcessMessages()

//Retorna browse ao pedidos posicionado
	TRBF->(Dbgoto(_nposi))

Return()

/*
===============================================================================================================================
Programa--------: AOMS112LEG
Autor-----------: Erich Buttner
Data da Criacao-: 09/09/2010
===============================================================================================================================
Descrição-------: Exibe a tela de detalhes da legenda
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112LEG()

	Local cCadastro := OemToAnsi( "Pedidos do Portal" )

	BrwLegenda( cCadastro   , "Legenda" ,;
		{{"BR_VERMELHO"     , "Pedido aguardando  Efetivação" 		} ,;
		{ "BR_PRETO"        , "Pedido com Preço   Bloqueado" 		} ,;
		{ "BR_VIOLETA"      , "Pedido com Preço   Rejeitado" 		} ,;
		{ "ENABLE"          , "Pedido com Preço   Liberado"  		} ,;
		{ "BR_AZUL"         , "Pedido com Crédito Bloqueado" 		} ,;
		{ "BR_LARANJA"      , "Pedido com Crédito Rejeitado" 		} ,;
		{ "BR_MARRON_OCEAN" , "Pedido Bonificação Bloqueado" 		} ,;
		{ "BR_MARRON"       , "Pedido Bonificação Rejeitado" 		} ,;
		{ "BR_AMARELO"      , "Pendente Aprov. Preço P/Coordenador"	} ,;
		{ "BR_VERDE_ESCURO" , "Pendente Aprov. Preço P/Gerente"		} ,;
		{ "BR_CANCEL"       , "Pedido com Cliente/Remessa Bloqueado"} })

Return(.T.)

/*
===============================================================================================================================
Programa----------: AOMS112EC()
Autor-------------: Josué Danich Prestes
Data da Criacao---: 11/03/2019
===============================================================================================================================
Descrição---------: Exporta browse para o excel
===============================================================================================================================
Parametros--------: oproc - objeto de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112EC(oproc)

	Local _acolec := {}
	Local _aheaderec := {}
	Local _nnh		:= 0
	//Monta aheader
	aadd(_aheaderec,"Impresso")             //01
	aadd(_aheaderec,"Dias/Horas Pendentes") //02
	aadd(_aheaderec,"Filial Faturamento" )  //03
	aadd(_aheaderec,"Filial Carregamento")  //04
	aadd(_aheaderec,"Id Pedido")            //05
	aadd(_aheaderec,"Tipo")                 //06
	aadd(_aheaderec,"Cliente/Venda"  )      //07
	aadd(_aheaderec,"Cliente/Remessa")      //08
	aadd(_aheaderec,"Valor do Pedido")      //09
	aadd(_aheaderec,"Tipo Entrega")         //10
	aadd(_aheaderec,"Dt Entrega")           //11
	aadd(_aheaderec,"Tipo Frete")           //12
	aadd(_aheaderec,"Peso Bruto")           //13
	aadd(_aheaderec,"Desconto")             //14
	aadd(_aheaderec,"Obs")                  //15
	aadd(_aheaderec,"Mens NF")              //16
	aadd(_aheaderec,"Classificacao Entrega")//17

	//Monta acols
	For _nnh := 1 to len(aarr)

		If aarr[_nnh][1] == cmarca .OR. MV_PAR23 = 1 //SÓ REJEITADOS

           TRBF->(DBGOTO(aarr[_nnh,LEN(aarr[_nnh])]))

  	       cClassEnt:=POSICIONE("SA1",1,xfilial("SA1")+TRBF->CODCLI+TRBF->LOJA,"A1_I_CLABC")
		   IF cClassEnt = '1'
		      cClassEnt:="1-TOP 1 NACIONAL"
		   ELSEIF cClassEnt = '2'
		      cClassEnt:="2-TOP 5 Reg. SP "
		   ELSEIF cClassEnt = '3'
		      cClassEnt:="3-TOP 5 Reg. RS "
		   ENDIF

			aadd(_acolec,;
				{ALLTRIM(TRBF->IMPRIME),;//01
				 ALLTRIM(TRBF->TEMPOPEND),;//02
				 aarr[_nnh,A112MAP("Filial Faturamento" )],;//03
				 aarr[_nnh,A112MAP("Filial Carregamento")],;//04
				 ALLTRIM(TRBF->NUMPED),;//05
				 TRBF->TIPO + " - " + ALLTRIM(POSICIONE("ZB4",1,XFILIAL("ZB4")+TRBF->TIPO,"ZB4_DESCRI")),;//06
				 aarr[_nnh,A112MAP("Cliente/Venda"  )],;//07
				 aarr[_nnh,A112MAP("Cliente/Remessa")],;//08
				 TRANS(TRBF->VALOR,"@E 999,999,999.99"),;//09
				 aarr[_nnh,A112MAP("Tipo Entrega")],;//10
				 aarr[_nnh,A112MAP("Dt Entrega")],;//11
				 IF(TRBF->TPFRETE="C",'CIF','FOB'),;//12
				 TRANS(TRBF->PESO,"@E 999,999.9999"),;//13
				 TRANS(TRBF->DESCONTO,"@E 999,999,999.99"),;//14
				 TRBF->OBSCOMER,;//15
				 TRBF->MENSANF ,;//16
				 cClassEnt    })//17
		Endif

	Next

	//Apresenta itlist
	If len(_acolec) > 0

		U_ITListBox( "Pedidos de venda" , _aheaderec , _acolec , .T. , 1 )

	Else

		u_itmsg("Nenhum registro selecionado!","Atenção",,1)

	Endif

Return

/*
===============================================================================================================================
Programa--------: AOMS112REC
Autor-----------: Erich Buttner
Data da Criacao-: 09/09/2010
===============================================================================================================================
Descrição-------: Processa a recusa do pedido de venda
===============================================================================================================================
Parametros------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112REC( oproc )

	Local _nposi := TRBF->(Recno())
	Local _aPeds := {}
	Local _acolec := {}
	Local _aheaderec := {}
	Local _nnh		:= 0
	Local _Xnnm		:= 0

	TRBF->( DBGoTop() )

//================================================================================
//Carrega pedidos selecionados
//================================================================================
	Do While TRBF->(!EOF())

		//================================================================================
		// Somente pedidos selecionados pelo usuario
		//================================================================================
		If (TRBF->OK == cmarca .and. !linverte) .or. (TRBF->OK != cmarca .and. linverte)

			aadd(_aPeds,TRBF->(Recno()))

		Endif

		TRBF->(DBSKIP())

	Enddo

//Retorna browse ao pedidos posicionado
	TRBF->(Dbgoto(_nposi))

	If len(_aPeds) == 0

		AOMS112RE2(oproc) //Recusa somente pedido posicionado

	Else

		//Monta tela de confirmação

		//Monta aheader
		aadd(_aheaderec,"Impresso")
		aadd(_aheaderec,"Fil Car")
		aadd(_aheaderec,"Fil Fat" )
		aadd(_aheaderec,"Id Pedido" )
		aadd(_aheaderec,"Cliente/Remessa")
		aadd(_aheaderec,"Tipo Entrega")
		aadd(_aheaderec,"Dt Emissão")
		aadd(_aheaderec,"Dt Carga")
		aadd(_aheaderec,"Trans Time")
		aadd(_aheaderec,"Dt Entrega")
		aadd(_aheaderec,"Tp Frete")
		aadd(_aheaderec,"Tab Preço")
		aadd(_aheaderec,"Cond Pgto")
		aadd(_aheaderec,"Vendedor")
		aadd(_aheaderec,"Mens NF")
		aadd(_aheaderec,"Obs")

		//Monta acols
		For _nnh := 1 to len(aarr)

			If aarr[_nnh][A112MAP(SPACE(1))] == cmarca

				aadd(_acolec, {	aarr[_nnh,A112MAP("Impresso")],;
					aarr[_nnh,A112MAP("Filial Faturamento")],;
					aarr[_nnh,A112MAP("Filial Carregamento")],;
					aarr[_nnh,A112MAP("Id Pedido")],;
					aarr[_nnh,A112MAP("Cliente/Remessa")],;
					aarr[_nnh,A112MAP("Tipo Entrega")],;
					aarr[_nnh,A112MAP("Dt Emissão")],;
					aarr[_nnh,A112MAP("Dt Carga")],;
					aarr[_nnh,A112MAP("Trans Time")],;
					aarr[_nnh,A112MAP("Dt Entrega")],;
					aarr[_nnh,A112MAP("Tp Frete")],;
					aarr[_nnh,A112MAP("Tab Preço")],;
					aarr[_nnh,A112MAP("Cond Pgto")],;
					aarr[_nnh,A112MAP("Vendedor")],;
					aarr[_nnh,A112MAP("Mens NF")],;
					aarr[_nnh,A112MAP("Tipo")],;
					aarr[_nnh,A112MAP("Obs")]})
			Endif

		Next

		//Apresenta itlist
		If len(_acolec) > 0

			If U_ITListBox( "Recusa de pedidos do portal" , _aheaderec , _acolec , .T. , 1,"Confirma recusa dos pedidos abaixo?" )
				//Solicita motivo da recusa
				cMens1 := ""
				_nopci := 0

				DEFINE FONT oFont NAME "Tahoma" BOLD

				@0,0 TO 320,500 DIALOG oDlg TITLE "Motivo de Recusa de pedidos do portal"

				oTPanel1:= TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,300,160,.T.,.F.)

				@005,010 SAY "Motivo de Recusa de múltiplos pedidos"					Of oTPanel1 Pixel FONT oFont

				oTFolder1 := TFolder():New( 050,005,{"Motivo"},,oTPanel1,,,,.T.,,240,090 )

				@ 005,005 Get cMens1 MEMO Size 230,60 when .T. of oTFolder1:aDialogs[1] Pixel

				TButton():New( 145 , 010 , ' Confirma '	, oTPanel1 , {|| _nopci := 1, oDlg:End()	} , 70 , 10 ,,,, .T. )
				TButton():New( 145 , 080 , ' Cancela '	, oTPanel1 , {|| oDlg:END()	} , 70 , 10 ,,,, .T. )

				ACTIVATE MSDIALOG oDlg Centered

				If _nopci == 1

					//Realiza recusa dos pedidos
					For _Xnnm := 1 to len(_aPeds)


						TRBF->(Dbgoto(_aPeds[_Xnnm]))

						//Recusa pedido sem perguntar motivo
						fwmsgrun(,{|| AOMS112RE2(oproc,cmens1)},"Aguarde...","Recusando pedido " + strzero(_Xnnm,4) + " de " + strzero(len(_aPeds),4) +"...")

					Next

					U_ITListBox( "Recusa de pedidos do portal" , _aheaderec , _acolec , .T. , 1,"Pedidos recusados com sucesso!" )

					//Retorna browse ao pedidos posicionado
					TRBF->(Dbgoto(_nposi))
					fwmsgrun(,{|| AOMS112arq(oproc)},"2 - Aguarde...","Atualizando tela...")

				Else

					u_itmsg("Processo cancelado pelo usuário!","Atenção",,1)

				Endif

			Else

				u_itmsg("Processo cancelado pelo usuário!","Atenção",,1)

			Endif

		Else

			u_itmsg("Nenhum registro selecionado!","Atenção",,1)

		Endif

	Endif

Return

/*
===============================================================================================================================
Programa--------: AOMS112RE2
Autor-----------: Erich Buttner
Data da Criacao-: 09/09/2010
===============================================================================================================================
Descrição-------: Processa a recusa do pedido de venda
===============================================================================================================================
Parametros------: oproc - objeto da barra de processamento
									_cmotivo - motivo da recusa
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112RE2( oproc, _cmotivo )

	Local cTitulo	:= "Recusa de Pedidos Portal"
	Local lRetMod2	:= .F. // Retorno da função Modelo2 - .T. Confirmou / .F. Cancelou
	Local nLinha	:= 0 , nColuna
	Public nOpcx	:= 7
	Default _cmotivo := ""

	nUsado	:=0
	aHeader	:={}
	aCols	:={}
	cDescr	:= ""
	nQtd2UM	:= 0
	c2UM	:= ""
	nVlrTot	:= 0
	nVTot	:= 0

	If empty(_cmotivo)

		//====================================================================================================
		// Montagem do aHeader
		//====================================================================================================
		aHeader := {	{ "Item"		  		,"ZW_ITEM"			,"@!"					,010,0,"AllwaysTrue()", "","C","","R"},;
			{ "Produto"	  		,"ZW_PRODUTO"		,"@!"					,015,0,"AllwaysTrue()", "","C","","R"},;
			{ "Descrição"	  		,"cDescr" 			,"@!"					,020,0,"AllwaysTrue()", "","C","","R"},;
			{ "Qtd Ven 2 UM"  	,"nQtd2UM" 		,"@e 999,999,999.99"	,014,2,"AllwaysTrue()", "","C","","R"},;
			{ "Segunda UM"	   	,"c2UM"			,"@!"					,002,0,"AllwaysTrue()", "","C","","R"},;
			{ "Quantidade"		,"ZW_QTDVEN"		,"@e 999,999,999.99"	,014,2,"AllwaysTrue()", "","C","","R"},;
			{ "Unidade"		   	,"ZW_UM"			,"@!"					,002,0,"AllwaysTrue()", "","C","","R"},;
			{ "Prc Unitario" 		,"ZW_PRCVEN"		,"@e 9,999,999.9999"	,014,4,"AllwaysTrue()", "","C","","R"},;
			{ "Vlr.Total "		,"nVlrTot"			,"@e 999,999,999.99"	,014,2,"AllwaysTrue()", "","C","","R"},;
			{ "Blq. Preço "		,"ZW_BLOPRC"		,"@!"					,001,0,"AllwaysTrue()", "","C","","R"} }

		//Locka registros
		If !( AOMS112LO( SubStr( TRBF->FILIAL , 1 , 2 ), TRBF->NUMPED ) )

			Return

		Endif

		DBSELECTAREA("SZW")
		SZW->( DbSetOrder(1) )
		If SZW->( DbSeek( SubStr( TRBF->FILIAL , 1 , 2 ) + TRBF->NUMPED ) )

			While SZW->(!Eof()) .AND. SZW->( ZW_FILIAL + ZW_IDPED ) == SubStr( TRBF->FILIAL , 1 , 2 ) + TRBF->NUMPED

				AADD( aCols , Array( Len(aHeader) + 1 ) )
				nLinha++

				cDescr	:= GetAdvFVal( "SB1" , "B1_I_DESCD"	, xFilial("SB1") + ALLTRIM( SZW->ZW_PRODUTO )	, 1 , "" )
				nFatConv:= GetAdvFVal( "SB1" , "B1_CONV"	, xFilial("SB1") + SZW->ZW_PRODUTO				, 1 , "" )
				cTpConv := GetAdvFVal( "SB1" , "B1_TIPCONV"	, xFilial("SB1") + SZW->ZW_PRODUTO				, 1 , "" )
				nNewFat := GetAdvFVal( "SB1" , "B1_I_FATCO"	, xFilial("SB1") + SZW->ZW_PRODUTO				, 1 , "" )

				If cTpConv == "M"
					nQtd2UM := IIf( nFatConv == 0 , nNewFat * SZW->ZW_QTDVEN	, nFatConv * SZW->ZW_QTDVEN	)
				Else
					nQtd2UM := IIf( nFatConv == 0 , SZW->ZW_QTDVEN / nNewFat	, SZW->ZW_QTDVEN / nFatConv	)
				EndIf

				c2UM	:= GetAdvFVal( "SB1" , "B1_SEGUM"	, xFilial("SB1") + ALLTRIM( SZW->ZW_PRODUTO )	, 1 , "" )
				nVlrTot := SZW->ZW_QTDVEN * SZW->ZW_PRCVEN
				nVtot	+= nVlrTot

				For nColuna := 1 to Len(aHeader)
					aCols[nLinha][nColuna] := &(aHeader[nColuna][2])
				Next nColuna

				aCols[nLinha][Len(aHeader)+1] := .F. // Linha não deletada

				SZW->( DBSkip() )
			EndDo

		EndIf

		cFli		:= Space(020)
		cFilPro		:= Space(040)
		cTipPed		:= Space(015)
		cNumPed		:= Space(025)
		cCliente	:= Space(006)
		cNomCli		:= Space(060)
		cLojaCli	:= Space(004)
		cGrpCli		:= Space(030)
		cCond		:= Space(050)
		cVend1		:= Space(006)
		cNmVend1	:= Space(040)
		cVend2		:= Space(006)
		cNmVend2	:= Space(040)
		cPedCli		:= Space(009)
		dDtEnt		:= CtoD("")
		cTipoAg		:= Space(10)
		cHrEnt		:= Space(005)
		cSha		:= Space(014)
		cTipFre		:= Space(010)
		cTipCar		:= Space(015)
		cQtdCha		:= Space(003)
		cHrDes		:= Space(005)
		nCusDes		:= 0
		cObsCom		:= Space(300)
		cObsNF		:= Space(300)

		DBSELECTAREA("SZW")
		SZW->( DBSetOrder(1) )
		SZW->( DbSeek( SubStr( TRBF->FILIAL , 1 , 2 ) + TRBF->NUMPED ) )

		dDtEnt		:= SZW->ZW_FECENT
		_laltera := .T.

		If SZW->ZW_I_AGEND == 'P'

			//cTipoAg	:= SZW->ZW_I_AGEND+" - AGUARD AGENDA"

			If month(date()) != 12

				dDtEnt := STOD(ALLTRIM(STR((YEAR(DATE())+1)))+"0101")-1

			Else

				dDtEnt := STOD(ALLTRIM(STR((YEAR(DATE())+2)))+"0101")-1

			Endif

			_laltera := .F.

		Endif

		If SZW->ZW_I_AGEND $ 'I/O'//I=Imediata //O=Agendada pelo Op.Log.
			_cFilCarreg := SZW->ZW_FILIAL
			If !EMPTY(SZW->ZW_FILPRO) .AND. !(ALLTRIM(SZW->ZW_FILPRO)=='0')
				_cFilCarreg := SZW->ZW_FILPRO
			EndIf

			//cTipoAg	:= SZW->ZW_I_AGEND+" - IMEDIATO"
			dDtEnt      := SZW->ZW_FECENT
			_laltera := .F.

		Endif

		//If SZW->ZW_I_AGEND == 'M'
		//	cTipoAg		:= SZW->ZW_I_AGEND+" - AGENDADA COM MULTA"
		//Endif
		//If SZW->ZW_I_AGEND == 'A'
		//	cTipoAg		:= SZW->ZW_I_AGEND+" - AGENDADA"
		//Endif
        
		cTipoAg:=SZW->ZW_I_AGEND+" - "+(U_TipoEntrega(SZW->ZW_I_AGEND))
		
		//====================================================================================================
		// aC[n,1] = Nome da Variavel Ex.:"cCliente"
		// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
		// aC[n,3] = Titulo do Campo
		// aC[n,4] = Picture
		// aC[n,5] = Validacao
		// aC[n,6] = F3
		// aC[n,7] = Se campo e' editavel .t. se nao .f.
		//====================================================================================================

		aC := {	{ "cFli"	,{015,003} 		,"Filial                   " 	  	,"@!"   				,	,		,.F.	},;
			{ "cFilPro" 	,{015,203} 		,"Filial Carregamento   "         	,"@!"   				,   ,       ,.F.	},;
			{ "cTipPed"		,{030,003} 		,"Tipo Pedido       " 	  			,"@!"   				,	,		,.F.	},;
			{ "cNumPed"		,{030,203} 		,"Num. Pedido " 	  				,"@!"   				,	,		,.F.	},;
			{ "cCliente"	,{045,003}		,"Cliente/Remessa" 		 			,"@!"   				,	,		,.F.	},;
			{ "cLojaCli"	,{045,085}		,"Loja   "							,"@!"   				,	,		,.F.	},;
			{ "cNomCli"		,{045,140} 		,"Nome Cliente/Remessa"				,"@!"   				,	,		,.F.	},;
			{ "cGrpCli"		,{060,003} 		,"Grupo Cliente/Rem."				,"@!"   				,	,		,.F.	},;
			{ "cCond"		,{060,285}		,"Cond. Pagto" 						,"@!"   				,	,		,.F.	},;
			{ "cVend1"		,{075,003}		,"Vendedor 1       "  				,"@!"   				,	,		,.F.	},;
			{ "cNmVend1"	,{075,140}		,"Nome Vendedor 1" 					,"@!"   				,	,		,.F.	},;
			{ "nVTot"		,{075,500}		,"Valor Total   " 					,"@e 999,999,999.99"	,	,		,.F.	},;
			{ "cVend2"		,{090,003}		,"Vendedor 2       "  				,"@!"   				,	,		,.F.	},;
			{ "cNmVend2"	,{090,140}		,"Nome Vendedor 2" 					,"@!"   				,	,		,.F.	},;
			{ "cPedCli" 	,{105,003} 		,"Pedido Cliente/Remessa    "		,"@!"   				,	,		,.F.	},;
			{ "cTipoAg"		,{030,500}		,"Tipo Agendamento"					,"@!"   				,	,		,.F.	},;
			{ "dDtEnt"		,{015,470}		,"Data Entrega          "			,"@!"   				,	,		,_laltera	},;
			{ "cHrEnt"		,{015,570}		,"Hora Entrega   "					,"@!"   				,	,		,.F.	},;
			{ "cSha"		,{105,325}		,"Senha                "			,"@!"   				,	,		,.F.	},;
			{ "cTipFre"	 	,{105,500} 		,"Tipo Frete    "					,"@!"   				,	,		,.F.	},;
			{ "cTipCar"		,{120,003} 		,"Tipo de Carga     "				,"@!"   				,	,		,.F.	},;
			{ "cQtdCha"		,{120,140} 		,"Qtd. Chapa           "			,"@!"   				,	,		,.F.	},;
			{ "cHrDes"		,{120,245} 		,"Hora Descarga"					,"@!"   				,	,		,.F.	},;
			{ "nCusDes"		,{120,325} 		,"Custo Descarga"					,"@e 999,999,999.99"	,	,		,.F.	},;
			{ "cObsCom"		,{135,003} 		,"Obs. Comercial  "					,"@!"					,	,		,.F.	},;
			{ "cObsNf"		,{150,003} 		,"Mensagem NF    "					,"@!"					,	,		,.F.	} }


		//====================================================================================================
		// Array com descricao dos campos do Rodape do Modelo 2
		// aR[n,1] = Nome da Variavel Ex.:"cCliente"
		// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
		// aR[n,3] = Titulo do Campo
		// aR[n,4] = Picture
		// aR[n,5] = Validacao
		// aR[n,6] = F3
		// aR[n,7] = Se campo e' editavel .t. se nao .f.
		//====================================================================================================
		aR := {}

		DBSELECTAREA("SZW")
		SZW->( DBSetOrder(1) )
		If SZW->( DbSeek( SubStr( TRBF->FILIAL , 1 , 2 ) + TRBF->NUMPED ) )

			cFli		:= Left( SubStr( TRBF->FILIAL , 1 , 2 ) +" - "+ GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(TRBF->FILIAL,1,2),1,""),25 )
			cFilPro		:= SubStr( TRBF->FILPRO , 1 , 2 ) +" - "+ GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(TRBF->FILPRO,1,2),1,"")
			cTipPed		:= SUBSTR( TRBF->TIPO +" - "+ GetAdvFVal("ZB4","ZB4_DESCRI",xFilial("ZB4")+TRBF->TIPO,1,"") , 1 , 25 )
			cNumPed  	:= TRBF->NUMPED
			cCliente 	:= SZW->ZW_CLIENTE
			cLojaCli 	:= SZW->ZW_LOJACLI
			cNomCli 	:= GetAdvFVal( "SA1" , "A1_NOME"	, xFilial("SA1") + SZW->ZW_CLIENTE + SZW->ZW_LOJACLI , 1 , "" )
			cGrpCli		:= GetAdvFVal( "SA1" , "A1_GRPVEN"	, xFilial("SA1") + SZW->ZW_CLIENTE + SZW->ZW_LOJACLI , 1 , "" ) +" - "+ GetAdvFVal( "SA1" , "A1_I_NGRPC" , xFilial("SA1") + SZW->ZW_CLIENTE + SZW->ZW_LOJACLI , 1 , "" )
			cCond		:= AOMS1125()
			cVend1	 	:= SZW->ZW_VEND1
			cNmVend1 	:= GetAdvFVal( "SA3" , "A3_NOME" , xFilial("SA3") + SZW->ZW_VEND1 , 1 , "" )
			cVend2   	:= SZW->ZW_VEND2
			cNmVend2 	:= GetAdvFVal( "SA3" , "A3_NOME" , xFilial("SA3") + SZW->ZW_VEND2 , 1 , "" )
			nVTot 		:= nVTot
			cPedCli		:= SZW->ZW_PEDCLI

			cHrEnt		:= SZW->ZW_HOREN
			cSha		:= SZW->ZW_SENHA
			cTipFre		:= IF( SZW->ZW_TPFRETE == 'C' , SZW->ZW_TPFRETE	+" - CIF"			, SZW->ZW_TPFRETE	+" - FOB"		)
			_cchep 		:= posicione("SA1",1,XFILIAL("SA1")+ccliente+cLojaCli,"A1_I_CCHEP")
			cTipCar		:= IF( !empty(_cchep) , "1 - Paletizada" , "2 - Batida" )
			cQtdCha		:= SZW->ZW_CHAPA
			cHrDes		:= SZW->ZW_HORDES
			nCusDes		:= SZW->ZW_CUSDES
			cObsCom		:= SZW->ZW_OBSCOM
			cObsNF		:= SZW->ZW_MENNOTA
			aCGD		:= { 350 , 06 , 26 , 74 } // Array com coordenadas da GetDados no modelo2


			//====================================================================================================
			// Chamada da Modelo2
			//====================================================================================================
			lRetMod2 := Modelo2( cTitulo , aC , aR , aCGD , nOpcx ,,,,,, 9999 ,,, .T. )

			If lRetMod2

				cMens1 := ""

				DEFINE FONT oFont NAME "Tahoma" BOLD

				@0,0 TO 320,500 DIALOG oDlg TITLE "Recusa de pedido do portal"

				oTPanel1:= TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,300,160,.T.,.F.)

				@005,010 SAY "Motivo de Recusa"								Of oTPanel1 Pixel FONT oFont
				@020,010 SAY "Pedido........: "+ cNumPed					Of oTPanel1 Pixel
				@020,100 SAY "Cliente/Remessa.......: "+ cCliente +" - "+ cLojaCli	Of oTPanel1 Pixel
				@035,010 SAY "Nome Cliente/Remessa..: "+ cNomCli					Of oTPanel1 Pixel

				oTFolder1 := TFolder():New( 050,005,{"Motivo"},,oTPanel1,,,,.T.,,240,090 )

				@ 005,005 Get cMens1 MEMO Size 230,60 when .T. of oTFolder1:aDialogs[1] Pixel

				TButton():New( 145 , 010 , ' Confirma '	, oTPanel1 , {|| fwmsgrun(,{|oproc| AOMS112GRC(SubStr( TRBF->FILIAL , 1 , 2 ), TRBF->NUMPED)},"Aguarde...","Gravando recusa..."), oDlg:End()	} , 70 , 10 ,,,, .T. )
				TButton():New( 145 , 080 , ' Cancela '	, oTPanel1 , {|| oDlg:END()	} , 70 , 10 ,,,, .T. )

				ACTIVATE MSDIALOG oDlg Centered

			EndIf

		Else

			u_itmsg(  'Não foi possível posicionar no pedido!' , 'Atenção!',,1)

		EndIf

	Else

		//Execução múltipla
		cMens1 := _cmotivo

		AOMS112GRC(SubStr( TRBF->FILIAL , 1 , 2 ), TRBF->NUMPED)

	Endif

	AOMS112UN(SubStr( TRBF->FILIAL , 1 , 2 ), TRBF->NUMPED )

Return()

/*
===============================================================================================================================
Programa--------: AOMS112GRC
Autor-----------: Erich Buttner
Data da Criacao-: 09/09/2010
===============================================================================================================================
Descrição-------: Grava as informações da recusa do pedido de venda
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112GRC(cFilPed, nIDPED, cOrigem, cMot)
	Local cEmail   := ""
	Local cCliente := ""
	Local lEnvia   := .F.

	Default cOrigem := U_UCFG001(1)

	If !Empty(ALLTRIM(cMot))
		cMens1 := cMot
	EndIf

	DbSelectArea("SZW")
	SZW->( DBSetOrder(1) )
	If SZW->( DBSeek( ALLTRIM(cFilPed) + ALLTRIM(nIDPED) ) )

		While !(EoF()) .And. ALLTRIM(SZW->ZW_FILIAL) + ALLTRIM(SZW->ZW_IDPED) == ALLTRIM(cFilPed)  + ALLTRIM(nIDPED)

			RecLock( "SZW" , .F. )

			SZW->ZW_STATUS := "R"
			SZW->ZW_MOTREC := cMens1
			SZW->ZW_MOTREP := cMens1
			SZW->ZW_USRREC := cOrigem
			SZW->ZW_DTREC  := Date()
			SZW->ZW_HRREC  := TIME()

			SZW->( MsUnLock() )

			cCliente	:= SZW->ZW_CLIENTE +" - "+ SZW->ZW_LOJACLI +" - "+ GetAdvFVal( "SA1" , "A1_NOME" , xFilial("SA1") + SZW->ZW_CLIENTE + SZW->ZW_LOJACLI , 1 , "" )
			cEmail		:= GetAdvFVal( "SA3" , "A3_EMAIL" , xFilial("SA3") + SZW->ZW_VEND1 , 1 , "" )
			lEnvia		:= .T.
			SZW->( DbSkip() )
		EndDo

		If lEnvia
			DbSelectArea("SZW")
			SZW->( DBSetOrder(1) )
			SZW->( DBSeek( ALLTRIM(cFilPed) + ALLTRIM(nIDPED) ) )

			cMsg := '<table width="75%" border="1"> '
			cMsg += '  <tr>  '
			cMsg += '    <td bordercolor="#000000" bgcolor="#778899" align="center"><font color="#FFFFFF">AVISO DE RECUSA DE PEDIDO</font></td> '
			cMsg += '  </tr>  '
			cMsg += '</table>  '
			cMsg += '<BR> '
			cMsg += '<table width="75%" border="1"> '
			cMsg += '  <tr> '
			cMsg += '    <td><b>Pedido: </b>'+ ALLTRIM(nIDPED) + ' Dt.Inclusão: ' +   DtoC(SZW->ZW_EMISSAO) + ' HH Inclusão: ' + SZW->ZW_HORAINC + ' </td>  '
			cMsg += '  </tr>  '
			cMsg += '</table> '
			cMsg += '<table width="75%" border="1"> '
			cMsg += '  <tr>  '
			cMsg += '    <td><b>Cliente: </b>'+ ALLTRIM(cCliente) +'</td>  '
			cMsg += '  </tr> '
			cMsg += '</table>  '
			cMsg += '<table width="75%" border="1"> '
			cMsg += '  <tr> '
			cMsg += '    <td><b>Motivo: </b> </td>  '
			cMsg += '  </tr> '
			cMsg += '</table>  '
			cMsg += '<table width="75%" border="1"> '
			cMsg += '  <tr> '

			I		:= 1
			lRetMen	:= .T.

			While lRetMen

				If I < Len( cMens1 )
					cMsg +='   <td>'+ SubStr(cMens1,I,254) +' </td> '
				Else
					lRetMen := .F.
				EndIf

				I += 254

			EndDo

			cMsg +='  </tr> '
			cMsg +='</table>  '

			AOMS112EN( cMsg , "Recusa Pedido do Portal - Filial " + ALLTRIM(SZW->ZW_FILIAL) + " Pedido " + ALLTRIM(nIDPED) + " Cliente/Remessa " + ALLTRIM(cCliente) , cEmail )
		EndIf
	EndIf

Return( .T. )

/*
===============================================================================================================================
Programa--------: AOMS112EN
Autor-----------: Erich Buttner
Data da Criacao-: 09/09/2010
===============================================================================================================================
Descrição-------: Processa o envio de mensagens
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112EN( cMensagem , cTitulo , cEmail )

	nInd		:= 0
	lResult		:= .F.
	_cArq		:= ''
	lRelauth	:= .T.

//====================================================================================================
// Tenta conexao com o servidor de E-Mail
//====================================================================================================
	CONNECT SMTP                    ;
	SERVER       GetMV("MV_RELSERV");      // Nome do servidor de e-mail = smtp.bra.terra.com.br
	ACCOUNT 	 GetMV("MV_RELACNT");      // Nome da conta a ser usada no e-mail = fulano
	PASSWORD 	 GetMV("MV_RELPSW") ;      // Senha = senha
	RESULT       lResult                   // Resultado da tentativa de conexão

	If lRelauth
		lRet := Mailauth(GetMV("MV_RELACNT"),GetMV("MV_RELPSW"))
	Else
		lRet := .T.
	Endif

	If lResult

		SEND MAIL FROM GetMV("MV_RELACNT") TO cEmail SUBJECT cTitulo BODY cMensagem RESULT lResult

	EndIf

//====================================================================================================
// Finaliza conexao com o servidor de E-Mail
//====================================================================================================
	DISCONNECT SMTP SERVER

Return( lResult )

/* 
===============================================================================================================================
Programa--------: AOMS112AF
Autor-----------: Josué Danich Prestes
Data da Criacao-: 21/03/2019
===============================================================================================================================
Descrição-------: Alteração múltipla de filiais
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112AF()

	Local _nposi := TRBF->(Recno())
	Local _aPeds := {}
	Local _acolec := {}
	Local _aheaderec := {}
	Local _nnh		:= 0
	Local _nnm		:= 0
	Private cfilfat := space(30)
	Private cfilcrg := space(30)


	TRBF->( DBGoTop() )

//================================================================================
//Carrega pedidos selecionados
//================================================================================
	Do While TRBF->(!EOF())

		//================================================================================
		// Somente pedidos selecionados pelo usuario
		//================================================================================
		If (TRBF->OK == cmarca .and. !linverte) .or. (TRBF->OK != cmarca .and. linverte)

			aadd(_aPeds,TRBF->(Recno()))

		Endif

		TRBF->(DBSKIP())

	Enddo

//Retorna browse ao pedidos posicionado
	TRBF->(Dbgoto(_nposi))

	If len(_aPeds) == 0

		u_itmsg("Nenhum pedido selecionado","Atenção","Selecione pedidos ou altere as filiais diretamente na tela",1)

	Else

		//Monta tela de confirmação

		//Monta aheader
		aadd(_aheaderec,"Impresso")
		aadd(_aheaderec,"Fil Car")
		aadd(_aheaderec,"Fil Fat" )
		aadd(_aheaderec,"Id Pedido" )
		aadd(_aheaderec,"Cliente/Remessa")
		aadd(_aheaderec,"Tipo Entrega")
		aadd(_aheaderec,"Dt Emissão")
		aadd(_aheaderec,"Dt Carga")
		aadd(_aheaderec,"Trans Time")
		aadd(_aheaderec,"Dt Entrega")
		aadd(_aheaderec,"Tp Frete")
		aadd(_aheaderec,"Tab Preço")
		aadd(_aheaderec,"Cond Pgto")
		aadd(_aheaderec,"Vendedor")
		aadd(_aheaderec,"Mens NF")
		aadd(_aheaderec,"Obs")

		//Monta acols
		For _nnh := 1 to len(aarr)

			If aarr[_nnh][1] == cmarca

				aadd(_acolec, {	 aarr[_nnh,A112MAP("Impresso")],;
					aarr[_nnh,A112MAP("Filial Faturamento") ],;
					aarr[_nnh,A112MAP("Filial Carregamento")],;
					aarr[_nnh,A112MAP("Id Pedido")],;
					aarr[_nnh,A112MAP("Cliente/Remessa")],;
					aarr[_nnh,A112MAP("Tipo Entrega")],;
					aarr[_nnh,A112MAP("Dt Emissão")],;
					aarr[_nnh,A112MAP("Dt Carga")],;
					aarr[_nnh,A112MAP("Trans Time")],;
					aarr[_nnh,A112MAP("Dt Entrega")],;
					aarr[_nnh,A112MAP("Tp Frete")],;
					aarr[_nnh,A112MAP("Tab Preço")],;
					aarr[_nnh,A112MAP("Cond Pgto")],;
					aarr[_nnh,A112MAP("Vendedor")],;
					aarr[_nnh,A112MAP("Mens NF")],;
					aarr[_nnh,A112MAP("Obs")]})
			Endif

		Next

		//Apresenta itlist
		If len(_acolec) > 0

			If U_ITListBox( "Alteração de filiais de pedidos" , _aheaderec , _acolec , .T. , 1,"Confirma alteração de filiais dos pedidos abaixo?" )

				//Solicita filiais
				cMens1 := ""
				_nopci := 0
				cfilcrg := aarr[01,A112MAP("Filial Carregamento")]
				cfilfat := aarr[01,A112MAP("Filial Faturamento")]

				DEFINE FONT oFont NAME "Tahoma" BOLD

				@0,0 TO 320,500 DIALOG oDlg TITLE "Alteração de filiais de pedidos do portal"

				oTPanel1:= TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,300,160,.T.,.F.)

				@ 005,010 SAY "Filial de Faturamento:"	Of oTPanel1 Pixel FONT oFont
				@ 005,090 Get cfilfat valid AOMS112F2() when .T. of oTPanel1 Pixel

				@ 035,010 SAY "Filial de Carregamento:"		Of oTPanel1 Pixel FONT oFont
				@ 035,090 Get cfilcrg valid AOMS112F2() when .T. of oTPanel1 Pixel


				TButton():New( 145 , 010 , ' Confirma '	, oTPanel1 , {|| _nopci := 1, oDlg:End()	} , 70 , 10 ,,,, .T. )
				TButton():New( 145 , 080 , ' Cancela '	, oTPanel1 , {|| oDlg:END()	} , 70 , 10 ,,,, .T. )

				ACTIVATE MSDIALOG oDlg Centered

				If _nopci == 1

					//Valida filial de faturamento em branco
					If empty(cfilfat)
						TRBF->(Dbgoto(_nposi))
						u_itmsg("Filial de faturamento não pode ficar em branco!","Atenção",,1)
						Return
					Endif

					_acolec2 := {}

					//Realiza alteração de pedidos
					For _nnm := 1 to len(_aPeds)

						BEGIN TRANSACTION
							TRBF->(Dbgoto(_aPeds[_nnm]))

							_cfilul := TRBF->FILIAL
							_numul  := TRBF->NUMPED

							Reclock("TRBF",.F.)
							TRBF->FILIAL := cfilfat
							TRBF->FILPRO := cfilcrg
							TRBF->(Msunlock())

							_acolec[_nnm][1] := cfilfat
							_acolec[_nnm][2] := cfilcrg

							SZW->(Dbsetorder(1))
							If SZW->(Dbseek(substr(_cfilul,1,2)+_numul))

								If  !( AOMS112LO( substr(_cfilul,1,2), _numul,.F. ) )

									aadd(_acolec2,{_acolec[_nnm][1],_acolec[_nnm][2],_acolec[_nnm][3],_acolec[_nnm][4],"Pedido em uso!"})
									Disarmtransaction()

								Else

									SZW->(Dbseek(substr(_cfilul,1,2)+_numul))
									Do while SZW->ZW_FILIAL == substr(_cfilul,1,2) .AND. ALLTRIM(SZW->ZW_IDPED) == ALLTRIM(_numul)

										Reclock("SZW",.F.)
										SZW->ZW_FILIAL := LEFT(cfilfat,2)
										SZW->ZW_FILPRO := LEFT(cfilcrg,2)
										SZW->(Msunlock())
										SZW->(Dbskip())

									Enddo

									AOMS112UN( substr(TRBF->FILIAL,1,2), _numul )

									aadd(_acolec2,{_acolec[_nnm][1],_acolec[_nnm][2],_acolec[_nnm][3],_acolec[_nnm][4],"Filiais alteradas com sucesso"})

								Endif

							Else

								Disarmtransaction()
								_acolec[_nnm][1] := TRBF->FILIAL
								_acolec[_nnm][2] := TRBF->FILPRO
								aadd(_acolec2,{_acolec[_nnm][1],_acolec[_nnm][2],_acolec[_nnm][3],_acolec[_nnm][4],"Falha na alteração de filiais"})

							Endif

						END TRANSACTION

					Next

					//Monta novo aheader
					_aheaderec := {}
					//Monta aheader
					aadd(_aheaderec,"Fil Car")
					aadd(_aheaderec,"Fil Fat" )
					aadd(_aheaderec,"Id Pedido" )
					aadd(_aheaderec,"Cliente/Remessa")
					aadd(_aheaderec,"Resultado")

					U_ITListBox( "Alteração de filiais de pedidos do portal" , _aheaderec , _acolec2 , .T. , 1,"Alteração de filiais de pedidos do portal realizada com sucesso!" )

					//atualiza a tela
					fwmsgrun(,{|oproc| AOMS112arq(oproc)},"3 - Aguarde...","Atualizando tela...")

				Else

					u_itmsg("Processo cancelado pelo usuário!","Atenção",,1)

				Endif

			Else

				u_itmsg("Processo cancelado pelo usuário!","Atenção",,1)

			Endif

		Else

			u_itmsg("Nenhum registro selecionado!","Atenção",,1)

		Endif

	Endif

//Retorna browse ao pedidos posicionado
	TRBF->(Dbgoto(_nposi))

Return

/*
===============================================================================================================================
Programa--------: AOMS112F2
Autor-----------: Josué Danich Prestes
Data da Criacao-: 21/03/2019
===============================================================================================================================
Descrição-------: Validação de filial
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: lret - validação sim ou não
===============================================================================================================================
*/
Static Function AOMS112F2()
	Local lret := .T.
	Local cfildes2 := ""
	Local cfildes := ""

	IF !EMPTY(cfilcrg)

		cFilDes2:= GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+LEFT(cfilcrg,2),1,"")
		IF EMPTY(cFilDes2)
			U_ITMSG("Filial de carregamento nao cadastrada",'Atenção',,1)
			RETURN .F.
		ENDIF

	Endif

	IF !EMPTY(cfilfat)

		cFilDes:= GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+LEFT(cfilfat,2),1,"")
		IF EMPTY(cFilDes)
			U_ITMSG("Filial de faturamento nao cadastrada",'Atenção',,1)
			RETURN .F.
		ENDIF

		_cFilSalva:= cFilAnt
		cFilAnt   := LEFT(ALLTRIM(cfilfat),2)
		If ALLTRIM(U_ITGETMV( "IT_FATNF" , "N")) == "N"
			U_ITMSG("Filial "+cfilfat+" nao é troca nota de Faturamento (IT_FATNF)",'Atenção',,1)
			cFilAnt  := _cFilSalva
			RETURN .F.
		ENDIF

		If !empty(cfilcrg)
			cFilAnt:=LEFT(cfilcrg,2)
			If ALLTRIM(U_ITGETMV( "IT_PRONF" , "N")) == "N"
				U_ITMSG("Filial "+ALLTRIM(cfilcrg)+" nao é troca nota de Carregamento (IT_PRONF)",'Atenção',,1)
				cFilAnt  := _cFilSalva
				RETURN .F.
			ENDIF
		Endif

		cFilAnt  := _cFilSalva

		IF lRet .and. !empty(cfilcrg)                            //Fil Carregamento, Fil Faturamento
			lRet:=U_AOM112Val( 'VAL_GRUPO' , left(cfilcrg,2) , left(cfilfat,2) )
		ENDIF

	ENDIF

	If !empty(cFilDes)
		cfilfat:= LEFT(LEFT(cfilfat,2)+" - "+cFilDes,40)
	Endif
	If !empty(cFilDes2)
		cfilcrg:= LEFT(LEFT(cfilcrg,2)+" - "+cFilDes2,40)
	Endif

Return lret

/*
===============================================================================================================================
Programa--------:  AOMS112EFI
Autor-----------: Josué Danich Prestes
Data da Criacao-: 22/03/2019
===============================================================================================================================
Descrição-------: Chamada de efetivação dos pedidos de vendas do portal
===============================================================================================================================
Parametros------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112EFI(oproc)

	Local _nposi := TRBF->(Recno())
	Local _aPeds := {}
	Local _nnm		:= 0
	Private _lefetivado := .F.
	Private _aResults := {}
	Private _nni := 0
	Private _ntot := 0


	TRBF->( DBGoTop() )

//================================================================================
//Carrega pedidos selecionados
//================================================================================
	Do While TRBF->(!EOF())

		//================================================================================
		// Somente pedidos selecionados pelo usuario
		//================================================================================
		If (TRBF->OK == cmarca .and. !linverte) .or. (TRBF->OK != cmarca .and. linverte)

			aadd(_aPeds,TRBF->(Recno()))

		Endif

		TRBF->(DBSKIP())

	Enddo

//Retorna browse ao pedidos posicionado
	TRBF->(Dbgoto(_nposi))

	If len(_aPeds) == 0

		u_itmsg("Nenhum pedido selecionado","Atenção","Selecione ao menos um pedido para efetivar",1)

	Else

		aSort(_aPeds)
		If len(_aPeds) > 0

			_lefetivado := .T.
			_aResults := {}
			//Realiza efetivação dos pedidos
			For _nnm := 1 to len(_aPeds)

				TRBF->(Dbgoto(_aPeds[_nnm]))
				_ntot := len(_aPeds)
				_nni := _nnm
				FWMSGRUN(,{|oproc| AOMS112EFE(TRBF->NUMPED , LEFT(TRBF->FILIAL,2),.T.)},;
					"Aguarde...","Efetivando pedido " + strzero(_nnm,4) + " de " + strzero(len(_aPeds),4) +"...")


			Next

			If len(_aResults) > 0

				_aCab:={' ','Filial','Pedido','Cliente/Remessa','Resultado / Erros',"Complemento do Resultado / Erros"}
				FOR _nnm := 1 TO LEN(_aResults)
					IF LEN(_aResults[_nnm]) < 6
					   ASize( _aResults[_nnm] , 6 )
					   _aResults[_nnm,6]:=" "
					ENDIF
				NEXT

				//Apresenta resultados
				U_ITListBox( "Efetivação de pedidos do portal" ,_aCab , _aResults , .T. , 1,"Resultado dos processamentos" )

			Else

				u_itmsg("Nenhum pedido efetivado!","Atenção",,1)

				_lefetivado := .F.

			Endif

			If _lefetivado

				fwmsgrun(,{|oproc| AOMS112arq(oproc)},"4 - Aguarde...","Atualizando tela...") //remonta tela

			Endif

		Else

			u_itmsg("Nenhum registro selecionado!","Atenção",,1)

		Endif

	Endif

//Retorna browse ao pedidos posicionado
	TRBF->(Dbgoto(_nposi))

Return

/*
===============================================================================================================================
Programa--------: AOMS112EFE
Autor-----------: Alexandre Villar
Data da Criacao-: 14/02/2014
===============================================================================================================================
Descrição-------: Efetivação dos pedidos de vendas do portal
===============================================================================================================================
Parametros------: cNumPed - Número do pedido de venda do portal
----------------: cFilAux - Filial do pedido de venda
									_lAutoref - execução de múltiplos pedidos
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112EFE(cNumPed , cFilAux, _lAutoref ,_lTela)

	Local aArea	    := GetArea()
	Local lProcOk   := .T. //Variável de Controle de Erros de Processamento
	Local _cOper    := "01"
	Local _cItensPM := ""
	Local _cItensMA := ""
	Local _cDetPM   := ""
	Local _cDetMA   := ""

	Private _aret := {}

	Default _lAutoref := .F.
	Default _lTela := .T.

//1-Valida se o Pedido deve ser Efetivado com a Nova Regra de WF de Aprovação de Preço
	IF _lTela
		FWMSGRUN(, {|| lProcOk:= AOMS112WF(cFilAux,cNumPed) }, "Aguarde!" , "1-Validando WF de Aprovação de Preço " + cNumPed	 )
	ELSE
		lProcOk:= AOMS112WF(cFilAux,cNumPed)
	ENDIF

	//Valida se o Cliente pode usar Tipo de Frete FOB
	If lProcOk
		SZW->( DBSetOrder(1) )
		SZW->( DBSeek( cFilAux + cNumPed ) )
		_lFob := Posicione("SA1",1,xfilial("SA1") + SZW->ZW_CLIENTE + SZW->ZW_LOJACLI ,"A1_I_FOB")
		If SZW->ZW_TPFRETE == "F"
			If !_lFob

				If _lAutoref
					aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),"Para este Cliente/Remessa não é permitdo o Tipo de Frete = FOB. Necessário ajuste no cadastro desse cliente antes da efetivação."})
				Else
					u_ItMsg("Para este Cliente/Remessa " + SZW->ZW_CLIENTE + " Loja: " + SZW->ZW_LOJACLI + " - " + ALLTRIM(SA1->A1_NOME) + " não é permitdo o Tipo de Frete = FOB. Necessário ajuste no cadastro desse Cliente/Remessa antes da efetivação. Pedido: "+cNumPed,"Atenção!" , ,1 )
				Endif

				lProcOk := .F.
			EndIf
		EndIf
	EndIf

	//============================================================
	// Inclusão de Tratamentos para Unidade Frisia = Filial 93
	//============================================================
	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( cFilAux + cNumPed ) )
	If SZW->ZW_FILPRO $ "93" .Or. SZW->ZW_FILIAL $ "93" //.And. SZW->ZW_TIPO == "01"
		U_AOMS112Q(SZW->ZW_FILIAL , cNumPed ,SZW->ZW_FILPRO)
	EndIf

//2-Valida se o Cliente desse Pedido possui pedido(s) de Bonificacao sem aprovação
	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( cFilAux + cNumPed ) )
	If lProcOk .And. ALLTRIM(SZW->ZW_TIPO) <> '10'

		SA1->(Dbsetorder(1))
		SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))
		_cPSB:=""

		IF _lTela
			FWMSGRUN(, {|| lProcOk := AOM112BoniApro(SZW->ZW_CLIENTE,SZW->ZW_LOJACLI,@_cPSB) }, "Aguarde!" , "2-Validando Bonificacao do pedido " + cNumPed	 )
		ELSE
			lProcOk := AOM112BoniApro(SZW->ZW_CLIENTE,SZW->ZW_LOJACLI,@_cPSB)
		ENDIF
		if !lProcOk
			aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,cNumPed,SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),"O Cliente/Remessa desse Pedido possui pedido(s) de Bonificacao sem aprovação: "+_cPSB})
		ENDIF

	EndIf

//3-Validando Limites de Crédito do pedido
	if lProcOk
		SZW->( DBSetOrder(1) )
		SZW->( DBSeek( cFilAux + cNumPed ) )

		SA1->(Dbsetorder(1))
		SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

		//-- Validação do Limite de Crédito do Cliente --//
		If lProcOk .And. ALLTRIM(SZW->ZW_TIPO) != '10' .And. !SZW->ZW_STATUS $ "E/C"

			IF _lTela
				fwmsgrun(, {|| lProcOk := AOMS112LCR( cNumPed , cFilAux,_lAutoref ) }, "Aguarde!" , "3-Validando Limites de Crédito do pedido " + cNumPed	)
			ELSE
				lProcOk := AOMS112LCR( cNumPed , cFilAux,_lAutoref )
			ENDIF

		EndIF
	Endif


//4-Valida Itens do pedido que a qtd não é multipla a Qt. Pallet do Produto
	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( cFilAux + cNumPed ) )

	SA1->(Dbsetorder(1))
	SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

	If lProcOk .And. SZW->ZW_FILIAL = '90' //.And. !AOMS112PM(cFilAux,cNumPed,@_cItensPM,@_cDetPM)

		IF _lTela
			fwmsgrun(, {|| lProcOk := AOMS112PM(cFilAux,cNumPed,@_cItensPM,@_cDetPM) }, "Aguarde!" , "4-Valida Itens do pedido que a qtd não é multipla a Qt. Pallet " + cNumPed	 )
		ELSE
			lProcOk := AOMS112PM(cFilAux,cNumPed,@_cItensPM,@_cDetPM)
		ENDIF

		If !lProcOk
			If _lautoref
				aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,cNumPed,SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),'O(s) Item(ns): '+_cItensPM+ " do Pedido possuem Qtd de venda não permitida! Atribua a Qtd do pedido um multiplo de CX do Cadastro do Produto. " + CRLF + _cDetPM})
			Else
				u_itmsg("Pedido ["+ ALLTRIM(cNumPed) +"] possui o(s) seguinte(s) item(ns): "+_cItensPM + " com Qtd de venda não permitida!" ,"Validação de Produto","Atribua a Qtd do pedido um multiplo de CX do Cadastro do Produto. " ,1)
				MsgAlert(_cDetPM,"Detalhes")
			Endif
		Endif

	EndIf

//Valida peso acima de 22.000 somente para Produto Matinais 
	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( cFilAux + cNumPed ) )

	SA1->(Dbsetorder(1))
	SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

	If lProcOk .And. AOMS112MA(cFilAux,cNumPed,@_cItensMA,@_cDetMA)

		If _lautoref
			aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,cNumPed,SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),;
				"Para o(s) Item(ns): " + _cItensMA + " do Pedido que são Matinais não é permitido que possuam peso Superior a " ;
				+ ALLTRIM(Str(_nPesoMat)) + " kg! Troque para o armazem " ;
				+ ALLTRIM(_cArmazMat) + ". " + CRLF + _cDetMA})
		Else
			u_itmsg("Para o(s) Item(ns): " + _cItensMA + " do Pedido ["+ ALLTRIM(cNumPed) ;
				+"] que são Matinais não é permitido que possuam peso Superior a " + ALLTRIM(Str(_nPesoMat)) + " kg!" ,;
				"Validação de Produto","Troque para o armazem " + ALLTRIM(_cArmazMat) + ". ",1)

			MsgAlert(_cDetMA,"Detalhes")
		Endif

		lProcOk := .F.

	EndIf

//Posiciona Pedido quando Filial 40 (Três Coraçõess) para Validar Produtos x Operação 08-VENDA COM ICMS ST PAGO ANTERIORMENTE
	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( cFilAux + cNumPed ) )

	SA1->(Dbsetorder(1))
	SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))


	If lProcOk .And. !(ALLTRIM(SZW->ZW_TIPO) $ '10/08') .And. ALLTRIM(SZW->ZW_FILIAL) = '40'

		IF _lTela
			fwmsgrun( , {|| lProcOk := AOMS1123C( cNumPed , cFilAux,_lAutoref )}, "Aguarde!", "6-Validando Pedido Operacao 08 " + cNumPed	  )
		ELSE
			lProcOk := AOMS1123C( cNumPed , cFilAux,_lAutoref )
		ENDIF

	EndIf


//Posiciona pedido e cliente para mensagens

	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( cFilAux + cNumPed ) )

	_cOper := SZW->ZW_TIPO

	SA1->(Dbsetorder(1))
	SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

	lCliBloq:=IF(SELECT("TRBF")<>0, (TRBF->BLOCLI == '1') , (SA1->A1_MSBLQL == '1'))
	If lProcOk .And. lCliBloq

		If _lautoref
			aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,cNumPed,SA1->A1_COD + "/"+SA1->A1_LOJA + " - "+ALLTRIM(SA1->A1_NOME),'Cliente/Remessa bloqueado'})
		Else
			u_itmsg("Pedido ["+ ALLTRIM(cNumPed) +"] com Cliente/Remessa bloqueado: "+SA1->A1_COD + "/"+SA1->A1_LOJA + " - "+ALLTRIM(SA1->A1_NOME),"Validação Cliente/Remessa","verifique cadastro!",1)
		Endif

		lProcOk := .F.

	EndIf

	If lProcOk .And. _cOper = "05" .And. Empty(ALLTRIM(SZW->ZW_CLIREM)) //Depois da Mudança da Op Triangular de  05 para 42. Este campo agora é o cliente de faturamento.
		If _lautoref
			aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,cNumPed,SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),'Pedido Triangular sem Código do cliente de Remessa'})
		Else
			u_itmsg("Pedido ["+ ALLTRIM(cNumPed) +"] Falta código Cliente/Venda","Triangular","Informe o Código Cliente do Cliente/Venda!",1)
		Endif

		lProcOk := .F.
	EndIf


//Valida contra pedido com condições de pagamentos diversas entre os itens se não for bonificação
	If lProcOk .and. _cOper != "10"

		IF _lTela
			fwmsgrun( , {|| lProcOk := AOMS1128( cFilAux,cNumPed,_lautoref   )}, "Aguarde!", "7-Validando condições de pagamento do pedido " + cNumPed	  )
		ELSE
			lProcOk := AOMS1128( cFilAux,cNumPed,_lautoref   )
		ENDIF

	Endif


//Locka registros
	If lProcOk .and. !( AOMS112LO( cFilAux, cNumPed ,.F.) )

		If _lautoref
			aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,cNumPed,SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),'Pedido em uso por outra estação'})
		Else
			u_itmsg("O Pedido ["+ ALLTRIM(cNumPed) +"] está sendo usado em outra estação!","Atenção",,1)
		Endif

		Return
	Endif


	If lProcOk .and. (Empty(cNumPed) .Or. Empty(cFilAux))

		If _lautoref
			aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,cNumPed,'N/C','Falha ao identificar o pedido.'})
		Else
			u_itmsg("Falha ao identificar o Pedido ["+ cNumPed +"]. Informar a área de TI/ERP","Atenção",,1)
		Endif

		lProcOk := .F.

	EndIf
//Posiciona pedido e cliente para mensagens
	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( cFilAux + cNumPed ) )

	SA1->(Dbsetorder(1))
	SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

//-- Verifica se deve executar as rotinas de Efetivação --//
	If lProcOk .And. AOMS112VEF( cNumPed , cFilAux, _lAutoref ) //Retorna false se está tudo ok

		AOMS112UN(cFilAux,cNumPed)
		RestArea(aArea)
		Return()

	EndIf

//Posiciona pedido e cliente para mensagens
	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( cFilAux + cNumPed ) )

	SA1->(Dbsetorder(1))
	SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

//-- Validação de data entrega --//
	If lProcOk

		IF _lTela
			fwmsgrun(, {|| lProcOk := AOMS112ENT( _lAutoref ) }, "Aguarde!" , "8-Validando data de entrega do pedido " + cNumPed	 )
		ELSE
			lProcOk := AOMS112ENT( _lAutoref )
		ENDIF

	EndIF

	//-- Validação da Tabela de Preços x Preços do Pedido --//
	If lProcOk .And. ALLTRIM(SZW->ZW_TIPO) != '10'
		//Posiciona pedido e cliente para mensagens
		SZW->( DBSetOrder(1) )
		SZW->( DBSeek( cFilAux + cNumPed ) )

		SA1->(Dbsetorder(1))
		SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

		IF _lTela
			fwmsgrun( , {|| lProcOk := AOMS112PRV( cNumPed , cFilAux,_lAutoref )}, "Aguarde!", "9-Validando Tabela de Preços do pedido " + cNumPed	  )
		ELSE
			lProcOk := AOMS112PRV( cNumPed , cFilAux,_lAutoref )
		ENDIF

	EndIf

//Posiciona pedido e cliente para mensagens
	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( cFilAux + cNumPed ) )

	SA1->(Dbsetorder(1))
	SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

//-- Chama a Rotina de Efetivação do Pedido se não existirem falhas de processamento --//
	If lProcOk

		lProcOk:=AOMS112PEF( cNumPed , cFilAux, _lAutoref , _lTela )

	Endif

	AOMS112UN(cFilAux,cNumPed)
	RestArea(aArea)

Return()

/*
===============================================================================================================================
Programa--------: AOMS1128
Autor-----------: Josué Danich Prestes
Data da Criacao-: 28/03/2018
===============================================================================================================================
Descrição-------: Valida pedido contra itens com condições de pagamento conflitantes
                  
===============================================================================================================================
Parametros------: _cCodFil - filial
				  				_cIdPedido - id do pedido
									_lAutoref - execução multipla de pedidos
===============================================================================================================================
Retorno---------: _lret - validação do pedido
===============================================================================================================================
*/
Static Function AOMS1128(_cCodFil,_cIdPedido,_lAutoref)
	Local _lret := .T.
	Local _ccond := ""
	Local _ccondo := ""
	Local _nni := 1
	Local _aconf := {}
	Local _ntotal  := 0
	Local _nminimo := 0
	Local _lValMinimo := .T.
	Local _cFilSalva := cFilAnt
	Default _lAutoref := .F.

	Begin Sequence

		SZW->( DBSetOrder(1) )
		SZW->( DBSeek( _cCodFil + _cIdPedido ) )

		_lValMinimo := (POSICIONE("SA3",1,xfilial("SA3")+SZW->ZW_VEND1,"A3_I_VBROK") <> 'B' )

		Do While SZW->( !EOF() ) .AND. _cCodFil + _cIdPedido == SZW->( ZW_FILIAL + ZW_IDPED )

			_ntotal += (SZW->ZW_QTDVEN * SZW->ZW_PRCVEN)

			_cCond := AOMS1125()

			_cproduto := ALLTRIM(SZW->ZW_PRODUTO) + " - " +  GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SZW->ZW_PRODUTO,1,"")

			aadd(_aconf,{strzero(val(SZW->ZW_ITEM),3),"OK",_cCond,_cproduto})

			If _nni == 1

				_ccondo := _cCond

			Elseif _ccondo != _cCond

				_aconf[len(_aconf)][2] := "DIVERGÊNCIA"
				_lret := .F.

			Endif

			_nni++
			SZW->(DbSkip())
		EndDo

		If !_lret

			If _lAutoref

				SZW->( DBSetOrder(1) )
				SZW->( DBSeek( _cCodFil + _cIdPedido ) )

				SA1->(Dbsetorder(1))
				SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

				aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),_cCodFil,_cIdPedido,SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),'Existem divergências de condição de pagamento entre os produtos'})
			Else
				U_ITListBox( 'Existem divergências de condição de pagamento entre os produtos:' , {'Item','Situação','Condição','Produto'} , _aconf , .F. , 1 )
			Endif

		Endif

		//Valida para parcelas abaixo de R$ 300,00
		_aconf := {}
		If _lret
			_cFilSalva := cFilAnt
			cFilAnt    := SZW->ZW_FILIAL
			_nminimo   := u_itgetmv("ITSZWMIN",300)
			cFilAnt := _cFilSalva

			_apars := 	Condicao(_ntotal,_cCond,0,date())
			_cobs := ""

			For _nni := 1 to len(_apars)

				_csitu := iif(_lValMinimo .And. _apars[_nni][2] < _nminimo ,"DIVERGÊNCIA","OK")

				If _csitu == "DIVERGÊNCIA"

					_lret := .F.
					_cobs += " - " + dtoc(_apars[_nni][1]) + ": " + transform(_apars[_nni][2],"@E 999,999.99")

				Endif

				aadd(_aconf,{dtoc(_apars[_nni][1]),transform(_apars[_nni][2],"@E 999,999.99"),_csitu})

			Next

			If !_lret

				If _lAutoref

					SZW->( DBSetOrder(1) )
					SZW->( DBSeek( _cCodFil + _cIdPedido ) )

					SA1->(Dbsetorder(1))
					SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

					aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),_cCodFil,_cIdPedido,SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),'Existem parcelas menores que o valor mínimo ( ' + transform(_nminimo,"@E 999,999.99")+ '):' + _cobs} )
				Else
					U_ITListBox( 'Existem parcelas menores que o valor mínimo ( ' + transform(_nminimo,"@E 999,999.99") + '):' , {'Data','Valor','Situação'} , _aconf , .F. , 1 )

				Endif

			Endif

		Endif

	End Sequence

Return _lret

/*
===============================================================================================================================
Programa--------: AOMS112VEF
Autor-----------: Alexandre Villar
Data da Criacao-: 14/02/2014
===============================================================================================================================
Descrição-------: Verifica se o pedido está liberado para Efetivação e se não tem pedido gerado
===============================================================================================================================
Parametros------: cNumPed - Número do pedido de venda do portal
----------------: cFilAux - Filial do pedido de venda
									_lAutoref - execução multipla de pedidos
===============================================================================================================================
Retorno---------: lRet    - Informa se o pedido está bloqueado
===============================================================================================================================
*/
Static Function AOMS112VEF( cNumPed , cFilAux, _lAutoref )

	Local aArea	:= GetArea()
	Local lRet	:= .F.
	Local _cMensBloq := ""

	Default _lAutoref := .T.

	DBSelectArea("SZW")
	SZW->( DBSetOrder(1) )

	If SZW->( DBSeek( cFilAux + cNumPed ) )

		SA1->(Dbsetorder(1))
		SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

		While SZW->(!Eof()) .And. SZW->( ZW_FILIAL + ZW_IDPED ) == cFilAux + cNumPed

			If !Empty(ALLTRIM(SZW->ZW_NUMPED))

				If _lAutoref

					aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(SZW->ZW_NUMPED),SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),'Já foi gerado pedido para esse registro!'})
				Else
					u_itmsg( "Já foi gerado o pedido " + SZW->ZW_FILIAL + " - " + ALLTRIM(SZW->ZW_NUMPED) + " para esse registro!" , "Atenção!" ,,1 )
				Endif

				lRet := .T.
				Exit

			Endif

			If  (SZW->ZW_TIPO $ '10/24' .OR.  SZW->ZW_TPFRETE = "F" ) .And. SZW->ZW_BLOQ != "L" .and. !(lRet)

				Do Case
				Case SZW->ZW_TPFRETE = "F"
					_cMensBloq := "BLOQUEIO FRETE FOB"
				Case SZW->ZW_TIPO = '10'
					_cMensBloq := "BLOQUEIO DE BONIFICACAO"
				Case SZW->ZW_TIPO = '24'
					_cMensBloq := "BLOQUEIO DATA CRITICA"
				Otherwise
					_cMensBloq := "BLOQUEIO INEXISTENTE"
				EndCase

				Reclock("SZW",.F.)
				SZW->ZW_I_MOTBL := _cMensBloq
				SZW->ZW_DTAVAC := DATE()
				SZW->ZW_HRAVAC := TIME()
				SZW->(Msunlock())

				If _lAutoref
					aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME), ALLTRIM(_cMensBloq)})
				Else
					u_itmsg( "Não é possível efetivar com" + _cMensBloq + " Pedido Nr " + ALLTRIM(cNumPed) , "Atenção" , ,1 )
				Endif

				lRet := .T.

				Exit

			EndIf

			If SZW->ZW_BLQLCR == "B" .and. !(lRet) //Bloqueio de Crédito

				If _lAutoref

					aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),'Pedido com bloqueio de crédito'})

				Else
					u_itmsg( "Não é possível efetivar um Pedido Bloqueado Crédito.[" + ALLTRIM(cNumPed) + "]" , "Atenção!" , ,1 )
				Endif

				lRet := .T.

				Exit

			EndIf

			If SZW->ZW_BLQLCR == "R" .and. !(lRet)  //Crédito Rejeitado

				If _lAutoref

					aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),'Pedido com rejeição de crédito'})
				Else
					u_itmsg( "Não é possível efetivar um Pedido Rejeitado Crédito.[" + ALLTRIM(cNumPed) + "]" , "Atenção!" , ,1 )
				Endif

				lRet := .T.
				Exit

			EndIf


			If (SZW->ZW_BLOPRC == 'B' .OR. SZW->ZW_BLOPRC == 'R') .and. !(lRet)

				If _lAutoref

					aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),'Pedido com bloqueio ou recusa de preço'})
				Else
					u_itmsg( "Não é possível efetivar um Pedido com Preço Bloqueado ou Recusado.[" + ALLTRIM(cNumPed) + "]" , "Atenção!" , ,1 )
				Endif

				lRet := .T.
				Exit

			EndIf


			SZW->( DBSkip() )
		EndDo

	EndIf

	RestArea(aArea)

Return( lRet )

/*
===============================================================================================================================
Programa--------: AOMS112LCR
Autor-----------: Alexandre Villar
Data da Criacao-: 14/02/2014
===============================================================================================================================
Descrição-------: Valida Limite de Crédito do Cliente para Efetivação do Pedido de Venda.
===============================================================================================================================
Parametros------: cNumPed - Número do pedido de venda do portal
----------------: cFilAux - Filial do pedido de venda
									_lAutoref - execução de múltiplos pedidos
===============================================================================================================================
Retorno---------: lRet    - Informa o resultado da validação
===============================================================================================================================
*/
Static Function AOMS112LCR( cNumPed , cFilAux, _lAutoref )

	Local aAreaAux	:= GetArea()
	Local lOk		:= .T.
	Local cCodCli	:= ""
	Local cLojCli	:= ""
	Local lbq := .F.

	Local _nTotped   := 0
	Local _aRetCre   := _cRetDes := _cRetSta := _cRetTip := _cRetDesC:= ""
	Local _cGerente, _cCoordena, _cSupervis, _cRepresen
	Local _cRetMsg, _aOrd, _nRegSA3
	Default _lAutoref := .F.

	If Empty(cNumPed) .Or. Empty(cFilAux)

		If _lAutoref
			aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,cNumPed,"N/C",'Falha ao identificar o pedido'})
		Else
			u_itmsg( "Falha ao identificar o Pedido.","Atenção","Informar a área de TI/ERP:[AOMS112003]" ,  1 )
		Endif
		lOk := .F.

	Else

		//-- Posiciona na Tabela de Pedidos do Portal --//
		DbSelectArea("SZW")
		SZW->( DbSetOrder(1) )
		If SZW->( DbSeek( cFilAux + cNumPed ) ) .and. lOk

			//-- Recupera Código/Loja do Cliente --//
			cCodCli := SZW->ZW_CLIENTE
			cLojCli	:= SZW->ZW_LOJACLI

			_cGerente  := " "
			_cCoordena := " "
			_cSupervis := " "
			_cRepresen := " "
			_aOrd      :=  SaveOrd({"SA3"})
			_nRegSA3   := SA3->(Recno())

			SA3->(DbSetOrder(1))

			If !Empty(SZW->ZW_VEND1)

				_cRepresen := SZW->ZW_VEND1

				If ! SA3->(DbSeek(xFilial("SA3")+_cRepresen))

					If _lAutoref
						SA1->(Dbsetorder(1))
						SA1->(Dbseek(xfilial("SA1")+cCodCli+cLojCli))
						aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),"O código de representante " + _cRepresen + " não está cadastrado no cadastro de Vendedores."})
					Else
						U_ItMsg("O código de representante não está cadastrado no cadastro de Vendedores.","Atenção!" ,_cRepresen ,1 )
					Endif

					lOk := .F. //Retorna .F. para controle de processamento da rotina
					lBq := .T. //Seta .T. na variável de Controle de Bloqueio de Pedidos

				EndIf

			Else

				If _lAutoref

					SA1->(Dbsetorder(1))
					SA1->(Dbseek(xfilial("SA1")+cCodcli+cLojCli))

					aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),"O código de representante não está preenchido"})
				Else
					U_ItMsg("O código de representante não está preenchido.","Atenção!" , ,1 )
				Endif

				lOk := .F. //Retorna .F. para controle de processamento da rotina
				lBq := .T. //Seta .T. na variável de Controle de Bloqueio de Pedidos

			EndIf

			If lOk

				If !Empty(SA3->A3_SUPER) // SZW->ZW_VEND2
					_cCoordena := SA3->A3_SUPER
				EndIf

				If !Empty(SA3->A3_GEREN) // SZW->ZW_VEND3
					_cGerente  := SA3->A3_GEREN
				EndIf

				If !Empty(SA3->A3_I_SUPE) // SZW->ZW_VEND4
					_cSupervis := SA3->A3_I_SUPE

				EndIf

			EndIf

			RestOrd(_aOrd)
			SA3->(DbGoTo(_nRegSA3))

			If lOk

				//-- Posiciona no Cliente Atual (Cód.+Loja) para recuperar o Código do Risco e a Validade do Limite de Crédito --//
				DBSelectArea("SA1")
				SA1->( DBSetOrder(1) )

				If SA1->( DBSeek( xFilial("SA1") + cCodCli + cLojCli ) )

					IF ALLTRIM(SZW->ZW_TIPO) != '10' //Não valida para bonificação

						_nTotped := U_AOMS112Y( cCodCli , cLojCli , cNumPed )

						_aRetCre := U_ValidaCredito( _nTotped , cCodCli , cLojCli , .T., {|| SZW->ZW_BLQLCR == "C" }, SZW->ZW_LIBL, _nTotped, 1,," ", _cGerente, _cCoordena, _cSupervis, _cRepresen, SZW->ZW_CONDPAG)

						_cRetDes := _aRetCre[1]// Descricoes da avaliaçãode credito
						_cRetSta := _aRetCre[2]// "B" , "L"
						_cRetTip := _aRetCre[3]// 1=Limite Expirado ; 2=Atraso Titulos ; 3=Limite Excedido ; 4=Risco ; 5=Automatico

						IF LEN(_aRetCre) > 3
							_cRetDesC:= " - "+_aRetCre[4]// Complemento da descricoes da avaliação de credito
						ELSE
							_cRetDesC:= ""
						ENDIF

						lOk := .T.

						IF _cRetSta = "B"

							If U_AOM112GA( cNumPed , cFilAux , _cRetSta , _cRetTip , _cRetDes+_cRetDesC,,_nTotped ) // 1=Limite Expirado;2=Atraso Titulos;3=Limite Excedido;4=Risco;5=Automatico
								_cRetMsg := Upper(_cRetDes)

								If "INATIVO" $ _cRetMsg
									If _lAutoref
										aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),_cRetDes})
									Else
										u_itmsg(_cRetDes + CRLF + CRLF + _cRetDesC,"Atenção!" , ,1 )
									Endif
								Else
									If _lAutoref
										aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),"O pedido atual será " + _cRetDes})
									Else
										u_itmsg("O pedido atual será " + _cRetDes + CRLF + CRLF + _cRetDesC,"Atenção!" , ,1 )
									Endif
								EndIf

								lOk := .F. //Retorna .F. para controle de processamento da rotina
								lBq := .T. //Seta .T. na variável de Controle de Bloqueio de Pedidos

							ENDIF

						EndIf

					EndIf

				Endif


			ElseIf !SA1->( DBSeek( xFilial("SA1") + cCodCli + cLojCli ) )

				If _lAutoref
					aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),cCodcli+"/"+cLojCli,"Falha ao posicionar no Cliente/Remessa para validação do Limite de Crédito."})
				Else
					u_itmsg( "Falha ao posicionar no Cliente/Remessa para validação do Limite de Crédito.", "Atenção! ","Informar a área de TI/ERP"  , 1 )
				Endif

				lOk := .F. //Retorna .F. para controle de processamento da rotina

			EndIf//If SA1->( DBSeek( xFilial("SA1") + cCodCli + cLojCli ) )

		Else//If SZW->( DbSeek( cFilAux + cNumPed ) ) .and. lok

			If _lAutoref
				aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),"N/C","Falha ao posicionar no Pedido para validação do Limite de Crédito.."})
			Else
				u_itmsg( "Falha ao posicionar no Pedido para validação do Limite de Crédito.", "Atenção!","Informar a área de TI/ERP"   ,1 )
			Endif
			lOk := .F. //Retorna .F. para controle de processamento da rotina

		EndIf//If SZW->( DbSeek( cFilAux + cNumPed ) ) .and. lok

	EndIf

	RestArea(aAreaAux)

	If lBq //Atualiza o bloqueio de crédito do browse posicionado

		IF SELECT("TRBF") <> 0
			TRBF->( Reclock( "TRBF", .F. ) )
			TRBF->BLQLCR := "B"
			TRBF->( MsUnlock() )
		ENDIF

	Endif

Return( lOk )

/*
===============================================================================================================================
Programa--------: AOMS112PRV
Autor-----------: Erich Buttner
Data da Criacao-: 09/09/2010
===============================================================================================================================
Descrição-------: Valida Preço de Venda dos Itens do Pedido do Portal
===============================================================================================================================
Parametros------: cNumPed   := Código do Pedido
----------------: cFilAux   := Filial do Pedido
				  _lAutoref := Execução de pedidos múltiplos
===============================================================================================================================
Retorno---------: lRet := Informa se validou os preços do pedido
===============================================================================================================================
*/
Static Function AOMS112PRV( cNumPed , cFilAux, _lAutoref )
	Local aAreaAux	:= GetArea()
	Local lOk		:= .T.
	Local _lret  	:= .T.
	Local lbq       := .F.
	Local _nPesoBrutoPedido := 0
	Local _nPesoParam := U_ITGETMV( "IT_PESOFEC",4000)
	Local _cTpVenda := ""
	Local _nPrecoTabela := 0
	Local _lBlqPrc  := .F.
	Local _cCoord   := ""
	Local _cWF      := ""
	Local _lSimplNac :=  .F.
	Local _aBlqprc := {}

	_cFilSalva  := cFilAnt
	cFilAnt     := SZW->ZW_FILIAL
	cFilAnt     := _cFilSalva

	_cTpVenda := SZW->ZW_TPVENDA

	_nPesoBrutoPedido := AOMS112PES(cFilAux,cNumPed)

	If Empty(ALLTRIM(_cTpVenda))
		_cTpVenda := "F" //Carga Fechada
		If _nPesoBrutoPedido <= _nPesoParam
			_cTpVenda := "V" //Carga Fracionada (Varejo)
		EndIf
	EndIf

	If _cTpVenda = "F" .And. _nPesoBrutoPedido <= _nPesoParam //Quando Carga Fechada o Peso do Pedido tem que ser maior que o Parâmetro definido
		If _lAutoref
			aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SZW->ZW_CLIENTE + " " + SZW->ZW_LOJACLI,"Tipo de Vendas Carga Fechada, nao Permitido para Pedido com Peso Menor que " + ALLTRIM(Transform(_nPesoParam,"@E 99,999.99")) ,"Verifique o Pedido com Peso igual " + ALLTRIM(Transform(_nPesoBrutoPedido,"@E 99,999.99")) })
		Else
			u_itmsg("Tipo de Vendas Carga Fechada, nao Permitido para Pedido com Peso Menor que " + ALLTRIM(Transform(_nPesoParam,"@E 99,999.99")) ,"Atenção","Verifique o Pedido com Peso igual " + ALLTRIM(Transform(_nPesoBrutoPedido,"@E 99,999.99")) ,1)
		Endif
		_lRet := .F.
		lok := .F.
	EndIF

	SZW->(DbSetOrder(1))
	If SZW->(DbSeek(cFilAux + cNumPed))

		If ( SZW->ZW_BLOPRC == "B" .Or. Empty(ALLTRIM(SZW->ZW_BLOPRC))) .And. _lRet

			_cvend2 := Posicione("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_SUPER")
			_cvend3 := Posicione("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_GEREN")

			If SZW->ZW_FILPRO != '0 ' .and. !empty(SZW->ZW_FILPRO) .and. SZW->ZW_FILPRO != SZW->ZW_FILIAL

				_cfilpro := SZW->ZW_FILPRO

			Else

				_cfilpro := SZW->ZW_FILIAL

			Endif

			_cTab	:= SZW->ZW_TABELA

			//======================================================
			//Valida tabela de preços selecionada
			//======================================================
			DA0->(Dbsetorder(1))
			If !(DA0->(Dbseek(xFilial("DA0")+_ctab)))
				If _lAutoref
					aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SZW->ZW_CLIENTE + " " + SZW->ZW_LOJACLI,"Tabela de preços " + _cTab + " não localizada!"})
				Else
					u_itmsg("Tabela de preços " + _cTab + " não localizada!","Atenção","Verifique regras de tabelas de preço",1)
				Endif
				_lret := .F.
				lok := .F.
			Else //Encontrou Tabela de Preço DA0010


				SA1->(Dbsetorder(1))
				SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

				_lSimplNac  :=IF(SA1->A1_SIMPNAC="1",.T.,.F.)

				Do while SZW->ZW_FILIAL == cFilAux .AND. SZW->ZW_IDPED == cNumPed
					DA1->(Dbsetorder(1))
					If DA1->(Dbseek(xFilial("DA1")+SZW->ZW_TABELA+SZW->ZW_PRODUTO))
						IF SZW->ZW_TPVENDA == "F"
							_nPrecoTabela := DA1->DA1_PRCVEN
						Else
							_nPrecoTabela := DA1->DA1_I_PRFE
						EndIf

						IF SZW->ZW_PRUNIT < _nPrecoTabela .And. SZW->ZW_PRCVEN < _nPrecoTabela .And. SZW->ZW_KIT == ' ' 

							_aBlqprc := U_BLQPRC(SZW->ZW_PRODUTO,SZW->ZW_PRCVEN,       cFilAux,   .F.,         _cTab,    .T.,      .T.,        .T.,           ,         ,SA1->A1_EST,,     _cTpVenda,_lSimplNac,_nPesoBrutoPedido,SZW->ZW_I_FXPES)

							_lbloq   := _aBlqprc[1]
							If (_lbloq)
								_lret := .F.
								_lBlqPrc  := .T.

								Reclock("SZW",.F.)
								SZW->ZW_PRUNIT := _nPrecoTabela
								SZW->(Msunlock())

							Endif
						EndIF

					Else
						If _lAutoref
							aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SZW->ZW_CLIENTE + " " + SZW->ZW_LOJACLI,"Item não Localizado na Tabela de preços " + _cTab + " não localizada!"})
						Else
							u_itmsg(" Item: " + SZW->ZW_PRODUTO + " Tabela: " + _cTab + " não localizada!","Atenção","Verifique regras de tabelas de preço",1)
						Endif
						_lret := .F.
						lok  := .F.
					EndIF
					SZW->(Dbskip())

				Enddo

			Endif
			If _lBlqPrc

				DBSelectArea("SZW")
				SZW->( DBSetOrder(1) )

				If SZW->( DBSeek( cFilAux + cNumPed ) )
					_cCoord:= posicione("SA3",1,xfilial("SA3")+SZW->ZW_VEND1,"A3_SUPER")
					_cWF   := posicione("SA3",1,xfilial("SA3")+_cCoord,"A3_I_WF")
					While SZW->(!Eof()) .And. SZW->( ZW_FILIAL + ZW_IDPED ) == cFilAux + cNumPed

						Reclock("SZW",.F.)
						If _cWF == "2"
							SZW->ZW_BLOPRC  := ' '
							SZW->ZW_STATUS  := 'L'
							SZW->ZW_ENVWF   := 'C'
							SZW->ZW_NIVELWF := 'P'
							SZW->ZW_I_HTML  := ' '
							SZW->ZW_OBSAVAC := ' '
							SZW->ZW_DATAAPR := ' '
							SZW->ZW_BLQLCR  := ' '
							SZW->ZW_I_OBS   := ' '
							SZW->ZW_MOTLP   := ' '
						Else
							SZW->ZW_BLOPRC  := ' '
							SZW->ZW_STATUS  := 'A'
							SZW->ZW_ENVWF   := ' '
							SZW->ZW_NIVELWF := ' '
							SZW->ZW_I_HTML  := ' '
							SZW->ZW_OBSAVAC := ' '
							SZW->ZW_DATAAPR := ' '
							SZW->ZW_BLQLCR  := ' '
							SZW->ZW_I_OBS   := ' '
							SZW->ZW_MOTLP   := ' '
						EndIF
						SZW->(Msunlock())
						SZW->(Dbskip())
					EndDo

				Endif
			EndIF
			//Desfaz lock nos registros
			AOMS112UN(cFilAux,cNumPed)

			If !_lret

				If _lAutoref //Qdo marca vários

					SZW->( DbSetOrder(1) )
					SZW->( DbSeek( cFilAux + cNumPed ) )

					SA1->(Dbsetorder(1))
					SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

					aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),"Existe(m) item(ns) cujo(s) preço(s) informado(s) está(ão) fora da tabela de preços praticada pela empresa."})
				Else
					u_itmsg("Existe(m) item(ns) cujo(s) preço(s) informado(s) está(ão) fora da tabela de preços praticada pela empresa. ","Validação de preços",;
						"O pedido será marcado como bloqueado para posterior avaliação.", 1	)
				Endif

				lok := .F.
				lBq := .T. //Seta .T. na variável de Controle de Bloqueio de Pedidos

			EndIf

		EndIf

	Else

		If _lAutoref

			SZW->( DbSetOrder(1) )
			SZW->( DbSeek( cFilAux + cNumPed ) )

			SA1->(Dbsetorder(1))
			SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

			aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SA1->A1_COD + "/"+SA1->A1_LOJA + " - "+ALLTRIM(SA1->A1_NOME),"Existe(m) item(ns) cujo(s) preço(s) informado(s) está(ão) fora da tabela de preços praticada pela empresa."})
		Else

			u_itmsg( "Falha ao posicionar no Pedido para validação de Preços.", "Atenção!","Informar a área de TI/ERP" , 1 )

		Endif
		lOk := .F. //Retorna .F. para controle de processamento da rotina
	EndIf

	RestArea(aAreaAux)

Return( lOk )

/*
===============================================================================================================================
Programa--------: AOMS112PEF
Autor-----------: Erich Buttner
Data da Criacao-: 09/09/2010
===============================================================================================================================
Descrição-------: Validações pré-efetivação dos pedidos de vendas do portal
===============================================================================================================================
Parametros------: cNumPed - Número do pedido de venda do portal
----------------: cFilAux - Filial do pedido de venda
									_lAutoref - Execução de múltiplas efetivações
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112PEF( CPED , cFlVer, _lAutoref , _lTela)

	Local cTitulo	:= "Efetivação de Pedidos Portal"
	Local lRetMod2  := .F. // Retorno da função Modelo2 - .T. Confirmou / .F. Cancelou
	Local lBLQLCR	:= .F. // Variavel que identifica bloqueio por Limite de Credito [Chamado: 5413]
	Local nLinha	:= 0
	Local _lRet 	:= .T.
	Local _nRegAtu, _aOrd  , nColuna
	Local lbq := .F.

	Default _lAutoref := .F.

	Private _nPosLocal, _nPosProd, _nPosItem

	Public nOpcx	:= 6

	nUsado	:= 0
	aHeader	:= {}
	aCols	:= {}
	cDescr	:= ""
	nQtd2UM	:= 0
	c2UM	:= ""
	nVlrTot	:= 0
	nVTot	:= 0

	// Montagem do aHeader
	aHeader := {	{ "Item"		  	, "ZW_ITEM"		, "@!"					, 010 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
		{ "Produto"	  		, "ZW_PRODUTO"	, "@!"					, 015 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
		{ "Descrição"	  	, "cDescr" 		, "@!"					, 020 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
		{ "Qtd Ven 2 UM"  	, "nQtd2UM"		, "@e 999,999,999.99"	, 014 , 2 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
		{ "Segunda UM"	   	, "c2UM"		, "@!"					, 002 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
		{ "Quantidade"		, "ZW_QTDVEN"	, "@e 999,999,999.99"	, 014 , 2 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
		{ "Unidade"		   	, "ZW_UM"		, "@!"					, 002 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
		{ "Prc Unitario" 	, "ZW_PRCVEN"	, "@e 9,999,999.9999"	, 014 , 4 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
		{ "Vlr.Total "		, "nVlrTot"		, "@e 999,999,999.99"	, 014 , 2 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
		{ "Blq. Preço "		, "ZW_BLOPRC"	, "@!"					, 001 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" },;
		{ "Local "		    , "ZW_LOCAL"	, "@!"					, 002 , 0 , "AllwaysTrue()" , "" , "C" , "" , "R" } }

	_nPosLocal := Ascan(aHeader,{|x| x[2] = "ZW_LOCAL"})
	_nPosProd  := Ascan(aHeader,{|x| x[2] = "ZW_PRODUTO"})
	_nPosItem  := Ascan(aHeader,{|x| x[2] = "ZW_ITEM"})

	_aButtons := {}
	AADD(_aButtons,{"Alt.Armazem",{|| U_AOMS112B(N,_nPosLocal,_nPosProd) },"Altera Armazem","Altera Armazem"})

	DBSELECTAREA("SZW")
	SZW->( DbSetOrder(1) )
	IF SZW->( DbSeek( cFlVer + CPED ) )

		// Montagem do aCols
		While SZW->( !Eof() ) .AND. SZW->( ZW_FILIAL + ZW_IDPED ) == cFlVer + CPED

			AADD( aCols , Array( Len(aHeader) + 1 ) )
			nLinha++

			cDescr		:= GetAdvFVal( "SB1" , "B1_I_DESCD"	, xFilial("SB1") + ALLTRIM( SZW->ZW_PRODUTO )	, 1 , "" )
			nFatConv	:= GetAdvFVal( "SB1" , "B1_CONV"	, xFilial("SB1") + SZW->ZW_PRODUTO				, 1 , "" )
			cTpConv		:= GetAdvFVal( "SB1" , "B1_TIPCONV"	, xFilial("SB1") + SZW->ZW_PRODUTO				, 1 , "" )
			nNewFat		:= GetAdvFVal( "SB1" , "B1_I_FATCO"	, xFilial("SB1") + SZW->ZW_PRODUTO				, 1 , "" )

			If cTpConv == "M"
				nQtd2UM	:= IIf( nFatConv == 0 , nNewFat * SZW->ZW_QTDVEN , nFatConv * SZW->ZW_QTDVEN )
			Else
				nQtd2UM	:= IIf( nFatConv == 0 , SZW->ZW_QTDVEN / nNewFat , SZW->ZW_QTDVEN / nFatConv )
			EndIf

			c2UM		:= GetAdvFVal( "SB1" , "B1_SEGUM" , xFilial("SB1") + ALLTRIM( SZW->ZW_PRODUTO ) , 1 , "" )
			nVlrTot		:= SZW->ZW_QTDVEN * SZW->ZW_PRCVEN
			nVtot		+= nVlrTot

			For nColuna := 1 to Len(aHeader)
				aCols[nLinha][nColuna] := &( aHeader[nColuna][2] )
			Next nColuna

			aCols[nLinha][Len(aHeader)+1] := .F. // Linha não deletada

			SZW->( DBSkip() )
		EndDo

		cFli		:= Space(20)
		cFilPro		:= Space(040)
		cTipPed		:= Space(15)
		cNumPed		:= Space(25)
		cVincula    := Space(1)
		cCliente	:= Space(06)
		cNomCli		:= Space(60)
		cLojaCli	:= Space(04)
		cGrpCli		:= Space(30)
		cCond		:= Space(50)
		cVend1		:= Space(06)
		cNmVend1	:= Space(40)
		cVend2		:= Space(06)
		cNmVend2	:= Space(40)
		cPedCli		:= Space(09)
		dDtEnt		:= CtoD("")
		cTipoAg     := Space(10)
		cHrEnt		:= Space(05)
		cSha		:= Space(14)
		cTipFre	:= Space(10)
		cTipCar	:= Space(15)
		cQtdCha	:= Space(03)
		cHrDes		:= Space(05)
		nCusDes	:= 0
		cObsCom	:= Space(300)
		cObsNF	:= Space(300)

		DBSELECTAREA("SZW")
		SZW->( DBSetOrder(1) )
		SZW->( DbSeek( SubStr( cFlVer , 1 , 2 ) + CPED ) )

		csuper := posicione("SA3",1,xfilial("SA3")+SZW->ZW_VEND1,"A3_I_SUPE")
		_ccoord  := SA3->A3_SUPER
		_cgeren := SA3->A3_GEREN

		ctabela := SZW->ZW_TABELA + " - " + posicione("DA0",1,xFilial("DA0")+SZW->ZW_TABELA,"DA0_DESCRI")

		SZW->( DbSeek( SubStr( cFlVer , 1 , 2 ) + CPED ) )

		dDtEnt		:= SZW->ZW_FECENT
		_laltera := .T.

		If SZW->ZW_I_AGEND == 'P'

			//cTipoAg		:= SZW->ZW_I_AGEND+" - AGUARD AGENDA"

			If month(date()) != 12

				dDtEnt := STOD(ALLTRIM(STR((YEAR(DATE())+1)))+"0101")-1

			Else

				dDtEnt := STOD(ALLTRIM(STR((YEAR(DATE())+2)))+"0101")-1

			Endif

			_laltera := .F.

		Endif

		If SZW->ZW_I_AGEND $ 'I/O'//I=Imediata //O=Agendada pelo Op.Log.
			_cFilCarreg := SZW->ZW_FILIAL
			If !EMPTY(SZW->ZW_FILPRO) .AND. !(ALLTRIM(SZW->ZW_FILPRO)=='0')
				_cFilCarreg := SZW->ZW_FILPRO
			EndIf

			//cTipoAg		:= SZW->ZW_I_AGEND+" - IMEDIATO"
			dDtEnt 		:=  SZW->ZW_FECENT
			_laltera := .F.
		Endif

		//If SZW->ZW_I_AGEND == 'M'
		//	cTipoAg		:= SZW->ZW_I_AGEND+" - AGENDADA COM MULTA"
		//Endif
		//If SZW->ZW_I_AGEND == 'A'
		//	cTipoAg		:= SZW->ZW_I_AGEND+" - AGENDADA"
		//Endif
    
	    cTipoAg:=SZW->ZW_I_AGEND+" - "+(U_TipoEntrega(SZW->ZW_I_AGEND))

    If !_lAutoref //Se é execução múltipla não apresenta tela de modelo2

		//====================================================================================================
		// aC[n,1] = Nome da Variavel Ex.:"cCliente"
		// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
		// aC[n,3] = Titulo do Campo
		// aC[n,4] = Picture
		// aC[n,5] = Validacao
		// aC[n,6] = F3
		// aC[n,7] = Se campo e' editavel .t. se nao .f.
		//====================================================================================================
		_cVal3:=" U_AOM112Val('cTipPed',LEFT(cFilPro,2),LEFT(cFli,2)) "
		aC := {	{ "cFli"	,{015,003} 	,"Filial                   "   		,"@!"   				,	, "SM0" ,.F. 	},;
			{ "cFilPro" 	,{015,203} 	,"Filial Carregamento   "        	,"@!"   				,   , "SM0" ,.F.	},;
			{ "cVincula" 	,{030,423} 	,"Vincula Pedido? "              	,"@!"   				,   ,       ,.T.	},;
			{ "cTipPed"		,{030,003} 	,"Tipo Pedido       " 	  			,"@!"   				,_cVal3,"ZB4",.F. 	},;//editavel se TRBF->TIPO == '01' .or. TRBF->TIPO == '03'
		    { "cNumPed"		,{030,203} 	,"Num. Pedido " 	  				,"@!"   				,	,		,.F.	},;
			{ "cCliente"	,{045,003} 	,"Cliente/Remessa" 	 				,"@!"   				,	,		,.F.	},;
			{ "cLojaCli"	,{045,085} 	,"Loja   "							,"@!"   				,	,		,.F.	},;
			{ "cNomCli"		,{045,140} 	,"Nome Cliente/Remessa"				,"@!"   				,	,		,.F.	},;
			{ "cGrpCli"		,{060,003} 	,"Grupo Cliente/Rem."				,"@!"   				,	,		,.F.	},;
			{ "cCond"		,{060,285} 	,"Cond. Pagto" 						,"@!"   				,	,		,.F.	},;
			{ "cVend1"		,{075,003} 	,"Vendedor 1       "  				,"@!"   				,	,		,.F.	},;
			{ "cNmVend1"	,{075,140} 	,"Nome Vendedor 1" 					,"@!"   				,	,		,.F.	},;
			{ "nVTot"		,{075,500} 	,"Valor Total   " 					,"@e 999,999,999.99"	,	,		,.F.	},;
			{ "cVend2"		,{090,003} 	,"Vendedor 2       "  				,"@!"   				,	,		,.F.	},;
			{ "cNmVend2"	,{090,140} 	,"Nome Vendedor 2" 					,"@!"   				,	,		,.F.	},;
			{ "cPedCli"		,{105,003} 	,"Pedido Cliente/Remessa    "		,"@!"   				,	,		,.F.	},;
			{ "dDtEnt"		,{015,500} 	,"Data Entrega          "			,"@!"   				,	,		,_laltera 	},;//editavel
		    { "cTipoAg"		,{030,500}	,"Tipo Agendamento"					,"@!"   				,	,		,.F.	},;
			{ "cHrEnt"		,{105,245} 	,"Hora Entrega   "					,"@E 99:99 "   			,	,		,.T. 	},;//editavel
		    { "cSha"		,{105,325} 	,"Senha                "			,"@!"   				,	,		,.F.	},;
			{ "cTipFre"		,{105,500} 	,"Tipo Frete    "					,"@!"   				,	,		,.F.	},;
			{ "cTipCar"		,{120,003} 	,"Tipo de Carga      "				,"@!"   				,	,		,.F.	},;
			{ "cQtdCha"		,{120,140} 	,"Qtd. Chapa           "			,"@!"   				,	,		,.F.	},;
			{ "cHrDes"		,{120,245} 	,"Hora Descarga"					,"@!"   				,	,		,.F.	},;
			{ "nCusDes"		,{120,325} 	,"Custo Descarga"					,"@e 999,999,999.99"	,	,		,.F.	},;
			{ "ctabela"		,{120,430} 	,"Tabela Preço"						,"@!"					,	,		,.F.	},;
			{ "cObsCom"		,{135,003} 	,"Obs. Comercial  "					,"@!"					,	,		,.F.	},;
			{ "cObsNf"		,{150,003} 	,"Mensagem NF    "					,"@!"					,	,		,.F.	} }

		AADD(aC,{"cVECliente",{165,003},"Cliente / Venda" 	 	    ,"@!",,,.F.})
		AADD(aC,{"cVELojaCli",{165,085},"Loja   "					,"@!",,,.F.})
		AADD(aC,{"cRENomCli" ,{165,140},"Nome Cliente/Venda        ","@!",,,.F.})

		// Tratamento da Operação Triangular
		//====================================================================================================
		// Array com descricao dos campos do Rodape do Modelo 2
		// aR[n,1] = Nome da Variavel Ex.:"cCliente"
		// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
		// aR[n,3] = Titulo do Campo
		// aR[n,4] = Picture
		// aR[n,5] = Validacao
		// aR[n,6] = F3
		// aR[n,7] = Se campo e' editavel .t. se nao .f.
		//====================================================================================================
		//Define se pode editar tipo do pedido
		If SZW->ZW_TIPO == '01' .or. SZW->ZW_TIPO == '03'
			aC[3,7] := .T.
		Endif
	ENDIF
	
		aR := {}

		DBSELECTAREA("SZW")
		SZW->( DBSetOrder(1) )
		SZW->( DbSeek( cFlVer + CPED ) )

		cFli		:= Left(SubStr(cFlVer,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(cFlVer,1,2),1,""),25)
		cFilPro		:= IF(!EMPTY(SZW->ZW_FILPRO), SubStr( SZW->ZW_FILPRO , 1 , 2 ) +" - "+ GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(SZW->ZW_FILPRO,1,2),1,"")  , SPACE(LEN(cFli)) )
		cTipPed		:= SUBSTR(SZW->ZW_TIPO+" - "+GetAdvFVal("ZB4","ZB4_DESCRI",xFilial("ZB4")+SZW->ZW_TIPO,1,""),1,25)


		cNumPed  	:= CPED
		cCliente 	:= SZW->ZW_CLIENTE
		cLojaCli 	:= SZW->ZW_LOJACLI
		cVincula    := "N"
		cNomCli 	:= GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,1,"")
		cGrpCli		:= GetAdvFVal("SA1","A1_GRPVEN",xFilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,1,"")+" - "+GetAdvFVal("SA1","A1_I_NGRPC",xFilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,1,"")
		cCond		:= AOMS1125()
		cVend1	 	:= SZW->ZW_VEND1
		cNmVend1 	:= GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+SZW->ZW_VEND1,1,"")
		cVend2   	:= SZW->ZW_VEND2
		cNmVend2 	:= GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+SZW->ZW_VEND2,1,"")
		nVTot 		:= nVTot
		cPedCli		:= SZW->ZW_PEDCLI

		cHrEnt		:= SZW->ZW_HOREN
		cSha		:= SZW->ZW_SENHA
		cTipFre	  	:= IF(SZW->ZW_TPFRETE == 'C',SZW->ZW_TPFRETE+" - CIF",SZW->ZW_TPFRETE+" - FOB")
		_cchep 		:= posicione("SA1",1,XFILIAL("SA1")+ccliente+cLojaCli,"A1_I_CCHEP")
		cTipCar		:= IF( !empty(_cchep) , "1 - Paletizada" , "2 - Batida" )
		cQtdCha	  	:= SZW->ZW_CHAPA
		cHrDes		:= SZW->ZW_HORDES
		nCusDes	  	:= SZW->ZW_CUSDES
		cObsCom	  	:= SZW->ZW_OBSCOM
		cObsNF		:= SZW->ZW_MENNOTA
		cVECliente 	:= SZW->ZW_CLIREM
		cVELojaCli 	:= SZW->ZW_LOJEN

		cRENomCli	:= Iif(EMPTY(SZW->ZW_CLIREM),"  ",POSICIONE("SA1",1,xfilial("SA1")+SZW->ZW_CLIREM+SZW->ZW_LOJEN,"A1_NOME"))

		aCGD		:= { 350 , 06 , 26 , 74 } // Array com coordenadas da GetDados no modelo2


		//====================================================================================================
		// Verificação de bloqueio de crédito e bonificação
		//====================================================================================================

		_aItensLock:={}
		DBSelectArea("SZW")
		SZW->( DBSetOrder(1) )
		SZW->( DBSeek( cFlVer + cNumPed ) )
		While SZW->( !Eof() ) .And. SZW->( ZW_FILIAL + ZW_IDPED ) == cFlVer + cNumPed

			If SZW->ZW_TIPO == "05"
				SZW->(RecLock("SZW",.F.))
				SZW->ZW_TIPO:=cTipPed:=cTp:="42"
				SZW->(MsUnlock())
			ENDIF

			If SZW->ZW_BLQLCR == "B"
				lBLQLCR := .T.
				Exit
			EndIF

			SZW->( DBSkip() )
		EndDo
		_lRet:=!lBLQLCR
		//====================================================================================================
		// Realiza o processamento de Preço somente se ja estiver liberado no Credito
		//====================================================================================================
		If !lBLQLCR

			If _lAutoref //Se é execução múltipla não apresenta tela de modelo2

				_lRet:=lRetMod2 := .T.

			Else
				//( cTitulo , aC , aR , aGd  , nOp   ,cLinhaOk,cTudoOk ,aGetsD,bF4,cIniCpos,nMax,aCordW,lDelGetD,lMaximazed ] [ aButtons ] )
				_lRet:=lRetMod2 := Modelo2( cTitulo , aC , aR , aCGD , nOpcx ,        ,        , aR   ,   ,        ,9999,      ,        , .T. ,_aButtons)

			Endif

			If lRetMod2
				//===============================================================================================
				// GRAVAÇÃO DOS DADOS DO ARMAZEM
				//===============================================================================================
				_nRegAtu := SZW->(Recno())
				_aOrd    := SaveOrd({"SZW"})
				SZW->( DbSetOrder(1) ) // ZW_FILIAL+ZW_IDPED
				IF SZW->( DbSeek( cFlVer + CPED ) )
					Do While !SZW->(Eof()) .And. SZW->(ZW_FILIAL+ZW_IDPED) == cFlVer + CPED
						_nI := AsCan(aCols,{|x| x[_nPosItem] == SZW->ZW_ITEM})  // _nPosLocal // ZW_ITEM
						If _nI > 0
							SZW->(RecLock("SZW",.F.))
							SZW->ZW_LOCAL := aCols[_nI,_nPosLocal]
							SZW->(MsUnlock())
						EndIf

						SZW->(DbSkip())
					EndDo
				EndIf
				RestOrd(_aOrd)
				SZW->(DbGoTo(_nRegAtu))

				If lBq // Registra o Bloqueio por Preço para todos os itens do Pedido
					_lRet:=.F.
					If !lBLQLCR .And. SZW->ZW_BLOPRC == "B" .Or. Empty( ALLTRIM( SZW->ZW_BLOPRC ) )

						DbSelectArea("SZW")
						SZW->( DbSetOrder(1) )
						SZW->( DbSeek(cFlVer+cNumPed) )
						WHILE SZW->(!EOF()) .AND. cFlVer + cNumPed == SZW->( ZW_FILIAL + ZW_IDPED )

							RecLock( "SZW" , .F. )
							SZW->ZW_BLOPRC := "B"
							SZW->ZW_STATUS := "P"
							SZW->( MsUnLock() )

							SZW->( DBSKIP() )
						ENDDO
						IF SELECT("TRBF") <> 0
							TRBF->( Reclock( "TRBF", .F. ) )
							TRBF->BLOPRC := 'B'
							TRBF->( MsUnlock() )
						ENDIF

					EndIf

				Else

					//Valida se campo vincula pedido está corretamente preenchido
					If _lAutoref .and. !( cVincula $ ("SN") )

						cVincula := "S"

					Else

						If !( cVincula $ ("SN") )

							If u_itmsg("Pedido deve ficar disponível para vinculação?","Atenção","Clicando em Sim o pedido não será enviado para o RDC até ser vinculado",2,2,2)

								cVincula := "S"

							Else

								cVincula := "N"


							Endif


						Endif

					Endif
					IF _lTela
						FwMsgRun(, {|_oSay| _lRet:=AOMS112GC5( cFlVer , _oSay, _lAutoref , _lTela ) }, 'Aguarde!' , 'Efetivando o Pedido: '+cFlVer+" "+cNumPed , .F. )//-- Chama a Rotina de Geração de Pedidos de Venda --//
					ELSE
						_lRet:=AOMS112GC5( cFlVer , , _lAutoref  , _lTela )
					ENDIF

				EndIf

			Endif

		EndIf

	Else

		u_itmsg( 'Não foi possível posicionar no pedido!' ,'Atenção!',,1 )
		_lRet:=.F.
	EndIf

Return _lRet

/*
===============================================================================================================================
Programa--------: AOMS112Y
Autor-----------: Alexandre Villar
Data da Criacao-: 14/02/2014
===============================================================================================================================
Descrição-------: Valida o saldo disponível no Limite de Crédito do Cliente para verificar se o pedido atual excede.
===============================================================================================================================
Parametros------: cCodCli := Código do Cliente do Pedido
----------------: cLojCli := Código da Loja do Cliente do Pedido
----------------: cNumPed := Código do Pedido
===============================================================================================================================
Retorno---------: lRet := Informa se o Pedido atual 'cabe' no Limite disponível ( .F. = Sim / .T. = Não )
===============================================================================================================================
*/
User Function AOMS112Y( cCodCli , cLojCli , cNumPed )

	Local cAlias	:= GetNextAlias()
	Local _cQuery	:= ""
	Local nValPed	:= 0

//-- Recupera o valor do Pedido atual para verificar se 'cabe' no Limite de Crédito disponível --//
	_cQuery := " SELECT "
	_cQuery += "     SUM( SZW.ZW_PRCVEN * SZW.ZW_QTDVEN ) AS VALPED "
	_cQuery += " FROM "+ RetSqlName("SZW") +" SZW "
	_cQuery += " WHERE "
	_cQuery += "     SZW.ZW_IDPED	= '"+ cNumPed +"' "
	_cQuery += " AND	SZW.ZW_CLIENTE	= '"+ cCodCli +"' "
	_cQuery += " AND	SZW.ZW_LOJACLI	= '"+ cLojCli +"' "
	_cQuery += " AND SZW.D_E_L_E_T_	= ' ' "

	If Select(cAlias) > 0
		(cAlias)->( DBCloseArea() )
	EndIf

	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , cAlias , .T. , .F. )

	DBSelectArea(cAlias)
	(cAlias)->( DBGoTop() )
	If (cAlias)->(!Eof()) .And. (cAlias)->VALPED > 0
		nValPed := (cAlias)->VALPED
	EndIf

	(cAlias)->( DBCloseArea() )


RETURN nValPed

/*
===============================================================================================================================
Programa--------: AOMS112GA
Autor-----------: Alexandre Villar
Data da Criacao-: 14/02/2014
===============================================================================================================================
Descrição-------: Atualiza status da avaliação da análise de Crédito do Pedido.
===============================================================================================================================
Parametros------: cNumPed := Código do Pedido
----------------: cFilAux := Filial do Pedido
----------------: cStsAva := Status da Avaliação do Pedido
----------------: cMotAva := Motivo da Avaliação do Pedido
----------------: cObsAva := Observação da Avaliação do Pedido
----------------: dLimite := Data limite da liberação completa
===============================================================================================================================
Retorno---------: lRet := Informa se a gravação da avaliação foi efetivada com sucesso ( .T. = Sim / .F. = Não )
===============================================================================================================================
*/
User Function AOM112GA( cNumPed , cFilAux , cStsAva , cMotAva , cObsAva, dLimite, nvalor )

	Local lRet		:= .T.
	Local _aarea	:= getarea()
	Local _cCoord   := ""
	Local _cWF      := "1"
	Default cNumPed	:= ""
	Default cFilAux	:= ""
	Default cStsAva	:= ""
	Default cMotAva	:= ""
	Default dLimite := ddatabase + 7
	Default nvalor 	:= 0

	If Empty(cNumPed) .Or. Empty(cFilAux) .Or. Empty(cStsAva) .Or. Empty(cMotAva)
		lRet := .F.
	Else

		DBSelectArea("SZW")
		SZW->( DBSetOrder(1) )
		If SZW->( DBSeek( cFilAux + cNumPed ) )
			_cCoord:= posicione("SA3",1,xfilial("SA3")+SZW->ZW_VEND1,"A3_SUPER")
			_cWF   := posicione("SA3",1,xfilial("SA3")+_cCoord,"A3_I_WF")
			_cusername := UsrFullName(__cUserID)
			While SZW->(!Eof()) .And. SZW->( ZW_FILIAL + ZW_IDPED ) == cFilAux + cNumPed

				SZW->( Reclock( "SZW" , .F. ) )

				SZW->ZW_BLQLCR	:= cStsAva
				SZW->ZW_LIBL	:= dLimite
				SZW->ZW_LIBV	:= nvalor
				SZW->ZW_MOTBLCR	:= cMotAva
				SZW->ZW_DTAVAC	:= Date()
				SZW->ZW_HRAVAC	:= Time()
				SZW->ZW_USRAVAC	:= _cusername
				SZW->ZW_OBSAVAC	:= ALLTRIM(cObsAva) + " - AOMS112"

				If ALLTRIM(cStsAva) == "B"
					SZW->ZW_STATUS := "D"
				Else
					If _cWF == "2" //WF não é enviado ao Coord. somente ao Gerente caso tenha Preço fora da Tabela
						SZW->ZW_BLOPRC = ' '
						SZW->ZW_STATUS = 'L'
						SZW->ZW_ENVWF   = 'C'
						SZW->ZW_NIVELWF = 'P'
					Else
						SZW->ZW_BLOPRC  = ' '
						SZW->ZW_STATUS  = 'A'
						SZW->ZW_ENVWF   = ' '
						SZW->ZW_NIVELWF = ' '
						SZW->ZW_I_HTML  = ' '
					EndIf
				EndIf

				SZW->( MsUnlock() )

				SZW->( DBSkip() )

			EndDo

		Else
			lRet := .F.
		EndIF

	EndIf

	Restarea(_aarea)

Return(lRet)

/*
===============================================================================================================================
Programa--------: AOMS112GC5
Autor-----------: Erich Buttner
Data da Criacao-: 09/09/2010
===============================================================================================================================
Descrição-------: Gera pedido de venda real
===============================================================================================================================
Parametros------: cFlVer - Filial do pedido de venda / _lAutoref - execução de pedidos múltiplos
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112GC5( cFlVer , _oSay, _lAutoref , _lTela )

	Local cCli			:= ""
	Local cLojCli		:= ""
	Local cTipCli		:= ""
	Local cCond			:= ""
	Local cVend1		:= ""
	Local cTab			:= ""
	Local nDesp			:= 0
	Local cMenNf		:= ""
	Local cTpFret		:= ""
	Local cObs			:= ""
	Local cTransp		:= ""
	Local cHr			:= ""
	Local cSenha		:= ""
//Local cTp			:= ""
	Local dEntr			:= CtoD("")
	Local cIdPed		:= ""
	Local cBlPrc		:= ""
	Local cCodUsu		:= ""
	Local aItens		:= {}
	Local nVlrTot		:= 0
	Local nVlDesc1		:= 0
	Local nVlDesc2		:= 0
	Local nVlDesc3		:= 0
	Local nVlDesc4		:= 0
	Local _ntotvlr		:= 0
	Local _ntotqtd		:= 0
	Local _cFilPro 		:= cFlVer
	Local _lok 			:= .F.
	Local _cEvento      := " "
	Local _lRet			:= .T.
	Local _nnl			:= 0
	Local _ty			:= 0
	Local _cErro        := ""
	Local _cEnvRDC		:= "N"
    
	Local _cOperFret := U_ITGETMV("IT_OPERFRE","")
	Local _dDtCalcFr := Ctod(U_ITGETMV("IT_DTCALCF","23/06/2022"))
	Local _nDescPTon := 0
	Local _lFob := .F.
	Local _cUF  := ""
	Local _cCodMunic := ""
	Local _nPesBrIte, _nPesBrTot
    Local _lProdBLqF  := .F.
	Private _cAOMS074VLD:= ' '
	Private cFilAtual	:= " "
	Private cPedGeraSC5	:= " "
	Private lMsErroAuto	:= .F.
	Private lMsHelpAuto	:= .T.
	Private nSaveSX8	:= 0
	Private _aLog		:= {}
	Private _cTpAgenda  := " "
	Private aCorrigeItem:= {}//Array para Corrigir a sequencia do campo C6_ITEM quando grava com '00'

	DBSELECTAREA("SZW")
	SZW->( DBSetOrder(1) )
	If SZW->( DBSeek( cFlVer + ALLTRIM( cNumPed ) ) )

		cCli 		:= SZW->ZW_CLIENTE
		cLojCli		:= SZW->ZW_LOJACLI
		cTipCli		:= SZW->ZW_TIPOCLI
		cCond		:= AOMS1125()
		cVend1		:= SZW->ZW_VEND1
		cTab		:= ""
		nDesp		:= SZW->ZW_DESPESA
		cMenNf		:= ALLTRIM( SZW->ZW_MENNOTA )
		cTpFret		:= SZW->ZW_TPFRETE
		cObs		:= SZW->ZW_OBSCOM
		cTransp		:= SZW->ZW_TRANSP
		cHr			:= SZW->ZW_HOREN
		cSenha		:= SZW->ZW_SENHA
		cTp			:= Iif(SZW->ZW_TIPO == "05","42",SZW->ZW_TIPO) //substr(cTipPed,1,2)
		dEntr		:= SZW->ZW_FECENT

		If SZW->ZW_I_AGEND == 'P'

			//cTipoAg	:= SZW->ZW_I_AGEND+" - AGUARD AGENDA"

			If month(date()) != 12

				dDtEnt := STOD(ALLTRIM(STR((YEAR(DATE())+1)))+"0101")-1

			Else

				dDtEnt := STOD(ALLTRIM(STR((YEAR(DATE())+2)))+"0101")-1

			Endif


		Endif

		If SZW->ZW_I_AGEND $ 'I/O'//I=Imediata //O=Agendada pelo Op.Log.

			_cFilCarreg := SZW->ZW_FILIAL
			If !EMPTY(SZW->ZW_FILPRO) .AND. !(ALLTRIM(SZW->ZW_FILPRO)=='0')
				_cFilCarreg := SZW->ZW_FILPRO
			EndIf

			//cTipoAg		:= SZW->ZW_I_AGEND+" - IMEDIATO"
			dDtEnt := DATE()+u_omsvldent(DATE(),SZW->ZW_CLIENTE,SZW->ZW_LOJACLI,SZW->ZW_FILIAL,cNumPed,1,.F.,_cFilCarreg,SZW->ZW_TIPO,SZW->ZW_TPVENDA)

		Endif

		//If SZW->ZW_I_AGEND == 'M'
		//	cTipoAg		:= SZW->ZW_I_AGEND+" - AGENDADA COM MULTA"
		//Endif
		//If SZW->ZW_I_AGEND == 'A'
		//	cTipoAg		:= SZW->ZW_I_AGEND+" - AGENDADA"
		//Endif
       
	    cTipoAg:=SZW->ZW_I_AGEND+" - "+(U_TipoEntrega(SZW->ZW_I_AGEND))

		cIdPed		:= SZW->ZW_IDPED
		cBlPrc		:= SZW->ZW_BLOPRC
		IF _lTela
			cCodUsu		:= U_UCFG001(1)
		else
			cCodUsu		:= "SISTEMA"
		ENDIF
		_cchep 		:= posicione("SA1",1,XFILIAL("SA1")+ccli+cLojCli,"A1_I_CCHEP")
		cTipCar		:= IF( !empty(_cchep) , "1 - Paletizada" , "2 - Batida" )
		nQtdCha		:= SZW->ZW_CHAPA
		cHrDes		:= SZW->ZW_HORDES
		nCusDes		:= SZW->ZW_CUSDES
		_cEvento    := SZW->ZW_EVENTO
		_cTpAgenda  := If(SZW->ZW_I_AGEND$"PIAMO",SZW->ZW_I_AGEND,"I")

		If SZW->ZW_FILPRO != '0 ' .and. !empty(SZW->ZW_FILPRO) .and. SZW->ZW_FILPRO != SZW->ZW_FILIAL
			_cFilpro := SZW->ZW_FILPRO//TROCA NF
		Else
			_cFilpro := SZW->ZW_FILIAL// FATURANDO E CARREGANDO NA MESMA FILIAL
		Endif

		//Localiza tabela de preço do pedido
		_cvend2 := Posicione("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_SUPER")
		_cvend3 := Posicione("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_GEREN")

		_aItensLock:={}
		_llibpreco := .F.

		SBZ->(DbSetOrder(1)) // BZ_FILIAL+BZ_COD

		DBSELECTAREA("SZW")
		_lTrocaArmTN:=.F.//Troca o armazem para o da filial nova

		/* EM ANALISE 
        If SZW->ZW_FILIAL = "90" .And. (VAL(SZW->ZW_FILPRO)=0 .Or. SZW->ZW_FILPRO == "90")  .AND. ;
           SZW->ZW_TIPO   = "01" .And. SZW->ZW_TPVENDA = "F" .And. AOMS112PB( cFlVer,  ALLTRIM(cNumPed) )
            _cFilpro := "01"
            _lTrocaArmTN:=.T
        EndIf*/

		If _cfilpro $ "90/40" .Or. (!EMPTY(SZW->ZW_FILPRO) .and. VAL(SZW->ZW_FILPRO) != 0 .and. SZW->ZW_FILPRO != SZW->ZW_FILIAL )
			U_AOMS112H(cFlVer , cIdPed ,_cfilpro) //Somente tratar para Filial 90/40  que tem produção em Itapetininga / 2 coracoes e troca nota para tratar armaem 36
		EndIf        
    
		//Reordena pedido por código de produto para diminuir possibilidades de deadlock futuro
		SZW->( DBSetOrder(16) )
		SZW->( DBSeek( cFlVer + cIdPed ) )
		_aposis := {}

		Do while SZW->ZW_FILIAL == cFlVer .AND. SZW->ZW_IDPED == cIdPed

			aadd(_aposis,SZW->(Recno()))
			SZW->(Dbskip())

		Enddo

		_nnl := 1
		_cseq := "A1"//TROCA A SEQUENCIA PARA LETRA PARA QUANDO NUMERAR CERTO NÃO DAR CHAVE DUPLICADA

		For _nnl := 1 to len(_aposis)

			SZW->(Dbgoto(_aposis[_nnl]))
			Reclock("SZW", .F.)
			SZW->ZW_ITEM = _cseq
			IF _lTrocaArmTN
			   SZW->ZW_LOCAL:=POSICIONE("SBZ",1,_cFilpro+SZW->ZW_PRODUTO,"BZ_LOCPAD")
			ENDIF
			_cseq := soma1(_cseq)
			SZW->(Msunlock())

		Next

		For _nnl := 1 to len(_aposis)

			SZW->(Dbgoto(_aposis[_nnl]))
			Reclock("SZW", .F.)
			SZW->ZW_ITEM = ALLTRIM(str(_nnl))
			SZW->(Msunlock())

		Next

        ZBS->(DbSetOrder(1)) 

		SZW->( DBSetOrder(16) )
		SZW->( DBSeek( cFlVer + cIdPed ) )
        
		_nPesBrIte := 0
		_nPesBrTot := 0
		aCorrigeItem:={}//Array para Corrigir a sequencia do campo C6_ITEM quando grava com '00'
        
		_lProdBLqF := .F. // Indica se houve bloqueio de produto por filial.

		DO WHILE SZW->( !EOF() ) .AND. cFlVer + cIdPed == SZW->( ZW_FILIAL + ZW_IDPED )

			IF _oSay <> NIL
			   _oSay:cCaption := ('Lendo Item ' + SZW->ZW_ITEM)
			   ProcessMessages()
			ENDIF

            //==========================================================================
			// Nova Validação de Acordo com o cadastro de produtos bloqueados x filial
			//========================================================================== 
/* - Não validar produtos bloqueados por filial durante a efetivação.			
            If ZBS->(MsSeek(xFilial("ZBS")+SZW->ZW_FILIAL+SZW->ZW_PRODUTO))  
               If ZBS->ZBS_SITUAC == "B"
                  aAdd(  _aLog ,{SZW->ZW_FILIAL,cTp ,"O Produto: " + AllTrim(SZW->ZW_PRODUTO) + ", está bloqueados para esta filial. Veja cadastro de produtos bloqueados por filial.","","","",SZW->ZW_PRODUTO+" - "+Posicione("SB1",1,Xfilial("SB1")+SZW->ZW_PRODUTO,"B1_DESC")})
                  
				  aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),_cFilPro,cNumPed,SZW->ZW_CLIENTE+"/"+SZW->ZW_LOJACLI+" - "+ALLTRIM(Posicione("SA1",1,xFilial("SA1") + SZW->ZW_CLIENTE + SZW->ZW_LOJACLI ,"A1_NOME")),"O Produto: " + AllTrim(SZW->ZW_PRODUTO) + ", está bloqueados para a filial: "+SZW->ZW_FILIAL,"A equipe do comercial bloqueou a venda do produto para a filial: "+SZW->ZW_FILIAL})
 			   EndIf
			EndIf  
*/            
			nFatConv:= GetAdvFVal( "SB1" , "B1_CONV"	, xFilial("SB1") + SZW->ZW_PRODUTO	, 1 , "" )
			cTpConv	:= GetAdvFVal( "SB1" , "B1_TIPCONV"	, xFilial("SB1") + SZW->ZW_PRODUTO	, 1 , "" )
			nNewFat	:= GetAdvFVal( "SB1" , "B1_I_FATCO"	, xFilial("SB1") + SZW->ZW_PRODUTO	, 1 , "" )

            //============================================================
			// Calcula o Peso Total Bruto do Pedido do Portal.
			//============================================================
			_nPesBrIte := GetAdvFVal( "SB1" , "B1_PESBRU"	, xFilial("SB1") + SZW->ZW_PRODUTO	, 1 , "" ) 
		    _nPesBrTot += (_nPesBrIte * SZW->ZW_QTDVEN)

			//=============================================================================================================================
			// Verifica se existe regra de TES inteligente para o cliente e produto, caso não exista, o sistema retorna para a tela inicial
			//=============================================================================================================================
			AOM112VerTES( cCli , cLojCli , cTp , cIdPed) 

		    AADD(_aItensLock,{SZW->ZW_PRODUTO,SZW->ZW_LOCAL}) // _cAramazem
    
		    If cTpConv == "M"
		    	nQtd2UM:= IIf( nFatConv == 0 , nNewFat * SZW->ZW_QTDVEN	, nFatConv * SZW->ZW_QTDVEN	)
		    Else
		    	nQtd2UM:= IIf( nFatConv == 0 , SZW->ZW_QTDVEN / nNewFat	, SZW->ZW_QTDVEN / nFatConv	)
		    EndIf
            
			AADD(aCorrigeItem,{SZW->ZW_PRODUTO , STRZERO( VAL( ALLTRIM(SZW->ZW_ITEM) ) , 2 )  } )

		    aIt := {{ "C6_FILIAL", _cFilPro					   		, Nil },;
			{ "C6_ITEM"   	, STRZERO( VAL( ALLTRIM(SZW->ZW_ITEM) ) , 2 ), Nil },;
			{ "C6_PRODUTO"	, SZW->ZW_PRODUTO						, Nil },;
			{ "C6_QTDVEN" 	, SZW->ZW_QTDVEN						, Nil },;
			{ "C6_UNSVEN" 	, nQtd2UM								, Nil },;
			{ "C6_PEDCLI" 	, StrTran( StrTran( StrTran( SZW->ZW_PEDCLI , "ª" , "" ) , "º" , "" ) , CHAR(176) , "" ) , Nil },;
			{ "C6_I_LIBPE" 	, SZW->ZW_MLIBPRC						, Nil },;
			{ "C6_PRCVEN" 	, SZW->ZW_PRCVEN						, Nil },;
			{ "C6_I_VLIBP" 	, SZW->ZW_PRCVEN						, Nil },;
			{ "C6_I_VLTAB" 	, SZW->ZW_PRUNIT						, Nil },;
            { "C6_I_PRMIN" 	, SZW->ZW_I_PRMP						, Nil },;
			{ "C6_PRUNIT" 	, 0              						, Nil },;
			{ "C6_I_BLPRC"  , SZW->ZW_BLOPRC						, Nil },;
			{ "C6_I_DLIBP"  , SZW->ZW_DLIBP							, Nil },;
			{ "C6_I_PLIBP"  , SZW->ZW_PLIBP							, Nil },;
			{ "C6_I_ULIBP"  , SZW->ZW_ULIBP							, Nil },;
			{ "C6_I_PLIBP"  , SZW->ZW_PLIBP							, Nil },;
			{ "C6_I_LLIBP"  , SZW->ZW_LOJACLI						, Nil },;
			{ "C6_I_CLILP"  , SZW->ZW_CLIENTE						, Nil },;
			{ "C6_I_QTLIP"  , SZW->ZW_QTDVEN						, Nil },;
			{ "C6_I_LLIBB"  , SZW->ZW_LOJACLI						, Nil },;
			{ "C6_I_CLILB"  , SZW->ZW_CLIENTE						, Nil },;
			{ "C6_I_QLIBB"  , SZW->ZW_QTDVEN						, Nil },;
			{ "C6_I_MOTLB"  , SZW->ZW_I_MTBON						, Nil },;
			{ "C6_I_PLIBB"  , SZW->ZW_I_DLIBE + 30					, Nil },;
			{ "C6_I_DLIBB"  , SZW->ZW_I_DLIBE						, Nil },;
			{ "C6_I_MOTLP"  , SZW->ZW_MOTLP							, Nil },;
			{ "C6_LOCAL"    , SZW->ZW_LOCAL							, Nil },;
			{ "C6_I_FXPES"  , SZW->ZW_I_FXPES						, Nil },;
			{ "C6_ENTREG" 	, dDtEnt	                            , Nil },;
			{ "C6_ITEMPC"   , STRZERO( VAL( ALLTRIM(SZW->ZW_ITEM) ) , 2 )	, Nil },;
			{ "C6_NUMPCOM"  , StrTran( StrTran( StrTran( SZW->ZW_PEDCLI , "ª" , "" ) , "º" , "" ) , CHAR(176) , "" ) , Nil }}
		
	    	IF SZW->(FIELDPOS( "ZW_I_ITDW" )) <>  0
	    		AADD(aIt,{ "C6_I_ITDW",SZW->ZW_I_ITDW,Nil })
	    	ENDIF

			AADD(aIt,{ "C6_I_KIT" , SZW->ZW_KIT ,Nil }) 

	    	aAdd( aItens , aIt )
    
	    	nVlDesc1	:= SZW->ZW_DESC1
	    	nVlDesc2	:= SZW->ZW_DESC2
	    	nVlDesc3	:= SZW->ZW_DESC3
	    	nVlDesc4	:= SZW->ZW_DESC4
	    	nVlrTot		:= nVlrTot + ( SZW->ZW_QTDVEN * SZW->ZW_PRCVEN )
	    	_ntotvlr  += SZW->ZW_PRCVEN
	    	_ntotqtd  += SZW->ZW_QTDVEN
    
	    	If SZW->ZW_BLOPRC == 'L'
    
	    		_llibpreco := .T.
    
	    	Endif
    
	    	SZW->( DBSKIP() )
	    ENDDO

	SZW->( DBSetOrder(1) )

	//===================================================================
	//Se teve problema de TES avisa e volta para tela inicial
	//===================================================================
	If LEN(_aLog) > 0//_aLog gravado na funcao AOM112VerTES()

		If _lAutoref

			SZW->( DBSetOrder(1) )
			SZW->( DBSeek( _cFilpro + cNumped ) )

			SA1->(Dbsetorder(1))
			SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

			//Monta produtos que apresentaram problemas
			_cprodutos := ""
			_cDetalhes := ""
			For _ty := 1 to len(_alog)
				_cprodutos += "[ "+ALLTRIM( _alog[_ty][7] )+" ] "
				_cDetalhes += ALLTRIM( _alog[_ty][4] )
			Next

			//_cprodutos := substr(_cprodutos,1,len(_cprodutos)-3)

			aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),_cFilPro,cNumPed,SZW->ZW_CLIENTE+"/"+SZW->ZW_LOJACLI+" - "+ALLTRIM(SA1->A1_NOME),"Foram encontrado(s) produto(s) sem regra de TES INTELIGENTE: " + _cprodutos,_cDetalhes})

		Else

			_cMen:="Foram encontrado(s) produto(s) sem regra de TES INTELIGENTE cadastrada para a filial de criação do pedido de venda, "				+;
				"desta forma não sera possível prosseguir com a efetivação, favor informar ao responsável pela inclusão das regras de TES INTELIGENTE "	+;
				"do problema encontrado."

			u_itmsg( _cMen, 'Atenção!',, 1   )

			U_ITListBox( 'Lista de produtos com sem TES Inteligente, Pedido: '+ALLTRIM(cIdPed)+' (AOMS112)' ,;
				{'Filial','Operação','Cliente/Remessa','Est. Orig. Dest.','Suframa/Simples/Contr.',"Armazem",'Produto'} , _aLog , .T. , 1 ,;
				"Abaixo segue a relação de produtos que se encontram sem TES Inteligente: " )

		Endif

		Return .F.

	EndIf////////////////////////////If LEN(_aLog) > 0

	DBSELECTAREA("SZW")
	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( cFlVer + cIdPed ) )

	//Se é tipo agenda aguardando agendamento força data de entrega para último dia do ano
	If	ALLTRIM(_cTpAGenda) == 'P'

		If month(date()) != 12

			dDtEnt := STOD(ALLTRIM(STR((YEAR(DATE())+1)))+"0101")-1

		Else

			dDtEnt := STOD(ALLTRIM(STR((YEAR(DATE())+2)))+"0101")-1

		Endif

	Endif

	If cvincula == "S"
		_cEnvRDC := "V"
	Else
		_cEnvRDC := "N"
	Endif

	_ccondi := substr(AOMS1125(),1,3)

	//==================================================
	// Calcula desconto por tonelada para fretes Fob.
	//==================================================
	_lFob      := Posicione("SA1",1,xfilial("SA1") + cCli + cLojCli ,"A1_I_FOB")
	_nDescPTon := 0

	If _lFob .And. ALLTRIM(cTpFret) $ "F/D" .And. !(SZW->ZW_TIPO $ _cOperFret) .And. Dtos(Date()) >= Dtos(_dDtCalcFr)  //  M->C5_TPFRETE   // M->C5_I_OPER

		_cUF       := Posicione("SA1",1,xfilial("SA1") + cCli + cLojCli ,"A1_EST")
		_cCodMunic := Posicione("SA1",1,xfilial("SA1") + cCli + cLojCli ,"A1_COD_MUN")

		_nDescPTon := U_M410BDES(_cFilPro , _cUF, SZW->ZW_TIPO ,_cCodMunic) // Retorna o desconto por tonelada para pedidos Fob.

		If _nDescPTon > 0
			_nDescPTon := ((_nPesBrTot /1000 ) * _nDescPTon)
		EndIf
	EndIf

	If _nDescPTon = 0
		_nDescPTon := SZW->ZW_FOBDESC
	EndIf

	aCabec := {	{ "C5_FILIAL"	, _cFilPro	, Nil },;
		{ "C5_TIPO"   	, "N"		, Nil },;
		{ "C5_I_OPER" 	, Iif(ALLTRIM(SZW->ZW_TIPO) == _cOperFat,_cOperRemessa,SZW->ZW_TIPO)	, Nil },;
		{ "C5_CLIENTE"	, cCli		, Nil },;
		{ "C5_LOJACLI"	, cLojCli	, Nil },;
		{ "C5_TIPOCLI"	, cTipCli 	, Nil },;
		{ "C5_VEND1"	, cVend1	, Nil },;
		{ "C5_EMISSAO"	, DATE()	, Nil },;
		{ "C5_I_HREMI"	, TIME()	, Nil },;
		{ "C5_DESC1"	, nVlDesc1	, Nil },;
		{ "C5_DESC2"	, nVlDesc2	, Nil },;
		{ "C5_DESC3"	, nVlDesc3	, Nil },;
		{ "C5_DESC4"	, nVlDesc4	, Nil },;
		{ "C5_DESPESA" 	, nDesp	    , Nil },;
		{ "C5_MENNOTA" 	, cMenNf	, Nil },;
		{ "C5_TPFRETE" 	, cTpFret	, Nil },;
		{ "C5_I_OBPED" 	, cObs		, Nil },;
		{ "C5_TRANSP" 	, cTransp	, Nil },;
		{ "C5_I_HOREN" 	, cHrEnt	, Nil },;
		{ "C5_I_SENHA" 	, cSenha	, Nil },;
		{ "C5_I_DTENT" 	, dDtEnt	, Nil },;
		{ "C5_I_IDPED" 	, cIdPed	, Nil },;//TRB->NUMPED - SZW->ZW_IDPED - TRBF->NUMPED
		{ "C5_I_CDUSU" 	, cCodUsu	, Nil },;
		{ "C5_I_TIPCA" 	, cTipCar	, Nil },;
		{ "C5_I_CHAPA" 	, nQtdCha	, Nil },;
		{ "C5_I_HORDE" 	, cHrDes	, Nil },;
		{ "C5_I_CUSDE"	, nCusDes	, Nil },;
		{ "C5_I_EVENT"	, _cEvento	, Nil },;
		{ "C5_I_AGEND"	, _cTpAGenda	  , Nil },;
		{ "C5_CONDPAG"	, _ccondi         , Nil },;
		{ "C5_I_TPVEN"  , SZW->ZW_TPVENDA , Nil },;
		{ "C5_I_DTAVA"  , SZW->ZW_DTAVAC  , Nil },;
		{ "C5_I_HRAVA"  , SZW->ZW_HRAVAC  , Nil },;
		{ "C5_I_ORTBP"  , SZW->ZW_REGRA   , Nil },;
		{ "C5_I_TAB"    , SZW->ZW_TABELA  , Nil },;
		{ "C5_DESCONT"  , _nDescPTon      , Nil },; // SZW->ZW_FOBDESC
	    { "C5_I_OBS"    , SZW->ZW_I_OBS   , Nil },;
		{ "C5_I_DLIBG"  , SZW->ZW_I_DLIBG , Nil },;
		{ "C5_I_HLIBG"  , SZW->ZW_I_HLIBG , Nil },;
		{ "C5_I_ENVRD"  , _cEnvRDC        , Nil },;
		{ "C5_I_USRAV"  , SZW->ZW_USRAVAC , Nil }}
		
		AADD( aCabec,{ "C5_I_RECSA" , SZW->ZW_I_RECSA, Nil })

	//Apresenta erro de tabela invalida { "C5_TABELA"   , ""               , Nil },;

	//Liberação de preço - Só grava se teve liberação
	If  SZW->ZW_BLOPRC == "L"

		AADD( aCabec,{ "C5_I_BLPRC"  	, SZW->ZW_BLOPRC, Nil })
		AADD( aCabec,{ "C5_I_DTLIP"  	, SZW->ZW_DLIBP	, Nil })
		AADD( aCabec,{ "C5_I_HLIBP"  	, SZW->ZW_HLIBP	, Nil })
		AADD( aCabec,{ "C5_I_PLIBP"  	, SZW->ZW_PLIBP	, Nil })
		AADD( aCabec,{ "C5_I_ULIBP"  	, SZW->ZW_ULIBP	, Nil })
		AADD( aCabec,{ "C5_I_LLIBP"  	, SZW->ZW_LLIBP	, Nil })
		AADD( aCabec,{ "C5_I_MLIBP"  	, SZW->ZW_MLIBP	, Nil })
		AADD( aCabec,{ "C5_I_MOTLP"  	, SZW->ZW_MOTLP	, Nil })
		AADD( aCabec,{ "C5_I_CLILP"  	, SZW->ZW_CLILP	, Nil })
		AADD( aCabec,{ "C5_I_QLIBP"  	, _ntotqtd		, Nil })
		AADD( aCabec,{ "C5_I_VLIBP"  	, _ntotvlr		, Nil } )

	Endif

	//Liberação de crédito - Só grava se teve liberação
	If SZW->ZW_BLQLCR == "L" .OR. SZW->ZW_BLQLCR == "C"

		AADD( aCabec,{"C5_I_BLCRE"  , "L"			    , Nil })
		AADD( aCabec,{"C5_I_LIBC "  , IIF(SZW->ZW_BLQLCR == "L",0,2)		, Nil })
		AADD( aCabec,{"C5_I_DTLIC"  , SZW->ZW_I_LIBCD	, Nil })
		AADD( aCabec,{"C5_I_LIBCD"  , SZW->ZW_I_LIBCD	, Nil })
		AADD( aCabec,{"C5_I_LIBCT"  , SZW->ZW_I_LIBCT	, Nil })
		AADD( aCabec,{"C5_I_LIBCA"  , SZW->ZW_I_LIBCA	, Nil })
		AADD( aCabec,{"C5_I_MOTBL"  , SZW->ZW_I_MOTBL	, Nil })
		AADD( aCabec,{"C5_I_LIBL"   , SZW->ZW_LIBL		, Nil })
		AADD( aCabec,{"C5_I_LIBV"   , SZW->ZW_LIBV		, Nil })
		AADD( aCabec,{"C5_I_LIBCV"  , nVlrTot	        , Nil })

	Endif

	//Liberação de bonificação - Só grava se teve liberação e ainda é bonificação
	//If SZW->ZW_BLOQ == "L" .and. SZW->ZW_TIPO == '10'
	If SZW->ZW_BLOQ == "L" .and. (SZW->ZW_TIPO $ '10/24/05' .OR.  SZW->ZW_TPFRETE = "F" )
		AADD( aCabec,{ "C5_I_BLOQ"  , SZW->ZW_BLOQ, Nil })
		AADD( aCabec,{ "C5_I_DLIBE"  , SZW->ZW_I_DLIBE, Nil })
		AADD( aCabec,{ "C5_I_HLIBE"  , SZW->ZW_I_HLIBE, Nil })
		AADD( aCabec,{ "C5_I_VLIBB"  , _ntotvlr, Nil })
		AADD( aCabec,{ "C5_I_QLIBB"  , _ntotqtd, Nil })
		AADD( aCabec,{ "C5_I_LLIBB"  , cLojCli, Nil })
		AADD( aCabec,{ "C5_I_CLILB"  , cCli, Nil })
		AADD( aCabec,{ "C5_I_MOTLB"  , SZW->ZW_I_MOTLB, Nil })
		AADD( aCabec,{ "C5_I_ULIBB"  , SZW->ZW_I_ULIBB, Nil })
	Endif

	IF SZW->(FIELDPOS("C5_I_OBSAV")) # 0//Campo da avaliacao NOVO
		AADD( aCabec, {"C5_I_OBSAV"  , SZW->ZW_OBSAVAC, Nil }  )
	ENDIF
	IF SZW->(FIELDPOS( "ZW_I_PEDDW" )) <>  0
		AADD(aCabec,{ "C5_I_PEDDW",SZW->ZW_I_PEDDW,Nil })
	ENDIF

	_cOperTri   := Space(1)  // Esta variável será utilizada no fonte MT410TOK para peencher o campo operação triangular.
	_cCodClien  := Space(6)  // Esta variável será utilizada no fonte MT410TOK para peencher o campo codigo Cliente/Venda.
	_cLojaClie  := Space(4)  // Esta variável será utilizada no fonte MT410TOK para peencher o campo Loja Cliente/Venda.

	If _cFilPro <> cFlVer//_cFilPro sempre esta preenchido PQ inicio com a cFlVer

		M->C5_I_TRCNF:="S"   //Variavel usada no gatilho do C6_PRCVEN
		M->C5_I_FILFT:=cFlVer//Variavel usada no gatilho do C6_PRCVEN

		aadd( aCabec, { "C5_I_TRCNF", "S"	  , Nil } )
		aadd( aCabec, { "C5_I_FILFT", cFlVer  , Nil } )
		aadd( aCabec, { "C5_I_FLFNC", _cFilPro, Nil } )

	ELSE

		M->C5_I_TRCNF:="N"   //Variavel usada no gatilho do C6_PRCVEN
		M->C5_I_FILFT:=cFlVer//Variavel usada no gatilho do C6_PRCVEN

		aadd( aCabec, { "C5_I_TRCNF", "N"  , Nil } )
		aadd( aCabec, { "C5_I_FILFT", " "  , Nil } )
		aadd( aCabec, { "C5_I_FLFNC", " "  , Nil } )

	Endif

	// Tratamento da Operação Tria zngular
	IF !EMPTY(SZW->ZW_CLIREM) .AND. LEFT(cTipPed,2) $ _cOperTriangular
		_cOperTri   := ""//"R"
		_cCodClien  := ""//SZW->ZW_CLIREM
		_cLojaClie  := ""//SZW->ZW_LOJEN

		Aadd( aCabec, { "C5_I_OPTRI","R"           , Nil})//TRATAMENTO DA OPERCAO TRIAGULAR
		Aadd( aCabec, { "C5_I_CLIEN",SZW->ZW_CLIREM, Nil})//Depois da Mudança da Op Triangular de  05 para 42. Este campo agora é o cliente de faturamento.
		Aadd( aCabec, { "C5_I_LOJEN",SZW->ZW_LOJEN , NiL})
	ENDIF
	// Tratamento da Operação Triangular


	Begin Sequence
		Begin Transaction


			//Valida se já não existe um pedido na c5 com esse idped
			_cQuery := " SELECT C5_NUM , C5_EMISSAO "
			_cQuery += " FROM "+ RetSqlName("SC5") +" SC5 "
			_cQuery += " WHERE  SC5.C5_I_IDPED	= '"+ ALLTRIM(cNumPed) +"' "
			_cQuery += " AND SC5.D_E_L_E_T_	= ' ' "

			cAliast := getnextalias()

			If Select(cAliast) > 0
				(cAliast)->( DBCloseArea() )
			EndIf

			DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , cAliast , .T. , .F. )

			DBSelectArea(cAliast)
			(cAliast)->( DBGoTop() )

			If (cAliast)->(!Eof())
				_lok := .F.
				_cAOMS074VLD:="Pedido ja foi Efetivado, esta no Protheus no Código Ped.: " +(cAliast)->C5_NUM + " / Emissao: "+DTOC(STOD((cAliast)->C5_EMISSAO))+". Por favor entrar em contato com TI."//})
				Disarmtransaction()
				Break
			Endif

			(cAliast)->( DBCloseArea() )

			//Valida se pedido está disponível para lock e se não foi efetivado por outra estação durante as validações
			DBSELECTAREA("SZW")
			SZW->( DbSetOrder(1) )
			SZW->( DbSeek( cFlVer + cNumPed ) )
            _aRecProdSZW:={}
			Do While SZW->(!EOF()).AND.cNumPed == SZW->ZW_IDPED

				If !SZW->(MsRLock(SZW->(RECNO()))) .OR. !Empty(SZW->ZW_NUMPED) .OR. SZW->ZW_STATUS == "I"
					_lok := .F.
					Disarmtransaction()
					Break
				Endif
                AADD(_aRecProdSZW,{SZW->ZW_PRODUTO,SZW->(RECNO())," "})
				SZW->(Dbskip())

			Enddo

			cFilAtual:= cFilAnt // Filial que esta logado
			cFilAnt	 := _cFilPro  // Filial que o pedido do portal esta selecionado para efetivacao
			_cErroPV := ""

			//Guarda parâmetros
			_MV_PAR01 := MV_PAR01
			_MV_PAR02 := MV_PAR02
			_MV_PAR03 := MV_PAR03
			_MV_PAR04 := MV_PAR04
			_MV_PAR05 := MV_PAR05
			_MV_PAR06 := MV_PAR06

			If _lAutoref

				_cmens := "Gerando pedido " + strzero(_nni,4) + " de " + strzero(_ntot,4)

			Else

				_cmens := "GERANDO O PEDIDO DE VENDA PARA O PEDIDO DO PORTAL " + cIdPed

			Endif

         _lMsgEmTela  := .F.
			_cAOMS074    :="AOMS112"//DesAtiva o _lMsgEmTela := .F. no MT410TOK.PRW
			_cAOMS074Vld :=""//Pega as mensagens de erro
			_cErro       := " "

			//Siga auto de inclusao de pedido de venda
			IF _lTela
				FWMSGRUN( , {|| MSEXECAUTO( {|x,y,z| Mata410(x,y,z) } , aCabec , aItens , 3 ) }, "MSEXECAUTO() - AGUARDE...", _cmens  )
			ELSE
				MSEXECAUTO( {|x,y,z| Mata410(x,y,z) } , aCabec , aItens , 3 )
			ENDIF
         _lMsgEmTela  := .T.

			_lLiberou:=.T.
			If lMsErroAuto
				IF !_lAutoref
					_cErro:=" MostraErro: ["+MostraErro()+"]"
				ELSE
					_cErro:=" MostraErro: ["+MostraErro("\data\Italac\AOMS112\","AOMS112_MostraErro_"+ALLTRIM(cNumPed)+".LOG")+"]"
				ENDIF
			ELSE

				SA3->(dbSetOrder(1))
				IF SA3->(dbSeek(xFilial("SA3")+LEFT(SC5->C5_VEND1,LEN(SA3->A3_COD)) )) .AND. SA3->A3_I_ESTOQ = "S"
			       
				   IF !(_lLiberou:=Ver_Lib_PV(SC5->C5_FILIAL+SC5->C5_NUM,_aRecProdSZW))//Pedidos Vendas via Pedido portal para Broker que validar Estoque
	   			   
				      AADD(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),SC5->C5_FILIAL,SC5->C5_NUM,ALLTRIM(SC5->C5_VEND1)+"-"+SA3->A3_NOME,"Falha na LIBERACAO DO ESTOQUE (SC9) do pedido de vendas."})
					  _cAOMS074VLD:="Não foi possivel a LIBERACAO DO ESTOQUE (SC9) de todos os itens do pedido de vendas."
				   ELSE
	   			       AADD(_aResults, {LoadBitmap(GetResources(),"BR_AZUL"),SC5->C5_FILIAL,SC5->C5_NUM,ALLTRIM(SC5->C5_VEND1)+"-"+SA3->A3_NOME,"LIBERACAO DO ESTOQUE (SC9) do pedido de vendas COM SUCESSO."})
				   ENDIF
                //ELSE 
			       //AADD(_aResults, {LoadBitmap(GetResources(),"BR_AMARELO"),SC5->C5_FILIAL,SC5->C5_NUM,ALLTRIM(SC5->C5_VEND1)+"-"+SA3->A3_NOME,"LIBERACAO DO ESTOQUE (SC9) do pedido de vendas NÃO ATIVADA."})
				ENDIF
			
			ENDIF
			//Restaura parâmetros
			MV_PAR01 := _MV_PAR01
			MV_PAR02 := _MV_PAR02
			MV_PAR03 := _MV_PAR03
			MV_PAR04 := _MV_PAR04
			MV_PAR05 := _MV_PAR05
			MV_PAR06 := _MV_PAR06

			cFilGeraSC5	:= SC5->C5_FILIAL
			cPedGeraSC5	:= SC5->C5_NUM
			cFilAnt		:= cFilAtual
			
			SZW->( DbSetOrder(1) )
			SZW->( DbSeek( cFlVer + cNumPed ) )
			cNumPedMostra:= cNumPed
		    IF !EMPTY(SZW->ZW_PEDIMPO)
               cNumPedMostra:=ALLTRIM(cNumPed)+" ["+ALLTRIM(SZW->ZW_PEDIMPO)+"]"
		    ENDIF


			If Empty( cPedGeraSC5 ) .OR. ALLTRIM( cFilGeraSC5 ) <> ALLTRIM( _cFilPro ) .OR.;
			            lMsErroAuto .OR. !EMPTY(_cErroPV) .OR. !_lLiberou

				If ( __lSx8 )

					While ( GetSX8Len() > nSaveSX8 ) // Retorna a numeração caso não confirme
						RollBackSX8()
					EndDo

				EndIf

				_lok := .F.
				DisarmTransaction()

				IF !_lLiberou
				   SA3->(dbSeek(xFilial("SA3")+LEFT(SZW->ZW_VEND1,LEN(SA3->A3_COD)) ))
				   FOR  _nnl := 1 TO LEN(_aRecProdSZW)
				       IF _aRecProdSZW[_nnl,2] > 0 
		                  SZW->( DBGOTO(_aRecProdSZW[_nnl,2]) )
 		                  SZW->( RecLock( "SZW" , .F. ) )
						  IF !EMPTY(_aRecProdSZW[_nnl,3])
		                     SZW->ZW_MOTREC := ALLTRIM(SZW->ZW_MOTREC)+"["+_aRecProdSZW[_nnl,3]+"] "
				             AADD(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFlVer,cNumPedMostra,ALLTRIM(SZW->ZW_VEND1)+"-"+SA3->A3_NOME,"Produto: "+ALLTRIM(SZW->ZW_PRODUTO)+" - "+ALLTRIM(GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SZW->ZW_PRODUTO,1,""))+" => SEM ESTOQUE."})
						  ENDIF
		                  SZW->ZW_STATUS := "R"
		                  SZW->ZW_PEDIMPO:= " "
		                  SZW->ZW_NUMPED := " " 
		                  SZW->( MsUnLock() )
					   ENDIF
					NEXT				
				ENDIF


			Else

				_lefetivado := .T.

				If ( __lSx8 )

					While (GetSX8Len() > nSaveSX8) // Confirma a numeração
						ConfirmSX8()
					EndDo

				EndIf

				DBSELECTAREA("SZW")
				SZW->( DbSetOrder(1) )
				SZW->( DbSeek( cFlVer + cNumPed ) )

				WHILE SZW->(!EOF()).AND.cNumPed == SZW->ZW_IDPED

					IF _oSay <> NIL .And. _lTela
						_oSay:cCaption := ('Atualizando Item ' + SZW->ZW_ITEM)
						ProcessMessages()
					ENDIF
					RecLock( "SZW" , .F. )

					SZW->ZW_STATUS  := "I"
					SZW->ZW_MUSEIMP := U_UCFG001(1)
					SZW->ZW_HORAIMP := Time()
					SZW->ZW_DATAIMP := dDataBase
					SZW->ZW_NUMPED	:= SC5->C5_NUM
					SZW->ZW_I_MOTBL := " "
					SZW->( MsUnLock() )

					SZW->(DbSkip())

				EndDo

				SC5->( Reclock( "SC5", .F. ) )
				SC5->C5_CONDPAG :=  _ccondi
				SC5->C5_TABELA := ""
				SC5->( Msunlock())
                

				IF SELECT("TRBF") <> 0
					TRBF->( Reclock( "TRBF", .F. ) )
					TRBF->( DbDelete() )
					TRBF->( MsUnlock() )
					TRBF->(DBSKIP())
				ENDIF

				_lok := .T.

				//Gerar Pallet somente para Produtos Matinais Armazem 40
				//Não ativar FWMSGRUN( , {|| GeraPedPallet() }, "MSEXECAUTO() - AGUARDE...", _cmens  )
			EndIf

		End Transaction
        
        If _lok .And. Len(aCorrigeItem) > 0 
           CorrigeItem(aCorrigeItem)// Verefica se o C6_ITEM esta igual ao ZW_ITEM, senão acerta - Parametros: aCorrigeItem,_cChavePed
           aCorrigeItem:={}
        EndIf

	End Sequence


	SB2->(DBUNLOCK())
	SA1->(DBUNLOCK())
	SB1->(MSUNLOCKALL())
	SB2->(MSUNLOCKALL())
	SA1->(MSUNLOCKALL())
	SC5->(MSUNLOCKALL())
	MsUnlockAll()

	If _lAutoref

		SZW->( DBSetOrder(1) )
		SZW->( DBSeek( cFlVer + cNumPed ) )

		SA1->(Dbsetorder(1))
		SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))
        cNumPedMostra:=cNumPed
		IF !EMPTY(SZW->ZW_PEDIMPO)
           cNumPedMostra:=ALLTRIM(cNumPed)+" ["+ALLTRIM(SZW->ZW_PEDIMPO)+"]"
		ENDIF
        
		If _lok

			aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERDE"),cFlVer,cNumPedMostra,SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),"PEDIDO DE VENDA " + cPedGeraSC5 + "  CRIADO COM SUCESSO",""})

		Else

			aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),;                //01                                         
			                 cFlVer,;                                                  //02       
							 cNumPedMostra,;                                           //03              
							 ALLTRIM(SA1->A1_COD)+"-"+ALLTRIM(SA1->A1_NOME),;                   //04                                      
							 "Falha na criação do pedido de vendas: { " + _cAOMS074VLD + " }" ,;//05
							 "" })                                                     //06     
			IF !EMPTY(_cErro)
				_aResults[LEN(_aResults),6]:="Mostra Erro:  { " +  _cErro + " }"
			ENDIF
			_lRet:=.F.
		Endif

	Else

		If _lok .And. _lTela

			MSGINFO("Criado o Pedido de Venda "+ CHR(10) + CHR(13) +" Filial: "+ cFilGeraSC5 + CHR(10) + CHR(13) +"Pedido: "+ cPedGeraSC5 + " para o pedido do portal " + cNumPed , "Processo concluído")

		Else
			If _lTela
				U_ITMSG( 'Não foi possível gerar o Pedido de Venda! Verifique o registro de Log!' , 'Atenção!',IF(!EMPTY(_cErroPV),_cErroPV,),1 )

				IF EMPTY(_cErroPV)
					MostraErro()
				ENDIF
			ENDIF

			_lRet:=.F.

		Endif

	Endif

Else

	If _lAutoref

		aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFlVer,cNumPed,"N/C",'Falha ao posicionar no pedido!'})

	Else
		IF _lTela
			u_itmsg(  'Falha ao posicionar no pedido!' , 'Atenção!' ,,1)
		ENDIF

	Endif

	_lRet:=.F.

EndIf


Return _lRet

/*
==============================================================================================================================================
Programa--------: AOM112VerTES()
Autor-----------: Alex Wallauer
Data da Criacao-: 22/02/2017
==============================================================================================================================================
Descrição-------: Verifica se existe regra de TES inteligente para o cliente e produto, caso não exista, o sistema retorna para a tela inicial
==============================================================================================================================================
Parametros------: cCli: coidgo do cliente  
----------------: cLojCli: loja do cliente
				  cTp - operação do pedido
				  cIdPed - id do pedido
				  cfilfat - filial de faturamento
==============================================================================================================================================
Retorno---------: Nenhum
==============================================================================================================================================
*/
Static Function AOM112VerTES( cCli , cLojCli , cTp , cIdPed,cfilfat)
	LOCAL _cfilial := cfilant
	LOCAL _cArma,_cSuframa,_cTes,_cEstOri:=""

	Default cfilfat := cfilant

	SA1->(dbSetOrder(1))
	If SA1->(dbSeek( xFilial("SA1") + cCli + cLojCli ))

		//posiciona na filial que vai gerar o pedido
		cfilant := SZW->ZW_FILIAL
		IF !EMPTY(SZW->ZW_FILPRO) .and. VAL(SZW->ZW_FILPRO) != 0
			cfilant := SZW->ZW_FILPRO
		ENDIF

		Posicione("SM0",1,'01'+cFilant,"M0_NOMECOM")

		//Localiza armazém que será usado
		_cArma := SZW->ZW_LOCAL

		_cSuframa:=IF(!EMPTY(SA1->A1_SUFRAMA),"S","N")
		_cCpoSN  :=IF(SA1->A1_SIMPNAC="1","S","N")
		_cCpoCI  :=IF(SA1->A1_CONTRIB="2","N","S")

		_cTes := u_selectTES(SZW->ZW_PRODUTO ,_cSuframa, SA1->A1_EST, (_cEstOri:=SM0->M0_ESTCOB), cCli, cLojCli, cTp,_cArma)

		If Empty(_cTes)
           _cMenTES:="Não existe nenhuma regra de TES Inteligente cadastrada para: "+CHR(13)+CHR(10)+;
					  "Filial / Estado / Operacao: "+cFilAnt+" / "+_cEstOri+" / "+cTp+CHR(13)+CHR(10)+;
					  "Cliente / Loja / Est. / Suframa: "+cCli+" / "+cLojCli+" / "+SA1->A1_EST+" / "+_cSuframa+CHR(13)+CHR(10)+;
					  "Produto / Armazem: "+ALLTRIM(SZW->ZW_PRODUTO)+" / "+_cArma+CHR(13)+CHR(10)
			aAdd( _aLog ,{cfilant,cTp ,SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),_cMenTES                   ,_cSuframa+" / "+_cCpoSN+" / "+_cCpoCI,_cArma,ALLTRIM(SZW->ZW_PRODUTO)+" - "+Posicione("SB1",1,Xfilial("SB1")+SZW->ZW_PRODUTO,"B1_DESC")})
		EndIf

		//volta a filial a posição do ambiente
		cfilant := _cfilial
		Posicione("SM0",1,'01'+cFilant,"M0_NOMECOM")

		//Se mandou filial de faturamento diferente da filial de produção
		// testa TES para filial de faturamento também
		If cfilfat != cfilant

			//posiciona na filial que vai gerar o pedido
			_cfilori := cfilant
			cfilant := cfilfat
			Posicione("SM0",1,'01'+cFilant,"M0_NOMECOM")

			//Localiza armazém que será usado, no faturamento
			//do troca nota é sempre o armazém 40
			_cArma := '40'

			_cSuframa:=IF(!EMPTY(SA1->A1_SUFRAMA),"S","N")
			_cCpoSN  :=IF(SA1->A1_SIMPNAC="1","S","N")
			_cCpoCI  :=IF(SA1->A1_CONTRIB="2","N","S")

			_cTes := u_selectTES(SZW->ZW_PRODUTO ,_cSuframa, SA1->A1_EST, (_cEstOri:=SM0->M0_ESTCOB), cCli, cLojCli, cTp,_cArma,"N")

			If Empty(_cTes)
               _cMenTES:="Não existe nenhuma regra de TES Inteligente cadastrada para: "+CHR(13)+CHR(10)+;
						  "Filial / Estado / Operacao: "+cFilAnt+" / "+_cEstOri+" / "+cTp+CHR(13)+CHR(10)+;
						  "Cliente / Loja / Est. / Suframa: "+cCli+" / "+cLojCli+" / "+SA1->A1_EST+" / "+_cSuframa+CHR(13)+CHR(10)+;
						  "Produto / Armazem: "+ALLTRIM(SZW->ZW_PRODUTO)+" / "+_cArma+CHR(13)+CHR(10)
				aAdd(  _aLog ,{cfilant,cTp ,SA1->A1_COD + "/"+SA1->A1_LOJA + " - "+ALLTRIM(SA1->A1_NOME),_cMenTES                   ,_cSuframa+" / "+_cCpoSN+" / "+_cCpoCI,_cArma,ALLTRIM(SZW->ZW_PRODUTO)+" - "+Posicione("SB1",1,Xfilial("SB1")+SZW->ZW_PRODUTO,"B1_DESC")})
			EndIf

			//volta a filial a posição do ambiente
			cfilant := _cfilori
			Posicione("SM0",1,'01'+cFilant,"M0_NOMECOM")


		Endif

	ELSE
		aAdd(  _aLog ,{SZW->ZW_FILIAL,cTp ,SA1->A1_COD + " "+SA1->A1_LOJA,SA1->A1_COD + " "+SA1->A1_LOJA + " - Cliente/Remessa não cadastrado",""                 ,_cArma,SZW->ZW_PRODUTO+" - "+Posicione("SB1",1,Xfilial("SB1")+SZW->ZW_PRODUTO,"B1_DESC")})
	EndIf

RETURN

/*
===============================================================================================================================
Programa--------: AOMS112H
Autor-----------: Julio de Paula Paz
Data da Criacao-: 21/03/2018
===============================================================================================================================
Descrição-------: Atualizar os armazens da tabela SZW para Filial 90, tendo como base a seguinte regra:
                  a) Se algum item da tabela SZW possuir o codigo do armazem contido no parametro IT_ARMAZTER, então
                     pegar o código do armazem do primeiro item que não esteja no parâmetro e gravar nos itens que possuem 
                     código do armazem contido no parâmetro IT_ARMAZTER.
                  b) Caso nenhum item da tabela SZW possua código do armazem contido no parâmetro IT_ARMAZTER, seguir a 
                     seguinte regra:
                      - Para quando ZW_LOCAL = B1_LOCPAD, gravar C6_LOCAL = BZ_LOCPAD
                      - Para quando ZW_LOCAL <> B1_LOCPAD, gravar C6_LOCAL = ZW_LOCAL
                  
===============================================================================================================================
Parametros------: _cCodFil = Código da filial
                  _cIdPedido = Código do Pedido.
				  _cfilpro = FILIAL DE CARREGAMENTO
===============================================================================================================================
Retorno---------: Nenhum_cfilpro
===============================================================================================================================
*/

User Function AOMS112H(_cCodFil,_cIdPedido,_cfilpro)
	Local _aRecnoSZW := {}
	Local _cArmazemTerc := ""
	Local _nI , cQry :=""
	Local _lHaArmz36, _lSoArmaz36
	Local _nPesoSZW, _nSomaPeso
	Local _nPesoParam := 4000
	Local _cRevenda := "N"
	Local _cProexc := "00010225901;00010145901"
	Local _cAlias := GetNextAlias()
	Local _cArmzRevenda := "22"
	Local _cArmzLocal   := "20"

	_cFilSalva    := cFilAnt
	cFilAnt       := SZW->ZW_FILIAL
	_cArmazemTerc := U_ITGETMV("IT_ARMAZTER","36;")
	_nPesoParam   := U_ITGETMV("IT_PESOBRLC",4000)
	_cProexc      := U_ITGETMV("IT_ZWEXC","00010225901;00010145901")
	_cArmzRevenda := U_ITGETMV("ITARMREV","22")
	_cArmzLocal   := U_ITGETMV("ITARMNRV","20")
	cFilAnt       := _cFilSalva

	Begin Sequence

		_aRecnoSZW := {}

		_lHaArmz36 := .F.

		_lSoArmaz36 := .T.  // Todos os itens são do armazem 36.

		_nPesoSZW  := 0
		_nSomaPeso := 0 // Soma dos pesos da tabela SZW.

		lCidAtendeOPL:=.F.

		_cProds:=""
		nConta:=0

		SZW->( DBSetOrder(1) )
		SZW->( DBSeek( _cCodFil + _cIdPedido ) )

		SA1->(DBSETORDER(1))
		SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))
		SA2->(DBSETORDER(1))

		nSA2PesoRef :=0
		nSA2PesoSeco:=0
		nSB1SomaRef :=0
		nSB1SomaSeco:=0
		_cLOG:="FILIAL LOGADA: cFilAnt = "+cFilAnt+CRLF
		_cLOG:="PED. PORTAL: _cIdPedido = "+_cIdPedido+CRLF

		CC2->(DBSETORDER(1))
		CC2->(DBSeek(xFilial("CC2")+SA1->A1_EST+SA1->A1_COD_MUN) )
		IF !EMPTY(CC2->CC2_I_OPCO) .AND. _cfilpro $ "90/40"
			IF SA2->(DbSeek(xFilial("SA2")+CC2->CC2_I_OPCO+CC2->CC2_I_OPLO))
				nSA2PesoRef  := SA2->A2_I_PMAXR
				nSA2PesoSeco := SA2->A2_I_PMAXS
				lCidAtendeOPL:=.T.

				_cLOG+="ACHOU NO SA2 CC2->CC2_I_OPCO+CC2->CC2_I_OPLO = "+CC2->CC2_I_OPCO+" "+CC2->CC2_I_OPLO+CRLF
				_cLOG+="Com nSA2PesoRef = "+CVALTOCHAR(nSA2PesoRef)+CRLF
				_cLOG+="Com nSA2PesoSeco = "+CVALTOCHAR(nSA2PesoSeco)+CRLF

			ELSE
				_cLOG+="NAO ACHOU SA2 CC2->CC2_I_OPCO+CC2->CC2_I_OPLO = "+CC2->CC2_I_OPCO+" "+CC2->CC2_I_OPLO+CRLF
			ENDIF
		ELSE
			_cLOG+="NAO ACHOU CC2 xFilial(CC2)+SA1->A1_EST+SA1->A1_COD_MUN = "+xFilial("CC2")+" "+SA1->A1_EST+" "+SA1->A1_COD_MUN+CRLF
			_cLOG+="CC2->CC2_I_OPCO+CC2->CC2_I_OPLO = "+CC2->CC2_I_OPCO+" "+CC2->CC2_I_OPLO+CRLF
		ENDIF

		Do While SZW->( !EOF() ) .AND. _cCodFil + _cIdPedido == SZW->( ZW_FILIAL + ZW_IDPED )

//----------------------------------------------------------------- // JPP TESTE - Rever este trecho. Incluir aqui a nova regra.

			//==================================================
			// Faz a somatória dos Pesos.
			//==================================================
			_nPesoSZW := Posicione("SB1",1,Xfilial("SB1")+SZW->ZW_PRODUTO,"B1_PESBRU")
			_nSomaPeso:= (_nSomaPeso + (_nPesoSZW * SZW->ZW_QTDVEN))
			_cLOG+="Produto: "+SZW->ZW_PRODUTO+" - Peso: "+CVALTOCHAR(_nPesoSZW)+CRLF
			IF SB1->B1_TIPCAR == "000002" // Carga Refrigerada
				nSB1SomaRef  +=(_nPesoSZW * SZW->ZW_QTDVEN)
				_cLOG+="nSB1SomaRef += "+CVALTOCHAR(_nPesoSZW)+" * "+CVALTOCHAR(SZW->ZW_QTDVEN)+CRLF
			ELSE// Carga Seca
				nSB1SomaSeco +=(_nPesoSZW * SZW->ZW_QTDVEN)
				_cLOG+="nSB1SomaSeco += "+CVALTOCHAR(_nPesoSZW)+" * "+CVALTOCHAR(SZW->ZW_QTDVEN)+CRLF
			ENDIF

			_cProds+=ALLTRIM(SZW->ZW_PRODUTO)+";"
			nConta++
			Aadd(_aRecnoSZW,SZW->(Recno()))

			If SZW->ZW_LOCAL == ALLTRIM(_cArmazemTerc)

				_lHaArmz36 := .T.

			Else

				_lSoArmaz36 := .F.

			Endif

			SZW->(DbSkip())

		EndDo
		_cProds:=LEFT(_cProds,LEN(_cProds)-1)
		_cLOG+="IF lCidAtendeOPL = "+IF(lCidAtendeOPL,"VERDADEIRO","FALSO")+CRLF
		_cLOG+=" AND nSB1SomaRef = "+CVALTOCHAR(nSB1SomaRef)+CRLF
		_cLOG+="  <= nSA2PesoRef = "+CVALTOCHAR(nSA2PesoRef)+CRLF
		_cLOG+="AND nSB1SomaSeco = "+CVALTOCHAR(nSB1SomaSeco)+CRLF
		_cLOG+=" <= nSA2PesoSeco = "+CVALTOCHAR(nSA2PesoSeco)+CRLF
		_cLOG+="lCidAtendeOPL .AND. (nSB1SomaRef <= nSA2PesoRef) .AND. (nSB1SomaSeco <=  nSA2PesoSeco) = "+;
			IF(lCidAtendeOPL .AND. (nSB1SomaRef <= nSA2PesoRef) .and.(nSB1SomaSeco <=  nSA2PesoSeco),"VERDADEIRO","FALSO")+CRLF

			IF lCidAtendeOPL .AND. (nSB1SomaRef <= nSA2PesoRef) .AND. (nSB1SomaSeco <=  nSA2PesoSeco)

				cQry += "SELECT NVL(COUNT(DISTINCT ZGL_PRODUT),0) TOT FROM ZGL010 "+CRLF
				cQry += "  WHERE ZGL_FILIAL =  '"+_cfilpro+"' " +CRLF
				cQry += "    AND ZGL_FORNEC =  '"+CC2->CC2_I_OPCO+"' " +CRLF
				cQry += "    AND ZGL_LOJA   =  '"+CC2->CC2_I_OPLO+"' " +CRLF
				cQry += "    AND ZGL_MSBLQL <> '1' "+CRLF
				cQry += "    AND ZGL_PRODUT IN "+FORMATIN(ALLTRIM(_cProds),";")+CRLF
				cQry += "    AND D_E_L_E_T_ = ' ' "	+CRLF

				DBUSEAREA( .T. , "TOPCONN" , TcGenQry(,, cQry ) , _cAlias , .T., .F. )

				(_cAlias)->(dbGoTop())
				IF (_cAlias)->TOT <> nConta
					lCidAtendeOPL:=.F.
				ENDIF
				_cLOG+="SELECT DO ZGL:  "+cQry+CRLF
				_cLOG+="RESULTADO DO SELECT ZGL: (_cAlias)->TOT = "+CVALTOCHAR((_cAlias)->TOT)+CRLF
				_cLOG+=" Qtde de itens:  nConta = "+CVALTOCHAR(nConta)+CRLF
				_cLOG+=" [IF (_cAlias)->TOT <> nConta] => lCidAtendeOPL = "+IF(lCidAtendeOPL,"VERDADEIRO","FALSO")+CRLF

				IF lCidAtendeOPL
					For _nI := 1 To Len(_aRecnoSZW)
						SZW->(DbGoTo(_aRecnoSZW[_nI]))
						IF !SZW->ZW_TIPO $ "01,08,10"
							_cLOG+="IF !SZW->ZW_TIPO [ "+SZW->ZW_TIPO+" ] $ 01,08 => DEU LOOP"+CRLF
							LOOP
						ENDIF
						_cLOG+="IF SZW->ZW_TIPO [ "+SZW->ZW_TIPO+" ] <> 01 => NAO DEU LOOP"+CRLF
						_cLOCBZ :=(ALLTRIM(POSICIONE("SBZ",1,_cfilpro+SZW->ZW_PRODUTO,'BZ_LOCPAD')))
						SZW->(RecLock("SZW",.F.))
						IF _cfilpro = "90" .AND. SZW->ZW_TIPO = "01" //IGONORA 08
							SZW->ZW_TIPO:=cTipPed:=cTp:="12"
						ELSEIF _cfilpro = "40" .AND. SZW->ZW_TIPO <> '10' //VALE PARA 01 E 08 E <> 10
							SZW->ZW_TIPO:=cTipPed:=cTp:="31"
						ENDIF
						If _cLOCBZ == '20'
							SZW->ZW_LOCAL := "50"
						ELSE
							SZW->ZW_LOCAL := "52"
						EndIf
						_cLOG+="Procurou _cfilpro+SZW->ZW_PRODUTO = "+_cfilpro+" "+SZW->ZW_PRODUTO+CRLF
						_cLOG+="Buscou POSICIONE(SBZ,1,_cfilpro+SZW->ZW_PRODUTO,'BZ_LOCPAD') = "+_cLOCBZ+CRLF
						_cLOG+="Alterou para SZW->ZW_TIPO = "+SZW->ZW_TIPO+CRLF
						_cLOG+="Alterou para SZW->ZW_LOCAL = "+SZW->ZW_LOCAL+CRLF
						SZW->(MsUnLock())
					Next
					BREAK
				ENDIF

			ENDIF

			//==============================================================================================
			// Efetua a leitura dos dados da tabela SZW para determinar os armazens dos itens.
			//==============================================================================================

			IF _cfilpro == "90"
				SZW->( DBSetOrder(1) )
				SZW->( DBSeek( _cCodFil + _cIdPedido ) )
				Do While SZW->( !EOF() ) .AND. _cCodFil + _cIdPedido == SZW->( ZW_FILIAL + ZW_IDPED )
//--------------------// JPP TESTE - Alterar este trecho.
                    If  ALLTRIM(SZW->ZW_PRODUTO) $ _cProexc .And. _nSomaPeso > _nPesoParam //Produto de exceção que deve voltar para o armazém 36 se não estiver  

						Reclock("SZW",.F.)
						SZW->ZW_LOCAL := '36'
						SZW->(Msunlock())

						_lHaArmz36 := .T.

					Endif

					SZW->(DbSkip())

				EndDo

				//Revalida flags de armazém de terceiros
				_lHaArmz36  := .F.
				_lSoArmaz36 := .T.
				For _nI := 1 To Len(_aRecnoSZW)

					SZW->(DbGoTo(_aRecnoSZW[_nI]))
					If SZW->ZW_LOCAL == '36'
						_lHaArmz36 := .T.
					Else
						_lSoArmaz36 := .F.
					Endif

				Next

				If _lHaArmz36 .And. !_lSoArmaz36 //Diversos Armazéns
					For _nI := 1 To Len(_aRecnoSZW)
						SZW->(DbGoTo(_aRecnoSZW[_nI]))
						_cRevenda :=(ALLTRIM(posicione("SBZ",1,_cfilpro+SZW->ZW_PRODUTO,'BZ_I_REVEN')))
						If SZW->ZW_LOCAL == '36'
							If _cRevenda == "S"
								SZW->(RecLock("SZW",.F.))
								SZW->ZW_LOCAL := _cArmzRevenda  //22
								SZW->(MsUnLock())
							Else
								SZW->(RecLock("SZW",.F.))
								SZW->ZW_LOCAL := _cArmzLocal  //30
								SZW->(MsUnLock())
							EndIf
						EndIf
					Next
				EndIf


				//=============================================================================================
				// Quando todos os itens forem armazem 36, Ignora-se as regras anteriores. Se o peso dos itens
				// for menor que o peso do parâmetro. Aplica-se a regra da estrutura.
				//=============================================================================================

				If _lSoArmaz36
					For _nI := 1 To Len(_aRecnoSZW)
						SZW->(DbGoTo(_aRecnoSZW[_nI]))
						If _nSomaPeso < _nPesoParam //.OR. SZW->ZW_TIPO <> "25"
							_cRevenda :=(ALLTRIM(posicione("SBZ",1,_cfilpro+SZW->ZW_PRODUTO,'BZ_I_REVEN')))
							If _cRevenda == "S"
								SZW->(RecLock("SZW",.F.))
								SZW->ZW_LOCAL := "22"
								SZW->(MsUnLock())
							Else
								SZW->(RecLock("SZW",.F.))
								SZW->ZW_LOCAL := "20"
								SZW->(MsUnLock())
							EndIf
						EndIf
					Next
				EndIf

			ENDIF
		End Sequence

		IF !EMPTY(_cLOG) .AND. GetMV( "IT_AO116LO" ,,.F.)
			_cFileNome:="\data\Italac\NT\LOGS\AOMS112_"+_cCodFil+"__"+ALLTRIM(_cIdPedido)+"__"+STRTRAN(TIME(),":","_")+".TXT"
			MemoWrite(_cFileNome,_cLOG)
		ENDIF

Return Nil
/*
===============================================================================================================================
Programa--------: AOMS112DI
Autor-----------: Josué Danich
Data da Criacao-: 03/05/2019
===============================================================================================================================
Descrição-------: Desmarca impressão
===============================================================================================================================
Parametros------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112DI(oproc)

	Local _nposi := TRBF->(Recno())
	Private _aPed			:= {}

	TRBF->( DBGoTop() )

//================================================================================
//Imprime todos os pedidos selecionados
//================================================================================
	Do While TRBF->(!EOF())

		//================================================================================
		// Somente pedidos selecionados pelo usuario
		//================================================================================
		If (TRBF->OK == cmarca .and. !linverte) .or. (TRBF->OK != cmarca .and. linverte)

			SZW->(Dbsetorder(1))
			If SZW->(Dbseek(substr(TRBF->FILIAL,1,2)+TRBF->NUMPED))

				aadd(_aped,{ALLTRIM(SZW->ZW_FILIAL) ,ALLTRIM(SZW->ZW_IDPED) , ALLTRIM(SZW->ZW_CLIENTE) , ALLTRIM(SZW->ZW_LOJACLI) ,  SZW->ZW_VEND1 })

				TRBF->( Reclock( "TRBF", .F. ) )
				TRBF->IMPRIME := '2-NAO'
				TRBF->( MsUnlock() )

				aarr[ascan(aarr,{|x| x[Len(x)] == TRBF->(Recno())}),04] := '2-NAO'

				Do while 	substr(TRBF->FILIAL,1,2)+TRBF->NUMPED == SZW->ZW_FILIAL+SZW->ZW_IDPED

					SZW->( Reclock( "SZW", .F. ) )
					SZW->ZW_IMPRIME := ' '
					SZW->( MsUnlock() )

					SZW->(Dbskip())

				Enddo

			Endif

		Endif

		TRBF->(DBSKIP())

	Enddo

	If len(_aped) = 0

		//Imprime somente pedido posicionado
		TRBF->(Dbgoto(_nposi))

		SZW->(Dbsetorder(1))
		If SZW->(Dbseek(substr(TRBF->FILIAL,1,2)+TRBF->NUMPED))

			TRBF->( Reclock( "TRBF", .F. ) )
			TRBF->IMPRIME := '2-NAO'
			TRBF->( MsUnlock() )

			aarr[ascan(aarr,{|x| x[Len(x)] == TRBF->(Recno())}),04] := '2-NAO'


			Do while 	substr(TRBF->FILIAL,1,2)+TRBF->NUMPED == SZW->ZW_FILIAL+SZW->ZW_IDPED

				SZW->( Reclock( "SZW", .F. ) )
				SZW->ZW_IMPRIME := ' '
				SZW->( MsUnlock() )

				SZW->(Dbskip())

			Enddo

		Endif

	Endif

//Atualiza tela
	fwmsgrun(,{|| AOMS112arq(oproc)},"5 - Aguarde...","Atualizando tela...")

	omark:setarray(aarr)
	omark:refresh()
	ProcessMessages()

//Retorna browse ao pedidos posicionado
	TRBF->(Dbgoto(_nposi))

Return()

/*
===============================================================================================================================
Programa--------: AOMS112ENT
Autor-----------: Josué Danich
Data da Criacao-: 10/05/2019
===============================================================================================================================
Descrição-------: Valida Data de entrega do pedido
===============================================================================================================================
Parametros------:	_lAutoref - execução de pedidos múltiplos
===============================================================================================================================
Retorno---------:  lRet := Informa se validou os preços do pedido 
===============================================================================================================================
*/
Static Function AOMS112ENT(_lAutoref )

	Local _lOk		 := .T.
	Local dDtEnt     := SZW->ZW_FECENT
	Local dDtAgenMax := SZW->ZW_FECENT
	Local _cTpAgenda := If(SZW->ZW_I_AGEND$"PIAMO",SZW->ZW_I_AGEND,"I")
	Local _cFilCarreg := ""

	Private aheader  := {{1,"C6_ITEM"},{2,"C6_PRODUTO"},{3,"C6_LOCAL"}}
	Private acols    := {}

	_cFilCarreg := SZW->ZW_FILIAL

	If !EMPTY(SZW->ZW_FILPRO) .AND. !(ALLTRIM(SZW->ZW_FILPRO)=='0')
		_cFilCarreg := SZW->ZW_FILPRO
	EndIf

//Se é entrega agendada ou agendada com multa faz validação de transit time
	If	ALLTRIM(_cTpAGenda) == 'A' .or.  ALLTRIM(_cTpAGenda) == 'M'

		//If !(U_OMSVLDENT(dDtEnt, SZW->ZW_CLIENTE,SZW->ZW_LOJACLI,SZW->ZW_FILIAL,SZW->ZW_IDPED,0,.F.,_cFilCarreg,SZW->ZW_TIPO,SZW->ZW_TPVENDA))

		dDtEnt := DATE()+u_omsvldent(DATE(),SZW->ZW_CLIENTE,SZW->ZW_LOJACLI,SZW->ZW_FILIAL,SZW->ZW_IDPED,1,.F.,_cFilCarreg,SZW->ZW_TIPO,SZW->ZW_TPVENDA)

		dDtAgenMax := U_DTVAL112(dDtEnt)

		If dDtEnt == DATE()

			//Falha de regra
			_cmens := "Cad. de Transit Time não encontradao ou Qtd Dias Zerado para pedido, verificar o Cad. de Transit Time x Dados do Cliente/Remessa."
			_lOk := .F.

		ElseIf SZW->ZW_FECENT < dDtEnt

			_cmens := "Data de Entrega "+DTOC(SZW->ZW_FECENT)+" menor que transit time, data mínima de Entrega : " + dtoc(dDtEnt)
			_lOk := .F.

		ElseIf SZW->ZW_FECENT > dDtAgenMax

			_cmens := "Data de Agendamento "+DTOC(SZW->ZW_FECENT)+" maior que a Data Máxima permitida para Agendamento, data máxima: " + dtoc(dDtAgenMax)
			_lOk := .F.

		Endif

		If _lAutoref .And. !_lOk

			SA1->(Dbsetorder(1))
			SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

			aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),SZW->ZW_FILIAL,ALLTRIM(SZW->ZW_IDPED),SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME),_cmens})

		ElseIf !_lOk

			u_itmsg(_cmens,"Atenção","Verifique regra de transit time para a cidade do pedido",1)

		Endif

	Endif

Return( _lok )

/*
===============================================================================================================================
Programa--------: AOMS112K
Autor-----------: Josué Danich
Data da Criacao-: 15/05/2019
===============================================================================================================================
Descrição-------: Valida Data de entrega do pedido
===============================================================================================================================
Parametros------:	_cclirem - código do cliente selecionado
									_clojrem - codigo da loja selecionada
===============================================================================================================================
Retorno---------:  _lRet := Informa se validou os preços do pedido 
===============================================================================================================================
*/
Static Function AOMS112K(_cclirem,_clojrem)

	Local _lret := .T.

	BEGIN SEQUENCE

//Não pode escolher mesmo cliente do pedido para remessa
		If !EMPTY(_cclirem) .and. ALLTRIM(_cclirem) + ALLTRIM(_clojrem) == ALLTRIM(TRBF->CODCLI)+ALLTRIM(TRBF->LOJA)

			u_itmsg("Não é permitido escolher mesmo Cliente/Remessa do pedido para remessa","Atenção",,1)
			_lret := .F.
			Break

		Endif

//Se escolheu cliente vazio e já está selecionada operação triangular pergunta se quer limpar operação
		If empty(_cclirem) .and. !empty(TRBF->CLIREM)

			If !(u_itmsg("Eliminar operação triangular desse pedido?(" + ALLTRIM(TRBF->NUMPED) + ")","Atenção",,3,2,2))

				_lret := .F.
				Break

			Endif

		Endif

		SA1->(Dbsetorder(1))
		If !(SA1->(Dbseek(xfilial("SA1")+ALLTRIM(_cclirem)+ALLTRIM(_clojrem))))

			u_itmsg("Cliente/Remessa não localizado no cadastro: "+_cclirem+ "/"+_clojrem,"Atenção",,1)
			_lret := .F.
			Break

		Elseif SA1->A1_MSBLQL = '1'

			u_itmsg("Cliente/Remessa bloqueado","Atenção",SA1->A1_COD + "/"+SA1->A1_LOJA + " - "+ALLTRIM(SA1->A1_NOME),1)
			_lret := .F.
			Break

		Endif


	END SEQUENCE

Return _lret

/*
===============================================================================================================================
Programa--------: aoms112B
Autor-----------: Julio de Paula Paz
Data da Criacao-: 22/01/2018
===============================================================================================================================
Descrição-------: Permite alterar o armazem do item de Pedido, na efetivação do Pedido de Vendas do Portal.
===============================================================================================================================
Parametros------: _nLin = Numero da linha do ACols.
                  _nPosLocal = Coluna do ACols que possui o código do armazem.
                  _nPosProd = Posição do código do produto no aCols.
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function aoms112B(_nLin, _nPosLocal,_nPosProd) //aoms112B(_nLin, _nPosLocal)
	Local _bOk, _bCancel
	Local _oDlgLocal
	Local _lRet := .T.
	Local _cTitulo
	Local _cArmazAtu, _cArmazNovo, _cCodProduto
	Local _cItem, _aItens := {"Atual (Posicionado)","Todos os Itens"}
	Local _nAjusteLin := 30
	Local _nI

	Begin Sequence
		//================================================================================
		// Tela de Alteração do Armazem do item de Pedido de Vendas
		//================================================================================
		_cTitulo := "Alteração do Armazem do item de Pedido de Vendas"
		_bOk := {|| If(U_aoms112D(_cArmazNovo,_cCodProduto),(_lRet := .T., _oDlgLocal:End()),)}
		_bCancel := {|| _lRet := .F., _oDlgLocal:End()}

		_cArmazAtu := aCols[_nLin, _nPosLocal]

		_cArmazNovo := _cArmazAtu

		_cCodProduto := aCols[_nLin, _nPosProd]

		Define MsDialog _oDlgLocal Title _cTitulo From 9,0 To 22,55 Of oMainWnd

		@ 06+_nAjusteLin,20 Say "Item a Ser Alterado: " Of _oDlgLocal Pixel
		@ 06+_nAjusteLin,80 ComboBox _cItem Items _aItens Of _oDlgLocal Pixel Size 080,010

		@ 26+_nAjusteLin,20 Say "Armazem Atual: " Of _oDlgLocal Pixel
		@ 25+_nAjusteLin,80 Get _cArmazAtu Size 30, 10 WHEN .F. Of _oDlgLocal Pixel

		@ 46+_nAjusteLin,20 Say "Novo Armazem: " Of _oDlgLocal Pixel
		@ 45+_nAjusteLin,80 MsGet _cArmazNovo F3 "NNR" Size 30, 10 Valid(U_aoms112D(_cArmazNovo,_cCodProduto )) Of _oDlgLocal Pixel

		Activate MsDialog _oDlgLocal On Init EnchoiceBar(_oDlgLocal,_bOk,_bCancel) CENTERED

		//================================================================================
		// Altera o armazem do Acol se confirmado a alteração pele usuário.
		//================================================================================
		If _lRet
			If _cItem == "Atual (Posicionado)"
				aCols[_nLin, _nPosLocal] := _cArmazNovo
			Else
				For _nI := 1 To Len(aCols)
					aCols[_nI, _nPosLocal] := _cArmazNovo
				Next
			EndIf
		EndIf

	End Sequence

Return Nil

/*
===============================================================================================================================
Programa--------: aoms112D
Autor-----------: Julio de Paula Paz
Data da Criacao-: 22/01/2018
===============================================================================================================================
Descrição-------: Permite alterar o armazem do item de Pedido, na efetivação do Pedido de Vendas do Portal. Validação.
===============================================================================================================================
Parametros------: _cArmazNovo  = Novo código do Armazem.
                  _cCodProduto = Código do Produto.
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function aoms112D(_cArmazNovo,_cCodProduto)
	Local _lRet := .T.
	Local _aOrd := SaveOrd({"SB2","NNR"})
	Begin Sequence
		SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
		NNR->(DbSetOrder(1)) // NNR_FILIAL+NNR_CODIGO

		If Empty(_cArmazNovo)
			U_ITMSG("O novo código do armazem precisa ser informado.","Atenção.", ,1)
			lRet := .F.
			Break
		EndIf

		If ! NNR->(DbSeek(xFilial("NNR")+_cArmazNovo))
			U_ITMSG("O código de armazem informado não existe. ","Atenção.", ,1)
			lRet := .F.
			Break
		EndIf

	End Sequence

	RestOrd(_aOrd)

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS112I
Autor-------------: Alex Wallauer
Data da Criacao---: 06/01/2020
===============================================================================================================================
Descrição---------: Processamento de Importação de Pedidos do Broker via arquivo CSV
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function AOMS112I()
	Local _aParAux := {},nI
	Local _aParRet := {}
	Local _bOK     := {|| .T. }

	MV_PAR01:=SPACE(200)
	aAdd( _aParAux , { 1 , "Selecione arquivo .CSV:",MV_PAR01, "@!"	, "", "DIR","", 100, .T. } )

	For nI := 1 To Len( _aParAux )
		aAdd( _aParRet , _aParAux[nI][03] )
	Next nI
// 1 - < aParametros > - Vetor com as configurações
// 2 - < cTitle >      - Título da janela
// 3 - < aRet >        - Vetor passador por referencia que contém o retorno dos parâmetros
// 4 - < bOk >         - Code block para validar o botão Ok
// 5 - < aButtons >    - Vetor com mais botões além dos botões de Ok e Cancel
// 6 - < lCentered >   - Centralizar a janela
// 7 - < nPosX >       - Se não centralizar janela coordenada X para início
// 8 - < nPosY >       - Se não centralizar janela coordenada Y para início
// 9 - < oDlgWizard >  - Utiliza o objeto da janela ativa
//10 - < cLoad >       - Nome do perfil se caso for carregar
//11 - < lCanSave >    - Salvar os dados informados nos parâmetros por perfil
//12 - < lUserSave >   - Configuração por usuário
//        aParametros,cTitle,aRet     ,bOk ,aButtons,lCentered,nPosX,nPosY,oDlgWizard,cLoad,lCanSave,lUserSave
	IF !ParamBox( _aParAux , "" ,@_aParRet,_bOK,        ,         ,     ,     ,          ,     ,.T.     ,.T. )//Intervalo de Datas e Filial
		RETURN .F.
	EndIf

	FWMSGRUN( ,{|oProc| U_AOMS112I(oProc) },,'Iniciando o processamento...' )

RETURN .T.

/*
===============================================================================================================================
Programa----------: AOMS112I
Autor-------------: Alex Wallauer
Data da Criacao---: 06/01/2020
===============================================================================================================================
Descrição---------: Processamento de Importação de Pedidos do Broker via arquivo CSV
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS112I(oProc)
	LOCAL _nCpo,_cTot
	Local lHtml:= (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml
	PRIVATE _aPercLeiteMadro:={}

	oProc:cCaption := ("Lendo dados do arquivo CSV...")
	ProcessMessages()

	_cArq := ALLTRIM(MV_PAR01)

	IF lHtml
		cDirDest:="\DATA\LAMBERT\"
		IF CpyT2S( _cArq , cDirDest )
			_cArq:=cDirDest+SubStr(_cArq,RAt('\',_cArq) )
		ELSE
			U_ITMSG("Não foi possível COPIAR o arquivo informado "+_cArq+" PARA: "+cDirDest,;
				"Arquivo inválido","O arquivo informado deve ser .CSV ou verificar se o arquivo informado esta correto.",1)
			RETURN .F.
		ENDIF
	ENDIF

//AVISO("_cArq",_cArq,{"Fechar"},3)

	IF UPPER(RIGHT(_cArq,3)) <> "CSV" .OR. FT_FUSE(_cArq) = -1
		U_ITMSG("Não foi possível abrir o arquivo informado: "+_cArq,;
			"Arquivo inválido","O arquivo informado deve ser .CSV ou verificar se o arquivo informado esta correto.",1)
		RETURN .F.
	ENDIF

	_cTot:=FT_FLASTREC()-1
	_cTot:=ALLTRIM(STR(_cTot))
	_nTam:=LEN(_cTot)+1

	FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
	_cDados := FT_FREADLN()

	lLambert:=.F.
	lOutros:=.F.
	If "COD PEDIDO;CNPJ;COD CLIENTE;ITEM;QTD UNI;QTD DA CAIXA;VALORT DO ITEM;FORMA PG;VL_UNI;QTD CX;VL UNI SEM IMPOSTO;COD REPRESENTANTE;COD TABELA;FILIAL" $ UPPER(ALLTRIM(_cDados))
		lOutros:=.T.
	ELSE
		FT_FUSE()
		U_ITMSG("O arquivo "+_carq+" informado para relizar a importação não tem o layout padrão.",;
			"Arquivo com formato inválido",;
			"O CSV deve ter as colunas [ COD PEDIDO;CNPJ;COD CLIENTE;ITEM;QTD UNI;QTD DA CAIXA;VALORT DO ITEM;FORMA PG;VL_UNI;QTD CX;VL UNI SEM IMPOSTO;COD REPRESENTANTE;COD TABELA;FILIAL ] e o mesmo deve ser salvo "+;
			"no Excel no formato [ CSV (separado por virgulas) ] e "+;
			"no LibreOffice Calc com Demilitador de campo Ponto e Virgula e sem delimitador de texto.",1)
		RETURN .F.
	ENDIF

	FT_FSKIP()
	_aDados:={}
	_nCont:=_nConta:=0
	_nErro:=0
	_aPedErro:={}
	_aItemRepetido={}
	SB1->(DBSETORDER(1))
	DA1->(DBSETORDER(1))
	SA1->(DBSETORDER(1))
	SZW->(DBSETORDER(17))//COD PEDIDO --> ZW_PEDIMPO

	DO WHILE !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO

		_nCont++
		oProc:cCaption := ("Lendo Dados do TXT: "+ STRZERO(_nCont,_nTam) +" de "+ _cTot)
		ProcessMessages()

		_cDados := FT_FREADLN()
		_cDados := STRTRAN(_cDados,'"','')//Tem que ter ate 6 colunas
		_cDados := STRTRAN(_cDados,'.','') //Campos com PONTO por Branco
		_cDados := STRTRAN(_cDados,',','.')//Campos com decimais "virugla por ponto"

		IF EMPTY(_cDados)
			FT_FSKIP()
			LOOP
		ENDIF
		//Verifica se é final de arquivo
		IF ALLTRIM(_cDados) = ';;;;;'
			FT_FSKIP()
			LOOP
		ENDIF
		_nConta++

		_aLinhas:= StrTokArr2(_cDados,";",.T.)//Tem que ter ate 6 colunas
		_aItens:={}

		IF LEN(_aLinhas) < 11
			_aLinhas:=U_ITTXTARRAY(_cDados,"",11,11)
		ENDIF

		AADD(_aItens,.T.)                                   //01
		AADD(_aItens,IF(LEN(_aLinhas) > 00,_aLinhas[01],""))//02
		AADD(_aItens,IF(LEN(_aLinhas) > 01,_aLinhas[02],""))//03
		AADD(_aItens,IF(LEN(_aLinhas) > 02,_aLinhas[03],""))//04
		AADD(_aItens,IF(LEN(_aLinhas) > 03,_aLinhas[04],""))//05
		AADD(_aItens,IF(LEN(_aLinhas) > 04,_aLinhas[05],""))//06
		AADD(_aItens,IF(LEN(_aLinhas) > 05,_aLinhas[06],""))//07
		AADD(_aItens,IF(LEN(_aLinhas) > 06,_aLinhas[07],""))//08
		AADD(_aItens,IF(LEN(_aLinhas) > 07,_aLinhas[08],""))//09
		AADD(_aItens,IF(LEN(_aLinhas) > 08,_aLinhas[09],""))//10
		AADD(_aItens,IF(LEN(_aLinhas) > 09,_aLinhas[10],""))//11
		AADD(_aItens,IF(LEN(_aLinhas) > 10,_aLinhas[11],""))//12
		//Outros
		AADD(_aItens,IF(LEN(_aLinhas) > 11,_aLinhas[12],""))//13 COD REPRESENTANTE
		AADD(_aItens,IF(LEN(_aLinhas) > 12,_aLinhas[13],""))//14 COD TABELA
		AADD(_aItens,IF(LEN(_aLinhas) > 13,_aLinhas[14],""))//15 FILIAL

		AADD(_aItens,IF(LEN(_aLinhas) > 14,_aLinhas[15],""))//16 PEDIDO CLIENTE
		AADD(_aItens,IF(LEN(_aLinhas) > 15,_aLinhas[16],""))//17 OBS PARA NFE

		AADD(_aItens,IF(LEN(_aLinhas) > 16,_aLinhas[17],""))//18 TIPO DE ENTREGA
		AADD(_aItens,IF(LEN(_aLinhas) > 17,_aLinhas[18],""))//19 DATA DE ENTREGA

		AADD(_aItens,""                                    )//20 Erro -> LEN(_aItens)

		_lAchouSA3:=.F.
		cCODVEND:=""
		IF EMPTY(_aItens[13])  //13 COD REPRESENTANTE
			_aItens[1]:=.F.
			_aItens[LEN(_aItens)]+="[ COD REPRESENTANTE não INFORMADO ] "+CRLF
		ENDIF

		//QUANDO É Lambert posiciona no SA3 para pegar a tabela de preço
		IF !EMPTY(_aItens[13])  //13 COD REPRESENTANTE
			cCODVEND:=STRZERO(VAL(ALLTRIM(_aItens[13])),6)
			SA3->(Dbsetorder(1))
			If SA3->(Dbseek(xfilial("SA3")+ALLTRIM(cCODVEND)))
				_aItens[13]:=SA3->A3_COD+" - "+ALLTRIM(SA3->A3_NOME)+" ["+_aItens[13]+"]"//NÃO MEXER NA ORDEM USO PARA DAR SEEK PARA FRENTE
				_lAchouSA3:=.T.
			ELSE
				_aItens[1]:=.F.
				_aItens[LEN(_aItens)]+="[ COD REPRESENTANTE não Encontrado ] "+CRLF
			ENDIF
		ENDIF

		IF EMPTY(_aItens[15])//15 FILIAL
			_aItens[1]:=.F.
			_aItens[LEN(_aItens)]+="[ FILIAL não INFORMADA ] "+CRLF
		ELSE
			SM0->(dbSetOrder(1))
			IF !SM0->(dbSeek(cEmpAnt + _aItens[15]))
				_aItens[1]:=.F.
				_aItens[LEN(_aItens)]+="[ FILIAL invalida ] "+CRLF
			ENDIF
		ENDIF

		SZW->(DBSETORDER(17))// ZW_FILIAL+ZW_PEDIMPO
		IF EMPTY(_aItens[2])
			_aItens[1]:=.F.
			_aItens[LEN(_aItens)]+="[ COD PEDIDO não INFORMADO ] "+CRLF
		ELSEIF !EMPTY(cCODVEND) .AND. !EMPTY(_aItens[15]) .AND. SZW->(DBSEEK(_aItens[15]+U_ITkey(_aItens[2],"ZW_PEDIMPO")+cCODVEND))//ZW_PEDIMPO
			_aItens[1]:=.F.
			_aItens[LEN(_aItens)]+="[ Cod. Vend.+Cod. Ped. Imp. (PEDIMPO): (	"+cCODVEND+"+"+ALLTRIM(_aItens[2])+") já importado no Pedido Portal (IDPED): ("+_aItens[15]+" "+ALLTRIM(SZW->ZW_IDPED)+") ] "+CRLF
		ENDIF
// FOI RETIRADA ESSA VALIDACAO PQ O CAMPO 
		//SZW->(DBSETORDER(1))//COD PEDIDO ZW_IDPED VAI SER NUMERADO POR NOIS
		//IF _aItens[1] .AND. !EMPTY(cCODVEND) .AND. !EMPTY(_aItens[15]) .AND. SZW->(DBSEEK(_aItens[15]+SUBSTR(cCODVEND,3,4)+"-"+_aItens[2] ))
		//	_aItens[1]:=.F.
		//	_aItens[LEN(_aItens)]+="[ COD PEDIDO já usado em um Ped.do Portal: "+_aItens[15]+" "+ALLTRIM(SZW->ZW_IDPED)+" ] "+CRLF
		//ENDIF

		_lAchouSA1:=.F.
		IF EMPTY(_aItens[3])
			_aItens[1]:=.F.
			_aItens[LEN(_aItens)]+="[ CNPJ não informado ] "+CRLF
		ELSE
			cCPFCNPJ  :=STRZERO(VAL(ALLTRIM(_aItens[3])),14)
			SA1->(Dbsetorder(3))
			If SA1->(Dbseek(xfilial("SA1")+ALLTRIM(cCPFCNPJ)))
				cCPFCNPJ  :=SUBSTR(cCPFCNPJ,1,2)+"."+Substr(cCPFCNPJ,3,3)+"."+Substr(cCPFCNPJ,6,3)+"/"+Substr(cCPFCNPJ,9,4)+"-"+ Substr(cCPFCNPJ,13,2)
				_aItens[3]:=SA1->A1_COD+"-"+SA1->A1_LOJA+" - "+ALLTRIM(SA1->A1_NOME)+" ["+cCPFCNPJ+"]"//NÃO MEXER NA ORDEM USO PARA DAR SEEK PARA FRENTE
				_lAchouSA1:=.T.
			ELSE
				cCPFCNPJ  :=SUBSTR(cCPFCNPJ,1,2)+"."+Substr(cCPFCNPJ,3,3)+"."+Substr(cCPFCNPJ,6,3)+"/"+Substr(cCPFCNPJ,9,4)+"-"+ Substr(cCPFCNPJ,13,2)
				_aItens[3]:="["+cCPFCNPJ+"]"
				_aItens[1]:=.F.
				_aItens[LEN(_aItens)]+="[ CNPJ não Encontrado ] "+CRLF
			ENDIF
		ENDIF

		IF _lAchouSA1 .AND. _lAchouSA3
			IF SA1->A1_VEND <> SA3->A3_COD .And. SA1->A1_I_VEND2 <> SA3->A3_COD
				_aItens[1]:=.F.
				_aItens[LEN(_aItens)]+="[ Cliente/Remessa não pertence ao Vendedor ("+SA3->A3_COD+") / Vendedor do Cliente ("+SA1->A1_VEND+") ] "+CRLF
			ENDIF
		ENDIF

		IF EMPTY(_aItens[14])//14 COD TABELA
			IF _lAchouSA1 .AND. !EMPTY(SA1->A1_TABELA)
				_aItens[14]:=LEFT(SA1->A1_TABELA,LEN(DA1->DA1_CODTAB))
			ELSEIF _lAchouSA3
				_aItens[14]:=LEFT(SA3->A3_I_TABPR,LEN(DA1->DA1_CODTAB))
			ENDIF
		ENDIF
		IF EMPTY(_aItens[14])//14 COD TABELA
			_aItens[1]:=.F.
			_aItens[LEN(_aItens)]+="[ COD TABELA não informado ] "+CRLF
		ENDIF
		cTabPreco:=_aItens[14]

		IF !EMPTY(cTabPreco) .AND. !DA1->(Dbseek(xFilial("DA1")+cTabPreco))
			_aItens[1]:=.F.
			_aItens[LEN(_aItens)]+="[ COD TABELA PREÇO não encontrado: " + cTabPreco + "] "+CRLF
		ENDIF

		IF EMPTY(_aItens[5])
			_aItens[1]:=.F.
			_aItens[LEN(_aItens)]+="[ ITEM não informada ] "+CRLF
		ELSE
			_aItens[5]:=STRZERO(VAL(ALLTRIM(_aItens[5])),11)

			IF ASCAN(_aItemRepetido,_aItens[2]+_aItens[5]) = 0
				AADD(_aItemRepetido,_aItens[2]+_aItens[5])
			ELSE
				_aItens[1]:=.F.
				_aItens[LEN(_aItens)]+="[ ITEM REPETIDO ("+ALLTRIM(_aItens[5])+") ] "
			ENDIF

			_aItens[12]:=STRTRAN(UPPER(_aItens[12]),"R$","")

			IF VAL(_aItens[12]) <=  0   // Preço Unitário estive zerado, buscar o Preço Item com Impostos
				_aItens[12] := _aItens[10]  //Vlr com Impostos
			ENDIF

			IF !SB1->(DBSEEK(xFilial()+_aItens[5]))
				_aItens[1]:=.F.
				_aItens[LEN(_aItens)]+="[ ITEM não encontrado no Protheus ] "+CRLF
			ELSE
				IF !DA1->(Dbseek(xFilial("DA1")+cTabPreco+_aItens[5]))
					_aItens[1]:=.F.
					_aItens[LEN(_aItens)]+="[ ITEM não encontrado na Tabela de Preço: " + cTabPreco +"] "+CRLF

				ELSEif Round(VAL(_aItens[12]),2)  > DA1->DA1_PRCMAX
					_aItens[1]:=.F.
					_aItens[LEN(_aItens)]+="[ Preço acima do máximo: " + ALLTRIM(transform(DA1->DA1_PRCMAX,"@E 999,999,999.99"))+" da Tabela de Preço: " + cTabPreco +"] "+CRLF

				Elseif Round(VAL(_aItens[12]),2) < DA1->DA1_I_PMF3
					_aItens[1]:=.F.
					_aItens[LEN(_aItens)]+="[ Preço abaixo do mínimo da Faixa 3: " + ALLTRIM(transform(DA1->DA1_I_PMF3,"@E 999,999,999.99"))+" da Tabela de Preço: " + cTabPreco +"] "+CRLF

				ENDIF

				cArm:= POSICIONE("SBZ",1,_aItens[15]+_aItens[5],"BZ_LOCPAD")

				IF SA3->A3_I_VBROK == 'B'
					IF cArm = "20"
						cArm:= "50"
					ELSE
						cArm:= "52"
					ENDIF
				ENDIF

				_aItens[5]:=_aItens[5]+" [ "+cArm+" ] [ "+ALLTRIM(SB1->B1_DESC)+" ]"
			ENDIF
		ENDIF

		IF VAL(_aItens[6]) <= 0
			_aItens[1]:=.F.
			_aItens[LEN(_aItens)]+="[ QTD UNI invalida ] "+CRLF
		ENDIF
		IF VAL(_aItens[7]) <= 0
			_aItens[1]:=.F.
			_aItens[LEN(_aItens)]+="[ QTD DA CAIXA invalida ] "+CRLF
		ENDIF
		IF EMPTY(_aItens[9])
			_aItens[1]:=.F.
			_aItens[LEN(_aItens)]+="[ FORMA PG nao informada ] "+CRLF
		ELSE
			_cE4_I_PRZMD:="  "
			IF LEN(ALLTRIM(_aItens[09])) < 3
				_aItens[09]:=strzero(val(_aItens[09]),LEN(SE4->E4_CODIGO))
			ENDIF
			_cCond:=ALLTRIM(Posicione("SE4",1,xFilial("SE4") +_aItens[09] ,"E4_DESCRI"))
			_aItens[09]:=_aItens[09]+" - "+_cCond
			_cE4_I_PRZMD:=SE4->E4_I_PRZMD

			IF EMPTY(_cCond)
				_aItens[1]:=.F.
				_aItens[LEN(_aItens)]+="[FORMA PG nao encontrada] "+CRLF
			ELSEIF SE4->E4_I_PRZMD = 1
				_aItens[1]:=.F.
				_aItens[LEN(_aItens)]+="[Prazo de pagamento a vista antecipado não permitido] "+CRLF
			ELSEIF _lAchouSA1 .AND. SE4->(dbSeek(xFilial("SE4")+SA1->A1_COND)) .AND. _cE4_I_PRZMD > SE4->E4_I_PRZMD
				_aItens[1]:=.F.
				_aItens[LEN(_aItens)]+="[Prazo medio do Pedido: "+STR(_cE4_I_PRZMD,3)+", maior que o do Cliente/Remessa: "+STR(SE4->E4_I_PRZMD,3)+"] "+CRLF
			ENDIF
		ENDIF

		IF VAL(_aItens[11]) <= 0
			_aItens[1]:=.F.
			_aItens[LEN(_aItens)]+="[QTD CX invalida] "
		ENDIF
		IF (_aItens[17]) $ "IMEDIATA/AGENDADO"
			_aItens[1]:=.F.
			_aItens[LEN(_aItens)]+="[ TIPO DE ENTREGA invalida ] "+CRLF
		ENDIF

		IF _aItens[1] = .F.
			AADD(_aPedErro,_aItens[2])
			_nErro++
		ENDIF
		AADD(_aDados,_aItens)

		FT_FSKIP()

	ENDDO

	FT_FUSE()

	SZW->(DBSETORDER(1))

	If LEN(_aDados) > 0
		_aPercLeiteMadro:={}
		FOR _nCpo := 1 TO LEN(_aDados)
			IF _aDados[_nCpo,1] .AND. ASCAN(_aPedErro,_aDados[_nCpo,2]) <> 0//Se achou
				_aDados[_nCpo,1]:=.F.//Se um der errado não vai integra o pedido todo
				_aDados[_nCpo,LEN(_aDados[1])]:="[Pedido com 1 ou mais itens com erro] "
			ENDIF

			//IF _aDados[_nCpo,1]

			IF (_nPos:=ASCAN(_aPercLeiteMadro, {|P| P[1] == _aDados[_nCpo,2] })) = 0
				AADD( _aPercLeiteMadro , { _aDados[_nCpo,2] , 0 , 0 , 0 } )
				_nPos:=LEN(_aPercLeiteMadro)
			ENDIF
			IF _nPos <> 0

				cProd:=_aDados[_nCpo,5]
				nQtde:=VAL(_aDados[_nCpo,06])
				SB1->(DBSEEK(xFilial()+LEFT(cProd,11)))
				IF SB1->B1_I_TIPLT = "M"
					_aPercLeiteMadro[_nPos,2]+=nQtde
				ELSEIF SB1->B1_I_TIPLT = "I"
					_aPercLeiteMadro[_nPos,3]+=nQtde
				ENDIF

			ENDIF

			//ENDIF

		NEXT
		_aListaPerc:={}
		_cPict:=PesqPict("SZW","ZW_I_LMAGR")
		_cPictQ:=PesqPict("SZW","ZW_QTDVEN")
		FOR _nCpo := 1 TO LEN(_aPercLeiteMadro)
			IF _aPercLeiteMadro[_nCpo,2] <> 0
				_aPercLeiteMadro[_nCpo,4]:=((_aPercLeiteMadro[_nCpo,2] / (_aPercLeiteMadro[_nCpo,2]+_aPercLeiteMadro[_nCpo,3]))*100)
				AADD( _aListaPerc , { "A"                                        ,_aPercLeiteMadro[_nCpo,1] , TRANSFORM(_aPercLeiteMadro[_nCpo,2],_cPictQ), TRANSFORM(_aPercLeiteMadro[_nCpo,3],_cPictQ) , TRANSFORM(_aPercLeiteMadro[_nCpo,4],_cPict) } )
			ELSE
				AADD( _aListaPerc , { IF(_aPercLeiteMadro[_nCpo,3] <> 0,"B","C") ,_aPercLeiteMadro[_nCpo,1] , TRANSFORM(_aPercLeiteMadro[_nCpo,2],_cPictQ), TRANSFORM(_aPercLeiteMadro[_nCpo,3],_cPictQ) , TRANSFORM(_aPercLeiteMadro[_nCpo,4],_cPict) } )
			ENDIF
		NEXT
		aSort(_aListaPerc,,,{ |x,y| x[1]+x[2] < y[1]+y[2]})

		//Monta _aCab
		_aCab:={}
		_aSize:={}
		aadd(_aCab,"")//01
		aadd(_aSize,05)
		AAdd(_aCab,"Pedido Broker")//02
		aadd(_aSize,40)
		AAdd(_aCab,"CNPJ")//03
		aadd(_aSize,170)
		AAdd(_aCab,"CLIENTE")//04
		aadd(_aSize,35)
		AAdd(_aCab,"CODIGO [ ARMAZEM ][ DESCRICAO DO PRODUTO ]")//05
		aadd(_aSize,200)
		AAdd(_aCab,"QTD UNI")//06
		aadd(_aSize,40)
		AAdd(_aCab,"QTD DA CAIXA")//07
		aadd(_aSize,45)
		AAdd(_aCab,"VALORT DO ITEM")//08
		aadd(_aSize,50)
		AAdd(_aCab,"FORMA PG")//09
		aadd(_aSize,100)
		AAdd(_aCab,"VL_UNI")//10
		aadd(_aSize,50)
		AAdd(_aCab,"QTD CX")//11
		aadd(_aSize,40)
		AAdd(_aCab,"VL UNI SEM IMPOSTO")//12
		aadd(_aSize,50)
		AAdd(_aCab,"COD REPRESENTANTE")//13
		aadd(_aSize,150)
		AAdd(_aCab,"COD TABELA")//14
		aadd(_aSize,45)
		AAdd(_aCab,"FILIAL")//15
		aadd(_aSize,20)

		AAdd(_aCab,"PEDIDOC CLIENTE")//16
		aadd(_aSize,20)
		AAdd(_aCab,"OBS PARA NFE")//17
		aadd(_aSize,150)

		AAdd(_aCab,"TIPO DE ENTREGA")//18
		aadd(_aSize,20)
		AAdd(_aCab,"DT ENTREGA ")//19
		aadd(_aSize,20)


		AAdd(_aCab,"Resultado")//19
		aadd(_aSize,500)

		_cTitAux:="Dados do Arquivo "+_cArq
		_cMsgTop:="Importação, Registros Lidos: "+ALLTRIM(TRANSFORM(_nConta,"@E 999,999,999"))+", Com Erros: "+ALLTRIM(TRANSFORM(_nErro,"@E 999,999,999"))
		DO WHILE .T.

			aSort( _aDados ,,, {|X, Y| X[2] < Y[2] } )

			nPosResu:=LEN(_aDados[1])//Posiçao dos Resultado"
			_aButtons:={}
			AADD(_aButtons,{"BUDGET",{|| AVISO("RESULTADO",oLbxAux:aArray[oLbxAux:nAt][nPosResu],{"Fechar"},3)  },"", "Visualizar Resultado" })
			IF LEN(_aPercLeiteMadro) > 0
				AADD( _aButtons , { "" , {|| AOM112Magro(_aListaPerc) } , "" , "Visualisar % Leite Magro"  } )
			ENDIF

			//     ITListBox(_cTitAux, _aHeader , _aCols    , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _aButtons )
			lOK:=U_ITLISTBOX(_cTitAux, _aCab    , _aDados   , .T.      , 4      ,_cMsgTop  ,          , _aSize  ,         ,     ,        , _aButtons)

			IF lOK .AND. U_ITMSG("Confirma importação dos registros válidos",'Atenção!',,3,2,3,,"CONFIRMA","Voltar")

				AOMS112M(oProc)//GRAVA OS DADOS DO CSV
				EXIT
			ELSEIF !lOK .AND. U_ITMSG("Confirma SAIR ?",'Atenção!',"Todos os registros de válidações serão perdidos",3,2,3,,"CONFIRMA","Voltar")
				EXIT
			ENDIF

		ENDDO
	ELSE
		U_ITMSG("Nenhum registro válido",'Atenção!',"Dados do Arquivo "+_cArq,1)
	Endif

	IF lHtml
		FERASE(_cArq)
	ENDIF

RETURN .T.

/*
===============================================================================================================================
Programa----------: AOMS112M
Autor-------------: Alex Wallauer
Data da Criacao---: 06/01/2020
===============================================================================================================================
Descrição---------: Processamento de Importação de DADOS DO Sistema Blokers/Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function AOMS112M(oProc)
	LOCAL _nCpo
	LOCAL _nCont     := 0
	LOCAL _cTot      := ALLTRIM(STR(LEN(_aDados)))
	Local _cLocal    := ""
	Local _cMesoReg  := ""
	Local _cMicroReg := ""
	Local _cCodMunic := ""
	Local _cEstado   := ""
	Local _lBusca_2  := .F.
	Local _lAchou    := .F.

	_nTam:=LEN(_cTot)

	_aDados2:={}
	
	nPosResu:=LEN(_aDados[1])//Posiçao do Resultado

	SB1->(DBSETORDER(1))
	DA1->(DBSETORDER(1))
	SA1->(DBSETORDER(1))
	SZW->(DBSETORDER(1))
	SA3->(DBSETORDER(1))

	_nCpo:=1
	DO WHILE _nCpo <= LEN(_aDados)

		_cSalvaPed:=_aDados[_nCpo,2]//PEDIDO

		IF !SA3->(DBSEEK(xFilial("SA3") + LEFT(_aDados[_nCpo,13],LEN(SA3->A3_COD))  ))
		   _nCpo++
		   LOOP
		ENDIF

		BEGIN TRANSACTION


		   cVend:=LEFT(_aDados[_nCpo,13],LEN(SA3->A3_COD))//"001583"
		   _cCodSZW:=GeraZWIDPED(cVend)

			_nItem:=0

			DO WHILE _nCpo <= LEN(_aDados) .AND. _cSalvaPed == _aDados[_nCpo,2]

				_nCont++
				oProc:cCaption := ("Processando Dados: "+ STRZERO(_nCont,_nTam) +" de "+ _cTot)
				ProcessMessages()

				IF _aDados[_nCpo,1] //.AND. !EMPTY(_cRet)
           				/*//quando der chave duplicada novamente no SZW ativar essa validação
					IF _nItem = 0 .AND. SZW->(DBSEEK(_aDados[_nCpo,15]+SUBSTR(_aDados[_nCpo,13],3,4)+"-"+_aDados[_nCpo,2]))
						DO WHILE _nCpo <= LEN(_aDados) .AND. _cSalvaPed == _aDados[_nCpo,2]
							_aDados[_nCpo,1]:=.F.
							_aDados[_nCpo,nPosResu]:="Codigo Pedido já usado em um Pedido do Portal: "+SUBSTR(_aDados[_nCpo,13],3,4)+"-"+_aDados[_nCpo,2]
							AADD(_aDados2,_aDados[_nCpo])
							_nCpo++
						ENDDO
						EXIT
					ENDIF*/
					//CAPA
					SZW->(Reclock("SZW",.T.))
					SZW->ZW_FILIAL := _aDados[_nCpo,15]
					SZW->ZW_CODEMP := "010"
					SZW->ZW_IDPED  := _cCodSZW//SUBSTR(_aDados[_nCpo,13],3,4)+"-"+_aDados[_nCpo,2]//_cRet//"1583-"
					SZW->ZW_EMISSAO:= DATE()
					SZW->ZW_TIMEEMI:= "0"
					SZW->ZW_IDUSER := cVend//LEFT(_aDados[_nCpo,13],LEN(SA3->A3_COD))//"001583"
					SZW->ZW_VEND1  := cVend//LEFT(_aDados[_nCpo,13],LEN(SA3->A3_COD))//"001583"
					SZW->ZW_STATUS := "A"
					SZW->ZW_NIVELWF := " "
					SZW->ZW_ENVWF   := " "
					SZW->ZW_IMPRIME := '1'

					SA1->(DBSEEK(xFilial()+LEFT(_aDados[_nCpo,3],LEN(SA1->A1_COD))+SUBSTR(_aDados[_nCpo,3],LEN(SA1->A1_COD)+2,LEN(SA1->A1_LOJA)) ))

					SZW->ZW_CLIENTE:= SA1->A1_COD
					SZW->ZW_LOJACLI:= SA1->A1_LOJA
					SZW->ZW_CLIENT := SZW->ZW_CLIENTE
					SZW->ZW_LOJAENT:= SZW->ZW_LOJACLI
					SZW->ZW_TABELA := _aDados[_nCpo,14]//SA1->A1_TABELA

					If Empty(ALLTRIM(_aDados[_nCpo,16]))
						SZW->ZW_PEDCLI := "NT"
					Else
						SZW->ZW_PEDCLI := _aDados[_nCpo,16]//Pedido do Cliente
					EndIf

					SZW->ZW_MENNOTA := _aDados[_nCpo,17]// Mensagem para Nfe

					SZW->ZW_CONDPAG:= LEFT(_aDados[_nCpo,09], LEN(SE4->E4_CODIGO) )//BuscaCond(_aDados[_nCpo,09])

					SZW->ZW_TPFRETE:= "C"
					SZW->ZW_TIPOCLI:= SA1->A1_TIPO//"R"
					SZW->ZW_TIPCAR := "2"//"1 - Paletizada" , "2 - Batida"

					SZW->ZW_PEDIMPO := _aDados[_nCpo,2]
					SZW->ZW_I_PEDDW := _aDados[_nCpo,2]

					IF (_nPos:=ASCAN(_aPercLeiteMadro, {|P| P[1] == _aDados[_nCpo,2] })) <> 0
						SZW->ZW_I_LMAGR:=_aPercLeiteMadro[_nPos,4]
					ENDIF
					//ITENS
					_nItem++
					SZW->ZW_ITEM   := ALLTRIM(STR( _nItem , LEN(SZW->ZW_ITEM) ))
					SZW->ZW_PRODUTO:=LEFT(_aDados[_nCpo,5],11)
					SB1->(DBSEEK(xFilial()+SZW->ZW_PRODUTO))
					SZW->ZW_UM     := SB1->B1_UM//"UN"

					DA1->(Dbseek(xFilial("DA1")+SZW->ZW_TABELA+SZW->ZW_PRODUTO))

					SZW->ZW_QTDVEN := VAL(_aDados[_nCpo,06])
					SZW->ZW_PRCVEN := Round(VAL(_aDados[_nCpo,12]),2)

					SZW->ZW_OBSCOM := "Pedido Importado TXT: "+_aDados[_nCpo,2]

					SZW->ZW_HORAINC:= TIME()
					SZW->ZW_2UM    := SB1->B1_SEGUM//"CX"
					SZW->ZW_I_PRMP := DA1->DA1_I_PMF3//DA1
					SZW->ZW_I_PRNET:= SZW->ZW_PRCVEN
					SZW->ZW_PRUNIT := DA1->DA1_I_PMF3//DA1

					SZW->ZW_TPVENDA:= 'V'
					cArm:= POSICIONE("SBZ",1,SZW->ZW_FILIAL+SZW->ZW_PRODUTO,"BZ_LOCPAD")

					//------------------------------------------------------
					// Operação e Local
					// Para Broker Operação 12 e Local 50/52
					// Para Direto Fabrica Operação 01 e Local 20/22
					//
					// Broker quando A3_I_VBROK = B
					//------------------------------------------------------

					IF SA3->A3_I_VBROK == 'B'

						SZW->ZW_TIPO   := "12" // SC5->C5_I_OPER

						IF cArm = "20"
							SZW->ZW_LOCAL  := "50"
						ELSE
							SZW->ZW_LOCAL  := "52"
						ENDIF

					ELSE

						SZW->ZW_TIPO   := "01" // SC5->C5_I_OPER
						SZW->ZW_LOCAL  := cArm

					ENDIF

					IF SB1->B1_CONV > 0
						IF SB1->B1_TIPCONV = 'D'
							SZW->ZW_SEGQTD:=(SZW->ZW_QTDVEN/SB1->B1_CONV)
						ELSE
							SZW->ZW_SEGQTD:=(SZW->ZW_QTDVEN*SB1->B1_CONV)
						ENDIF
					ELSE
						SZW->ZW_SEGQTD:=VAL(_aDados[_nCpo,11])
					ENDIF

					_cfilft    := SZW->ZW_FILIAL
					_cLocal    := cArm
					_cMesoReg  := Posicione("CC2",1,xFilial("CC2")+SA1->A1_EST+SA1->A1_COD_MUN,"CC2_I_MESO")
					_cMicroReg := Posicione("CC2",1,xFilial("CC2")+SA1->A1_EST+SA1->A1_COD_MUN,"CC2_I_MICR")
					_cCodMunic := SA1->A1_COD_MUN
					_cEstado   := SA1->A1_EST
					_lBusca_2  := .F.
					_lAchou    := .F.

					If Empty(ALLTRIM(_aDados[_nCpo,18]))
						SZW->ZW_I_AGEND := "I"
					Else
						If _aDados[_nCpo,18] == 'IMEDIATO'
							SZW->ZW_I_AGEND := "I"
						ElseIf _aDados[_nCpo,18] == 'AGENDADO'
							SZW->ZW_I_AGEND := "A"
						Else
							SZW->ZW_I_AGEND := "I"
						EndIf
						SZW->ZW_I_AGEND  := _aDados[_nCpo,18]//Tipo de Entrega
					EndIf

               If SZW->ZW_I_AGEND <> "A"
   					If !Empty(_cLocal)

   						ZG5->(DbSetOrder(3))
   						If ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cLocal+_cEstado+_cMesoReg+_cMicroReg+_cCodMunic))
   							_lAchou   := .T.
   							_lBusca_2 := .F.
   						ElseIf ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cLocal+_cEstado+_cMesoReg+_cMicroReg))
   							_lAchou   := .T.
   							_lBusca_2 := .F.
   						ElseIf ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cLocal+_cEstado+_cMesoReg))
   							_lAchou   := .T.
   							_lBusca_2 := .F.
   						ElseIf ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cLocal+_cEstado))
   							_lAchou   := .T.
   							_lBusca_2 := .F.
   						Else
   							_lBusca_2 := .T.
   						EndIf

   					Else

   						_lBusca_2 := .T.

   					EndIf

   					If _lBusca_2

   						ZG5->(DbSetOrder(2))
   						If ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cEstado+_cMesoReg+_cMicroReg+_cCodMunic))
   							_lAchou := .T.
   						ElseIf ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cEstado+_cMesoReg+_cMicroReg))
   							_lAchou := .T.
   						ElseIf ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cEstado+_cMesoReg))
   							_lAchou := .T.
   						ElseIf ZG5->(Dbseek(xFilial("ZG5")+_cfilft+_cEstado))
   							_lAchou := .T.
   						Else
   							_lAchou := .F.
   						EndIf

   					EndIf

   					If _lAchou
   						SZW->ZW_FECENT := DATE() + Iif(ZG5->ZG5_FRDIAS >0,ZG5->ZG5_FRDIAS,ZG5->ZG5_DIAS) + 1
   					Else
   						SZW->ZW_FECENT := (DATE() + 1)
   					EndIf
               Else
                  SZW->ZW_FECENT := CTOD(Alltrim(_aDados[_nCpo,19]))
               EndIf
					
               SZW->(Msunlock())

					_aDados[_nCpo,5]:=ALLTRIM(SZW->ZW_PRODUTO)+" [ "+SZW->ZW_LOCAL+" ] [ "+ALLTRIM(SB1->B1_DESC)+" ]"
					_aDados[_nCpo,nPosResu]:="Codigo Pedido Gerado: "+SZW->ZW_IDPED

					AADD(_aDados2,_aDados[_nCpo])


				ENDIF

				_nCpo++

			ENDDO

		END TRANSACTION

	ENDDO

	IF LEN(_aDados2) = 0

		U_ITMSG("NÃO TEM registros para processar. Verifique os erros ocorridos na coluna Resultado",;
			"TODOS AS LINHAS ESTÃO VERMELHAS",;
			"Clique no CANCELAR OU ESC para sair da tela, quando todos as linhas estiverem VERMELHA",1)

		RETURN .F.
    ELSE 

	ENDIF
	_cMsgTop:="Importação, Registros Importados: "+ALLTRIM(TRANSFORM(LEN(_aDados2),"@E 999,999,999"))

	U_ITLISTBOX(_cTitAux, _aCab    , _aDados2   , .T.      , 4      ,_cMsgTop  ,          , _aSize)

	IF TYPE("aarr") = "A"
		AOMS112C(1)
	ENDIF

RETURN .T.

/*
===============================================================================================================================
Programa----------: GeraZWIDPED()
Autor-------------: Alex Wallauer
Data da Criacao---: 06/01/2020
===============================================================================================================================
Descrição---------: Gera oproximo ZW_IDPED
===============================================================================================================================
Parametros--------: _cCodVen: Codigo com somente numeros
===============================================================================================================================
Retorno-----------: _cRet: proximo codigo
===============================================================================================================================
*/
STATIC Function GeraZWIDPED(_cCodVen)
	Local _cAlias:= GetNextAlias()
	LOCAL _cQuery:= "SELECT  NVL(MAX(LPAD(TRIM(SUBSTR(ZW_IDPED,6,10)),10,'0')),'0') AS CODIGO FROM "+ RetSqlName('SZW') +" SZW WHERE ZW_VEND1 = '"+_cCodVen+"' "

	DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T., .F. )

	(_cAlias)->( DBGoTop() )
	If (_cAlias)->(!Eof()) .AND. Val((_cAlias)->CODIGO) > 0
	   //nAt:=AT("-",(_cAlias)->CODIGO)
	   //_cRet := LEFT( (_cAlias)->CODIGO,nAt )
	   _cRet := ALLTRIM(STR(VAL((_cAlias)->CODIGO )+1 ) )
	   _cRet := ALLTRIM(STR(VAL(_cCodVen)))+"-"+_cRet
	Else
	   _cRet := ALLTRIM(STR(VAL(_cCodVen)))+"-000001"
	EndIf

	IF EMPTY(_cRet)//Para garantir não devolver branco
	   _cRet := ALLTRIM(STR(VAL(_cCodVen)))+"-000001"
	ENDIF

	DbSelectArea(_cAlias)
	DbCloseArea()
	DbSelectArea("SZW")

Return _cRet

/*
===============================================================================================================================
Programa----------: BuscaCond()
Autor-------------: Alex Wallauer
Data da Criacao---: 06/01/2020
===============================================================================================================================
Descrição---------: Gera oproximo ZW_IDPED
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function BuscaCond(_cDias)
	Local _cAlias:= GetNextAlias()

//_cTot:=ALLTRIM(STR(LEN(_aDados)))
//_nTam:=LEN(_cTot)

	_cQuery:=" SELECT E4_CODIGO AS CODIGO , E4_I_PRZMD FROM "+ RetSqlName('SE4') +" SE4 WHERE "+ RetSqlCond('SE4') +" AND  E4_I_PRZMD  = "+_cDias+"  AND E4_I_PARCS = 1 AND E4_MSBLQL <> '1' "
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T., .F. )
	(_cAlias)->( DBGoTop() )
	If (_cAlias)->(!Eof())
		_cRet := (_cAlias)->CODIGO
		_cE4_I_PRZMD:=(_cAlias)->E4_I_PRZMD
	Else
		_cRet := ""
	EndIf
	DBSelectArea(_cAlias)
	DBCLOSEAREA()
	DBSelectArea("SZW")

RETURN _cRet

/*
===============================================================================================================================
Programa----------: AOMS112PES
Autor-------------: Jerry
Data da Criacao---: 01/03/2020
===============================================================================================================================
Descrição---------: Funcao que calcula o Peso Bruto do Pedido para tratar se é Carga Fechada ou Fracionada
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112PES(_cFilAux,_cNumPed)
	Local _aArea := GetArea()
	Local _nPesoSZW := 0
	Local _nSomaPeso := 0

//=======================================================================================================================
//Calcula o Peso Bruto do Pedido
//=======================================================================================================================	
	DBSelectArea("SZW")
	SZW->( DBSetOrder(1) )

	If SZW->( DBSeek( _cFilAux + _cNumPed ) )

		While SZW->(!Eof()) .And. SZW->( ZW_FILIAL + ZW_IDPED ) == _cFilAux + _cNumPed

			//==================================================
			// Faz a somatória dos Pesos.
			//==================================================
			_nPesoSZW := Posicione("SB1",1,Xfilial("SB1")+SZW->ZW_PRODUTO,"B1_PESBRU")

			_nSomaPeso += (_nPesoSZW * SZW->ZW_QTDVEN)

			SZW->(Dbskip())
		EndDo

	Endif

	Restarea( _aArea)

Return _nSomaPeso


/*
===============================================================================================================================
Programa----------: REENVAPR
Autor-------------: Jonathan Torioni
Data da Criacao---: 14/05/2020
===============================================================================================================================
Descrição---------: Função de exibição do processo de aprovação de preço
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function REENVAPR()

	Local _nU		:= 0
	Local _cFilLoc	:= ""
	Local _cIdpedL	:= ""
	Local _cCoord	:= ""
	Local _cCoordWF := ""
	Local _nQtdEnv  := 0

    If len(aarr) = 0
       u_itmsg("Não há registros para reenviar.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
       Return .F.
    Endif

	SZW->(DbSelectArea("SZW"))
	SZW->(DbSetOrder(1))

	FOR _nU := 1 TO LEN(aArr)

		If ALLTRIM(aArr[_nU][1]) != "" .AND. ( ALLTRIM(aArr[_nU][29]) == "BR_AMARELO" .OR. ALLTRIM(aArr[_nU][29]) == "BR_VERDE_ESCURO" .OR. ALLTRIM(aArr[_nU][29]) == "BR_PRETO" )
			_cFilLoc := LEFT(aArr[_nU][A112MAP("Filial Faturamento")], 2) 	//filial
			_cIdpedL := aArr[_nU][A112MAP("Id Pedido")] 			//IDPED

			SZW->(Dbsetorder(1))
			If SZW->(DbSeek(_cFilLoc+_cIdpedL))

				_nQtdEnv++

				_cCoord     := POSICIONE("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_SUPER")
				_cCoordWF   := POSICIONE("SA3",1,xFilial("SA3")+_cCoord,"A3_I_WF")

				If !(SZW->ZW_BLOPRC $ 'L/R' )

					Do while SZW->ZW_FILIAL == _cFilLoc .AND. ALLTRIM(SZW->ZW_IDPED) == _cIdpedL

						Reclock("SZW",.F.)

						SZW->ZW_I_HTML  := ' '
						SZW->ZW_MOTLP   := ' '
						SZW->ZW_HLIBP   := ' '
						SZW->ZW_DLIBP   := STOD("")
						SZW->ZW_ULIBP   := ' '
						SZW->ZW_MOTLP   := ' '
						SZW->ZW_BLOPRC  := ' '
						SZW->ZW_DATAAPR := STOD("")
						SZW->ZW_HORAAPR := ' '
						SZW->ZW_MLIBPRC := ' '
						SZW->ZW_OBSAVAC := 'REENVIADO WF POR ' + UsrFullName(__cUserID)
						SZW->ZW_MLIBPRC := ' '
						SZW->ZW_I_DLIBG  := STOD("")
						SZW->ZW_I_HLIBG := ' '
						SZW->ZW_BLOPRC	:= ' '
						IF ALLTRIM(SZW->ZW_I_OBS) = 'APROVADO'
							SZW->ZW_I_OBS := ' '
						ENDIF
						SZW->ZW_NIVELWF := " "
						SZW->ZW_ENVWF   := " "
						SZW->ZW_IMPRIME := '1'

						If _cCoordWF == "1"  //nao necessita de aprovação via portal
							SZW->ZW_STATUS  := "A"
						Else  // _cCoordWF == "2" -- necessita de aprovação via portal
							SZW->ZW_STATUS      := 'L'
						EndIF

						SZW->(Msunlock())

						SZW->(Dbskip())

					Enddo
				Endif
			Endif
		EndIF
	Next


	U_ITMSG(" Total de " + ALLTRIM(Str(_nQtdEnv))    +  " Pedidos Enviados ","Operação Concluída!")

RETURN .T.


/*
===============================================================================================================================
Programa----------: AOMS112WF
Autor-------------: Jerry
Data da Criacao---: 25/06/2020
===============================================================================================================================
Descrição---------: Funcao que verifica se o Pedido já passou por todas Alçada de aprovação do WF
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112WF(_cFilAux,_cNumPed)
	Local _aArea    := GetArea()
	Local _lWFOk    := .T.
	Local _cCoord   := ""
	Local _cCoordWF	:= ""

	_cCoord     := POSICIONE("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_SUPER")
	_cCoordWF   := POSICIONE("SA3",1,xFilial("SA3")+_cCoord,"A3_I_WF")

	DBSelectArea("SZW")
	SZW->( DBSetOrder(1) )

	If SZW->( DBSeek( _cFilAux + _cNumPed ) )
	   SA1->(Dbsetorder(1))
	  
	   DO WHILE SZW->(!Eof()) .And. SZW->( ZW_FILIAL + ZW_IDPED ) == _cFilAux + _cNumPed
          //===========================================================
          // Validação Padrão do Portal
		  //===========================================================
	      SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

			If SZW->ZW_BLOPRC == "B"
				_lWFOk := .F.
				aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),_cFilAux,ALLTRIM(_cNumPed),SA1->A1_COD + "/"+SA1->A1_LOJA + " - "+ALLTRIM(SA1->A1_NOME),"Existe(m) item(ns) cujo(s) preço(s) informado(s) está(ão) fora da tabela de preços (ZW_BLOPRC = B'), estão aguardando WF de aprovação"})
				EXIT
			Else
				_cCoord     := POSICIONE("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_SUPER")
				_cCoordWF   := POSICIONE("SA3",1,xFilial("SA3")+_cCoord,"A3_I_WF")
				If _cCoordWF == "2"
					IF Empty(SZW->ZW_BLOPRC) .And. SZW->ZW_STATUS == "L" .And. SZW->ZW_ENVWF == "C" .And. SZW->ZW_NIVELWF == "P"
						_lWFOk := .F.
						aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),_cFilAux,ALLTRIM(_cNumPed),SA1->A1_COD + "/"+SA1->A1_LOJA + " - "+ALLTRIM(SA1->A1_NOME),"Existe(m) item(ns) cujo(s) preço(s) informado(s) está(ão) fora da tabela de preços (Empty(SZW->ZW_BLOPRC)/SZW->ZW_STATUS='L'/SZW->ZW_ENVWF='C'/SZW->ZW_NIVELWF='P), estão aguardando WF de aprovação"})
						EXIT
					EndIf
				EndIF
			EndIf
			SZW->(Dbskip())
		EndDo
	Endif

	Restarea( _aArea)

Return _lWFOk


/*
===============================================================================================================================
Programa----------: AMS112PE
Autor-------------: Jonathan Torioni
Data da Criacao---:  03/04/2020
===============================================================================================================================
Descrição---------: Realiza a montagem do grid com os pedidos pendentes por gerentes
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
STATIC FUNCTION AMS112PE()
	Local _aCols 	:= {}
	Local _aPeds	:= {}
	Local _aGeren 	:= {}
	Local _aHead	:= {}
	Local _aSize	:= {}
	Local _aTot		:= {}
	Local _nX  		:= 0
	Local _nZ		:= 0

    If len(aarr) = 0
       u_itmsg("Não há registros para listagem.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
       Return .F.
    Endif
	
	DbSelectArea("SA3")
	SA3->(DbSetOrder(1))
	FOR _nX := 1 TO Len(aArr)

		SA3->(DbSeek(xFilial("SA3")+SubStr(aArr[_nX][A112MAP("Vendedor")],1,6)))

		Aadd(_aPeds, {	aArr[_nX][A112MAP("Id Pedido")],;					// 1 - ZW_NUMPED
		aArr[_nX][30],;					// 2 - STATUS2
		ALLTRIM(aArr[_nX][29]),;		// 3 - STATUS3
		SA3->A3_GEREN})					// 4 - GERENTE

		IF AScan(_aGeren, {|x| x == SA3->A3_GEREN}) == 0
			Aadd(_aGeren, SA3->A3_GEREN)
		ENDIF

	NEXT _nX


	FOR _nX := 1 TO Len(_aGeren)

		Aadd(_aCols, {_aGeren[_nX],; 											//1 - COD GERENTE
		LoadBitmap( GetResources() , "BR_VERMELHO" ),; 	// 2
		0,;	 											//3 - QTDE LEGENDA VERMELHA
		LoadBitmap( GetResources() , "BR_PRETO" ),; 	// 4
		0,;  											//5 - QTDE LEGENDA PRETO
		LoadBitmap( GetResources() , "BR_VERDE" ),; 	// 6
		0,;  											//7 - QTDE LEGENDA VERDE
		LoadBitmap( GetResources() , "BR_AZUL" ),; 		//8
		0,;  											//9 - QTDE LEGENDA AZUL
		LoadBitmap( GetResources() , "BR_AMARELO" ),; 	// 10
		0,;  											//11 - QTDE LEGENDA AMARELA
		LoadBitmap( GetResources() , "BR_VERDE_ESCURO" ),; // 12
		0,;												//13 - QTDE LEGENDA VERDE ESCURO
		LoadBitmap( GetResources() , "BR_CANCEL" ),;	//14 - BR_CANCEL
		0,;												//15
		0})												//16 - TOTALIZADOR HORIZONTAL


		FOR _nZ := 1 TO Len(_aPeds)

			DO CASE
			CASE _aPeds[_nZ][4] == _aGeren[_nX] .AND. _aPeds[_nZ][3] == "BR_VERMELHO"
				_aCols[_nX][3] ++
				_aCols[_nX][16] ++
			CASE _aPeds[_nZ][4] == _aGeren[_nX] .AND. _aPeds[_nZ][3] == "BR_PRETO"
				_aCols[_nX][5] ++
				_aCols[_nX][16] ++
			CASE _aPeds[_nZ][4] == _aGeren[_nX] .AND. _aPeds[_nZ][3] == "BR_VERDE"
				_aCols[_nX][7] ++
				_aCols[_nX][16] ++
			CASE _aPeds[_nZ][4] == _aGeren[_nX] .AND. _aPeds[_nZ][3] == "BR_AZUL"
				_aCols[_nX][9] ++
				_aCols[_nX][16] ++
			CASE _aPeds[_nZ][4] == _aGeren[_nX] .AND. _aPeds[_nZ][3] == "BR_AMARELO"
				_aCols[_nX][11] ++
				_aCols[_nX][16] ++
			CASE _aPeds[_nZ][4] == _aGeren[_nX] .AND. _aPeds[_nZ][3] == "BR_VERDE_ESCURO"
				_aCols[_nX][13] ++
				_aCols[_nX][16] ++
			CASE _aPeds[_nZ][4] == _aGeren[_nX] .AND. _aPeds[_nZ][3] == "BR_CANCEL"
				_aCols[_nX][15] ++
				_aCols[_nX][16] ++
			ENDCASE

		NEXT _nZ

	NEXT _nX

	//Monta o totalizador vertical
	Aadd(_aTot, {"Total Geral",; 								//1 - COD GERENTE
	LoadBitmap( GetResources() , "BR_VERMELHO" ),; 	// 2
	0,;	 											//3 - QTDE LEGENDA VERMELHA
	LoadBitmap( GetResources() , "BR_PRETO" ),; 	// 4
	0,;  											//5 - QTDE LEGENDA PRETO
	LoadBitmap( GetResources() , "ENABLE" ),; 		// 6
	0,;  											//7 - QTDE LEGENDA VERDE
	LoadBitmap( GetResources() , "BR_AZUL" ),; 		//8
	0,;  											//9 - QTDE LEGENDA AZUL
	LoadBitmap( GetResources() , "BR_AMARELO" ),; 	// 10
	0,;  											//11 - QTDE LEGENDA AMARELA
	LoadBitmap( GetResources() , "BR_VERDE_ESCURO" ),; // 12
	0,;												//13 - QTDE LEGENDA VERDE ESCURO
	LoadBitmap( GetResources() , "BR_CANCEL" ),;	//14 - BR_CANCEL
	0,;												//15
	0})	//16 - TOTALIZADOR HORIZONTAL

	//Soma do totalizador vertical
	FOR _nX := 1 TO Len(_aCols)
		_aTot[1][3] += _aCols[_nX][3]
		_aTot[1][5] += _aCols[_nX][5]
		_aTot[1][7] += _aCols[_nX][7]
		_aTot[1][9] += _aCols[_nX][9]
		_aTot[1][11] += _aCols[_nX][11]
		_aTot[1][13] += _aCols[_nX][13]
		_aTot[1][15] += _aCols[_nX][15]
		_aTot[1][16] += _aCols[_nX][16]
	NEXT _nX

	_aTot[1][3] := AllToChar(_aTot[1][3])
	_aTot[1][5] := AllToChar(_aTot[1][5])
	_aTot[1][7] := AllToChar(_aTot[1][7])
	_aTot[1][9] := AllToChar(_aTot[1][9])
	_aTot[1][11]:= AllToChar(_aTot[1][11])
	_aTot[1][13]:= AllToChar(_aTot[1][13])
	_aTot[1][15]:= AllToChar(_aTot[1][15])
	_aTot[1][16]:= AllToChar(_aTot[1][16])

	FOR _nX := 1 TO Len(_aCols)
		_aCols[_nX][1] := PADR(POSICIONE("SA3",1,xFilial("SA3")+_aCols[_nX][1], "A3_NOME"),40)
		_aCols[_nX][3] := AllToChar(_aCols[_nX][3])
		_aCols[_nX][5] := AllToChar(_aCols[_nX][5])
		_aCols[_nX][7] := AllToChar(_aCols[_nX][7])
		_aCols[_nX][9] := AllToChar(_aCols[_nX][9])
		_aCols[_nX][11] := AllToChar(_aCols[_nX][11])
		_aCols[_nX][13] := AllToChar(_aCols[_nX][13])
		_aCols[_nX][15] := AllToChar(_aCols[_nX][15])
		_aCols[_nX][16] := AllToChar(_aCols[_nX][16])
	NEXT _nX

	Aadd(_aCols, _aTot[1])

	Aadd(_aHead , "Gerente")
	Aadd(_aSize, 40)

	Aadd(_aHead , " ")
	Aadd(_aSize, 5)
	Aadd(_aHead , "Ag. Efetivação")
	Aadd(_aSize, 30)

	Aadd(_aHead , " ")
	Aadd(_aSize, 5)
	Aadd(_aHead , "Preço Bloq.")
	Aadd(_aSize, 30)

	Aadd(_aHead , " ")
	Aadd(_aSize, 5)
	Aadd(_aHead , "Preço Lib.")
	Aadd(_aSize, 30)

	Aadd(_aHead , " ")
	Aadd(_aSize, 5)
	Aadd(_aHead , "Crédito Bloq.")
	Aadd(_aSize, 30)

	Aadd(_aHead , " ")
	Aadd(_aSize, 5)
	Aadd(_aHead , "Pend. Coord.")
	Aadd(_aSize, 40)

	Aadd(_aHead , " ")
	Aadd(_aSize, 5)
	Aadd(_aHead , "Pend. Gerente")
	Aadd(_aSize, 40)

	Aadd(_aHead , " ")
	Aadd(_aSize, 5)
	Aadd(_aHead , "Cliente/Remessa Bloq.")
	Aadd(_aSize, 40)

	Aadd(_aHead , "Total")
	Aadd(_aSize, 5)


	U_ITListBox( "Listagem de pedidos por gerente" , _aHead , _aCols , .T. , 1 ,"Listagem de pedidos por gerente",_aSize)

RETURN


/*
===============================================================================================================================
Programa----------: A112MAP
Autor-------------: Jonathan Torioni
Data da Criacao---:  05/08/2020
===============================================================================================================================
Descrição---------: Realiza o mapeamento das colunas do oMark
===============================================================================================================================
Parametros--------: _cCampo - Recebe o nome da coluna
					_lPesc	- Indica se realiza o mapeamento das colunas
===============================================================================================================================
Retorno-----------: _nPos posição da coluna do browser
===============================================================================================================================
*/
STATIC FUNCTION A112MAP(_cCampo, _lPesc)
	Local lHtml     := (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml
	Local _nX		:=	0
	Local _nPos		:= 0

	DEFAULT _cCampo := ""
	DEFAULT _lPesc := .T.

	IF _lPesc
		_nPos := aScan(_aArmap, {|x| x[1] == _cCampo})
	ELSE
		IF !lHtml
			FOR _nX := 1 TO Len(oMark:aColumns)
				Aadd(_aArmap, {oMark:aColumns[_nX]:cHeading, _nX})
			NEXT _nX
		ELSE
			FOR _nX := 1 TO Len(oMark:aHeaders)
				Aadd(_aArmap, {oMark:aHeaders[_nX], _nX})
			NEXT _nX
		ENDIF
	ENDIF

RETURN _nPos


/*
===============================================================================================================================
Programa----------: A112OMK
Autor-------------: Jonathan Torioni
Data da Criacao---:  04/08/2020
===============================================================================================================================
Descrição---------: Monta oMark
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
STATIC FUNCTION A112OMK()
	Local lHtml     := (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml
	Local _nX  		:= 0
	Local _bLine	:= Nil
	Local _cMacro	:= ""

	_aColuns := {}
	// AO TROCAR AS ORDENS DOS CAMPOS NA TELA TROQUE A ORDEM TB NA TABELA aArr NA GRAVACAO QUANDO VIA HTML NA FUNCAO AOMS112arq() Procure por "ACERTO MANUAL", e TESTE VIA HTML
	//QUANDO FOR HTML O AARR DEVE SER ORDENADO MANUALMENTE, QUANDO NÃO É ELA É REORDENADA AUTOMATICAMENTE NA A112RA()
	AADD(_aColuns,{SPACE(1), 				"If(aArr[oMark:nAt,01]==cmarca,oOK,oNO)",,,,,,													  01})//01
	AADD(_aColuns,{SPACE(2), 				"LoadBitmap(GetResources(),U_AOMS1129())",,,,,,													  02})//02
	AADD(_aColuns,{SPACE(3), 				"LoadBitmap(GetResources(),U_AOMS1128())",,,,,,													  03})//03
	AADD(_aColuns,{"Impresso",				"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","RIGHT",020,.F.,.F.,					  04})//04
	AADD(_aColuns,{"Dt Emissão",			"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","RIGHT",035,.F.,.F.,					  11})//05
	AADD(_aColuns,{"Dias/Horas Pendentes",	"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,100,.F.,.F.,					  28})//06
	AADD(_aColuns,{"Tipo Entrega",			"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,050,.F.,.F.,					  10})//07
	AADD(_aColuns,{"Dt Entrega",			"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","RIGHT",035,.F.,.F.,					  14})//08
	AADD(_aColuns,{"Filial Faturamento",	"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,050,.F.,.F.,					  06})//09
	AADD(_aColuns,{"Filial Carregamento",	"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,050,.F.,.F.,					  07})//10
	AADD(_aColuns,{"Cond Pgto",				"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,050,.F.,.F.,					  17})//11
	AADD(_aColuns,{"Id Pedido",				"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,040,.F.,.F.,					  08})//12
	AADD(_aColuns,{"Tipo",					"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,050,.F.,.F.,					  05})//13
	AADD(_aColuns,{"Cliente/Venda",			"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,100,.F.,.F.,					  27})//14
	AADD(_aColuns,{"Cliente/Remessa",		"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,050,.F.,.F.,					  09})//15
	AADD(_aColuns,{"Valor Pedido",			"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@E 999,999,999.99","LEFT" ,050,.F.,.F.,		  25})//16
	AADD(_aColuns,{"Tp Frete",				"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","RIGHT",020,.F.,.F.,					  15})//17
	AADD(_aColuns,{"Peso Bruto",			"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@E 999,999.9999","LEFT" ,020,.F.,.F.,		  29})//18
	AADD(_aColuns,{"Desconto",				"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@E 999,999,999.99","LEFT" ,050,.F.,.F.,	  30})//19
	AADD(_aColuns,{"Obs",					"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,Len(SZW->ZW_OBSCOM)+300,.F.,.F., 20})//20
	AADD(_aColuns,{"Mens NF",				"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,Len(SZW->ZW_MENNOTA)+300,.F.,.F.,19})//21
	AADD(_aColuns,{"Trans Time",			"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","RIGHT",025,.F.,.F.,					  13})//22
	AADD(_aColuns,{"Dt Carga",				"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","RIGHT",035,.F.,.F.,					  12})//23
	AADD(_aColuns,{"Tab Preço",				"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,050,.F.,.F.,					  16})//24
	AADD(_aColuns,{"Vendedor",				"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,050,.F.,.F.,					  18})//25
	AADD(_aColuns,{"Coordenador",			"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,060,.F.,.F.,					  31})//26
	AADD(_aColuns,{"Gerente",				"aArr[oMark:nAt,"+ALLTRIM(STR(len(_aColuns)+1))+"]","@!","LEFT" ,060,.F.,.F.,					  32})//27

	IF lHtml
		aHeaders:={}
		FOR _nX := 1 TO Len(_aColuns)
			AADD(aHeaders,_aColuns[_nX][1])
		NEXT _nX
	Else
		aHeaders:=NIL
	Endif

	//TCBrowse():New(          [ nRow ], [ nCol ], [ nWidth ], [ nHeight ]  , [ bLine ]   , [ aHeaders ], [ aColSizes ], [ oWnd ], [ cField ], [ uValue1 ], [ uValue2 ], [ bChange ], [ bLDblClick ]              , [ bRClick ], [ oFont ], [ oCursor ], [ nClrFore ], [ nClrBack ], [ cMsg ], [ uParam20 ], [ cAlias ], [ lPixel ], [ bWhen ], [ uParam24 ], [ bValid ], [ lHScroll ], [ lVScroll ] )
	oMark:=TCBrowse():New(   35    ,    01   , 35+nHeight, 01+nwidth    ,             ,    aHeaders ,              , odlg1    ,           ,            ,            ,            , {|| AOMS112N( cmarca  )} ,            ,          ,            ,             ,             ,         ,             ,    "ARRAY",   .T.     ,          ,             ,           ,             ,              )
	oMark:SetArray(aarr)
    oMark:bHeaderClick := {|| AOMS112ALL( cmarca  ) }

	IF lHtml
		IF LEN(aarr) > 0

			FOR _nX := 1 TO Len(_aColuns)
				_cMacro +=  IIF(_nX == 1 , "{|| { ", ",") + _aColuns[_nX][2] + IIF(_nX == Len(_aColuns), "} }", "")
			NEXT _nX

			_bLine := &(_cMacro)

			oMark:bLine:= _bLine
		ELSE//QUANDO NÃO TEM RESGISTROS
			FOR _nX := 1 TO Len(_aColuns)
				//_cMacro +=  IIF(_nX == 1 , "{|| { ", ",") + " " + IIF(_nX == ATail(_aColuns), "} }", "")
				_cMacro +=  IIF(_nX == 1 , "{|| { ", ",") + " " + IIF(_nX == Len(_aColuns), "} }", "")
			NEXT _nX

			_bLine := &(_cMacro)

			oMark:bLine:= _bLine
		ENDIF

	ELSE

		FOR _nX := 1 TO Len(_aColuns)
			_cCol := "{ || iif(len(aarr)>0,"+_aColuns[_nX][2]+", ' ') }"
			bCol := &(_cCol)

			IF EMPTY(_aColuns[_nX][1])
				oMark:AddColumn(TCColumn():New(_aColuns[_nX][1], bCol,,,,,,.T.,.F.,,,,.F. ) )
			ELSE
				oMark:AddColumn(TCColumn():New(_aColuns[_nX][1], bCol ,_aColuns[_nX][3],,,_aColuns[_nX][4],_aColuns[_nX][5],_aColuns[_nX][6],_aColuns[_nX][7],,,,,))
			ENDIF
		NEXT _nX
	ENDIF



RETURN


/*
===============================================================================================================================
Programa----------: A112RA
Autor-------------: Jonathan Torioni
Data da Criacao---:  04/08/2020
===============================================================================================================================
Descrição---------: Reordena o conteúdo do aArr para um novo array para a ordem do A112MAP()
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC FUNCTION A112RA()

	Local _aTemp := aClone(aArr)
	Local _nX  		:= 0
	Local _nY		:= 0
	Local _nPos		:= 0

	FOR _nX := 1 TO Len(_aTemp)
		FOR _nY := 1 to Len(_aColuns)
			_nPos := A112MAP(_aColuns[_nY][1])
			AFill(aArr[_nX], _aTemp[_nX][_aColuns[_nY][8]], _nPos, 1)
		NEXT _nY
		AFill(aArr[_nX], _aTemp[_nX][21], 32,1) //<- RECNO -> Garantir que o RECNO fique sempre na ultima posição do aArr
		AFill(aArr[_nX], _aTemp[_nX][22], 31,1)
		AFill(aArr[_nX], _aTemp[_nX][23], 30,1)
		AFill(aArr[_nX], _aTemp[_nX][24], 29,1)
		AFill(aArr[_nX], _aTemp[_nX][26], 28,1)
	NEXT _nX

RETURN

/*
===============================================================================================================================
Programa--------: AOMS1123C
Autor-----------: Jerry
Data da Criacao-: 06/05/2021
===============================================================================================================================
Descrição-------: Valida Produto para operação 08 para Filial Três Corações
===============================================================================================================================
Parametros------: cNumPed   := Código do Pedido
----------------: cFilAux   := Filial do Pedido
				  _lAutoref := Execução de pedidos múltiplos
===============================================================================================================================
Retorno---------: lRet := Informa se validou
===============================================================================================================================
*/
Static Function AOMS1123C( cNumPed , cFilAux, _lAutoref )
	Local aAreaAux	:= GetArea()
	Local lOk		:= .T.
	Local lbq       := .F.
	Local _nQtd3c   := 0
	Local _nQtdItem := 0
	Local _cProd3c := ""

	_cFilSalva  := cFilAnt
	cFilAnt     := SZW->ZW_FILIAL
	_cProd3c    := U_ITGETMV( "IT_ZW3C","00030010601;00030041401;00030041301;00030070601;00030080601;00050019101;00050010301;00050030301;00030050601;00030023401" )

	cFilAnt     := _cFilSalva

	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( cFilAux + cNumPed ) )
	Do While SZW->( !EOF() ) .AND. cFilAux + cNumPed == SZW->( ZW_FILIAL + ZW_IDPED )

		_nQtdItem++

		If (ALLTRIM(SZW->ZW_PRODUTO) $ _cProd3c)  //Produto Creme e Condensando
			_nQtd3c++
		Endif

		SZW->(DbSkip())

	EndDo

	If _nQtd3c > 0

		IF _nQtdItem = _nQtd3c
			DBSelectArea("SZW")
			SZW->( DBSetOrder(1) )

			If SZW->( DBSeek( cFilAux + cNumPed ) )

				While SZW->(!Eof()) .And. SZW->( ZW_FILIAL + ZW_IDPED ) == cFilAux + cNumPed

					Reclock("SZW",.F.)
					SZW->ZW_TIPO  := '08'
					SZW->(Msunlock())
					SZW->(Dbskip())
				EndDo
			EndIf
		Else
			If _lAutoref //Qdo marca vários

				SZW->( DbSetOrder(1) )
				SZW->( DbSeek( cFilAux + cNumPed ) )

				SA1->(Dbsetorder(1))
				SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

				aadd(_aResults, {LoadBitmap(GetResources(),"BR_VERMELHO"),cFilAux,ALLTRIM(cNumPed),SA1->A1_COD+"/"+SA1->A1_LOJA + " - "+ALLTRIM(SA1->A1_NOME),"Pedido Filial Três Corações, contendo Creme de Leite e Condensando e Outros, não podera ser efetivado com Operação 08"})
			Else
				u_itmsg("Pedido Filial Três Corações, contendo Creme de Leite e Condensando e Outros, não podera ser efetivado com Operação 08","Validação de Operação 08", 1	)
			Endif

			lok := .F.
			lBq := .T. //Seta .T. na variável de Controle de Bloqueio de Pedidos

		EndIF
		//Desfaz lock nos registros
		AOMS112UN(cFilAux,cNumPed)
	EndIf

	RestArea(aAreaAux)

Return( lOk )


/*
===============================================================================================================================
Programa--------: AOMS112PM
Autor-----------: Igor Melgaço
Data da Criacao-: 24/05/2021
===============================================================================================================================
Descrição-------: Valida Itens do pedido que a qtd não é multipla a Qt. Pallet do Produto
===============================================================================================================================
Parametros------: _cCodFil := Filial
----------------: _cNumPed := Numero do pedido
----------------: _cItens  := Itens do pedido que a qtd não é multipla a Qt. Pallet do Produto
----------------: _cDet    := Detalhes dos itens informando a qtd sugerida
===============================================================================================================================
Retorno---------: _lRet    := Validação do pedido
===============================================================================================================================
*/
Static Function AOMS112PM(_cCodFil,_cNumPed,_cItens,_cDet)
	Local _lRet     := .T.
	Local _nQtdMult := 0
	Local _nResto   := 0
	Local _nQtdPecas:= 0
	Local _cQueijo  := "N"
	Local _nQtdFator:= 1
	Local _cGrpBI   := ""

	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( _cCodFil + _cNumPed ) )
	Do While SZW->( !EOF() ) .AND. _cCodFil + _cNumPed == SZW->( ZW_FILIAL + ZW_IDPED )

		SB1->(DBSetOrder(1))
		If SB1->(DBSeek(xFilial("SB1")+SZW->ZW_PRODUTO))
			_nQtdMult := SB1->B1_I_PCCX
			_cQueijo  := SB1->B1_I_QQUEI
			_nQtdFator:= SB1->B1_I_FATCO
			_cGrpBI   := SB1->B1_I_BIGRP
		EndIf

		If _cQueijo = "S" .And. _nQtdMult > 0 .And. _cGrpBI = "43"

			_nQtdPecas := (SZW->ZW_QTDVEN / _nQtdFator)

			_nResto   := Mod(_nQtdPecas,_nQtdMult)

			If _nQtdMult > 0 .And. _nResto <> 0

				_nMin := Iif(_nQtdPecas < _nQtdMult, 0 ,_nQtdPecas - _nResto)
				_nMax := Iif(_nQtdPecas < _nQtdMult, _nQtdMult ,_nMin + _nQtdMult)

				_cSugest := Iif(_nQtdPecas < _nQtdMult,"  Qtd Sugerida " + ALLTRIM(transform(_nMax, _cPictQtv )),;
					"  Qtd Sugerida " + ALLTRIM(transform(_nMin, _cPictQtv )) + " Ou " + ALLTRIM(transform(_nMax, _cPictQtv )) )

				_cItens += Iif(Empty(ALLTRIM(_cItens)),"","; ") + SZW->ZW_ITEM

				_cDet += Iif(Empty(ALLTRIM(_cDet)),"",CRLF) + "Item " + SZW->ZW_ITEM + " Produto " + SZW->ZW_PRODUTO + ;
					" Qtd " + ALLTRIM(transform(_nQtdPecas, _cPictQtv)) + " Qt.Pc na Cx." + ALLTRIM(transform(_nQtdMult, _cPictQtv )) + _cSugest

				_lRet   := .F.

			EndIf
		Else
			_lRet   := .T.
		Endif

		SZW->(Dbskip())

	EndDo

Return _lRet


/*
===============================================================================================================================
Programa--------: AOMS112MA
Autor-----------: Igor Melgaço
Data da Criacao-: 24/05/2021
===============================================================================================================================
Descrição-------: Valida peso acima de 22.000 somente para Produto Matinais 
===============================================================================================================================
Parametros------: _cCodFil := Filial
----------------: _cNumPed := Numero do pedido
----------------: _cItens  := Itens do pedido 
----------------: _cDet    := Detalhes dos itens informando a qtd sugerida
===============================================================================================================================
Retorno---------: _lRet    := Validação do pedido
===============================================================================================================================
*/
Static Function AOMS112MA(_cCodFil,_cNumPed,_cItens,_cDet)
	Local _lRet      := .F.
	Local _lProdMat  := 0
	Local _nPeso     := 0

	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( _cCodFil + _cNumPed ) )
	Do While SZW->( !EOF() ) .AND. _cCodFil + _cNumPed == SZW->( ZW_FILIAL + ZW_IDPED )

		_lProdMat := ( POSICIONE("SB1",1,xFilial("SB1") + SZW->ZW_PRODUTO,"B1_I_BIFAM") $ _cProdMat )

		If _lProdMat .And. !(SZW->ZW_LOCAL $ _cArmazMat) .And. ( SZW->ZW_UM $ "KG;G " .OR. SZW->ZW_2UM $ "KG;G ")

			If SZW->ZW_UM $ "KG;G "
				_nPeso  += Iif(SZW->ZW_2UM = "G ",1000,1) * SZW->ZW_QTDVEN
			ElseIf SZW->ZW_2UM $ "KG;G "
				_nPeso  += Iif(SZW->ZW_2UM = "G ",1000,1) * ConvUM( SZW->ZW_PRODUTO,SZW->ZW_QTDVEN,0,POSICIONE("SB1",1,xFilial("SB1") + SZW->ZW_PRODUTO,"B1_CONV") )
			EndIf

			_cItens += Iif(Empty(ALLTRIM(_cItens)),"","; ") + SZW->ZW_ITEM

			_cDet += Iif(Empty(ALLTRIM(_cDet)),"",CRLF) + "Item " + SZW->ZW_ITEM + " Produto " + SZW->ZW_PRODUTO + ;
				" Qtd " + ALLTRIM(transform(SZW->ZW_QTDVEN, _cPictQtv)) + " Peso " + ALLTRIM(transform(_nPeso, _cPictQtv )) + " Kg"

		EndIf

		SZW->(Dbskip())

	EndDo

	If _nPeso > _nPesoMat
		_cDet += CRLF + " Peso Total: " + ALLTRIM(transform(_nPeso, _cPictQtv)) + " kg"
		_lRet := .T.
	EndIf

Return _lRet


/*
===============================================================================================================================
Programa--------: GeraPedPallet(_aPeds_Pallet,_lAutomatico)
Autor-----------: Igor Fricks
Data da Criacao-: 07/06/2021
===============================================================================================================================
Descrição-------: Gera Pedidos de Pallet
===============================================================================================================================
Parametros------: 
==============================================================================================================================
Retorno---------: Lógico (.T.) Se tudo OK (.F.) Se deu erro
===============================================================================================================================
*/
Static Function GeraPedPallet()
	LOCAL _cDesc  	:= "",_cPedPallet
	LOCAL _nPreco 	:= _nTotVlrPal:=_nPallet:=0
	LOCAL _cUM	  	:= "",_Ped
	Local _citls 	:= ALLTRIM( U_ITGETMV( 'IT_CHEPITLS' ) )
	Local _citln 	:= ALLTRIM( U_ITGETMV( 'IT_CHEPITLN' ) )
	Local _cclis 	:= ALLTRIM( U_ITGETMV( 'IT_CHEPCLIS' ) )
	Local _cclin 	:= ALLTRIM( U_ITGETMV( 'IT_CHEPCLIN' ) )
	Local _cchep 	:= GetMV( "IT_CCHEP" )
	Local _cpbr 	:= GetMV( "IT_PPBR" )
	Local _cPBRITLP := ALLTRIM( U_ITGETMV( 'IT_PBRITLP','51' ) )
	Local _cPBRCLIP := ALLTRIM( U_ITGETMV( 'IT_PBRCLIP','51' ) )
	Local _nRenoSC5 := SC5->(Recno())
	Local _lGerouOK := .T.
	Local _clichep := "N"

	Default oproc := nil

	_aCabPV		:= {}
	_aItemPV	:= {}

	Dbselectarea("SC6")
	Dbsetorder(1)
	Dbseek(SC5->C5_FILIAL + SC5->C5_NUM)
	Do While SC5->C5_FILIAL + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM .AND. SC6->(!EOF())
		_nPallet += SC6->C6_QTDVEN //TRBPED->PED_I_QTPA//Qtde do Pallet
		SC6->(Dbskip())
	EndDo

	FOR _Ped := 1 TO 1

		SA2->( DBSetOrder(1) )
		SBZ->( DBSetOrder(1) )
		SC5->( DBSetOrder(1) )

		lMsErroAuto	:= .F.
		nItem		:= 1
		_cDesc      := ""
		_nPreco     := 0
		_cUM	    := ""

		//====================================================================================================
		// Verifica se o Cliente esta com Pallet == Sim
		//====================================================================================================
		If .T.//Upper( _cUPalet ) $ '1,S' .And. M->C5_I_TIPCA <> "2" // Tipo de Carga (C5_TIPCA) => 1=Paletizada; 2=Batida

			//====================================================================================================
			// Verifica se o pedido atual já não está amarrado à um pedido de Pallet
			//====================================================================================================
			If .T.//Empty( SC5->C5_I_NPALE )


				//====================================================================================================
				// Verifica se houveram vendas com quantidade de Pallets
				//====================================================================================================
				If _nPallet > 0

					_cFilOrigem := SC5->C5_FILIAL
					_cPedOrigem := SC5->C5_NUM
					cTipoPV		:= SC5->C5_TIPO
					cCliente	:= SC5->C5_CLIENTE
					cLoja		:= SC5->C5_LOJACLI
					_dDtEnt		:= IF(SC5->C5_I_DTENT < DATE(),DATE(),SC5->C5_I_DTENT)//Para nao travar a criacao do Pedido de Pallet
					_cLocal     := Posicione('SC6',1,SC5->C5_FILIAL+SC5->C5_NUM,"C6_LOCAL")

					cTpOper		:= ''

					//====================================================================================================
					// Verifica se no cadastro do Cliente É CLIENTE CADASTRADO NA CHEP
					//====================================================================================================
					_clichep := "N"
					SA1->(Dbsetorder(1))
					If SA1->( DBSeek( xFilial("SA1") + ( cCliente + cLoja ) ) )

						If LEN(ALLTRIM(SA1->A1_I_CCHEP)) == 10
							_clichep := "S"
						EndIf

						_TipoC := SA1->A1_I_CHEP

						If !EMPTY(SA1->A1_I_PALET)
							_cPallet:= SA1->A1_I_PALET
						EndIf

					EndIf

					If EMPTY(_TipoC)
						_TipoC := "C"
					EndIf

					_cTipoPed := "2"

					If !SC5->C5_TIPO $ "B/D"//Se NÃO for beneficiamento e Devolução
						If _cPallet $ "S,1"
							//Esse controle é pela a origem dos dados para deixar alterar o tipo de carga inclusive se o usuario já alterou, saiu e entrou na tela de novo
							_cTipoPed := Iif(_TipoC = "C","1","3")
						Else
							_cTipoPed := "2"
						EndIF
					EndIF

					If _cTipoPed  $ "3,6"//"3-Pallet PBR","6-Pallet PBR Retorno"
						_TipoC:="P"
					EndIf

					If _TipoC == "C" //Pallet Chep
						If cCliente == '000001'
							cTpOper := Iif(_clichep == "S",_citls,_citln)
						Else
							cTpOper := Iif(_clichep == "S",_cclis,_cclin)
						EndIf
					ElseIf _TipoC == "P" //Pallet PBR
						cTpOper := Iif(cCliente == '000001',_cPBRITLP,_cPBRCLIP)
					EndIf

					//====================================================================================================
					// Monta o cabeçalho do pedido de Pallet
					//====================================================================================================
					_aCabPV :={	{ "C5_TIPO"		, cTipoPV			, Nil },; // Tipo de pedido
					{ "C5_I_OPER"	, cTpOper			, Nil },; // Tipo da operacao
					{ "C5_FILIAL"	, _cFilOrigem   	, Nil },; // filial
					{ "C5_CLIENTE"	, cCliente			, Nil },; // Codigo do cliente
					{ "C5_LOJAENT"	, cLoja				, Nil },; // Loja para entrada
					{ "C5_LOJACLI"	, cLoja				, Nil },; // Loja do cliente
					{ "C5_EMISSAO"	, date()			, Nil },; // Data de emissao
					{ "C5_CONDPAG"	, '001'				, Nil },; // Codigo da condicao de pagamanto*
					{ "C5_TIPLIB"	, "1"				, Nil },; // Tipo de Liberacao
					{ "C5_MOEDA"	, 1					, Nil },; // Moeda
					{ "C5_LIBEROK"	, " "				, Nil },; // Liberacao Total
					{ "C5_TIPOCLI"	, "F"				, Nil },; // Tipo do Cliente
					{ "C5_I_NPALE"	, _cPedOrigem		, Nil },; // Numero que originou a pedido de palete
					{ "C5_I_PEDPA"	, "S"				, Nil },; // Pedido Refere a um pedido de Pallet
					{ "C5_I_DTENT"	, _dDtEnt			, Nil } } // Dt de Entrega

					//====================================================================================================
					// Quando Pedido de Pallet Retorno e for Troca Nota o Pedido deve ser gerado na Filial de Carregamento
					//====================================================================================================
					If _cTipoPed  $ "1,3,4"
						Aadd( _aCabPV, { "C5_I_TRCNF", IF(EMPTY(SC5->C5_I_TRCNF),"N",SC5->C5_I_TRCNF), Nil } )
						Aadd( _aCabPV, { "C5_I_FILFT", SC5->C5_I_FILFT, Nil } )
						Aadd( _aCabPV, { "C5_I_FLFNC", SC5->C5_I_FLFNC, Nil } )
					EndIf


					//====================================================================================================
					// Verifica o Tipo de Pallet e recupera o código do Produto referente
					//====================================================================================================
					If _TipoC == "C"
						_cProduto := _cchep
					ElseIf _TipoC == "P"
						_cProduto := _cpbr
					EndIf


					//================================================================================
					// Localiza armazém do produto
					//================================================================================
					If _cLocal != '36'

						_cLocal := ""

						If SBZ->( DBSeek( xFilial('SBZ') + _cProduto ) )
							_cLocal := SBZ->BZ_LOCPAD
						EndIf

					Endif

					//================================================================================
					// Localiza nome do produto, preço e UM
					//================================================================================
					SB1->(DBSetOrder(1))
					If SB1->(DBSeek(xFilial("SB1")+_cProduto))
						_cDesc := ALLTRIM(SB1->B1_DESC)
						_nPreco:= SB1->B1_PRV1
						_cUM	  := SB1->B1_UM
					EndIf

					_nTotVlrPal   := _nPallet * _nPreco

					//====================================================================================================
					// Monta o item do pedido de Pallet
					//====================================================================================================
					AAdd( _aItemPV , {	{ "C6_ITEM"		, StrZero( nItem , 2 )	, Nil },; // Numero do Item no Pedido
					{ "C6_FILIAL"	, _cFilOrigem			, Nil },;
						{ "C6_PRODUTO"	, _cProduto				, Nil },; // Codigo do Produto
					{ "C6_QTDVEN"	, _nPallet				, Nil },; // Quantidade Vendida
					{ "C6_PRCVEN"	, _nPreco				, Nil },; // Preco Unitario Liquido
					{ "C6_PRUNIT"	, _nPreco				, Nil },; // Preco Unitario Liquido
					{ "C6_ENTREG"	, _dDtEnt				, Nil },; // Data da Entrega
					{ "C6_SUGENTR"	, _dDtEnt				, Nil },; // Data da Entrega
					{ "C6_VALOR"	, _nTotVlrPal			, Nil },; // valor total do item
					{ "C6_UM"		, _cUM					, Nil },; // Unidade de Medida Primar.
					{ "C6_LOCAL"	, _cLocal				, Nil },; // Almoxarifado
					{ "C6_DESCRI"	, _cDesc				, Nil },; // Descricao
					{ "C6_QTDLIB"	, 0						, Nil }}) // Quantidade Liberada

					_lMsgEmTela  := .F.
               //====================================================================================================
					// Geração do  pedido de Pallet
					//====================================================================================================
					MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItemPV , 3 )

               _lMsgEmTela  := .T.
					
               If lMsErroAuto

						If ( __lSx8 )
							RollBackSx8()
						EndIf

						_cMsgEfetiva := " Pedido_"+ALLTRIM(_cPedOrigem)+" - "+ALLTRIM(MostraErro("\system\", "Pedido_"+ALLTRIM(SC5->C5_NUM)+"_"+DTos(Date())+"_"+StrTran(Time(),":","-")+".log")) // Esta mensagem será retornada na integração com Webservice Italac x RDC.
						_cMsgEfetiva := " Ocorreram problemas na Geração de Pedidos de Pallet: " + StrTran(_cMsgEfetiva,Chr(10)+Chr(13),"")

						SC5->( DBGOTO( _aPeds_Pallet[_Ped,1] ))
						_cMensagem:='Erro ao gerar o Pedido Novo de Pallet'+IF(SC5->C5_I_TRCNF="S"," (Troca NF)","")+" ,"+_cMensagem
						_cCliente:=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+ALLTRIM( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME") )

						aAdd( _aLog , {.F.,SC5->C5_NUM,"Nao gerado",_cMensagem  ,_cCliente,cTpOper ,_cLocal  ,SC5->C5_I_FLFNC      ,SC5->C5_I_FILFT     } )

						_lGerouOK:=.F.
						LOOP //do FOR

					Else
						//Regrava por garantia
						SC5->( RecLock( 'SC5' , .F. ) )
						SC5->C5_I_NPALE := _cPedOrigem
						SC5->C5_I_PEDPA := 'S'//É o Pedido de Pallet
						SC5->C5_I_PEDGE := ''
						SC5->( MsUnlock() )

						_cCliente  := SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+ALLTRIM( Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME") )
						_cMensagem := 'Gerou o Pedido Novo de Pallet'+IF(SC5->C5_I_TRCNF="S"," (Troca NF)","")
						U_ITCONOUT(_cMensagem+": "+SC5->C5_NUM)

						aAdd( _aLog , {.T.,_cPedOrigem,SC5->C5_NUM,_cMensagem   ,_cCliente,cTpOper ,_cLocal  ,SC5->C5_I_FLFNC      ,SC5->C5_I_FILFT     } )

						SC6->(DBSetOrder(1))
						SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )//Posiciono por garantia

						//====================================================================================================
						// Faz a amarração do pedido de origem no pedido de Pallet
						//====================================================================================================
						_cPedPallet := SC5->C5_NUM
						If SC5->( DBSeek( _cFilOrigem + _cPedOrigem ) )
							SC5->( RecLock( 'SC5' , .F. ) )
							SC5->C5_I_NPALE := _cPedPallet
							SC5->C5_I_PEDPA := ''
							SC5->C5_I_PEDGE := 'S' //É o Pedido Gerador de Pallet
							SC5->( MsUnlock() )
						EndIf
					EndIf

				EndIf

			Else

				U_ITCONOUT("Pedido:"+_cPedOrigem+" sem quantidade de Pallet")

			EndIf

		EndIf

	NEXT

	SA1->(DBSETORDER(1))

	SC5->(DbGoTo(_nRenoSC5))

RETURN _lGerouOK



/*
===============================================================================================================================
Programa--------: AOMS112PB(_cCodFil,_cNumPed)
Autor-----------: Igor Fricks
Data da Criacao-: 07/06/2021
===============================================================================================================================
Descrição-------: Contabiliza peso do Pedido
===============================================================================================================================
Parametros------: 
==============================================================================================================================
Retorno---------: Lógico (.T.) Se acima de 5.000
===============================================================================================================================
*/
Static Function AOMS112PB(_cCodFil,_cNumPed)
	Local _lRet     := .F.
	Local _aAreaSZW := GetArea("SZW")
	Local _nPeso    := 0
	LOCAL _nPesoMinimo:=U_ITGETMV("IT_PBMITN",5000)
	Default _cCodFil := ""
	Default _cNumPed := ""

	SZW->( DBSetOrder(1) )
	SZW->( DBSeek( _cCodFil + _cNumPed ) )
	Do While SZW->( !EOF() ) .AND. ALLTRIM( _cCodFil + _cNumPed) == ALLTRIM(SZW->( ZW_FILIAL + ZW_IDPED ))

		_nPeso  += SZW->ZW_QTDVEN * POSICIONE("SB1",1,xFilial("SB1") + SZW->ZW_PRODUTO,"B1_PESBRU")

		SZW->(Dbskip())

	EndDo

	If _nPeso >= _nPesoMinimo
		_lRet := .T.
	EndIf

	RestArea(_aAreaSZW)

Return _lRet

/*
===============================================================================================================================
Programa--------: AOM112Magro()
Autor-----------: Alex Wallauer
Data da Criacao-: 14/07/2021
===============================================================================================================================
Descrição-------: LISTA DOS % DE LEITE MAGRO
===============================================================================================================================
Parametros------: _aListaPerc
==============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

Static Function AOM112Magro(_aListaPerc)
	LOCAL _aSize:={"40","40","40","40"}
	LOCAL _cMsgTop:=NIL
	LOCAL _cTitAux:="LISTA DOS % DE LEITE MAGRO"
	LOCAL _aCabPT:={"","Pedido","Qtde Magro","Qtde Integral","% Magro"}
	LOCAL _bLegenda:={|C,L| U_AOMS12Leg(C,L) }


	//         ITListBox(_cTitAux, _aHeader , _aCols       , _lMaxSiz ,  nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca,_bLegenda)
	lRet:=U_ITLISTBOX(_cTitAux, _aCabPT  , _aListaPerc  , .F.      , 4      , _cMsgTop ,          , _aSize  ,         ,     ,        ,          ,       ,        ,          ,           ,_bLegenda)

RETURN .T.

/*
===============================================================================================================================
Programa--------: AOMS12Leg()
Autor-----------: Alex Wallauer
Data da Criacao-: 29/04/2021
===============================================================================================================================
Descrição-------: DEVOLVE AS CORES PARA A LEGENDA
===============================================================================================================================
Parametros------: _aCol,_nLinha
==============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
USER Function AOMS12Leg(_aCol,_nLinha)
	Local oVerm := LoadBitmap( , "BR_VERMELHO")// VERMELHO TEM QUE GERA REPOSICAO .F. CRITICO
	Local oAzul := LoadBitmap( , "BR_AZUL"    )// AZUL TEM QUE GERA REPOSICAO .F. MAS TEM AINDA
	Local oVerd := LoadBitmap( , "BR_VERDE"   )// VERDE ESTOQUE TUDO OK .T.

	IF VAL(_aCol[_nLinha,5]) <> 0
		RETURN oVerd
	ELSEIF VAL(_aCol[_nLinha,4]) <> 0
		RETURN oAzul
	ENDIF

RETURN oVerm

/*
===============================================================================================================================
Programa--------: AOM112BoniApro()
Autor-----------: Alex Wallauer
Data da Criacao-: 19/07/2021
===============================================================================================================================
Descrição-------: Valida se o Cliente possui pedido(s) de Bonificacao sem aprovação
===============================================================================================================================
Parametros------: cCodCli , cLojCli , _cPSB
==============================================================================================================================
Retorno---------: .T. OU .F.
===============================================================================================================================
*/
STATIC Function AOM112BoniApro(cCodCli , cLojCli , _cPSB )

	Local cAlias	:= GetNextAlias()
	Local _cQuery	:= ""

	_cQuery := " SELECT DISTINCT SZW.ZW_IDPED "
	_cQuery += " FROM "+ RetSqlName("SZW") +" SZW "
	_cQuery += " WHERE  SZW.ZW_NUMPED 	= ' ' "
	_cQuery += " AND	SZW.ZW_CLIENTE	= '"+ cCodCli +"' "
	_cQuery += " AND	SZW.ZW_LOJACLI	= '"+ cLojCli +"' "
	_cQuery += " AND	SZW.ZW_TIPO	    = '10' "
	_cQuery += " AND	SZW.ZW_STATUS NOT IN ('Q','R','E','C') "
	_cQuery += " AND	SZW.ZW_BLOQ     <> 'R' "
	_cQuery += " AND    SZW.D_E_L_E_T_	= ' ' "

	If Select(cAlias) > 0
		(cAlias)->( DBCloseArea() )
	EndIf
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , cAlias , .T. , .F. )

	DBSelectArea(cAlias)
	_cPSB:=""
	(cAlias)->( DBGoTop() )
	DO WHILE (cAlias)->(!Eof())
		_cPSB += "[ "+ALLTRIM((cAlias)->ZW_IDPED)+" ] "
		(cAlias)->(DBSKIP())
	ENDDO
	(cAlias)->( DBCloseArea() )
	DBSelectArea("SZW")

RETURN EMPTY(_cPSB)

/*
===============================================================================================================================
Programa----------: AOM112F3()
Autor-------------: Alex Wallauer
Data da Criacao---: 030/07/2018
===============================================================================================================================
Descricao---------: Função usada no F3: F3ITLC
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Tipos de pedidos
===============================================================================================================================*/
USER Function AOM112F3()
LOCAL  _aF3Novo :={}
AADD(  _aF3Novo , "01=Pedido com Crédito Rejeitado [Laranja]")
AADD(  _aF3Novo , "02=Pedido com Cliente/Remessa Bloqueado [X Vermelho] ")
AADD(  _aF3Novo , "03=Pedido Bonificação Bloqueadoo [Marrom Ocean]")
AADD(  _aF3Novo , "04=Pedido Bonificação Rejeitado [Marrom Quadrado]")
AADD(  _aF3Novo , "05=Pedido com Preço Rejeitado [Violeta]")
AADD(  _aF3Novo , "06=Pedido com Preço Bloqueado [Preto]")
AADD(  _aF3Novo , "07=Pedido com Preço Liberado [Verde]")
AADD(  _aF3Novo , "08=Pedido com Crédito Bloqueado [Azul]")
AADD(  _aF3Novo , "09=Pendente Aprov. Preço P/Coordenador [Amarelo]")
AADD(  _aF3Novo , "10=Pendente Aprov. Preço P/Gerente [Verde Escuro]")
AADD(  _aF3Novo , "11=Pedido aguardando Efetivação [Vermelho]")
RETURN _aF3Novo

/*
===============================================================================================================================
Programa--------: SOMS112S
Autor-----------: Alex Wallauer
Data da Criacao-: 10/03/2022
===============================================================================================================================
Descrição-------: Efetivação dos pedidos de vendas do portal automatica
===============================================================================================================================
Parametros------: _lTela - Se .t. mostra as telas
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
USER Function SOMS112S(_lTela)//U_SOMS112S(.T.)
	LOCAL _nnm
	Local _cAlias := GetNextAlias()
	Local _cQuery := ""
	Local _aPeds  :={}
	//Private _lMsgEmTela := .F.  //Para o mt410tok não mostrar mensagens em tela
	Private _alista := {}
	Private _otemp := nil
	Private _ccodclip := ""
	Private _cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))// Tipos de operações da operação trigular
	Private _cOperFat       := LEFT(_cOperTriangular,2)
	Private _cOperRemessa   := RIGHT(_cOperTriangular,2)
	Private aarr := {}
	Private aheader := {}
//============================================================================================
// Variáveis abaixo utilizadas na efetivação do pedido do portal. Na chamada do MSEXECAUTO.
//============================================================================================
	Private _cOperTri   := Space(1)  // Esta variável será utilizada no fonte MT410TOK para peencher o campo operação triangular.
	Private _cCodClien  := Space(6)  // Esta variável será utilizada no fonte MT410TOK para peencher o campo codigo Cliente/Venda.
	Private _cLojaClie  := Space(4)  // Esta variável será utilizada no fonte MT410TOK para peencher o campo loja Cliente/Venda.

	DEFAULT _lTela := !FWGetRunSchedule()

	IF _lTela
		IF !U_ITMSG("Confirma Geração de Pedidos",'Atenção!',,1,2,2)
			RETURN .F.
		ENDIF
	ENDIF

	_cQuery += " SELECT DISTINCT ZW_FILIAL, ZW_IDPED, CASE WHEN ZW_TIPO = '10' THEN 'A ' ELSE 'B' END ORD , "
	_cQuery += " (SELECT MIN(R_E_C_N_O_) FROM "+ RETSQLNAME('SZW') +" B WHERE B.ZW_IDPED = SZW.ZW_IDPED) NRRECNO "
	_cQuery += " FROM  "+ RETSQLNAME('SZW') +" SZW "
	_cQuery += " WHERE "+ RETSQLDEL('SZW')
	_cQuery += " AND SZW.ZW_EMISSAO >= '20240101'
	_cQuery += " AND SZW.ZW_STATUS = 'L' "
	_cQuery += " AND SZW.ZW_ITEM = '1 ' "
	_cQuery += " AND SZW.ZW_NUMPED = ' ' "
	_cQuery += " AND SZW.ZW_ENVWF <> ' ' " //Somente listar Pedido que já foi avaliado pela rotina MOMS050 - WF DE PREÇO
	_cQuery += " AND NOT EXISTS (SELECT 'Y' FROM "+ RETSQLNAME('SZW') +" SZWB WHERE SZWB.ZW_IDPED = SZW.ZW_IDPED "
	_cQuery += " AND SZWB.ZW_BLOPRC IN ('B', 'R') AND SZWB.ZW_BLQLCR IN ('B','R','Z') ) "
	_cQuery += " ORDER BY ORD, NRRECNO "

	TCQUERY _cquery NEW ALIAS (_cAlias)

	(_cAlias)->( DBGoTop() )

	Do While (_cAlias)->(!EOF())

		aadd(_aPeds,(_cAlias)->ZW_FILIAL+(_cAlias)->ZW_IDPED)

		(_cAlias)->(DBSKIP())

	Enddo

	If len(_aPeds) == 0

		IF _lTela
			u_itmsg("Nenhum pedido selecionado","Atenção","Selecione ao menos um pedido para efetivar",1)
		ENDIF

	Else

		If len(_aPeds) > 0

			SZW->( DBSetOrder(1) )
			_aResults := {}
			_ntot := len(_aPeds)
			//Realiza efetivação dos pedidos
			For _nnm := 1 to _ntot

				IF SZW->( DBSeek( _aPeds[_nnm] ) ) .AND. SZW->ZW_STATUS = 'L' .AND. SZW->ZW_NUMPED = ' ' .AND. SZW->ZW_ENVWF <> ' '
					_nni := _nnm
					cFilAnt := SZW->ZW_FILIAL
					IF _lTela
						FWMSGRUN(,{|oproc| AOMS112EFE(SZW->ZW_IDPED , SZW->ZW_FILIAL,.T.,_lTela)},"Pedido: "+_aPeds[_nnm],"Efetivando pedido " + STRZERO(_nnm,4) + " de " + STRZERO(_ntot,4) +"...")
					ELSE
						AOMS112EFE(SZW->ZW_IDPED , SZW->ZW_FILIAL,.T.,_lTela)
					ENDIF
				ENDIF

			Next

			If len(_aResults) > 0
				_aCab:={' ','Filial','Pedido','Cliente/Remessa','Resultado / Erros',"Complemento do Resultado / Erros"}
				FOR _nnm := 1 TO LEN(_aResults)
					IF LEN(_aResults[_nnm]) < 6
					   ASize( _aResults[_nnm] , 6 )
					   _aResults[_nnm,6]:=" "
					ENDIF
				NEXT
				IF _lTela
					U_ITListBox( "Efetivação de pedidos do portal" , _aCab , _aResults , .T. , 1,"Resultado do processamento" )
				ENDIF
				_cLinha:=ARRTOKSTR(_aCab,";")+CRLF
				FOR _nnm := 1 TO LEN(_aResults)
					_cLinha+=ARRTOKSTR(_aResults[_nnm],";")+CRLF
				NEXT
				_cLinha:=STRTRAN(_cLinha,".",",")
				_cdir := "\data\Italac\AOMS112\"
				_cFileNome:=_cdir+"AOMS112_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".CSV"
				MemoWrite(_cFileNome,_cLinha)
			Else

				IF _lTela
					u_itmsg("Nenhum pedido efetivado!","Atenção",,1)
				ENDIF

			Endif

		Else

			IF _lTela
				u_itmsg("Nenhum registro encontrado!","Atenção",,1)
			ENDIF

		Endif

	Endif

Return

/*
===============================================================================================================================
Programa----------: AOM112RC()
Autor-------------: Jerry
Data da Criacao---: 22/03/2022
===============================================================================================================================
Descricao---------: Função usada para chamada da Gravação da Recusa via Scheduler MOMS050
===============================================================================================================================
Parametros--------: cFilPed, nIdPed
===============================================================================================================================
Retorno-----------: _dDataOriginal
===============================================================================================================================*/
USER Function AOM112RC(cFilPed, nIdPed, cMotivo)
	
	AOMS112GRC(cFilPed, nIdPed,"AUTO",cMotivo)

RETURN

User Function DTVAL112(_dDataOriginal)
Local _ni     := 0
Local _nDiasMax  := U_ItGetMv("IT_MAXDIASE", 7)


Do while _ni < _nDiasMax

	
	_dDataOriginal := (_dDataOriginal + 1 )

	If _dDataOriginal =  DataVAlida( _dDataOriginal, .T. )
		_ni++
	EndIf 
	
ENDDO

Return(_dDataOriginal)




/*
===============================================================================================================================
Programa----------: AOM112AP()
Autor-------------: Igor Melgaço
Data da Criacao---: 02/06/2022
===============================================================================================================================
Descricao---------: Função usada para visualizar dados da aprovação
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
USER Function AOM112AP()
Local _oDlg
Local _cGData:= ""
Local _cGHora:= ""
Local _cCData:= ""
Local _cCHora:= ""
Local _cObs  := ""
Local _nCol1 := 007
Local _nCol2 := 105
Local _nLinha:= 007

If len(aarr) = 0
   u_itmsg("Não há registros para visualizar.",'Atenção!',"Altere o filtro para trazer registros validos.",1)
   Return .F.
Endif

SZW->(DbSetOrder(1))
SZW->(Dbseek(LEFT(ALLTRIM(aarr[oMark:naT,A112MAP("Filial Faturamento")]),2)+ALLTRIM(aarr[oMark:naT,A112MAP("Id Pedido")]) ))
_cGData:= SZW->ZW_I_DLIBG
_cGHora:= LEFT(SZW->ZW_I_HLIBG,5)
_cCData:= SZW->ZW_DATAAPR 
_cCHora:= SZW->ZW_HORAAPR 
_cObs  := SZW->ZW_I_OBS

DEFINE MSDIALOG _oDlg TITLE "Dados de Aprovação de Pedido " FROM 000,000 TO 300,470 PIXEL

	@ _nLinha, _nCol1 SAY "Data de Aprovação do Gerente:" PIXEL
	@ _nLinha, _nCol2 MSGET _cGData  SIZE 50,11 OF _oDlg  PIXEL When .F.
	_nLinha+=15

	@ _nLinha, _nCol1 SAY "Hora de Aprovação do Gerente:" PIXEL
	@ _nLinha, _nCol2 MSGET _cGHora SIZE 50,11 OF _oDlg PIXEL When .F.
	_nLinha+=15

	@ _nLinha, _nCol1 SAY "Data de Aprovação do Coordenador:" PIXEL
	@ _nLinha, _nCol2 MSGET _cCData  SIZE 50,11 OF _oDlg  PIXEL When .F.
	_nLinha+=15

	@ _nLinha, _nCol1 SAY "Hora de Aprovação do Coordenador:" PIXEL
	@ _nLinha, _nCol2 MSGET _cCHora SIZE 50,11 OF _oDlg PIXEL When .F.
	_nLinha+=15

	@ _nLinha, _nCol1 SAY "Observação:" PIXEL
	_nLinha+=15
	@ _nLinha, _nCol1 GET _cObs MEMO SIZE 220,50 MEMO OF _oDlg PIXEL WHEN .F.

Activate MSDialog _oDlg Centered

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS112Q()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 16/09/2022
===============================================================================================================================
Descricao---------: Alterar pedido de vendas do portal, conforme regras estabelecidas para filial "93".
                    No momento da efetivação. Chamado 41299.
===============================================================================================================================
Parametros--------: _cCodFil = Filial do Pedido
                    _cIdPed  = NUMERO DO PEDIDO /PORTAL
					_cfilpro = Filial de Carregamento.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
User Function AOMS112Q(_cCodFil , _cIdPed ,_cfilpro)
Local _aRegsSZW := {}
//Local _lSoLocal38 := .T.
Local _lHaArmaz38 := .F.
Local _nI 
Local _cLocFrisia := U_ITGETMV("IT_LOCFRIS","38")
Local _cLocProd

Begin Sequence 
   
   SBZ->( DBSetOrder(1) ) // BZ_FILIAL+BZ_COD

   SZW->( DBSetOrder(1) )
   SZW->( DBSeek( _cCodFil + _cIdPed ) )

   Do While SZW->( !Eof() ) .AND. _cCodFil + _cIdPed == SZW->( ZW_FILIAL + ZW_IDPED )

      Aadd(_aRegsSZW, SZW->(Recno()))
	  IF _lHaArmaz38
	     SZW->(DbSkip())
	     LOOP//SÓ PARA NÃO FICAR DANDO SEEK NO SBZ EM TODOS
	  ENDIF
      
	  _cLocProd := "ZZ"
	  If SBZ->(MsSeek(_cCodFil+ SZW->ZW_PRODUTO)) //.Or. SBZ->(MsSeek(_cfilpro+ SZW->ZW_PRODUTO))
	     _cLocProd := SBZ->BZ_LOCPAD 
	  EndIf

      If _cLocProd $ _cLocFrisia // "38"
		 _lHaArmaz38 := .T.
	  //Else
		// _lSoLocal38 := .F.
	  EndIf

	  SZW->(DbSkip())

   EndDo
   
   For _nI := 1 To Len(_aRegsSZW)
       SZW->(DbGoto(_aRegsSZW[_nI]))

	   If _lHaArmaz38 //.And. _lSoLocal38
          SZW->(RecLock("SZW",.F.))
          SZW->ZW_TIPO  := "26"  // Alterar ZW_TIPO para 26
          SZW->ZW_LOCAL := "38"  // Alterar ZW_LOCAL para 38
          SZW->(MsUnLock())
	   //ElseIf _lHaArmaz38
	   //   SZW->(RecLock("SZW",.F.)) 
       //   SZW->ZW_LOCAL := "36" // Alterar ZW_LOCAL para 36
       //   SZW->(MsUnLock())
       EndIf 

   Next 

End Sequence 

Return Nil


/*
===============================================================================================================================
Programa--------: Ver_Lib_PV(cChave)
Autor-----------: Alex Wallauer
Data da Criacao-: 30/01/2020
===============================================================================================================================
Descrição-------: Verefica se no SC9 esta tudo OK ou tenta liberar o Pedido
===============================================================================================================================
Parametros------: cChave: Filia + Pedido, _aRecProdSZW: {PRODUTO,RECNO DO SZW}
==============================================================================================================================
Retorno---------: Lógico (.F.) Tá com erro (.T.) Tá tudo OK
===============================================================================================================================
*/
*====================================================================================================*
Static Function Ver_Lib_PV(cChave,_aRecProdSZW)
*====================================================================================================*
LOCAL _lOK:=.T.//Não Tem erro
LOCAL _nQtdLib:=0
LOCAL _lLiberou:=.T.

SC6->( DbSetOrder(1) )//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
IF !SC6->( DBSeek( cChave ) )
	_lOK:=.F.//Tem erro
ENDIF

SC9->(DBSETORDER(1) )//
SC6->(DBSETORDER(1))
DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == cChave
	
	_lOK:=.T.
	
	IF !SC9->(DBSEEK(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))
		_nQtdLib := MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN)//LIBERA ITEM DO PEDIDO
	ENDIF
	
	IF SC9->(DBSEEK(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))
		If SC9->C9_QTDLIB <> SC6->C6_QTDVEN
			_lOK:=.F.//Tem erro
			//EXIT
		ElseIf !Empty(SC9->C9_BLEST)
			_lOK:=.F.//Tem erro
			//EXIT
		ENDIF	    
		If _lOK .AND. !(EMPTY(SC9->C9_BLCRED))
           SC9->(RECLOCK("SC9",.F.))
  		   SC9->C9_BLCRED := " "	   
	   	   SC9->(MsUnlock("SC9"))
	   		
	       //Faz análise e liberação de estoque pois o padrão não analisa estoque se o crédito está bloqueado
	       //Posiciona SC6 pois a função A440VerSb2 depende do SC6 posicionado para analisar o estoque
	       If SC6->(DbSeek(SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM)) .AND. A440VerSB2(SC9->C9_QTDLIB)
	       	  If !(empty(SC9->C9_BLEST))
	       	     SC9->(RECLOCK("SC9",.F.))
		         SC9->C9_BLEST := ""
	   	         If !(MaAvalSC9("SC9",5,{{ "","","","",SC9->C9_QTDLIB,SC9->C9_QTDLIB2,Ctod(""),"","","",SC9->C9_LOCAL}}))
	   	            SC9->C9_BLEST := "02"
			        _lOK:=.F.//Tem erro
			        //EXIT
	   	         Endif	
	             SC9->(MsUnlock("SC9"))
	          Endif
	   	   Endif	
   	    Endif	
	ELSE
	   _lOK:=.F.//Tem erro
	   //EXIT
	ENDIF
    IF !_lOK //Tem erro
	   _lLiberou:=.F.
	   IF (nPos:= ASCAN(_aRecProdSZW, {|P| P[1] == SC6->C6_PRODUTO  })) > 0
		   _aRecProdSZW[nPos,3]:="Produto "+SC6->C6_PRODUTO+" com quantidade de Estoque insuficiente"
	   ENDIF	
	ENDIF

	SC6->( DBSkip() )
	
ENDDO

RETURN _lLiberou


/*
===============================================================================================================================
Programa--------: CorrigeItem
Autor-----------: Alex Wallauer
Data da Criacao-: 10/05/2024
===============================================================================================================================
Descrição-------: Verefica se o C6_ITEM esta igual ao ZW_ITEM
===============================================================================================================================
Parametros------: aCorrigeItem,_cChavePed
==============================================================================================================================
Retorno---------: (.T.) Tá tudo OK
===============================================================================================================================*/
Static Function CorrigeItem(aCorrigeItem As Array,_cChavePed As Character) As Logical
 Local aChaveUnica:= {} As Array
 Local _cLog      := "" As Character
 Local _lGravaLog :=.F. As Character
 Local nConta     := 0  As Numeric
 Local cConta     := "" As Character
 Local lCorrige   := GetMV( "IT_CORITEM",,.T.) As Logical
 Local _cFileNome := "" As Character 
 
 DEFAULT _cChavePed:=SC5->C5_FILIAL + SC5->C5_NUM
 
 //FORMATO DO ARRAY aCorrigeItem
 //AADD(aCorrigeItem,{SZW->ZW_PRODUTO , STRZERO( VAL( ALLTRIM(SZW->ZW_ITEM) ) , 2 )} )
 
 //Indice 12 pq não pode ter o campo C6_ITEM no indice pois vai ser atualizado.
 SC6->(Dbsetorder(12))//C6_FILIAL+C6_NUM+C6_PRODUTO+C6_SOLCOM
 
 SC6->(Dbseek(_cChavePed))
 _cLog+="Usuario ......................: "+Posicione("SRA",1,SC5->C5_I_CDUSU,"RA_NOME")+CRLF
 _cLog+="Data e Hora ..................: "+DToC(Date())+" as "+Time()+CRLF
 _cLog+="Pedido do Protheus ...........: "+SC5->C5_FILIAL +" "+ SC5->C5_NUM+CRLF
 _cLog+="Pedido do Portal .............: "+SC5->C5_I_IDPED+CRLF
 aChaveUnica:={}
 nConta:=0
 Do While _cChavePed == SC6->C6_FILIAL + SC6->C6_NUM .AND. SC6->(!EOF())
    nConta++
    cConta:=STRZERO(nConta,3)
    _cLog+="Produto "+cConta+" do SC6............: "+SC6->C6_FILIAL +" "+ SC6->C6_NUM +" "+ SC6->C6_PRODUTO +" "+ SC6->C6_ITEM+CRLF
    If SC6->C6_ITEM = "00" .OR. ASCAN(aChaveUnica,SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_PRODUTO) > 0
       _lGravaLog :=.T.
    EndIF
    AADD(aChaveUnica, SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_PRODUTO + SC6->C6_ITEM)
    SC6->(Dbskip())
 EndDo
 If _lGravaLog 
    _cFileNome:="\data\Italac\aoms112\"+"aoms112_item00_A_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".TXT"
    MemoWrite(_cFileNome,_cLog)
 EndIf
 SC6->(Dbseek(_cChavePed))
 Do While _cChavePed == SC6->C6_FILIAL + SC6->C6_NUM .AND. SC6->(!EOF())
    IF (nPos:=ASCAN(aCorrigeItem,{|I| I[1] == SC6->C6_PRODUTO })) > 0
       _cLog+="Produto no SZW ...............: "+ALLTRIM(SC6->C6_PRODUTO) +" ["+aCorrigeItem[nPos,2]+"]"+CRLF
       IF SC6->C6_ITEM = "00" .AND. SC6->C6_ITEM <> aCorrigeItem[nPos,2]
 	      _lGravaLog :=.T.
          _cLog+="Achou Item diferente no Portal: Prod.: "+ALLTRIM(SC6->C6_PRODUTO)+" SC6: {"+SC6->C6_ITEM+"} <> SZW: {"+aCorrigeItem[nPos,2]+"}"+CRLF
          IF lCorrige .AND. VAL(aCorrigeItem[nPos,2]) > 0 .AND. ASCAN(aChaveUnica,SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_PRODUTO + aCorrigeItem[nPos,2]) = 0
             _cLog+="CORRIGIU Item no Protheus.....: "+ALLTRIM(SC6->C6_PRODUTO) +" DE {"+SC6->C6_ITEM+"} PARA {"+aCorrigeItem[nPos,2]+"}"+CRLF
             SC6->( Reclock( "SC6", .F. ) )
             SC6->C6_ITEM := aCorrigeItem[nPos,2]//Não tem problema de repetir o C6_ITEM pq a chave unica é C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
             SC6->( Msunlock())
          ELSE
             _cLog+="NAO corrigiu Item no Protheus : "+ALLTRIM(SC6->C6_PRODUTO) +" DE {"+SC6->C6_ITEM+"} PARA {"+aCorrigeItem[nPos,2]+"}"+CRLF
          ENDIF
       ENDIF
    ELSE
       _cLog+="NAO Achou Item/Prod. no Portal: "+ALTRIM(SC6->C6_PRODUTO) +CRLF
    ENDIF 
    SC6->(Dbskip())
 EndDo
 IF _lGravaLog
    _cFileNome:="\data\Italac\aoms112\"+"aoms112_item00_D_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".TXT"
    MemoWrite(_cFileNome,_cLog)
 ENDIF
 SC6->(Dbsetorder(1))//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

RETURN .T.



/*
===============================================================================================================================
Programa----------: AOMS112X
Autor-------------: Igor Melgaço
Data da Criacao---: 16/08/2024
===============================================================================================================================
Descrição---------: Altera Marcados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112X()

Local aCoors 	:= {}
Local aSize    := {}
Local aObjects	:= {}
Local oDlg		:= Nil
Local oFont		:= Nil
Local cTitAux	:= "Alterar Selecionados"

Private C5_I_AGEND := ""

If AOMS112VM()

   aCoors 	:= FWGetDialogSize(oMainWnd)
   aSize    := MsAdvSize( .T. ) 

   aAdd( aObjects , { 100 , 100 , .T. , .T. } )
   aInfo   := { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 3 , 2 }
   aPosObj := MsObjSize( aInfo , aObjects )

   DEFINE FONT oFont NAME "Verdana" SIZE 05,12

   C5_I_AGEND := Space(Len(TRBF->TPCAR))
   dDataEnt   := CTOD("")
   cOper      := Space(Len(TRBF->TIPO ))
   cFilCar    := Space(Len(TRBF->FILIAL))
   cFilFat    := Space(Len(TRBF->FILIAL))
   cNomeCar   := Space(50)
   cNomeFat   := Space(50)

   nLin := 5
   nCol := 10
   nCol2 := 80

   DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitAux) From 03,0 To 17,50  //"OPs em Aberto deste Produto"

   	  @ nLin , nCol  SAY 'Tipo de Agendamento' OF oDlg PIXEL 
      @ nLin , nCol2 MSGET oTipo Var C5_I_AGEND  SIZE 50,09  PIXEL F3 "LSTAGE" PICTURE "@!" OF oDlg PIXEL VALID AOMS112VT( C5_I_AGEND ) 

      nLin += 15

   	  @ nLin , nCol  SAY 'Data de Entrega' OF oDlg PIXEL 
      @ nLin , nCol2 GET oDataEnt Var dDataEnt SIZE 40,09 PIXEL /*VALID NaoVazio(  )*/  OF oDlg PIXEL
      oDataEnt:bLostFocus := { || IIf(!Empty(Alltrim(DTOS(dDataEnt))),(Iif(dDataEnt >= DATE(),dDataEnt,DATE()),oDataEnt:Refresh()),dDataEnt) }

      nLin += 15

   	  @ nLin , nCol  SAY 'Filial de Carregamento' OF oDlg PIXEL 
      @ nLin , nCol2 MSGET oFilCar Var cFilCar SIZE 20,09 PIXEL F3 "SM0" OF oDlg PIXEL VALID AOMS112VF( @cFilCar,@cNomeCar,@oNomeCar,@cFilFat,@cNomeFat,@oNomeFat )  //QA_CHKFIL(cFilCar,@cFilCar) //VALID {||/*Vazio() .OR.*/ Pertence("SM0") }
      @ nLin , nCol2+20 MSGET oNomeCar Var cNomeCar SIZE 70,09 PIXEL OF oDlg PIXEL  When .F. 

      nLin += 15

      @ nLin , nCol  SAY 'Filial de Faturamento' OF oDlg PIXEL 
      @ nLin , nCol2 MSGET oFilFat Var cFilFat SIZE 20,09 PIXEL F3 "SM0" OF oDlg PIXEL  VALID AOMS112VF( @cFilCar,@cNomeCar,@oNomeCar,@cFilFat,@cNomeFat,@oNomeFat )   //QA_CHKFIL(cFilFat,@cFilFat) //VALID {||/*Vazio() .OR.*/ Pertence("SM0") }
      @ nLin , nCol2+20 MSGET oNomeFat Var cNomeFat SIZE 70,09 PIXEL OF oDlg PIXEL  When .F. //QA_CHKFIL(cFilFat,@cFilFat) //VALID {||/*Vazio() .OR.*/ Pertence("SM0") }

      nLin += 15

      @ nLin , nCol  SAY 'Operação' OF oDlg PIXEL 
      @ nLin , nCol2 MSGET oOper Var cOper SIZE 40,09 PIXEL F3 "ZB4" OF oDlg VALID (AOMS112VO(cOper))

      nLin += 20

    DEFINE SBUTTON FROM nLin,130  TYPE 1 ACTION Iif(AOMS112VM(),(oDlg:End(),AOMS112Y(C5_I_AGEND,dDataEnt,cFilCar,cFilFat,cOper)),Nil) ENABLE OF oDlg
   	DEFINE SBUTTON FROM nLin,166  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

   ACTIVATE MSDIALOG oDlg VALID ()
EndIf 

Return



/*
===============================================================================================================================
Programa----------: AOMS112Y
Autor-------------: Igor Melgaço
Data da Criacao---: 16/08/2024
===============================================================================================================================
Descrição---------: Altera os Marcados
===============================================================================================================================
Parametros--------: _cTipoAg,_dDtEnt
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS112Y(_cTipoAg,_dDtEnt,_cFilCar,_cFilFat,_cOper)
Local _ni := 0
Local aTpCar :={}
Local cTpCar := ""

Local _nposi := TRBF->(Recno())
Local _aPeds := {}
Local _acolec := {}
Local _aheaderec := {}
Local _nnh		:= 0
Local _nnm		:= 0
Private cfilfat := space(30)
Private cfilcrg := space(30)

IF MV_PAR23 = 1 //SÓ REJEITADOS
   RETURN .F.
ENDIF

If !Empty(Alltrim(_cTipoAg))

   AADD(aTpCar,{'A','AGENDADA'})
   AADD(aTpCar,{'I','IMEDIATA'})
   AADD(aTpCar,{'O','AGENDADA P/ O.LOG.'})
   AADD(aTpCar,{'M','AGENDADA C/MULTA'})

   nPos := aScan(aTpCar,{|x| x[1] == _cTipoAg}) 
   If nPos > 0
      cTpCar := aTpCar[nPos,2]
   Else
      cTpCar := 'AGUARD. AGENDA'
   EndIf
EndIf

For _ni := 1 to Len(aarr)
   If aarr[_ni,1] == cMarca

      If !Empty(Alltrim(_cTipoAg))
		   aarr[_ni,A112MAP("Tipo Entrega")] := cTpCar
      EndIf 
      
      If !Empty(AllTrim(DTOS(_dDtEnt)))
         aarr[_ni,A112MAP("Dt Entrega")] := _dDtEnt
      EndIf

      If !Empty(_cFilCar)
         aarr[_ni,A112MAP("Filial Carregamento")] := SUBSTR(_cFilCar,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(_cFilCar,1,2),1,"") 
      EndIf

      If !Empty(_cFilFat)
         aarr[_ni,A112MAP("Filial Faturamento")] := SUBSTR(_cFilFat,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(_cFilFat,1,2),1,"")
      EndIf

      If !Empty(_cOper)
         aarr[_ni,A112MAP("Tipo")] = _cOper + " - " + Posicione("ZB4",1,xFilial("ZB4")+_cOper,"ZB4_DESCRI")
      EndIf

   EndIf

Next
//Validação do Alex

	TRBF->( DBGoTop() )

   //================================================================================
   //Carrega pedidos selecionados
   //================================================================================
	Do While TRBF->(!EOF())

		//================================================================================
		// Somente pedidos selecionados pelo usuario
		//================================================================================
		If (TRBF->OK == cmarca .and. !linverte) .or. (TRBF->OK != cmarca .and. linverte)

			aadd(_aPeds,TRBF->(Recno()))

		Endif

		TRBF->(DBSKIP())

	Enddo

   //Retorna browse ao pedidos posicionado
	TRBF->(Dbgoto(_nposi))

	//Monta tela de confirmação

	//Monta aheader
	aadd(_aheaderec,"Impresso")
	aadd(_aheaderec,"Fil Car")
	aadd(_aheaderec,"Fil Fat" )
	aadd(_aheaderec,"Id Pedido" )
	aadd(_aheaderec,"Cliente/Remessa")
	aadd(_aheaderec,"Tipo Entrega")
	aadd(_aheaderec,"Dt Emissão")
	aadd(_aheaderec,"Dt Carga")
	aadd(_aheaderec,"Trans Time")
	aadd(_aheaderec,"Dt Entrega")
	aadd(_aheaderec,"Tp Frete")
	aadd(_aheaderec,"Tab Preço")
	aadd(_aheaderec,"Cond Pgto")
	aadd(_aheaderec,"Vendedor")
	aadd(_aheaderec,"Mens NF")
	aadd(_aheaderec,"Obs")

	//Monta acols
	For _nnh := 1 to len(aarr)

		If aarr[_nnh][1] == cmarca

			aadd(_acolec, {	 aarr[_nnh,A112MAP("Impresso")],;
				aarr[_nnh,A112MAP("Filial Faturamento") ],;
				aarr[_nnh,A112MAP("Filial Carregamento")],;
				aarr[_nnh,A112MAP("Id Pedido")],;
				aarr[_nnh,A112MAP("Cliente/Remessa")],;
				aarr[_nnh,A112MAP("Tipo Entrega")],;
				aarr[_nnh,A112MAP("Dt Emissão")],;
				aarr[_nnh,A112MAP("Dt Carga")],;
				aarr[_nnh,A112MAP("Trans Time")],;
				aarr[_nnh,A112MAP("Dt Entrega")],;
				aarr[_nnh,A112MAP("Tp Frete")],;
				aarr[_nnh,A112MAP("Tab Preço")],;
				aarr[_nnh,A112MAP("Cond Pgto")],;
				aarr[_nnh,A112MAP("Vendedor")],;
				aarr[_nnh,A112MAP("Mens NF")],;
				aarr[_nnh,A112MAP("Obs")]})
		Endif

	Next

   cfilfat := _cFilFat
   cfilcrg := _cFilCar

	//_acolec2 := {}

	//Realiza alteração de pedidos
	For _nnm := 1 to len(_aPeds)

		BEGIN TRANSACTION
			TRBF->(Dbgoto(_aPeds[_nnm]))

			_cfilul := TRBF->FILIAL
			_numul  := TRBF->NUMPED

			Reclock("TRBF",.F.)

         If !Empty(cfilcrg)
            TRBF->FILIAL := cfilcrg
         EndIf

         If !Empty(cfilfat)
            TRBF->FILPRO := cfilfat
         EndIf

         If !Empty(_cOper)
            TRBF->TIPO := _cOper
         EndIf

         If !Empty(Alltrim(_cTipoAg))
   		   TRBF->TPCAR := _cTipoAg
         EndIf 
         
         If !Empty(Alltrim(Dtos(_dDtEnt)))
            TRBF->DT_ENTREG := dtoc(_dDtEnt)
         EndIf         

			TRBF->(Msunlock())

			_acolec[_nnm][1] := cfilfat
			_acolec[_nnm][2] := cfilcrg

			SZW->(Dbsetorder(1))
			If SZW->(Dbseek(substr(_cfilul,1,2)+_numul))

				If  !( AOMS112LO( substr(_cfilul,1,2), _numul,.F. ) )

					//aadd(_acolec2,{_acolec[_nnm][1],_acolec[_nnm][2],_acolec[_nnm][3],_acolec[_nnm][4],"Pedido em uso!"})
					Disarmtransaction()

				Else

					SZW->(Dbseek(substr(_cfilul,1,2)+_numul))
					Do while SZW->ZW_FILIAL == substr(_cfilul,1,2) .AND. ALLTRIM(SZW->ZW_IDPED) == ALLTRIM(_numul)

						Reclock("SZW",.F.)
                  If !Empty(Alltrim(cfilfat))
						   SZW->ZW_FILIAL := LEFT(cfilfat,2)
                  EndIf

                  If !Empty(Alltrim(cfilcrg))
						   SZW->ZW_FILPRO := LEFT(cfilcrg,2)
                  EndIf
                  
                  If !Empty(Alltrim(_cTipoAg))
            		   SZW->ZW_I_AGEND := _cTipoAg
                  EndIf 
                  
                 If !Empty(Alltrim(Dtos(_dDtEnt)))
                     SZW->ZW_FECENT := _dDtEnt
                  EndIf

                  If !Empty(_cOper)
                     SZW->ZW_TIPO := _cOper
                  EndIf

						SZW->(Msunlock())
						SZW->(Dbskip())

					Enddo

					AOMS112UN( substr(TRBF->FILIAL,1,2), _numul )

					//aadd(_acolec2,{_acolec[_nnm][1],_acolec[_nnm][2],_acolec[_nnm][3],_acolec[_nnm][4],"Filiais alteradas com sucesso"})

				Endif

			Else

				Disarmtransaction()
				_acolec[_nnm][1] := TRBF->FILIAL
				_acolec[_nnm][2] := TRBF->FILPRO
				//aadd(_acolec2,{_acolec[_nnm][1],_acolec[_nnm][2],_acolec[_nnm][3],_acolec[_nnm][4],"Falha na alteração de filiais"})

			Endif

		END TRANSACTION

	Next

	//U_ITListBox( "Alteração de filiais de pedidos do portal" , _aheaderec , _acolec2 , .T. , 1,"Alteração de filiais de pedidos do portal realizada com sucesso!" )
   U_ITMSG("Alterações processadas com sucesso","Atenção",,1)
	//atualiza a tela
	fwmsgrun(,{|oproc| AOMS112arq(oproc)},"3 - Aguarde...","Atualizando tela...")
///////////

Return()


/*
===============================================================================================================================
Programa----------: AOMS112VO
Autor-------------: Igor Melgaço
Data da Criacao---: 27/08/2024
===============================================================================================================================
Descrição---------: Altera os Marcados
===============================================================================================================================
Parametros--------: _cOper
===============================================================================================================================
Retorno-----------: _lReturn
===============================================================================================================================
*/
Static Function AOMS112VO(_cOper)
Local _lReturn := .T.

If !Empty(Alltrim(_cOper))
   Dbselectarea("ZB4")
   DbSetOrder(1)
   If Dbseek(xFilial("ZB4")+_cOper)
      _lReturn := .T.
   Else
      _lReturn := .F.
      u_itmsg("Operação não valida!")
   EndIf
EndIf

Return _lReturn


/*
===============================================================================================================================
Programa----------: AOMS112VT
Autor-------------: Igor Melgaço
Data da Criacao---: 27/08/2024
===============================================================================================================================
Descrição---------: Valida Tipo de Entrega
===============================================================================================================================
Parametros--------: _cTipo
===============================================================================================================================
Retorno-----------: _lReturn
===============================================================================================================================
*/
Static Function AOMS112VT(_cTipo)
Local aCat := U_TipoEntrega() 
Local aDados := {}
Local _lReturn := .T.
Local i := 0

If !Empty(Alltrim(_cTipo))
   For i := 1 To Len(aCat)
      AADD(aDados,StrToArray(aCat[i],"="))
   Next

   If Ascan(aDados,{|x| x[1] == RTrim(_cTipo) }) > 0
      _lReturn := .T.
   Else
      _lReturn := .F.

      u_itmsg("Tipo de Entrega não valido!")
   EndIf
EndIf

Return _lReturn


/*
===============================================================================================================================
Programa----------: AOMS112VF
Autor-------------: Igor Melgaço
Data da Criacao---: 27/08/2024
===============================================================================================================================
Descrição---------: Valida Filiais
===============================================================================================================================
Parametros--------: _cTipo
===============================================================================================================================
Retorno-----------: _lReturn
===============================================================================================================================
*/
Static Function AOMS112VF(cFilcrg,cNomeCrg,oNomeCrg,cFilfat,cNomeFat,oNomeFat)
	Local lRet := .T.
	
   IF !EMPTY(cfilcrg)
      
		cNomeCrg := GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+LEFT(cfilcrg,2),1,"")
		IF EMPTY(cNomeCrg)
			U_ITMSG("Filial de carregamento nao cadastrada",'Atenção',,1)
			RETURN .F.
		ENDIF
   Else
      cNomeCarg := ""
	Endif

	If !EMPTY(cfilfat)

		cNomeFat := GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+LEFT(cfilfat,2),1,"")
		IF EMPTY(cNomeFat)
			U_ITMSG("Filial de faturamento nao cadastrada",'Atenção',,1)
			RETURN .F.
		ENDIF

		_cFilSalva:= cFilAnt
		cFilAnt   := LEFT(ALLTRIM(cfilfat),2)
		If ALLTRIM(U_ITGETMV( "IT_FATNF" , "N")) == "N"
			U_ITMSG("Filial "+Alltrim(cfilfat)+" - " +Alltrim(cNomeFat)+" nao é troca nota de Faturamento (IT_FATNF)",'Atenção',,1)
			cFilAnt  := _cFilSalva
			RETURN .F.
		ENDIF

		If !empty(cfilcrg)
			cFilAnt:=LEFT(cfilcrg,2)
			If ALLTRIM(U_ITGETMV( "IT_PRONF" , "N")) == "N"
				U_ITMSG("Filial "+Alltrim(cfilcrg)+" - " +Alltrim(cNomeCrg)+" nao é troca nota de Carregamento (IT_PRONF)",'Atenção',,1)
				cFilAnt  := _cFilSalva
				RETURN .F.
			ENDIF
		Endif

		cFilAnt  := _cFilSalva

		IF lRet .and. !empty(cfilcrg)                            //Fil Carregamento, Fil Faturamento
			lRet := U_AOM112Val( 'VAL_GRUPO' , left(cfilcrg,2) , left(cfilfat,2) )
		ENDIF

   Else
      cNomeFat := ""
	ENDIF

   oNomeCrg:cText := cNomeCrg
   oNomeFat:cText := cNomeFat
   oNomeCrg:Refresh()
   oNomeFat:Refresh()

Return lRet

/*
===============================================================================================================================
Programa----------: AOMS112VM
Autor-------------: Igor Melgaço
Data da Criacao---: 29/08/2024
===============================================================================================================================
Descrição---------: Valida se há seleção no Markbrwose
===============================================================================================================================
Parametros--------: _cTipo
===============================================================================================================================
Retorno-----------: _lReturn
===============================================================================================================================
*/
Static Function AOMS112VM()
 Local _ni := 0 
 Local lRet := .F.
 
 For _ni := 1 to Len(aarr)
    If aarr[_ni,1] == cMarca
       lRet := .T.
       Exit
    Endif
 Next
 
 If !lRet
    u_itmsg("Não há registros marcados.",'Atenção!',"Selecione no minimo um pedido.",1)
 EndIf

Return lRet
