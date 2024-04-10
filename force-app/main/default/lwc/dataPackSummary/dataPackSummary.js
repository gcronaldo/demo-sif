import { LightningElement, api } from 'lwc';

export default class DataPackSummary extends LightningElement {

    @api objects = [];

    handleToggleSection(event) {
        console.log('handleToggleSection'+event.detail.openSections);
    }

}