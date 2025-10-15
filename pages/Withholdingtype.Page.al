page 50714 "Withholding type"
{
    Editable = true;
    PageType = List;
    SourceTable = "Withholding codes";
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Withholding type';
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Tipo impuesto retencion"; "Tipo impuesto retencion")
                {
                }
                field("Cod. retencion"; "Cod. retencion")
                {
                }
                field("Stepwise calculation"; "Stepwise calculation")
                {
                }
                field(Descripcion; Descripcion)
                {
                }
                field("Codigo SICORE"; "Codigo SICORE")
                {
                }
                field("Tipo de regimen 7"; "Tipo de regimen 7")
                {
                }
                field("Exclusión por actividad"; "Exclusión por actividad")
                {
                }
                field("Importe maximo Ctd."; "Importe maximo Ctd.")
                {
                }
                field("Impuesto bajo maximo"; "Impuesto bajo maximo")
                {
                }
                field("Impuesto sobre maximo"; "Impuesto sobre maximo")
                {
                }
                field("Cuenta retencion"; "Cuenta retencion")
                {
                }
                field("Valores acumulados por"; "Valores acumulados por")
                {
                }
                field("Verificar registro RG3594"; "Verificar registro RG3594")
                {
                }
                field("Valid from"; "Valid from")
                {
                }
                field("Valid to"; "Valid to")
                {
                }
                field("Act as withholding agent"; "Act as withholding agent")
                {
                }
                field("Descripción RG"; "Descripción RG")
                {
                }
                field("Base cálculo stepwise"; "Base cálculo stepwise")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if CurrPage.LookupMode then
            CurrPage.Editable(true);
    end;
}

