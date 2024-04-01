/*
 * Name: CustomNotificationFromApex
 * Description: create a notification from apex execution. 
*/
public without sharing class CustomNotificationFromApex {

    public static void notifyUsers(Set<String> recipientsIds, String targetId, String title, String bodyMsg) {

        // Get the Id for our custom notification type
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Custom_Notification'];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle(title);
        notification.setBody(bodyMsg);

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        
        // Actually send the notification
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}