import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class AskQuestionButton extends NavigationMixin(LightningElement) {
    handleClick() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Ask_a_question__c' 
            }
        });
    }
}