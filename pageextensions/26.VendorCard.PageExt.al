pageextension 26 "Taxes Vendor Card" extends "Vendor Card"
{
    layout
    {
        addafter("Foreign Trade")
        {
            group(ARCA_Invoicing)
            {
                //CaptionML = ENU = 'ARCA Invoicing', ESP = 'ARCA Facturación';
                Caption = 'AFIP Facturación';
                field("Tipo autorizacion"; "Tipo autorizacion")
                {
                }
                field("N° CAI"; "No.CAI")
                {
                }
                field("Fecha vencimiento CAI"; "Fecha vencimiento CAI")
                {
                }
                field("Lleva CAI"; "Lleva CAI")
                {
                }
                field("Comprobar N° factura proveedor"; "Comprobar No.factura proveedor")
                {
                }
                field("Omitir validación WS-AFIP"; "Omitir validación WS-AFIP")
                {
                }
                field("Admite factura directa"; "Admite factura directa")
                {
                }

            }
        }
        addafter("Exclude from Pmt. Practices")
        {
            field("Sin Autorizacion Pago"; "Sin Autorizacion Pago")
            {
            }
            field("Lugar de Pago"; "Lugar de Pago")
            {
            }
            field("Cheque a la orden de"; "Cheque a la orden de")
            {
            }

        }
        addlast(content)
        {
            group(Taxes)
            {
                Caption = 'Taxes';

                field("Tipo persona"; "Tipo persona")
                {
                }
                field("Tipo retención"; "Tipo retención")
                {
                }
                field("Cód. retención IVA"; "Cód. retención IVA")
                {
                }
                field("Cód. retención SS"; "Cód. retención SS")
                {
                }
                field("Cód. retención ganancias"; "Cód. retención ganancias")
                {
                }
                field("Imp Ganancias"; "Imp Ganancias")
                {
                }
                field("Imp IVA"; "Imp IVA")
                {
                }
                field(Monotributo; Monotributo)
                {
                }
                field("Nº resolucion IVA"; "No. resolucion IVA")
                {
                }
                field("Fecha consulta Reproweb"; "Fecha consulta Reproweb")
                {
                    Editable = false;
                }
                field("Estado de situación fiscal"; "Estado de situación fiscal")
                {
                    Editable = false;
                }
                field(Empleador; Empleador)
                {
                }
                field("Integrante Soc"; "Integrante Soc")
                {
                }
                field("Exento retención SS"; "Exento retención SS")
                {
                }
                field("Exento retención IVA"; "Exento retención IVA")
                {
                }
                field("Exento ganancias"; "Exento ganancias")
                {
                }
                field("Exento ganancias 3594"; "Exento ganancias 3594")
                {
                }
                field("Agente retención IB"; "Agente retención IB")
                {
                }
                field("Agente retención IVA"; "Agente retención IVA")
                {
                }
                field("Tipo Fiscal"; "VAT Bus. Posting Group")
                {
                }
                field("Fecha Consulta"; "Fecha Consulta")
                {
                    Caption = 'Fecha consulta constancia';
                    Editable = false;
                }
                field("Fecha digitalizacion IIBB"; "Fecha digitalizacion IIBB")
                {
                }
                field("Documentacion IIBB verificada"; "Documentacion IIBB verificada")
                {
                }
                field("Inscripto IIBB"; "Inscripto IIBB")
                {
                }
                field("GI Inscription type"; "GI Inscription type")
                {
                }
                field("Nº ingresos brutos"; "No. ingresos brutos")
                {
                }
                field("Cód. retención IIBB"; "Cód. retención IIBB")
                {
                }

            }
            group(Dimensions)
            {
                //CaptionML = ENU = 'Dimensions', ESP = 'Dimensiones';

                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    CaptionClass = '1,1,1';
                    Caption = 'Global Dimension 1 Code';
                    TableRelation = "Dimension Value".Code Where("Global Dimension No." = CONST(1));
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    CaptionClass = '1,1,2';
                    Caption = 'Global Dimension 2 Code';
                    TableRelation = "Dimension Value".Code Where("Global Dimension No." = CONST(2));
                }
                field("Global Dimension 3 Code"; "Global Dimension 3 Code")
                {
                    CaptionClass = '1,1,3';
                    Caption = 'Global Dimension 3 Code';
                    TableRelation = "Dimension Value".Code Where("Global Dimension No." = CONST(3));
                }
                field("Global Dimension 4 Code"; "Global Dimension 4 Code")
                {
                    CaptionClass = '1,1,4';
                    Caption = 'Global Dimension 4 Code';
                    TableRelation = "Dimension Value".Code Where("Global Dimension No." = CONST(4));
                }
                field("Global Dimension 5 Code"; "Global Dimension 5 Code")
                {
                    CaptionClass = '1,1,5';
                    Caption = 'Global Dimension 5 Code';
                    TableRelation = "Dimension Value".Code Where("Global Dimension No." = CONST(5));
                }
                field("Global Dimension 6 Code"; "Global Dimension 6 Code")
                {
                    CaptionClass = '1,1,6';
                    Caption = 'Global Dimension 6 Code';
                    TableRelation = "Dimension Value".Code Where("Global Dimension No." = CONST(6));
                }
                field("Global Dimension 7 Code"; "Global Dimension 7 Code")
                {
                    CaptionClass = '1,1,7';
                    Caption = 'Global Dimension 7 Code';
                    TableRelation = "Dimension Value".Code Where("Global Dimension No." = CONST(7));
                }
                field("Concepto proyecto"; "Concepto proyecto")
                {
                    Caption = 'Concepto Proyecto';
                    TableRelation = "Concepto proyecto"."Código";
                }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            group(Taxes_Group)
            {
                Caption = 'Taxes';

                action("Digitalizar documento")
                {
                    Image = Attach;
                    //PromotedIsBig = true;

                    trigger OnAction()
                    var
                        frmDigitalizar: Page "Ruta digitalización";
                        cduDigitalizarOAbrir: Codeunit Escaneado;
                        rstDigitalizar: Record "Ruta digitalizacion depto/espe";
                        rstArchivos: Record "Documentos digitalizados";
                    begin
                        //++ Migración Arbumasa 2009
                        Clear(frmDigitalizar);
                        Clear(rstDigitalizar);

                        frmDigitalizar.funLlamarCapturador('', '', '', "No.", UserId, '', '', '', '', '', '');
                        frmDigitalizar.LookupMode(true);
                        frmDigitalizar.SetTableView(rstDigitalizar);
                        //IF frmDigitalizar.RUNMODAL = ACTION::LookupOK THEN
                        frmDigitalizar.RunModal;
                        begin

                            frmDigitalizar.GetRecord(rstDigitalizar);
                            Clear(rstArchivos);
                            rstArchivos.SetRange(rstArchivos."Nivel 1", 'CONSTANCIA');
                            //  rstArchivos.SETRANGE(rstArchivos."Nivel 2",FORMAT(DATE2DMY(TODAY,1))+'/'+FORMAT(DATE2DMY(TODAY,2))+'/'+
                            //  COPYSTR(FORMAT(DATE2DMY(TODAY,3)),3,2));
                            rstArchivos.SetRange(rstArchivos."Nivel 4", "No.");
                            if rstArchivos.FindLast then
                                "Fecha Consulta" := Today;

                        end;
                        //-- Migración arbumasa 2009
                    end;
                }
                action("Exenciones impositivas")
                {
                    Caption = 'Exenciones impositivas';
                    Image = ElectronicVATExemption;
                    RunObject = Page "Withholding Tax Excemption";
                    RunPageLink = "Cod. proveedor/cliente" = FIELD("No.");
                    RunPageView = WHERE("Tipo retención" = FILTER(<> "Ingresos Brutos"));
                }
                action("Padrón IIBB")
                {
                    Caption = 'Padrón IIBB';
                    Image = ElectronicDoc;
                    //PromotedIsBig = true;
                    RunObject = Page "Withholding Tax Excemption";
                    RunPageLink = "Cod. proveedor/cliente" = FIELD("No."),
                                  "Tipo registro" = CONST(Compra);
                    RunPageView = WHERE("Tipo retención" = CONST("Ingresos Brutos"),
                                        "Tipo registro" = CONST(Compra));
                }
                action("Sincronizar con AFIP")
                {
                    Image = "1099Form";

                    trigger OnAction()
                    var
                        l_rstGLS: Record "General Ledger Setup";
                        l_cduWS: Codeunit "WS - AFIP";
                        l_rstCI: Record "Company Information";
                        Message001: Label '¿Desea sincronizar los datos de este proveedor incorporando lo provisto por la AFIP?';
                        l_rst23: Record Vendor;
                        l_codMes: Code[2];
                        l_codYear: Code[4];
                    begin
                        //++Arbu 2020
                        Clear(l_rst23);
                        CurrPage.SetSelectionFilter(l_rst23);
                        l_rst23.Validate("VAT Registration No.", "No.");
                        Clear(l_rstGLS);
                        l_rstGLS.Get();
                        Clear(l_rstCI);
                        l_rstCI.Get();

                        if l_rstGLS."WS - CUIT Check Dimension" <> '' then begin
                            if Confirm(Message001) then begin

                                l_cduWS.fntPersonaService5('ws_sr_constancia_inscripcion', DelChr(l_rstCI."VAT Registration No.", '=', '-'), DelChr(l_rst23."VAT Registration No.", '=', '-'), '', l_rst23);

                            end;

                        end;

                        if l_rstGLS."WS - Reproweb Dimension" <> '' then begin

                            l_codMes := Format(Date2DMY(Today, 2));
                            l_codYear := Format(Date2DMY(Today, 3));
                            if StrLen(l_codMes) = 1 then
                                l_codMes := '0' + l_codMes;
                            l_cduWS.fntReprowebIndividual('wsagr', DelChr(l_rstCI."VAT Registration No.", '=', '-'), DelChr("VAT Registration No.", '=', '-'), l_codMes + '/' + l_codYear);

                        end;

                        //--Arbu 2020
                    end;
                }
                action("Actividades AFIP")
                {
                    Image = BulletList;

                    RunObject = Page "Lista actividad proveedor";
                    RunPageLink = "No. proveedor" = FIELD("No.");
                }
                action("Relación con recursos")
                {
                    Caption = 'Relación con recursos';
                    RunObject = Page "Lista flia. rec. por proveedor";
                    RunPageLink = "No. proveedor" = FIELD("No.");
                }
            }
        }
        addlast(Category_Category9)
        {
            actionref("Digitalizar documento_Promoted"; "Digitalizar documento")
            {
            }
        }
        addfirst(Category_Process)
        {
            group(Category_Taxes)
            {
                Caption = 'Taxes';
                actionref("Exenciones impositivas_Promoted"; "Exenciones impositivas")
                {
                }
                actionref("Padrón IIBB_Promoted"; "Padrón IIBB")
                {
                }
                actionref("Sincronizar con AFIP_Promoted"; "Sincronizar con AFIP")
                {
                }
                actionref("Actividades AFIP_Promoted"; "Actividades AFIP")
                {
                }
            }
        }
        addlast(Category_Category7)
        {
            actionref("Relación con recursos_Promoted"; "Relación con recursos")
            {
            }
        }
    }
}