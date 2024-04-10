import { LightningElement } from 'lwc';

export default class DataPackCreation extends LightningElement {

    packName;
    packageActive;
    frequency;
    shedule;
    initialSetup = true;

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

    nextStep() {
        console.log('Enter nextStep');
        this.initialSetup = false;
        const event = new CustomEvent('datapackcreation', { detail: this.initialSetup });
        this.dispatchEvent(event);
    }

}