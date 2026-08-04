import { LightningElement, wire } from 'lwc';
import getCurrentUserName from '@salesforce/apex/YH_PortalController.getCurrentUser';

export default class YhCustomerPortalHomeContainer extends LightningElement {
    greetingMessage;
    userName;

    connectedCallback() {
        this.updateGreeting();
    }

     @wire(getCurrentUserName)
    wiredUser({ error, data }) {
        if (data) {
            this.userName = data.firstName;
            console.log('Data:****', data);
        } else if (error) {
            console.log('Error:', JSON.stringify(error));  
        }
    }
    
    updateGreeting() {
        const now = new Date();
        const hour = now.getHours();

        let greeting;

        if (hour >= 5 && hour < 12) {
            greeting = 'Good Morning';
        } else if (hour >= 12 && hour < 17) {
            greeting = 'Good Afternoon';
        } else if (hour >= 17 && hour < 21) {
            greeting = 'Good Evening';
        } else {
            greeting = 'Good Night';
        }        

        this.greetingMessage = `${greeting}`; 
    }
}