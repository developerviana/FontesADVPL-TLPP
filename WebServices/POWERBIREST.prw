#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"  
#INCLUDE "totvs.CH"

/*Criado por Sangelles Moraes - Rei do Apsdu 01/01/2023 */

WSRESTFUL powerbi_rei_apsdu DESCRIPTION "REST Power Bi - v3"
 
 WSDATA page AS INTEGER OPTIONAL
 WSDATA pageSize AS INTEGER OPTIONAL
 
 WSMETHOD GET CT1 ;
 DESCRIPTION "TABELA CT1" ;
 WSSYNTAX "/powerbi_rei_apsdu/CT1" ;
 PATH "/CT1" PRODUCES APPLICATION_JSON

  WSMETHOD GET SA6 ;
 DESCRIPTION "TABELA SA6" ;
 WSSYNTAX "/powerbi_rei_apsdu/SA6" ;
 PATH "/SA6" PRODUCES APPLICATION_JSON

    

END WSRESTFUL


//-------------------------------------------------------------------
// CT1
//-----------------------------------------------------------------
WSMETHOD GET CT1 WSRECEIVE page, pageSize WSREST powerbi_rei_apsdu
 
 Local _aList       := {}
 Local _cJson       := ''
 ////Local cCodEmp		:= "01"
 //Local cCodFil		:= "0101"
 Local lRet         := .T.
 Local nCount       := 0
 Local nStart       := 1
 Local nReg         := 0
 Local nAux         := 0
 Local cPulaLinha   := chr(13)+chr(10)
 Local _oJson       := JsonObject():New() 
 
 Default self:page := 1
 Default self:pageSize := 10000 
 
 ////PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil

    conout("************CT1-Posicao 1************")

    If Select("QRYCT1") > 0
	    dbSelectArea( "QRYCT1" )
	    QRYCT1->(dbCloseArea())
    EndIf

    If "ORACLE" $ Upper(TcGetDb())

        cQry := "  SELECT
        cQry += " '01' AS M0_CODIGO , CT1_FILIAL    , CT1_CONTA     , CT1_DESC01 " + cPulaLinha
        cQry += "	, CT1_CTASUP   " + cPulaLinha      
        cQry += ", CASE " + cPulaLinha
        cQry += "        WHEN CT1_NORMAL = '1' THEN 'DEVEDORA' " + cPulaLinha
        cQry += "        WHEN CT1_NORMAL = '2' THEN 'CREDORA' " + cPulaLinha
        cQry += "    END CT1_NORMAL " + cPulaLinha
        cQry += "    , CASE  " + cPulaLinha
        cQry += "        WHEN CT1_NATCTA = '01' THEN 'ATIVO' " + cPulaLinha
        cQry += "        WHEN CT1_NATCTA = '02' THEN 'PASSIVO' " + cPulaLinha
        cQry += "        WHEN CT1_NATCTA = '03' THEN 'PATRIM NIO L QUIDO' " + cPulaLinha
        cQry += "        WHEN CT1_NATCTA = '04' THEN 'RESULTADO' " + cPulaLinha
        cQry += "        WHEN CT1_NATCTA = '05' THEN 'COMPENSA  O' " + cPulaLinha
        cQry += "        WHEN CT1_NATCTA = '99' THEN 'OUTROS' " + cPulaLinha
        cQry += "    END CT1_NATCTA " + cPulaLinha
        cQry += "FROM " + RetSqlName("CT1") + " CT1 " + cPulaLinha
        cQry += "WHERE CT1.D_E_L_E_T_ <> '*' " + cPulaLinha	


    else

        cQry := "  SELECT
        cQry += " '01' AS M0_CODIGO , CT1_FILIAL    , CT1_CONTA     , CT1_DESC01 " + cPulaLinha
        cQry += "	, CT1_CTASUP   " + cPulaLinha      
        cQry += ", CASE " + cPulaLinha
        cQry += "        WHEN CT1_NORMAL = '1' THEN 'DEVEDORA' " + cPulaLinha
        cQry += "        WHEN CT1_NORMAL = '2' THEN 'CREDORA' " + cPulaLinha
        cQry += "    END CT1_NORMAL " + cPulaLinha
        cQry += "    , CASE  " + cPulaLinha
        cQry += "        WHEN CT1_NATCTA = '01' THEN 'ATIVO' " + cPulaLinha
        cQry += "        WHEN CT1_NATCTA = '02' THEN 'PASSIVO' " + cPulaLinha
        cQry += "        WHEN CT1_NATCTA = '03' THEN 'PATRIM NIO L QUIDO' " + cPulaLinha
        cQry += "        WHEN CT1_NATCTA = '04' THEN 'RESULTADO' " + cPulaLinha
        cQry += "        WHEN CT1_NATCTA = '05' THEN 'COMPENSA  O' " + cPulaLinha
        cQry += "        WHEN CT1_NATCTA = '99' THEN 'OUTROS' " + cPulaLinha
        cQry += "    END CT1_NATCTA " + cPulaLinha
        cQry += "FROM " + RetSqlName("CT1") + " CT1 " + cPulaLinha
        cQry += "WHERE CT1.D_E_L_E_T_ <> '*' " + cPulaLinha	

    end 
    Conout(cQry)
	
	TcQuery cQry New Alias "QRYCT1" // Cria uma nova area com o resultado do query   

	if QRYCT1->(!Eof()) 

        COUNT TO nRecord
        Conout("Total de Registros na Query: "+cValToChar(nRecord), "Aten  o")
        
        If self:page > 1
            nStart := ( ( self:page - 1 ) * self:pageSize ) + 1
            nReg := nRecord - nStart + 1
        Else
            nReg := nRecord
        EndIf
 
        QRYCT1->( DBGoTop() )
    EndIf
 
    While QRYCT1->( ! Eof() ) 
 
        nCount++
        If nCount >= nStart
            nAux++ 
            aAdd( _aList , JsonObject():New() )

            //conout("************Posicao 2************")
            _aList[nAux]['M0_CODIGO']    := QRYCT1->M0_CODIGO
			_aList[nAux]['CT1_FILIAL']   := QRYCT1->CT1_FILIAL
			_aList[nAux]['CT1_CONTA']    := QRYCT1->CT1_CONTA
			_aList[nAux]['CT1_DESC01']   := QRYCT1->CT1_DESC01
			_aList[nAux]['CT1_CTASUP']   := QRYCT1->CT1_CTASUP
			_aList[nAux]['CT1_NORMAL']   := QRYCT1->CT1_NORMAL
			_aList[nAux]['CT1_NATCTA']   := QRYCT1->CT1_NATCTA

            conout("************CT1-Posicao 3************") 
            If Len(_aList) >= self:pageSize
                Exit
            EndIf
        
        EndIf 
        QRYCT1->( DBSkip() )
    End
    QRYCT1->( DBCloseArea() )
    
    conout("************CT1-Posicao 4************")
    IF LEN(_aList) > 0 
        _oJson['CT1'] := _aList
    ENDIF
    _cJson:= FwJsonSerialize( _oJson )
    
    FreeObj(_oJson)
    conout("************CT1-Posicao 5************")
    
    Self:SetResponse( _cJson ) //-- Seta resposta

Return( lRet )

//-------------------------------------------------------------------
// SA6
//-----------------------------------------------------------------
WSMETHOD GET SA6 WSRECEIVE page, pageSize WSREST powerbi_rei_apsdu
 
 Local _aList       := {}
 Local _cJson       := ''
 //Local cCodEmp		:= "01"
// Local cCodFil		:= "0101"
 Local lRet         := .T.
 Local nCount       := 0
 Local nStart       := 1
 Local nReg         := 0
 Local nAux         := 0
 Local cPulaLinha   := chr(13)+chr(10)
 Local _oJson       := JsonObject():New() 
 
 Default self:page := 1
 Default self:pageSize := 10000 
 
 //PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil

    conout("************SA6-Posicao 1************")

    If Select("QRYSA6") > 0
	    dbSelectArea( "QRYSA6" )
	    QRYSA6->(dbCloseArea())
    EndIf
    
    If "ORACLE" $ Upper(TcGetDb())

        cQry := "  SELECT  '01' AS M0_CODIGO" + cPulaLinha   
        cQry += "         , A6_FILIAL" + cPulaLinha      
        cQry += "             , A6_COD" + cPulaLinha 
        cQry += "             , A6_AGENCIA" + cPulaLinha
        cQry += "             , A6_NUMCON" + cPulaLinha   
        cQry += "             , A6_NOME " + cPulaLinha
        cQry += "             , A6_NREDUZ " + cPulaLinha       
        cQry += "             , CASE WHEN A6_BLOCKED = '1' THEN 'SIM' ELSE 'NAO' END Bloqueada " + cPulaLinha
        cQry += "             , A6_CONTA " + cPulaLinha
        cQry += "             , CASE A6_FLUXCAI WHEN 'N' THEN 'NAO' ELSE 'SIM' END Fluxo_Cx " + cPulaLinha
        cQry += "         	, LTRIM(RTRIM( ( CT1_DESC01) ) Descricao " + cPulaLinha
        cQry += "         	, LTRIM (RTRIM( ( CT1_CONTA )) || ' - ' || LTRIM(RTRIM( ( CT1_DESC01 ) )) Conta_ctb " + cPulaLinha
        cQry += "         FROM " + RetSqlName("SA6") + " SA6 " + cPulaLinha
        cQry += "         LEFT JOIN " + RetSqlName("CT1") + " CT1 " + cPulaLinha
        cQry += "         	ON  CT1.D_E_L_E_T_	= ' ' " + cPulaLinha
        cQry += "         	AND CT1_CONTA		= A6_CONTA " + cPulaLinha
        cQry += "         WHERE SA6.D_E_L_E_T_  = ' ' " + cPulaLinha

    else
        
        cQry := "  SELECT  '01' AS M0_CODIGO" + cPulaLinha   
        cQry += "         , A6_FILIAL" + cPulaLinha      
        cQry += "             , A6_COD" + cPulaLinha 
        cQry += "             , A6_AGENCIA" + cPulaLinha
        cQry += "             , A6_NUMCON" + cPulaLinha   
        cQry += "             , A6_NOME " + cPulaLinha
        cQry += "             , A6_NREDUZ " + cPulaLinha       
        cQry += "             , CASE WHEN A6_BLOCKED = '1' THEN 'SIM' ELSE 'NAO' END Bloqueada " + cPulaLinha
        cQry += "             , A6_CONTA " + cPulaLinha
        cQry += "             , CASE A6_FLUXCAI WHEN 'N' THEN 'NAO' ELSE 'SIM' END Fluxo_Cx " + cPulaLinha
        cQry += "         	, TRIM ( CT1_DESC01) 'Descricao' " + cPulaLinha
        cQry += "         	, TRIM ( CT1_CONTA ) + ' - ' + TRIM ( CT1_DESC01 ) 'Conta_ctb' " + cPulaLinha
        cQry += "         FROM " + RetSqlName("SA6") + " SA6 " + cPulaLinha
        cQry += "         LEFT JOIN " + RetSqlName("CT1") + " CT1 " + cPulaLinha
        cQry += "         	ON  CT1.D_E_L_E_T_	= ' ' " + cPulaLinha
        cQry += "         	AND CT1_CONTA		= A6_CONTA " + cPulaLinha
        cQry += "         WHERE SA6.D_E_L_E_T_  = ' ' " + cPulaLinha

    end 
    Conout(cQry)
	
	TcQuery cQry New Alias "QRYSA6" // Cria uma nova area com o resultado do query   

	if QRYSA6->(!Eof()) 

        COUNT TO nRecord
        Conout("Total de Registros na Query: "+cValToChar(nRecord), "Aten  o")
        
        If self:page > 1
            nStart := ( ( self:page - 1 ) * self:pageSize ) + 1
            nReg := nRecord - nStart + 1
        Else
            nReg := nRecord
        EndIf
 
        QRYSA6->( DBGoTop() )
    EndIf
 
    While QRYSA6->( ! Eof() ) 
 
        nCount++
        If nCount >= nStart
            nAux++ 
            aAdd( _aList , JsonObject():New() )

            //conout("************Posicao 2************")
            _aList[nAux]['M0_CODIGO']         := QRYSA6->M0_CODIGO
			_aList[nAux]['A6_FILIAL']         := QRYSA6->A6_FILIAL
			_aList[nAux]['A6_COD']            := QRYSA6->A6_COD
			_aList[nAux]['A6_AGENCIA']        := QRYSA6->A6_AGENCIA
			_aList[nAux]['A6_NUMCON']         := QRYSA6->A6_NUMCON
			_aList[nAux]['A6_NOME']           := QRYSA6->A6_NOME
			_aList[nAux]['A6_NREDUZ']         := QRYSA6->A6_NREDUZ
            _aList[nAux]['Bloqueada']         := QRYSA6->Bloqueada
            _aList[nAux]['A6_CONTA']          := QRYSA6->A6_CONTA
            _aList[nAux]['Fluxo_Cx']       := QRYSA6->Fluxo_Cx
            _aList[nAux]['Desc']   := QRYSA6->Desc
            _aList[nAux]['Conta_ctb']   := QRYSA6->Conta_ctb

            conout("************SA6-Posicao 3************") 
            If Len(_aList) >= self:pageSize
                Exit
            EndIf
        
        EndIf 
        QRYSA6->( DBSkip() )
    End
    QRYSA6->( DBCloseArea() )
    
    conout("************SA6-Posicao 4************")
    IF LEN(_aList) > 0 
        _oJson['SA6'] := _aList
    ENDIF
    _cJson:= FwJsonSerialize( _oJson )
    
    FreeObj(_oJson)
    conout("************SA6-Posicao 5************")
    
    Self:SetResponse( _cJson ) //-- Seta resposta

Return( lRet )
