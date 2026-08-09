import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMyOpenCases from '@salesforce/apex/YH_PortalController.getMyOpenCases';

const DATE_FORMAT_OPTIONS = { day: 'numeric', month: 'short', year: 'numeric' };

export default class YhMyOpenCases extends NavigationMixin(LightningElement) {
    cases = [];

    @wire(getMyOpenCases)
    wiredCases({ data, error }) {
        if (data) {
            this.cases = data.map((caseRecord) => ({
                caseNumber: caseRecord.caseNumber,
                caseType: caseRecord.caseType,
                status: caseRecord.status,
                formattedOpenedDate: this.formatDate(caseRecord.openedDate)
            }));
        } else if (error) {
            this.cases = [];
            console.log('Error:', JSON.stringify(error));
        }
    }

    get hasCases() {
        return this.cases.length > 0;
    }

    formatDate(value) {
        if (!value) {
            return '';
        }
        return new Intl.DateTimeFormat('en-GB', DATE_FORMAT_OPTIONS).format(new Date(value));
    }

    handleViewAllCases() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'home'
            }
        });
    }
}
