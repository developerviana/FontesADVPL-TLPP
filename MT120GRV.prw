#INCLUDE "protheus.ch"  

User Function MT120GRV()

Local lInclui   := PARAMIXB[2]
Local lAltera   := PARAMIXB[3]
//Local lExclui   := PARAMIXB[4]
Local nPosObs   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_OBSM'})
Local cObservaComprador := ACOLS[1][106]
Local lRet      := .T.

    If lInclui .Or. lAltera
        If !Acols[n][len(aHeader)+1] 
            If !empty(aCols[n][nPosObs])
                    aCols[n][nPosObs] :=  cObservc  + ", " + cObservaComprador
            Else 
                    aCols[n][nPosObs] := Alltrim(cObservc)
            Endif         
        Endif
    Endif 
    
Return lRet 
