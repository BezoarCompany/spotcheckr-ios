import UIKit
import Firebase
import FirebaseUI
import MaterialComponents
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialTextFields_Theming
import MaterialComponents.MaterialTextFields_TypographyThemer
import MaterialComponents.MaterialContainerScheme

class AuthOptionsViewController: UIViewController, UITextFieldDelegate {

    let spotcheckHeadline: UILabel = {
       let label = UILabel()
        label.text = "Spotcheck"
        label.textAlignment = .center
        label.textColor = .white
        label.font = ApplicationScheme.instance.containerScheme.typographyScheme.headline4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let spotcheckSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Get your exercise form reviewed \nand connect with certfied trainers."
        label.textAlignment = .center
        label.textColor = .white
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
    
    let signUpButton: MDCButton = {
        let button = MDCButton()
        button.setTitle("Sign Up", for: .normal)
        button.isUppercaseTitle = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyContainedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        button.addTarget(self, action: #selector(onSignUpClick(sender:)), for: .touchUpInside)
        return button
    }()
    
    let signInButton: MDCButton = {
        let button = MDCButton()
        button.setTitle("Sign In", for: .normal)
        button.isUppercaseTitle = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyContainedTheme(withScheme: ApplicationScheme.instance.containerScheme)
        button.addTarget(self, action: #selector(onSignInClick(sender:)), for: .touchUpInside)
        return button
    }()
    
    let authenticationService: AuthenticationProtocol = {
        let service = AuthenticationService()
        return service
    }()
    
    required init?(coder aDecoder: NSCoder) {
        emailAddressTextFieldController = MDCTextInputControllerOutlined(textInput: emailAddressTextField)
        passwordTextFieldController = MDCTextInputControllerOutlined(textInput: passwordTextField)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setDelegates()
        applyConstraints()
    }

    private func setDelegates() {
        emailAddressTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func addSubviews() {
        self.view.addSubview(spotcheckHeadline)
        self.view.addSubview(spotcheckSubtitle)
        self.view.addSubview(emailAddressTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(signUpButton)
        self.view.addSubview(signInButton)
    }
    
    private func applyConstraints() {
        spotcheckHeadline.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        spotcheckHeadline.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 90).isActive = true
        spotcheckSubtitle.topAnchor.constraint(equalTo: spotcheckHeadline.bottomAnchor, constant: 16).isActive = true
        spotcheckSubtitle.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        emailAddressTextField.topAnchor.constraint(equalTo: spotcheckSubtitle.bottomAnchor, constant: 90).isActive = true
        emailAddressTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: emailAddressTextField.trailingAnchor, constant: 40).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailAddressTextField.bottomAnchor, constant: 10).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: 40).isActive = true
        signUpButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        signUpButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10).isActive = true
        signInButton.widthAnchor.constraint(equalTo: signUpButton.widthAnchor).isActive = true
        signInButton.leadingAnchor.constraint(equalTo: signUpButton.trailingAnchor, constant: 20).isActive = true
        signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: signInButton.trailingAnchor, constant: 40).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailAddressTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
    
    @objc private func onSignUpClick(sender: Any) {
        
    }
    
    @objc private func onSignInClick(sender: Any) {
        authenticationService.signIn(emailAddress: emailAddressTextField.text!, password: passwordTextField.text!)
    }
    
    @objc private func authenticationFinished() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let baseViewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        UIApplication.shared.keyWindow?.rootViewController = baseViewController
    }
}

