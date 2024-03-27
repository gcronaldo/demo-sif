import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import jspdf from '@salesforce/resourceUrl/jspdf';
import saveFile from '@salesforce/apex/PDFFileConversion.saveFile';

import NAME_FIELD from "@salesforce/schema/Account.Name";
import COUNTRIES_FIELD from "@salesforce/schema/Account.CountriesBusinessJSON__c";

export default class MapComponent extends LightningElement {
    @api recordId;
    jsPdfInitialized = false;

    @wire(getRecord, { recordId: "$recordId", fields: [NAME_FIELD, COUNTRIES_FIELD] })
    account;

    renderedCallback() {
        if (!this.jsPdfInitialized) {
            loadScript(this, jspdf)
                .then(() => {
                    this.jsPdfInitialized = true;
                })
                .catch(error => {
                    console.error('Error loading jsPDF:', error);
                });
        }
    }

    get mapMarkers() {
        if (this.account.data) {
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

    mapOptions = {
        draggable: false,
        disableDefaultUI: true,
    };

    generatePDF() {
        console.log('Enter generatePDF');
        if (!this.jsPdfInitialized) {
            console.error('jsPDF not initialized.');
            return;
        }

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        doc.text("Hello world", 12, 149); // Print text on document
        const pdfData = btoa(doc.output()); 
        this.callApexMethod(pdfData);
    }

    callApexMethod(pdfData) {
        console.log('Enter callApexMethod--> '+pdfData)
        saveFile({ base64: pdfData, parentId: this.recordId, fileName: 'Test.pdf' })
            .then(() => {
                console.log('File saved successfully.');
                this.showToast('Success', 'PDF file saved successfully!', 'sucess');
            })
            .catch(error => {
                console.error('Error saving file:', error);
                this.showToast('Error', 'Failed to save PDF file :-(', 'error');
            });
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