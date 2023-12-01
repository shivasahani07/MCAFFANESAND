import { LightningElement,track } from 'lwc';
 import getObjectList from '@salesforce/apex/ObjectInfoController.getObjectList'
 import getAllUsersList from '@salesforce/apex/ObjectInfoController.getAllUsersList'
 import getAccessLeverUserWise  from '@salesforce/apex/ObjectInfoController.getAccessLeverUserWise'

export default class ObjectInfoComponent extends LightningElement {

    @track
    options=[];
    value = '';
    labelObjectName='';

    
    @track
    optionsUsers=[];
     valueUser = '';
     labelUserName=''

    @track
    filedInfoObjectList=[];

   checkboxVal = true;


    connectedCallback() {
        this.getAllObjectInOrg();
        this.getAllUsersInOrg();
    }

    getAllObjectInOrg(){
        getObjectList().then((result) => {
            //alert(result+JSON.stringify(result));
            console.log('result'+JSON.stringify(result));
            this.createOptionData(result);
        }).catch((err) => {
           // alert('errr'+JSON.stringify(err));
            console.log('errr'+JSON.stringify(err));

        });
    }

    getAllUsersInOrg(){
        getAllUsersList().then((result) => {
            //alert(result+JSON.stringify(result));
            console.log('getAllUsersList result'+JSON.stringify(result));
            this.createOptionDataForUsers(result);
        }).catch((err) => {
           // alert('errr'+JSON.stringify(err));
            console.log('getAllUsersList errr'+JSON.stringify(err));

        });
    }

    createOptionData(result){

         result.map(data =>{

            const option = {
                label : ''+data.label,
                value : ''+data.apiName
            };

            this.options = [...this.options, option];
        
        });

       console.log(' this.options'+JSON.stringify( this.options));
    }

    createOptionDataForUsers(result){

         result.map(data =>{

            const option = {
                label : ''+data.userName,
                value : ''+data.userId
            };

            this.optionsUsers = [...this.optionsUsers, option];
        
        });

       console.log(' this.optionsUsers'+JSON.stringify( this.optionsUsers));
    }

    handleChange(event) {
        this.value = event.detail.value;
        console.log('this.value'+this.value);

        this.labelObjectName = event.target.options.find(opt => opt.value === event.detail.value).label;

        //this.getFieldDefination();

        this.checkFieldAndGetAccessLevel();

    }

    handleChangeUser(event){
        this.valueUser = event.detail.value;
        this.labelUserName=event.target.options.find(opt => opt.value === event.detail.value).label;
        this.checkFieldAndGetAccessLevel();
    }

    checkFieldAndGetAccessLevel(){
        console.log('valueUser '+this.value);
        console.log('valueUser '+this.valueUser);
        
        if((this.value != null && this.value != '') && (this.valueUser != null && this.valueUser != '')){
            this.getFieldDefination();
        }

    }

    getFieldDefination(){
        console.log('getAccessLeverUserWise valueUser '+this.valueUser);
        console.log('getAccessLeverUserWise value '+this.value);
        
         getAccessLeverUserWise({userId:this.valueUser,objectName:this.value}).then((result) => {
            //alert(result+JSON.stringify(result));
            console.log('getAccessLeverUserWise result'+JSON.stringify(result));
            this.filedInfoObjectList=result;
            //this.createOptionDataForUsers(result);
        }).catch((err) => {
           // alert('errr'+JSON.stringify(err));
            console.log('getAccessLeverUserWise errr'+JSON.stringify(err));
        });
    }

    

}