@isTest
public with sharing class UthPermissionAssigner {
    
    public static void assignPermissionSet(Id assigneedId, String permissionSetId){
        insert new PermissionSetAssignment(AssigneeId=assigneedId,
                                   PermissionSetId=permissionSetId);
    }

    public static void assignPermissionSetGroup(Id assigneedId, String permissionSetGroupId){
        insert new PermissionSetAssignment(AssigneeId=assigneedId,
        PermissionSetGroupId =permissionSetGroupId);
    }

}