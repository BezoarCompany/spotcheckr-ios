#  UI Tests
We are using the Page Object Model pattern for setting up testing.

Best Practices:
- Introduce a struct to manage your UI objects. For example,  LoginScreen has a Buttons struct and TextFields struct. This ensures that everything is initialized at the top of the file and makes it easier to look at more than anything else.
- Tests should never depend on one another. You can introduce some helper methods in BaseTest such as `loginIfNeeded` or `logout`.
- BaseScreen has some helpful tab functions for simple navigation. This is because these need to occur across screens and it doesn't make sense to duplicate the code per screen. Be cautious when adding things to these base classes; things should only be added if they affect more than one screen.
- If you are navigating away from the screen then you should not return anything from your function. But if you are performing an action on the screen and expect to stay there then you should `return self` because then you are allowed to do a fluent syntax similar to `LoginScreen(self).enterCredentials(...).clickLogin()`.
- Use accessibilityIdentifiers in the code under test UI elements, this is the best way to uniquely identify elements.

Helpful Links:
https://www.hackingwithswift.com/articles/148/xcode-ui-testing-cheat-sheet
https://devblogs.microsoft.com/xamarin/best-practices-tips-xamarin-uitest/
https://www.youtube.com/watch?v=9x7KVKVgsTs

