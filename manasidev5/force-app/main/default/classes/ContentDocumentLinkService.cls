public without sharing class ContentDocumentLinkService {
    public List<ContentDocumentLink> getContentDocumentLinks(Set<Id> linkedEntityids){
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        if( !linkedEntityids.isEmpty()){
            contentDocumentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :linkedEntityids];
        }
        return contentDocumentLinks;
    }

    public void deleteContentDocument(Set<Id> contentDocumentIds){
        if( !contentDocumentIds.isEmpty()){
            List<ContentDocument> contentDocuments = new List<ContentDocument>();
            for(Id contentDocumentId: contentDocumentIds){
                contentDocuments.add(new ContentDocument(Id = contentDocumentId));
            }
            delete contentDocuments;
        }
    }
    
    public void  getAndDeleteContentDocumentLinkAndIds(Set<Id> linkedEntityids){
        List<ContentDocumentLink> links = getContentDocumentLinks(linkedEntityids);
        List<ContentDocument> contentDocuments = new List<ContentDocument>();

        if( !links.isEmpty() ){
            for(ContentDocumentLink link: links){
                contentDocuments.add(new ContentDocument(Id = link.ContentDocumentId));
            }
            delete links;
        }
        if( !contentDocuments.isEmpty()){
            delete contentDocuments;
        }
    }
}