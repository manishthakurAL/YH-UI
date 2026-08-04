public with sharing class FetchSuggestedKnowledgeArticleInvocable {
    @InvocableMethod
    public static List<FetchSuggestedKnowledgeArticleInvocableResult> fetchSuggestedKnowledgeArticle(List<FetchSuggestedKnowledgeArticleInvocableRequest> requests) {
        List<FetchSuggestedKnowledgeArticleInvocableResult> results = new List<FetchSuggestedKnowledgeArticleInvocableResult>();
        if(requests.size() > 1){
            throw new AuraHandledException('Only one request is allowed.');
        }
        for (FetchSuggestedKnowledgeArticleInvocableRequest request : requests) {
            try{
                FetchSuggestedKnowledgeArticleInvocableResult result = new FetchSuggestedKnowledgeArticleInvocableResult();
                String sosl = 'FIND \'' + String.escapeSingleQuotes(request.searchTerm) + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion (Id, Title WHERE PublishStatus=\''+String.escapeSingleQuotes(KnowledgeDecorator.KNOWLEDGE_PUBLISH) +'\') WITH DATA CATEGORY Audience__c AT '+ String.escapeSingleQuotes(KnowledgeDecorator.DATACATEGORY_EXTERNALLOGGEDIN)  + ' AND Domain__c AT ' + string.escapeSingleQuotes(KnowledgeDecorator.DATA_CATEGORY_LABEL_BY_DEV_NAME.get(request.searchTerm));
                if( String.isNotEmpty(KnowledgeDecorator.INTENT_BY_DOMAIN.get(request.searchTerm))){
                    sosl += ' AND Intent__c AT ' + String.escapeSingleQuotes(KnowledgeDecorator.INTENT_BY_DOMAIN.get(request.searchTerm));
                } 
                List<List<SObject>> searchList = search.query(sosl);
                List<KnowledgeArticleVersion> articles = (List<KnowledgeArticleVersion>)searchList[0];
                for(KnowledgeArticleVersion article : articles){
                    result.suggestedKnowledgeArticles.add(article.Id);
                }
                results.add(result);
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        return results;
    }

    public class FetchSuggestedKnowledgeArticleInvocableRequest {
        @InvocableVariable
        public String searchTerm;
        @InvocableVariable
        public Boolean isDisplayedInPortal;
    }

    public class FetchSuggestedKnowledgeArticleInvocableResult{
        @AuraEnabled @InvocableVariable
        public List<Id> suggestedKnowledgeArticles;
        public FetchSuggestedKnowledgeArticleInvocableResult(){
            suggestedKnowledgeArticles = new List<Id>();
        }
    }
}