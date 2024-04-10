import { LightningElement, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class DataPackObjectSetup extends LightningElement {

    relatedObjects;
    replicationSelected;
    selectedObject;
    objectListUpdated;
    isDataPackCreation;

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

}