codeunit 80101 "AIR CameraAuthorization"
{
    var
        BlobId: BigInteger;

    procedure BreakPostingIfUserIsNotAuthorizedThroughCamera()
    var
        Handled: Boolean;
        Verified: Boolean;
    begin
        OpenCameraAndTakePicture(Handled);
        SendPictureToAzureAndVerifyUser(Handled, Verified);
        BreakPostingIfNotAuthorized(Handled, Verified);
    end;

    local procedure OpenCameraAndTakePicture(var Handled: Boolean);
    var
        Camera: Codeunit Camera;
        InStream: InStream;
        PictureName: Text;
    begin
        Handled := Not Camera.GetPicture(InStream, PictureName);
        if Handled then
            exit;

        TemporarySavePicture(InStream);
    end;

    local procedure SendPictureToAzureAndVerifyUser(var Handled: Boolean; var Verified: Boolean);
    var
        OriginalFaceId: Text;
        CurrentFaceId: Text;
    begin
        if Handled then
            exit;

        SendPictureToAzureAndGetFaceId(Handled, CurrentFaceId);
        GetOriginalPicture(Handled);
        SendPictureToAzureAndGetFaceId(Handled, OriginalFaceId);
        VerifyIfTwoFacesBelongToOnePerson(Handled, Verified, OriginalFaceId, CurrentFaceId);
    end;

    local procedure SendPictureToAzureAndGetFaceId(var Handled: Boolean; var FaceId: Text)
    var
        AzureFaceIdApiMgt: Codeunit "AIR Azure FaceAPI Mgt.";
        InStream: InStream;
    begin
        if Handled then
            exit;

        AzureFaceIdApiMgt.SendPictureToAzureAndGetFaceId(FaceId, BlobId);
    end;

    local procedure VerifyIfTwoFacesBelongToOnePerson(var Handled: Boolean; var Verified: Boolean; FaceId1: Text; FaceId2: Text)
    var
        AzureFaceIdApiMgt: Codeunit "AIR Azure FaceAPI Mgt.";
    begin
        if Handled then
            exit;

        AzureFaceIdApiMgt.VerifyIfTwoFacesBelongToOnePerson(Verified, FaceId1, FaceId2);
    end;

    local procedure GetOriginalPicture(var Handled: Boolean)
    var
        UserSetup: Record "User Setup";
    begin
        if Handled then
            exit;

        if Not UserSetup.get(UserId) then
            exit;

        TemporarySavePicture(UserSetup."AIR Picture".MediaId);
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

    local procedure TemporarySavePicture(Instream: InStream);
    var
        PersistentBlob: codeunit "Persistent Blob";
    begin
        DeletePictureFromTemporaryLocation();

        BlobId := PersistentBlob.Create();
        PersistentBlob.CopyFromInStream(BlobId, InStream);
    end;

    local procedure TemporarySavePicture(MediaId: Guid);
    var
        TenantMedia: Record "Tenant Media";
        PersistentBlob: codeunit "Persistent Blob";
        InStream: InStream;
    begin
        TenantMedia.get(MediaId);
        TenantMedia.CalcFields(Content);
        TenantMedia.Content.CreateInStream(InStream);

        TemporarySavePicture(InStream);
    end;

    local procedure DeletePictureFromTemporaryLocation()
    var
        PersistentBlob: codeunit "Persistent Blob";
    begin
        if PersistentBlob.Exists(BlobId) then
            PersistentBlob.Delete(BlobId);
    end;

}