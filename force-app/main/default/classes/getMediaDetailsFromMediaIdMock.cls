@isTest
public class getMediaDetailsFromMediaIdMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        // Create a mock HTTP response with the expected JSON body
        String jsonResponse = '{"entry":[{"id":"103319499517877","time":1690800614,"changes":[{"value":{"from_c":{"id":"103319499517877","name":"Test Salesforce Integration"},"message":"Hi Test post from facebook","post_id":"103319499517877_106857975834754","created_time":1690800612,"item":"status","published":1,"verb":"add"},"field":"feed"}]}],"object":"page"}';
        
        // Create a new HTTP response
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(jsonResponse);
        response.setStatusCode(200);
        
        return response;
    }
    
}