import UIKit

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

class CreateAnswerViewController: UIViewController {
    @IBAction func cancelAnswer(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    static let POST_BODY_TEXT_PLACEHOLDER = "Write your answer"
    static let MIN_ANSBODY_LENGTH = 2
    
    static func create() -> CreateAnswerViewController  {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let createAnswerViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.CreateAnswerViewControllerId) as! CreateAnswerViewController
                    
        return createAnswerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CreateAnswerViewController")                
    }
        
}
