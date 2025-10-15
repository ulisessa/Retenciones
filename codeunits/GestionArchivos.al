codeunit 50043 GestionArchivos
{
    trigger OnRun()
    begin

    end;

    var
        PathHelper: DotNet Path;
        ServerDirectoryHelper: DotNet Directory;
        ServerFileHelper: DotNet File;
        FileDoesNotExistErr: Label 'The file %1 does not exist.', Comment = '%1 File Path';
        ZipArchive: DotNet ZipArchive;
        ZipArchiveMode: DotNet ZipArchiveMode;
        optEncoding: Option " ",UTF8,UTF16,Windows;
        NotAllowedPathErr: Label 'Files outside of the current user''s folder cannot be accessed. Access is denied to file %1.', Comment = '%1=the full path to a file. ex: C:\Windows\TextFile.txt ';

    procedure CombinePath(BasePath: Text; Suffix: Text): Text
    begin
        exit(PathHelper.Combine(BasePath, Suffix));
    end;

    procedure ExtractZipFile(ZipFilePath: Text; DestinationFolder: Text)
    var
        Zip: DotNet ZipFileExtensions;
        ZipFile: DotNet ZipFile;
    begin
        IsAllowedPath(ZipFilePath, false);

        if not ServerFileHelper.Exists(ZipFilePath) then
            Error(FileDoesNotExistErr, ZipFilePath);

        // Create directory if it doesn't exist
        ServerCreateDirectory(DestinationFolder);

        ZipArchive := ZipFile.Open(ZipFilePath, ZipArchiveMode.Read);
        Zip.ExtractToDirectory(ZipArchive, DestinationFolder);
        CloseZipArchive;
    end;

    procedure CloseZipArchive()
    begin
        if not IsNull(ZipArchive) then
            ZipArchive.Dispose;
    end;

    procedure ServerTempFileName(FileExtension: Text) FileName: Text
    var
        TempFile: File;
    begin
        TempFile.CreateTempFile;
        FileName := CreateFileNameWithExtension(TempFile.Name, FileExtension);
        TempFile.Close;
    end;

    local procedure CreateFileNameWithExtension(FileNameWithoutExtension: Text; Extension: Text) FileName: Text
    begin
        FileName := FileNameWithoutExtension;
        if Extension <> '' then begin
            if Extension[1] <> '.' then
                FileName := FileName + '.';
            FileName := FileName + Extension;
        end
    end;

    procedure GetDirectoryName(FileName: Text): Text
    begin
        if FileName = '' then
            exit(FileName);

        FileName := DelChr(FileName, '<');
        exit(PathHelper.GetDirectoryName(FileName));
    end;

    procedure ServerCreateTempSubDirectory() DirectoryPath: Text
    var
        ServerTempFile: Text;
    begin
        ServerTempFile := ServerTempFileName('tmp');
        DirectoryPath := CombinePath(GetDirectoryName(ServerTempFile), Format(CreateGuid));
        ServerCreateDirectory(DirectoryPath);
        DeleteServerFile(ServerTempFile);
    end;

    procedure ServerDirectoryExists(DirectoryPath: Text): Boolean
    begin
        exit(ServerDirectoryHelper.Exists(DirectoryPath));
    end;

    procedure DeleteServerFile(FilePath: Text): Boolean
    begin
        IsAllowedPath(FilePath, false);
        if not Exists(FilePath) then
            exit(false);

        ServerFileHelper.Delete(FilePath);
        exit(true);
    end;

    procedure ServerCreateDirectory(DirectoryPath: Text)
    begin
        if not ServerDirectoryExists(DirectoryPath) then
            ServerDirectoryHelper.CreateDirectory(DirectoryPath);
    end;

    procedure IsAllowedPath(Path: Text; SkipError: Boolean): Boolean
    var
        MembershipEntitlement: Record "Membership Entitlement";
        WebRequestHelper: Codeunit "Web Request Helper";
    begin
        if not MembershipEntitlement.IsEmpty then
            if not WebRequestHelper.IsHttpUrl(Path) then begin
                ClearLastError;
                if not FILE.IsPathTemporary(Path) then begin
                    if SkipError then
                        exit(false);
                    Error(NotAllowedPathErr, Path);
                end;
            end;
        exit(true);
    end;

    [Scope('OnPrem')]
    procedure DownloadFromURL(p_URL: Text; p_Extension: Text): Text
    var
        l_HttpWebRequest: DotNet HttpWebRequest;
        l_WebRequestHelper: Codeunit "Web Request Helper";
        l_HttpWebResponse: DotNet HttpWebResponse;
        l_ResponseInStream: InStream;
        l_HttpStatusCode: DotNet HttpStatusCode;
        l_ResponseHeaders: DotNet NameValueCollection;
        l_TempBlob: Codeunit "Temp Blob";
        l_FileMgt: Codeunit "File Management";
        l_strFileName: Text;
        l_Folder: Text;
        l_NameValueBuffer: Record "Name/Value Buffer";
    begin
        l_HttpWebRequest := l_HttpWebRequest.Create(p_URL);
        l_HttpWebRequest.Method := 'GET';
        l_HttpWebRequest.KeepAlive := true;
        l_HttpWebRequest.AllowAutoRedirect := true;
        l_HttpWebRequest.UseDefaultCredentials := true;
        l_HttpWebRequest.Timeout := 60000;

        //l_TempBlob.Init;
        l_TempBlob.CreateInStream(l_ResponseInStream);
        l_WebRequestHelper.GetWebResponse(l_HttpWebRequest, l_HttpWebResponse, l_ResponseInStream, l_HttpStatusCode, l_ResponseHeaders, GuiAllowed);
        //l_TempBlob.Insert;
        //l_TempBlob.CalcFields(Blob);

        l_strFileName := l_FileMgt.ServerTempFileName(p_Extension);
        case CopyStr(l_strFileName, StrLen(l_strFileName) - 2, StrLen(l_strFileName)) of
            'zip':
                begin

                    l_FileMgt.BLOBExportToServerFile(l_TempBlob, l_strFileName);
                    l_Folder := ServerCreateTempSubDirectory;
                    ExtractZipFile(l_strFileName, l_Folder);
                    l_FileMgt.GetServerDirectoryFilesList(l_NameValueBuffer, l_Folder);
                    if l_NameValueBuffer.FindFirst then
                        exit(l_NameValueBuffer.Name);

                end;

            'txt', 'csv':
                begin

                    l_FileMgt.BLOBExportToServerFile(l_TempBlob, l_strFileName);
                    exit(l_strFileName);

                end;

        end;
        exit('Extensión no soportada.');
    end;

    procedure fntAnularDocumentoDigital(strLineaDigitalizacion: Text[30]): Boolean
    var
        rstDocumentosDigitalizados: Record "Documentos digitalizados";
        strArchivoDigital: Text[250];
        intLineaDigitalizacion: Integer;
    begin

        Evaluate(intLineaDigitalizacion, strLineaDigitalizacion);

        Clear(rstDocumentosDigitalizados);
        rstDocumentosDigitalizados.SetRange(rstDocumentosDigitalizados.Linea, intLineaDigitalizacion);
        if rstDocumentosDigitalizados.Find('-') then begin

            if Exists(rstDocumentosDigitalizados.Archivo) then
                Erase(rstDocumentosDigitalizados.Archivo);
            rstDocumentosDigitalizados.Delete;
            exit(true);

        end;

        exit(false);
    end;

    procedure DownloadFile(strNombre: Text)
    var
        IStream: InStream;
        ExportFileName: Text;
        rstTB: Codeunit "Temp Blob";
    begin
        ExportFileName := strNombre;
        IStream.ReadText(ExportFileName);
        DownloadFromStream(IStream, 'Download', '', '', ExportFileName);
    end;

    [Scope('OnPrem')]
    procedure AssingEncoding(l_optEncoding: Option UTF8,UTF16,Windows)
    begin
        optEncoding := l_optEncoding;
    end;
}
