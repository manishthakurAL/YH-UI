import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { generatePRN } from 'c/generatePRNService';
import getTenancies from '@salesforce/apex/RentStatementController.getTenancies';
import getAccountsByTenancyNumber from '@salesforce/apex/RentStatementController.getAccountsByTenancyNumber';
import getAllPayPaymentURL from '@salesforce/apex/RentStatementController.getAllPayPaymentURL';

export default class AccountOverviewV1 extends NavigationMixin(LightningElement) {
    tenancy = {};
    mainRentAccount = {};
    errorMessage = '';

    tenancyNumber;
    orchardChequeDigit;
    allPayURL;

    @wire(getAllPayPaymentURL)
    wiredAllPayURL(value) {
        this.allPayURL = value;
    }

    @wire(getTenancies)
    wiredTenancies({ error, data }) {
        if (data === undefined && error === undefined) {
            return;
        }
        this.errorMessage = '';
        if (data && data.length > 0) {
            this.tenancy =
                data.find((tenancy) => tenancy.propertyType !== 'Garage Rent') ||
                data.find((tenancy) => tenancy.propertyType === 'Garage Rent');
            this.orchardChequeDigit =
                this.tenancy?.orchardChequeDigit != null && this.tenancy?.orchardChequeDigit !== ''
                    ? this.tenancy?.orchardChequeDigit
                    : null;
            this.tenancyNumber = this.tenancy?.tenancyNumber;

            if (this.tenancy?.propertyAddress) {
                this.dispatchEvent(
                    new CustomEvent('addresschange', {
                        detail: { address: this.tenancy.propertyAddress }
                    })
                );
            }
        } else if (error) {
            this.errorMessage = error?.body?.message;
            this.tenancy = undefined;
        }
    }

    @wire(getAccountsByTenancyNumber, { tenancyNumber: '$tenancyNumber', orchardChequeDigit: '$orchardChequeDigit' })
    wiredMainAccount({ error, data }) {
        if (data === undefined && error === undefined) {
            return;
        }
        this.errorMessage = '';
        if (data) {
            this.mainRentAccount = data.find((account) => account.id === '0');
        } else if (error) {
            this.errorMessage = error?.body?.message;
        }
    }

    get disabledMakePayment() {
        return !this.mainRentAccount || !this.tenancy?.tenancyNumber || !this.allPayURL?.data;
    }

    get disabledViewStatements() {
        return !this.mainRentAccount?.id || !this.tenancy?.tenancyNumber;
    }

    get balanceValue() {
        const balance = this.mainRentAccount?.accountBalance;
        return balance == null ? null : parseFloat(balance);
    }

    get isArrears() {
        return this.balanceValue != null && this.balanceValue > 0;
    }

    get isCredit() {
        return this.balanceValue != null && this.balanceValue < 0;
    }

    get formattedBalance() {
        return this.balanceValue == null ? '--' : Math.abs(this.balanceValue).toFixed(2);
    }

    get balanceSign() {
        return this.isArrears ? '-' : '';
    }

    get balanceClass() {
        if (this.isArrears) {
            return 'balance balance-arrears';
        }
        if (this.isCredit) {
            return 'balance balance-credit';
        }
        return 'balance balance-neutral';
    }

    get balanceMessage() {
        if (this.isArrears) {
            return 'Your rent is overdue — pay now';
        }
        if (this.isCredit) {
            return 'Your account is in credit';
        }
        return '';
    }

    get hasBalanceMessage() {
        return !!this.balanceMessage;
    }

    get balanceMessageClass() {
        return this.isArrears ? 'balance-message balance-arrears' : 'balance-message balance-credit';
    }

    get hasRentAmount() {
        return this.tenancy?.weeklyRent != null;
    }

    get formattedRentAmount() {
        return this.hasRentAmount ? Number(this.tenancy.weeklyRent).toFixed(2) : '--';
    }

    get rentFrequencyLabel() {
        const frequency = (this.tenancy?.chargeFrequency || '').toLowerCase();
        if (frequency === 'weekly') {
            return 'Weekly Rent';
        }
        if (frequency === 'monthly') {
            return 'Monthly Rent';
        }
        return 'Rent';
    }

    get rentPeriodLabel() {
        const frequency = (this.tenancy?.chargeFrequency || '').toLowerCase();
        if (frequency === 'weekly') {
            return 'Per week';
        }
        if (frequency === 'monthly') {
            return 'Per month';
        }
        return this.tenancy?.chargeFrequency || '';
    }

    handleMakePayment() {
        let prnNumber;
        try {
            prnNumber = generatePRN(this.tenancyNumber, this.mainRentAccount?.id, this.orchardChequeDigit);
        } catch (error) {
            prnNumber = null;
        }

        const url = prnNumber ? this.allPayURL.data + prnNumber : this.allPayURL.data;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url }
        });
    }

    handleViewStatements() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Rent_Statement__c'
            },
            state: {
                c__accountId: this.mainRentAccount.id,
                c__customerName: this.tenancy.customerName,
                c__tenancyNumber: this.tenancy.tenancyNumber,
                c__propertyType: this.tenancy.propertyType,
                c__accountType: this.mainRentAccount.accountDescription,
                c__pAddress: this.tenancy.propertyAddress,
                c__occupancyStartDate: this.tenancy.occupancyStartDate
            }
        });
    }
}
