import { LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import searchArticles from '@salesforce/apex/KnowledgeSearchController.searchArticles';
import CP_HelpSearchPlaceholder from '@salesforce/label/c.CP_HelpSearchPlaceholder';
import CP_HelpSearchButton from '@salesforce/label/c.CP_HelpSearchButton';
import CP_HelpSearchNoResults from '@salesforce/label/c.CP_HelpSearchNoResults';
import CP_HelpSearchError from '@salesforce/label/c.CP_HelpSearchError';
import CP_HelpSearchResultsFor from '@salesforce/label/c.CP_HelpSearchResultsFor';
import CP_HelpSearchEnterTerm from '@salesforce/label/c.CP_HelpSearchEnterTerm';
import CP_HelpSearching from '@salesforce/label/c.CP_HelpSearching';

const KNOWLEDGE_ARTICLE_PAGE = 'standard__knowledgeArticlePage';

export default class KnowledgeSearchResults extends NavigationMixin(LightningElement) {
    label = {
        searchPlaceholder: CP_HelpSearchPlaceholder,
        searchButton: CP_HelpSearchButton,
        noResults: CP_HelpSearchNoResults,
        searchError: CP_HelpSearchError,
        searchResultsFor: CP_HelpSearchResultsFor,
        enterTerm: CP_HelpSearchEnterTerm,
        searching: CP_HelpSearching
    };

    searchTerm = '';
    appliedTerm = '';
    searchResults = [];
    isSearching = false;
    statusMessage = '';

    @wire(CurrentPageReference)
    setCurrentPageReference(pageRef) {
        const term = pageRef?.state?.c__term ? pageRef.state.c__term.trim() : '';
        if (term && term !== this.appliedTerm) {
            this.searchTerm = term;
            this.runSearch(term);
        }
    }

    get hasSearchResults() {
        return this.searchResults.length > 0;
    }

    get hasAppliedTerm() {
        return !!this.appliedTerm;
    }

    handleSearchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    handleSearchSubmit(event) {
        event.preventDefault();
        const term = this.searchTerm.trim();
        if (!term) {
            return;
        }
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Knowledge_Search_Results'
            },
            state: {
                c__term: term
            }
        });
        this.runSearch(term);
    }

    handleArticleClick(event) {
        event.preventDefault();
        const { articleType, urlName } = event.currentTarget.dataset;
        this[NavigationMixin.Navigate]({
            type: KNOWLEDGE_ARTICLE_PAGE,
            attributes: {
                articleType,
                urlName
            }
        });
    }

    async runSearch(term) {
        this.appliedTerm = term;
        this.isSearching = true;
        this.statusMessage = '';

        try {
            const data = await searchArticles({ searchTerm: term });
            this.searchResults = await this.generateArticleUrls(data);
            this.statusMessage = this.searchResults.length
                ? `${this.searchResults.length} result${this.searchResults.length === 1 ? '' : 's'} found`
                : this.label.noResults;
        } catch (error) {
            this.searchResults = [];
            this.statusMessage = this.label.searchError;
            // eslint-disable-next-line no-console
            console.error('knowledgeSearchResults: search failed', error);
        } finally {
            this.isSearching = false;
        }
    }

    generateArticleUrls(articles) {
        return Promise.all(
            (articles || []).map((article) =>
                this[NavigationMixin.GenerateUrl]({
                    type: KNOWLEDGE_ARTICLE_PAGE,
                    attributes: {
                        articleType: article.articleType,
                        urlName: article.urlName
                    }
                }).then((url) => ({ ...article, url }))
            )
        );
    }
}