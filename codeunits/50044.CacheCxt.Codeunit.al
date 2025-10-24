codeunit 50044 "Apply Ctx Cache"
{
    SingleInstance = true;

    var
        Libro: Code[10];
        Seccion: Code[10];

    procedure SetFromGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    var
        GenJnlBatch: Record "Gen. Journal Batch";
    begin
        // 1) Si “Libro/Sección” son campos en la línea:
        GetLibroSeccionFromLine(GenJnlLine, Libro, Seccion);

        // 2) Si en tu caso están en el Batch, tomalos de allí:
        if GenJnlBatch.Get(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name") then
            GetLibroSeccionFromBatch(GenJnlBatch, Libro, Seccion);
    end;

    local procedure GetLibroSeccionFromLine(var GenJnlLine: Record "Gen. Journal Line"; var Libro: Code[10]; var Seccion: Code[10])
    begin
        // TODO: reemplazar por tus campos reales si existen en la línea.
        // Ejemplo si los añadiste como campos en "Gen. Journal Line":
        Libro := GenJnlLine."Journal Template Name";
        Seccion := GenJnlLine."Journal Batch Name";
    end;

    local procedure GetLibroSeccionFromBatch(var GenJnlBatch: Record "Gen. Journal Batch"; var Libro: Code[10]; var Seccion: Code[10])
    begin
        // TODO: reemplazar por tus campos reales si existen en el batch.
        // Ejemplo si los añadiste como campos en "Gen. Journal Batch":
        Libro := GenJnlBatch."Journal Template Name";
        Seccion := GenJnlBatch.Name;
    end;

    procedure Read(var codLibro: Code[10]; var codSeccion: Code[10])
    begin
        codLibro := Libro;
        codSeccion := Seccion;
    end;

    procedure Clear()
    begin
        Libro := '';
        Seccion := '';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Apply", 'OnBeforeRun', '', false, false)]
    local procedure OnBeforeRun(var GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    var
        Ctx: Codeunit "Apply Ctx Cache";
    begin
        // Guardamos el contexto antes de que se abra la página de aplicación
        Ctx.SetFromGenJnlLine(GenJnlLine);
        // No marcamos IsHandled; dejamos que siga el flujo estándar que abrirá la page.
    end;
}
