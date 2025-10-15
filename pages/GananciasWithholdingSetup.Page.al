page 50727 "Ganancias Withholding Setup"
{
    PageType = List;
    SourceTable = "Withholding setup";
    SourceTableView = SORTING("Tipo retenciones", "Cod. retencion", "Tipo fiscal", Provincia, "Importe pago minimo")
                      WHERE("Tipo retenciones" = FILTER(Ganancias));
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Ganancias Withholding Setup';
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
                field("Importe minimo Stepwise"; "Importe minimo Stepwise")
                {
                }
                field("% retencion"; "% retencion")
                {
                }
                field("Importe retencion"; "Importe retencion")
                {
                }
                field("RT Base pago anterior"; "RT Base pago anterior")
                {
                }
                field("RT Base este pago"; "RT Base este pago")
                {
                }
                field("RT este pago"; "RT este pago")
                {
                }
                field("RT pago anterior"; "RT pago anterior")
                {
                }
                field("Precio unitario maximo"; "Precio unitario maximo")
                {
                }
                field("Importe min. retencion"; "Importe min. retencion")
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
        "Tipo retenciones" := "Tipo retenciones"::Ganancias;
    end;
}

