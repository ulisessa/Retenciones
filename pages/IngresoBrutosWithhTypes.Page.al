page 50719 "Ingreso Brutos Withh. Types"
{
    PageType = List;
    SourceTable = "Withholding codes";
    SourceTableView = WHERE("Tipo impuesto retencion" = FILTER("Ingresos Brutos"));
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Ingreso Brutos Withh. Types';
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

