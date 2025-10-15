page 50718 "IVA Withholding Types"
{
    PageType = List;
    SourceTable = "Withholding codes";
    SourceTableView = WHERE("Tipo impuesto retencion" = FILTER(IVA));
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'IVA Withholding Types';
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
                field(Descripcion; Descripcion)
                {
                }
            }
        }
    }

    actions
    {
    }
}

