codeunit 50005 Retenciones
{
    trigger OnRun()
    begin
    end;

    var
        decTotalEstePago: Decimal;
        decTCambioPago: Decimal;
        decTotalRetenido: Decimal;
        decPorcentajeIVA: Code[10];
        strFiltro: array[250, 3] of Text[250];
        rstTFiscal: Record "VAT Business Posting Group";
        rstProveedor: Record Vendor;
        blnConfirmar: Boolean;
        // Variables para el manejo de códigos de libro y sección en aplicación de movimientos
        GlobalCodLibro: Code[20];
        GlobalCodSeccion: Code[20];
        GlobalDocumentNo: Code[20];


    [Scope('OnPrem')]
    procedure "**RETENCIONES**"()
    begin
    end;

    [Scope('OnPrem')]
    procedure Retenciones(rstLinDiaGen: Record "Gen. Journal Line"; blnRegistrar: Boolean)
    var
        rstFacturaBufferRT: Record "Invoice Withholding Buffer";
        rstFacturaBufferRT2: Record "Invoice Withholding Buffer";
        rstFacturaBufferRT3: Record "Invoice Withholding Buffer";
        rstCodigosRetencion: Record "Withholding codes";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstProveedor: Record Vendor;
        rstLinDiaGenTemp: Record "Gen. Journal Line";
        rstExencion: Record "Withholding details";
        rstCabFactura: Record "Purch. Inv. Header";
        rstLinFactura: Record "Purch. Inv. Line";
        rstCabNC: Record "Purch. Cr. Memo Hdr.";
        rstLinNC: Record "Purch. Cr. Memo Line";
        rstAccionEstFis: Record "Acción estado sit. fiscal";
        rstLinDiaGen2: Record "Gen. Journal Line";
        rstTipoCambio: Record "Currency Exchange Rate";
        rstHisCFacComp: Record "Purch. Inv. Header";
        rstHisLFacComp: Record "Purch. Inv. Line";
        rstHisCNC: Record "Purch. Cr. Memo Hdr.";
        rstHisLNC: Record "Purch. Cr. Memo Line";
        intMotivoExclusion: Integer;
        decImportePagosAnterioresIVA: Decimal;
        rstMovProveedor: Record "Vendor Ledger Entry";
        rstConfCont: Record "General Ledger Setup";
        rstCompInfo: Record "Company Information";
        rstCliente: Record Customer;
    begin
        //Retenciones

        /*
        IF USERID <> 'ULISES.SASOVSKY' THEN
          ERROR('');
        */
        Clear(rstFacturaBufferRT);
        Clear(rstCodigosRetencion);
        Clear(rstConfiguracionRetencion);
        Clear(rstProveedor);
        Clear(rstLinDiaGenTemp);
        Clear(rstExencion);
        Clear(rstCabFactura);
        Clear(rstLinFactura);

        //Busco las líneas que tienen el código de proveedor

        rstLinDiaGenTemp.SetRange(rstLinDiaGenTemp."Journal Template Name", rstLinDiaGen."Journal Template Name");
        rstLinDiaGenTemp.SetRange(rstLinDiaGenTemp."Journal Batch Name", rstLinDiaGen."Journal Batch Name");
        rstLinDiaGenTemp.SetRange("Document No.", rstLinDiaGen."Document No.");
        rstLinDiaGenTemp.SetRange(rstLinDiaGenTemp."Account Type", rstLinDiaGenTemp."Account Type"::Vendor);
        if rstLinDiaGenTemp.FindFirst then
            rstProveedor.Get(rstLinDiaGenTemp."Account No.")
        else
            //ERROR('No se encuentra el documento');
            exit;

        rstLinDiaGen.SetRange(rstLinDiaGen."Journal Template Name", rstLinDiaGenTemp."Journal Template Name");
        rstLinDiaGen.SetRange(rstLinDiaGen."Journal Batch Name", rstLinDiaGenTemp."Journal Batch Name");
        rstLinDiaGen.SetRange("Document No.", rstLinDiaGenTemp."Document No.");
        rstLinDiaGen.SetRange(rstLinDiaGen."Account Type", rstLinDiaGenTemp."Account Type"::Vendor);
        if rstLinDiaGen.FindFirst then
            rstProveedor.Get(rstLinDiaGenTemp."Account No.")
        else
            Error('No se encuentra el documento');

        Clear(rstLinDiaGenTemp);

        //Elimino las líneas que hubiesen en el buffer de retenciones para este pago

        rstFacturaBufferRT.SetCurrentKey(rstFacturaBufferRT."No. documento");
        rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstLinDiaGen."Document No.");
        rstFacturaBufferRT.DeleteAll;

        //Elimino los cálculos de retenciones anteriores presentes en el diario

        Clear(rstConfCont);
        rstConfCont.Get();

        Clear(rstLinDiaGen2);
        rstLinDiaGen2.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
        rstLinDiaGen2.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
        rstLinDiaGen2.SetRange("Document No.", rstLinDiaGen."Document No.");
        rstLinDiaGen2.SetFilter("Account No.", '%1|%2|%3|%4', rstConfCont."VAT withholding account", rstConfCont."Winnings withholding account", rstConfCont."SS withholding account", rstConfCont."GI withholding account");
        rstLinDiaGen2.DeleteAll;

        Clear(rstLinDiaGenTemp);
        rstLinDiaGenTemp.Reset;

        //Antes de verificar exenciones, se chequea que no se encuentre comprendido por la RG3594

        Clear(rstCompInfo);
        rstCompInfo.Get();
        /*
        Arbu 2019 - Voy a chequear si es agente desde el código de retención
        
        IF rstCompInfo."Ag. Retencion IVA" THEN
        BEGIN
        
        
        */
        //if (rstProveedor."VAT Bus. Posting Group" = 'PRV-RI')
        /*AND
          ((rstProveedor."Registrado RG3594" <> rstProveedor."Registrado RG3594"::" " ) AND
          (ActividadRG3594(rstLinDiaGen)))
          */
        //then begin
        IF (not rstProveedor."Exento retención IVA") then
            CalcularRetencionIVA(rstLinDiaGen, rstProveedor);
        /*
      END
      ELSE
      BEGIN

        //Si el proveedor no es exento de retención de IVA, sigo con el cálculo general de la retención
        {
        IF NOT rstProveedor."Exento retención IVA" THEN
        BEGIN
        }
            CalcularRetencionIVA(rstLinDiaGen,rstProveedor);

        END;
        */
        //end;
        //Si el proveedor no está excluído de Seguridad Social, le calculamos la retención

        if (rstCompInfo."Ag. Retencion Ganancias") and (not rstProveedor."Exento ganancias") then
            CalcularRetencionGanancias(rstLinDiaGen, rstProveedor);

        if (not rstProveedor."Exento retención SS") and rstProveedor.Empleador and rstCompInfo."Ag. Retencion IVA" then
            CalcularRetencionSS(rstLinDiaGen, rstProveedor);

        //Si el proveedor no está excluído de Ingresos Brutos, le calculamos la retención

        //Si envió la documentación y está verificada, me fijo si es necesario retener
        Clear(rstCompInfo);
        rstCompInfo.Get();
        if rstCompInfo."Ag. Retencion Ingreso Brutos" then begin

            if rstLinDiaGen."Account Type" = rstLinDiaGen."Account Type"::Vendor then begin

                if rstProveedor."Documentacion IIBB verificada" then begin

                    if rstProveedor."Inscripto IIBB" = rstProveedor."Inscripto IIBB"::"Sí" then
                        CalcularRetencionIIBB(rstLinDiaGen, rstProveedor)
                    else begin

                        if rstProveedor."Inscripto IIBB" = rstProveedor."Inscripto IIBB"::" " then
                            Error('Debe seleccionar una opción de Inscripción en IIBB.');

                    end;

                end
                else begin

                    if rstProveedor."Fecha digitalizacion IIBB" <> 0D then
                        Error('Debe verificar la documentación de IIBB.')
                    else
                        Error('Debe digitalizar la documentación de respaldo a la situación del sujeto frente a IIBB.')
                    //CalcularRetencionIIBB(rstLinDiaGen,rstProveedor);

                end;

            end;

        end;

    end;

    [Scope('OnPrem')]
    procedure CalcularRetencionIVA(var rstLinDiaGen: Record "Gen. Journal Line"; rstProveedor: Record Vendor)
    var
        rstLinDiaGenTemp: Record "Gen. Journal Line";
        rstCabFactura: Record "Purch. Inv. Header";
        rstLinFactura: Record "Purch. Inv. Line";
        rstFacturaBufferRT: Record "Invoice Withholding Buffer";
        decImportePagosAnterioresIVA: Decimal;
        rstCabNC: Record "Purch. Cr. Memo Hdr.";
        rstLinNC: Record "Purch. Cr. Memo Line";
        rstExencion: Record "Withholding details";
        rstWithholdingCodes: Record "Withholding codes";
        rstIC: Record "Company Information";
    begin
        //Me fijo qué facturas ha seleccionado el usuario para liquidar en este pago

        rstLinDiaGenTemp.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
        rstLinDiaGenTemp.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
        rstLinDiaGenTemp.SetRange("Document No.", rstLinDiaGen."Document No.");
        rstLinDiaGenTemp.SetFilter("Applies-to Doc. No.", '<>%1', '');

        //Me posiciono en la primera factura a pagar

        if rstLinDiaGenTemp.FindFirst then
            repeat

                //Si el documento es una factura, voy a la línea de la factura, y comienzo a rellenar el buffer de retenciones

                if rstLinDiaGenTemp."Applies-to Doc. Type" = rstLinDiaGenTemp."Applies-to Doc. Type"::Invoice then begin

                    Clear(rstLinFactura);
                    rstLinFactura.SetRange("Document No.", rstLinDiaGenTemp."Applies-to Doc. No.");

                    if (rstProveedor."VAT Bus. Posting Group" = 'PRV-RI') then
                        rstLinFactura.SetFilter("VAT %", '<>0');

                    rstLinFactura.SetFilter("No.", '<>%1', '');
                    if rstLinFactura.FindFirst then
                        repeat

                            Clear(rstWithholdingCodes);
                            if rstWithholdingCodes.Get(rstWithholdingCodes."Tipo impuesto retencion"::IVA, rstLinFactura."Cód. retención IVA") then;

                            Clear(rstIC);
                            rstIC.Get();

                            if rstWithholdingCodes."Act as withholding agent" or rstIC."Ag. Retencion IVA" then begin

                                Clear(rstCabFactura);
                                rstCabFactura.Get(rstLinFactura."Document No.");

                                if (rstProveedor."VAT Bus. Posting Group" = 'PRV-RI') then
                                    rstLinFactura.TestField("Actividad AFIP");

                                Clear(rstFacturaBufferRT);
                                rstFacturaBufferRT.SetRange("Tipo registro", rstFacturaBufferRT."Tipo registro"::Compra);
                                rstFacturaBufferRT.SetRange("Cliente/Proveedor", rstProveedor."No.");
                                rstFacturaBufferRT.SetRange("No. Factura", rstLinFactura."Document No.");
                                rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::IVA);
                                rstFacturaBufferRT.SetRange("Cod. retencion", rstLinFactura."Cód. retención IVA");
                                rstFacturaBufferRT.SetRange("No. documento", rstLinDiaGen."Document No.");
                                rstFacturaBufferRT.SetRange("Tipo fiscal", rstCabFactura."VAT Bus. Posting Group");

                                //Si esta es la primera vez que se inserta la factura en la tabla, entonces limpio el resto de los campos

                                if not rstFacturaBufferRT.FindFirst then begin

                                    rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Compra;
                                    rstFacturaBufferRT."Cliente/Proveedor" := rstProveedor."No.";
                                    rstFacturaBufferRT."Estado de situación fiscal" := rstProveedor."Estado de situación fiscal";
                                    rstFacturaBufferRT."No. Factura" := rstLinFactura."Document No.";
                                    rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::IVA;
                                    rstFacturaBufferRT."Cod. retencion" := rstLinFactura."Cód. retención IVA";
                                    rstFacturaBufferRT."No. documento" := rstLinDiaGen."Document No.";
                                    rstFacturaBufferRT."Tipo fiscal" := rstCabFactura."VAT Bus. Posting Group";
                                    rstFacturaBufferRT."Fecha pago" := 0D;
                                    rstFacturaBufferRT."Base pago retencion" := 0;
                                    rstFacturaBufferRT."Pagos anteriores" := 0;
                                    rstFacturaBufferRT."Importe retencion" := 0;
                                    rstFacturaBufferRT."Importe total comprobante" := 0;
                                    rstFacturaBufferRT."% retencion" := 0;
                                    rstFacturaBufferRT.Provincia := '';
                                    rstFacturaBufferRT."No. serie ganancias" := '';
                                    rstFacturaBufferRT."No. serie IVA" := '';
                                    rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                                    rstFacturaBufferRT."Fecha factura" := 0D;
                                    rstFacturaBufferRT.Nombre := '';
                                    rstFacturaBufferRT."Importe neto factura" := 0;
                                    rstFacturaBufferRT."Tipo factura" := rstFacturaBufferRT."Tipo factura"::Factura;
                                    rstFacturaBufferRT.Insert;

                                end;

                                rstFacturaBufferRT."Fecha pago" := rstLinDiaGen."Posting Date";

                                //Si la divisa de la factura es diferente a la divisa local, calculo el importe base a retener utilizando el factor
                                //de divisa de la cabecera de compra.
                                //Cambio de lógica. Siempre se paga la factura en pesos, así que utilizo el tipo de cambio por el que se cargó la
                                //factura para el cálculo de las retenciones.
                                //++Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                decTCambioPago := fntTipoCambioPago(rstLinDiaGenTemp, rstFacturaBufferRT."No. Factura");
                                //--Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                /*
                                IF rstCabFactura."Currency Code" <> '' THEN
                                BEGIN
                                */
                                //decTCambioPago := 0;
                                //decTCambioPago := 1/rstCabFactura."Currency Factor";
                                //decTCambioPago := 1/rstLinDiaGenTemp."Currency Factor";
                                /*
                                IF rstCabFactura."Currency Factor" <> 0 THEN
                                  rstFacturaBufferRT."Importe neto factura"  += (rstLinFactura.Amount)/rstCabFactura."Currency Factor"
                                ELSE
                                  rstFacturaBufferRT."Importe neto factura"  += (rstLinFactura.Amount);
                                  */
                                //CalcularTotalComprobante
                                //rstFacturaBufferRT."Importe total comprobante" += (rstLinFactura."Amount Including VAT")*decTCambioPago;
                                rstFacturaBufferRT."Importe neto factura" += (rstLinFactura.Amount) * decTCambioPago;
                                rstFacturaBufferRT."Importe total comprobante" := CalcularTotalComprobante(rstLinDiaGen."Document No.", rstFacturaBufferRT."No. Factura", decTCambioPago);
                                rstFacturaBufferRT."Base pago retencion" += (rstLinFactura."Amount Including VAT" - rstLinFactura."VAT Base Amount")
                                  * decTCambioPago;
                                /*
                            END
                            ELSE
                            BEGIN

                              rstFacturaBufferRT."Importe neto factura"  += (rstLinFactura.Amount);
                              rstFacturaBufferRT."Importe total comprobante" := CalcularTotalComprobante(rstLinDiaGen."Document No.",rstFacturaBufferRT."No. Factura",decTCambioPago);
                              rstFacturaBufferRT."Base pago retencion" += (rstLinFactura."Amount Including VAT"-rstLinFactura."VAT Base Amount");

                            END;
                              */
                                //Calculo los pagos realizados anteriormente sobre ésta factura
                                decImportePagosAnterioresIVA := 0;
                                decImportePagosAnterioresIVA := CalcularPagosAnterioresIVA(rstFacturaBufferRT);

                                //Calculo el importe a retener. Para eso, busco la configuración de retenciones correcta
                                CalcularImporteARetener(rstLinFactura, rstLinDiaGen, decImportePagosAnterioresIVA, rstFacturaBufferRT, rstCabFactura);

                            end;

                        until rstLinFactura.Next = 0;

                end;

                //Si el documento es una Nota de Crédito

                if rstLinDiaGenTemp."Applies-to Doc. Type" = rstLinDiaGenTemp."Applies-to Doc. Type"::"Credit Memo" then begin

                    Clear(rstLinNC);
                    rstLinNC.SetRange("Document No.", rstLinDiaGenTemp."Applies-to Doc. No.");
                    rstLinNC.SetFilter("VAT %", '<>0');
                    rstLinNC.SetFilter("No.", '<>%1', '');
                    if rstLinNC.FindFirst then
                        repeat

                            Clear(rstCabNC);
                            rstCabNC.Get(rstLinNC."Document No.");

                            Clear(rstWithholdingCodes);
                            if rstWithholdingCodes.Get(rstWithholdingCodes."Tipo impuesto retencion"::IVA, rstLinNC."Cód. retención IVA") then;

                            Clear(rstIC);
                            rstIC.Get();

                            if rstWithholdingCodes."Act as withholding agent" or rstIC."Ag. Retencion IVA" then begin

                                Clear(rstFacturaBufferRT);
                                rstFacturaBufferRT.SetRange("Tipo registro", rstFacturaBufferRT."Tipo registro"::Compra);
                                rstFacturaBufferRT.SetRange("Cliente/Proveedor", rstProveedor."No.");
                                rstFacturaBufferRT.SetRange("No. Factura", rstLinNC."Document No.");
                                rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::IVA);
                                rstFacturaBufferRT.SetRange("Cod. retencion", rstLinNC."Cód. retención IVA");
                                rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstLinDiaGen."Document No.");
                                rstFacturaBufferRT.SetRange("Tipo fiscal", rstCabNC."VAT Bus. Posting Group");
                                //Si esta es la primera vez que se inserta la factura en la tabla, entonces limpio el resto de los campos

                                if not rstFacturaBufferRT.FindFirst then begin

                                    rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Compra;
                                    rstFacturaBufferRT."Cliente/Proveedor" := rstProveedor."No.";
                                    rstFacturaBufferRT."Estado de situación fiscal" := rstProveedor."Estado de situación fiscal";
                                    rstFacturaBufferRT."No. Factura" := rstLinNC."Document No.";
                                    rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::IVA;
                                    rstFacturaBufferRT."Cod. retencion" := rstLinNC."Cód. retención IVA";
                                    rstFacturaBufferRT."No. documento" := rstLinDiaGen."Document No.";
                                    rstFacturaBufferRT."Tipo fiscal" := rstCabNC."VAT Bus. Posting Group";
                                    rstFacturaBufferRT."Fecha pago" := 0D;
                                    rstFacturaBufferRT."Base pago retencion" := 0;
                                    rstFacturaBufferRT."Pagos anteriores" := 0;
                                    rstFacturaBufferRT."Importe retencion" := 0;
                                    rstFacturaBufferRT."Importe total comprobante" := 0;
                                    rstFacturaBufferRT."% retencion" := 0;
                                    rstFacturaBufferRT.Provincia := '';
                                    rstFacturaBufferRT."No. serie ganancias" := '';
                                    rstFacturaBufferRT."No. serie IVA" := '';
                                    rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                                    rstFacturaBufferRT."Fecha factura" := 0D;
                                    rstFacturaBufferRT.Nombre := '';
                                    rstFacturaBufferRT."Importe neto factura" := 0;
                                    rstFacturaBufferRT."Tipo factura" := rstFacturaBufferRT."Tipo factura"::"Nota d/c";
                                    rstFacturaBufferRT.Insert;

                                end;

                                rstFacturaBufferRT."Fecha pago" := rstLinDiaGen."Posting Date";

                                //Si la divisa de la factura es diferente a la divisa local, calculo el importe base a retener utilizando el factor
                                //de divisa de la cabecera de compra.
                                //Cambio de lógica. Siempre se paga la factura en pesos, así que utilizo el tipo de cambio por el que se cargó la
                                //factura para el cálculo de las retenciones.

                                //++Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                decTCambioPago := fntTipoCambioPago(rstLinDiaGenTemp, rstFacturaBufferRT."No. Factura");
                                //--Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                /*
                                IF rstCabNC."Currency Code" <> '' THEN
                                {BEGIN

                                  decTCambioPago := 0;
                                  //decTCambioPago := 1/rstLinDiaGenTemp."Currency Factor";
                                  decTCambioPago := 1/rstCabNC."Currency Factor";
                                  }
                                  //rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)*decTCambioPago;
                                  rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)/rstCabNC."Currency Factor"
                                ELSE
                                */
                                rstFacturaBufferRT."Importe neto factura" -= (rstLinNC.Amount) * decTCambioPago;
                                rstFacturaBufferRT."Importe total comprobante" -= (rstLinNC."Amount Including VAT")
                                    * decTCambioPago;

                                rstFacturaBufferRT."Base pago retencion" -= (rstLinNC."Amount Including VAT" - rstLinNC."VAT Base Amount")
                                    * decTCambioPago;

                                /*
                                END
                                ELSE
                                BEGIN

                                  rstFacturaBufferRT."Importe nteo factura"  -= (rstLinNC.Amount);

                                  rstFacturaBufferRT."Importe total comprobante"  -= (rstLinNC."Amount Including VAT");

                                  rstFacturaBufferRT."Base pago retencion" -= (rstLinNC."Amount Including VAT"-rstLinNC."VAT Base Amount");

                                END;
                                */
                                //Calculo los pagos realizados anteriormente sobre ésta factura
                                decImportePagosAnterioresIVA := 0;
                                decImportePagosAnterioresIVA := CalcularPagosAnterioresIVANC(rstFacturaBufferRT);

                                //Calculo el importe a retener. Para eso, busco la configuración de retenciones correcta
                                CalcularImporteARetenerNC(rstLinNC, rstLinDiaGen, decImportePagosAnterioresIVA, rstFacturaBufferRT, rstCabNC);

                            end;

                        until rstLinNC.Next = 0;

                end;

            until rstLinDiaGenTemp.Next = 0;


        //Insertamos el cálculo en el diario de pagos
        CrearDiarioPagosIVA(rstLinDiaGen);

    end;

    [Scope('OnPrem')]
    procedure CalcularPagosAnterioresIVA(rstFacturaBuffer: Record "Invoice Withholding Buffer"): Decimal
    var
        rstConfiguracionRetenciones: Record "Withholding setup";
        rstTotalPagos: Record "Invoice Withholding Buffer";
        datInicioMes: Date;
        datFinMes: Date;
        rstFactura: Record "Purch. Inv. Line";
        rstNCredito: Record "Purch. Cr. Memo Line";
        rstPagosBuffer: Record "Invoice Withholding Buffer";
        rstAcumuladoBuffer: Record "Invoice Withholding Buffer";
        decImporte: Decimal;
    begin
        //CalcularPagosAnterioresIVA

        Clear(rstPagosBuffer);
        decImporte := 0;
        rstPagosBuffer.SetCurrentKey(rstPagosBuffer."Cliente/Proveedor", rstPagosBuffer."No. Factura", rstPagosBuffer."Tipo retencion",
                                     rstPagosBuffer."Cod. retencion", rstPagosBuffer."Tipo fiscal");
        rstPagosBuffer.SetRange("Cliente/Proveedor", rstFacturaBuffer."Cliente/Proveedor");
        rstPagosBuffer.SetRange("No. Factura", rstFacturaBuffer."No. Factura");
        rstPagosBuffer.SetRange("Tipo retencion", rstFacturaBuffer."Tipo retencion");
        rstPagosBuffer.SetRange("Cod. retencion", rstFacturaBuffer."Cod. retencion");
        rstPagosBuffer.SetRange("Tipo fiscal", rstFacturaBuffer."Tipo fiscal");
        rstPagosBuffer.SetFilter(rstPagosBuffer."No. documento", '<>%1', rstFacturaBuffer."No. documento");
        if rstPagosBuffer.FindFirst then
            repeat

                decImporte += rstPagosBuffer."Importe retencion";

            until rstPagosBuffer.Next = 0;

        exit(decImporte);
    end;

    [Scope('OnPrem')]
    procedure CalcularImporteARetener(rstLinFacturaL: Record "Purch. Inv. Line"; rstLinDiaGenL: Record "Gen. Journal Line"; decImportePagosAnterioresIVAL: Decimal; var rstFacturaBufferRTL: Record "Invoice Withholding Buffer"; rstCabFacturaL: Record "Purch. Inv. Header"): Decimal
    var
        rstCodigosRetencion: Record "Withholding codes";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstExencion: Record "Withholding details";
        rstProveedor: Record Vendor;
        rstAccionEstFis: Record "Acción estado sit. fiscal";
        int80or100: Integer;
        rstTFiscal: Record "VAT Business Posting Group";
        rst13810: RecordRef;
        cduValidaciones: Codeunit Validaciones;
        rstConfCont: Record "General Ledger Setup";
        rstActiv: Record "Actividad AFIP";
    //rstLAI: Record "Tax Area Line";
    //rstJD: Record "Tax Detail";
    begin
        /*
        CÓDIGO  Descripción
        2       Sujeto con certificado de Exclusión
        3       Monto mínimo no sujeto a retención
        4       Comprobante no retenido por agente de retención reciente
        5       Operación de canje o permuta
        6       Sujeto excluido RG 18 Art 2 Inc. b y c
        7       Objeto excluido por actividad
        8       RG 3873. IVA depositado en CBU proveedor
        */

        rstFacturaBufferRTL."Facturacion anterior 12M" := CalcularFacturaciónAnterior(rstLinDiaGenL);
        rstFacturaBufferRTL."Precio unitario maximo fac." := CalcularPrecioUnitarioFac(rstLinDiaGenL);
        rstProveedor.Get(rstLinFacturaL."Buy-from Vendor No.");

        Clear(rstConfCont);
        rstConfCont.Get();

        Clear(rstTFiscal);
        rstTFiscal.Get(rstFacturaBufferRTL."Tipo fiscal");

        Clear(rstCodigosRetencion);
        rstCodigosRetencion.SetRange("Tipo impuesto retencion", rstCodigosRetencion."Tipo impuesto retencion"::IVA);
        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstLinDiaGenL."Posting Date", 0D);
        rstCodigosRetencion.SetRange("Cod. retencion", rstLinFacturaL."Cód. retención IVA");
        //IF rstCodigosRetencion.GET(rstCodigosRetencion."Tipo impuesto retencion"::IVA,rstLinFacturaL."Cód. retención IVA") THEN
        if rstCodigosRetencion.FindFirst then begin

            if rstCodigosRetencion."Stepwise calculation" then begin

                if ((rstCodigosRetencion."Valid to" <> 0D) and
                   (rstLinDiaGenL."Posting Date" <= rstCodigosRetencion."Valid to")) or
                   (rstCodigosRetencion."Valid to" = 0D)
                   then begin

                    if decPorcentajeIVA = '' then begin

                        Clear(rstActiv);
                        rstActiv.SetRange("No. actividad", rstLinFacturaL."Actividad AFIP");
                        if rstActiv.FindFirst then;

                        //Si la actividad no se encuentra entre las comprendidas por la RG3594
                        if (not rstActiv."Actividad registrada en RG3594") /*AND (rstProveedor."Registrado RG3594"=
                                                                        rstProveedor."Registrado RG3594"::" ")*/ then begin

                            Clear(rstAccionEstFis);
                            rstAccionEstFis.Get(rstProveedor."Estado de situación fiscal");
                            case rstAccionEstFis."Acción retención" of

                                rstAccionEstFis."Acción retención"::" ":
                                    begin

                                        decPorcentajeIVA := '';

                                    end;

                                rstAccionEstFis."Acción retención"::"Aplicar 100%":
                                    begin

                                        decPorcentajeIVA := '100';

                                    end;

                                rstAccionEstFis."Acción retención"::"Aplicar 80%ó50%":
                                    begin

                                        decPorcentajeIVA := '80|50';

                                    end;

                                rstAccionEstFis."Acción retención"::"Consultar al usuario":
                                    begin
                                        /*
                                          IF blnConfirmar THEN
                                          BEGIN
                                          */
                                        if not Confirm('El proveedor seleccionado está clasificado por la AFIP en "Estado de situación fiscal" n° %1.' +
                                                   'Se recomienda que\' +
                                                 'antes de proseguir con el pago, consulte al responsable el procedimiento a seguir. ¿Desea cancelar el pago?',
                                                  true, rstAccionEstFis."Estado de Situación fiscal") then begin

                                            int80or100 := StrMenu('Aplicar 100%,Aplicar 80%ó50%', 1);
                                            if int80or100 = 1 then
                                                decPorcentajeIVA := '100';
                                            if int80or100 = 2 then
                                                decPorcentajeIVA := '80|50';

                                        end
                                        else
                                            Error('Pago cancelado');
                                        /*
                                    END
                                    ELSE
                                    BEGIN

                                      int80or100 := STRMENU('Aplicar 100%,Aplicar 80%ó50%',1);
                                      IF int80or100 = 1 THEN
                                        decPorcentajeIVA := '100';
                                      IF int80or100 = 2 THEN
                                        decPorcentajeIVA := '80|50';

                                    END;
                                    */
                                    end;

                                rstAccionEstFis."Acción retención"::"Consultar al usuario y aplicar el 100%":
                                    begin
                                        /*
                                          IF blnConfirmar THEN
                                          BEGIN
                                          */
                                        if not Confirm('El proveedor seleccionado está clasificado por la AFIP en "Estado de situación fiscal" n° %1.' +
                                                   'Se recomienda que\' +
                                                 'antes de proseguir con el pago, consulte al responsable el procedimiento a seguir. ¿Desea cancelar el pago?',
                                                 true, rstAccionEstFis."Estado de Situación fiscal") then begin

                                            decPorcentajeIVA := '100';

                                        end
                                        else
                                            Error('Pago cancelado');
                                        /*
                                    END
                                    ELSE
                                      decPorcentajeIVA := '100';
                                      */
                                    end;

                                rstAccionEstFis."Acción retención"::"Consultar al usuario y aplicar el 80%ó50%":
                                    begin

                                        if not Confirm('El proveedor seleccionado está clasificado por la AFIP en "Estado de situación fiscal" n° %1.' +
                                                   'Se recomienda que\' +
                                                 'antes de proseguir con el pago, consulte al responsable el procedimiento a seguir. ¿Desea cancelar el pago?',
                                                 true, rstAccionEstFis."Estado de Situación fiscal") then begin

                                            decPorcentajeIVA := '80|50';

                                        end
                                        else
                                            Error('Pago cancelado');

                                    end;

                            end;

                        end
                        else begin

                            if rstProveedor."Registrado RG3594" = rstProveedor."Registrado RG3594"::Activo then
                                decPorcentajeIVA := '50';
                            if rstProveedor."Registrado RG3594" = rstProveedor."Registrado RG3594"::" " then
                                decPorcentajeIVA := '100';
                            if rstProveedor."Registrado RG3594" in [rstProveedor."Registrado RG3594"::Suspendido,
                                                                   rstProveedor."Registrado RG3594"::Excluido,
                                                                   rstProveedor."Registrado RG3594"::"Inscripción cancelada"] then begin

                                decPorcentajeIVA := '100';

                            end;

                        end;

                    end
                    else
                        Error('El código de retención ' + rstCodigosRetencion."Cod. retencion" + ', tipo de impuesto ' + Format(rstCodigosRetencion."Tipo impuesto retencion") + ', del documento ' + rstLinDiaGenL."Applies-to Doc. No." + ', no está activo a esta fecha.')

                end;

                Clear(rstConfiguracionRetencion);
                rstConfiguracionRetencion.SetRange(rstConfiguracionRetencion."Tipo retenciones",
                rstConfiguracionRetencion."Tipo retenciones"::IVA);
                rstConfiguracionRetencion.SetRange(rstConfiguracionRetencion."Cod. retencion", rstLinFacturaL."Cód. retención IVA");
                rstConfiguracionRetencion.SetRange("Tipo fiscal", rstFacturaBufferRTL."Tipo fiscal");

                case rstTFiscal."Tipo cálculo acumulado" of

                    rstTFiscal."Tipo cálculo acumulado"::" ",
                    rstTFiscal."Tipo cálculo acumulado"::Mensual:
                        begin

                            case rstCodigosRetencion."Base cálculo stepwise" of
                                rstCodigosRetencion."Base cálculo stepwise"::"Neto factura":
                                    rstConfiguracionRetencion.SetRange("Importe minimo Stepwise", 0, rstFacturaBufferRTL."Importe neto factura");
                                rstCodigosRetencion."Base cálculo stepwise"::"Total factura":
                                    rstConfiguracionRetencion.SetRange("Importe minimo Stepwise", 0, rstFacturaBufferRTL."Importe total comprobante");
                            end;

                            /*Parece ser innecesario!
                            
                            Clear(rstLAI);
                            rstLAI.SetRange(rstLAI."Tax Area", rstLinFacturaL."VAT Bus. Posting Group");
                            if rstLAI.FindLast then begin

                                Clear(rstJD);
                                rstJD.Get(rstLAI."Tax Jurisdiction Code", rstLinFacturaL."Tax Group Code");

                            end;

                            rstConfiguracionRetencion.SetRange("% retencion", rstJD."Tax Below Maximum");
                            */
                            if decPorcentajeIVA <> '' then
                                rstConfiguracionRetencion.SetFilter("Porcentaje de IVA", decPorcentajeIVA);
                            if rstConfiguracionRetencion.FindLast then begin
                                //Si el proveedor tiene algún certificado de exclusión vigente

                                Clear(rstExencion);
                                rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                                rstExencion.SetFilter("Tipo retención", '%1', rstExencion."Tipo retención"::IVA);
                                rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                                rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                                //Si la configuración de exclusiones obliga a retener más allá del certificado de exclusión
                                if rstExencion.FindLast and (not rstConfiguracionRetencion."Skip exclusions") then
                                /*
                                Este código no funciona cuando tenemos dos exclusiones activas, una en el mes actual y otra en el próximo mes,
                                porque la fecha del documento de exención es superior a la fecha del documento que estoy registrando (encuentra siempre el último!)

                                IF rstExencion.FINDLAST AND (rstExencion."Fecha documento" <= rstLinDiaGenL."Posting Date") AND
                                (rstExencion."Fecha efectividad retencion" >= rstLinDiaGenL."Posting Date") AND
                                //Se agrega la excepción en caso de actividades de la RG3594
                                (NOT rstCodigosRetencion."Verificar registro RG3594") THEN
                                */
                                begin
                                    //Si el proveedor tiene un certificado de exclusión vigente, evalúo el Estado de Situación fiscal del proveedor
                                    //antes de aplicar el porcentaje de exclusión

                                    Clear(rstAccionEstFis);
                                    rstAccionEstFis.Get(rstProveedor."Estado de situación fiscal");
                                    case rstAccionEstFis."Acción exclusión" of

                                        rstAccionEstFis."Acción exclusión"::"Aplicar exención":
                                            begin

                                                rstFacturaBufferRTL."Importe retencion" := (((rstFacturaBufferRTL."Importe neto factura" *
                                                //rstConfiguracionRetencion."% retención")/100)*((-rstExencion."% exención"+100)/100))-
                                                fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                ) / 100) * ((-rstExencion."% exención" + 100) / 100)) -
                                                decImportePagosAnterioresIVAL;
                                                rstFacturaBufferRTL.Excluido := 2;
                                                rstFacturaBufferRTL."% Exclusion" := rstExencion."% exención";
                                                rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";
                                                rstFacturaBufferRTL."Numero de Certificado" := rstExencion."No. documento";

                                            end;

                                        rstAccionEstFis."Acción exclusión"::"No aplicar exención":
                                            begin

                                                rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                                //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;

                                                fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                ) / 100) - decImportePagosAnterioresIVAL;
                                                rstFacturaBufferRTL.Excluido := 0;
                                                rstFacturaBufferRTL."% Exclusion" := 0;
                                                rstFacturaBufferRTL."Fecha documento exclusion" := 0D;
                                                rstFacturaBufferRTL."Numero de Certificado" := rstExencion."No. documento";

                                            end;

                                        rstAccionEstFis."Acción exclusión"::"Consultar al usuario":
                                            begin

                                                if Confirm('El proveedor %1 posee un Certificado de Exclusión de situación %2 por un %3 por ciento.\' +
                                                '¿Desea aplicarlo en este pago?', false, rstProveedor.Name,
                                                rstProveedor."Estado de situación fiscal", rstExencion."% exención") then begin

                                                    rstFacturaBufferRTL."Importe retencion" := (((rstFacturaBufferRTL."Importe neto factura" *
                                                    //rstConfiguracionRetencion."% retención")/100)*((-rstExencion."% exención"+100)/100))-
                                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                    ) / 100) * ((-rstExencion."% exención" + 100) / 100)) -
                                                    decImportePagosAnterioresIVAL;
                                                    rstFacturaBufferRTL.Excluido := 2;
                                                    rstFacturaBufferRTL."% Exclusion" := rstExencion."% exención";
                                                    rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";
                                                    rstFacturaBufferRTL."Numero de Certificado" := rstExencion."No. documento";

                                                end
                                                else begin

                                                    rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                                    //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                    ) / 100) - decImportePagosAnterioresIVAL;
                                                    rstFacturaBufferRTL.Excluido := 0;
                                                    rstFacturaBufferRTL."% Exclusion" := 0;
                                                    rstFacturaBufferRTL."Fecha documento exclusion" := 0D;
                                                    rstFacturaBufferRTL."Numero de Certificado" := rstExencion."No. documento";

                                                end;

                                            end;

                                    end;
                                end
                                else begin
                                    //Si la fecha del certificado de exclusión es anterior a la fecha del pago
                                    Clear(rstExencion);
                                    rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                                    rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::IVA);
                                    //rstExencion.SETFILTER("Fecha efectividad retencion",'<%1|%2',rstLinDiaGenL."Posting Date",0D);
                                    rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                                    rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                                    if (rstExencion.FindLast) and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                                    //Se agrega la excepción en caso de actividades de la RG3594
                                    /*(NOT rstCodigosRetencion."Verificar registro RG3594") THEN*/
                                    begin
                                        fntConfirmaExencionAntigua(rstExencion, rstProveedor);
                                        rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                        ) / 100) - decImportePagosAnterioresIVAL;

                                        if rstCodigosRetencion."Verificar registro RG3594" then begin
                                            case rstConfiguracionRetencion."Porcentaje de IVA" of
                                                50:
                                                    rstFacturaBufferRTL."Cod. sicore" := 826;
                                                100:
                                                    rstFacturaBufferRTL."Cod. sicore" := 827;
                                            end;
                                        end
                                        else
                                            Evaluate(rstFacturaBufferRTL."Cod. sicore", rstCodigosRetencion."Codigo SICORE");

                                        rstFacturaBufferRTL.Excluido := 0;
                                        rstFacturaBufferRTL."% Exclusion" := 0;
                                        rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                    end
                                    else begin

                                        rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                        //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                        ) / 100) - decImportePagosAnterioresIVAL;

                                        if rstCodigosRetencion."Verificar registro RG3594" then begin
                                            case rstConfiguracionRetencion."Porcentaje de IVA" of
                                                50:
                                                    rstFacturaBufferRTL."Cod. sicore" := 826;
                                                100:
                                                    rstFacturaBufferRTL."Cod. sicore" := 827;
                                            end;
                                        end
                                        else
                                            Evaluate(rstFacturaBufferRTL."Cod. sicore", rstCodigosRetencion."Codigo SICORE");

                                        rstFacturaBufferRTL.Excluido := 0;
                                        rstFacturaBufferRTL."% Exclusion" := 0;
                                        rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                    end;
                                    Clear(rstExencion);
                                    rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                                    rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::"Agente de retención IVA");
                                    //rstExencion.SETFILTER("Fecha efectividad retencion",'<%1|%2',rstLinDiaGenL."Posting Date",0D);
                                    rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                                    rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                                    if (not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent") then begin
                                        rstFacturaBufferRTL."Importe retencion" := 0;
                                        rstFacturaBufferRTL.Excluido := 6;
                                        rstFacturaBufferRTL."% Exclusion" := 100;
                                        rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";
                                    end;

                                end;

                                if rstFacturaBufferRTL.Excluido = 0 then
                                    fntTestExentoRetencionIVA(rstFacturaBufferRTL."Cliente/Proveedor", rstFacturaBufferRTL."Importe retencion", rstFacturaBufferRTL.Excluido);

                            end
                            else begin

                                //Almaceno en el buffer de retenciones el motivo de la exclusión para esta factura

                                rstFacturaBufferRTL.Excluido := 3;
                                rstFacturaBufferRTL.Modify;

                            end;

                        end;

                    rstTFiscal."Tipo cálculo acumulado"::"11 meses":
                        begin

                            rstConfiguracionRetencion.SetRange("Importe minimo Stepwise", 0, rstFacturaBufferRTL."Facturacion anterior 12M");
                            if decPorcentajeIVA <> '' then
                                rstConfiguracionRetencion.SetFilter("Porcentaje de IVA", decPorcentajeIVA);
                            if rstConfiguracionRetencion.FindLast then begin

                                //Si el proveedor tiene algún certificado de exclusión vigente

                                Clear(rstExencion);
                                rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                                rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::IVA);
                                rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                                rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                                if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                                /*
                                IF rstExencion.FINDLAST AND (rstExencion."Fecha documento" <= rstLinDiaGenL."Posting Date") AND
                                (rstExencion."Fecha efectividad retencion" >= rstLinDiaGenL."Posting Date") THEN
                                */
                                begin

                                    //Si el proveedor tiene un certificado de exclusión vigente, evalúo el Estado de Situación fiscal del proveedor
                                    //antes de aplicar el porcentaje de exclusión

                                    Clear(rstAccionEstFis);
                                    rstAccionEstFis.Get(rstProveedor."Estado de situación fiscal");
                                    case rstAccionEstFis."Acción exclusión" of

                                        rstAccionEstFis."Acción exclusión"::"Aplicar exención":
                                            begin

                                                rstFacturaBufferRTL."Importe retencion" := (((rstFacturaBufferRTL."Importe neto factura" *
                                                //rstConfiguracionRetencion."% retención")/100)*((-rstExencion."% exención"+100)/100))-
                                                fntCalcularPorcentajeRetencion(rstConfiguracionRetencion))
                                                / 100) * ((-rstExencion."% exención" + 100) / 100)) -
                                                decImportePagosAnterioresIVAL;
                                                rstFacturaBufferRTL.Excluido := 2;
                                                rstFacturaBufferRTL."% Exclusion" := rstExencion."% exención";
                                                rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";
                                                rstFacturaBufferRTL."Numero de Certificado" := rstExencion."No. documento";

                                            end;

                                        rstAccionEstFis."Acción exclusión"::"No aplicar exención":
                                            begin

                                                rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                                //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                                fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                ) / 100) - decImportePagosAnterioresIVAL;
                                                rstFacturaBufferRTL.Excluido := 0;
                                                rstFacturaBufferRTL."% Exclusion" := 0;
                                                rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                            end;

                                        rstAccionEstFis."Acción exclusión"::"Consultar al usuario":
                                            begin

                                                if Confirm('El proveedor %1 posee un Certificado de Exclusión de situación %2 por un %3 por ciento.\' +
                                                '¿Desea aplicarlo en este pago?', false, rstProveedor.Name,
                                                rstProveedor."Estado de situación fiscal", rstExencion."% exención") then begin

                                                    rstFacturaBufferRTL."Importe retencion" := (((rstFacturaBufferRTL."Importe neto factura" *
                                                    //rstConfiguracionRetencion."% retención")/100)*((-rstExencion."% exención"+100)/100))-
                                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                    ) / 100) * ((-rstExencion."% exención" + 100) / 100)) -
                                                    decImportePagosAnterioresIVAL;
                                                    rstFacturaBufferRTL.Excluido := 2;
                                                    rstFacturaBufferRTL."% Exclusion" := rstExencion."% exención";
                                                    rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";
                                                    rstFacturaBufferRTL."Numero de Certificado" := rstExencion."No. documento";

                                                end
                                                else begin

                                                    rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                                    //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                    ) / 100) - decImportePagosAnterioresIVAL;
                                                    rstFacturaBufferRTL.Excluido := 0;
                                                    rstFacturaBufferRTL."% Exclusion" := 0;
                                                    rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                                end;

                                            end;

                                    end;

                                end
                                else begin

                                    //Si la fecha del certificado de exclusión es anterior a la fecha del pago

                                    Clear(rstExencion);
                                    rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                                    rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::IVA);
                                    //rstExencion.SETFILTER("Fecha efectividad retencion",'>=%1|%2',rstLinDiaGenL."Posting Date",0D);
                                    rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                                    rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                                    if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                                    //IF rstExencion.FINDLAST AND (rstExencion."Fecha efectividad retencion" < rstLinDiaGenL."Posting Date") THEN
                                    /*ERROR('El certificado de Exención del proveedor %1, %2, ha vencido. \'+
                                    'Por favor, actualice el certificado, o elimínelo de la configuración del proveedor.',
                                    ",rstProveedor.Name)*/
                                    begin
                                        fntConfirmaExencionAntigua(rstExencion, rstProveedor);
                                        rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                        //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                        ) / 100) - decImportePagosAnterioresIVAL;
                                        rstFacturaBufferRTL.Excluido := 0;
                                        rstFacturaBufferRTL."% Exclusion" := 0;
                                        rstFacturaBufferRTL."Fecha documento exclusion" := 0D;
                                    end
                                    else begin

                                        rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                        //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                        ) / 100) - decImportePagosAnterioresIVAL;
                                        rstFacturaBufferRTL.Excluido := 0;
                                        rstFacturaBufferRTL."% Exclusion" := 0;
                                        rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                    end;

                                end;

                                if not rstExencion.FindFirst then begin

                                    rstFacturaBufferRTL.Excluido := 3;
                                    rstFacturaBufferRTL.Modify;

                                end;

                            end
                            else begin

                                //Almaceno en el buffer de retenciones el motivo de la exclusión para esta factura

                                rstFacturaBufferRTL.Excluido := 3;
                                rstFacturaBufferRTL.Modify;

                            end;

                        end;

                end;

                if rstCodigosRetencion."Exclusión por actividad" then
                    rstFacturaBufferRTL.Excluido := 7;

            end
            else begin

                //Si el cálculo de ese código de retención no es stepwise

                Clear(rstConfiguracionRetencion);
                rstConfiguracionRetencion.SetRange("Tipo retenciones", rstConfiguracionRetencion."Tipo retenciones"::IVA);
                rstConfiguracionRetencion.SetRange("Cod. retencion", rstLinFacturaL."Cód. retención IVA");
                rstConfiguracionRetencion.SetRange("Tipo fiscal", rstFacturaBufferRTL."Tipo fiscal");
                if rstConfiguracionRetencion.FindFirst then begin

                    //Si el proveedor tiene un certificado de exclusión vigente

                    Clear(rstExencion);
                    rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                    rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::IVA);
                    rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                    //rstExencion.SETFILTER("Fecha efectividad retencion",'>=%1',rstLinDiaGenL."Posting Date");
                    //IF rstExencion.FINDLAST THEN
                    begin

                        //Si tiene certificado de exclusión, me fijo en el estado de situación fiscal

                        Clear(rstAccionEstFis);
                        rstAccionEstFis.Get(rstProveedor."Estado de situación fiscal");
                        case rstAccionEstFis."Acción exclusión" of

                            rstAccionEstFis."Acción exclusión"::"Aplicar exención":
                                begin

                                    rstFacturaBufferRTL."Importe retencion" := (((rstFacturaBufferRTL."Importe neto factura" *
                                    //rstConfiguracionRetencion."% retención")/100)*((-rstExencion."% exención"+100)/100))-
                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                    ) / 100) * ((-rstExencion."% exención" + 100) / 100)) -
                                    decImportePagosAnterioresIVAL;
                                    rstFacturaBufferRTL.Excluido := 2;
                                    rstFacturaBufferRTL."% Exclusion" := rstExencion."% exención";
                                    rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";
                                    rstFacturaBufferRTL."Numero de Certificado" := rstExencion."No. documento";

                                end;

                            rstAccionEstFis."Acción exclusión"::"No aplicar exención":
                                begin

                                    rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                    //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                    ) / 100) - decImportePagosAnterioresIVAL;
                                    rstFacturaBufferRTL.Excluido := 0;
                                    rstFacturaBufferRTL."% Exclusion" := 0;
                                    rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                end;

                            rstAccionEstFis."Acción exclusión"::"Consultar al usuario":
                                begin

                                    if Confirm('El proveedor %1 posee un Certificado de Exclusión de situación %2 por un %3 por ciento.\' +
                                    '¿Desea aplicarlo en este pago?', false, rstProveedor.Name,
                                    rstProveedor."Estado de situación fiscal", rstExencion."% exención") then begin

                                        rstFacturaBufferRTL."Importe retencion" := (((rstFacturaBufferRTL."Importe neto factura" *
                                        //rstConfiguracionRetencion."% retención")/100)*((-rstExencion."% exención"+100)/100))-
                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                        ) / 100) * ((-rstExencion."% exención" + 100) / 100)) -
                                        decImportePagosAnterioresIVAL;
                                        rstFacturaBufferRTL.Excluido := 2;
                                        rstFacturaBufferRTL."% Exclusion" := rstExencion."% exención";
                                        rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";
                                        rstFacturaBufferRTL."Numero de Certificado" := rstExencion."No. documento";

                                    end
                                    else begin

                                        rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                        //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                        ) / 100) - decImportePagosAnterioresIVAL;
                                        rstFacturaBufferRTL.Excluido := 0;
                                        rstFacturaBufferRTL."% Exclusion" := 0;
                                        rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                    end;
                                end;
                        end;

                    end
                    else begin

                        Clear(rstExencion);
                        rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                        rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::IVA);
                        //rstExencion.SETFILTER("Fecha efectividad retencion",'>=%1|%2',rstLinDiaGenL."Posting Date",0D);
                        rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                        rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);

                        if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                            //IF rstExencion.FINDLAST AND (rstExencion."Fecha efectividad retencion" < rstLinDiaGenL."Posting Date") THEN
                            /*ERROR('El certificado de Exención del proveedor %1, %2, ha vencido. \'+
                            'Por favor, actualice el certificado, o elimínelo de la configuración del proveedor.',
                            ",rstProveedor.Name)*/
                                        fntConfirmaExencionAntigua(rstExencion, rstProveedor)

                        else begin

                            if rstExencion.FindLast and (not rstConfiguracionRetencion."Skip exclusions") and (rstExencion."Fecha documento" > rstLinDiaGenL."Posting Date") then
                                /*ERROR('El certificado de Exención del proveedor %1, %2, no está todavía vigente. \',
                                ",rstProveedor.Name)*/
                                            fntConfirmaExencionAntigua(rstExencion, rstProveedor);
                        end;
                        /*
                          ELSE
                          BEGIN
                          */
                        if (rstConfiguracionRetencion."Precio unitario maximo" < rstFacturaBufferRTL."Precio unitario maximo fac.") and
                            (rstConfiguracionRetencion."Precio unitario maximo" <> 0) then begin

                            rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                            //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                            fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                            ) / 100) - decImportePagosAnterioresIVAL;
                            rstFacturaBufferRTL.Excluido := 0;
                            rstFacturaBufferRTL."% Exclusion" := 0;
                            rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                        end
                        else begin

                            if rstConfiguracionRetencion."Importe minimo Stepwise" < rstFacturaBufferRTL."Facturacion anterior 12M" then begin

                                rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                ) / 100) - decImportePagosAnterioresIVAL;
                                rstFacturaBufferRTL.Excluido := 0;
                                rstFacturaBufferRTL."% Exclusion" := 0;
                                rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                            end;
                        end;
                    end;
                end;
            end;
            if rstCodigosRetencion."Exclusión por actividad" then
                rstFacturaBufferRTL.Excluido := 7;

        end;
        //Completo la línea de retención con la información de la retención
        //Si está marcado "Exento retención en IVA" en el proveedor, tipo de exclusión 3
        if rstFacturaBufferRTL.Excluido = 0 then
            fntTestExentoRetencionIVA(rstFacturaBufferRTL."Cliente/Proveedor", rstFacturaBufferRTL."Importe retencion", rstFacturaBufferRTL.Excluido);

        rstFacturaBufferRTL.Provincia := rstLinFacturaL.Area;
        rstFacturaBufferRTL."% retencion" := rstConfiguracionRetencion."% retencion" /
                                              100 * rstConfiguracionRetencion."Porcentaje de IVA";
        rstFacturaBufferRTL."No. serie IVA" := '';
        rstFacturaBufferRTL."Fecha factura" := rstCabFacturaL."Document Date";
        if not rstFacturaBufferRTL.Insert then
            rstFacturaBufferRTL.Modify;

        decPorcentajeIVA := '';
        rst13810.GetTable(rstFacturaBufferRTL);
        cduValidaciones.ValidarxTabla(rst13810, rst13810.GetPosition(), strFiltro);

    end;

    [Scope('OnPrem')]
    procedure CrearDiarioPagosIVA(var rstLinDiaGen: Record "Gen. Journal Line")
    var
        rstHisCFacComp: Record "Purch. Inv. Header";
        intMotivoExclusion: Integer;
        rstCodigosRetencion: Record "Withholding codes";
        rstFacturaBufferRT2: Record "Invoice Withholding Buffer";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstLinDiaGen2: Record "Gen. Journal Line";
        rstLinDiaGenTemp: Record "Gen. Journal Line";
        rstConfCont: Record "General Ledger Setup";
        rstHisCNC: Record "Purch. Cr. Memo Hdr.";
        rstFacturaBufferRT: Record "Invoice Withholding Buffer";
    begin
        //CrearDiarioPagosIva

        Clear(rstConfCont);
        rstConfCont.Get();
        Clear(rstFacturaBufferRT);
        CalcularTotalRetenido(rstLinDiaGen."Document No.", rstLinDiaGen."Applies-to Doc. No.");
        rstFacturaBufferRT.SetCurrentKey(rstFacturaBufferRT."No. documento");
        rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstLinDiaGen."Document No.");
        rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::IVA);
        rstFacturaBufferRT.SetFilter("Importe retencion", '<>0');
        if rstFacturaBufferRT.FindFirst then
            repeat

                rstFacturaBufferRT."Importe retencion" := Round(rstFacturaBufferRT."Importe retencion", 0.01);
                rstFacturaBufferRT.CalcFields(rstFacturaBufferRT."Importe retencion total");

                if rstFacturaBufferRT."Tipo factura" = rstFacturaBufferRT."Tipo factura"::Factura then begin

                    Clear(rstHisCFacComp);
                    rstHisCFacComp.Get(rstFacturaBufferRT."No. Factura");

                    if intMotivoExclusion = 0 then begin

                        Clear(rstCodigosRetencion);
                        rstCodigosRetencion.SetRange("Tipo impuesto retencion", rstCodigosRetencion."Tipo impuesto retencion"::IVA);
                        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstLinDiaGen."Posting Date", 0D);
                        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstLinDiaGen."Posting Date", 0D);
                        rstCodigosRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                        //IF rstCodigosRetencion.GET(rstCodigosRetencion."Tipo impuesto retencion"::IVA,rstLinFacturaL."Cód. retención IVA") THEN
                        if rstCodigosRetencion.FindFirst then begin

                            if rstCodigosRetencion."Stepwise calculation" then begin

                                Clear(rstFacturaBufferRT2);
                                Clear(rstConfiguracionRetencion);
                                rstConfiguracionRetencion.SetRange("Tipo fiscal", rstFacturaBufferRT."Tipo fiscal");
                                rstConfiguracionRetencion.SetRange("Tipo retenciones", rstFacturaBufferRT."Tipo retencion");
                                rstConfiguracionRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");

                                rstProveedor.Get(rstFacturaBufferRT."Cliente/Proveedor");

                                Clear(rstConfCont);
                                rstConfCont.Get();

                                Clear(rstTFiscal);
                                rstTFiscal.Get(rstFacturaBufferRT."Tipo fiscal");

                                case rstTFiscal."Tipo cálculo acumulado" of

                                    rstTFiscal."Tipo cálculo acumulado"::" ",
                                  rstTFiscal."Tipo cálculo acumulado"::Mensual:

                                        rstConfiguracionRetencion.SetRange(rstConfiguracionRetencion."Importe minimo Stepwise", 0,
                                        rstFacturaBufferRT."Importe retencion total");

                                    rstTFiscal."Tipo cálculo acumulado"::"11 meses":

                                        rstConfiguracionRetencion.SetRange(rstConfiguracionRetencion."Importe minimo Stepwise", 0,
                                        rstFacturaBufferRT."Facturacion anterior 12M");

                                end;

                                if rstConfiguracionRetencion.FindLast then begin

                                    if rstFacturaBufferRT."Importe retencion total" >= rstConfiguracionRetencion."Importe min. retencion" then begin

                                        Clear(rstLinDiaGen2);
                                        rstLinDiaGen2.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
                                        rstLinDiaGen2.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                                        rstLinDiaGen2.SetRange("Document No.", rstLinDiaGen."Document No.");
                                        if rstLinDiaGen2.FindLast then;
                                        Clear(rstLinDiaGenTemp);
                                        rstLinDiaGenTemp."Journal Template Name" := rstLinDiaGen."Journal Template Name";
                                        rstLinDiaGenTemp."Journal Batch Name" := rstLinDiaGen."Journal Batch Name";
                                        rstLinDiaGenTemp."Posting Date" := rstLinDiaGen."Posting Date";
                                        rstLinDiaGenTemp."Posting No. Series" := rstLinDiaGen."Posting No. Series";
                                        rstLinDiaGenTemp."Due Date" := Today;
                                        rstLinDiaGenTemp."Document No." := rstLinDiaGen."Document No.";
                                        rstLinDiaGenTemp."Line No." := rstLinDiaGen2."Line No." + 1;
                                        rstLinDiaGenTemp."Due Date" := rstLinDiaGen."Due Date";
                                        rstLinDiaGenTemp."Document Type" := rstLinDiaGenTemp."Document Type"::Payment;
                                        rstLinDiaGenTemp."Account Type" := rstLinDiaGenTemp."Account Type"::"G/L Account";
                                        rstLinDiaGenTemp."Transaction No." := rstLinDiaGen."Transaction No.";
                                        rstLinDiaGenTemp."No. cheque" := rstLinDiaGen."No. cheque";
                                        //rstLinDiaGenTemp."Account No." := rstTipoImpRetencion."Cuenta retención";
                                        case rstFacturaBufferRT."Tipo retencion" of
                                            rstFacturaBufferRT."Tipo retencion"::IVA:
                                                begin
                                                    Clear(rstConfCont);
                                                    rstConfCont.Get();
                                                    rstLinDiaGenTemp."Account No." := rstConfCont."VAT withholding account";
                                                    rstLinDiaGenTemp.Description := CopyStr('Ret. IVA ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                end;
                                            rstFacturaBufferRT."Tipo retencion"::Ganancias:
                                                begin
                                                    Clear(rstConfCont);
                                                    rstConfCont.Get();
                                                    rstLinDiaGenTemp."Account No." := rstConfCont."Winnings withholding account";
                                                    rstLinDiaGenTemp.Description := CopyStr('Ret. Gan. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                end;
                                            rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos":
                                                begin
                                                    Clear(rstConfCont);
                                                    rstConfCont.Get();
                                                    rstLinDiaGenTemp."Account No." := rstConfCont."GI withholding account";
                                                    rstLinDiaGenTemp.Description := CopyStr('Ret. I.B. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                end;
                                            rstFacturaBufferRT."Tipo retencion"::"Seguridad Social":
                                                begin
                                                    Clear(rstConfCont);
                                                    rstConfCont.Get();
                                                    rstLinDiaGenTemp."Account No." := rstConfCont."SS withholding account";
                                                    rstLinDiaGenTemp.Description := CopyStr('Ret. SS. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                end;
                                        end;

                                        rstLinDiaGenTemp.Validate("Account No.");
                                        rstLinDiaGenTemp.Validate(Amount, -rstFacturaBufferRT."Importe retencion");
                                        rstLinDiaGenTemp."Factor divisa operacion" := rstLinDiaGen."Factor divisa operacion";
                                        rstLinDiaGenTemp."Valor divisa operacion" := rstLinDiaGen."Valor divisa operacion";
                                        if rstLinDiaGenTemp."Shortcut Dimension 1 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 1 Code", rstLinDiaGen."Shortcut Dimension 1 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 2 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 2 Code", rstLinDiaGen."Shortcut Dimension 2 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 3 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 3 Code", rstLinDiaGen."Shortcut Dimension 3 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 4 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 4 Code", rstLinDiaGen."Shortcut Dimension 4 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 5 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 5 Code", rstLinDiaGen."Shortcut Dimension 5 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 6 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 6 Code", rstLinDiaGen."Shortcut Dimension 6 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 7 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 7 Code", rstLinDiaGen."Shortcut Dimension 7 Code");
                                        rstLinDiaGenTemp."External Document No." := rstHisCFacComp."Vendor Invoice No.";
                                        rstLinDiaGenTemp."Descripción 2" := rstFacturaBufferRT."No. Factura";
                                        rstFacturaBufferRT.Retenido := true;
                                        rstFacturaBufferRT.Modify;
                                        rstLinDiaGenTemp.Retención := true;
                                        rstFacturaBufferRT.Retenido := true;
                                        rstFacturaBufferRT.Modify;

                                        if not rstLinDiaGenTemp.Insert then
                                            rstLinDiaGenTemp.Modify;

                                    end;
                                end
                                else begin

                                    rstFacturaBufferRT.Excluido := 3;
                                    rstFacturaBufferRT.Modify;

                                end;
                            end
                            else begin

                                Clear(rstConfiguracionRetencion);
                                rstConfiguracionRetencion.SetRange("Tipo retenciones", rstFacturaBufferRT."Tipo retencion");
                                rstConfiguracionRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                                if rstConfiguracionRetencion.FindFirst then begin

                                    if rstFacturaBufferRT."Importe retencion total" >= rstConfiguracionRetencion."Importe min. retencion" then begin

                                        Clear(rstLinDiaGen2);
                                        rstLinDiaGen2.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
                                        rstLinDiaGen2.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                                        rstLinDiaGen2.SetRange("Document No.", rstLinDiaGen."Document No.");
                                        if rstLinDiaGen2.FindLast then;
                                        Clear(rstLinDiaGenTemp);
                                        rstLinDiaGenTemp."Journal Template Name" := rstLinDiaGen."Journal Template Name";
                                        rstLinDiaGenTemp."Journal Batch Name" := rstLinDiaGen."Journal Batch Name";
                                        rstLinDiaGenTemp."Posting Date" := rstLinDiaGen."Posting Date";
                                        rstLinDiaGenTemp."Posting No. Series" := rstLinDiaGen."Posting No. Series";
                                        rstLinDiaGenTemp."Due Date" := Today;
                                        rstLinDiaGenTemp."Document No." := rstLinDiaGen."Document No.";
                                        rstLinDiaGenTemp."Line No." := rstLinDiaGen2."Line No." + 1;
                                        rstLinDiaGenTemp."Due Date" := rstLinDiaGen."Due Date";
                                        rstLinDiaGenTemp."No. cheque" := rstLinDiaGen."No. cheque";
                                        rstLinDiaGenTemp."Transaction No." := rstLinDiaGen."Transaction No.";
                                        rstLinDiaGenTemp.Validate("Account No.");
                                        if rstLinDiaGenTemp."Shortcut Dimension 1 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 1 Code", rstLinDiaGen."Shortcut Dimension 1 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 2 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 2 Code", rstLinDiaGen."Shortcut Dimension 2 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 3 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 3 Code", rstLinDiaGen."Shortcut Dimension 3 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 4 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 4 Code", rstLinDiaGen."Shortcut Dimension 4 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 5 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 5 Code", rstLinDiaGen."Shortcut Dimension 5 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 6 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 6 Code", rstLinDiaGen."Shortcut Dimension 6 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 7 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 7 Code", rstLinDiaGen."Shortcut Dimension 7 Code");

                                        rstLinDiaGenTemp."Document Type" := rstLinDiaGenTemp."Document Type"::Payment;
                                        rstLinDiaGenTemp."Account Type" := rstLinDiaGenTemp."Account Type"::"G/L Account";
                                        case rstFacturaBufferRT."Tipo retencion" of
                                            rstFacturaBufferRT."Tipo retencion"::IVA:
                                                begin
                                                    Clear(rstConfCont);
                                                    rstConfCont.Get();
                                                    rstLinDiaGenTemp."Account No." := rstConfCont."VAT withholding account";
                                                    rstLinDiaGenTemp.Description := CopyStr('Ret. IVA ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                end;
                                            rstFacturaBufferRT."Tipo retencion"::Ganancias:
                                                begin
                                                    Clear(rstConfCont);
                                                    rstConfCont.Get();
                                                    rstLinDiaGenTemp."Account No." := rstConfCont."Winnings withholding account";
                                                    rstLinDiaGenTemp.Description := CopyStr('Ret. Gan. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                end;
                                            rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos":
                                                begin
                                                    Clear(rstConfCont);
                                                    rstConfCont.Get();
                                                    rstLinDiaGenTemp."Account No." := rstConfCont."GI withholding account";
                                                    rstLinDiaGenTemp.Description := CopyStr('Ret. I.B. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                end;
                                            rstFacturaBufferRT."Tipo retencion"::"Seguridad Social":
                                                begin
                                                    Clear(rstConfCont);
                                                    rstConfCont.Get();
                                                    rstLinDiaGenTemp."Account No." := rstConfCont."SS withholding account";
                                                    rstLinDiaGenTemp.Description := CopyStr('Ret. SS. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                end;

                                        end;
                                        rstLinDiaGenTemp.Validate(Amount, -rstFacturaBufferRT."Importe retencion");
                                        rstLinDiaGenTemp."External Document No." := rstHisCFacComp."Vendor Invoice No.";
                                        rstLinDiaGenTemp."Descripción 2" := rstFacturaBufferRT."No. Factura";
                                        rstLinDiaGenTemp."Factor divisa operacion" := rstLinDiaGen."Factor divisa operacion";
                                        rstLinDiaGenTemp."Valor divisa operacion" := rstLinDiaGen."Valor divisa operacion";
                                        rstLinDiaGenTemp.Retención := true;
                                        rstFacturaBufferRT.Retenido := true;
                                        rstFacturaBufferRT.Modify;
                                        if not rstLinDiaGenTemp.Insert then
                                            rstLinDiaGenTemp.Modify;

                                    end
                                    else begin

                                        rstFacturaBufferRT.Excluido := 3;
                                        rstFacturaBufferRT.Modify;

                                    end;

                                end;

                            end;
                        end;

                    end
                    else begin

                        rstFacturaBufferRT.Excluido := intMotivoExclusion;
                        rstFacturaBufferRT.Modify;

                    end;

                end;

                if rstFacturaBufferRT."Tipo factura" = rstFacturaBufferRT."Tipo factura"::"Nota d/c" then begin

                    Clear(rstHisCNC);
                    rstHisCNC.Get(rstFacturaBufferRT."No. Factura");
                    if intMotivoExclusion = 0 then begin

                        Clear(rstCodigosRetencion);
                        rstCodigosRetencion.SetRange("Tipo impuesto retencion", rstCodigosRetencion."Tipo impuesto retencion"::IVA);
                        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstLinDiaGen."Posting Date", 0D);
                        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstLinDiaGen."Posting Date", 0D);
                        rstCodigosRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                        //IF rstCodigosRetencion.GET(rstCodigosRetencion."Tipo impuesto retencion"::IVA,rstLinFacturaL."Cód. retención IVA") THEN
                        if rstCodigosRetencion.FindFirst then begin

                            if rstCodigosRetencion."Stepwise calculation" then begin

                                Clear(rstFacturaBufferRT2);
                                Clear(rstConfiguracionRetencion);
                                rstConfiguracionRetencion.SetRange("Tipo fiscal", rstFacturaBufferRT."Tipo fiscal");
                                rstConfiguracionRetencion.SetRange("Tipo retenciones", rstFacturaBufferRT."Tipo retencion");
                                rstConfiguracionRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                                rstConfiguracionRetencion.SetRange(rstConfiguracionRetencion."Importe minimo Stepwise", 0,
                                Abs(rstFacturaBufferRT."Importe retencion total"));
                                if rstConfiguracionRetencion.FindLast then begin

                                    Clear(rstLinDiaGen2);
                                    rstLinDiaGen2.SetRange(rstLinDiaGen2."Journal Template Name", rstLinDiaGen."Journal Template Name");
                                    rstLinDiaGen2.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                                    //rstLinDiaGen2.SETRANGE("No. documento",rstLinDiaGen."No. documento");
                                    if rstLinDiaGen2.FindLast then;
                                    Clear(rstLinDiaGenTemp);
                                    rstLinDiaGenTemp."Journal Template Name" := rstLinDiaGen."Journal Template Name";
                                    rstLinDiaGenTemp."Journal Batch Name" := rstLinDiaGen."Journal Batch Name";
                                    rstLinDiaGenTemp."Posting Date" := rstLinDiaGen."Posting Date";
                                    rstLinDiaGenTemp."Posting No. Series" := rstLinDiaGen."Posting No. Series";
                                    rstLinDiaGenTemp."Due Date" := Today;
                                    rstLinDiaGenTemp."Document No." := rstLinDiaGen."Document No.";
                                    rstLinDiaGenTemp."Line No." := rstLinDiaGen2."Line No." + 1;
                                    rstLinDiaGenTemp."Due Date" := rstLinDiaGen."Due Date";
                                    rstLinDiaGenTemp."Document Type" := rstLinDiaGenTemp."Document Type"::Payment;
                                    rstLinDiaGenTemp."Account Type" := rstLinDiaGenTemp."Account Type"::"G/L Account";
                                    rstLinDiaGenTemp."Transaction No." := rstLinDiaGen."Transaction No.";
                                    rstLinDiaGenTemp."No. cheque" := rstLinDiaGen."No. cheque";
                                    rstLinDiaGenTemp.Validate("Account No.");
                                    if rstLinDiaGenTemp."Shortcut Dimension 1 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 1 Code", rstLinDiaGen."Shortcut Dimension 1 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 2 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 2 Code", rstLinDiaGen."Shortcut Dimension 2 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 3 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 3 Code", rstLinDiaGen."Shortcut Dimension 3 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 4 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 4 Code", rstLinDiaGen."Shortcut Dimension 4 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 5 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 5 Code", rstLinDiaGen."Shortcut Dimension 5 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 6 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 6 Code", rstLinDiaGen."Shortcut Dimension 6 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 7 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 7 Code", rstLinDiaGen."Shortcut Dimension 7 Code");

                                    //rstLinDiaGenTemp."Account No." := rstTipoImpRetencion."Cuenta retención";
                                    case rstFacturaBufferRT."Tipo retencion" of
                                        rstFacturaBufferRT."Tipo retencion"::IVA:
                                            begin
                                                Clear(rstConfCont);
                                                rstConfCont.Get();
                                                rstLinDiaGenTemp."Account No." := rstConfCont."VAT withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. IVA ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;
                                        rstFacturaBufferRT."Tipo retencion"::Ganancias:
                                            begin
                                                Clear(rstConfCont);
                                                rstConfCont.Get();
                                                rstLinDiaGenTemp."Account No." := rstConfCont."Winnings withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. Gan. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;
                                        rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos":
                                            begin
                                                Clear(rstConfCont);
                                                rstConfCont.Get();
                                                rstLinDiaGenTemp."Account No." := rstConfCont."GI withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. I.B. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;
                                        rstFacturaBufferRT."Tipo retencion"::"Seguridad Social":
                                            begin
                                                Clear(rstConfCont);
                                                rstConfCont.Get();
                                                rstLinDiaGenTemp."Account No." := rstConfCont."SS withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. SS. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;
                                    end;

                                    rstLinDiaGenTemp.Validate(Amount, -rstFacturaBufferRT."Importe retencion");
                                    rstLinDiaGenTemp."Descripción 2" := rstFacturaBufferRT."No. Factura";
                                    rstLinDiaGenTemp."External Document No." := rstHisCNC."Vendor Cr. Memo No.";
                                    rstLinDiaGenTemp."Factor divisa operacion" := rstLinDiaGen."Factor divisa operacion";
                                    rstLinDiaGenTemp."Valor divisa operacion" := rstLinDiaGen."Valor divisa operacion";
                                    rstLinDiaGenTemp.Retención := true;
                                    rstFacturaBufferRT.Retenido := true;
                                    rstFacturaBufferRT.Modify;

                                    if not rstLinDiaGenTemp.Insert then
                                        rstLinDiaGenTemp.Modify;

                                end
                                else begin

                                    rstFacturaBufferRT.Excluido := 3;
                                    rstFacturaBufferRT.Modify;

                                end;

                            end
                            else begin

                                Clear(rstConfiguracionRetencion);
                                rstConfiguracionRetencion.SetRange("Tipo retenciones", rstFacturaBufferRT."Tipo retencion");
                                rstConfiguracionRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                                if rstConfiguracionRetencion.FindFirst then begin

                                    if Abs(rstFacturaBufferRT."Importe retencion total") >= rstConfiguracionRetencion."Importe min. retencion" then begin

                                        Clear(rstLinDiaGen2);
                                        rstLinDiaGen2.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
                                        rstLinDiaGen2.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                                        //rstLinDiaGen2.SETRANGE("No. documento",rstLinDiaGen."No. documento");
                                        if rstLinDiaGen2.FindLast then;
                                        Clear(rstLinDiaGenTemp);
                                        rstLinDiaGenTemp."Journal Template Name" := rstLinDiaGen."Journal Template Name";
                                        rstLinDiaGenTemp."Journal Batch Name" := rstLinDiaGen."Journal Batch Name";
                                        rstLinDiaGenTemp."Posting Date" := rstLinDiaGen."Posting Date";
                                        rstLinDiaGenTemp."Posting No. Series" := rstLinDiaGen."Posting No. Series";
                                        rstLinDiaGenTemp."Due Date" := Today;
                                        rstLinDiaGenTemp."Document No." := rstLinDiaGen."Document No.";
                                        rstLinDiaGenTemp."Line No." := rstLinDiaGen2."Line No." + 1;
                                        rstLinDiaGenTemp."Due Date" := rstLinDiaGen."Due Date";
                                        rstLinDiaGenTemp."Transaction No." := rstLinDiaGen."Transaction No.";
                                        rstLinDiaGenTemp.Validate("Account No.");
                                        if rstLinDiaGenTemp."Shortcut Dimension 1 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 1 Code", rstLinDiaGen."Shortcut Dimension 1 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 2 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 2 Code", rstLinDiaGen."Shortcut Dimension 2 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 3 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 3 Code", rstLinDiaGen."Shortcut Dimension 3 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 4 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 4 Code", rstLinDiaGen."Shortcut Dimension 4 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 5 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 5 Code", rstLinDiaGen."Shortcut Dimension 5 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 6 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 6 Code", rstLinDiaGen."Shortcut Dimension 6 Code");
                                        if rstLinDiaGenTemp."Shortcut Dimension 7 Code" = '' then
                                            rstLinDiaGenTemp.Validate("Shortcut Dimension 7 Code", rstLinDiaGen."Shortcut Dimension 7 Code");

                                        rstLinDiaGenTemp."No. cheque" := rstLinDiaGen."No. cheque";
                                        rstLinDiaGenTemp."Document Type" := rstLinDiaGenTemp."Document Type"::Payment;
                                        rstLinDiaGenTemp."Account Type" := rstLinDiaGenTemp."Account Type"::"G/L Account";
                                        case rstFacturaBufferRT."Tipo retencion" of
                                            rstFacturaBufferRT."Tipo retencion"::IVA:
                                                begin
                                                    Clear(rstConfCont);
                                                    rstConfCont.Get();
                                                    rstLinDiaGenTemp."Account No." := rstConfCont."VAT withholding account";
                                                    rstLinDiaGenTemp.Description := CopyStr('Ret. IVA ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                end;
                                            rstFacturaBufferRT."Tipo retencion"::Ganancias:
                                                begin
                                                    Clear(rstConfCont);
                                                    rstConfCont.Get();
                                                    rstLinDiaGenTemp."Account No." := rstConfCont."Winnings withholding account";
                                                    rstLinDiaGenTemp.Description := CopyStr('Ret. Gan. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                end;
                                            rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos":
                                                begin
                                                    Clear(rstConfCont);
                                                    rstConfCont.Get();
                                                    rstLinDiaGenTemp."Account No." := rstConfCont."GI withholding account";
                                                    rstLinDiaGenTemp.Description := CopyStr('Ret. I.B. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                end;
                                            rstFacturaBufferRT."Tipo retencion"::"Seguridad Social":
                                                begin
                                                    Clear(rstConfCont);
                                                    rstConfCont.Get();
                                                    rstLinDiaGenTemp."Account No." := rstConfCont."SS withholding account";
                                                    rstLinDiaGenTemp.Description := CopyStr('Ret. SS. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                end;
                                        end;
                                        rstLinDiaGenTemp.Validate(Amount, -rstFacturaBufferRT."Importe retencion");
                                        rstLinDiaGenTemp."Descripción 2" := rstFacturaBufferRT."No. Factura";
                                        rstLinDiaGenTemp."External Document No." := rstHisCNC."Vendor Cr. Memo No.";
                                        rstLinDiaGenTemp."Factor divisa operacion" := rstLinDiaGen."Factor divisa operacion";
                                        rstLinDiaGenTemp."Valor divisa operacion" := rstLinDiaGen."Valor divisa operacion";
                                        rstLinDiaGenTemp.Retención := true;
                                        rstFacturaBufferRT.Retenido := true;
                                        rstFacturaBufferRT.Modify;

                                        if not rstLinDiaGenTemp.Insert then
                                            rstLinDiaGenTemp.Modify;

                                    end
                                    else begin

                                        rstFacturaBufferRT.Excluido := 3;
                                        rstFacturaBufferRT.Modify;

                                    end;

                                end;

                            end;

                        end;
                    end
                    else begin

                        rstFacturaBufferRT.Excluido := intMotivoExclusion;
                        rstFacturaBufferRT.Modify;

                    end;

                end;

            until rstFacturaBufferRT.Next = 0;
    end;

    [Scope('OnPrem')]
    procedure CalcularRetencionGanancias(var rstLinDiaGen: Record "Gen. Journal Line"; rstProveedor: Record Vendor)
    var
        rstCabFactura: Record "Purch. Inv. Header";
        rstLinFactura: Record "Purch. Inv. Line";
        rstLinDiaGenTemp: Record "Gen. Journal Line";
        rstMovProveedor: Record "Vendor Ledger Entry";
        rstFacturaBufferRT: Record "Invoice Withholding Buffer";
        decImportePagosAnterioresIVA: Decimal;
        rstCabNC: Record "Purch. Cr. Memo Hdr.";
        rstLinNC: Record "Purch. Cr. Memo Line";
        rstFacturaBufferRT2: Record "Invoice Withholding Buffer";
        rstCodigosRetencion: Record "Withholding codes";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstExencion: Record "Withholding details";
        rstAccionEstFis: Record "Acción estado sit. fiscal";
        intMotivoExclusion: Integer;
        decImportePagoPorConcepto: Decimal;
        rstMovProveedorPagos: Record "Vendor Ledger Entry";
        rstMovProveedorNC: Record "Vendor Ledger Entry";
        rstLinFactura2: Record "Purch. Inv. Line";
        rstLinNC2: Record "Purch. Cr. Memo Line";
        //rstTFiscal: Record "Dimension Value";
        rstConfCont: Record "General Ledger Setup";
        intFactor: Integer;
        decPorcentajePagado: Decimal;
    begin
        //CalcularRetencionGanancias

        Clear(rstLinDiaGenTemp);
        rstLinDiaGenTemp.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
        rstLinDiaGenTemp.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
        rstLinDiaGenTemp.SetRange("Document No.", rstLinDiaGen."Document No.");

        //Me posiciono en la primera factura a pagar
        if rstLinDiaGenTemp.FindFirst then
            repeat

                //Voy a la línea de la factura, y comienzo a rellenar el buffer de retenciones
                //Si el documento es una factura
                case rstLinDiaGenTemp."Applies-to Doc. Type" of
                    rstLinDiaGenTemp."Applies-to Doc. Type"::Invoice:
                        begin
                            Clear(rstMovProveedor);
                            rstMovProveedor.SetCurrentKey(rstMovProveedor."Vendor No.", "Document No.");
                            rstMovProveedor.SetRange(rstMovProveedor."Vendor No.", rstLinDiaGenTemp."Account No.");
                            rstMovProveedor.SetRange("Document No.", rstLinDiaGenTemp."Applies-to Doc. No.");
                            if rstMovProveedor.FindFirst then;
                            rstMovProveedor.CalcFields(Amount, "Remaining Amount");
                            Clear(rstLinFactura);
                            rstLinFactura.SetRange("Document No.", rstLinDiaGenTemp."Applies-to Doc. No.");
                            rstLinFactura.SetFilter("No.", '<>%1', '');
                            if rstLinFactura.FindFirst then
                                repeat
                                    Clear(rstCabFactura);
                                    rstCabFactura.Get(rstLinFactura."Document No.");
                                    rstCabFactura.CalcFields(Amount, rstCabFactura."Amount Including VAT");
                                    if (rstProveedor."VAT Bus. Posting Group" = 'PRV-RI') then
                                        if blnConfirmar then
                                            rstLinFactura.TestField("Actividad AFIP");
                                    Clear(rstFacturaBufferRT);
                                    rstFacturaBufferRT.SetRange("Tipo registro", rstFacturaBufferRT."Tipo registro"::Compra);
                                    rstFacturaBufferRT.SetRange("Cliente/Proveedor", rstProveedor."No.");
                                    rstFacturaBufferRT.SetRange("No. Factura", '');
                                    rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::Ganancias);
                                    rstFacturaBufferRT.SetRange("Cod. retencion", rstLinFactura."Cód. retención ganancias");
                                    rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstLinDiaGen."Document No.");
                                    rstFacturaBufferRT.SetRange("Tipo fiscal", rstCabFactura."VAT Bus. Posting Group");
                                    if not rstFacturaBufferRT.FindFirst then begin
                                        rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Compra;
                                        rstFacturaBufferRT."Cliente/Proveedor" := rstProveedor."No.";
                                        rstFacturaBufferRT."No. Factura" := '';
                                        rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::Ganancias;
                                        rstFacturaBufferRT."Cod. retencion" := rstLinFactura."Cód. retención ganancias";
                                        rstFacturaBufferRT."No. documento" := rstLinDiaGen."Document No.";
                                        rstFacturaBufferRT."Tipo fiscal" := rstCabFactura."VAT Bus. Posting Group";
                                        rstFacturaBufferRT."Fecha pago" := 0D;
                                        rstFacturaBufferRT."Base pago retencion" := 0;
                                        rstFacturaBufferRT."Pagos anteriores" := 0;
                                        rstFacturaBufferRT."Importe retencion" := 0;
                                        rstFacturaBufferRT."% retencion" := 0;
                                        rstFacturaBufferRT.Provincia := '';
                                        rstFacturaBufferRT."No. serie ganancias" := '';
                                        rstFacturaBufferRT."No. serie IVA" := '';
                                        rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                                        rstFacturaBufferRT."Fecha factura" := 0D;
                                        rstFacturaBufferRT.Nombre := '';
                                        rstFacturaBufferRT."Importe neto factura" := 0;
                                        rstFacturaBufferRT."Tipo factura" := rstFacturaBufferRT."Tipo factura"::Factura;
                                        rstFacturaBufferRT.Insert;
                                    end;
                                    rstFacturaBufferRT."Fecha pago" := rstLinDiaGen."Posting Date";
                                    decTCambioPago := 1;
                                    rstMovProveedor.SetFilter(rstMovProveedor."Applied by doc. type  Filter", '<>%1', rstMovProveedor."Applied by doc. type  Filter"::Abono);
                                    if rstMovProveedor.Open then
                                        decPorcentajePagado := Abs(rstLinDiaGenTemp.Amount / rstMovProveedor."Remaining Amount")
                                    else
                                        decPorcentajePagado := 1;
                                    //decPorcentajePagado := ABS(rstLinDiaGenTemp.Amount/rstMovProveedor."Amount");
                                    //decTCambioPago := fntTipoCambioPago(rstLinDiaGenTemp,rstFacturaBufferRT."No. Factura");
                                    decTCambioPago := fntTipoCambioPago(rstLinDiaGenTemp, rstCabFactura."No.");
                                    rstFacturaBufferRT."Importe neto factura" += rstLinFactura.Amount * decTCambioPago;
                                    rstFacturaBufferRT."Base pago retencion" += Round(rstLinFactura.Amount * decTCambioPago * decPorcentajePagado, rstConfCont."Amount Rounding Precision");
                                    rstFacturaBufferRT."Facturacion anterior 12M" := CalcularFacturaciónAnterior(rstLinDiaGen);
                                    rstFacturaBufferRT."Precio unitario maximo fac." := CalcularPrecioUnitarioFac(rstLinDiaGen);
                                    rstFacturaBufferRT.Modify;

                                until (rstLinFactura.Next = 0);
                        end;

                    rstLinDiaGenTemp."Applies-to Doc. Type"::"Credit Memo":
                        begin
                            Clear(rstMovProveedor);
                            rstMovProveedor.SetCurrentKey(rstMovProveedor."Vendor No.", "Document No.");
                            rstMovProveedor.SetRange(rstMovProveedor."Vendor No.", rstLinDiaGenTemp."Account No.");
                            rstMovProveedor.SetRange("Document No.", rstLinDiaGenTemp."Applies-to Doc. No.");
                            if rstMovProveedor.FindFirst then;
                            rstMovProveedor.CalcFields(Amount, "Remaining Amount");
                            Clear(rstLinNC);
                            rstLinNC.SetRange("Document No.", rstLinDiaGenTemp."Applies-to Doc. No.");
                            rstLinNC.SetFilter("No.", '<>%1', '');
                            if rstLinNC.FindFirst then
                                repeat
                                    Clear(rstCabNC);
                                    rstCabNC.Get(rstLinNC."Document No.");
                                    rstCabNC.CalcFields(Amount, rstCabNC."Amount Including VAT");
                                    if (rstProveedor."VAT Bus. Posting Group" = 'PRV-RI') then
                                        if blnConfirmar then
                                            rstLinNC.TestField("Actividad AFIP");
                                    Clear(rstFacturaBufferRT);
                                    rstFacturaBufferRT.SetRange("Tipo registro", rstFacturaBufferRT."Tipo registro"::Compra);
                                    rstFacturaBufferRT.SetRange("Cliente/Proveedor", rstProveedor."No.");
                                    rstFacturaBufferRT.SetRange("No. Factura", '');
                                    rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::Ganancias);
                                    rstFacturaBufferRT.SetRange("Cod. retencion", rstLinNC."Cód. retención ganancias");
                                    rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstLinDiaGen."Document No.");
                                    rstFacturaBufferRT.SetRange("Tipo fiscal", rstCabNC."VAT Bus. Posting Group");
                                    if not rstFacturaBufferRT.FindFirst then begin
                                        rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Compra;
                                        rstFacturaBufferRT."Cliente/Proveedor" := rstProveedor."No.";
                                        rstFacturaBufferRT."No. Factura" := '';
                                        rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::Ganancias;
                                        rstFacturaBufferRT."Cod. retencion" := rstLinNC."Cód. retención ganancias";
                                        rstFacturaBufferRT."No. documento" := rstLinDiaGen."Document No.";
                                        rstFacturaBufferRT."Tipo fiscal" := rstCabNC."VAT Bus. Posting Group";
                                        rstFacturaBufferRT."Fecha pago" := 0D;
                                        rstFacturaBufferRT."Base pago retencion" := 0;
                                        rstFacturaBufferRT."Pagos anteriores" := 0;
                                        rstFacturaBufferRT."Importe retencion" := 0;
                                        rstFacturaBufferRT."% retencion" := 0;
                                        rstFacturaBufferRT.Provincia := '';
                                        rstFacturaBufferRT."No. serie ganancias" := '';
                                        rstFacturaBufferRT."No. serie IVA" := '';
                                        rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                                        rstFacturaBufferRT."Fecha factura" := 0D;
                                        rstFacturaBufferRT.Nombre := '';
                                        rstFacturaBufferRT."Importe neto factura" := 0;
                                        rstFacturaBufferRT."Tipo factura" := rstFacturaBufferRT."Tipo factura"::"Nota d/c";
                                        rstFacturaBufferRT.Insert;
                                    end;
                                    rstFacturaBufferRT."Fecha pago" := rstLinDiaGen."Posting Date";
                                    if UserId in ['ULISES.SASOVSKY', 'ADMULISES'] then begin
                                        rstMovProveedor.SetFilter(rstMovProveedor."Applied by doc. type  Filter", '%1', rstMovProveedor."Applied by doc. type  Filter"::Abono);
                                        if rstMovProveedor.Open then
                                            decPorcentajePagado := Abs(rstLinDiaGenTemp.Amount / rstMovProveedor."Remaining Amount")
                                        else
                                            decPorcentajePagado := 1;
                                    end;
                                    decTCambioPago := 1;
                                    //rstMovProveedor.SETFILTER(rstMovProveedor."Applied by doc. type  Filter",'<>%1',rstMovProveedor."Applied by doc. type  Filter"::Abono);
                                    //decPorcentajePagado := ABS(rstLinDiaGenTemp.Amount/rstMovProveedor."Remaining Amount");
                                    //decTCambioPago := fntTipoCambioPago(rstLinDiaGenTemp,rstFacturaBufferRT."No. Factura");
                                    decTCambioPago := fntTipoCambioPago(rstLinDiaGenTemp, rstCabNC."No.");
                                    rstFacturaBufferRT."Importe neto factura" -= rstLinNC.Amount * decTCambioPago;
                                    rstFacturaBufferRT."Base pago retencion" -= Round(rstLinNC.Amount * decTCambioPago * decPorcentajePagado, rstConfCont."Amount Rounding Precision");
                                    rstFacturaBufferRT."Facturacion anterior 12M" := CalcularFacturaciónAnterior(rstLinDiaGen);
                                    rstFacturaBufferRT."Precio unitario maximo fac." := CalcularPrecioUnitarioFac(rstLinDiaGen);
                                    rstFacturaBufferRT.Modify;
                                until (rstLinNC.Next = 0);
                        end;
                end;

            until rstLinDiaGenTemp.Next = 0;

        //CalcularPagosAnterioresGan(rstLinDiaGen);
        CalcularImporteEstePago(rstLinDiaGen);
        Clear(rstFacturaBufferRT2);
        rstFacturaBufferRT2.SetRange("Tipo registro", rstFacturaBufferRT2."Tipo registro"::Compra);
        rstFacturaBufferRT2.SetRange("Cliente/Proveedor", rstLinDiaGen."Account No.");
        rstFacturaBufferRT2.SetRange("No. Factura", '');
        rstFacturaBufferRT2.SetRange("Tipo retencion", rstFacturaBufferRT2."Tipo retencion"::Ganancias);
        rstFacturaBufferRT2.SetRange(rstFacturaBufferRT2."No. documento", rstLinDiaGen."Document No.");
        if rstFacturaBufferRT2.FindFirst then
            repeat

                CalcularPagosAnterioresGan(rstLinDiaGen, rstFacturaBufferRT2);
                if rstFacturaBufferRT2."Base pago retencion" > 0 then
                    intFactor := 1
                else
                    intFactor := -1;
                Clear(rstCodigosRetencion);
                rstCodigosRetencion.SetRange("Tipo impuesto retencion", rstCodigosRetencion."Tipo impuesto retencion"::Ganancias);
                rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstLinDiaGen."Posting Date", 0D);
                rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstLinDiaGen."Posting Date", 0D);
                rstCodigosRetencion.SetRange("Cod. retencion", rstFacturaBufferRT2."Cod. retencion");
                if rstCodigosRetencion.FindFirst then begin

                    if rstCodigosRetencion."Stepwise calculation" then begin

                        Clear(rstConfiguracionRetencion);
                        rstConfiguracionRetencion.SetRange(rstConfiguracionRetencion."Tipo retenciones",
                        rstConfiguracionRetencion."Tipo retenciones"::Ganancias);
                        rstConfiguracionRetencion.SetRange(rstConfiguracionRetencion."Cod. retencion", rstFacturaBufferRT2."Cod. retencion");
                        rstConfiguracionRetencion.SetRange("Tipo fiscal", rstFacturaBufferRT2."Tipo fiscal");
                        if rstConfiguracionRetencion.FindFirst then;

                        rstProveedor.Get(rstFacturaBufferRT2."Cliente/Proveedor");

                        Clear(rstConfCont);
                        rstConfCont.Get();

                        Clear(rstTFiscal);
                        rstTFiscal.Get(rstFacturaBufferRT2."Tipo fiscal");

                        case rstTFiscal."Tipo cálculo acumulado" of

                            rstTFiscal."Tipo cálculo acumulado"::" ",
                          rstTFiscal."Tipo cálculo acumulado"::Mensual:
                                rstConfiguracionRetencion.SetRange("Importe minimo Stepwise", 0, Abs(rstFacturaBufferRT2."Base pago retencion" * intFactor -
                                rstConfiguracionRetencion."Importe pago minimo" + rstFacturaBufferRT2."Pagos anteriores"));

                            rstTFiscal."Tipo cálculo acumulado"::"11 meses":
                                rstConfiguracionRetencion.SetRange("Importe minimo Stepwise", 0, Abs(rstFacturaBufferRT2."Facturacion anterior 12M"));

                        end;

                        //Si el código de retención es RG3594, buscar el código correcto por medio de la lógica de registro
                        if rstCodigosRetencion."Verificar registro RG3594" then begin

                            if rstProveedor."Registrado RG3594" = rstProveedor."Registrado RG3594"::Activo then begin
                                rstConfiguracionRetencion.SetRange("Importe minimo Stepwise");
                                rstConfiguracionRetencion.SetRange("Registrado RG3594", rstConfiguracionRetencion."Registrado RG3594"::Activo);
                                rstConfiguracionRetencion.FindLast;
                            end;
                            if rstProveedor."Registrado RG3594" <> rstProveedor."Registrado RG3594"::Activo then begin
                                rstConfiguracionRetencion.SetRange("Importe minimo Stepwise");
                                rstConfiguracionRetencion.SetFilter("Registrado RG3594", '<>%1', rstConfiguracionRetencion."Registrado RG3594"::Activo);
                                rstConfiguracionRetencion.FindFirst;
                            end;
                            rstFacturaBufferRT2."Importe minimo pago" := rstConfiguracionRetencion."Importe pago minimo";
                            rstFacturaBufferRT2."Importe minimo retención" := rstConfiguracionRetencion."Importe min. retencion";
                            case rstTFiscal."Tipo cálculo acumulado" of

                                rstTFiscal."Tipo cálculo acumulado"::" ",
                              rstTFiscal."Tipo cálculo acumulado"::Mensual:
                                    rstFacturaBufferRT2."Importe retencion" := intFactor * Round(rstConfiguracionRetencion."Importe retencion" +
                                    (((rstFacturaBufferRT2."Base pago retencion" * intFactor + rstFacturaBufferRT2."Pagos anteriores"
                                    - rstConfiguracionRetencion."Importe minimo Stepwise" - rstConfiguracionRetencion."Importe pago minimo") *
                                    ((rstConfiguracionRetencion."% retencion" / 100)) - rstFacturaBufferRT2."Importe retenciones anteriores")), 0.01);
                                rstTFiscal."Tipo cálculo acumulado"::"11 meses":
                                    rstFacturaBufferRT2."Importe retencion" :=
                                    Round((rstFacturaBufferRT2."Base pago retencion" *
                                    (rstConfiguracionRetencion."% retencion" / 100)), 0.01);

                            end;

                            rstFacturaBufferRT2."% retencion" := rstConfiguracionRetencion."% retencion";

                            if rstCodigosRetencion."Verificar registro RG3594" then begin
                                case rstConfiguracionRetencion."% retencion" of
                                    2:
                                        rstFacturaBufferRT2."Cod. sicore" := 828;
                                    10:
                                        rstFacturaBufferRT2."Cod. sicore" := 829;
                                    35:
                                        rstFacturaBufferRT2."Cod. sicore" := 830;
                                end;
                            end
                            else
                                Evaluate(rstFacturaBufferRT2."Cod. sicore", rstCodigosRetencion."Codigo SICORE");

                        end
                        else begin

                            if rstConfiguracionRetencion.FindLast then begin
                                rstFacturaBufferRT2."Importe minimo pago" := rstConfiguracionRetencion."Importe pago minimo";
                                rstFacturaBufferRT2."Importe minimo retención" := rstConfiguracionRetencion."Importe min. retencion";
                                Clear(rstExencion);
                                rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                                rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::Ganancias);
                                rstExencion.SetFilter("Fecha documento", '<=%1', rstLinDiaGen."Posting Date");
                                rstExencion.SetFilter("Fecha efectividad retencion", '>=%1', rstLinDiaGen."Posting Date");
                                //IF rstExencion.FINDLAST AND (rstExencion."Fecha efectividad retencion" >= rstLinDiaGen."Posting Date") AND
                                //Se agrega la excepción en caso de actividades de la RG3594
                                //(NOT rstCodigosRetencion."Verificar registro RG3594") THEN
                                if rstExencion.FindLast and (not rstConfiguracionRetencion."Skip exclusions") then begin

                                    Clear(rstAccionEstFis);
                                    rstAccionEstFis.Get(rstProveedor."Estado de situación fiscal");

                                    case rstAccionEstFis."Acción exclusión" of

                                        rstAccionEstFis."Acción exclusión"::"Aplicar exención":
                                            begin

                                                rstFacturaBufferRT2."Importe retencion" := intFactor * Round((((rstConfiguracionRetencion."Importe retencion" +
                                                (((rstFacturaBufferRT2."Base pago retencion" * intFactor + rstFacturaBufferRT2."Pagos anteriores"
                                                - rstConfiguracionRetencion."Importe minimo Stepwise") *
                                                //(rstConfiguracionRetencion."% retención"-(rstExencion."% exención"*rstConfiguracionRetencion."% retención")/100))
                                                (rstConfiguracionRetencion."% retencion" - (rstExencion."% exención" *
                                                fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                ) / 100))
                                                / 100) - rstFacturaBufferRT2."Importe retenciones anteriores"))));
                                                rstFacturaBufferRT2.Excluido := 2;
                                                rstFacturaBufferRT2."% Exclusion" := rstExencion."% exención";
                                                rstFacturaBufferRT2."Fecha documento exclusion" := rstExencion."Fecha documento";

                                            end;

                                        rstAccionEstFis."Acción exclusión"::"No aplicar exención":
                                            begin

                                                rstFacturaBufferRT2."Importe retencion" := intFactor * Round(rstConfiguracionRetencion."Importe retencion" +
                                                (((rstFacturaBufferRT2."Base pago retencion" * intFactor + rstFacturaBufferRT2."Pagos anteriores"
                                                - rstConfiguracionRetencion."Importe minimo Stepwise" - rstConfiguracionRetencion."Importe pago minimo") *
                                                //rstConfiguracionRetencion."% retención")/100)-rstFacturaBufferRT2."Importe retenciones anteriores";
                                                fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                ) / 100) - rstFacturaBufferRT2."Importe retenciones anteriores");
                                                rstFacturaBufferRT2.Excluido := 0;
                                                rstFacturaBufferRT2."% Exclusion" := 0;
                                                rstFacturaBufferRT2."Fecha documento exclusion" := 0D;

                                            end;

                                        rstAccionEstFis."Acción exclusión"::"Consultar al usuario":
                                            begin

                                                if Confirm('El proveedor %1 se encuentra observado por la AFIP. ¿Desea proseguir con el pago?'
                                                           , false, rstProveedor.Name) then begin

                                                    rstFacturaBufferRT2."Importe retencion" := intFactor * Round((((rstConfiguracionRetencion."Importe retencion" +
                                                    (((rstFacturaBufferRT2."Base pago retencion" * intFactor + rstFacturaBufferRT2."Pagos anteriores"
                                                    - rstConfiguracionRetencion."Importe minimo Stepwise") *
                                                    //(rstConfiguracionRetencion."% retención"-(rstExencion."% exención"*rstConfiguracionRetencion."% retención")/100))
                                                    (rstConfiguracionRetencion."% retencion" - (rstExencion."% exención" *
                                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                    ) / 100))
                                                    / 100) - rstFacturaBufferRT2."Importe retenciones anteriores"))));
                                                    rstFacturaBufferRT2.Excluido := 2;
                                                    rstFacturaBufferRT2."% Exclusion" := rstExencion."% exención";
                                                    rstFacturaBufferRT2."Fecha documento exclusion" := rstExencion."Fecha documento";

                                                end
                                                else begin

                                                    rstFacturaBufferRT2."Importe retencion" := intFactor * Round((rstConfiguracionRetencion."Importe retencion" +
                                                    (((rstFacturaBufferRT2."Base pago retencion" * intFactor + rstFacturaBufferRT2."Pagos anteriores"
                                                    - rstConfiguracionRetencion."Importe minimo Stepwise") *
                                                    //rstConfiguracionRetencion."% retención")/100))-rstFacturaBufferRT2."Importe retenciones anteriores";
                                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                    ) / 100)) - rstFacturaBufferRT2."Importe retenciones anteriores");
                                                    rstFacturaBufferRT2.Excluido := 0;
                                                    rstFacturaBufferRT2."% Exclusion" := 0;
                                                    rstFacturaBufferRT2."Fecha documento exclusion" := 0D;

                                                end;

                                            end
                                        else begin

                                            rstFacturaBufferRT2."Importe retencion" := intFactor * Round((rstConfiguracionRetencion."Importe retencion" +
                                            (((rstFacturaBufferRT2."Base pago retencion" * intFactor + rstFacturaBufferRT2."Pagos anteriores"
                                            - rstConfiguracionRetencion."Importe minimo Stepwise") *
                                            //rstConfiguracionRetencion."% retención")/100))-rstFacturaBufferRT2."Importe retenciones anteriores";
                                            fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                            ) / 100)) - rstFacturaBufferRT2."Importe retenciones anteriores");
                                            rstFacturaBufferRT2.Excluido := 0;
                                            rstFacturaBufferRT2."% Exclusion" := 0;
                                            rstFacturaBufferRT2."Fecha documento exclusion" := 0D;

                                        end;

                                    end;

                                end
                                else begin

                                    Clear(rstExencion);
                                    rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                                    rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::Ganancias);
                                    if rstExencion.FindLast and (not rstConfiguracionRetencion."Skip exclusions") and (rstExencion."Fecha efectividad retencion" < Today) and
                                    //Se agrega la excepción en caso de actividades de la RG3594
                                    (not rstCodigosRetencion."Verificar registro RG3594")
                                    then

                                        /*ERROR('El certificado de Exención del proveedor %1, %2, ha vencido. \'+
                                        'Por favor, actualice el certificado, o elimínelo de la configuración del proveedor.',
                                        ",rstProveedor.Name)*/
                                              fntConfirmaExencionAntigua(rstExencion, rstProveedor);
                                    //ELSE
                                    begin

                                        case rstTFiscal."Tipo cálculo acumulado" of

                                            rstTFiscal."Tipo cálculo acumulado"::" ",
                                          rstTFiscal."Tipo cálculo acumulado"::Mensual:
                                                rstFacturaBufferRT2."Importe retencion" := intFactor * Round(rstConfiguracionRetencion."Importe retencion" +
                                                (((rstFacturaBufferRT2."Base pago retencion" * intFactor + rstFacturaBufferRT2."Pagos anteriores"
                                                - rstConfiguracionRetencion."Importe minimo Stepwise" - rstConfiguracionRetencion."Importe pago minimo") *
                                                ((rstConfiguracionRetencion."% retencion" / 100)) - rstFacturaBufferRT2."Importe retenciones anteriores")), 0.01);
                                            rstTFiscal."Tipo cálculo acumulado"::"11 meses":
                                                rstFacturaBufferRT2."Importe retencion" :=
                                                Round((rstFacturaBufferRT2."Base pago retencion" *
                                                (rstConfiguracionRetencion."% retencion" / 100)), 0.01);

                                        end;

                                        rstFacturaBufferRT2."% retencion" := rstConfiguracionRetencion."% retencion";

                                        if rstCodigosRetencion."Verificar registro RG3594" then begin
                                            case rstConfiguracionRetencion."% retencion" of
                                                2:
                                                    rstFacturaBufferRT2."Cod. sicore" := 828;
                                                10:
                                                    rstFacturaBufferRT2."Cod. sicore" := 829;
                                                35:
                                                    rstFacturaBufferRT2."Cod. sicore" := 830;
                                            end;
                                        end
                                        else
                                            Evaluate(rstFacturaBufferRT2."Cod. sicore", rstCodigosRetencion."Codigo SICORE");

                                        if rstFacturaBufferRT2."Importe retencion" < rstConfiguracionRetencion."Importe min. retencion" then begin

                                            rstFacturaBufferRT2.Excluido := 3;
                                            rstFacturaBufferRT2.Modify;

                                        end
                                        else begin

                                            rstFacturaBufferRT2.Excluido := 0;
                                            rstFacturaBufferRT2."% Exclusion" := 0;
                                            rstFacturaBufferRT2."Fecha documento exclusion" := 0D;

                                        end;

                                    end;

                                end;

                            end
                            else begin

                                rstFacturaBufferRT2.Excluido := 3;
                                rstFacturaBufferRT2.Modify;

                            end;

                        end;

                    end
                    else begin

                        Clear(rstConfiguracionRetencion);
                        decImportePagoPorConcepto := 0;
                        decImportePagoPorConcepto := rstFacturaBufferRT2."Base pago retencion"; //CalcularImporteEstePagoPGcias(rstLinDiaGen,rstFacturaBufferRT2."Cod. retencion");
                        rstConfiguracionRetencion.SetRange(rstConfiguracionRetencion."Tipo retenciones",
                        rstConfiguracionRetencion."Tipo retenciones"::Ganancias);
                        rstConfiguracionRetencion.SetRange("Cod. retencion", rstCodigosRetencion."Cod. retencion");
                        rstConfiguracionRetencion.SetRange("Tipo fiscal", rstFacturaBufferRT2."Tipo fiscal");
                        rstConfiguracionRetencion.SetRange("Importe pago minimo", 0, Abs(decImportePagoPorConcepto)
                        + rstFacturaBufferRT2."Pagos anteriores");
                        //rstConfiguracionRetencion.SETRANGE("Importe min. retención",0,rstConfiguracionRetencion."Importe retención");

                        rstProveedor.Get(rstFacturaBufferRT2."Cliente/Proveedor");

                        Clear(rstConfCont);
                        rstConfCont.Get();

                        Clear(rstTFiscal);
                        rstTFiscal.Get(rstFacturaBufferRT2."Tipo fiscal");

                        case rstTFiscal."Tipo cálculo acumulado" of

                            rstTFiscal."Tipo cálculo acumulado"::" ",
                            rstTFiscal."Tipo cálculo acumulado"::Mensual:
                                begin

                                    if rstConfiguracionRetencion.FindFirst then begin

                                        rstConfiguracionRetencion.SetRange("Importe min. retencion", 0, decImportePagoPorConcepto +
                                        rstFacturaBufferRT2."Pagos anteriores" - rstConfiguracionRetencion."Importe pago minimo");
                                        if rstConfiguracionRetencion.FindFirst then begin
                                            rstFacturaBufferRT2."Importe minimo pago" := rstConfiguracionRetencion."Importe pago minimo";
                                            rstFacturaBufferRT2."Importe minimo retención" := rstConfiguracionRetencion."Importe min. retencion";
                                            Clear(rstExencion);
                                            rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                                            rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::Ganancias);
                                            rstExencion.SetFilter("Fecha documento", '<=%1', rstLinDiaGen."Posting Date");
                                            rstExencion.SetFilter("Fecha efectividad retencion", '>=%1', rstLinDiaGen."Posting Date");
                                            if rstExencion.FindLast and (not rstConfiguracionRetencion."Skip exclusions") then begin

                                                Clear(rstAccionEstFis);
                                                rstAccionEstFis.Get(rstProveedor."Estado de situación fiscal");
                                                case rstAccionEstFis."Acción exclusión" of

                                                    rstAccionEstFis."Acción exclusión"::"Aplicar exención":
                                                        begin

                                                            rstFacturaBufferRT2."Importe retencion" := intFactor * Round((((rstConfiguracionRetencion."Importe retencion" +
                                                            ((decImportePagoPorConcepto + rstFacturaBufferRT2."Pagos anteriores"
                                                            - rstConfiguracionRetencion."Importe pago minimo") *
                                                            (rstConfiguracionRetencion."% retencion" - (rstExencion."% exención" * rstConfiguracionRetencion."% retencion") / 100)
                                                            / 100))) - rstFacturaBufferRT2."Importe retenciones anteriores"), 0.01);
                                                            rstFacturaBufferRT2.Excluido := 2;
                                                            rstFacturaBufferRT2."% Exclusion" := rstExencion."% exención";
                                                            rstFacturaBufferRT2."Fecha documento exclusion" := rstExencion."Fecha documento";

                                                        end;

                                                    rstAccionEstFis."Acción exclusión"::"No aplicar exención":
                                                        begin

                                                            rstFacturaBufferRT2."Importe retencion" := intFactor * Round((rstConfiguracionRetencion."Importe retencion" +
                                                            (((decImportePagoPorConcepto + rstFacturaBufferRT2."Pagos anteriores"
                                                            - rstConfiguracionRetencion."Importe pago minimo") *
                                                            //rstConfiguracionRetencion."% retención")/100))-rstFacturaBufferRT2."Importe retenciones anteriores";
                                                            fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                            ) / 100)) - rstFacturaBufferRT2."Importe retenciones anteriores");
                                                            rstFacturaBufferRT2.Excluido := 0;
                                                            rstFacturaBufferRT2."% Exclusion" := 0;
                                                            rstFacturaBufferRT2."Fecha documento exclusion" := 0D;

                                                        end;

                                                    rstAccionEstFis."Acción exclusión"::"Consultar al usuario":
                                                        begin

                                                            if Confirm('El proveedor %1 posee un Certificado de Exclusión de situación %2 por un %3 por ciento.\' +
                                                                       '¿Desea aplicarlo en este pago?', false, rstProveedor.Name,
                                                                        rstProveedor."Estado de situación fiscal", rstExencion."% exención") then begin

                                                                rstFacturaBufferRT2."Importe retencion" := intFactor * Round((((rstConfiguracionRetencion."Importe retencion" +
                                                                ((decImportePagoPorConcepto + rstFacturaBufferRT2."Pagos anteriores"
                                                                - rstConfiguracionRetencion."Importe pago minimo") *
                                                                (rstConfiguracionRetencion."% retencion" - (rstExencion."% exención" * rstConfiguracionRetencion."% retencion") /
                                                                100) / 100))) - rstFacturaBufferRT2."Importe retenciones anteriores"), 0.01);
                                                                rstFacturaBufferRT2.Excluido := 2;
                                                                rstFacturaBufferRT2."% Exclusion" := rstExencion."% exención";
                                                                rstFacturaBufferRT2."Fecha documento exclusion" := rstExencion."Fecha documento";

                                                            end
                                                            else begin

                                                                rstFacturaBufferRT2."Importe retencion" := intFactor * Round((rstConfiguracionRetencion."Importe retencion" +
                                                                (((decImportePagoPorConcepto - rstFacturaBufferRT2."Pagos anteriores"
                                                                - rstConfiguracionRetencion."Importe pago minimo") *
                                                                rstConfiguracionRetencion."% retencion") / 100)) - rstFacturaBufferRT2."Importe retenciones anteriores", 0.01);
                                                                rstFacturaBufferRT2.Excluido := 2;
                                                                rstFacturaBufferRT2."% Exclusion" := rstExencion."% exención";
                                                                rstFacturaBufferRT2."Fecha documento exclusion" := rstExencion."Fecha documento";

                                                            end;

                                                        end;

                                                end;

                                            end
                                            else begin

                                                Clear(rstExencion);
                                                rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                                                rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::Ganancias);
                                                if rstExencion.FindLast and (not rstConfiguracionRetencion."Skip exclusions") and (rstExencion."Fecha efectividad retencion" < Today) then
                                                    /*ERROR('El certificado de Exención del proveedor %1, %2, ha vencido. \'+
                                                    'Por favor, actualice el certificado, o elimínelo de la configuración del proveedor.',
                                                    ",rstProveedor.Name)*/
                                              fntConfirmaExencionAntigua(rstExencion, rstProveedor);
                                                //ELSE
                                                begin

                                                    rstFacturaBufferRT2."Importe retencion" := intFactor * Round((rstConfiguracionRetencion."Importe retencion" +
                                                    (((decImportePagoPorConcepto + rstFacturaBufferRT2."Pagos anteriores"
                                                    - rstConfiguracionRetencion."Importe pago minimo") *
                                                    rstConfiguracionRetencion."% retencion") / 100)) - rstFacturaBufferRT2."Importe retenciones anteriores", 0.01);
                                                    rstFacturaBufferRT2.Excluido := 0;
                                                    rstFacturaBufferRT2."% Exclusion" := 0;
                                                    rstFacturaBufferRT2."Fecha documento exclusion" := 0D;

                                                end;

                                            end;

                                        end
                                        else
                                            if rstConfiguracionRetencion."Importe pago minimo" > decImportePagoPorConcepto then
                                                intMotivoExclusion := 3;

                                    end
                                    else begin

                                        rstFacturaBufferRT2."Importe retencion" := 0;
                                        rstFacturaBufferRT2."% retencion" := rstConfiguracionRetencion."% retencion";
                                        rstFacturaBufferRT2.Excluido := 3;
                                        rstFacturaBufferRT2."% Exclusion" := rstExencion."% exención";

                                    end;

                                    rstFacturaBufferRT2."% retencion" := rstConfiguracionRetencion."% retencion";
                                    rstFacturaBufferRT2.Provincia := rstLinFactura.Area;
                                    rstFacturaBufferRT2."No. serie IVA" := '';
                                    rstFacturaBufferRT2."Fecha factura" := 0D;
                                    if not rstFacturaBufferRT2.Insert then
                                        rstFacturaBufferRT2.Modify;

                                end;

                            rstTFiscal."Tipo cálculo acumulado"::"11 meses":
                                begin

                                    if rstConfiguracionRetencion.FindFirst then begin

                                        rstConfiguracionRetencion.SetRange("Importe min. retencion", 0, decImportePagoPorConcepto +
                                        rstFacturaBufferRT2."Pagos anteriores" - rstConfiguracionRetencion."Importe pago minimo");
                                        if rstConfiguracionRetencion.FindFirst then begin
                                            rstFacturaBufferRT2."Importe minimo pago" := rstConfiguracionRetencion."Importe pago minimo";
                                            rstFacturaBufferRT2."Importe minimo retención" := rstConfiguracionRetencion."Importe min. retencion";
                                            Clear(rstExencion);
                                            rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                                            rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::Ganancias);
                                            rstExencion.SetFilter("Fecha documento", '<=%1', rstLinDiaGen."Posting Date");
                                            rstExencion.SetFilter("Fecha efectividad retencion", '>=%1', rstLinDiaGen."Posting Date");
                                            if rstExencion.FindLast and (not rstConfiguracionRetencion."Skip exclusions") then begin

                                                Clear(rstAccionEstFis);
                                                rstAccionEstFis.Get(rstProveedor."Estado de situación fiscal");
                                                case rstAccionEstFis."Acción exclusión" of

                                                    rstAccionEstFis."Acción exclusión"::"Aplicar exención":
                                                        begin

                                                            rstFacturaBufferRT2."Importe retencion" := intFactor * Round((((rstConfiguracionRetencion."Importe retencion" +
                                                            ((decImportePagoPorConcepto + rstFacturaBufferRT2."Pagos anteriores"
                                                            - rstConfiguracionRetencion."Importe pago minimo") *
                                                            (rstConfiguracionRetencion."% retencion" - (rstExencion."% exención" * rstConfiguracionRetencion."% retencion") / 100)
                                                            / 100))) - rstFacturaBufferRT2."Importe retenciones anteriores"), 0.01);
                                                            rstFacturaBufferRT2.Excluido := 2;
                                                            rstFacturaBufferRT2."% Exclusion" := rstExencion."% exención";
                                                            rstFacturaBufferRT2."Fecha documento exclusion" := rstExencion."Fecha documento";

                                                        end;

                                                    rstAccionEstFis."Acción exclusión"::"No aplicar exención":
                                                        begin

                                                            rstFacturaBufferRT2."Importe retencion" := intFactor * Round((rstConfiguracionRetencion."Importe retencion" +
                                                            (((decImportePagoPorConcepto + rstFacturaBufferRT2."Pagos anteriores"
                                                            - rstConfiguracionRetencion."Importe pago minimo") *
                                                            //rstConfiguracionRetencion."% retención")/100))-rstFacturaBufferRT2."Importe retenciones anteriores";
                                                            fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                            ) / 100)) - rstFacturaBufferRT2."Importe retenciones anteriores");
                                                            rstFacturaBufferRT2.Excluido := 0;
                                                            rstFacturaBufferRT2."% Exclusion" := 0;
                                                            rstFacturaBufferRT2."Fecha documento exclusion" := 0D;

                                                        end;

                                                    rstAccionEstFis."Acción exclusión"::"Consultar al usuario":
                                                        begin

                                                            if Confirm('El proveedor %1 posee un Certificado de Exclusión de situación %2 por un %3 por ciento.\' +
                                                                       '¿Desea aplicarlo en este pago?', false, rstProveedor.Name,
                                                                        rstProveedor."Estado de situación fiscal", rstExencion."% exención") then begin

                                                                rstFacturaBufferRT2."Importe retencion" := intFactor * Round((((rstConfiguracionRetencion."Importe retencion" +
                                                                ((decImportePagoPorConcepto + rstFacturaBufferRT2."Pagos anteriores"
                                                                - rstConfiguracionRetencion."Importe pago minimo") *
                                                                (rstConfiguracionRetencion."% retencion" - (rstExencion."% exención" * rstConfiguracionRetencion."% retencion") /
                                                                100) / 100))) - rstFacturaBufferRT2."Importe retenciones anteriores"), 0.01);
                                                                rstFacturaBufferRT2.Excluido := 2;
                                                                rstFacturaBufferRT2."% Exclusion" := rstExencion."% exención";
                                                                rstFacturaBufferRT2."Fecha documento exclusion" := rstExencion."Fecha documento";

                                                            end
                                                            else begin

                                                                rstFacturaBufferRT2."Importe retencion" := intFactor * Round((rstConfiguracionRetencion."Importe retencion" +
                                                                (((decImportePagoPorConcepto - rstFacturaBufferRT2."Pagos anteriores"
                                                                - rstConfiguracionRetencion."Importe pago minimo") *
                                                                //rstConfiguracionRetencion."% retención")/100))-rstFacturaBufferRT2."Importe retenciones anteriores";
                                                                fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                                ) / 100)) - rstFacturaBufferRT2."Importe retenciones anteriores");
                                                                rstFacturaBufferRT2.Excluido := 2;
                                                                rstFacturaBufferRT2."% Exclusion" := rstExencion."% exención";
                                                                rstFacturaBufferRT2."Fecha documento exclusion" := rstExencion."Fecha documento";

                                                            end;

                                                        end;

                                                end;

                                            end
                                            else begin

                                                Clear(rstExencion);
                                                rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                                                rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::Ganancias);

                                                if rstExencion.FindLast and (not rstConfiguracionRetencion."Skip exclusions") and (rstExencion."Fecha efectividad retencion" < Today) then
                                                    /*ERROR('El certificado de Exención del proveedor %1, %2, ha vencido. \'+
                                                    'Por favor, actualice el certificado, o elimínelo de la configuración del proveedor.',
                                                    ",rstProveedor.Name)*/
                                                fntConfirmaExencionAntigua(rstExencion, rstProveedor);
                                                //ELSE
                                                begin

                                                    if (rstConfiguracionRetencion."Precio unitario maximo" < rstFacturaBufferRT2."Precio unitario maximo fac.") and
                                                       (rstConfiguracionRetencion."Precio unitario maximo" <> 0) then begin

                                                        rstFacturaBufferRT2."Importe retencion" := intFactor * Round((rstConfiguracionRetencion."Importe retencion" +
                                                        (((decImportePagoPorConcepto + rstFacturaBufferRT2."Pagos anteriores"
                                                        - rstConfiguracionRetencion."Importe pago minimo") *
                                                        //rstConfiguracionRetencion."% retención")/100))-rstFacturaBufferRT2."Importe retenciones anteriores";
                                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                        ) / 100)) - rstFacturaBufferRT2."Importe retenciones anteriores");
                                                        rstFacturaBufferRT2.Excluido := 0;
                                                        rstFacturaBufferRT2."% Exclusion" := 0;
                                                        rstFacturaBufferRT2."Fecha documento exclusion" := 0D;

                                                    end
                                                    else begin

                                                        if rstConfiguracionRetencion."Importe minimo Stepwise" < rstFacturaBufferRT2."Facturacion anterior 12M" then begin

                                                            rstFacturaBufferRT2."Importe retencion" := intFactor * Round((rstConfiguracionRetencion."Importe retencion" +
                                                            (((decImportePagoPorConcepto + rstFacturaBufferRT2."Pagos anteriores"
                                                            - rstConfiguracionRetencion."Importe pago minimo") *
                                                            //rstConfiguracionRetencion."% retención")/100))-rstFacturaBufferRT2."Importe retenciones anteriores";
                                                            fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                            ) / 100)) - rstFacturaBufferRT2."Importe retenciones anteriores");
                                                            rstFacturaBufferRT2.Excluido := 0;
                                                            rstFacturaBufferRT2."% Exclusion" := 0;
                                                            rstFacturaBufferRT2."Fecha documento exclusion" := 0D;

                                                        end;

                                                    end;

                                                end;

                                            end;

                                        end
                                        else
                                            if rstConfiguracionRetencion."Importe pago minimo" > decImportePagoPorConcepto then
                                                intMotivoExclusion := 3;

                                    end
                                    else begin

                                        rstFacturaBufferRT2."Importe retencion" := 0;
                                        rstFacturaBufferRT2."% retencion" := rstConfiguracionRetencion."% retencion";
                                        rstFacturaBufferRT2.Excluido := 3;
                                        rstFacturaBufferRT2."% Exclusion" := rstExencion."% exención";

                                    end;

                                    rstFacturaBufferRT2."% retencion" := rstConfiguracionRetencion."% retencion";
                                    rstFacturaBufferRT2.Provincia := rstLinFactura.Area;
                                    rstFacturaBufferRT2."No. serie IVA" := '';
                                    rstFacturaBufferRT2."Fecha factura" := 0D;
                                    if not rstFacturaBufferRT2.Insert then
                                        rstFacturaBufferRT2.Modify;

                                end;

                        end;

                    end;

                end;
                if not rstFacturaBufferRT2.Insert then
                    rstFacturaBufferRT2.Modify;

            until rstFacturaBufferRT2.Next = 0;

        if not rstFacturaBufferRT2.Insert then
            rstFacturaBufferRT2.Modify;

        //Insertamos el cálculo en el diario de pagos
        CrearDiarioPagosGanancias(rstLinDiaGen, rstFacturaBufferRT2);

    end;

    [Scope('OnPrem')]
    procedure CalcularPagosAnterioresGan(rstLinDiaGen: Record "Gen. Journal Line"; var rstFacturaBufferRTL: Record "Invoice Withholding Buffer")
    var
        rstConfiguracionRetenciones: Record "Withholding setup";
        rstTotalPagos: Record "Invoice Withholding Buffer";
        datInicioMes: Date;
        datFinMes: Date;
        rstFactura: Record "Purch. Inv. Line";
        rstNCredito: Record "Purch. Cr. Memo Line";
        rstPagosBuffer: Record "Invoice Withholding Buffer";
        rstAcumuladoBuffer: Record "Invoice Withholding Buffer";
        rstTipoFiscal: Record "Dimension Value";
        rstCodigoRetGan: Record "Withholding codes";
        rstConfCont: Record "General Ledger Setup";
    begin
        //CalcularPagosAnterioresGan

        datInicioMes := CalcDate('<-CM>', rstLinDiaGen."Posting Date");
        datFinMes := CalcDate('<CM>', rstLinDiaGen."Posting Date");

        rstProveedor.Get(rstLinDiaGen."Account No.");

        Clear(rstCodigoRetGan);
        rstCodigoRetGan.SetFilter("Valid from", '<=%1|%2', rstLinDiaGen."Posting Date", 0D);
        rstCodigoRetGan.SetFilter("Valid to", '>%1|%2', rstLinDiaGen."Posting Date", 0D);
        rstCodigoRetGan.SetRange(rstCodigoRetGan."Tipo impuesto retencion", rstCodigoRetGan."Tipo impuesto retencion"::Ganancias);
        rstCodigoRetGan.SetRange("Cod. retencion", rstFacturaBufferRTL."Cod. retencion");
        if rstCodigoRetGan.FindSet then
            repeat

                Clear(rstConfCont);
                rstConfCont.Get();
                /*
                CLEAR(rstTipoFiscal);
                rstTipoFiscal.SETRANGE("Dimension Code",rstConfCont."Fiscal Type");
                IF rstTipoFiscal.FINDFIRST THEN
                REPEAT
                */
                rstConfiguracionRetenciones.Reset;
                rstConfiguracionRetenciones.SetRange("Tipo retenciones", rstConfiguracionRetenciones."Tipo retenciones"::Ganancias);
                rstConfiguracionRetenciones.SetRange("Cod. retencion", rstCodigoRetGan."Cod. retencion");
                rstConfiguracionRetenciones.SetRange("Tipo fiscal", rstFacturaBufferRTL."Tipo fiscal");
                if rstConfiguracionRetenciones.FindFirst then
                    repeat

                        //Si el código de retención es RG3594, buscar el código correcto por medio de la lógica de registro
                        if rstCodigoRetGan."Verificar registro RG3594" then begin

                            if rstProveedor."Registrado RG3594" = rstProveedor."Registrado RG3594"::Activo then begin
                                rstConfiguracionRetenciones.SetRange("Importe minimo Stepwise");
                                rstConfiguracionRetenciones.SetRange("Registrado RG3594", rstConfiguracionRetenciones."Registrado RG3594"::Activo);
                                if rstConfiguracionRetenciones.FindLast then;
                            end;
                            if rstProveedor."Registrado RG3594" <> rstProveedor."Registrado RG3594"::Activo then begin
                                rstConfiguracionRetenciones.SetRange("Importe minimo Stepwise");
                                rstConfiguracionRetenciones.SetFilter("Registrado RG3594", '<>%1', rstConfiguracionRetenciones."Registrado RG3594"::Activo);
                                if rstConfiguracionRetenciones.FindFirst then;
                            end;

                        end;

                        rstTotalPagos.Reset;
                        rstTotalPagos.SetRange(rstTotalPagos."Tipo registro", rstTotalPagos."Tipo registro"::Compra);
                        rstTotalPagos.SetRange(rstTotalPagos."Cliente/Proveedor", rstLinDiaGen."Account No.");
                        rstTotalPagos.SetRange(rstTotalPagos."Fecha pago", datInicioMes, datFinMes);
                        rstTotalPagos.SetRange(rstTotalPagos."Tipo retencion", rstConfiguracionRetenciones."Tipo retenciones");
                        rstTotalPagos.SetRange(rstTotalPagos."Cod. retencion", rstConfiguracionRetenciones."Cod. retencion");
                        rstTotalPagos.SetRange(rstTotalPagos."Tipo fiscal", rstConfiguracionRetenciones."Tipo fiscal");
                        if rstCodigoRetGan."Stepwise calculation" then
                            rstTotalPagos.SetRange("% retencion", rstConfiguracionRetenciones."% retencion");
                        rstTotalPagos.SetFilter(rstTotalPagos."No. documento", '<>%1', rstLinDiaGen."Document No.");
                        if rstTotalPagos.FindFirst then
                            repeat

                                rstPagosBuffer.SetRange("Tipo registro", rstPagosBuffer."Tipo registro"::Compra);
                                rstPagosBuffer.SetRange("Cliente/Proveedor", rstTotalPagos."Cliente/Proveedor");
                                rstPagosBuffer.SetRange("No. Factura", '');
                                rstPagosBuffer.SetRange("Tipo retencion", rstTotalPagos."Tipo retencion");
                                rstPagosBuffer.SetRange("Cod. retencion", rstTotalPagos."Cod. retencion");
                                rstPagosBuffer.SetRange(rstPagosBuffer."No. documento", rstLinDiaGen."Document No.");
                                if rstPagosBuffer.FindFirst then begin

                                    rstAcumuladoBuffer := rstPagosBuffer;

                                    //CLEAR(rstAcumuladoBuffer);
                                    rstAcumuladoBuffer."Tipo registro" := rstTotalPagos."Tipo registro"::Compra;
                                    rstAcumuladoBuffer."Cliente/Proveedor" := rstTotalPagos."Cliente/Proveedor";
                                    rstAcumuladoBuffer."No. Factura" := '';
                                    rstAcumuladoBuffer."Tipo retencion" := rstTotalPagos."Tipo retencion";
                                    rstAcumuladoBuffer."Cod. retencion" := rstTotalPagos."Cod. retencion";
                                    rstAcumuladoBuffer."No. documento" := rstLinDiaGen."Document No.";
                                    rstAcumuladoBuffer."Tipo fiscal" := rstTotalPagos."Tipo fiscal";

                                    if rstAcumuladoBuffer.Insert then begin

                                        rstAcumuladoBuffer."Fecha pago" := rstLinDiaGen."Posting Date";
                                        rstAcumuladoBuffer."Base pago retencion" := rstLinDiaGen."Amount (LCY)";
                                        rstAcumuladoBuffer."Pagos anteriores" := 0;
                                        rstAcumuladoBuffer."Importe retencion" := 0;
                                        rstAcumuladoBuffer."% retencion" := 0;
                                        rstAcumuladoBuffer.Provincia := '';
                                        rstAcumuladoBuffer."No. serie ganancias" := '';
                                        rstAcumuladoBuffer."No. serie IVA" := '';
                                        rstAcumuladoBuffer."No. serie Ingresos Brutos" := '';
                                        rstAcumuladoBuffer."Fecha factura" := 0D;
                                        rstAcumuladoBuffer.Excluido := 0;
                                        rstAcumuladoBuffer."% Exclusion" := 0;
                                        rstAcumuladoBuffer."Fecha documento exclusion" := 0D;
                                        rstAcumuladoBuffer."Importe neto factura" := 0;
                                        rstAcumuladoBuffer.Nombre := '';
                                        rstAcumuladoBuffer."Importe retencion total" := 0;
                                        rstAcumuladoBuffer."Importe retenciones anteriores" := 0;
                                        rstAcumuladoBuffer.Modify;

                                    end
                                    else begin

                                        rstFacturaBufferRTL."Facturacion anterior 12M" := CalcularFacturaciónAnterior(rstLinDiaGen);
                                        rstFacturaBufferRTL."Fecha pago" := rstLinDiaGen."Posting Date";
                                        rstFacturaBufferRTL."Pagos anteriores" += rstTotalPagos."Base pago retencion";
                                        if rstTotalPagos.Excluido = 0 then begin

                                            if rstTotalPagos.Retenido then begin

                                                rstFacturaBufferRTL."Importe retenciones anteriores" += rstTotalPagos."Importe retencion";

                                            end;

                                        end;

                                        rstFacturaBufferRTL.Modify;

                                    end;

                                end;

                            until rstTotalPagos.Next = 0;

                    until rstConfiguracionRetenciones.Next = 0;

            //  UNTIL rstTipoFiscal.NEXT = 0;

            until rstCodigoRetGan.Next = 0;

        //EXIT;

    end;

    [Scope('OnPrem')]
    procedure CalcularPagosAnterioresIVANC(rstFacturaBuffer: Record "Invoice Withholding Buffer"): Decimal
    var
        rstConfiguracionRetenciones: Record "Withholding setup";
        rstTotalPagos: Record "Invoice Withholding Buffer";
        datInicioMes: Date;
        datFinMes: Date;
        rstFactura: Record "Purch. Inv. Line";
        rstNCredito: Record "Purch. Cr. Memo Line";
        rstPagosBuffer: Record "Invoice Withholding Buffer";
        rstAcumuladoBuffer: Record "Invoice Withholding Buffer";
        decImporte: Decimal;
        rstMovProv: Record "Vendor Ledger Entry";
        rstNCMovProv: Record "Vendor Ledger Entry";
    begin
        //CalcularPagosAnterioresIVA

        Clear(rstNCMovProv);
        rstNCMovProv.SetCurrentKey("Document No.");
        rstNCMovProv.SetRange("Document No.", rstFacturaBuffer."No. Factura");
        if rstNCMovProv.FindFirst then begin

            Clear(rstMovProv);
            rstMovProv.SetCurrentKey(rstMovProv."Closed by Entry No.");
            rstMovProv.SetRange("Closed by Entry No.", rstNCMovProv."Entry No.");
            if rstMovProv.FindSet then
                repeat

                    Clear(rstPagosBuffer);
                    decImporte := 0;
                    rstPagosBuffer.SetCurrentKey(rstPagosBuffer."Cliente/Proveedor", rstPagosBuffer."No. Factura", rstPagosBuffer."Tipo retencion",
                                                 rstPagosBuffer."Cod. retencion", rstPagosBuffer."Tipo fiscal");
                    rstPagosBuffer.SetRange("Cliente/Proveedor", rstFacturaBuffer."Cliente/Proveedor");
                    rstPagosBuffer.SetFilter("No. documento", '<>%1', rstFacturaBuffer."No. documento");
                    rstPagosBuffer.SetRange("No. Factura", rstMovProv."Document No.");
                    rstPagosBuffer.SetRange("Tipo retencion", rstFacturaBuffer."Tipo retencion");
                    rstPagosBuffer.SetRange("Cod. retencion", rstFacturaBuffer."Cod. retencion");
                    rstPagosBuffer.SetRange("Tipo fiscal", rstFacturaBuffer."Tipo fiscal");
                    if rstPagosBuffer.FindFirst then
                        repeat

                            decImporte -= rstPagosBuffer."Importe retencion";

                        until rstPagosBuffer.Next = 0;

                until rstMovProv.Next = 0;

        end;

        exit(decImporte);
    end;

    [Scope('OnPrem')]
    procedure CalcularPrecioUnitarioFac(rstLinDiaGen: Record "Gen. Journal Line"): Decimal
    var
        rstLinFac: Record "Purch. Inv. Line";
        decImporteU: Decimal;
        rstCabFac: Record "Purch. Inv. Header";
    begin
        decImporteU := 0;

        case rstLinDiaGen."Applies-to Doc. Type" of

            rstLinDiaGen."Applies-to Doc. Type"::Invoice:
                begin

                    Clear(rstCabFac);
                    rstCabFac.Get(rstLinDiaGen."Applies-to Doc. No.");

                    Clear(rstLinFac);
                    rstLinFac.SetRange(rstLinFac."Document No.", rstLinDiaGen."Applies-to Doc. No.");
                    if rstLinFac.FindFirst then
                        repeat

                            if rstCabFac."Currency Factor" <> 0 then begin

                                if decImporteU < rstLinFac."Direct Unit Cost" / rstCabFac."Currency Factor" then
                                    decImporteU := rstLinFac."Direct Unit Cost" / rstCabFac."Currency Factor";

                            end
                            else begin

                                if decImporteU < rstLinFac."Direct Unit Cost" then
                                    decImporteU := rstLinFac."Direct Unit Cost";

                            end;

                        until rstLinFac.Next = 0;

                end;

        end;

        exit(decImporteU);
    end;

    [Scope('OnPrem')]
    procedure "CalcularFacturaciónAnterior"(rstLinDiaGen: Record "Gen. Journal Line"): Decimal
    var
        datInicio12M: Date;
        datFin12M: Date;
        rstProv: Record Vendor;
    begin
        datInicio12M := CalcDate('-11M', CalcDate('<-CM>', rstLinDiaGen."Posting Date"));
        datFin12M := rstLinDiaGen."Posting Date";

        Clear(rstProv);
        rstProv.Get(rstLinDiaGen."Account No.");
        rstProv.SetRange("Date Filter", datInicio12M, datFin12M);
        rstProv.SetFilter("Filtro tipo documento", '%1|%2', rstProv."Filtro tipo documento"::Factura,
                                                               rstProv."Filtro tipo documento"::"Nota d/c");
        rstProv.CalcFields("Importe operaciones a fecha");
        exit(rstProv."Importe operaciones a fecha");
    end;

    local procedure CalcularTotalComprobante(strDocumento: Code[20]; strFactura: Code[20]; decFactor: Decimal): Decimal
    var
        rstLinCompra: Record "Purch. Inv. Line";
        rstCabFactura: Record "Purch. Inv. Header";
    begin
        Clear(rstCabFactura);
        rstCabFactura.SetRange("No.", strFactura);
        if rstCabFactura.FindSet then begin

            Clear(rstLinCompra);
            rstLinCompra.SetRange("Document No.", strFactura);
            rstLinCompra.CalcSums("Amount Including VAT");
            if rstCabFactura."Currency Code" <> '' then begin

                //CalcularTotalComprobante
                //rstFacturaBufferRT."Importe total comprobante" += (rstLinFactura."Amount Including VAT")*decTCambioPago;
                exit(rstLinCompra."Amount Including VAT" * decFactor);

            end
            else begin

                exit(rstLinCompra."Amount Including VAT");

            end;

        end;
    end;

    [Scope('OnPrem')]
    procedure CalcularImporteEstePago(rstLinDiaGen: Record "Gen. Journal Line")
    var
        rstLinDiaGenTemp: Record "Gen. Journal Line";
        rstLinDiaGen2: Record "Gen. Journal Line";
        rstHistFac: Record "Purch. Inv. Line";
        rstHistNC: Record "Purch. Cr. Memo Line";
        rstConfCont: Record "General Ledger Setup";
    begin
        //CalcularImporteEstePago

        Clear(rstLinDiaGenTemp);
        decTotalEstePago := 0;
        rstLinDiaGenTemp.SetRange(rstLinDiaGenTemp."Journal Template Name", rstLinDiaGen."Journal Template Name");
        rstLinDiaGenTemp.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
        rstLinDiaGenTemp.SetRange("Document No.", rstLinDiaGen."Document No.");
        rstLinDiaGenTemp.SetFilter("Applies-to Doc. No.", '<>%1', '');
        if rstLinDiaGenTemp.FindFirst then
            repeat

                if rstLinDiaGenTemp."Currency Factor" <> 0 then
                    decTCambioPago := 1 / rstLinDiaGenTemp."Currency Factor"
                else
                    decTCambioPago := 1;
                if decTCambioPago = 0 then
                    decTCambioPago := 1;

                if rstLinDiaGenTemp."Applies-to Doc. Type" = rstLinDiaGenTemp."Applies-to Doc. Type"::Invoice then begin

                    Clear(rstHistFac);
                    rstHistFac.SetCurrentKey(rstHistFac."Document No.");
                    rstHistFac.SetRange(rstHistFac."Document No.", rstLinDiaGenTemp."Applies-to Doc. No.");
                    rstHistFac.SetFilter("Cód. retención ganancias", '<>%1', '');
                    if rstHistFac.FindFirst then
                        //BEGIN
                        repeat

                            //IF decTCambioPago <> 0 THEN
                            //  decTotalEstePago += rstLinDiaGenTemp.Importe*decTCambioPago;
                            if decTCambioPago <> 0 then
                                decTotalEstePago += rstHistFac.Amount * decTCambioPago;

                        until rstHistFac.Next = 0;
                    //END;

                end;

                if rstLinDiaGenTemp."Applies-to Doc. Type" in [rstLinDiaGenTemp."Applies-to Doc. Type"::"Credit Memo",
                     rstLinDiaGenTemp."Applies-to Doc. Type"::" "] then begin

                    Clear(rstHistNC);
                    rstHistNC.SetCurrentKey(rstHistNC."Document No.");
                    rstHistNC.SetRange(rstHistNC."Document No.", rstLinDiaGenTemp."Applies-to Doc. No.");
                    if rstHistNC.FindFirst then
                        //BEGIN
                        repeat

                            //IF decTCambioPago <> 0 THEN
                            //  decTotalEstePago -= rstLinDiaGenTemp.Importe*decTCambioPago;
                            if decTCambioPago <> 0 then
                                decTotalEstePago -= rstHistNC.Amount * decTCambioPago;

                        until rstHistNC.Next = 0;
                    //END;

                end;

            until rstLinDiaGenTemp.Next = 0;

        //Resto el cálculo de retenciones de IVA anteriores

        /*CLEAR(rstTipoImpRetencion);
        IF rstTipoImpRetencion.FINDFIRST THEN
        REPEAT
        
          rstLinDiaGen2.SETRANGE("Journal Template Name",rstLinDiaGen."Journal Template Name");
          rstLinDiaGen2.SETRANGE("Journal Batch Name",rstLinDiaGen."Journal Batch Name");
          rstLinDiaGen2.SETRANGE("Account No.",rstTipoImpRetencion."Cuenta retención");
          IF rstLinDiaGen2.FINDFIRST THEN
          REPEAT
        
            IF rstTipoImpRetencion."Tipo retención" = rstTipoImpRetencion."Tipo retención"::IVA THEN
            BEGIN
        
              decTotalEstePago += rstLinDiaGen2.Importe;
        
            END;
        
          UNTIL rstLinDiaGen2.NEXT = 0;
        
        UNTIL rstTipoImpRetencion.NEXT =0;
        */

    end;

    [Scope('OnPrem')]
    procedure CalcularImporteEstePagoPGcias(rstLinDiaGen: Record "Gen. Journal Line"; codConcepto: Code[20]): Decimal
    var
        rstLinDiaGenTemp: Record "Gen. Journal Line";
        rstLinDiaGen2: Record "Gen. Journal Line";
        rstHistFac: Record "Purch. Inv. Line";
        rstHistNC: Record "Purch. Cr. Memo Line";
        rstConfCont: Record "General Ledger Setup";
    begin
        //CalcularImporteEstePagoPGcias

        Clear(rstLinDiaGenTemp);
        decTotalEstePago := 0;

        rstLinDiaGenTemp.SetRange(rstLinDiaGenTemp."Journal Template Name", rstLinDiaGen."Journal Template Name");
        rstLinDiaGenTemp.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
        rstLinDiaGenTemp.SetRange("Document No.", rstLinDiaGen."Document No.");
        rstLinDiaGenTemp.SetFilter("Applies-to Doc. No.", '<>%1', '');
        if rstLinDiaGenTemp.FindFirst then
            repeat

                if rstLinDiaGenTemp."Currency Factor" <> 0 then
                    decTCambioPago := 1 / rstLinDiaGenTemp."Currency Factor"
                else
                    decTCambioPago := 1;
                if decTCambioPago = 0 then
                    decTCambioPago := 1;

                if rstLinDiaGenTemp."Applies-to Doc. Type" = rstLinDiaGenTemp."Applies-to Doc. Type"::Invoice then begin

                    Clear(rstHistFac);
                    rstHistFac.SetCurrentKey(rstHistFac."Document No.");
                    rstHistFac.SetRange(rstHistFac."Document No.", rstLinDiaGenTemp."Applies-to Doc. No.");
                    rstHistFac.SetRange("Cód. retención ganancias", codConcepto);
                    if rstHistFac.FindFirst then
                        //BEGIN
                        repeat

                            //IF decTCambioPago <> 0 THEN
                            //  decTotalEstePago += rstLinDiaGenTemp.Importe*decTCambioPago;
                            if decTCambioPago <> 0 then
                                decTotalEstePago += rstHistFac.Amount * decTCambioPago;

                        until rstHistFac.Next = 0;
                    //END;

                end;

                if rstLinDiaGenTemp."Applies-to Doc. Type" in [rstLinDiaGenTemp."Applies-to Doc. Type"::"Credit Memo",
                     rstLinDiaGenTemp."Applies-to Doc. Type"::" "] then begin

                    Clear(rstHistNC);
                    rstHistNC.SetCurrentKey(rstHistNC."Document No.");
                    rstHistNC.SetRange(rstHistNC."Document No.", rstLinDiaGenTemp."Applies-to Doc. No.");
                    rstHistNC.SetRange("Cód. retención ganancias", codConcepto);
                    if rstHistNC.FindFirst then
                        //BEGIN
                        repeat

                            //IF decTCambioPago <> 0 THEN
                            //  decTotalEstePago -= rstLinDiaGenTemp.Importe*decTCambioPago;
                            if decTCambioPago <> 0 then
                                decTotalEstePago -= rstHistNC.Amount * decTCambioPago;

                        until rstHistNC.Next = 0;
                    //END;

                end;

            until rstLinDiaGenTemp.Next = 0;

        //Resto el cálculo de retenciones de IVA anteriores

        /*CLEAR(rstTipoImpRetencion);
        IF rstTipoImpRetencion.FINDFIRST THEN
        REPEAT
        
          rstLinDiaGen2.SETRANGE("Journal Template Name",rstLinDiaGen."Journal Template Name");
          rstLinDiaGen2.SETRANGE("Journal Batch Name",rstLinDiaGen."Journal Batch Name");
          rstLinDiaGen2.SETRANGE("Account No.",rstTipoImpRetencion."Cuenta retención");
          IF rstLinDiaGen2.FINDFIRST THEN
          REPEAT
        
            IF rstTipoImpRetencion."Tipo retención" = rstTipoImpRetencion."Tipo retención"::IVA THEN
            BEGIN
        
              decTotalEstePago += rstLinDiaGen2.Importe;
        
            END;
        
          UNTIL rstLinDiaGen2.NEXT = 0;
        
        UNTIL rstTipoImpRetencion.NEXT =0;
        */

        exit(decTotalEstePago);

    end;

    [Scope('OnPrem')]
    procedure CalcularTotalRetenido(strDocumento: Code[20]; strFactura: Code[20])
    var
        rstFacturaRTBufferCalculoTotal: Record "Invoice Withholding Buffer";
    begin
        //CalcularTotalRetenido

        Clear(rstFacturaRTBufferCalculoTotal);
        decTotalRetenido := 0;
        rstFacturaRTBufferCalculoTotal.SetCurrentKey(rstFacturaRTBufferCalculoTotal."No. documento");
        rstFacturaRTBufferCalculoTotal.SetRange(rstFacturaRTBufferCalculoTotal."No. documento", strDocumento);
        rstFacturaRTBufferCalculoTotal.SetRange("No. Factura", strFactura);
        if rstFacturaRTBufferCalculoTotal.FindFirst then
            repeat

                decTotalRetenido += rstFacturaRTBufferCalculoTotal."Importe retencion";

            until rstFacturaRTBufferCalculoTotal.Next = 0;
    end;

    [Scope('OnPrem')]
    procedure CalcularImporteARetenerNC(rstLinNCL: Record "Purch. Cr. Memo Line"; rstLinDiaGenL: Record "Gen. Journal Line"; decImportePagosAnterioresIVAL: Decimal; var rstFacturaBufferRTL: Record "Invoice Withholding Buffer"; rstCabNCL: Record "Purch. Cr. Memo Hdr."): Decimal
    var
        rstCodigosRetencion: Record "Withholding codes";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstExencion: Record "Withholding details";
        rstProveedor: Record Vendor;
        rstAccionEstFis: Record "Acción estado sit. fiscal";
        rstActiv: Record "Actividad AFIP";
        int80or100: Integer;
    begin
        //CalcularImporteARetener

        Clear(rstCodigosRetencion);
        rstProveedor.Get(rstLinNCL."Buy-from Vendor No.");
        rstCodigosRetencion.SetRange("Tipo impuesto retencion", rstCodigosRetencion."Tipo impuesto retencion"::IVA);
        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstLinDiaGenL."Posting Date", 0D);
        rstCodigosRetencion.SetRange("Cod. retencion", rstLinNCL."Cód. retención IVA");
        //IF rstCodigosRetencion.GET(rstCodigosRetencion."Tipo impuesto retencion"::IVA,rstLinFacturaL."Cód. retención IVA") THEN
        if rstCodigosRetencion.FindFirst then begin

            if rstCodigosRetencion."Stepwise calculation" then begin

                if ((rstCodigosRetencion."Valid to" <> 0D) and
                   (rstLinDiaGenL."Posting Date" <= rstCodigosRetencion."Valid to")) or
                   (rstCodigosRetencion."Valid to" = 0D) then begin

                    if decPorcentajeIVA = '' then begin

                        Clear(rstActiv);
                        rstActiv.SetRange("No. actividad", rstLinNCL."Actividad AFIP");
                        if rstActiv.FindFirst then;

                        //Si la actividad no se encuentra entre las comprendidas por la RG3594
                        if (not rstActiv."Actividad registrada en RG3594") /*AND (rstProveedor."Registrado RG3594"=
                                                                        rstProveedor."Registrado RG3594"::" ")*/ then begin

                            Clear(rstAccionEstFis);
                            rstAccionEstFis.Get(rstProveedor."Estado de situación fiscal");
                            case rstAccionEstFis."Acción retención" of

                                rstAccionEstFis."Acción retención"::" ":
                                    begin

                                        decPorcentajeIVA := '';

                                    end;

                                rstAccionEstFis."Acción retención"::"Aplicar 100%":
                                    begin

                                        decPorcentajeIVA := '100';

                                    end;

                                rstAccionEstFis."Acción retención"::"Aplicar 80%ó50%":
                                    begin

                                        decPorcentajeIVA := '80|50';

                                    end;


                                rstAccionEstFis."Acción retención"::"Consultar al usuario":
                                    begin

                                        if not Confirm('El proveedor seleccionado est  clasificado por la AFIP en "Estado de Situación fiscal" no. %1.' +
                                                   'Se recomienda que\' +
                                                 'antes de proseguir con el pago, consulte al responsable el procedimiento a seguir. ðDesea cancelar el pago?',
                                                      true, rstAccionEstFis."Estado de Situación fiscal") then begin

                                            int80or100 := StrMenu('Aplicar 100%,Aplicar 80%ó50%', 1);
                                            if int80or100 = 1 then
                                                decPorcentajeIVA := '100';
                                            if int80or100 = 2 then
                                                decPorcentajeIVA := '80|50';

                                        end
                                        else
                                            Error('Pago cancelado');

                                    end;

                                rstAccionEstFis."Acción retención"::"Consultar al usuario y aplicar el 100%":
                                    begin

                                        if not Confirm('El proveedor seleccionado est  clasificado por la AFIP en "Estado de Situación fiscal" no. %1.' +
                                                   'Se recomienda que\' +
                                                 'antes de proseguir con el pago, consulte al responsable el procedimiento a seguir. ðDesea cancelar el pago?',
                                                      true, rstAccionEstFis."Estado de Situación fiscal") then begin

                                            decPorcentajeIVA := '100';

                                        end
                                        else
                                            Error('Pago cancelado');

                                    end;

                                rstAccionEstFis."Acción retención"::"Consultar al usuario y aplicar el 80%ó50%":
                                    begin

                                        if not Confirm('El proveedor seleccionado est  clasificado por la AFIP en "Estado de Situación fiscal" no. %1.' +
                                                   'Se recomienda que\' +
                                                 'antes de proseguir con el pago, consulte al responsable el procedimiento a seguir. ðDesea cancelar el pago?',
                                                      true, rstAccionEstFis."Estado de Situación fiscal") then begin

                                            decPorcentajeIVA := '80|50';

                                        end
                                        else
                                            Error('Pago cancelado');

                                    end;

                            end;

                        end
                        else begin

                            if rstProveedor."Registrado RG3594" = rstProveedor."Registrado RG3594"::Activo then
                                decPorcentajeIVA := '50';
                            if rstProveedor."Registrado RG3594" = rstProveedor."Registrado RG3594"::" " then
                                decPorcentajeIVA := '100';
                            if rstProveedor."Registrado RG3594" in [rstProveedor."Registrado RG3594"::Suspendido,
                                                                   rstProveedor."Registrado RG3594"::Excluido,
                                                                   rstProveedor."Registrado RG3594"::"Inscripción cancelada"] then begin

                                decPorcentajeIVA := '100';

                            end;

                        end;

                    end
                    else
                        Error('El código de retención ' + rstCodigosRetencion."Cod. retencion" + ', tipo de impuesto ' + Format(rstCodigosRetencion."Tipo impuesto retencion") + ', del documento ' + rstLinDiaGenL."Applies-to Doc. No." + ', no está activo a esta fecha.')

                end;

                Clear(rstConfiguracionRetencion);
                rstConfiguracionRetencion.SetRange(rstConfiguracionRetencion."Tipo retenciones",
                rstConfiguracionRetencion."Tipo retenciones"::IVA);
                rstConfiguracionRetencion.SetRange(rstConfiguracionRetencion."Cod. retencion", rstLinNCL."Cód. retención IVA");
                rstConfiguracionRetencion.SetRange("Tipo fiscal", rstFacturaBufferRTL."Tipo fiscal");
                if decPorcentajeIVA <> '' then
                    rstConfiguracionRetencion.SetFilter("Porcentaje de IVA", decPorcentajeIVA);

                case rstCodigosRetencion."Base cálculo stepwise" of
                    rstCodigosRetencion."Base cálculo stepwise"::"Neto factura":
                        rstConfiguracionRetencion.SetRange("Importe minimo Stepwise", 0, Abs(rstFacturaBufferRTL."Importe neto factura"));
                    rstCodigosRetencion."Base cálculo stepwise"::"Total factura":
                        rstConfiguracionRetencion.SetRange("Importe minimo Stepwise", 0, Abs(rstFacturaBufferRTL."Importe total comprobante"));
                end;
                /*
                rstConfiguracionRetencion.SETRANGE("Importe minimo Stepwise",0,ABS(rstFacturaBufferRTL."Importe neto factura"));
                */
                if rstConfiguracionRetencion.FindLast then begin

                    //Si el proveedor tiene algún certificado de exclusión vigente

                    Clear(rstExencion);
                    rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                    rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::IVA);
                    rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                    //rstExencion.SETFILTER("Fecha efectividad retencion",'>=%1',rstLinDiaGenL."Posting Date");

                    //Se agrega la excepción en caso de actividades de la RG3594
                    //IF rstExencion.FINDLAST THEN
                    begin

                        //Si el proveedor tiene un certificado de exclusión vigente, evalúo el Estado de Situación fiscal del proveedor
                        //antes de aplicar el porcentaje de exclusión

                        Clear(rstAccionEstFis);
                        rstAccionEstFis.Get(rstProveedor."Estado de situación fiscal");
                        case rstAccionEstFis."Acción exclusión" of

                            rstAccionEstFis."Acción exclusión"::"Aplicar exención":
                                begin

                                    rstFacturaBufferRTL."Importe retencion" := (((rstFacturaBufferRTL."Importe neto factura" *
                                    //rstConfiguracionRetencion."% retención")/100)*((-rstExencion."% exención"+100)/100))-
                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                    ) / 100) * ((-rstExencion."% exención" + 100) / 100)) -
                                    decImportePagosAnterioresIVAL;
                                    rstFacturaBufferRTL.Excluido := 2;
                                    rstFacturaBufferRTL."% Exclusion" := rstExencion."% exención";
                                    rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";

                                end;

                            rstAccionEstFis."Acción exclusión"::"No aplicar exención":
                                begin

                                    rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                    //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                    ) / 100) - decImportePagosAnterioresIVAL;
                                    rstFacturaBufferRTL.Excluido := 0;
                                    rstFacturaBufferRTL."% Exclusion" := 0;
                                    rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                end;

                            rstAccionEstFis."Acción exclusión"::"Consultar al usuario":
                                begin

                                    if Confirm('El proveedor %1 posee un Certificado de Exclusión de situación %2 por un %3 por ciento.\' +
                                      '¿Desea aplicarlo en este pago?', false, rstProveedor.Name,
                                      rstProveedor."Estado de situación fiscal", rstExencion."% exención") then begin

                                        rstFacturaBufferRTL."Importe retencion" := (((rstFacturaBufferRTL."Importe neto factura" *
                                        //rstConfiguracionRetencion."% retención")/100)*((-rstExencion."% exención"+100)/100))-
                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                        ) / 100) * ((-rstExencion."% exención" + 100) / 100)) -
                                        decImportePagosAnterioresIVAL;
                                        rstFacturaBufferRTL.Excluido := 2;
                                        rstFacturaBufferRTL."% Exclusion" := rstExencion."% exención";
                                        rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";

                                    end
                                    else begin

                                        rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                        //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                        ) / 100) - decImportePagosAnterioresIVAL;
                                        rstFacturaBufferRTL.Excluido := 0;
                                        rstFacturaBufferRTL."% Exclusion" := 0;
                                        rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                    end;
                                end;
                        end;
                    end
                    else begin

                        //Si la fecha del certificado de exclusión es anterior a la fecha del pago

                        Clear(rstExencion);
                        rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                        rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::IVA);
                        //rstExencion.SETFILTER("Fecha efectividad retencion",'>=%1|%2',rstLinDiaGenL."Posting Date",0D);
                        rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                        rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                        if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) and
                        //IF rstExencion.FINDLAST AND (rstExencion."Fecha efectividad retencion" < rstLinDiaGenL."Posting Date") AND
                        //Se agrega la excepción en caso de actividades de la RG3594
                        (not rstCodigosRetencion."Verificar registro RG3594")
                        then
                            /*ERROR('El certificado de Exención del proveedor %1, %2, ha vencido. \'+
                            'Por favor, actualice el certificado, o elimínelo de la configuración del proveedor.',
                            ",rstProveedor.Name)*/
                                          fntConfirmaExencionAntigua(rstExencion, rstProveedor)
                        else begin

                            if rstCodigosRetencion."Verificar registro RG3594" then begin
                                case rstConfiguracionRetencion."Porcentaje de IVA" of
                                    50:
                                        rstFacturaBufferRTL."Cod. sicore" := 826;
                                    100:
                                        rstFacturaBufferRTL."Cod. sicore" := 827;
                                end;
                            end
                            else
                                Evaluate(rstFacturaBufferRTL."Cod. sicore", rstCodigosRetencion."Codigo SICORE");

                            rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                            //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                            fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                            ) / 100) - decImportePagosAnterioresIVAL;
                            rstFacturaBufferRTL.Excluido := 0;
                            rstFacturaBufferRTL."% Exclusion" := 0;
                            rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                        end;
                    end;
                    Clear(rstExencion);
                    rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                    rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::"Agente de retención IVA");
                    rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    if (not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent") then begin
                        rstFacturaBufferRTL."Importe retencion" := 0;
                        rstFacturaBufferRTL.Excluido := 6;
                        rstFacturaBufferRTL."% Exclusion" := 100;
                        rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";
                    end;
                end
                else begin

                    //Almaceno en el buffer de retenciones el motivo de la exclusión para esta factura

                    rstFacturaBufferRTL.Excluido := 3;
                    rstFacturaBufferRTL.Modify;

                end;
            end
            else begin

                //Si el cálculo de ese código de retención no es stepwise

                Clear(rstConfiguracionRetencion);
                rstConfiguracionRetencion.SetRange("Tipo retenciones", rstConfiguracionRetencion."Tipo retenciones"::IVA);
                rstConfiguracionRetencion.SetRange("Cod. retencion", rstLinNCL."Cód. retención IVA");
                rstConfiguracionRetencion.SetRange("Tipo fiscal", rstFacturaBufferRTL."Tipo fiscal");
                if rstConfiguracionRetencion.FindFirst then begin

                    //Si el proveedor tiene un certificado de exclusión vigente

                    Clear(rstExencion);
                    rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                    rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::IVA);
                    rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                    //rstExencion.SETFILTER("Fecha efectividad retencion",'>=%1',rstLinDiaGenL."Posting Date");
                    //IF rstExencion.FINDLAST THEN
                    begin

                        //Si tiene certificado de exclusión, me fijo en el estado de situación fiscal

                        Clear(rstAccionEstFis);
                        rstAccionEstFis.Get(rstProveedor."Estado de situación fiscal");
                        case rstAccionEstFis."Acción exclusión" of

                            rstAccionEstFis."Acción exclusión"::"Aplicar exención":
                                begin

                                    rstFacturaBufferRTL."Importe retencion" := (((rstFacturaBufferRTL."Importe neto factura" *
                                    //rstConfiguracionRetencion."% retención")/100)*((-rstExencion."% exención"+100)/100))-
                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                    ) / 100) * ((-rstExencion."% exención" + 100) / 100)) -
                                    decImportePagosAnterioresIVAL;
                                    rstFacturaBufferRTL.Excluido := 2;
                                    rstFacturaBufferRTL."% Exclusion" := rstExencion."% exención";
                                    rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";

                                end;

                            rstAccionEstFis."Acción exclusión"::"No aplicar exención":
                                begin

                                    rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                    //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                    ) / 100) - decImportePagosAnterioresIVAL;
                                    rstFacturaBufferRTL.Excluido := 0;
                                    rstFacturaBufferRTL."% Exclusion" := 0;
                                    rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                end;

                            rstAccionEstFis."Acción exclusión"::"Consultar al usuario":
                                begin

                                    if Confirm('El proveedor %1 posee un Certificado de Exclusión de situación %2 por un %3 por ciento.\' +
                                               '¿Desea aplicarlo en este pago?', false, rstProveedor.Name,
                                                rstProveedor."Estado de situación fiscal", rstExencion."% exención") then begin

                                        rstFacturaBufferRTL."Importe retencion" := (((rstFacturaBufferRTL."Importe neto factura" *
                                        //rstConfiguracionRetencion."% retención")/100)*((-rstExencion."% exención"+100)/100))-
                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                        ) / 100) * ((-rstExencion."% exención" + 100) / 100)) -
                                        decImportePagosAnterioresIVAL;
                                        rstFacturaBufferRTL.Excluido := 2;
                                        rstFacturaBufferRTL."% Exclusion" := rstExencion."% exención";
                                        rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";

                                    end
                                    else begin

                                        rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                        //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                        ) / 100) - decImportePagosAnterioresIVAL;
                                        rstFacturaBufferRTL.Excluido := 0;
                                        rstFacturaBufferRTL."% Exclusion" := 0;
                                        rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                    end;
                                end;
                        end;

                    end
                    else begin

                        Clear(rstExencion);
                        rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                        rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::IVA);
                        //rstExencion.SETFILTER("Fecha efectividad retencion",'>=%1|%2',rstLinDiaGenL."Posting Date",0D);
                        rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                        rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                        if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                            //IF rstExencion.FINDLAST AND (rstExencion."Fecha efectividad retencion" < rstLinDiaGenL."Posting Date") THEN
                            /*ERROR('El certificado de Exención del proveedor %1, %2, ha vencido. \'+
                            'Por favor, actualice el certificado, o elimínelo de la configuración del proveedor.',
                            ",rstProveedor.Name)*/
                                          fntConfirmaExencionAntigua(rstExencion, rstProveedor)

                        else begin

                            rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                            //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                            fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                            ) / 100) - decImportePagosAnterioresIVAL;
                            rstFacturaBufferRTL.Excluido := 0;
                            rstFacturaBufferRTL."% Exclusion" := 0;
                            rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                        end;
                    end;
                end;
            end;
        end;

        rstFacturaBufferRTL."% retencion" := rstConfiguracionRetencion."% retencion" / 100 * rstConfiguracionRetencion."Porcentaje de IVA";
        rstFacturaBufferRTL.Provincia := rstLinNCL.Area;
        rstFacturaBufferRTL."No. serie IVA" := '';
        rstFacturaBufferRTL."Fecha factura" := rstCabNCL."Document Date";
        if not rstFacturaBufferRTL.Insert then
            rstFacturaBufferRTL.Modify;

        decPorcentajeIVA := '';

    end;

    [Scope('OnPrem')]
    procedure CrearDiarioPagosGanancias(var rstLinDiaGen: Record "Gen. Journal Line"; var rstFacturaBufferRT: Record "Invoice Withholding Buffer")
    var
        rstHisCFacComp: Record "Purch. Inv. Header";
        intMotivoExclusion: Integer;
        rstCodigosRetencion: Record "Withholding codes";
        rstFacturaBufferRT2: Record "Invoice Withholding Buffer";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstLinDiaGen2: Record "Gen. Journal Line";
        rstLinDiaGenTemp: Record "Gen. Journal Line";
        rstConfCont: Record "General Ledger Setup";
        rstHisCNC: Record "Purch. Cr. Memo Hdr.";
        intFactor: Integer;
    begin
        //CrearDiarioPagosGanancias

        CalcularTotalRetenido(rstLinDiaGen."Document No.", '');
        Clear(rstFacturaBufferRT);
        rstFacturaBufferRT.SetCurrentKey(rstFacturaBufferRT."No. documento");
        rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstLinDiaGen."Document No.");
        rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::Ganancias);
        rstFacturaBufferRT.SetFilter("Importe retencion", '<>0');
        if rstFacturaBufferRT.FindFirst then
            repeat

                if rstFacturaBufferRT."Base pago retencion" > 0 then
                    intFactor := 1
                else
                    intFactor := -1;
                rstFacturaBufferRT.CalcFields("Importe minimo retención");
                rstFacturaBufferRT."Importe retencion" := Round(rstFacturaBufferRT."Importe retencion", 0.01);
                if intMotivoExclusion = 0 then begin

                    Clear(rstCodigosRetencion);
                    rstCodigosRetencion.SetRange("Tipo impuesto retencion", rstCodigosRetencion."Tipo impuesto retencion"::Ganancias);
                    rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstLinDiaGen."Posting Date", 0D);
                    rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstLinDiaGen."Posting Date", 0D);
                    rstCodigosRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                    //IF rstCodigosRetencion.GET(rstCodigosRetencion."Tipo impuesto retencion"::IVA,rstLinFacturaL."Cód. retención IVA") THEN
                    if rstCodigosRetencion.FindFirst then begin

                        Clear(rstConfiguracionRetencion);
                        rstConfiguracionRetencion.SetRange(rstConfiguracionRetencion."Tipo retenciones",
                        rstConfiguracionRetencion."Tipo retenciones"::Ganancias);
                        rstConfiguracionRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                        if rstConfiguracionRetencion.FindFirst then begin

                            //IF ABS(decTotalRetenido) >= rstConfiguracionRetencion."Importe min. retención" THEN TeST
                            if rstFacturaBufferRT."Importe minimo retención" <= intFactor * rstFacturaBufferRT."Importe retencion" then begin

                                Clear(rstLinDiaGen2);
                                rstLinDiaGen2.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
                                rstLinDiaGen2.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                                rstLinDiaGen2.SetRange("Document No.", rstLinDiaGen."Document No.");
                                if rstLinDiaGen2.FindLast then;
                                Clear(rstLinDiaGenTemp);
                                rstLinDiaGenTemp."Journal Template Name" := rstLinDiaGen."Journal Template Name";
                                rstLinDiaGenTemp."Journal Batch Name" := rstLinDiaGen."Journal Batch Name";
                                rstLinDiaGenTemp."Posting Date" := rstLinDiaGen."Posting Date";
                                rstLinDiaGenTemp."Posting No. Series" := rstLinDiaGen."Posting No. Series";
                                rstLinDiaGenTemp."Due Date" := Today;
                                rstLinDiaGenTemp."Transaction No." := rstLinDiaGen."Transaction No.";

                                rstLinDiaGenTemp."No. cheque" := rstLinDiaGen."No. cheque";
                                rstLinDiaGenTemp."Document No." := rstLinDiaGen."Document No.";
                                rstLinDiaGenTemp."Line No." := rstLinDiaGen2."Line No." + 1;
                                rstLinDiaGenTemp."Due Date" := rstLinDiaGen."Due Date";
                                rstLinDiaGenTemp."Document Type" := rstLinDiaGenTemp."Document Type"::Payment;
                                rstLinDiaGenTemp."Account Type" := rstLinDiaGenTemp."Account Type"::"G/L Account";
                                //rstLinDiaGenTemp."Account No." := rstTipoImpRetencion."Cuenta retención";

                                Clear(rstConfCont);
                                rstConfCont.Get();

                                case rstFacturaBufferRT."Tipo retencion" of
                                    rstFacturaBufferRT."Tipo retencion"::IVA:
                                        begin

                                            rstLinDiaGenTemp."Account No." := rstConfCont."VAT withholding account";
                                            rstLinDiaGenTemp.Description := CopyStr('Ret. IVA ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            rstLinDiaGenTemp."External Document No." := rstFacturaBufferRT."No. Factura";
                                        end;
                                    rstFacturaBufferRT."Tipo retencion"::Ganancias:
                                        begin
                                            rstLinDiaGenTemp."Account No." := rstConfCont."Winnings withholding account";
                                            rstLinDiaGenTemp.Description := CopyStr('Ret. Gan. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                        end;
                                    rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos":
                                        begin
                                            rstLinDiaGenTemp."Account No." := rstConfCont."GI withholding account";
                                            rstLinDiaGenTemp.Description := CopyStr('Ret. I.B. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                        end;
                                    rstFacturaBufferRT."Tipo retencion"::"Seguridad Social":
                                        begin
                                            Clear(rstConfCont);
                                            rstConfCont.Get();
                                            rstLinDiaGenTemp."Account No." := rstConfCont."SS withholding account";
                                            rstLinDiaGenTemp.Description := CopyStr('Ret. SS. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                        end;
                                end;

                                rstLinDiaGenTemp.Validate("Account No.");
                                if rstLinDiaGenTemp."Shortcut Dimension 1 Code" = '' then
                                    rstLinDiaGenTemp.Validate("Shortcut Dimension 1 Code", rstLinDiaGen."Shortcut Dimension 1 Code");
                                if rstLinDiaGenTemp."Shortcut Dimension 2 Code" = '' then
                                    rstLinDiaGenTemp.Validate("Shortcut Dimension 2 Code", rstLinDiaGen."Shortcut Dimension 2 Code");
                                if rstLinDiaGenTemp."Shortcut Dimension 3 Code" = '' then
                                    rstLinDiaGenTemp.Validate("Shortcut Dimension 3 Code", rstLinDiaGen."Shortcut Dimension 3 Code");
                                if rstLinDiaGenTemp."Shortcut Dimension 4 Code" = '' then
                                    rstLinDiaGenTemp.Validate("Shortcut Dimension 4 Code", rstLinDiaGen."Shortcut Dimension 4 Code");
                                if rstLinDiaGenTemp."Shortcut Dimension 5 Code" = '' then
                                    rstLinDiaGenTemp.Validate("Shortcut Dimension 5 Code", rstLinDiaGen."Shortcut Dimension 5 Code");
                                if rstLinDiaGenTemp."Shortcut Dimension 6 Code" = '' then
                                    rstLinDiaGenTemp.Validate("Shortcut Dimension 6 Code", rstLinDiaGen."Shortcut Dimension 6 Code");
                                if rstLinDiaGenTemp."Shortcut Dimension 7 Code" = '' then
                                    rstLinDiaGenTemp.Validate("Shortcut Dimension 7 Code", rstLinDiaGen."Shortcut Dimension 7 Code");

                                rstLinDiaGenTemp.Validate(Amount, -rstFacturaBufferRT."Importe retencion");
                                rstLinDiaGenTemp."Factor divisa operacion" := rstLinDiaGen."Factor divisa operacion";
                                rstLinDiaGenTemp."Valor divisa operacion" := rstLinDiaGen."Valor divisa operacion";
                                rstLinDiaGenTemp.Retención := true;
                                rstFacturaBufferRT.Retenido := true;
                                rstFacturaBufferRT.Modify;

                                if not rstLinDiaGenTemp.Insert then
                                    rstLinDiaGenTemp.Modify;

                            end;

                        end
                        else begin

                            rstFacturaBufferRT.Excluido := 3;
                            rstFacturaBufferRT.Modify;

                        end;
                    end;
                end
                else begin

                    Clear(rstConfiguracionRetencion);
                    rstConfiguracionRetencion.SetRange("Tipo retenciones", rstFacturaBufferRT."Tipo retencion");
                    rstConfiguracionRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                    if rstConfiguracionRetencion.FindFirst then begin

                        if Abs(decTotalRetenido) >= rstConfiguracionRetencion."Importe min. retencion" then begin

                            Clear(rstLinDiaGen2);
                            rstLinDiaGen2.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
                            rstLinDiaGen2.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                            rstLinDiaGen2.SetRange("Document No.", rstLinDiaGen."Document No.");
                            if rstLinDiaGen2.FindLast then;
                            Clear(rstLinDiaGenTemp);
                            rstLinDiaGenTemp."Journal Template Name" := rstLinDiaGen."Journal Template Name";
                            rstLinDiaGenTemp."Journal Batch Name" := rstLinDiaGen."Journal Batch Name";
                            rstLinDiaGenTemp."Posting Date" := rstLinDiaGen."Posting Date";
                            rstLinDiaGenTemp."Posting No. Series" := rstLinDiaGen."Posting No. Series";
                            rstLinDiaGenTemp."Due Date" := Today;
                            rstLinDiaGenTemp."Document No." := rstLinDiaGen."Document No.";
                            rstLinDiaGenTemp."Line No." := rstLinDiaGen2."Line No." + 1;
                            rstLinDiaGenTemp."Due Date" := rstLinDiaGen."Due Date";
                            rstLinDiaGenTemp."Transaction No." := rstLinDiaGen."Transaction No.";
                            rstLinDiaGenTemp."No. cheque" := rstLinDiaGen."No. cheque";
                            rstLinDiaGenTemp."Document Type" := rstLinDiaGenTemp."Document Type"::Payment;
                            rstLinDiaGenTemp."Account Type" := rstLinDiaGenTemp."Account Type"::"G/L Account";
                            Clear(rstConfCont);
                            rstConfCont.Get();

                            case rstFacturaBufferRT."Tipo retencion" of
                                rstFacturaBufferRT."Tipo retencion"::IVA:
                                    begin
                                        rstLinDiaGenTemp."Account No." := rstConfCont."VAT withholding account";
                                        rstLinDiaGenTemp.Description := CopyStr('Ret. IVA ' + rstCodigosRetencion.Descripcion, 1, 50);
                                        rstLinDiaGenTemp."External Document No." := rstFacturaBufferRT."No. Factura";
                                    end;
                                rstFacturaBufferRT."Tipo retencion"::Ganancias:
                                    begin
                                        rstLinDiaGenTemp."Account No." := rstConfCont."Winnings withholding account";
                                        rstLinDiaGenTemp.Description := CopyStr('Ret. Gan. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                    end;
                                rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos":
                                    begin
                                        rstLinDiaGenTemp."Account No." := rstConfCont."GI withholding account";
                                        rstLinDiaGenTemp.Description := CopyStr('Ret. I.B. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                    end;
                                rstFacturaBufferRT."Tipo retencion"::"Seguridad Social":
                                    begin
                                        Clear(rstConfCont);
                                        rstConfCont.Get();
                                        rstLinDiaGenTemp."Account No." := rstConfCont."SS withholding account";
                                        rstLinDiaGenTemp.Description := CopyStr('Ret. SS. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                    end;
                            end;
                            rstLinDiaGenTemp.Validate("Account No.");
                            if rstLinDiaGenTemp."Shortcut Dimension 1 Code" = '' then
                                rstLinDiaGenTemp.Validate("Shortcut Dimension 1 Code", rstLinDiaGen."Shortcut Dimension 1 Code");
                            if rstLinDiaGenTemp."Shortcut Dimension 2 Code" = '' then
                                rstLinDiaGenTemp.Validate("Shortcut Dimension 2 Code", rstLinDiaGen."Shortcut Dimension 2 Code");
                            if rstLinDiaGenTemp."Shortcut Dimension 3 Code" = '' then
                                rstLinDiaGenTemp.Validate("Shortcut Dimension 3 Code", rstLinDiaGen."Shortcut Dimension 3 Code");
                            if rstLinDiaGenTemp."Shortcut Dimension 4 Code" = '' then
                                rstLinDiaGenTemp.Validate("Shortcut Dimension 4 Code", rstLinDiaGen."Shortcut Dimension 4 Code");
                            if rstLinDiaGenTemp."Shortcut Dimension 5 Code" = '' then
                                rstLinDiaGenTemp.Validate("Shortcut Dimension 5 Code", rstLinDiaGen."Shortcut Dimension 5 Code");
                            if rstLinDiaGenTemp."Shortcut Dimension 6 Code" = '' then
                                rstLinDiaGenTemp.Validate("Shortcut Dimension 6 Code", rstLinDiaGen."Shortcut Dimension 6 Code");
                            if rstLinDiaGenTemp."Shortcut Dimension 7 Code" = '' then
                                rstLinDiaGenTemp.Validate("Shortcut Dimension 7 Code", rstLinDiaGen."Shortcut Dimension 7 Code");

                            rstLinDiaGenTemp.Validate(Amount, -rstFacturaBufferRT."Importe retencion");
                            rstLinDiaGenTemp."Factor divisa operacion" := rstLinDiaGen."Factor divisa operacion";
                            rstLinDiaGenTemp."Valor divisa operacion" := rstLinDiaGen."Valor divisa operacion";
                            rstLinDiaGenTemp.Retención := true;
                            rstFacturaBufferRT.Retenido := true;
                            rstFacturaBufferRT.Modify;

                            if not rstLinDiaGenTemp.Insert then
                                rstLinDiaGenTemp.Modify;

                        end
                        else begin

                            rstFacturaBufferRT.Excluido := 3;
                            rstFacturaBufferRT.Modify;

                        end;

                    end;

                    rstFacturaBufferRT.Excluido := intMotivoExclusion;
                    rstFacturaBufferRT.Modify;

                end;

            until rstFacturaBufferRT.Next = 0;
    end;

    [Scope('OnPrem')]
    procedure CalcularRetencionSS(var rstLinDiaGen: Record "Gen. Journal Line"; rstProveedor: Record Vendor)
    var
        rstLinDiaGenTemp: Record "Gen. Journal Line";
        rstCabFactura: Record "Purch. Inv. Header";
        rstLinFactura: Record "Purch. Inv. Line";
        rstFacturaBufferRT: Record "Invoice Withholding Buffer";
        decImportePagosAnterioresIVA: Decimal;
        rstCabNC: Record "Purch. Cr. Memo Hdr.";
        rstLinNC: Record "Purch. Cr. Memo Line";
        rstExencion: Record "Withholding details";
        rstMovIva: Record "VAT Entry";
        rstCodRetencion: Record "Withholding codes";
        cduGestionNoSerie: Codeunit "No. Series";
        rstConfCont: Record "General Ledger Setup";
        codNoSerieCertificado: Code[20];
        blnRetenido: Boolean;
        rstMovProveedor: Record "Vendor Ledger Entry";
        rstMovProveedorFC: Record "Vendor Ledger Entry";
        rstLinDiaGenNCLic: Record "Gen. Journal Line";
        decImpoLiqNC: Decimal;
    begin
        //CalcularRetencionSS

        /*CLEAR(rstCodRetencion);
        rstCodRetencion.SETRANGE(rstCodRetencion."Tipo impuesto retención",rstCodRetencion."Tipo impuesto retención"::"Seguridad Social");
        IF rstCodRetencion.FINDFIRST THEN
        BEGIN
        */
        //Busco el N° de serie del certificado

        //Me fijo qué facturas ha seleccionado el usuario para liquidar en este pago

        rstLinDiaGenTemp.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
        rstLinDiaGenTemp.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
        rstLinDiaGenTemp.SetRange("Document No.", rstLinDiaGen."Document No.");
        rstLinDiaGenTemp.SetFilter("Applies-to Doc. No.", '<>%1', '');

        //Me posiciono en la primera factura a pagar

        if rstLinDiaGenTemp.FindFirst then
            repeat

                //Si el documento es una factura, voy a la línea de la factura, y comienzo a rellenar el buffer de retenciones

                if rstLinDiaGenTemp."Applies-to Doc. Type" = rstLinDiaGenTemp."Applies-to Doc. Type"::Invoice then begin

                    Clear(rstLinFactura);
                    rstLinFactura.SetRange("Document No.", rstLinDiaGenTemp."Applies-to Doc. No.");
                    rstLinFactura.SetFilter("VAT %", '<>0');
                    rstLinFactura.SetFilter("No.", '<>%1', '');
                    if rstLinFactura.FindFirst then
                        repeat

                            Clear(rstCabFactura);
                            rstCabFactura.Get(rstLinFactura."Document No.");

                            Clear(rstFacturaBufferRT);
                            rstFacturaBufferRT.SetRange("Tipo registro", rstFacturaBufferRT."Tipo registro"::Compra);
                            rstFacturaBufferRT.SetRange("Cliente/Proveedor", rstProveedor."No.");
                            rstFacturaBufferRT.SetRange("No. Factura", rstLinFactura."Document No.");
                            rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::"Seguridad Social");
                            rstFacturaBufferRT.SetRange("Cod. retencion", rstLinFactura."Cód. retención SS");
                            rstFacturaBufferRT.SetRange("No. documento", rstLinDiaGen."Document No.");
                            rstFacturaBufferRT.SetRange("Tipo fiscal", rstCabFactura."VAT Bus. Posting Group");
                            //Si esta es la primera vez que se inserta la factura en la tabla, entonces limpio el resto de los campos

                            if not rstFacturaBufferRT.FindFirst then begin

                                rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Compra;
                                rstFacturaBufferRT."Cliente/Proveedor" := rstProveedor."No.";
                                rstFacturaBufferRT."No. Factura" := rstLinFactura."Document No.";
                                rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::"Seguridad Social";
                                rstFacturaBufferRT."Cod. retencion" := rstLinFactura."Cód. retención SS";
                                rstFacturaBufferRT."No. documento" := rstLinDiaGen."Document No.";
                                rstFacturaBufferRT."Tipo fiscal" := rstCabFactura."VAT Bus. Posting Group";
                                rstFacturaBufferRT."Serie retención" := '';
                                rstFacturaBufferRT."Fecha pago" := 0D;
                                rstFacturaBufferRT."Base pago retencion" := 0;
                                rstFacturaBufferRT."Pagos anteriores" := 0;
                                rstFacturaBufferRT."Importe retencion" := 0;
                                rstFacturaBufferRT."% retencion" := 0;
                                rstFacturaBufferRT.Provincia := '';
                                rstFacturaBufferRT."No. serie ganancias" := '';
                                rstFacturaBufferRT."No. serie IVA" := '';
                                rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                                rstFacturaBufferRT."Fecha factura" := 0D;
                                rstFacturaBufferRT.Nombre := '';
                                rstFacturaBufferRT."Importe neto factura" := 0;
                                rstFacturaBufferRT."Factura liquidada" := rstLinFactura."Document No.";
                                rstFacturaBufferRT.Insert;

                            end;

                            rstFacturaBufferRT."Fecha pago" := rstLinDiaGen."Posting Date";


                            //Si la divisa de la factura es diferente a la divisa local, calculo el importe base a retener utilizando el factor
                            //de divisa de la cabecera de compra.
                            //Cambio de lógica. Siempre se paga la factura en pesos, así que utilizo el tipo de cambio por el que se cargó la
                            //factura para el cálculo de las retenciones.

                            //++Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                            decTCambioPago := fntTipoCambioPago(rstLinDiaGenTemp, rstFacturaBufferRT."No. Factura");
                            //--Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                            //IF decTCambioPago <> 0 THEN
                            //IF rstCabFactura."Currency Code" <> '' THEN
                            //BEGIN

                            //decTCambioPago := 0;
                            //decTCambioPago := 1/rstCabFactura."Currency Factor";
                            //decTCambioPago := 1/rstLinDiaGenTemp."Currency Factor";
                            /*
                            IF rstCabFactura."Currency Code" <> '' THEN
                              rstFacturaBufferRT."Importe neto factura"  += (rstLinFactura.Amount)/rstCabFactura."Currency Factor"
                            ELSE
                            */
                            rstFacturaBufferRT."Importe neto factura" += (rstLinFactura.Amount) * decTCambioPago;
                            rstFacturaBufferRT."Base pago retencion" += (rstLinFactura."Amount Including VAT" - rstLinFactura."VAT Base Amount")
                              * decTCambioPago;
                            /*
                        END
                        ELSE
                        BEGIN

                          rstFacturaBufferRT."Importe neto factura"  += (rstLinFactura.Amount);
                          rstFacturaBufferRT."Base pago retencion" += (rstLinFactura."Amount Including VAT"-rstLinFactura."VAT Base Amount");

                        END;
                        */
                            //Calculo los pagos realizados anteriormente sobre ésta factura
                            decImportePagosAnterioresIVA := 0;
                            decImportePagosAnterioresIVA := CalcularPagosAnterioresSS(rstFacturaBufferRT);

                            //Calculo el importe a retener. Para eso, busco la configuración de retenciones correcta
                            CalcularImporteARetenerSS(rstLinFactura, rstLinDiaGen, decImportePagosAnterioresIVA, rstFacturaBufferRT, rstCabFactura);

                        until rstLinFactura.Next = 0;

                end;

                //Si el documento es una Nota de Crédito

                if rstLinDiaGenTemp."Applies-to Doc. Type" = rstLinDiaGenTemp."Applies-to Doc. Type"::"Credit Memo" then begin

                    Clear(rstLinNC);
                    rstLinNC.SetRange("Document No.", rstLinDiaGenTemp."Applies-to Doc. No.");
                    rstLinNC.SetFilter("VAT %", '<>0');
                    rstLinNC.SetFilter("No.", '<>%1', '');
                    if rstLinNC.FindFirst then
                        repeat

                            //US.ARBU - 2005-08-03 - Inicio - Con ésta modificación, se modifica el sistema de cálculo de las NC's para
                            //                                que acumulen sobre el registro de buffer de la factura a que aplican
                            Clear(rstMovProveedor);
                            rstMovProveedor.SetCurrentKey("Vendor No.", rstMovProveedor."Document Type", rstMovProveedor."Document No.");
                            rstMovProveedor.SetRange("Vendor No.", rstLinNC."Buy-from Vendor No.");
                            rstMovProveedor.SetRange("Document Type", rstMovProveedor."Document Type"::"Credit Memo");
                            rstMovProveedor.SetRange("Document No.", rstLinNC."Document No.");
                            if rstMovProveedor.FindFirst then begin

                                rstMovProveedor.CalcFields(Amount, "Remaining Amount", "Amount (LCY)", "Remaining Amt. (LCY)");
                                if rstMovProveedor.Amount <> rstMovProveedor."Remaining Amount" then begin

                                    Clear(rstMovProveedorFC);
                                    rstMovProveedorFC.SetRange(rstMovProveedorFC."Closed by Entry No.", rstMovProveedor."Entry No.");
                                    rstMovProveedorFC.SetRange(Anulado, false);
                                    if rstMovProveedorFC.FindSet then
                                        repeat

                                            rstMovProveedorFC.CalcFields(Amount, rstMovProveedorFC."Remaining Amount", "Amount (LCY)", rstMovProveedorFC."Remaining Amt. (LCY)");

                                            Clear(rstLinDiaGenNCLic);
                                            rstLinDiaGenNCLic.SetRange(rstLinDiaGenNCLic."Journal Template Name", rstLinDiaGen."Journal Template Name");
                                            rstLinDiaGenNCLic.SetRange(rstLinDiaGenNCLic."Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                                            rstLinDiaGenNCLic.SetRange("Document No.", rstLinDiaGen."Document No.");
                                            rstLinDiaGenNCLic.SetRange(rstLinDiaGenNCLic."Applies-to Doc. No.", rstMovProveedorFC."Document No.");
                                            if rstLinDiaGenNCLic.FindFirst then begin

                                                Clear(rstCabNC);
                                                rstCabNC.Get(rstLinNC."Document No.");

                                                decImpoLiqNC := 0;
                                                decImpoLiqNC := rstMovProveedorFC."Purchase (LCY)" / rstMovProveedorFC."Amount (LCY)";

                                                Clear(rstFacturaBufferRT);
                                                rstFacturaBufferRT.SetRange("Tipo registro", rstFacturaBufferRT."Tipo registro"::Compra);
                                                rstFacturaBufferRT.SetRange("Cliente/Proveedor", rstProveedor."No.");
                                                rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. Factura", rstLinNC."Document No.");
                                                rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::"Seguridad Social");
                                                //rstFacturaBufferRT.SETRANGE("Cód. retención",rstCodRetencion."Cód. retención");
                                                rstFacturaBufferRT.SetRange("Cod. retencion", rstLinNC."Cód. retención SS");
                                                rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstLinDiaGen."Document No.");
                                                rstFacturaBufferRT.SetRange("Tipo fiscal", rstCabNC."VAT Bus. Posting Group");
                                                if not rstFacturaBufferRT.FindFirst then begin

                                                    rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Compra;
                                                    rstFacturaBufferRT."Cliente/Proveedor" := rstProveedor."No.";
                                                    //US.ARBU - 2005-08-03 - Inicio - Con ésta modificación, se modifica el sistema de c lculo de las NC's para
                                                    //                                que acumulen sobre el registro de buffer de la factura a que aplican
                                                    //rstFacturaBufferRT."No. Factura" := rstMovProveedorFC."Document no.";
                                                    //US.ARBU - 2005-08-03 - Fin - Con ésta modificación, se modifica el sistema de c lculo de las NC's para
                                                    //                                que acumulen sobre el registro de buffer de la factura a que aplican
                                                    rstFacturaBufferRT."No. Factura" := rstLinNC."Document No.";
                                                    rstFacturaBufferRT."Tipo factura" := rstFacturaBufferRT."Tipo factura"::"Nota d/c";
                                                    rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::"Seguridad Social";
                                                    rstFacturaBufferRT."Cod. retencion" := rstLinNC."Cód. retención SS";
                                                    //rstFacturaBufferRT."Cód. retención" := rstCodRetencion."Cód. retención";
                                                    rstFacturaBufferRT."No. documento" := rstLinDiaGen."Document No.";
                                                    rstFacturaBufferRT."Tipo fiscal" := rstCabNC."VAT Bus. Posting Group";
                                                    rstFacturaBufferRT."Serie retención" := '';
                                                    rstFacturaBufferRT."Fecha pago" := 0D;
                                                    rstFacturaBufferRT."Base pago retencion" := 0;
                                                    rstFacturaBufferRT."Pagos anteriores" := 0;
                                                    rstFacturaBufferRT."Importe retencion" := 0;
                                                    rstFacturaBufferRT."% retencion" := 0;
                                                    rstFacturaBufferRT.Provincia := '';
                                                    rstFacturaBufferRT."No. serie ganancias" := '';
                                                    rstFacturaBufferRT."No. serie IVA" := '';
                                                    rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                                                    rstFacturaBufferRT."Fecha factura" := 0D;
                                                    rstFacturaBufferRT.Nombre := '';
                                                    rstFacturaBufferRT."Importe neto factura" := 0;
                                                    //rstFacturaBufferRT."Factura liquidada" := rstMovProveedorFC."Document No.";
                                                    rstFacturaBufferRT."Factura liquidada" := rstLinNC."Document No.";
                                                    rstFacturaBufferRT.Insert;

                                                end;

                                                rstFacturaBufferRT."Fecha pago" := rstLinDiaGen."Posting Date";


                                                //Si la divisa de la factura es diferente a la divisa local, calculo el importe base a retener utilizando el factor
                                                //de divisa de la cabecera de compra.
                                                //Cambio de lógica. Siempre se paga la factura en pesos, as¡ que utilizo el tipo de cambio por el que se cargó la
                                                //factura para el c lculo de las retenciones.

                                                //++Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                                decTCambioPago := fntTipoCambioPago(rstLinDiaGenTemp, rstFacturaBufferRT."No. Factura");
                                                //--Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                                //IF decTCambioPago <> 0 THEN
                                                //IF rstCabNC."Currency Code" <> '' THEN
                                                //BEGIN

                                                //decTCambioPago := 0;
                                                //decTCambioPago := 1/rstCabNC."Currency Factor";
                                                //decTCambioPago := 1/rstLinDiaGenTemp."Currency Factor";
                                                /*
                                                IF rstCabNC."Currency Factor" <> 0 THEN
                                                  rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)/rstCabNC."Currency Factor"
                                                ELSE
                                                */
                                                rstFacturaBufferRT."Importe neto factura" -= (rstLinNC.Amount) * decTCambioPago;
                                                rstFacturaBufferRT."Base pago retencion" -= (rstLinNC."Amount Including VAT" - rstLinNC."VAT Base Amount")
                                                  * decTCambioPago;
                                                /*
                                            END
                                            ELSE
                                            BEGIN

                                              rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)*ABS(rstMovProveedorFC."Closed by Amount"/
                                                                                                                rstMovProveedor."Amount (LCY)");
                                              rstFacturaBufferRT."Base pago retencion" -= (rstLinNC."Amount Including VAT"-rstLinNC."VAT Base Amount")
                                              *ABS(rstMovProveedorFC."Closed by Amount"/rstMovProveedor."Amount (LCY)");

                                            END;
                                            */
                                                //Calculo el importe a retener. Para eso, busco la configuración de retenciones correcta
                                                CalcularImporteARetenerNCSS(rstLinNC, rstLinDiaGen, decImportePagosAnterioresIVA, rstFacturaBufferRT, rstCabNC);

                                            end;

                                        until rstMovProveedorFC.Next = 0
                                    else begin

                                        Clear(rstMovProveedorFC);
                                        rstMovProveedorFC.SetRange("Entry No.", rstMovProveedor."Closed by Entry No.");
                                        rstMovProveedorFC.SetRange(Anulado, false);
                                        if rstMovProveedorFC.FindSet then begin

                                            rstMovProveedorFC.CalcFields("Amount (LCY)", rstMovProveedorFC."Remaining Amt. (LCY)");

                                            Clear(rstLinDiaGenNCLic);
                                            rstLinDiaGenNCLic.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
                                            rstLinDiaGenNCLic.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                                            rstLinDiaGenNCLic.SetRange("Document No.", rstLinDiaGen."Document No.");
                                            rstLinDiaGenNCLic.SetRange("Applies-to Doc. No.", rstMovProveedorFC."Document No.");
                                            if rstLinDiaGenNCLic.FindFirst then begin

                                                Clear(rstCabNC);
                                                rstCabNC.Get(rstLinNC."Document No.");

                                                decImpoLiqNC := 0;
                                                decImpoLiqNC := rstMovProveedorFC."Purchase (LCY)" / rstMovProveedorFC."Amount (LCY)";

                                                Clear(rstFacturaBufferRT);
                                                rstFacturaBufferRT.SetRange("Tipo registro", rstFacturaBufferRT."Tipo registro"::Compra);
                                                rstFacturaBufferRT.SetRange("Cliente/Proveedor", rstProveedor."No.");
                                                rstFacturaBufferRT.SetRange("No. Factura", rstLinNC."Document No.");
                                                rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::"Seguridad Social");
                                                //rstFacturaBufferRT.SETRANGE("Cód. retención",rstCodRetencion."Cód. retención");
                                                rstFacturaBufferRT.SetRange("Cod. retencion", rstLinNC."Cód. retención SS");
                                                rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstLinDiaGen."Document No.");
                                                rstFacturaBufferRT.SetRange("Tipo fiscal", rstCabNC."VAT Bus. Posting Group");
                                                if not rstFacturaBufferRT.FindFirst then begin

                                                    rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Compra;
                                                    rstFacturaBufferRT."Cliente/Proveedor" := rstProveedor."No.";
                                                    //US.ARBU - 2005-08-03 - Inicio - Con ésta modificación, se modifica el sistema de cálculo de las NC's para
                                                    //                                que acumulen sobre el registro de buffer de la factura a que aplican
                                                    //rstFacturaBufferRT."No. Factura" := rstMovProveedorFC."No. documento";
                                                    //US.ARBU - 2005-08-03 - Fin - Con ésta modificación, se modifica el sistema de cálculo de las NC's para
                                                    //                                que acumulen sobre el registro de buffer de la factura a que aplican
                                                    rstFacturaBufferRT."No. Factura" := rstLinNC."Document No.";
                                                    rstFacturaBufferRT."Tipo factura" := rstFacturaBufferRT."Tipo factura"::"Nota d/c";
                                                    rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::"Seguridad Social";
                                                    rstFacturaBufferRT."Cod. retencion" := rstLinNC."Cód. retención SS";
                                                    rstFacturaBufferRT."No. documento" := rstLinDiaGen."Document No.";
                                                    rstFacturaBufferRT."Tipo fiscal" := rstCabNC."VAT Bus. Posting Group";
                                                    rstFacturaBufferRT."Serie retención" := '';
                                                    rstFacturaBufferRT."Fecha pago" := 0D;
                                                    rstFacturaBufferRT."Base pago retencion" := 0;
                                                    rstFacturaBufferRT."Pagos anteriores" := 0;
                                                    rstFacturaBufferRT."Importe retencion" := 0;
                                                    rstFacturaBufferRT."% retencion" := 0;
                                                    rstFacturaBufferRT.Provincia := '';
                                                    rstFacturaBufferRT."No. serie ganancias" := '';
                                                    rstFacturaBufferRT."No. serie IVA" := '';
                                                    rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                                                    rstFacturaBufferRT."Fecha factura" := 0D;
                                                    rstFacturaBufferRT.Nombre := '';
                                                    rstFacturaBufferRT."Importe neto factura" := 0;
                                                    //rstFacturaBufferRT."Factura liquidada" := rstMovProveedorFC."Document No.";
                                                    rstFacturaBufferRT."Factura liquidada" := rstLinNC."Document No.";
                                                    rstFacturaBufferRT.Insert;

                                                end;

                                                rstFacturaBufferRT."Fecha pago" := rstLinDiaGen."Posting Date";

                                                //Si la divisa de la factura es diferente a la divisa local, calculo el importe base a retener utilizando el factor
                                                //de divisa de la cabecera de compra.
                                                //Cambio de lógica. Siempre se paga la factura en pesos, así que utilizo el tipo de cambio por el que se cargó la
                                                //factura para el cálculo de las retenciones.
                                                //++Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                                decTCambioPago := fntTipoCambioPago(rstLinDiaGenTemp, rstFacturaBufferRT."No. Factura");
                                                //--Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                                //IF decTCambioPago <> 0 THEN
                                                //IF rstCabNC."Currency Code" <> '' THEN
                                                //BEGIN

                                                //decTCambioPago := 0;
                                                //decTCambioPago := 1/rstCabNC."Currency Factor";
                                                //decTCambioPago := 1/rstLinDiaGenTemp."Currency Factor";
                                                /*
                                                IF rstCabNC."Currency Factor" <> 0 THEN
                                                  rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)/rstCabNC."Currency Factor"
                                                ELSE
                                                */
                                                rstFacturaBufferRT."Importe neto factura" -= (rstLinNC.Amount) * decTCambioPago;
                                                rstFacturaBufferRT."Base pago retencion" -= (rstLinNC."Amount Including VAT" - rstLinNC."VAT Base Amount")
                                                  * decTCambioPago;
                                                /*
                                            END
                                            ELSE
                                            BEGIN

                                                rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)*ABS(rstMovProveedor."Closed by Amount"/
                                                                                                                  rstMovProveedor."Amount (LCY)");
                                                rstFacturaBufferRT."Base pago retencion" -= (rstLinNC."Amount Including VAT"-rstLinNC."VAT Base Amount")
                                                *ABS(rstMovProveedor."Closed by Amount"/rstMovProveedor."Amount (LCY)");

                                            END;
                                            */
                                                //Calculo el importe a retener. Para eso, busco la configuración de retenciones correcta
                                                CalcularImporteARetenerNCSS(rstLinNC, rstLinDiaGen, decImportePagosAnterioresIVA, rstFacturaBufferRT, rstCabNC);

                                            end;

                                        end;

                                    end;

                                end
                                else begin

                                    Clear(rstLinDiaGenNCLic);
                                    rstLinDiaGenNCLic.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
                                    rstLinDiaGenNCLic.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                                    rstLinDiaGenNCLic.SetRange("Document No.", rstLinDiaGen."Document No.");
                                    rstLinDiaGenNCLic.SetRange("Applies-to Doc. No.", rstMovProveedorFC."Document No.");
                                    if rstLinDiaGenNCLic.FindFirst then begin

                                        Clear(rstCabNC);
                                        rstCabNC.Get(rstLinNC."Document No.");

                                        decImpoLiqNC := 0;
                                        decImpoLiqNC := 1;

                                        Clear(rstFacturaBufferRT);
                                        rstFacturaBufferRT.SetRange("Tipo registro", rstFacturaBufferRT."Tipo registro"::Compra);
                                        rstFacturaBufferRT.SetRange("Cliente/Proveedor", rstProveedor."No.");
                                        rstFacturaBufferRT.SetRange("No. Factura", rstLinNC."Document No.");
                                        rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::"Seguridad Social");
                                        //rstFacturaBufferRT.SETRANGE("Cód. retención",rstCodRetencion."Cód. retención");
                                        rstFacturaBufferRT.SetRange("Cod. retencion", rstLinNC."Cód. retención SS");
                                        rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstLinDiaGen."Document No.");
                                        rstFacturaBufferRT.SetRange("Tipo fiscal", rstCabNC."VAT Bus. Posting Group");
                                        if not rstFacturaBufferRT.FindFirst then begin

                                            rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Compra;
                                            rstFacturaBufferRT."Cliente/Proveedor" := rstProveedor."No.";
                                            //US.ARBU - 2005-08-03 - Inicio - Con ésta modificación, se modifica el sistema de cálculo de las NC's para
                                            //                                que acumulen sobre el registro de buffer de la factura a que aplican
                                            //rstFacturaBufferRT."No. Factura" := rstMovProveedorFC."No. documento";
                                            //US.ARBU - 2005-08-03 - Fin - Con ésta modificación, se modifica el sistema de cálculo de las NC's para
                                            //                                que acumulen sobre el registro de buffer de la factura a que aplican
                                            rstFacturaBufferRT."No. Factura" := rstLinNC."Document No.";
                                            rstFacturaBufferRT."Tipo factura" := rstFacturaBufferRT."Tipo factura"::"Nota d/c";
                                            rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::"Seguridad Social";
                                            rstFacturaBufferRT."Cod. retencion" := rstLinNC."Cód. retención SS";
                                            //rstFacturaBufferRT."Cód. retención" := rstCodRetencion."Cód. retención";
                                            rstFacturaBufferRT."No. documento" := rstLinDiaGen."Document No.";
                                            rstFacturaBufferRT."Tipo fiscal" := rstCabNC."VAT Bus. Posting Group";
                                            rstFacturaBufferRT."Serie retención" := '';
                                            rstFacturaBufferRT."Fecha pago" := 0D;
                                            rstFacturaBufferRT."Base pago retencion" := 0;
                                            rstFacturaBufferRT."Pagos anteriores" := 0;
                                            rstFacturaBufferRT."Importe retencion" := 0;
                                            rstFacturaBufferRT."% retencion" := 0;
                                            rstFacturaBufferRT.Provincia := '';
                                            rstFacturaBufferRT."No. serie ganancias" := '';
                                            rstFacturaBufferRT."No. serie IVA" := '';
                                            rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                                            rstFacturaBufferRT."Fecha factura" := 0D;
                                            rstFacturaBufferRT.Nombre := '';
                                            rstFacturaBufferRT."Importe neto factura" := 0;
                                            rstFacturaBufferRT."Factura liquidada" := rstLinNC."Document No.";
                                            rstFacturaBufferRT.Insert;

                                        end;

                                        rstFacturaBufferRT."Fecha pago" := rstLinDiaGen."Posting Date";


                                        //Si la divisa de la factura es diferente a la divisa local, calculo el importe base a retener utilizando el factor
                                        //de divisa de la cabecera de compra.
                                        //Cambio de lógica. Siempre se paga la factura en pesos, así que utilizo el tipo de cambio por el que se cargó la
                                        //factura para el cálculo de las retenciones.

                                        //++Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                        decTCambioPago := fntTipoCambioPago(rstLinDiaGenTemp, rstFacturaBufferRT."No. Factura");
                                        //--Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                        //IF decTCambioPago <> 0 THEN
                                        //IF rstCabNC."Currency Code" <> '' THEN
                                        //BEGIN

                                        //decTCambioPago := 0;
                                        //decTCambioPago := 1/rstCabNC."Currency Factor";
                                        //decTCambioPago := 1/rstLinDiaGenTemp."Currency Factor";
                                        /*
                                        IF rstCabNC."Currency Code" <> '' THEN
                                          rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)/rstCabNC."Currency Factor"
                                        ELSE
                                        */
                                        rstFacturaBufferRT."Importe neto factura" -= (rstLinNC.Amount) * decTCambioPago;
                                        rstFacturaBufferRT."Base pago retencion" -= (rstLinNC."Amount Including VAT" - rstLinNC."VAT Base Amount")
                                            * decTCambioPago;
                                        /*
                                  END
                                  ELSE
                                  BEGIN

                                    rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount);
                                    rstFacturaBufferRT."Base pago retencion" -= (rstLinNC."Amount Including VAT"-rstLinNC."VAT Base Amount");

                                  END;
                                  */

                                        //Calculo el importe a retener. Para eso, busco la configuración de retenciones correcta
                                        CalcularImporteARetenerNCSS(rstLinNC, rstLinDiaGen, decImportePagosAnterioresIVA, rstFacturaBufferRT, rstCabNC);

                                    end;

                                end;

                                //IF NOT rstMovProveedorFC.GET(rstMovProveedor."Cerrado por nº orden") THEN
                                //  ERROR('Debe liquidar la Nota de Crédito N° %1',rstMovProveedor."No. documento");

                            end;

                        //Si esta es la primera vez que se inserta la factura en la tabla, entonces limpio el resto de los campos

                        until rstLinNC.Next = 0;

                end;

            until rstLinDiaGenTemp.Next = 0;

        //Insertamos el cálculo en el diario de pagos

        CrearDiarioPagosSS(rstLinDiaGen);

        //END;

    end;

    [Scope('OnPrem')]
    procedure CalcularPagosAnterioresSS(rstFacturaBuffer: Record "Invoice Withholding Buffer"): Decimal
    var
        rstConfiguracionRetenciones: Record "Withholding setup";
        rstTotalPagos: Record "Invoice Withholding Buffer";
        datInicioMes: Date;
        datFinMes: Date;
        rstFactura: Record "Purch. Inv. Line";
        rstNCredito: Record "Purch. Cr. Memo Line";
        rstPagosBuffer: Record "Invoice Withholding Buffer";
        rstAcumuladoBuffer: Record "Invoice Withholding Buffer";
        decImporte: Decimal;
    begin
        //CalcularPagosAnterioresSS

        Clear(rstPagosBuffer);
        decImporte := 0;
        rstPagosBuffer.SetCurrentKey(rstPagosBuffer."Cliente/Proveedor", rstPagosBuffer."No. Factura", rstPagosBuffer."Tipo retencion",
                                     rstPagosBuffer."Cod. retencion", rstPagosBuffer."Tipo fiscal");
        rstPagosBuffer.SetRange("Cliente/Proveedor", rstFacturaBuffer."Cliente/Proveedor");
        rstPagosBuffer.SetRange("No. Factura", rstFacturaBuffer."No. Factura");
        rstPagosBuffer.SetFilter("No. documento", '<>%1', rstFacturaBuffer."No. documento");
        rstPagosBuffer.SetRange("Tipo retencion", rstFacturaBuffer."Tipo retencion");
        rstPagosBuffer.SetRange("Cod. retencion", rstFacturaBuffer."Cod. retencion");
        rstPagosBuffer.SetRange("Tipo fiscal", rstFacturaBuffer."Tipo fiscal");
        rstPagosBuffer.SetFilter(rstPagosBuffer."No. documento", '<>%1', rstFacturaBuffer."No. documento");
        if rstPagosBuffer.FindFirst then
            repeat

                decImporte += rstPagosBuffer."Importe retencion";

            until rstPagosBuffer.Next = 0;

        exit(decImporte);
    end;

    [Scope('OnPrem')]
    procedure CalcularImporteARetenerSS(rstLinFacturaL: Record "Purch. Inv. Line"; rstLinDiaGenL: Record "Gen. Journal Line"; decImportePagosAnterioresIVAL: Decimal; var rstFacturaBufferRTL: Record "Invoice Withholding Buffer"; rstCabFacturaL: Record "Purch. Inv. Header"): Decimal
    var
        rstCodigosRetencion: Record "Withholding codes";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstExencion: Record "Withholding details";
        rstProveedor: Record Vendor;
        rstAccionEstFis: Record "Acción estado sit. fiscal";
        int80or100: Integer;
    begin
        //CalcularImporteARetenerSS

        rstProveedor.Get(rstLinFacturaL."Buy-from Vendor No.");
        Clear(rstCodigosRetencion);
        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstLinDiaGenL."Posting Date", 0D);
        rstCodigosRetencion.SetRange(rstCodigosRetencion."Tipo impuesto retencion",
                                     rstCodigosRetencion."Tipo impuesto retencion"::"Seguridad Social");
        rstCodigosRetencion.SetRange("Cod. retencion", rstLinFacturaL."Cód. retención SS");
        if rstCodigosRetencion.FindFirst then begin

            if ((rstCodigosRetencion."Valid to" <> 0D) and
               (rstLinDiaGenL."Posting Date" <= rstCodigosRetencion."Valid to")) or
               (rstCodigosRetencion."Valid to" = 0D) then begin

                Clear(rstConfiguracionRetencion);
                rstConfiguracionRetencion.SetRange("Tipo retenciones", rstConfiguracionRetencion."Tipo retenciones"::"Seguridad Social");
                rstConfiguracionRetencion.SetRange("Cod. retencion", rstCodigosRetencion."Cod. retencion");
                rstConfiguracionRetencion.SetRange("Tipo fiscal", rstFacturaBufferRTL."Tipo fiscal");
                if rstConfiguracionRetencion.FindFirst then begin

                    //Si el proveedor tiene un certificado de exclusión vigente

                    Clear(rstExencion);
                    rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                    //rstExencion.SETRANGE("Tipo retención",rstExencion."Tipo retención"::"Seguridad Social");
                    rstExencion.SetFilter("Tipo retención", '%1|%2', rstExencion."Tipo retención"::"Seguridad Social", rstExencion."Tipo retención"::"Agente de retención IVA");
                    rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                    //rstExencion.SETFILTER("Fecha efectividad retencion",'>=%1',rstLinDiaGenL."Posting Date");
                    //IF rstExencion.FINDLAST THEN
                    begin

                        //Si tiene certificado de exclusión, me fijo en el estado de situación fiscal

                        Clear(rstAccionEstFis);
                        rstAccionEstFis.Get(rstProveedor."Estado de situación fiscal");
                        case rstAccionEstFis."Acción exclusión" of

                            rstAccionEstFis."Acción exclusión"::"Aplicar exención":
                                begin

                                    rstFacturaBufferRTL."Importe retencion" := (((rstFacturaBufferRTL."Importe neto factura" *
                                    //rstConfiguracionRetencion."% retención")/100)*((-rstExencion."% exención"+100)/100))-
                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                    ) / 100) * ((-rstExencion."% exención" + 100) / 100)) -
                                    decImportePagosAnterioresIVAL;
                                    rstFacturaBufferRTL.Excluido := 2;
                                    rstFacturaBufferRTL."% Exclusion" := rstExencion."% exención";
                                    rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";

                                end;

                            rstAccionEstFis."Acción exclusión"::"No aplicar exención":
                                begin

                                    rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                    //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                    ) / 100) - decImportePagosAnterioresIVAL;
                                    rstFacturaBufferRTL.Excluido := 0;
                                    rstFacturaBufferRTL."% Exclusion" := 0;
                                    rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                end;

                            rstAccionEstFis."Acción exclusión"::"Consultar al usuario":
                                begin

                                    if Confirm('El proveedor %1 posee un Certificado de Exclusión de situación %2 por un %3 por ciento.\' +
                                    '¿Desea aplicarlo en este pago?', false, rstProveedor.Name,
                                    rstProveedor."Estado de situación fiscal", rstExencion."% exención") then begin

                                        rstFacturaBufferRTL."Importe retencion" := (((rstFacturaBufferRTL."Importe neto factura" *
                                        //rstConfiguracionRetencion."% retención")/100)*((-rstExencion."% exención"+100)/100))-
                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                        ) / 100) * ((-rstExencion."% exención" + 100) / 100)) -
                                        decImportePagosAnterioresIVAL;
                                        rstFacturaBufferRTL.Excluido := 2;
                                        rstFacturaBufferRTL."% Exclusion" := rstExencion."% exención";
                                        rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";

                                    end
                                    else begin

                                        rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                        //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                        ) / 100) - decImportePagosAnterioresIVAL;
                                        rstFacturaBufferRTL.Excluido := 0;
                                        rstFacturaBufferRTL."% Exclusion" := 0;
                                        rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                    end;
                                end;
                        end;

                    end
                    else begin

                        Clear(rstExencion);
                        rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                        //rstExencion.SETRANGE("Tipo retención",rstExencion."Tipo retención"::"Seguridad Social");
                        rstExencion.SetFilter("Tipo retención", '%1|%2', rstExencion."Tipo retención"::"Seguridad Social", rstExencion."Tipo retención"::"Agente de retención IVA");
                        rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                        if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                            //IF rstExencion.FINDLAST AND (rstExencion."Fecha efectividad retencion" < rstLinDiaGenL."Posting Date") THEN
                            /*ERROR('El certificado de Exención del proveedor %1, %2, ha vencido. \'+
                            'Por favor, actualice el certificado, o elimínelo de la configuración del proveedor.',
                            ",rstProveedor.Name)*/
                                        fntConfirmaExencionAntigua(rstExencion, rstProveedor)

                        else begin

                            rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                            //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                            fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                            ) / 100) - decImportePagosAnterioresIVAL;
                            rstFacturaBufferRTL.Excluido := 0;
                            rstFacturaBufferRTL."% Exclusion" := 0;
                            rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                        end;

                    end;

                end;

            end
            else
                Error('El código de retención ' + rstCodigosRetencion."Cod. retencion" + ', tipo de impuesto ' + Format(rstCodigosRetencion."Tipo impuesto retencion") + ', del documento ' + rstLinDiaGenL."Applies-to Doc. No." + ', no está activo a esta fecha.')

        end;

        //Completo la línea de retención con la información de la retención

        rstFacturaBufferRTL."% retencion" := rstConfiguracionRetencion."% retencion";
        rstFacturaBufferRTL.Provincia := rstLinFacturaL.Area;
        rstFacturaBufferRTL."No. serie IVA" := '';
        rstFacturaBufferRTL."Fecha factura" := rstCabFacturaL."Document Date";
        if not rstFacturaBufferRTL.Insert then
            rstFacturaBufferRTL.Modify;

    end;

    [Scope('OnPrem')]
    procedure CalcularImporteARetenerNCSS(rstLinNCL: Record "Purch. Cr. Memo Line"; rstLinDiaGenL: Record "Gen. Journal Line"; decImportePagosAnterioresIVAL: Decimal; var rstFacturaBufferRTL: Record "Invoice Withholding Buffer"; rstCabNCL: Record "Purch. Cr. Memo Hdr."): Decimal
    var
        rstCodigosRetencion: Record "Withholding codes";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstExencion: Record "Withholding details";
        rstProveedor: Record Vendor;
        rstAccionEstFis: Record "Acción estado sit. fiscal";
    begin
        //CalcularImporteARetenerNCSS

        rstProveedor.Get(rstLinNCL."Buy-from Vendor No.");
        Clear(rstCodigosRetencion);
        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstLinDiaGenL."Posting Date", 0D);
        rstCodigosRetencion.SetRange(rstCodigosRetencion."Tipo impuesto retencion",
                                     rstCodigosRetencion."Tipo impuesto retencion"::"Seguridad Social");

        if rstCodigosRetencion.FindFirst then begin

            if ((rstCodigosRetencion."Valid to" <> 0D) and
               (rstLinDiaGenL."Posting Date" <= rstCodigosRetencion."Valid to")) or
               (rstCodigosRetencion."Valid to" = 0D) then begin

                Clear(rstConfiguracionRetencion);
                rstConfiguracionRetencion.SetRange("Tipo retenciones", rstConfiguracionRetencion."Tipo retenciones"::"Seguridad Social");
                rstConfiguracionRetencion.SetRange("Cod. retencion", rstLinNCL."Cód. retención SS");
                rstConfiguracionRetencion.SetRange("Tipo fiscal", rstFacturaBufferRTL."Tipo fiscal");
                if rstConfiguracionRetencion.FindFirst then begin

                    //Si el proveedor tiene un certificado de exclusión vigente

                    Clear(rstExencion);
                    rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                    //rstExencion.SETRANGE("Tipo retención",rstExencion."Tipo retención"::"Seguridad Social");
                    rstExencion.SetFilter("Tipo retención", '%1|%2', rstExencion."Tipo retención"::"Seguridad Social", rstExencion."Tipo retención"::"Agente de retención IVA");
                    rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                    //rstExencion.SETFILTER("Fecha efectividad retencion",'>=%1',rstLinDiaGenL."Posting Date");
                    //IF rstExencion.FINDLAST THEN
                    begin

                        //Si tiene certificado de exclusión, me fijo en el estado de situación fiscal

                        Clear(rstAccionEstFis);
                        rstAccionEstFis.Get(rstProveedor."Estado de situación fiscal");
                        case rstAccionEstFis."Acción exclusión" of

                            rstAccionEstFis."Acción exclusión"::"Aplicar exención":
                                begin

                                    rstFacturaBufferRTL."Importe retencion" := Round((((rstFacturaBufferRTL."Importe neto factura" *
                                    rstConfiguracionRetencion."% retencion") / 100) * ((-rstExencion."% exención" + 100) / 100)) -
                                    decImportePagosAnterioresIVAL, 0.01);
                                    rstFacturaBufferRTL.Excluido := 2;
                                    rstFacturaBufferRTL."% Exclusion" := rstExencion."% exención";
                                    rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";

                                end;

                            rstAccionEstFis."Acción exclusión"::"No aplicar exención":
                                begin

                                    rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                    //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                    fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                    ) / 100) - decImportePagosAnterioresIVAL;
                                    rstFacturaBufferRTL.Excluido := 0;
                                    rstFacturaBufferRTL."% Exclusion" := 0;
                                    rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                end;

                            rstAccionEstFis."Acción exclusión"::"Consultar al usuario":
                                begin

                                    if Confirm('El proveedor %1 posee un Certificado de Exclusión de situación %2 por un %3 por ciento.\' +
                                    '¿Desea aplicarlo en este pago?', false, rstProveedor.Name,
                                    rstProveedor."Estado de situación fiscal", rstExencion."% exención") then begin

                                        rstFacturaBufferRTL."Importe retencion" := (((rstFacturaBufferRTL."Importe neto factura" *
                                        //rstConfiguracionRetencion."% retención")/100)*((-rstExencion."% exención"+100)/100))-
                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                        ) / 100) * ((-rstExencion."% exención" + 100) / 100)) -
                                        decImportePagosAnterioresIVAL;
                                        rstFacturaBufferRTL.Excluido := 2;
                                        rstFacturaBufferRTL."% Exclusion" := rstExencion."% exención";
                                        rstFacturaBufferRTL."Fecha documento exclusion" := rstExencion."Fecha documento";

                                    end
                                    else begin

                                        rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                        //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                        ) / 100) - decImportePagosAnterioresIVAL;
                                        rstFacturaBufferRTL.Excluido := 0;
                                        rstFacturaBufferRTL."% Exclusion" := 0;
                                        rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                                    end;
                                end;
                        end;

                    end
                    else begin

                        Clear(rstExencion);
                        rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                        //rstExencion.SETRANGE("Tipo retención",rstExencion."Tipo retención"::"Seguridad Social");
                        rstExencion.SetFilter("Tipo retención", '%1|%2', rstExencion."Tipo retención"::"Seguridad Social", rstExencion."Tipo retención"::"Agente de retención IVA");
                        rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                        if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                            //IF rstExencion.FINDLAST AND (rstExencion."Fecha efectividad retencion" < rstLinDiaGenL."Posting Date") THEN
                            /*ERROR('El certificado de Exención del proveedor %1, %2, ha vencido. \'+
                            'Por favor, actualice el certificado, o elimínelo de la configuración del proveedor.',
                            ",rstProveedor.Name)*/
                                        fntConfirmaExencionAntigua(rstExencion, rstProveedor)

                        else begin

                            rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                            //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                            fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                            ) / 100) - decImportePagosAnterioresIVAL;
                            rstFacturaBufferRTL.Excluido := 0;
                            rstFacturaBufferRTL."% Exclusion" := 0;
                            rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                        end;

                    end;

                end;

            end
            else
                Error('El código de retención ' + rstCodigosRetencion."Cod. retencion" + ', tipo de impuesto ' + Format(rstCodigosRetencion."Tipo impuesto retencion") + ', del documento ' + rstLinDiaGenL."Applies-to Doc. No." + ', no está activo a esta fecha.')

        end;

        //Completo la línea de retención con la información de la retención

        rstFacturaBufferRTL."% retencion" := rstConfiguracionRetencion."% retencion";
        rstFacturaBufferRTL.Provincia := rstLinNCL.Area;
        rstFacturaBufferRTL."No. serie IVA" := '';
        rstFacturaBufferRTL."Fecha factura" := rstCabNCL."Document Date";
        if not rstFacturaBufferRTL.Insert then
            rstFacturaBufferRTL.Modify;

    end;

    [Scope('OnPrem')]
    procedure CrearDiarioPagosSS(var rstLinDiaGen: Record "Gen. Journal Line")
    var
        rstHisCFacComp: Record "Purch. Inv. Header";
        intMotivoExclusion: Integer;
        rstCodigosRetencion: Record "Withholding codes";
        rstFacturaBufferRT2: Record "Invoice Withholding Buffer";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstLinDiaGen2: Record "Gen. Journal Line";
        rstLinDiaGenTemp: Record "Gen. Journal Line";
        rstHisCNC: Record "Purch. Cr. Memo Hdr.";
        rstFacturaBufferRT: Record "Invoice Withholding Buffer";
        codNoSerieCertificado: Code[20];
        rstConfCont: Record "General Ledger Setup";
        cduGestionNoSerie: Codeunit "No. Series";
        rstMovProveedor: Record "Vendor Ledger Entry";
    begin
        //CrearDiarioPagosSS


        Clear(rstFacturaBufferRT);
        CalcularTotalRetenido(rstLinDiaGen."Document No.", rstLinDiaGen."Applies-to Doc. No.");
        rstFacturaBufferRT.SetCurrentKey(rstFacturaBufferRT."No. documento");
        rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstLinDiaGen."Document No.");
        rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::"Seguridad Social");
        rstFacturaBufferRT.SetFilter("Importe retencion", '<>0');
        if rstFacturaBufferRT.FindFirst then
            repeat

                rstFacturaBufferRT."Importe retencion" := Round(rstFacturaBufferRT."Importe retencion", 0.01);
                rstFacturaBufferRT.CalcFields(rstFacturaBufferRT."Importe retencion total", "Importe retenido real",
                                              rstFacturaBufferRT."Importe minimo pago", rstFacturaBufferRT."Importe minimo retención");

                if rstFacturaBufferRT."Tipo factura" = rstFacturaBufferRT."Tipo factura"::Factura then begin

                    /*CLEAR(rstHisCFacComp);
                    rstHisCFacComp.GET(rstFacturaBufferRT."No. Factura");*/

                    Clear(rstMovProveedor);
                    rstMovProveedor.SetCurrentKey(rstMovProveedor."Vendor No.", rstMovProveedor."Document No.");
                    rstMovProveedor.SetRange("Vendor No.", rstFacturaBufferRT."Cliente/Proveedor");
                    rstMovProveedor.SetRange("Document No.", rstFacturaBufferRT."Factura liquidada");
                    rstMovProveedor.FindFirst;

                    if intMotivoExclusion = 0 then begin

                        Clear(rstCodigosRetencion);
                        rstCodigosRetencion.SetRange("Tipo impuesto retencion", rstCodigosRetencion."Tipo impuesto retencion"::"Seguridad Social");
                        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstLinDiaGen."Posting Date", 0D);
                        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstLinDiaGen."Posting Date", 0D);
                        rstCodigosRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                        //IF rstCodigosRetencion.GET(rstCodigosRetencion."Tipo impuesto retencion"::IVA,rstLinFacturaL."Cód. retención IVA") THEN
                        if rstCodigosRetencion.FindFirst then begin

                            Clear(rstConfiguracionRetencion);
                            rstConfiguracionRetencion.SetRange("Tipo retenciones", rstFacturaBufferRT."Tipo retencion");
                            rstConfiguracionRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                            if rstConfiguracionRetencion.FindFirst then begin

                                if rstFacturaBufferRT."Importe retenido real" >= rstConfiguracionRetencion."Importe min. retencion" then begin

                                    Clear(rstLinDiaGen2);
                                    rstLinDiaGen2.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
                                    rstLinDiaGen2.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                                    //rstLinDiaGen2.SETRANGE("No. documento",rstLinDiaGen."No. documento");
                                    if rstLinDiaGen2.FindLast then;
                                    Clear(rstLinDiaGenTemp);
                                    rstLinDiaGenTemp."Journal Template Name" := rstLinDiaGen."Journal Template Name";
                                    rstLinDiaGenTemp."Journal Batch Name" := rstLinDiaGen."Journal Batch Name";
                                    rstLinDiaGenTemp."Posting Date" := rstLinDiaGen."Posting Date";
                                    rstLinDiaGenTemp."Posting No. Series" := rstLinDiaGen."Posting No. Series";
                                    rstLinDiaGenTemp."Due Date" := Today;
                                    rstLinDiaGenTemp."Document No." := rstLinDiaGen."Document No.";
                                    rstLinDiaGenTemp."Line No." := rstLinDiaGen2."Line No." + 1;
                                    rstLinDiaGenTemp."Transaction No." := rstLinDiaGen."Transaction No.";
                                    rstLinDiaGenTemp."No. cheque" := rstLinDiaGen."No. cheque";
                                    rstLinDiaGenTemp."Due Date" := rstLinDiaGen."Due Date";
                                    rstLinDiaGenTemp."Document Type" := rstLinDiaGenTemp."Document Type"::Payment;
                                    rstLinDiaGenTemp."Account Type" := rstLinDiaGenTemp."Account Type"::"G/L Account";
                                    Clear(rstConfCont);
                                    rstConfCont.Get();
                                    case rstFacturaBufferRT."Tipo retencion" of
                                        rstFacturaBufferRT."Tipo retencion"::"Seguridad Social":
                                            begin
                                                rstLinDiaGenTemp."Account No." := rstConfCont."SS withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. Seguridad Social ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;
                                        rstFacturaBufferRT."Tipo retencion"::Ganancias:
                                            begin
                                                rstLinDiaGenTemp."Account No." := rstConfCont."Winnings withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. Gan. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;
                                        rstFacturaBufferRT."Tipo retencion"::IVA:
                                            begin
                                                rstLinDiaGenTemp."Account No." := rstConfCont."VAT withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. IVA ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;
                                    end;
                                    rstLinDiaGenTemp.Validate("Account No.");
                                    if rstLinDiaGenTemp."Shortcut Dimension 1 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 1 Code", rstLinDiaGen."Shortcut Dimension 1 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 2 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 2 Code", rstLinDiaGen."Shortcut Dimension 2 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 3 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 3 Code", rstLinDiaGen."Shortcut Dimension 3 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 4 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 4 Code", rstLinDiaGen."Shortcut Dimension 4 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 5 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 5 Code", rstLinDiaGen."Shortcut Dimension 5 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 6 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 6 Code", rstLinDiaGen."Shortcut Dimension 6 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 7 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 7 Code", rstLinDiaGen."Shortcut Dimension 7 Code");

                                    rstLinDiaGenTemp.Validate(Amount, -rstFacturaBufferRT."Importe retencion");
                                    rstLinDiaGenTemp."External Document No." := rstMovProveedor."External Document No.";
                                    rstLinDiaGenTemp."Descripción 2" := rstFacturaBufferRT."No. Factura";
                                    rstLinDiaGenTemp."Factor divisa operacion" := rstLinDiaGen."Factor divisa operacion";
                                    rstLinDiaGenTemp."Valor divisa operacion" := rstLinDiaGen."Valor divisa operacion";
                                    rstLinDiaGenTemp.Retención := true;
                                    rstFacturaBufferRT.Retenido := true;
                                    Clear(rstConfCont);
                                    rstConfCont.Get();

                                    rstFacturaBufferRT.Modify;

                                    if not rstLinDiaGenTemp.Insert then
                                        rstLinDiaGenTemp.Modify;

                                end
                                else begin

                                    rstFacturaBufferRT.Excluido := 3;
                                    rstFacturaBufferRT.Modify;

                                end;

                            end;

                        end;

                    end
                    else begin

                        rstFacturaBufferRT.Excluido := intMotivoExclusion;
                        rstFacturaBufferRT.Modify;

                    end;

                end;


                if rstFacturaBufferRT."Tipo factura" = rstFacturaBufferRT."Tipo factura"::"Nota d/c" then begin

                    Clear(rstHisCNC);
                    rstHisCNC.Get(rstFacturaBufferRT."No. Factura");
                    if intMotivoExclusion = 0 then begin

                        Clear(rstCodigosRetencion);
                        rstCodigosRetencion.SetRange("Tipo impuesto retencion", rstCodigosRetencion."Tipo impuesto retencion"::"Seguridad Social");
                        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstLinDiaGen."Posting Date", 0D);
                        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstLinDiaGen."Posting Date", 0D);
                        rstCodigosRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                        //IF rstCodigosRetencion.GET(rstCodigosRetencion."Tipo impuesto retencion"::IVA,rstLinFacturaL."Cód. retención IVA") THEN
                        if rstCodigosRetencion.FindFirst then begin

                            Clear(rstConfiguracionRetencion);
                            rstConfiguracionRetencion.SetRange("Tipo retenciones", rstFacturaBufferRT."Tipo retencion");
                            rstConfiguracionRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                            if rstConfiguracionRetencion.FindFirst then begin

                                if Abs(rstFacturaBufferRT."Importe retenido real") >= rstConfiguracionRetencion."Importe min. retencion" then begin

                                    Clear(rstLinDiaGen2);
                                    rstLinDiaGen2.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
                                    rstLinDiaGen2.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                                    //rstLinDiaGen2.SETRANGE("No. documento",rstLinDiaGen."No. documento");
                                    if rstLinDiaGen2.FindLast then;
                                    Clear(rstLinDiaGenTemp);
                                    rstLinDiaGenTemp."Journal Template Name" := rstLinDiaGen."Journal Template Name";
                                    rstLinDiaGenTemp."Journal Batch Name" := rstLinDiaGen."Journal Batch Name";
                                    rstLinDiaGenTemp."Posting Date" := rstLinDiaGen."Posting Date";
                                    rstLinDiaGenTemp."Posting No. Series" := rstLinDiaGen."Posting No. Series";
                                    rstLinDiaGenTemp."Due Date" := Today;
                                    rstLinDiaGenTemp."Document No." := rstLinDiaGen."Document No.";
                                    rstLinDiaGenTemp."Line No." := rstLinDiaGen2."Line No." + 1;
                                    rstLinDiaGenTemp."Due Date" := rstLinDiaGen."Due Date";
                                    rstLinDiaGenTemp."Transaction No." := rstLinDiaGen."Transaction No.";
                                    rstLinDiaGenTemp."No. cheque" := rstLinDiaGen."No. cheque";
                                    rstLinDiaGenTemp."Document Type" := rstLinDiaGenTemp."Document Type"::Payment;
                                    rstLinDiaGenTemp."Account Type" := rstLinDiaGenTemp."Account Type"::"G/L Account";
                                    Clear(rstConfCont);
                                    rstConfCont.Get();
                                    case rstFacturaBufferRT."Tipo retencion" of
                                        rstFacturaBufferRT."Tipo retencion"::Ganancias:
                                            begin
                                                rstLinDiaGenTemp."Account No." := rstConfCont."Winnings withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. Gan. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;
                                        rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos":
                                            begin
                                                rstLinDiaGenTemp."Account No." := rstConfCont."GI withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. I.B. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;
                                        rstFacturaBufferRT."Tipo retencion"::"Seguridad Social":
                                            begin
                                                Clear(rstConfCont);
                                                rstConfCont.Get();
                                                rstLinDiaGenTemp."Account No." := rstConfCont."SS withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. SS. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;
                                    end;
                                    rstLinDiaGenTemp.Validate("Account No.");
                                    if rstLinDiaGenTemp."Shortcut Dimension 1 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 1 Code", rstLinDiaGen."Shortcut Dimension 1 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 2 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 2 Code", rstLinDiaGen."Shortcut Dimension 2 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 3 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 3 Code", rstLinDiaGen."Shortcut Dimension 3 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 4 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 4 Code", rstLinDiaGen."Shortcut Dimension 4 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 5 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 5 Code", rstLinDiaGen."Shortcut Dimension 5 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 6 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 6 Code", rstLinDiaGen."Shortcut Dimension 6 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 7 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 7 Code", rstLinDiaGen."Shortcut Dimension 7 Code");

                                    rstLinDiaGenTemp.Validate(Amount, -rstFacturaBufferRT."Importe retencion");
                                    rstLinDiaGenTemp."Descripción 2" := rstFacturaBufferRT."No. Factura";
                                    rstLinDiaGenTemp."External Document No." := rstHisCNC."Vendor Cr. Memo No.";
                                    rstLinDiaGenTemp."Factor divisa operacion" := rstLinDiaGen."Factor divisa operacion";
                                    rstLinDiaGenTemp."Valor divisa operacion" := rstLinDiaGen."Valor divisa operacion";
                                    rstLinDiaGenTemp.Retención := true;
                                    rstFacturaBufferRT.Retenido := true;

                                    Clear(rstConfCont);
                                    rstConfCont.Get();

                                    rstFacturaBufferRT.Modify;

                                    if not rstLinDiaGenTemp.Insert then
                                        rstLinDiaGenTemp.Modify;

                                end
                                else begin

                                    rstFacturaBufferRT.Excluido := 3;
                                    rstFacturaBufferRT.Modify;

                                end;
                            end;

                        end;

                    end
                    else begin

                        rstFacturaBufferRT.Excluido := intMotivoExclusion;
                        rstFacturaBufferRT.Modify;

                    end;

                end;

            until rstFacturaBufferRT.Next = 0;

    end;

    [Scope('OnPrem')]
    procedure CalcularRetencionIIBB(var rstLinDiaGen: Record "Gen. Journal Line"; rstProveedor: Record Vendor)
    var
        rstLinDiaGenTemp: Record "Gen. Journal Line";
        rstCabFactura: Record "Purch. Inv. Header";
        rstLinFactura: Record "Purch. Inv. Line";
        rstFacturaBufferRT: Record "Invoice Withholding Buffer";
        decImportePagosAnterioresIVA: Decimal;
        rstCabNC: Record "Purch. Cr. Memo Hdr.";
        rstLinNC: Record "Purch. Cr. Memo Line";
        rstExencion: Record "Withholding details";
        rstMovIva: Record "VAT Entry";
        rstCodRetencion: Record "Withholding codes";
        cduGestionNoSerie: Codeunit "No. Series";
        rstConfCont: Record "General Ledger Setup";
        codNoSerieCertificado: Code[20];
        blnRetenido: Boolean;
        rstMovProveedor: Record "Vendor Ledger Entry";
        rstMovProveedorFC: Record "Vendor Ledger Entry";
        rstLinDiaGenNCLic: Record "Gen. Journal Line";
        decImpoLiqNC: Decimal;
        decPorcentajePagado: Decimal;
    begin
        //CalcularRetencionIIBB

        //Busco el N° de serie del certificado

        //Me fijo qué facturas ha seleccionado el usuario para liquidar en este pago

        rstLinDiaGenTemp.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
        rstLinDiaGenTemp.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
        rstLinDiaGenTemp.SetRange("Document No.", rstLinDiaGen."Document No.");
        rstLinDiaGenTemp.SetFilter("Applies-to Doc. No.", '<>%1', '');

        //Me posiciono en la primera factura a pagar

        if rstLinDiaGenTemp.FindFirst then
            repeat

                //Si el documento es una factura, voy a la línea de la factura, y comienzo a rellenar el buffer de retenciones

                if rstLinDiaGenTemp."Applies-to Doc. Type" = rstLinDiaGenTemp."Applies-to Doc. Type"::Invoice then begin

                    Clear(rstLinFactura);
                    rstLinFactura.SetRange("Document No.", rstLinDiaGenTemp."Applies-to Doc. No.");
                    //rstLinFactura.SETFILTER("VAT %",'<>0');
                    rstLinFactura.SetFilter("No.", '<>%1', '');
                    if rstLinFactura.FindFirst then
                        repeat

                            Clear(rstCabFactura);
                            rstCabFactura.Get(rstLinFactura."Document No.");

                            rstLinFactura.TestField("Cód. retención IIBB");
                            Clear(rstFacturaBufferRT);
                            rstFacturaBufferRT.SetRange("Tipo registro", rstFacturaBufferRT."Tipo registro"::Compra);
                            rstFacturaBufferRT.SetRange("Cliente/Proveedor", rstProveedor."No.");
                            rstFacturaBufferRT.SetRange("No. Factura", rstLinFactura."Document No.");
                            rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos");
                            rstFacturaBufferRT.SetRange("Cod. retencion", rstLinFactura."Cód. retención IIBB");
                            rstFacturaBufferRT.SetRange("No. documento", rstLinDiaGen."Document No.");
                            rstFacturaBufferRT.SetRange("Tipo fiscal", rstCabFactura."VAT Bus. Posting Group");
                            //Si esta es la primera vez que se inserta la factura en la tabla, entonces limpio el resto de los campos

                            if not rstFacturaBufferRT.FindFirst then begin

                                rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Compra;
                                rstFacturaBufferRT."Cliente/Proveedor" := rstProveedor."No.";
                                rstFacturaBufferRT."No. Factura" := rstLinFactura."Document No.";
                                rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos";
                                rstFacturaBufferRT."Cod. retencion" := rstLinFactura."Cód. retención IIBB";
                                rstFacturaBufferRT."No. documento" := rstLinDiaGen."Document No.";
                                rstFacturaBufferRT."Tipo fiscal" := rstCabFactura."VAT Bus. Posting Group";
                                rstFacturaBufferRT."Serie retención" := '';
                                rstFacturaBufferRT."Fecha pago" := 0D;
                                rstFacturaBufferRT."Base pago retencion" := 0;
                                rstFacturaBufferRT."Pagos anteriores" := 0;
                                rstFacturaBufferRT."Importe retencion" := 0;
                                rstFacturaBufferRT."% retencion" := 0;
                                rstFacturaBufferRT.Provincia := '';
                                rstFacturaBufferRT."No. serie ganancias" := '';
                                rstFacturaBufferRT."No. serie IVA" := '';
                                rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                                rstFacturaBufferRT."Fecha factura" := 0D;
                                rstFacturaBufferRT.Nombre := '';
                                rstFacturaBufferRT."Importe neto factura" := 0;
                                rstFacturaBufferRT."Factura liquidada" := rstLinFactura."Document No.";
                                rstFacturaBufferRT.Insert;

                            end;

                            rstFacturaBufferRT."Fecha pago" := rstLinDiaGen."Posting Date";


                            //Si la divisa de la factura es diferente a la divisa local, calculo el importe base a retener utilizando el factor
                            //de divisa de la cabecera de compra.
                            //Cambio de lógica. Siempre se paga la factura en pesos, así que utilizo el tipo de cambio por el que se cargó la
                            //factura para el cálculo de las retenciones.
                            //++Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                            decTCambioPago := fntTipoCambioPago(rstLinDiaGenTemp, rstFacturaBufferRT."No. Factura");
                            //--Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                            //IF decTCambioPago <> 0 THEN
                            /*
                            IF rstCabFactura."Currency Code" <> '' THEN
                            //BEGIN

                              //decTCambioPago := 0;
                              //decTCambioPago := 1/rstCabFactura."Currency Factor";
                              //decTCambioPago := 1/rstLinDiaGenTemp."Currency Factor";
                              rstFacturaBufferRT."Importe neto factura"  += (rstLinFactura.Amount)/rstCabFactura."Currency Factor"
                            ELSE
                              rstFacturaBufferRT."Importe neto factura"  += (rstLinFactura.Amount);
                              */
                            rstFacturaBufferRT."Importe neto factura" += (rstLinFactura.Amount) * decTCambioPago;
                            rstFacturaBufferRT."Base pago retencion" += (rstLinFactura.Amount)
                              * decTCambioPago;
                            /*
                        END
                        ELSE
                        BEGIN

                          rstFacturaBufferRT."Importe neto factura"  += (rstLinFactura.Amount);
                          rstFacturaBufferRT."Base pago retencion" += (rstLinFactura.Amount);

                        END;
                        */
                            //Calculo los pagos realizados anteriormente sobre esta factura
                            decImportePagosAnterioresIVA := 0;
                            decImportePagosAnterioresIVA := CalcularPagosAnterioresIIBB(rstFacturaBufferRT);
                            rstFacturaBufferRT."Importe retenciones anteriores" := decImportePagosAnterioresIVA;

                            //Calculo el importe a retener. Para eso, busco la configuración de retenciones correcta
                            CalcularImporteARetenerIIBB(rstLinFactura, rstLinDiaGen, decImportePagosAnterioresIVA, rstFacturaBufferRT, rstCabFactura);

                        until rstLinFactura.Next = 0;

                end;

                //Si el documento es una Nota de Crédito

                if rstLinDiaGenTemp."Applies-to Doc. Type" = rstLinDiaGenTemp."Applies-to Doc. Type"::"Credit Memo" then begin
                    Clear(rstLinNC);
                    rstLinNC.SetRange("Document No.", rstLinDiaGenTemp."Applies-to Doc. No.");
                    //rstLinNC.SETFILTER("VAT %",'<>0');
                    rstLinNC.SetFilter("No.", '<>%1', '');
                    if rstLinNC.FindFirst then
                        repeat

                            //US.ARBU - 2005-08-03 - Inicio - Con ésta modificación, se modifica el sistema de cálculo de las NC's para
                            //                                que acumulen sobre el registro de buffer de la factura a que aplican
                            Clear(rstMovProveedor);
                            rstMovProveedor.SetCurrentKey("Vendor No.", rstMovProveedor."Document Type", rstMovProveedor."Document No.");
                            rstMovProveedor.SetRange("Vendor No.", rstLinNC."Buy-from Vendor No.");
                            rstMovProveedor.SetRange("Document Type", rstMovProveedor."Document Type"::"Credit Memo");
                            rstMovProveedor.SetRange("Document No.", rstLinNC."Document No.");
                            if rstMovProveedor.FindFirst then begin

                                rstMovProveedor.CalcFields(Amount, "Remaining Amount", "Amount (LCY)", "Remaining Amt. (LCY)");
                                if rstMovProveedor.Amount <> rstMovProveedor."Remaining Amount" then begin

                                    Clear(rstMovProveedorFC);
                                    if rstMovProveedor."Closed by Entry No." <> 0 then
                                        rstMovProveedorFC.SetRange("Entry No.", rstMovProveedor."Closed by Entry No.")
                                    else
                                        rstMovProveedorFC.SetRange(rstMovProveedorFC."Closed by Entry No.", rstMovProveedor."Entry No.");
                                    rstMovProveedorFC.SetRange(Anulado, false);
                                    if rstMovProveedorFC.FindSet then
                                        repeat

                                            rstMovProveedorFC.CalcFields(Amount, rstMovProveedorFC."Remaining Amount", "Amount (LCY)", rstMovProveedorFC."Remaining Amt. (LCY)");

                                            Clear(rstLinDiaGenNCLic);
                                            rstLinDiaGenNCLic.SetRange(rstLinDiaGenNCLic."Journal Template Name", rstLinDiaGen."Journal Template Name");
                                            rstLinDiaGenNCLic.SetRange(rstLinDiaGenNCLic."Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                                            rstLinDiaGenNCLic.SetRange("Document No.", rstLinDiaGen."Document No.");
                                            rstLinDiaGenNCLic.SetRange(rstLinDiaGenNCLic."Applies-to Doc. No.", rstMovProveedorFC."Document No.");
                                            if rstLinDiaGenNCLic.FindFirst then begin

                                                Clear(rstCabNC);
                                                rstCabNC.Get(rstLinNC."Document No.");

                                                decImpoLiqNC := 0;
                                                decImpoLiqNC := rstMovProveedorFC."Purchase (LCY)" / rstMovProveedorFC."Amount (LCY)";

                                                Clear(rstFacturaBufferRT);
                                                rstFacturaBufferRT.SetRange("Tipo registro", rstFacturaBufferRT."Tipo registro"::Compra);
                                                rstFacturaBufferRT.SetRange("Cliente/Proveedor", rstProveedor."No.");
                                                rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. Factura", rstLinNC."Document No.");
                                                rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos");
                                                //rstFacturaBufferRT.SETRANGE("Cód. retención",rstCodRetencion."Cód. retención");
                                                rstFacturaBufferRT.SetRange("Cod. retencion", rstLinNC."Cód. retención IIBB");
                                                rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstLinDiaGen."Document No.");
                                                rstFacturaBufferRT.SetRange("Tipo fiscal", rstCabNC."VAT Bus. Posting Group");
                                                if not rstFacturaBufferRT.FindFirst then begin

                                                    rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Compra;
                                                    rstFacturaBufferRT."Cliente/Proveedor" := rstProveedor."No.";
                                                    //US.ARBU - 2005-08-03 - Inicio - Con ésta modificación, se modifica el sistema de c lculo de las NC's para
                                                    //                                que acumulen sobre el registro de buffer de la factura a que aplican
                                                    //rstFacturaBufferRT."No. Factura" := rstMovProveedorFC."Document no.";
                                                    //US.ARBU - 2005-08-03 - Fin - Con ésta modificación, se modifica el sistema de c lculo de las NC's para
                                                    //                                que acumulen sobre el registro de buffer de la factura a que aplican
                                                    rstFacturaBufferRT."No. Factura" := rstLinNC."Document No.";
                                                    rstFacturaBufferRT."Tipo factura" := rstFacturaBufferRT."Tipo factura"::"Nota d/c";
                                                    rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos";
                                                    rstFacturaBufferRT."Cod. retencion" := rstLinNC."Cód. retención IIBB";
                                                    //rstFacturaBufferRT."Cód. retención" := rstCodRetencion."Cód. retención";
                                                    rstFacturaBufferRT."No. documento" := rstLinDiaGen."Document No.";
                                                    rstFacturaBufferRT."Tipo fiscal" := rstCabNC."VAT Bus. Posting Group";
                                                    rstFacturaBufferRT."Serie retención" := '';
                                                    rstFacturaBufferRT."Fecha pago" := 0D;
                                                    rstFacturaBufferRT."Base pago retencion" := 0;
                                                    rstFacturaBufferRT."Pagos anteriores" := 0;
                                                    rstFacturaBufferRT."Importe retencion" := 0;
                                                    rstFacturaBufferRT."% retencion" := 0;
                                                    rstFacturaBufferRT.Provincia := '';
                                                    rstFacturaBufferRT."No. serie ganancias" := '';
                                                    rstFacturaBufferRT."No. serie IVA" := '';
                                                    rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                                                    rstFacturaBufferRT."Fecha factura" := 0D;
                                                    rstFacturaBufferRT.Nombre := '';
                                                    rstFacturaBufferRT."Importe neto factura" := 0;
                                                    //rstFacturaBufferRT."Factura liquidada" := rstMovProveedorFC."Document No.";
                                                    rstFacturaBufferRT."Factura liquidada" := rstLinNC."Document No.";
                                                    rstFacturaBufferRT.Insert;

                                                end;

                                                rstFacturaBufferRT."Fecha pago" := rstLinDiaGen."Posting Date";


                                                //Si la divisa de la factura es diferente a la divisa local, calculo el importe base a retener utilizando el factor
                                                //de divisa de la cabecera de compra.
                                                //Cambio de lógica. Siempre se paga la factura en pesos, as¡ que utilizo el tipo de cambio por el que se cargó la
                                                //factura para el c lculo de las retenciones.
                                                //++Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                                decTCambioPago := fntTipoCambioPago(rstLinDiaGenTemp, rstFacturaBufferRT."No. Factura");
                                                //--Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                                /*IF decTCambioPago <> 0 THEN
                                                IF rstCabNC."Currency Code" <> '' THEN
                                                //BEGIN

                                                  //decTCambioPago := 0;
                                                  //decTCambioPago := 1/rstCabNC."Currency Factor";
                                                  //decTCambioPago := 1/rstLinDiaGenTemp."Currency Factor";
                                                  rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)/rstCabNC."Currency Factor"
                                                ELSE
                                                */
                                                rstFacturaBufferRT."Importe neto factura" -= (rstLinNC.Amount) * decTCambioPago;
                                                rstFacturaBufferRT."Base pago retencion" -= (rstLinNC.Amount) * decTCambioPago;
                                                /*
                                            END
                                            ELSE
                                            BEGIN

                                              rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)*ABS(rstMovProveedorFC."Closed by Amount"/
                                                                                                                rstMovProveedor."Amount (LCY)");
                                              rstFacturaBufferRT."Base pago retencion" -= (rstLinNC.Amount)
                                              *ABS(rstMovProveedorFC."Closed by Amount"/rstMovProveedor."Amount (LCY)");

                                            END;
                                            */
                                                //Calculo el importe a retener. Para eso, busco la configuración de retenciones correcta

                                                CalcularImporteARetenerNCIIBB(rstLinNC, rstLinDiaGen, decImportePagosAnterioresIVA, rstFacturaBufferRT, rstCabNC);

                                            end;

                                        until rstMovProveedorFC.Next = 0;
                                    /*
                                    ELSE
                                    BEGIN

                                      CLEAR(rstMovProveedorFC);
                                      rstMovProveedorFC.SETRANGE("Entry No.",rstMovProveedor."Closed by Entry No.");
                                      rstMovProveedorFC.SETRANGE(Anulado,FALSE);
                                      IF rstMovProveedorFC.FINDSET THEN
                                      BEGIN

                                        rstMovProveedorFC.CALCFIELDS("Amount (LCY)",rstMovProveedorFC."Remaining Amt. (LCY)");

                                        CLEAR(rstLinDiaGenNCLic);
                                        rstLinDiaGenNCLic.SETRANGE("Journal Template Name",rstLinDiaGen."Journal Template Name");
                                        rstLinDiaGenNCLic.SETRANGE("Journal Batch Name",rstLinDiaGen."Journal Batch Name");
                                        rstLinDiaGenNCLic.SETRANGE("Document No.",rstLinDiaGen."Document No.");
                                        rstLinDiaGenNCLic.SETRANGE("Applies-to Doc. No.",rstMovProveedorFC."Document No.");
                                        IF rstLinDiaGenNCLic.FINDFIRST THEN
                                        BEGIN

                                          CLEAR(rstCabNC);
                                          rstCabNC.GET(rstLinNC."Document No.");

                                          decImpoLiqNC := 0;
                                          decImpoLiqNC := rstMovProveedorFC."Purchase (LCY)"/rstMovProveedorFC."Amount (LCY)";

                                          CLEAR(rstFacturaBufferRT);
                                          rstFacturaBufferRT.SETRANGE("Tipo registro",rstFacturaBufferRT."Tipo registro"::Compra);
                                          rstFacturaBufferRT.SETRANGE("Cliente/Proveedor",rstProveedor."No.");
                                          rstFacturaBufferRT.SETRANGE("No. Factura",rstLinNC."Document No.");
                                          rstFacturaBufferRT.SetRange("Tipo retencion",rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos");
                                          //rstFacturaBufferRT.SETRANGE("Cód. retención",rstCodRetencion."Cód. retención");
                                          rstFacturaBufferRT.SETRANGE("Cod. retencion",rstLinNC."Cód. retención IIBB");
                                          rstFacturaBufferRT.SETRANGE(rstFacturaBufferRT."No. documento",rstLinDiaGen."Document No.");
                                          rstFacturaBufferRT.SETRANGE("Tipo fiscal",rstCabNC."Tipo Fiscal");
                                          IF NOT rstFacturaBufferRT.FINDFIRST THEN
                                          BEGIN

                                            rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Compra;
                                            rstFacturaBufferRT."Cliente/Proveedor" := rstProveedor."No.";
                                            //US.ARBU - 2005-08-03 - Inicio - Con ésta modificación, se modifica el sistema de cálculo de las NC's para
                                            //                                que acumulen sobre el registro de buffer de la factura a que aplican
                                            //rstFacturaBufferRT."No. Factura" := rstMovProveedorFC."No. documento";
                                            //US.ARBU - 2005-08-03 - Fin - Con ésta modificación, se modifica el sistema de cálculo de las NC's para
                                            //                                que acumulen sobre el registro de buffer de la factura a que aplican
                                            rstFacturaBufferRT."No. Factura" := rstLinNC."Document No.";
                                            rstFacturaBufferRT."Tipo factura" := rstFacturaBufferRT."Tipo factura"::"Nota d/c";
                                            rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos";
                                            rstFacturaBufferRT."Cod. retencion" := rstLinNC."Cód. retención IIBB";
                                            rstFacturaBufferRT."No. documento" := rstLinDiaGen."Document No.";
                                            rstFacturaBufferRT."Tipo fiscal" := rstCabNC."Tipo Fiscal";
                                            rstFacturaBufferRT."Serie retención" := '';
                                            rstFacturaBufferRT."Fecha pago" := 0D;
                                            rstFacturaBufferRT."Base pago retencion" := 0;
                                            rstFacturaBufferRT."Pagos anteriores" := 0;
                                            rstFacturaBufferRT."Importe retencion" := 0;
                                            rstFacturaBufferRT."% retencion" := 0;
                                            rstFacturaBufferRT.Provincia := '';
                                            rstFacturaBufferRT."No. serie ganancias" := '';
                                            rstFacturaBufferRT."No. serie IVA" := '';
                                            rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                                            rstFacturaBufferRT."Fecha factura" := 0D;
                                            rstFacturaBufferRT.Nombre := '';
                                            rstFacturaBufferRT."Importe neto factura" := 0;
                                            //rstFacturaBufferRT."Factura liquidada" := rstMovProveedorFC."Document No.";
                                            rstFacturaBufferRT."Factura liquidada" := rstLinNC."Document No.";
                                            rstFacturaBufferRT.INSERT;

                                          END;

                                          rstFacturaBufferRT."Fecha pago" := rstLinDiaGen."Posting Date";


                                          //Si la divisa de la factura es diferente a la divisa local, calculo el importe base a retener utilizando el factor
                                          //de divisa de la cabecera de compra.
                                          //Cambio de lógica. Siempre se paga la factura en pesos, así que utilizo el tipo de cambio por el que se cargó la
                                          //factura para el cálculo de las retenciones.
                                          //++Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                          decTCambioPago := fntTipoCambioPago(rstLinDiaGen);
                                          //--Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                          //IF decTCambioPago <> 0 THEN
                                          IF rstCabNC."Currency Code" <> '' THEN
                                          //BEGIN

                                            //decTCambioPago := 0;
                                            //decTCambioPago := 1/rstCabNC."Currency Factor";
                                            //decTCambioPago := 1/rstLinDiaGenTemp."Currency Factor";
                                            {
                                            rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)/rstCabNC."Currency Factor"
                                          ELSE
                                          }
                                          rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)*decTCambioPago;
                                          rstFacturaBufferRT."Base pago retencion" -= (rstLinNC."Amount Including VAT"-rstLinNC."VAT Base Amount")
                                              *decTCambioPago;
                                              {
                                          END
                                          ELSE
                                          BEGIN

                                              rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)*ABS(rstMovProveedor."Closed by Amount"/
                                                                                                                rstMovProveedor."Amount (LCY)");
                                              rstFacturaBufferRT."Base pago retencion" -= (rstLinNC.Amount)
                                              *ABS(rstMovProveedor."Closed by Amount"/rstMovProveedor."Amount (LCY)");

                                          END;
                                          }
                                          //Calculo el importe a retener. Para eso, busco la configuración de retenciones correcta
                                          CalcularImporteARetenerNCIIBB(rstLinNC,rstLinDiaGen,decImportePagosAnterioresIVA,rstFacturaBufferRT,rstCabNC);

                                        END;

                                      END;

                                    END;*/

                                    //Test 02/11/2022
                                    /*
                                    CLEAR(rstMovProveedorFC);
                                    rstMovProveedorFC.SETRANGE("Entry No.",rstMovProveedor."Closed by Entry No.");
                                    rstMovProveedorFC.SETRANGE(Anulado,FALSE);
                                    IF rstMovProveedorFC.FINDSET THEN
                                    BEGIN

                                      rstMovProveedorFC.CALCFIELDS("Amount (LCY)",rstMovProveedorFC."Remaining Amt. (LCY)");

                                      CLEAR(rstLinDiaGenNCLic);
                                      rstLinDiaGenNCLic.SETRANGE("Journal Template Name",rstLinDiaGen."Journal Template Name");
                                      rstLinDiaGenNCLic.SETRANGE("Journal Batch Name",rstLinDiaGen."Journal Batch Name");
                                      rstLinDiaGenNCLic.SETRANGE("Document No.",rstLinDiaGen."Document No.");
                                      rstLinDiaGenNCLic.SETRANGE("Applies-to Doc. No.",rstMovProveedorFC."Document No.");
                                      IF rstLinDiaGenNCLic.FINDFIRST THEN
                                      BEGIN

                                        CLEAR(rstCabNC);
                                        rstCabNC.GET(rstLinNC."Document No.");

                                        decImpoLiqNC := 0;
                                        //decImpoLiqNC := {rstMovProveedorFC."Purchase (LCY)"/rstMovProveedorFC."Amount (LCY)"}rstMovProveedor."Closed by Amount (LCY)";
                                        decImpoLiqNC := {rstMovProveedorFC."Purchase (LCY)"/rstMovProveedorFC."Amount (LCY)"}rstMovProveedor."Closed by Amount (LCY)"/rstMovProveedorFC."Purchase (LCY)";
                                        decPorcentajePagado := ABS(rstMovProveedor."Closed by Amount"/rstMovProveedor.Amount);

                                        CLEAR(rstFacturaBufferRT);
                                        rstFacturaBufferRT.SETRANGE("Tipo registro",rstFacturaBufferRT."Tipo registro"::Compra);
                                        rstFacturaBufferRT.SETRANGE("Cliente/Proveedor",rstProveedor."No.");
                                        rstFacturaBufferRT.SETRANGE("No. Factura",rstLinNC."Document No.");
                                        rstFacturaBufferRT.SetRange("Tipo retencion",rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos");
                                        //rstFacturaBufferRT.SETRANGE("Cód. retención",rstCodRetencion."Cód. retención");
                                        rstFacturaBufferRT.SETRANGE("Cod. retencion",rstLinNC."Cód. retención IIBB");
                                        rstFacturaBufferRT.SETRANGE(rstFacturaBufferRT."No. documento",rstLinDiaGen."Document No.");
                                        rstFacturaBufferRT.SETRANGE("Tipo fiscal",rstCabNC."Tipo Fiscal");
                                        IF NOT rstFacturaBufferRT.FINDFIRST THEN
                                        BEGIN

                                          rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Compra;
                                          rstFacturaBufferRT."Cliente/Proveedor" := rstProveedor."No.";
                                          //US.ARBU - 2005-08-03 - Inicio - Con ésta modificación, se modifica el sistema de cálculo de las NC's para
                                          //                                que acumulen sobre el registro de buffer de la factura a que aplican
                                          //rstFacturaBufferRT."No. Factura" := rstMovProveedorFC."No. documento";
                                          //US.ARBU - 2005-08-03 - Fin - Con ésta modificación, se modifica el sistema de cálculo de las NC's para
                                          //                                que acumulen sobre el registro de buffer de la factura a que aplican
                                          rstFacturaBufferRT."No. Factura" := rstLinNC."Document No.";
                                          rstFacturaBufferRT."Tipo factura" := rstFacturaBufferRT."Tipo factura"::"Nota d/c";
                                          rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos";
                                          rstFacturaBufferRT."Cod. retencion" := rstLinNC."Cód. retención IIBB";
                                          rstFacturaBufferRT."No. documento" := rstLinDiaGen."Document No.";
                                          rstFacturaBufferRT."Tipo fiscal" := rstCabNC."Tipo Fiscal";
                                          rstFacturaBufferRT."Serie retención" := '';
                                          rstFacturaBufferRT."Fecha pago" := 0D;
                                          rstFacturaBufferRT."Base pago retencion" := 0;
                                          rstFacturaBufferRT."Pagos anteriores" := 0;
                                          rstFacturaBufferRT."Importe retencion" := 0;
                                          rstFacturaBufferRT."% retencion" := 0;
                                          rstFacturaBufferRT.Provincia := '';
                                          rstFacturaBufferRT."No. serie ganancias" := '';
                                          rstFacturaBufferRT."No. serie IVA" := '';
                                          rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                                          rstFacturaBufferRT."Fecha factura" := 0D;
                                          rstFacturaBufferRT.Nombre := '';
                                          rstFacturaBufferRT."Importe neto factura" := 0;
                                          //rstFacturaBufferRT."Factura liquidada" := rstMovProveedorFC."Document No.";
                                          rstFacturaBufferRT."Factura liquidada" := rstLinNC."Document No.";
                                          rstFacturaBufferRT.INSERT;

                                        END;

                                        rstFacturaBufferRT."Fecha pago" := rstLinDiaGen."Posting Date";


                                        //Si la divisa de la factura es diferente a la divisa local, calculo el importe base a retener utilizando el factor
                                        //de divisa de la cabecera de compra.
                                        //Cambio de lógica. Siempre se paga la factura en pesos, así que utilizo el tipo de cambio por el que se cargó la
                                        //factura para el cálculo de las retenciones.
                                        //++Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                        decTCambioPago := fntTipoCambioPago(rstLinDiaGenTemp,rstFacturaBufferRT."No. Factura");
                                        //--Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                        //IF decTCambioPago <> 0 THEN

                                        //IF rstCabNC."Currency Code" <> '' THEN
                                        //BEGIN

                                          //decTCambioPago := 0;
                                          //decTCambioPago := 1/rstCabNC."Currency Factor";
                                          //decTCambioPago := 1/rstLinDiaGenTemp."Currency Factor";
                                          {
                                          rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)/rstCabNC."Currency Factor"
                                        ELSE
                                        }

                                        rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)*decTCambioPago*decPorcentajePagado;
                                        rstFacturaBufferRT."Base pago retencion" -= (rstLinNC."Amount Including VAT"-rstLinNC."VAT Base Amount")
                                            *decTCambioPago*decPorcentajePagado;
                                            {
                                        END
                                        ELSE
                                        BEGIN

                                            rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)*ABS(rstMovProveedor."Closed by Amount"/
                                                                                                              rstMovProveedor."Amount (LCY)");
                                            rstFacturaBufferRT."Base pago retencion" -= (rstLinNC.Amount)
                                            *ABS(rstMovProveedor."Closed by Amount"/rstMovProveedor."Amount (LCY)");

                                        END;
                                        }
                                        //Calculo el importe a retener. Para eso, busco la configuración de retenciones correcta
                                        CalcularImporteARetenerNCIIBB(rstLinNC,rstLinDiaGen,decImportePagosAnterioresIVA,rstFacturaBufferRT,rstCabNC);

                                      END;

                                    END;
                                    */
                                    //END;

                                end
                                else begin

                                    Clear(rstLinDiaGenNCLic);
                                    rstLinDiaGenNCLic.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
                                    rstLinDiaGenNCLic.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                                    rstLinDiaGenNCLic.SetRange("Document No.", rstLinDiaGen."Document No.");
                                    rstLinDiaGenNCLic.SetRange("Applies-to Doc. No.", rstMovProveedorFC."Document No.");
                                    if rstLinDiaGenNCLic.FindFirst then begin

                                        Clear(rstCabNC);
                                        rstCabNC.Get(rstLinNC."Document No.");

                                        decImpoLiqNC := 0;
                                        decImpoLiqNC := 1;

                                        Clear(rstFacturaBufferRT);
                                        rstFacturaBufferRT.SetRange("Tipo registro", rstFacturaBufferRT."Tipo registro"::Compra);
                                        rstFacturaBufferRT.SetRange("Cliente/Proveedor", rstProveedor."No.");
                                        rstFacturaBufferRT.SetRange("No. Factura", rstLinNC."Document No.");
                                        rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos");
                                        //rstFacturaBufferRT.SETRANGE("Cód. retención",rstCodRetencion."Cód. retención");
                                        rstFacturaBufferRT.SetRange("Cod. retencion", rstLinNC."Cód. retención IIBB");
                                        rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstLinDiaGen."Document No.");
                                        rstFacturaBufferRT.SetRange("Tipo fiscal", rstCabNC."VAT Bus. Posting Group");
                                        if not rstFacturaBufferRT.FindFirst then begin

                                            rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Compra;
                                            rstFacturaBufferRT."Cliente/Proveedor" := rstProveedor."No.";
                                            //US.ARBU - 2005-08-03 - Inicio - Con ésta modificación, se modifica el sistema de cálculo de las NC's para
                                            //                                que acumulen sobre el registro de buffer de la factura a que aplican
                                            //rstFacturaBufferRT."No. Factura" := rstMovProveedorFC."No. documento";
                                            //US.ARBU - 2005-08-03 - Fin - Con ésta modificación, se modifica el sistema de cálculo de las NC's para
                                            //                                que acumulen sobre el registro de buffer de la factura a que aplican
                                            rstFacturaBufferRT."No. Factura" := rstLinNC."Document No.";
                                            rstFacturaBufferRT."Tipo factura" := rstFacturaBufferRT."Tipo factura"::"Nota d/c";
                                            rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos";
                                            rstFacturaBufferRT."Cod. retencion" := rstLinNC."Cód. retención IIBB";
                                            //rstFacturaBufferRT."Cód. retención" := rstCodRetencion."Cód. retención";
                                            rstFacturaBufferRT."No. documento" := rstLinDiaGen."Document No.";
                                            rstFacturaBufferRT."Tipo fiscal" := rstCabNC."VAT Bus. Posting Group";
                                            rstFacturaBufferRT."Serie retención" := '';
                                            rstFacturaBufferRT."Fecha pago" := 0D;
                                            rstFacturaBufferRT."Base pago retencion" := 0;
                                            rstFacturaBufferRT."Pagos anteriores" := 0;
                                            rstFacturaBufferRT."Importe retencion" := 0;
                                            rstFacturaBufferRT."% retencion" := 0;
                                            rstFacturaBufferRT.Provincia := '';
                                            rstFacturaBufferRT."No. serie ganancias" := '';
                                            rstFacturaBufferRT."No. serie IVA" := '';
                                            rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                                            rstFacturaBufferRT."Fecha factura" := 0D;
                                            rstFacturaBufferRT.Nombre := '';
                                            rstFacturaBufferRT."Importe neto factura" := 0;
                                            rstFacturaBufferRT."Factura liquidada" := rstLinNC."Document No.";
                                            rstFacturaBufferRT.Insert;

                                        end;

                                        rstFacturaBufferRT."Fecha pago" := rstLinDiaGen."Posting Date";


                                        //Si la divisa de la factura es diferente a la divisa local, calculo el importe base a retener utilizando el factor
                                        //de divisa de la cabecera de compra.
                                        //Cambio de lógica. Siempre se paga la factura en pesos, así que utilizo el tipo de cambio por el que se cargó la
                                        //factura para el cálculo de las retenciones.
                                        //++Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                        decTCambioPago := fntTipoCambioPago(rstLinDiaGenTemp, rstFacturaBufferRT."No. Factura");
                                        //--Arbu 2022 -- El tipo de cambio a utilizar debería ser el del pago
                                        //IF decTCambioPago <> 0 THEN
                                        //IF rstCabNC."Currency Code" <> '' THEN
                                        //BEGIN

                                        //decTCambioPago := 0;
                                        //decTCambioPago := 1/rstCabNC."Currency Factor";
                                        //decTCambioPago := 1/rstLinDiaGenTemp."Currency Factor";
                                        /*IF rstCabNC."Currency Code" <> '' THEN
                                          rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount)/rstCabNC."Currency Factor"
                                        ELSE
                                        */
                                        rstFacturaBufferRT."Importe neto factura" -= (rstLinNC.Amount) * decTCambioPago;
                                        rstFacturaBufferRT."Base pago retencion" -= (rstLinNC.Amount)
                                          * decTCambioPago;
                                        /*
                                    END
                                    ELSE
                                    BEGIN

                                      rstFacturaBufferRT."Importe neto factura"  -= (rstLinNC.Amount);
                                      rstFacturaBufferRT."Base pago retencion" -= (rstLinNC.Amount);

                                    END;
                                    */
                                        //Calculo el importe a retener. Para eso, busco la configuración de retenciones correcta
                                        CalcularImporteARetenerNCIIBB(rstLinNC, rstLinDiaGen, decImportePagosAnterioresIVA, rstFacturaBufferRT, rstCabNC);

                                    end;

                                end;

                                //IF NOT rstMovProveedorFC.GET(rstMovProveedor."Cerrado por nº orden") THEN
                                //  ERROR('Debe liquidar la Nota de Crédito N° %1',rstMovProveedor."No. documento");

                            end;

                        //Si esta es la primera vez que se inserta la factura en la tabla, entonces limpio el resto de los campos

                        until rstLinNC.Next = 0;
                end;

            until rstLinDiaGenTemp.Next = 0;

        //Insertamos el cálculo en el diario de pagos

        CrearDiarioPagosIIBB(rstLinDiaGen);

        //END;

    end;

    [Scope('OnPrem')]
    procedure CalcularPagosAnterioresIIBB(rstFacturaBuffer: Record "Invoice Withholding Buffer"): Decimal
    var
        rstConfiguracionRetenciones: Record "Withholding setup";
        rstTotalPagos: Record "Invoice Withholding Buffer";
        datInicioMes: Date;
        datFinMes: Date;
        rstFactura: Record "Purch. Inv. Line";
        rstNCredito: Record "Purch. Cr. Memo Line";
        rstPagosBuffer: Record "Invoice Withholding Buffer";
        rstAcumuladoBuffer: Record "Invoice Withholding Buffer";
        decImporte: Decimal;
    begin
        //CalcularPagosAnterioresIIBB

        Clear(rstPagosBuffer);
        decImporte := 0;
        rstPagosBuffer.SetCurrentKey(rstPagosBuffer."Cliente/Proveedor", rstPagosBuffer."No. Factura", rstPagosBuffer."Tipo retencion",
                                     rstPagosBuffer."Cod. retencion", rstPagosBuffer."Tipo fiscal");
        rstPagosBuffer.SetRange("Cliente/Proveedor", rstFacturaBuffer."Cliente/Proveedor");
        rstPagosBuffer.SetRange("No. Factura", rstFacturaBuffer."No. Factura");
        rstPagosBuffer.SetFilter("No. documento", '<>%1', rstFacturaBuffer."No. documento");
        rstPagosBuffer.SetRange("Tipo retencion", rstFacturaBuffer."Tipo retencion");
        rstPagosBuffer.SetRange("Cod. retencion", rstFacturaBuffer."Cod. retencion");
        rstPagosBuffer.SetRange("Tipo fiscal", rstFacturaBuffer."Tipo fiscal");
        rstPagosBuffer.SetFilter(rstPagosBuffer."No. documento", '<>%1', rstFacturaBuffer."No. documento");
        if rstPagosBuffer.FindFirst then
            repeat

                decImporte += rstPagosBuffer."Importe retencion";

            until rstPagosBuffer.Next = 0;

        exit(decImporte);
    end;

    [Scope('OnPrem')]
    procedure CalcularImporteARetenerIIBB(rstLinFacturaL: Record "Purch. Inv. Line"; rstLinDiaGenL: Record "Gen. Journal Line"; decImportePagosAnterioresIVAL: Decimal; var rstFacturaBufferRTL: Record "Invoice Withholding Buffer"; rstCabFacturaL: Record "Purch. Inv. Header"): Decimal
    var
        rstCodigosRetencion: Record "Withholding codes";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstExencion: Record "Withholding details";
        rstProveedor: Record Vendor;
        rstAccionEstFis: Record "Acción estado sit. fiscal";
        int80or100: Integer;
    begin
        //CalcularImporteARetenerIIBB

        rstProveedor.Get(rstLinFacturaL."Buy-from Vendor No.");
        Clear(rstCodigosRetencion);
        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstLinDiaGenL."Posting Date", 0D);
        rstCodigosRetencion.SetRange(rstCodigosRetencion."Tipo impuesto retencion",
                                     rstCodigosRetencion."Tipo impuesto retencion"::"Ingresos Brutos");
        rstCodigosRetencion.SetRange("Cod. retencion", rstLinFacturaL."Cód. retención IIBB");
        if rstCodigosRetencion.FindFirst then begin

            if ((rstCodigosRetencion."Valid to" <> 0D) and
               (rstLinDiaGenL."Posting Date" <= rstCodigosRetencion."Valid to")) or
               (rstCodigosRetencion."Valid to" = 0D) then begin

                Clear(rstConfiguracionRetencion);
                rstConfiguracionRetencion.SetRange("Tipo retenciones", rstConfiguracionRetencion."Tipo retenciones"::"Ingresos Brutos");
                rstConfiguracionRetencion.SetRange("Cod. retencion", rstCodigosRetencion."Cod. retencion");
                rstConfiguracionRetencion.SetRange("Tipo fiscal", rstFacturaBufferRTL."Tipo fiscal");
                if rstConfiguracionRetencion.FindFirst then begin

                    //Si el proveedor tiene un certificado de exclusión vigente

                    Clear(rstExencion);
                    rstExencion.SetRange("Tipo registro", rstExencion."Tipo registro"::Compra);
                    rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                    rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::"Ingresos Brutos");
                    rstExencion.SetRange("Cód. retención", rstLinFacturaL."Cód. retención IIBB");
                    rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    //rstExencion.SETFILTER("Fecha efectividad retencion",'>=%1',rstLinDiaGenL."Posting Date");
                    rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                    /*IF rstExencion.FINDLAST AND {(rstExencion."Fecha documento" <= rstLinDiaGenL."Posting Date") AND}
                    (rstExencion."Fecha efectividad retencion" >= rstLinDiaGenL."Posting Date") THEN
                    */
                    //IF rstExencion.FINDLAST AND (rstExencion."Fecha efectividad retencion" >= rstLinDiaGenL."Posting Date") THEN
                    begin

                        rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                                                   rstExencion."% retencion"
                                                                   //fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                                   ) / 100) - decImportePagosAnterioresIVAL;
                        rstFacturaBufferRTL."% retencion" := rstExencion."% retencion";
                        rstFacturaBufferRTL.Excluido := 0;
                        rstFacturaBufferRTL."% Exclusion" := 0;
                        rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                    end
                    else begin

                        if rstExencion.FindLast and (not rstConfiguracionRetencion."Skip exclusions") and (rstExencion."Fecha efectividad retencion" < rstLinDiaGenL."Posting Date") then
                            /*ERROR('El padrón registrado para el proveedor %1, %2, ha vencido. \'+
                            'Por favor, actualice el padrón, o elimínelo de la configuración del proveedor.',
                            ",rstProveedor.Name)*/
                                        fntConfirmaExencionAntigua(rstExencion, rstProveedor)

                        else begin

                            rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                            //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                            fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                            ) / 100) - decImportePagosAnterioresIVAL;
                            rstFacturaBufferRTL."% retencion" := rstConfiguracionRetencion."% retencion";
                            rstFacturaBufferRTL.Excluido := 0;
                            rstFacturaBufferRTL."% Exclusion" := 0;
                            rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                        end;

                    end;

                end;

            end
            else
                Error('El código de retención ' + rstCodigosRetencion."Cod. retencion" + ', tipo de impuesto ' + Format(rstCodigosRetencion."Tipo impuesto retencion") + ', del documento ' + rstLinDiaGenL."Applies-to Doc. No." + ', no está activo a esta fecha.')

        end;

        //Completo la línea de retención con la información de la retención

        rstFacturaBufferRTL.Provincia := rstLinFacturaL.Area;
        rstFacturaBufferRTL."No. serie IVA" := '';
        rstFacturaBufferRTL."Fecha factura" := rstCabFacturaL."Document Date";
        if not rstFacturaBufferRTL.Insert then
            rstFacturaBufferRTL.Modify;

    end;

    [Scope('OnPrem')]
    procedure CalcularImporteARetenerNCIIBB(rstLinFacturaL: Record "Purch. Cr. Memo Line"; rstLinDiaGenL: Record "Gen. Journal Line"; decImportePagosAnterioresIVAL: Decimal; var rstFacturaBufferRTL: Record "Invoice Withholding Buffer"; rstCabFacturaL: Record "Purch. Cr. Memo Hdr."): Decimal
    var
        rstCodigosRetencion: Record "Withholding codes";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstExencion: Record "Withholding details";
        rstProveedor: Record Vendor;
        rstAccionEstFis: Record "Acción estado sit. fiscal";
        int80or100: Integer;
        rstNC: Record "Purch. Cr. Memo Hdr.";
        rstFC: Record "Purch. Inv. Header";
        rstInBFNC: Record "Invoice Withholding Buffer";
    begin
        //CalcularImporteARetenerIIBB

        rstProveedor.Get(rstLinFacturaL."Buy-from Vendor No.");
        Clear(rstCodigosRetencion);
        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstLinDiaGenL."Posting Date", 0D);
        rstCodigosRetencion.SetRange(rstCodigosRetencion."Tipo impuesto retencion",
                                     rstCodigosRetencion."Tipo impuesto retencion"::"Ingresos Brutos");
        rstCodigosRetencion.SetRange("Cod. retencion", rstLinFacturaL."Cód. retención IIBB");
        if rstCodigosRetencion.FindFirst then begin

            if ((rstCodigosRetencion."Valid to" <> 0D) and
               (rstLinDiaGenL."Posting Date" <= rstCodigosRetencion."Valid to")) or
               (rstCodigosRetencion."Valid to" = 0D) then begin

                Clear(rstConfiguracionRetencion);
                rstConfiguracionRetencion.SetRange("Tipo retenciones", rstConfiguracionRetencion."Tipo retenciones"::"Ingresos Brutos");
                rstConfiguracionRetencion.SetRange("Cod. retencion", rstCodigosRetencion."Cod. retencion");
                rstConfiguracionRetencion.SetRange("Tipo fiscal", rstFacturaBufferRTL."Tipo fiscal");
                if rstConfiguracionRetencion.FindFirst then begin

                    //Si el proveedor tiene un certificado de exclusión vigente

                    Clear(rstNC);
                    rstNC.SetRange(rstNC."No.", rstFacturaBufferRTL."No. Factura");
                    if rstNC.FindFirst then;
                    rstNC.CalcFields(Amount);
                    if rstNC."Applies-to Doc. No." <> '' then begin

                        Clear(rstFC);
                        rstFC.Get(rstNC."Applies-to Doc. No.");


                    end
                    else begin

                        Clear(rstInBFNC);
                        rstInBFNC.SetRange("No. documento", rstFacturaBufferRTL."No. documento");
                        rstInBFNC.SetRange("Tipo retencion", rstFacturaBufferRTL."Tipo factura"::Factura);
                        rstInBFNC.SetRange("Tipo retencion", rstFacturaBufferRTL."Tipo retencion"::"Ingresos Brutos");
                        rstInBFNC.SetRange(Retenido, true);
                        if rstInBFNC.FindFirst then begin

                            Clear(rstFC);
                            rstFC.Get(rstInBFNC."No. Factura");

                        end;

                    end;

                    rstFC.CalcFields(Amount);

                    Clear(rstExencion);
                    rstExencion.SetRange("Tipo registro", rstExencion."Tipo registro"::Compra);
                    rstExencion.SetRange("Cod. proveedor/cliente", rstProveedor."No.");
                    rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::"Ingresos Brutos");
                    rstExencion.SetRange("Cód. retención", rstLinFacturaL."Cód. retención IIBB");
                    rstExencion.SetFilter("Fecha documento", '<=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstLinDiaGenL."Posting Date", 0D);
                    if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) and (rstFC.Amount <> rstNC.Amount) then
                    //rstExencion.SETFILTER("Fecha efectividad retencion",'>=%1',rstLinDiaGenL."Posting Date");
                    //IF rstExencion.FINDLAST AND (rstFC.Amount <> rstNC.Amount) THEN
                    begin

                        rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                                                   rstExencion."% retencion"
                                                                   //fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                                                   ) / 100) - decImportePagosAnterioresIVAL;
                        rstFacturaBufferRTL."% retencion" := rstExencion."% retencion";
                        rstFacturaBufferRTL.Excluido := 0;
                        rstFacturaBufferRTL."% Exclusion" := 0;
                        rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                    end
                    else begin

                        if rstExencion.FindLast and (not rstConfiguracionRetencion."Skip exclusions") and (rstExencion."Fecha efectividad retencion" < rstLinDiaGenL."Posting Date") then
                            /*ERROR('El padrón registrado para el proveedor %1, %2, ha vencido. \'+
                            'Por favor, actualice el padrón, o elimínelo de la configuración del proveedor.',
                            ",rstProveedor.Name)*/
                                        fntConfirmaExencionAntigua(rstExencion, rstProveedor)

                        else begin

                            if (rstFC.Amount <> rstNC.Amount) then begin

                                rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                                fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                                ) / 100) - decImportePagosAnterioresIVAL;
                                rstFacturaBufferRTL."% retencion" := rstConfiguracionRetencion."% retencion";
                                rstFacturaBufferRTL.Excluido := 0;
                                rstFacturaBufferRTL."% Exclusion" := 0;
                                rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                            end;

                        end;

                    end;

                end;

            end
            else
                Error('El código de retención ' + rstCodigosRetencion."Cod. retencion" + ', tipo de impuesto ' + Format(rstCodigosRetencion."Tipo impuesto retencion") + ', del documento ' + rstLinDiaGenL."Applies-to Doc. No." + ', no está activo a esta fecha.')

        end;

        //Completo la línea de retención con la información de la retención

        //rstFacturaBufferRTL."% retencion" := rstConfiguracionRetencion."% retencion";
        rstFacturaBufferRTL.Provincia := rstLinFacturaL.Area;
        rstFacturaBufferRTL."No. serie IVA" := '';
        rstFacturaBufferRTL."Fecha factura" := rstCabFacturaL."Document Date";
        if not rstFacturaBufferRTL.Insert then
            rstFacturaBufferRTL.Modify;

    end;

    [Scope('OnPrem')]
    procedure CrearDiarioPagosIIBB(var rstLinDiaGen: Record "Gen. Journal Line")
    var
        rstHisCFacComp: Record "Purch. Inv. Header";
        intMotivoExclusion: Integer;
        rstCodigosRetencion: Record "Withholding codes";
        rstFacturaBufferRT2: Record "Invoice Withholding Buffer";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstLinDiaGen2: Record "Gen. Journal Line";
        rstLinDiaGenTemp: Record "Gen. Journal Line";
        rstHisCNC: Record "Purch. Cr. Memo Hdr.";
        rstFacturaBufferRT: Record "Invoice Withholding Buffer";
        codNoSerieCertificado: Code[20];
        rstConfCont: Record "General Ledger Setup";
        cduGestionNoSerie: Codeunit "No. Series";
        rstMovProveedor: Record "Vendor Ledger Entry";
    begin
        //CrearDiarioPagosIIBB


        Clear(rstFacturaBufferRT);
        CalcularTotalRetenido(rstLinDiaGen."Document No.", rstLinDiaGen."Applies-to Doc. No.");
        rstFacturaBufferRT.SetCurrentKey(rstFacturaBufferRT."No. documento");
        rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstLinDiaGen."Document No.");
        rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos");
        rstFacturaBufferRT.SetFilter("Importe retencion", '<>0');
        if rstFacturaBufferRT.FindFirst then
            repeat

                rstFacturaBufferRT."Importe retencion" := Round(rstFacturaBufferRT."Importe retencion", 0.01);
                rstFacturaBufferRT.CalcFields(rstFacturaBufferRT."Importe retencion total", "Importe retenido real",
                                              rstFacturaBufferRT."Importe minimo pago", rstFacturaBufferRT."Importe minimo retención");

                if rstFacturaBufferRT."Tipo factura" = rstFacturaBufferRT."Tipo factura"::Factura then begin

                    Clear(rstMovProveedor);
                    rstMovProveedor.SetCurrentKey(rstMovProveedor."Vendor No.", rstMovProveedor."Document No.");
                    rstMovProveedor.SetRange("Vendor No.", rstFacturaBufferRT."Cliente/Proveedor");
                    rstMovProveedor.SetRange("Document No.", rstFacturaBufferRT."Factura liquidada");
                    rstMovProveedor.FindFirst;

                    if intMotivoExclusion = 0 then begin

                        Clear(rstCodigosRetencion);
                        rstCodigosRetencion.SetRange("Tipo impuesto retencion", rstCodigosRetencion."Tipo impuesto retencion"::"Ingresos Brutos");
                        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstLinDiaGen."Posting Date", 0D);
                        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstLinDiaGen."Posting Date", 0D);
                        rstCodigosRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                        //IF rstCodigosRetencion.GET(rstCodigosRetencion."Tipo impuesto retencion"::IVA,rstLinFacturaL."Cód. retención IVA") THEN
                        if rstCodigosRetencion.FindFirst then begin

                            Clear(rstConfiguracionRetencion);
                            rstConfiguracionRetencion.SetRange("Tipo retenciones", rstFacturaBufferRT."Tipo retencion");
                            rstConfiguracionRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                            //      2023-07-04
                            rstConfiguracionRetencion.SetRange("Tipo fiscal", rstFacturaBufferRT."Tipo fiscal");
                            if rstConfiguracionRetencion.FindFirst then begin

                                if rstFacturaBufferRT."Base pago retencion"/*rstFacturaBufferRT."Importe retenido real"*/ >= rstConfiguracionRetencion."Importe pago minimo" then begin

                                    Clear(rstLinDiaGen2);
                                    rstLinDiaGen2.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
                                    rstLinDiaGen2.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                                    //rstLinDiaGen2.SETRANGE("No. documento",rstLinDiaGen."No. documento");
                                    if rstLinDiaGen2.FindLast then;
                                    Clear(rstLinDiaGenTemp);
                                    rstLinDiaGenTemp."Journal Template Name" := rstLinDiaGen."Journal Template Name";
                                    rstLinDiaGenTemp."Journal Batch Name" := rstLinDiaGen."Journal Batch Name";
                                    rstLinDiaGenTemp."Posting Date" := rstLinDiaGen."Posting Date";
                                    rstLinDiaGenTemp."Posting No. Series" := rstLinDiaGen."Posting No. Series";
                                    rstLinDiaGenTemp."Due Date" := Today;
                                    rstLinDiaGenTemp."Document No." := rstLinDiaGen."Document No.";
                                    rstLinDiaGenTemp."Line No." := rstLinDiaGen2."Line No." + 1;
                                    rstLinDiaGenTemp."Transaction No." := rstLinDiaGen."Transaction No.";
                                    rstLinDiaGenTemp.Validate("Account No.");
                                    if rstLinDiaGenTemp."Shortcut Dimension 1 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 1 Code", rstLinDiaGen."Shortcut Dimension 1 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 2 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 2 Code", rstLinDiaGen."Shortcut Dimension 2 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 3 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 3 Code", rstLinDiaGen."Shortcut Dimension 3 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 4 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 4 Code", rstLinDiaGen."Shortcut Dimension 4 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 5 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 5 Code", rstLinDiaGen."Shortcut Dimension 5 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 6 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 6 Code", rstLinDiaGen."Shortcut Dimension 6 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 7 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 7 Code", rstLinDiaGen."Shortcut Dimension 7 Code");
                                    rstLinDiaGenTemp."No. cheque" := rstLinDiaGen."No. cheque";
                                    rstLinDiaGenTemp."Due Date" := rstLinDiaGen."Due Date";
                                    rstLinDiaGenTemp."Document Type" := rstLinDiaGenTemp."Document Type"::Payment;
                                    rstLinDiaGenTemp."Account Type" := rstLinDiaGenTemp."Account Type"::"G/L Account";
                                    Clear(rstConfCont);
                                    rstConfCont.Get();

                                    case rstFacturaBufferRT."Tipo retencion" of
                                        rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos":
                                            begin
                                                rstLinDiaGenTemp."Account No." := rstConfCont."GI withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. Ingresos Brutos ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;
                                        rstFacturaBufferRT."Tipo retencion"::Ganancias:
                                            begin
                                                rstLinDiaGenTemp."Account No." := rstConfCont."Winnings withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. Gan. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;
                                        rstFacturaBufferRT."Tipo retencion"::IVA:
                                            begin
                                                rstLinDiaGenTemp."Account No." := rstConfCont."VAT withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. IVA ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;
                                    end;
                                    /*
                                    rstLinDiaGenTemp.validate("Currency Code",rstLinDiaGen."Currency Code");
                                    rstLinDiaGenTemp.validate("Currency factor",rstLinDiaGen."Currency factor");
                                    */
                                    rstLinDiaGenTemp.Validate("Account No.");
                                    rstLinDiaGenTemp."Factor divisa operacion" := rstLinDiaGen."Factor divisa operacion";
                                    rstLinDiaGenTemp."Valor divisa operacion" := rstLinDiaGen."Valor divisa operacion";
                                    rstLinDiaGenTemp.Validate(Amount, -rstFacturaBufferRT."Importe retencion");
                                    rstLinDiaGenTemp."Descripción 2" := rstFacturaBufferRT."No. Factura";
                                    rstLinDiaGenTemp."External Document No." := rstMovProveedor."External Document No.";
                                    rstLinDiaGenTemp.Retención := true;
                                    rstFacturaBufferRT.Retenido := true;
                                    Clear(rstConfCont);
                                    rstConfCont.Get();

                                    rstFacturaBufferRT.Modify;

                                    if not rstLinDiaGenTemp.Insert then
                                        rstLinDiaGenTemp.Modify;

                                end
                                else begin

                                    rstFacturaBufferRT.Excluido := 3;
                                    rstFacturaBufferRT.Modify;

                                end;

                            end;

                        end;

                    end
                    else begin

                        rstFacturaBufferRT.Excluido := intMotivoExclusion;
                        rstFacturaBufferRT.Modify;

                    end;

                end;


                if rstFacturaBufferRT."Tipo factura" = rstFacturaBufferRT."Tipo factura"::"Nota d/c" then begin

                    Clear(rstHisCNC);
                    rstHisCNC.Get(rstFacturaBufferRT."No. Factura");
                    if intMotivoExclusion = 0 then begin

                        Clear(rstCodigosRetencion);
                        rstCodigosRetencion.SetRange("Tipo impuesto retencion", rstCodigosRetencion."Tipo impuesto retencion"::"Ingresos Brutos");
                        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstLinDiaGen."Posting Date", 0D);
                        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstLinDiaGen."Posting Date", 0D);
                        rstCodigosRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                        //IF rstCodigosRetencion.GET(rstCodigosRetencion."Tipo impuesto retencion"::IVA,rstLinFacturaL."Cód. retención IVA") THEN
                        if rstCodigosRetencion.FindFirst then begin

                            Clear(rstConfiguracionRetencion);
                            rstConfiguracionRetencion.SetRange("Tipo retenciones", rstFacturaBufferRT."Tipo retencion");
                            rstConfiguracionRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                            if rstConfiguracionRetencion.FindFirst then begin

                                if Abs(rstFacturaBufferRT."Base pago retencion")/*ABS(rstFacturaBufferRT."Importe retenido real")*/ >= rstConfiguracionRetencion."Importe min. retencion" then begin

                                    Clear(rstLinDiaGen2);
                                    rstLinDiaGen2.SetRange("Journal Template Name", rstLinDiaGen."Journal Template Name");
                                    rstLinDiaGen2.SetRange("Journal Batch Name", rstLinDiaGen."Journal Batch Name");
                                    //rstLinDiaGen2.SETRANGE("No. documento",rstLinDiaGen."No. documento");
                                    if rstLinDiaGen2.FindLast then;
                                    Clear(rstLinDiaGenTemp);
                                    rstLinDiaGenTemp."Journal Template Name" := rstLinDiaGen."Journal Template Name";
                                    rstLinDiaGenTemp."Journal Batch Name" := rstLinDiaGen."Journal Batch Name";
                                    rstLinDiaGenTemp."Posting Date" := rstLinDiaGen."Posting Date";
                                    rstLinDiaGenTemp."Posting No. Series" := rstLinDiaGen."Posting No. Series";
                                    rstLinDiaGenTemp."Due Date" := Today;
                                    rstLinDiaGenTemp."Document No." := rstLinDiaGen."Document No.";
                                    rstLinDiaGenTemp."Line No." := rstLinDiaGen2."Line No." + 1;
                                    rstLinDiaGenTemp."Due Date" := rstLinDiaGen."Due Date";
                                    rstLinDiaGenTemp."Transaction No." := rstLinDiaGen."Transaction No.";
                                    rstLinDiaGenTemp.Validate("Account No.");
                                    if rstLinDiaGenTemp."Shortcut Dimension 1 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 1 Code", rstLinDiaGen."Shortcut Dimension 1 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 2 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 2 Code", rstLinDiaGen."Shortcut Dimension 2 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 3 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 3 Code", rstLinDiaGen."Shortcut Dimension 3 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 4 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 4 Code", rstLinDiaGen."Shortcut Dimension 4 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 5 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 5 Code", rstLinDiaGen."Shortcut Dimension 5 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 6 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 6 Code", rstLinDiaGen."Shortcut Dimension 6 Code");
                                    if rstLinDiaGenTemp."Shortcut Dimension 7 Code" = '' then
                                        rstLinDiaGenTemp.Validate("Shortcut Dimension 7 Code", rstLinDiaGen."Shortcut Dimension 7 Code");
                                    rstLinDiaGenTemp."No. cheque" := rstLinDiaGen."No. cheque";
                                    rstLinDiaGenTemp."Document Type" := rstLinDiaGenTemp."Document Type"::Payment;
                                    rstLinDiaGenTemp."Account Type" := rstLinDiaGenTemp."Account Type"::"G/L Account";
                                    Clear(rstConfCont);
                                    rstConfCont.Get();

                                    case rstFacturaBufferRT."Tipo retencion" of
                                        rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos":
                                            begin
                                                rstLinDiaGenTemp."Account No." := rstConfCont."GI withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. Ingresos Brutos ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                rstLinDiaGenTemp."External Document No." := rstHisCNC."Vendor Cr. Memo No.";
                                            end;
                                        rstFacturaBufferRT."Tipo retencion"::Ganancias:
                                            begin
                                                rstLinDiaGenTemp."Account No." := rstConfCont."Winnings withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. Gan. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;
                                        rstFacturaBufferRT."Tipo retencion"::"Seguridad Social":
                                            begin
                                                rstLinDiaGenTemp."Account No." := rstConfCont."SS withholding account";
                                                rstLinDiaGenTemp.Description := CopyStr('Ret. SS. ' + rstCodigosRetencion.Descripcion, 1, 50);
                                            end;

                                    end;
                                    rstLinDiaGenTemp.Validate("Account No.");
                                    rstLinDiaGenTemp.Validate(Amount, -rstFacturaBufferRT."Importe retencion");
                                    rstLinDiaGenTemp."Descripción 2" := rstFacturaBufferRT."No. Factura";
                                    rstLinDiaGenTemp."External Document No." := rstMovProveedor."External Document No.";
                                    rstLinDiaGenTemp."Factor divisa operacion" := rstLinDiaGen."Factor divisa operacion";
                                    rstLinDiaGenTemp."Valor divisa operacion" := rstLinDiaGen."Valor divisa operacion";
                                    rstLinDiaGenTemp.Retención := true;
                                    rstFacturaBufferRT.Retenido := true;

                                    Clear(rstConfCont);
                                    rstConfCont.Get();

                                    rstFacturaBufferRT.Modify;

                                    if not rstLinDiaGenTemp.Insert then
                                        rstLinDiaGenTemp.Modify;

                                end
                                else begin

                                    rstFacturaBufferRT.Excluido := 3;
                                    rstFacturaBufferRT.Modify;

                                end;

                            end;

                        end;

                    end
                    else begin

                        rstFacturaBufferRT.Excluido := intMotivoExclusion;
                        rstFacturaBufferRT.Modify;

                    end;

                end;

            until rstFacturaBufferRT.Next = 0;

    end;

    local procedure fntConfirmaExencionAntigua(rstExencion: Record "Withholding details"; rstProveedor: Record Vendor)
    begin
        if not Confirm('El certificado de Exención del proveedor ' + rstExencion."Cod. proveedor/cliente" + ', ' + rstProveedor.Name + ', ha vencido. \' +
        '¿Desea proceder con el pago?')
        then
            Error('Se ha detenido el proceso.');
    end;

    local procedure "**PERCEPCIONES**"()
    begin
    end;

    [Scope('OnPrem')]
    procedure CalcularPercepcionIIBB(var rstCabVenta: Record "Sales Header"; rstCliente: Record Customer)
    var
        rstCabFactura: Record "Sales Header";
        rstLinFactura: Record "Sales Line";
        rstFacturaBufferRT: Record "Invoice Withholding Buffer";
        decImportePagosAnterioresIVA: Decimal;
        rstExencion: Record "Withholding details";
        rstWS: Record "Withholding setup";
        rstMovIva: Record "VAT Entry";
        rstCodRetencion: Record "Withholding codes";
        cduGestionNoSerie: Codeunit "No. Series";
        rstConfCont: Record "General Ledger Setup";
        codNoSerieCertificado: Code[20];
        blnRetenido: Boolean;
        rstMovProveedor: Record "Cust. Ledger Entry";
        rstMovProveedorFC: Record "Cust. Ledger Entry";
        decImpoLiqNC: Decimal;
    begin
        //CalcularPercepcionIIBB

        Clear(rstFacturaBufferRT);
        rstFacturaBufferRT.SetCurrentKey("No. documento");
        rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstCabVenta."No.");
        rstFacturaBufferRT.DeleteAll;

        Clear(rstWS);
        rstWS.SetRange("Tipo retenciones", rstWS."Tipo retenciones"::"Ingresos Brutos");
        rstWS.SetRange("Tipo base retencion", rstWS."Tipo base retencion"::"Subtotal factura");
        if rstWS.FindSet then
            repeat

                Clear(rstLinFactura);
                rstLinFactura.SetRange("Document Type", rstCabVenta."Document Type");
                rstLinFactura.SetRange("Document No.", rstCabVenta."No.");
                rstLinFactura.SetRange("Cód. ingresos brutos", rstWS."Cod. retencion");
                if rstLinFactura.FindSet then
                    repeat

                        Clear(rstFacturaBufferRT);
                        rstFacturaBufferRT.SetRange("Tipo registro", rstFacturaBufferRT."Tipo registro"::Venta);
                        rstFacturaBufferRT.SetRange("Cliente/Proveedor", rstCliente."No.");
                        rstFacturaBufferRT.SetRange("No. Factura", rstLinFactura."Document No.");
                        rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos");
                        rstFacturaBufferRT.SetRange("Cod. retencion", rstWS."Cod. retencion");
                        rstFacturaBufferRT.SetRange("No. documento", rstLinFactura."Document No.");

                        //Si esta es la primera vez que se inserta la factura en la tabla, entonces limpio el resto de los campos

                        if not rstFacturaBufferRT.FindFirst then begin

                            rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Venta;
                            rstFacturaBufferRT."Cliente/Proveedor" := rstCliente."No.";
                            rstFacturaBufferRT."No. Factura" := rstLinFactura."Document No.";
                            rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos";
                            rstFacturaBufferRT."Cod. retencion" := rstWS."Cod. retencion";
                            rstFacturaBufferRT."No. documento" := rstLinFactura."Document No.";
                            rstFacturaBufferRT."Serie retención" := '';
                            rstFacturaBufferRT."Fecha pago" := rstCabVenta."Posting Date";
                            rstFacturaBufferRT."Tipo fiscal" := rstCliente."VAT Bus. Posting Group";
                            rstFacturaBufferRT."Base pago retencion" := 0;
                            rstFacturaBufferRT."Pagos anteriores" := 0;
                            rstFacturaBufferRT."Importe retencion" := 0;
                            rstFacturaBufferRT."% retencion" := 0;
                            rstFacturaBufferRT.Provincia := '';
                            rstFacturaBufferRT."No. serie ganancias" := '';
                            rstFacturaBufferRT."No. serie IVA" := '';
                            rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                            rstFacturaBufferRT."Fecha factura" := 0D;
                            rstFacturaBufferRT.Nombre := '';
                            rstFacturaBufferRT."Importe neto factura" := 0;
                            rstFacturaBufferRT."Factura liquidada" := rstLinFactura."Document No.";
                            rstFacturaBufferRT.Insert;

                        end;

                        Clear(rstCabFactura);
                        rstCabFactura.Get(rstCabFactura."Document Type"::Invoice, rstLinFactura."Document No.");

                        //Si la divisa de la factura es diferente a la divisa local, calculo el importe base a retener utilizando el factor
                        //de divisa de la cabecera de compra.
                        //Cambio de lógica. Siempre se paga la factura en pesos, así que utilizo el tipo de cambio por el que se cargó la
                        //factura para el cálculo de las retenciones.

                        if (decTCambioPago <> 0) and
                        (rstCabFactura."Currency Code" <> '') then begin

                            decTCambioPago := 0;
                            decTCambioPago := 1 / rstCabFactura."Currency Factor";
                            rstFacturaBufferRT."Importe neto factura" += (rstLinFactura.Amount)
                              * decTCambioPago;
                            rstFacturaBufferRT."Base pago retencion" += (rstLinFactura."Amount Including VAT" - rstLinFactura."VAT Base Amount")
                              * decTCambioPago;

                        end
                        else begin

                            rstFacturaBufferRT."Importe neto factura" += (rstLinFactura.Amount);
                            rstFacturaBufferRT."Base pago retencion" += (rstLinFactura."Amount Including VAT" - rstLinFactura."VAT Base Amount");

                        end;

                        rstFacturaBufferRT.Modify;

                    until rstLinFactura.Next = 0;

                //Calculo el importe a retener. Para eso, busco la configuración de retenciones correcta
                CalcularImporteAPercibirIIBB(rstLinFactura, rstFacturaBufferRT, rstCabFactura);
                CrearLineasPercepcionIIBB(rstWS, rstCabFactura);

            until rstWS.Next = 0;
    end;

    [Scope('OnPrem')]
    procedure CalcularImporteAPercibirIIBB(rstLinFacturaL: Record "Sales Line"; var rstFacturaBufferRTL: Record "Invoice Withholding Buffer"; rstCabFacturaL: Record "Sales Header"): Decimal
    var
        rstCodigosRetencion: Record "Withholding codes";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstExencion: Record "Withholding details";
        rstCliente: Record Customer;
        rstAccionEstFis: Record "Acción estado sit. fiscal";
        int80or100: Integer;
    begin
        //CalcularImporteAPercibirIIBB

        rstCliente.Get(rstLinFacturaL."Bill-to Customer No.");
        Clear(rstCodigosRetencion);
        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstCabFacturaL."Posting Date", 0D);
        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstCabFacturaL."Posting Date", 0D);
        rstCodigosRetencion.SetRange(rstCodigosRetencion."Tipo impuesto retencion",
                                     rstCodigosRetencion."Tipo impuesto retencion"::"Ingresos Brutos");
        rstCodigosRetencion.SetRange("Cod. retencion", rstFacturaBufferRTL."Cod. retencion" /*rstFacturaBufferRTL."Cód. ingresos brutos"*/);
        if rstCodigosRetencion.FindFirst then begin

            Clear(rstConfiguracionRetencion);
            rstConfiguracionRetencion.SetRange("Tipo retenciones", rstConfiguracionRetencion."Tipo retenciones"::"Ingresos Brutos");
            rstConfiguracionRetencion.SetRange("Cod. retencion", rstCodigosRetencion."Cod. retencion");
            rstConfiguracionRetencion.SetRange("Tipo base retencion", rstConfiguracionRetencion."Tipo base retencion"::"Subtotal factura");
            if rstConfiguracionRetencion.FindFirst then begin

                Clear(rstExencion);
                rstExencion.SetRange("Cod. proveedor/cliente", rstCliente."No.");
                rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::"Ingresos Brutos");
                rstExencion.SetFilter("Fecha documento", '<=%1', rstCabFacturaL."Posting Date");
                rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstCabFacturaL."Posting Date", 0D);
                if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                //rstExencion.SETFILTER("Fecha efectividad retencion",'>=%1',rstCabFacturaL."Posting Date");
                //IF rstExencion.FINDLAST THEN
                begin

                    rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                                               rstExencion."% percepcion"
                                                               ) / 100);
                    rstFacturaBufferRTL."% retencion" := rstExencion."% percepcion";
                    rstFacturaBufferRTL.Excluido := 0;
                    rstFacturaBufferRTL."% Exclusion" := 0;
                    rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                end
                else begin

                    Clear(rstExencion);
                    rstExencion.SetRange("Cod. proveedor/cliente", rstCliente."No.");
                    rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::"Ingresos Brutos");
                    if rstExencion.FindLast and (not rstConfiguracionRetencion."Skip exclusions") and (rstExencion."Fecha efectividad retencion" < rstCabFacturaL."Posting Date") then
                        Error('El padrón registrado para el cliente %1, %2, ha vencido. \' +
                        'Por favor, actualice el padrón, o elimínelo de la configuración del cliente.',
                        rstExencion."Cod. proveedor/cliente", rstCliente.Name)

                    else begin

                        rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                        //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                        ) / 100);
                        rstFacturaBufferRTL."% retencion" := rstConfiguracionRetencion."% retencion";
                        rstFacturaBufferRTL.Excluido := 0;
                        rstFacturaBufferRTL."% Exclusion" := 0;
                        rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                    end;
                end;
            end;
        end;

        //Completo la línea de retención con la información de la retención

        rstFacturaBufferRTL.Provincia := rstLinFacturaL.Area;
        rstFacturaBufferRTL."No. serie IVA" := '';
        rstFacturaBufferRTL."Fecha factura" := rstCabFacturaL."Document Date";
        if not rstFacturaBufferRTL.Insert then
            rstFacturaBufferRTL.Modify;

    end;

    [Scope('OnPrem')]
    procedure CrearLineasPercepcionIIBB(l_rstWS: Record "Withholding setup"; l_rstCabFactura: Record "Sales Header")
    var
        rstHisCFacComp: Record "Sales Header";
        intMotivoExclusion: Integer;
        rstCodigosRetencion: Record "Withholding codes";
        rstFacturaBufferRT2: Record "Invoice Withholding Buffer";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstLinFactura2: Record "Sales Line";
        rstLinFacturaTemp: Record "Sales Line";
        rstFacturaBufferRT: Record "Invoice Withholding Buffer";
        codNoSerieCertificado: Code[20];
        rstConfCont: Record "General Ledger Setup";
        cduGestionNoSerie: Codeunit "No. Series";
        l_rst50020: Record "Withholding codes";
        l_rstRes: Record Resource;
    begin
        //CrearDiarioPagosIIBB


        Clear(rstFacturaBufferRT);
        CalcularTotalRetenido(l_rstCabFactura."No.", l_rstCabFactura."No.");
        rstFacturaBufferRT.SetCurrentKey(rstFacturaBufferRT."No. documento");
        rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", l_rstCabFactura."No.");
        rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos");
        rstFacturaBufferRT.SetRange("Tipo registro", rstFacturaBufferRT."Tipo registro"::Venta);
        rstFacturaBufferRT.SetFilter("Importe retencion", '<>0');
        if rstFacturaBufferRT.FindFirst then
            repeat

                rstFacturaBufferRT."Importe retencion" := Round(rstFacturaBufferRT."Importe retencion", 0.01);
                rstFacturaBufferRT.CalcFields(rstFacturaBufferRT."Importe retencion total", "Importe retenido real",
                                              rstFacturaBufferRT."Importe minimo pago", rstFacturaBufferRT."Importe minimo retención");

                if rstFacturaBufferRT."Tipo factura" = rstFacturaBufferRT."Tipo factura"::Factura then begin

                    if intMotivoExclusion = 0 then begin

                        Clear(rstCodigosRetencion);
                        rstCodigosRetencion.SetRange("Tipo impuesto retencion", rstCodigosRetencion."Tipo impuesto retencion"::"Ingresos Brutos");
                        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', l_rstCabFactura."Posting Date", 0D);
                        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', l_rstCabFactura."Posting Date", 0D);
                        rstCodigosRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                        //IF rstCodigosRetencion.GET(rstCodigosRetencion."Tipo impuesto retencion"::IVA,rstLinFacturaL."Cód. retención IVA") THEN
                        if rstCodigosRetencion.FindFirst then begin

                            Clear(rstConfiguracionRetencion);
                            rstConfiguracionRetencion.SetRange("Tipo retenciones", rstFacturaBufferRT."Tipo retencion");
                            rstConfiguracionRetencion.SetRange("Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                            if rstConfiguracionRetencion.FindFirst then begin

                                if rstFacturaBufferRT."Base pago retencion"/*rstFacturaBufferRT."Importe retenido real"*/ >= rstConfiguracionRetencion."Importe min. retencion" then begin

                                    Clear(rstLinFactura2);
                                    rstLinFactura2.SetRange("Document No.", rstFacturaBufferRT."No. Factura");
                                    if rstLinFactura2.FindLast then;
                                    Clear(rstLinFacturaTemp);
                                    rstLinFacturaTemp.SetSalesHeader(l_rstCabFactura);
                                    rstLinFacturaTemp.Init;
                                    rstLinFacturaTemp."Posting Date" := l_rstCabFactura."Posting Date";
                                    rstLinFacturaTemp."Document Type" := l_rstCabFactura."Document Type";
                                    rstLinFacturaTemp.Validate("Sell-to Customer No.", l_rstCabFactura."Sell-to Customer No.");
                                    rstLinFacturaTemp.Validate("Bill-to Customer No.", l_rstCabFactura."Bill-to Customer No.");
                                    rstLinFacturaTemp."Document No." := l_rstCabFactura."No.";
                                    rstLinFacturaTemp."Line No." := rstLinFactura2."Line No." + 1;
                                    rstLinFacturaTemp.Validate("Shortcut Dimension 1 Code", l_rstCabFactura."Shortcut Dimension 1 Code");
                                    rstLinFacturaTemp.Validate("Shortcut Dimension 2 Code", l_rstCabFactura."Shortcut Dimension 2 Code");
                                    rstLinFacturaTemp.Validate("Shortcut Dimension 3 Code", l_rstCabFactura."Shortcut Dimension 3 Code");
                                    rstLinFacturaTemp.Validate("Shortcut Dimension 4 Code", l_rstCabFactura."Shortcut Dimension 4 Code");
                                    rstLinFacturaTemp.Validate("Shortcut Dimension 5 Code", l_rstCabFactura."Shortcut Dimension 5 Code");
                                    rstLinFacturaTemp.Validate("Shortcut Dimension 6 Code", l_rstCabFactura."Shortcut Dimension 6 Code");
                                    rstLinFacturaTemp.Validate("Shortcut Dimension 7 Code", l_rstCabFactura."Shortcut Dimension 7 Code");
                                    Clear(rstConfCont);
                                    rstConfCont.Get();
                                    case rstFacturaBufferRT."Tipo retencion" of
                                        rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos":
                                            begin
                                                Clear(l_rst50020);
                                                l_rst50020.SetRange(l_rst50020."Tipo impuesto retencion", l_rst50020."Tipo impuesto retencion"::"Ingresos Brutos");
                                                l_rst50020.SetRange(l_rst50020."Cod. retencion", rstFacturaBufferRT."Cod. retencion");
                                                l_rst50020.SetFilter("Codigo SICORE", '<>%1', '');
                                                if l_rst50020.FindFirst then begin
                                                    Clear(l_rstRes);
                                                    l_rstRes.SetRange("Gross winnings perception code", l_rst50020."Codigo SICORE");
                                                    if l_rstRes.FindFirst then begin
                                                        rstLinFacturaTemp.Type := rstLinFacturaTemp.Type::Resource;
                                                        rstLinFacturaTemp.Validate("No.", l_rstRes."No.");
                                                        rstLinFacturaTemp.Description := CopyStr('Percepción IIBB CABA ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                    end;
                                                end;
                                                if rstLinFacturaTemp."No." = '' then begin
                                                    rstLinFacturaTemp.Type := rstLinFacturaTemp.Type::"G/L Account";
                                                    rstLinFacturaTemp.Validate("No.", rstConfCont."GI perception account");
                                                    rstLinFacturaTemp.Description := CopyStr('Percepción IIBB CABA ' + rstCodigosRetencion.Descripcion, 1, 50);
                                                end;
                                            end;
                                    end;
                                    if l_rstCabFactura."Currency Factor" = 0 then
                                        rstLinFacturaTemp.Validate(rstLinFacturaTemp."Unit Price", rstFacturaBufferRT."Importe retencion")
                                    else
                                        rstLinFacturaTemp.Validate(rstLinFacturaTemp."Unit Price", rstFacturaBufferRT."Importe retencion" * l_rstCabFactura."Currency Factor");
                                    rstLinFacturaTemp."Description 2" := rstFacturaBufferRT."No. Factura";
                                    rstFacturaBufferRT.Retenido := true;
                                    Clear(rstConfCont);
                                    rstConfCont.Get();

                                    rstFacturaBufferRT.Modify;

                                    if not rstLinFacturaTemp.Insert then
                                        rstLinFacturaTemp.Modify;

                                end
                                else begin

                                    rstFacturaBufferRT.Excluido := 3;
                                    rstFacturaBufferRT.Modify;

                                end;

                            end;

                        end;

                    end
                    else begin

                        rstFacturaBufferRT.Excluido := intMotivoExclusion;
                        rstFacturaBufferRT.Modify;

                    end;

                end;

            until rstFacturaBufferRT.Next = 0;

    end;

    [Scope('OnPrem')]
    procedure CalcularPercepcionIIBBReg(var rstCabVenta: Record "Sales Invoice Header"; rstCliente: Record Customer)
    var
        rstCabFactura: Record "Sales Invoice Header";
        rstLinFactura: Record "Sales Invoice Line";
        rstFacturaBufferRT: Record "Invoice Withholding Buffer";
        decImportePagosAnterioresIVA: Decimal;
        rstExencion: Record "Withholding details";
        rstWS: Record "Withholding setup";
        rstMovIva: Record "VAT Entry";
        rstCodRetencion: Record "Withholding codes";
        cduGestionNoSerie: Codeunit "No. Series";
        rstConfCont: Record "General Ledger Setup";
        codNoSerieCertificado: Code[20];
        blnRetenido: Boolean;
        rstMovProveedor: Record "Cust. Ledger Entry";
        rstMovProveedorFC: Record "Cust. Ledger Entry";
        decImpoLiqNC: Decimal;
    begin
        //CalcularPercepcionIIBB

        Clear(rstFacturaBufferRT);
        rstFacturaBufferRT.SetCurrentKey("No. documento");
        rstFacturaBufferRT.SetRange(rstFacturaBufferRT."No. documento", rstCabVenta."No.");
        rstFacturaBufferRT.DeleteAll;

        Clear(rstWS);
        rstWS.SetRange("Tipo retenciones", rstWS."Tipo retenciones"::"Ingresos Brutos");
        rstWS.SetRange("Tipo base retencion", rstWS."Tipo base retencion"::"Subtotal factura");
        if rstWS.FindSet then
            repeat

                Clear(rstLinFactura);
                rstLinFactura.SetRange("Document No.", rstCabVenta."No.");
                rstLinFactura.SetRange("Cód. ingresos brutos", rstWS."Cod. retencion");
                if rstLinFactura.FindSet then
                    repeat

                        Clear(rstFacturaBufferRT);
                        rstFacturaBufferRT.SetRange("Tipo registro", rstFacturaBufferRT."Tipo registro"::Venta);
                        rstFacturaBufferRT.SetRange("Cliente/Proveedor", rstCliente."No.");
                        rstFacturaBufferRT.SetRange("No. Factura", rstLinFactura."Document No.");
                        rstFacturaBufferRT.SetRange("Tipo retencion", rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos");
                        rstFacturaBufferRT.SetRange("Cod. retencion", rstWS."Cod. retencion");
                        rstFacturaBufferRT.SetRange("No. documento", rstLinFactura."Document No.");

                        //Si esta es la primera vez que se inserta la factura en la tabla, entonces limpio el resto de los campos

                        if not rstFacturaBufferRT.FindFirst then begin

                            rstFacturaBufferRT."Tipo registro" := rstFacturaBufferRT."Tipo registro"::Venta;
                            rstFacturaBufferRT."Cliente/Proveedor" := rstCliente."No.";
                            rstFacturaBufferRT."No. Factura" := rstLinFactura."Document No.";
                            rstFacturaBufferRT."Tipo retencion" := rstFacturaBufferRT."Tipo retencion"::"Ingresos Brutos";
                            rstFacturaBufferRT."Cod. retencion" := rstWS."Cod. retencion";
                            rstFacturaBufferRT."No. documento" := rstLinFactura."Document No.";
                            rstFacturaBufferRT."Serie retención" := '';
                            rstFacturaBufferRT."Fecha pago" := rstCabVenta."Posting Date";
                            rstFacturaBufferRT."Tipo fiscal" := rstCliente."VAT Bus. Posting Group";
                            rstFacturaBufferRT."Base pago retencion" := 0;
                            rstFacturaBufferRT."Pagos anteriores" := 0;
                            rstFacturaBufferRT."Importe retencion" := 0;
                            rstFacturaBufferRT."% retencion" := 0;
                            rstFacturaBufferRT.Provincia := '';
                            rstFacturaBufferRT."No. serie ganancias" := '';
                            rstFacturaBufferRT."No. serie IVA" := '';
                            rstFacturaBufferRT."No. serie Ingresos Brutos" := '';
                            rstFacturaBufferRT."Fecha factura" := 0D;
                            rstFacturaBufferRT.Nombre := '';
                            rstFacturaBufferRT."Importe neto factura" := 0;
                            rstFacturaBufferRT."Factura liquidada" := rstLinFactura."Document No.";
                            rstFacturaBufferRT.Insert;

                        end;

                        Clear(rstCabFactura);
                        rstCabFactura.Get(rstLinFactura."Document No.");

                        //Si la divisa de la factura es diferente a la divisa local, calculo el importe base a retener utilizando el factor
                        //de divisa de la cabecera de compra.
                        //Cambio de lógica. Siempre se paga la factura en pesos, así que utilizo el tipo de cambio por el que se cargó la
                        //factura para el cálculo de las retenciones.

                        if rstCabFactura."Currency Code" <> '' then begin

                            decTCambioPago := 0;
                            decTCambioPago := 1 / rstCabFactura."Currency Factor";
                            rstFacturaBufferRT."Importe neto factura" += (rstLinFactura.Amount)
                              * decTCambioPago;
                            rstFacturaBufferRT."Base pago retencion" += (rstLinFactura."Amount Including VAT" - rstLinFactura."VAT Base Amount")
                              * decTCambioPago;

                        end
                        else begin

                            rstFacturaBufferRT."Importe neto factura" += (rstLinFactura.Amount);
                            rstFacturaBufferRT."Base pago retencion" += (rstLinFactura."Amount Including VAT" - rstLinFactura."VAT Base Amount");

                        end;

                        rstFacturaBufferRT.Modify;

                    until rstLinFactura.Next = 0;

                //Calculo el importe a retener. Para eso, busco la configuración de retenciones correcta
                CalcularImporteAPercibirIIBBReg(rstLinFactura, rstFacturaBufferRT, rstCabFactura);
            //CrearLineasPercepcionIIBBReg(rstWS,rstCabFactura);

            until rstWS.Next = 0;
    end;

    [Scope('OnPrem')]
    procedure CalcularImporteAPercibirIIBBReg(rstLinFacturaL: Record "Sales Invoice Line"; var rstFacturaBufferRTL: Record "Invoice Withholding Buffer"; rstCabFacturaL: Record "Sales Invoice Header"): Decimal
    var
        rstCodigosRetencion: Record "Withholding codes";
        rstConfiguracionRetencion: Record "Withholding setup";
        rstExencion: Record "Withholding details";
        rstCliente: Record Customer;
        rstAccionEstFis: Record "Acción estado sit. fiscal";
        int80or100: Integer;
    begin
        //CalcularImporteAPercibirIIBB

        rstCliente.Get(rstLinFacturaL."Bill-to Customer No.");
        Clear(rstCodigosRetencion);
        rstCodigosRetencion.SetFilter("Valid from", '<=%1|%2', rstCabFacturaL."Posting Date", 0D);
        rstCodigosRetencion.SetFilter("Valid to", '>%1|%2', rstCabFacturaL."Posting Date", 0D);
        rstCodigosRetencion.SetRange(rstCodigosRetencion."Tipo impuesto retencion",
                                     rstCodigosRetencion."Tipo impuesto retencion"::"Ingresos Brutos");
        rstCodigosRetencion.SetRange("Cod. retencion", rstFacturaBufferRTL."Cod. retencion" /*rstFacturaBufferRTL."Cód. ingresos brutos"*/);
        if rstCodigosRetencion.FindFirst then begin

            Clear(rstConfiguracionRetencion);
            rstConfiguracionRetencion.SetRange("Tipo retenciones", rstConfiguracionRetencion."Tipo retenciones"::"Ingresos Brutos");
            rstConfiguracionRetencion.SetRange("Cod. retencion", rstCodigosRetencion."Cod. retencion");
            rstConfiguracionRetencion.SetRange("Tipo base retencion", rstConfiguracionRetencion."Tipo base retencion"::"Subtotal factura");
            if rstConfiguracionRetencion.FindFirst then begin

                Clear(rstExencion);
                rstExencion.SetRange("Cod. proveedor/cliente", rstCliente."No.");
                rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::"Ingresos Brutos");
                rstExencion.SetFilter("Fecha documento", '<=%1', rstCabFacturaL."Posting Date");
                rstExencion.SetFilter("Fecha efectividad retencion", '>=%1|%2', rstCabFacturaL."Posting Date", 0D);
                if (rstExencion.FindLast) and (not rstConfiguracionRetencion."Skip exclusions") and ((not rstExencion.IsEmpty) and (not rstTFiscal."Withhold Even if Agent")) then
                //rstExencion.SETFILTER("Fecha efectividad retencion",'>=%1',rstCabFacturaL."Posting Date");
                //IF rstExencion.FINDLAST THEN
                begin

                    rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                                                               rstExencion."% percepcion"
                                                               ) / 100);
                    rstFacturaBufferRTL."% retencion" := rstExencion."% percepcion";
                    rstFacturaBufferRTL.Excluido := 0;
                    rstFacturaBufferRTL."% Exclusion" := 0;
                    rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                end
                else begin

                    Clear(rstExencion);
                    rstExencion.SetRange("Cod. proveedor/cliente", rstCliente."No.");
                    rstExencion.SetRange("Tipo retención", rstExencion."Tipo retención"::"Ingresos Brutos");
                    if rstExencion.FindLast and (not rstConfiguracionRetencion."Skip exclusions") and (rstExencion."Fecha efectividad retencion" < rstCabFacturaL."Posting Date") then
                        Error('El padrón registrado para el cliente %1, %2, ha vencido. \' +
                        'Por favor, actualice el padrón, o elimínelo de la configuración del cliente.',
                        rstExencion."Cod. proveedor/cliente", rstCliente.Name)

                    else begin

                        rstFacturaBufferRTL."Importe retencion" := ((rstFacturaBufferRTL."Importe neto factura" *
                        //rstConfiguracionRetencion."% retención")/100)-decImportePagosAnterioresIVAL;
                        fntCalcularPorcentajeRetencion(rstConfiguracionRetencion)
                        ) / 100);
                        rstFacturaBufferRTL."% retencion" := rstConfiguracionRetencion."% retencion";
                        rstFacturaBufferRTL.Excluido := 0;
                        rstFacturaBufferRTL."% Exclusion" := 0;
                        rstFacturaBufferRTL."Fecha documento exclusion" := 0D;

                    end;
                end;
            end;
        end;

        //Completo la línea de retención con la información de la retención

        rstFacturaBufferRTL.Provincia := rstLinFacturaL.Area;
        rstFacturaBufferRTL."No. serie IVA" := '';
        rstFacturaBufferRTL."Fecha factura" := rstCabFacturaL."Document Date";
        if not rstFacturaBufferRTL.Insert then
            rstFacturaBufferRTL.Modify;

    end;

    local procedure fntTipoCambioPago(l_rst81: Record "Gen. Journal Line"; l_codDoc: Code[20]): Decimal
    var
        l_rstCabFac: Record "Purch. Inv. Header";
        l_rstCabNC: Record "Purch. Cr. Memo Hdr.";
    begin
        //IF USERID <> 'ADMULISES' THEN ERROR('');
        if l_codDoc <> '' then begin
            l_rst81.SetRange("Applies-to Doc. No.", l_codDoc);
            l_rst81.FindFirst;
            if l_rst81."Currency Factor" <> 0 then
                exit(1 / l_rst81."Currency Factor")
            else begin
                Clear(l_rstCabNC);
                if l_rstCabNC.Get(l_codDoc) then
                    if l_rstCabNC."Currency Factor" <> 0 then
                        exit(1 / l_rstCabNC."Currency Factor");
                exit(1);
            end;
        end
        else begin
            l_rst81.SetRange("Document Type", l_rst81."Document Type");
            l_rst81.SetRange("Document No.", l_rst81."Document No.");
            l_rst81.SetFilter(Amount, '<>%1', 0);
            l_rst81.FindFirst;
            if l_rst81."Currency Factor" <> 0 then
                exit(1 / l_rst81."Currency Factor")
            else
                exit(1);
        end;
    end;

    local procedure fntPorcentajePagado(rstLinDiaGenTemp: Record "Gen. Journal Line"; rstMovProveedor: Record "Vendor Ledger Entry") decCredito: Decimal
    var
        rstMens: Record Mensajeria;
        rstNC: Record "Purch. Cr. Memo Hdr.";
        l_rstVLE: Record "Vendor Ledger Entry";
        l_rst50519: Record "Tipos documento";
        rstND: Record "Purch. Inv. Header";
        rstCC: Record "Vendor Ledger Entry";
        rstCCL: Record "Vendor Ledger Entry";
        rstCI: Record "Company Information";
        rstLFC: Record "Purch. Inv. Line";
        rstLNC: Record "Purch. Cr. Memo Line";
        rstVE2: Record "VAT Entry";
        rstFC: Record "Purch. Inv. Header";
        l_rstSS: Record "Sales & Receivables Setup";
    begin
        if rstLinDiaGenTemp."Applies-to Doc. Type" = rstLinDiaGenTemp."Applies-to Doc. Type"::Invoice then begin
            with l_rstVLE do begin
                Clear(rstCCL);
                rstCCL.SetRange("Entry No.", rstMovProveedor."Closed by Entry No.");
                if rstCCL.FindFirst then
                    repeat
                        rstCCL.CalcFields(Amount);
                        decCredito += rstCCL.Amount;
                    until rstCCL.Next = 0;
                Clear(rstCCL);
                rstCCL.SetRange("Document Type", rstCCL."Document Type"::"Credit Memo");
                rstCCL.SetRange("Closed by Entry No.", rstMovProveedor."Entry No.");
                if rstCCL.FindFirst then
                    repeat
                        rstCCL.CalcFields(Amount);
                        decCredito += rstCCL.Amount;
                    until rstCCL.Next = 0;
            end;
        end;
        exit(Abs(decCredito));
    end;

    [Scope('OnPrem')]
    procedure fntCalcularPorcentajeRetencion(l_rstConfiguracionRetencion: Record "Withholding setup"): Decimal
    var
        l_decPor: Decimal;
    begin
        if l_rstConfiguracionRetencion."Porcentaje de IVA" = 0 then
            l_decPor := 100
        else
            l_decPor := l_rstConfiguracionRetencion."Porcentaje de IVA";
        exit(l_rstConfiguracionRetencion."% retencion" * l_decPor / 100);
    end;

    procedure fntTestExentoRetencionIVA(l_codProveedor: Code[10]; l_decImpoRet: Decimal; var l_intMotivo: Integer)
    var
        l_rstVendor: Record Vendor;
    begin
        //Si está marcado "Exento retención en IVA" en el proveedor, tipo de exclusión 3
        Clear(rstProveedor);
        rstProveedor.Get(l_codProveedor);
        if rstProveedor."Exento retención IVA" then begin
            if l_decImpoRet = 0 then
                //ERROR('El importe retenido no puede ser diferente de 0 para un proveedor exento de retención de IVA. El error se dá en el proveedor %1',l_codProveedor);
                l_intMotivo := 3;
        end;
    end;


    [Scope('OnPrem')]
    procedure ActividadRG3594(l_rstLinDiaGen: Record "Gen. Journal Line"): Boolean
    var
        l_rstLinDiaGenTemp: Record "Gen. Journal Line";
        l_linFacC: Record "Purch. Inv. Line";
        l_ActAFIP: Record "Actividad AFIP";
        l_linNotaDCC: Record "Purch. Cr. Memo Line";
        blnRG3594: Boolean;
        l_rstConfRet: Record "Withholding codes";
    begin
        Clear(rstProveedor);
        rstProveedor.Get(l_rstLinDiaGen."Account No.");
        if rstProveedor."VAT Bus. Posting Group" <> 'PRV-RI' then
            exit;

        Clear(l_rstLinDiaGenTemp);
        blnRG3594 := false;
        l_rstLinDiaGenTemp.SetRange("Journal Template Name", l_rstLinDiaGen."Journal Template Name");
        l_rstLinDiaGenTemp.SetRange("Journal Batch Name", l_rstLinDiaGen."Journal Batch Name");
        l_rstLinDiaGenTemp.SetRange("Document No.", l_rstLinDiaGen."Document No.");
        l_rstLinDiaGenTemp.SetRange(l_rstLinDiaGenTemp."Account Type", l_rstLinDiaGenTemp."Account Type"::Vendor);
        if l_rstLinDiaGenTemp.FindFirst then
            repeat

                case l_rstLinDiaGenTemp."Applies-to Doc. Type" of

                    l_rstLinDiaGenTemp."Applies-to Doc. Type"::Invoice:
                        begin

                            Clear(l_linFacC);
                            l_linFacC.SetRange("Document No.", l_rstLinDiaGenTemp."Applies-to Doc. No.");
                            l_linFacC.SetFilter("Actividad AFIP", '<>%1', '');
                            if l_linFacC.FindSet then
                                repeat

                                    Clear(l_ActAFIP);
                                    l_ActAFIP.Get(l_linFacC."Actividad AFIP");
                                    if l_ActAFIP."Actividad registrada en RG3594" then begin
                                        blnRG3594 := true;
                                        Clear(l_rstConfRet);
                                        l_rstConfRet.SetRange(l_rstConfRet."Cod. retencion", l_linFacC."Cód. retención IVA");
                                        l_rstConfRet.SetRange("Verificar registro RG3594", false);
                                        if l_rstConfRet.FindFirst then
                                            Error('La línea %1 de la factura %2 tiene especificada una actividad correspondiente a la RG3594.\' +
                                                  'Por favor, verifique que el código de retención de %3 corresponda a uno de la RG3594.',
                                                  Format(l_linFacC."Line No."), Format(l_linFacC."Document No."), Format(l_rstConfRet."Tipo impuesto retencion"));
                                        Clear(l_rstConfRet);
                                        l_rstConfRet.SetRange(l_rstConfRet."Cod. retencion", l_linFacC."Cód. retención ganancias");
                                        l_rstConfRet.SetRange("Verificar registro RG3594", false);
                                        if l_rstConfRet.FindFirst then
                                            Error('La línea %1 de la factura %2 tiene especificada una actividad correspondiente a la RG3594.\' +
                                                  'Por favor, verifique que el código de retención de %3 corresponda a uno de la RG3594.',
                                                  Format(l_linFacC."Line No."), Format(l_linFacC."Document No."), Format(l_rstConfRet."Tipo impuesto retencion"));
                                    end;

                                    Clear(l_rstConfRet);
                                    l_rstConfRet.SetRange("Tipo impuesto retencion", l_rstConfRet."Tipo impuesto retencion"::IVA);
                                    l_rstConfRet.SetRange(l_rstConfRet."Cod. retencion", l_linFacC."Cód. retención IVA");
                                    l_rstConfRet.SetRange("Verificar registro RG3594", true);
                                    if l_rstConfRet.FindFirst then begin
                                        Clear(l_ActAFIP);
                                        l_ActAFIP.Get(l_linFacC."Actividad AFIP");
                                        if not l_ActAFIP."Actividad registrada en RG3594" then
                                            Error('La línea %1 de la factura %2 tiene especificado un código de retención de %3 correspondiente a la RG3594.\' +
                                                  'Por favor, verifique que la actividad corresponda a una de la RG3594.',
                                                  Format(l_linFacC."Line No."), Format(l_linFacC."Document No."), Format(l_rstConfRet."Tipo impuesto retencion"));
                                    end;

                                    Clear(l_rstConfRet);
                                    l_rstConfRet.SetRange("Tipo impuesto retencion", l_rstConfRet."Tipo impuesto retencion"::Ganancias);
                                    l_rstConfRet.SetRange(l_rstConfRet."Cod. retencion", l_linFacC."Cód. retención ganancias");
                                    l_rstConfRet.SetRange("Verificar registro RG3594", true);
                                    if l_rstConfRet.FindFirst then begin
                                        Clear(l_ActAFIP);
                                        l_ActAFIP.Get(l_linFacC."Actividad AFIP");
                                        if not l_ActAFIP."Actividad registrada en RG3594" then
                                            Error('La línea %1 de la factura %2 tiene especificado un código de retención de %3 correspondiente a la RG3594.\' +
                                                  'Por favor, verifique que la actividad corresponda a una de la RG3594.',
                                                  Format(l_linFacC."Line No."), Format(l_linFacC."Document No."), Format(l_rstConfRet."Tipo impuesto retencion"));
                                    end;

                                until (l_linFacC.Next = 0);

                        end;

                    l_rstLinDiaGenTemp."Applies-to Doc. Type"::"Credit Memo":
                        begin

                            Clear(l_linNotaDCC);
                            l_linNotaDCC.SetRange("Document No.", l_rstLinDiaGenTemp."Applies-to Doc. No.");
                            l_linNotaDCC.SetFilter("Actividad AFIP", '<>%1', '');
                            if l_linNotaDCC.FindSet then
                                repeat

                                    Clear(l_ActAFIP);
                                    l_ActAFIP.Get(l_linNotaDCC."Actividad AFIP");
                                    if l_ActAFIP."Actividad registrada en RG3594" then begin
                                        blnRG3594 := true;
                                        Clear(l_rstConfRet);
                                        l_rstConfRet.SetRange(l_rstConfRet."Cod. retencion", l_linNotaDCC."Cód. retención IVA");
                                        l_rstConfRet.SetRange("Verificar registro RG3594", false);
                                        if l_rstConfRet.FindFirst then
                                            Error('La línea %1 de la n/c %2 tiene especificada una actividad correspondiente a la RG3594.\' +
                                                  'Por favor, verifique que el código de retención de %3 corresponda a uno de la RG3594.',
                                                  Format(l_linNotaDCC."Line No."),
                                                  Format(l_linNotaDCC."Document No."), Format(l_rstConfRet."Tipo impuesto retencion"));
                                        Clear(l_rstConfRet);
                                        l_rstConfRet.SetRange(l_rstConfRet."Cod. retencion", l_linNotaDCC."Cód. retención ganancias");
                                        l_rstConfRet.SetRange("Verificar registro RG3594", false);
                                        if l_rstConfRet.FindFirst then
                                            Error('La línea %1 de la n/c %2 tiene especificada una actividad correspondiente a la RG3594.\' +
                                                  'Por favor, verifique que el código de retención de %3 corresponda a uno de la RG3594.',
                                                  Format(l_linNotaDCC."Line No."),
                                                  Format(l_linNotaDCC."Document No."), Format(l_rstConfRet."Tipo impuesto retencion"));
                                    end;

                                    Clear(l_rstConfRet);
                                    l_rstConfRet.SetRange("Tipo impuesto retencion", l_rstConfRet."Tipo impuesto retencion"::IVA);
                                    l_rstConfRet.SetRange(l_rstConfRet."Cod. retencion", l_linNotaDCC."Cód. retención IVA");
                                    l_rstConfRet.SetRange("Verificar registro RG3594", true);
                                    if l_rstConfRet.FindFirst then begin
                                        Clear(l_ActAFIP);
                                        l_ActAFIP.Get(l_linNotaDCC."Actividad AFIP");
                                        if not l_ActAFIP."Actividad registrada en RG3594" then
                                            Error('La línea %1 de la n/c %2 tiene especificado un código de retención de %3 correspondiente a la RG3594.\' +
                                                  'Por favor, verifique que la actividad corresponda a una de la RG3594.',
                                                  Format(l_linNotaDCC."Line No."),
                                                  Format(l_linNotaDCC."Document No."), Format(l_rstConfRet."Tipo impuesto retencion"));
                                    end;

                                    Clear(l_rstConfRet);
                                    l_rstConfRet.SetRange("Tipo impuesto retencion", l_rstConfRet."Tipo impuesto retencion"::Ganancias);
                                    l_rstConfRet.SetRange(l_rstConfRet."Cod. retencion", l_linNotaDCC."Cód. retención ganancias");
                                    l_rstConfRet.SetRange("Verificar registro RG3594", true);
                                    if l_rstConfRet.FindFirst then begin
                                        Clear(l_ActAFIP);
                                        l_ActAFIP.Get(l_linNotaDCC."Actividad AFIP");
                                        if not l_ActAFIP."Actividad registrada en RG3594" then
                                            Error('La línea %1 de la factura %2 tiene especificado un código de retención de %3 correspondiente a la RG3594.\' +
                                                  'Por favor, verifique que la actividad corresponda a una de la RG3594.',
                                                  Format(l_linNotaDCC."Line No."),
                                                  Format(l_linNotaDCC."Document No."), Format(l_rstConfRet."Tipo impuesto retencion"));
                                    end;

                                until (l_linNotaDCC.Next = 0);

                        end;

                end;

            until (l_rstLinDiaGenTemp.Next = 0);

        exit(blnRG3594);
    end;

    [Scope('OnPrem')]
    procedure fntNroSerieRetenciones(codDocumento: Code[1024])
    var
        rstFacturaRTBaseBuffer: Record "Invoice Withholding Buffer";
        codNoSerieCertificado: Code[30];
        cduGestionNoSerie: Codeunit "No. Series";
        rstConfCont: Record "General Ledger Setup";
    begin
        Clear(rstFacturaRTBaseBuffer);
        rstFacturaRTBaseBuffer.SetCurrentKey("Fecha pago", "No. documento");
        rstFacturaRTBaseBuffer.FindLast;

        Clear(rstFacturaRTBaseBuffer);
        rstFacturaRTBaseBuffer.SetCurrentKey(rstFacturaRTBaseBuffer."No. documento");
        rstFacturaRTBaseBuffer.SetFilter(rstFacturaRTBaseBuffer."No. documento", codDocumento);
        rstFacturaRTBaseBuffer.SetRange("Tipo retencion", rstFacturaRTBaseBuffer."Tipo retencion"::"Seguridad Social");
        rstFacturaRTBaseBuffer.SetRange(Retenido, true);
        if rstFacturaRTBaseBuffer.FindSet then begin

            rstConfCont.Get();
            Clear(cduGestionNoSerie);
            codNoSerieCertificado := '';
            codNoSerieCertificado := cduGestionNoSerie.GetNextNo(rstConfCont."No. serie retención SS", Today, true);

            repeat
                if rstFacturaRTBaseBuffer."Serie retención" = '' then begin
                    rstFacturaRTBaseBuffer.Validate("Serie retención", codNoSerieCertificado);
                    rstFacturaRTBaseBuffer.Modify;
                end;
            until rstFacturaRTBaseBuffer.Next = 0;

        end;

        Clear(rstFacturaRTBaseBuffer);
        rstFacturaRTBaseBuffer.SetCurrentKey(rstFacturaRTBaseBuffer."No. documento");
        rstFacturaRTBaseBuffer.SetFilter(rstFacturaRTBaseBuffer."No. documento", codDocumento);
        rstFacturaRTBaseBuffer.SetRange("Tipo retencion", rstFacturaRTBaseBuffer."Tipo retencion"::IVA);
        rstFacturaRTBaseBuffer.SetRange(Retenido, true);
        if rstFacturaRTBaseBuffer.FindSet then begin

            rstConfCont.Get();
            Clear(cduGestionNoSerie);
            codNoSerieCertificado := '';
            codNoSerieCertificado := cduGestionNoSerie.GetNextNo(rstConfCont."No. serie retención IVA", Today, true);

            repeat
                if rstFacturaRTBaseBuffer."Serie retención" = '' then begin
                    rstFacturaRTBaseBuffer.Validate("Serie retención", codNoSerieCertificado);
                    rstFacturaRTBaseBuffer.Modify;
                end;
            until rstFacturaRTBaseBuffer.Next = 0;

        end;

        Clear(rstFacturaRTBaseBuffer);
        rstFacturaRTBaseBuffer.SetCurrentKey(rstFacturaRTBaseBuffer."No. documento");
        rstFacturaRTBaseBuffer.SetFilter(rstFacturaRTBaseBuffer."No. documento", codDocumento);
        rstFacturaRTBaseBuffer.SetRange("Tipo retencion", rstFacturaRTBaseBuffer."Tipo retencion"::Ganancias);
        rstFacturaRTBaseBuffer.SetRange(Retenido, true);
        if rstFacturaRTBaseBuffer.FindSet then begin

            rstConfCont.Get();
            Clear(cduGestionNoSerie);
            codNoSerieCertificado := '';
            codNoSerieCertificado := cduGestionNoSerie.GetNextNo(rstConfCont."No. serie retención Ganancias", Today, true);

            repeat
                if rstFacturaRTBaseBuffer."Serie retención" = '' then begin
                    rstFacturaRTBaseBuffer.Validate("Serie retención", codNoSerieCertificado);
                    rstFacturaRTBaseBuffer.Modify;
                end;
            until rstFacturaRTBaseBuffer.Next = 0;

        end;

        Clear(rstFacturaRTBaseBuffer);
        rstFacturaRTBaseBuffer.SetCurrentKey(rstFacturaRTBaseBuffer."No. documento");
        rstFacturaRTBaseBuffer.SetFilter(rstFacturaRTBaseBuffer."No. documento", codDocumento);
        rstFacturaRTBaseBuffer.SetRange("Tipo retencion", rstFacturaRTBaseBuffer."Tipo retencion"::"Ingresos Brutos");
        rstFacturaRTBaseBuffer.SetRange(Retenido, true);
        if rstFacturaRTBaseBuffer.FindSet then begin

            rstConfCont.Get();
            Clear(cduGestionNoSerie);
            codNoSerieCertificado := '';
            codNoSerieCertificado := cduGestionNoSerie.GetNextNo(rstConfCont."No. serie retención IIBB", Today, true);

            repeat
                if rstFacturaRTBaseBuffer."Serie retención" = '' then begin
                    rstFacturaRTBaseBuffer.Validate("Serie retención", codNoSerieCertificado);
                    rstFacturaRTBaseBuffer.Modify;
                end;
            until rstFacturaRTBaseBuffer.Next = 0;

        end;
    end;

    [Scope('OnPrem')]
    procedure fntRenumerarRetenciones(codDocumento: Code[1024])
    var
        rstFacturaRTBaseBuffer: Record "Invoice Withholding Buffer";
        codNoSerieCertificado: Code[30];
        cduGestionNoSerie: Codeunit "No. Series";
        rstConfCont: Record "General Ledger Setup";
        rst17: Record "G/L Entry";
        rstFacturaRTBaseBuffer2: Record "Invoice Withholding Buffer";
    begin
        Clear(rst17);
        rst17.SetRange("Document No.", codDocumento);
        if rst17.FindSet then
            repeat

                if rst17."No. documento preasignado" = '' then
                    exit;

                Clear(rstFacturaRTBaseBuffer);
                rstFacturaRTBaseBuffer.SetRange("No. documento", rst17."No. documento preasignado");
                if rstFacturaRTBaseBuffer.FindSet then
                    repeat

                        Clear(rstFacturaRTBaseBuffer2);
                        rstFacturaRTBaseBuffer2.Get(rstFacturaRTBaseBuffer."Tipo registro",
                                                      rstFacturaRTBaseBuffer."Cliente/Proveedor",
                                                      rstFacturaRTBaseBuffer."No. Factura",
                                                      rstFacturaRTBaseBuffer."Tipo retencion",
                                                      rstFacturaRTBaseBuffer."Cod. retencion",
                                                      rstFacturaRTBaseBuffer."No. documento");

                        rstFacturaRTBaseBuffer2.Rename(rstFacturaRTBaseBuffer."Tipo registro",
                                                      rstFacturaRTBaseBuffer."Cliente/Proveedor",
                                                      rstFacturaRTBaseBuffer."No. Factura",
                                                      rstFacturaRTBaseBuffer."Tipo retencion",
                                                      rstFacturaRTBaseBuffer."Cod. retencion",
                                                      rst17."Document No.");

                    until rstFacturaRTBaseBuffer.Next = 0;

            until rst17.Next = 0;
    end;

    [Scope('OnPrem')]
    procedure fntNoSolicitarConfirmaciones(l_blnConfirmar: Boolean)
    begin
        blnConfirmar := l_blnConfirmar;
    end;

    procedure SetLibroAndSeccionForApply(codLibro: Code[20]; codSeccion: Code[20]; documentNo: Code[20])
    begin
        // Procedimiento público para establecer los códigos antes de la aplicación
        GlobalCodLibro := codLibro;
        GlobalCodSeccion := codSeccion;
        GlobalDocumentNo := documentNo;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Apply", 'OnBeforeRun', '', false, false)]
    local procedure OnBeforeGenJnlApplyRun()
    begin
        // Este evento se ejecuta antes de que se complete la aplicación de movimientos
        // Usar las variables globales establecidas previamente

        if (GlobalCodLibro <> '') and (GlobalCodSeccion <> '') then begin
            ProcessLibroAndSeccionAfterApply(GlobalCodLibro, GlobalCodSeccion);

            // Limpiar las variables globales después de usar
            ClearGlobalVariables();
        end;
    end;

    local procedure ProcessLibroAndSeccionAfterApply(codLibro: Code[20]; codSeccion: Code[20])
    begin

    end;

    local procedure ClearGlobalVariables()
    begin
        // Limpiar las variables globales después de usar
        Clear(GlobalCodLibro);
        Clear(GlobalCodSeccion);
        Clear(GlobalDocumentNo);
    end;


}