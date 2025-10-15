pageextension 50032 "Inv. Subpage Ext." extends "Purch. Invoice Subform"
{
    layout
    {
        addlast(PurchDetailLine)
        {
            field("Consumir automáticamente"; "Consumir automáticamente")
            {
                ApplicationArea = All;
                Caption = 'Consumir automáticamente';
            }
            field("Concepto proyecto"; "Concepto proyecto")
            {
                ApplicationArea = All;
                Caption = 'Concepto proyecto';
            }
            field("Actividad AFIP"; "Actividad AFIP")
            {
                ApplicationArea = All;
                Caption = 'Actividad AFIP';
                ShowMandatory = true;
                TableRelation = "Actividad proveedor"."No. actividad" WHERE("No. proveedor" = FIELD("No."), "Tipo actividad" = FILTER(Actividad));
            }
            field("VAT withholding code"; "VAT withholding code")
            {
                ApplicationArea = All;
                Caption = 'VAT withholding code';
                ShowMandatory = blnVATWithholding;
            }
            field("Winnings withholding code"; "Winnings withholding code")
            {
                ApplicationArea = All;
                Caption = 'Winnings withholding code';
                ShowMandatory = blnWinningsWithholding;
            }
            field("Gross winnings with. code"; "Gross winnings with. code")
            {
                ApplicationArea = All;
                Caption = 'Gross winnings with. code';
                ShowMandatory = blnWinningsWithholdingGross;
            }
            field("SS withholding code"; "SS withholding code")
            {
                ApplicationArea = All;
                Caption = 'SS withholding code';
                ShowMandatory = blnSSWithholding;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


    trigger OnAfterGetCurrRecord()

    begin
        TestWithholdingSetup();
    end;

    local procedure TestWithholdingSetup()
    var
        l_rstCI: Record "Company Information";
    begin
        clear(l_rstCI);
        l_rstCI.get();
        IF l_rstCI."Ag. Retencion IVA" then
            blnVATWithholding := true
        else
            blnVATWithholding := false;
        IF l_rstCI."Ag. Retencion Ganancias" then
            blnWinningsWithholding := true
        else
            blnWinningsWithholding := false;
        IF l_rstCI."Ag. Retencion Ingreso Brutos" then
            blnWinningsWithholdingGross := true
        else
            blnWinningsWithholdingGross := false;
    end;

    var
        blnVATWithholding: Boolean;
        blnWinningsWithholding: Boolean;
        blnWinningsWithholdingGross: Boolean;
        blnSSWithholding: Boolean;
}