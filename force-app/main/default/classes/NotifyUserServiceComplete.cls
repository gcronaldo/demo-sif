/*
 * Name: NotifyUserServiceComplete
 * Description: create a custom notification to informe the users about the conclusion of service execution.   
*/ 
public with sharing class NotifyUserServiceComplete {

    public static void notifyUser(String jobName) {

        Id userId = UserInfo.getUserId();
        Set<String> recipients = new Set<String>{userId};
        String dummyId = '000000000000000AAA';
        String bodyMsg = jobName + ' completed.';
        CustomNotificationFromApex.notifyUsers(recipients, dummyId, jobName, bodyMsg);

    }
}