page 50717 "Withholding Setup"
{
    PageType = List;
    SourceTable = "Withholding setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Withholding Setup';
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
                field("Tipo fiscal"; "Tipo fiscal")
                {
                }
                field("Cod. retencion"; "Cod. retencion")
                {
                }
                field("Importe pago minimo"; "Importe pago minimo")
                {
                }
                field("Importe retencion"; "Importe retencion")
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
                field("Porcentaje de IVA"; "Porcentaje de IVA")
                {
                }
                field("Skip exclusions"; "Skip exclusions")
                {
                }
            }
        }
    }

    actions
    {
    }
}

