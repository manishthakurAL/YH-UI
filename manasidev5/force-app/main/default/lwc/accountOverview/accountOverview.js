import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { generatePRN } from "c/generatePRNService";
import getTenancies from '@salesforce/apex/RentStatementController.getTenancies';
import getAccountsByTenancyNumber from '@salesforce/apex/RentStatementController.getAccountsByTenancyNumber';
import getallPayURL from '@salesforce/apex/RentStatementController.getAllPayPaymentURL';

export default class AccountOverview  extends NavigationMixin(LightningElement) {

    @track allPayURL;
    @track mainRentAccount = {};
    @track tenancy = {};
    @track isLoading = true;
    @track error = undefined;
    @track errorMessage = '';
    @track tenancyNumber = null;
    @track orchardChequeDigit = null;
    
    @wire(getallPayURL)
        allPayURL;

    @wire(getTenancies)
    getTenancies({ error, data }) {
        if (data === undefined && error === undefined) {
            return;
        }
        this.errorMessage = '';
        this.isLoading = false;
        if (data && data.length > 0) {
            this.tenancy = data.find(tenancy => (
                tenancy.propertyType !== 'Garage Rent' ));
            if (!this.tenancy) {
                this.tenancy = data.find(tenancy => (
                tenancy.propertyType === 'Garage Rent' ));
            }
            this.orchardChequeDigit = this.tenancy?.orchardChequeDigit || null;
            this.tenancyNumber = this.tenancy?.tenancyNumber;
            
        } else if (error) {
            console.error(JSON.stringify(error))
             this.errorMessage = error.body.message;
            this.tenancy = undefined;
        }
    }

    @wire(getAccountsByTenancyNumber, { tenancyNumber: '$tenancyNumber', orchardChequeDigit: '$orchardChequeDigit' })
    getMainAccount({ error, data }) {
        if (data === undefined && error === undefined) {
            return;
        }
        this.errorMessage = '';
        this.isLoading = false;
        if (data) {
            this.mainRentAccount = data?.find(
                account => account.id === '0'
            );   
            console.log('Main Rent Account:', JSON.stringify(this.mainRentAccount, null, 2));         
        } else if (error) {
            console.error(JSON.stringify(error));
            this.errorMessage = error.body.message;
        }
    }   

    get disabledMakePayment() {
        return !this.mainRentAccount || !this.tenancy?.tenancyNumber  || !this.allPayURL?.data;
    }

    get disabledViewStatements() {
        return !this.mainRentAccount?.id || !this.tenancy?.tenancyNumber ;
    }

    get tenancyAddress() {
        return this.tenancy?.propertyAddress || 'Address not available';
    }

    get mainAccountBalance() {
        const balance = this.mainRentAccount?.accountBalance;
        if (balance == null || balance === '') {
            return ' --';
        }
        return balance.toFixed(2);
    }

    get balanceDate() {
        return this.mainRentAccount?.balanceDate? this.mainRentAccount?.balanceDate : ' --';
    }

    get balanceMessage() {
        if (this.mainRentAccount?.accountBalance === null || this.mainRentAccount?.accountBalance === undefined) {
            return 'Balance not available';
        }
        return parseFloat(this.mainRentAccount?.accountBalance).toFixed(2) > 0.00 ? 
        'You\'re currently in arrears' : 
        'You\'re currently in credit';
    }

    get balanceMessageIcon() {
        if (this.mainRentAccount?.accountBalance === null || this.mainRentAccount?.accountBalance === undefined) {
            return 'action:close';
        }
        return parseFloat(this.mainRentAccount?.accountBalance).toFixed(2)  > 0.00 ? 'utility:expired' : 'utility:success';
    }

    get balanceIconClass() {
       return parseFloat(this.mainRentAccount?.accountBalance).toFixed(2)  > 0.00 ? 'badge-icon' : 'badge-icon badge-icon-green';
    }

    handleMakePayment(event) {
        let prnNumber;
        try{
            prnNumber = generatePRN(this.tenancyNumber,  this.mainRentAccount?.id, this.orchardChequeDigit);
        }catch(error){
            prnNumber = null;
        }

        let url = prnNumber? this.allPayURL.data+prnNumber : this.allPayURL.data;
        const pageref = {
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        };
        this[NavigationMixin.Navigate](pageref);
    }

    handleViewStatements() {
        const pageReference = {
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
                c__occupancyStartDate: this.tenancy.occupancyStartDate,
            }
        };
        this[NavigationMixin.Navigate](pageReference);
        
    }

}