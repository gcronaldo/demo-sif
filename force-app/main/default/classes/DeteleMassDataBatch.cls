/*
 * Name: DeteleMassDataBatch
 * Description: delete mass data based a quantity target and query parameters. 
*/ 
public without sharing class DeteleMassDataBatch  implements Database.Batchable<SObject> {

    private String query;
    private String jobName;

    public DeteleMassDataBatch(String query, String jobName) {
        this.query = query;
        this.jobName = jobName;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch finished.');
        notifyUser();
    }

    // Notify users about job completion
    private void notifyUser() {
        Id userId = UserInfo.getUserId();
        Set<String> recipients = new Set<String>{userId};
        String dummyId = '000000000000000AAA';
        String bodyMsg = this.jobName + ' completed.';
        CustomNotificationFromApex.notifyUsers(recipients, dummyId, this.jobName, bodyMsg);
    }
}