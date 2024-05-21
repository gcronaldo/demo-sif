import { LightningElement, api } from 'lwc';

export default class CorporateHeadquarters extends LightningElement {

    @api city;
    @api country;
    @api postalCode;
    @api state;
    @api street;
    @api mapMarkersValue;
    @api title;
    @api description;
    @api icon;

    get mapMarkers() {
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