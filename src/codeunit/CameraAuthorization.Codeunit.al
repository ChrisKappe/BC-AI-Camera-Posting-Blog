codeunit 80101 "AIR CameraAuthorization"
{
    procedure BreakPostingIfUserIsNotAuthorizedThroughCamera()
    var
        Handled: Boolean;
        TempPicture: Record "AIR Temp Picture" temporary;
        Verified: Boolean;
    begin
        OpenCameraAndTakePicture(Handled, TempPicture);
        SendPictureToAzureAndVerifyUser(Handled, Verified, TempPicture);
        BreakPostingIfNotAuthorized(Handled, Verified);
    end;

    local procedure OpenCameraAndTakePicture(var Handled: Boolean; var TempPicture: Record "AIR Temp Picture" temporary);
    var
        //Camera: Codeunit Camera;
        Camera: Page Camera;
        CameraInteraction: Page "Camera Interaction";
        InStream: InStream;
    begin
        //Handled := Not Camera.GetPicture(PictureInStream, PictureName);
        Handled := Not Camera.IsAvailable();
        if Handled then
            exit;

        CameraInteraction.AllowEdit(true);
        CameraInteraction.Quality(100);
        CameraInteraction.EncodingType('JPEG');
        CameraInteraction.RunModal();

        CameraInteraction.GetPicture(InStream);

        TempPicture.Picture.ImportStream(InStream, '');
    end;

    local procedure SendPictureToAzureAndVerifyUser(var Handled: Boolean; var Verified: Boolean; var TempPicture: Record "AIR Temp Picture" temporary);
    var
        OriginalFaceId: Text;
        CurrentFaceId: Text;
    begin
        if Handled then
            exit;

        SendPictureToAzureAndGetFaceId(Handled, CurrentFaceId, TempPicture);
        GetOriginalPicture(Handled, TempPicture);
        SendPictureToAzureAndGetFaceId(Handled, OriginalFaceId, TempPicture);
        Error(StrSubstNo('CurrentFaceId:%1, OriginalFaceId:%2', CurrentFaceId, OriginalFaceId));
        //VerifyIfTwoFacesBelongToOnePerson(Handled, Verified, OriginalFaceId, CurrentFaceId);
    end;

    local procedure SendPictureToAzureAndGetFaceId(var Handled: Boolean; var FaceId: Text; var TempPicture: Record "AIR Temp Picture" temporary)
    var
        AzureFaceIdApiMgt: Codeunit "AIR Azure FaceAPI Mgt.";
    begin
        if Handled then
            exit;

        AzureFaceIdApiMgt.SendPictureToAzureAndGetFaceId(FaceId, TempPicture);
    end;

    local procedure GetOriginalPicture(var Handled: Boolean; var TempPicture: Record "AIR Temp Picture" temporary)
    var
        UserSetup: Record "User Setup";
        OutStream: OutStream;
        InStream: InStream;
        TempBlob: Codeunit "Temp Blob";
    begin
        if Handled then
            exit;

        if Not UserSetup.get(UserId) then
            exit;

        TempBlob.CreateOutStream(OutStream);
        UserSetup."AIR Picture".ExportStream(OutStream);
        TempBlob.CreateInStream(InStream);

        TempPicture.Picture.ImportStream(InStream, '');
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