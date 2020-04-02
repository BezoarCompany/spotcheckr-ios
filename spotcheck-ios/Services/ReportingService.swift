import PromiseKit
import FirebaseFirestore

class ReportingService: ReportingProtocol {
    private let reportTypesCollection = "report-types"
    
    func getReportOptions() -> Promise<[Report]> {
        return Promise { promise in
            let reportTypesCollectionRef = Firestore.firestore().collection(reportTypesCollection)
            reportTypesCollectionRef.getDocuments { (snapshot, error) in
                if let error = error {
                    return promise.reject(error)
                }
                
                var reportTypes = [Report]()
                for document in snapshot!.documents {
                    reportTypes.append(FirebaseToDomainMapper.mapReport(id: document.documentID, data: document.data()))
                }
                
                return promise.fulfill(reportTypes)
            }
        }
    }
}
