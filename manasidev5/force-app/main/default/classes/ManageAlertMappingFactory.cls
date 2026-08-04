public inherited sharing class ManageAlertMappingFactory {
    private Schema.SObjectType sObjType;

    public ManageAlertMappingFactory(Schema.SObjectType sObjType){
        this.sObjType = sObjType;
    }

    public IManageAlertMappingInterface getInstance(){
        String manageAlertMappingHandler;
        if(this.sObjType == Alert__c.SObjectType){
            manageAlertMappingHandler = ManageAlertMappingAlertImpl.class.getName();
        }else if(this.sObjType == Member__c.SObjectType){
            manageAlertMappingHandler = ManageAlertMappingMemberImpl.class.getName();
        }else{
            throw new ManageAlertMappingFactoryException('Class implementation not found for ' + this.sObjType + ' object');
        }

        Type classType = Type.forName(manageAlertMappingHandler);
        if(classType == null || !IManageAlertMappingInterface.class.isAssignableFrom(classType)) {
            throw new ManageAlertMappingFactoryException('Invalid Manage Customer Data Sharing Handler');
        }

        return (IManageAlertMappingInterface) classType.newInstance();

    }
    
    public class ManageAlertMappingFactoryException extends Exception {}
}