page 50669 Retenciones
{
    SaveValues = true;
    Caption = 'Retenciones';

    layout
    {
        area(content)
        {
            group("Importar archivo")
            {
                field("Tipo archivo"; optRet)
                {

                    trigger OnValidate()
                    begin
                        strRetCualquiera1 := '';
                        CurrPage.Update;
                    end;
                }
                field("Archivo a importar"; strRetCualquiera1)
                {

                    trigger OnAssistEdit()
                    var
                        cduCommonControl: Codeunit Mail;
                        optFiletype: Option " ",Text,Excel,Word,Custom;
                    begin
                        strRetenidoGan := '';
                        strRetenidoSS := '';
                        strRetenidoAg := '';
                        strRetenidoIVA := '';
                        strRetenidoSRV := '';
                        strSICORE := '';
                        optRetExpo := 0;
                        strRetCualquiera2 := '';
                        strPadronAGIP := '';
                        strPadronARBA := '';
                        /*
                        CLEAR(cduCommonControl);
                        
                        strRetCualquiera1 := cduCommonControl.OpenFile('Importar ',
                                            '*.*',optFiletype::Custom,'',0);
                        */
                        Clear(FileMgt);
                        strRetCualquiera1 := FileMgt.UploadFileWithFilter('Importar ', '', 'Archivos de texto (*.txt)|*.txt', '*.txt');

                        case optRet of
                            optRet::" ":
                                Error(Error1);
                            optRet::"Exclusiones de IVA":
                                strRetenidoIVA := strRetCualquiera1;
                            optRet::"Exclusiones de Ganancias":
                                strRetenidoGan := strRetCualquiera1;
                            optRet::"Exclusiones de Seguridad Social":
                                strRetenidoSS := strRetCualquiera1;
                            optRet::"Agentes de retención de IVA":
                                strRetenidoAg := strRetCualquiera1;
                            optRet::Reproweb:
                                strReproweb := strRetCualquiera1;
                            optRet::"Padrón AGIP":
                                strPadronAGIP := strRetCualquiera1;
                            optRet::"Padrón ARBA":
                                strPadronARBA := strRetCualquiera1;
                        end;

                    end;
                }
            }
            group("Exportar ")
            {
                field("Tipo archivo Expo"; optRetExpo)
                {

                    trigger OnValidate()
                    begin
                        strRetCualquiera1 := '';
                        CurrPage.Update;
                    end;
                }
                field("Fecha inicial"; datInicio)
                {
                }
                field("Fecha final"; datFinal)
                {
                }
                field("Archivo a exportar"; strRetCualquiera2)
                {
                    Editable = false;
                    Visible = false;

                    trigger OnAssistEdit()
                    var
                        cduCommonControl: Codeunit "Mail";
                        optFiletype: Option " ",Text,Excel,Word,Custom;
                    begin
                        if (datInicio = 0D) or (datFinal = 0D) then
                            Error(Error2);
                        optRet := 0;
                        strRetCualquiera1 := '';
                        strRetenidoGan := '';
                        strRetenidoSS := '';
                        strRetenidoAg := '';
                        strRetenidoIVA := '';
                        strRetenidoSRV := '';
                        strSICORE := '';
                        strSIRE := '';
                        strCITICompras := '';
                        strComprobarDocumentos := '';
                        strPadronAGIP := '';
                        strAgIP := '';
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Importar/Exportar")
            {
                Image = Import;

                trigger OnAction()
                var
                    rstConfCont: Record "General Ledger Setup";
                    cdu419: Codeunit "File Management";
                begin
                    Clear(cdu419);

                    if (optRetExpo <> optRetExpo::" ") and (optRet <> optRet::" ") then
                        Error('Seleccione una operación de importación o exportación, no puede seleccionar ambas operaciones.');

                    strRetCualquiera2 := FileMgt.ServerTempFileName(strRetCualquiera2);

                    if optRetExpo = optRetExpo::SICORE then
                        strSICORE := strRetCualquiera2;
                    if optRetExpo = optRetExpo::SIRE then
                        strSIRE := strRetCualquiera2;
                    if optRetExpo = optRetExpo::"Comprobar Documentos" then
                        strComprobarDocumentos := strRetCualquiera2;
                    if optRetExpo = optRetExpo::"CITI Compras" then
                        strCITICompras := strRetCualquiera2;
                    if optRetExpo = optRetExpo::AGIP then
                        strAgIP := strRetCualquiera2;
                    if optRetExpo = optRetExpo::"Exportar consulta Reproweb" then
                        strReproweb := strRetCualquiera2;
                    if optRetExpo = optRetExpo::ARBA then
                        strARBA := strRetCualquiera2;
                    if optRetExpo = optRetExpo::IIBB then
                        strIIBB := strRetCualquiera2;

                    if optRet <> optRet::" " then
                        strRetenidoSRV := cdu419.UploadFile('Importar archivo', strRetenidoIVA + strRetenidoAg + strRetenidoSS + strRetenidoGan + strSICORE + strReproweb + strSIRE + strComprobarDocumentos + strCITICompras + strPadronAGIP + strAgIP + strPadronARBA + strARBA + strIIBB);

                    case (strRetenidoIVA + strRetenidoAg + strRetenidoSS + strRetenidoGan + strSICORE + strReproweb + strSIRE + strComprobarDocumentos + strCITICompras + strPadronAGIP + strAgIP + strPadronARBA + strARBA + strIIBB) of
                        strRetenidoIVA:
                            begin

                                fntImportarIVA;

                            end;
                        strRetenidoGan:
                            begin

                                fntImportarGan;

                            end;
                        strRetenidoSS:
                            begin

                                fntImportarSS;

                            end;
                        strRetenidoAg:
                            begin

                                fntImportarAg;

                            end;
                        strSICORE:
                            begin

                                strRetenidoSRV := strRetenidoIVA + strRetenidoAg + strRetenidoSS + strRetenidoGan + strSICORE + strSIRE;
                                fntExportarSICORE;

                            end;
                        strARBA:
                            begin

                                strRetenidoSRV := strRetenidoIVA + strRetenidoAg + strRetenidoSS + strRetenidoGan + strSICORE + strSIRE + strARBA;
                                fntExportarARBA;

                            end;
                        strReproweb:
                            begin

                                if optRetExpo = optRetExpo::"Exportar consulta Reproweb" then begin
                                    strRetenidoSRV := strRetenidoIVA + strRetenidoAg + strRetenidoSS + strRetenidoGan + strSICORE + strSIRE + strReproweb;
                                    fntExportarReproweb;
                                end;
                                if optRet = optRet::Reproweb then
                                    fntImportarReproweb;

                            end;
                        strSIRE:
                            begin

                                strRetenidoSRV := strRetenidoIVA + strRetenidoAg + strRetenidoSS + strRetenidoGan + strSICORE + strSIRE;
                                fntExportarSIRE;

                            end;

                        strComprobarDocumentos:
                            begin

                                strRetenidoSRV := strRetenidoIVA + strRetenidoAg + strRetenidoSS + strRetenidoGan + strSICORE + strSIRE + strComprobarDocumentos;
                                fntExportarComprobarDocumentos;

                            end;

                        strIIBB:
                            begin
                                strRetenidoSRV := strRetenidoIVA + strRetenidoAg + strRetenidoSS + strRetenidoGan + strSICORE + strSIRE + strComprobarDocumentos + strIIBB;
                                fntExportarIIBB;
                            end;
                        strCITICompras:
                            begin

                                strRetenidoSRV := strRetenidoIVA + strRetenidoAg + strRetenidoSS + strRetenidoGan + strSICORE + strSIRE + strComprobarDocumentos +
                                                  strCITICompras;
                                fntExportarCitiCompras;

                            end;

                        strPadronAGIP:
                            begin

                                //strRetenidoSRV := strRetenidoIVA+strRetenidoAg+strRetenidoSS+strRetenidoGan+strSICORE+strSIRE+strComprobarDocumentos+
                                //                  strCITICompras+strPadronAGIP;

                                //strRetenidoSRV := strPadronARBA;
                                fntImportarAgiP;

                            end;

                        strAgIP:
                            begin

                                strRetenidoSRV := strAgIP;
                                fntExportarAGIP;
                                fntExportarAGIPNC;

                            end;

                        strPadronARBA:
                            begin

                                fntImportarARBA;

                            end;

                    end;

                    Message(Message1, Format(j));

                    CurrPage.Close;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref("Importar/Exportar_Promoted"; "Importar/Exportar")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        strRetCualquiera2 := '';
        strRetCualquiera1 := '';
    end;

    var
        strRetenidoIVA: Text[1024];
        dlgDialogo: Dialog;
        strRetenidoGan: Text[1024];
        strRetenidoSS: Text[1024];
        strRetenidoAg: Text[1024];
        strRetenidoSRV: Text[1024];
        strReproweb: Text[1024];
        strSICORE: Text[1024];
        strSIRE: Text[1024];
        strCITICompras: Text[1024];
        strComprobarDocumentos: Text[1024];
        strPadronAGIP: Text[1024];
        strAgIP: Text[1024];
        strPadronARBA: Text[1024];
        strARBA: Text[1024];
        strIIBB: Text[1024];
        optRet: Option " ","Exclusiones de IVA","Exclusiones de Ganancias","Exclusiones de Seguridad Social","Agentes de retención de IVA",Reproweb,"Padrón AGIP","Padrón ARBA";
        optRetExpo: Option " ",SICORE,SIRE,"Comprobar Documentos","CITI Compras",AGIP,"Exportar consulta Reproweb",ARBA,IIBB;
        strRetCualquiera1: Text[1024];
        Error1: Label 'Por favor, seleccione primero el tipo de archivo a importar';
        strRetCualquiera2: Text[1024];
        strRetCualquiera3: Text[1024];
        datInicio: Date;
        datFinal: Date;
        FileMgt: Codeunit "File Management";
        DOSFile: File;
        Error2: Label 'Please, first enter the date filter for the withholdings to export';
        Message1: Label 'Acción finalizada. Se han procesado %1 registros.';
        rstVATEntry: Record "VAT Entry";
        lindecla: Record "VAT Statement Line";
        secci: Code[20];
        decImpoRet: Decimal;
        rstProv: Record Vendor;
        rstTaxGroup: Record "Tax Group";
        rstTaxJur: Record "Tax Jurisdiction";
        k: Integer;
        Comprador: Record Vendor;
        Importemostrar: Decimal;
        movivaanterior: Record "VAT Entry";
        i: Integer;
        Movivasiguiente: Record "VAT Entry";
        cambiodia: Boolean;
        ultimapagina: Boolean;
        palabra: Text[30];
        footerprinted: Boolean;
        LastFieldNo: Integer;
        Importetotal: Decimal;
        Importegravado: Decimal;
        totalimportetotal: Decimal;
        totalimportegravado: Decimal;
        thistoricofactura: Record "Purch. Inv. Header";
        thistoriconota: Record "Purch. Cr. Memo Hdr.";
        importeotros: Decimal;
        totalimporteotros: Decimal;
        Filtregcg: Text[250];
        posi: Integer;
        LONG: Integer;
        SUBSTRING: Text[30];
        tlin: Record "VAT Statement Line";
        txtfiltros: Text[250];
        impordl: Boolean;
        VarFechaDocFact: Date;
        PunMovProv: Record "Vendor Ledger Entry";
        VarMovPRov: Boolean;
        ExcelBuffer: Record "Excel Buffer";
        blnExcel: Boolean;
        blnExcelRein: Boolean;
        rstCGCont: Record "General Posting Setup";
        rstCuenta: Record "G/L Account";
        blnMostrarNoPagadas: Boolean;
        rstInfoEmpre: Record "Company Information";
        codDocEx: Code[30];
        blnBuffer: Boolean;
        rstDigitales: Record "Documentos digitalizados";
        Titulo1: Text[200];
        Importe1: Decimal;
        Titulo2: Text[200];
        Importe2: Decimal;
        Titulo3: Text[200];
        Importe3: Decimal;
        Titulo4: Text[200];
        Importe4: Decimal;
        Titulo5: Text[200];
        Importe5: Decimal;
        Titulo6: Text[200];
        Importe6: Decimal;
        Titulo7: Text[200];
        Importe7: Decimal;
        Titulo8: Text[200];
        Importe8: Decimal;
        Titulo9: Text[200];
        Importe9: Decimal;
        Titulo10: Text[200];
        Importe10: Decimal;
        datIni: Date;
        datFin: Date;
        rstVLE: Record "Vendor Ledger Entry";
        j: Integer;
        l: Integer;
        AsciiStr: Text[250];
        AnsiStr: Text[250];
        CharVar: array[32] of Char;
        strArchivo: Text;

    [Scope('OnPrem')]
    procedure fntImportarIVA()
    var
        StreamInTest: InStream;
        Txt: Text[250];
        rstProv: Record Vendor;
        rstRet: Record "Withholding details";
        codProv: Code[11];
        strProv: Text[60];
        datDesde: Date;
        datHasta: Date;
        intPor: Integer;
        codDoc: Code[20];
        intCant: Integer;
        FileTest: File;
        rstGLS: Record "General Ledger Setup";
        i: Integer;
        l_rst99008535: Codeunit "Temp Blob";
        l_rrDocsDigitalizados: RecordRef;
        l_rstDocumentosDigitalizados: Record "Documentos digitalizados";
        intLinea: Integer;
        l_OutStream: OutStream;
        cduFM: Codeunit "File Management";
        cduCompress: Codeunit "Data Compression";
        cduGA: Codeunit GestionArchivos;
        ZipFile: DotNet ZipFile;
        Zip: DotNet ZipFileExtensions;
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
        EntryContentBlob: Codeunit "Temp Blob";
        EntryInStr: InStream;
        EntryList: List of [Text];
        EntryName: Text;
        EntryIndex: Integer;
        TempBlob: Codeunit "Temp Blob";
        TextoContenido: Text;
        DestinationFolder: Text;
        ZipArchiveMode: DotNet ZipArchiveMode;
        ZipArchive: DotNet ZipArchive;
        l_NameValueBuffer: Record "Name/Value Buffer";
        l_Folder: Text;
        rstRL: Record "Record Link";
        LinkID: Integer;
        l_rstCI: Record "Company Information";
    begin
        Clear(rstGLS);
        rstGLS.Get();

        // Descargar el ZIP
        if not HttpClient.Get(rstGLS."RG17 URL", HttpResponse) then
            Error('No se pudo acceder a la URL.');

        // Create directory if it doesn't exist
        strRetenidoSRV := cduGA.DownloadFromURL(rstGLS."RG17 URL", rstGLS."RG17 ext");
        /*
        if (rstGLS."RG17 URL" <> '') and (rstGLS."RG17 ext" <> '') then
            FileMgt.DownloadHandler(rstGLS."RG17 URL", 'Bajar el archivo', strRetenidoSRV, '', rstGLS."RG17 ext");
        */
        rstRet.SetRange("Tipo retención", rstRet."Tipo retención"::IVA);
        rstRet.SetFilter("Fecha efectividad retencion", '>%1', WorkDate);
        rstRet.DeleteAll;

        FileTest.Open(strRetenidoSRV);
        FileTest.CreateInStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');

        i := 0;

        while not (StreamInTest.EOS) do begin
            StreamInTest.ReadText(Txt);

            i += 1;
            if (i > 0) and (StrPos(Txt, '/') <> 0) then begin

                codProv := CopyStr(Txt, 2, 11);
                strProv := CopyStr(Txt, 14, 60);
                Evaluate(datDesde, CopyStr(Txt, 75, 10));
                Evaluate(datHasta, CopyStr(Txt, 86, 10));
                Evaluate(intPor, CopyStr(Txt, 106, 3));
                codDoc := CopyStr(Txt, 110, 6);

                dlgDialogo.Update(1, Txt);

                if codProv <> '' then begin

                    Clear(rstProv);
                    rstProv.SetRange("VAT Registration No.", CopyStr(codProv, 1, 2) + '-' + CopyStr(codProv, 3, 8) + '-' + CopyStr(codProv, 11, 1));
                    if rstProv.FindFirst then begin

                        case codDoc of
                            'RG2226':
                                begin

                                    Clear(rstRet);
                                    if not rstRet.Get(rstRet."Tipo registro"::Compra, CopyStr(codProv, 1, StrLen(codProv) - 1), rstRet."Tipo retención"::IVA, datHasta) then begin

                                        rstRet."Tipo registro" := rstRet."Tipo registro"::Compra;
                                        rstRet."Cod. proveedor/cliente" := CopyStr(codProv, 1, StrLen(codProv) - 1);
                                        rstRet."Tipo retención" := rstRet."Tipo retención"::IVA;
                                        rstRet."Fecha efectividad retencion" := datHasta;
                                        rstRet."Fecha documento" := datDesde;
                                        rstRet."% exención" := intPor;
                                        rstRet."No. documento" := codDoc;
                                        rstRet.Insert;

                                        j += 1;

                                    end;

                                end;

                        end;

                    end;

                end;

            end;

        end;

        dlgDialogo.Close;

        Clear(cduFM);
        cduFM.BLOBImportFromServerFile(l_rst99008535, strRetenidoSRV);

        Clear(l_rstDocumentosDigitalizados);
        if l_rstDocumentosDigitalizados.Find('+') then
            intLinea := l_rstDocumentosDigitalizados.Linea
        else
            intLinea := 1;

        Clear(l_rstDocumentosDigitalizados);
        l_rstDocumentosDigitalizados.Linea := intLinea + 1;
        l_rstDocumentosDigitalizados.Archivo := strRetenidoSRV;
        l_rstDocumentosDigitalizados."Nivel 1" := 'txt';
        l_rstDocumentosDigitalizados."Nivel 4" := 'RG17';
        l_rstDocumentosDigitalizados.Insert;

        clear(l_rrDocsDigitalizados);
        l_rrDocsDigitalizados.get(l_rstDocumentosDigitalizados.RecordId);
        l_rst99008535.ToRecordRef(l_rrDocsDigitalizados, l_rstDocumentosDigitalizados.FieldNo("BlobFile"));
        l_rrDocsDigitalizados.Modify;

        clear(l_rstCI);
        l_rstCI.get();

        strRetenidoSRV := l_rstCI."Ruta de digitalizacion" + l_rstCI."Ruta cabecera digitalizacion" + cduFM.GetFileName(l_rstDocumentosDigitalizados.Archivo);
        If File.Exists(strRetenidoSRV) then
            strRetenidoSRV := CopyStr(strRetenidoSRV, 1, StrLen(strRetenidoSRV) - 4) + DelChr(format(CurrentDateTime, 10, 1), '=', '/ :') + '.txt';
        cduFM.CopyServerFile(l_rstDocumentosDigitalizados.Archivo, strRetenidoSRV, true);
        IF STRPOS(UPPERCASE(strRetenidoSRV), UPPERCASE(l_rstCI."Ruta Intranet")) = 0 THEN
            strRetenidoSRV := l_rstCI."Ruta Intranet" + (CONVERTSTR(COPYSTR(strRetenidoSRV, STRLEN(l_rstCI."Ruta de digitalizacion"), 250), '\', '/'));
        LinkID := rstGLS.AddLink(strRetenidoSRV, 'RG17 importado el ' + Format(Today));
        Clear(rstRL);
        rstRL.Get(LinkID);

        FileTest.Close();

        Message('Importación finalizada');
    end;

    [Scope('OnPrem')]
    procedure fntImportarGan()
    var
        StreamInTest: InStream;
        Txt: Text[250];
        rstProv: Record Vendor;
        rstRet: Record "Withholding details";
        codProv: Code[11];
        strProv: Text[60];
        datDesde: Date;
        datHasta: Date;
        intPor: Integer;
        codDoc: Code[20];
        intCant: Integer;
        FileTest: File;
        strDato: Text[250];
        strVacio: Text[250];
        datPublic: Date;
        rstGLS: Record "General Ledger Setup";
        l_rst99008535: codeunit "Temp Blob";
        l_rstDocumentosDigitalizados: Record "Documentos digitalizados";
        intLinea: Integer;
        cduFM: Codeunit GestionArchivos;
        strRS: Text[100];
        codPF: Code[10];
        strDesc: Text[100];
        j: Integer;
        streamReader: DotNet StreamReader;
        l_rrDocsDigitalizados: RecordRef;
        encoding: DotNet Encoding;
        cduGA: Codeunit "File Management";
        rstRL: Record "Record Link";
        LinkID: Integer;
        l_rstCI: Record "Company Information";
    begin
        Clear(rstGLS);
        rstGLS.Get();
        if (rstGLS."RG830 URL" <> '') and (rstGLS."RG830 ext" <> '') then
            strRetenidoSRV := cduFM.DownloadFromURL(rstGLS."RG830 URL", rstGLS."RG830 ext");

        rstRet.SetRange("Tipo retención", rstRet."Tipo retención"::Ganancias);
        rstRet.SetFilter("Fecha efectividad retencion", '>%1', WorkDate);
        rstRet.DeleteAll;

        FileTest.Open(strRetenidoSRV);
        FileTest.CreateInStream(StreamInTest);


        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');

        j := 0;

        streamReader := streamReader.StreamReader(StreamInTest, encoding.UTF8);

        while not (streamReader.EndOfStream/*StreamInTest.EOS*/) do begin

            j += 1;
            //StreamInTest.READTEXT(Txt);
            Txt := streamReader.ReadLine;

            strDato := '';
            strDato := Txt;

            if j <> 1 then begin

                for i := 1 to 8 do begin

                    case i of
                        1: //No. Certificado
                            begin
                                codDoc := CopyStr(strDato, 1, StrPos(strDato, ';') - 1);
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        2: //CUIT
                            begin
                                codProv := CopyStr(strDato, 1, StrPos(strDato, ';') - 1);
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        3: //Razón social
                            begin
                                strRS := CopyStr(strDato, 1, StrPos(strDato, ';') - 1);
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        4: //Periodo fiscal
                            begin
                                codPF := CopyStr(strDato, 1, StrPos(strDato, ';') - 1);
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        5: //Porcentaje
                            begin
                                Evaluate(intPor, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        6: //Resolución
                            begin
                                strDesc := CopyStr(strDato, 1, StrPos(strDato, ';') - 1);
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        7: //Fecha desde
                            begin
                                Evaluate(datDesde, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        /*8: //Fecha publicación
                        BEGIN
                          EVALUATE(datPublic,COPYSTR(strDato,1,STRPOS(strDato,';')-1));
                          strDato := COPYSTR(strDato,STRPOS(strDato,';')+1,250);
                        END;*/
                        8: //Fecha hasta
                            begin
                                Evaluate(datHasta, CopyStr(strDato, 1, 20));
                            end;

                    end;

                end;

                dlgDialogo.Update(1, Txt);
                if codProv <> '' then begin

                    Clear(rstProv);
                    rstProv.SetRange(rstProv."VAT Registration No.", CopyStr(codProv, 1, 2) + '-' + CopyStr(codProv, 3, 8) + '-' + CopyStr(codProv, 11, 1));
                    if rstProv.FindFirst then begin

                        Clear(rstRet);
                        if not rstRet.Get(rstRet."Tipo registro"::Compra, CopyStr(codProv, 1, StrLen(codProv) - 1), rstRet."Tipo retención"::Ganancias, datHasta) then begin

                            rstRet."Tipo registro" := rstRet."Tipo registro"::Compra;
                            rstRet."Cod. proveedor/cliente" := CopyStr(codProv, 1, StrLen(codProv) - 1);
                            rstRet."Tipo retención" := rstRet."Tipo retención"::Ganancias;
                            rstRet."Fecha efectividad retencion" := datHasta;
                            rstRet."Fecha documento" := datDesde;
                            rstRet."Fecha emisión boletin" := datPublic;
                            rstRet."% exención" := intPor;
                            rstRet."No. documento" := codDoc;
                            rstRet.Descripción := strDesc;
                            rstRet."Razon social Proveedor" := strRS;
                            rstRet."Periodo fiscal" := codPF;
                            rstRet.Insert;
                            j += 1;

                        end;

                    end;

                end;

            end;

        end;

        dlgDialogo.Close;

        Clear(FileMgt);
        FileMgt.BLOBImportFromServerFile(l_rst99008535, strRetenidoSRV);

        Clear(l_rstDocumentosDigitalizados);
        if l_rstDocumentosDigitalizados.Find('+') then
            intLinea := l_rstDocumentosDigitalizados.Linea
        else
            intLinea := 1;

        Clear(l_rstDocumentosDigitalizados);
        l_rstDocumentosDigitalizados.Linea := intLinea + 1;
        l_rstDocumentosDigitalizados.Archivo := strRetenidoSRV;
        l_rstDocumentosDigitalizados."Nivel 1" := 'txt';
        l_rstDocumentosDigitalizados."Nivel 4" := 'RG830';
        //l_rstDocumentosDigitalizados.BlobFile := l_rst99008535.Blob;
        l_rstDocumentosDigitalizados.Insert;


        clear(l_rrDocsDigitalizados);
        l_rrDocsDigitalizados.get(l_rstDocumentosDigitalizados.RecordId);
        l_rst99008535.ToRecordRef(l_rrDocsDigitalizados, l_rstDocumentosDigitalizados.FieldNo("BlobFile"));
        l_rrDocsDigitalizados.Modify;

        clear(l_rstCI);
        l_rstCI.get();

        strRetenidoSRV := l_rstCI."Ruta de digitalizacion" + l_rstCI."Ruta cabecera digitalizacion" + cduGA.GetFileName(l_rstDocumentosDigitalizados.Archivo);
        If File.Exists(strRetenidoSRV) then
            strRetenidoSRV := CopyStr(strRetenidoSRV, 1, StrLen(strRetenidoSRV) - 4) + DelChr(format(CurrentDateTime, 10, 1), '=', '/ :') + '.txt';
        clear(cduGA);
        cduGA.CopyServerFile(l_rstDocumentosDigitalizados.Archivo, strRetenidoSRV, true);
        IF STRPOS(UPPERCASE(strRetenidoSRV), UPPERCASE(l_rstCI."Ruta Intranet")) = 0 THEN
            strRetenidoSRV := l_rstCI."Ruta Intranet" + (CONVERTSTR(COPYSTR(strRetenidoSRV, STRLEN(l_rstCI."Ruta de digitalizacion"), 250), '\', '/'));
        LinkID := rstGLS.AddLink(strRetenidoSRV, 'RG830 importado el ' + Format(Today));
        Clear(rstRL);
        rstRL.Get(LinkID);

        FileTest.Close();

        Message('Importación finalizada');

    end;

    [Scope('OnPrem')]
    procedure fntImportarSS()
    var
        StreamInTest: InStream;
        Txt: Text[250];
        rstProv: Record Vendor;
        rstRet: Record "Withholding details";
        codProv: Code[11];
        strProv: Text[60];
        strDesde: Text[25];
        strHasta: Text[25];
        intPor: Integer;
        codDoc: Code[20];
        intCant: Integer;
        FileTest: File;
        strDato: Text[250];
        strVacio: Text[250];
        datPublic: Date;
        codInciso: Code[5];
        intMesHasta: Integer;
        intMesDesde: Integer;
        intDia: Integer;
        intAno: Integer;
        rstGLS: Record "General Ledger Setup";
        l_rst99008535: codeunit "Temp Blob";
        l_rstDocumentosDigitalizados: Record "Documentos digitalizados";
        intLinea: Integer;
        cduFM: Codeunit GestionArchivos;
        strRS: Text[100];
        codPF: Code[10];
        strDesc: Text[100];
        j: Integer;
        streamReader: DotNet StreamReader;
        l_rrDocsDigitalizados: RecordRef;
        encoding: DotNet Encoding;
        cduGA: Codeunit "File Management";
        rstRL: Record "Record Link";
        LinkID: Integer;
        l_rstCI: Record "Company Information";
    begin
        rstRet.SetRange("Tipo retención", rstRet."Tipo retención"::"Seguridad Social");
        rstRet.SetFilter("Fecha efectividad retencion", '>%1', WorkDate);
        rstRet.DeleteAll;

        FileTest.Open(strRetenidoSRV);
        FileTest.CreateInStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');


        while not (StreamInTest.EOS) do begin

            StreamInTest.ReadText(Txt);

            strDato := '';
            strDato := Txt;

            if StrPos(strDato, ';') <> 0 then begin

                for i := 1 to 8 do begin

                    case i of
                        1:
                            begin
                                codProv := CopyStr(strDato, 1, StrPos(strDato, ';') - 1);
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        2:
                            begin
                                codDoc := CopyStr(strDato, 1, StrPos(strDato, ';') - 1);
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        3:
                            begin
                                strVacio := CopyStr(strDato, 1, StrPos(strDato, ';') - 1);
                                if StrLen(strVacio) <> 0 then
                                    strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250)
                                else
                                    strDato := CopyStr(strDato, 2, 250)
                            end;
                        4:
                            begin
                                Evaluate(intPor, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        5, 6:
                            begin
                                strVacio := CopyStr(strDato, 1, StrPos(strDato, ';') - 1);
                                if StrLen(strVacio) <> 0 then
                                    strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250)
                                else
                                    strDato := CopyStr(strDato, 2, 250)
                            end;
                        7:
                            begin
                                Evaluate(strDesde, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        8:
                            begin
                                Evaluate(strHasta, CopyStr(strDato, 1, 25));
                            end;

                    end;

                end;

                dlgDialogo.Update(1, Txt);

                case CopyStr(strHasta, 4, 3) of
                    'JAN':
                        intMesHasta := 1;
                    'FEB':
                        intMesHasta := 2;
                    'MAR':
                        intMesHasta := 3;
                    'APR':
                        intMesHasta := 4;
                    'MAY':
                        intMesHasta := 5;
                    'JUN':
                        intMesHasta := 6;
                    'JUL':
                        intMesHasta := 7;
                    'AUG':
                        intMesHasta := 8;
                    'SEP':
                        intMesHasta := 9;
                    'OCT':
                        intMesHasta := 10;
                    'NOV':
                        intMesHasta := 11;
                    'DEC':
                        intMesHasta := 12;
                end;

                case CopyStr(strDesde, 4, 3) of
                    'JAN':
                        intMesDesde := 1;
                    'FEB':
                        intMesDesde := 2;
                    'MAR':
                        intMesDesde := 3;
                    'APR':
                        intMesDesde := 4;
                    'MAY':
                        intMesDesde := 5;
                    'JUN':
                        intMesDesde := 6;
                    'JUL':
                        intMesDesde := 7;
                    'AUG':
                        intMesDesde := 8;
                    'SEP':
                        intMesDesde := 9;
                    'OCT':
                        intMesDesde := 10;
                    'NOV':
                        intMesDesde := 11;
                    'DEC':
                        intMesDesde := 12;
                end;

                if (codProv <> '') and (codInciso <> 'D') then begin

                    Clear(rstProv);
                    rstProv.SetRange(rstProv."VAT Registration No.", CopyStr(codProv, 1, 2) + '-' + CopyStr(codProv, 3, 8) + '-' + CopyStr(codProv, 11, 1));
                    if rstProv.FindFirst then begin

                        Evaluate(intDia, CopyStr(strHasta, 1, 2));
                        Evaluate(intAno, CopyStr(strHasta, 8, 2));
                        intAno := intAno + 2000;

                        Clear(rstRet);
                        if not rstRet.Get(rstRet."Tipo registro"::Compra, CopyStr(codProv, 1, StrLen(codProv) - 1), rstRet."Tipo retención"::"Seguridad Social",
                                          DMY2Date(intDia, intMesHasta, intAno)) then begin

                            rstRet."Tipo registro" := rstRet."Tipo registro"::Compra;
                            rstRet."Fecha efectividad retencion" := DMY2Date(intDia, intMesHasta, intAno);
                            rstRet."Cod. proveedor/cliente" := CopyStr(codProv, 1, StrLen(codProv) - 1);
                            rstRet."Tipo retención" := rstRet."Tipo retención"::"Seguridad Social";
                            Evaluate(intDia, CopyStr(strDesde, 1, 2));
                            Evaluate(intAno, CopyStr(strDesde, 8, 2));
                            intAno := intAno + 2000;
                            rstRet."Fecha documento" := DMY2Date(intDia, intMesDesde, intAno);
                            ;
                            rstRet."% exención" := intPor;
                            rstRet."No. documento" := codDoc;
                            rstRet.Insert;

                            j += 1;

                        end;

                    end;

                end;

            end;

        end;

        dlgDialogo.Close;

        Clear(FileMgt);
        FileMgt.BLOBImportFromServerFile(l_rst99008535, strRetenidoSRV);

        Clear(l_rstDocumentosDigitalizados);
        if l_rstDocumentosDigitalizados.Find('+') then
            intLinea := l_rstDocumentosDigitalizados.Linea
        else
            intLinea := 1;

        Clear(l_rstDocumentosDigitalizados);
        l_rstDocumentosDigitalizados.Linea := intLinea + 1;
        l_rstDocumentosDigitalizados.Archivo := strRetenidoSRV;
        l_rstDocumentosDigitalizados."Nivel 1" := 'txt';
        l_rstDocumentosDigitalizados."Nivel 4" := 'RGSS';
        //l_rstDocumentosDigitalizados.BlobFile := l_rst99008535.Blob;
        l_rstDocumentosDigitalizados.Insert;

        clear(l_rrDocsDigitalizados);
        l_rrDocsDigitalizados.get(l_rstDocumentosDigitalizados.RecordId);
        l_rst99008535.ToRecordRef(l_rrDocsDigitalizados, l_rstDocumentosDigitalizados.FieldNo("BlobFile"));
        l_rrDocsDigitalizados.Modify;

        clear(l_rstCI);
        l_rstCI.get();

        strRetenidoSRV := l_rstCI."Ruta de digitalizacion" + l_rstCI."Ruta cabecera digitalizacion" + cduGA.GetFileName(l_rstDocumentosDigitalizados.Archivo);
        If File.Exists(strRetenidoSRV) then
            strRetenidoSRV := CopyStr(strRetenidoSRV, 1, StrLen(strRetenidoSRV) - 4) + DelChr(format(CurrentDateTime, 10, 1), '=', '/ :') + '.txt';
        clear(cduGA);
        cduGA.CopyServerFile(l_rstDocumentosDigitalizados.Archivo, strRetenidoSRV, true);
        IF STRPOS(UPPERCASE(strRetenidoSRV), UPPERCASE(l_rstCI."Ruta Intranet")) = 0 THEN
            strRetenidoSRV := l_rstCI."Ruta Intranet" + (CONVERTSTR(COPYSTR(strRetenidoSRV, STRLEN(l_rstCI."Ruta de digitalizacion"), 250), '\', '/'));
        LinkID := rstGLS.AddLink(strRetenidoSRV, 'Padrón Seguridad Social importado el ' + Format(Today));
        Clear(rstRL);
        rstRL.Get(LinkID);

        FileTest.Close();
    end;

    [Scope('OnPrem')]
    procedure fntImportarAg()
    var
        StreamInTest: InStream;
        Txt: Text[250];
        rstProv: Record Vendor;
        rstRet: Record "Withholding details";
        codProv: Code[11];
        strProv: Text[60];
        datDesde: Date;
        datHasta: Date;
        intPor: Integer;
        codDoc: Code[20];
        intCant: Integer;
        FileTest: File;
        strDato: Text[250];
        strVacio: Text[250];
        datPublic: Date;
        codInciso: Code[1];
        rstGLS: Record "General Ledger Setup";
        l_rst99008535: Codeunit "Temp Blob";
        l_rstDocumentosDigitalizados: Record "Documentos digitalizados";
        intLinea: Integer;
        cduFM: Codeunit GestionArchivos;
        cduGA: Codeunit "File Management";
        rstRL: Record "Record Link";
        LinkID: Integer;
        l_rstCI: Record "Company Information";
    begin
        Clear(rstGLS);
        rstGLS.Get();
        if (rstGLS."RG18 URL" <> '') and (rstGLS."RG18 ext" <> '') then
            strRetenidoSRV := cduFM.DownloadFromURL(rstGLS."RG18 URL", rstGLS."RG18 ext");

        rstRet.SetRange("Tipo retención", rstRet."Tipo retención"::"Agente de retención IVA");
        rstRet.SetFilter("Fecha efectividad retencion", '>%1', WorkDate);
        rstRet.DeleteAll;

        FileTest.Open(strRetenidoSRV);
        FileTest.CreateInStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');


        while not (StreamInTest.EOS) do begin

            StreamInTest.ReadText(Txt);

            strDato := '';
            strDato := Txt;

            if (StrPos(Txt, ';') <> 0) and (CopyStr(Txt, 1, 4) <> 'CUIT') then begin

                for i := 1 to 5 do begin

                    case i of
                        1:
                            begin
                                codProv := CopyStr(strDato, 1, StrPos(strDato, ';') - 1);
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        2:
                            begin
                                strProv := CopyStr(strDato, 1, StrPos(strDato, ';') - 1);
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        3:
                            begin
                                Evaluate(datDesde, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        4:
                            begin
                                Evaluate(datHasta, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                                strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                            end;
                        5:
                            begin
                                Evaluate(codInciso, CopyStr(strDato, 1, 1));
                            end;

                    end;

                end;

                dlgDialogo.Update(1, Txt);

                if (codProv <> '') and (codInciso <> 'D') then begin

                    Clear(rstProv);
                    rstProv.SetRange(rstProv."VAT Registration No.", CopyStr(codProv, 1, 2) + '-' + CopyStr(codProv, 3, 8) + '-' + CopyStr(codProv, 11, 1));
                    if rstProv.FindFirst then begin

                        Clear(rstRet);
                        if not rstRet.Get(rstRet."Tipo registro"::Compra, CopyStr(codProv, 1, StrLen(codProv) - 1), rstRet."Tipo retención"::"Agente de retención IVA", datHasta) then begin

                            rstRet."Tipo registro" := rstRet."Tipo registro"::Compra;
                            rstRet."Cod. proveedor/cliente" := CopyStr(codProv, 1, StrLen(codProv) - 1);
                            rstRet."Tipo retención" := rstRet."Tipo retención"::"Agente de retención IVA";
                            rstRet."Fecha efectividad retencion" := datHasta;
                            rstRet."Fecha documento" := datDesde;
                            rstRet."No. documento" := codDoc;
                            rstRet.Insert;

                            j += 1;

                        end;

                    end;

                end;

            end;

        end;

        dlgDialogo.Close;
        Clear(FileMgt);
        FileMgt.BLOBImportFromServerFile(l_rst99008535, strRetenidoSRV);

        Clear(l_rstDocumentosDigitalizados);
        if l_rstDocumentosDigitalizados.Find('+') then
            intLinea := l_rstDocumentosDigitalizados.Linea
        else
            intLinea := 1;

        Clear(l_rstDocumentosDigitalizados);
        l_rstDocumentosDigitalizados.Linea := intLinea + 1;
        l_rstDocumentosDigitalizados.Archivo := strRetenidoSRV;
        l_rstDocumentosDigitalizados."Nivel 1" := 'txt';
        l_rstDocumentosDigitalizados."Nivel 4" := 'RG18';
        //l_rstDocumentosDigitalizados.BlobFile := l_rst99008535.Blob;
        l_rstDocumentosDigitalizados.Insert;

        clear(l_rstCI);
        l_rstCI.get();

        strRetenidoSRV := l_rstCI."Ruta de digitalizacion" + l_rstCI."Ruta cabecera digitalizacion" + cduGA.GetFileName(l_rstDocumentosDigitalizados.Archivo);
        If File.Exists(strRetenidoSRV) then
            strRetenidoSRV := CopyStr(strRetenidoSRV, 1, StrLen(strRetenidoSRV) - 4) + DelChr(format(CurrentDateTime, 10, 1), '=', '/ :') + '.txt';
        clear(cduGA);
        cduGA.CopyServerFile(l_rstDocumentosDigitalizados.Archivo, strRetenidoSRV, true);
        IF STRPOS(UPPERCASE(strRetenidoSRV), UPPERCASE(l_rstCI."Ruta Intranet")) = 0 THEN
            strRetenidoSRV := l_rstCI."Ruta Intranet" + (CONVERTSTR(COPYSTR(strRetenidoSRV, STRLEN(l_rstCI."Ruta de digitalizacion"), 250), '\', '/'));
        LinkID := rstGLS.AddLink(strRetenidoSRV, 'Padrón RG18 importado el ' + Format(Today));
        Clear(rstRL);
        rstRL.Get(LinkID);

        FileTest.Close();

        Message('Importación finalizada');
    end;

    [Scope('OnPrem')]
    procedure fntImportarReproweb()
    var
        StreamInTest: InStream;
        Txt: Text[250];
        rstProv: Record Vendor;
        rstRet: Record "Withholding details";
        codProv: Code[11];
        strProv: Text[60];
        datDesde: Date;
        datHasta: Date;
        intPor: Integer;
        codDoc: Code[20];
        intCant: Integer;
        FileTest: File;
        strDato: Text[250];
        strVacio: Text[250];
        datPublic: Date;
        codInciso: Code[1];
        codNumero: Code[30];
        strFecha: Text[30];
        codEstado: Code[30];
        rstProveedor: Record Vendor;
        rstAreaImpuesto: Record "Tax Area";
        rstFecha: Record Date;
        datFecha: Date;
        rstGLS: Record "General Ledger Setup";
        l_rst99008535: codeunit "Temp Blob";
        l_rstDocumentosDigitalizados: Record "Documentos digitalizados";
        intLinea: Integer;
        cduFM: Codeunit GestionArchivos;
        strRS: Text[100];
        codPF: Code[10];
        strDesc: Text[100];
        j: Integer;
        streamReader: DotNet StreamReader;
        l_rrDocsDigitalizados: RecordRef;
        encoding: DotNet Encoding;
        cduGA: Codeunit "File Management";
        rstRL: Record "Record Link";
        LinkID: Integer;
        l_rstCI: Record "Company Information";
    begin
        FileTest.Open(strRetenidoSRV);
        FileTest.CreateInStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');

        while not (StreamInTest.EOS) do begin

            StreamInTest.ReadText(Txt);

            strDato := '';
            strDato := Txt;

            j += 1;
            //ya no es por distancia, ahora es separación por comas
            /*
            FOR i := 1 TO 8 DO
            BEGIN

              CASE i OF
                {
                1:
                BEGIN
                END;
                }
                2:
                BEGIN
                  codNumero := COPYSTR(strDato,14,11);
                END;
                3:
                BEGIN
                  strProv := COPYSTR(strDato,26,30);
                END;
                4:
                BEGIN
                  EVALUATE(datFecha,('01'+FORMAT(COPYSTR(strDato,58,7))));
                END;
                5:
                BEGIN
                END;
                6:
                BEGIN
                  codEstado := COPYSTR(strDato,94,1);
                END;
                7:
                BEGIN
                END;
                8:
                BEGIN
                END;

              END;

            END;
            */
            for i := 1 to 8 do begin

                case i of
                    1:
                        begin
                            strDato := CopyStr(strDato, StrPos(strDato, ',') + 1, 250);
                        end;
                    2:
                        begin
                            codNumero := CopyStr(strDato, 1, StrPos(strDato, ',') - 1);
                            strDato := CopyStr(strDato, StrPos(strDato, ',') + 1, 250);
                        end;
                    3:
                        begin
                            //strProv := COPYSTR(strDato,1,STRPOS(strDato,',')-1);
                            strDato := CopyStr(strDato, StrPos(strDato, ',') + 1, 250);
                        end;
                    4:
                        begin
                            //EVALUATE(datFecha,('01'+FORMAT(COPYSTR(strDato,1,STRPOS(strDato,',')-1))));
                            strDato := CopyStr(strDato, StrPos(strDato, ',') + 1, 250);
                        end;
                    5:
                        begin
                            codEstado := CopyStr(strDato, 1, StrPos(strDato, ',') - 1);
                            strDato := CopyStr(strDato, StrPos(strDato, ',') + 1, 250);
                        end;
                    6:
                        begin
                            Evaluate(datFecha, (CopyStr(strDato, 1, StrPos(strDato, ',') - 1)));
                            datFecha := CalcDate('<-CM>', datFecha);
                            strDato := CopyStr(strDato, StrPos(strDato, ',') + 1, 250);
                        end;
                    7:
                        begin
                        end;
                    8:
                        begin
                        end;

                end;

            end;

            Clear(rstProveedor);
            if rstProveedor.Get(CopyStr(codNumero, 1, 10)) then begin

                Clear(rstAreaImpuesto);
                if rstAreaImpuesto.Get(rstProveedor."Tax Area Code") then begin

                    if rstAreaImpuesto."Importar Reproweb" then begin

                        Clear(rstFecha);
                        rstFecha.SetRange(rstFecha."Period Type", rstFecha."Period Type"::Month);
                        rstFecha.SetRange("Period Start", datFecha);
                        if rstFecha.Find('-') then
                            rstProveedor."Fecha consulta Reproweb" := rstFecha."Period End";

                        rstProveedor."Estado de situación fiscal" := codEstado;
                        rstProveedor.Modify;

                    end;

                end;

            end;

            dlgDialogo.Update(1, Txt);


        end;

        dlgDialogo.Close;

        clear(l_rstCI);
        l_rstCI.get();

        strRetenidoSRV := l_rstCI."Ruta de digitalizacion" + l_rstCI."Ruta cabecera digitalizacion" + cduGA.GetFileName(l_rstDocumentosDigitalizados.Archivo);
        If File.Exists(strRetenidoSRV) then
            strRetenidoSRV := CopyStr(strRetenidoSRV, 1, StrLen(strRetenidoSRV) - 4) + DelChr(format(CurrentDateTime, 10, 1), '=', '/ :') + '.txt';
        clear(cduGA);
        cduGA.CopyServerFile(l_rstDocumentosDigitalizados.Archivo, strRetenidoSRV, true);
        IF STRPOS(UPPERCASE(strRetenidoSRV), UPPERCASE(l_rstCI."Ruta Intranet")) = 0 THEN
            strRetenidoSRV := l_rstCI."Ruta Intranet" + (CONVERTSTR(COPYSTR(strRetenidoSRV, STRLEN(l_rstCI."Ruta de digitalizacion"), 250), '\', '/'));
        LinkID := rstGLS.AddLink(strRetenidoSRV, 'Padrón Reproweb importado el ' + Format(Today));
        Clear(rstRL);
        rstRL.Get(LinkID);

        FileTest.Close();

    end;

    [Scope('OnPrem')]
    procedure fntExportarSICORE()
    var
        StreamInTest: OutStream;
        Txt: Text[250];
        rstProv: Record Vendor;
        rstRet: Record "Withholding details";
        codProv: Code[11];
        strProv: Text[60];
        datDesde: Date;
        datHasta: Date;
        intPor: Integer;
        codDoc: Text[20];
        intCant: Integer;
        FileTest: File;
        strDato: Text[250];
        strVacio: Text[250];
        datPublic: Date;
        codInciso: Code[1];
        rstInBF: Record "Invoice Withholding Buffer";
        rstMens: Record Mensajeria;
        strDia: Text[2];
        strMes: Text[2];
        strAno: Text[4];
        strFechEm: Text[10];
        strNroComp: Text[20];
        decImp: Text[16];
        intImp: Text[4];
        rstTipoRet: Record "Withholding codes";
        codReg: Text[4];
        intOper: Text[1];
        decBase: Text[16];
        decPorExcl: Text[16];
        strFecRet: Text[10];
        codCond: Text[2];
        intRetPract: Text[1];
        decImpRet: Text[16];
        strFecBol: Text[10];
        intTDocRet: Text[2];
        strNroDocRet: Text[20];
        intNroCert: Text[30];
        rstCont: Record "G/L Entry";
        CrLf: Text;
    begin
        FileTest.TextMode(true);
        FileTest.Create(strRetenidoSRV);
        FileTest.CreateOutStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');


        CrLf[1] := 13;
        CrLf[2] := 10;

        Clear(rstInBF);
        rstInBF.SetCurrentKey("Fecha pago", "Cliente/Proveedor", "No. Factura");
        rstInBF.SetRange("Fecha pago", datInicio, datFinal);
        rstInBF.SetFilter("Tipo retencion", '%1|%2', rstInBF."Tipo retencion"::IVA, rstInBF."Tipo retencion"::Ganancias);
        rstInBF.SetRange(Retenido, true);
        if rstInBF.FindSet then
            repeat

                j += 1;

                Clear(rstCont);
                rstCont.SetCurrentKey(rstCont."Document No.");
                rstCont.SetRange(rstCont."Document No.", rstInBF."No. documento");
                if not rstCont.FindFirst then
                    rstCont.Next
                else begin

                    rstInBF.CalcFields("Factura Prov");
                    codDoc := '';
                    strFechEm := '';
                    strNroComp := '';
                    decImp := '';
                    intImp := '';
                    codReg := '';
                    intOper := '';
                    decBase := '';
                    strFecRet := '';
                    codCond := '';
                    intRetPract := '';
                    decImpRet := '';
                    decPorExcl := '';
                    strFecBol := '';
                    intTDocRet := '';
                    strNroDocRet := '';
                    intNroCert := '';

                    Clear(rstProv);
                    rstProv.Get(rstInBF."Cliente/Proveedor");

                    for i := 1 to 17 do begin

                        case i of
                            1://Código comprobante - 2
                                begin

                                    if rstInBF."No. Factura" <> '' then begin

                                        Clear(rstMens);
                                        rstMens.SetRange(rstMens."Codigo vinculante", rstInBF."Cliente/Proveedor");
                                        rstMens.SetRange(rstMens."No. documento", rstInBF."No. Factura");
                                        if rstMens.Find('+') then begin

                                            case rstMens."Tipo Documento" of
                                                'Factura (compras)', 'Fact. pronto venc. (compras)':
                                                    codDoc := '01';
                                                /*'Nota crédito (compras)':
                                                  codDoc := '03';*/
                                                'Nota débito (compras)', 'Déb. pronto venc. (compras)':
                                                    codDoc := '04';
                                            end;

                                        end;

                                    end;

                                    if rstInBF."Tipo factura" = rstInBF."Tipo factura"::"Nota d/c" then
                                        codDoc := '03';

                                    if rstInBF."Tipo retencion" = rstInBF."Tipo retencion"::Ganancias then
                                        codDoc := '06';

                                    if codDoc = '' then
                                        case rstInBF."Tipo factura" of
                                            rstInBF."Tipo factura"::Factura:
                                                codDoc := '01';
                                            rstInBF."Tipo factura"::"Nota d/c":
                                                codDoc := '03';
                                        end;
                                    fntFillNum(codDoc, 2);

                                end;
                            2://Fecha comprobante - 10
                                begin

                                    if codDoc <> '03' then begin

                                        if rstInBF."Fecha factura" <> 0D then begin

                                            strDia := Format(Date2DMY(rstInBF."Fecha factura", 1));
                                            if StrLen(strDia) = 1 then
                                                strDia := '0' + strDia;
                                            strMes := Format(Date2DMY(rstInBF."Fecha factura", 2));
                                            if StrLen(strMes) = 1 then
                                                strMes := '0' + strMes;
                                            strAno := Format(Date2DMY(rstInBF."Fecha factura", 3));

                                        end
                                        else begin

                                            strDia := Format(Date2DMY(rstInBF."Fecha pago", 1));
                                            if StrLen(strDia) = 1 then
                                                strDia := '0' + strDia;
                                            strMes := Format(Date2DMY(rstInBF."Fecha pago", 2));
                                            if StrLen(strMes) = 1 then
                                                strMes := '0' + strMes;
                                            strAno := Format(Date2DMY(rstInBF."Fecha pago", 3));

                                        end;

                                    end
                                    else begin

                                        strDia := Format(Date2DMY(rstInBF."Fecha pago", 1));
                                        if StrLen(strDia) = 1 then
                                            strDia := '0' + strDia;
                                        strMes := Format(Date2DMY(rstInBF."Fecha pago", 2));
                                        if StrLen(strMes) = 1 then
                                            strMes := '0' + strMes;
                                        strAno := Format(Date2DMY(rstInBF."Fecha pago", 3));

                                    end;

                                    strFechEm := strDia + '/' +
                                                 strMes + '/' +
                                                 strAno;

                                end;
                            3://Número comprobante - 16
                                begin

                                    //strNroComp := DELCHR(rstInBF."Factura Prov",'=',DELCHR(rstInBF."Factura Prov",'=','0123456789'));
                                    rstInBF.CalcFields("Factura Prov");
                                    strNroComp := rstInBF."Factura Prov";
                                    if strNroComp = '' then
                                        //strNroComp := DELCHR(rstInBF."No. documento",'=',DELCHR(rstInBF."No. documento",'=','0123456789'));
                                        strNroComp := rstInBF."No. documento";

                                    strNroComp := fntNum(16, DelChr(strNroComp, '=', DelChr(strNroComp, '=', '0123456789')));
                                    //strNroComp := fntNum(16,DELCHR(strNroComp,'=','0123456789-'));

                                end;
                            4://Importe comprobante - 16
                                begin

                                    decImp := DelChr(Format(fntDecConComa(Round(Abs(rstInBF."Importe neto factura"), 0.01), 2, 16, '')), '=', '.');

                                end;
                            5://Código del impuesto - 4
                                begin

                                    if intImp = '' then begin

                                        case rstInBF."Tipo retencion" of
                                            rstInBF."Tipo retencion"::IVA:
                                                intImp := '0767';
                                            rstInBF."Tipo retencion"::Ganancias:
                                                intImp := '0217';
                                        end;

                                    end;

                                end;
                            6://Código de régimen - 3
                                begin

                                    Clear(rstTipoRet);
                                    rstTipoRet.SetRange("Tipo impuesto retencion", rstInBF."Tipo retencion");
                                    rstTipoRet.SetRange("Cod. retencion", rstInBF."Cod. retencion");
                                    rstTipoRet.Find('+');

                                    codReg := rstTipoRet."Codigo SICORE";

                                    if ((rstInBF."Cod. sicore" > 800)) then
                                        codReg := Format(rstInBF."Cod. sicore");

                                    fntFillNum(codReg, 3);

                                end;
                            7://Código de operación - 1
                                begin

                                    intOper := '1';

                                    if StrLen(intOper) < 1 then
                                        repeat

                                            intOper := ' ' + intOper;

                                        until StrLen(intOper) = 1;
                                    fntFillNum(intOper, 1);

                                end;
                            8:// Base de cálculo - 14
                                begin

                                    if rstInBF."Tipo retencion" = rstInBF."Tipo retencion"::IVA then begin

                                        if codDoc = '03' then
                                            decBase := DelChr(Format(fntDecConComa(Round(Abs(rstInBF."Importe retencion"), 0.01), 2, 14, '')), '=', '.')
                                        else
                                            decBase := DelChr(Format(fntDecConComa(Round(Abs(rstInBF."Importe neto factura"), 0.01), 2, 14, '')), '=', '.');

                                    end;

                                    if rstInBF."Tipo retencion" = rstInBF."Tipo retencion"::Ganancias then
                                        decBase := DelChr(Format(fntDecConComa(Round(Abs(rstInBF."Base pago retencion"), 0.01), 2, 14, '')), '=', '.');

                                end;
                            9://Fecha emisión retención - 10
                                begin
                                    strFecRet := PadStr(strFecRet, 10, ' ');
                                end;
                            10://Código de condición - 2
                                begin
                                    case rstInBF."Tipo retencion" of
                                        rstInBF."Tipo retencion"::IVA:
                                            begin
                                                if codReg = '499' then
                                                    codCond := '01'
                                                else
                                                    codCond := '00';
                                            end;
                                        rstInBF."Tipo retencion"::Ganancias:
                                            codCond := '01';
                                    end;
                                end;
                            11://Retención realizada sujetos suspendidos - 1
                                begin

                                    fntFillNum(intRetPract, 1);
                                    /*
                                    IF STRLEN(intRetPract)<1 THEN
                                    REPEAT

                                      intRetPract := ' '+intRetPract;

                                    UNTIL STRLEN(intRetPract)=1;
                                    */
                                end;
                            12://Impo retención - 14
                                begin

                                    decImpRet := DelChr(Format(fntDecConComa(Round(Abs(rstInBF."Importe retencion"), 0.01), 2, 14, '')), '=', '.');
                                    /*IF STRLEN(decImpRet)<14 THEN
                                    REPEAT

                                      decImpRet := ' '+decImpRet;

                                    UNTIL STRLEN(decImpRet)=14;*/

                                end;
                            13://Porcentaje exclusión - 6
                                begin

                                    decPorExcl := DelChr(Format(fntDecConComa(Round(Abs(rstInBF."% Exclusion"), 0.01), 2, 6, '')), '=', '.');
                                    /*IF STRLEN(decPorExcl)<6 THEN
                                    REPEAT

                                      decPorExcl := ' '+decPorExcl;

                                    UNTIL STRLEN(decPorExcl)=6;*/

                                end;
                            14://Fecha publicación - 10
                                begin
                                    if rstInBF."Fecha documento exclusion" <> 0D then begin

                                        strDia := Format(Date2DMY(rstInBF."Fecha documento exclusion", 1));
                                        if StrLen(strDia) = 1 then
                                            strDia := '0' + strDia;
                                        strMes := Format(Date2DMY(rstInBF."Fecha documento exclusion", 2));
                                        if StrLen(strMes) = 1 then
                                            strMes := '0' + strMes;
                                        strAno := Format(Date2DMY(rstInBF."Fecha documento exclusion", 3));

                                    end;

                                    strFecBol := strDia + '/' +
                                                 strMes + '/' +
                                                 strAno;
                                    if strFecBol = '' then
                                        strFecBol := '00/00/0000';
                                end;
                            15://Tipo documento - 2
                                begin

                                    intTDocRet := '80';

                                    if StrLen(intTDocRet) < 2 then
                                        repeat

                                            intTDocRet := ' ' + intTDocRet;

                                        until StrLen(intTDocRet) = 2;

                                end;
                            16://Número documento - 20
                                begin

                                    strNroDocRet := DelChr(rstProv."VAT Registration No.", '=', DelChr(rstProv."VAT Registration No.", '=', '0123456789'));
                                    strNroDocRet := PadStr(strNroDocRet, 20, ' ');

                                end;
                            17://Número certificado - 14
                                begin

                                    j += 1;
                                    intNroCert := Format(j);
                                    if StrLen(intNroCert) < 14 then
                                        repeat

                                            intNroCert := '0' + intNroCert;

                                        until StrLen(intNroCert) = 14;

                                end;

                        end;

                    end;


                    if codDoc = '03' then begin

                        strDia := Format(Date2DMY(rstInBF."Fecha factura", 1));
                        if StrLen(strDia) = 1 then
                            strDia := '0' + strDia;
                        strMes := Format(Date2DMY(rstInBF."Fecha factura", 2));
                        if StrLen(strMes) = 1 then
                            strMes := '0' + strMes;
                        strAno := Format(Date2DMY(rstInBF."Fecha factura", 3));
                        strFecRet := strDia + '/' +
                                     strMes + '/' +
                                     strAno;

                    end
                    else begin

                        strDia := Format(Date2DMY(rstInBF."Fecha pago", 1));
                        if StrLen(strDia) = 1 then
                            strDia := '0' + strDia;
                        strMes := Format(Date2DMY(rstInBF."Fecha pago", 2));
                        if StrLen(strMes) = 1 then
                            strMes := '0' + strMes;
                        strAno := Format(Date2DMY(rstInBF."Fecha pago", 3));
                        strFecRet := strDia + '/' +
                                     strMes + '/' +
                                     strAno;

                    end;
                    /*
                    codDoc := PADSTR(codDoc,2,' ');
                    strFechEm := PADSTR(strFechEm,10,' ');
                    {strNroComp := }
                    fntFillAlfa(strNroComp,16);
                    strFecRet :=  PADSTR(strFecRet,10,' ');
                    strFecBol :=  PADSTR(strFecBol,10,' ');
                    strNroDocRet := PADSTR(strNroDocRet,20,' ');
                    IF STRLEN(decImp)<16 THEN
                    REPEAT

                      decImp := ' '+decImp;

                    UNTIL STRLEN(decImp)=16;

                    IF STRLEN(intImp)<3 THEN
                    REPEAT

                      intImp := ' '+intImp;

                    UNTIL STRLEN(intImp)=3;

                    IF STRLEN(codReg)<3 THEN
                    REPEAT

                      codReg := ' '+codReg;

                    UNTIL STRLEN(codReg)=3;

                    IF STRLEN(intOper)<1 THEN
                    REPEAT

                      intOper := ' '+intOper;

                    UNTIL STRLEN(intOper)=1;

                    IF STRLEN(decBase)<14 THEN
                    REPEAT

                      decBase := ' '+decBase;

                    UNTIL STRLEN(decBase)=14;

                    IF STRLEN(intRetPract)<1 THEN
                    REPEAT

                      intRetPract := ' '+intRetPract;

                    UNTIL STRLEN(intRetPract)=1;

                    IF STRLEN(decImpRet)<14 THEN
                    REPEAT

                      decImpRet := ' '+decImpRet;

                    UNTIL STRLEN(decImpRet)=14;

                    IF STRLEN(decPorExcl)<6 THEN
                    REPEAT

                      decPorExcl := ' '+decPorExcl;

                    UNTIL STRLEN(decPorExcl)=6;

                    intTDocRet := '80';

                    IF STRLEN(intTDocRet)<2 THEN
                    REPEAT

                      intTDocRet := ' '+intTDocRet;

                    UNTIL STRLEN(intTDocRet)=2;
                    */
                    fntFillAlfa(codDoc, 2);
                    fntFillAlfa(strNroComp, 16);
                    //fntDecConComa(decImp,2,16);
                    fntFillNum(intImp, 3);
                    fntFillNum(codReg, 3);
                    fntFillNum(intOper, 1);
                    //fntDecConComa(decBase,2,14);
                    fntFillAlfa(codCond, 2);
                    //fntFillNum(decImpRet,14);
                    //fntFillNum(decPorExcl,6);
                    fntFillNum(intTDocRet, 2);
                    fntFillAlfa(strNroDocRet, 20);
                    fntFillAlfa(intNroCert, 14);

                    Txt :=
                                           codDoc +
                                           strFechEm +
                                           strNroComp +
                                           decImp +
                                           intImp +
                                           codReg +
                                           intOper +
                                           decBase +
                                           strFecRet +
                                           codCond +
                                           intRetPract +
                                           decImpRet +
                                           decPorExcl +
                                           strFecBol +
                                           intTDocRet +
                                           strNroDocRet +
                                           intNroCert;

                    dlgDialogo.Update(1, Txt);

                    if (codProv <> '') and (codInciso <> 'D') then begin

                        Clear(rstProv);
                        rstProv.SetRange(rstProv."VAT Registration No.", CopyStr(codProv, 1, 2) + '-' + CopyStr(codProv, 3, 8) + '-' + CopyStr(codProv, 11, 1));
                        if rstProv.FindFirst then begin

                            Clear(rstRet);
                            if not rstRet.Get(CopyStr(codProv, 1, StrLen(codProv) - 1), rstRet."Tipo retención"::"Agente de retención IVA", datHasta) then begin

                                rstRet."Cod. proveedor/cliente" := CopyStr(codProv, 1, StrLen(codProv) - 1);
                                rstRet."Tipo retención" := rstRet."Tipo retención"::"Agente de retención IVA";
                                rstRet."Fecha efectividad retencion" := datHasta;
                                rstRet."Fecha documento" := datDesde;
                                rstRet."No. documento" := codDoc;

                                rstRet.Insert;

                            end;

                        end;

                    end;

                    StreamInTest.WriteText(Txt +
                                           CrLf);

                end;

            until rstInBF.Next = 0;

        dlgDialogo.Close;

        FileTest.Close();

        FileMgt.DownloadTempFile(strRetenidoSRV);

        strRetCualquiera2 := FileMgt.UploadFileWithFilter('Archivo nuevo ', strRetenidoSRV, 'Archivos de texto (*.txt)|*.txt', '*.txt');
        //FileMgt.DownloadToFile(strRetenidoSRV, strRetCualquiera2);

    end;

    [Scope('OnPrem')]
    procedure fntExportarSIRE()
    var
        StreamInTest: OutStream;
        FileTest: File;
        Txt: Text[250];
        rstProv: Record Vendor;
        rstCompanyInfo: Record "Company Information";
        rstRet: Record "Withholding details";
        codProv: Code[11];
        strProv: Text[60];
        datDesde: Date;
        datHasta: Date;
        intPor: Integer;
        rstInBF: Record "Invoice Withholding Buffer";
        rstInBFNC: Record "Invoice Withholding Buffer";
        rstMens: Record Mensajeria;
        strDia: Text[2];
        strMes: Text[2];
        strAno: Text[4];
        rstTipoRet: Record "Withholding codes";
        rstCont: Record "G/L Entry";
        CrLf: Text;
        strForm: Text[4];
        strVersion: Text[4];
        strTrazabilidad: Text[10];
        strCUITAgente: Text[11];
        intImpuesto: Integer;
        intRegimen: Integer;
        strCUITRetenido: Text[11];
        strFechaRet: Text[10];
        strTipo: Text[2];
        strFechaCom: Text[10];
        strNroCompr: Text[16];
        strImpComp: Text[14];
        strImpRet: Text[14];
        strCertOrigNro: Text[25];
        strCertOrigFech: Text[10];
        strCertOrigImp: Text[14];
        strOtrosDatos: Text[30];
        strDec: Text[2];
        intDec: Decimal;
        rstMovProveedorFC: Record "Vendor Ledger Entry";
        rstMovProveedor: Record "Vendor Ledger Entry";
    begin
        //FileMgt.ServerTempFileName(strRetenidoSRV);
        FileTest.TextMode(true);
        FileTest.Create(strRetenidoSRV);
        //FileTest.OPEN(strRetenidoSRV);
        FileTest.CreateOutStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');


        CrLf[1] := 13;
        CrLf[2] := 10;

        Clear(rstInBF);
        rstInBF.SetCurrentKey("Fecha pago", "Cliente/Proveedor", "No. Factura");
        rstInBF.SetRange("Fecha pago", datInicio, datFinal);
        rstInBF.SetFilter("Tipo retencion", '%1', rstInBF."Tipo retencion"::"Seguridad Social");
        rstInBF.SetRange(Retenido, true);
        if rstInBF.FindSet then
            repeat

                j += 1;

                Clear(rstCont);
                rstCont.SetCurrentKey(rstCont."Document No.");
                rstCont.SetRange(rstCont."Document No.", rstInBF."No. documento");
                if not rstCont.FindFirst then
                    rstCont.Next
                else begin

                    rstInBF.CalcFields("Factura Prov", "NC Prov");
                    strForm := '2004';
                    strVersion := '0100';

                    Clear(rstProv);
                    rstProv.Get(rstInBF."Cliente/Proveedor");

                    Clear(rstCompanyInfo);
                    rstCompanyInfo.Get();

                    for i := 1 to 17 do begin

                        case i of
                            1:
                                strForm := '2004';
                            2:
                                strVersion := '0100';
                            3:
                                begin

                                    if StrLen(strTrazabilidad) < 10 then
                                        repeat

                                            strTrazabilidad := strTrazabilidad + ' ';

                                        until StrLen(strTrazabilidad) = 10;

                                end;
                            4:
                                begin

                                    Evaluate(strCUITAgente, DelChr(rstCompanyInfo."VAT Registration No.", '=', '-'));

                                end;
                            5:
                                intImpuesto := 353;
                            6:
                                intRegimen := 755;
                            7:
                                begin

                                    Evaluate(strCUITRetenido, DelChr(rstProv."VAT Registration No.", '=', '-'));

                                end;
                            8:
                                begin

                                    strDia := Format(Date2DMY(rstInBF."Fecha pago", 1));
                                    if StrLen(strDia) = 1 then
                                        strDia := '0' + strDia;
                                    strMes := Format(Date2DMY(rstInBF."Fecha pago", 2));
                                    if StrLen(strMes) = 1 then
                                        strMes := '0' + strMes;
                                    strAno := Format(Date2DMY(rstInBF."Fecha pago", 3));
                                    strFechaRet := strDia + '/' +
                                                 strMes + '/' +
                                                 strAno;

                                end;
                            9:
                                begin

                                    if rstInBF."No. Factura" <> '' then begin

                                        Clear(rstMens);
                                        rstMens.SetRange(rstMens."Codigo vinculante", rstInBF."Cliente/Proveedor");
                                        rstMens.SetRange(rstMens."No. documento", rstInBF."No. Factura");
                                        if rstMens.Find('+') then begin

                                            case rstMens."Tipo Documento" of
                                                'Factura (compras)', 'Fact. pronto venc. (compras)':
                                                    strTipo := '1';
                                                'Nota débito (compras)', 'Déb. pronto venc. (compras)':
                                                    strTipo := '4';
                                            end;

                                        end;

                                    end;

                                    if rstInBF."Tipo factura" = rstInBF."Tipo factura"::"Nota d/c" then
                                        strTipo := '3';

                                    if StrLen(strTipo) < 2 then
                                        repeat

                                            strTipo := ' ' + strTipo;

                                        until StrLen(strTipo) = 2;

                                end;
                            10:
                                begin

                                    strDia := Format(Date2DMY(rstInBF."Fecha factura", 1));
                                    if StrLen(strDia) = 1 then
                                        strDia := '0' + strDia;
                                    strMes := Format(Date2DMY(rstInBF."Fecha factura", 2));
                                    if StrLen(strMes) = 1 then
                                        strMes := '0' + strMes;
                                    strAno := Format(Date2DMY(rstInBF."Fecha factura", 3));
                                    strFechaCom := strDia + '/' +
                                                 strMes + '/' +
                                                 strAno;

                                    if rstInBF."Tipo factura" = rstInBF."Tipo factura"::"Nota d/c" then
                                        strFechaCom := strFechaRet;
                                end;
                            11:
                                begin
                                    strNroCompr := DelChr(CopyStr(rstInBF."Factura Prov", 2, 20) + CopyStr(rstInBF."NC Prov", 2, 20), '=', '.');
                                    if StrLen(strNroCompr) < 16 then
                                        repeat

                                            strNroCompr := strNroCompr + ' ';

                                        until StrLen(strNroCompr) = 16;
                                end;
                            12:
                                begin

                                    strDec := '';
                                    strDec := CopyStr(Format(Round(rstInBF."Importe neto factura", 0.01, '<') - Round(rstInBF."Importe neto factura", 1, '<')),
                                                      StrPos(Format(Round(rstInBF."Importe neto factura", 0.01, '<') - Round(rstInBF."Importe neto factura", 1, '<')), ',') + 1,
                                                      2);

                                    if StrLen(strDec) < 2 then
                                        repeat

                                            strDec := strDec + '0';

                                        until StrLen(strDec) = 2;

                                    strImpComp := DelChr(Format(Round(rstInBF."Importe neto factura", 1, '<')), '=', '-.,') + ',' + DelChr(strDec, '=', ',-');
                                    if StrLen(strImpComp) < 14 then
                                        repeat

                                            strImpComp := ' ' + strImpComp;

                                        until StrLen(strImpComp) = 14;

                                end;
                            13:
                                begin

                                    strDec := '';
                                    strDec := CopyStr(Format(Round(rstInBF."Importe retencion", 0.01, '<') - Round(rstInBF."Importe retencion", 1, '<')),
                                                      StrPos(Format(Round(rstInBF."Importe retencion", 0.01, '<') - Round(rstInBF."Importe retencion", 1, '<')), ',') + 1,
                                              2);
                                    if StrLen(strDec) < 2 then
                                        repeat

                                            strDec := strDec + '0';

                                        until StrLen(strDec) = 2;

                                    strImpRet := DelChr(Format(Round(rstInBF."Importe retencion", 1, '<')), '=', '.,-') + ',' + DelChr(strDec, '=', '.,-');

                                    if StrLen(strImpRet) < 14 then
                                        repeat

                                            strImpRet := ' ' + strImpRet;

                                        until StrLen(strImpRet) = 14;

                                end;
                            14:
                                begin

                                    if rstInBF."Tipo factura" = rstInBF."Tipo factura"::"Nota d/c" then begin

                                        Clear(rstMovProveedor);
                                        rstMovProveedor.SetCurrentKey("Vendor No.", rstMovProveedor."Document Type", rstMovProveedor."Document No.");
                                        rstMovProveedor.SetRange("Vendor No.", rstInBF."Cliente/Proveedor");
                                        rstMovProveedor.SetRange("Document Type", rstMovProveedor."Document Type"::"Credit Memo");
                                        rstMovProveedor.SetRange("Document No.", rstInBF."No. Factura");
                                        if rstMovProveedor.Find('-') then begin

                                            Clear(rstMovProveedorFC);
                                            rstMovProveedorFC.SetRange(rstMovProveedorFC."Closed by Entry No.", rstMovProveedor."Entry No.");
                                            rstMovProveedorFC.SetRange(Anulado, false);
                                            if not (rstMovProveedorFC.FindFirst) or (rstMovProveedorFC."Document Type" = rstMovProveedorFC."Document Type"::Payment) then begin

                                                Clear(rstMovProveedorFC);
                                                rstMovProveedorFC.SetRange("Entry No.", rstMovProveedor."Closed by Entry No.");
                                                rstMovProveedorFC.SetRange(Anulado, false);
                                                if rstMovProveedorFC.FindFirst then;

                                            end;

                                        end;

                                        Clear(rstInBFNC);
                                        if rstMovProveedorFC."Document Type" = rstMovProveedorFC."Document Type"::Invoice then
                                            rstInBFNC.SetRange(rstInBFNC."No. Factura", rstMovProveedorFC."Document No.");
                                        if rstMovProveedorFC."Document Type" = rstMovProveedorFC."Document Type"::Payment then
                                            rstInBFNC.SetRange(rstInBFNC."No. documento", rstMovProveedorFC."Document No.");
                                        rstInBFNC.SetRange("Tipo retencion", rstInBFNC."Tipo retencion"::"Seguridad Social");
                                        if rstInBFNC.FindFirst then begin
                                            Evaluate(strCertOrigNro, DelChr(rstInBF."Serie retención", '=', '-'));
                                            if StrLen(Format(strCertOrigNro)) < 25 then
                                                repeat

                                                    strCertOrigNro := ' ' + strCertOrigNro;

                                                until StrLen(Format(strCertOrigNro)) = 25;
                                        end;
                                    end
                                    else begin

                                        strCertOrigNro := '';
                                        Clear(rstInBFNC);
                                        if StrLen(Format(strCertOrigNro)) < 25 then
                                            repeat

                                                strCertOrigNro := '0' + strCertOrigNro;

                                            until StrLen(Format(strCertOrigNro)) = 25;

                                    end;

                                end;
                            15:
                                begin

                                    if rstInBF."Tipo factura" = rstInBFNC."Tipo factura"::"Nota d/c" then begin

                                        if rstInBFNC."Fecha pago" <> 0D then begin

                                            strDia := Format(Date2DMY(rstInBFNC."Fecha pago", 1));
                                            if StrLen(strDia) = 1 then
                                                strDia := '0' + strDia;
                                            strMes := Format(Date2DMY(rstInBFNC."Fecha pago", 2));
                                            if StrLen(strMes) = 1 then
                                                strMes := '0' + strMes;
                                            strAno := Format(Date2DMY(rstInBFNC."Fecha pago", 3));
                                            strCertOrigFech := strDia + '/' +
                                                         strMes + '/' +
                                                         strAno;

                                        end
                                        else
                                            strCertOrigFech := '          ';

                                    end
                                    else
                                        strCertOrigFech := '          ';

                                end;
                            16:
                                begin

                                    if rstInBF."Tipo factura" = rstInBF."Tipo factura"::"Nota d/c" then begin

                                        strDec := '';
                                        strDec := CopyStr(Format(Round(Abs(rstInBFNC."Importe retencion"), 0.01, '<') - Round(Abs(rstInBFNC."Importe retencion"), 1, '<')),
                                                          StrPos(Format(Round(Abs(rstInBFNC."Importe retencion"), 0.01, '<') - Round(Abs(rstInBFNC."Importe retencion"), 1, '<')), ',') + 1,
                                                  2);
                                        if StrLen(strDec) < 2 then
                                            repeat

                                                strDec := strDec + '0';

                                            until StrLen(strDec) = 2;

                                        strCertOrigImp := DelChr(Format(Round(Abs(rstInBFNC."Importe retencion"), 1, '<')), '=', '.,-') + ',' + DelChr(strDec, '=', ',.-');

                                        if StrLen(strCertOrigImp) < 14 then
                                            repeat

                                                strCertOrigImp := '0' + strCertOrigImp;

                                            until StrLen(strCertOrigImp) = 14;

                                    end
                                    else begin

                                        strCertOrigImp := '';
                                        if StrLen(strCertOrigImp) < 14 then
                                            repeat

                                                strCertOrigImp := '0' + strCertOrigImp;

                                            until StrLen(strCertOrigImp) = 14;

                                    end;

                                end;
                            17:
                                begin

                                    if StrLen(strOtrosDatos) < 30 then
                                        repeat

                                            strOtrosDatos := strOtrosDatos + ' ';

                                        until StrLen(strOtrosDatos) = 30;

                                end;

                        end;

                    end;

                    Txt :=
                            Format(strForm) +
                            Format(strVersion) +
                            strTrazabilidad +
                            Format(strCUITAgente) +
                            Format(intImpuesto) +
                            Format(intRegimen) +
                            Format(strCUITRetenido) +
                            strFechaRet +
                            Format(strTipo) +
                            strFechaCom +
                            strNroCompr +
                            strImpComp +
                            strImpRet +
                            Format(strCertOrigNro) +
                            strCertOrigFech +
                            strCertOrigImp +
                            strOtrosDatos;



                    dlgDialogo.Update(1, Txt);

                    StreamInTest.WriteText(Txt +
                                           CrLf);

                end;

            until rstInBF.Next = 0;

        dlgDialogo.Close;

        FileTest.Close();

        FileMgt.DownloadTempFile(strRetenidoSRV);

        strRetCualquiera3 := FileMgt.UploadFileWithFilter('Archivo nuevo ', strRetenidoSRV, 'Archivos de texto (*.txt)|*.txt', '*.txt');
        //FileMgt.DownloadToFile(strRetenidoSRV, strRetCualquiera3);
    end;

    [Scope('OnPrem')]
    procedure fntExportarIIBB()
    var
        StreamInTest: OutStream;
        FileTest: File;
        Txt: Text[250];
        rstProv: Record Vendor;
        rstCompanyInfo: Record "Company Information";
        rstRet: Record "Withholding details";
        codProv: Code[11];
        strProv: Text[60];
        datDesde: Date;
        datHasta: Date;
        intPor: Integer;
        rstInBF: Record "Invoice Withholding Buffer";
        rstInBFNC: Record "Invoice Withholding Buffer";
        rstMens: Record Mensajeria;
        strDia: Text[2];
        strMes: Text[2];
        strAno: Text[4];
        rstTipoRet: Record "Withholding codes";
        rstCont: Record "G/L Entry";
        CrLf: Text;
        strForm: Text[4];
        strVersion: Text[4];
        strTrazabilidad: Text[10];
        strCUITAgente: Text[11];
        intImpuesto: Integer;
        intRegimen: Integer;
        strCUITRetenido: Text[13];
        strFechaRet: Text[10];
        strTipo: Text[2];
        strFechaCom: Text[10];
        strImpComp: Text[14];
        strImpRet: Text[14];
        strCertOrigNro: Text[25];
        strCertOrigFech: Text[10];
        strCertOrigImp: Text[14];
        strOtrosDatos: Text[30];
        strDec: Text[11];
        intDec: Decimal;
        rstMovProveedorFC: Record "Vendor Ledger Entry";
        rstMovProveedor: Record "Vendor Ledger Entry";
        qryPIIBB: Query "Gross winnings perceptions";
        strRegimen: Code[10];
        strFechaPerc: Code[10];
        strPV: Text[20];
        strNroComp: Text[20];
        strLetraComprobante: Text[1];
        rstGLS: Record "General Ledger Setup";
        rstTipoDoc: Record "Tipos documento";
        l_blnInterno: Boolean;
        decCF: Decimal;
        l_rstCC: Record "Purchases & Payables Setup";
        l_codSigno: Code[1];
    begin
        FileTest.TextMode(true);
        FileTest.Create(strRetenidoSRV);
        FileTest.CreateOutStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');

        Clear(rstGLS);
        rstGLS.Get();

        CrLf[1] := 13;
        CrLf[2] := 10;

        //Primero, sin Aduana
        Clear(l_rstCC);
        l_rstCC.Get();

        Clear(qryPIIBB);
        qryPIIBB.SetFilter(qryPIIBB.Vendor_No_filter, '<>%1&<>%2', l_rstCC."Proveedor Aduana Exterior", l_rstCC."Proveedor Aduana Local");
        qryPIIBB.SetRange(qryPIIBB.Posting_Date_filter, datInicio, datFinal);
        qryPIIBB.Open;
        while qryPIIBB.Read do begin

            Clear(rstMens);
            //rstMens.SETRANGE(rstMens."Codigo vinculante",qryPIIBB.Source_No);
            rstMens.SetRange(rstMens."No. documento", qryPIIBB.Document_No);
            rstMens.Find('+');

            Clear(rstTipoDoc);
            rstTipoDoc.SetRange(rstTipoDoc."Tipos documento", rstMens."Tipo Documento");
            rstTipoDoc.FindFirst;

            if not fntDocsInternosCompras(qryPIIBB.Document_No) then begin

                j += 1;

                for i := 1 to 8 do begin

                    case i of
                        1: //Régimen
                            strRegimen := qryPIIBB.Gross_winnings_perception_code;
                        2: //CUIT
                            strCUITRetenido := qryPIIBB.VAT_Registration_No;
                        3: //Fecha
                            begin
                                strDia := Format(Date2DMY(qryPIIBB.Document_Date, 1));
                                if StrLen(strDia) = 1 then
                                    strDia := '0' + strDia;
                                strMes := Format(Date2DMY(qryPIIBB.Document_Date, 2));
                                if StrLen(strMes) = 1 then
                                    strMes := '0' + strMes;
                                strAno := Format(Date2DMY(qryPIIBB.Document_Date, 3));
                                strFechaPerc := strDia + '/' +
                                             strMes + '/' +
                                             strAno;
                            end;
                        4: //Sucursal
                            begin

                                strPV := DelChr(qryPIIBB.External_Document_No, '=', DelChr(qryPIIBB.External_Document_No, '=', '-0123456789'));
                                strPV := DelChr(CopyStr(strPV, 1, StrPos(strPV, '-')), '=', '-');
                                if StrLen(strPV) > 4 then
                                    strPV := CopyStr(strPV, StrLen(strPV) - 3, StrLen(strPV));
                                fntFillNum(strPV, 4);

                            end;
                        5: //Documento
                            begin

                                strNroComp := DelChr(qryPIIBB.External_Document_No, '=', DelChr(qryPIIBB.External_Document_No, '=', '-0123456789'));
                                strNroComp := DelChr(CopyStr(strNroComp, StrPos(strNroComp, '-') + 1, 1000), '=', '-');
                                fntFillNum(strNroComp, 8);

                            end;
                        6: //Tipo de comprobante origen de la retención
                            begin
                                if qryPIIBB.External_Document_No <> '' then begin
                                    Clear(rstMens);
                                    //rstMens.SETRANGE(rstMens."Codigo vinculante",qryPIIBB.Source_No);
                                    rstMens.SetRange(rstMens."No. documento", qryPIIBB.Document_No);
                                    if rstMens.Find('+') then begin

                                        case rstMens."Tipo Documento" of
                                            'Factura (compras)', 'Fact. pronto venc. (compras)', 'Factura (ventas)':
                                                strTipo := 'F';
                                            'Nota débito (compras)', 'Déb. pronto venc. (compras)':
                                                strTipo := 'D';
                                            else
                                                strTipo := 'C';
                                        end;
                                    end;
                                end;
                            end;
                        7: // Letra del Comprobante
                            begin
                                strLetraComprobante := CopyStr(qryPIIBB.External_Document_No, 1, 1);
                            end;
                        8: //Monto percibido
                            begin
                                if qryPIIBB.Currency_Code <> '' then
                                    decCF := qryPIIBB.Sum_Amount / qryPIIBB.Sum_Amount_LCY
                                else
                                    decCF := 0;
                                l_codSigno := '';
                                if qryPIIBB.Sum_Amount > 0 then
                                    l_codSigno := '-';
                                /*
                                IF qryPIIBB.Currency_Code <> '' THEN
                                  strDec := fntDecConComa(ROUND(qryPIIBB.Sum_Total_Cost/decCF,rstGLS."Amount Rounding Precision"),2,11,l_codSigno)
                                ELSE
                                */
                                strDec := fntDecConComa(qryPIIBB.Sum_Total_Cost, 2, 11, l_codSigno);
                            end;
                    end;
                end;

                Txt :=
                      strRegimen +
                      strCUITRetenido +
                      strFechaPerc +
                      strPV +
                      strNroComp +
                      strTipo +
                      strLetraComprobante +
                      strDec;

                dlgDialogo.Update(1, Txt);

                StreamInTest.WriteText(Txt +
                                        CrLf);

            end;
        end;

        dlgDialogo.Close;

        FileTest.Close();

        FileMgt.DownloadTempFile(strRetenidoSRV);

        strRetCualquiera3 := FileMgt.UploadFileWithFilter('Percepciones ', strRetenidoSRV, 'Archivos de texto (*.txt)|*.txt', '*.txt');
        //FileMgt.DownloadToFile(strRetenidoSRV, strRetCualquiera3);

        //Ahora, con Aduana
        FileTest.TextMode(true);
        FileTest.Create(strRetenidoSRV);
        FileTest.CreateOutStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');

        Clear(qryPIIBB);
        qryPIIBB.SetFilter(qryPIIBB.Vendor_No_filter, '%1|%2', l_rstCC."Proveedor Aduana Exterior", l_rstCC."Proveedor Aduana Local");
        qryPIIBB.SetRange(qryPIIBB.Posting_Date_filter, datInicio, datFinal);
        qryPIIBB.Open;
        while qryPIIBB.Read do begin

            Clear(rstMens);
            //rstMens.SETRANGE(rstMens."Codigo vinculante",qryPIIBB.Source_No);
            rstMens.SetRange(rstMens."No. documento", qryPIIBB.Document_No);
            rstMens.Find('+');

            Clear(rstTipoDoc);
            rstTipoDoc.SetRange(rstTipoDoc."Tipos documento", rstMens."Tipo Documento");
            rstTipoDoc.FindFirst;

            if not fntDocsInternosCompras(qryPIIBB.Document_No) then begin

                j += 1;

                for i := 1 to 5 do begin

                    case i of
                        1:
                            strRegimen := qryPIIBB.Gross_winnings_perception_code;
                        2:
                            strCUITRetenido := qryPIIBB.VAT_Registration_No;
                        3:
                            begin
                                strDia := Format(Date2DMY(qryPIIBB.Document_Date, 1));
                                if StrLen(strDia) = 1 then
                                    strDia := '0' + strDia;
                                strMes := Format(Date2DMY(qryPIIBB.Document_Date, 2));
                                if StrLen(strMes) = 1 then
                                    strMes := '0' + strMes;
                                strAno := Format(Date2DMY(qryPIIBB.Document_Date, 3));
                                strFechaPerc := strDia + '/' +
                                             strMes + '/' +
                                             strAno;
                            end;
                        4:
                            begin

                                strNroComp := DelChr(qryPIIBB.External_Document_No, '=', DelChr(qryPIIBB.External_Document_No, '=', '-0123456789'));
                                strNroComp := DelChr(CopyStr(strNroComp, StrPos(strNroComp, '-') + 1, 1000), '=', '-');
                                fntFillNum(strNroComp, 20);

                            end;
                        5: //Monto percibido
                            begin
                                if qryPIIBB.Currency_Code <> '' then
                                    decCF := qryPIIBB.Sum_Amount / qryPIIBB.Sum_Amount_LCY
                                else
                                    decCF := 0;
                                /*
                                IF qryPIIBB.Currency_Code <> '' THEN
                                  strDec := fntDecConComa(ROUND(qryPIIBB.Sum_Total_Cost/decCF,rstGLS."Amount Rounding Precision"),2,11,'')
                                ELSE
                                */
                                strDec := fntDecConComa(qryPIIBB.Sum_Total_Cost, 2, 11, '');
                            end;
                    end;
                end;

                Txt :=
                      strRegimen +
                      strCUITRetenido +
                      strFechaPerc +
                      strNroComp +
                      strDec;

                dlgDialogo.Update(1, Txt);

                StreamInTest.WriteText(Txt +
                                        CrLf);

            end;
        end;

        dlgDialogo.Close;

        FileTest.Close();

        FileMgt.DownloadTempFile(strRetenidoSRV);

        strRetCualquiera3 := FileMgt.UploadFileWithFilter('Aduana ', strRetenidoSRV, 'Archivos de texto (*.txt)|*.txt', '*.txt');
        //FileMgt.DownloadToFile(strRetenidoSRV, strRetCualquiera3);

    end;

    [Scope('OnPrem')]
    procedure fntExportarComprobarDocumentos()
    var
        StreamInTest: OutStream;
        FileTest: File;
        Txt: Text[250];
        rstProv: Record Vendor;
        rstCompanyInfo: Record "Company Information";
        codProv: Code[11];
        strProv: Text[60];
        datDesde: Date;
        datHasta: Date;
        intPor: Integer;
        rstVLE: Record "Vendor Ledger Entry";
        rstMens: Record Mensajeria;
        strDia: Text[2];
        strMes: Text[2];
        strAno: Text[4];
        rstCont: Record "G/L Entry";
        CrLf: Text;
        strCUIT: Text[11];
        intImpuesto: Integer;
        intRegimen: Integer;
        strFechaEmision: Text[10];
        strTipoAutorizacion: Text[4];
        strTipoComprobante: Text[2];
        strFechaCom: Text[10];
        strNroCompr: Text[8];
        strImpComp: Text[15];
        strImpRet: Text[14];
        strDec: Text[2];
        intDec: Decimal;
        strCodAuto: Text[14];
        rstPI: Record "Purch. Inv. Header";
        rstPC: Record "Purch. Cr. Memo Hdr.";
        strPOV: Text[4];
        rstTDR: Text[2];
        strCUITReceptor: Text[11];
    begin
        FileTest.TextMode(true);
        FileTest.Create(strRetenidoSRV);
        FileTest.CreateOutStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');


        CrLf[1] := 13;
        CrLf[2] := 10;


        Clear(rstVLE);
        rstVLE.SetCurrentKey(rstVLE."Document Type", rstVLE."Posting Date");
        rstVLE.SetFilter("Document Type", '%1|%2', rstVLE."Document Type"::Invoice, rstVLE."Document Type"::"Credit Memo");
        rstVLE.SetRange("Posting Date", datInicio, datFinal);
        rstVLE.SetRange(Anulado, false);
        if rstVLE.FindSet then
            repeat

                Clear(rstMens);
                rstMens.SetRange("Codigo vinculante", rstVLE."Vendor No.");
                rstMens.SetRange("No. documento", rstVLE."Document No.");
                if rstMens.FindFirst then begin

                    Clear(rstProv);
                    rstProv.Get(rstVLE."Vendor No.");

                    Clear(rstCompanyInfo);
                    rstCompanyInfo.Get();

                    if rstProv."Tipo autorizacion" <> rstProv."Tipo autorizacion"::" " then begin

                        Clear(rstPI);
                        Clear(rstPC);

                        case rstVLE."Document Type" of
                            rstVLE."Document Type"::Invoice:
                                begin

                                    Clear(rstPI);
                                    if rstPI.Get(rstVLE."Document No.") then;

                                end;
                            rstVLE."Document Type"::"Credit Memo":
                                begin

                                    Clear(rstPC);
                                    if rstPC.Get(rstVLE."Document No.") then;

                                end;

                        end;

                        rstVLE.CalcFields(Amount);
                        if ((rstPI."No." + rstPC."No.") <> '') and ((rstPI."CAI-CAE" + rstPC."CAI-CAE") <> '') then begin

                            j += 1;

                            for i := 1 to 10 do begin

                                case i of
                                    1:
                                        strTipoAutorizacion := Format(rstProv."Tipo autorizacion");
                                    2:
                                        Evaluate(strCUIT, DelChr(rstProv."VAT Registration No.", '=', '-'));
                                    3:
                                        strCodAuto := rstPI."CAI-CAE" + rstPC."CAI-CAE";
                                    4:
                                        begin

                                            strDia := Format(Date2DMY(rstVLE."Posting Date", 1));
                                            if StrLen(strDia) = 1 then
                                                strDia := '0' + strDia;
                                            strMes := Format(Date2DMY(rstVLE."Posting Date", 2));
                                            if StrLen(strMes) = 1 then
                                                strMes := '0' + strMes;
                                            strAno := Format(Date2DMY(rstVLE."Posting Date", 3));
                                            strFechaEmision := strAno + strMes + strDia;

                                        end;
                                    5:
                                        strTipoComprobante := rstPI."Tipo documento AFIP" + rstPC."Tipo documento AFIP";
                                    6:
                                        strPOV := CopyStr(rstVLE."External Document No.", 2, 4);
                                    7:
                                        strNroCompr := CopyStr(rstVLE."External Document No.", StrPos(rstVLE."External Document No.", '-') + 1, 8);
                                    8:
                                        begin

                                            strDec := '';
                                            strDec := CopyStr(Format(Round(rstVLE.Amount, 0.01, '<') - Round(rstVLE.Amount, 1, '<')),
                                                              StrPos(Format(Round(rstVLE.Amount, 0.01, '<') - Round(rstVLE.Amount, 1, '<')), '.') + 1,
                                                              2);

                                            if StrLen(strDec) < 2 then
                                                repeat

                                                    strDec := '0' + strDec;

                                                until StrLen(strDec) = 2;

                                            strImpComp := DelChr(Format(Round(rstVLE.Amount, 1, '<')), '=', '-.,') + DelChr(strDec, '=', ',-');
                                            if StrLen(strImpComp) < 15 then
                                                repeat

                                                    strImpComp := '0' + strImpComp;

                                                until StrLen(strImpComp) = 15;

                                        end;

                                    9:
                                        rstTDR := '99';
                                    10:
                                        //EVALUATE(strCUITReceptor,DELCHR(rstProv."VAT Registration No.",'=','-'));
                                        strCUITReceptor := '99999999999';

                                end;

                            end;

                            fntFillAlfa(strTipoAutorizacion, 4);
                            fntFillNum(strCUIT, 11);
                            fntFillNum(strCodAuto, 14);
                            fntFillNum(strFechaEmision, 8);
                            fntFillNum(strTipoComprobante, 2);
                            fntFillNum(strPOV, 4);
                            fntFillNum(strNroCompr, 8);
                            fntFillNum(strImpComp, 15);
                            fntFillNum(rstTDR, 2);
                            fntFillNum(strCUITReceptor, 11);

                            Txt :=
                                    strTipoAutorizacion +
                                    strCUIT +
                                    strCodAuto +
                                    strFechaEmision +
                                    strTipoComprobante +
                                    strPOV +
                                    strNroCompr +
                                    strImpComp +
                                    rstTDR +
                                    strCUITReceptor;

                            dlgDialogo.Update(1, Txt);

                            StreamInTest.WriteText(Txt +
                                                   CrLf);

                        end;

                    end;

                end;

            until rstVLE.Next = 0;

        dlgDialogo.Close;

        FileTest.Close();

        FileMgt.DownloadTempFile(strRetenidoSRV);

        strRetCualquiera3 := FileMgt.UploadFileWithFilter('Archivo nuevo ', strRetenidoSRV, 'Archivos de texto (*.txt)|*.txt', '*.txt');
        //FileMgt.DownloadToFile(strRetenidoSRV, strRetCualquiera3);
    end;

    [Scope('OnPrem')]
    procedure fntExportarCitiCompras()
    var
        StreamInTest: OutStream;
        FileTest: File;
        Txt: Text;
        rstProv: Record Vendor;
        rstCompanyInfo: Record "Company Information";
        codProv: Code[11];
        strProv: Text[60];
        datDesde: Date;
        datHasta: Date;
        intPor: Integer;
        rstVLE: Record "Vendor Ledger Entry";
        rstMens: Record Mensajeria;
        strDia: Text[2];
        strMes: Text[2];
        strAno: Text[4];
        rstCont: Record "G/L Entry";
        CrLf: Text;
        strCUIT: Text[11];
        intImpuesto: Integer;
        intRegimen: Integer;
        strFechaEmision: Text[10];
        strTipoAutorizacion: Text[4];
        strTipoComprobante: Text[2];
        strFechaCom: Text[10];
        strNroCompr: Text[8];
        strImpComp: Text[15];
        strImpRet: Text[14];
        strDec: Text[2];
        intDec: Decimal;
        strCodAuto: Text[14];
        rstPI: Record "Purch. Inv. Header";
        rstPC: Record "Purch. Cr. Memo Hdr.";
        strPOV: Text[4];
        rstTDR: Text[2];
        strCUITReceptor: Text[11];
        strVariable: array[1000] of Text;
        FileMgt: Codeunit "File Management";
        k: Integer;
        rstPS: Record "Purchases & Payables Setup";
        rstIVABuffer: Record "Mov. IVA Buffer";
    begin
        FileTest.TextMode(true);
        FileTest.Create(strRetenidoSRV);
        FileTest.CreateOutStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');


        CrLf[1] := 13;
        CrLf[2] := 10;

        Clear(rstIVABuffer);
        if rstIVABuffer.FindSet then
            repeat

                Txt := '';

                Clear(rstCompanyInfo);
                rstCompanyInfo.Get();

                for i := 1 to 25 do begin

                    case i of
                        1:
                            begin

                                if rstIVABuffer."Fecha documento" <> 0D then
                                    strVariable[i] := fntNum(2, Format(Date2DMY(rstIVABuffer."Fecha documento", 1))) +
                                                      fntNum(2, Format(Date2DMY(rstIVABuffer."Fecha documento", 2))) +
                                                      fntNum(4, Format(Date2DMY(rstIVABuffer."Fecha documento", 3)))
                                else
                                    strVariable[i] := fntNum(8, '0');

                            end;

                        2:
                            begin

                                Clear(rstDigitales);
                                rstDigitales.SetRange("Nivel 8", rstIVABuffer."Documento original");
                                if rstDigitales.FindFirst then
                                    strVariable[i] := fntNum(3, rstDigitales."Nivel 9");

                            end;
                        3:
                            begin

                                if (CopyStr(rstIVABuffer."Número comprobante", 1, 1) in ['A..Z']) and (StrPos(rstIVABuffer."Número comprobante", '-') <> 0) then
                                    strVariable[i] := fntNum(5, CopyStr(rstIVABuffer."Número comprobante", 2, 4))
                                else
                                    strVariable[i] := fntNum(5, '0');

                            end;
                        4:
                            begin

                                if (CopyStr(rstIVABuffer."Número comprobante", 1, 1) in ['A..Z']) and (StrPos(rstIVABuffer."Número comprobante", '-') <> 0) then
                                    strVariable[i] := fntNum(20, CopyStr(rstIVABuffer."Número comprobante", 7, 8))
                                else
                                    strVariable[i] := fntNum(20, '0');

                            end;
                        5:
                            begin

                                if rstIVABuffer."No. despacho" <> '' then
                                    strVariable[i] := fntAlfa(16, rstIVABuffer."No. despacho")
                                else
                                    strVariable[i] := fntAlfa(16, ' ');

                            end;
                        6:
                            strVariable[i] := '80';
                        7:
                            strVariable[i] := fntNum(20, Format(rstIVABuffer.CUIT));
                        8:
                            strVariable[i] := fntAlfa(30, rstIVABuffer."Nombre proveedor");
                        9:
                            strVariable[i] := fntDec(rstIVABuffer."Importe total operación", 2, 15);
                        10:
                            strVariable[i] := fntNum(15, '0');
                        11:
                            strVariable[i] := fntDec(rstIVABuffer."Exentos y no gravados", 2, 15);
                        12:
                            strVariable[i] := fntDec(rstIVABuffer."Saldo a favor IVA", 2, 15);
                        13:
                            strVariable[i] := fntNum(15, '0');
                        14:
                            strVariable[i] := fntDec(rstIVABuffer."Per IIBB", 2, 15);
                        15:
                            strVariable[i] := fntNum(15, '0');
                        16:
                            strVariable[i] := fntNum(15, '0');
                        17:
                            strVariable[i] := fntNum(3, rstIVABuffer.Divisa);
                        18:
                            strVariable[i] := fntDec(rstIVABuffer."Tipo cambio", 4, 10);
                        19:
                            begin

                                j := 0;

                                if rstIVABuffer."Crédito fiscal 21%" <> 0 then
                                    j += 1;
                                if rstIVABuffer."Crédito fiscal 27%" <> 0 then
                                    j += 1;
                                if rstIVABuffer."Crédito fiscal 10,5%" <> 0 then
                                    j += 1;

                                strVariable[i] := Format(j);

                            end;
                        20:
                            begin

                                Clear(rstPS);
                                rstPS.Get();

                                if j = 0 then begin

                                    if rstProv."Vendor Posting Group" = rstPS."Grupo Contable Importaciones" then
                                        strVariable[i] := 'Z';

                                    if rstIVABuffer."Exentos y no gravados" <> 0 then
                                        strVariable[i] := 'E';

                                end
                                else
                                    strVariable[i] := ' ';

                            end;
                        21:
                            begin

                                if rstIVABuffer.Computable then
                                    strVariable[i] := fntDec(rstIVABuffer."Crédito fiscal 21%" + rstIVABuffer."Crédito fiscal 27%" + rstIVABuffer."Crédito fiscal 10,5%", 2, 15);

                            end;
                        22:
                            strVariable[i] := fntDec(rstIVABuffer.Otros, 2, 15);
                        23:
                            strVariable[i] := fntNum(11, '0');
                        24:
                            strVariable[i] := fntAlfa(30, ' ');
                        25:
                            strVariable[i] := fntNum(15, '0');

                    end;

                end;

                l += 1;

                for i := 1 to 25 do begin

                    Txt := Txt + strVariable[i];

                end;

                dlgDialogo.Update(1, CopyStr(Txt, 1, 15));

                StreamInTest.WriteText(Txt +
                                       CrLf);

            until rstIVABuffer.Next = 0;

        dlgDialogo.Close;

        FileTest.Close();

        FileMgt.DownloadTempFile(strRetenidoSRV);

        strRetCualquiera3 := FileMgt.UploadFileWithFilter('Archivo nuevo ', strRetenidoSRV, 'Archivos de texto (*.txt)|*.txt', '*.txt');
        //FileMgt.DownloadToFile(strRetenidoSRV, strRetCualquiera3);
    end;

    [Scope('OnPrem')]
    procedure fntExportarReproweb()
    var
        StreamInTest: OutStream;
        FileTest: File;
        Txt: Text[250];
        rstProv: Record Vendor;
        rstCli: Record Customer;
        rstCompanyInfo: Record "Company Information";
        CrLf: Text;
        rstAreaImpuesto: Record "Tax Area";
    begin
        //FileMgt.ServerTempFileName(strRetenidoSRV);
        FileTest.TextMode(true);
        FileTest.Create(strRetenidoSRV);
        //FileTest.OPEN(strRetenidoSRV);
        FileTest.CreateOutStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');


        CrLf[1] := 13;
        CrLf[2] := 10;

        Clear(rstCompanyInfo);
        rstCompanyInfo.Get();

        if UserId <> 'SONIA.HERNANDEZ' then
            StreamInTest.WriteText(DelChr(rstCompanyInfo."VAT Registration No.", '=', '-') +
                                    CrLf);
        Clear(rstProv);
        if rstProv.FindSet then
            repeat

                Clear(rstAreaImpuesto);
                if rstAreaImpuesto.Get(rstProv."Tax Area Code") then begin

                    if (rstAreaImpuesto."Importar Reproweb") and (rstProv."VAT Registration No." <> '') then begin

                        j += 1;

                        if UserId <> 'SONIA.HERNANDEZ' then
                            StreamInTest.WriteText(DelChr(rstProv."VAT Registration No.", '=', '-') + ' ' + Format(fntNum(2, Format(Date2DMY(Today, 2)))) + '/' +
                                                                                                      Format(fntNum(4, Format(Date2DMY(Today, 3)))) +
                                                   CrLf)
                        else
                            StreamInTest.WriteText(DelChr(rstProv."VAT Registration No.", '=', '-') + ' ' + Format(fntNum(2, Format(Date2DMY(Today, 2)))) + '/' +
                                                                                                      Format(fntNum(4, Format(Date2DMY(Today, 3)))) + ' ' +
                                                                                                      DelChr(rstCompanyInfo."VAT Registration No.", '=', '-') +
                                                   CrLf)
                    end;

                end;

            until rstProv.Next = 0;
        /*
        CLEAR(rstCli);
        IF rstCli.FINDSET THEN
        REPEAT
        
          CLEAR(rstAreaImpuesto);
          IF rstAreaImpuesto.GET(rstCli."Tax Area Code") THEN
          BEGIN
        
            IF (rstAreaImpuesto."Importar Reproweb") AND (rstCli."VAT Registration No." <> '') THEN
            BEGIN
        
              j += 1;
        
              StreamInTest.WRITETEXT(DELCHR(rstCli."VAT Registration No.",'=','-')+' '+FORMAT(fntNum(2,FORMAT(DATE2DMY(TODAY,2))))+'/'+
                                                                                        FORMAT(fntNum(4,FORMAT(DATE2DMY(TODAY,3))))+
                                     CrLf);
        
            END;
        
          END;
        
        UNTIL rstCli.NEXT = 0;
        */
        FileTest.Close();

        FileMgt.DownloadTempFile(strRetenidoSRV);

        strRetCualquiera3 := FileMgt.UploadFileWithFilter('Archivo nuevo ', strRetenidoSRV, 'Archivos de texto (*.txt)|*.txt', '*.txt');
        //FileMgt.DownloadToFile(strRetenidoSRV, strRetCualquiera3);

    end;

    [Scope('OnPrem')]
    procedure fntImportarAgiP()
    var
        StreamInTest: InStream;
        Txt: Text[250];
        rstProv: Record Vendor;
        rstRet: Record "Withholding details";
        codProv: Code[11];
        strProv: Text[60];
        datDesde: Date;
        datHasta: Date;
        intPor: Integer;
        codDoc: Text;
        intCant: Integer;
        decAlicuotaPercepcion: Decimal;
        decAlicuotaRetencion: Decimal;
        codTipoContrInsc: Text[2];
        codMarcaAltaSujeto: Code[1];
        codMarcaAlicuota: Code[1];
        strNombre: Text[250];
        FileTest: File;
        strDato: Text[250];
        strVacio: Text[250];
        datPublic: Date;
        rstCli: Record Customer;
        z: Integer;
        rstGLS: Record "General Ledger Setup";
        l_rst99008535: codeunit "Temp Blob";
        l_rstDocumentosDigitalizados: Record "Documentos digitalizados";
        intLinea: Integer;
        cduFM: Codeunit GestionArchivos;
        strRS: Text[100];
        codPF: Code[10];
        strDesc: Text[100];
        j: Integer;
        streamReader: DotNet StreamReader;
        l_rrDocsDigitalizados: RecordRef;
        encoding: DotNet Encoding;
        cduGA: Codeunit "File Management";
        rstRL: Record "Record Link";
        LinkID: Integer;
        l_rstCI: Record "Company Information";
    begin
        codDoc := strRetCualquiera1;

        while StrPos(codDoc, '\') <> 0 do begin

            codDoc := CopyStr(codDoc, StrPos(codDoc, '\') + 1, 1024);

        end;

        rstRet.SetRange("Tipo retención", rstRet."Tipo retención"::"Ingresos Brutos");
        rstRet.SetRange("No. documento", codDoc);
        //rstRet.SETFILTER("Fecha efectividad retencion",'>=%1',datHasta);
        rstRet.DeleteAll;

        FileTest.Open(strRetenidoSRV);
        FileTest.CreateInStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');

        Clear(rstGLS);
        rstGLS.Get();

        z := 0;

        while not (StreamInTest.EOS) do begin

            StreamInTest.ReadText(Txt);

            strDato := '';
            strDato := Txt;

            z += 1;

            for i := 1 to 12 do begin

                case i of
                    1://Fecha de publicación
                        begin
                            Evaluate(datPublic, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    2://Fecha vigencia desde
                        begin
                            Evaluate(datDesde, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    3://Fecha vigencia hasta
                        begin
                            Evaluate(datHasta, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    4://Número de CUIT
                        begin
                            Evaluate(codProv, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    5://Tipo-Contr_Insc
                        begin
                            Evaluate(codTipoContrInsc, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    6://Marca-alta-sujeto
                        begin
                            Evaluate(codMarcaAltaSujeto, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    7://Marca-alicuota
                        begin
                            Evaluate(codMarcaAlicuota, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    8://Alicuota percepción
                        begin
                            Evaluate(decAlicuotaPercepcion, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    9://Alícutoa retención
                        begin
                            Evaluate(decAlicuotaRetencion, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    10://Nro-Grupo-Percepción
                        begin
                            //Por ahora, en ceros
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    11://Nro-Grupo-Retención
                        begin
                            //Por ahora, en ceros
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    12://Razón social contribuyente
                        begin
                            Evaluate(strNombre,/*COPYSTR(strDato,1,STRPOS(strDato,';')-1)*/ strDato);
                        end;

                end;

            end;

            dlgDialogo.Update(1, Format(z) + ' - ' + Txt);

            if codProv <> '' then begin

                Clear(rstProv);
                rstProv.SetRange(rstProv."VAT Registration No.", CopyStr(codProv, 1, 2) + '-' + CopyStr(codProv, 3, 8) + '-' + CopyStr(codProv, 11, 1));
                if rstProv.FindFirst then begin

                    Clear(rstRet);
                    /*IF NOT rstRet.GET(rstRet."Tipo registro"::Compra,COPYSTR(codProv,1,STRLEN(codProv)-1),rstRet."Tipo retención"::"Ingresos Brutos",datHasta) THEN
                    BEGIN
                    */
                    rstRet."Tipo registro" := rstRet."Tipo registro"::Compra;
                    rstRet."Cod. proveedor/cliente" := rstProv."No.";
                    rstRet."Tipo retención" := rstRet."Tipo retención"::"Ingresos Brutos";
                    rstRet."Fecha efectividad retencion" := datHasta;
                    rstRet."Fecha documento" := datDesde;
                    rstRet."Fecha emisión boletin" := datPublic;
                    rstRet."% exención" := intPor;
                    rstRet."% percepcion" := decAlicuotaPercepcion;
                    rstRet."% retencion" := decAlicuotaRetencion;
                    rstRet."No. documento" := codDoc;
                    rstRet."Cód. retención" := rstGLS."GI retention code";
                    rstProv."GI Inscription type" := codTipoContrInsc;
                    rstProv.Modify;
                    if not rstRet.Insert then
                        rstRet.Modify;
                    j += 1;
                    /*
                  END;
                  */
                end;

                Clear(rstCli);
                rstCli.SetRange(rstCli."VAT Registration No.", CopyStr(codProv, 1, 2) + '-' + CopyStr(codProv, 3, 8) + '-' + CopyStr(codProv, 11, 1));
                if rstCli.FindFirst then begin
                    /*
                      CLEAR(rstRet);
                      IF NOT rstRet.GET(rstRet."Tipo registro"::Venta,COPYSTR(codProv,1,STRLEN(codProv)-1),rstRet."Tipo retención"::"Ingresos Brutos",datHasta) THEN
                      BEGIN
                      */
                    rstRet."Tipo registro" := rstRet."Tipo registro"::Venta;
                    rstRet."Cod. proveedor/cliente" := rstCli."No.";
                    rstRet."Tipo retención" := rstRet."Tipo retención"::"Ingresos Brutos";
                    rstRet."Fecha efectividad retencion" := datHasta;
                    rstRet."Fecha documento" := datDesde;
                    rstRet."Fecha emisión boletin" := datPublic;
                    rstRet."% exención" := intPor;
                    rstRet."% percepcion" := decAlicuotaPercepcion;
                    rstRet."% retencion" := decAlicuotaRetencion;
                    rstRet."No. documento" := codDoc;
                    rstRet."Cód. retención" := codTipoContrInsc;
                    rstRet."Cód. retención" := rstGLS."GI retention code";
                    rstCli."GI Inscription type" := codTipoContrInsc;
                    rstCli.Modify;
                    if not rstRet.Insert then
                        rstRet.Modify;
                    j += 1;
                    /*
                          END;
                          */
                end;

            end;

        end;

        dlgDialogo.Close;

        Clear(FileMgt);
        FileMgt.BLOBImportFromServerFile(l_rst99008535, strRetenidoSRV);

        Clear(l_rstDocumentosDigitalizados);
        if l_rstDocumentosDigitalizados.Find('+') then
            intLinea := l_rstDocumentosDigitalizados.Linea
        else
            intLinea := 1;

        Clear(l_rstDocumentosDigitalizados);
        l_rstDocumentosDigitalizados.Linea := intLinea + 1;
        l_rstDocumentosDigitalizados.Archivo := strRetenidoSRV;
        l_rstDocumentosDigitalizados."Nivel 1" := 'txt';
        l_rstDocumentosDigitalizados."Nivel 4" := 'AGIP';
        //l_rstDocumentosDigitalizados.BlobFile := l_rst99008535.Blob;
        l_rstDocumentosDigitalizados.Insert;


        clear(l_rrDocsDigitalizados);
        l_rrDocsDigitalizados.get(l_rstDocumentosDigitalizados.RecordId);
        l_rst99008535.ToRecordRef(l_rrDocsDigitalizados, l_rstDocumentosDigitalizados.FieldNo("BlobFile"));
        l_rrDocsDigitalizados.Modify;

        clear(l_rstCI);
        l_rstCI.get();

        strRetenidoSRV := l_rstCI."Ruta de digitalizacion" + l_rstCI."Ruta cabecera digitalizacion" + cduGA.GetFileName(l_rstDocumentosDigitalizados.Archivo);
        If File.Exists(strRetenidoSRV) then
            strRetenidoSRV := CopyStr(strRetenidoSRV, 1, StrLen(strRetenidoSRV) - 4) + DelChr(format(CurrentDateTime, 10, 1), '=', '/ :') + '.txt';
        cduGA.CopyServerFile(l_rstDocumentosDigitalizados.Archivo, strRetenidoSRV, true);
        IF STRPOS(UPPERCASE(strRetenidoSRV), UPPERCASE(l_rstCI."Ruta Intranet")) = 0 THEN
            strRetenidoSRV := l_rstCI."Ruta Intranet" + (CONVERTSTR(COPYSTR(strRetenidoSRV, STRLEN(l_rstCI."Ruta de digitalizacion"), 250), '\', '/'));
        LinkID := rstGLS.AddLink(strRetenidoSRV, 'Padrón AGIP importado el ' + Format(Today));
        Clear(rstRL);
        rstRL.Get(LinkID);

        FileTest.Close();

    end;

    [Scope('OnPrem')]
    procedure fntImportarARBA()
    var
        StreamInTest: InStream;
        Txt: Text[250];
        rstCli: Record Customer;
        rstRet: Record "Withholding details";
        codCli: Code[11];
        strCli: Text[60];
        datDesde: Date;
        datHasta: Date;
        intPor: Integer;
        codDoc: Text;
        intCant: Integer;
        decAlicuotaPercepcion: Decimal;
        decAlicuotaRetencion: Decimal;
        codTipoContrInsc: Text[1];
        codMarcaAltaSujeto: Code[1];
        codMarcaAlicuota: Code[1];
        strNombre: Text[250];
        FileTest: File;
        strDato: Text[250];
        strVacio: Text[250];
        datPublic: Date;
        z: Integer;
        rstGLS: Record "General Ledger Setup";
        codRegimen: Code[1];
        rstProv: Record Vendor;
        l_rst99008535: codeunit "Temp Blob";
        l_rstDocumentosDigitalizados: Record "Documentos digitalizados";
        intLinea: Integer;
        cduFM: Codeunit GestionArchivos;
        strRS: Text[100];
        codPF: Code[10];
        strDesc: Text[100];
        j: Integer;
        streamReader: DotNet StreamReader;
        l_rrDocsDigitalizados: RecordRef;
        encoding: DotNet Encoding;
        cduGA: Codeunit "File Management";
        rstRL: Record "Record Link";
        LinkID: Integer;
        l_rstCI: Record "Company Information";
    begin
        codDoc := strRetCualquiera1;

        while StrPos(codDoc, '\') <> 0 do begin

            codDoc := CopyStr(codDoc, StrPos(codDoc, '\') + 1, 1024);

        end;

        rstRet.SetRange("Tipo retención", rstRet."Tipo retención"::"Ingresos Brutos");
        rstRet.SetRange("No. documento", codDoc);
        //rstRet.SETFILTER("Fecha efectividad retencion",'>=%1',datHasta);
        rstRet.DeleteAll;

        FileTest.Open(strRetenidoSRV);
        FileTest.CreateInStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');

        Clear(rstGLS);
        rstGLS.Get();

        z := 0;

        while not (StreamInTest.EOS) do begin

            StreamInTest.ReadText(Txt);

            strDato := '';
            strDato := Txt;

            z += 1;

            for i := 1 to 10 do begin

                case i of
                    1://Régimen
                        begin
                            Evaluate(codRegimen, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    2://Fecha de publicación
                        begin
                            Evaluate(datPublic, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    3://Fecha vigencia desde
                        begin
                            Evaluate(datDesde, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    4://Fecha vigencia hasta
                        begin
                            Evaluate(datHasta, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    5://Número de CUIT
                        begin
                            Evaluate(codCli, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    6://Tipo-Contr_Insc
                        begin
                            Evaluate(codTipoContrInsc, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    7://Marca-alta-sujeto
                        begin
                            Evaluate(codMarcaAltaSujeto, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    8://Marca-alicuota
                        begin
                            Evaluate(codMarcaAlicuota, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    9://Alicuota percepción
                        begin
                            Evaluate(decAlicuotaPercepcion, CopyStr(strDato, 1, StrPos(strDato, ';') - 1));
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                    10://Nro-Grupo-Percepción
                        begin
                            //Por ahora, en ceros
                            strDato := CopyStr(strDato, StrPos(strDato, ';') + 1, 250);
                        end;
                end;

            end;

            dlgDialogo.Update(1, Format(z) + ' - ' + Txt);

            case codRegimen of
                'P':
                    begin

                        Clear(rstCli);
                        rstCli.SetRange(rstCli."VAT Registration No.", CopyStr(codCli, 1, 2) + '-' + CopyStr(codCli, 3, 8) + '-' + CopyStr(codCli, 11, 1));
                        if rstCli.FindFirst then begin
                            rstRet."Tipo registro" := rstRet."Tipo registro"::Venta;
                            rstRet."Cod. proveedor/cliente" := rstCli."No.";
                            rstRet."Tipo retención" := rstRet."Tipo retención"::"Ingresos Brutos";
                            rstRet."Fecha efectividad retencion" := datHasta;
                            rstRet."Fecha documento" := datDesde;
                            rstRet."Fecha emisión boletin" := datPublic;
                            rstRet."% exención" := intPor;
                            rstRet."% percepcion" := decAlicuotaPercepcion;
                            rstRet."% retencion" := decAlicuotaRetencion;
                            rstRet."No. documento" := codDoc;
                            rstRet."Cód. retención" := codTipoContrInsc;
                            rstRet."Cód. retención" := rstGLS."GI retention code";
                            rstCli."GI Inscription type" := codTipoContrInsc;
                            rstCli.Modify;
                            if not rstRet.Insert then
                                rstRet.Modify;
                            j += 1;
                        end;
                    end;

                'R':
                    begin

                        Clear(rstProv);
                        rstProv.SetRange(rstProv."VAT Registration No.", CopyStr(codCli, 1, 2) + '-' + CopyStr(codCli, 3, 8) + '-' + CopyStr(codCli, 11, 1));
                        if rstProv.FindFirst then begin
                            rstRet."Tipo registro" := rstRet."Tipo registro"::Compra;
                            rstRet."Cod. proveedor/cliente" := rstProv."No.";
                            rstRet."Tipo retención" := rstRet."Tipo retención"::"Ingresos Brutos";
                            rstRet."Fecha efectividad retencion" := datHasta;
                            rstRet."Fecha documento" := datDesde;
                            rstRet."Fecha emisión boletin" := datPublic;
                            rstRet."% retencion" := decAlicuotaPercepcion;
                            rstRet."No. documento" := codDoc;
                            rstRet."Cód. retención" := codTipoContrInsc;
                            rstRet."Cód. retención" := rstGLS."GI retention code";
                            rstProv."GI Inscription type" := codTipoContrInsc;
                            rstProv.Modify;
                            if not rstRet.Insert then
                                rstRet.Modify;
                            j += 1;
                        end;

                    end;

            end;

        end;
        dlgDialogo.Close;

        Clear(FileMgt);
        FileMgt.BLOBImportFromServerFile(l_rst99008535, strRetenidoSRV);

        Clear(l_rstDocumentosDigitalizados);
        if l_rstDocumentosDigitalizados.Find('+') then
            intLinea := l_rstDocumentosDigitalizados.Linea
        else
            intLinea := 1;

        Clear(l_rstDocumentosDigitalizados);
        l_rstDocumentosDigitalizados.Linea := intLinea + 1;
        l_rstDocumentosDigitalizados.Archivo := strRetenidoSRV;
        l_rstDocumentosDigitalizados."Nivel 1" := 'txt';
        l_rstDocumentosDigitalizados."Nivel 4" := 'ARBA';
        //l_rstDocumentosDigitalizados.BlobFile := l_rst99008535.Blob;
        l_rstDocumentosDigitalizados.Insert;


        clear(l_rrDocsDigitalizados);
        l_rrDocsDigitalizados.get(l_rstDocumentosDigitalizados.RecordId);
        l_rst99008535.ToRecordRef(l_rrDocsDigitalizados, l_rstDocumentosDigitalizados.FieldNo("BlobFile"));
        l_rrDocsDigitalizados.Modify;

        clear(l_rstCI);
        l_rstCI.get();

        strRetenidoSRV := l_rstCI."Ruta de digitalizacion" + l_rstCI."Ruta cabecera digitalizacion" + cduGA.GetFileName(l_rstDocumentosDigitalizados.Archivo);
        If File.Exists(strRetenidoSRV) then
            strRetenidoSRV := CopyStr(strRetenidoSRV, 1, StrLen(strRetenidoSRV) - 4) + DelChr(format(CurrentDateTime, 10, 1), '=', '/ :') + '.txt';
        cduGA.CopyServerFile(l_rstDocumentosDigitalizados.Archivo, strRetenidoSRV, true);
        IF STRPOS(UPPERCASE(strRetenidoSRV), UPPERCASE(l_rstCI."Ruta Intranet")) = 0 THEN
            strRetenidoSRV := l_rstCI."Ruta Intranet" + (CONVERTSTR(COPYSTR(strRetenidoSRV, STRLEN(l_rstCI."Ruta de digitalizacion"), 250), '\', '/'));
        LinkID := rstGLS.AddLink(strRetenidoSRV, 'Padrón ARBA importado el ' + Format(Today));
        Clear(rstRL);
        rstRL.Get(LinkID);

        FileTest.Close();
    end;

    [Scope('OnPrem')]
    procedure fntFillAlfa(var strAlfa: Text; intQ: Integer)
    begin
        if StrLen(strAlfa) < intQ then
            repeat

                strAlfa := strAlfa + ' ';

            until StrLen(strAlfa) = intQ;
    end;

    [Scope('OnPrem')]
    procedure fntFillNum(var strAlfa: Text; intQ: Integer)
    begin
        if StrLen(strAlfa) < intQ then
            repeat

                strAlfa := '0' + strAlfa;

            until StrLen(strAlfa) = intQ;
    end;

    [Scope('OnPrem')]
    procedure fntNum(intQty: Integer; strData: Text[30]): Text[30]
    begin
        strData := DelChr(strData, '=', '.');
        if StrLen(strData) < intQty then
            repeat

                strData := '0' + strData;

            until StrLen(strData) = intQty;

        if StrLen(strData) > intQty then
            repeat

                strData := CopyStr(strData, 2, 30);

            until StrLen(strData) = intQty;

        exit(fntAnularAcentosyEnes(strData));
    end;

    [Scope('OnPrem')]
    procedure fntDec(decImpo: Decimal; intDec: Integer; intEnt: Integer): Text
    var
        strDec: Text;
        strImpComp: Text;
    begin
        strDec := '';
        strDec := CopyStr(Format(Round(decImpo, 0.01, '<') - Round(decImpo, 1, '<')),
                          StrPos(Format(Round(decImpo, 0.01, '<') - Round(decImpo, 1, '<')), ',') + 1,
                          2);

        if StrLen(strDec) < intDec then
            repeat

                strDec := strDec + '0';

            until StrLen(strDec) = intDec;

        strImpComp := DelChr(Format(Round(decImpo, 1, '<')), '=', '-.,')/*+','*/+ DelChr(strDec, '=', ',-.');
        if StrLen(strImpComp) < intEnt then
            repeat

                strImpComp := '0' + strImpComp;

            until StrLen(strImpComp) = intEnt;

        exit(Format(strImpComp));

    end;

    [Scope('OnPrem')]
    procedure fntDecConComa(decImpo: Decimal; intDec: Integer; intEnt: Integer; codSigno: Code[1]): Text
    var
        strDec: Text;
        strImpComp: Text;
    begin
        strDec := '';
        strDec := CopyStr(Format(Round(decImpo, 0.01, '<') - Round(decImpo, 1, '<')),
                          StrPos(Format(Round(decImpo, 0.01, '<') - Round(decImpo, 1, '<')), ',') + 1,
                          2);

        if StrLen(strDec) < intDec then
            repeat

                strDec := strDec + '0';

            until StrLen(strDec) = intDec;

        strImpComp := DelChr(Format(Round(decImpo, 1, '<')), '=', '-.,') + ',' + DelChr(strDec, '=', ',-.');
        if StrLen(strImpComp) < intEnt then
            repeat

                strImpComp := '0' + strImpComp;

            until StrLen(strImpComp) + StrLen(codSigno) = intEnt;

        exit(Format(codSigno + strImpComp));
    end;

    [Scope('OnPrem')]
    procedure fntAlfa(intQty: Integer; strData: Text[50]): Text[30]
    begin
        if StrLen(strData) < intQty then
            repeat

                strData := strData + ' ';

            until StrLen(strData) = intQty;

        if StrLen(strData) > intQty then
            repeat

                strData := CopyStr(strData, 1, StrLen(strData) - 1);

            until StrLen(strData) = intQty;

        exit(fntAnularAcentosyEnes(strData));
    end;

    [Scope('OnPrem')]
    procedure Ascii2Ansi(_Text: Text[250]): Text[250]
    begin
        MakeVars;
        exit(ConvertStr(_Text, AnsiStr, AsciiStr));
    end;

    [Scope('OnPrem')]
    procedure MakeVars()
    begin
        AsciiStr := '€‚©„…†‡ˆ‰ŠŽÇŽüŽéŽâŽäŽàŽêŽëŽèŽïŽîŽìŽÄŽòŽÖŽÜŽøŽ£ŽƒŽ‚Ž¥ ¡¢ôŽÅ¥ŽØŽÁŽ†©ª«¬Ž€®Ž«Ž¡Ž¡Ž¡Ž¡Ž¡ŽªŽ…Ž‡ŽÀŽ¡Ž¡++½Ž„++--+-+ÔÇÖÔé¼++--Ž¡-+';
        AsciiStr := AsciiStr + 'ŽÿŽæÑŽúŽáŽóiÔäó¥Ø++Ž¡_Ž¡Ž¿ÆÔÇªáãÆŽåÔÇ×ÔÇáÔÇÿÔÇíáé”åÔÇ€ìíÆÔÇ†ŽÉn=óÔÇ£ŽñÔÇØŽÂÔÇ‡ÔÇöúÔÇôüŽ¼Ž¡”£';
        CharVar[1] := 196;
        CharVar[2] := 197;
        CharVar[3] := 201;
        CharVar[4] := 242;
        CharVar[5] := 220;
        CharVar[6] := 186;
        CharVar[7] := 191;
        CharVar[8] := 188;
        CharVar[9] := 187;
        CharVar[10] := 193;
        CharVar[11] := 194;
        CharVar[12] := 192;
        CharVar[13] := 195;
        CharVar[14] := 202;
        CharVar[15] := 203;
        CharVar[16] := 200;
        CharVar[17] := 205;
        CharVar[18] := 206;
        CharVar[19] := 204;
        CharVar[20] := 175;
        CharVar[21] := 223;
        CharVar[22] := 213;
        CharVar[23] := 254;
        CharVar[24] := 218;
        CharVar[25] := 219;
        CharVar[26] := 217;
        CharVar[27] := 180;
        CharVar[28] := 177;
        CharVar[29] := 176;
        CharVar[30] := 185;
        CharVar[31] := 179;
        CharVar[32] := 178;
        AnsiStr := 'Ôé¼üéãÆÔÇ×ÔÇªÔÇáÔÇí”åÔÇ€áÔÇ†Æì' + Format(CharVar[1]) + Format(CharVar[2]) + Format(CharVar[3]) + 'ÔÇÿÔÇÖÔÇ£ÔÇØ' + Format(CharVar[4]);
        AnsiStr := AnsiStr + 'ÔÇôÔÇö”£Ôäó' + Format(CharVar[5]) + 'ÔÇ‡ôØ¥©áíóúnÑª' + Format(CharVar[6]) + Format(CharVar[7]);
        AnsiStr := AnsiStr + '®¬½' + Format(CharVar[8]) + '¡«' + Format(CharVar[9]) + '___ŽØŽØ' + Format(CharVar[10]) + Format(CharVar[11]);
        AnsiStr := AnsiStr + Format(CharVar[12]) + '©ŽØŽØ++¢¥++--+-+Žå' + Format(CharVar[13]) + '++--ŽØ-+ŽÅŽÉŽæ';
        AnsiStr := AnsiStr + Format(CharVar[14]) + Format(CharVar[15]) + Format(CharVar[16]) + 'i' + Format(CharVar[17]) + Format(CharVar[18]);
        AnsiStr := AnsiStr + 'Žÿ++__ŽØ' + Format(CharVar[19]) + Format(CharVar[20]) + 'Žá' + Format(CharVar[21]) + 'ŽóŽúŽñ';
        AnsiStr := AnsiStr + Format(CharVar[22]) + 'Žª' + Format(CharVar[23]) + 'Ž¿' + Format(CharVar[24]) + Format(CharVar[25]);
        AnsiStr := AnsiStr + Format(CharVar[26]) + 'Ž¼Ž¡Ž«' + Format(CharVar[27]) + 'Ž€' + Format(CharVar[28]) + '=Ž„Ž…ŽÁŽÂŽÀ' +
        Format(CharVar[29]);
        AnsiStr := AnsiStr + 'Ž†Ž‡' + Format(CharVar[30]) + Format(CharVar[31]) + Format(CharVar[32]) + '_ ';
    end;

    [Scope('OnPrem')]
    procedure Ansi2Ascii(_Text: Text[30]): Text[30]
    begin
        MakeVars;
        exit(ConvertStr(_Text, AnsiStr, AsciiStr));
    end;

    [Scope('OnPrem')]
    procedure fntAnularAcentosyEnes(strTexto: Text[100]): Text[100]
    begin
        exit(ConvertStr(strTexto, 'áéíóúñÑ', 'aeiounN'));
    end;

    [Scope('OnPrem')]
    procedure fntPercep(codCta: Code[20]): Decimal
    var
        rst17: Record "G/L Entry";
        decTot: Decimal;
    begin
        decTot := 0;
        Clear(rst17);
        rst17.SetRange("Document Type", rstVATEntry."Document Type");
        rst17.SetRange("Document No.", rstVATEntry."Document No.");
        rst17.SetRange("G/L Account No.", codCta);
        if rst17.FindSet then
            repeat

                decTot += rst17.Amount;

            until rst17.Next = 0;
        exit(decTot);
    end;

    [Scope('OnPrem')]
    procedure fntExportarAGIP()
    var
        StreamInTest: OutStream;
        FileTest: File;
        Txt: Text[250];
        rstProv: Record Vendor;
        rstCompanyInfo: Record "Company Information";
        rstRet: Record "Withholding details";
        codProv: Code[11];
        strProv: Text[60];
        datDesde: Date;
        datHasta: Date;
        intPor: Integer;
        rstInBF: Record "Invoice Withholding Buffer";
        rstInBFNC: Record "Invoice Withholding Buffer";
        rstMens: Record Mensajeria;
        strDia: Text[2];
        strMes: Text[2];
        strAno: Text[4];
        rstTipoRet: Record "Withholding codes";
        rstCont: Record "G/L Entry";
        CrLf: Text;
        strTrazabilidad: Text[10];
        strCUITAgente: Text[11];
        intImpuesto: Integer;
        intRegimen: Integer;
        strCUITRetenido: Text[11];
        strFechaRet: Text[10];
        strTipoOp: Text[1];
        strTipo: Text[2];
        strCodNorma: Text[3];
        strFechaCom: Text[10];
        strLetraComprobante: Text[1];
        strNroCompr: Text[16];
        strSituacionIBRetenido: Text[1];
        strImpComp: Text[16];
        strImpRet: Text[16];
        strNroCert: Text[16];
        strCertOrigNro: Text[25];
        strCertOrigFech: Text[10];
        strCertOrigImp: Text[16];
        strOtrosDatos: Text[30];
        strDec: Text[2];
        intDec: Decimal;
        rstMovProveedorFC: Record "Vendor Ledger Entry";
        rstMovProveedor: Record "Vendor Ledger Entry";
        strTipoDocRetenido: Text[1];
        strNroIIBB: Text[11];
        strSituacionIVA: Text[1];
        strRazonSocial: Text[30];
        strImpoIVA: Text[16];
        strOtroImpo: Text[16];
        rstIVA: Record "VAT Entry";
        strBase: Text[16];
        strAlicuota: Text[5];
        rstCli: Record Customer;
        codDoc: Code[20];
        rstFV: Record "Sales Invoice Header";
        rstNV: Record "Sales Cr.Memo Header";
    begin
        //FileMgt.ServerTempFileName(strRetenidoSRV);
        FileTest.TextMode(true);
        FileTest.Create(strRetenidoSRV);
        //FileTest.OPEN(strRetenidoSRV);
        FileTest.CreateOutStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');


        CrLf[1] := 13;
        CrLf[2] := 10;

        Clear(rstInBF);
        rstInBF.SetCurrentKey("Fecha pago", "Cliente/Proveedor", "No. Factura");
        rstInBF.SetRange("Fecha pago", datInicio, datFinal);
        rstInBF.SetFilter("Tipo retencion", '%1', rstInBF."Tipo retencion"::"Ingresos Brutos");
        rstInBF.SetRange(Retenido, true);
        //rstInBF.SETRANGE("Tipo registro",rstInBF."Tipo registro"::Compra);
        rstInBF.SetRange("Tipo factura", rstInBF."Tipo factura"::Factura);
        if rstInBF.FindSet then
            repeat

                j += 1;

                codDoc := '';

                case rstInBF."Tipo registro" of
                    rstInBF."Tipo registro"::Compra:
                        codDoc := rstInBF."No. documento";
                    rstInBF."Tipo registro"::Venta:
                        begin
                            Clear(rstFV);
                            rstFV.SetRange("Pre-Assigned No.", rstInBF."No. documento");
                            if rstFV.FindFirst then
                                codDoc := rstFV."No.";
                            Clear(rstNV);
                            rstNV.SetRange("Pre-Assigned No.", rstInBF."No. documento");
                            if rstNV.FindFirst then
                                codDoc := rstNV."No.";
                        end;
                end;
                Clear(rstCont);
                rstCont.SetCurrentKey(rstCont."Document No.");
                rstCont.SetRange(rstCont."Document No.", codDoc);
                if not rstCont.FindFirst then
                    rstCont.Next
                else begin

                    rstInBF.CalcFields("Factura Prov", "NC Prov");

                    Clear(rstProv);
                    Clear(rstCli);

                    if rstInBF."Tipo registro" = rstInBF."Tipo registro"::Compra then
                        rstProv.Get(rstInBF."Cliente/Proveedor")
                    else
                        rstCli.Get(rstInBF."Cliente/Proveedor");

                    Clear(rstCompanyInfo);
                    rstCompanyInfo.Get();

                    for i := 1 to 21 do begin

                        case i of
                            1://Tipo de Operación
                                if rstInBF."Tipo registro" = rstInBF."Tipo registro"::Compra then
                                    strTipoOp := '1'
                                else
                                    strTipoOp := '2';
                            2://Código de norma
                                begin
                                    strCodNorma := Format(rstInBF."Cod. sicore");
                                    strCodNorma := fntNum(3, '29');
                                end;
                            3://Fecha de retención/percepción
                                begin

                                    strDia := Format(Date2DMY(rstInBF."Fecha pago", 1));
                                    if StrLen(strDia) = 1 then
                                        strDia := '0' + strDia;
                                    strMes := Format(Date2DMY(rstInBF."Fecha pago", 2));
                                    if StrLen(strMes) = 1 then
                                        strMes := '0' + strMes;
                                    strAno := Format(Date2DMY(rstInBF."Fecha pago", 3));
                                    strFechaRet := strDia + '/' +
                                                 strMes + '/' +
                                                 strAno;

                                end;
                            4://Tipo de comprobante origen de la retención
                                begin

                                    if rstInBF."No. Factura" <> '' then begin

                                        Clear(rstMens);
                                        rstMens.SetRange(rstMens."Codigo vinculante", rstInBF."Cliente/Proveedor");
                                        rstMens.SetRange(rstMens."No. documento", rstInBF."No. Factura");
                                        if rstMens.Find('+') then begin

                                            case rstMens."Tipo Documento" of
                                                'Factura (compras)', 'Fact. pronto venc. (compras)', 'Factura (ventas)':
                                                    strTipo := '1';
                                                'Nota débito (compras)', 'Déb. pronto venc. (compras)':
                                                    strTipo := '2';
                                                else
                                                    strTipo := '9';
                                            end;
                                        end;

                                    end;
                                    strTipo := fntNum(2, strTipo);

                                end;
                            5:// Letra del Comprobante
                                if strTipo in ['01', '06', '07'] then begin
                                    if rstInBF."Tipo registro" = rstInBF."Tipo registro"::Compra then
                                        strLetraComprobante := CopyStr(rstInBF."Factura Prov", 1, 1)
                                    else
                                        strLetraComprobante := CopyStr(codDoc, 1, 1);
                                end
                                else
                                    strLetraComprobante := ' ';
                            6://Nro de comprobante
                                begin
                                    if rstInBF."Tipo registro" = rstInBF."Tipo registro"::Compra then
                                        strNroCompr := fntNum(16, DelChr(CopyStr(rstInBF."Factura Prov", 2, 20) + CopyStr(rstInBF."NC Prov", 2, 20), '=', '.-'))
                                    else
                                        strNroCompr := fntNum(16, DelChr(CopyStr(codDoc, 2, 20), '=', '.-'));
                                end;
                            7://Fecha del comprobante
                                begin
                                    /*
                   strDia := FORMAT(DATE2DMY(rstInBF."Fecha factura",1));
                   IF STRLEN(strDia) = 1 THEN
                     strDia := '0'+strDia;
                   strMes := FORMAT(DATE2DMY(rstInBF."Fecha factura",2));
                   IF STRLEN(strMes) = 1 THEN
                     strMes := '0'+strMes;
                   strAno := FORMAT(DATE2DMY(rstInBF."Fecha factura",3));
                   strFechaCom := strDia+'/'+
                                strMes+'/'+
                                strAno;
                                     */
                                    strDia := Format(Date2DMY(rstInBF."Fecha pago", 1));
                                    if StrLen(strDia) = 1 then
                                        strDia := '0' + strDia;
                                    strMes := Format(Date2DMY(rstInBF."Fecha pago", 2));
                                    if StrLen(strMes) = 1 then
                                        strMes := '0' + strMes;
                                    strAno := Format(Date2DMY(rstInBF."Fecha pago", 3));
                                    strFechaCom := strDia + '/' +
                                                 strMes + '/' +
                                                 strAno;


                                end;
                            8://Monto del comprobante
                                begin

                                    Clear(rstIVA);
                                    if rstInBF."Tipo registro" = rstInBF."Tipo registro"::Compra then
                                        rstIVA.SetRange("Document No.", rstInBF."No. Factura")
                                    else
                                        rstIVA.SetRange("Document No.", codDoc);
                                    rstIVA.CalcSums(Amount, Base);

                                    strImpComp := fntDecConComa(rstIVA.Base + rstIVA.Amount, 2, 16, '');
                                    strImpComp := fntDecConComa(rstInBF."Importe neto factura", 2, 16, '');

                                end;
                            9://Nro de certificado propio
                                begin

                                    if strTipoOp = '1' then begin
                                        strNroCert := Format(rstInBF."Serie retención");
                                        fntFillAlfa(strNroCert, 16);
                                    end;
                                    if strTipoOp = '2' then begin
                                        strNroCert := '';
                                        fntFillAlfa(strNroCert, 16);
                                    end;

                                end;
                            10://Tipo de documento del Retenido
                                begin

                                    strTipoDocRetenido := '3';

                                end;
                            11://Nro de documento del Retenido
                                begin

                                    Evaluate(strCUITRetenido, DelChr(rstProv."VAT Registration No." + rstCli."VAT Registration No.", '=', '-'));

                                end;
                            12:// Nro Inscripción IB del Retenido
                                begin

                                    strNroIIBB := CopyStr(DelChr(CopyStr(rstProv."No. ingresos brutos" + rstCli."No. ingresos brutos", 1, 20), '=', '.-/'), 1, 11);
                                    strNroIIBB := '0';
                                    fntFillNum(strNroIIBB, 11);

                                end;
                            13:// Situación IB del Retenido
                                begin

                                    case CopyStr(strNroIIBB, 1, 2) of
                                        '90':
                                            begin

                                                strSituacionIBRetenido := '2';

                                            end
                                        else begin

                                            strSituacionIBRetenido := '1';

                                        end;
                                            /*
                                        IF rstProv."Inscripto IIBB" = rstProv."Inscripto IIBB"::Sí THEN
                                        BEGIN

                                          IF rstProv."GI Inscription type" = 'D' THEN
                                            strSituacionIBRetenido := '1';
                                          IF rstProv."GI Inscription type" = 'C' THEN
                                            strSituacionIBRetenido := '2';
                                          IF rstProv."Tax Area Code" = 'PRV-MONO' THEN
                                            strSituacionIBRetenido := '5';

                                        END
                                        ELSE
                                        BEGIN

                                          strSituacionIBRetenido := '4';

                                        END;
                                             */
                                            strSituacionIBRetenido := '4';

                                    end;

                                end;
                            14://Situación frente al IVA del Retenido
                                begin

                                    case rstProv."Tax Area Code" of
                                        'PRV-MONO':
                                            strSituacionIVA := '4';
                                        'PRV-RI':
                                            strSituacionIVA := '1';
                                        'PRV-EXENTO':
                                            strSituacionIVA := '3';
                                    end;

                                end;
                            15://Razón Social del Retenido
                                begin

                                    strRazonSocial := CopyStr(rstProv.Name + rstCli.Name, 1, 30);
                                    strRazonSocial := fntAnularAcentosyEnes(strRazonSocial);
                                    fntFillAlfa(strRazonSocial, 30);

                                end;
                            16:// Importe otros conceptos
                                begin

                                    strOtroImpo := fntDecConComa(0, 2, 16, '');

                                end;
                            17:// Importe IVA
                                begin

                                    Clear(rstIVA);
                                    if rstInBF."Tipo registro" = rstInBF."Tipo registro"::Compra then
                                        rstIVA.SetRange("Document No.", rstInBF."No. Factura")
                                    else
                                        rstIVA.SetRange("Document No.", codDoc);
                                    rstIVA.CalcSums(Amount);

                                    strImpoIVA := fntDecConComa(rstIVA.Amount, 2, 16, '');
                                    strImpoIVA := fntDecConComa(0, 2, 16, '');

                                end;
                            18://Monto Sujeto a Retención/ Percepción
                                begin

                                    strBase := fntDecConComa(rstInBF."Importe neto factura", 2, 16, '');

                                end;
                            19://Alícuota
                                begin

                                    strAlicuota := fntDecConComa(rstInBF."% retencion", 2, 5, '');

                                end;
                            20://Retención/Percepción Practicada
                                begin


                                    strImpRet := fntDecConComa(rstInBF."Importe retencion", 2, 16, '');

                                end;
                            21://Monto Total Retenido/Percibido
                                begin

                                    strImpRet := fntDecConComa(rstInBF."Importe retencion", 2, 16, '');

                                end;

                        end;

                    end;

                    Txt :=
                            strTipoOp +
                            strCodNorma +
                            strFechaRet +
                            strTipo +
                            strLetraComprobante +
                            strNroCompr +
                            strFechaCom +
                            strImpComp +
                            strNroCert +
                            strTipoDocRetenido +
                            strCUITRetenido +
                            strSituacionIBRetenido +
                            strNroIIBB +
                            strSituacionIVA +
                            strRazonSocial +
                            strOtroImpo +
                            strImpoIVA +
                            strBase +
                            strAlicuota +
                            strImpRet +
                            strImpRet;

                    dlgDialogo.Update(1, Txt);

                    StreamInTest.WriteText(Txt +
                                           CrLf);

                end;

            until rstInBF.Next = 0;

        dlgDialogo.Close;

        FileTest.Close();

        FileMgt.DownloadTempFile(strRetenidoSRV);

        strRetCualquiera3 := FileMgt.UploadFileWithFilter('Facturas', 'Facturas.txt', 'Archivos de texto (*.txt)|*.txt', '*.txt');
        //FileMgt.DownloadToFile(strRetenidoSRV, strRetCualquiera3);

    end;

    [Scope('OnPrem')]
    procedure fntExportarAGIPNC()
    var
        StreamInTest: OutStream;
        FileTest: File;
        Txt: Text[250];
        rstProv: Record Vendor;
        rstCompanyInfo: Record "Company Information";
        rstRet: Record "Withholding details";
        codProv: Code[11];
        strProv: Text[60];
        datDesde: Date;
        datHasta: Date;
        intPor: Integer;
        rstInBF: Record "Invoice Withholding Buffer";
        rstInBFNC: Record "Invoice Withholding Buffer";
        rstMens: Record Mensajeria;
        strDia: Text[2];
        strMes: Text[2];
        strAno: Text[4];
        rstTipoRet: Record "Withholding codes";
        rstCont: Record "G/L Entry";
        CrLf: Text;
        strTrazabilidad: Text[10];
        strCUITAgente: Text[11];
        intImpuesto: Integer;
        intRegimen: Integer;
        strCUITRetenido: Text[11];
        strFechaRet: Text[10];
        strTipoOp: Text[1];
        strTipo: Text[2];
        strCodNorma: Text[3];
        strFechaCom: Text[10];
        strLetraComprobante: Text[1];
        strNroCompr: Text[16];
        strSituacionIBRetenido: Text[1];
        strImpComp: Text[16];
        strImpRet: Text[16];
        strNroCert: Text[16];
        strCertOrigNro: Text[25];
        strCertOrigFech: Text[10];
        strCertOrigImp: Text[16];
        strOtrosDatos: Text[30];
        strDec: Text[2];
        intDec: Decimal;
        rstMovProveedorFC: Record "Vendor Ledger Entry";
        rstMovProveedor: Record "Vendor Ledger Entry";
        strTipoDocRetenido: Text[1];
        strNroIIBB: Text[11];
        strSituacionIVA: Text[1];
        strRazonSocial: Text[30];
        strImpoIVA: Text[16];
        strOtroImpo: Text[16];
        rstIVA: Record "VAT Entry";
        strBase: Text[16];
        strAlicuota: Text[5];
        rstCli: Record Customer;
        codDoc: Code[20];
        rstFV: Record "Sales Invoice Header";
        rstNV: Record "Sales Cr.Memo Header";
        rstLNV: Record "Sales Cr.Memo Line";
        rstConfCont: Record "General Ledger Setup";
        strNroNC: Text[12];
        rstNC: Record "Purch. Cr. Memo Hdr.";
        rstFC: Record "Purch. Inv. Header";
        strFechaNC: Text[10];
    begin
        //FileMgt.ServerTempFileName(strRetenidoSRV);
        FileTest.TextMode(true);
        FileTest.Create(strRetenidoSRV);
        //FileTest.OPEN(strRetenidoSRV);
        FileTest.CreateOutStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');


        CrLf[1] := 13;
        CrLf[2] := 10;

        Clear(rstInBF);
        rstInBF.SetCurrentKey("Fecha pago", "Cliente/Proveedor", "No. Factura");
        rstInBF.SetRange("Fecha pago", datInicio, datFinal);
        rstInBF.SetFilter("Tipo retencion", '%1', rstInBF."Tipo retencion"::"Ingresos Brutos");
        rstInBF.SetRange(Retenido, true);
        //rstInBF.SETRANGE("Tipo registro",rstInBF."Tipo registro"::Compra);
        rstInBF.SetRange("Tipo factura", rstInBF."Tipo factura"::"Nota d/c");
        if rstInBF.FindSet then
            repeat

                j += 1;

                Clear(rstNC);
                rstNC.SetRange(rstNC."No.", rstInBF."No. Factura");
                if rstNC.FindFirst then;

                codDoc := '';
                codDoc := rstNC."Vendor Cr. Memo No.";

                Clear(rstCont);
                rstCont.SetCurrentKey(rstCont."Document No.");
                rstCont.SetRange(rstCont."Document No.", rstNC."No.");
                if not rstCont.FindFirst then
                    rstCont.Next
                else begin

                    rstInBF.CalcFields("Factura Prov", "NC Prov");

                    Clear(rstProv);
                    Clear(rstCli);

                    if rstInBF."Tipo registro" = rstInBF."Tipo registro"::Compra then
                        rstProv.Get(rstInBF."Cliente/Proveedor");

                    Clear(rstCompanyInfo);
                    rstCompanyInfo.Get();

                    for i := 1 to 13 do begin

                        case i of
                            1://Tipo de Operación
                                strTipoOp := '1';
                            2://Nro nota de crédito
                                strNroNC := fntNum(12, DelChr(CopyStr(codDoc, 2, 20), '=', '.-'));
                            3://Fecha de NC
                                begin

                                    strDia := Format(Date2DMY(rstInBF."Fecha pago"/*rstNC."Posting Date"*/, 1));
                                    if StrLen(strDia) = 1 then
                                        strDia := '0' + strDia;
                                    strMes := Format(Date2DMY(rstInBF."Fecha pago"/*rstNC."Posting Date"*/, 2));
                                    if StrLen(strMes) = 1 then
                                        strMes := '0' + strMes;
                                    strAno := Format(Date2DMY(rstInBF."Fecha pago"/*rstNC."Posting Date"*/, 3));
                                    strFechaCom := strDia + '/' +
                                                 strMes + '/' +
                                                 strAno;

                                end;
                            4://Monto NC
                                begin

                                    Clear(rstIVA);
                                    rstIVA.SetRange("Document Type", rstIVA."Document Type"::"Credit Memo");
                                    rstIVA.SetRange("Document No.", rstNC."No.");
                                    rstIVA.FindFirst;
                                    rstIVA.CalcSums(Amount, Base);

                                    strImpComp := fntDecConComa(rstIVA.Base/*+rstIVA.Amount*/, 2, 16, '');
                                    //strImpComp := fntDecConComa(rstNC."Importe neto factura",2,16);

                                end;
                            5://Nro de certificado propio
                                begin
                                    strNroCert := rstInBF."Serie retención";
                                    fntFillAlfa(strNroCert, 16);
                                end;
                            6://Tipo de comprobante origen de la retención
                                begin
                                    /*
                                    strTipo := '9';
                                    strTipo := fntNum(2,strTipo);
                                    */

                                    if (rstNC."Corrected Invoice No." <> '') or (rstNC."Applies-to Doc. No." <> '') then begin

                                        Clear(rstFC);
                                        if rstNC."Corrected Invoice No." <> '' then
                                            rstFC.Get(rstNC."Corrected Invoice No.");

                                        Clear(rstFC);
                                        if rstNC."Applies-to Doc. No." <> '' then
                                            rstFC.Get(rstNC."Applies-to Doc. No.");

                                        Clear(rstMens);
                                        //rstMens.SETRANGE(rstMens."Código vinculante",rstFV."Bill-to Customer No.");
                                        rstMens.SetRange(rstMens."No. documento", rstFC."No.");

                                        if rstMens.Find('+') then begin

                                            case rstMens."Tipo Documento" of
                                                'Factura (compras)', 'Fact. pronto venc. (compras)', 'Factura (ventas)':
                                                    strTipo := '1';
                                                'Nota débito (ventas)', 'Déb. pronto venc. (compras)':
                                                    strTipo := '2';
                                                else
                                                    strTipo := '9';
                                            end;
                                        end;

                                    end
                                    else begin

                                        Clear(rstInBFNC);
                                        rstInBFNC.SetRange("No. documento", rstInBF."No. documento");
                                        rstInBFNC.SetRange("Tipo factura", rstInBFNC."Tipo factura"::Factura);
                                        rstInBFNC.SetRange("Tipo retencion", rstInBFNC."Tipo retencion"::"Ingresos Brutos");
                                        rstInBFNC.SetRange(Retenido, true);
                                        if rstInBFNC.FindFirst then begin

                                            Clear(rstFC);
                                            rstFC.Get(rstInBFNC."No. Factura");

                                            Clear(rstMens);
                                            rstMens.SetRange(rstMens."No. documento", rstInBFNC."No. Factura");

                                            if rstMens.Find('+') then begin

                                                case rstMens."Tipo Documento" of
                                                    'Factura (compras)', 'Fact. pronto venc. (compras)', 'Factura (ventas)':
                                                        strTipo := '1';
                                                    'Nota débito (ventas)', 'Déb. pronto venc. (compras)':
                                                        strTipo := '2';
                                                    else
                                                        strTipo := '9';
                                                end;
                                            end;

                                        end;

                                    end;

                                    strTipo := fntNum(2, strTipo);

                                end;
                            7:// Letra del Comprobante
                                strLetraComprobante := CopyStr(rstFC."Vendor Invoice No.", 1, 1);
                            8://Nro de comprobante
                                strNroCompr := fntNum(16, DelChr(CopyStr(rstFC."Vendor Invoice No.", 2, 20), '=', '-'));
                            9://Nro de documento del Retenido
                                Evaluate(strCUITRetenido, DelChr(rstProv."VAT Registration No.", '=', '-'));
                            10://Código de norma
                                strCodNorma := fntNum(3, '29');
                            11://Fecha de retención/percepción
                                begin

                                    strDia := Format(Date2DMY(rstInBF."Fecha pago", 1));
                                    if StrLen(strDia) = 1 then
                                        strDia := '0' + strDia;
                                    strMes := Format(Date2DMY(rstInBF."Fecha pago", 2));
                                    if StrLen(strMes) = 1 then
                                        strMes := '0' + strMes;
                                    strAno := Format(Date2DMY(rstInBF."Fecha pago", 3));
                                    strFechaRet := strDia + '/' +
                                                 strMes + '/' +
                                                 strAno;

                                end;
                            12://Monto retención
                                strImpRet := fntDecConComa(rstInBF."Importe retencion", 2, 16, '');
                            13://Alícuota
                                strAlicuota := fntDecConComa(rstInBF."% retencion", 2, 5, '');

                        end;

                    end;

                    Txt :=
                          strTipoOp +
                          strNroNC +
                          strFechaCom +
                          strImpComp +
                          strNroCert +
                          strTipo +
                          strLetraComprobante +
                          strNroCompr +
                          strCUITRetenido +
                          strCodNorma +
                          strFechaRet +
                          strImpRet +
                          strAlicuota;

                    dlgDialogo.Update(1, Txt);

                    StreamInTest.WriteText(Txt +
                                           CrLf);

                end;

            until rstInBF.Next = 0;

        Clear(rstNV);
        rstNV.SetRange("Posting Date", datInicio, datFinal);
        if rstNV.FindSet then
            repeat

                codDoc := '';
                codDoc := rstNV."No.";

                Clear(rstConfCont);
                rstConfCont.Get();

                Clear(rstLNV);
                rstLNV.SetRange("Document No.", rstNV."No.");
                rstLNV.SetRange("No.", rstConfCont."GI perception account");
                if rstLNV.FindFirst then;


                Clear(rstCont);
                rstCont.SetCurrentKey(rstCont."Document No.");
                rstCont.SetRange(rstCont."Document No.", codDoc);
                rstCont.SetRange("G/L Account No.", rstConfCont."GI perception account");
                if not rstCont.FindFirst then
                    rstCont.Next
                else begin

                    j += 1;


                    Clear(rstProv);
                    Clear(rstCli);

                    rstCli.Get(rstNV."Bill-to Customer No.");

                    Clear(rstCompanyInfo);
                    rstCompanyInfo.Get();

                    Clear(rstFV);
                    rstFV.SetRange("No.", rstNV."Corrected Invoice No.");
                    rstFV.FindFirst;

                    for i := 1 to 13 do begin

                        case i of
                            1://Tipo de Operación
                                strTipoOp := '2';
                            2://Nro nota de crédito
                                strNroNC := fntNum(12, DelChr(CopyStr(codDoc, 2, 20), '=', '.-'));
                            3://Fecha de retención/percepción
                                begin

                                    strDia := Format(Date2DMY(rstNV."Posting Date", 1));
                                    if StrLen(strDia) = 1 then
                                        strDia := '0' + strDia;
                                    strMes := Format(Date2DMY(rstNV."Posting Date", 2));
                                    if StrLen(strMes) = 1 then
                                        strMes := '0' + strMes;
                                    strAno := Format(Date2DMY(rstNV."Posting Date", 3));
                                    strFechaNC := strDia + '/' +
                                                 strMes + '/' +
                                                 strAno;

                                end;
                            4://Monto NC
                                begin

                                    Clear(rstIVA);
                                    rstIVA.SetRange("Document Type", rstIVA."Document Type"::"Credit Memo");
                                    rstIVA.SetRange("Document No.", codDoc);
                                    rstIVA.FindFirst;
                                    rstIVA.CalcSums(Amount, Base);

                                    strImpComp := fntDecConComa(rstIVA.Base/*+rstIVA.Amount*/, 2, 16, '');
                                    //strImpComp := fntDecConComa(rstNV."Importe neto factura",2,16);

                                end;
                            5://Nro de certificado propio
                                begin
                                    strNroCert := '';
                                    fntFillAlfa(strNroCert, 16);
                                end;
                            6://Tipo de comprobante origen de la retención
                                begin
                                    /*
                                    strTipo := '9';
                                    strTipo := fntNum(2,strTipo);
                                    */
                                    if rstFV."Pre-Assigned No." <> '' then begin

                                        Clear(rstMens);
                                        //rstMens.SETRANGE(rstMens."Código vinculante",rstFV."Bill-to Customer No.");
                                        rstMens.SetRange(rstMens."No. documento", rstFV."Pre-Assigned No.");

                                        if rstMens.Find('+') then begin

                                            case rstMens."Tipo Documento" of
                                                'Factura (compras)', 'Fact. pronto venc. (compras)', 'Factura (ventas)':
                                                    strTipo := '1';
                                                'Nota débito (ventas)', 'Déb. pronto venc. (compras)':
                                                    strTipo := '2';
                                                else
                                                    strTipo := '9';
                                            end;
                                        end;

                                    end;
                                    strTipo := fntNum(2, strTipo);

                                end;
                            7:// Letra del Comprobante
                                strLetraComprobante := CopyStr(rstFV."No.", 1, 1);
                            8://Nro de comprobante
                                strNroCompr := fntNum(16, DelChr(CopyStr(rstFV."No.", 2, 20), '=', '-'));
                            9://Nro de documento del Retenido
                                Evaluate(strCUITRetenido, DelChr(rstCli."VAT Registration No.", '=', '-'));
                            10://Código de norma
                                strCodNorma := fntNum(3, '29');
                            11://Fecha de retención/percepción
                                begin

                                    strDia := Format(Date2DMY(rstFV."Posting Date", 1));
                                    if StrLen(strDia) = 1 then
                                        strDia := '0' + strDia;
                                    strMes := Format(Date2DMY(rstFV."Posting Date", 2));
                                    if StrLen(strMes) = 1 then
                                        strMes := '0' + strMes;
                                    strAno := Format(Date2DMY(rstFV."Posting Date", 3));
                                    strFechaRet := strDia + '/' +
                                                 strMes + '/' +
                                                 strAno;

                                end;
                            12://Monto percepción
                                begin

                                    if rstNV."Currency Factor" <> 0 then
                                        strImpRet := fntDecConComa(rstLNV.Amount / rstNV."Currency Factor", 2, 16, '')
                                    else
                                        strImpRet := fntDecConComa(rstLNV.Amount, 2, 16, '');

                                end;
                            13://Alícuota
                                begin

                                    Clear(rstInBF);
                                    rstInBF.SetRange("Tipo registro", rstInBF."Tipo registro"::Venta);
                                    rstInBF.SetRange("Tipo retencion", rstInBF."Tipo retencion"::"Ingresos Brutos");
                                    rstInBF.SetRange("No. documento", rstFV."Pre-Assigned No.");
                                    rstInBF.SetFilter("Importe retencion", '<>%1', 0);
                                    rstInBF.SetRange(Retenido, true);
                                    if rstInBF.FindFirst then;
                                    strAlicuota := fntDecConComa(rstInBF."% retencion", 2, 5, '');

                                end;

                        end;

                    end;

                    Txt :=
                          strTipoOp +
                          strNroNC +
                          strFechaNC +
                          strImpComp +
                          strNroCert +
                          strTipo +
                          strLetraComprobante +
                          strNroCompr +
                          strCUITRetenido +
                          strCodNorma +
                          strFechaRet +
                          strImpRet +
                          strAlicuota;


                    dlgDialogo.Update(1, Txt);

                    StreamInTest.WriteText(Txt +
                                           CrLf);

                end;

            until rstNV.Next = 0;

        dlgDialogo.Close;

        FileTest.Close();

        FileMgt.DownloadTempFile(strRetenidoSRV);

        strRetCualquiera3 := FileMgt.UploadFileWithFilter('Notas de crédito', 'NotasCredito.txt', 'Archivos de texto (*.txt)|*.txt', '*.txt');

        //FileMgt.DownloadToFile(strRetenidoSRV, strRetCualquiera3);

    end;

    procedure fntImportarApocs()
    var
        StreamInTest: InStream;
        Txt: Text;
        rstProv: Record Vendor;
        rstRet: Record "Withholding details";
        codProv: Code[11];
        strProv: Text[60];
        datDesde: Date;
        datHasta: Date;
        strObs: Text;
        codDoc: Code[20];
        intCant: Integer;
        FileTest: File;
        rstGLS: Record "General Ledger Setup";
        rstCL: Record "Comment Line";
        FileMgt: Codeunit "File Management";
        i: Integer;
        j: Integer;
        LinkID: Integer;
        rstRL: Record "Record Link";
        OutStr: OutStream;
        NVInStream: InStream;
        NVOutStream: OutStream;
        UploadResult: Boolean;
        ErrorMessage: Text;
        DialogCaption: Text;
        Name: Text;
        FileFilter: Text;
        ExtFilter: Text;
        BLOBRef: Codeunit "Temp Blob";
        ToFile: Text;
        Path: Text;
        IsDownloaded: Boolean;
        cduFM: Codeunit GestionArchivos;
        cduGA: Codeunit "File Management";
        l_rstDocumentosDigitalizados: Record "Documentos Digitalizados";
        l_rrDocsDigitalizados: RecordRef;
        intLinea: Integer;
        l_rstCI: Record "Company Information";
    begin
        Clear(rstGLS);
        rstGLS.Get();
        rstGLS.TestField("Apochryphal listing URL");
        rstGLS.TestField("Apochryphal file ext.");

        strRetenidoSRV := cduFM.DownloadFromURL(rstGLS."Apochryphal listing URL", rstGLS."Apochryphal file ext.");

        FileMgt.DownloadTempFile(strRetenidoSRV);
        FileTest.Open(strRetenidoSRV);
        FileTest.CreateInStream(StreamInTest);
        i := 0;
        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');

        while not (StreamInTest.EOS) do begin
            StreamInTest.ReadText(Txt);

            i += 1;
            j := 0;
            if i > 3 then
                repeat

                    j += 1;
                    case j of
                        1:
                            codProv := CopyStr(Txt, 1, StrPos(Txt, ',') - 1);
                        //2:strProv := COPYSTR(Txt,1,STRPOS(Txt,',')-1);
                        2:
                            Evaluate(datDesde, CopyStr(Txt, 1, StrPos(Txt, ',') - 1));
                        3:
                            Evaluate(datHasta, CopyStr(Txt, 1, StrPos(Txt, ',') - 1));
                        4:
                            strObs := Txt;
                    end;

                    if (StrPos(Txt, ',') <> 0) and (j < 4) then
                        Txt := CopyStr(Txt, StrPos(Txt, ',') + 1, 1000)
                    else
                        Txt := '';
                    dlgDialogo.Update(1, Format(i));

                    Clear(rstProv);
                    if rstProv.Get(CopyStr(codProv, 1, 10)) then begin

                        Clear(rstCL);
                        rstCL."Table Name" := rstCL."Table Name"::Vendor;
                        rstCL."No." := CopyStr(codProv, 1, 10);
                        rstCL."Line No." := 10000;
                        rstCL.Comment := 'Fue hallado emitiendo facturas apócrifas el ' + Format(datDesde) + ', publicado el ' + Format(datHasta);
                        rstCL.Date := Today;
                        if not rstCL.Insert then
                            repeat
                                rstCL."Line No." += 10000;
                            until rstCL.Insert;

                        rstProv."Sin Autorizacion Pago" := true;
                        rstProv.Modify;

                    end;

                until j = 4;

            rstGLS."Last apochryphal update" := Today;
            rstGLS.Modify;

        end;

        LinkID := rstGLS.AddLink(strArchivo, 'Informe de facturas apócrifas ejecutado el ' + Format(Today));


        //rstRL.Type := rstRL.Type::Note;
        //rstRL.Note.IMPORT(strRetenidoSRV,false);

        Clear(l_rstDocumentosDigitalizados);
        if l_rstDocumentosDigitalizados.Find('+') then
            intLinea := l_rstDocumentosDigitalizados.Linea
        else
            intLinea := 1;

        Clear(l_rstDocumentosDigitalizados);
        l_rstDocumentosDigitalizados.Linea := intLinea + 1;
        l_rstDocumentosDigitalizados.Archivo := strRetenidoSRV;
        l_rstDocumentosDigitalizados."Nivel 1" := 'txt';
        l_rstDocumentosDigitalizados."Nivel 4" := 'Apócrifas';
        l_rstDocumentosDigitalizados.Insert;

        clear(l_rrDocsDigitalizados);
        l_rrDocsDigitalizados.get(l_rstDocumentosDigitalizados.RecordId);
        BLOBRef.CreateOutStream(NVOutStream);
        BLOBRef.ToRecordRef(l_rrDocsDigitalizados, l_rstDocumentosDigitalizados.FieldNo("BlobFile"));
        l_rrDocsDigitalizados.Modify;


        strRetenidoSRV := FileMgt.ServerTempFileName('txt');

        clear(l_rstCI);
        l_rstCI.get();

        strRetenidoSRV := l_rstCI."Ruta de digitalizacion" + l_rstCI."Ruta cabecera digitalizacion" + cduGA.GetFileName(l_rstDocumentosDigitalizados.Archivo);
        If File.Exists(strRetenidoSRV) then
            strRetenidoSRV := CopyStr(strRetenidoSRV, 1, StrLen(strRetenidoSRV) - 4) + DelChr(format(CurrentDateTime, 10, 1), '=', '/ :') + '.txt';
        cduGA.CopyServerFile(l_rstDocumentosDigitalizados.Archivo, strRetenidoSRV, true);
        IF STRPOS(UPPERCASE(strRetenidoSRV), UPPERCASE(l_rstCI."Ruta Intranet")) = 0 THEN
            strRetenidoSRV := l_rstCI."Ruta Intranet" + (CONVERTSTR(COPYSTR(strRetenidoSRV, STRLEN(l_rstCI."Ruta de digitalizacion"), 250), '\', '/'));
        LinkID := rstGLS.AddLink(strRetenidoSRV, 'Padrón facturas apócrifas importado el ' + Format(Today));
        Clear(rstRL);
        rstRL.Get(LinkID);

        FileTest.Close;

        FileMgt.BLOBExport(BLOBRef, strRetenidoSRV, true);


    end;

    [Scope('OnPrem')]
    procedure fntExportarARBA()
    var
        StreamInTest: OutStream;
        Txt: Text[250];
        rstProv: Record Vendor;
        rstRet: Record "Withholding details";
        codProv: Code[11];
        strProv: Text[60];
        datDesde: Date;
        datHasta: Date;
        intPor: Integer;
        codDoc: Text[20];
        intCant: Integer;
        FileTest: File;
        strDato: Text[250];
        strVacio: Text[250];
        datPublic: Date;
        codInciso: Code[1];
        rstInBF: Record "Invoice Withholding Buffer";
        rstInBF2: Record "Invoice Withholding Buffer";
        rstMens: Record Mensajeria;
        strPV: Text[20];
        strDia: Text[2];
        strMes: Text[2];
        strAno: Text[4];
        strFechEm: Text[10];
        strNroComp: Text[16];
        decImp: Text[16];
        intImp: Text[3];
        rstTipoRet: Record "Withholding codes";
        codReg: Text[3];
        intOper: Text[1];
        decBase: Text[16];
        decPorExcl: Text[16];
        strFecRet: Text[10];
        codCond: Text[2];
        intRetPract: Text[1];
        decImpRet: Text[16];
        strFecBol: Text[10];
        intTDocRet: Text[2];
        strNroDocRet: Text[20];
        intNroCert: Text[30];
        rstCont: Record "G/L Entry";
        CrLf: Text;
        blnPasar: Boolean;
    begin
        FileTest.TextMode(true);
        FileTest.Create(strRetenidoSRV);
        FileTest.CreateOutStream(StreamInTest);

        Clear(dlgDialogo);
        dlgDialogo.Open('#1##################################');


        CrLf[1] := 13;
        CrLf[2] := 10;

        Clear(rstInBF2);
        rstInBF2.SetCurrentKey("Fecha pago", "Cliente/Proveedor", "No. documento");
        rstInBF2.SetRange("Fecha pago", datInicio, datFinal);
        rstInBF2.SetFilter("Tipo retencion", '%1', rstInBF2."Tipo retencion"::"Ingresos Brutos");
        rstInBF2.SetRange(Retenido, true);
        if rstInBF2.FindSet then
            repeat

                blnPasar := false;
                if strNroDocRet = '' then
                    strNroDocRet := rstInBF2."No. documento"
                else begin
                    if strNroDocRet = rstInBF2."No. documento" then
                        blnPasar := true
                    else
                        strNroDocRet := rstInBF2."No. documento";
                end;

                if blnPasar = false then begin

                    Clear(rstInBF);
                    rstInBF.SetCurrentKey("Fecha pago", "Cliente/Proveedor", "No. documento");
                    rstInBF.SetRange("Fecha pago", datInicio, datFinal);
                    rstInBF.SetFilter("Tipo retencion", '%1', rstInBF."Tipo retencion"::"Ingresos Brutos");
                    rstInBF.SetRange(Retenido, true);
                    rstInBF.SetRange("Cliente/Proveedor", rstInBF2."Cliente/Proveedor");
                    rstInBF.SetRange("No. documento", rstInBF2."No. documento");
                    if rstInBF.FindSet then begin

                        j += 1;

                        Clear(rstCont);
                        rstCont.SetCurrentKey(rstCont."Document No.");
                        rstCont.SetRange(rstCont."Document No.", rstInBF."No. documento");
                        if not rstCont.FindFirst then
                            rstCont.Next
                        else begin

                            rstInBF.CalcFields("Factura Prov");
                            rstInBF.CalcSums("Importe retencion");
                            codDoc := '';
                            strFechEm := '';
                            strNroComp := '';
                            decImp := '';
                            intImp := '';
                            codReg := '';
                            intOper := '';
                            decBase := '';
                            strFecRet := '';
                            codCond := '';
                            intRetPract := '';
                            decImpRet := '';
                            decPorExcl := '';
                            strFecBol := '';
                            intTDocRet := '';
                            intNroCert := '';

                            Clear(rstProv);
                            rstProv.Get(rstInBF."Cliente/Proveedor");

                            for i := 1 to 6 do begin

                                case i of
                                    1:
                                        begin

                                            strProv := rstProv."VAT Registration No.";

                                        end;
                                    2:
                                        begin

                                            strDia := Format(Date2DMY(rstInBF."Fecha pago", 1));
                                            if StrLen(strDia) = 1 then
                                                strDia := '0' + strDia;
                                            strMes := Format(Date2DMY(rstInBF."Fecha pago", 2));
                                            if StrLen(strMes) = 1 then
                                                strMes := '0' + strMes;
                                            strAno := Format(Date2DMY(rstInBF."Fecha pago", 3));

                                            strFechEm := strDia + '/' +
                                                          strMes + '/' +
                                                          strAno;

                                        end;
                                    3:
                                        begin

                                            strPV := /*DELCHR(*/rstInBF."Serie retención"/*,'=',DELCHR(rstInBF."Serie retención",'=','-0123456789'))*/;
                                            strPV := DelChr(CopyStr(strPV, 1, StrPos(strPV, '-')), '=', '-');
                                            if StrLen(strPV) > 4 then
                                                strPV := CopyStr(strPV, StrLen(strPV) - 3, StrLen(strPV));
                                            fntFillNum(strPV, 4);

                                        end;
                                    4:
                                        begin

                                            strNroComp := DelChr(rstInBF."Serie retención", '=', DelChr(rstInBF."Serie retención", '=', '-0123456789'));
                                            strNroComp := DelChr(CopyStr(strNroComp, StrPos(strNroComp, '-') + 1, 1000), '=', '-');
                                            if StrLen(strNroComp) > 8 then
                                                strNroComp := CopyStr(strNroComp, StrLen(strNroComp) - 7, StrLen(strNroComp));
                                            fntFillNum(strNroComp, 8);

                                        end;
                                    5:
                                        begin

                                            decImpRet := fntDecConComa(rstInBF."Importe retencion", 2, 11, '');

                                        end;
                                    6:
                                        begin

                                            codReg := 'A';

                                        end;

                                end;

                            end;

                            Txt :=
                                                    strProv +
                                                    strFechEm +
                                                    strPV +
                                                    strNroComp +
                                                    decImpRet +
                                                    codReg;
                            dlgDialogo.Update(1, Txt);
                            StreamInTest.WriteText(Txt +
                                                    CrLf);

                        end;

                    end;

                end;

            until rstInBF2.Next = 0;

        dlgDialogo.Close;

        FileTest.Close();

        FileMgt.DownloadTempFile(strRetenidoSRV);

        strRetCualquiera2 := FileMgt.UploadFileWithFilter('Archivo nuevo', '*.*', 'Archivos de texto (*.txt)|*.txt', '*.txt');
        //FileMgt.DownloadToFile(strRetenidoSRV, strRetCualquiera2);

    end;

    local procedure fntDocsInternosCompras(l_doc: Code[20]): Boolean
    var
        rstMens: Record Mensajeria;
        rstNC: Record "Purch. Cr. Memo Hdr.";
        l_rst50519: Record "Tipos documento";
        rstND: Record "Purch. Inv. Header";
        rstCC: Record "Vendor Ledger Entry";
        rstCCL: Record "Vendor Ledger Entry";
        rstCI: Record "Company Information";
        rstLFC: Record "Purch. Inv. Line";
        rstLNC: Record "Purch. Cr. Memo Line";
        rstFC: Record "Purch. Inv. Header";
        l_rstSS: Record "Sales & Receivables Setup";
        l_rstGLS: Record "General Ledger Setup";
        l_blnInterno: Boolean;
        l_rstVLE: Record "Vendor Ledger Entry";
    begin
        Clear(l_rstVLE);
        l_rstVLE.SetRange("Document No.", l_doc);
        if l_rstVLE.FindFirst then begin
            with l_rstVLE do begin

                Clear(rstNC);
                rstNC.SetRange("Applies-to Doc. No.", "Document No.");
                if rstNC.FindFirst then begin
                    Clear(rstMens);
                    rstMens.SetRange("No. documento", rstNC."No.");
                    if rstMens.FindFirst then begin
                        Clear(l_rst50519);
                        l_rst50519.SetRange("Tipos documento", rstMens."Tipo Documento");
                        l_rst50519.FindFirst;
                        l_blnInterno := l_rst50519."Documento interno";
                    end;
                end;
                Clear(rstNC);
                rstNC.SetRange("No.", l_doc);
                if rstNC.FindFirst then begin
                    Clear(rstMens);
                    rstMens.SetRange("No. documento", rstNC."No.");
                    if rstMens.FindFirst then begin
                        Clear(l_rst50519);
                        l_rst50519.SetRange("Tipos documento", rstMens."Tipo Documento");
                        l_rst50519.FindFirst;
                        l_blnInterno := l_rst50519."Documento interno";
                    end;
                end;
                Clear(rstNC);
                rstNC.SetRange("Corrected Invoice No.", "Document No.");
                if rstNC.FindFirst then begin
                    Clear(rstMens);
                    rstMens.SetRange("No. documento", rstNC."No.");
                    if rstMens.FindFirst then begin
                        Clear(l_rst50519);
                        l_rst50519.SetRange("Tipos documento", rstMens."Tipo Documento");
                        l_rst50519.FindFirst;
                        l_blnInterno := l_rst50519."Documento interno";
                    end;
                end;
                Clear(rstCCL);
                rstCCL.SetRange("Entry No.", "Closed by Entry No.");
                if rstCCL.FindFirst then begin
                    Clear(rstMens);
                    rstMens.SetRange("No. documento", rstCCL."Document No.");
                    if rstMens.FindFirst then begin
                        Clear(l_rst50519);
                        l_rst50519.SetRange("Tipos documento", rstMens."Tipo Documento");
                        l_rst50519.FindFirst;
                        l_blnInterno := l_rst50519."Documento interno";
                    end;
                end;
                Clear(rstCCL);
                rstCCL.SetRange("Closed by Entry No.", "Entry No.");
                if rstCCL.FindFirst then begin
                    Clear(rstMens);
                    rstMens.SetRange("No. documento", rstCCL."Document No.");
                    if rstMens.FindFirst then begin
                        Clear(l_rst50519);
                        l_rst50519.SetRange("Tipos documento", rstMens."Tipo Documento");
                        l_rst50519.FindFirst;
                        l_blnInterno := l_rst50519."Documento interno";
                    end;
                end;
                Clear(rstMens);
                rstMens.SetRange("No. documento", "Document No.");
                if rstMens.FindFirst then begin
                    Clear(l_rst50519);
                    l_rst50519.SetRange("Tipos documento", rstMens."Tipo Documento");
                    l_rst50519.FindFirst;
                    l_blnInterno := l_rst50519."Documento interno";
                end;
            end;
        end;
    end;
}

