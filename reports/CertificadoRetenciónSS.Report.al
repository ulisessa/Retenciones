report 50611 "Certificado Retención SS"
{
    DefaultLayout = RDLC;
    RDLCLayout = 'projects/Administración/Impuestos/Retenciones/reports/CertificadoRetenciónSS.rdlc';
    EnableExternalImages = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Invoice Withholding Buffer"; "Invoice Withholding Buffer")
        {
            DataItemTableView = SORTING("Serie retención") WHERE(Retenido = CONST(true), "Tipo retencion" = CONST("Seguridad Social"));
            RequestFilterFields = "No. documento", "Serie retención";
            column(Logo; rstCI."Logo path")
            {
            }
            column("Certificado_de_Retención_"; 'Certificado de Retención')
            {
            }
            column("Fecha_de_emisón___"; 'Fecha de emisón: ')
            {
            }
            column(rstInfoEmpresa_Picture; rstInfoEmpresa.Picture)
            {
            }
            column(FORMAT__Factura_RT_Base_Buffer___Fecha_pago__; Format("Invoice Withholding Buffer"."Fecha pago"))
            {
            }
            column(N____; 'N°: ')
            {
            }
            column("Factura_RT_Base_Buffer__Factura_RT_Base_Buffer___Serie_retención_"; "Invoice Withholding Buffer"."Serie retención")
            {
            }
            column(rstInfoEmpresa__VAT_Registration_No__; rstInfoEmpresa."VAT Registration No.")
            {
            }
            column(CUIT__; 'CUIT:')
            {
            }
            column(rstProveedor__VAT_Registration_No__; rstProveedor."VAT Registration No.")
            {
            }
            column(CUIT___Control24; 'CUIT:')
            {
            }
            column(Domicilio_fiscal__; 'Domicilio fiscal:')
            {
            }
            column(rstInfoEmpresa_Address; rstInfoEmpresa.Address)
            {
            }
            column(rstProveedor_Address; rstProveedor.Address)
            {
            }
            column(Domicilio_fiscal___Control23; 'Domicilio fiscal:')
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Hoy; datHoy)
            {
            }
            column("Agente_retención__"; 'Agente retención:')
            {
            }
            column("Sujeto_retención__"; 'Sujeto retención:')
            {
            }
            column(rstProveedor_Name; rstProveedor.Name)
            {
            }
            column(Seguridad_Social_; 'Seguridad Social')
            {
            }
            column(Reg__General_Ret__RG__1784_; 'Reg. General Ret. RG. 1784')
            {
            }
            column(strDocumento; "Invoice Withholding Buffer"."Factura Prov")
            {
            }
            column(FechaEmision; "Invoice Withholding Buffer"."Fecha factura")
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
            column(N_Caption; N_CaptionLbl)
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
            column(Firma; rstConfCont.Signature)
            {
            }
            column(Fecha_pago; "Invoice Withholding Buffer"."Fecha pago")
            {
            }

            trigger OnAfterGetRecord()
            begin

                Clear(rstProveedor);
                rstProveedor.Get("Invoice Withholding Buffer"."Cliente/Proveedor");

                Clear(rstConfCont);
                rstConfCont.Get();
            end;

            trigger OnPreDataItem()
            begin
                rstInfoEmpresa.Get();
                rstInfoEmpresa.CalcFields(Picture);
                if codSerie <> '' then
                    "Invoice Withholding Buffer".SetRange("Serie retención", codSerie);
                rstConfCont.Get();
                //rstConfCont.CALCFIELDS(Signature);
                Clear(rstCI);
                rstCI.Get;
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
        strPie: Label 'Declaro que los datos consignados en este Formulario son correctos y completos y que he confeccionado la presente según normativas establecidas por la AFIP sin omitir ni falsear dato alguno que deba contener, siendo fiel expresión de la verdad.';
        N_CaptionLbl: Label 'N°';
        Importe_netoCaptionLbl: Label 'Importe neto';
        Importe_retenidoCaptionLbl: Label 'Importe retenido';
        Tipo_documentoCaptionLbl: Label 'Tipo documento';
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

