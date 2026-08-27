public with sharing class KnowledgeSearchController {
    private static final Integer POPULAR_ARTICLES_LIMIT = 5;
    private static final Integer SEARCH_RESULTS_LIMIT = 10;
    private static final Integer MIN_SEARCH_TERM_LENGTH = 2;

    public class ArticleSummary {
        @AuraEnabled public String articleId;
        @AuraEnabled public String title;
        @AuraEnabled public String urlName;
        @AuraEnabled public String articleType;
    }

    @AuraEnabled(cacheable=true)
    public static List<ArticleSummary> getPopularArticles() {
        List<ArticleSummary> results = new List<ArticleSummary>();
        for (KnowledgeArticleVersion article : [
            SELECT Id, Title, UrlName
            FROM KnowledgeArticleVersion
            WHERE PublishStatus =: KnowledgeDecorator.PUBLISH_STATUS_ONLINE
            WITH SYSTEM_MODE
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
        List<List<SObject>> searchResults = new List<List<SObject>>();
        String sanitizedTerm = sanitizeSearchTerm(searchTerm);
        if (sanitizedTerm == null) {
            return results;
        }

        // TODO login needed to populate surch result

        if (!searchResults.isEmpty()) {
            for (SObject record : searchResults[0]) {
                results.add(toSummary((KnowledgeArticleVersion) record));
            }
        }
        return results;
    }

    private static ArticleSummary toSummary(KnowledgeArticleVersion article) {
        ArticleSummary summary = new ArticleSummary();
        summary.articleId = article.Id;
        summary.title = article.Title;
        summary.urlName = article.UrlName;
        summary.articleType = KnowledgeDecorator.ARTICLE_TYPE;
        return summary;
    }

    private static String sanitizeSearchTerm(String searchTerm) {
        if (String.isBlank(searchTerm)) {
            return null;
        }
        String withoutSpecialChars = searchTerm.replaceAll('[^\\p{L}\\p{N}\\s]', ' ').trim();
        if (withoutSpecialChars.length() < MIN_SEARCH_TERM_LENGTH) {
            return null;
        }
        return withoutSpecialChars;
    }
}