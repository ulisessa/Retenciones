page 50093 "SS Withholding Setup"
{
    PageType = List;
    SourceTable = "Withholding setup";
    SourceTableView = SORTING("Tipo retenciones", "Cod. retencion", "Tipo fiscal", Provincia, "Importe pago minimo")
                      WHERE("Tipo retenciones" = FILTER("Seguridad Social"));
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'SS Withholding Setup';
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Tipo retenciones"; "Tipo retenciones")
                {
                }
                field("Cod. retencion"; "Cod. retencion")
                {
                }
                field("Tipo base retencion"; "Tipo base retencion")
                {
                }
                field("Tipo fiscal"; "Tipo fiscal")
                {
                }
                field("Importe pago minimo"; "Importe pago minimo")
                {
                }
                field("Importe min. retencion"; "Importe min. retencion")
                {
                }
                field("Importe minimo Stepwise"; "Importe minimo Stepwise")
                {
                }
                field("% retencion"; "% retencion")
                {
                }
                field("Importe retencion"; "Importe retencion")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Tipo retenciones" := "Tipo retenciones"::"Seguridad Social";
    end;
}

