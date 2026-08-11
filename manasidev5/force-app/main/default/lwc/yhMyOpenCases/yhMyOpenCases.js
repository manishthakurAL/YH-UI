import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMyOpenCases from '@salesforce/apex/YH_PortalController.getMyOpenCases';

const DATE_FORMAT_OPTIONS = { day: 'numeric', month: 'short', year: 'numeric' };
const DESCRIPTION_MAX_LENGTH = 80;

export default class YhMyOpenCases extends NavigationMixin(LightningElement) {
    cases = [];

    @wire(getMyOpenCases)
    wiredCases({ data, error }) {
        if (data) {
            this.cases = data.map((caseRecord) => ({
                caseNumber: caseRecord.caseNumber,
                caseMeta: this.formatCaseMeta(caseRecord.caseNumber, caseRecord.caseType),
                description: this.truncateDescription(caseRecord.description),
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

    formatCaseMeta(caseNumber, caseType) {
        const number = `#${caseNumber}`;
        return caseType ? `${number} · ${caseType}` : number;
    }

    truncateDescription(value) {
        if (!value) {
            return '';
        }
        const singleLine = value.replace(/\s+/g, ' ').trim();
        if (singleLine.length <= DESCRIPTION_MAX_LENGTH) {
            return singleLine;
        }
        return `${singleLine.slice(0, DESCRIPTION_MAX_LENGTH - 1)}…`;
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
