page 50579 "Record Links"
{
    PageType = List;
    SourceTable = "Record Link";
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Record Links';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Note; Note)
                {

                    trigger OnAssistEdit()
                    var
                        BLOBRef: Codeunit "Temp Blob";
                        FileMgt: Codeunit "File Management";
                        strRetenidoSRV: Text;
                    begin
                        Clear(BLOBRef);

                        strRetenidoSRV := FileMgt.ServerTempFileName('txt');
                        //FileMgt.BLOBExport(BLOBRef, strRetenidoSRV, true);
                        Rec.Note.Export(strRetenidoSRV);
                    end;
                }
                field(Created; Created)
                {
                }
                field("User ID"; "User ID")
                {
                }
                field(Company; Company)
                {
                }
                field(Notify; Notify)
                {
                }
                field("To User ID"; "To User ID")
                {
                }
            }
        }
    }

    actions
    {
    }
}

