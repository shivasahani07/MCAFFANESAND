global class TicketEmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String body=email.htmlBody;
        if(body.contains('Export File Path:'))
        {
            string url=body.substringBetween('Export File Path:</strong>','</td>');
            system.debug('url------->'+url);
            testemail(url);           
        }
        
        return result;
    }
    public static void testemail(String url)
    {                
        List<Map<String,String>> dataMap= new List<Map<String,String>>();
        Map<String,Order> mapOrder= new Map<String,Order>(); 
        Map<String,List<OrderItem>> orderwithOredrItem=new Map<String,List<OrderItem>>();
        Map<String,List<Shipment__c>> shipmentItem=new Map<String,List<Shipment__c>>();
        //List<OrderItem> orderItemList= new List<OrderItem>();
        HttpRequest req = new HttpRequest();
        //req.setEndpoint('https://unicommerce-export.s3.amazonaws.com/pep/653a472b1017ca3549fa0b57/Export-Sale%20Orders-pep_26102023163203.csv');
        //start added for testing
        //req.setEndpoint('https://unicommerce-export.s3.amazonaws.com/pep/655eebbf369f01303ccc090c/Export-Sale%20Orders-pep_23112023113551.csv');
        //req.setEndpoint('https://unicommerce-export.s3.amazonaws.com/pep/6565b462faa27d0b9062b9cf/Export-Sale%20Orders-pep_28112023150530.csv');
        //req.setEndpoint('https://unicommerce-export.s3.amazonaws.com/pep/656875a7faa27d0b9064fdc8/Export-Sale%20Orders-pep_30112023171441.csv');
        //end added for testing
        req.setEndpoint(url);
        req.setMethod('GET');
        List<Order> orderList=new List<Order>();
        // Create an HTTP client to send the request
        Http http = new Http();
        HttpResponse res = http.send(req);
        //system.debug('res body'+res.getbody());
        
        // Check if the request was successful
        if (res.getStatusCode() == 200) {
            
            String csvData = res.getBody();
            //system.debug('csvData===>'+csvData);
            //system.debug('length===>'+csvData.length());
            //Blob fileBlob = Blob.valueOf(res.getBody());
            TicketEmailServiceIterator r = New TicketEmailServiceIterator(csvData,'\n');
            String firstRow;
            List<String> allRows = new List<String>();
            while(r.hasNext()){
                firstRow = r.next();
                system.debug('firstRow==>'+firstRow);
                allRows.add(firstRow);
            }
            // system.debug('allRows==>'+allRows);   
            
            //List<String> allRows=csvData.split('\n');
            //List<String> allRows=fileBlob.toString().split('\n');
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
            List<PricebookEntry> updatePricebookEntryList=new List<PricebookEntry>();
            List<String> listofDisplayCode=new List<String>();
            
            
            for(Product2 podObj:[select id,ProductCode,name,(select id,UnitPrice from PricebookEntries) from Product2]){
                productMap.put(podObj.ProductCode,podObj);
            }
            Map<String,productWrapper> productmapCSV=new Map<String,productWrapper>();
            for(Map<String,String> mapObject:dataMap){
                
                if(mapObject.get('Display Order Code')!=Null)
                {
                    listofDisplayCode.add(mapObject.get('Display Order Code'));
                }
                if(!productMap.containskey(mapObject.get('Item SKU Code')) && !productmapCSV.containskey(mapObject.get('Item SKU Code')) && !string.isBlank(mapObject.get('Item SKU Code')))
                {
                    productWrapper prodwrp=new productWrapper();
                    prodwrp.name=mapObject.get('SKU Name');
                    prodwrp.MRP=mapObject.get('MRP');
                    prodwrp.channelName=mapObject.get('Channel Name');
                    productmapCSV.put(mapObject.get('Item SKU Code'),prodwrp);
                }
                else if(productMap.containskey(mapObject.get('Item SKU Code')) && productMap.get(mapObject.get('Item SKU Code')).name!=mapObject.get('SKU Name'))
                {
                    Product2 prod2Obj=new Product2();
                    prod2Obj.id=productMap.get(mapObject.get('Item SKU Code')).id;
                    prod2Obj.Name=mapObject.get('SKU Name');
                    prod2Obj.Channel_Name__c=mapObject.get('Channel Name');
                    productUpdate.add(prod2Obj);
                }
               /* if(productMap.containskey(mapObject.get('Item SKU Code')) && productMap.get(mapObject.get('Item SKU Code')).PricebookEntries[0].UnitPrice!=decimal.valueof(mapObject.get('MRP')))
                {
                    //PricebookEntry pb=new 
                }
			*/
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
                    prodObj.Channel_Name__c=productmapCSV.get(productcode).channelName;
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
                        priceBk.Pricebook2Id=System.Label.uniware_pricebook_id;
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
            
            Map<string,string> orderIdandDisplayCode=new Map<string,string>();
            for(Order odObj:[select id,Display_Code__c from order where Display_Code__c IN: listofDisplayCode])
            {
                orderIdandDisplayCode.put(odObj.Display_Code__c,odObj.Id);
            }
            /*get existing shipment records to update*/
            Map<String,Shipment__c> shippingMap=new Map<String,Shipment__c>();
            Set<String> shipPackCodeSet = new Set<String>();
            for(Shipment__c shipObj:[SELECT Id, Name, Order__c, Uniware_Order_Id__c, Shipping_provider__c, Shipping_Courier__c, Shipping_Package_Creation_Date__c, Tracking_Number__c, Shipping_Package_Status_Code__c, Dispatch_Date__c, Facility__c, Created_Uniware__c, Shipping_Courier_Status__c, Shipping_Tracking_Status__c, Batch_Date_Of_Expiry__c, Shipping_Package_Code__c FROM Shipment__c]){
                shippingMap.put(shipObj.Shipping_Package_Code__c,shipObj);
            }
            
            for(Map<String,String> mapObject:dataMap){
                
                if(!mapOrder.containsKey(mapObject.get('Display Order Code')) )
                {
                    system.debug('has record id'+orderIdandDisplayCode.containskey(mapObject.get('Display Order Code')));
                    if(orderIdandDisplayCode.containskey(mapObject.get('Display Order Code')))
                    {
                        Order odObj1=getOrder(mapObject);
                        odObj1.id=orderIdandDisplayCode.get(mapObject.get('Display Order Code'));
                        mapOrder.put(mapObject.get('Display Order Code'),odObj1);
                    }
                    else
                    {
                        mapOrder.put(mapObject.get('Display Order Code'),getOrder(mapObject));
                    }
                    //
                    OrderItem orderItemObject=new OrderItem();
                    //orderItemObject.OrderId=od.id;
                    orderItemObject.Quantity=1;
                    orderItemObject.UnitPrice=decimal.valueof(mapObject.get('Total Price'));
                    orderItemObject.Sale_Order_Item_Code__c=mapObject.get('Sale Order Item Code');
                    orderItemObject.PricebookEntryId=mapProductEntry.get(mapObject.get('Item SKU Code')).priceBookEntryId;
                    orderItemObject.Product2Id=mapProductEntry.get(mapObject.get('Item SKU Code')).productId;
                    List<OrderItem> orderItemList= new List<OrderItem>();
                    orderItemList.add(orderItemObject);
                    orderwithOredrItem.put(mapObject.get('Display Order Code'),orderItemList);
                   //shipment records insert update
                    List<Shipment__c> shipmentItemList= new List<Shipment__c>();                    
                    if(!shippingMap.containskey(mapObject.get('Shipping Package Code'))){
                       //shippingMap.get(mapObject.get('Shipping Package Code'))
                        Shipment__c shipmentItemObject = new Shipment__c();
                        shipmentItemObject.Shipping_Package_Code__c = mapObject.get('Shipping Package Code');
                        shipmentItemObject.Shipping_provider__c = mapObject.get('Shipping provider');
                        shipmentItemObject.Shipping_Courier__c = mapObject.get('Shipping Courier');                        
                        shipmentItemObject.Shipping_Package_Status_Code__c = mapObject.get('Shipping Package Status Code');
                       // shipmentItemObject.Tracking_Number__c = decimal.valueof(mapObject.get('Tracking Number'));                        
                        shipmentItemObject.Facility__c = mapObject.get('Facility');                        
                        shipmentItemObject.Shipping_Courier_Status__c = mapObject.get('Shipping Courier Status');
                        shipmentItemObject.Shipping_Tracking_Status__c = mapObject.get('Shipping Tracking Status');
                       /* shipmentItemObject.Shipping_Package_Creation_Date__c = datetime.valueof(mapObject.get(''));
                        shipmentItemObject.Dispatch_Date__c = datetime.valueof(mapObject.get(''));
                        shipmentItemObject.Created_Uniware__c = datetime.valueof(mapObject.get(''));
                        shipmentItemObject.Batch_Date_Of_Expiry__c = date.valueof(mapObject.get(''));*/
                        shipPackCodeSet.add(mapObject.get('Shipping Package Code'));
                        shipmentItemList.add(shipmentItemObject);
                        shipmentItem.put(mapObject.get('Display Order Code'),shipmentItemList);
                    }else{
                        Shipment__c shipmentItemObject = new Shipment__c();
                        shipmentItemObject.id = shippingMap.get(mapObject.get('Shipping Package Code')).id;
                        shipmentItemObject.Shipping_Package_Code__c = mapObject.get('Shipping Package Code');
                        shipmentItemObject.Shipping_provider__c = mapObject.get('Shipping provider');
                        shipmentItemObject.Shipping_Courier__c = mapObject.get('Shipping Courier');                        
                        shipmentItemObject.Shipping_Package_Status_Code__c = mapObject.get('Shipping Package Status Code');
                        //shipmentItemObject.Tracking_Number__c = decimal.valueof(mapObject.get('Tracking Number'));                        
                        shipmentItemObject.Facility__c = mapObject.get('Facility');                        
                        shipmentItemObject.Shipping_Courier_Status__c = mapObject.get('Shipping Courier Status');
                        shipmentItemObject.Shipping_Tracking_Status__c = mapObject.get('Shipping Tracking Status');
                       /* shipmentItemObject.Shipping_Package_Creation_Date__c = datetime.valueof(mapObject.get(''));
                        shipmentItemObject.Dispatch_Date__c = datetime.valueof(mapObject.get(''));
                        shipmentItemObject.Created_Uniware__c = datetime.valueof(mapObject.get(''));
                        shipmentItemObject.Batch_Date_Of_Expiry__c = date.valueof(mapObject.get(''));*/
                        shipPackCodeSet.add(mapObject.get('Shipping Package Code'));
                        shipmentItemList.add(shipmentItemObject);
                        shipmentItem.put(mapObject.get('Display Order Code'),shipmentItemList);
                    }
                    
                }else{
                    Order od=mapOrder.get(mapObject.get('Display Order Code'));
                    OrderItem orderItemObject=new OrderItem();
                    //orderItemObject.OrderId=od.id;
                    orderItemObject.Quantity=1;
                    orderItemObject.PricebookEntryId=mapProductEntry.get(mapObject.get('Item SKU Code')).priceBookEntryId;
                    orderItemObject.Product2Id=mapProductEntry.get(mapObject.get('Item SKU Code')).productId;
                    orderItemObject.UnitPrice=decimal.valueof(mapObject.get('Total Price'));
                    orderItemObject.Sale_Order_Item_Code__c=mapObject.get('Sale Order Item Code');
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
                    List<Shipment__c> shipmentItemList= new List<Shipment__c>();
                    if(!shippingMap.containskey(mapObject.get('Shipping Package Code'))){
                       //shippingMap.get(mapObject.get('Shipping Package Code'))
                        Shipment__c shipmentItemObject = new Shipment__c();
                        shipmentItemObject.Shipping_Package_Code__c = mapObject.get('Shipping Package Code');
                        shipmentItemObject.Shipping_provider__c = mapObject.get('Shipping provider');
                        shipmentItemObject.Shipping_Courier__c = mapObject.get('Shipping Courier');                        
                        shipmentItemObject.Shipping_Package_Status_Code__c = mapObject.get('Shipping Package Status Code');
                        //shipmentItemObject.Tracking_Number__c = decimal.valueof(mapObject.get('Tracking Number'));                        
                        shipmentItemObject.Facility__c = mapObject.get('Facility');                        
                        shipmentItemObject.Shipping_Courier_Status__c = mapObject.get('Shipping Courier Status');
                        shipmentItemObject.Shipping_Tracking_Status__c = mapObject.get('Shipping Tracking Status');
                       /* shipmentItemObject.Shipping_Package_Creation_Date__c = datetime.valueof(mapObject.get(''));
                        shipmentItemObject.Dispatch_Date__c = datetime.valueof(mapObject.get(''));
                        shipmentItemObject.Created_Uniware__c = datetime.valueof(mapObject.get(''));
                        shipmentItemObject.Batch_Date_Of_Expiry__c = date.valueof(mapObject.get(''));*/
                        shipPackCodeSet.add(mapObject.get('Shipping Package Code'));
                        if(shipmentItem.containskey(mapObject.get('Display Order Code')) && !shipPackCodeSet.contains(mapObject.get('Shipping Package Code'))){
                            shipmentItem.get(mapObject.get('Display Order Code')).add(shipmentItemObject);
                        }else{
                            List<Shipment__c> shippItemList= new List<Shipment__c>();
                            shippItemList.add(shipmentItemObject);
                            shipmentItem.put(mapObject.get('Display Order Code'),shippItemList);
                        }
                        //shipmentItemList.add(shipmentItemObject);
                        //shipmentItem.put(mapObject.get('Display Order Code'),shipmentItemList);
                    }else{
                        Shipment__c shipmentItemObject = new Shipment__c();
                        shipmentItemObject.id = shippingMap.get(mapObject.get('Shipping Package Code')).id;
                        shipmentItemObject.Shipping_Package_Code__c = mapObject.get('Shipping Package Code');
                        shipmentItemObject.Shipping_provider__c = mapObject.get('Shipping provider');
                        shipmentItemObject.Shipping_Courier__c = mapObject.get('Shipping Courier');                        
                        shipmentItemObject.Shipping_Package_Status_Code__c = mapObject.get('Shipping Package Status Code');
                        //shipmentItemObject.Tracking_Number__c = decimal.valueof(mapObject.get('Tracking Number'));                        
                        shipmentItemObject.Facility__c = mapObject.get('Facility');                        
                        shipmentItemObject.Shipping_Courier_Status__c = mapObject.get('Shipping Courier Status');
                        shipmentItemObject.Shipping_Tracking_Status__c = mapObject.get('Shipping Tracking Status');
                       /* shipmentItemObject.Shipping_Package_Creation_Date__c = datetime.valueof(mapObject.get(''));
                        shipmentItemObject.Dispatch_Date__c = datetime.valueof(mapObject.get(''));
                        shipmentItemObject.Created_Uniware__c = datetime.valueof(mapObject.get(''));
                        shipmentItemObject.Batch_Date_Of_Expiry__c = date.valueof(mapObject.get(''));*/
                        shipPackCodeSet.add(mapObject.get('Shipping Package Code'));
                        if(shipmentItem.containskey(mapObject.get('Display Order Code')) && !shipPackCodeSet.contains(mapObject.get('Shipping Package Code'))){
                            shipmentItem.get(mapObject.get('Display Order Code')).add(shipmentItemObject);
                        }else{
                            List<Shipment__c> shippItemList= new List<Shipment__c>();
                            shippItemList.add(shipmentItemObject);
                            shipmentItem.put(mapObject.get('Display Order Code'),shippItemList);
                        }
                        //shipmentItemList.add(shipmentItemObject);
                        //shipmentItem.put(mapObject.get('Display Order Code'),shipmentItemList);
                    }
                    
                }
            }
            
            
            system.debug('Data json -->'+JSON.serialize(dataMap.get(0)));
            
            
            if(mapOrder.values().size()>0)
            {
                upsert mapOrder.values();
                //system.debug('mapOrder------------>'+JSON.serializepretty(mapOrder));
                
            }
            
            List<Order> tempListOrder= [select id,Display_Code__c,Pricebook2Id from Order where Display_Code__c in :orderwithOredrItem.keyset()];   
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
                        //system.debug('Pricebook2Id------------>'+displayOrderId.get(code));
                        insertOrderLine.add(ot);
                    }
                }
                if(insertOrderLine.size()>0)
                {
                    //system.debug('insertOrderLine------------>'+JSON.serializepretty(insertOrderLine));
                    //insert insertOrderLine;
                    upsert insertOrderLine Sale_Order_Item_Code__c;
                }
                
            }
            
            /*add order id to shipment and upsert shipment records*/
            List<Shipment__c> upsrtShipmentItem = new List<Shipment__c>();
            if(shipmentItem.size()>0){
                for(String code:shipmentItem.keyset()){
                    for(Shipment__c sp:shipmentItem.get(code)){
                        sp.Order__c=displayOrderId.get(code);
                        //system.debug('Pricebook2Id------------>'+displayOrderId.get(code));
                        upsrtShipmentItem.add(sp);
                    }
                }
                if(upsrtShipmentItem.size()>0){
                    //system.debug('insertOrderLine------------>'+JSON.serializepretty(insertOrderLine));
                    upsert upsrtShipmentItem;
                }
                
            }
            
        }
    }
    
    public static Order getOrder(Map<String,String> mapObject){
        
        order od=new order();
        od.EffectiveDate=system.today();
        od.AccountId=System.Label.uniware_account_id;
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
        od.Pricebook2Id=System.Label.uniware_pricebook_id;
        //updated missing fields later
        system.debug('reverse pickup created date==>'+mapObject.get('Reverse Pickup Created Date'));
        if(mapObject.get('Reverse Pickup Created Date')!=null && mapObject.get('Reverse Pickup Created Date')!=''){
           od.Reverse_Pickup_Created_Date__c = date.valueof(mapObject.get('Reverse Pickup Created Date')); 
        }        
        od.Reverse_Pickup_Reason__c	= mapObject.get('Reverse Pickup Reason');
        od.COD__c = decimal.valueof(mapObject.get('COD'));
        od.Shipping_Address_Id__c = decimal.valueof(mapObject.get('Shipping Address Id'));
        od.Billing_Address_Id__c = decimal.valueof(mapObject.get('Billing Address Id'));
        od.Sale_Order_Code__c = mapObject.get('Sale Order Code');
        od.Sale_Order_Status__c = mapObject.get('Sale Order Status');
        od.Sale_Order_Item_Status__c = mapObject.get('Sale Order Item Status');
        od.Cancellation_Reason__c = mapObject.get('Cancellation Reason');
        od.Order_Approval_Status__c = mapObject.get('Order Approval Status');
        od.Channel_Shipping__c = mapObject.get('Channel Shipping')!= null ? boolean.valueof(mapObject.get('Channel Shipping')) : false;
		od.Uniware_Created__c = DateTime.valueof(mapObject.get('Order Date as dd/mm/yyyy hh:MM:ss'));
        od.Shipping_provider__c = mapObject.get('Shipping provider');
        return od;
        
        
    } 
    
    public class productWrapper
    {
        Public string name;
        Public string MRP;
        Public string channelName;
    }
    
    public class PriceBookEntryProduct
    {
        Public string priceBookEntryId;
        Public string productId;
    }
    
}