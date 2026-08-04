public with sharing class CongaLiveEditHandlerFactory {

    public static ICongaLiveEditHandler getCongaLiveEditHandler(Id recordId) {
        String congaLiveEditHandlerName = '';
        switch on recordId.getSObjectType().getDescribe().getName().toLowerCase() {
            when 'case' {
                congaLiveEditHandlerName = CaseCongaLiveEditHandler.class.getName();
            }
        }
        Type classType = Type.forName(congaLiveEditHandlerName);
        if(classType == null || !ICongaLiveEditHandler.class.isAssignableFrom(classType)) {
            throw new CongaLiveEditException('Invalid Conga Live Edit Handler');
        }
        ICongaLiveEditHandler congaLiveEditHandler = (ICongaLiveEditHandler)Type.forName(congaLiveEditHandlerName).newInstance();
        return congaLiveEditHandler;
    }

    public class CongaLiveEditException extends Exception {}
}