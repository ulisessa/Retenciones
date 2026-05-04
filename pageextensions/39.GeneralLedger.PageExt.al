pageextension 50319 "Add Fields to General Journal" extends "General Journal"
{
    layout
    {
        // Add changes to page layout here
        addbefore("Currency Code")
        {
            field("Additional-Currency Posting"; "Additional-Currency Posting")
            {
                ApplicationArea = All;
                Caption = 'Additional-Currency Posting';
                Editable = true;
            }
        }
    }
    actions
    {
        // Add changes to page actions here
    }
}