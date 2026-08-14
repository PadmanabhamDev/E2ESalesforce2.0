@RestResource(urlMapping='/welcome')
global with sharing class WelcomeRestResource {

    @HttpGet
    global static String WelcomeMessage() {
        return 'Welcome to Rest Resource with Hanu';
    }
}