import { LightningElement, wire, api } from 'lwc';
import getRelatedAccounts from '@salesforce/apex/RelatedAccountsController.getRelatedAccounts';
import ACCOUNT_NAME from '@salesforce/schema/AccountContactRelation.AccountId';
import ROLE from '@salesforce/schema/AccountContactRelation.Roles';

const COLUMNS = [
    { label: 'Account', fieldName:'Account' },
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
                parsedAccount.Role = record.Roles;
                console.log('--> '+JSON.stringify(parsedAccount));
                parsedAccounts.push(parsedAccount);
            });
            this.records = parsedAccounts;
        } else if (error) {
            this.errors = error;
            console.log('--> '+JSON.stringify(this.errors));
        }
    };
}