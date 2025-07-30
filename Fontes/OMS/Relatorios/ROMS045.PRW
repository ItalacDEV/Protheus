 /*
==================================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
==================================================================================================================================
       Autor      |    Data    |                                             Motivo  
--------------------------------------------------------------------------------------------------------------------------------- 
Alex Wallauer     | 06/02/2019 | Troca de Site para geração de codigo de barra - Chamado 27971
Alex Wallauer     | 10/04/2019 | Acerto do calculo do peso liquido - Chamado 28897
Lucas Borges      | 28/08/2024 | Incluída proteção na classe evitando error.log - Chamado 48315
=============================================================================================================================== 
Analista     - Programador  - Inicio   - Envio    - Chamado - Motivo da Alteração
===============================================================================================================================
Alex         - Igor Melgaço - 02/05/25 - 06/05/25 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
===============================================================================================================================
*/
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*
===============================================================================================================================
Programa----------: ROMS045
Autor-------------: Josué Danich Prestes
Data da Criacao---: 24/11/2016
===============================================================================================================================
Descrição---------: Emissão de etiquetas de pallets
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function ROMS045()

Private oPrint
Private cproduto := space(15)
Private nquant := 0
Private dprod := date()
Private dvalid := date() + 240
Private clote := space(4)
Private npeso := 0
Private csequen := space(7)

//_cPallet:= ZFW->ZFW_PALLET
cproduto:= ZFW->ZFW_PRODUT
nquant  := ZFW->ZFW_QUANT
npeso   := ZFW->ZFW_PESO
clote   := ZFW->ZFW_LOTE
dprod   := ZFW->ZFW_DPROD
dvalid  := ZFW->ZFW_DVALID
  
roms045E() //Imprime Etiqueta de pallet

Return 

/*
===============================================================================================================================
Programa----------: roms045E
Autor-------------: Josué Danich Prestes
Data da Criacao---: 24/11/2016
===============================================================================================================================
Descrição---------: Impressão de etiquetas de pallets
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function roms045E()

LOCAL _ni
Private nlinha := 40
Private ncoluna := 20
Private ntamh := 1120
Private ntamv := 1680
Private nTrPl := 0

//                       Fonte      Tamanho  Negrito
oFont10  := TFont():New("Arial", 9, 10, .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont10n := TFont():New("Arial", 9, 10, .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont12n := TFont():New("Arial", 9, 12, .T., .T., 5,,, .T., .F.,,,,,, oPrint)

//Localiza produto selecionado
posicione("SB1",1,xfilial("SB1")+cproduto,"B1_COD")

If len(alltrim(SB1->B1_I_DUN14)) < 10
	U_ITMSG("Produto sem código DUN14 válido","Atenção","Preencha o campo "+AVSX3("B1_I_DUN14",5)+" no cadastro do produto: "+cproduto,3)
	Return
Endif

If !Pergunte("ROMS045",.T.)
     return
Endif

nTrPl := MV_PAR01

PRIVATE _lSite:=.F.//U_ITMSG("Origem do Codigo de Barra do Site ? ",'Atenção!',,3,2,2)

IF _lSite
   ntamv    :=1680
   ntamh    :=1120
   nAltura  :=0480 
   ncoluna  :=20
   nTamFonte:=00
   nlinhaIni:=40
   nLinhAux1:=00
   nLinhAux2:=00
   nColuAux1:=500
   _nEsqu1  :=010
   _nEsqu2  :=nAltura + 10

   oPrint := TAVPrinter():New("Etiquetas p/ pallets")                     
   oPrint :SetPortrait()                  // Fixa a Impressao em Retrato
   oPrint :Setup()

ELSE

   ntamv    :=1550//ALTURA DAS LINHA LATERAIS 
   ntamh    :=1140//LARGURA DA ETIQUETA
   nAltura  :=0480 
   ncoluna  :=15
   nTamFonte:=04
   nlinhaIni:=35
   nLinhAux1:=35
   nLinhAux2:=15
   nColuAux1:=100
   _nEsqu1  :=010
   _nEsqu2  :=nAltura + 10

   cLocal:= GetTempPath() 

   cFileName:="ROM045_"
   cFileName+=DToS( DATE() ) + "_"
   cFileName+=StrTran(TIME(), ":" , "" )
   cFileName:=cFileName+".pdf"

   oPrint:= FwMsPrinter():New(cFileName, IMP_PDF , .T., cLocal , .T.)//, .T., NIL, NIL, NIL, NIL, NIL, .F., NIL)
   oPrint:SetPortrait()                  // Fixa a Impressao em Retrato
	oPrint:Setup()

	IF UPPER(oPrint:cPathPDF) == "C:\" .OR. EMPTY(oPrint:cPathPDF)
	   oPrint:cPathPDF := cLocal
	ENDIF
	
	IF oPrint:nModalResult = 2//APERTOU O CANCELA
	   RETURN .F.
	ENDIF
ENDIF   

oFont10  := TFont():New("Arial", 9, (10+nTamFonte  ), .T., .F., 5,,, .T., .F.,,,,,, oPrint)
oFont10n := TFont():New("Arial", 9, (10+nTamFonte  ), .T., .T., 5,,, .T., .F.,,,,,, oPrint)
oFont12n := TFont():New("Arial", 9, (12+nTamFonte+1), .T., .T., 5,,, .T., .F.,,,,,, oPrint)//TITULO

nlinha := nlinhaIni

oPrint:StartPage()              // Inicializa a Pagina de Impressao
oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)//LINHA INICIAL

nLinha += 010

oPrint:Say(nLinha+nLinhAux1, nColuna + 180,"Goiasminas Indústria de Laticínios Ltda.", oFont12n)

nLinha += 060
oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)

oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Conteúdo", oFont10n)//200
oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, "Peso Líquido", oFont10n) //610
oPrint:Line(nlinha , ncoluna + nAltura, nlinha + 110,  ncoluna + nAltura) 

nLinha += 060 - nLinhAux2

nsoma := 0

cprebar := "9" + SUBSTR(alltrim(SB1->B1_I_DUN14),2,(len(alltrim(SB1->B1_I_DUN14))-2))

For _ni := 1 to len(cprebar)
   If int(_ni/2) == _ni/2
      nsoma +=  val(substr(cprebar,_ni,1))
   Else
      nsoma += 3 * val(substr(cprebar,_ni,1))
  Endif
Next	

nprox := nsoma

Do while int(nprox/10) != nprox/10
	nprox++
Enddo

cdigito := alltrim(str(nprox-nsoma))
cgtin := cprebar + cdigito

IF SB1->B1_UM = "KG"
   nPesoLiq:=npeso-(ZFW->ZFW_TREMB+ZFW->ZFW_TRCAX)
ELSE
   nPesoLiq:=npeso
ENDIF

oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, cgtin, oFont10)//150
oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, transform(nPesoLiq,"@E 9,999,999.99") + " kg.", oFont10)// - (aret[3])//750

nLinha += 050
oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
nLinha += 010

oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Data de Validade", oFont10n)//70
oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, "Quantidade", oFont10n)//610
oPrint:Line(nlinha - 10  , ncoluna + nAltura, nlinha + 110,  ncoluna + nAltura) 

nLinha += 060 - nLinhAux2

oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, dtoc(dvalid), oFont10)//210
oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, TRANSFORM(round(nquant,2),"@E 9,999,999"), oFont10)//710

nLinha += 050
oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
nLinha += 010

oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Lote", oFont10n)//170
oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, "Data de Prod", oFont10n)//710
oPrint:Line(nlinha - 10 , ncoluna + nAltura, nlinha + 110,  ncoluna + nAltura) 

nLinha += 060 - nLinhAux2

oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, clote, oFont10)//210
oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, dtoc(dprod), oFont10)//750

nLinha += 050
oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)
nLinha += 010

oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "Peso Bruto", oFont10n)//120
oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, "Produto", oFont10n)//710
//oPrint:Line(nlinha - 10 , ncoluna + nAltura, nlinha + 110,  ncoluna + nAltura) 

nLinha += 060 - nLinhAux2

oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, transform(round((npeso+nTrPl),2),"@E 9,999,999.99") + " kg.", oFont10)//110
oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu2, substr(alltrim(SB1->B1_DESC),1,30), oFont10)//510


nLinha += 050

oPrint:Line(nlinha - 110 , ncoluna + nAltura, nlinha,  ncoluna + nAltura)//LINHA DO MEIO FINAL

oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)                   // IMPRIME UM TRACO
nLinha += 010

oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "No. Registro Processador", oFont10n)//350

nLinha += 060 - nLinhAux2

oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "0763763", oFont10)//370

nLinha += 050
oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)                    // Imprime um Traco
nLinha += 010

oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "SSCC - Código de Série da Unidade Logística", oFont10n)//220

nLinha += 060 - nLinhAux2

//Monta pré string do SSCC para calcular dígito verificador - http://www.gs1.org/how-calculate-check-digit-manually

csequen  := ZFW->ZFW_SEQUEN
  
cprebar := "0" + "789808064" + csequen

nsoma := 0

For _ni := 1 to len(cprebar)
   If int(_ni/2) == _ni/2
      nsoma +=  val(substr(cprebar,_ni,1))
   Else
      nsoma += 3 * val(substr(cprebar,_ni,1))
   Endif
Next _ni

nprox := nsoma

Do while int(nprox/10) != nprox/10
	nprox++
Enddo

cdigito := alltrim(str(nprox-nsoma))

oPrint:Say(nLinha+nLinhAux1, nColuna + _nEsqu1, "0" + "789808064" + csequen + cdigito, oFont10)// 350

nLinha += 040
oPrint:Line(nlinha,ncoluna - 5,nlinha,ncoluna + ntamh)                    // Imprime um Traco

oPrint:Say(nLinha+nLinhAux1, nColuna + 10, "Tara Embalagem:", oFont10n)
oPrint:Say(nLinha+nLinhAux1, nColuna + 350, transform(ZFW->ZFW_TREMB,"@E 9,999.999") + " kg", oFont10)//aret[2]
nLinha += 050

oPrint:Say(nLinha+nLinhAux1, nColuna + 10, "Tara Caixa:", oFont10n)
oPrint:Say(nLinha+nLinhAux1, nColuna + 350, transform(ZFW->ZFW_TRCAX,"@E 9,999.999") + " kg", oFont10)//aret[1]
nLinha += 050

oPrint:Say(nLinha+nLinhAux1, nColuna + 10, "Tara Pallet:", oFont10n)
oPrint:Say(nLinha+nLinhAux1, nColuna + 350, transform(nTrPl,"@E 9,999.999") + " kg", oFont10)
nLinha += 050

oPrint:Say(nLinha+nLinhAux1, nColuna + 10, "Tara Total:", oFont10n)
oPrint:Say(nLinha+nLinhAux1, nColuna + 350, transform((ZFW->ZFW_TREMB+ZFW->ZFW_TRCAX+nTrPl),"@E 9,999.999") + " kg", oFont10)//aret[2] + aret[1]
nLinha += 050

ccodbar1 := "(02)" + cgtin + "(3102)" + strzero(round((nPesoLiq)*100,0),6) // - aret[3]

ccodbar1 += "(3302)" +  strzero(round((npeso+nTrPl)*100,0),6) + "(37)" + ALLTRIM(str(round(nquant,0))) 

ccodbar2 := "(15)" + substr(dtos(dvalid),3,2) +  substr(dtos(dvalid),5,2) + substr(dtos(dvalid),7,2) 
//    					ano                        mes                           dia          

ccodbar2 += "(11)" +  substr(dtos(dprod),3,2) +  substr(dtos(dprod),5,2) + substr(dtos(dprod),7,2) 
//						ano                        mes                           dia   

ccodbar2 += "(7030)" + "0763763"// + "(10)" + ALLTRIM(clote)
//                      Reg SIF

cCodBar2Say:=ccodbar2
ccodbar2:=STRTRAN(ccodbar2,"(","")
ccodbar2:=STRTRAN(ccodbar2,")","")
ccodbar2 += "(10)" + ALLTRIM(clote)
cCodBar2Say+= "(10)" + ALLTRIM(clote)

ccodbar3 := "(00)0" + "789808064" + csequen + cdigito
//                       Registro GS1 

IF _lSite
   _cExt     := ".gif"
   _EndHttp1 := "https://barcode.tec-it.com/barcode.ashx?data="
   _EndHttp2 := "&code=EANUCC128&multiplebarcodes=true&translate-esc=true&unit=Fit&dpi=96&imagetype=Gif&rotation=0&color=%23000000&bgcolor=%23ffffff&qunit=Mm&quiet=0"
   _cCaminho := cLocal

   url := _EndHttp1 + ccodbar1 + _EndHttp2
   Html  := HttpGet( Url )
  	IF Html <> nil
	   MemoWrite( _cCaminho + ccodbar1 + _cExt, Html )
	ENDIF   
	oPrint:SayBitmap( nlinha - 05 ,ncoluna+40,_cCaminho + ccodbar1 + _cExt,1050,170 )
ELSE
	cCodBar1Say:=ccodbar1
	ccodbar1:=STRTRAN(ccodbar1,"(","")
	ccodbar1:=STRTRAN(ccodbar1,")","")
	cCodBar3Say:=ccodbar3
	ccodbar3:=STRTRAN(ccodbar3,"(","")
	ccodbar3:=STRTRAN(ccodbar3,")","")
	_cTypeBar:="EAN128"//"CODE128"
ENDIF
   
nLinha += 180

IF _lSite
	url := _EndHttp1 + ccodbar2 + _EndHttp2
	Html  := HttpGet( Url )
  	IF Html <> nil
	   MemoWrite( _cCaminho + ccodbar2 + _cExt, Html )
	ENDIF   
	oPrint:SayBitmap( nlinha + 55 ,ncoluna+40,_cCaminho + ccodbar2 + _cExt,1050,170 )
ELSE
   oPrint:Say(nLinha-20, nColuna + 100, cCodBar1Say, oFont10)
ENDIF

nLinha += 245

IF _lSite
	url := _EndHttp1 + ccodbar3 + _EndHttp2
	Html  := HttpGet( Url )
  	IF Html <> nil
	   MemoWrite( _cCaminho + ccodbar3 + _cExt, Html )
	ENDIF   
	oPrint:SayBitmap( nlinha + 55 ,ncoluna+40,_cCaminho + ccodbar3 + _cExt,600,170 )
  	SLEEP(5000)
ELSE
	oPrint:Say(nLinha-050, nColuna + 100, cCodBar2Say, oFont10)
	oPrint:FWMSBAR(_cTypeBar,21,0.4,ccodbar1,oPrint,.T.,,.T.,0.0168,0.7,.F.,"Arial","C",.F.,1,1,.F.)
	oPrint:FWMSBAR(_cTypeBar,26,0.5,ccodbar2,oPrint,.T.,,.T.,0.0168,0.7,.F.,"Arial","C",.F.,1,1,.F.)
	oPrint:FWMSBAR(_cTypeBar,31,0.5,ccodbar3,oPrint,.T.,,.T.,0.0168,0.7,.F.,"Arial","C",.F.,1,1,.F.)
ENDIF

nLinha += 245

IF _lSite
	nLinha += 60
ELSE
	oPrint:Say(nLinha-070, nColuna + 100, cCodBar3Say, oFont10)
	nLinha += 20
ENDIF

oPrint:Line(nlinhaIni,ncoluna - 5     , nlinha, ncoluna - 5     )//LINHA LATERAL ESQUERDA
oPrint:Line(nlinhaIni,ncoluna + ntamh , nlinha, ncoluna + ntamh )//LINHA LATERAL DIRETA
oPrint:Line(nlinha   ,ncoluna - 5     , nlinha ,ncoluna + ntamh )//LINHA FINAL

IF _lSite
    LjMsgRun( "Gerando a visualização..." , "Aguarde!" , {|| oPrint:Preview() } )//Visualiza antes de imprimir
	oPrint:End()
ELSE
   If !(oPrint:nModalResult == PD_OK)
	   oPrint:Deactivate() 
	   Return
   EndIf
    LjMsgRun( "Gerando a visualização..." , "Aguarde!" , {|| oPrint:Preview() } )//Visualiza antes de imprimir
ENDIF

Return
