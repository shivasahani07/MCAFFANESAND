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
            testemail(url);
            
            
         /*   HttpRequest req = new HttpRequest();
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
            }*/
        }
            
        return result;
    }
    public static void testemail(String url)
    {                
        List<Map<String,String>> dataMap= new List<Map<String,String>>();
        Map<String,Order> mapOrder= new Map<String,Order>(); 
        Map<String,List<OrderItem>> orderwithOredrItem=new Map<String,List<OrderItem>>();
        //List<OrderItem> orderItemList= new List<OrderItem>();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://unicommerce-export.s3.amazonaws.com/pep/650c0700fe4c2e3c31faf2f5/Export-Sale%20Orders-pep_21092023143400.csv');
        //req.setEndpoint(url);
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
            
            // for(i=19;i<30;i++)
            //{
            //system.debug('Row ----------> '+i);
            list<String> csvColum=allRows[0].split(',');
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
                Map<String,String> mapObject= new Map<String,String>();
                
                for(Integer i=0;i<eachRow.size()-1;i++){
                    mapObject.put(csvColum[i],eachRow[i]);
                }
                
                dataMap.add(mapObject);
                
                
              
              }
            
            for(Map<String,String> mapObject:dataMap){
                
                if(!mapOrder.containsKey(mapObject.get('Display Order Code')))
                {
                    mapOrder.put(mapObject.get('Display Order Code'),getOrder(mapObject));
                    OrderItem orderItemObject=new OrderItem();
                    //orderItemObject.OrderId=od.id;
                    orderItemObject.Quantity=1;
                    orderItemObject.UnitPrice=decimal.valueof(mapObject.get('Total Price'));
                    List<OrderItem> orderItemList= new List<OrderItem>();
                    orderItemList.add(orderItemObject);
                    orderwithOredrItem.put(mapObject.get('Display Order Code'),orderItemList);

                    
                }else{
                    Order od=mapOrder.get(mapObject.get('Display Order Code'));
                    OrderItem orderItemObject=new OrderItem();
                    //orderItemObject.OrderId=od.id;
                    orderItemObject.Quantity=1;
                    orderItemObject.UnitPrice=decimal.valueof(mapObject.get('Total Price'));
                    if(orderwithOredrItem.containskey(mapObject.get('Display Order Code')))
                    {
                        orderwithOredrItem.get(mapObject.get('Display Order Code')).add(orderItemObject);
                    }
                    else
                    {
                        List<OrderItem> orderItemList= new List<OrderItem>();
                        orderItemList.add(orderItemObject);
                        orderwithOredrItem.put(mapObject.get('Display Order Code'),orderItemList);
                    }
                    //orderItemList.add(orderItemObject);
                    
                }
            
                
            }
            
            
         system.debug('Data json -->'+JSON.serialize(dataMap.get(0)));

            if(mapOrder.values().size()>0)
            {
                insert mapOrder.values();
            }
            
           List<Order> tempListOrder= [select id,Display_Code__c from Order where Display_Code__c in :orderwithOredrItem.keyset()];   
            List<OrderItem> insertOrderLine=new List<OrderItem>();
            Map<String,String> displayOrderId=new Map<String,String>();
            for(Order tempOrderObject:tempListOrder) {
                //orderwithOredrItem.get(tempListOrder.Display_Code__c);
                displayOrderId.put(tempOrderObject.Display_Code__c,tempOrderObject.id);
            }
            
            
         if(orderwithOredrItem.size()>0)
         {
             for(String code:orderwithOredrItem.keyset())
             {
                 for(OrderItem ot:orderwithOredrItem.get(code))
                     {
                         ot.OrderId=displayOrderId.get(code);
                         insertOrderLine.add(ot);
                     }
             }
              if(insertOrderLine.size()>0)
              {
                  insert insertOrderLine;
              }
             
         }
            
        }
    }
   
    public static Order getOrder(Map<String,String> mapObject){
        
                order od=new order();
                od.EffectiveDate=system.today();
                od.AccountId='001Hn00001uVDAPIA4';
                od.Sale_Order_Item_Code__c=mapObject.get('Sale Order Item Code');
                od.Display_Code__c=mapObject.get('Display Order Code');
                od.Shipping_Method__c=mapObject.get('Shipping Method');
                od.Item_SKU_Code__c=mapObject.get('Item SKU Code');
                od.Channel_Name__c=mapObject.get('Channel Name');
                od.Total_Price__c=decimal.valueof(mapObject.get('Total Price'));
                od.Voucher_Code__c=mapObject.get('Voucher Code');
                od.Facility__c=mapObject.get('Facility');
                od.SKU_Name__c=mapObject.get('SKU Name');
                od.Shipping_Package_Code__c=mapObject.get('Shipping Package Code');
                //
                od.Status=  'Draft';
                
                od.BillingCountry=mapObject.get('Billing Address Country');
                od.BillingCity=mapObject.get('Billing Address City');
                od.BillingState=mapObject.get('Billing Address State');
                od.BillingStreet=mapObject.get('Billing Address Line 2');
                od.BillingPostalCode=mapObject.get('Billing Address Pincode');
                
                od.ShippingCountry=mapObject.get('Shipping Address Country');
                od.ShippingCity=mapObject.get('Shipping Address City');
                od.ShippingState=mapObject.get('Shipping Address State');
                od.ShippingStreet=mapObject.get('Shipping Address Line 2');
                od.ShippingPostalCode=mapObject.get('Shipping Address Pincode');        
                 return od;
		
        
    } 
    
}