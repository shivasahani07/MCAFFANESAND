public class TestUniwareIntegration {
    Public Static void testIntegration()
    {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('https://peptestinstance.unicommerce.com/oauth/token');
        req.setHeader('grant_type', 'password');
       	req.setHeader('client_id', 'my-trusted-client');
        req.setHeader('username', 'prashik.lokhande@techilaservices.com');
        req.setHeader('password', 'success101');
        
        HttpResponse res = new HttpResponse();
        res = http.send(req);
        system.debug('response body------->'+res.getBody());
    }
}