import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getStatements from '@salesforce/apex/RentStatementController.getStatements';
import understandingRentStamentKAURL from "@salesforce/label/c.UnderstandingRentStatementKAURLName";


export default class RentStatementsList extends NavigationMixin(LightningElement) {
    @api tenancy;
    @api account;
    @api pageSize = 10;
    
    @track allStatements = [];
    @track displayedStatements = [];
    @track isLoading = false;
    @track error;
    @track currentPage = 1;
    @track totalPages = 1;
    @track selectedPeriod = '30days';
    @track customStartDate;
    @track customEndDate;
    @track oneYearFromStartDate;
    @track showCustomRange = false;
    understandingRentStatementURL ='/s/article/'+understandingRentStamentKAURL;

    isLogoLoaded = false;
    
    periodOptions = [
        { label: 'Last 7 Days', value: '7days' },
        { label: 'Last 30 Days', value: '30days' },
        { label: 'Last Quarter', value: 'quarter' },
        { label: 'Last 6 Months', value: '6months' },
        { label: 'Custom Range', value: 'custom' }
    ];

    @wire(CurrentPageReference)
        currentPageReference;

    handleImageLoad() {
        this.isLogoLoaded = true;
    }

    get columns() {
        if (this.isMainRentAccount) {
            return this.rentAccountColumns;
        } else {
            return this.defaultColumns;
        }
    }

    get statmentTableClass() {
        if (this.isMainRentAccount) {
            return 'statements-table seven-columns';
        } else {
            return 'statements-table five-columns';
        }
    }

    get rentAccountColumns() {
        return [
            {
                label: 'Date',
                fieldName: 'balanceDate',
                type: 'text',
                typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric'
                },
                sortable: true
            },
            {
                label: 'Rent',
                fieldName: 'rent',
                type: 'currency',
                typeAttributes: {
                    currencyCode: 'GBP'
                },
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Charge',
                fieldName: 'charge',
                type: 'currency',
                typeAttributes: {
                    currencyCode: 'GBP'
                },
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Benefit',
                fieldName: 'benefit',
                type: 'currency',
                typeAttributes: {
                    currencyCode: 'GBP'
                },
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Payment',
                fieldName: 'payment',
                type: 'currency',
                typeAttributes: {
                    currencyCode: 'GBP'
                },
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Date of Payment',
                fieldName: 'paymentDate',
                type: 'date',
                typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric'
                },
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Balance',
                fieldName: 'formattedBalance',
                type: 'text',
                sortable: true,
                cellAttributes: {
                    alignment: 'left',
                    class: {
                        fieldName: 'balanceClass'
                    }
                }
            }
        ];
    }

    get defaultColumns() {
        return [
            {
                label: 'Date',
                fieldName: 'transactionDate',
                type: 'date',
                typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric'
                },
                sortable: true
            },
            {
                label: this.chargelabel,
                fieldName: 'charge',
                type: 'currency',
                typeAttributes: {
                    currencyCode: 'GBP'
                },
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Payment',
                fieldName: 'payment',
                type: 'currency',
                typeAttributes: {
                    currencyCode: 'GBP'
                },
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Date of Payment',
                fieldName: 'paymentDate',
                type: 'date',
                typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric'
                },
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Balance',
                fieldName: 'formattedBalance',
                type: 'text',
                sortable: true,
                cellAttributes: {
                    alignment: 'left',
                    class: {
                        fieldName: 'balanceClass'
                    }
                }
            }
        ];
    }

    connectedCallback() {
        this.currentPage = 1;        
        if (this.accountId) {
            this.loadStatements();
        }
    }

    handleKeyDown(event) {
        event.preventDefault();
    }

    get hasPermissionViewBreakdowns() {
        return (this.rentTag !== 'Affordable Rent' && 
        this.rentTag !== 'Rent To Buy' &&
        this.rentTag !== 'Intermediate Rent' &&
        this.rentTag !== 'Supported Housing - Affordable Rent' &&
        this.rentTag !== 'Schemes - Affordable' &&
        this.rentTag !== 'Extra Care - Affordable');
    }

    get rentTag() {
        return this.currentPageReference.state.c__rentTag;
    }

    get customerName() {
        return this.currentPageReference.state.c__customerName;
    }

    get tenancyNumber() {
        return this.currentPageReference.state.c__tenancyNumber;
    }

    get propertyType() {
        return this.currentPageReference.state.c__propertyType;
    }

    get accountType() {
        return this.currentPageReference.state.c__accountType;
    }

    get accountId() {
        return this.currentPageReference.state.c__accountId;
    }

    get propertyAddress() {
        return this.currentPageReference.state.c__pAddress;
    }

    get occupancyStartDate() {
        return this.currentPageReference.state.c__occupancyStartDate || new Date().toISOString().split('T')[0];
    }

    get chargelabel() {
        if (this.accountType === 'Main Rent Account') {
            return 'Rent';
        } else if (this.accountType === 'Chargeable Repairs') {
            return 'Charge';
        } else if (this.accountType === 'Legal Costs') {
            return 'Legal Cost';
        } else if (this.accountType === 'Admin Costs') {
            return 'Admin Charges';
        }
        return 'Charge';
    }


    get rentType() {
        return this.currentPageReference.state.c__rentType;
    }

    get chargeFrequency() {
        return this.currentPageReference.state.c__chargeFrequency;
    }

    handlePeriodChange(event) {
        this.selectedPeriod = event.detail.value;
        this.showCustomRange = this.selectedPeriod === 'custom';
    }

    handleCustomStartDateChange(event) {
        this.customStartDate = event.detail.value;
        this.oneYearFromStartDate = new Date(this.customStartDate);
        this.oneYearFromStartDate.setFullYear(this.oneYearFromStartDate.getFullYear() + 1);
        if (this.oneYearFromStartDate > new Date()) {
            this.oneYearFromStartDate = new Date();
        }
    }

    handleCustomEndDateChange(event) {
        this.customEndDate = event.detail.value;
    }

    get disableEndDate() {
        return !this.customStartDate;
    }

    get oneYearFromStartDateISOString() {
        return this.oneYearFromStartDate?.toISOString().split('T')[0] || new Date().toISOString().split('T')[0];
    }

    handleApplyFilter() {

        this.error = undefined;
        this.currentPage = 1;
        this.allStatements = [];
        this.loadStatements();
    }

    loadStatements() {
        if (this.isLoading) return;
        this.isLoading = true;
        const allValid = [
            ...this.template.querySelectorAll('lightning-input')
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (!allValid) {
            this.allStatements = [];
            this.isLoading = false;
            return;
        }
        const filter = {
            period: this.selectedPeriod,
            startDate: this.customStartDate,
            endDate: this.customEndDate,
            pageSize: this.pageSize,
            pageNumber: this.currentPage
        };

        const tenancy = {
            tenancyNumber: this.tenancyNumber,
            chargeFrequency: this.chargeFrequency,
            rentType: this.rentType
        };

        getStatements({ 
            accountId : this.accountId,
            tenancy : JSON.stringify(tenancy),
            filter : JSON.stringify(filter)
        })
        .then(result => {
            console.log('Statements Result:', JSON.stringify(result, null, 2));
            if (result && result.statements.length > 0) {
                this.allStatements = [...result.statements];
                this.error = undefined;
            } else {
                this.isLoading = false;
                return;
            }
            
        })
        .catch(error => {
            this.error = error;
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    get currentDate() {
    return new Date().toLocaleDateString('en-GB', {
        day: 'numeric',
        month: 'long',
        year: 'numeric'
    });
}

    get currentDateTime() {
        return new Date().toLocaleString('en-GB', {
            day: 'numeric',
            month: 'long',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    get selectedPeriodLabel() {
        const period = this.periodOptions.find(opt => opt.value === this.selectedPeriod);
        return period ? period.label : 'All Time';
    }

    get currentBalance() {
        if (this.allStatements.length === 0) return '£0.00';
        const lastStatement = this.allStatements[this.allStatements.length - 1];
        return this.getFormattedCurrency(lastStatement.balance);
    }

    getFormattedDate(dateValue) {
        if (!dateValue) return '-';
        const date = new Date(dateValue);
        return date.toLocaleDateString('en-GB', {
            day: 'numeric',
            month: 'short',
            year: 'numeric'
        });
    }

    getFormattedCurrency(amount) {
        if (amount === null || amount === undefined) return '-';
        return new Intl.NumberFormat('en-GB', {
            style: 'currency',
            currency: 'GBP'
        }).format(amount);
    }

    get formattedStatements() {
        return this.allStatements.map(statement => ({
            ...statement,
            formattedDate: this.getFormattedDate(statement.transactionDate),
            formattedPaymentDate: this.getFormattedDate(statement.paymentDate),
            formattedRent: this.getFormattedCurrency(statement.rent),
            formattedCharge: this.getFormattedCurrency(statement.charge),
            formattedBenefit: this.getFormattedCurrency(statement.benefit),
            formattedPayment: this.getFormattedCurrency(statement.payment),
            formattedBalance: this.getFormattedBalance(statement.balance),
            formattedAmount: this.getFormattedCurrency(statement.amount),
            balanceClass: this.getBalanceClass(statement.balance)
        }));
    }

    getFormattedBalance(balance) {
        let fBalance = parseFloat(balance).toFixed(2);
        if (fBalance < 0.00) {
            return this.getFormattedCurrency(balance) + ' (CR)';
        } else if(fBalance > 0.00) {
            return this.getFormattedCurrency(balance) + ' (AR)';
        } else{
            return this.getFormattedCurrency(balance);
        }
    }
    
    handleAllAccounts() {
        const pageReference = {
            type: 'comm__namedPage',
            attributes: {
                name: 'Rent__c' 
            },
        };
        this[NavigationMixin.Navigate](pageReference);
    }

    handlePrint() {
        let hasError = false;
        try {
            if (this.selectedPeriod === 'custom') {
                const start = new Date(this.customStartDate);
                const end = new Date(this.customEndDate);
                const oneYearLater = new Date(start);
                oneYearLater.setFullYear(start.getFullYear() + 1);
                if (end > oneYearLater) {
                    hasError = true;
                    this.error = 'Please select a time range of no more than 1yr';
                } 

            }
            if (!hasError) {
                this.template.querySelector('c-rent-statement-table').print();
            }
        } catch (err) {
            console.error('Error in handlePrint:', err);
        }   
    }

    

    getBalanceClass(balance) {
        let fBalance = parseFloat(balance).toFixed(2);
        if (fBalance == 0.00) {
            return 'balance-amount';
        } else if(fBalance > 0.00) {
            return 'balance-negative';
        } 
        return 'balance-positive';
    }

    get accountTypeClass() {
        if (this.isMainRentAccount) return 'is-main-rent-account';
        if (this.isGarageAccount) return 'is-garage-account';
        return 'is-default-account';
    }

    get hasStatements() {
        return this.allStatements && this.allStatements.length > 0;
    }

    get isCustomRangeValid() {
        return this.customStartDate && this.customEndDate;
    }

    get isFilterButtonDisabled() {
        return this.selectedPeriod === 'custom' && !this.isCustomRangeValid;
    }

    get hasMorePages() {
        return this.totalPages > 1;
    }

    get errorMessage() {
        return this.error?.body?.message || this.error?.message || this.error || '';
    }

    get isMainRentAccount() {
        return (this.propertyType !== 'Garage' && this.accountType === 'Main Account' );
    }
    
    get isMainRentAccountAllPropertyTypes(){
        return this.accountType === 'Main Account';
    }
}