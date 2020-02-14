import UIKit
import iOSDropDown //https://github.com/jriosdev/iOSDropDown

class CreatePostViewController: UIViewController {

    @IBOutlet weak var workoutTypeDropDown: DropDown!
    @IBOutlet weak var subjectTextView: UITextView!
    @IBOutlet weak var postBodyTextView: UITextView!
    @IBAction func cancelPost(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    static let SUBJECT_TEXT_PLACEHOLDER = "Subject"
    static let POST_BODY_TEXT_PLACEHOLDER = "Write your question"

    static func create() -> CreatePostViewController  {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let createPostViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.CreatePostViewControllerId) as! CreatePostViewController
                    
        return createPostViewController

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CreatePostViewController")
        
        initDropDown()
        initTextViewPlaceholders()
    }    
}

extension CreatePostViewController {
    func initDropDown() {
        workoutTypeDropDown.selectedRowColor = .magenta
        
        //TODO load from Firebase
        workoutTypeDropDown.optionArray = ["Bench TEST", "Cardio TEST", "Games Test"]
        
        workoutTypeDropDown.didSelect{
            (selectedText, index, id) in
            print("\(selectedText) @ index: \(index)")
        }
    }
    
    func initTextViewPlaceholders() {
        subjectTextView.delegate = self
        postBodyTextView.delegate = self
        
        subjectTextView.text = CreatePostViewController.SUBJECT_TEXT_PLACEHOLDER
        subjectTextView.textColor = UIColor.lightGray
        
        postBodyTextView.text = CreatePostViewController.POST_BODY_TEXT_PLACEHOLDER
        postBodyTextView.textColor = UIColor.lightGray
    }
}

//Resetting textview's text to gray and placeholder value if empty,
//or back to black if non-empty (key press event triggered)
extension CreatePostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView == subjectTextView {
                textView.text = CreatePostViewController.SUBJECT_TEXT_PLACEHOLDER
            } else {
                textView.text = CreatePostViewController.POST_BODY_TEXT_PLACEHOLDER
            }
            textView.textColor = UIColor.lightGray
        }
    }
}
