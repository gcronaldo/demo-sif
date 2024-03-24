import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from "@salesforce/schema/Account.Name";
import COUNTRIES_FIELD from "@salesforce/schema/Account.CountriesBusinessJSON__c";

export default class MapComponent extends LightningElement {
    
    @api recordId; 

    // Retrieve account record info. 
    @wire(getRecord, { recordId: "$recordId", fields: [NAME_FIELD, COUNTRIES_FIELD] })
    account;

    get mapMarkers(){
        if(this.account.data){
            const countriesJSON = getFieldValue(this.account.data, COUNTRIES_FIELD);
            const countries = JSON.parse(countriesJSON);
            return countries.map(location => ({
                location: {
                    City: location.location.City,
                    Country: location.location.Country,
                    PostalCode: location.location.PostalCode,
                    State: location.location.State,
                    Street: location.location.Street
                },
                title: location.title,
                description: location.description,
                icon: location.icon
            }));
        } else {
            return [];
        }
    }
}