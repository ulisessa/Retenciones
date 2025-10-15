page 50721 "Calculated Withholdings"
{
    PageType = List;
    SourceTable = "Withholding details";
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Calculated Withholdings';
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Cod. proveedor/cliente"; "Cod. proveedor/cliente")
                {
                }
                field("Tipo retención"; "Tipo retención")
                {
                }
                field("% exención"; "% exención")
                {
                }
                field("Fecha efectividad retencion"; "Fecha efectividad retencion")
                {
                }
                field("Cód. retención"; "Cód. retención")
                {
                }
                field(Importe; Importe)
                {
                }
                field("Fecha documento"; "Fecha documento")
                {
                }
            }
        }
    }

    actions
    {
    }
}

