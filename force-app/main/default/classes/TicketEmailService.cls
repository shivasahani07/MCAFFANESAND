global class TicketEmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        //system.debug('Body-------->'+email.htmlBody);
        //system.debug('subject-------->'+email.subject);
        String body=email.htmlBody;
        if(body.contains('Export File Path:'))
        {
            string url=body.substringBetween('Export File Path:</strong>','</td>');
            system.debug('url------->'+url);
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url.trim());
            req.setMethod('GET');
            
            // Create an HTTP client to send the request
            Http http = new Http();
            HttpResponse res = http.send(req);
            //system.debug('res body'+res.getbody());
            
            // Check if the request was successful
            if (res.getStatusCode() == 200) {
                // Parse the CSV data from the response
                String csvData = res.getBody();
                List<String> allRows=csvData.split('\n');
                system.debug(allRows[0]);
                list<String> columnName=allRows[0].split(',');
                system.debug('columnName------->'+columnName.size());
                system.debug('columnName------->'+columnName[0]);
                system.debug('columnName------->'+columnName[1]);
                
            }
            
            
            
        }
        return result;
    }
}