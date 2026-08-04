import { LightningElement } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class RedirectToCommunityPage extends NavigationMixin(LightningElement) {
	connectedCallback(){

		this[NavigationMixin.Navigate]({

			type: 'comm__namedPage',

			attributes: {

				pageName:'comm-my-account'   // url string after the forward slash in page config

			}

		});
    }
}