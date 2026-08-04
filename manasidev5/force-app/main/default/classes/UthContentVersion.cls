@isTest
public with sharing class UthContentVersion {

    public static ContentVersion build(){
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        return content;
    }

    public static ContentVersion build(String title){
        ContentVersion content=new ContentVersion(); 
        content.Title= title; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        return content;
    }

    public static ContentVersion[] getAll() {
        return Database.query('SELECT '+
			String.join(new List<String>(ContentVersion.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM ContentVersion ' + 
			' ORDER BY Id'
		);
    }

}