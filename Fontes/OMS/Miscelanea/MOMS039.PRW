/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 10/01/2019 | Incluido update de SZW para pedidos importados - Chamado 27639
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 26/02/2019 | Ajuste de execução via schedule - Chamado 28236
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 05/04/2019 | Ajuste de data de cadastro na afa190 - Chamado 28792 
 -------------------------------------------------------------------------------------------------------------------------------
 Jonathan         | 02/10/2020 | Limpeza de viagens finalizadas por parâmetro de filiais - Chamado 34307 
 ------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 10/02/2021 | Correcao do error.log no console.log. Chamado 35598
===============================================================================================================================
*/

#Include 'Protheus.ch'
#Include "TopConn.ch"  

/*
===============================================================================================================================
Programa----------: MOMS039
Autor-------------: Josué Danich Prestes
Data da Criacao---: 20/09/2018
===============================================================================================================================
Descrição---------: Schedule de manutenção diária de tabelas - Chamado 26331 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User function MOMS039()

Local _ddtlimite := date()-u_itgetmv("ITARQMT",90)

If u_itmsg("Realiza manutenção diária de tabelas?","Atenção","Registros RDC anteriores à " + dtoc(_ddtlimite) + " serão apagados! - Pedidos do portal de represntante terão status atualizado - Viagens finalizadas serão limpas do painel RDC",3,2,2)

	fwmsgrun(,{|oproc| U_MOMS039T(.T.,oproc)},"Aguarde processamento...", "Aguarde processamento...")
	
Else

	u_itmsg("Processo cancelado!","Atenção",,1)

Endif


Return

/*
===============================================================================================================================
Programa----------: MOMS039T
Autor-------------: Josué Danich Prestes
Data da Criacao---: 20/09/2018
===============================================================================================================================
Descrição---------: Processamento de limpeza de tabelas de muro do RDC - Chamado 26331 
===============================================================================================================================
Parametros--------: _lshow - Processando com tela de usuário?
					oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS039T(_lshow,oproc)

Local _atabelas := {"ZFU","ZFH","ZFI","ZFJ","ZFK","ZFL","ZFN","ZFO","ZFP","ZFQ","ZFR","ZFV","ZG4","ZG0"}
Local _ni := 1
Local _ddtlimite := ""

Default _lshow := .F.
Default oproc := nil


If !_lshow

	//Monta ambiente
	u_itconout( 'Abrindo o ambiente...' )
   
	RPCSetType(3)
	RpcSetEnv( "01" , '01' ,,,"COM", "SCHEDULE_MANUT_TABELAS" , {'ZP1','SRA'} )
	Sleep( 5000 ) //Aguarda 5 segundos para subam as configurações do ambiente.
	
Endif

//========================================================================================
//Limpa registros antigos das tabelas de muro RDC
//========================================================================================

_ddtlimite := date()-u_itgetmv("ITARQMT",90)
u_itconout("Iniciando limpeza de tabelas de muro com datas anteriores à " + dtoc(_ddtlimite) + "...")

For _ni := 1 to len(_atabelas)

	If _lshow
	
		oproc:cCaption := ("Limpando dados anteriores à "  + dtoc(_ddtlimite) + " para a tabela " + _atabelas[_ni] + "...")
		ProcessMessages()
		
	Endif
	
	u_itconout("Limpando dados anteriores à "  + dtoc(_ddtlimite) + " para a tabela " + _atabelas[_ni] + "...")
	
	_cQry := " Delete from  " + _atabelas[_ni] + "010 where ("  + _atabelas[_ni] + "_SITUAC = 'P' OR "  + _atabelas[_ni] + "_SITUAC = 'E')
	_cQry += " AND " +  _atabelas[_ni] + "_DATA < '" + Dtos(_ddtlimite) + "'"
		
	_nres := TCSqlExec(_cQry)
	
	If _nres >= 0
	
		u_itconout("Limpeza bem sucedida de dados anteriores à "  + dtoc(_ddtlimite) + " para a tabela " + _atabelas[_ni] + "...")
		
	Else
	
		u_itconout("Falhou limpeza de dados anteriores à "  + dtoc(_ddtlimite) + " para a tabela " + _atabelas[_ni] + "...")
	
	Endif

Next

//==================================================================
//Realiza ajuste de status de tabela de portal do representante
//==================================================================
u_itconout("Realizando ajuste de status de pedidos do portal já importados...")

	If _lshow
	
		oproc:cCaption := ("Realizando ajuste de status de pedidos do portal já importados...")
		ProcessMessages()
		
	Endif

	
_cQry := "update " + retsqlname("SZW") + " set zw_status = 'I' where d_e_l_e_t_ <> '*' and zw_numped <> ' ' and zw_status = 'L'"
		
_nres := TCSqlExec(_cQry)
	
If _nres >= 0
	
	u_itconout("Ajuste bem sucedido de status de pedidos do portal já importados...")
		
Else
	
	u_itconout("Falhou ajuste de status de pedidos do portal já importados...")
	
Endif

//===================================================================================================================================
//Limpeza de viagens finalizadas dos painéis RDC
//===================================================================================================================================
_cFil := u_itgetmv("IT_FILLIMP")

_cquery :=  "     SELECT codfil, numero AS viagem "
_cquery +=  "     FROM rdcitl.afa037 a "
_cquery +=  "     WHERE    situac <> 5 "
_cquery +=  "              AND (dtcheg IS NULL OR dtrica IS NULL) "
_cquery +=  "              AND nrsoli IS NOT NULL "
_cquery +=  "              AND EXISTS "
_cquery +=  "                     (SELECT 'x' "
_cquery +=  "                        FROM rdcitl.afa190 b "
_cquery +=  "                       WHERE     b.codfil = a.codfil "
_cquery +=  "                             AND b.numero = a.numero "
_cquery +=  "                             AND b.libnfc = 'N' "
_cquery +=  "                             AND b.libcar = 'N' "
_cquery +=  "                             AND b.pageno IS NULL "
_cquery +=  "                             AND b.pagede IS NULL) "
_cquery +=  "              AND EXISTS "
_cquery +=  "                     (SELECT 'x' "
_cquery +=  "                        FROM dak010 dak "
_cquery +=  "                       WHERE     dak_filial = LPAD (codfil, 2, '0') "
_cquery +=  "                             AND dak_cod = LPAD (nrsoli, 6, '0') "
_cquery +=  "                             AND dak_feznf = '1' "
_cquery +=  "                             AND dak.d_e_l_e_t_ = ' ') "
_cquery +=  "     AND a.codfil IN " + STRTRAN(FormatIn(_cFil, ";"), "'","")
 
DBUseArea( .T. , "TOPCONN" , TCGenQry(,,_cQuery) , "TMP" , .F. , .T. )
	
TMP->( DBGoTop() )


Do while TMP->(!Eof())

	u_itconout("Limpando painéis para viagem - " + alltrim(strzero(TMP->CODFIL,2)) + " - " + alltrim(strzero(TMP->VIAGEM,6)))
	
	_cQry := "UPDATE rdcitl.tga300 SET status = 5, stctrl = 7 WHERE     filialviagem = " + alltrim(str(TMP->CODFIL)) + " AND nrviagem = " + alltrim(str(TMP->VIAGEM))
	
	_nres1 := TCSqlExec(_cQry)
	
	//Carrega dados da afa190 para montar data e hora de cadastro
	
	_cquery :=  "     SELECT datcad, hrcad "
	_cquery +=  "     FROM rdcitl.afa190  "
	_cquery +=  "     WHERE     codfil = " + alltrim(str(TMP->CODFIL)) + " AND numero = " + alltrim(str(TMP->VIAGEM))

	DBUseArea( .T. , "TOPCONN" , TCGenQry(,,_cQuery) , "TMP2" , .F. , .T. )
	
	If TMP2->(!Eof())

		TMP2->( DBGoTop() )

		_cdate := "'" + SUBSTR(DTOS(TMP2->DATCAD),1,4)+"/"+SUBSTR(DTOS(TMP2->DATCAD),5,2)+"/"+SUBSTR(DTOS(TMP2->DATCAD),7,2) + " " + tmp2->hrcad + ":00'"+", 'YYYY/MM/DD HH24:MI:SS'
	
		Dbselectarea("TMP2")
		TMP2->(Dbclosearea())

	Else

		u_itconout("Limpeza e painéis RDC para viagem - " + alltrim(strzero(TMP->CODFIL,2)) + " - " + alltrim(strzero(TMP->VIAGEM,6)) + " falhou..." )
		TMP->(Dbskip())
		Loop

	Endif

	_cqry := "UPDATE rdcitl.afa190 SET dtfira = TO_DATE("+ _cdate + "), datram = TO_DATE("+ _cdate + "), pageno = 999, pagede = 999, codloc = 1, codram = 1, libcar = 'S', libnfc = 'S' "
	_cQry += " WHERE     codfil = " + alltrim(str(TMP->CODFIL)) + " AND numero = " + alltrim(str(TMP->VIAGEM))

	_nres2 := TCSqlExec(_cQry)
		
	_cQry := "UPDATE rdcitl.afa037 SET dtcheg = datcad, hrcheg = hrcad, dtrica = datcad, hrrica = hrcad "
	_cQry += " WHERE     codfil = " + alltrim(str(TMP->CODFIL)) + " AND numero = " + alltrim(str(TMP->VIAGEM))
	
	_nres3 := TCSqlExec(_cQry)
	
	If _nres1 >= 0 .and. _nres2 >= 0 .and. _nres3 >= 0
	
		u_itconout("Limpeza e painéis RDC para viagem - " + alltrim(strzero(TMP->CODFIL,2)) + " - " + alltrim(strzero(TMP->VIAGEM,6)) + " bem sucedida..." )
		
	Else
	
		u_itconout("Limpeza e painéis RDC para viagem - " + alltrim(strzero(TMP->CODFIL,2)) + " - " + alltrim(strzero(TMP->VIAGEM,6)) + " falhou..." )
	
	Endif
		
	TMP->(Dbskip())
	
Enddo

Dbselectarea("TMP")
TMP->(Dbclosearea())

u_itmsg("Processo finalizado","Atenção",,2)

u_itconout("Processo de ajuste de tabelas de integração completado.")

Return

/*
===============================================================================================================================
Programa----------: MOMS039P
Autor-------------: Josué Danich Prestes
Data da Criacao---: 20/09/2018
===============================================================================================================================
Descrição---------: Chamada de processamento via schedule
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS039P()

U_MOMS039T(.F.,NIL)

Return
