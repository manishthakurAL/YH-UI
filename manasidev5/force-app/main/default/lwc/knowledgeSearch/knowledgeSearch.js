import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPopularArticles from '@salesforce/apex/KnowledgeSearchController.getPopularArticles';
import * as labels from 'c/labelService';

const KNOWLEDGE_ARTICLE_PAGE = 'standard__knowledgeArticlePage';
const SEARCH_RESULTS_PAGE_NAME = 'Knowledge_Search_Results';

export default class KnowledgeSearch extends NavigationMixin(LightningElement) {
    label = {
        searchPlaceholder: labels.CP_HelpSearchPlaceholder,
        searchButton: labels.CP_HelpSearchButton,
        popularSearches: labels.CP_HelpPopularSearches,
        noPopularArticles: labels.CP_HelpNoPopularArticles
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