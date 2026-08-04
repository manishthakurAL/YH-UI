import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class RentAccountItem extends NavigationMixin(LightningElement) {
    @api account;
    @api tenancy;
    @track showStatements = false;
    

    handleMakePayment() {
        this.dispatchEvent(new CustomEvent('makepayment', {
            detail: {
                accountId: this.account.id,
                amount: this.account.accountBalance
            }
        }));
    }

    handleViewStatements() {
        this.showStatements = !this.showStatements;
        if (this.showStatements) {
        
            this.dispatchEvent(new CustomEvent('viewstatements', {
                detail: this.account.id
            }));

            const pageReference = {
                type: 'comm__namedPage',
                attributes: {
                    name: 'Rent_Statement__c' 
                },
                state: {
                    c__accountId: this.account.id,
                    c__customerName: this.tenancy.customerName,
                    c__tenancyNumber: this.tenancy.tenancyNumber,
                    c__propertyType: this.tenancy.propertyType,
                    c__accountType: this.account.accountDescription,
                    c__pAddress: this.tenancy.propertyAddress,
                    c__rentTag: this.tenancy.rentTag,
                    c__occupancyStartDate: this.tenancy.occupancyStartDate,
                    c__chargeFrequency: this.tenancy.chargeFrequency,
                    c__rentType: this.tenancy.rentType
                }
            };
            this[NavigationMixin.Navigate](pageReference);
        }
    }

    get isActiveAccount() {
        return !this.account.occupancyTerminated || this.account.occupancyTerminated === 'Current';
    }

    get isMainRentAccount() {
        return this.account.id == '0';
    }

    get balanceAmount() {
        return this.getFormattedCurrency(this.account.accountBalance);
    }

    getFormattedCurrency(amount) {
        if (amount === null || amount === undefined) return '-';
        return new Intl.NumberFormat('en-GB', {
            style: 'currency',
            currency: 'GBP'
        }).format(amount);
    }

    get balanceClass() {
        if(parseFloat(this.account.accountBalance).toFixed(2) > 0.00) {
            return 'field-value slds-text-heading_small balance-negative';
        } else if(parseFloat(this.account.accountBalance).toFixed(2) < 0.00) {
            return 'field-value slds-text-heading_small balance-positive';
        } else {
            return 'field-value slds-text-heading_small balance-amount';
        }
    }
}