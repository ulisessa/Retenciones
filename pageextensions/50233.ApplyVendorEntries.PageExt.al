pageextension 50233 "Apply Entries In Journal" extends "Apply Vendor Entries"
{
    layout
    {
        addafter(General)
        {
            grid(DiarioDestino)
            {
                ShowCaption = false;
                field(codLibro; codLibro)
                {
                    Caption = 'Libro diario';
                    TableRelation = "Gen. Journal Template" WHERE(Type = CONST(Payments));
                }
                field(codSeccion; codSeccion)
                {
                    Caption = 'Sección diario';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        pgeBatch: Page "General Journal Batches";
                        rstBatch: Record "Gen. Journal Batch";
                    begin
                        //++Migración Arbumasa 2009
                        Clear(rstBatch);
                        rstBatch.SetRange(rstBatch."Journal Template Name", codLibro);
                        if rstBatch.FindSet then begin

                            Clear(pgeBatch);
                            pgeBatch.SetTableView(rstBatch);
                            if pgeBatch.RunModal = ACTION::LookupOK then begin

                                pgeBatch.GetRecord(rstBatch);
                                codSeccion := rstBatch.Name;

                            end;

                        end;
                        //--Migración Arbumasa 2009
                    end;
                }
            }
        }
    }

    actions
    {
        addbefore(Navigate)
        {
            action(TraerSeleccionados)
            {
                Caption = 'Llevar a diario';
                Image = ChangeToLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    TraerSeleccionados();
                end;
            }
            action(PaymentBLock)
            {
                Caption = 'Payment block';
                Image = StopPayment;

                trigger OnAction()

                begin
                    PaymentBLock();
                end;
            }
        }
    }

    local procedure TraerSeleccionados()
    var
        l_rstLinDiaGen: Record "Gen. Journal Line";
        l_txtConfirmar: Label 'Se eliminarán todas las líneas preexistentes en el diario y sección especificados. ¿Desea continuar?';
        l_i: Integer;
        dlgDialogo: Dialog;
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlAlloc: Record "Gen. Jnl. Allocation";
        NoSeriesMgt: Codeunit "No. Series";
        rstNC: Record "Purch. Cr. Memo Hdr.";
        rstCCL: Record "Vendor Ledger Entry";
        rstCCL2: Record "Vendor Ledger Entry";
        rstCCL3: Record "Vendor Ledger Entry";

    begin
        if (codLibro <> '') and (codSeccion <> '') then begin
            Clear(dlgDialogo);
            dlgDialogo.Open('Generando línea #1############# de #2#############\' +
                            '                              @3@@@@@@@@@@@@@@@@@@@@@');
            dlgDialogo.Update(2, Rec.Count);

            Clear(l_rstLinDiaGen);
            if Confirm(l_txtConfirmar) then begin

                l_rstLinDiaGen.SetRange("Journal Template Name", codLibro);
                l_rstLinDiaGen.SetRange("Journal Batch Name", codSeccion);
                l_rstLinDiaGen.DeleteAll;

                Clear(l_rstLinDiaGen);

                SetRange("Applies-to ID", GenJnlLine."Document No.");

                if Rec.FindSet then
                    repeat
                        if "Document Type" = "Document Type"::"Credit Memo" then
                            Error('Por favor, no seleccione Notas de Crédito para ingresar en el Diario, aplíquelas previamente desde la Cuenta Corriente del proveedor.');
                        l_i += 10000;
                        dlgDialogo.Update(1, l_i / 10000);
                        dlgDialogo.Update(3, Round(l_i / Rec.Count, 1));
                        l_rstLinDiaGen."Journal Template Name" := codLibro;
                        l_rstLinDiaGen."Journal Batch Name" := codSeccion;
                        l_rstLinDiaGen."Document No." := "Applies-to ID";
                        l_rstLinDiaGen."Line No." := l_i;
                        l_rstLinDiaGen.Insert(true);
                        l_rstLinDiaGen.Validate("Account Type", l_rstLinDiaGen."Account Type"::Vendor);
                        l_rstLinDiaGen.Validate("Account No.", "Vendor No.");
                        l_rstLinDiaGen.Validate("Posting Date", "Posting Date");
                        l_rstLinDiaGen.Validate("Document Type", l_rstLinDiaGen."Document Type"::Payment);
                        l_rstLinDiaGen.Validate("Applies-to Doc. Type", "Document Type");
                        l_rstLinDiaGen.Validate("Applies-to Doc. No.", "Document No.");
                        l_rstLinDiaGen.Validate("Account No.", "Vendor No.");
                        l_rstLinDiaGen.Validate("Currency Code", "Currency Code");
                        if l_rstLinDiaGen."Currency Code" = '' then
                            l_rstLinDiaGen."Currency Code" := l_rstLinDiaGen."Currency Code"
                        else
                            l_rstLinDiaGen.Validate("Currency Factor", "Original Currency Factor");
                        l_rstLinDiaGen.Validate(Amount, -"Remaining Amount");
                        if (l_rstLinDiaGen."Shortcut Dimension 1 Code" = '') AND ("Global Dimension 1 Code" <> '') then
                            l_rstLinDiaGen.Validate("Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                        if (l_rstLinDiaGen."Shortcut Dimension 2 Code" = '') AND ("Global Dimension 2 Code" <> '') then
                            l_rstLinDiaGen.Validate("Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                        if (l_rstLinDiaGen."Shortcut Dimension 3 Code" = '') AND ("Global Dimension 3 Code" <> '') then
                            l_rstLinDiaGen.Validate("Shortcut Dimension 3 Code", "Global Dimension 3 Code");
                        if (l_rstLinDiaGen."Shortcut Dimension 4 Code" = '') AND ("Global Dimension 4 Code" <> '') then
                            l_rstLinDiaGen.Validate("Shortcut Dimension 4 Code", "Global Dimension 4 Code");
                        if (l_rstLinDiaGen."Shortcut Dimension 5 Code" = '') AND ("Global Dimension 5 Code" <> '') then
                            l_rstLinDiaGen.Validate("Shortcut Dimension 5 Code", "Global Dimension 5 Code");
                        if (l_rstLinDiaGen."Shortcut Dimension 6 Code" = '') AND ("Global Dimension 6 Code" <> '') then
                            l_rstLinDiaGen.Validate("Shortcut Dimension 6 Code", "Global Dimension 6 Code");
                        if (l_rstLinDiaGen."Shortcut Dimension 7 Code" = '') AND ("Global Dimension 7 Code" <> '') then
                            l_rstLinDiaGen.Validate("Shortcut Dimension 7 Code", "Global Dimension 7 Code");
                        l_rstLinDiaGen.Modify(true);
                        Clear(rstCCL2);
                        rstCCL2.SetRange("Closed by Entry No.", "Entry No.");
                        if rstCCL2.FindSet then
                            repeat
                                if (rstCCL2."Document Type" = rstCCL2."Document Type"::"Credit Memo") and (rstCCL."Document No." <> rstCCL2."Document No.") then begin
                                    l_i += 10000;
                                    dlgDialogo.Update(1, l_i / 10000);
                                    dlgDialogo.Update(3, Round(l_i / Rec.Count, 1));
                                    l_rstLinDiaGen."Journal Template Name" := codLibro;
                                    l_rstLinDiaGen."Journal Batch Name" := codSeccion;
                                    l_rstLinDiaGen."Line No." := l_i;
                                    l_rstLinDiaGen.Insert(true);
                                    l_rstLinDiaGen.Validate("Account Type", l_rstLinDiaGen."Account Type"::Vendor);
                                    l_rstLinDiaGen.Validate("Account No.", "Vendor No.");
                                    l_rstLinDiaGen.Validate("Posting Date", "Posting Date");
                                    l_rstLinDiaGen.Validate("Document Type", l_rstLinDiaGen."Document Type"::Payment);
                                    l_rstLinDiaGen.Validate("Applies-to Doc. Type", l_rstLinDiaGen."Document Type"::"Credit Memo");
                                    l_rstLinDiaGen.Validate("Applies-to Doc. No.", rstCCL2."Document No.");
                                    l_rstLinDiaGen.Validate("Account No.", "Vendor No.");
                                    l_rstLinDiaGen.Validate(Amount, 0);
                                    l_rstLinDiaGen."Allow Zero-Amount Posting" := true;
                                    if l_rstLinDiaGen."Shortcut Dimension 1 Code" = '' then
                                        l_rstLinDiaGen.Validate("Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                                    if l_rstLinDiaGen."Shortcut Dimension 2 Code" = '' then
                                        l_rstLinDiaGen.Validate("Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                                    if l_rstLinDiaGen."Shortcut Dimension 3 Code" = '' then
                                        l_rstLinDiaGen.Validate("Shortcut Dimension 3 Code", "Global dimension 3 Code");
                                    if l_rstLinDiaGen."Shortcut Dimension 4 Code" = '' then
                                        l_rstLinDiaGen.Validate("Shortcut Dimension 4 Code", "Global Dimension 4 Code");
                                    if l_rstLinDiaGen."Shortcut Dimension 5 Code" = '' then
                                        l_rstLinDiaGen.Validate("Shortcut Dimension 5 Code", "Global Dimension 5 Code");
                                    if l_rstLinDiaGen."Shortcut Dimension 6 Code" = '' then
                                        l_rstLinDiaGen.Validate("Shortcut Dimension 6 Code", "Global Dimension 6 Code");
                                    if l_rstLinDiaGen."Shortcut Dimension 7 Code" = '' then
                                        l_rstLinDiaGen.Validate("Shortcut Dimension 7 Code", "Global Dimension 7 Code");
                                    l_rstLinDiaGen.Modify(true);
                                end;
                                //Busco facturas liquidadas completamente por esa misma NC, si la encuentro inserto la factura con valor 0
                                //IF (rstCCL2."Entry No." = 0) AND (rstCCL2."Document Type" = rstCCL2."Document Type"::"Credit Memo") THEN
                                if (rstCCL2."Closed by Entry No." <> 0) and (rstCCL2."Document Type" = rstCCL2."Document Type"::"Credit Memo") then begin
                                    Clear(rstCCL);
                                    rstCCL.Get(rstCCL2."Entry No.");
                                    //Si hay alguna otra factura liquidada por esta NC, la incorporo a la OP
                                    Clear(rstCCL3);
                                    rstCCL3.SetRange("Closed by Entry No.", rstCCL."Entry No.");
                                    if rstCCL3.FindSet then
                                        repeat
                                            if (rstCCL3."Document Type" = rstCCL3."Document Type"::Invoice) then begin
                                                l_i += 10000;
                                                dlgDialogo.Update(1, l_i / 10000);
                                                dlgDialogo.Update(3, Round(l_i / Rec.Count, 1));
                                                l_rstLinDiaGen."Journal Template Name" := codLibro;
                                                l_rstLinDiaGen."Journal Batch Name" := codSeccion;
                                                l_rstLinDiaGen."Line No." := l_i;
                                                l_rstLinDiaGen.Insert(true);
                                                l_rstLinDiaGen.Validate("Account Type", l_rstLinDiaGen."Account Type"::Vendor);
                                                l_rstLinDiaGen.Validate("Account No.", "Vendor No.");
                                                l_rstLinDiaGen.Validate("Posting Date", "Posting Date");
                                                l_rstLinDiaGen.Validate("Document Type", l_rstLinDiaGen."Document Type"::Payment);
                                                l_rstLinDiaGen.Validate("Applies-to Doc. Type", l_rstLinDiaGen."Document Type"::Invoice);
                                                l_rstLinDiaGen.Validate("Applies-to Doc. No.", rstCCL3."Document No.");
                                                l_rstLinDiaGen.Validate("Account No.", "Vendor No.");
                                                l_rstLinDiaGen.Validate(Amount, 0);
                                                l_rstLinDiaGen."Allow Zero-Amount Posting" := true;
                                                if l_rstLinDiaGen."Shortcut Dimension 1 Code" = '' then
                                                    l_rstLinDiaGen.Validate("Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                                                if l_rstLinDiaGen."Shortcut Dimension 2 Code" = '' then
                                                    l_rstLinDiaGen.Validate("Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                                                if l_rstLinDiaGen."Shortcut Dimension 3 Code" = '' then
                                                    l_rstLinDiaGen.Validate("Shortcut Dimension 3 Code", "Global dimension 3 Code");
                                                if l_rstLinDiaGen."Shortcut Dimension 4 Code" = '' then
                                                    l_rstLinDiaGen.Validate("Shortcut Dimension 4 Code", "Global Dimension 4 Code");
                                                if l_rstLinDiaGen."Shortcut Dimension 5 Code" = '' then
                                                    l_rstLinDiaGen.Validate("Shortcut Dimension 5 Code", "Global Dimension 5 Code");
                                                if l_rstLinDiaGen."Shortcut Dimension 6 Code" = '' then
                                                    l_rstLinDiaGen.Validate("Shortcut Dimension 6 Code", "Global Dimension 6 Code");
                                                if l_rstLinDiaGen."Shortcut Dimension 7 Code" = '' then
                                                    l_rstLinDiaGen.Validate("Shortcut Dimension 7 Code", "Global Dimension 7 Code");
                                                l_rstLinDiaGen.Modify(true);
                                            end;
                                        until rstCCL3.Next = 0;
                                end;
                            until rstCCL2.Next = 0;
                    until Rec.Next = 0;
            end;
        end;
        l_rstLinDiaGen.GenerarLinRetencion(l_rstLinDiaGen, false);
        CurrPage.Close;

    end;

    local procedure PaymentBLock()
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        VendEntryApplyPostEntries: Codeunit "VendEntry-Apply Posted Entries";
        rstSeguridadUsuario: Record "Seguridad por usuario";
        rstSeguridad: Record Seguridad;
        ConfUsu: Record "User Setup";
        l_rstPIH: Record "Purch. Inv. Header";
        CodeMens: Codeunit "Mensajería";
        PunMensajeria: Record Mensajeria;

    begin
        TestField(Open, true);
        if "Document Type" = "Document Type"::Invoice then begin
            Clear(l_rstPIH);
            l_rstPIH.Get("Document No.");
            if not rstSeguridadUsuario.fntSeguridadPermiso(UserId, rstSeguridad.FieldNo(rstSeguridad."Bloquear pago")) then
                Error('Usted no está habilitado para modificar el estado de bloqueo de pago de este documento')
            else begin
                ConfUsu.Reset;
                l_rstPIH.CalcFields("Tipo documento mensajeria");
                if ConfUsu.Get(UserId) then begin
                    if not "Payment block" then begin
                        CodeMens.RegistrarMensaje('Bloquear pago de Factura', '', "Document No.", l_rstPIH."Tipo documento mensajeria", 'Bloqueado', Today,
                        PunMensajeria."Tipo movimiento"::"Mensaje con Seguimiento", ConfUsu.Grupo, '', '', '', '', '', '', '');
                        "Payment block" := true;
                        "Payment blocked by" := ConfUsu.Grupo;
                        Modify;
                    end
                    else begin
                        if rstSeguridadUsuario.fntEstaEnGrupoSeguridad(UserId, "Payment blocked by") then begin
                            CodeMens.RegistrarMensaje('Desbloquear pago de Factura', '', "Document No.", l_rstPIH."Tipo documento mensajeria", 'Desbloqueado', Today,
                            PunMensajeria."Tipo movimiento"::"Mensaje con Seguimiento", ConfUsu.Grupo, '', '', '', '', '', '', '');
                            "Payment block" := false;
                            "Payment blocked by" := '';
                            Modify;
                        end;
                    end;
                end;
            end;
        end;

        CurrPage.Update;

    end;

    trigger OnOpenPage()
    begin
        GetLibro();
    end;

    [Scope('OnPrem')]
    procedure GetLibro()
    var
        cduCacheCxt: Codeunit "Apply Ctx Cache";
    begin
        cduCacheCxt.Read(codLibro, codSeccion);
    end;

    var
        codLibro: Code[10];
        codSeccion: Code[10];
}

