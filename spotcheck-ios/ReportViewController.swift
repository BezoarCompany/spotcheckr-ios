import UIKit
import DropDown
import MaterialComponents
import PromiseKit

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
    var reportOptions = [Report]()
    var selectedReson: Report?
    
    required init?(coder: NSCoder) {
        reportTypeTextFieldController = MDCTextInputControllerFilled(textInput: reportTypeTextField)
        reportTypeTextFieldController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        reportTypeTextFieldController.isFloatingEnabled = false
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppBar()
        addSubviews()
        initControls()
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
            self.reportTypeTextField.text = item
            self.selectedReson = self.reportOptions[index]
        }
        reportTypeDropdown.cancelAction = { [unowned self] in
            self.toggleDropdownIcon()
        }
        reportTypeDropdown.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        reportTypeDropdown.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
        reportTypeDropdown.selectionBackgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor
        reportTypeDropdown.selectedTextColor = ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor
        reportTypeDropdown.direction = .bottom
        reportTypeDropdown.bottomOffset = CGPoint(x: 0, y:(self.reportTypeDropdown.anchorView?.plainView.bounds.height)! - 25)
        reportTypeDropdown.dataSource = []
    }
    
    func addSubviews() {
        view.addSubview(appBarViewController.view)
        view.addSubview(reportTypeTextField)
    }
    
    func applyConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            reportTypeTextField.topAnchor.constraint(equalTo: appBarViewController.view.bottomAnchor, constant: 16),
            reportTypeTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            safeArea.trailingAnchor.constraint(equalTo: reportTypeTextField.trailingAnchor, constant: 16)
        ])
    }
    
    func load() {
        firstly {
            Services.reportingService.getReportOptions()
        }.done{ options in
            var arr = [String]()
            for report in options {
                self.reportOptions.append(report)
                arr.append((report.reportType?.name!)!)
            }
            arr = arr.sorted()
            
            self.reportTypeDropdown.dataSource = arr
        }
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
    
    @objc func dropdownIconOnClick(sender: Any) {
        toggleDropdownIcon()
    }
    
    func toggleDropdownIcon() {
        if reportTypeTextField.trailingView == Images.chevronDown {
            reportTypeTextField.trailingView = Images.chevronUp
            reportTypeDropdown.hide()
        }
        else {
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
