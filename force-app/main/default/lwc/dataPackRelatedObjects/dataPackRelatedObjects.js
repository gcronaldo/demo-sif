import { LightningElement, api } from 'lwc';

export default class DataPackRelatedObjects extends LightningElement {
    @api objects = [];

    handleSelectedObject(event) {
        const selectedObjectname = event.currentTarget.dataset.key;
        const selectedObject = this.objects.find(obj => obj.objectName === selectedObjectname);
        const selectedEvent = new CustomEvent('objectselected', { detail: selectedObject });
        this.dispatchEvent(selectedEvent);
    }

    handleDelete(event) {
        console.log('Enter handleDelete');
        const objectName = event.currentTarget.dataset.key;
        const deleteEvent = new CustomEvent('deleteobject', { detail: objectName });
        this.dispatchEvent(deleteEvent);
    }
}
