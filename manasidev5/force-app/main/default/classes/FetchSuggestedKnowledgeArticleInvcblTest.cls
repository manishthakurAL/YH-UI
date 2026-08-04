@isTest
public with sharing class FetchSuggestedKnowledgeArticleInvcblTest {
    @TestSetup
    static void makeData(){
       Knowledge__kav article = UthKnowledge.create();
       UthKnowledge.addDataCategory(article.Id, KnowledgeDecorator.DATACATEGORY_AUDIENCE, KnowledgeDecorator.DATACATEGORY_EXTERNALLOGGEDIN_LABEL);
       UthKnowledge.addDataCategory(article.Id, KnowledgeDecorator.DATACATEGORY_DOMAIN, CaseDecorator.TYPE_COMPLAINT);
       Knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM Knowledge__kav WHERE id =: article.id];
       KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);

    }

    @isTest
    static void testFilteredArticles(){
        List<Id> articleIds = new List<Id>();
        for(Knowledge__kav article : UthKnowledge.getAll()){
            articleIds.add(article.Id);
        }
        Test.setFixedSearchResults(articleIds);
        FetchSuggestedKnowledgeArticleInvocable.FetchSuggestedKnowledgeArticleInvocableRequest request = new FetchSuggestedKnowledgeArticleInvocable.FetchSuggestedKnowledgeArticleInvocableRequest();
        request.searchTerm = CaseDecorator.TYPE_COMPLAINT;
        request.isDisplayedInPortal = true;
        Test.startTest();
        List<FetchSuggestedKnowledgeArticleInvocable.FetchSuggestedKnowledgeArticleInvocableResult> results = FetchSuggestedKnowledgeArticleInvocable.fetchSuggestedKnowledgeArticle(new List<FetchSuggestedKnowledgeArticleInvocable.FetchSuggestedKnowledgeArticleInvocableRequest>{request});
        articleIds = results[0].suggestedKnowledgeArticles;
        Assert.isTrue(articleIds.size() > 0 , 'Articles should be returned');
        Assert.areEqual(UthKnowledge.getAll()[0].Id, articleIds[0]);
        Test.stopTest();
    }

     @isTest
    static void testDataCategoryNotFound(){
        FetchSuggestedKnowledgeArticleInvocable.FetchSuggestedKnowledgeArticleInvocableRequest request = new FetchSuggestedKnowledgeArticleInvocable.FetchSuggestedKnowledgeArticleInvocableRequest();
        request.searchTerm = 'NoDataCategory';
        request.isDisplayedInPortal = true;
        List<FetchSuggestedKnowledgeArticleInvocable.FetchSuggestedKnowledgeArticleInvocableResult> results;
        String exceptionMessage;
        Test.startTest();
        try{
            results = FetchSuggestedKnowledgeArticleInvocable.fetchSuggestedKnowledgeArticle(new List<FetchSuggestedKnowledgeArticleInvocable.FetchSuggestedKnowledgeArticleInvocableRequest>{request});
        }catch(Exception e){ 
            exceptionMessage = e.getMessage();
            Assert.isNull(results, 'KA should not be returned');
        }finally{
            Assert.isTrue(String.isNotBlank(exceptionMessage), 'Exception message should get populated');
        }
        Test.stopTest();
    }

     @isTest
    static void testFilteredArticlesNotFound(){
        FetchSuggestedKnowledgeArticleInvocable.FetchSuggestedKnowledgeArticleInvocableRequest request = new FetchSuggestedKnowledgeArticleInvocable.FetchSuggestedKnowledgeArticleInvocableRequest();
        request.searchTerm = CaseDecorator.TYPE_COMPLIMENT;
        request.isDisplayedInPortal = true;
        List<FetchSuggestedKnowledgeArticleInvocable.FetchSuggestedKnowledgeArticleInvocableResult> results;
        String exceptionMessage;
        Test.startTest();
        results = FetchSuggestedKnowledgeArticleInvocable.fetchSuggestedKnowledgeArticle(new List<FetchSuggestedKnowledgeArticleInvocable.FetchSuggestedKnowledgeArticleInvocableRequest>{request});
        Test.stopTest();
        List<Id> articleIds = results[0].suggestedKnowledgeArticles;
        Assert.isTrue(articleIds.size() == 0 , 'No Articles should be returned');
    }
}