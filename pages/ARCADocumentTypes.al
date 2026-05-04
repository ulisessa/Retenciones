page 50004 "ARCA Document Types"
{
    ApplicationArea = All;
    Caption = 'ARCA Document Types';
    PageType = List;
    SourceTable = "ARCA Document Types";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    Caption = 'Code';
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Last updated"; Rec."Last updated")
                {
                    Caption = 'Last updated';
                    ToolTip = 'Specifies the value of the Last updated field.', Comment = '%';
                }
            }
        }
    }
}
