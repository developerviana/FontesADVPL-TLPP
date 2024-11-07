#include "rwmake.ch"
#include "topconn.ch"
 
/*------------------------------------------------------------------------//
//Programa:  Ponto de Entrada MT120ISC
//Autor:     Victor Lucas
//Data:      06/11/2024
//Descricao: Ponto de entrada que adiciona campos customizados no pedido de compras 
//           (Quando inclui Solicitação de Compra).
//------------------------------------------------------------------------*/
 
User Function MT120ISC()

  // Pegando a posição dos campos da SC7
  Local nPosNomeCC := aScan(aHeader, {|x| Trim(x[2]) == "C7_XNOMCC"}) 
  Local nPosNItem  := aScan(aHeader, {|x| Trim(x[2]) == "C7_NOMITEM"})
  Local nPosNCLava := aScan(aHeader, {|x| Trim(x[2]) == "C7_XNOMCLA"})

  // Adicionando as informações nos campos da tabela SC7
  ACOLS[n, nPosNomeCC] := Alltrim(SC1->C1_XCCNOME)
  ACOLS[n, nPosNItem] := Alltrim(SC1->C1_XNITEM) 
  ACOLS[n, nPosNCLava] := Alltrim(SC1->C1_XNCLAVA)
  
Return .T.
