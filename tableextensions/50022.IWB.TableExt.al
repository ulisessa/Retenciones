tableextension 51373 "Transaction in Withholdings" extends "Invoice Withholding Buffer"
{
    fields
    {
        // Add changes to table fields here
        field(50025; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }
}