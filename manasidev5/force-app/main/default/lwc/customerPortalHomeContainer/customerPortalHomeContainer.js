import { LightningElement, wire } from 'lwc';
import getCurrentUserName from '@salesforce/apex/CustomPortalThemeController.getCurrentUser';

export default class CustomerPortalHomeContainer extends LightningElement {
    greetingMessage;
    userName;
    address;
    hasAddress = false;

    connectedCallback() {
        this.updateGreeting();
    }

    handleAddressChange(event) {
        this.address = event.detail.address;
        this.hasAddress = !!this.address;
    }

     @wire(getCurrentUserName)
    wiredUser({ error, data }) {
        if (data) {
            this.userName = data.firstName;
        } else if (error) {
            console.log('Error:', JSON.stringify(error));  
        }
    }
    
    updateGreeting() {
        const now = new Date();
        const hour = now.getHours();

        let greeting;

        if (hour >= 0 && hour < 12) {
            greeting = 'GOOD MORNING';
        } else if (hour >= 12 && hour < 18) {
            greeting = 'GOOD AFTERNOON';
        } else if (hour >= 18 && hour <= 23) {
            greeting = 'GOOD EVENING';
        }        

        this.greetingMessage = `${greeting}`; 
    }
}