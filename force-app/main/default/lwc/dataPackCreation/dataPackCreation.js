import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DataPackCreation extends LightningElement {

    packName;
    packageActive;
    frequency;
    shedule;

    get frequencyOptions() {
        return [
            { label: 'Daily', value: 'Daily' },
            { label: 'Monthly', value: 'Monthly' },
            { label: 'Weekly', value: 'Weekly' }
        ];
    }

    handlePackName(event) {
        this.packName = event.detail.value;
    }

    handleActive(event) {
        this.packageActive = event.detail.checked;
    }

    handleFrequency(event) {
        this.frequency = event.detail.value;
    }

    handleSchedule(event) {
        this.shedule = event.detail.value;
    }

    validateInputs() {
        return (
            this.packName &&
            this.frequency &&
            this.shedule
        );
    }

    nextStep() {
        console.log('Enter nextStep');
        if(this.validateInputs()){
            const packData = {
                packName: this.packName,
                packageActive: this.packageActive,
                frequency: this.frequency,
                shedule: this.shedule,
                gotoNextStep: true
            };
            const event = new CustomEvent('datapackcreation', { detail: packData });
            this.dispatchEvent(event);
        } 
        else {
             this.showToast('Required Fields', 'Please enter values for all required fields.', 'warning');
        }
        
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
             title: title,
             message: message,
             variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

}