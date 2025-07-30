/* 
===============================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor    |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich   | 24/08/2018 | Chamado 25998. Incluido desvio para não executar na transferência de funcionário.
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melgaço   | 19/10/2023 | Chamado 44951. Chamadas para Integração Dimep e Control ID.
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer  | 10/11/2023 | Chamado 45527. Fernando. Gravação do campo RD0_PORTAL com "000001" na inclusão do funcionario.
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer  | 23/01/2024 | Chamado 46153. Fernando. Gravação do campo RD0_FVIAJ com "2" na inclusão do funcionario.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "RwMake.ch"      
#Include "Protheus.ch"   
#Include "TopConn.ch"

/*
===============================================================================================================================
Programa----------: GP010AGRV
Autor-------------: Josué Danich Prestes
Data da Criacao---: 21/08/2018
===============================================================================================================================
Descrição---------: Ponto de Entrada após gravação da SRA - Chamado 25620
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function GP010AGRV()
/*
//Se for exclusão e for filial que integra com o Suricato inicia a exclusão de dados vinculados no Suricato
If !isincallstack("GPEA180") .AND. Exclui .and. SRA->RA_FILIAL $ u_itgetmv("IT_FILSUR","01;10")

	//Identifica idcolab pela filial e matricula
	_cQry := "select idcolab,situafas,dataafas,horaafas,numepis from SURICATO.tbcolab WHERE  "
	_cQry += " codimatr = " + alltrim(STR(val(SRA->RA_MAT))) + " AND CODIEMPR = " + ALLTRIM(STR(VAL(SRA->RA_FILIAL)))

	If select ("TRBCOL") > 0

		dbselectarea("TRBCOL")
		TRBCOL->(Dbclosearea())
	
	Endif

	dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBCOL" , .T., .F. )
	dbSelectArea("TRBCOL")

	//Se existir idcolab faz exclusões
	If !TRBCOL->(Eof())

		//Excluir da tabela tbacesscolab
		_cQry := " DELETE FROM  SURICATO.tbacesscolab "						
		_cQry += " WHERE idcolab =  " + ALLTRIM(STR(TRBCOL->IDCOLAB)) 
		_nres := TCSqlExec(_cQry)
	
		//Excluir da tabela tbhistocrach
		_cQry := " DELETE FROM  SURICATO.tbhistocrach "						
		_cQry += " WHERE idcolab =  " + ALLTRIM(STR(TRBCOL->IDCOLAB)) 
		_nres := TCSqlExec(_cQry)
		
		//Excluir da tabela tbafast
		_cQry := " DELETE FROM  SURICATO.tbafast "						
		_cQry += " WHERE idcolab =  " + ALLTRIM(STR(TRBCOL->IDCOLAB)) 
		_nres := TCSqlExec(_cQry)
	
		//Excluir da tabela tbcolab
		_cQry := " DELETE FROM  SURICATO.tbcolab "						
		_cQry += " WHERE idcolab =  " + ALLTRIM(STR(TRBCOL->IDCOLAB)) 
		_nres := TCSqlExec(_cQry)

	Endif

	
Endif
*/
If !isincallstack("GPEA180") 
   IF Inclui
      RD0->(DBSETORDER(6))
      IF RD0->(DBSEEK(xFilial()+SRA->RA_CIC))
	     RD0->(RECLOCK( "RD0", .F. ))
		 RD0->RD0_PORTAL:="000001"
		 RD0->RD0_FVIAJ :="2"
		 RD0->(MSUNLOCK())
	     //U_ITMSG("CPF / CNPJ [ "+xFilial("RD0")+SRA->RA_CIC+" ] cadastrado na tabela Pessoas / Participantes ( RD0 ).",'Informação!',,2)
	  ELSE
	      U_ITMSG("CPF / CNPJ [ "+SRA->RA_CIC+" ] não cadastrado na tabela Pessoas / Participantes ( RD0 ).",'Informação!',"Cadastre manualmente.",3)// [ "+M->RA_CIC+" ]
	  ENDIF 
      RD0->(DBSETORDER(1))
   ENDIF
	//Integração COONTROLID
	U_MGPE026(Iif(Exclui,3,Iif(Inclui,1,2)))

	//Integração DIMEP
	U_MPON002(4)
Endif

Return
