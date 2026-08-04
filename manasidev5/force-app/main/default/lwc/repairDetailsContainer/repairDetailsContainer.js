import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRepairsList from '@salesforce/apex/RepairViewController.getRepairsRelatedTenancy';
import getDetails from '@salesforce/apex/RepairViewController.getRepairDetails';
import getTenancies from '@salesforce/apex/RepairViewController.getTenancies';

export default class ReportDetailsContainer extends NavigationMixin(LightningElement) {
    repairsData = [];
    tenancyData = [];
    isLoading = true;
    error = undefined;
    singlerepairdetail;
    showDetails = false;
    showrRepairItemDetil;
    singlerepairdetailsMoreInfo;
    showRepairsRelatedToProperty = false;
    parentTenancyDetail;
    propertyAddress;
    @api isDisplayedOnFlexiPage = false;
    @api recordId;

    connectedCallback() {
        if( !this.recordId ){
            getTenancies({  recordId: null })
            .then(result => {
               this.handleTenancyWrapperResults(result);
               this.showFirstTenancyDetails();
            })
            .catch(error => {
                console.error(JSON.stringify(error))
                this.error = error;
                this.tenancyData = [];
            })
        }
    }

   @wire(getTenancies, { recordId: '$recordId' })
    wiredRepairsDetail({ error, data }) {
        this.isLoading = false;
        if (data) {
           this.handleTenancyWrapperResults(data);
        } else if (error) {
            console.error(JSON.stringify(error))
            this.error = error;
            this.tenancyData = [];
        }
    }

    showFirstTenancyDetails(){
        if(this.tenancyData && this.tenancyData.length > 0){
            const firstTenancy = this.tenancyData[0];
            this.handleRepairDetailsView({ detail: { tenancyNumber: firstTenancy.tenancyNumber, propertyNumber: firstTenancy.propertyNumber, status : 'Open' } });
        }   
    }

    handleTenancyWrapperResults(result){
        this.error = undefined;
        this.tenancyData = result.map(tenancy => ({
            ...tenancy,
            isExpanded: false,          
            repairs: null,             
            isLoadingRepairs: true,
            hasError : false 
            }));
    }
    
    handleBackToSingleTenancyRepair(){
        this.showDetails = false;
        this.showRepairsRelatedToProperty = true;

    }

    handleDetails(event) {
        this.isLoading = true;
        this.singlerepairdetail = event.detail.repairitem;
        this.propertyAddress = event.detail.propertyAddress
        //this.singlerepairdetailsMoreInfo = event.detail.repairitem;
        getDetails({ jobNumber : this.singlerepairdetail?.jobNumber})
                    .then(
                        repairDetails => {
                            this.singlerepairdetailsMoreInfo = repairDetails;
                            this.error = undefined;
                    })
                    .catch(error => {
                        this.error = error;
                    })
                    .finally(() => {
                        this.isLoading = false;
                        this.showDetails = true;
                    }); 

    }

    get hasTenancyData() {
        return this.tenancyData && this.tenancyData.length > 0;
    }

    get hasRepairsData() {
        return this.repairsData && this.repairsData.length > 0;
    }

    get errorMessage() {
        return this.error ? this.error.message : '';
    }

    get showReportToRepair(){
        return !this.isDisplayedOnFlexiPage;
    }
    get showAdditionalFields(){
        return this.isDisplayedOnFlexiPage;
    }
    
    handleRepairDetailsView(event){
        this.isLoading = true;
        const tenancyNumber = event?.detail?.tenancyNumber;
        const propertyNumber = event?.detail?.propertyNumber;
        const status = event?.detail?.status;
         const tenancy = this.tenancyData.find(
            t => t.tenancyNumber === tenancyNumber
        );
        tenancy.isExpanded = !tenancy.isExpanded;
        if (!tenancy.isLoadingRepairs) {
            this.tenancyData = [...this.tenancyData];
            this.isLoading = false;
            return;
        } 
        getRepairsList({ tenancyNumber : tenancyNumber, propertyNumber: propertyNumber, status : status, fromDate : null, toDate : null})
                    .then(
                        repairs => {
                            tenancy.repairs = repairs;
                            this.error = undefined;
                    })
                    .catch(error => {
                        tenancy.repairs = [];
                        this.error = error;
                    })
                    .finally(() => {
                        tenancy.isLoadingRepairs = false;
                        this.tenancyData = [...this.tenancyData];
                        this.isLoading = false;
                        this.showDetails = false;
                        this.showRepairsRelatedToProperty = true;
                    });       
    }

    handlebacktoalltenancies(){
        this.showRepairsRelatedToProperty = false;
        this.showDetails = false;
    }

    handleRepairFilter(event){
        this.isLoading = true;
        const tenancyNumber = event?.detail?.tenancyNumber;
        const propertyNumber = event?.detail?.propertyNumber;
        const status = event?.detail?.status;
        const fromDate = event?.detail?.fromDate;
        const toDate = event?.detail?.toDate;

         const tenancy = this.tenancyData.find(
            t => t.tenancyNumber === tenancyNumber
        );
        tenancy.isLoadingRepairs = true; 
        tenancy.repairs = [];   
        this.tenancyData = [...this.tenancyData];
        getRepairsList({ tenancyNumber : tenancyNumber, propertyNumber: propertyNumber, status : status, fromDate : fromDate, toDate : toDate})
                    .then(
                        filteredRepairs => {
                            
                            let deduped = Array.from(
                                                    new Map(filteredRepairs.map(r => [r.jobNumber, r])).values()
                                            );

                            if (deduped && deduped.length > 0) {
                                    tenancy.repairs = [...deduped];
                            } 
                            else{
                                    tenancy.repairs = [];
                            }
                            this.error = undefined;                   
                     })
                    .catch(error => {
                        tenancy.repairs = null;
                        this.error = error;
                    })
                    .finally(() => {
                        tenancy.isLoadingRepairs = false;
                        this.tenancyData = [...this.tenancyData];
                        this.isLoading = false;
                        
                    });
    }

    invokeReportRepairFlow(){
        const pageReference = {
            type: 'comm__namedPage',
            attributes: {
                name: 'Report_A_Repair__c' 
            },
        };
        this[NavigationMixin.Navigate](pageReference);
    }

}