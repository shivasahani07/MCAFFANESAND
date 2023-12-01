import { LightningElement, wire, track, api } from "lwc";
import { getListUi } from "lightning/uiListApi";
import CASE_OBJECT from "@salesforce/schema/Case";
import { refreshApex } from "@salesforce/apex";

const columns = [
    { label: "Id", fieldName: "CaseNumber" },
    { label: "Subject", fieldName: "Subject", type: "text" },
    { label: "Priority", fieldName: "Priority", type: "picklist" },
    { label: "Owner", fieldName: "Owner", type: "lookup" },
    { label: "Status", fieldName: "Status", type: "picklist" }
];
export default class CaseTabsListTable extends LightningElement {
    selectedNav = "default_recent";
    @track value;
    @track allListViews;
    @track listViewData = [];
    @track wiredCaseList = [];
    @track progressValue = "AllOpenCases";
    @track recordCount = 0;
    @track sobjectResult;
    @track columns = columns;

    togglePanel() {
        let leftPanel = this.template.querySelector(
            "div[data-my-id=leftPanel]"
        );
        let rightPanel = this.template.querySelector(
            "div[data-my-id=rightPanel]"
        );

        if (leftPanel.classList.contains("slds-is-open")) {
            leftPanel.classList.remove("slds-is-open");
            leftPanel.classList.remove("open-panel");
            leftPanel.classList.add("slds-is-closed");
            leftPanel.classList.add("close-panel");
            rightPanel.classList.add("expand-panel");
            rightPanel.classList.remove("collapse-panel");
        } else {
            leftPanel.classList.add("slds-is-open");
            leftPanel.classList.add("open-panel");
            leftPanel.classList.remove("slds-is-closed");
            leftPanel.classList.remove("close-panel");
            rightPanel.classList.remove("expand-panel");
            rightPanel.classList.add("collapse-panel");
        }
    }

    refreshUserData(evt) {
        const buttonIcon = evt.target.querySelector(".slds-button__icon");
        buttonIcon.classList.add("refreshRotate");

        // setTimeout(() => {
        //     buttonIcon.classList.remove("refreshRotate");
        // }, 1000);
    }

    handleSelect(event) {
        const selected = event.detail.name;
        this.selectedNav = selected;
    }
    handleListNameClick(event) {       
        const selected = event.currentTarget.dataset.name;
        //refreshApex(this.progressValue2);
        this.selectedNav = selected;
        this.progressValue = this.selectedNav;
        //this.progressValue = "00BHn00000BJuqAMAT";
        refreshApex(this.wiredCaseList);
    }

    @wire(getListUi, { objectApiName: CASE_OBJECT })
    wiredlistView({ error, data }) {
        if (data) {
            this.allListViews = data.lists;
            console.log("data.lists===>", data.lists);
            // for(var i=0;i<this.allListViews.length;i++){
            //     console.log('in for loop===>',i);
            //     this.listViewData.push({"label" : this.allListViews[i].label, "value" : this.allListViews[i].apiName});
            //     console.log('this.listViewData===>',this.listViewData);
            // }
            //this.allListViews = this.listViewData;
            console.log("this.allListViews===>", this.allListViews);
        } else if (error) {
            console.log("An error has occurred:");
            console.log(error);
        }
    }

    @wire(getListUi, {
        objectApiName: CASE_OBJECT,
        //listViewId: '$progressValue'
        listViewApiName: '$progressValue',
        pageSize: 2000,
    })
    lastView(result) {
        this.wiredCaseList = result;
        
        if (result.data) {
            // this.sobjectResult = data.records.records;

            this.sobjectResult = result.data.records.records;
            this.recordCount = this.selectedNav +'('+this.sobjectResult.length+')';
            console.log("data.records===>111111", result.data.records);
            this.listViewData=[];
            for (let i = 0; i < this.sobjectResult.length; i++) {
                console.log("in for loop===>", i);
                //console.log('Display value ===>',data.records.records[i].fields.Priority.displayValue);
                console.log(
                    "value ===>",
                    this.sobjectResult[i].fields.Priority.value
                );

                

                //this.listViewData.push({"id" : data.records.records[i].fields.Id.value,"CaseNumber" : data.records.records[i].fields.CaseNumber.value, "Subject" : data.records.records[i].fields.Subject.value, "Priority" : data.records.records[i].fields.Priority.value, "Owner" : data.records.records[i].fields.Subject.displayValue, "Status" : data.records.records[i].fields.Status.value});
               let tempObj =  {
                    id: this.sobjectResult[i].fields.Id.value,
                    CaseNumber:
                        this.sobjectResult[i].fields.CaseNumber.value,
                    Subject: this.sobjectResult[i].fields.Subject.value,
                    Priority: this.sobjectResult[i].fields.Priority.value,
                    Owner: this.sobjectResult[i].fields.Subject
                        .displayValue,
                    Status: this.sobjectResult[i].fields.Status.value
                }  ;

                this.listViewData.push(tempObj);

                console.log("this.listViewData===>", this.listViewData);
            }
            console.log("this.sobjectResult===>", this.listViewData);
        } else if (result.error) {
            this.error = result.error;
        }
    }
}