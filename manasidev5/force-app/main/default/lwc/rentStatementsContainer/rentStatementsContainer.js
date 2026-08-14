import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { generatePRN } from "c/generatePRNService";
import getTenancies from '@salesforce/apex/RentStatementController.getTenancies';
import getAccountsByTenancyNumber from '@salesforce/apex/RentStatementController.getAccountsByTenancyNumber';
import getallPayURL from '@salesforce/apex/RentStatementController.getAllPayPaymentURL';

export default class RentStatementsContainer extends NavigationMixin(LightningElement) {
    @track tenancyData = [];
    @track isLoading = true;
    @track error = undefined;
    @track allPayURL;
    firstLoad = false;
 

    @wire(getallPayURL)
        allPayURL;

    @wire(getTenancies)
    getTenancies({ error, data }) {
        if (data === undefined && error === undefined) {
            return;
        }
        this.isLoading = false;
        if (data && data.length > 0) {
            this.tenancyData = data.map(tenancy => ({
                ...tenancy,
                isExpanded: false,          
                accounts: null,             
                isLoadingAccounts: true,
                hasMainRentAccount: false,
                hasError : false 
            }));
            // this.expandFirstTenancy();
            this.error = undefined;
        } else if (error) {
            console.error(JSON.stringify(error))
            this.error = error;
            this.tenancyData = [];
        }
    }

    expandFirstTenancy(){
        if(this.tenancyData && this.tenancyData.length > 0){
            const firstTenancy = this.tenancyData[0];
            this.handleExpandTenancy({ detail: { tenancyNumber: firstTenancy.tenancyNumber, isExpanded: true } });
        }   
    }

    renderedCallback() {
        if (!this.firstLoad && this.tenancyData.length > 0) {
            this.firstLoad = true;
            this.expandFirstTenancy();
        }
    }


    handleMakePayment(event) {
        let tenancyNumber = event.detail?.tenancyNumber;
        let orchardChequeDigit = event.detail.orchardChequeDigit;
        let prnNumber;
        try{
            console.log('Generating PRN for tenancyNumber: ' + tenancyNumber + ', accountId: ' + event.detail?.accountid + ', orchardChequeDigit: ' + orchardChequeDigit);
            prnNumber = generatePRN(tenancyNumber, event.detail?.accountid, orchardChequeDigit);
            console.log('Generated PRN: ' + prnNumber);
        }catch(error){
            prnNumber = null;
            console.log('Error generating PRN: ' + error);
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

    handleViewStatements(event) {
        const accountId = event.detail;
    }


  handleExpandTenancy(event) {  
    try{
            const { tenancyNumber, isExpanded } = event.detail;
            const tenancy = this.tenancyData.find(
                t => t.tenancyNumber === tenancyNumber
            );
            if (!tenancy) return;

            const newExpandedState = isExpanded;
            // Toggle expand/collapse
            this.tenancyData = this.tenancyData.map(t => {
                if (t.tenancyNumber === tenancyNumber) {
                    return {
                        ...t,
                        isExpanded: newExpandedState,
                        isLoadingAccounts: newExpandedState && !t.accounts ? true : false
                    };
                }
                return t;
            });

            // If collapsing → stop here
            if (!newExpandedState) return;

        // If accounts are already loaded, no need to call Apex
        if (tenancy.accounts && tenancy.accounts.length > 0) {
            return;
        }

            getAccountsByTenancyNumber({ tenancyNumber : tenancyNumber, orchardChequeDigit: tenancy.orchardChequeDigit })
                .then(
                    accounts => {
                    this.tenancyData = this.tenancyData.map(t => {
                        if (t.tenancyNumber === tenancyNumber) {
                            return {
                                ...t,
                                accounts: accounts,
                                isExpanded: true,
                                isLoadingAccounts: false,
                                hasMainRentAccount: accounts.some(account => account.id === '0'),
                                hasError: false
                            };
                        }
                        return t;
                    });
                })
            .catch(error => {
                this.tenancyData = this.tenancyData.map(t => {
                    if (t.tenancyNumber === tenancyNumber) {
                        return {
                            ...t,
                            accounts: [],
                            isLoadingAccounts: false,
                            hasError: true,
                            errorMessage: error?.body?.message
                        };
                    }
                    return t;
                });
            });

        } catch (error) {
            console.error('Error in handleExpandTenancy:', error);
        }

    }

    get hasTenancyData() {
        return this.tenancyData && this.tenancyData.length > 0;
    }

    get errorMessage() {
        return this.error ? this.error.message : '';
    }
}