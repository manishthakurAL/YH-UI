import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { buildPaymentUrl } from 'c/paymentUrlService';
import * as labels from 'c/labelService';
import getTenancies from '@salesforce/apex/RentStatementController.getTenancies';
import getAccountsByTenancyNumber from '@salesforce/apex/RentStatementController.getAccountsByTenancyNumber';
import getAllPayPaymentURL from '@salesforce/apex/RentStatementController.getAllPayPaymentURL';

export default class AccountOverviewV1 extends NavigationMixin(LightningElement) {
    label = labels;

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
            return this.label.CP_RentOverdueMessage;
        }
        if (this.isCredit) {
            return this.label.CP_AccountInCreditMessage;
        }
        return '';
    }

    get hasBalanceMessage() {
        return !!this.balanceMessage;
    }

    get hasRentAmount() {
        return this.tenancy?.weeklyRent != null;
    }

    get isNegativeRent() {
        return this.hasRentAmount && Number(this.tenancy.weeklyRent) < 0;
    }

    get rentValueClass() {
        return this.isNegativeRent ? 'info-value info-value-negative' : 'info-value';
    }

    get formattedRentAmount() {
        if (!this.hasRentAmount) {
            return '£--';
        }
        const amount = Number(this.tenancy.weeklyRent);
        const sign = amount < 0 ? '-' : '';
        return `${sign}£${Math.abs(amount).toFixed(2)}`;
    }

    get rentFrequencyLabel() {
        return this.tenancy?.rentFrequencyLabel || this.label.CP_RentFrequencyDefault;
    }

    get rentPeriodLabel() {
        return this.tenancy?.rentPeriodLabel || '';
    }

    handleMakePayment() {
        const url = buildPaymentUrl(this.allPayURL.data, this.tenancyNumber, this.mainRentAccount?.id, this.orchardChequeDigit);
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