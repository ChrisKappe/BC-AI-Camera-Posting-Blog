codeunit 80101 "AIR CameraAuthorization"
{
    procedure BreakPostingIfUserIsNotAuthorizedThroughCamera()
    var
        Handled: Boolean;
        PictureInStream: InStream;
        PictureName: Text;
        Verified: Boolean;
    begin
        //OpenCameraAndTakePicture(Handled, PictureInStream, PictureName);
        SendPictureToAzureAndVerifyUser(Handled, Verified, PictureInStream);
        BreakPostingIfNotAuthorized(Handled, Verified);
    end;

    local procedure OpenCameraAndTakePicture(var Handled: Boolean; var PictureInStream: InStream; PictureName: Text);
    var
        //Camera: Codeunit Camera;
        Camera: Page Camera;
        CameraInteraction: Page "Camera Interaction";
    begin
        //Handled := Not Camera.GetPicture(PictureInStream, PictureName);
        Handled := Not Camera.IsAvailable();
        if Handled then
            exit;

        CameraInteraction.AllowEdit(true);
        CameraInteraction.Quality(100);
        CameraInteraction.RunModal();

        CameraInteraction.GetPicture(PictureInStream);
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
        //GetOriginalPicture(Handled, OriginalPictureInStream);
        SendPictureToAzureAndGetFaceId(Handled, OriginalFaceId, OriginalPictureInStream);
        //VerifyIfTwoFacesBelongToOnePerson(Handled, Verified, OriginalFaceId, CurrentFaceId);
    end;

    local procedure SendPictureToAzureAndGetFaceId(var Handled: Boolean; var FaceId: Text; var PictureInStream: InStream)
    var
        AzureFaceIdApiMgt: Codeunit "AIR Azure FaceAPI Mgt.";
    begin
        if Handled then
            exit;

        AzureFaceIdApiMgt.SendPictureToAzureAndGetFaceId(FaceId, PictureInStream);
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