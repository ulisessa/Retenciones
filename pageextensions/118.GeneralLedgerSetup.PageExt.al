pageextension 50119 "Add functions to GLS" extends "General Ledger Setup"
{
    layout
    {
        addafter("Global Dimension 2 Code")
        {
            field("Global Dimension 3 Code"; "Global Dimension 3 Code")
            {
                Caption = 'Global Dimension 3 Code';
            }
            field("Global Dimension 4 Code"; "Global Dimension 4 Code")
            {
                Caption = 'Global Dimension 4 Code';
            }
            field("Global Dimension 5 Code"; "Global Dimension 5 Code")
            {
                Caption = 'Global Dimension 5 Code';
            }
            field("Global Dimension 6 Code"; "Global Dimension 6 Code")
            {
                Caption = 'Global Dimension 6 Code';
            }
            field("Global Dimension 7 Code"; "Global Dimension 7 Code")
            {
                Caption = 'Global Dimension 7 Code';
            }
            field("Fiscal Type"; "Fiscal Type")
            {
                Caption = 'Fiscal type';
            }
        }
        addafter("Autocredit Memo Nos.")
        {
            group("Serie de retenciones")
            {
                Caption = 'Withholding serial numbers';
                field("N° serie retención IVA"; "No. serie retención IVA")
                {
                }
                field("N° serie retención Ganancias"; "No. serie retención Ganancias")
                {
                }
                field("N° serie retención SS"; "No. serie retención SS")
                {
                }
                field("N° serie retención IIBB"; "No. serie retención IIBB")
                {
                }
            }
        }
        addafter(General)
        {
            field("AFIP QR URL"; "AFIP QR URL")
            {
            }
            group(Retenciones)
            {
                Caption = 'Withholdings';
                group(Firma)
                {
                    field("Persona habilitada certificado"; "Persona habilitada certificado")
                    {
                    }
                    field("Carácter persona habilitada"; "Carácter persona habilitada")
                    {
                    }
                    field(Signatary; Signatary)
                    {
                    }
                    field(Signature; Signature)
                    {
                    }
                }
                group(Contabilización)
                {

                    field("VAT withholding account"; "VAT withholding account")
                    {
                        Caption = 'VAT withholding account';
                    }
                    field("VAT perception account"; "VAT perception account")
                    {
                        Caption = 'VAT perception account';
                    }
                    field("Winnings withholding account"; "Winnings withholding account")
                    {
                        Caption = 'Winnings withholding account';
                    }
                    field("SS withholding account"; "SS withholding account")
                    {
                        Caption = 'SS withholding account';
                    }
                    field("GI withholding account"; "GI withholding account")
                    {
                        Caption = 'GI withholding account';
                    }
                    field("GI perception account"; "GI perception account")
                    {
                        Caption = 'GI perception account';
                    }
                    field("GI perception resource"; "GI perception resource")
                    {
                        Caption = 'GI perception resource';
                    }
                    field("GI retention code"; "GI retention code")
                    {
                        Caption = 'GI withholding code';
                    }
                    field("GI no retention code"; "GI no retention code")
                    {
                        Caption = 'GI no withholding code';
                    }
                }
            }
            group("Actividades Periódicas")
            {

                field("Apochryphal listing URL"; "Apochryphal listing URL")
                {
                }
                field("Apochryphal file ext."; "Apochryphal file ext.")
                {
                }
                field("Last apochryphal update"; "Last apochryphal update")
                {
                }
                field("RG17 URL"; "RG17 URL")
                {
                }
                field("RG17 ext"; "RG17 ext")
                {
                }
                field("RG18 URL"; "RG18 URL")
                {
                }
                field("RG18 ext"; "RG18 ext")
                {
                }
                field("RG830 URL"; "RG830 URL")
                {
                }
                field("RG830 ext"; "RG830 ext")
                {
                }
            }
            group("Recupero IVA")
            {
                Caption = 'Recupero IVA';
                field("Age recovery VAT formula"; "Age recovery VAT formula")
                {
                }
                field("General VAT rate for recovery"; "General VAT rate for recovery")
                {
                }
                field("VAT recover quotient summarize"; "VAT recover quotient summarize")
                {
                }
                field("VAT recovery end date margin"; "VAT recovery end date margin")
                {
                }
                field("Omit in months with no exports"; "Omit in months with no exports")
                {
                }
                field("Recover VAT from"; "Recover VAT from")
                {
                }
                field("Recovery VAT platform"; "Recovery VAT platform")
                {
                }
                field("Filter partials from recovery"; "Filter partials from recovery")
                {
                }
                field("Filter recovery by item cat."; "Filter recovery by item cat.")
                {
                }
            }
            group("Inflation adjustment")
            {
                Caption = 'Ajuste de inflación';
                field("Inflation Adjustment T.Journal"; "Inflation Adjustment T.Journal")
                {
                }
                field("Inflation Adjustment B.Journal"; "Inflation Adjustment B.Journal")
                {
                }
                field("Inflation Adjustment Dimension"; "Inflation Adjustment Dimension")
                {
                }
                field("Inflation Adj. Account filter"; "Inflation Adj. Account filter")
                {
                }
                field("Inflation Adj. Posting Acc."; "Inflation Adj. Posting Acc.")
                {
                }
            }
            group("AFIP - WS")
            {
                Caption = 'AFIP - WS';
                field("AFIP Certificate"; "AFIP Certificate")
                {
                }
                field("AFIP Private Key"; "AFIP Private Key")
                {
                }
                field("AFIP Result Path"; "AFIP Result Path")
                {
                }
                field("Tipo Regimen"; "Tipo Regimen")
                {
                }
                field("Tipo Dato Adicional"; "Tipo Dato Adicional")
                {
                }
                field("Block codes"; "Block codes")
                {
                }
                field("WS - Dimensión code"; "WS - Dimension code")
                {
                }
                field("WS - Reproweb Dimension"; "WS - Reproweb Dimension")
                {
                }
                field("WS - Verif. Comprobante"; "WS - Verif. Comprobante")
                {
                }
                field("WS - CUIT Check Dimension"; "WS - CUIT Check Dimension")
                {
                }
                field("WS - Taxes"; "WS - Taxes")
                {
                }
                field("WS - Collection request"; "WS - Collection request")
                {
                }
            }
        }
    }
    actions
    {
        addlast(Category_Process)
        {
            group(Category_Recurrent_Activities)
            {
                //ShowAs = SplitButton;
                Caption = 'Recurrent Activities';
                actionref("Get apochryphals_Promoted"; "Get apochryphals")
                {
                }
                actionref("Get RG17_Promoted"; "Get RG17")
                {
                }
                actionref("Get RG18_Promoted"; "Get RG18")
                {
                }
                actionref("Get RG830_Promoted"; "Get RG830")
                {
                }
            }
        }
        addlast(processing)
        {
            group(Recurrent_Activities)
            {
                Caption = 'Recurrent Activities';
                action("Get apochryphals")
                {
                    Caption = 'Consultar apócrifos';
                    Image = UpdateXML;
                    trigger OnAction()
                    var
                        rstRetenciones: Page Retenciones;
                    begin
                        rstRetenciones.fntImportarApocs;
                    end;
                }
                action("Get RG17")
                {
                    Caption = 'Certificados de Exclusión Ret/Percep del IVA';
                    Image = UpdateXML;

                    trigger OnAction()
                    var
                        rstRetenciones: Page Retenciones;
                    begin
                        rstRetenciones.fntImportarIVA;
                    end;
                }
                action("Get RG18")
                {
                    Caption = 'Actualizar Agentes de Retención';
                    Image = UpdateXML;

                    trigger OnAction()
                    var
                        rstRetenciones: Page Retenciones;
                    begin
                        rstRetenciones.fntImportarAg;
                    end;
                }
                action("Get RG830")
                {
                    Caption = 'Certificados exlusión Ganancias - RG830';
                    Image = UpdateXML;

                    trigger OnAction()
                    var
                        rstRetenciones: Page Retenciones;
                    begin
                        rstRetenciones.fntImportarGan;
                    end;
                }
            }
        }

    }


}