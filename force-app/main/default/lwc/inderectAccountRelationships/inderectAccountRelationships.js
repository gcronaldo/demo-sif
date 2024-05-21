import { LightningElement, wire, api } from 'lwc';
import getRelatedAccounts from '@salesforce/apex/RelatedAccountsController.getRelatedAccounts';

const COLUMNS = [
    { label: 'Related Account', fieldName:'Account' },
    { label: 'Source Account', fieldName:'SourceAccount' },
    { label: 'Contact', fieldName:'Contact' },
    { label: 'Role', fieldName:'Role' }
];

export default class InderectAccountRelationships extends LightningElement {

    @api recordId;
    columns = COLUMNS;
    errors;
    records = [];
    hasData = false;

    @wire(getRelatedAccounts,  { accountId: '$recordId' })
    wiredAccounts({error, data}){
        this.records = data;
        if (this.records && this.records.length) {
            console.log('--> '+JSON.stringify(data));
            this.hasData = true;
            this.records = data;
            let parsedAccounts = [];
            this.records.forEach(record => {
                let parsedAccount = {};
                parsedAccount.Id = record.Id;
                parsedAccount.Account = record.Account.Name;
                parsedAccount.SourceAccount = record.Contact.Account.Name;
                parsedAccount.Contact = record.Contact.Name;
                parsedAccount.Role = record.Roles;
                parsedAccounts.push(parsedAccount);
            });
            this.records = parsedAccounts;
        } else if (error) {
            this.errors = error;
            console.log('--> '+JSON.stringify(this.errors));
        }
    };
}