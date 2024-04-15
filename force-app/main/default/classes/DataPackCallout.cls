/*
 * Name: DataPackCallout
 * Description: make callout to step function on AWS to start the replication process. 
*/
public with sharing class DataPackCallout {
    
    @future(callout = true)
    public static void executeReplicationCallout(String input, String name, String stateMachineArn) {

        // Create a map to hold parameters and values
        Map<String, Object> payloadMap = new Map<String, Object>();
        payloadMap.put('input', input);
        payloadMap.put('name', name);
        payloadMap.put('stateMachineArn', stateMachineArn);

        // Serialize the map to JSON
        String payload = JSON.serialize(payloadMap);
        System.debug('Payload ---> '+payload);

        // Create the request. 
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:ReplicationExecutionCredential');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(payload);

        // Create an HTTP object to send the request
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('Response----> ' + response.getBody());

    }
}