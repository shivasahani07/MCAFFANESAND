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
            Map<String,Product2> productMap=new Map<String,Product2>();
            List<Product2> productInsert=new List<Product2>();
            List<Product2> productUpdate=new List<Product2>();
            List<PricebookEntry> PricebookEntryList=new List<PricebookEntry>();
            for(Product2 podObj:[select id,ProductCode,name from Product2]){
                 productMap.put(podObj.ProductCode,podObj);
             }
            Map<String,productWrapper> productmapCSV=new Map<String,productWrapper>();
            for(Map<String,String> mapObject:dataMap){
                if(!productMap.containskey(mapObject.get('Item SKU Code')) && !productmapCSV.containskey(mapObject.get('Item SKU Code')) && !string.isBlank(mapObject.get('Item SKU Code')))
                {
                    productWrapper prodwrp=new productWrapper();
                    prodwrp.name=mapObject.get('SKU Name');
                    prodwrp.MRP=mapObject.get('MRP');
					productmapCSV.put(mapObject.get('Item SKU Code'),prodwrp);
                }
                else if(productMap.containskey(mapObject.get('Item SKU Code')) && productMap.get(mapObject.get('Item SKU Code')).name!=mapObject.get('SKU Name'))
                {
                    Product2 prod2Obj=new Product2();
                    prod2Obj.id=productMap.get(mapObject.get('Item SKU Code')).id;
                    prod2Obj.Name=mapObject.get('SKU Name');
                    productUpdate.add(prod2Obj);
                }
            }
            if(productUpdate.size()>0)
            {
                update productUpdate;
            }
            if(productmapCSV.size()>0)
            {
                for(String productcode:productmapCSV.keyset())
                {
                 	Product2 prodObj=new Product2();
                    prodObj.ProductCode=productcode;
                    prodObj.name=productmapCSV.get(productcode).name;
                    prodObj.IsActive=true;
                    productInsert.add(prodObj);
				}
                if(productInsert.size()>0)
                {
                    insert productInsert;
                    
                    for(Product2 prodIns:productInsert)
                    {
                        PricebookEntry priceBk=new PricebookEntry();
                        priceBk.Product2Id=prodIns.Id;
                        priceBk.Pricebook2Id='01sHn000000qqgpIAA';
                        priceBk.UnitPrice=Decimal.valueof(productmapCSV.get(prodIns.ProductCode).MRP);
                        priceBk.IsActive=true;
                        PricebookEntryList.add(priceBk);
                    }
                    
                    if(PricebookEntryList.size()>0)
                    {
                        insert PricebookEntryList;
                    }
                    
                }
            }
            Map<String,PriceBookEntryProduct> mapProductEntry=new Map<String,PriceBookEntryProduct>();
            for(Product2 prodObj:[Select id,ProductCode,(Select id from pricebookentries) from product2])
            {
                PriceBookEntryProduct pb=new PriceBookEntryProduct();
                pb.priceBookEntryId=prodObj.pricebookentries[0].id;
                pb.productId=prodObj.id;
                mapProductEntry.put(prodObj.ProductCode,pb);
            }
            
            System.debug(mapProductEntry);
           
            

           
            for(Map<String,String> mapObject:dataMap){
                
                if(!mapOrder.containsKey(mapObject.get('Display Order Code')) )
                {
                    mapOrder.put(mapObject.get('Display Order Code'),getOrder(mapObject));
                    OrderItem orderItemObject=new OrderItem();
                    //orderItemObject.OrderId=od.id;
                    orderItemObject.Quantity=1;
                    orderItemObject.UnitPrice=decimal.valueof(mapObject.get('Total Price'));
                    orderItemObject.PricebookEntryId=mapProductEntry.get(mapObject.get('Item SKU Code')).priceBookEntryId;
                    orderItemObject.Product2Id=mapProductEntry.get(mapObject.get('Item SKU Code')).productId;
                    List<OrderItem> orderItemList= new List<OrderItem>();
                    orderItemList.add(orderItemObject);
                    orderwithOredrItem.put(mapObject.get('Display Order Code'),orderItemList);

                    
                }else{
                    Order od=mapOrder.get(mapObject.get('Display Order Code'));
                    OrderItem orderItemObject=new OrderItem();
                    //orderItemObject.OrderId=od.id;
                    orderItemObject.Quantity=1;
                    orderItemObject.PricebookEntryId=mapProductEntry.get(mapObject.get('Item SKU Code')).priceBookEntryId;
                    orderItemObject.Product2Id=mapProductEntry.get(mapObject.get('Item SKU Code')).productId;
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
        		od.Pricebook2Id='01sHn000000qqgpIAA';
                return od;
		
        
    } 
    
    public class productWrapper
    {
        Public string name;
        Public string MRP;
    }
    
    public class PriceBookEntryProduct
    {
        Public string priceBookEntryId;
        Public string productId;
    }
    
}