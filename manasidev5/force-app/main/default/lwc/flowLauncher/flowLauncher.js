import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import userId from '@salesforce/user/Id';
import isGuest from '@salesforce/user/isGuest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FlowLauncher extends LightningElement {
    @api flowName = 'SF_Community_Create_Web_to_Case';
    @api requestType = 'ending-my-tenancy';
    
    isFlowActive = false;
    flowInputVariables = [];
    urlParameters = {};
    availableParameters = [];

    connectedCallback() {
    }

    @wire(CurrentPageReference)
    currentPageReference(pageRef) {
        if (pageRef && pageRef.state) {
            this.urlParameters = pageRef.state;
            this.availableParameters = Object.keys(this.urlParameters);
            this.initializeFlow();
        }
    }

    get isGuestUser() {
        return isGuest;
    }

    get userId() {
        return userId;
    }

    initializeFlow() {
        this.flowInputVariables = [{
            name: 'isGuestUserPortal',
            type: 'Boolean',
            value: this.isGuestUser
        }];
        if (!this.isGuestUser) {
            this.flowInputVariables.push({
                name: 'requestType',
                type: 'String',
                value: this.requestType
            });
        }
        if (this.availableParameters.length > 0) {
            this.availableParameters.forEach(paramName => {
                if (paramName.startsWith('c__')) {
                    const paramValue = this.urlParameters[paramName];
                    const flowVariableName = this.convertToFlowVariableName(paramName);
                    this.flowInputVariables.push({
                        name: flowVariableName,
                        type: 'String',
                        value: paramValue
                    });
                }
            });
        }
        this.isFlowActive = true;
        console.log('Flow Input Variables:', JSON.stringify(this.flowInputVariables, null, 2));
    }

    convertToFlowVariableName(paramName) {
        return paramName
            .replace(/^c__/, '');
    }

    handleFlowStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            // this.isFlowActive = false;
            
        } else if (event.detail.status === 'ERROR') {
        
        } else if (event.detail.status === 'FINISHED_SCREEN') {
           
        }
    }


    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }



}