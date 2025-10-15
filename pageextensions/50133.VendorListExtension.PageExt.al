pageextension 50133 "Vendor List Extension" extends "Vendor List"
{
    actions
    {
        addafter(Category_Category4)
        {
            group(Category4)
            {
                Caption = 'Impuestos';
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
        addafter("Ven&dor")
        {
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
                    l_rst23.Get("No.");
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

        }
    }
}