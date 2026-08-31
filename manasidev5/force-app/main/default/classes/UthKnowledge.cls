public with sharing class UthKnowledge {
    public static Knowledge__kav create(){
        Knowledge__kav article = new Knowledge__kav();
        article.Title = 'Test Article Complaint';
        article.Summary = 'Complaint';
        article.urlName ='Test'+System.currentTimeMillis();
        article.Language = 'en_US';
        insert article;
       
        return article;
    }

    public static Knowledge__kav build(String title, String summary, string urlName){
        return new Knowledge__kav(
            Title = title,
            Summary = summary,
            urlName = urlName,
            Language = 'en_US'
        );
    }

     public static void addDataCategory(Id articleId, String dataCategoryGroupName, String dataCategory){
        Knowledge__DataCategorySelection dcs = new Knowledge__DataCategorySelection(
            ParentId = articleId,
            DataCategoryGroupName = dataCategoryGroupName ,    
            DataCategoryName = dataCategory                 
        );

        insert dcs;
    }

    public static List<Knowledge__kav> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(Knowledge__kav.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM Knowledge__kav '
		);
    }

    public static List<Knowledge__kav> getUsingId(Id articleId){
        return Database.query('SELECT '+
			String.join(new List<String>(Knowledge__kav.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM Knowledge__kav ' +
            ' WHERE Id = \'' + articleId + '\''
		);
    }
}