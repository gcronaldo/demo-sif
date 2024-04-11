import { LightningElement, api } from 'lwc';
import saveDataPackRecords from '@salesforce/apex/DataPackSetupController.saveDataPackRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DataPackSummary extends LightningElement {

    @api objects;

    handleToggleSection(event) {
        console.log('handleToggleSection'+event.detail.openSections);
    }

    saveDataPack() {
        console.log('Enter saveDataPack');
        console.log('Value of input ---> '+JSON.stringify(this.objects));
        saveDataPackRecords({ dataPackJson: JSON.stringify(this.objects) })
            .then(result => {
                console.log('Records saved successfully --> '+JSON.stringify(result));
                this.showToast('Success', 'Data Pack saved successfully', 'success');
            })
            .catch(error => {
                console.log('Got error --> '+JSON.stringify(error));
                 this.showToast('Error', 'Error in saving Data Pack', 'error');
            })
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