import { LightningElement, api, wire } from 'lwc';
import getProcessConfig from '@salesforce/apex/ProcessConfigController.getProcessConfigs';
import processModalComponent from 'c/processModalComponent';

export default class ProcessComponent extends LightningElement {

    @api recordId;
    @api objectAPIName;
    configs;
    hasData = false;
    error;
    selectedConfig;

    @wire(getProcessConfig, {objectName: '$objectAPIName'})
    wiredConfigs({error, data}) {
        if(data) {
            console.log('Wire Data ---> '+JSON.stringify(data));
            this.hasData = true;
            this.configs = data;
        } else if(error) {
            console.log('Error ---> '+JSON.stringify(error));
            this.error = error;
        }
    }

    handleButtonClick(event){
        const configName = event.target.alternativeText;
        this.selectedConfig = this.configs.find(config => config.DeveloperName === configName);
        console.log('button click selectedConfig --> '+JSON.stringify(this.selectedConfig));
        processModalComponent.open({
            config : this.selectedConfig,
            recordId: this.recordId,
            label: configName
        }).then((result) => {
            console.log('result modal ---> '+JSON.stringify(result));
        });
    }
}