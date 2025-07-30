#Include "RwMake.ch"
#Include "TopConn.ch"

/*
===============================================================================================================================
Programa----------: MTA455P
Autor-------------: Frederico O. C. Jr
Data da Criacao---: 11/08/2009
===============================================================================================================================
Descri��o---------: Ponto de Entrada para validar Liberacao Manual do Estoque
===============================================================================================================================
Uso---------------: Italac - Valida a permissao para liberacao manual do Estoque de Produto Acabado para Venda no modulo OMS
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: L�gico - Definindo se pode liberar
===============================================================================================================================
Usuario-----------: 
===============================================================================================================================
Setor-------------: OMS
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                              Motivo                       |        Usuario         |  Setor  |
-------------------------------------------------------------------------------------------------------------------------------
 Guilherme Diogo  | 27/11/2012 | Alterado PswSeek, pois na vers�o 11 � preciso posicionar  | 90-000285-GUILHERMED   |  TI-SP  |
                  |            | pelo ID ou nome do usu�rio para depois verificar a senha  |                        |         |
------------------:------------:-----------------------------------------------------------:------------------------:---------:
 Talita           | 17/07/2013 | Alterada a valida��o na libera��o do estoque para que seja| 92-000300-TALITAT      |  TI-SP  |
                  |            | feita pelo cadastro da Gest�o de Usu�rios. Chamado 3748   |                        |         |
------------------:------------:-----------------------------------------------------------:------------------------:---------:
 Alexandre Villar | 30/09/2014 | Atualiza��o da rotina retirando coment�rios e refer�ncias | 01-003485-ALEXANDREV   |  TI-CB  |
                  |            | ao par�metro que n�o est� mais em uso. Retirada tamb�m a  |                        |         |
                  |            | op��o para digita��o de senha, validando apenas a config. |                        |         |
                  |            | do usu�rio para o acesso. Chamado 7249                    |                        |         |
===============================================================================================================================
*/

User Function MTA455P()
    
Local _aArea 	:= GetArea()
Local _lRet		:= .F.
Local _cUsuLog	:= RetCodUsr()

//================================================================================
// Talita - 16/07/13 - Alterada a valida��o na libera��o do estoque para que era 
// feito pelo parametro IT_LIBEST e agora ser� feita na tela de gest�o de usuarios
// campo ZZL_LIBEST. Chamado:3748
//================================================================================
// Removida a configura��o de digita��o de senha para libera��o manual do estoque,
// ser� feita a valida��o apenas pelo controle de acesso da Gest�o de Usu�rios.
// Alexandre Villar - Chamado 7249
//================================================================================
DBSelectArea("ZZL")
ZZL->( DBSetOrder(3) )
If ZZL->( DBSeek( xFilial("ZZL") + _cUsuLog ) ) .And. ZZL->ZZL_LIBEST == 'S'

	_lRet := .T.

Else

	Aviso( 'Aten��o!' , 'O usu�rio atual n�o possui acesso para realizar a libera��o manual de Estoque! '									+;
						'Caso necess�rio, solicite ao usu�rio respons�vel por essa atividade para que realize a libera��o.'	, {'Fechar'} , 2 )

EndIf

RestArea( _aArea )

Return( _lRet )