import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class ProcessModalComponent extends LightningModal {
    @api recordId;
    @api config;

    get isEdit() {
        return this.config.DeveloperName === 'Account_Edit';
    }
    get isView() {
        if(this.config.DeveloperName === 'Account_View' || this.config.DeveloperName === 'Opportunity_View'){
            return true;
        } else {
            return false;
        }
    }

    handleClose() {
        this.close();
    }

    handleSuccess(){
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Record updated successfully!',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
        this.handleClose();
    }

    handleSubmit(){
        const form = this.template.querySelector('lightning-record-edit-form');
        form.submit();
    }

}