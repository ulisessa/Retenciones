pageextension 50033 ARCAActExt extends "Lista actividad AFIP"
{
    layout
    {
        addlast(Group)
        {
            field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
            {
                ApplicationArea = All;
                Caption = 'VAT Bus. Posting Group';
                ToolTip = 'Specifies the VAT Business Posting Group for the activity.';

                trigger OnValidate()
                var
                    lblError: Label 'Only activities of type "Tax" can have a VAT Business Posting Group.';
                begin
                    If "Tipo actividad" <> "Tipo actividad"::Impuesto then
                        Error(lblError);
                end;
            }
        }
    }
}
