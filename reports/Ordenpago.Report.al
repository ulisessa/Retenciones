report 50564 "Orden pago"
{
    // IBdos Argentina - USS - 030402 - Modificación Arbumasa
    //  a) Se cambia la siguiente línea por la otra
    //  b) Se cambia el DataItemLink del buf. retenciones de Nº Documento=FIELD(Nº documento) a Nº Factura=FIELD(Liq. por nº documento)
    DefaultLayout = RDLC;
    RDLCLayout = 'reports/Ordenpago.rdl';

    EnableExternalImages = true;

    dataset
    {
        dataitem("G/L Register"; "G/L Register")
        {
            RequestFilterFields = "No.", "No. documento";
            column(Logo; rstCI."Logo path")
            {
            }
            column(No_GLRegister; "G/L Register"."No.")
            {
            }
            column(Ndocumento_GLRegister; "G/L Register"."No. documento")
            {
            }
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemLink = "Document No." = FIELD("No. documento"), "Transaction No." = FIELD("No."), "Posting Date" = FIELD("Posting Date");
                DataItemTableView = SORTING("Transaction No.", "Document No.");
                RequestFilterFields = "Transaction No.", "Document No.";
                column(NombreProveedor; NombreProveedor)
                {
                }
                column(Orden; Orden)
                {
                }
                column(COMPANYNAME; CompanyName)
                {
                }
                column(G_L_Entry__G_L_Entry___Document_No__; "G/L Entry"."Document No.")
                {
                }
                column(G_L_Entry__Posting_Date_; "Posting Date")
                {
                }
                column(Concepto; Concepto)
                {
                }
                column(G_L_Entry__Posting_Date__Control42; "Posting Date")
                {
                }
                column(G_L_Entry__G_L_Entry___Document_No___Control66; "G/L Entry"."Document No.")
                {
                }
                column(COMPANYNAME_Control1; CompanyName)
                {
                }
                column(NombreProveedor_Control3; NombreProveedor)
                {
                }
                column(Orden_Control8; Orden)
                {
                }
                column(Concepto_Control90; Concepto)
                {
                }
                column(ABS_total_; Abs(total))
                {
                    DecimalPlaces = 2 : 2;
                }
                column(Proveedor_Caption; Proveedor_CaptionLbl)
                {
                }
                column(Cheque_a_la_orden_de_Caption; Cheque_a_la_orden_de_CaptionLbl)
                {
                }
                column(Orden_de_Pago_Caption; Orden_de_Pago_CaptionLbl)
                {
                }
                column(Fecha_Caption; Fecha_CaptionLbl)
                {
                }
                column(EmptyStringCaption; EmptyStringCaptionLbl)
                {
                }
                column(Fecha_Caption_Control9; Fecha_Caption_Control9Lbl)
                {
                }
                column(Orden_de_Pago_Caption_Control10; Orden_de_Pago_Caption_Control10Lbl)
                {
                }
                column(Proveedor_Caption_Control4; Proveedor_Caption_Control4Lbl)
                {
                }
                column(Cheque_a_la_orden_de_Caption_Control7; Cheque_a_la_orden_de_Caption_Control7Lbl)
                {
                }
                column(EmptyStringCaption_Control91; EmptyStringCaption_Control91Lbl)
                {
                }
                column(EmptyStringCaption_Control97; EmptyStringCaption_Control97Lbl)
                {
                }
                column(EmptyStringCaption_Control84; EmptyStringCaption_Control84Lbl)
                {
                }
                column(TipoCaption; TipoCaptionLbl)
                {
                }
                column(NumeroCaption; NumeroCaptionLbl)
                {
                }
                column(ImporteCaption; ImporteCaptionLbl)
                {
                }
                column(EmptyStringCaption_Control113; EmptyStringCaption_Control113Lbl)
                {
                }
                column(Firmas_ChequesCaption; Firmas_ChequesCaptionLbl)
                {
                }
                column(Espacio_para_adherir_chequeCaption; Espacio_para_adherir_chequeCaptionLbl)
                {
                }
                column(V__B_Caption; V__B_CaptionLbl)
                {
                }
                column(EmisorCaption; EmisorCaptionLbl)
                {
                }
                column(G_L_Entry_Entry_No_; "Entry No.")
                {
                }
                column(G_L_Entry_Transaction_No_; "Transaction No.")
                {
                }
                dataitem(Movimientos; "G/L Entry")
                {
                    DataItemLink = "Transaction No." = FIELD("Transaction No."), "Document No." = FIELD("Document No."), "Posting Date" = FIELD("Posting Date");
                    DataItemTableView = SORTING("Transaction No.", "Document No.");
                    column(Movimientos_Amount; Amount)
                    {
                        DecimalPlaces = 2 : 2;
                    }
                    column("Description________Descripción_2_"; Description + ' - ' + "Descripción 2")
                    {
                    }
                    column(DebitAmount_Movimientos; Movimientos."Debit Amount")
                    {
                    }
                    column(CreditAmount_Movimientos; Movimientos."Credit Amount")
                    {
                    }
                    column(Movimientos__G_L_Account_No__; "G/L Account No.")
                    {
                    }
                    column(Movimientos_Name; Cta.Name)
                    {
                    }
                    column(Movimientos__Bal__Account_Type_; "Bal. Account Type")
                    {
                    }
                    column(Movimientos_Entry_No_; "Entry No.")
                    {
                    }
                    column(Movimientos_Transaction_No_; "Transaction No.")
                    {
                    }
                    column(Movimientos_Document_No_; "Document No.")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Clear(Cta);
                        Cta.Get("G/L Account No.");
                    end;
                }
                dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
                {
                    CalcFields = Amount, "Amount (LCY)";
                    UseTemporary = true;
                    column(VLE_EntryNo; "Vendor Ledger Entry"."Entry No.")
                    {
                    }
                    column(VLE_CurrCode; "Vendor Ledger Entry"."Currency Code")
                    {
                    }
                    column(VLE_Amount; -"Vendor Ledger Entry"."Amount to Apply")
                    {
                    }
                    column(VLE_ApplDocType; "Vendor Ledger Entry"."Document Type")
                    {
                    }
                    column(VLE_ApplDocNo; "Vendor Ledger Entry"."Document No.")
                    {
                    }
                    column(VLE_ExtDocNo; "Vendor Ledger Entry"."External Document No.")
                    {
                    }
                    column(VLE_DueDate; "Vendor Ledger Entry"."Due Date")
                    {
                    }
                    column(VLE_Name; Prov.Name)
                    {
                    }
                    column(VLE_NoCheque; "Vendor Ledger Entry"."No. cheque")
                    {
                    }
                    column(VLE_AmountLCY; -"Vendor Ledger Entry"."Amount to Apply (LCY)")
                    {
                    }
                    column(VLE_AppliestoExtDocNo; VLE_AppliestoExtDocNo)
                    {
                    }
                    column(VLE_ClosedByCurrency; "Vendor Ledger Entry"."Currency Code")
                    {
                    }
                    column(VLE_DocumentDate; "Vendor Ledger Entry"."Document Date")
                    {
                    }
                    column(ChequeALaOrdenDe; strCheque)
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        cdu50501: Codeunit "Registro diarios";
                        TEMPAppliedVentLedgerEntry: Record "Vendor Ledger Entry" temporary;
                        AppliedVentLedgerEntry: Record "Vendor Ledger Entry";
                        l_rst25Pago: Record "Vendor Ledger Entry";
                    begin
                        Clear(Prov);
                        if Prov.Get("Vendor Ledger Entry"."Vendor No.") then;

                        Clear(Prov);
                        Prov.Get("Vendor No.");
                        strCheque := Prov."Cheque a la orden de";
                        Orden := Prov."Cheque a la orden de";

                        if "Vendor Ledger Entry"."External Document No." = '' then
                            VLE_AppliestoExtDocNo := "Vendor Ledger Entry"."Document No."
                        else
                            VLE_AppliestoExtDocNo := "Vendor Ledger Entry"."External Document No.";
                    end;

                    trigger OnPreDataItem()
                    begin
                        CurrReport.CreateTotals(MovProvPagados4.Amount);
                    end;
                }
                dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
                {
                    DataItemLink = "Document No." = FIELD("Document No."), "Posting Date" = FIELD("Posting Date"), "Transaction No." = FIELD("Transaction No.");
                    column(CLE_Name; rstCliente.Name)
                    {
                    }
                    column(CLE_CustomerNo; "Cust. Ledger Entry"."Customer No.")
                    {
                    }
                    column(CLE_CurrCode; "Cust. Ledger Entry"."Currency Code")
                    {
                    }
                    column(CLE_Amount; "Cust. Ledger Entry".Amount)
                    {
                    }
                    column(CLE_AmountLCY; "Cust. Ledger Entry"."Amount (LCY)")
                    {
                    }
                    column(CLE_ApplDocType; "Cust. Ledger Entry"."Applies-to Doc. Type")
                    {
                    }
                    column(CLE_AppliestoExtDocNo; rstCLE."External Document No.")
                    {
                    }
                    column(CLE_DueDate; "Cust. Ledger Entry"."Due Date")
                    {
                    }
                    column(CLE_ExternalDocumentNo; "Cust. Ledger Entry"."External Document No.")
                    {
                    }
                    column(CLE_DocumentDate; "Cust. Ledger Entry"."Document Date")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Clear(rstCliente);
                        rstCliente.Get("Cust. Ledger Entry"."Customer No.");

                        Clear(rstCLE);
                        rstCLE.SetRange("Document Type", "Cust. Ledger Entry"."Applies-to Doc. Type");
                        rstCLE.SetRange("Document No.", "Cust. Ledger Entry"."Applies-to Doc. No.");
                        if rstCLE.FindFirst then;
                    end;
                }
                dataitem("Mov. contabilidad2"; "G/L Entry")
                {
                    DataItemLink = "Document No." = FIELD("Document No."), "Posting Date" = FIELD("Posting Date"), "Transaction No." = FIELD("Transaction No.");
                    DataItemLinkReference = "G/L Entry";
                    DataItemTableView = SORTING("Transaction No.", "Document No.") ORDER(Ascending) WHERE("Source Type" = FILTER("Bank Account"), Amount = FILTER(< 0));
                    RequestFilterFields = "Document No.";
                    column(Mov__contabilidad2__N__cheque_; "No. cheque")
                    {
                    }
                    column(PunBanco_Name_________PunBanco__Search_Name_; PunBanco.Name + '/' + PunBanco."Search Name")
                    {
                    }
                    column(ABS_Amount_; Abs(Amount))
                    {
                        DecimalPlaces = 2 : 2;
                    }
                    column("Cheque_NúmeroCaption"; Cheque_NúmeroCaptionLbl)
                    {
                    }
                    column(Banco_CuentaCaption; Banco_CuentaCaptionLbl)
                    {
                    }
                    column(ImporteCaption_Control1000000005; ImporteCaption_Control1000000005Lbl)
                    {
                    }
                    column(Mov__contabilidad2_Entry_No_; "Entry No.")
                    {
                    }
                    column(Mov__contabilidad2_Document_No_; "Document No.")
                    {
                    }
                    column(Mov__contabilidad2_Transaction_No_; "Transaction No.")
                    {
                    }
                }
                dataitem("Bank Account Ledger Entry"; "Bank Account Ledger Entry")
                {
                    DataItemLink = "Document No." = FIELD("Document No."), "Posting Date" = FIELD("Posting Date"), "Transaction No." = FIELD("Transaction No.");
                    column(BLE_Nombre; PunBanco.Name)
                    {
                    }
                    column(BLE_Description; "Bank Account Ledger Entry".Description)
                    {
                    }
                    column(BLE_PostingDate; "Bank Account Ledger Entry"."Posting Date")
                    {
                    }
                    column(BLE_CurrencyCode; "Bank Account Ledger Entry"."Currency Code")
                    {
                    }
                    column(BLE_Amount; "Bank Account Ledger Entry".Amount)
                    {
                    }
                    column(BLE_AmountLCY; "Bank Account Ledger Entry"."Amount (LCY)")
                    {
                    }
                    column(BLE_DocumentDate; "Bank Account Ledger Entry"."Value Date")
                    {
                    }
                    column(BLE_ExternalDocumentNo; "Bank Account Ledger Entry"."No. cheque")
                    {
                    }
                    column(BLE_BankAccountNo; PunBanco."CCC No.")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Clear(PunBanco);
                        PunBanco.Get("Bank Account Ledger Entry"."Bank Account No.");

                        codCheque := '';

                        Clear(Prov);
                        if Prov.Get("Vendor Ledger Entry"."Vendor No.") then;

                        Clear(MovConta);
                        MovConta.SetCurrentKey(MovConta."Document No.");
                        MovConta.SetRange("Document No.", "Document No.");
                        MovConta.SetRange("Source Type", MovConta."Source Type"::"Bank Account");
                        MovConta.SetRange("Source No.", "Bank Account Ledger Entry"."Bank Account No.");
                        MovConta.SetRange(Amount, "Bank Account Ledger Entry"."Amount (LCY)");
                        if MovConta.FindFirst then
                            codCheque := MovConta."No. cheque";
                    end;
                }
                dataitem("Invoice Withholding Buffer"; "Invoice Withholding Buffer")
                {
                    CalcFields = "Factura Prov";
                    DataItemLink = "No. documento" = FIELD("Document No."), "Fecha pago" = FIELD("Posting Date");
                    DataItemTableView = SORTING("No. documento", "Cod. retencion") WHERE(Retenido = CONST(true));
                    column(ClienteProveedor_FacturaRTBaseBuffer; "Invoice Withholding Buffer"."Cliente/Proveedor")
                    {
                    }
                    column("Tiporetención_FacturaRTBaseBuffer"; "Invoice Withholding Buffer"."Tipo retencion")
                    {
                    }
                    column("Códretención_FacturaRTBaseBuffer"; "Invoice Withholding Buffer"."Cod. retencion")
                    {
                    }
                    column("Importeretención_FacturaRTBaseBuffer"; "Invoice Withholding Buffer"."Importe retencion")
                    {
                    }
                    column(Nombre_FacturaRTBaseBuffer; "Invoice Withholding Buffer".Nombre)
                    {
                    }
                    column(FacturaProv_FacturaRTBaseBuffer; "Invoice Withholding Buffer"."Factura Prov")
                    {
                    }
                    column("Serieretención_InvoiceWithholdingBuffer"; "Invoice Withholding Buffer"."Serie retención")
                    {
                    }
                    column("Códsicore_InvoiceWithholdingBuffer"; "Invoice Withholding Buffer"."Cod. sicore")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Clear(rst25);
                        rst25.SetRange("Vendor No.", "Invoice Withholding Buffer"."Cliente/Proveedor");
                        case "Invoice Withholding Buffer"."Tipo factura" of
                            "Invoice Withholding Buffer"."Tipo factura"::"Nota d/c":
                                rst25.SetRange("Document Type", rst25."Document Type"::"Credit Memo");
                            "Invoice Withholding Buffer"."Tipo factura"::Factura:
                                rst25.SetRange("Document Type", rst25."Document Type"::Invoice);
                        end;
                        rst25.FindFirst;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if codDocumento <> '' then begin

                        if codDocumento = "G/L Entry"."Document No." then
                            CurrReport.Skip
                        else
                            codDocumento := "G/L Entry"."Document No.";

                    end
                    else
                        codDocumento := "G/L Entry"."Document No.";

                    Clear(MovConta);
                    MovConta.SetCurrentKey("Transaction No.");
                    MovConta.SetRange("Transaction No.", "G/L Entry"."Transaction No.");
                    MovConta.SetFilter("Concepto general", '<>%1', '');
                    if MovConta.FindFirst then
                        Concepto := MovConta."Concepto general"
                    else begin
                        Clear(rstSeccion);
                        rstSeccion.SetRange(rstSeccion.Name, "G/L Entry"."Journal Batch Name");
                        if rstSeccion.FindFirst then
                            Concepto := rstSeccion.Description;
                    end;

                    Clear(MovConta);
                    MovConta.SetCurrentKey("Transaction No.");
                    MovConta.SetRange("Transaction No.", "G/L Entry"."Transaction No.");
                    MovConta.SetRange("Document No.", "G/L Entry"."Document No.");
                    MovConta.SetRange("Source Type", MovConta."Source Type"::Vendor);
                    if MovConta.FindFirst then begin

                        Clear(Prov);
                        Prov.Get(MovConta."Source No.");
                        strCheque := Prov."Cheque a la orden de";
                        Orden := Prov."Cheque a la orden de";

                    end;

                    Clear(Cta);
                    Cta.Get("G/L Account No.");
                end;

                trigger OnPreDataItem()
                begin
                    if codDocNro <> '' then
                        SetRange("Document No.", codDocNro);
                end;
            }

            trigger OnAfterGetRecord()
            var
                l_rstVLE: Record "Vendor Ledger Entry";
                l_rstVLE2: Record "Vendor Ledger Entry";
                l_rstVLE3_tmp: Record "Vendor Ledger Entry" temporary;
                cdu50501: Codeunit "Registro diarios";
                TEMPAppliedVentLedgerEntry: Record "Vendor Ledger Entry" temporary;
                blnFound: Boolean;
            begin
                Clear(rstCI);
                rstCI.Get;

                //Busco los documentos aplicados dentro de esta transacción
                Clear(l_rstVLE);
                l_rstVLE.SetRange("Transaction No.", "No.");
                if l_rstVLE.FindSet then
                    repeat
                        blnFound := false;
                        //Primero, me fijo si algo aplica directamente a este movimiento de proveedor
                        Clear(l_rstVLE2);
                        l_rstVLE2.SetRange("Closed by Entry No.", l_rstVLE."Entry No.");
                        if (l_rstVLE2.FindSet) and (l_rstVLE2."Document Type" in [l_rstVLE2."Document Type"::Payment, l_rstVLE2."Document Type"::" "]) then begin
                            blnFound := true;
                            i += 1;
                            l_rstVLE.CalcFields(Amount, "Amount (LCY)");
                            "Vendor Ledger Entry".TransferFields(l_rstVLE2);
                            "Vendor Ledger Entry"."Amount to Apply" := -l_rstVLE.Amount;
                            "Vendor Ledger Entry"."Amount to Apply (LCY)" := -l_rstVLE."Amount (LCY)";
                            "Vendor Ledger Entry"."Entry No." := i;
                            "Vendor Ledger Entry".Insert;
                            l_rstVLE3_tmp.TransferFields(l_rstVLE2);
                            l_rstVLE3_tmp.Insert;
                            fntGenerarLineas(l_rstVLE3_tmp);
                        end;
                        if ((l_rstVLE."Applies-to Doc. No." <> '') or (l_rstVLE."Closed by Entry No." <> 0)) and not blnFound then begin
                            //Inserto los movimientos aplicados en una tabla temporal
                            Clear(l_rstVLE2);
                            if (l_rstVLE."Applies-to Doc. No." <> '') and not (l_rstVLE."Closed by Entry No." <> 0) then begin
                                l_rstVLE2.SetRange("Document Type", l_rstVLE."Applies-to Doc. Type");
                                l_rstVLE2.SetRange("Document No.", l_rstVLE."Applies-to Doc. No.");
                                if (l_rstVLE2.FindSet) and (l_rstVLE2."Document Type" = l_rstVLE2."Document Type"::Invoice) then begin
                                    blnFound := true;
                                    i += 1;
                                    l_rstVLE2.CalcFields(Amount, "Amount (LCY)");
                                    "Vendor Ledger Entry".TransferFields(l_rstVLE2);
                                    "Vendor Ledger Entry"."Amount to Apply" := l_rstVLE2.Amount;
                                    "Vendor Ledger Entry"."Amount to Apply (LCY)" := l_rstVLE2."Amount (LCY)";
                                    "Vendor Ledger Entry"."Entry No." := i;
                                    "Vendor Ledger Entry".Insert;
                                    l_rstVLE3_tmp.TransferFields(l_rstVLE2);
                                    l_rstVLE3_tmp.Insert;
                                    fntGenerarLineas(l_rstVLE3_tmp);
                                end;
                                if (l_rstVLE2.FindSet) and (l_rstVLE2."Document Type" in [l_rstVLE2."Document Type"::Payment, l_rstVLE2."Document Type"::" "]) then begin
                                    blnFound := true;
                                    i += 1;
                                    l_rstVLE.CalcFields(Amount, "Amount (LCY)");
                                    "Vendor Ledger Entry".TransferFields(l_rstVLE2);
                                    "Vendor Ledger Entry"."Amount to Apply" := -l_rstVLE.Amount;
                                    "Vendor Ledger Entry"."Amount to Apply (LCY)" := -l_rstVLE."Amount (LCY)";
                                    "Vendor Ledger Entry"."Entry No." := i;
                                    "Vendor Ledger Entry".Insert;
                                    l_rstVLE3_tmp.TransferFields(l_rstVLE2);
                                    l_rstVLE3_tmp.Insert;
                                    fntGenerarLineas(l_rstVLE3_tmp);
                                end;
                            end;
                            if (l_rstVLE."Closed by Entry No." <> 0) and not blnFound then begin
                                l_rstVLE2.Get(l_rstVLE."Closed by Entry No.");
                                if l_rstVLE2."Document Type" in [l_rstVLE2."Document Type"::Invoice] then begin
                                    blnFound := true;
                                    i += 1;
                                    l_rstVLE2.CalcFields(Amount, "Amount (LCY)");
                                    "Vendor Ledger Entry".TransferFields(l_rstVLE2);
                                    "Vendor Ledger Entry"."Amount to Apply" := l_rstVLE2.Amount;
                                    "Vendor Ledger Entry"."Amount to Apply (LCY)" := l_rstVLE2."Amount (LCY)";
                                    "Vendor Ledger Entry"."Entry No." := i;
                                    "Vendor Ledger Entry".Insert;
                                    l_rstVLE3_tmp.TransferFields(l_rstVLE2);
                                    l_rstVLE3_tmp.Insert;
                                    fntGenerarLineas(l_rstVLE3_tmp);
                                end;
                                if (l_rstVLE2."Document Type" in [l_rstVLE2."Document Type"::Payment, l_rstVLE2."Document Type"::" "]) and not blnFound then begin
                                    i += 1;
                                    l_rstVLE.CalcFields(Amount, "Amount (LCY)");
                                    "Vendor Ledger Entry".TransferFields(l_rstVLE2);
                                    "Vendor Ledger Entry"."Amount to Apply" := -l_rstVLE.Amount;
                                    "Vendor Ledger Entry"."Amount to Apply (LCY)" := -l_rstVLE."Amount (LCY)";
                                    "Vendor Ledger Entry"."Entry No." := i;
                                    "Vendor Ledger Entry".Insert;
                                    /*
                                    l_rstVLE3_tmp.TRANSFERFIELDS(l_rstVLE2);
                                    l_rstVLE3_tmp.INSERT;
                                    fntGenerarLineas(l_rstVLE3_tmp);
                                    */
                                end;
                            end;
                        end;
                    until l_rstVLE.Next = 0;

                //Genero la historia de aplicación de todos los documentos del Pago
                /*
                IF l_rstVLE3_tmp.FINDSET THEN
                REPEAT
                UNTIL l_rstVLE3_tmp.NEXT = 0;
                */

            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        Prov: Record Vendor;
        Cta: Record "G/L Account";
        MovProvPagados: Record "Vendor Ledger Entry";
        MovProvPagados2: Record "Vendor Ledger Entry";
        MovProvPagados3: Record "Vendor Ledger Entry";
        GanRetenciones: Decimal;
        TotalPagado: Decimal;
        VBANCO: Record "Bank Account";
        VTEXTO: Text[50];
        vdocumento: Text[1024];
        TotalPagadoNeto: Decimal;
        vtexto1: Text[50];
        PunBanco: Record "Bank Account";
        PunMovConta: Record "G/L Entry";
        encontrado: Boolean;
        TImporte: Decimal;
        importecerrado: Decimal;
        importelinea: Decimal;
        IVARetenciones: Decimal;
        MovConta: Record "G/L Entry";
        vimporte: Decimal;
        IBRetenciones: Decimal;
        Mostrar: Boolean;
        total: Decimal;
        MovProvPagados4: Record "Vendor Ledger Entry";
        MovCont2: Record "G/L Entry";
        MovProvPagados4TotImporte: Decimal;
        NombreProveedor: Text[200];
        Prov1: Record Vendor;
        Orden: Text[200];
        Concepto: Text[200];
        codDocumento: Code[1024];
        codDocNro: Code[1024];
        blnMostrar: Boolean;
        Proveedor_CaptionLbl: Label 'Proveedor:';
        Cheque_a_la_orden_de_CaptionLbl: Label 'Cheque a la orden de:';
        Orden_de_Pago_CaptionLbl: Label 'Orden de Pago:';
        Fecha_CaptionLbl: Label 'Fecha:';
        EmptyStringCaptionLbl: Label 'Proveedor:';
        Fecha_Caption_Control9Lbl: Label 'Fecha:';
        Orden_de_Pago_Caption_Control10Lbl: Label 'Orden de Pago:';
        Proveedor_Caption_Control4Lbl: Label 'Proveedor:';
        Cheque_a_la_orden_de_Caption_Control7Lbl: Label 'Cheque a la orden de:';
        EmptyStringCaption_Control91Lbl: Label 'Proveedor:';
        EmptyStringCaption_Control97Lbl: Label 'Tipo';
        EmptyStringCaption_Control84Lbl: Label 'Comprobante';
        TipoCaptionLbl: Label 'Tipo';
        NumeroCaptionLbl: Label 'Numero';
        ImporteCaptionLbl: Label 'Importe';
        EmptyStringCaption_Control113Lbl: Label 'Total';
        Firmas_ChequesCaptionLbl: Label 'Firmas Cheques';
        Espacio_para_adherir_chequeCaptionLbl: Label 'Espacio para adherir cheque';
        V__B_CaptionLbl: Label 'Vº Bº';
        EmisorCaptionLbl: Label 'Emisor';
        EmptyStringCaption_Control14Lbl: Label 'Comprobante';
        NumeroCaption_Control18Lbl: Label 'Numero';
        TipoCaption_Control20Lbl: Label 'Tipo';
        VencimientoCaptionLbl: Label 'Vencimiento';
        MonedaCaptionLbl: Label 'Moneda';
        ImporteCaption_Control27Lbl: Label 'Importe';
        EmptyStringCaption_Control37Lbl: Label 'Total';
        "Cheque_NúmeroCaptionLbl": Label 'Cheque Número';
        Banco_CuentaCaptionLbl: Label 'Banco/Cuenta';
        ImporteCaption_Control1000000005Lbl: Label 'Importe';
        rstCliente: Record Customer;
        rstSeccion: Record "Gen. Journal Batch";
        codCheque: Code[20];
        rstVLE: Record "Vendor Ledger Entry";
        rstCLE: Record "Cust. Ledger Entry";
        rstDVLE: Record "Detailed Vendor Ledg. Entry";
        strCheque: Text;
        rstCI: Record "Company Information";
        rst25: Record "Vendor Ledger Entry";
        decAmount: Decimal;
        decAmountLCY: Decimal;
        VLE_AppliestoExtDocNo: Text[20];
        i: Integer;

    [Scope('OnPrem')]
    procedure fntDoc(codDocu: Code[1024])
    begin
        codDocNro := codDocu;
    end;

    local procedure fntGenerarLineas(l_rstVLE3_tmp: Record "Vendor Ledger Entry" temporary)
    var
        l_rstVLE4: Record "Vendor Ledger Entry";
        l_rstPagos: Record "Vendor Ledger Entry";
    begin
        Clear(l_rstVLE4);
        l_rstVLE4.SetRange("Entry No.", l_rstVLE3_tmp."Entry No.");
        if l_rstVLE4.FindSet then
            repeat
                Clear(l_rstPagos);
                l_rstPagos.SetRange("Applies-to Doc. Type", l_rstVLE4."Document Type");
                l_rstPagos.SetRange("Applies-to Doc. No.", l_rstVLE4."Document No.");
                if l_rstPagos.FindSet then
                    repeat
                        if (l_rstPagos."Document No." <> "G/L Register"."No. documento") and (l_rstPagos."Document Type" in [l_rstPagos."Document Type"::Invoice, l_rstPagos."Document Type"::"Credit Memo"]) then begin
                            i += 1;
                            l_rstPagos.CalcFields(Amount, "Amount (LCY)");
                            "Vendor Ledger Entry".TransferFields(l_rstPagos);
                            "Vendor Ledger Entry"."Amount to Apply" := l_rstPagos.Amount;
                            "Vendor Ledger Entry"."Amount to Apply (LCY)" := l_rstPagos."Amount (LCY)";
                            "Vendor Ledger Entry"."Entry No." := i;
                            "Vendor Ledger Entry".Insert;
                        end;
                    until l_rstPagos.Next = 0;
            until l_rstVLE4.Next = 0;
        Clear(l_rstVLE4);
        l_rstVLE4.SetRange("Closed by Entry No.", l_rstVLE3_tmp."Entry No.");
        if l_rstVLE4.FindSet then
            repeat
                Clear(l_rstPagos);
                l_rstPagos.SetRange("Entry No.", l_rstVLE4."Entry No.");
                if l_rstPagos.FindSet then
                    repeat
                        if (l_rstPagos."Document No." <> "G/L Register"."No. documento")
                          and (l_rstPagos."Document Type" in [l_rstPagos."Document Type"::Invoice, l_rstPagos."Document Type"::"Credit Memo"])
                          and (l_rstPagos."Document No." <> "Vendor Ledger Entry"."Document No.") then begin
                            i += 1;
                            l_rstPagos.CalcFields(Amount, "Amount (LCY)");
                            "Vendor Ledger Entry".TransferFields(l_rstPagos);
                            "Vendor Ledger Entry"."Amount to Apply" := l_rstPagos.Amount;
                            "Vendor Ledger Entry"."Amount to Apply (LCY)" := l_rstPagos."Amount (LCY)";
                            "Vendor Ledger Entry"."Entry No." := i;
                            "Vendor Ledger Entry".Insert;
                        end;
                    until l_rstPagos.Next = 0;
            until l_rstVLE4.Next = 0;
    end;
}

