import MaterialComponents.MDCTextInputControllerOutlined

class SignUpViewController: UIViewController, UITextFieldDelegate {

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
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    let passwordTextFieldController: MDCTextInputControllerOutlined
    
    required init?(coder aDecoder: NSCoder) {
        emailAddressTextFieldController = MDCTextInputControllerOutlined(textInput: emailAddressTextField)
        emailAddressTextFieldController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        passwordTextFieldController = MDCTextInputControllerOutlined(textInput: passwordTextField)
        passwordTextFieldController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setDelegates()
        applyStyling()
        applyConstraints()
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
}
