pageextension 50320 "Add Fields to GL Register" extends "G/L Registers"
{
    layout
    {
        addafter("No.")
        {
            field("Document No."; "No. documento")
            {
                ApplicationArea = All;
                Caption = 'Document No.';
                Editable = true;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
}