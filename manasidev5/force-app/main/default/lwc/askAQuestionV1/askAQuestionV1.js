import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

const ASK_A_QUESTION_PAGE_NAME = 'Ask_a_question__c';

export default class askAQuestionV1 extends NavigationMixin(LightningElement) {
    handleClick() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: ASK_A_QUESTION_PAGE_NAME
            }
        });
    }
}