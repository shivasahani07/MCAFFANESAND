import { LightningElement,api,track } from 'lwc';
import getOrderDeliveryUpdates from '@salesforce/apex/ShipRocketCallbackController.getOrderDeliveryUpdates';

export default class OrderActivity extends LightningElement {

    @api
    recordId;

    @track
    activityList

    connectedCallback() {
        this.getOrderDeliveryUpdates();
    }

    getOrderDeliveryUpdates(){
        getOrderDeliveryUpdates({orderId:this.recordId}).then((result) => {
            //alert('success'+JSON.stringify(result));
            this.activityList=result;
            alert('result');
            
        }).catch((err) => {
            alert('err'+JSON.stringify(err));
            
        });
    }

}