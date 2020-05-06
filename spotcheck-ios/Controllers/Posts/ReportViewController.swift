import UIKit
import DropDown
import MaterialComponents
import PromiseKit
import SwiftValidator

class ReportViewController: UIViewController {
    let appBarViewController = UIElementFactory.getAppBar()
    let reportTypeDropdown: DropDown = {
        let dropdown = DropDown()
        return dropdown
    }()
    var reportTypeTextField: MDCTextField = {
        let field = MDCTextField()
        field.placeholder = "Select Reason"
        field.cursorColor = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    let reportTypeTextFieldController: MDCTextInputControllerFilled
    let reportDescriptionTextField: MDCMultilineTextField = {
        let field = MDCMultilineTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    var reportDescriptionInputController: MDCTextInputControllerOutlinedTextArea
    let sendReportButton: MDCFloatingButton = {
        let button = MDCFloatingButton()
        button.applySecondaryTheme(withScheme: ApplicationScheme.instance.containerScheme)
        button.setImage(Images.send, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        indicator.cycleColors = [ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor]
        return indicator
    }()

    var reportTypes = [ReportType]()
    var selectedReportType: ReportType?
    var contentId: GenericID?
    var currentUser: User?
    let validator = Validator()

    static func create(contentId: GenericID?) -> ReportViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let reportViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.ReportViewControllerId) as! ReportViewController

        reportViewController.contentId = contentId

        return reportViewController
    }

    required init?(coder: NSCoder) {
        reportTypeTextFieldController = MDCTextInputControllerFilled(textInput: reportTypeTextField)
        reportTypeTextFieldController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        reportTypeTextFieldController.isFloatingEnabled = false

        reportDescriptionInputController = MDCTextInputControllerOutlinedTextArea(textInput: reportDescriptionTextField)
        MDCTextFieldTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme, to: reportDescriptionInputController)
        reportDescriptionInputController.activeColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        reportDescriptionInputController.normalColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        reportDescriptionInputController.floatingPlaceholderNormalColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        reportDescriptionInputController.floatingPlaceholderActiveColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        reportDescriptionInputController.inlinePlaceholderColor = ApplicationScheme.instance.containerScheme.colorScheme.primaryColorVariant
        reportDescriptionInputController.placeholderText = "Report Description (Optional)"

        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initAppBar()
        addSubviews()
        initControls()
        setupValidation()
        applyConstraints()
        load()
    }

    func initAppBar() {
        addChild(appBarViewController)
        appBarViewController.didMove(toParent: self)
        appBarViewController.inferTopSafeAreaInsetFromViewController = true
        appBarViewController.title = "Report"
    }

    func initControls() {
        reportTypeTextField.delegate = self
        reportTypeTextField.trailingView = Images.chevronUp
        reportTypeTextField.trailingViewMode = .always
        reportTypeTextField.trailingView?.isUserInteractionEnabled = true
        reportTypeTextField.trailingView?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        reportTypeTextField.trailingView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        reportTypeTextField.trailingView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dropdownIconOnClick(sender:))))

        reportTypeDropdown.anchorView = reportTypeTextField
        reportTypeDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.toggleDropdownIcon()
            self.reportTypeTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
            self.reportTypeTextField.text = item
            self.selectedReportType = self.reportTypes[index]
        }
        reportTypeDropdown.cancelAction = { [unowned self] in
            self.toggleDropdownIcon()
        }
        reportTypeDropdown.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        reportTypeDropdown.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
        reportTypeDropdown.selectionBackgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor
        reportTypeDropdown.selectedTextColor = ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor
        reportTypeDropdown.direction = .bottom
        reportTypeDropdown.bottomOffset = CGPoint(x: 0, y: (self.reportTypeDropdown.anchorView?.plainView.bounds.height)! - 25)
        reportTypeDropdown.dataSource = []

        reportDescriptionTextField.clearButtonMode = .never
        reportDescriptionTextField.cursorColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        reportDescriptionTextField.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor

        sendReportButton.addTarget(self, action: #selector(sendReport(_:)), for: .touchUpInside)
    }

    func addSubviews() {
        view.addSubview(appBarViewController.view)
        view.addSubview(reportTypeTextField)
        view.addSubview(reportDescriptionTextField)
        view.addSubview(sendReportButton)
        view.addSubview(activityIndicator)
    }

    func applyConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            reportTypeTextField.topAnchor.constraint(equalTo: appBarViewController.view.bottomAnchor, constant: 16),
            reportTypeTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            safeArea.trailingAnchor.constraint(equalTo: reportTypeTextField.trailingAnchor, constant: 16),
            reportDescriptionTextField.topAnchor.constraint(equalTo: reportTypeTextField.bottomAnchor, constant: 16),
            reportDescriptionTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            safeArea.trailingAnchor.constraint(equalTo: reportDescriptionTextField.trailingAnchor, constant: 16),
            sendReportButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -25),
            sendReportButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -75),
            sendReportButton.widthAnchor.constraint(equalToConstant: 64),
            sendReportButton.heightAnchor.constraint(equalToConstant: 64),
            activityIndicator.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }

    func setupValidation() {
        validator.registerField(reportTypeTextField, rules: [RequiredRule(message: "Required")])
    }

    func load() {
        firstly {
            when(fulfilled: Services.reportingService.getReportTypes(), Services.userService.getCurrentUser())
        }.done { options, user in
            self.currentUser = user
            var arr = [String]()
            for type in options {
                self.reportTypes.append(type)
                arr.append(type.name!)
            }
            arr = arr.sorted()

            self.reportTypeDropdown.dataSource = arr
        }
    }

    @objc func sendReport(_ sender: Any) {
        validator.validate(self)
    }
}

extension ReportViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField as? MDCTextField == self.reportTypeTextField {
            if reportTypeDropdown.isHidden {
                reportTypeDropdown.show()
            } else {
                reportTypeDropdown.hide()
            }
            toggleDropdownIcon()
            return false
        }

        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField as? MDCTextField == reportTypeTextField && reportTypeTextFieldController.errorText != nil {
            reportTypeTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validator.validateField(textField) { error in
            if textField as? MDCTextField == reportTypeTextField {
                reportTypeTextFieldController.setErrorText(error?.errorMessage, errorAccessibilityValue: error?.errorMessage)
            }
        }

        return true
    }

    @objc func dropdownIconOnClick(sender: Any) {
        toggleDropdownIcon()
    }

    func toggleDropdownIcon() {
        if reportTypeTextField.trailingView == Images.chevronDown {
            reportTypeTextField.trailingView = Images.chevronUp
            reportTypeDropdown.hide()
        } else {
            reportTypeTextField.trailingView = Images.chevronDown
            reportTypeDropdown.show()
        }
        reportTypeTextField.trailingView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dropdownIconOnClick(sender:))))
        reportTypeTextField.trailingViewMode = .always
        reportTypeTextField.trailingView?.isUserInteractionEnabled = true
        reportTypeTextField.trailingView?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        reportTypeTextField.trailingView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
}

extension ReportViewController: ValidationDelegate {
    func validationSuccessful() {
        activityIndicator.startAnimating()
        let userReport = Report(reportType: selectedReportType,
                                contentType: getContentType(),
                                description: reportDescriptionTextField.text,
                                createdBy: currentUser)
        sendReportButton.isEnabled = false

        firstly {
            Services.reportingService.submitReport(contentId: contentId!, details: userReport)
        }.done {
            self.dismiss(animated: true) {
                self.snackbarMessage.text = "Report submitted."
                MDCSnackbarManager.show(self.snackbarMessage)
            }
        }.catch { _ in
            self.snackbarMessage.text = "Failed to submit report."
            MDCSnackbarManager.show(self.snackbarMessage)
        }.finally {
            self.sendReportButton.isEnabled = true
            self.activityIndicator.stopAnimating()
        }
    }

    func getContentType() -> ContentType {
        if self.contentId is ExercisePostID {
            return ContentType.exercisePost
        } else {
            return ContentType.answer
        }
    }

    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            if let field = field as? MDCTextField {
                if field == reportTypeTextField {
                    reportTypeTextFieldController.setErrorText(error.errorMessage, errorAccessibilityValue: error.errorMessage)
                }
            }
        }
    }
}
