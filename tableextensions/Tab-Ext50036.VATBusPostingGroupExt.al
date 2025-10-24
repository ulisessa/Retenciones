tableextension 50036 "VAT Bus. Posting Group Ext" extends "VAT Business Posting Group"
{
    fields
    {
        field(50000; "Tipo cálculo acumulado"; Enum "Tipo cálculo acumulado")
        {
            Caption = 'Tipo cálculo acumulado';
            DataClassification = ToBeClassified;
        }
        field(50001; "Withhold Even if Agent"; Boolean)
        {
            Caption = 'Withhold Even if Agent';
            DataClassification = ToBeClassified;
        }
    }
}
