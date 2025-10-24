pageextension 256 "Withholdings in Payments" extends "Payment Journal"
{
    layout
    {
        addafter(Control1)
        {
            group(DocLines)
            {
                Caption = '';
                part(PurchInvLines; "Posted Invoice Purchase Lines")
                {
                    Caption = 'Posted Invoice Purchase Lines';
                    ApplicationArea = All;
                    SubPageLink = "Document No." = field("Applies-to Doc. No.");
                    Visible = blnFac;
                    Enabled = blnFac;
                }
                part(PurchCMLines; "Posted CM Purchase Lines")
                {
                    Caption = 'Posted CM Purchase Lines';
                    ApplicationArea = All;
                    SubPageLink = "Document No." = field("Applies-to Doc. No.");
                    Visible = blnNC;
                    Enabled = blnNC;
                }
            }
        }

        addafter(DocLines)
        {
            group(WithLines)
            {
                Caption = '';
                part(BufferRetenciones; "Lista Retenciones")
                {
                    ApplicationArea = All;
                    SubPageView = sorting("No. documento", "Cod. retencion");
                    SubPageLink = "No. documento" = field("Document No."), "Fecha pago" = field("Posting Date");
                    Visible = blnRetCalc;
                    Enabled = blnRetCalc;
                    Editable = false;
                }

            }
        }
        modify(AppliesToDocNo)
        {
            AssistEdit = true;
            trigger OnDrillDown()
            begin

                if "Applies-to Doc. Type" = "Applies-to Doc. Type"::Invoice then begin

                    Clear(rstCabCompra);
                    Clear(frmCabCompra);
                    rstCabCompra.SetRange(rstCabCompra."No.", "Applies-to Doc. No.");
                    frmCabCompra.SetTableView(rstCabCompra);
                    frmCabCompra.RunModal;

                end;

                if "Applies-to Doc. Type" = "Applies-to Doc. Type"::"Credit Memo" then begin

                    Clear(rstCabCompraNC);
                    Clear(frmCabCompraNC);
                    rstCabCompraNC.SetRange(rstCabCompraNC."No.", "Applies-to Doc. No.");
                    frmCabCompraNC.SetTableView(rstCabCompraNC);
                    frmCabCompraNC.RunModal;

                end;
            end;
        }

    }
    actions
    {
        /*
        modify(ApplyEntries)
        {
            Visible = false;
        }
        */
        modify(Post)
        {
            Visible = false;
        }
        modify("Post and &Print")
        {
            Visible = false;
        }
        addafter(PreviewCheck)
        {
            action("Registrar e &imprimir")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Post and &Print';
                Image = PostPrint;
                ShortCutKey = 'Shift+F9';
                ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';
                trigger OnAction()
                var
                    codDoc: Text;
                    cduRegistro: Codeunit "Retenciones";
                    l_rstLinDiaGen: Record "Gen. Journal Line";
                    l_rstLinDiaGen2: Record "Gen. Journal Line";
                    codDocActual: Code[20];
                    l_rstGLRegister: Record "G/L Register";
                    matDoc: array[1000] of Code[20];
                    i: Integer;
                    j: Integer;
                    GLReg: Record "G/L Register";
                    rptOP: Report "Orden pago";
                    rstMovCont: Record "G/L Entry";
                    intGLReg: Integer;
                    rstReporteSS: Report "Certificado Retención SS";
                    rstReporteIVA: Report "Certificado Retención IVA";
                    rstReporteGAN: Report "Certificado Retención Ganancia";
                    k: Integer;
                    rstReporteIIBB: Report "Certificado Retención IIBB";
                    rstPS: Record "Purchases & Payables Setup";
                    l: Integer;
                begin
                    //++Migración Arbumasa 2009
                    if not VerificarFechaReproweb then
                        Error('Se ha detenido el proceso');


                    Clear(l_rstLinDiaGen2);
                    l_rstLinDiaGen2.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Document No.");
                    l_rstLinDiaGen2.SetRange("Journal Template Name", "Journal Template Name");
                    l_rstLinDiaGen2.SetRange("Journal Batch Name", "Journal Batch Name");
                    if l_rstLinDiaGen2.FindSet then
                        repeat

                            if codDoc = '' then begin

                                i += 1;
                                codDocActual := l_rstLinDiaGen2."Document No.";
                                codDoc := l_rstLinDiaGen2."Document No.";
                                matDoc[i] := codDocActual;
                                GenerarLinRetencion(l_rstLinDiaGen2, false);

                            end
                            else begin

                                if codDocActual <> l_rstLinDiaGen2."Document No." then begin

                                    i += 1;
                                    codDocActual := l_rstLinDiaGen2."Document No.";
                                    codDoc := codDoc + '|' + codDocActual;
                                    matDoc[i] := codDocActual;
                                    GenerarLinRetencion(l_rstLinDiaGen2, false);

                                end;

                            end;

                        until l_rstLinDiaGen2.Next = 0;

                    //--Migración Arbumasa 2009

                    Clear(GLReg);
                    GLReg.LockTable;
                    GLReg.FindLast;
                    intGLReg := 0;
                    intGLReg := GLReg."No.";

                    Rec.SendToPosting(Codeunit::"Gen. Jnl.-Post+Print");
                    CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
                    CurrPage.Update(false);

                    for j := 1 to i do begin

                        matDoc[j] := '';

                    end;

                    j := 0;
                    i := 0;
                    codDoc := '';

                    Clear(GLReg);
                    GLReg.SetFilter("No.", '>%1', intGLReg);
                    if GLReg.FindSet then
                        repeat

                            if codDoc = '' then begin

                                i += 1;
                                codDocActual := GLReg."No. documento";
                                codDoc := GLReg."No. documento";
                                matDoc[i] := codDocActual;

                            end
                            else begin

                                if codDocActual <> GLReg."No. documento" then begin

                                    i += 1;
                                    codDocActual := GLReg."No. documento";
                                    codDoc := codDoc + '|' + codDocActual;
                                    matDoc[i] := codDocActual;

                                end;

                            end;

                            cduRegistro.fntRenumerarRetenciones(GLReg."No. documento");

                        until GLReg.Next = 0;

                    //++Migración Arbumasa 2009

                    cduRegistro.fntNroSerieRetenciones(codDoc);

                    Commit;

                    for j := 1 to i do begin

                        Clear(l_rstGLRegister);
                        l_rstGLRegister.SetFilter(l_rstGLRegister."No. documento", matDoc[j]);

                        Clear(rstPS);
                        rstPS.Get;
                        if rstPS."Cantidad OP a imprimir" = 0 then begin

                            rstPS."Cantidad OP a imprimir" := 1;
                            rstPS.Modify;

                        end;
                        if rstPS."Cantidad impresos retenciones" = 0 then begin
                            rstPS."Cantidad impresos retenciones" := 1;
                            rstPS.Modify;
                        end;

                        for l := 1 to rstPS."Cantidad OP a imprimir" do begin

                            Clear(rptOP);
                            rptOP.SetTableView(l_rstGLRegister);
                            rptOP.fntDoc(matDoc[j]);

                            rptOP.UseRequestPage(false);
                            rptOP.Run();

                        end;

                        for k := 1 to rstPS."Cantidad impresos retenciones" do begin

                            Clear(rstFacturaRTBaseBuffer);
                            rstFacturaRTBaseBuffer.SetFilter(rstFacturaRTBaseBuffer."No. documento", matDoc[j]);
                            rstFacturaRTBaseBuffer.SetRange("Tipo retencion", rstFacturaRTBaseBuffer."Tipo retencion"::"Seguridad Social");
                            rstFacturaRTBaseBuffer.SetRange(Retenido, true);
                            if rstFacturaRTBaseBuffer.FindSet then begin

                                Clear(rstReporteSS);
                                rstReporteSS.UseRequestPage(false);
                                rstReporteSS.SetTableView(rstFacturaRTBaseBuffer);
                                rstReporteSS.Run;

                            end;

                            Clear(rstFacturaRTBaseBuffer);
                            rstFacturaRTBaseBuffer.SetFilter(rstFacturaRTBaseBuffer."No. documento", matDoc[j]);
                            rstFacturaRTBaseBuffer.SetRange("Tipo retencion", rstFacturaRTBaseBuffer."Tipo retencion"::IVA);
                            rstFacturaRTBaseBuffer.SetRange(Retenido, true);
                            if rstFacturaRTBaseBuffer.FindSet then begin

                                Clear(rstReporteIVA);
                                rstReporteIVA.UseRequestPage(false);
                                rstReporteIVA.SetTableView(rstFacturaRTBaseBuffer);
                                rstReporteIVA.Run;

                            end;

                            Clear(rstFacturaRTBaseBuffer);
                            rstFacturaRTBaseBuffer.SetFilter(rstFacturaRTBaseBuffer."No. documento", matDoc[j]);
                            rstFacturaRTBaseBuffer.SetRange("Tipo retencion", rstFacturaRTBaseBuffer."Tipo retencion"::Ganancias);
                            rstFacturaRTBaseBuffer.SetRange(Retenido, true);
                            if rstFacturaRTBaseBuffer.FindSet then begin

                                Clear(rstReporteGAN);
                                rstReporteGAN.UseRequestPage(false);
                                rstReporteGAN.SetTableView(l_rstGLRegister);
                                rstReporteGAN.Run;

                            end;

                            Clear(rstFacturaRTBaseBuffer);
                            rstFacturaRTBaseBuffer.SetFilter(rstFacturaRTBaseBuffer."No. documento", matDoc[j]);
                            rstFacturaRTBaseBuffer.SetRange("Tipo retencion", rstFacturaRTBaseBuffer."Tipo retencion"::"Ingresos Brutos");
                            rstFacturaRTBaseBuffer.SetRange(Retenido, true);
                            if rstFacturaRTBaseBuffer.FindSet then begin

                                Clear(rstReporteIIBB);
                                rstReporteIIBB.UseRequestPage(false);
                                rstReporteIIBB.SetTableView(l_rstGLRegister);
                                rstReporteIIBB.Run;

                            end;

                        end;

                    end;

                    //--Migración Arbumasa 2009

                    CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                    CurrPage.Update(false);
                end;
            }
        }
        addafter("Renumber Document Numbers")
        {
            action(PostCustom)
            {
                Caption = 'P&ost';
                Image = PostOrder;
                ShortCutKey = 'F9';

                trigger OnAction()
                var
                    codDoc: Text;
                    cduRegistro: Codeunit "Retenciones";
                    l_rstLinDiaGen: Record "Gen. Journal Line";
                    l_rstLinDiaGen2: Record "Gen. Journal Line";
                    codDocActual: Text;
                begin
                    //++Migración Arbumasa 2009
                    if not VerificarFechaReproweb then
                        Error('Se ha detenido el proceso');

                    Clear(l_rstLinDiaGen2);
                    l_rstLinDiaGen2.SetRange("Journal Template Name", "Journal Template Name");
                    l_rstLinDiaGen2.SetRange("Journal Batch Name", "Journal Batch Name");
                    if l_rstLinDiaGen2.FindSet then
                        repeat

                            if codDoc = '' then begin

                                codDocActual := l_rstLinDiaGen2."Document No.";
                                codDoc := l_rstLinDiaGen2."Document No.";
                                GenerarLinRetencion(l_rstLinDiaGen2, false);

                            end
                            else begin

                                //IF codDocActual <> l_rstLinDiaGen2."Document No." THEN
                                if StrPos(codDoc, l_rstLinDiaGen2."Document No.") = 0 then begin

                                    codDocActual := l_rstLinDiaGen2."Document No.";
                                    codDoc := codDoc + '|' + codDocActual;
                                    GenerarLinRetencion(l_rstLinDiaGen2, false);

                                end;

                            end;

                        until l_rstLinDiaGen2.Next = 0;

                    //--Migración Arbumasa 2009

                    CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post", Rec);

                    //++Migración Arbumasa 2009
                    cduRegistro.fntNroSerieRetenciones(codDoc);
                    //--Migración Arbumasa 2009

                    CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                    CurrPage.Update(false);
                end;
            }
        }
        addafter("P&osting")
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
                action("Imprimir Transacción")
                {
                    Caption = 'Print Transaction';
                    Image = PrintReport;

                    trigger OnAction()
                    var
                        l_rstLinDiaGen: Record "Gen. Journal Line";
                        l_rstOrdenPago: Report "Orden pago test";
                    begin
                        CurrPage.SetSelectionFilter(l_rstLinDiaGen);
                        l_rstLinDiaGen.FindFirst;
                        l_rstOrdenPago.SetTableView(l_rstLinDiaGen);
                        //l_rstOrdenPago.UseRequestPage(false);
                        l_rstOrdenPago.Run();
                    end;
                }
            }
        }
        addbefore("Renumber Document Numbers_Promoted")
        {
            actionref(CalcularRetenciones_Promoted; Calculate)
            {
            }
            actionref(ImprimirTransaccion_Promoted; "Imprimir Transacción")
            {
            }
        }
        addafter(Post_Promoted)
        {

            actionref(PostCustom_Promoted; PostCustom)
            {
            }

            actionref(PostPrintCustom_Promoted; "Registrar e &imprimir")
            {
            }
        }
        /*
        addafter("Renumber Document Numbers_Promoted")
        {
            actionref(ApplyEntriesCustom_Promoted; ApplyEntriesCustom)
            {
            }
        }
        */
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

    trigger OnDeleteRecord(): Boolean
    var
        rst17: Record "Gen. Journal Line";
        rstBufferRetenciones: Record "Invoice Withholding Buffer";
    begin
        CLEAR(rst17);
        rst17.SETRANGE("Document No.", "Document No.");
        IF NOT rst17.FINDFIRST THEN BEGIN

            CLEAR(rstBufferRetenciones);
            rstBufferRetenciones.SETRANGE(rstBufferRetenciones."No. documento", "Document No.");
            rstBufferRetenciones.DELETEALL;

        END;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SubPageVisible(Rec);
    end;

    local procedure SubPageVisible(p_rstLinDiaGen: Record "Gen. Journal Line")
    var
        IWB: Record "Invoice Withholding Buffer";
    begin
        blnFac := p_rstLinDiaGen."Applies-to Doc. Type" = p_rstLinDiaGen."Applies-to Doc. Type"::Invoice;
        blnNC := p_rstLinDiaGen."Applies-to Doc. Type" = p_rstLinDiaGen."Applies-to Doc. Type"::"Credit Memo";
        Clear(IWB);
        IWB.SetRange("No. documento", p_rstLinDiaGen."Document No.");
        IWB.SetRange("Fecha pago", p_rstLinDiaGen."Posting Date");
        blnRetCalc := NOT IWB.IsEmpty;
    end;

    local procedure SetJobQueueVisibility()
    var
        JobQueuesUsed: Boolean;
        JobQueueVisible: Boolean;
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        JobQueueVisible := Rec."Job Queue Status" = Rec."Job Queue Status"::"Scheduled for Posting";
        JobQueuesUsed := GeneralLedgerSetup.JobQueueActive();
    end;


    var
        blnFac: Boolean;
        blnNC: Boolean;
        blnRetCalc: Boolean;
        rstCabCompra: Record "Purch. Inv. Header";
        frmCabCompra: Page "Posted Purchase Invoice";
        rstCabCompraNC: Record "Purch. Cr. Memo Hdr.";
        frmCabCompraNC: Page "Posted Purchase Credit Memo";
        rstFacturaRTBaseBuffer: Record "Invoice Withholding Buffer";
        codLibro: Code[20];
        codSeccion: Code[20];

}