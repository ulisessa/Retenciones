page 50009 "Posted Invoice Purchase Lines"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Purch. Inv. Line";
    DeleteAllowed = false;
    InsertAllowed = false;
    //Caption = 'Posted Invoice Purchase Lines';


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                ShowCaption = false;
                field("Document No."; "Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Cód. retención ganancias"; "Cód. retención ganancias")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Cód. retención IIBB"; "Cód. retención IIBB")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Cód. retención IVA"; "Cód. retención IVA")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Cód. retención SS"; "Cód. retención SS")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Actividad AFIP"; "Actividad AFIP")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                    TableRelation = "Actividad proveedor"."No. actividad" WHERE("No. proveedor" = FIELD("Pay-to Vendor No."),
                                                                         "Tipo actividad" = FILTER(Actividad));
                }
            }
        }
    }
}