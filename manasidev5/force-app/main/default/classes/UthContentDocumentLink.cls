public with sharing class UthContentDocumentLink {
    
    public static ContentDocumentLink build(Id cdId, Id linkId){
        return new ContentDocumentLink(
            ContentDocumentId = cdId,
            LinkedEntityId = linkId,
            ShareType = 'V',  
            Visibility = 'AllUsers'
        );
    }

    public static List<ContentDocumentLink> getAllLinked(Set<Id> linkIds){
        return [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title, ContentDocument.Description, SystemModstamp
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :linkIds];
    }
}