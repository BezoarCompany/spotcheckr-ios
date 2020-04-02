import PromiseKit
import FirebaseFirestore

class ReportingService: ReportingProtocol {
    private let reportTypesCollection = "report-types"
     private let cache = Cache<String,Any>()
    
    func getReportOptions() -> Promise<[Report]> {
        return Promise { promise in
            if let reportTypes = cache["report-types"] as? [Report] {
                return promise.fulfill(reportTypes)
            }
            
            let reportTypesCollectionRef = Firestore.firestore().collection(reportTypesCollection)
            reportTypesCollectionRef.getDocuments { (snapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                var reportTypes = [Report]()
                for document in snapshot!.documents {
                    reportTypes.append(FirebaseToDomainMapper.mapReport(id: document.documentID, data: document.data()))
                }
                self.cache.insert(reportTypes, forKey: "report-types")
                return promise.fulfill(reportTypes)
            }
        }
    }
}
