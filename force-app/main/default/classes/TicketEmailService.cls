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
            req.setEndpoint('https://unicommerce-export.s3.amazonaws.com/pep/64f849aefe511f223af073a2/Export-Sale%20Orders-pep_06092023151310.csv');//url.trim()
            req.setMethod('GET');
            
            // Create an HTTP client to send the request
            Http http = new Http();
            HttpResponse res = http.send(req);
            //system.debug('res body'+res.getbody());
            
            // Check if the request was successful
            if (res.getStatusCode() == 200) {
                // Parse the CSV data from the response
                String csvData = res.getBody();
                List<String> allRows=csvData.split('\n');// Space, new Line \n
                integer i=0;
                // for(i=19;i<30;i++)
                //{
                //system.debug('Row ----------> '+i);
                for(String s:allRows)
                {
                    if(s.contains('"'))
                    {
                        while(s.contains('"'))
                        {
                            //system.debug('yes');
                            //system.debug('start s'+s);
                            string test=s.substringBetween('"','"');
                            //system.debug('fault string'+test);
                            string removefault=test.replace(',',' - ');
                            //system.debug('removefault'+removefault);
                            s=s.replace('"'+test+'"',removefault);
                            // system.debug('final s'+s);
                        }
                        
                    }
                    list<String> eachRow=s.split(',');
                    system.debug('eachRow size---->'+eachRow[127]);
                    //system.debug('eachRow size---->'+eachRow.size());
                    eachRow.clear();
                    
                }                              
            }
        }
        return result;
    }
    public static void testemail()
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://unicommerce-export.s3.amazonaws.com/pep/64f849aefe511f223af073a2/Export-Sale%20Orders-pep_06092023151310.csv');//url.trim()
        req.setMethod('GET');
        List<Order> orderList=new List<Order>();
        // Create an HTTP client to send the request
        Http http = new Http();
        HttpResponse res = http.send(req);
        //system.debug('res body'+res.getbody());
        
        // Check if the request was successful
        if (res.getStatusCode() == 200) {
            // Parse the CSV data from the response
            String csvData = res.getBody();
            List<String> allRows=csvData.split('\n');// Space, new Line \n
            integer i=0;
            // for(i=19;i<30;i++)
            //{
            //system.debug('Row ----------> '+i);
            allRows.remove(0);
            for(String s:allRows)
            {
                if(s.contains('"'))
                {
                    while(s.contains('"'))
                    {
                        //system.debug('yes');
                        //system.debug('start s'+s);
                        string test=s.substringBetween('"','"');
                        //system.debug('fault string'+test);
                        string removefault=test.replace(',',' - ');
                        //system.debug('removefault'+removefault);
                        s=s.replace('"'+test+'"',removefault);
                        // system.debug('final s'+s);
                    }
                    
                }
                list<String> eachRow=s.split(',');
                order od=new order();
                od.EffectiveDate=system.today();
                od.AccountId='001Hn00001uVDAPIA4';
                od.Sale_Order_Item_Code__c=eachRow[0];
                //od.Display_Order_No__c=eachRow[1];
                od.Shipping_Method__c=eachRow[25];
                od.Item_SKU_Code__c=eachRow[26];
                od.Channel_Name__c=eachRow[27];
                od.Total_Price__c=decimal.valueof(eachRow[29]);
                od.Voucher_Code__c=eachRow[31];
                od.Facility__c=eachRow[43];
                od.SKU_Name__c=eachRow[49];
                od.Status='Draft';
                orderList.add(od);
                eachRow.clear();
                
            }
            if(orderList.size()>0)
            {
                insert orderList;
            }
        }
    }
}