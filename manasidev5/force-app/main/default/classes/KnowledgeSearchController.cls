public with sharing class KnowledgeSearchController {
    private static final Integer POPULAR_ARTICLES_LIMIT = 5;
    private static final Integer SEARCH_RESULTS_LIMIT = 10;
    private static final Integer MIN_SEARCH_TERM_LENGTH = 2;
    private static final String ARTICLE_TYPE = 'Knowledge__kav';
    private static final String CATEGORY_GROUP = 'Category__c'; //Added

    public class ArticleSummary {
        @AuraEnabled public String articleId;
        @AuraEnabled public String title;
        @AuraEnabled public String summary;
        @AuraEnabled public String urlName;
        @AuraEnabled public String articleType;
    }

    @AuraEnabled(cacheable=true)
    public static List<ArticleSummary> getPopularArticles() {
        List<ArticleSummary> results = new List<ArticleSummary>();
        for (KnowledgeArticleVersion article : [
            SELECT Id, Title, UrlName, Summary
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online'
                AND Language = :UserInfo.getLanguage()
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
        String sanitizedTerm = sanitizeSearchTerm(searchTerm);
        if (sanitizedTerm == null) {
            return results;
        }

        Map<Id, KnowledgeArticleVersion> articleMap = new Map<Id, KnowledgeArticleVersion>(); //Added

        // PublishStatus and Language must be literals here: the platform rejects bind
        // variables for these fields in a SOSL RETURNING clause on KnowledgeArticleVersion.
        String categoryName = searchTerm;
        sanitizedTerm = sanitizedTerm + '*';
        List<List<SObject>> searchResults = [
            //FIND :sanitizedTerm IN ALL FIELDS
            FIND :sanitizedTerm IN ALL FIELDS
            RETURNING KnowledgeArticleVersion(
                Id, Title, UrlName, Summary
                WHERE PublishStatus = 'Online'
                    AND Language = 'en_US'
                    AND IsVisibleInCsp = true
                ORDER BY ArticleTotalViewCount DESC NULLS LAST
                LIMIT :SEARCH_RESULTS_LIMIT
            )
            WITH SYSTEM_MODE
        ];

        if (!searchResults.isEmpty()) {
            for (SObject record : searchResults[0]) {
                KnowledgeArticleVersion article = (KnowledgeArticleVersion) record;

                articleMap.put(article.Id, article); //Added
            }
        }
        // return results; commented

        //Added
        if (isValidCategoryName(categoryName)) {
            System.debug(LoggingLevel.DEBUG, 'If isValidCategoryName: ' + isValidCategoryName(categoryName) );
            try {
                List < List < SObject >> categorySearchResults = searchArticlesByCategory(categoryName);
                    if (!categorySearchResults.isEmpty()) {
                        for (SObject record: categorySearchResults[0]) {
                            KnowledgeArticleVersion article = (KnowledgeArticleVersion) record; 
                            articleMap.put(article.Id, article);
                        }
                    }   
                } catch (Exception ex) {
                    System.debug(LoggingLevel.DEBUG, 'Category search skipped for term: ' + categoryName + '. Error: ' + ex.getMessage());
                }
        }

        for (KnowledgeArticleVersion article: articleMap.values()) {
            results.add(toSummary(article));
        }

        if (results.size() > SEARCH_RESULTS_LIMIT) {
            List < ArticleSummary > limitedResults = new List < ArticleSummary > ();
                for (Integer i = 0; i < SEARCH_RESULTS_LIMIT; i++) {
                    limitedResults.add(results[i]);
                }
            return limitedResults;
        }
            
        return results;
    }

    private static List < List < SObject >> searchArticlesByCategory(String categoryName) {
        System.debug(LoggingLevel.DEBUG, 'searchArticlesByCategory: ' + categoryName );
        String soslQuery = 'FIND {'+ categoryName +'} IN ALL FIELDS ' + 'RETURNING KnowledgeArticleVersion(' + 'Id, ' 
                                                                                            + 'Title, ' 
                                                                                            + 'UrlName, ' 
                                                                                            + 'Summary ' 
                                                                                            + 'WHERE PublishStatus = \'Online\' ' 
                                                                                            + 'AND Language = \'en_US\' ' 
                                                                                            + 'AND IsVisibleInCsp = true ' 
                                                                                            + 'ORDER BY ArticleTotalViewCount DESC NULLS LAST ' 
                                                                                            + 'LIMIT ' + SEARCH_RESULTS_LIMIT + ') ' 
                                                                                            + 'WITH DATA CATEGORY ' 
                                                                                            + CATEGORY_GROUP + ' AT ' + categoryName + '__c';
        System.debug(LoggingLevel.DEBUG, 'Category SOSL Query: ' + soslQuery);
        return Search.query(soslQuery);
    }

    
    private static Boolean isValidCategoryName(String categoryName) {
        System.debug(LoggingLevel.DEBUG, 'categoryName: ' + categoryName );
        if (String.isBlank(categoryName)) {
            return false;
        }
        Pattern validPattern = Pattern.compile('^[A-Za-z0-9_]+$');
        Matcher matcher = validPattern.matcher(categoryName);
        System.debug(LoggingLevel.DEBUG, 'isValidCategoryName: ' + matcher.matches() );
        return matcher.matches();
    }
    
    private static ArticleSummary toSummary(KnowledgeArticleVersion article) {
        ArticleSummary summary = new ArticleSummary();
        summary.articleId = article.Id;
        summary.title = article.Title;
        summary.summary = article.Summary;
        summary.urlName = article.UrlName;
        summary.articleType = ARTICLE_TYPE;
        return summary;
    }

    private static String sanitizeSearchTerm(String searchTerm) {
        if (String.isBlank(searchTerm)) {
            return null;
        }
        /*String withoutSpecialChars = searchTerm.replaceAll('[^\\p{L}\\p{N}\\s]', ' ').trim();
        if (withoutSpecialChars.length() < MIN_SEARCH_TERM_LENGTH) {
            return null;
        }
        return withoutSpecialChars;*/
        //Added
        String term = searchTerm.trim();

        if (term.length() < MIN_SEARCH_TERM_LENGTH) {
            return null;
        }

        // Remove characters that are unsafe/unwanted in the search term,
        // but preserve normal words and spaces.
        term = term.replaceAll('[^\\p{L}\\p{N}\\s]', ' ').trim();

        // Collapse multiple spaces.
        term = term.replaceAll('\\s+', ' ').trim();

        if (term.length() < MIN_SEARCH_TERM_LENGTH) {
            return null;
        }

        return term;
        //End
    }
}