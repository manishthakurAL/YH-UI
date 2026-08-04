@isTest
public class UthQueue {
    
    public static Group getQueue(String developerName) {
        return [SELECT Id FROM Group WHERE DeveloperName = :developerName AND Type = 'Queue'];
    }
}