table 50015 "ARCA Document Types"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[3])
        {
            DataClassification = ToBeClassified;
            Caption = 'Code';
        }
        field(2; Description; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';
        }
        field(3; "Last updated"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Last updated';
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

}