pageextension 50036 VATBusGroup extends "VAT Business Posting Groups"
{
    layout
    {
        addafter("Description")
        {
            field("Tipo cálculo acumulado"; "Tipo cálculo acumulado")
            {
                Caption = 'Tipo cálculo acumulado';
                ApplicationArea = All;
            }
            field("Withhold Even if Agent"; "Withhold Even if Agent")
            {
                Caption = 'Withhold Even if Agent';
                ApplicationArea = All;
            }
            field("Importar Reproweb"; "Importar Reproweb")
            {
                Caption = 'Importar Reproweb';
                ApplicationArea = All;
            }
        }
    }
}
