public with sharing class PDFFileConversion {
    
    @AuraEnabled
    public static void saveFile(String base64, Id parentId, String fileName){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = fileName;
        contentVersion.PathOnClient = '/' + fileName;
        contentVersion.VersionData = EncodingUtil.base64Decode(base64);
        contentVersion.IsMajorVersion = true;
        insert contentVersion;

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDocumentId;
        cdl.LinkedEntityId = parentId;
        cdl.ShareType = 'V';
        insert cdl;
    }
}