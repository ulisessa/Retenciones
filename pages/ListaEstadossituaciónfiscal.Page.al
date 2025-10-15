page 50011 "Lista Estados situación fiscal"
{
    PageType = List;
    SourceTable = "Acción estado sit. fiscal";
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Lista Estados situación fiscal';
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Estado de Situación fiscal"; "Estado de Situación fiscal")
                {
                }
                field("Descripción"; Descripción)
                {
                }
                field("Acción exclusión"; "Acción exclusión")
                {
                }
                field("Acción retención"; "Acción retención")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if CurrPage.LookupMode = true then
            CurrPage.Editable(false);
    end;
}

