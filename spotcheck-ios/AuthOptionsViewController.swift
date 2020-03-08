import UIKit
import Firebase
import FirebaseUI
import MaterialComponents
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialTextFields_Theming
import MaterialComponents.MaterialTextFields_TypographyThemer
import MaterialComponents.MaterialContainerScheme
import MaterialComponents.MaterialSnackbar
import MaterialComponents.MaterialSnackbar_TypographyThemer
import SwiftValidator
import PromiseKit
import FirebaseAuth.FIRAuthErrors

class AuthOptionsViewController: UIViewController, UITextFieldDelegate, ValidationDelegate {
    var window: UIWindow?
    
    let spotcheckHeadline: UILabel = {
       let label = UILabel()
        label.text = "Spotcheckr"
        label.textAlignment = .center
        label.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        label.font = ApplicationScheme.instance.containerScheme.typographyScheme.headline4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let spotcheckSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Get your exercise form reviewed \nand connect with certfied trainers."
        label.textAlignment = .center
        label.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        label.font = ApplicationScheme.instance.containerScheme.typographyScheme.subtitle2
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailAddressTextField: MDCTextField = {
        let field = MDCTextField()
        field.placeholder = "Email Address"
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
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
    
    let forgotPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Forgot password?"
        label.font = ApplicationScheme.instance.containerScheme.typographyScheme.subtitle1
        label.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        label.textAlignment = .right
        label.sizeToFit()
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let signUpButton: MDCButton = {
        let button = MDCButton()
        button.setTitle("Sign Up", for: .normal)
        button.isUppercaseTitle = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyContainedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        button.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor, for: .normal)
        button.setBackgroundColor(ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor)
        button.addTarget(self, action: #selector(onSignUpClick(sender:)), for: .touchUpInside)
        return button
    }()
    
    let signInButton: MDCButton = {
        let button = MDCButton()
        button.setTitle("Sign In", for: .normal)
        button.isUppercaseTitle = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyContainedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        button.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor, for: .normal)
        button.setBackgroundColor(ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor)
        button.addTarget(self, action: #selector(onSignInClick(sender:)), for: .touchUpInside)
        return button
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.layer.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.errorColor.cgColor
        label.layer.cornerRadius = 3
        label.font = ApplicationScheme.instance.containerScheme.typographyScheme.body1
        label.isHidden = true
        label.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        emailAddressTextFieldController.normalColor  = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        emailAddressTextFieldController.activeColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        emailAddressTextFieldController.inlinePlaceholderColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        emailAddressTextFieldController.floatingPlaceholderNormalColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        emailAddressTextFieldController.floatingPlaceholderActiveColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        passwordTextFieldController = MDCTextInputControllerOutlined(textInput: passwordTextField)
        passwordTextFieldController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        passwordTextFieldController.normalColor  = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        passwordTextFieldController.activeColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        passwordTextFieldController.inlinePlaceholderColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        passwordTextFieldController.floatingPlaceholderNormalColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        passwordTextFieldController.floatingPlaceholderActiveColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor

        validator = Validator()
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        addGestures()
        setDelegates()
        setupValidation()
        applyConstraints()
    }

    private func setupValidation() {
        validator.registerField(emailAddressTextField, rules: [RequiredRule(message: "Required"), EmailRule(message: "Invalid email address")])
        validator.registerField(passwordTextField, rules: [RequiredRule(message: "Required")])
    }
    
    private func setDelegates() {
        emailAddressTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onForgotPasswordClick))
        forgotPasswordLabel.addGestureRecognizer(tapGesture)
    }
    
    private func addSubviews() {
        self.view.addSubview(spotcheckHeadline)
        self.view.addSubview(spotcheckSubtitle)
        self.view.addSubview(errorLabel)
        self.view.addSubview(emailAddressTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(forgotPasswordLabel)
        self.view.addSubview(signUpButton)
        self.view.addSubview(signInButton)
    }
    
    private func applyConstraints() {
        spotcheckHeadline.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        spotcheckHeadline.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 90).isActive = true
        spotcheckSubtitle.topAnchor.constraint(equalTo: spotcheckHeadline.bottomAnchor, constant: 16).isActive = true
        spotcheckSubtitle.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        errorLabel.topAnchor.constraint(equalTo: spotcheckSubtitle.bottomAnchor, constant: 30).isActive = true
        errorLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: errorLabel.trailingAnchor, constant: 40).isActive = true
        emailAddressTextField.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 15).isActive = true
        emailAddressTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: emailAddressTextField.trailingAnchor, constant: 40).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailAddressTextField.bottomAnchor, constant: 10).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: 40).isActive = true
        forgotPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 0).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: forgotPasswordLabel.trailingAnchor, constant: 40).isActive = true
        signUpButton.topAnchor.constraint(equalTo: forgotPasswordLabel.bottomAnchor, constant: 30).isActive = true
        signUpButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        signInButton.widthAnchor.constraint(equalTo: signUpButton.widthAnchor).isActive = true
        signInButton.topAnchor.constraint(equalTo: forgotPasswordLabel.bottomAnchor, constant: 30).isActive = true
        signInButton.leadingAnchor.constraint(equalTo: signUpButton.trailingAnchor, constant: 20).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: signInButton.trailingAnchor, constant: 40).isActive = true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == emailAddressTextField && emailAddressTextFieldController.errorText != nil {
            emailAddressTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        }
        else if textField == passwordTextField && passwordTextFieldController.errorText != nil {
            passwordTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    
    @objc private func onSignUpClick(sender: Any) {
        let signUpViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.Storyboard.SignUpViewControllerId)
        self.present(signUpViewController, animated: true)
    }
    
    @objc private func onSignInClick(sender: Any) {
        errorLabel.isHidden = true
        validator.validate(self)
    }
        
    func validationSuccessful() {
        signInButton.setEnabled(false, animated: true)
        emailAddressTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        passwordTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        firstly {
            authenticationService.signIn(emailAddress: emailAddressTextField.text!, password: passwordTextField.text!)
        }.done { _ in
            self.authenticationFinished()
        }.catch { error in
            let errorCode = (error as NSError).code
            var errorMessage = ""
            var isCriticalError = false
            
            switch errorCode {
            case AuthErrorCode.wrongPassword.rawValue:
                errorMessage = "The password is incorrect."
            case AuthErrorCode.userNotFound.rawValue:
                errorMessage = "This user does not exist."
            case AuthErrorCode.userDisabled.rawValue:
                self.snackbarMessage.text = "This user account is disabled."
                isCriticalError = true
            case AuthErrorCode.tooManyRequests.rawValue:
                self.snackbarMessage.text = "Too many requests made to log in."
                isCriticalError = true
            default:
                self.snackbarMessage.text = "An unknown error occurred."
                isCriticalError = true
            }
            if isCriticalError {
                MDCSnackbarManager.show(self.snackbarMessage)
            }
            self.errorLabel.text = errorMessage
            self.errorLabel.isHidden = false
        }.finally {
            self.signInButton.setEnabled(true, animated: true)
        }
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
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
    
    @objc func onForgotPasswordClick() {
        let forgotPasswordController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.Storyboard.ForgotPasswordControllerId)
        self.present(forgotPasswordController, animated: true)
    }
    
    @objc private func authenticationFinished() {
        let homeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.Storyboard.MainTabBarControllerId)
        //self.present(homeViewController, animated: true)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = homeViewController
        self.window?.makeKeyAndVisible()
    }
}
