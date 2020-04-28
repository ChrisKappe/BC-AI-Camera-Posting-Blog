pageextension 80100 "AIR PhotoInUserSetup" extends "User Setup"
{
    layout
    {
        addafter(Control1905767507)
        {
            part(UserPhoto; "AIR User Photo")
            {
                ApplicationArea = all;
                SubPageLink = "User ID" = field("User ID");
            }
        }
    }
}