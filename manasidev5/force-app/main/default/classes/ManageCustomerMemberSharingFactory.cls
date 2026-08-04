public class ManageCustomerMemberSharingFactory {
    private Schema.SObjectType sObjType;

    public ManageCustomerMemberSharingFactory(Schema.SObjectType sObjType){
        this.sObjType = sObjType;
    }

    public IManageCustomerDataSharing getInstance(){
        String manageCustomerDataSharingHandler;
        if(this.sObjType == Case.SObjectType){
            manageCustomerDataSharingHandler = ManageCustomerCaseSharingImpl.class.getName();
        } else if(this.sObjType == Member__c.SObjectType){
            manageCustomerDataSharingHandler = ManageCustomerMemberSharingImpl.class.getName();
        } else if(this.sObjType == YH_Tenancy__c.SObjectType){
            manageCustomerDataSharingHandler = ManageCustomerTenancySharingImpl.class.getName();
        } else{
            throw new ManageCustomerMemberSharingFactoryException('Class implementation not found for ' + this.sObjType + ' object');
        }

        Type classType = Type.forName(manageCustomerDataSharingHandler);
        if(classType == null || !IManageCustomerDataSharing.class.isAssignableFrom(classType)) {
            throw new ManageCustomerMemberSharingFactoryException('Invalid Manage Customer Data Sharing Handler');
        }

        return (IManageCustomerDataSharing) classType.newInstance();
    }

    public class ManageCustomerMemberSharingFactoryException extends Exception {}
}