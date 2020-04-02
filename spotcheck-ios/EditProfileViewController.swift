import UIKit
import MaterialComponents
import PromiseKit

class EditProfileViewController: UIViewController, UITextFieldDelegate {
    let appBarViewController = UIElementFactory.getAppBar()
    var profilePictureImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = Images.profilePicturePlaceholder
        return view
    }()
    let firstNameTextField: MDCTextField = {
        let field = MDCTextField()
        field.placeholder = "First Name"
        field.keyboardType = .alphabet
        field.returnKeyType = .next
        field.autocapitalizationType = .words
        field.autocorrectionType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    let firstNameTextFieldController: MDCTextInputControllerOutlined!
    let lastNameTextField: MDCTextField = {
        let field = MDCTextField()
        field.placeholder = "Last Name"
        field.keyboardType = .alphabet
        field.returnKeyType = .next
        field.autocapitalizationType = .words
        field.autocorrectionType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    let lastNameTextFieldController: MDCTextInputControllerOutlined!
    let saveButton: MDCFloatingButton = {
        let button = MDCFloatingButton()
        button.applySecondaryTheme(withScheme: ApplicationScheme.instance.containerScheme)
        button.setImage(Images.save, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let snackbarMessage: MDCSnackbarMessage = {
       let message = MDCSnackbarMessage()
       MDCSnackbarTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme)
       return message
    }()
    let savingIndicator = UIElementFactory.getActivityIndicator()
    var currentUser: User?
    
    required init?(coder aDecoder: NSCoder) {
        firstNameTextFieldController = MDCTextInputControllerOutlined(textInput: firstNameTextField)
        firstNameTextFieldController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        firstNameTextFieldController.normalColor  = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        firstNameTextFieldController.activeColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        firstNameTextFieldController.inlinePlaceholderColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        firstNameTextFieldController.floatingPlaceholderNormalColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        firstNameTextFieldController.floatingPlaceholderActiveColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        
        lastNameTextFieldController = MDCTextInputControllerOutlined(textInput: lastNameTextField)
        lastNameTextFieldController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        lastNameTextFieldController.normalColor  = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        lastNameTextFieldController.activeColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        lastNameTextFieldController.inlinePlaceholderColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        lastNameTextFieldController.floatingPlaceholderNormalColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        lastNameTextFieldController.floatingPlaceholderActiveColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        
        super.init(coder: aDecoder)
        self.addChild(appBarViewController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppBar()
        initControls()
        applyConstraints()
        loadProfile()
    }
    
    func initAppBar() {
        appBarViewController.didMove(toParent: self)
        appBarViewController.inferTopSafeAreaInsetFromViewController = true
        appBarViewController.navigationBar.title = "Edit Profile"
        view.addSubview(appBarViewController.view)
    }
    
    func initControls() {
        view.addSubview(firstNameTextField)
        view.addSubview(lastNameTextField)
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        view.addSubview(saveButton)
        view.addSubview(savingIndicator)
    }
    
    func applyConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            firstNameTextField.topAnchor.constraint(equalTo: appBarViewController.navigationBar.bottomAnchor, constant: 16),
            firstNameTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40),
            safeArea.trailingAnchor.constraint(equalTo: firstNameTextField.trailingAnchor, constant: 40),
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 16),
            lastNameTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40),
            safeArea.trailingAnchor.constraint(equalTo: lastNameTextField.trailingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -25),
            saveButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -75),
            saveButton.widthAnchor.constraint(equalToConstant: 64),
            saveButton.heightAnchor.constraint(equalToConstant: 64),
            savingIndicator.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            savingIndicator.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
    
    @objc func save() {
        savingIndicator.startAnimating()
        saveButton.isEnabled = false
        
        currentUser?.information?.firstName = firstNameTextField.text ?? ""
        currentUser?.information?.lastName = lastNameTextField.text ?? ""
        
        firstly {
            Services.userService.updateUser(currentUser!)
        }.done {
            self.snackbarMessage.text = "Profile updated."
            MDCSnackbarManager.show(self.snackbarMessage)
            NotificationCenter.default.post(name: K.Notifications.ProfileEdited, object: nil)
        }.catch{ error in
            self.snackbarMessage.text = "Failed to update your profile."
            MDCSnackbarManager.show(self.snackbarMessage)
        }.finally {
            self.savingIndicator.stopAnimating()
            self.saveButton.isEnabled = true
        }
    }
    
    func loadProfile() {
        firstly {
            Services.userService.getCurrentUser()
        }.done { user in
            self.currentUser = user
        }.catch { error in
            self.dismiss(animated: true) {
                self.snackbarMessage.text = "Failed to load user profile."
                MDCSnackbarManager.show(self.snackbarMessage)
            }
        }.finally {
            self.firstNameTextField.text = self.currentUser?.information?.firstName
            self.lastNameTextField.text = self.currentUser?.information?.lastName
        }
    }
}
