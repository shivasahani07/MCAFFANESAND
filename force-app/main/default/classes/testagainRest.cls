@RestResource(urlMapping='/testURLData/*')
global class testagainRest {
    @httpPost
    global static integer doPost() 
    {
        RestRequest req = RestContext.request;
        ///system.debug('headers------->'+req.headers);
        //system.debug('req------->'+req.requestBody);
        //system.debug('apikey------->'+req.headers.get('x-api-key'));
        
        if(req.headers.get('x-api-key')=='8374596128'){
            String body=EncodingUtil.base64Decode(EncodingUtil.base64Encode(req.requestBody)).toString();
            if(body.contains('date'))
            {
                system.debug('123');
                body = body.replace('date', 'date123');
            }
            if(body.containsIgnoreCase('sr-status-label'))
            {
                body = body.replace('sr-status-label', 'sr_status_label');
            }
            if(body.containsIgnoreCase('sr-status'))
            {
                body = body.replace('sr-status', 'sr_status');
            }
            
            
            System.debug('body '+ body);
            shipBody shpbdy=(shipBody)JSON.deserialize(body,shipBody.class);
			system.debug('shpbdy------->'+shpbdy.scans[1]);  
            system.debug('shpbdy------->'+shpbdy.scans[1].location); 
        }
        
        return 200;
    }
    
    public class shipBody{
        public String awb;	//123456
        public String courier_name;	//dummy courier_name
        public String current_status;	//Delivered
        public Integer current_status_id;	//7
        public String shipment_status;	//Delivered
        public Integer shipment_status_id;	//7
        public String current_timestamp;	//25 08 2023 12:57:24
        public String order_id;	//dummpy shiprocket order id 123
        public Integer sr_order_id;	//1234
        public String etd;	//2023-08-25 12:57:24
        public cls_scans[] scans;
        public Integer is_return;	//0
        public Integer channel_id;	//1234
        
    }
    public class cls_scans {
            public String location;	//Mumbai_Chndivli_PC (Maharashtra)
            public String date123;	//2022-05-16 16:18:47
            public String activity;	//Manifested - Consignment Manifested
            public String status;	//new
           	public String sr_status;	//NA
            public String sr_status_label;	//NA
        }
    
    

}