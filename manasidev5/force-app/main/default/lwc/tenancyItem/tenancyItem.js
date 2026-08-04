import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import CustomConfirmModal from 'c/customConfirmModal'; 

export default class TenancyItem extends NavigationMixin(LightningElement) {
    @api tenancy;

    connectedCallback() {
    }

    formattedMessage = `
        <p>This card makes paying your rent simple and convenient—you can use it at your local <b>PayPoint</b> or <b>Payzone shop</b>, or even at the <b>Post Office</b>.</p>
        <br/>
        <p><b>If you’re ready to go ahead</b>, just click <b style="color: var(--yh-green);">Continue</b>.</p>
        <br/>
        <p><b>Changed your mind?</b> No problem—click <b style="color: var(--yh-rose);">Go Back</b>.</p>
    `;

    get chevronIcon() { 
        return this.tenancy?.isExpanded ? 'utility:chevronup' : 'utility:chevrondown';
    }

    get toggleAltText() {
        return this.tenancy?.isExpanded ? 'Collapse' : 'Expand';
    }

    get hasAccounts() {
        return this.tenancy.accounts && this.tenancy.accounts.length > 0;
    }

    get mainRentAccount() { 
        if (!this.tenancy?.accounts) {
            console.warn('Tenancy accounts not loaded yet');
            return null;
        }

        // Defensive: allow id to be string or number
        return this.tenancy.accounts.find(account => account.id === '0' || account.id === 0);
    }

    get showRequestNewRentCard(){ 
        return this.tenancy.hasMainRentAccount && this.tenancy?.isExpanded;
    }
    handleToggle(e) {
        e.preventDefault(); 
        const newExpandedState = !this.tenancy?.isExpanded;
        this.dispatchEvent(
            new CustomEvent('expandtenancy', {
                detail: {
                    tenancyNumber: this.tenancy.tenancyNumber,
                    isExpanded: newExpandedState
                }
            })
        );
    }

    handleMakePayment(event) {
        let accountid = event.detail?.accountId;
        let amount = event.detail?.amount;
        this.dispatchEvent(new CustomEvent('makepayment', {
            detail: {
                tenancyNumber: this.tenancy.tenancyNumber,
                orchardChequeDigit: this.tenancy.orchardChequeDigit,
                accountid : accountid,
                amount: amount
            }
        }));
    }

    handleViewStatements(event) {
        this.dispatchEvent(new CustomEvent('viewstatements', {
            detail: event.detail
        }));
    }

    async handleNewRentCard() {
        // Prevent action if accounts not loaded
        if (!this.mainRentAccount) {
            return;
        }
        const result = await CustomConfirmModal.open({
            size: 'small',
            confirmTitle: 'You’re about to request a rent payment card.',
            confirmMessage: this.formattedMessage, // Pass the HTML string
            confirmLabel: 'Continue', // Custom label for confirmation button
            cancelLabel: 'Go Back', // Custom label for cancel button
        });

        if (result) { 
            this[NavigationMixin.Navigate]({            
                type: 'comm__namedPage',
                    attributes: {
                        name: 'NewRentCard__c' 
                    },
                    state: {
                        c__isActive: this.tenancy.isActive ? 'true' : 'false',
                        c__customerName: this.tenancy.customerName,
                        c__accountType: this.mainRentAccount.accountDescription,
                        c__propertyType: this.tenancy.propertyType,
                        c__tenancyId: this.tenancy.tenancyId,
                        c__tenancyNumber: this.tenancy.tenancyNumber, 
                        c__pAddress: this.tenancy.propertyAddress
                    }
            });
        }
    }

    handleActionMenuSelect(event) {
        switch (event.detail.value) {
            case 'new-rent-card':
                this.handleNewRentCard();
                break;
            default:
                break;
        }
    }

}