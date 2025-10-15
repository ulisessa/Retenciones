page 50026 "SS Withholding Types"
{
    PageType = List;
    SourceTable = "Withholding codes";
    SourceTableView = WHERE("Tipo impuesto retencion" = FILTER("Seguridad Social"));
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'SS Withholding Types';

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

