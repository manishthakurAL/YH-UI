public interface ICongaLiveEditHandler {
    
    List<CaseCongaSetting__mdt> getCongaSettings(Id recordId);
    List<CaseCongaSetting__mdt> getDefaultTemplates();
    String getCongaUrl(Id recordId, Id congaSettingId, String actionType);
    
}