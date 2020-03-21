import MaterialComponents.MDCTextInputControllerOutlined
import SwiftValidator
import PromiseKit
import FirebaseAuth.FIRAuthErrors
import SwiftSVG

class SignUpViewController: UIViewController, UITextFieldDelegate, ValidationDelegate {
    @IBOutlet weak var spotcheckHeadlineLabel: UILabel!
    @IBOutlet weak var spotcheckSubtitleLabel: UILabel!
    @IBOutlet weak var createAccountButton: MDCButton!
    @IBOutlet weak var loginButton: MDCFlatButton!
    
    var window: UIWindow?
    let emailAddressTextField: MDCTextField = {
        let field = MDCTextField()
        field.placeholder = "Email Address"
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocorrectionType = .no
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
        field.trailingView = UIImageView(SVGNamed: "eye"){
            (svgLayer) in
            svgLayer.fillColor = .none
            svgLayer.strokeColor = UIColor.white.cgColor
        }
        field.trailingViewMode = .always
        field.trailingView?.isUserInteractionEnabled = true
        field.trailingView?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        field.trailingView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    let passwordTextFieldController: MDCTextInputControllerOutlined
    
    let isTrainerSwitch: UISwitch = {
        let trainerSwitch = UIElementFactory.getSwitch()
        trainerSwitch.translatesAutoresizingMaskIntoConstraints = false
        return trainerSwitch
    }()
    let isTrainerLabel: UILabel = {
        let label = UIElementFactory.getLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Are you a certified personal trainer?"
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
        passwordTextFieldController.helperText = "Password must be at least 8 characters long"
        validator = Validator()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setGestures()
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
        self.view.addSubview(isTrainerLabel)
        self.view.addSubview(isTrainerSwitch)
    }
    
    private func setGestures() {
        self.passwordTextField.trailingView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(passwordIconOnClick(sender:))))
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
        self.createAccountButton.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor, for: .normal)
        self.createAccountButton.setBackgroundColor(ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor)
        self.loginButton.applyOutlinedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        self.loginButton.setTitleColor(ApplicationScheme.instance.containerScheme.colorScheme.onPrimaryColor, for: .normal)
    }
    
    private func applyConstraints() {
        self.emailAddressTextField.topAnchor.constraint(equalTo: spotcheckSubtitleLabel.bottomAnchor, constant: 45).isActive = true
        self.emailAddressTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: emailAddressTextField.trailingAnchor, constant: 40).isActive = true
        
        self.passwordTextField.topAnchor.constraint(equalTo: emailAddressTextField.bottomAnchor, constant: 15).isActive = true
        self.passwordTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: 40).isActive = true
        
        self.isTrainerLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 15).isActive = true
        self.isTrainerLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        self.isTrainerLabel.trailingAnchor.constraint(equalTo: isTrainerSwitch.leadingAnchor, constant: 20).isActive = true
        self.isTrainerSwitch.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 15).isActive = true
        
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: isTrainerSwitch.trailingAnchor, constant: 40).isActive = true
        
        self.createAccountButton.topAnchor.constraint(equalTo: isTrainerLabel.bottomAnchor, constant: 20).isActive = true
        self.createAccountButton.topAnchor.constraint(equalTo: isTrainerSwitch.bottomAnchor, constant: 20).isActive = true
    }
    
    private func setupValidation() {
        validator.registerField(emailAddressTextField, rules: [RequiredRule(message: "Required"), EmailRule(message: "Invalid email address")])
        validator.registerField(passwordTextField, rules: [RequiredRule(message: "Required"), MinLengthRule(length: 8, message: "Password must be at least 8 characters long")])
    }
    
    @objc private func authenticationFinished() {
           let homeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.Storyboard.MainTabBarControllerId)
           self.window = UIWindow(frame: UIScreen.main.bounds)
           self.window?.rootViewController = homeViewController
           self.window?.makeKeyAndVisible()
    }
    
    @objc func passwordIconOnClick(sender: Any) {
        self.passwordTextField.isSecureTextEntry = !self.passwordTextField.isSecureTextEntry
        if self.passwordTextField.isSecureTextEntry {
            self.passwordTextField.trailingView = UIImageView(SVGNamed: "eye"){
                (svgLayer) in
                svgLayer.fillColor = .none
                svgLayer.strokeColor = UIColor.white.cgColor
            }
        }
        else {
            self.passwordTextField.trailingView = UIImageView(SVGNamed: "eye-off"){
                (svgLayer) in
                svgLayer.fillColor = .none
                svgLayer.strokeColor = UIColor.white.cgColor
            }
        }
        self.passwordTextField.trailingView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(passwordIconOnClick(sender:))))
        self.passwordTextField.trailingViewMode = .always
        self.passwordTextField.trailingView?.isUserInteractionEnabled = true
        self.passwordTextField.trailingView?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.passwordTextField.trailingView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
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
        createAccountButton.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: createAccountButton.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: createAccountButton.centerXAnchor)
        ])
        createAccountButton.setTitle("", for: .normal)
        
        createAccountButton.isUserInteractionEnabled = false
        emailAddressTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        passwordTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        activityIndicator.startAnimating()
        
        firstly {
            authenticationService.signUp(emailAddress: emailAddressTextField.text!,
                                         password: passwordTextField.text!,
                                         isTrainer: isTrainerSwitch.isOn
                                        )
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
            self.activityIndicator.stopAnimating()
            self.createAccountButton.setTitle("Create Account", for: .normal)
            self.createAccountButton.isUserInteractionEnabled = true
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
