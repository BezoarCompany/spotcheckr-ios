import Foundation

struct K {
    struct App {
        static let BundleId = "com.spotcheck"
        static let iTunesId = "1506367283"
        static let CacheLifespanSeconds = 1 * 60 * 60
    }
    
    enum CacheInterval: Int {
        case hour = 3600
        case day = 86400
        case week = 604800
        case month = 2629800
    }
    
    struct Notifications {
        static let ExercisePostEdits = Notification.Name("ExercisePostEdits")
        static let ProfileEdited = Notification.Name("ProfileEdited")
    }    
    
    struct Storyboard {
        static let MainTabBarControllerId = "MainTabBarController"
        static let TabBarControllerId = "TabBarViewController"
        static let FeedViewControllerId = "FeedViewController"
        static let ProfileViewControllerId = "ProfileViewController"
        static let EditProfileViewControllerId = "EditProfileViewController"
        static let AuthOptionViewControllerId = "AuthOptionsViewController"
        static let PostDetailViewControllerId = "PostDetailViewController"        
        static let SignUpViewControllerId =  "SignUpViewController"
        static let ForgotPasswordControllerId = "ForgotPasswordViewController"
        static let PasswordResetConfirmationViewControllerId = "PasswordResetConfirmationViewController"
        static let CreatePostViewControllerId = "CreatePostViewController"
        static let CreateAnswerViewControllerId = "CreateAnswerViewController"
        static let ReportViewControllerId = "ReportViewController"
        
        static let feedCellId = "FeedCell"
        
        static let answerCellId = "AnswerReuseCell" //Reusable CellID
        static let answerNibName = "AnswerPostCell" //<name>.xib
        
        static let detailedPostCellId = "DetailedPostReuseCell" //Reusable CellID
        static let detailedPostNibName = "DetailedPostCell" //<name>.xib
        
        static let profilePostCellId = "ProfilePostCell"
        static let profilPostNibName = "ProfilePostCell"
    }
    
    struct Firestore {
        static let answers = "answers"
        
        struct Storage {
            static let imagesRootDirectory = "images"
            static let videosRootDirectory = "videos"
        }
    }
}
