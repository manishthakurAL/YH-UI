import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import * as labels from 'c/labelService';

const SEARCH_RESULTS_PAGE_NAME = 'Knowledge_Search_Results';

export default class KnowledgeSearch extends NavigationMixin(LightningElement) {
    label = {
        searchPlaceholder: labels.CP_HelpSearchPlaceholder,
        searchButton: labels.CP_HelpSearchButton
    };

    searchTerm = '';

    handleSearchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    //Added
    getSiteBasePath() {
        const path = window.location.pathname;

        const sitePath = path.match(/^\/[^/]+\/s\//);

        return sitePath ? sitePath[0] : '/';
    }
    //Ended

    handleSearchSubmit(event) {
        event.preventDefault();
        const term = this.searchTerm.trim();
        if (!term) {
            return;
        }

        const siteBasePath = this.getSiteBasePath(); //Added

        const searchUrl = siteBasePath + 'global-search/' + encodeURIComponent(term); //Added

        // const pageReference = {
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/global-search/' + encodeURIComponent(term)
        //     }
        // }; 
        //Added
        const currentPath = window.location.pathname;

        // Home page
        const isHomePage =
        currentPath === siteBasePath ||
        currentPath === siteBasePath.slice(0, -1);

        if (isHomePage) {
            // Home page → new tab
            window.open(searchUrl, '_blank', 'noopener');
        } else {
            // Other pages → same tab
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: searchUrl
                }
            });
        }

        //End

        //this[NavigationMixin.Navigate](pageReference);              
        /*this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: SEARCH_RESULTS_PAGE_NAME
            },
            state: {
                c__term: term
            }
        });*/
    }
}