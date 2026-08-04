import { LightningElement} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import AbestosPortalUrl from '@salesforce/label/c.FSMobileAbestosPortalUrl';
import HealthSafetyAssessments from '@salesforce/label/c.FSMobileHealthSafetyAssessments';
import TPGO from '@salesforce/label/c.FSMobileTPGO';
import SIRFForm from '@salesforce/label/c.FSMobileSIRFForm';
import Launchpad from '@salesforce/label/c.FSMobileLaunchpad';

export default class UsefulLinks extends NavigationMixin(LightningElement) {
    links = [
        {
            label: 'Asbestos Portal',
            url: AbestosPortalUrl,
            icon: "utility:table"
        },
        {
            label: 'Health & Safety Assessments',
            url: HealthSafetyAssessments,
            icon: "utility:copy"
        },
        {
            label: 'TP GO',
            url: TPGO,
            icon: "utility:link"
        },
        {
            label: 'SIRF Form',
            url: SIRFForm,
            icon: "utility:incident"
        },
        {
            label: 'Launchpad',
            url: Launchpad,
            icon: "utility:apps"
        }
    ];

    handleClick(event) {
        const url = event.target.dataset.url;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        });
    }
}