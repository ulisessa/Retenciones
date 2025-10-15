tableextension 50035 "Withholding Setup changes" extends "Withholding setup"
{
    fields
    {
        field(14; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = ToBeClassified;
            TableRelation = "VAT Business Posting Group".Code;
        }
    }
}
