import { LightningElement, api } from 'lwc';
import Id from '@salesforce/user/Id';
import isGuest from '@salesforce/user/isGuest';

export default class AnalyticsSupport extends LightningElement {
@api measurementId;
@api error;

connectedCallback()
{

    //build the event detail object in a structure that works for Google Analytics 
    let payload = { detail: 
        { 
            'user_id': Id, 
            'user_properties': {
                'user_id': Id,
                'user_type': (isGuest) ? 'Unauthenticated' : 'Authenticated'
            }
        }
    };
    //publish custom event for the listener in the head markup to handle
    document.dispatchEvent(new CustomEvent('analyticsSupport', payload));
}

}