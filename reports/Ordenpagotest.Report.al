report 50094 "Orden pago test"
{
    // IBdos Argentina - USS - 030402 - Modificación Arbumasa
    //  a) Se cambia la siguiente línea por la otra
    //  b) Se cambia el DataItemLink del buf. retenciones de Nº Documento=FIELD(Nº documento) a Nº Factura=FIELD(Liq. por nº documento)
    DefaultLayout = RDLC;
    RDLCLayout = 'reports/Ordenpagotest.rdl';

    EnableExternalImages = true;

    dataset
    {
        dataitem("G/L Entry"; "Gen. Journal Line")
        {
            DataItemTableView = SORTING("Document No.");
            RequestFilterFields = "Document No.", "Journal Template Name", "Journal Batch Name";
            column(Logo; rstCI."Logo path")
            {
            }
            column(GLEntry_JournTemplate; "G/L Entry"."Journal Template Name")
            {
            }
            column(GLEntry_JournBatch; "G/L Entry"."Journal Batch Name")
            {
            }
            column(GLEntry_Document_No; "G/L Entry"."Document No.")
            {
            }
            dataitem(Movimientos; "Gen. Journal Line")
            {
                DataItemLink = "Journal Template Name" = FIELD("Journal Template Name"), "Journal Batch Name" = FIELD("Journal Batch Name"), "Document No." = FIELD("Document No.");
                DataItemTableView = SORTING("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
                column(Movimientos_G_L_Account_No__; "Account No.")
                {
                }
                column(Movimientos_Name; strNombre)
                {
                }
                column(Movimientos_AccountType; Movimientos."Account Type")
                {
                }
                column(Movimientos_Description; Description + ' - ' + "Descripción 2")
                {
                }
                column(Movimientos_Amount; Amount)
                {
                    DecimalPlaces = 2 : 2;
                }
                column(Movimientos_DebitAmount; Movimientos."Debit Amount")
                {
                }
                column(Movimientos_CreditAmount; Movimientos."Credit Amount")
                {
                }
                column(Movimientos__Bal__Account_Type_; "Bal. Account Type")
                {
                }
                column(Movimientos_Transaction_No_; "Transaction No.")
                {
                }
                column(Movimientos_Cheque; Movimientos."No. cheque")
                {
                }
                column(Movimientos_RecipientBankAccount; Movimientos."Recipient Bank Account")
                {
                }
                column(Movimientos_BankPaymentType; Movimientos."Bank Payment Type")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(Cta);
                    if Cta.Get(Movimientos."Account No.") then;

                    Clear(Prov);
                    if Prov.Get(Movimientos."Account No.") then;

                    Clear(Cli);
                    if Cli.Get(Movimientos."Account No.") then;

                    Clear(Banco);
                    if Banco.Get(Movimientos."Account No.") then;

                    strNombre := Movimientos."Account No." + ' - ' + Cta.Name + Cli.Name + Banco.Name + Prov.Name;
                end;
            }
            dataitem(MovimientosContrapartida; "Gen. Journal Line")
            {
                DataItemLink = "Journal Template Name" = FIELD("Journal Template Name"), "Journal Batch Name" = FIELD("Journal Batch Name"), "Document No." = FIELD("Document No.");
                DataItemTableView = SORTING("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.") WHERE("Bal. Account No." = FILTER(<> ''));
                column(MovimientosContrapartida_G_L_Account_No__; "Bal. Account No.")
                {
                }
                column(MovimientosContrapartida_Name; strNombre)
                {
                }
                column(MovimientosContrapartida_AccountType; "Bal. Account Type")
                {
                }
                column(MovimientosContrapartida_Description; Description + ' - ' + "Descripción 2")
                {
                }
                column(MovimientosContrapartida_Amount; Amount)
                {
                    DecimalPlaces = 2 : 2;
                }
                column(MovimientosContrapartida_DebitAmount; "Debit Amount")
                {
                }
                column(MovimientosContrapartida_CreditAmount; "Credit Amount")
                {
                }
                column(MovimientosContrapartida__Bal__Account_Type_; "Bal. Account Type")
                {
                }
                column(MovimientosContrapartida_Transaction_No_; "Transaction No.")
                {
                }
                column(MovimientosContrapartida_Cheque; "No. cheque")
                {
                }
                column(MovimientosContrapartida_RecipientBankAccount; "Recipient Bank Account")
                {
                }
                column(MovimientosContrapartida_BankPaymentType; "Bank Payment Type")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(Cta);
                    if Cta.Get("Bal. Account No.") then;

                    Clear(Prov);
                    if Prov.Get("Bal. Account No.") then;

                    Clear(Cli);
                    if Cli.Get("Bal. Account No.") then;

                    Clear(Banco);
                    if Banco.Get("Bal. Account No.") then;

                    strNombre := "Bal. Account No." + ' - ' + Cta.Name + Cli.Name + Banco.Name + Prov.Name;
                end;
            }
            dataitem(MovimientosBanco; "Gen. Journal Line")
            {
                DataItemLink = "Journal Template Name" = FIELD("Journal Template Name"), "Journal Batch Name" = FIELD("Journal Batch Name"), "Document No." = FIELD("Document No.");
                DataItemTableView = SORTING("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.") WHERE("Account Type" = CONST("Bank Account"));
                column(MovimientosBanco_G_L_Account_No__; MovimientosBanco."Account No.")
                {
                }
                column(MovimientosBanco_Name; strNombre)
                {
                }
                column(MovimientosBanco_AccountType; MovimientosBanco."Account Type")
                {
                }
                column(MovimientosBanco_Description; MovimientosBanco.Description + ' - ' + MovimientosBanco."Descripción 2")
                {
                }
                column(MovimientosBanco_Amount; MovimientosBanco.Amount)
                {
                    DecimalPlaces = 2 : 2;
                }
                column(MovimientosBanco_DebitAmount; MovimientosBanco."Debit Amount")
                {
                }
                column(MovimientosBanco_CreditAmount; MovimientosBanco."Credit Amount")
                {
                }
                column(MovimientosBanco__Bal__Account_Type_; MovimientosBanco."Bal. Account Type")
                {
                }
                column(MovimientosBanco_Transaction_No_; MovimientosBanco."Transaction No.")
                {
                }
                column(MovimientosBanco_Cheque; MovimientosBanco."No. cheque")
                {
                }
                column(MovimientosBanco_RecipientBankAccount; MovimientosBanco."Recipient Bank Account")
                {
                }
                column(MovimientosBanco_BankPaymentType; MovimientosBanco."Bank Payment Type")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(Cta);
                    if Cta.Get(MovimientosBanco."Account No.") then;

                    Clear(Prov);
                    if Prov.Get(MovimientosBanco."Account No.") then;

                    Clear(Cli);
                    if Cli.Get(MovimientosBanco."Account No.") then;

                    Clear(Banco);
                    if Banco.Get(MovimientosBanco."Account No.") then;

                    strNombre := MovimientosBanco."Account No." + ' - ' + Cta.Name + Cli.Name + Banco.Name + Prov.Name;
                end;
            }
            dataitem("Vendor Ledger Entry"; "Gen. Journal Line")
            {
                DataItemLink = "Journal Template Name" = FIELD("Journal Template Name"), "Journal Batch Name" = FIELD("Journal Batch Name"), "Document No." = FIELD("Document No.");
                DataItemTableView = SORTING("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.") WHERE("Account Type" = FILTER(Vendor));
                column(VLE_VendorNo; "Vendor Ledger Entry"."Account No.")
                {
                }
                column(VLE_ApplDocType; rstVLE."Document Type")
                {
                }
                column(VLE_ApplDocNo; rstVLE."Document No.")
                {
                }
                column(VLE_ExtDocNo; rstVLE."External Document No.")
                {
                }
                column(VLE_DueDate; rstVLE."Due Date")
                {
                }
                column(VLE_Name; "Vendor Ledger Entry"."Account No." + ' - ' + Prov.Name)
                {
                }
                column(VLE_CurrCode; rstVLE."Currency Code")
                {
                }
                column(VLE_Amount; decAmount)
                {
                }
                column(VLE_ClosedByAmountLCY; rstVLE."Closed by Amount (LCY)")
                {
                }
                column(VLE_AmountLCY; decAmountLCY)
                {
                }
                column(VLE_AmountLCYDoc; decAmountLCYDoc)
                {
                }
                column(VLE_DocumentDate; rstVLE."Document Date")
                {
                }

                trigger OnAfterGetRecord()
                var
                    cdu50501: Codeunit "Registro diarios";
                    TEMPAppliedVentLedgerEntry: Record "Vendor Ledger Entry" temporary;
                    AppliedVentLedgerEntry: Record "Vendor Ledger Entry";
                    l_rst81Pago: Record "Gen. Journal Line";
                begin

                    Clear(Prov);
                    Prov.Get("Vendor Ledger Entry"."Account No.");

                    Clear(rstVLE);
                    rstVLE.SetRange(rstVLE."Document Type", "Vendor Ledger Entry"."Applies-to Doc. Type");
                    rstVLE.SetRange("Document No.", "Vendor Ledger Entry"."Applies-to Doc. No.");
                    if rstVLE.FindFirst then;
                    rstVLE.CalcFields(Amount, "Remaining Amount", "Remaining Amt. (LCY)", "Amount (LCY)");

                    Clear(TEMPAppliedVentLedgerEntry);

                    Clear(Prov);
                    Prov.Get("Vendor Ledger Entry"."Account No.");

                    decAmount := "Vendor Ledger Entry".Amount;
                    decAmountLCY := "Vendor Ledger Entry"."Amount (LCY)";
                    decAmountLCYDoc := "Vendor Ledger Entry"."Amount (LCY)";

                    Clear(cdu50501);
                    begin
                        cdu50501.fntGetAppliedVendorDocs(rstVLE, TEMPAppliedVentLedgerEntry, true);
                    end;
                    if not TEMPAppliedVentLedgerEntry.IsEmpty then begin
                        //Si la línea actual pertenece a una factura, y esa factura fue liquidada por una NC que también está incorporada en esta OP, le sumo el monto de la NC a esta factura
                        if TEMPAppliedVentLedgerEntry.FindSet then
                            repeat
                                case TEMPAppliedVentLedgerEntry."Document Type" of
                                    TEMPAppliedVentLedgerEntry."Document Type"::Invoice:
                                        begin
                                            Clear(AppliedVentLedgerEntry);
                                            cdu50501.fntGetAppliedVendorDocs(TEMPAppliedVentLedgerEntry, AppliedVentLedgerEntry, true);
                                            case "Vendor Ledger Entry"."Applies-to Doc. Type" of
                                                "Vendor Ledger Entry"."Applies-to Doc. Type"::"Credit Memo":
                                                    begin
                                                        Clear(l_rst81Pago);
                                                        l_rst81Pago.SetRange("Applies-to Doc. Type", l_rst81Pago."Applies-to Doc. Type"::"Credit Memo");
                                                        l_rst81Pago.SetRange("Applies-to Doc. No.", AppliedVentLedgerEntry."Document No.");
                                                        //l_rst25Pago.SETRANGE("Transaction No.",AppliedVentLedgerEntry."Transaction No.");
                                                        if l_rst81Pago.FindSet then
                                                            repeat
                                                                AppliedVentLedgerEntry.CalcFields(Amount, "Amount (LCY)");
                                                                decAmount -= AppliedVentLedgerEntry.Amount;
                                                                decAmountLCY -= AppliedVentLedgerEntry."Amount (LCY)";
                                                                decAmountLCYDoc -= AppliedVentLedgerEntry."Amount (LCY)";
                                                            until l_rst81Pago.Next = 0;
                                                    end;
                                                "Vendor Ledger Entry"."Applies-to Doc. Type"::Invoice:
                                                    begin
                                                        Clear(l_rst81Pago);
                                                        l_rst81Pago.SetRange("Applies-to Doc. Type", l_rst81Pago."Applies-to Doc. Type"::"Credit Memo");
                                                        l_rst81Pago.SetRange("Applies-to Doc. No.", AppliedVentLedgerEntry."Document No.");
                                                        //l_rst25Pago.SETRANGE("Transaction No.",AppliedVentLedgerEntry."Transaction No.");
                                                        if l_rst81Pago.FindSet then
                                                            repeat
                                                                AppliedVentLedgerEntry.CalcFields(Amount, "Amount (LCY)");
                                                                decAmount -= AppliedVentLedgerEntry.Amount;
                                                                decAmountLCY -= AppliedVentLedgerEntry."Amount (LCY)";
                                                                decAmountLCYDoc -= AppliedVentLedgerEntry."Amount (LCY)";
                                                            until l_rst81Pago.Next = 0;
                                                    end;
                                            end;
                                        end;
                                    TEMPAppliedVentLedgerEntry."Document Type"::"Credit Memo":
                                        begin
                                            Clear(l_rst81Pago);
                                            l_rst81Pago.SetRange("Applies-to Doc. Type", TEMPAppliedVentLedgerEntry."Document Type");
                                            l_rst81Pago.SetRange("Applies-to Doc. No.", TEMPAppliedVentLedgerEntry."Document No.");
                                            l_rst81Pago.SetRange("Transaction No.", "Vendor Ledger Entry"."Transaction No.");
                                            //l_rst25Pago.SETRANGE("Transaction No.",AppliedVentLedgerEntry."Transaction No.");
                                            if l_rst81Pago.FindSet then
                                                repeat
                                                    TEMPAppliedVentLedgerEntry.CalcFields(Amount, "Amount (LCY)");
                                                    decAmount += TEMPAppliedVentLedgerEntry.Amount;
                                                    decAmountLCY += TEMPAppliedVentLedgerEntry."Amount (LCY)";
                                                    decAmountLCYDoc += TEMPAppliedVentLedgerEntry."Amount (LCY)";
                                                until l_rst81Pago.Next = 0;
                                        end;
                                end;
                            until TEMPAppliedVentLedgerEntry.Next = 0;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    CurrReport.CreateTotals(MovProvPagados4.Amount);
                end;
            }
            dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
            {
                DataItemLink = "Customer No." = FIELD("Account No."), "Document Type" = FIELD("Applies-to Doc. Type"), "Document No." = FIELD("Applies-to Doc. No.");
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
            dataitem("Invoice Withholding Buffer"; "Invoice Withholding Buffer")
            {
                CalcFields = "Factura Prov";
                DataItemLink = "No. documento" = FIELD("Document No.");
                DataItemTableView = SORTING("No. documento", "Cod. retencion") WHERE(Retenido = CONST(true));
                column(IWB_Documento; "Invoice Withholding Buffer"."No. Factura")
                {
                }
                column(IWB_ClienteProveedor; "Invoice Withholding Buffer"."Cliente/Proveedor")
                {
                }
                column("IWB_Tiporetención"; "Invoice Withholding Buffer"."Tipo retencion")
                {
                }
                column("IWB_Códretención"; "Invoice Withholding Buffer"."Cod. retencion")
                {
                }
                column("IWB_Importeretención"; "Invoice Withholding Buffer"."Importe retencion")
                {
                }
                column(IWB_Nombre; "Invoice Withholding Buffer".Nombre)
                {
                }
                column(IWB_FacturaProv; "Invoice Withholding Buffer"."Factura Prov")
                {
                }
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

                Clear(Cta);
                if Cta.Get("G/L Entry"."Account No.") then;
            end;

            trigger OnPreDataItem()
            begin
                if codDocNro <> '' then
                    SetRange("Document No.", codDocNro);

                Clear(rstCI);
                rstCI.Get();
            end;
        }
    }

    requestpage
    {

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
        strNombre: Text[1024];
        Prov: Record Vendor;
        Cta: Record "G/L Account";
        Cli: Record Customer;
        Banco: Record "Bank Account";
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
        rstCI: Record "Company Information";
        decAmount: Decimal;
        decAmountLCY: Decimal;
        decAmountLCYDoc: Decimal;

    [Scope('OnPrem')]
    procedure fntDoc(codDocu: Code[1024])
    begin
        codDocNro := codDocu;
    end;
}

