struct K {
    struct App {
        static let BundleId = "com.spotcheck"
    }
    
    struct Storyboard {
        static let MainTabBarControllerId = "MainTabBarController"
        static let AuthOptionViewControllerId = "AuthOptionsViewController"
        static let SignUpViewControllerId =  "SignUpViewController"
        static let ForgotPasswordControllerId = "ForgotPasswordViewController"
        static let PasswordResetConfirmationViewControllerId = "PasswordResetConfirmationViewController"
        static let feedCellId = "FeedCell" //Reusable Cell ID
        static let postNibName = "FeedPostCell" //<name>.xib
        
    }
    struct Firestore {
        static let posts = "posts"
        
    }
}
