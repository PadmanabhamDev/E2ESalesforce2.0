/**
 * REST resource that returns a welcome message.
 */
@RestResource(urlMapping='/welcome')
global with sharing class WelcomeRestResource {

    /**
     * Returns a welcome message for the REST resource.
     * @return String
     */
    @HttpGet
    global static String welcomeMessage() {
        return 'Welcome to Rest Resource with Hanu';
    }
}