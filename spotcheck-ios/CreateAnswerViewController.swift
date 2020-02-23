import UIKit

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

class CreateAnswerViewController: UIViewController {
    @IBOutlet weak var subjectPostLabel: UILabel!
    @IBOutlet weak var answerBodyTextView: UITextView!
    
    @IBAction func cancelAnswer(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        print("submitAction")
        if(validatePost()) {
            createAnswer()
            dismiss(animated: true, completion: nil)
        }
    }
    
    static let ANSWER_BODY_TEXT_PLACEHOLDER = "Write your answer"
    static let MIN_ANSWERBODY_LENGTH = 2
        
    static func create(post: ExercisePost?) -> CreateAnswerViewController  {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let createAnswerViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.CreateAnswerViewControllerId) as! CreateAnswerViewController
                    
        createAnswerViewController.post = post
        return createAnswerViewController
    }
    
    var post: ExercisePost?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CreateAnswerViewController")
        
        subjectPostLabel.text = post?.title
        initTextViewPlaceholders() 
    }
        
}


extension CreateAnswerViewController {
    
    func initTextViewPlaceholders() {
        answerBodyTextView.delegate = self
        
        answerBodyTextView.text = CreateAnswerViewController.ANSWER_BODY_TEXT_PLACEHOLDER
        answerBodyTextView.textColor = UIColor.lightGray
    }
    
    func validatePost() -> Bool {
        
        let alert = UIAlertController(title: "Invalid post", message: "You can always access your content by signing back in", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            //Cancel Action
        }))
        
        if(CreateAnswerViewController.ANSWER_BODY_TEXT_PLACEHOLDER == answerBodyTextView.text
            || answerBodyTextView.text.count < CreateAnswerViewController.MIN_ANSWERBODY_LENGTH
            ) {
            alert.message = "Please fill out a valid answer"
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    // TODO: put in PostService
    func createAnswer() {
        
        let db = Firestore.firestore()
        let newDocRef = db.collection(K.Firestore.answers).document()
        
        newDocRef.setData([
            "created-by" : Auth.auth().currentUser?.uid,
            "created-date" : FieldValue.serverTimestamp(),
            "text" : answerBodyTextView.text!,
            "exercise-post" : post?.id,
            "modified-date" : FieldValue.serverTimestamp()
        ])
        
    }
}

//Resetting textview's text to gray and placeholder value if empty,
//or back to black if non-empty (key press event triggered)
extension CreateAnswerViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView == answerBodyTextView {
                textView.text = CreateAnswerViewController.ANSWER_BODY_TEXT_PLACEHOLDER
            }
            textView.textColor = UIColor.lightGray
        }
    }
}


