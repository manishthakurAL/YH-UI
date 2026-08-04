import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//import getFilteredRepairs from '@salesforce/apex/RepairViewController.getFilteredRepairs';


export default class RepairItem extends NavigationMixin(LightningElement) {
    @api tenancy;
    @api isexpanded = false;
    @api showbacktoallaccountsbtn = false;
    @api isloadingrepairs;
    @api isDisplayedOnFlexiPage;
    oneYearFromStartDate;
    selectedPeriod = '6months';
    showCustomRange = false;
    showDetails = false;
    detailRepairItem = false;
    repairItem;
    status = 'Open';
    toDate;
    fromDate;
    
    periodOptions = [
        { label: 'Last 7 Days', value: '7days' },
        { label: 'Last 30 Days', value: '30days' },
        { label: 'Last Quarter', value: 'quarter' },
        { label: 'Last 6 Months', value: '6months' },
        { label: 'Custom Range', value: 'custom' }
    ];

    filterOptions = [
        { label: 'Open', value: 'Open'},
        { label: 'Complete', value: 'Complete' },
        { label: 'All', value: null }
    ];

    get oneYearFromStartDateISOString() {
        return this.oneYearFromStartDate?.toISOString().split('T')[0] || new Date().toISOString().split('T')[0];
    }

    get disableEndDate() {
        return !this.fromDate;
    }

    get occupancyStartDate() {
        return this.tenancy?.occupancyStartDate ? new Date(this.tenancy.occupancyStartDate).toISOString().split('T')[0] : new Date().toISOString().split('T')[0];
    }

    connectedCallback() {
        this.toDate = new Date();
        this.fromDate = new Date();
        this.fromDate.setMonth(this.fromDate.getMonth() - 6);
    }

    handlePeriodChange(event) {
        this.selectedPeriod = event.detail.value;
        this.showCustomRange = this.selectedPeriod === 'custom';
        this.toDate = new Date();
        switch (this.selectedPeriod) {
            case '7days':   
            {
                this.fromDate = new Date(); 
                this.fromDate.setDate(this.fromDate.getDate() - 7);
                break;
            }
            case '30days': {
                this.fromDate = new Date();
                this.fromDate.setDate(this.fromDate.getDate() - 30);
                break;
            }
            case 'quarter': {
                this.fromDate = new Date();
                this.fromDate.setMonth(this.fromDate.getMonth() - 3);
                break;
            }
            case '6months': {
                this.fromDate = new Date();
                this.fromDate.setMonth(this.fromDate.getMonth() - 6);
                break;
            }
            case 'custom': {
                this.fromDate = null;
                this.toDate = null;
                break;
            }
        }
    }

    handleApplyFilter(e) {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input')
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (!allValid) {
            return;
        }
        let dateOfOccupancy = this.tenancy?.occupancyStartDate ? new Date(this.tenancy.occupancyStartDate) : new Date();
        if (dateOfOccupancy > this.fromDate) {
            this.fromDate = dateOfOccupancy;
        }
        const filter = {
            startDate: this.fromDate,
            endDate: this.toDate,
            status: this.status,
        };
        e.preventDefault();
        this.dispatchEvent(new CustomEvent('filter',{
            detail :{
                'tenancyNumber' : this.tenancy.tenancyNumber,
                'propertyNumber' : this.tenancy.propertyNumber,
                'fromDate' : this.fromDate,
                'toDate' : this.toDate, 
                'status' : this.status
            }
        }));
    }

    handleKeyDown(event) {
        event.preventDefault();
    }
   
    handleToDateChange(e){
        this.toDate = e.target.value;
    }

    handleFromDateChange(e){
        this.fromDate = e.target.value;
        this.oneYearFromStartDate = new Date(this.fromDate);
        this.oneYearFromStartDate.setFullYear(this.oneYearFromStartDate.getFullYear() + 1);
        if (this.oneYearFromStartDate > new Date()) {
            this.oneYearFromStartDate = new Date();
        }
    }

    handleSelection(e){
        this.status = e.target.value;
    }


    handleToggle(e) {
        e.preventDefault();
        //this.isexpanded = !this.isexpanded;
        this.dispatchEvent(new CustomEvent('expand',{
            detail :{
                'tenancyNumber' : this.tenancy.tenancyNumber,
                'propertyNumber' : this.tenancy.propertyNumber,
                'status' : this.status
            }
        }));
    }

    handleDetails(event){
        //this.detailRepairItem = true;
        this.repairItem = event.detail;
        this.dispatchEvent(new CustomEvent('handledetails',{
            detail :{
                repairitem : this.repairItem,
                propertyAddress : this.tenancy.propertyAddress
            }
        }));
    }

    handlebacktoallaccounts(){
        this.dispatchEvent(new CustomEvent('backtoallaccounts'));
    }

    get chevronIcon() {
        return this.isexpanded ? 'utility:chevronup' : 'utility:chevrondown';
    }

    get toggleAltText() {
        return this.isexpanded ? 'Collapse' : 'Expand';
    }
    
    get hasRepairs() {
        return this.tenancy.repairs && this.tenancy.repairs.length > 0;
    }  

    get isCustomRangeValid() {
        return this.toDate && this.fromDate;
    }

    get isDisplayedOnPortal (){
        return !this.isDisplayedOnFlexiPage;

    }

   
}