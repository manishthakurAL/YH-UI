public with sharing class RecordLookupController {

    private static final String SOQL_SEARCH_RECORD = 'SELECT {0} FROM {1} WHERE {2} ORDER BY {3} LIMIT 10';
    private static final String SOSL_SEARCH_RECORD = 'FIND {0} IN ALL FIELDS RETURNING {1}({2} ORDER BY {3})  LIMIT 10';

    private static final String SOQL_RECENTLY_RECORD_TEMPLATE = 'SELECT Id, Name FROM RecentlyViewed  WHERE Type = {0} ORDER BY LastViewedDate DESC';

    @AuraEnabled
    public static List<ResultWrapper> fetchRecentRecords(SearchWrapper inputWrapper) {
        List<ResultWrapper> returnWrapperList = null;
        try {
            if(inputWrapper != null){
                String soql = String.format(SOQL_RECENTLY_RECORD_TEMPLATE, new List<Object>{ '\'' + inputWrapper.objectApiName + '\''});
                Set<Id> recentRecordIds = (new Map<Id, sObject>(Database.query(soql))).keySet();
                String[] fieldsToQuery = getQueryFields(inputWrapper);
                soql = String.format(SOQL_SEARCH_RECORD, new List<Object>{ 
                    String.join(fieldsToQuery, ','),
                    String.escapeSingleQuotes(inputWrapper.objectApiName),
                    'Id in :recentRecordIds',
                    String.escapeSingleQuotes(inputWrapper.sortByField)
                });
                returnWrapperList = new List<ResultWrapper>();
                for(SObject result : Database.query(soql)) {
                    returnWrapperList.add(getResult(result,  inputWrapper.fieldApiName, inputWrapper.otherFieldApiName));
                }
            }
            return returnWrapperList;
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
    }

    @AuraEnabled
    public static List<ResultWrapper> fetchRecords(SearchWrapper inputWrapper) {
        try {
            if(inputWrapper != null){
               if (inputWrapper.enableSOSL) {
                    return getRecordBySOSL(inputWrapper);
               }
               return getRecordBySOQL(inputWrapper);
            }
            return null;
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
    }

    private static List<ResultWrapper> getRecordBySOQL(SearchWrapper inputWrapper) {
        String[] fieldsToQuery = getQueryFields(inputWrapper);
        String filter = '';
        String sortField = String.isNotEmpty(inputWrapper.sortByField)?inputWrapper.sortByField: 'LastModifiedDate DESC';

        if(String.isNotBlank(inputWrapper.selectedRecordId)) {
            filter += 'Id = \''+ inputWrapper.selectedRecordId + '\'';
        } else  if (String.isNotBlank(inputWrapper.searchFieldApiName)) {
            String seprator = '';
            for (String searchField: inputWrapper.searchFieldApiName.split(',')) {
                filter  += seprator + searchField + ' LIKE \'%' + String.escapeSingleQuotes(inputWrapper.searchString.trim()) + '%\'';
                seprator = ' OR ';
            }
        } else {
            filter = inputWrapper.fieldApiName + ' LIKE ' + '\'%' + String.escapeSingleQuotes(inputWrapper.searchString.trim()) + '%\' ';
        }
       
        String query = String.format(
            SOQL_SEARCH_RECORD,
            new List<String>{
                String.join(fieldsToQuery, ','),
                String.escapeSingleQuotes(inputWrapper.objectApiName),
                filter,
                String.escapeSingleQuotes(sortField)
            }
        );        
        List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
        for(SObject result : Database.query(query)) {
            returnWrapperList.add(getResult(result, inputWrapper.fieldApiName, inputWrapper.otherFieldApiName));
        
        }
        return returnWrapperList;
    }
    
    private static List<ResultWrapper> getRecordBySOSL(SearchWrapper inputWrapper) {
        String[] fieldsToQuery = getQueryFields(inputWrapper);

        String sortField = String.isNotBlank(inputWrapper.sortByField)?inputWrapper.sortByField: 'LastModifiedDate DESC';
        String query = String.format(
            SOSL_SEARCH_RECORD,
            new List<String>{
                '{' + String.escapeSingleQuotes(inputWrapper.searchString.trim()) + '}',
                String.escapeSingleQuotes(inputWrapper.objectApiName),
                String.join(fieldsToQuery, ','),
                String.escapeSingleQuotes(sortField)
            }
        );
        List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
        Search.SearchResults searchResults = Search.find(query);
        for(Search.SearchResult searchResult : searchResults.get(inputWrapper.objectApiName)) {
            returnWrapperList.add(getResult(searchResult.getSObject(), inputWrapper.fieldApiName, inputWrapper.otherFieldApiName));
        }
        return returnWrapperList; 
    }

    private static List<String> getQueryFields(SearchWrapper inputWrapper) {
        String[] allFields = String.isNotBlank(inputWrapper.otherFieldApiName)?inputWrapper.otherFieldApiName.trim().split(','): new List<String>();
        allFields.add(inputWrapper.fieldApiName);
        return allFields;
    }

    private static ResultWrapper getResult(SObject record, String fieldAPIName, String otherFieldAPIName) {
        String subtitle = '';
        String seprator = '';
        if(String.isNotBlank(otherFieldAPIName)){
            for (String otherField : otherFieldAPIName.split(',')) {
                if (record.get(otherField.trim()) != null) {
                    subtitle += seprator + (String)record.get(otherField);
                    seprator = ' • ';
                }
            }
        }
        return (new ResultWrapper(
            record,
            (String)record.get(fieldAPIName),
            subtitle
        ));
    } 

    public class ResultWrapper{
        @AuraEnabled public String title{get;set;}
        @AuraEnabled public String subtitle{get;set;}
        @AuraEnabled public String id{get;set;}
        @AuraEnabled public SObject record{get;set;}

        public ResultWrapper(SObject record, String title, String subtitle) {
            this.record = record;
            this.id = record.id;
            this.title = title;
            this.subtitle = subtitle;
        }
    }

    public class SearchWrapper {
        @AuraEnabled public Boolean enableSOSL{get;set;}
        @AuraEnabled public String objectApiName{get;set;}
        @AuraEnabled public String fieldApiName{get;set;}
        @AuraEnabled public String otherFieldApiName{get;set;}
        @AuraEnabled public String searchString{get;set;}
        @AuraEnabled public String searchFieldApiName{get;set;}
        @AuraEnabled public String sortByField{get;set;}
        @AuraEnabled public String selectedRecordId{get;set;}

        public SearchWrapper() {}

        public SearchWrapper(String jsonParams){
            SearchWrapper params = (SearchWrapper) JSON.deserialize(jsonParams, SearchWrapper.class);
            this.enableSOSL = params.enableSOSL;
            this.objectApiName = params.objectApiName;
            this.fieldApiName = params.fieldApiName;
            this.otherFieldApiName = params.otherFieldApiName;
            this.searchString = params.searchString;
            this.searchFieldApiName = params.searchFieldApiName;
            this.sortByField = params.sortByField;
            this.selectedRecordId = params.selectedRecordId;
        }
    }
}