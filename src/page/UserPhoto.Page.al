page 80100 "AIR User Photo"
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "User Setup";
    Caption = 'Photo';

    layout
    {
        area(Content)
        {
            field("AIR Picture"; "AIR Picture")
            {
                ToolTip = 'User Picture';
                ApplicationArea = all;
            }

        }
    }
    actions
    {
        area(Processing)
        {
            action(ImportPicture)
            {
                ApplicationArea = All;
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import a picture file.';

                trigger OnAction()
                begin
                    ImportPicture();
                end;
            }

        }
    }
}