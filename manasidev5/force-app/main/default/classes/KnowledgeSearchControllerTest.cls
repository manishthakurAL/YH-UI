@IsTest
private class KnowledgeSearchControllerTest {
    @TestSetup
    static void setupTestData() {
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0].Id;
        User knowledgeUser = UthUser.buildKnowledgeUser(null, adminProfileId, 'Knowledge', 'Tester');
        insert knowledgeUser;

        System.runAs(knowledgeUser) {
            Knowledge__kav article = UthKnowledge.build(
                'How do I report a leak',
                'Guidance on reporting a leak in your home',
                'How-do-I-report-a-leak'
            );
            insert article;

            Id knowledgeArticleId = UthKnowledge.getUsingId(article.Id)[0].KnowledgeArticleId;
            KbManagement.PublishingService.publishArticle(knowledgeArticleId, true);
        }
    }

    @isTest
    static void getPopularArticlesReturnsPublishedArticle() {
        Test.startTest();
            List<KnowledgeSearchController.ArticleSummary> results = KnowledgeSearchController.getPopularArticles();
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Only the published article should be returned');
        Assert.areEqual('How do I report a leak', results[0].title, 'Title should match the published article');
        Assert.areEqual('How-do-I-report-a-leak', results[0].urlName, 'UrlName should match the published article');
        Assert.areEqual('Knowledge__kav', results[0].articleType, 'ArticleType should identify the knowledge article type');
    }
}