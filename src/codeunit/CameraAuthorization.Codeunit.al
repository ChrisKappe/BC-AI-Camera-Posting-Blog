codeunit 80101 "AIR CameraAuthorization"
{
    procedure BreakPostingIfUserIsNotAuthorizedThroughCamera()
    var
        Handled: Boolean;
        PictureInStream: InStream;
        PictureName: Text;
        Verified: Boolean;
    begin
        OpenCameraAndTakePicture(Handled, PictureInStream, PictureName);
        SendPictureToAzureAndVerifyUser(Handled, Verified, PictureInStream);
        BreakPostingIfNotAuthorized(Handled, Verified);
    end;

    local procedure OpenCameraAndTakePicture(var Handled: Boolean; var PictureInStream: InStream; PictureName: Text);
    var
        Camera: Codeunit Camera;
    begin
        Handled := Not Camera.GetPicture(PictureInStream, PictureName);
    end;

    local procedure SendPictureToAzureAndVerifyUser(var Handled: Boolean; var Verified: Boolean; var CurrentPictureInStream: InStream);
    var
        OriginalPictureInStream: InStream;
        OriginalFaceId: Text;
        CurrentFaceId: Text;
    begin
        if Handled then
            exit;

        SendPictureToAzureAndGetFaceId(Handled, CurrentFaceId, CurrentPictureInStream);
        GetOriginalPicture(Handled, OriginalPictureInStream);
        SendPictureToAzureAndGetFaceId(Handled, OriginalFaceId, OriginalPictureInStream);
        VerifyIfTwoFacesBelongToOnePerson(Handled, Verified, OriginalFaceId, CurrentFaceId);
    end;

    local procedure SendPictureToAzureAndGetFaceId(var Handled: Boolean; var FaceId: Text; var PictureInStream: InStream)
    begin
        if Handled then
            exit;

    end;

    local procedure BreakPostingIfNotAuthorized(var Handled: Boolean; var Verified: Boolean);
    var
        UserIsNotVerifiedErr: Label 'User is not verified. Posting aborted.';
    begin
        if Handled then
            exit;

        if not Verified then
            Error(UserIsNotVerifiedErr);
    end;


}