import MaterialComponents.MDCTextInputControllerOutlined
import SwiftValidator
import PromiseKit
import FirebaseAuth.FIRAuthErrors

class SignUpViewController: UIViewController, UITextFieldDelegate, ValidationDelegate {
    @IBOutlet weak var spotcheckHeadlineLabel: UILabel!
    @IBOutlet weak var spotcheckSubtitleLabel: UILabel!
    @IBOutlet weak var createAccountButton: MDCButton!
    @IBOutlet weak var loginButton: MDCFlatButton!
    
    let emailAddressTextField: MDCTextField = {
        let field = MDCTextField()
        field.placeholder = "Email Address"
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocapitalizationType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    let emailAddressTextFieldController: MDCTextInputControllerOutlined
    
    let passwordTextField: MDCTextField = {
        let field = MDCTextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.returnKeyType = .done
        field.clearsOnBeginEditing = false
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    let passwordTextFieldController: MDCTextInputControllerOutlined
    
    let snackbarMessage: MDCSnackbarMessage = {
          let message = MDCSnackbarMessage()
           MDCSnackbarTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme)
          return message
       }()
    
    let authenticationService: AuthenticationProtocol = AuthenticationService()
    let validator: Validator
    
    required init?(coder aDecoder: NSCoder) {
        emailAddressTextFieldController = MDCTextInputControllerOutlined(textInput: emailAddressTextField)
        emailAddressTextFieldController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        passwordTextFieldController = MDCTextInputControllerOutlined(textInput: passwordTextField)
        passwordTextFieldController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        passwordTextFieldController.helperText = "Password must be at least 8 characters long"
        validator = Validator()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setDelegates()
        applyStyling()
        applyConstraints()
        setupValidation()
    }
    
    @IBAction func createAccountOnClick(_ sender: MDCButton) {
        validator.validate(self)
    }
    
    private func addSubviews() {
        self.view.addSubview(emailAddressTextField)
        self.view.addSubview(passwordTextField)
    }
    
    private func setDelegates() {
        self.emailAddressTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    private func applyStyling() {
        self.spotcheckHeadlineLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.headline4
        self.spotcheckHeadlineLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        
        self.spotcheckSubtitleLabel.font = ApplicationScheme.instance.containerScheme.typographyScheme.subtitle2
        self.spotcheckSubtitleLabel.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        
        self.createAccountButton.applyContainedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        self.loginButton.applyOutlinedTheme(withScheme: ApplicationScheme.instance.containerScheme)
    }
    
    private func applyConstraints() {
        self.emailAddressTextField.topAnchor.constraint(equalTo: spotcheckSubtitleLabel.bottomAnchor, constant: 45).isActive = true
        self.emailAddressTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: emailAddressTextField.trailingAnchor, constant: 40).isActive = true
        
        self.passwordTextField.topAnchor.constraint(equalTo: emailAddressTextField.bottomAnchor, constant: 15).isActive = true
        self.passwordTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: 40).isActive = true
            
        self.createAccountButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20).isActive = true
    }
    
    private func setupValidation() {
        validator.registerField(emailAddressTextField, rules: [RequiredRule(message: "Required"), EmailRule(message: "Invalid email address")])
        validator.registerField(passwordTextField, rules: [RequiredRule(message: "Required"), MinLengthRule(length: 8, message: "Password must be at least 8 characters long")])
    }
    
    @objc private func authenticationFinished() {
           let homeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.Storyboard.MainTabBarControllerId)
           self.present(homeViewController, animated: true)
    }
    
    internal func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == emailAddressTextField && emailAddressTextFieldController.errorText != nil {
            emailAddressTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        }
        else if textField == passwordTextField && passwordTextFieldController.errorText != nil {
            passwordTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        }
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validator.validateField(textField) { error in
            if textField == emailAddressTextField {
                passwordTextField.becomeFirstResponder()
                emailAddressTextFieldController.setErrorText(error?.errorMessage, errorAccessibilityValue: error?.errorMessage)
            }
            else if textField == passwordTextField {
                passwordTextField.resignFirstResponder()
                passwordTextFieldController.setErrorText(error?.errorMessage, errorAccessibilityValue: error?.errorMessage)
            }
        }
        
        return true
    }
    
    internal func validationSuccessful() {
        createAccountButton.setEnabled(false, animated: true)
        emailAddressTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        passwordTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        firstly {
            authenticationService.signUp(emailAddress: emailAddressTextField.text!, password: passwordTextField.text!)
        }.done {
            self.authenticationFinished()
        }.catch { error in
            let errorCode = (error as NSError).code
            
            switch errorCode {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                self.snackbarMessage.text = "Account with that email address already exists"
            default:
                self.snackbarMessage.text = error.localizedDescription
            }
            
            MDCSnackbarManager.show(self.snackbarMessage)
        }.finally {
            self.createAccountButton.setEnabled(true, animated: true)
        }
    }
    
    internal func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            if let field = field as? MDCTextField {
                if field == emailAddressTextField {
                    emailAddressTextFieldController.setErrorText(error.errorMessage, errorAccessibilityValue: error.errorMessage)
                }
                else if field == passwordTextField {
                    passwordTextFieldController.setErrorText(error.errorMessage, errorAccessibilityValue: error.errorMessage)
                }
            }
        }
    }
}
