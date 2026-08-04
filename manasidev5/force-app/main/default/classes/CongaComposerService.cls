public with sharing class CongaComposerService {
    
    private List<String> congaComposerVariables; 

    public CongaComposerService(Id recordId, String congaParams, String congaTemplateKey) {
        this.congaComposerVariables = new List<String>();
        this.congaComposerVariables.add(getCongaBaseUrl());
        this.congaComposerVariables.add('TemplateId='+congaTemplateKey);
        this.congaComposerVariables.add('Id='+recordId);
        this.congaComposerVariables.add(congaParams);
    }

    public String getCongaUrl(){
        return String.join(this.congaComposerVariables, '&');
    }

    public String getCongaBaseUrl(){
        return String.format(System.Label.CongaBaseUrl, new List<String>{
            Url.getSalesforceBaseUrl().toExternalForm(),
            UserInfo.getOrganizationId()
        });
    }
}