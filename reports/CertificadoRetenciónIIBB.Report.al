report 50616 "Certificado Retención IIBB"
{
    DefaultLayout = RDLC;
    RDLCLayout = 'reports/CertificadoRetenciónIIBB.rdl';
    EnableExternalImages = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("G/L Register"; "G/L Register")
        {
            RequestFilterFields = "No. documento";
            column(Logo; rstCI."Logo path")
            {
            }
            column(GLRegister_Documento; "G/L Register"."No. documento")
            {
            }
            column(Firma; rstConfCont.Signature)
            {
            }
            dataitem("Invoice Withholding Buffer"; "Invoice Withholding Buffer")
            {
                DataItemLink = "No. documento" = FIELD("No. documento"), "Fecha pago" = FIELD("Posting Date");
                DataItemTableView = SORTING("No. documento", "Cod. retencion") WHERE("Tipo retencion" = CONST("Ingresos Brutos"), Retenido = CONST(true));
                RequestFilterFields = "No. documento", "Serie retención";
                column(FORMAT__Factura_RT_Base_Buffer___Fecha_pago__; Format("Invoice Withholding Buffer"."Fecha pago"))
                {
                }
                column("Factura_RT_Base_Buffer__Factura_RT_Base_Buffer___Serie_retención_"; "Invoice Withholding Buffer"."Serie retención")
                {
                }
                column(rstProveedor_Name; rstProveedor.Name)
                {
                }
                column(Regimen; 'Régimen General')
                {
                }
                column(Reg__General_Ret__RG__830_; rstRetDesc."Descripción RG")
                {
                }
                column(Agente; 'Agente 12608')
                {
                }
                column(rstInfoEmpresa_Picture; rstInfoEmpresa.Picture)
                {
                }
                column(rstInfoEmpresa__VAT_Registration_No__; rstInfoEmpresa."VAT Registration No.")
                {
                }
                column(rstProveedor__VAT_Registration_No__; rstProveedor."VAT Registration No.")
                {
                }
                column(NroIIBBProveedor; rstProveedor."No. ingresos brutos")
                {
                }
                column(rstInfoEmpresa_Address_rstInfoEmpresa__Address_2_____; rstInfoEmpresa.Address + rstInfoEmpresa."Address 2" + ',')
                {
                }
                column(rstProveedor_Address_rstProveedor__Address_2_____; rstProveedor.Address + rstProveedor."Address 2" + ',')
                {
                }
                column(Provincia_de___rstInfoEmpresa_County____C_P____rstInfoEmpresa__Post_Code_; 'Provincia de ' + rstInfoEmpresa.County + ', C.P. ' + rstInfoEmpresa."Post Code")
                {
                }
                column(Provincia_de___rstProveedor_County____C_P____rstProveedor__Post_Code_; 'Provincia de ' + rstProveedor.County + ', C.P. ' + rstProveedor."Post Code")
                {
                }
                column(COMPANYNAME; CompanyName)
                {
                }
                column("Código___rstRetDesc__Código_SICORE________rstRetDesc_Descripción"; 'Código ' + rstRetDesc."Codigo SICORE" + ' - ' + rstRetDesc.Descripcion)
                {
                }
                column(Hoy; datHoy)
                {
                }
                column(Factura_RT_Base_Buffer__No__documento_; "Invoice Withholding Buffer"."No. documento")
                {
                }
                column("Factura_RT_Base_Buffer__Base_pago_retención_"; "Base pago retencion")
                {
                    DecimalPlaces = 2 : 2;
                }
                column("Factura_RT_Base_Buffer__Importe_retención__Control32"; "Importe retencion")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(FechaDocumento; "Invoice Withholding Buffer"."Fecha factura")
                {
                }
                column("rstConfCont__Persona_habilitada_certificado_______rstConfCont__Carácter_persona_habilitada_"; rstConfCont."Persona habilitada certificado" + ', ' + rstConfCont."Carácter persona habilitada")
                {
                }
                column(Empresa_Agente_ret; rstInfoEmpresa."Ag. Retencion Ganancias")
                {
                }
                column(Factura_RT_Base_Buffer_Tipo_registro; "Tipo registro")
                {
                }
                column(Tiporegistro_FacturaRTBaseBuffer; "Invoice Withholding Buffer"."Tipo registro")
                {
                }
                column(ClienteProveedor_FacturaRTBaseBuffer; "Invoice Withholding Buffer"."Cliente/Proveedor")
                {
                }
                column(Factura_RT_Base_Buffer__Tipo_factura_; "Invoice Withholding Buffer"."Tipo factura")
                {
                }
                column(NFactura_FacturaRTBaseBuffer; "Invoice Withholding Buffer"."No. Factura")
                {
                }
                column("Tiporetención_FacturaRTBaseBuffer"; "Invoice Withholding Buffer"."Tipo retencion")
                {
                }
                column("Códretención_FacturaRTBaseBuffer"; "Invoice Withholding Buffer"."Cod. retencion")
                {
                }
                column("Factura_RT_Base_Buffer__Importe_retención_"; "Invoice Withholding Buffer"."Importe retencion")
                {
                }
                column(Factura_RT_Base_Buffer_Cliente_Proveedor; "Cliente/Proveedor")
                {
                }
                column(Factura_RT_Base_Buffer__Importe_neto_factura_; "Invoice Withholding Buffer"."Importe neto factura")
                {
                }
                column(Factura_RT_Base_Buffer_N__Factura; "No. Factura")
                {
                }
                column("Factura_RT_Base_Buffer_Tipo_retención"; "Tipo retencion")
                {
                }
                column("Factura_RT_Base_Buffer_Cód__retención"; "Cod. retencion")
                {
                }
                column(AlicuotaRetencion; "Invoice Withholding Buffer"."% retencion")
                {
                }
                column(SituacionIVA; rst318.Description)
                {
                }
                column(NoIngBrutos; rstInfoEmpresa."No. ingresos brutos")
                {
                }
                column(TipoAgenteIIBB; rstInfoEmpresa."GI agent type")
                {
                }
                column(NroAgenteIIBB; rstInfoEmpresa."GI agent no.")
                {
                }
                column(Firmante; rstConfCont.Signatary)
                {
                }
                column(Fecha_pago; "Invoice Withholding Buffer"."Fecha pago")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(rstProveedor);
                    rstProveedor.Get("Invoice Withholding Buffer"."Cliente/Proveedor");

                    Clear(rstRetDesc);
                    rstRetDesc.Get("Invoice Withholding Buffer"."Tipo retencion", "Invoice Withholding Buffer"."Cod. retencion");

                    Clear(rstMovIva);
                    rstMovIva.SetCurrentKey(Type, "Posting Date", "External Document No.", "Bill-to/Pay-to No.");
                    rstMovIva.SetRange(rstMovIva."External Document No.", strDocumento);
                    rstMovIva.SetRange("Bill-to/Pay-to No.", "Invoice Withholding Buffer"."Cliente/Proveedor");
                    rstMovIva.CalcSums(rstMovIva.Amount, Base);

                    Clear(rstMovIvab);
                    rstMovIvab.SetCurrentKey(Type, "Posting Date", "External Document No.", "Bill-to/Pay-to No.");
                    rstMovIvab.SetRange("Document No.", "Invoice Withholding Buffer"."Factura liquidada");
                    rstMovIvab.SetRange("Bill-to/Pay-to No.", "Invoice Withholding Buffer"."Cliente/Proveedor");
                    rstMovIvab.FindFirst;

                    Clear(rst318);
                    rst318.Get(rstMovIvab."Tax Area Code");

                    "Invoice Withholding Buffer".CalcFields("Importe minimo retención");

                    Clear(rstConfRet);
                    rstConfRet.SetRange("Tipo retenciones", "Tipo retencion"::"Ingresos Brutos");
                    rstConfRet.SetRange(rstConfRet."Cod. retencion", "Cod. retencion");
                    rstConfRet.SetRange(rstConfRet."Tipo fiscal", "Tipo fiscal");
                    rstConfRet.SetRange(rstConfRet.Provincia, Provincia);
                    rstConfRet.SetRange("Importe minimo Stepwise", 0, rstMovIva.Base);
                    if rstConfRet.FindLast then
                        decMinImpo := rstConfRet."Importe pago minimo";

                    decPagAnt := fntTotPagoAnterior;
                    //decMinImpo := "Importe mínimo retención";
                    decTotal := "Invoice Withholding Buffer"."Importe retencion";
                    decTotRetenido := fntTotRetenido;
                    decRetenidoAnterior := fntTotRetenidoAnterior;
                    decRetenido := fntTotRetenido + fntTotRetenidoAnterior;
                end;

                trigger OnPreDataItem()
                begin
                    rstInfoEmpresa.Get();
                    rstInfoEmpresa.CalcFields(Picture);
                    if codSerie <> '' then
                        "Invoice Withholding Buffer".SetRange("Serie retención", codSerie);
                    rstConfCont.Get();
                    datHoy := Today;
                end;
            }
            dataitem("Factura RT Base Buffer2"; "Vendor Ledger Entry")
            {
                CalcFields = Amount;
                DataItemLink = "Document No." = FIELD("No. documento"), "Posting Date" = FIELD("Posting Date");
                DataItemLinkReference = "G/L Register";
                DataItemTableView = SORTING("Document No.");
                column("Fecha_de_emisón____Control1000000029"; 'Fecha de emisón: ')
                {
                }
                column(N_____Control1000000030; 'N°: ')
                {
                }
                column("Factura_RT_Base_Buffer___Serie_retención_"; "Invoice Withholding Buffer"."Serie retención")
                {
                }
                column(FORMAT__Factura_RT_Base_Buffer___Fecha_pago___Control1000000032; Format("Invoice Withholding Buffer"."Fecha pago"))
                {
                }
                column(rstInfoEmpresa_Picture_Control1000000033; rstInfoEmpresa.Picture)
                {
                }
                column(Detalle_de_documentos_liquidados_; 'Detalle de documentos liquidados')
                {
                }
                column(optTD; Format(optTD))
                {
                }
                column(strDocumento; strDocumento)
                {
                }
                column(decImporte; decImporte)
                {
                    DecimalPlaces = 2 : 2;
                }
                column(Total_Documentos_liquidados_; 'Total Documentos liquidados')
                {
                }
                column(Pagos_anteriores_; 'Pagos anteriores')
                {
                }
                column("Mínimo_no_imponible_"; 'Mínimo no imponible')
                {
                }
                column(Retenciones_calculada_; 'Retenciones calculada')
                {
                }
                column(Retenciones_anteriores_; 'Retenciones anteriores')
                {
                }
                column("Total_retención_"; 'Total retención')
                {
                }
                column(FechaEmision; datFecha)
                {
                }
                column(decTotal; decTotal)
                {
                    DecimalPlaces = 2 : 2;
                }
                column(decPagAnt; decPagAnt)
                {
                    DecimalPlaces = 2 : 2;
                }
                column(decIVA; decIVA)
                {
                }
                column(decMinImpo; decMinImpo)
                {
                    DecimalPlaces = 2 : 2;
                }
                column("decRetenido__Factura_RT_Base_Buffer___Importe_retención_"; decRetenido + "Invoice Withholding Buffer"."Importe retencion")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(decRetenido; -decRetenido)
                {
                    DecimalPlaces = 2 : 2;
                }
                column(decTotRetenido; decTotRetenido)
                {
                }
                column(decRetenidoAnterior; decRetenidoAnterior)
                {
                }
                column(Detailed_Vendor_Ledg__Entry_Entry_No_; "Entry No.")
                {
                }
                column(Detailed_Vendor_Ledg__Entry_Vendor_No_; "Vendor No.")
                {
                }
                column(Detailed_Vendor_Ledg__Entry_Document_No_; "Document No.")
                {
                }

                trigger OnAfterGetRecord()
                var
                    rstWI: Record "Invoice Withholding Buffer";
                    rstLF: Record "Purch. Inv. Line";
                begin
                    decImporte := 0;
                    decIVA := 0;

                    strDocumento := '';

                    if (("Applies-to Doc. Type" <> "Applies-to Doc. Type"::" ") and ("Applies-to Doc. No." <> '')) then begin

                        rstMovProv2.SetRange("Document Type", "Applies-to Doc. Type");
                        rstMovProv2.SetRange("Document No.", "Applies-to Doc. No.");
                        if rstMovProv2.FindFirst then begin

                            rstMovProv2.CalcFields("Amount (LCY)");
                            strDocumento := rstMovProv2."External Document No.";
                            optTD := rstMovProv2."Document Type";
                            decImporte := rstMovProv2."Purchase (LCY)";
                            decIVA := rstMovProv2."Amount (LCY)" - rstMovProv2."Purchase (LCY)";
                            datFecha := rstMovProv2."Document Date";

                        end;

                    end
                    else begin

                        Clear(rstMovProv2);
                        rstMovProv2.SetRange("Closed by Entry No.", "Factura RT Base Buffer2"."Entry No.");
                        if rstMovProv2.FindFirst then begin

                            rstMovProv2.CalcFields("Amount (LCY)");
                            strDocumento := rstMovProv2."External Document No.";
                            optTD := rstMovProv2."Document Type";
                            decImporte := rstMovProv2."Purchase (LCY)";
                            decIVA := rstMovProv2."Amount (LCY)" - rstMovProv2."Purchase (LCY)";
                            datFecha := rstMovProv2."Document Date";

                        end;

                    end;

                    //calcfields("Factura RT Base Buffer2"."Amount (LCY)");
                    //decImporte := "Factura RT Base Buffer2"."Amount (LCY)";
                    decTotal += decImporte;

                    Clear(rstConfRet);
                    rstConfRet.SetRange("Tipo retenciones", "Invoice Withholding Buffer"."Tipo retencion"::"Ingresos Brutos");
                    rstConfRet.SetRange(rstConfRet."Cod. retencion", "Invoice Withholding Buffer"."Cod. retencion");
                    rstConfRet.SetRange(rstConfRet."Tipo fiscal", "Invoice Withholding Buffer"."Tipo fiscal");
                    rstConfRet.SetRange(rstConfRet.Provincia, "Invoice Withholding Buffer".Provincia);
                    rstConfRet.SetRange("Importe minimo Stepwise", 0, decImporte);
                    if rstConfRet.FindLast then
                        decMinImpo := rstConfRet."Importe pago minimo";
                end;

                trigger OnPreDataItem()
                begin
                    "Factura RT Base Buffer2".SetRange("Document Type", "Factura RT Base Buffer2"."Document Type"::Payment);
                    "Factura RT Base Buffer2".SetRange("Document No.", "Invoice Withholding Buffer"."No. documento");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Clear(rstCI);
                rstCI.Get;
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

    trigger OnPreReport()
    begin
        rstInfoEmpresa.Get();
        if codSerie <> '' then
            "Invoice Withholding Buffer".SetRange("Serie retención", codSerie);
        rstConfCont.Get();
    end;

    var
        rstInfoEmpresa: Record "Company Information";
        rstProveedor: Record Vendor;
        rstConfCont: Record "General Ledger Setup";
        strDocumento: Code[1024];
        rstMovProv: Record "Vendor Ledger Entry";
        rstMovProv2: Record "Vendor Ledger Entry";
        codSerie: Code[30];
        rstMovIva: Record "VAT Entry";
        rstRetDesc: Record "Withholding codes";
        strPie: Label 'Declaro que los datos consignados en este Formulario son correctos y completos y que he confeccionado la presente según normativas establecidas por la AFIP sin omitir ni falsear dato alguno que deba contener, siendo fiel expresión de la verdad.';
        decImporte: Decimal;
        decTotal: Decimal;
        decPagAnt: Decimal;
        decMinImpo: Decimal;
        rstConfRet: Record "Withholding setup";
        rstFacBuf: Record "Invoice Withholding Buffer";
        decRetenido: Decimal;
        CreateVendLedgEntry: Record "Vendor Ledger Entry";
        Importe_netoCaptionLbl: Label 'Importe neto';
        Importe_retenidoCaptionLbl: Label 'Importe retenido';
        Tipo_documentoCaptionLbl: Label 'Tipo documento';
        "Tipo_retenciónCaptionLbl": Label 'Tipo retención';
        N_CaptionLbl: Label 'N°';
        Total_retenido_CaptionLbl: Label 'Total retenido:';
        Firma_responsable_CaptionLbl: Label 'Firma responsable:';
        optTD: Enum "Gen. Journal Document Type";
        decTotRetenido: Decimal;
        decRetenidoAnterior: Decimal;
        decIVA: Decimal;
        rstCI: Record "Company Information";
        rstGLS: Record "General Ledger Setup";
        datHoy: Date;
        rst318: Record "Tax Area";
        rstMovIvab: Record "VAT Entry";
        datFecha: Date;

    [Scope('OnPrem')]
    procedure fntFiltros(l_codSerie: Code[30])
    begin
        "Invoice Withholding Buffer".Reset;
        codSerie := '';
        if l_codSerie <> '' then
            codSerie := l_codSerie;
    end;

    [Scope('OnPrem')]
    procedure FindApplnEntriesDtldtLedgEntry()
    var
        DtldVendLedgEntry1: Record "Detailed Vendor Ledg. Entry";
        DtldVendLedgEntry2: Record "Detailed Vendor Ledg. Entry";
    begin
        Clear(rstMovProv);
        DtldVendLedgEntry1.SetCurrentKey("Vendor Ledger Entry No.");
        DtldVendLedgEntry1.SetRange("Vendor Ledger Entry No.", CreateVendLedgEntry."Entry No.");
        DtldVendLedgEntry1.SetRange(Unapplied, false);
        if DtldVendLedgEntry1.Find('-') then begin
            repeat
                if DtldVendLedgEntry1."Vendor Ledger Entry No." =
                  DtldVendLedgEntry1."Applied Vend. Ledger Entry No."
                then begin
                    DtldVendLedgEntry2.Init;
                    DtldVendLedgEntry2.SetCurrentKey("Applied Vend. Ledger Entry No.", "Entry Type");
                    DtldVendLedgEntry2.SetRange(
                      "Applied Vend. Ledger Entry No.", DtldVendLedgEntry1."Applied Vend. Ledger Entry No.");
                    DtldVendLedgEntry2.SetRange("Entry Type", DtldVendLedgEntry2."Entry Type"::Application);
                    DtldVendLedgEntry2.SetRange(Unapplied, false);
                    if DtldVendLedgEntry2.Find('-') then begin
                        repeat
                            if DtldVendLedgEntry2."Vendor Ledger Entry No." <>
                              DtldVendLedgEntry2."Applied Vend. Ledger Entry No."
                            then begin
                                rstMovProv.SetCurrentKey("Entry No.");
                                rstMovProv.SetRange("Entry No.", DtldVendLedgEntry2."Vendor Ledger Entry No.");
                                if rstMovProv.Find('-') then begin
                                    decImporte := -rstMovProv."Purchase (LCY)";
                                    strDocumento := rstMovProv."External Document No.";
                                end;
                            end;
                        until DtldVendLedgEntry2.Next = 0;
                    end;
                end else begin
                    rstMovProv.SetCurrentKey("Entry No.");
                    rstMovProv.SetRange("Entry No.", DtldVendLedgEntry1."Applied Vend. Ledger Entry No.");
                    if rstMovProv.Find('-') then begin
                        decImporte := -rstMovProv."Purchase (LCY)";
                        strDocumento := rstMovProv."External Document No.";
                    end;
                end;
            until DtldVendLedgEntry1.Next = 0;
        end;
    end;

    [Scope('OnPrem')]
    procedure fntTotRetenido(): Decimal
    var
        rstIWB: Record "Invoice Withholding Buffer";
    begin
        Clear(rstIWB);
        rstIWB.SetRange("Tipo retencion", rstIWB."Tipo retencion"::"Ingresos Brutos");
        rstIWB.SetRange("No. documento", "Invoice Withholding Buffer"."No. documento");
        rstIWB.SetRange(Retenido, true);
        rstIWB.CalcSums(rstIWB."Importe retencion");
        exit(rstIWB."Importe retencion");
    end;

    [Scope('OnPrem')]
    procedure fntTotRetenidoAnterior(): Decimal
    var
        rstIWB: Record "Invoice Withholding Buffer";
    begin
        Clear(rstIWB);
        rstIWB.SetRange("Tipo retencion", rstIWB."Tipo retencion"::"Ingresos Brutos");
        rstIWB.SetRange("No. documento", "Invoice Withholding Buffer"."No. documento");
        rstIWB.SetRange(Retenido, true);
        rstIWB.CalcSums(rstIWB."Importe retenciones anteriores");
        exit(rstIWB."Importe retenciones anteriores");
    end;

    [Scope('OnPrem')]
    procedure fntTotPagoAnterior(): Decimal
    var
        rstIWB: Record "Invoice Withholding Buffer";
    begin
        Clear(rstIWB);
        rstIWB.SetRange("Tipo retencion", rstIWB."Tipo retencion"::"Ingresos Brutos");
        rstIWB.SetRange("No. documento", "Invoice Withholding Buffer"."No. documento");
        rstIWB.SetRange(Retenido, true);
        rstIWB.CalcSums(rstIWB."Pagos anteriores");
        exit(rstIWB."Pagos anteriores");
    end;
}

