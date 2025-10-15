page 50598 "Lista Retenciones"
{
    PageType = List;
    SourceTable = "Invoice Withholding Buffer";
    SourceTableView = SORTING("No. documento", "Cod. retencion");
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Lista Retenciones';
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
                field("Cliente/Proveedor"; "Cliente/Proveedor")
                {
                }
                field("No. documento"; "No. documento")
                {
                }
                field("No. Factura"; "No. Factura")
                {
                }
                field("Tipo retención"; "Tipo retencion")
                {
                }
                field("Cod. retencion"; "Cod. retencion")
                {
                }
                field("Tipo fiscal"; "Tipo fiscal")
                {
                }
                field("Fecha pago"; "Fecha pago")
                {
                }
                field("Base pago retencion"; "Base pago retencion")
                {
                }
                field("Pagos anteriores"; "Pagos anteriores")
                {
                }
                field("Importe retencion"; "Importe retencion")
                {
                }
                field("% retencion"; "% retencion")
                {
                }
                field(Provincia; Provincia)
                {
                }
                field("No. serie ganancias"; "No. serie ganancias")
                {
                }
                field("No. serie IVA"; "No. serie IVA")
                {
                }
                field("No. serie Ingresos Brutos"; "No. serie Ingresos Brutos")
                {
                }
                field(Nombre; Nombre)
                {
                }
                field("Fecha factura"; "Fecha factura")
                {
                }
                field(Excluido; Excluido)
                {
                }
                field("% Exclusion"; "% Exclusion")
                {
                }
                field("Fecha documento exclusion"; "Fecha documento exclusion")
                {
                }
                field("Importe retencion total"; "Importe retencion total")
                {
                }
                field("Importe neto factura"; "Importe neto factura")
                {
                }
                field("Importe retenciones anteriores"; "Importe retenciones anteriores")
                {
                }
                field(Retenido; Retenido)
                {
                }
                field("Tipo factura"; "Tipo factura")
                {
                }
                field("Serie retención"; "Serie retención")
                {
                }
                field("Factura Prov"; "Factura Prov")
                {
                }
            }
        }
    }

    actions
    {
    }
}

