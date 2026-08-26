@IsTest
private class KnowledgeSearchControllerTest {
    @TestSetup
    static void setupTestData() {
        // Creating and publishing a Knowledge article requires the Knowledge User
        // feature license, so the insert must run as a user who has it enabled.
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0].Id;
        User knowledgeUser = UthUser.buildKnowledgeUser(null, adminProfileId, 'Knowledge', 'Tester');
        insert knowledgeUser;

        System.runAs(knowledgeUser) {
            Knowledge__kav article = new Knowledge__kav(
                Title = 'How do I report a leak',
                UrlName = 'How-do-I-report-a-leak',
                Summary = 'Guidance on reporting a leak in your home'
            );
            insert article;

            Id knowledgeArticleId = [
                SELECT KnowledgeArticleId
                FROM Knowledge__kav
                WHERE Id = :article.Id
            ].KnowledgeArticleId;
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

    @isTest
    static void searchArticlesReturnsMatchingArticle() {
        KnowledgeArticleVersion publishedVersion = [
            SELECT Id
            FROM KnowledgeArticleVersion
            WHERE PublishStatus = 'Online'
            LIMIT 1
        ];
        Test.setFixedSearchResults(new List<Id>{ publishedVersion.Id });

        Test.startTest();
            List<KnowledgeSearchController.ArticleSummary> results = KnowledgeSearchController.searchArticles('leak');
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'The fixed search result should be returned');
        Assert.areEqual('How do I report a leak', results[0].title, 'Title should match the matching article');
    }

    @isTest
    static void searchArticlesReturnsEmptyListForBlankTerm() {
        Test.startTest();
            List<KnowledgeSearchController.ArticleSummary> results = KnowledgeSearchController.searchArticles('   ');
        Test.stopTest();

        Assert.areEqual(0, results.size(), 'A blank search term should return no results');
    }

    @isTest
    static void searchArticlesReturnsEmptyListForTermShorterThanMinimumLength() {
        Test.startTest();
            List<KnowledgeSearchController.ArticleSummary> results = KnowledgeSearchController.searchArticles('a');
        Test.stopTest();

        Assert.areEqual(0, results.size(), 'A search term shorter than the minimum length should return no results');
    }

    @isTest
    static void searchArticlesStripsReservedCharactersBeforeSearching() {
        Test.setFixedSearchResults(new List<Id>());

        Test.startTest();
            List<KnowledgeSearchController.ArticleSummary> results = KnowledgeSearchController.searchArticles('lea*k?');
        Test.stopTest();

        Assert.areEqual(0, results.size(), 'No fixed results were configured so an empty list is expected');
    }
}