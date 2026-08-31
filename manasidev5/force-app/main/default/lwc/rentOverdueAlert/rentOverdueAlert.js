import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { buildPaymentUrl } from 'c/paymentUrlService';
import getTenancies from '@salesforce/apex/RentStatementController.getTenancies';
import getAccountsByTenancyNumber from '@salesforce/apex/RentStatementController.getAccountsByTenancyNumber';
import getAllPayPaymentURL from '@salesforce/apex/RentStatementController.getAllPayPaymentURL';

export default class RentOverdueAlert extends NavigationMixin(LightningElement) {
    tenancy = {};
    mainRentAccount = {};

    tenancyNumber;
    orchardChequeDigit;
    allPayURL;

    @wire(getAllPayPaymentURL)
    wiredAllPayURL(value) {
        this.allPayURL = value;
    }

    @wire(getTenancies)
    wiredTenancies({ data }) {
        if (data && data.length > 0) {
            this.tenancy =
                data.find((tenancy) => tenancy.propertyType !== 'Garage Rent') ||
                data.find((tenancy) => tenancy.propertyType === 'Garage Rent');
            this.orchardChequeDigit =
                this.tenancy?.orchardChequeDigit != null && this.tenancy?.orchardChequeDigit !== ''
                    ? this.tenancy?.orchardChequeDigit
                    : null;
            this.tenancyNumber = this.tenancy?.tenancyNumber;
        }
    }

    @wire(getAccountsByTenancyNumber, { tenancyNumber: '$tenancyNumber', orchardChequeDigit: '$orchardChequeDigit' })
    wiredMainAccount({ data }) {
        if (data) {
            this.mainRentAccount = data.find((account) => account.id === '0');
        }
    }

    get balanceValue() {
        const balance = this.mainRentAccount?.accountBalance;
        return balance == null ? null : parseFloat(balance);
    }

    get isOverdue() {
        return this.balanceValue != null && this.balanceValue > 0;
    }

    get formattedAmountDue() {
        return this.balanceValue == null ? '' : Math.abs(this.balanceValue).toFixed(2);
    }

    get disabledMakePayment() {
        return !this.mainRentAccount || !this.tenancy?.tenancyNumber || !this.allPayURL?.data;
    }

    handleMakePayment() {
        const url = buildPaymentUrl(this.allPayURL.data, this.tenancyNumber, this.mainRentAccount?.id, this.orchardChequeDigit);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url }
        });
    }
}
