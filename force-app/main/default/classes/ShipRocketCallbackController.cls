public class ShipRocketCallbackController {
    
    public static void updateOrderRecord(String orderIdentifier,testagainRest.shipBody shiprokcetResponse){
        
         system.debug('ShipRocketCallbackController------->'+orderIdentifier); 
         List<Order_Delivery_Update__c> deliveryupdateList= new List<Order_Delivery_Update__c>();
         List<Order> orderList=[select id from order where shiprocket_Order_Id__c=:orderIdentifier limit 1];
         Map<String,Order_Delivery_Update__c> statusMap= new Map<String,Order_Delivery_Update__c>();
        
         if(orderList!=null && orderList.size()>0){
             
             for(Order_Delivery_Update__c deliveryStatus:[select id,Status__c from Order_Delivery_Update__c where Order__c=: orderList[0].id]){
                 statusMap.put(deliveryStatus.Status__c,deliveryStatus);
             }            
                     if(statusMap.get(shiprokcetResponse.shipment_status)==null){
                         Order_Delivery_Update__c updateObject= new Order_Delivery_Update__c();
                  		 updateObject.Activity__c=shiprokcetResponse.shipment_status;
                         updateObject.Order__c=orderList[0].id;
                         updateObject.Status__c=shiprokcetResponse.shipment_status;
                         updateObject.ActivityDate__c=Date.valueOf(shiprokcetResponse.etd);                                            
                         deliveryupdateList.add(updateObject);
                     }
                      
         }
          else      {
                         order od=new order();
                         od.EffectiveDate=system.today();
                         od.AccountId='001Hn00001uVDAPIA4';
                         od.Display_Code__c=shiprokcetResponse.order_id.split('_')[0];
                         od.Shipping_Package_Code__c=shiprokcetResponse.order_id.split('_')[1];
              			 od.Status='Draft';
              			 insert od;
              
              			 Order_Delivery_Update__c updateObject= new Order_Delivery_Update__c();
                  		 updateObject.Activity__c=shiprokcetResponse.shipment_status;
                         updateObject.Order__c=od.id;
                         updateObject.Status__c=shiprokcetResponse.shipment_status;
                         updateObject.ActivityDate__c=Date.valueOf(shiprokcetResponse.etd);                                            
                         deliveryupdateList.add(updateObject);
              
                     }
        
        if(deliveryupdateList.size()>0){
            insert deliveryupdateList;
        }
        
        
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Order_Delivery_Update__c> getOrderDeliveryUpdates(String orderId){
         return [select id,name,Activity__c,ActivityDate__c,Status__c from Order_Delivery_Update__c where Order__c=:orderId];   
    }

}