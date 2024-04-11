import { LightningElement, api } from 'lwc';

export default class DataPackObjectSetup extends LightningElement {

    relatedObjects;
    replicationSelected;
    selectedObject;
    objectListUpdated;
    isDataPackCreation;
    gotoObjectSetup = false;
    gotoSummary = false;
    packData;

    @api packageObject;

    handleObjectData(event) {
        this.relatedObjects = event.detail;
    }

    handleRelatedObjects(event) {
        console.log('Enter handleRelatedObjects' + JSON.stringify(event.detail));
        this.selectedObject = event.detail;
    }

    handleDeleteObject(event) {
        console.log('handleDeleteObject');
        const deletedObjectName = event.detail;
        const updatedObjectList = this.relatedObjects.filter(obj => obj.objectName !== deletedObjectName);
        this.relatedObjects = updatedObjectList;

        // update object list on data pack object. 
        this.objectListUpdated = deletedObjectName;
    }
    
    handleNextStep(event) {
        const dataPackObject = event.detail;
        this.gotoObjectSetup = dataPackObject.gotoNextStep;

        this.packData = dataPackObject;
    }

    handleGotoSummary(event) {
        console.log('Enter handleGotoSummary --> '+JSON.stringify(event));
        console.log('this.packData --> '+JSON.stringify(this.packData));
        const dataObject = event.detail;
        this.gotoSummary = dataObject.gotoSummary;
        const data = {
            packData: this.packData,
            objects: dataObject.objectList
        }   
        console.log('data --> '+JSON.stringify(data));
        this.objectListUpdated = data;
    }

}