codeunit 80102 "AIR Azure FaceAPI Mgt."
{
    procedure SendPictureToAzureAndGetFaceId(var FaceId: Text; var TempPicture: Record "AIR Temp Picture" temporary)
    var
        RequestMessage: HttpRequestMessage;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
        HttpClient: HttpClient;
        ResponseMessage: HttpResponseMessage;
        ResponseTxt: Text;

        PictureInTextFormat: Text;
        TenantMedia: Record "Tenant Media";
        InStream: InStream;
    begin

        TenantMedia.get(TempPicture.Picture.MediaId);
        TenantMedia.CalcFields(Content);
        TenantMedia.Content.CreateInStream(InStream);

        HttpContent.WriteFrom(InStream);
        HttpContent.ReadAs(PictureInTextFormat);

        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-type', 'application/octet-stream');
        ContentHeaders.Add('Ocp-Apim-Subscription-Key', GetKey());
        RequestMessage.Content(HttpContent);

        RequestMessage.SetRequestUri(GetUriForFaceIdDetectService());
        RequestMessage.Method := 'POST';

        HttpClient.Send(RequestMessage, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode then
            error('The web service returned an error message:\\' +
                  'Status code: %1\' +
                  'Description: %2',
                  ResponseMessage.HttpStatusCode,
                  ResponseMessage.ReasonPhrase);

        HttpContent := ResponseMessage.Content;
        GetFaceIdFromJSon(HttpContent, FaceId);
    end;

    local procedure GetFaceIdFromJSon(var HttpContent: HttpContent; var FaceId: Text)
    var
        ContentInTextFormat: Text;
        JsonArray: JsonArray;
        JSonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        HttpContent.ReadAs(ContentInTextFormat);

        If not JsonArray.ReadFrom(ContentInTextFormat) then
            error('Invalid response, expected an JSON array as root object');

        JsonArray.Get(0, JsonToken);
        JsonObject := JsonToken.AsObject;
        FaceId := GetJsonValueAsText(JSonObject, 'faceId');
    end;

    procedure GetJsonValueAsText(var JsonObject: JsonObject; Property: text) Value: Text;
    var
        JsonValue: JsonValue;
    begin
        if not GetJsonValue(JsonObject, Property, JsonValue) then
            exit;
        Value := JsonValue.AsText;
    end;

    local procedure GetJsonValue(var JsonObject: JsonObject; Property: text; var JsonValue: JsonValue): Boolean;
    var
        JsonToken: JsonToken;
    begin
        if not JsonObject.Get(Property, JsonToken) then
            exit;
        JsonValue := JsonToken.AsValue;
        Exit(true);
    end;

    local procedure GetUriForFaceIdDetectService(): Text
    begin
        exit(StrSubstNo('%1/%2', GetBaseFaceIdUri(), GetFaceDetectUri()));
    end;

    local procedure GetUriForFaceVerifyService(): Text
    begin
        exit(StrSubstNo('%1/%2', GetBaseFaceIdUri(), GetFaceVerifyUri()));
    end;


    local procedure GetBaseFaceIdUri(): Text
    begin
        exit('https://mscognitivefaceapi.cognitiveservices.azure.com')
    end;

    local procedure GetFaceDetectUri(): Text
    begin
        exit('face/v1.0/detect?returnFaceId=true');
    end;

    local procedure GetFaceVerifyUri(): Text
    begin
        exit('face/v1.0/verify')
    end;

    local procedure GetKey(): Text
    begin
        exit('ba9d5b3bba1e4d5493b6b447e873d0c1')
    end;



}