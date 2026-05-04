tableextension 51374 "Extend GL Setup" extends "General Ledger Setup"
{
    fields
    {
        field(50720; "ARCA Tax Responsible Type Path"; Text[250])
        {
            Caption = 'ARCA Tax Responsible Type Path';
            DataClassification = ToBeClassified;
            ExtendedDataType = URL;
        }
        field(50721; "ARCA Document Types Path"; Text[250])
        {
            Caption = 'ARCA Document Types Path';
            DataClassification = ToBeClassified;
            ExtendedDataType = URL;
        }
    }

}