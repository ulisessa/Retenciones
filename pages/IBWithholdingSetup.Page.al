page 50726 "IB Withholding Setup"
{
    PageType = List;
    SourceTable = "Withholding setup";
    SourceTableView = SORTING("Tipo retenciones", "Cod. retencion", "Tipo fiscal", Provincia, "Importe pago minimo")
                      WHERE("Tipo retenciones" = FILTER("Seguridad Social"));
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'IB Withholding Setup';
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Cod. retencion"; "Cod. retencion")
                {
                }
                field(Provincia; Provincia)
                {
                }
                field("Tipo fiscal"; "Tipo fiscal")
                {
                }
                field("Tipo base retencion"; "Tipo base retencion")
                {
                }
                field("% retencion"; "% retencion")
                {
                }
                field("Importe pago minimo"; "Importe pago minimo")
                {
                }
                field("Importe minimo Stepwise"; "Importe minimo Stepwise")
                {
                }
                field("Importe min. retencion"; "Importe min. retencion")
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
        "Tipo retenciones" := "Tipo retenciones"::"Ingresos Brutos";
    end;
}

