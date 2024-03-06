import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ["Account.CountriesBusinessJSON__c", "Account.Name"];

export default class CountriesBusinessMap extends LightningElement {

    @api recordId;
    account;
    jsonMap;
    zoomLevel = 1;
    @track mapMarkers;  

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS})
    wiredRecord({error, data}) {
        if(error){
            console.log('Error -------> '+this.error);
        } else if(data) {
            this.account = data;
            this.jsonMap = this.account.fields.CountriesBusinessJSON__c.value;
            console.log('Value of json ---> '+this.jsonMap);
            console.log('Value of json ---> '+this.account.fields.Name.value);
            const jsonData = JSON.parse(this.jsonMap);
            console.log('jsondata ----------> '+jsonData);
            this.mapMarkers  = jsonData;
        }
    }

}