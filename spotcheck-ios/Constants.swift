import Foundation

struct K {
    struct App {
        static let BundleId = "com.spotcheck"
        static let CacheLifespanSeconds = 1 * 60 * 60
    }
    
    struct Notifications {
        static let ExercisePostEdits = Notification.Name("ExercisePostEdits")
    }    
    
    struct Storyboard {
        static let MainTabBarControllerId = "MainTabBarController"
        static let TabBarControllerId = "TabBarViewController"
        static let FeedViewControllerId = "FeedViewController"
        static let ProfileViewControllerId = "ProfileViewController"
        static let AuthOptionViewControllerId = "AuthOptionsViewController"
        static let PostDetailViewControllerId = "PostDetailViewController"        
        static let SignUpViewControllerId =  "SignUpViewController"
        static let ForgotPasswordControllerId = "ForgotPasswordViewController"
        static let PasswordResetConfirmationViewControllerId = "PasswordResetConfirmationViewController"
        static let CreatePostViewControllerId = "CreatePostViewController"
        static let CreateAnswerViewControllerId = "CreateAnswerViewController"
        
        static let answerCellId = "AnswerReuseCell" //Reusable CellID
        static let answerNibName = "AnswerPostCell" //<name>.xib
        
        static let detailedPostCellId = "DetailedPostReuseCell" //Reusable CellID
        static let detailedPostNibName = "DetailedPostCell" //<name>.xib
        
        static let profilePostCellId = "ProfilePostCell"
        static let profilPostNibName = "ProfilePostCell"
    }
    
    struct Firestore {
        static let posts = "posts"
        static let answers = "answers"
        
        struct Storage {
            static let IMAGES_ROOT_DIR = "images"
        }
    }
}
