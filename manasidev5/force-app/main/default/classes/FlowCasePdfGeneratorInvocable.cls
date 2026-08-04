public with sharing class FlowCasePdfGeneratorInvocable {
    
public class CasePdfRequest {
    @InvocableVariable(required=true)
        public Id caseId;
    }

    @InvocableMethod(label='Generate PDF for Case')
    public static void generatePdfForCase(List<CasePdfRequest> requests) {
        if (requests.size() != 0){
            CasePdfRequest req = requests[0];
            List<Case> cases = [Select Id, CaseNumber, CreatedDate From Case where Id =:req.caseId];
            Case c = cases[0];
            List<AwaabsLaw__c> abs = [Select Id From AwaabsLaw__c where Case__c =:req.caseId];
            AwaabsLaw__c ab = abs[0];
            
            PageReference pdfPage = Page.FlowCasePdfVisualforce;
            pdfPage.getParameters().put('key', ab.Id);
            
            Blob pdfBlob;
            if (Test.isRunningTest()) {
                pdfBlob = FlowDecorator.PDF_BLOB;
            } else {
                pdfBlob = pdfPage.getContentAsPDF();
            }
            
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Risk Assessment - '+c.CaseNumber+' - '+c.CreatedDate;
            cv.PathOnClient = 'Risk_Assessment_'+c.CaseNumber+'_'+c.CreatedDate+'.pdf';
            cv.VersionData = pdfBlob;
            cv.IsMajorVersion = true;
            insert cv;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = req.caseId;
            cdl.ShareType = FlowDecorator.V;
            cdl.Visibility = FlowDecorator.ALL_USERS;
            insert cdl;
        }}

}