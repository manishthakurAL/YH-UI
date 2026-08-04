import { LightningElement } from 'lwc';

export default class CookieConsentModalBtn extends LightningElement {
    isModalOpen = false;

    handleOpenModal() {
        this.isModalOpen = true;
        this.template.querySelector('c-cookie-consent-modal')?.refreshData();
    }   
    handleCloseModal() {
        this.isModalOpen = false;
    }
    handleSaveSettings(event) {
        const functionalCookies = event.detail;
        console.log('Functional Cookies Enabled:', functionalCookies);
        this.isModalOpen = false;
    }
}