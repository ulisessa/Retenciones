page 50502 "Lista actividad proveedor"
{
    DataCaptionFields = "No. actividad", "Nombre actividad";
    PageType = List;
    SourceTable = "Actividad proveedor";
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Lista actividad proveedor';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No. proveedor"; "No. proveedor")
                {
                }
                field("No. actividad"; "No. actividad")
                {
                }
                field("Nombre proveedor"; "Nombre proveedor")
                {
                }
                field("Nombre actividad"; "Nombre actividad")
                {
                }
                field("Fecha alta"; "Fecha alta")
                {
                }
                field("Fecha baja"; "Fecha baja")
                {
                }
                field("Tipo actividad"; "Tipo actividad")
                {
                }
                field("Tipo regimen"; "Tipo regimen")
                {
                }
                field(Orden; Orden)
                {
                }
            }
        }
    }

    actions
    {
    }
}

