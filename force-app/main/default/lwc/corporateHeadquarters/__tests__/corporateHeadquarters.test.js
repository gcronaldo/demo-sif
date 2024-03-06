import { createElement } from 'lwc';
import CorporateHeadquarters from 'c/corporateHeadquarters';

describe('c-corporate-headquarters', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders map markers correctly', () => {
        const CITY = 'San Francisco';
        const COUNTRY = 'USA';
        const POSTAL_CODE = '94105';
        const STATE = 'CA';
        const STREET = 'The Landmark @ One Market, Suite 300';
        const TITLE = 'Corporate Headquarters';
        const DESCRIPTION = 'Our main office location';
        const ICON = 'standard:location';
        
        const element = createElement('c-corporate-headquarters', {
            is: CorporateHeadquarters
        });
        element.city = CITY;
        element.country = COUNTRY;
        element.postalCode = POSTAL_CODE;
        element.state = STATE;
        element.street = STREET;
        element.title = TITLE;
        element.description = DESCRIPTION;
        element.icon = ICON;

        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            const map = element.shadowRoot.querySelector('lightning-map');

            expect(map.mapMarkers[0].location.City).toBe(CITY);
            expect(map.mapMarkers[0].location.Country).toBe(COUNTRY);
            expect(map.mapMarkers[0].location.PostalCode).toBe(POSTAL_CODE);
            expect(map.mapMarkers[0].location.State).toBe(STATE);
            expect(map.mapMarkers[0].location.Street).toBe(STREET);
            expect(map.mapMarkers[0].title).toBe(TITLE);
            expect(map.mapMarkers[0].description).toBe(DESCRIPTION);
            expect(map.mapMarkers[0].icon).toBe(ICON);
        });

    });
});