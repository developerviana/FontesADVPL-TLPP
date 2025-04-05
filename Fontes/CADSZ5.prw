#INCLUDE 'Protheus.ch'
#INCLUDE 'Parmtype.ch'
#INCLUDE 'FWMVCDef.ch'

User function CADSZ5()

    Local oBrowse := Nil
    Private aRotina := FwLoadMenuDef("CADSZ5")

    DbSelectArea("SZ5")
    SetFunName("CADSZ5")

    oBrowse := FWMBrowse():New()

    oBrowse:SetAlias("SZ5")
    oBrowse:SetDescription("SZ5 - Contabilidade Gerencial")
    oBrowse:Activate()
Return(Nil) 

Static Function MenuDef()
   
    aRotina := {}
    
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.CADSZ5' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.CADSZ5' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.CADSZ5' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.CADSZ5' OPERATION 5 ACCESS 0
    
Return aRotina

Static Function ModelDef()

    Local oModel as object
    Local oStMaster as object

    oModel := MPFormModel():New( "MODEL_SZ5", /*bPre*/ , /*bPos*/, /*bCommit*/, /*bCancel*/ )

    oStMaster := FWFormStruct(1, 'SZ5')

    oModel:AddFields("ModelSZ5",/*cOwner*/,oStMaster)

    oModel:SetPrimaryKey( {'SZ5_PROD'} )
Return oModel

Static Function ViewDef()
    Local oView as object
    Local oStMaster as object
    
    oView   := FwFormView():New()
    oModel  := ModelDef()

    oStMaster := FWFormStruct(2, 'SZ5')

    oView:SetModel(oModel)

    oStMaster:SetProperty("SZ5_PROD", MVC_VIEW_LOOKUP, {|| cConsulta := "SB1"})

    oView:AddField("ViewSZ5", oStMaster, "ModelSZ5")
   
    oView:CreateHorizontalBox('BoxSZ5' , 100)

	oView:SetOwnerView('ViewSZ5','BoxSZ5')	
Return oView

