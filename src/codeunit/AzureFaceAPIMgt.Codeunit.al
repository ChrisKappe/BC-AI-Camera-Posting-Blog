codeunit 80102 "AIR Azure FaceAPI Mgt."
{
    procedure SendPictureToAzureAndGetFaceId(var FaceId: Text; var PictureInStream: InStream)
    var
        RequestMessage: HttpRequestMessage;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
        HttpClient: HttpClient;
        ResponseMessage: HttpResponseMessage;
    begin
        HttpContent.WriteFrom(PictureInStream);
        //HttpContent.ReadAs(PictureInTextFormat);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-type', 'application/octet-stream');
        ContentHeaders.Add('Ocp-Apim-Subscription-Key', GetKey());
        RequestMessage.Content(HttpContent);

        RequestMessage.SetRequestUri(GetUriForFaceIdDetectService());
        RequestMessage.Method := 'POST';

        //HttpClient.DefaultRequestHeaders.Add('Ocp-Apim-Subscription-Key', GetKey());

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