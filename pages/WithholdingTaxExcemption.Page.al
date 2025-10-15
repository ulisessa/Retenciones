page 50723 "Withholding Tax Excemption"
{
    PageType = List;
    SourceTable = "Withholding details";
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Withholding Tax Excemption';
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Tipo registro"; "Tipo registro")
                {
                }
                field("Cod. proveedor/cliente"; "Cod. proveedor/cliente")
                {
                }
                field("Tipo retención"; "Tipo retención")
                {
                }
                field("Cód. retención"; "Cód. retención")
                {
                }
                field("% exención"; "% exención")
                {
                }
                field("% percepcion"; "% percepcion")
                {
                }
                field("% retencion"; "% retencion")
                {
                }
                field("Fecha efectividad retencion"; "Fecha efectividad retencion")
                {
                }
                field(Importe; Importe)
                {
                }
                field("Fecha documento"; "Fecha documento")
                {
                }
                field("Razon social Proveedor"; "Razon social Proveedor")
                {
                }
                field("VAT Registration No."; "VAT Registration No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

