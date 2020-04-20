import PromiseKit
import FirebaseFirestore

class ReportingService: ReportingProtocol {
    private let cache = Cache<String,Any>()
    
    func getReportTypes() -> Promise<[ReportType]> {
        return Promise { promise in
            if let reportTypes = cache["report-types"] as? [ReportType] {
                return promise.fulfill(reportTypes)
            }
            
            let reportTypesCollectionRef = Firestore.firestore().collection(CollectionConstants.reportTypesCollection)
            reportTypesCollectionRef.getDocuments { (snapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                var reportTypes = [ReportType]()
                for document in snapshot!.documents {
                    reportTypes.append(FirebaseToDomainMapper.mapReportType(id: document.documentID, data: document.data()))
                }
                self.cache.insert(reportTypes, forKey: "report-types")
                return promise.fulfill(reportTypes)
            }
        }
    }
    
    func submitReport(contentId: GenericID?, details: Report) -> Promise<Void> {
        return Promise { promise in
            let docRef = Firestore.firestore().collection(CollectionConstants.reportsCollection).document()
            docRef.setData(DomainToFirebaseMapper.mapReport(contentId: contentId, details: details)) { error in
                if let error = error {
                    return promise.reject(error)
                }
                
                return promise.fulfill_()
            }
        }
    }
}
