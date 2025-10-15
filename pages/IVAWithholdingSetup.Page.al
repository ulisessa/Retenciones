page 50725 "IVA Withholding Setup"
{
    PageType = List;
    SourceTable = "Withholding setup";
    SourceTableView = SORTING("Tipo retenciones", "Cod. retencion", "Tipo fiscal", Provincia, "Importe pago minimo")
                      WHERE("Tipo retenciones" = FILTER(IVA));
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'IVA Withholding Setup';
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
                field("% retencion"; "% retencion")
                {
                }
                field("Tipo base retencion"; "Tipo base retencion")
                {
                }
                field("Porcentaje de IVA"; "Porcentaje de IVA")
                {
                }
                field(Provincia; Provincia)
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
                field("Importe retencion"; "Importe retencion")
                {
                }
                field("Importe min. retencion"; "Importe min. retencion")
                {
                }
                field("Precio unitario maximo"; "Precio unitario maximo")
                {
                }
                field("Registrado RG3594"; "Registrado RG3594")
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
        "Tipo retenciones" := "Tipo retenciones"::IVA;
    end;
}

