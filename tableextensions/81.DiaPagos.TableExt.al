tableextension 81 "Withholdings on payments" extends "Gen. Journal Line"
{
    fields
    {
        // Add changes to table fields here
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    [Scope('OnPrem')]
    procedure GenerarLinRetencion(rstLinDiaGen: Record "Gen. Journal Line"; blnRegistrar: Boolean)
    var
        cduRegistroDiarios: Codeunit "Retenciones";
        l_rstLinDiaGen: Record "Gen. Journal Line";
    begin
        //TESTFIELD("Document Type","Document Type"::Payment);
        TestField("Document No.");
        Clear(cduRegistroDiarios);
        l_rstLinDiaGen := rstLinDiaGen;
        l_rstLinDiaGen.SetRecFilter();
        cduRegistroDiarios.Retenciones(l_rstLinDiaGen, blnRegistrar);
    end;

}