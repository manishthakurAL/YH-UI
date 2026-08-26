import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPopularArticles from '@salesforce/apex/KnowledgeSearchController.getPopularArticles';
import CP_HelpSearchPlaceholder from '@salesforce/label/c.CP_HelpSearchPlaceholder';
import CP_HelpSearchButton from '@salesforce/label/c.CP_HelpSearchButton';
import CP_HelpPopularSearches from '@salesforce/label/c.CP_HelpPopularSearches';
import CP_HelpNoPopularArticles from '@salesforce/label/c.CP_HelpNoPopularArticles';

const KNOWLEDGE_ARTICLE_PAGE = 'standard__knowledgeArticlePage';
const SEARCH_RESULTS_PAGE_NAME = 'Knowledge_Search_Results';

export default class KnowledgeSearch extends NavigationMixin(LightningElement) {
    label = {
        searchPlaceholder: CP_HelpSearchPlaceholder,
        searchButton: CP_HelpSearchButton,
        popularSearches: CP_HelpPopularSearches,
        noPopularArticles: CP_HelpNoPopularArticles
    };

    searchTerm = '';
    popularArticles = [];

    @wire(getPopularArticles)
    wiredPopularArticles({ data, error }) {
        if (data) {
            this.generateArticleUrls(data).then((articles) => {
                this.popularArticles = articles;
            });
        } else if (error) {
            this.popularArticles = [];
            console.error('knowledgeSearch: unable to load popular articles', error);
        }
    }

    get hasPopularArticles() {
        return this.popularArticles.length > 0;
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
                name: SEARCH_RESULTS_PAGE_NAME
            },
            state: {
                c__term: term
            }
        });
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