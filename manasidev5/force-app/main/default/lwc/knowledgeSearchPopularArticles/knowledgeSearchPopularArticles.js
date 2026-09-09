import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPopularArticles from '@salesforce/apex/KnowledgeSearchController.getPopularArticles';
import * as labels from 'c/labelService';

const KNOWLEDGE_ARTICLE_PAGE = 'standard__knowledgeArticlePage';
const path = window.location.pathname;

export default class KnowledgePopularArticles extends NavigationMixin(LightningElement) {
    label = {
        popularSearches: labels.CP_HelpPopularSearches,
        noPopularArticles: labels.CP_HelpNoPopularArticles
    };

    popularArticles = [];

    @wire(getPopularArticles)
    wiredPopularArticles({ data, error }) {
        if (!path.includes('/global-search')) {
            if (data) {
                this.generateArticleUrls(data).then((articles) => {
                    this.popularArticles = articles;
                });
            } else if (error) {
                this.popularArticles = [];
                console.error('knowledgeSearch: unable to load popular articles', error);
            }
        }
    }

    get hasPopularArticles() {
        return this.popularArticles.length > 0;
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