#INCLUDE "protheus.ch"     

/*/{Protheus.doc} mt120tel
Adiciona campos ao cabeçalho do pedido de compras
@type function
@author Fernando Nicolau
@since 01/11/2022
/*/
User Function MT120TEL()    

	Local   aAreaAux   := GetArea()
	Local   oNewDialog := PARAMIXB[1]
	Local   aPosGet    := PARAMIXB[2]
	Local   nTamanho   := Len(oNewDialog:aControls)	
	Local   nLinDife   := 13
	Local   nLinIni    := oNewDialog:aControls[2]:nTop
	Local   aOrigina   := Aclone(aPosGet)
	Local   aColuna    := {oNewDialog:aControls[2]:nLeft}
	Local   i          := 0
	
	_SetNamedPrvt("cObserva", " ", "A120Pedido")
	_SetNamedPrvt("cObservc", " ", "A120Pedido")
	_SetNamedPrvt("cSolicit", " ", "A120Pedido")
	_SetNamedPrvt("cContrat", " ", "A120Pedido")
	
	cObserva := If(INCLUI, Space(1), SC7->C7_XOBSAPV)
	cObservc := If(INCLUI, Space(1), SC7->C7_XOBSCOM)
	cSolicit := If(INCLUI, Space(1), SC7->C7_XSOLICI)
	cContrat := If(INCLUI, Space(1), SC7->C7_XCONTRA)


	bVldEnt  := {|| Empty(cEntrega) .Or. ExistCpo("SY2", cEntrega), fSetVar(cEntrega), }
	bVldComD := {|| fSetVar(cComprad)}

	// Coleta as posições das colunas e a diferença entre linhas
	For i := 4 To nTamanho	
		If oNewDialog:aControls[i]:nTop == nLinIni .Or. oNewDialog:aControls[i]:nTop == (nLinIni - 2) 	
			aAdd(aColuna, oNewDialog:aControls[i]:nLeft)			
		Else		
			nLinDife := (oNewDialog:aControls[i]:nTop - nLinIni) + 1			
			Exit		
		EndIf
	Next i		

	oSayObs := TSay():New(72, aOrigina[1,1], {|| "Obs. Aprov"}, oNewDialog,,, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 62, 012)		
	oGetObs := TMultiget():New(73, aOrigina[1,2], {|u| If (Pcount() > 0, cObserva:=u, cObserva)},oNewDialog,114, 040,,,,,,.T.,,,{|| .F.})
	
	oSayObs := TSay():New(72, aOrigina[1,3], {|| "Obs. Comprador"}, oNewDialog,,, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 62, 012)		
	oGetObs := TMultiget():New(73, aOrigina[1,4], {|u| If (Pcount() > 0, cObservc:=u, cObservc)},oNewDialog,114, 040,,,,,,.T.,,,{|| .T.})

	oSaySol := TSay():New(72, aOrigina[1,5] - 12, {|| "Solicitante"}, oNewDialog,,, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 62, 012)		
	oGetSol := TGet():New(73, aOrigina[1,6] - 25, bSetGet(cSolicit), oNewDialog, 065, 09, "@!",, CLR_BLACK, CLR_WHITE  ,,,, .T.,,, { || .F. },,,, .F., .F.,,,,)

	oSayCnt := TSay():New(72, aOrigina[1,7] - 12, {|| "Contrato"}, oNewDialog,,, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 62, 012)		
	oGetCnt := TGet():New(73, aOrigina[1,8] + 250, bSetGet(cContrat), oNewDialog, 065, 09, "@!",, CLR_BLACK, CLR_WHITE  ,,,, .T.,,, { || .F. },,,, .F., .F.,,,,)

	RestArea(aAreaAux)

Return()
