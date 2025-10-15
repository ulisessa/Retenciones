pageextension 50034 "Company Info Taxes" extends "Company Information"
{
    layout
    {
        addafter(General)
        {
            group("Taxes")
            {
                Caption = 'Taxes';
                field("Cód. área impuesto"; "Cód. área impuesto")
                {
                    ApplicationArea = All;
                    Caption = 'Cód. área impuesto';
                    ToolTip = 'Specifies the company''s tax area code.';
                    TableRelation = "Tax Area"."Code";
                }
                field("Sujeto a impuesto"; "Sujeto a impuesto")
                {
                    ApplicationArea = All;
                    Caption = 'Sujeto a impuesto';
                    ToolTip = 'Indicates whether the company is subject to tax.';
                }
                group("Es Agente")
                {
                    Caption = 'Is Agent';
                    field("Ag. Retencion IVA"; "Ag. Retencion IVA")
                    {
                        ApplicationArea = All;
                        Caption = 'Agente de Retención de IVA';
                        ToolTip = 'Indicates whether the company is an IVA withholding agent.';
                    }
                    field("Ag. Retencion Ingreso Brutos"; "Ag. Retencion Ingreso Brutos")
                    {
                        ApplicationArea = All;
                        Caption = 'Agente de Retención de Ingresos Brutos';
                        ToolTip = 'Indicates whether the company is an Ingresos Brutos withholding agent.';
                    }
                    field("Ag. Retencion Ganancias"; "Ag. Retencion Ganancias")
                    {
                        ApplicationArea = All;
                        Caption = 'Agente de Retención de Ganancias';
                        ToolTip = 'Indicates whether the company is a Ganancias withholding agent.';
                    }
                    field("No. agente retención"; "No agente retención")
                    {
                        ApplicationArea = All;
                        Caption = 'Nº agente retención';
                        ToolTip = 'Specifies the company''s withholding agent number.';
                    }
                    field("No. ingresos brutos"; "No. ingresos brutos")
                    {
                        ApplicationArea = All;
                        Caption = 'No. ingresos brutos';
                        ToolTip = 'Specifies the company''s Gross Income number as a withholding agent.';
                    }
                    field("GI agent type"; "GI agent type")
                    {
                        ApplicationArea = All;
                        Caption = 'Gross Income agent type';
                        ToolTip = 'Specifies the type of Gross Income withholding agent.';
                    }
                    field("GI agent no."; "GI agent no.")
                    {
                        ApplicationArea = All;
                        Caption = 'GI Agent No.';
                        ToolTip = 'Specifies the company''s Gross Income withholding agent number.';
                    }

                }
                group(Controls)
                {
                    Caption = 'Controls';
                    field("Omitir control factura directa"; "Omitir control factura directa")
                    {
                        ApplicationArea = All;
                        Caption = 'Omitir control factura directa';
                        ToolTip = 'Indicates whether to skip the direct invoice control.';
                    }
                    field("Omitir controles impositivos"; "Omitir controles impositivos")
                    {
                        ApplicationArea = All;
                        Caption = 'Omitir controles impositivos';
                        ToolTip = 'Indicates whether to skip tax controls.';
                    }

                }
            }
            group("Filing")
            {
                Caption = 'Filing';
                field("Almacen general informacion"; "Almacen general informacion")
                {
                    ApplicationArea = All;
                    Caption = 'Almacén general información';
                    ToolTip = 'Specifies the drive for information.';
                }
                field("Ruta de digitalizacion"; "Ruta de digitalizacion")
                {
                    ApplicationArea = All;
                    Caption = 'Ruta de digitalización';
                    ToolTip = 'Specifies the path for digitization.';
                }
                field("Ruta Intranet"; "Ruta Intranet")
                {
                    ApplicationArea = All;
                    Caption = 'Ruta Intranet';
                    ToolTip = 'Specifies the intranet path.';
                }
                field("Ruta cabecera digitalizacion"; "Ruta cabecera digitalizacion")
                {
                    ApplicationArea = All;
                    Caption = 'Ruta cabecera digitalización';
                    ToolTip = 'Specifies the header path for digitization.';
                }
                field("Ruta ejecutable digitalizacion"; "Ruta ejecutable digitalizacion")
                {
                    ApplicationArea = All;
                    Caption = 'Ruta ejecutable digitalización';
                    ToolTip = 'Specifies the executable path for digitization.';
                }
            }
        }
    }
}
