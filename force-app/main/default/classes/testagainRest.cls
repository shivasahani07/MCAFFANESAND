@RestResource(urlMapping='/testURLData/*')
global class testagainRest {
    @httpPost
    global static integer doPost() 
    {
        RestRequest req = RestContext.request;
        system.debug('req------->'+req.requestBody);
        String s = EncodingUtil.base64Encode(req.requestBody);
        Blob blobContent = EncodingUtil.base64Decode(s);
        System.debug( 'Decoded Base64 value is ' + blobContent.toString() );
        return 200;
    }

}