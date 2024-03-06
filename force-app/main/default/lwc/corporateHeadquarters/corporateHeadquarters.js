import { LightningElement, api } from 'lwc';

export default class CorporateHeadquarters extends LightningElement {

    // Expose attributes to handles values as inputs and not hardcoded. 
    @api city;
    @api country;
    @api postalCode;
    @api state;
    @api street;
    @api mapMarkersValue;
    @api title;
    @api description;
    @api icon;

    // Set the map markers value. 
    get mapMarkers() {
        // Compute mapMarkers array dynamically based on attribute values
        return [{
            location: {
                City: this.city,
                Country: this.country,
                PostalCode: this.postalCode,
                State: this.state,
                Street: this.street
            },
            title: this.title,
            description: this.description,
            icon: this.icon
        }];
    }
    zoomLevel = 12;

}