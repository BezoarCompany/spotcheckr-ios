struct K {
    struct App {
        static let BundleId = "com.spotcheck"
    }
    
    struct Storyboard {
        static let MainTabBarControllerId = "MainTabBarController"
        static let AuthOptionViewControllerId = "AuthOptionsViewController"
        static let PostDetailViewControllerId = "PostDetailViewController"        
        static let SignUpViewControllerId =  "SignUpViewController"
        static let ForgotPasswordControllerId = "ForgotPasswordViewController"
        static let PasswordResetConfirmationViewControllerId = "PasswordResetConfirmationViewController"
        static let CreatePostViewControllerId = "CreatePostViewController"
        static let CreateAnswerViewControllerId = "CreateAnswerViewController"

        static let feedCellId = "FeedCell" //Reusable Cell ID
        static let postNibName = "FeedPostCell" //<name>.xib
        
        static let answerCellId = "AnswerReuseCell" //Reusable CellID
        static let answerNibName = "AnswerPostCell" //<name>.xib
        
        static let detailedPostCellId = "DetailedPostReuseCell" //Reusable CellID
        static let detailedPostNibName = "DetailedPostCell" //<name>.xib
        
    }
    struct Firestore {
        static let posts = "posts"
        static let answers = "answers"
    }
}
