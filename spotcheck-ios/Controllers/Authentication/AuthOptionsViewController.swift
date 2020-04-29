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

    let anonSignUpButton: MDCButton = {
        let button = MDCButton()
        button.setTitle("Skip Sign Up", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyTextTheme(withScheme: ApplicationScheme.instance.containerScheme)
        button.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor, for: .normal)
        button.addTarget(self, action: #selector(onAnonSignUpClick(sender:)), for: .touchUpInside)
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

    var activityIndicator: MDCActivityIndicator = {
        let indicator = MDCActivityIndicator()
        indicator.sizeToFit()
        indicator.indicatorMode = .indeterminate
        indicator.cycleColors = [ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor]
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
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
        self.view.addSubview(anonSignUpButton)
    }

    private func applyConstraints() {
        let safeArea = self.view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            spotcheckHeadline.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor, constant: 0),
            spotcheckHeadline.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 90),
            spotcheckSubtitle.topAnchor.constraint(equalTo: spotcheckHeadline.bottomAnchor, constant: 16),
            spotcheckSubtitle.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor, constant: 0),
            errorLabel.topAnchor.constraint(equalTo: spotcheckSubtitle.bottomAnchor, constant: 30),
            errorLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40),
            safeArea.trailingAnchor.constraint(equalTo: errorLabel.trailingAnchor, constant: 40),
            emailAddressTextField.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 15),
            emailAddressTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40),
            safeArea.trailingAnchor.constraint(equalTo: emailAddressTextField.trailingAnchor, constant: 40),
            passwordTextField.topAnchor.constraint(equalTo: emailAddressTextField.bottomAnchor, constant: 10),
            passwordTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40),
            safeArea.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: 40),
            forgotPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 0),
            safeArea.trailingAnchor.constraint(equalTo: forgotPasswordLabel.trailingAnchor, constant: 40),
            signUpButton.topAnchor.constraint(equalTo: forgotPasswordLabel.bottomAnchor, constant: 30),
            signUpButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 40),
            signInButton.widthAnchor.constraint(equalTo: signUpButton.widthAnchor),
            signInButton.topAnchor.constraint(equalTo: forgotPasswordLabel.bottomAnchor, constant: 30),
            signInButton.leadingAnchor.constraint(equalTo: signUpButton.trailingAnchor, constant: 20),
            safeArea.trailingAnchor.constraint(equalTo: signInButton.trailingAnchor, constant: 40),
            anonSignUpButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            anonSignUpButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20),
            anonSignUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 20)
        ])
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == emailAddressTextField && emailAddressTextFieldController.errorText != nil {
            emailAddressTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        } else if textField == passwordTextField && passwordTextFieldController.errorText != nil {
            passwordTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validator.validateField(textField) { error in
            if textField == emailAddressTextField {
                passwordTextField.becomeFirstResponder()
                emailAddressTextFieldController.setErrorText(error?.errorMessage, errorAccessibilityValue: error?.errorMessage)
            } else if textField == passwordTextField {
                passwordTextField.resignFirstResponder()
                passwordTextFieldController.setErrorText(error?.errorMessage, errorAccessibilityValue: error?.errorMessage)
            }
        }

        return true
    }

    @objc private func onSignUpClick(sender: Any) {
        let signUpViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.Storyboard.SignUpViewControllerId)
        signUpViewController.modalPresentationStyle = .fullScreen
        self.present(signUpViewController, animated: true)
    }

    @objc private func onSignInClick(sender: Any) {
        errorLabel.isHidden = true
        validator.validate(self)
    }

    @objc private func onAnonSignUpClick(sender: Any) {
        anonSignUpButton.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: anonSignUpButton.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: anonSignUpButton.centerXAnchor)
        ])
        anonSignUpButton.setTitle("", for: .normal)

        anonSignUpButton.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        firstly {
            Services.authenticationService.anonymousSignUp()
        }.done {
            self.authenticationFinished()
        }.catch { _ in
            self.snackbarMessage.text = "Failed to continue"
            MDCSnackbarManager.show(self.snackbarMessage)
        }.finally {
            self.activityIndicator.stopAnimating()
            self.anonSignUpButton.setTitle("Skip Sign Up", for: .normal)
            self.anonSignUpButton.isUserInteractionEnabled = true
        }
    }

    func validationSuccessful() {
        signInButton.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: signInButton.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: signInButton.centerXAnchor)
        ])
        signInButton.setTitle("", for: .normal)

        signInButton.isUserInteractionEnabled = false
        emailAddressTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        passwordTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        activityIndicator.startAnimating()
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
            self.activityIndicator.stopAnimating()
            self.signInButton.setTitle("Sign In", for: .normal)
            self.signInButton.isUserInteractionEnabled = true
        }
    }

    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            if let field = field as? MDCTextField {
                if field == emailAddressTextField {
                    emailAddressTextFieldController.setErrorText(error.errorMessage, errorAccessibilityValue: error.errorMessage)
                } else if field == passwordTextField {
                    passwordTextFieldController.setErrorText(error.errorMessage, errorAccessibilityValue: error.errorMessage)
                }
            }
        }
    }

    @objc func onForgotPasswordClick() {
        let forgotPasswordController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.Storyboard.ForgotPasswordControllerId)
        forgotPasswordController.modalPresentationStyle = .fullScreen
        self.present(forgotPasswordController, animated: true)
    }

    @objc private func authenticationFinished() {
        let homeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.Storyboard.MainTabBarControllerId)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = homeViewController
        self.window?.makeKeyAndVisible()
    }
}
