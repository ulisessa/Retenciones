pageextension 256 "Withholdings in Payments" extends "Payment Journal"
{
    layout
    {
        addafter(Control1)
        {
            part(PurchInvLines; "Posted Invoice Purchase Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("Applies-to Doc. No.");
                Visible = blnFac;
            }
        }
        addafter(Control1)
        {
            part(PurchCMLines; "Posted CM Purchase Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("Applies-to Doc. No.");
                Visible = blnNC;
            }
        }
        modify(AppliesToDocNo)
        {
            trigger OnAfterAfterLookup(Selected: RecordRef)
            var
                myInt: Integer;
            begin

            end;
        }
    }
    actions
    {
        addlast(Creation)
        {
            group(Category4)
            {
                Caption = 'Withholdings';
                Image = TaxPayment;
                ToolTip = 'Actions over withholdings to perform on this payment. ';
                Visible = true;

                action(Calculate)
                {
                    ApplicationArea = All;
                    Caption = 'Calculate';
                    Image = "Calculate";
                    ToolTip = 'Calculate the withholdings for this payment. ';

                    trigger OnAction()
                    var
                        l_rstLinDiaGen: Record "Gen. Journal Line";
                    begin
                        CurrPage.SetSelectionFilter(l_rstLinDiaGen);
                        l_rstLinDiaGen.FindFirst;
                        GenerarLinRetencion(l_rstLinDiaGen, false);
                        VerificarFechaReproweb;
                    end;
                }
            }
        }
        addfirst(Category_Category4)
        {
            actionref(Calculate_Promoted; Calculate)
            {
            }
        }
        modify(Category_Category4)
        {
            Caption = 'Withholdings';
        }
        modify(Category_New)
        {
            Caption = 'New';
        }
        modify(Category_Process)
        {
            Caption = 'Process';
        }
        modify(Category_Report)
        {
            Caption = 'Report';
        }
        // Add changes to page actions here
    }

    [Scope('OnPrem')]
    procedure VerificarFechaReproweb(): Boolean
    var
        rstLinDiaGen: Record "Gen. Journal Line";
        rstAreaImpuesto: Record "Tax Area";
        rstCI: Record "Company Information";
        rstGLS: Record "General Ledger Setup";
        l_codMes: Text[2];
        l_codYear: Text[4];
        l_cduWS: Codeunit "WS - AFIP";
        rstProveedor: Record Vendor;
    begin
        Clear(rstCI);
        rstCI.Get();

        if rstCI."Ag. Retencion IVA" then begin

            Clear(rstLinDiaGen);
            rstLinDiaGen.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Account Type");
            rstLinDiaGen.SetRange("Journal Template Name", "Journal Template Name");
            rstLinDiaGen.SetRange("Journal Batch Name", "Journal Batch Name");
            rstLinDiaGen.SetRange("Account Type", rstLinDiaGen."Account Type"::Vendor);
            if rstLinDiaGen.Find('-') then begin

                Clear(rstProveedor);
                rstProveedor.SetFilter("No.", rstLinDiaGen."Account No.");
                if rstProveedor.FindFirst then;
                Clear(rstAreaImpuesto);
                if rstAreaImpuesto.Get(rstProveedor."Tax Area Code") then begin

                    if rstAreaImpuesto."Importar Reproweb" then begin

                        if (rstProveedor."Fecha consulta Reproweb" < rstLinDiaGen."Posting Date") and (not rstProveedor."Omitir validación WS-AFIP") then begin

                            Clear(rstGLS);
                            rstGLS.Get();
                            if rstGLS."WS - Reproweb Dimension" <> '' then begin

                                l_codMes := Format(Date2DMY(Today, 2));
                                l_codYear := Format(Date2DMY(Today, 3));
                                if StrLen(l_codMes) = 1 then
                                    l_codMes := '0' + l_codMes;
                                l_cduWS.fntReprowebIndividual('wsagr', DelChr(rstCI."VAT Registration No.", '=', '-'), DelChr(rstProveedor."VAT Registration No.", '=', '-'), l_codMes + '/' + l_codYear);

                            end
                            else begin

                                Message('Debe realizar la consulta Reproweb para registrar este pago (Proveedor ' + Format(rstProveedor."No.") + ')');
                                exit(false);

                            end;

                        end;

                    end;

                end;

            end;

        end;

        Clear(rstLinDiaGen);
        rstLinDiaGen.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Account Type");
        rstLinDiaGen.SetRange("Journal Template Name", "Journal Template Name");
        rstLinDiaGen.SetRange("Journal Batch Name", "Journal Batch Name");
        rstLinDiaGen.SetRange("Account Type", rstLinDiaGen."Account Type"::Vendor);
        if rstLinDiaGen.Find('-') then begin

            Clear(rstProveedor);
            rstProveedor.SetFilter("No.", rstLinDiaGen."Account No.");
            if rstProveedor.FindFirst then;
            Clear(rstAreaImpuesto);
            rstAreaImpuesto.Get(rstProveedor."Tax Area Code");
            if rstAreaImpuesto."Realizar consulta constancia" then begin

                if (rstProveedor."Fecha Consulta" < rstLinDiaGen."Posting Date") and (not rstProveedor."Omitir validación WS-AFIP") then begin

                    Clear(rstGLS);
                    rstGLS.Get();
                    if rstGLS."WS - CUIT Check Dimension" <> '' then
                        l_cduWS.fntPersonaService5('ws_sr_constancia_inscripcion', DelChr(rstCI."VAT Registration No.", '=', '-'), DelChr(rstProveedor."VAT Registration No.", '=', '-'), '', rstProveedor)
                    else begin

                        Message('Debe digitalizar la constancia de inscripción en AFIP correspondiente para registrar este pago ' +
                                '(Proveedor ' + Format(rstProveedor."No.") + ')');
                        exit(false);

                    end;

                end;

            end;

        end;

        exit(true);
    end;

    [Scope('OnPrem')]
    procedure CopiarConceptoGeneral()
    var
        rstLinDiaGeneral: Record "Gen. Journal Line";
        strConceptoGral: Text[250];
    begin
        Clear(rstLinDiaGeneral);
        rstLinDiaGeneral.SetRange("Journal Template Name", "Journal Template Name");
        rstLinDiaGeneral.SetRange("Journal Batch Name", "Journal Batch Name");
        if rstLinDiaGeneral.Find('-') then
            repeat

                rstLinDiaGeneral."Concepto general" := strConceptoGral;
                rstLinDiaGeneral.Modify;

            until rstLinDiaGeneral.Next = 0;
    end;

    local procedure OnAfterGetCurrRecordB()
    begin
        xRec := Rec;
        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
        UpdateBalance;
    end;

    [Scope('OnPrem')]
    procedure LiquidarporDoc()
    var
        NroLinea: Integer;
        NroLinea1: Integer;
        movprov: Record "Vendor Ledger Entry";
        lindiagen: Record "Gen. Journal Line";
        lindiagen1: Record "Gen. Journal Line";
    begin
        Clear(movprov);
        movprov.SetCurrentKey("Vendor No.", movprov."Applies-to ID");
        movprov.SetRange(movprov."Vendor No.", "Account No.");
        movprov.SetRange(movprov."Applies-to ID", "Document No.");

        if movprov.Count > 0 then begin
            Clear(lindiagen);

            lindiagen.SetRange(lindiagen."Journal Template Name", 'PAGO');
            lindiagen.SetRange(lindiagen."Journal Batch Name", CurrentJnlBatchName);
            if lindiagen.Find('+') then
                NroLinea := lindiagen."Line No.";

            if movprov.Find('-') then
                repeat
                    Clear(lindiagen1);
                    lindiagen1.SetRange(lindiagen1."Journal Template Name", 'PAGO');
                    lindiagen1.SetRange(lindiagen1."Journal Batch Name", CurrentJnlBatchName);
                    lindiagen1.SetRange(lindiagen1."Applies-to Doc. No.", movprov."Document No.");

                    movprov.CalcFields("Remaining Amount");
                    if not lindiagen1.Find('-') then begin
                        NroLinea := NroLinea + 100;
                        lindiagen.Init;
                        lindiagen.TransferFields(Rec);
                        lindiagen."Line No." := NroLinea;
                        lindiagen.Validate("Debit Amount", 0);
                        lindiagen.Validate("Credit Amount", 0);
                        lindiagen.Validate(lindiagen."Applies-to Doc. No.", movprov."Document No.");
                        lindiagen.Validate(lindiagen."Applies-to ID", '');
                        lindiagen.Validate(lindiagen."Shortcut Dimension 1 Code", movprov."Global Dimension 1 Code");
                        lindiagen.Validate(lindiagen."Shortcut Dimension 2 Code", movprov."Global Dimension 2 Code");
                        lindiagen.Validate(lindiagen."Shortcut Dimension 3 Code", movprov."Global dimension 3 Code");
                        lindiagen.Validate(lindiagen."Shortcut Dimension 4 Code", movprov."Global Dimension 4 Code");
                        lindiagen.Validate(lindiagen."Shortcut Dimension 5 Code", movprov."Global Dimension 5 Code");
                        lindiagen.Validate(lindiagen."Shortcut Dimension 6 Code", movprov."Global Dimension 6 Code");
                        lindiagen.Validate(lindiagen."Shortcut Dimension 7 Code", movprov."Global Dimension 7 Code");
                        if movprov."Remaining Amount" < 0 then begin
                            lindiagen.Validate("Debit Amount", Abs(movprov."Remaining Amount"));
                            lindiagen.Validate(lindiagen."Applies-to Doc. Type", lindiagen."Applies-to Doc. Type"::Invoice);
                        end
                        else begin
                            lindiagen.Validate(lindiagen."Applies-to Doc. Type", lindiagen."Applies-to Doc. Type"::"Credit Memo");
                            lindiagen.Validate("Credit Amount", Abs(movprov."Remaining Amount"));
                        end;
                        lindiagen.Insert;
                    end;
                until movprov.Next = 0;
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SubPageVisible(Rec);
    end;

    local procedure SubPageVisible(p_rstLinDiaGen: Record "Gen. Journal Line")
    begin
        blnFac := p_rstLinDiaGen."Applies-to Doc. Type" = p_rstLinDiaGen."Applies-to Doc. Type"::Invoice;
        blnNC := p_rstLinDiaGen."Applies-to Doc. Type" = p_rstLinDiaGen."Applies-to Doc. Type"::"Credit Memo";
    end;

    var
        blnFac: Boolean;
        blnNC: Boolean;
}