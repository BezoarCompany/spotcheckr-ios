import MaterialComponents.MDCButton
import MaterialComponents.MDCFlatButton
import FirebaseAuth.FIRAuthErrors
import SwiftValidator
import PromiseKit

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate, ValidationDelegate {
    @IBOutlet weak var forgotPasswordHeadline: UILabel!
    @IBOutlet weak var forgotPasswordSubtitle: UILabel!
    
    @IBOutlet weak var continueButton: MDCButton!
    @IBOutlet weak var cancelButton: MDCFlatButton!
    
    let emailAddressTextField: MDCTextField = {
        let field = MDCTextField()
        field.placeholder = "Email Address"
        field.keyboardType = .emailAddress
        field.returnKeyType = .done
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
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
    
    let emailAddressTextFieldController: MDCTextInputControllerOutlined
    let validator: Validator
    let authenticationService = AuthenticationService()

    required init?(coder aDecoder: NSCoder) {
        emailAddressTextFieldController = MDCTextInputControllerOutlined(textInput: emailAddressTextField)
        emailAddressTextFieldController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        emailAddressTextFieldController.normalColor  = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        emailAddressTextFieldController.activeColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        emailAddressTextFieldController.inlinePlaceholderColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        emailAddressTextFieldController.floatingPlaceholderNormalColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        emailAddressTextFieldController.floatingPlaceholderActiveColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        
        validator = Validator()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        applyStyling()
        setupDelegates()
        setupValidation()
        applyConstraints()
    }
    
    @IBAction func continueOnClick(_ sender: Any) {
        validator.validate(self)
    }
    
    private func addSubviews() {
        self.view.addSubview(emailAddressTextField)
    }
    
    private func applyStyling() {
        self.forgotPasswordHeadline.font = ApplicationScheme.instance.containerScheme.typographyScheme.headline4
        self.forgotPasswordHeadline.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        
        self.forgotPasswordSubtitle.font = ApplicationScheme.instance.containerScheme.typographyScheme.subtitle1
        self.forgotPasswordSubtitle.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor
        self.continueButton.applyContainedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        self.continueButton.setBackgroundColor(ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor)
        self.continueButton.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor, for: .normal)
        self.cancelButton.applyOutlinedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        self.cancelButton.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor, for: .normal)
    }
    
    private func setupDelegates() {
        emailAddressTextField.delegate = self
    }
    
    private func setupValidation() {
        validator.registerField(emailAddressTextField, rules: [RequiredRule(message: "Required"), EmailRule(message: "Invalid email address")])
    }
    
    private func applyConstraints() {
        self.emailAddressTextField.topAnchor.constraint(equalTo: self.forgotPasswordSubtitle.bottomAnchor, constant: 25).isActive = true
        self.emailAddressTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 45).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: emailAddressTextField.trailingAnchor, constant: 40).isActive = true
        self.continueButton.topAnchor.constraint(equalTo: emailAddressTextField.bottomAnchor, constant: 20).isActive = true
    }
    
    @objc private func navigateOnReset() {
           let resetPasswordConfirmationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.Storyboard.PasswordResetConfirmationViewControllerId)
           self.present(resetPasswordConfirmationViewController, animated: true)
    }
    
    internal func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == emailAddressTextField && emailAddressTextFieldController.errorText != nil {
            emailAddressTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        }
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validator.validateField(textField) { error in
            if textField == emailAddressTextField {
                emailAddressTextField.resignFirstResponder()
                emailAddressTextFieldController.setErrorText(error?.errorMessage, errorAccessibilityValue: error?.errorMessage)
            }
        }
        
        return true
    }
    
    internal func validationSuccessful() {
        continueButton.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor)
        ])
        continueButton.setTitle("", for: .normal)
        
        continueButton.isUserInteractionEnabled = false
        emailAddressTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        activityIndicator.startAnimating()
        
        firstly {
            authenticationService.sendResetPasswordEmail(emailAddress: emailAddressTextField.text!)
        }.done {
            self.navigateOnReset()
        }.catch { error in
            self.snackbarMessage.text = error.localizedDescription
            MDCSnackbarManager.show(self.snackbarMessage)
        }.finally {
            self.activityIndicator.stopAnimating()
            self.continueButton.setTitle("Continue", for: .normal)
            self.continueButton.isUserInteractionEnabled = true
        }
    }
    
    internal func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            if let field = field as? MDCTextField {
                if field == emailAddressTextField {
                    emailAddressTextFieldController.setErrorText(error.errorMessage, errorAccessibilityValue: error.errorMessage)
                }
            }
        }
    }
    
}
