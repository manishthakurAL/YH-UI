public with sharing class KnowledgeSearchController {
    private static final Integer POPULAR_ARTICLES_LIMIT = 5;
    private static final Integer SEARCH_RESULTS_LIMIT = 10;
    private static final Integer MIN_SEARCH_TERM_LENGTH = 2;

    public class ArticleSummary {
        @AuraEnabled public String articleId;
        @AuraEnabled public String title;
        @AuraEnabled public String urlName;
        @AuraEnabled public String articleType;

        public ArticleSummary(String articleId, String title, String urlName, String articleType){
            this.articleId = articleId;
            this.title = title;
            this.urlName = urlName;
            this.articleType = articleType;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ArticleSummary> getPopularArticles() {
        List<ArticleSummary> results = new List<ArticleSummary>();
        for (KnowledgeArticleVersion article : [
            SELECT Id, Title, UrlName
            FROM KnowledgeArticleVersion
            WHERE PublishStatus =: KnowledgeDecorator.PUBLISH_STATUS_ONLINE
            WITH USER_MODE
            ORDER BY ArticleTotalViewCount DESC NULLS LAST, Title ASC
            LIMIT :POPULAR_ARTICLES_LIMIT
        ]) {
            results.add(toSummary(article));
        }
        return results;
    }

    @AuraEnabled(cacheable=true)
    public static List<ArticleSummary> searchArticles(String searchTerm) {
        List<ArticleSummary> results = new List<ArticleSummary>();
        //TODO logic to be implemented in ticket 42209, this method is place holder for now.
        return results;
    }

    private static ArticleSummary toSummary(KnowledgeArticleVersion article) {
        ArticleSummary summary = new ArticleSummary(
            article.Id, 
            article.Title, 
            article.UrlName, 
            KnowledgeDecorator.ARTICLE_TYPE
        );
        return summary;
    }
}