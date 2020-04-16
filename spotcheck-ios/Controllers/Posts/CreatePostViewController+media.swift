import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Photos
import PromiseKit
import MaterialComponents
import DropDown

extension CreatePostViewController {
    @objc func openMediaOptions() {
        let mediaActionSheet = UIElementFactory.getActionSheet()
        mediaActionSheet.title = "Choose Media Source"
        
        let videoGalleryAction = MDCActionSheetAction(title: "Video Gallery", image: UIImage(systemName: "video.badge.plus"), handler: { (MDCActionSheetAction) in
            print("clicked Video Gallery")
        })
        
        let photoGalleryAction = MDCActionSheetAction(title: "Photo Gallery", image: Images.edit, handler: { (MDCActionSheetAction) in
            print("clicked Photo Gallery")
        })
            
        
        mediaActionSheet.addAction(videoGalleryAction)
        mediaActionSheet.addAction(photoGalleryAction)
        
        self.present(mediaActionSheet, animated: true, completion: nil)
        
    }

}
