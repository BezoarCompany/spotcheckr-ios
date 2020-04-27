import PromiseKit
import FirebaseFirestore

class ReportingService: ReportingProtocol {
    func getReportTypes() -> Promise<[ReportType]> {
        return Promise { promise in
            if let reportTypes = CacheManager.stringCache["report-types"] as? [ReportType] {
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
                CacheManager.stringCache.insert(reportTypes, forKey: "report-types")
                return promise.fulfill(reportTypes)
            }
        }
    }
    
    func submitReport(contentId: GenericID?, details: Report) -> Promise<Void> {
        return Promise { promise in
            let docRef = Firestore.firestore().collection(CollectionConstants.reportsCollection).document()
            let report = DomainToFirebaseMapper.mapReport(contentId: contentId, details: details)
            
            docRef.setData(report) { error in
                if let error = error {
                    return promise.reject(error)
                }
                
                return promise.fulfill_()
            }
        }
    }
}
