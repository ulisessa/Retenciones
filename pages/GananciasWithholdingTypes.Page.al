page 50720 "Ganancias Withholding Types"
{
    PageType = List;
    SourceTable = "Withholding codes";
    SourceTableView = WHERE("Tipo impuesto retencion" = FILTER(Ganancias));
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Ganancias Withholding Types';
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

