codeunit 80100 "AIR SalesPostSubscriptions"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc(PreviewMode: Boolean);
    begin
        if PreviewMode then
            exit;
        if not GuiAllowed then
            exit;

        BreakPostingIfUserIsNotAuthorizedThroughCamera();
    end;

    local procedure BreakPostingIfUserIsNotAuthorizedThroughCamera()
    var
        CameraAuthorization: Codeunit "AIR CameraAuthorization";
    begin
        CameraAuthorization.BreakPostingIfUserIsNotAuthorizedThroughCamera();
    end;


}