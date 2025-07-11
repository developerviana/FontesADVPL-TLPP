#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#INCLUDE "TOTVS.CH"


WSRESTFUL Cont_Dre DESCRIPTION "Consulta Cont_Dre"
    WsData TOKEN As Character
    WsMethod GET getDre Description "Consulta todos os dados da Cont_Dre" Path "/leverpro/cont_dre" WsSyntax "/leverpro/cont_dre"
END WSRESTFUL

WSMETHOD GET getDre WSSERVICE Cont_Dre

    Local cQuery   := ""
    Local oQry     := FWQuery():New(cQuery)
    Local aFields  := {}
    Local oJson    := JsonArray():New()
    Local oRow     := Nil
    Local nI       := 0

    cQuery := "SELECT "
    cQuery += " '55' ID_MAP, "
    cQuery += " '3' ID_SOURCE, "
    cQuery += " codcli CODE, "
    cQuery += " forn_cli DESCRIPTION, "
    cQuery += " value, "
    cQuery += " '1' COMPANY, "
    cQuery += " filial FILIAL, "
    cQuery += " num_documento DOCUMENTO, "
    cQuery += " data_vencimento DT_VENCIMENTO, "
    cQuery += " AGING_DIAS "
    cQuery += "FROM ( "
    cQuery += " SELECT "
    cQuery += "   CF.A2_COD codcli, "
    cQuery += "   P.E2_FILIAL filial, "
    cQuery += "   CF.A2_NOME forn_cli, "
    cQuery += "   P.E2_NUM num_documento, "
    cQuery += "   P.E2_VENCTO data_vencimento, "
    cQuery += "   CAST((P.E2_SALDO) AS decimal(12,2)) value, "
    cQuery += "   CASE "
    cQuery += "     WHEN DATEDIFF(DAY,CAST(SUBSTRING(P.E2_VENCTO,1,4)+'/'+SUBSTRING(P.E2_VENCTO,5,2)+'/'+SUBSTRING(P.E2_VENCTO,7,2) AS date),CURRENT_TIMESTAMP) <= -1 AND "
    cQuery += "          DATEDIFF(DAY,CAST(SUBSTRING(P.E2_VENCTO,1,4)+'/'+SUBSTRING(P.E2_VENCTO,5,2)+'/'+SUBSTRING(P.E2_VENCTO,7,2) AS date),CURRENT_TIMESTAMP) >= -30 THEN 8 "
    cQuery += "     WHEN DATEDIFF(DAY,CAST(SUBSTRING(P.E2_VENCTO,1,4)+'/'+SUBSTRING(P.E2_VENCTO,5,2)+'/'+SUBSTRING(P.E2_VENCTO,7,2) AS date),CURRENT_TIMESTAMP) < -30 AND "
    cQuery += "          DATEDIFF(DAY,CAST(SUBSTRING(P.E2_VENCTO,1,4)+'/'+SUBSTRING(P.E2_VENCTO,5,2)+'/'+SUBSTRING(P.E2_VENCTO,7,2) AS date),CURRENT_TIMESTAMP) >= -60 THEN 7 "
    cQuery += "     WHEN DATEDIFF(DAY,CAST(SUBSTRING(P.E2_VENCTO,1,4)+'/'+SUBSTRING(P.E2_VENCTO,5,2)+'/'+SUBSTRING(P.E2_VENCTO,7,2) AS date),CURRENT_TIMESTAMP) < -60 AND "
    cQuery += "          DATEDIFF(DAY,CAST(SUBSTRING(P.E2_VENCTO,1,4)+'/'+SUBSTRING(P.E2_VENCTO,5,2)+'/'+SUBSTRING(P.E2_VENCTO,7,2) AS date),CURRENT_TIMESTAMP) >= -90 THEN 6 "
    cQuery += "     -- continue os outros WHENs aqui no mesmo estilo... "
    cQuery += "   END AGING_DIAS "
    cQuery += " FROM "+RetSqlName("SE2")+" P "
    cQuery += " JOIN "+RetSqlName("SA2")+" CF ON P.E2_FORNECE = CF.A2_COD AND P.E2_LOJA = CF.A2_LOJA "
    cQuery += " WHERE P.D_E_L_E_T_ = ' ' AND CF.D_E_L_E_T_ = ' ' "
    cQuery += ") X "

    oQry:GoTop()
    aFields := oQry:GetColumns()

    While !oQry:Eof()
        oRow := JsonObject():New()
        For nI := 1 To Len(aFields)
            oRow[aFields[nI]] := oQry:FieldGet(aFields[nI])
        Next
        oJson:Add(oRow)
        oQry:Skip()
    EndDo

    ::SetContentType("application/json")
    ::SetResponse(200, oJson:ToJson())

Return .T.
