#include "protheus.ch"
#include "totvs.ch"
#include "TbiConn.ch"
#include "TopConn.ch"

/*/{Protheus.doc} F080ACON()
Ponto de entrada na baixa de contas a pagar, após a gravação dos dados no SE5.
@type function
@version Protheus 12.1.2210
@author Jander Silva
@obs Ponto de entrada utilizado para contabilização da execução das receitas.
@obs ORIGENS DAS CHAMADAS:
@obs - Ctas.Pagar > Baixa a Pagar Manual > Baixar
@obs - Ctas.Pagar > Funções Ctas.Pagar > Baixa Manual > Baixar
@obs - Ctas.Pagar > Baixas Pagar Automática ---> A partir do PE F90SE5GRV()
@obs - Ctas.Pagar > Funções Ctas.Pagar > Baixa Automática > Automática ---> A partir do PE F90SE5GRV()
@return NIL, none
@history 30/08/2024, Jander Silva, Primeira versão.
/*/
User Function F080ACON()

   Local    aAreaAnt    := {}
   Local    cE5DATA     := SToD("")
   Local    cE5NUMERO   := ""
   Local    cE5PREFIXO  := ""
   Local    cE5CLIFOR   := ""
   Local    cE5LOJA     := ""
   Local    nE5VALOR    := 0
   Local    aRetSD1     := {}
   Local    oD1F1A2
   Local    i

   Local    cCT2Sequen  := ""
   Local    cCT2Origem    := ""
   Local    cCT2Hist    := ""
   Local    cLote       := ""
   Local    cSbLote     := ""
   Local    cDocLote    := ""
   Local    aContas     := {}
   Local    nVlrItem    := 0
   Local    nVlrAcum    := 0
   Local    nTotImp     := 0
   Local    nValLiqNF   := 0
   Local    nFatorBx    := 0

   Local    cUpdCT2     := ""
   Local    aCTKRet     := {.t.,""}

   Private  aCab        := {}
   Private  aItens      := {}
   Private  lMsErroAuto := .f.

   aAreaAnt := GetArea()

   // identificação do título baixado na SE5

   cE5DATA     := SE5->E5_DATA
   cE5NUMERO   := SE5->E5_NUMERO
   cE5PREFIXO  := SE5->E5_PREFIXO
   cE5CLIFOR   := SE5->E5_CLIFOR
   cE5LOJA     := SE5->E5_LOJA
   nE5VALOR    := SE5->E5_VALOR

   // identificação do documento de entrada

   If ! (aRetSD1 := FindDoc(cE5NUMERO,cE5PREFIXO,cE5CLIFOR,cE5LOJA,nE5VALOR))[1]
     // FWAlertError( aRetSD1[2], "CTB - Falha na Execução da Receita" )
      RestArea(aAreaAnt)
      Return
   End

   oD1F1A2 := aRetSD1[3]

   // cria arrays aCab e aItens para Execauto

   dDtLanc     := cE5DATA     // Date()
   cLote       := "EXCR" + Substr(DToS(Date()), 3, 2)
   cSbLote     := "001"
   cDocLote    := "000001"    // sequencial gerado automaticamente pelo Execauto()

   AAdd(aCab, {'DDATALANC',      dDtLanc,    NIL} )
   AAdd(aCab, {'CLOTE',          cLote,      NIL} )   // Lote do ano vigente
   AAdd(aCab, {'CSUBLOTE',       cSbLote,    NIL} )   // 001
   AAdd(aCab, {'CDOC',           cDocLote,   NIL} )   // Sequencial para CT2_DOC e E5_XDOCLA
   AAdd(aCab, {'CPADRAO',        "",         NIL} )
   AAdd(aCab, {'NTOTINF',        0,          NIL} )
   AAdd(aCab, {'NTOTINFLOT',     0,          NIL} )

   cCT2Sequen  := u_GetNewSeq()

   For i := 1 To Len(oD1F1A2)

      // obtém contas débito e crédito a partir do Item Contábil

      aContas := u_GetContas(oD1F1A2[i]["D1_ITEMCTA"])

      // ROTEIRO DE CÁLCULO: valor a contabilizar (D1_TOTAL = despesa + impostos ) proporcional ao valor baixado

      nTotImp     := oD1F1A2[i]["F1_ISS"] + oD1F1A2[i]["F1_IRRF"] + oD1F1A2[i]["F1_INSS"] + oD1F1A2[i]["F1_VALPIS"] + oD1F1A2[i]["F1_VALCOFI"] + oD1F1A2[i]["F1_VALCSLL"]
      nValLiqNF   := oD1F1A2[i]["F1_VALBRUT"] - nTotImp
      nFatorBx    := nE5VALOR / nValLiqNF
      nVlrItem    := oD1F1A2[i]["D1_TOTAL"] * nFatorBx

      If i == Len(oD1F1A2)
         nVlrItem := ( oD1F1A2[i]["F1_VALBRUT"] * nFatorBx ) - nVlrAcum
      End

      nVlrAcum += nVlrItem

      // incrementa aItens

      cCT2Origem  := "EXEC-REC-" + Alltrim(cUsername) + "-" + DToC(Date()) + "-" + Time() + IIf("CTBBXA" $ Procname(1), "-CTBBXA", "-FINA080")
      cCT2Hist    := Left( "EXC-REC-NF: " + Alltrim(oD1F1A2[i]["D1_DOC"]) + "-" + Alltrim(oD1F1A2[i]["A2_NREDUZ"]), 40 )

      AAdd(aItens,{;
         {"CT2_FILIAL",       xFilial("CT2"),                  NIL},;
         {"CT2_LINHA",        StrZero(i,3,0),                  NIL},;
         {"CT2_MOEDLC",       "01",                            NIL},;
         {"CT2_DC",           "3",                             NIL},;
         {"CT2_DEBITO",       aContas[1],                      NIL},;
         {"CT2_CREDIT",       aContas[2],                      NIL},;
         {"CT2_VALOR",        nVlrItem,                        NIL},;
         {"CT2_ORIGEM",       cCT2Origem,                      NIL},;
         {"CT2_LP",           "",                              NIL},;
         {"CT2_SEQLAN",       "001",                           NIL},;
         {"CT2_VLR01",        nVlrItem,                        NIL},;
         {"CT2_SEQUEN",       cCT2Sequen,                      NIL},;
         {"CT2_HP",           "",                              NIL},;
         {"CT2_HIST",         cCT2Hist,                        NIL},;
         {"CT2_CCD",          "",                              NIL},;
         {"CT2_CCC",          Alltrim(oD1F1A2[i]["D1_CC"]),      NIL},;
         {"CT2_ITEMC",        Alltrim(oD1F1A2[i]["D1_ITEMCTA"]), NIL},;
         {"CT2_CLVLCR",       Alltrim(oD1F1A2[i]["D1_CLVL"]),    NIL},;
         {"CT2_ATIVCR",       Alltrim(oD1F1A2[i]["F1_NATUREZ"]), NIL},;
         {"CT2_CODFOR",       cE5CLIFOR,                       NIL}})

   Next

   // Tela de confirmação dos lançamentos
   // If "CTBBXA" $ Procname(1)
   //    aItens := u_CheckLP(aItens)
   // End

   aCab     := FWVetByDic(aCab, "CT2", .f.)
   aItens   := FWVetByDic(aItens, "CT2", .t. /*array de itens*/)

   MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab ,aItens, 3)

   If lMsErroAuto

      lMsErroAuto := .f.
      MostraErro()

   Else

      // obtém CT2_DOC gerado pelo Execauto()

      cDocLote := CT2->CT2_DOC

      // atualiza customizados na SE5

      RecLock("SE5",.f.)
      SE5->E5_XDTLA  := dDtLanc
      SE5->E5_XLOTLA := cLote
      SE5->E5_XSBLLA := cSbLote
      SE5->E5_XDOCLA := cDocLote
      SE5->(MsUnlock())

      // atualiza CT2_SEQUEN e CT2_ATIVCR não atualizados no Execauto()

      cUpdCT2 := " UPDATE " + RetSqlName("CT2") + " SET "//
      cUpdCT2 += "   CT2_SEQUEN = '" + cCT2Sequen + "', "
      cUpdCT2 += "   CT2_CLVLCR = '" + Alltrim(oD1F1A2[1]["D1_CLVL"]) + "', "
      cUpdCT2 += "   CT2_ATIVCR = '" + Alltrim(oD1F1A2[1]["F1_NATUREZ"]) + "' "
      cUpdCT2 += " WHERE D_E_L_E_T_    <> '*' "
      cUpdCT2 += " AND CT2_FILIAL      = '" + xFilial("CT2") + "' "
      cUpdCT2 += " AND CT2_DATA        = '" + DToS(dDtLanc) + "' "
      cUpdCT2 += " AND CT2_DOC         = '" + cDocLote + "' "
      cUpdCT2 += " AND CT2_LOTE        = '" + cLote + "' "
      cUpdCT2 += " AND CT2_SBLOTE      = '" + cSbLote + "' "

      If TcSQLExec(cUpdCT2) < 0
         FWAlertError("A contabilização foi processada. Porém, o campo CT2_SEQUEN pode estar incorreto." + Chr(13) + "Favor conferir ou acionar o suporte.")
      End

      // gera lançamentos na CTK (consistência com CT2_SEQUEN)

      If ! ( aCTKRet := u_CT2ToCTK( dDtLanc, cLote, cSbLote, cDocLote ) )[1]
         FWAlertError(aCTKRet[2], "Falha - Tabela CTK")
      End

   End

   RestArea(aAreaAnt)

Return

// obtém as contas débito e crédito do Item Contábil

User Function GetContas(cItemCtb)

   Local aRet

   clerCD := "SELECT CTD_ITEM,CTD_DESC01,CTD_XCTDEB,CTD_XCTCRE "
   clerCD += " FROM " + RetSqlname("CTD") + " "
   clerCD += " WHERE D_E_L_E_T_<> '*' "
   clerCD += " AND CTD_FILIAL = '" + xFilial("CTD") + "'"
   clerCD += " AND CTD_ITEM = '" + cItemCtb + "' "

   If Select("TMP3") > 0
      TMP3->(dbCloseArea())
   End
   TcQuery clerCD Alias "TMP3" New

   aRet := {TMP3->CTD_XCTDEB, TMP3->CTD_XCTCRE}

   TMP3->(dbCloseArea())

Return aRet

// gera sequencial para CT2_SEQUEN (consistência com a tabela CTK)

User Function GetNewSeq()

   Local cSql     := ''
   Local cCT2Seq  := ''
   Local aAreaAnt := GetArea()

   cSql := "SELECT MAX(CT2_SEQUEN) SEQUEN "
   cSql += " FROM "+RetSqlname("CT2")+" "
   cSql += " WHERE D_E_L_E_T_<> '*' "
   cSql += " AND CT2_FILIAL =   '"+xFilial("CT2") +"'"

   If Select("TMP2") > 0
      TMP2->(dbCloseArea())
   End
   TcQuery cSql Alias "TMP2" New

   cCT2Seq := Soma1(cValToChar(TMP2->SEQUEN))

   TMP2->(dbCloseArea())

   RestArea(aAreaAnt)

Return cCT2Seq

// identificação do documento de entrada

Static Function FindDoc(cE5NUMERO,cE5PREFIXO,cE5CLIFOR,cE5LOJA,nE5VALOR)

   Local    lRet        := .t.
   Local    cMsg        := ""
   Local    oD1F1A2     := {}
   Local    cItemD1F1A2 := ""
   Local    oItemD1F1A2
   Local    cFields     := "D1_DOC,D1_SERIE,D1_COD,D1_ITEM,D1_TOTAL,D1_FORNECE,D1_LOJA,D1_ITEMCTA,D1_CC,D1_PEDIDO,D1_CLVL,D1_FORNECE,F1_VALMERC,F1_VALBRUT,F1_NATUREZ,A2_NREDUZ,F1_ISS,F1_IRRF,F1_INSS,F1_VALPIS,F1_VALCOFI,F1_VALCSLL"
   Local    i
   Local    xVar

   Default  cE5NUMERO   := ""
   Default  cE5PREFIXO  := ""
   Default  cE5CLIFOR   := ""
   Default  cE5LOJA     := ""
   Default  nE5VALOR    := 0

   Begin Sequence

      If Empty(cE5NUMERO) .or. Empty(cE5CLIFOR) .or. Empty(nE5VALOR)
         lRet := .f.
         cMsg := "Dados insuficientes para identificação do título:" + Chr(13) +;
            "Número: " + cE5NUMERO + Chr(13) +;
            "Prefixo: " + cE5PREFIXO + Chr(13) +;
            "Cli/Forn: " + cE5CLIFOR + Chr(13) +;
            "Loja: " + cE5LOJA + Chr(13) +;
            "Valor: " + Alltrim(Transform(nE5VALOR, "@E 999,999,999.99")) + Chr(13)
         Break
      End

      cSql := "SELECT " + cFields + " "
      cSql += " FROM  " + RetSqlname("SD1") + " SD1, " + RetSqlname("SF1") + " SF1, " + RetSqlname("SA2") + " SA2 "
      cSql += " WHERE SD1.D_E_L_E_T_<> '*' AND SF1.D_E_L_E_T_<> '*' AND SA2.D_E_L_E_T_<> '*' "
      cSql += " AND D1_FILIAL  = '" + xFilial("SD1") + "' "
      cSql += " AND D1_DOC     = '" + cE5NUMERO + "' "
      cSql += " AND D1_SERIE   = '" + cE5PREFIXO + "' "
      cSql += " AND D1_FORNECE = '" + cE5CLIFOR + "' "
      cSql += " AND D1_LOJA    = '" + cE5LOJA + "' "
      cSql += " AND D1_FILIAL  = F1_FILIAL "
      cSql += " AND D1_DOC     = F1_DOC "
      cSql += " AND D1_SERIE   = F1_PREFIXO "
      cSql += " AND D1_FORNECE = F1_FORNECE "
      cSql += " AND D1_LOJA    = F1_LOJA "
      cSql += " AND D1_FORNECE = A2_COD "
      cSql += " AND D1_LOJA    = A2_LOJA "
      cSql += " ORDER BY D1_DOC,D1_SERIE,D1_ITEM "

      cSql := ChangeQuery(cSql)

      If Select("TMP1") > 0
         TMP1->(dbCloseArea())
      End

      TcQuery cSql Alias "TMP1" New

      If TMP1->(Eof())
         lRet := .f.
         cMsg := "Não foi localizado um Documento de Entrada associado a esta movimentação."
         Break
      End

      // cria objeto JSON com dados de SD1, SF1 e SA2

      aFields := StrTokArr(cFields, ",")

      While ! TMP1->(Eof())

         oItemD1F1A2 := JsonObject():New()

         cItemD1F1A2 := "{"

         For i := 1 To Len(aFields)

            xVar := TMP1->(&(aFields[i]))
            If Valtype(xVar) == "L"
               xVar := IIf(xVar, "TRUE", "FALSE")
            ElseIf Valtype(xVar) == "N"
               xVar := Alltrim(Str(xVar))
            ElseIf Valtype(xVar) == "D"
               xVar := '"' + DToC(xVar) + '"'
            Else
               xVar := '"' + Alltrim(xVar) + '"'
            End
            cItemD1F1A2 += '"' + aFields[i] + '":' + xVar + ','

         Next

         cItemD1F1A2 := Left( cItemD1F1A2, Len(cItemD1F1A2) - 1 ) + "}"

         oItemD1F1A2:FromJson( cItemD1F1A2 )
         AAdd( oD1F1A2, oItemD1F1A2 )
         TMP1->(DBSkip())

      End

   End Sequence

   If Select("TMP1") > 0
      TMP1->(dbCloseArea())
   End

Return { lRet, cMsg, oD1F1A2 }

// gera lançamentos na CTK (consistência com CT2_SEQUEN)

User Function CT2ToCTK(dDtLanc, cLote, cSbLote, cDocLote)

   Local aAreaAnt := GetArea()
   Local aAreaCT2 := {}
   Local aAreaCTK := {}
   Local aRet     := {.t., ""}

   If Select("CT2") > 0
      aAreaCT2 := CT2->(GetArea())
   End

   If Select("CTK") > 0
      aAreaCTK := CTK->(GetArea())
   End

   dbSelectArea("CTK")
   dbSelectArea("CT2")
   dbSetOrder(1)
   dbSeek( xFilial("CT2") + DToS(dDtLanc) + cLote + cSbLote + cDocLote + "001" )
   
   While ! CT2->(Eof()) .or. ( CT2->CT2_FILIAL == xFilial("CT2") .and. CT2->CT2_DATA == dDtLanc .and. CT2->CT2_LOTE == cLote .and. CT2->CT2_SBLOTE == cSbLote )

      If ! RecLock("CTK",.t.)
         aRet := {.f.,"Houve falha na inclusão da contabilização (CTK)."}
         Exit
      End

      CTK->CTK_FILIAL   := CT2->CT2_FILIAL
      CTK->CTK_CODFOR   := CT2->CT2_CODFOR
      CTK->CTK_DATA     := CT2->CT2_DATA
      CTK->CTK_LOTE     := CT2->CT2_LOTE
      CTK->CTK_SBLOTE   := CT2->CT2_SBLOTE
      CTK->CTK_SEQUEN   := CT2->CT2_SEQUEN
      CTK->CTK_MOEDLC   := CT2->CT2_MOEDLC
      CTK->CTK_DC       := CT2->CT2_DC
      CTK->CTK_DEBITO   := CT2->CT2_DEBITO
      CTK->CTK_CREDIT   := CT2->CT2_CREDIT
      CTK->CTK_VLR01    := CT2->CT2_VLR01
      CTK->CTK_HIST     := CT2->CT2_HIST
      CTK->CTK_HAGLUT   := CT2->CT2_HIST
      CTK->CTK_CCD      := CT2->CT2_CCD
      CTK->CTK_CCC      := CT2->CT2_CCC
      CTK->CTK_ITEMC    := CT2->CT2_ITEMC
      CTK->CTK_LP       := CT2->CT2_LP
      CTK->CTK_LPSEQ    := CT2->CT2_SEQLAN
      CTK->CTK_ORIGEM   := CT2->CT2_ORIGEM
      CTK->CTK_CLVLCR   := CT2->CT2_CLVLCR
      CTK->CTK_ATIVCR   := CT2->CT2_ATIVCR
      CTK->CTK_AT01DB   := CT2->CT2_AT01DB
      CTK->CTK_AT01CR   := CT2->CT2_AT01CR
      CTK->CTK_TPSALD   := CT2->CT2_TPSALD
      CTK->CTK_CTRLSD   := CT2->CT2_CTRLSD
      CTK->CTK_ROTINA   := CT2->CT2_ROTINA
      CTK->CTK_MOEDAS   := "12222"

      CTK->(MsUnlock())

      CT2->(dbSkip())

   End

   If ! Empty(aAreaCTK)
      RestArea(aAreaCTK)
   Else
      CTK->(dbCloseArea())
   End

   If ! Empty(aAreaCT2)
      RestArea(aAreaCT2)
   Else
      CT2->(dbCloseArea())
   End

   RestArea(aAreaAnt)

Return aRet
