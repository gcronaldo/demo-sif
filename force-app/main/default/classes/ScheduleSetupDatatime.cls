public with sharing class ScheduleSetupDatatime {

    public static DateTime createScheduleDatetime(Time scheduleTime, String frequency) {

        // Get the current date
        Date currentDate = Date.today();

        // Initialize a variable to store the resulting DateTime
        DateTime scheduledDateTime;

        // Apply the rule based on frequency.
        switch on frequency {
            when 'Daily' {
                currentDate = currentDate.addDays(1);
                scheduledDateTime = DateTime.newInstance(currentDate, scheduleTime);
                System.debug('Result of daily ---> '+scheduledDateTime);
            }
            when 'Weekly' {
                scheduledDateTime = currentDate.addDays(7);
                System.debug('Result of Weekly ---> '+scheduledDateTime);
            }
            when else {
                scheduledDateTime = currentDate.addMonths(1);
                System.debug('Result of monthly ---> '+scheduledDateTime);
            }
        }

        return scheduledDateTime;
    }
}
