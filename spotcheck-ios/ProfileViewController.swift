import Foundation
import Firebase
import PromiseKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var certificationsHeadingLabel: UILabel!
    @IBOutlet weak var certificationsLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    let userService = UserService()
    var currentUser: User?
    var receivedUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Remove, only for testing purposes
        setupTestUser()
        //resolveProfileUser()
        applyStyles()
    }
    
    private func setupTestUser() {
        let user = Trainer(id: "a")
        user.contactInformation = Contact(phoneNumbers: [PhoneNumber(number: "714-555-5555", type: .Cell)], emailAddresses: [Email(emailAddress: "emma.watson@gmail.com")])
        user.information = Identity(salutation: "Mr.", firstName: "Emma", middleName: "Charlotte Duerre", lastName: "Watson", gender: "Female", birthDate: Date("1990-04-15"))
        user.measurement = BodyMeasurement(height: 100, weight: 160)
        user.profilePictureUrl = URL(string: "https://pbs.twimg.com/profile_images/791680078203715585/OOgcKGuR_400x400.jpg")
        user.username = "emma.watson"
        user.certifications = [Certification(name: "CPT", issuer: Organization(name: "NASM")), Certification(name: "CES", issuer: Organization(name: "NASM"))]
        user.occupationTitle = "Certified Personal Trainer"
        user.occupationCompany = "LA Fitness"
        self.currentUser = user
        populateUserProfileInformation()
    }
    
    private func resolveProfileUser() {
        // Check if user received from another view controller (i.e. passed in from feed view).
        // https://www.youtube.com/watch?v=Kpwrc1PRDsg <- shows how to pass data from one view controller to this one.
        if self.receivedUser != nil {
            self.currentUser = self.receivedUser
        }
        else {
            firstly {
                //TODO: Show some sort of spinner while this data loads.
                self.userService.getCurrentUser()
            }.done { user in
                self.currentUser = user
            }.catch { error in
                //TODO: Display error to the user that fetching the current user failed.
            }.finally {
                self.populateUserProfileInformation()
                
                //TODO: Dismiss spinner once data has loaded from user service and is populated.
                
            }
        }
    }
    
    private func populateUserProfileInformation() {
        //TODO: Resolve, what to do if we don't have their full name.
        self.nameLabel.text = (self.currentUser?.information?.fullName.isEmpty ?? true) ? "Anonymous" : self.currentUser?.information?.fullName
        if self.currentUser is Trainer {
            let trainer = self.currentUser as! Trainer
            for certification in trainer.certifications {
                self.certificationsLabel.text?.append("\(certification.name), ")
            }
            self.certificationsLabel.text = self.certificationsLabel.text?.trimmingCharacters(in: CharacterSet.init(charactersIn: ", "))
            self.occupationLabel.text = trainer.occupation
        }
        else {
            self.certificationsLabel.isHidden = true
            self.certificationsHeadingLabel.isHidden = true
            self.occupationLabel.isHidden = true
        }
        
    }
    
    private func applyStyles() {
        nameLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        nameLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        certificationsLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        certificationsLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        certificationsHeadingLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        certificationsHeadingLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        occupationLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        occupationLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let baseViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.AuthOptionViewControllerId )
        UIApplication.shared.keyWindow?.rootViewController = baseViewController
    }
}
