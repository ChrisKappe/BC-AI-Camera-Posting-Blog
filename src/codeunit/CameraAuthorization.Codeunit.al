codeunit 80101 "AIR CameraAuthorization"
{
    procedure BreakPostingIfUserIsNotAuthorizedThroughCamera()
    var
        Handled: Boolean;
        PictureInStream: InStream;
        PictureName: Text;
    begin
        OpenCameraAndTakePicture(Handled, PictureInStream, PictureName);
        SendPictureToAzureAndVerifyUser(Handled, PictureInStream);
        BreakPostingIfNotAuthorized(Handled);
    end;

    local procedure OpenCameraAndTakePicture(var Handled: Boolean; var PictureInStream: InStream; PictureName: Text);
    var
        Camera: Codeunit Camera;
    begin
        Handled := Not Camera.GetPicture(PictureInStream, PictureName);
    end;

    local procedure SendPictureToAzureAndVerifyUser(var Handled: Boolean; var PictureInStream: InStream);
    begin
        if Handled then
            exit;


    end;

    local procedure BreakPostingIfNotAuthorized(var Handled: Boolean);
    begin
        if Handled then
            exit;


    end;


}