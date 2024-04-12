import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DataPackObject extends LightningElement {
    replicationSelected = false;
    purgeSelected = false;
    executionOrder;
    queryConditional;
    bucketName;
    screenSizeLoad;
    path;
    batchSize;
    queryConditionalPurge;
    objectName;
    objectList = [];

    _objectListUpdatedI;

    @api 
    get objectListUpdated() {
        console.log('<------get objectListUpdated------->');
        return this._objectListUpdatedI;
    }
    set objectListUpdated(value) {
        this._objectListUpdatedI = value;
        if(this._objectListUpdatedI && this._objectListUpdatedI.length > 0){
            this.objectList = this.objectList.filter(obj => obj.objectName !== value);
            this.clearValues();
        } 
    }


    _selectedObject;

    @api
    get selectedObject() {
        return this._selectedObject;
    }
    set selectedObject(value) {
        this._selectedObject = value;
        this.handleSelectedObjectChange();
    }

    handleSelectedObjectChange() {
        if (this.selectedObject) {
            this.replicationSelected = this.selectedObject.replicationSelected;
            this.purgeSelected = this.selectedObject.purgeSelected;
            this.objectName = this.selectedObject.objectName;
            this.executionOrder = this.selectedObject.executionOrder;
            this.queryConditional = this.selectedObject.queryConditional;
            this.bucketName = this.selectedObject.bucketName;
            this.queryConditionalPurge = this.selectedObject.queryConditionalPurge;
            this.screenSizeLoad = this.selectedObject.screenSizeLoad;
            this.path = this.selectedObject.path;
            this.batchSize = this.selectedObject.batchSize;
        } 
    }
  
    get availableObjects() {
        return [
            { label: 'Account', value: 'Account' },
            { label: 'Contact', value: 'Contact' },
            { label: 'Opportunity', value: 'Opportunity' },
            { label: 'Case', value: 'Case' },
            { label: 'Lead', value: 'Lead' },
            { label: 'Invoices', value: 'Invoice__c' },
        ];
    }

    handleSelectedObject(event) {
        this.objectName = event.detail.value;
    }

    handlePurge(event) {
        this.purgeSelected = event.target.checked;
    }

    handleExecutionOrder(event) {
        this.executionOrder = event.target.value;
        this.validateExecutionOrder();        
    }
    
    handleReplication(event) {
        this.replicationSelected = event.target.checked;
    }

    handleQueryConditional(event) {
        this.queryConditional = event.target.value;
    }

    handleBucketName(event) {
        this.bucketName = event.target.value;
    }

    handleScreenSizeLoad(event) {
        this.screenSizeLoad = event.target.value;
    }

    handlePath(event) {
        this.path = event.target.value;
    }

    handleBatchSize(event) {
        this.batchSize = event.target.value;
    }

    handleQueryConditionalPurge(event) {
        this.queryConditionalPurge = event.target.value;
    }

    addObject() {

        // Check if objectName is set. 
        if(!this.objectName) {
            this.showToast('Required Fields', 'Please select an object first.', 'warning');
            return;
        }

        // Check if the execution order is already in use. Return if so.
        if(!this.validateExecutionOrder()){
            return;
        }

        const objectData = {
            objectName: this.objectName,
            replicationSelected: this.replicationSelected,
            purgeSelected: this.purgeSelected,
            executionOrder: this.executionOrder,
            queryConditional: this.queryConditional,
            bucketName: this.bucketName,
            screenSizeLoad: this.screenSizeLoad,
            path: this.path,
            batchSize: this.batchSize,
            queryConditionalPurge: this.queryConditionalPurge
        }
        const existingIndex = this.objectList.findIndex(obj => obj.objectName === objectData.objectName);

        if (existingIndex !== -1) {
            this.objectList[existingIndex] = objectData;
            this.showToast('Object Updated', 'Object updated successfully!', 'success');
        } else { 
            this.objectList.push(objectData);
            this.showToast('Object Created', 'Object created successfully!', 'success');
        }

        // Sort object list based on execution order. 
        this.objectList.sort((a,b) => {
            return a.executionOrder - b.executionOrder;
        });
        const event = new CustomEvent('objectdata', { detail: this.objectList });
        this.dispatchEvent(event);
        this.clearValues();
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
             title: title,
             message: message,
             variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    clearValues() {
        this.objectName = '';
        this.replicationSelected = false;
        this.purgeSelected = false;
        this.executionOrder = '';
        this.queryConditional = '';
        this.bucketName = '';
        this.screenSizeLoad = '';
        this.path = '';
        this.batchSize = '';
        this.queryConditionalPurge = '';
        this.selectedObject = '';
    }

    validateExecutionOrder() {
        const existingOrderIndex = this.objectList.findIndex(obj => obj.executionOrder === this.executionOrder && obj.objectName !== this.objectName);
        if (existingOrderIndex !== -1) {
            this.showToast('Execution Order', 'This execution order already exists.', 'warning');
            return false;
        } else {
            return true;
        }
    }

    nextStep() {
        var data = {
            objectList: this.objectList,
            gotoSummary: true
        }
        console.log('Value data ---> '+data);
        const event = new CustomEvent('gotosummary', { detail: data });
        this.dispatchEvent(event);
    }

}