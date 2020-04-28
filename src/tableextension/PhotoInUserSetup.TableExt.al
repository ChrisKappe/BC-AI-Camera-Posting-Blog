tableextension 80100 "AIR PhotoInUserSetup" extends "User Setup"
{
    fields
    {
        field(80000; "AIR Picture"; Media)
        {
            Caption = 'Picture';
        }
    }

    procedure ImportPicture();
    var
        PicInStream: InStream;
        FromFileName: Text;
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?', Locked = false, MaxLength = 250;
    begin
        if "User ID" = '' then
            exit;

        if UploadIntoStream('Import', '', '', FromFileName, PicInStream) then begin
            Clear("AIR Picture");
            "AIR Picture".ImportStream(PicInStream, FromFileName);
            Modify(true);
        end;
    end;

}