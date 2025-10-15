page 50728 "Invoices WT Base Buffer"
{
    Editable = false;
    PageType = List;
    SourceTable = "Invoice Withholding Buffer";
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Invoices WT Base Buffer';
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(CUIT; strCUIT)
                {
                }
                field(Nombre; strNombre)
                {
                }
                field("Importe IVA"; decImpoIVA)
                {
                }
                field("Situación IIBB"; strSituacionIBRetenido)
                {
                }
                field("No. IIBB"; strNroIIBB)
                {
                }
                field("Factura Prov"; "Factura Prov")
                {
                }
                field("Tipo comprobante"; strTipo)
                {
                }
                field("Letra comprobante"; strLetraComprobante)
                {
                }
                field("Sucursal comprobante"; strSucursal)
                {
                }
                field("No. comprobante"; strComprobante)
                {
                }
                field("Importe comprobante"; decImpComp)
                {
                }
                field("Otros conceptos"; decOtros)
                {
                }
                field("Monto sujeto"; strBase)
                {
                }
                field("Tipo registro"; "Tipo registro")
                {
                    Visible = false;
                }
                field("Cliente/Proveedor"; "Cliente/Proveedor")
                {
                    Visible = false;
                }
                field("No. Factura"; "No. Factura")
                {
                }
                field("Tipo retención"; "Tipo retencion")
                {
                }
                field("Cod. retencion"; "Cod. retencion")
                {
                }
                field("Tipo fiscal"; "Tipo fiscal")
                {
                }
                field("Cod. sicore"; "Cod. sicore")
                {
                }
                field("Fecha pago"; "Fecha pago")
                {
                }
                field("Base pago retencion"; "Base pago retencion")
                {
                }
                field("No. documento"; "No. documento")
                {
                }
                field("Pagos anteriores"; "Pagos anteriores")
                {
                }
                field("Factura liquidada"; "Factura liquidada")
                {
                }
                field("Importe retenido real"; "Importe retenido real")
                {
                }
                field("Importe retencion"; "Importe retencion")
                {
                    Caption = 'Withholding amount per document.';
                }
                field("Importe retencion total"; "Importe retencion total")
                {
                }
                field("Importe neto factura"; "Importe neto factura")
                {
                }
                field("Importe retenciones anteriores"; "Importe retenciones anteriores")
                {
                }
                field("Importe minimo pago"; "Importe minimo pago")
                {
                }
                field("Importe minimo retención"; "Importe minimo retención")
                {
                }
                field("Importe total comprobante"; "Importe total comprobante")
                {
                }
                field("% retencion"; "% retencion")
                {
                }
                field(Provincia; Provincia)
                {
                }
                field("No. serie ganancias"; "No. serie ganancias")
                {
                    Visible = false;
                }
                field("Serie retención"; "Serie retención")
                {
                }
                field(Retenido; Retenido)
                {
                }
                field("No. serie IVA"; "No. serie IVA")
                {
                    Visible = false;
                }
                field(Excluido; Excluido)
                {
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Certificado Retención SS")
            {

                trigger OnAction()
                var
                    l_rptCR: Report "Certificado Retención SS";
                    l_rstIWB: Record "Invoice Withholding Buffer";
                begin
                    Clear(l_rstIWB);
                    l_rstIWB.SetRange("No. documento", "No. documento");
                    l_rstIWB.SetRange("Tipo retencion", "Tipo retencion"::"Seguridad Social");
                    if l_rstIWB.FindSet then begin
                        Clear(l_rptCR);
                        l_rptCR.SetTableView(l_rstIWB);
                        l_rptCR.Run;
                    end;
                end;
            }
            action("Certificado Retención IVA")
            {

                trigger OnAction()
                var
                    l_rptCR: Report "Certificado Retención IVA";
                    l_rstIWB: Record "Invoice Withholding Buffer";
                begin
                    Clear(l_rstIWB);
                    l_rstIWB.SetRange("No. documento", "No. documento");
                    l_rstIWB.SetRange("Tipo retencion", "Tipo retencion"::IVA);
                    if l_rstIWB.FindSet then begin
                        Clear(l_rptCR);
                        l_rptCR.SetTableView(l_rstIWB);
                        l_rptCR.Run;
                    end;
                end;
            }
            action("Certificado Retención Ganancias")
            {

                trigger OnAction()
                var
                    l_rptCR: Report "Certificado Retención Ganancia";
                    l_rstIWB: Record "Invoice Withholding Buffer";
                begin
                    Clear(l_rstIWB);
                    l_rstIWB.SetRange("No. documento", "No. documento");
                    l_rstIWB.SetRange("Tipo retencion", "Tipo retencion"::Ganancias);
                    if l_rstIWB.FindSet then begin
                        Clear(l_rptCR);
                        l_rptCR.SetTableView(l_rstIWB);
                        l_rptCR.Run;
                    end;
                end;
            }
            action("Certificado Retención IIBB")
            {

                trigger OnAction()
                var
                    l_rptCR: Report "Certificado Retención IIBB";
                    l_rstIWB: Record "Invoice Withholding Buffer";
                begin
                    Clear(l_rstIWB);
                    l_rstIWB.SetRange("No. documento", "No. documento");
                    l_rstIWB.SetRange("Tipo retencion", "Tipo retencion"::"Ingresos Brutos");
                    if l_rstIWB.FindSet then begin
                        Clear(l_rptCR);
                        l_rptCR.SetTableView(l_rstIWB);
                        l_rptCR.Run;
                    end;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Report)
            {
                actionref("Certificado Retención SS_Promoted"; "Certificado Retención SS")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields("Factura Prov");
        case "Tipo registro" of
            "Tipo registro"::Venta:
                begin
                    /*
                     CLEAR(rstCli);
                     rstCli.GET("Cliente/Proveedor");
                     strCUIT := rstCli."VAT Registration No.";
                     strNombre := rstCli.Name;
                     strNroIIBB := rstCli."No. ingresos brutos";

                     IF "No. Factura" <> '' THEN
                     BEGIN

                       CLEAR(rstMens);
                       rstMens.SETRANGE(rstMens."Código vinculante","Cliente/Proveedor");
                       rstMens.SETRANGE(rstMens."No. documento","No. Factura");
                       IF rstMens.FIND('+') THEN
                       BEGIN

                         CASE rstMens."Tipo Documento" OF
                           'Factura (compras)','Fact. pronto venc. (compras)':
                             strTipo := '1';
                           'Nota débito (compras)','Déb. pronto venc. (compras)':
                             strTipo := '4';
                         END;

                       END;

                     END;

                     IF "Tipo factura" = "Tipo factura"::"Nota d/c" THEN
                       strTipo := '3';
                   */
                    Clear(rstCli);
                    if rstCli.Get("Cliente/Proveedor") then;
                    strCUIT := rstCli."VAT Registration No.";
                    strNombre := rstCli.Name;
                    strNroIIBB := rstCli."No. ingresos brutos";

                    if rstCli."Inscripto IIBB" = rstCli."Inscripto IIBB"::"Sí" then begin

                        if rstCli."GI Inscription type" = 'D' then
                            strSituacionIBRetenido := '1';
                        if rstCli."GI Inscription type" = 'C' then
                            strSituacionIBRetenido := '2';
                        if rstCli."Tax Area Code" = 'PRV-MONO' then
                            strSituacionIBRetenido := '5';

                    end
                    else begin

                        strSituacionIBRetenido := '4';

                    end;

                    Clear(rstFV);
                    rstFV.SetRange("Pre-Assigned No.", "No. documento");
                    rstFV.SetRange("Posting Date", "Fecha factura");
                    if rstFV.FindFirst then
                        codDoc := rstFV."No.";
                    Clear(rstNV);
                    rstNV.SetRange("Pre-Assigned No.", "No. documento");
                    rstNV.SetRange("Posting Date", "Fecha factura");
                    if rstNV.FindFirst then
                        codDoc := rstNV."No.";

                    if codDoc <> '' then begin

                        Clear(rstMens);
                        rstMens.SetRange(rstMens."Codigo vinculante", "Cliente/Proveedor");
                        rstMens.SetRange(rstMens."No. documento", codDoc);
                        if rstMens.Find('+') then begin

                            case rstMens."Tipo Documento" of
                                'Factura (ventas)', 'Fact. pronto venc. (compras)':
                                    strTipo := '1';
                                'Nota débito (compras)', 'Déb. pronto venc. (compras)':
                                    strTipo := '4';
                            end;

                        end;

                    end;

                    if "Tipo factura" = "Tipo factura"::"Nota d/c" then
                        strTipo := '3';

                    strLetraComprobante := CopyStr(codDoc, 1, 1);
                    strSucursal := CopyStr(codDoc, 2, 4);
                    strComprobante := CopyStr(codDoc, 7, 10);
                    strBase := "Importe neto factura";

                end;

            "Tipo registro"::Compra:
                begin

                    Clear(rstProv);
                    if rstProv.Get("Cliente/Proveedor") then;
                    strCUIT := rstProv."VAT Registration No.";
                    strNombre := rstProv.Name;
                    strNroIIBB := rstProv."No. ingresos brutos";

                    if rstProv."Inscripto IIBB" = rstProv."Inscripto IIBB"::"Sí" then begin

                        if rstProv."GI Inscription type" = 'D' then
                            strSituacionIBRetenido := '1';
                        if rstProv."GI Inscription type" = 'C' then
                            strSituacionIBRetenido := '2';
                        if rstProv."Tax Area Code" = 'PRV-MONO' then
                            strSituacionIBRetenido := '5';

                    end
                    else begin

                        strSituacionIBRetenido := '4';

                    end;

                    if "No. Factura" <> '' then begin

                        Clear(rstMens);
                        rstMens.SetRange(rstMens."Codigo vinculante", "Cliente/Proveedor");
                        rstMens.SetRange(rstMens."No. documento", "No. Factura");
                        if rstMens.Find('+') then begin

                            case rstMens."Tipo Documento" of
                                'Factura (compras)', 'Fact. pronto venc. (compras)':
                                    strTipo := '1';
                                'Nota débito (compras)', 'Déb. pronto venc. (compras)':
                                    strTipo := '4';
                            end;

                        end;

                    end;

                    if "Tipo factura" = "Tipo factura"::"Nota d/c" then
                        strTipo := '3';

                    strLetraComprobante := CopyStr("Factura Prov", 1, 1);
                    strSucursal := CopyStr("Factura Prov", 2, 4);
                    strComprobante := CopyStr("Factura Prov", 7, 10);
                    strBase := "Importe neto factura";

                end;
        end;

        Clear(rstIVA);
        if "Tipo registro" = "Tipo registro"::Compra then
            rstIVA.SetRange("Document No.", "No. Factura")
        else
            rstIVA.SetRange("Document No.", codDoc);

        //rstIVA.SETRANGE("Document No.","No. Factura");
        rstIVA.CalcSums(Amount, Base);

        decImpComp := rstIVA.Base + rstIVA.Amount;

        decImpoIVA := rstIVA.Amount;

    end;

    var
        strCUIT: Code[13];
        strNombre: Text[50];
        rstProv: Record Vendor;
        rstCli: Record Customer;
        rstIVA: Record "VAT Entry";
        decImpoIVA: Decimal;
        strSituacionIBRetenido: Text;
        strNroIIBB: Text[20];
        rstMens: Record Mensajeria;
        strTipo: Text[1];
        strLetraComprobante: Text[1];
        strSucursal: Text[4];
        strComprobante: Text[10];
        decImpComp: Decimal;
        decOtros: Decimal;
        strBase: Decimal;
        codDoc: Code[20];
        rstFV: Record "Sales Invoice Header";
        rstNV: Record "Sales Cr.Memo Header";
}

