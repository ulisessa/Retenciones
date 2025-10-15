report 50614 "Certificado Retención IVA"
{
    DefaultLayout = RDLC;
    RDLCLayout = 'projects/Administración/Impuestos/Retenciones/reports/CertificadoRetenciónIVA.rdlc';
    EnableExternalImages = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Invoice Withholding Buffer"; "Invoice Withholding Buffer")
        {
            DataItemTableView = SORTING("Serie retención", "Cod. retencion") WHERE(Retenido = CONST(true), "Tipo retencion" = CONST(IVA));
            RequestFilterFields = "No. documento", "Serie retención";
            column(Logo; rstCI."Logo path")
            {
            }
            column(FORMAT__Factura_RT_Base_Buffer___Fecha_pago__; Format("Invoice Withholding Buffer"."Fecha pago"))
            {
            }
            column("Factura_RT_Base_Buffer__Factura_RT_Base_Buffer___Serie_retención_"; "Invoice Withholding Buffer"."Serie retención")
            {
            }
            column("Fecha_de_emisón___"; 'Fecha de emisón: ')
            {
            }
            column(N____; 'N°: ')
            {
            }
            column("Certificado_de_Retención_"; 'Certificado de Retención')
            {
            }
            column(IVA_; 'IVA')
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column("Sujeto_retención__"; 'Sujeto retención:')
            {
            }
            column(rstProveedor_Name; rstProveedor.Name)
            {
            }
            column(Reg__General_Ret__RG__18_; 'Reg. General Ret. RG. 18')
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
            column(CUIT__; 'CUIT:')
            {
            }
            column(rstInfoEmpresa_Address_rstInfoEmpresa__Address_2_____; rstInfoEmpresa.Address + rstInfoEmpresa."Address 2" + ',')
            {
            }
            column(rstProveedor_Address_rstProveedor__Address_2_____; rstProveedor.Address + rstProveedor."Address 2" + ',')
            {
            }
            column(Domicilio_fiscal__; 'Domicilio fiscal:')
            {
            }
            column(CUIT___Control15; 'CUIT:')
            {
            }
            column(Domicilio_fiscal___Control12; 'Domicilio fiscal:')
            {
            }
            column("Agente_retención__"; 'Agente retención:')
            {
            }
            column(Hoy; datHoy)
            {
            }
            column(Provincia_de___rstInfoEmpresa_County____C_P____rstInfoEmpresa__Post_Code_; 'Provincia de ' + rstInfoEmpresa.County + ', C.P. ' + rstInfoEmpresa."Post Code")
            {
            }
            column(Provincia_de___rstProveedor_County____C_P____rstProveedor__Post_Code_; 'Provincia de ' + rstProveedor.County + ', C.P. ' + rstProveedor."Post Code")
            {
            }
            column("Código___rstRetDesc__Código_SICORE________rstRetDesc_Descripción"; 'Código ' + rstRetDesc."Codigo SICORE" + ' - ' + rstRetDesc.Descripcion)
            {
            }
            column(strDocumento; strDocumento)
            {
            }
            column(Factura_RT_Base_Buffer__Importe_neto_factura_; "Importe neto factura")
            {
                DecimalPlaces = 2 : 2;
            }
            column("Factura_RT_Base_Buffer__Importe_retención_"; "Importe retencion")
            {
                DecimalPlaces = 2 : 2;
            }
            column(Factura_RT_Base_Buffer__Tipo_factura_; "Tipo factura")
            {
            }
            column(rstMovIva_Amount; rstMovIva.Amount)
            {
                DecimalPlaces = 2 : 2;
            }
            column("Factura_RT_Base_Buffer__Importe_retención__Control32"; "Importe retencion")
            {
                DecimalPlaces = 2 : 2;
            }
            column("rstConfCont__Persona_habilitada_certificado_______rstConfCont__Carácter_persona_habilitada_"; rstConfCont."Persona habilitada certificado" + ', ' + rstConfCont."Carácter persona habilitada")
            {
            }
            column(EmptyString; '________________________________________________________')
            {
            }
            column(strPie; strPie)
            {
            }
            column(Importe_netoCaption; Importe_netoCaptionLbl)
            {
            }
            column(Importe_retenidoCaption; Importe_retenidoCaptionLbl)
            {
            }
            column(Tipo_documentoCaption; Tipo_documentoCaptionLbl)
            {
            }
            column("Tipo_retenciónCaption"; Tipo_retenciónCaptionLbl)
            {
            }
            column(N_Caption; N_CaptionLbl)
            {
            }
            column(IVACaption; IVACaptionLbl)
            {
            }
            column(Total_retenido_Caption; Total_retenido_CaptionLbl)
            {
            }
            column(Firma_responsable_Caption; Firma_responsable_CaptionLbl)
            {
            }
            column(Factura_RT_Base_Buffer_Tipo_registro; "Tipo registro")
            {
            }
            column(Factura_RT_Base_Buffer_Cliente_Proveedor; "Cliente/Proveedor")
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
            column(Factura_RT_Base_Buffer_No__documento; "Invoice Withholding Buffer"."No. documento")
            {
            }
            column(Firmante; rstConfCont.Signatary)
            {
            }
            column(Firma; rstConfCont.Signature)
            {
            }
            column(Fecha_pago; "Invoice Withholding Buffer"."Fecha pago")
            {
            }

            trigger OnAfterGetRecord()
            begin
                rstConfCont.Get();

                Clear(rstRetDesc);
                rstRetDesc.Get("Invoice Withholding Buffer"."Tipo retencion", "Invoice Withholding Buffer"."Cod. retencion");


                Clear(rstProveedor);
                rstProveedor.Get("Invoice Withholding Buffer"."Cliente/Proveedor");



                strDocumento := '';
                Clear(rstMovProv);

                if "Invoice Withholding Buffer"."Tipo factura" = "Invoice Withholding Buffer"."Tipo factura"::"Nota d/c" then begin

                    Clear(rstMovProv);
                    rstMovProv.SetCurrentKey(rstMovProv."Vendor No.", rstMovProv."Document Type", rstMovProv."Document No.");
                    rstMovProv.SetRange(rstMovProv."Vendor No.", "Invoice Withholding Buffer"."Cliente/Proveedor");
                    rstMovProv.SetRange(rstMovProv."Document Type", rstMovProv."Document Type"::"Credit Memo");
                    rstMovProv.SetRange(rstMovProv."Document No.", "Invoice Withholding Buffer"."No. Factura");
                    rstMovProv.SetRange(Anulado, false);
                    if rstMovProv.Find('-') then
                        strDocumento := rstMovProv."External Document No.";

                end;

                if "Invoice Withholding Buffer"."Tipo factura" = "Invoice Withholding Buffer"."Tipo factura"::Factura then begin

                    Clear(rstMovProv);
                    rstMovProv.SetCurrentKey(rstMovProv."Vendor No.", rstMovProv."Document Type", rstMovProv."Document No.");
                    rstMovProv.SetRange(rstMovProv."Vendor No.", "Invoice Withholding Buffer"."Cliente/Proveedor");
                    rstMovProv.SetRange(rstMovProv."Document Type", rstMovProv."Document Type"::Invoice);
                    rstMovProv.SetRange(rstMovProv."Document No.", "Invoice Withholding Buffer"."No. Factura");
                    rstMovProv.SetRange(Anulado, false);
                    if rstMovProv.Find('-') then
                        strDocumento := rstMovProv."External Document No.";

                end;

                Clear(rstMovIva);
                rstMovIva.SetCurrentKey(rstMovIva.Type, "Posting Date", "External Document No.", rstMovIva."Bill-to/Pay-to No.");
                rstMovIva.SetRange(rstMovIva."External Document No.", strDocumento);
                rstMovIva.SetRange(rstMovIva."Bill-to/Pay-to No.", "Invoice Withholding Buffer"."Cliente/Proveedor");
                rstMovIva.CalcSums(rstMovIva.Amount);
            end;

            trigger OnPreDataItem()
            begin
                rstInfoEmpresa.Get();
                rstInfoEmpresa.CalcFields(Picture);
                Clear(rstCI);
                rstCI.Get;

                if codSerie <> '' then
                    "Invoice Withholding Buffer".SetRange("Serie retención", codSerie);
                rstConfCont.Get();
                datHoy := Today;
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
        rstInfoEmpresa: Record "Company Information";
        rstProveedor: Record Vendor;
        rstConfCont: Record "General Ledger Setup";
        strDocumento: Code[1024];
        rstMovProv: Record "Vendor Ledger Entry";
        codSerie: Code[30];
        rstMovIva: Record "VAT Entry";
        rstRetDesc: Record "Withholding codes";
        strPie: Label 'Declaro que los datos consignados en este Formulario son correctos y completos y que he confeccionado la presente según normativas establecidas por la AFIP sin omitir ni falsear dato alguno que deba contener, siendo fiel expresión de la verdad.';
        Importe_netoCaptionLbl: Label 'Importe neto';
        Importe_retenidoCaptionLbl: Label 'Importe retenido';
        Tipo_documentoCaptionLbl: Label 'Tipo documento';
        "Tipo_retenciónCaptionLbl": Label 'Tipo retención';
        N_CaptionLbl: Label 'N°';
        IVACaptionLbl: Label 'IVA';
        Total_retenido_CaptionLbl: Label 'Total retenido:';
        Firma_responsable_CaptionLbl: Label 'Firma responsable:';
        rstCI: Record "Company Information";
        datHoy: Date;

    [Scope('OnPrem')]
    procedure fntFiltros(l_codSerie: Code[30])
    begin
        "Invoice Withholding Buffer".Reset;
        codSerie := '';
        if l_codSerie <> '' then
            codSerie := l_codSerie;
    end;
}

