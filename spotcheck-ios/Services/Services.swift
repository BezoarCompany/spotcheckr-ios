//Singletons because if services depend on one another inside their constructors then you can end up in a recursive init loop :/ All of this should be initialized in some sort of IoC.
class Services {
    private static var userServiceSingleton = UserService()
    private static var exercisePostSingleton = ExercisePostService()
    private static var authenticationServiceSingleton = AuthenticationService()
    private static var storageSingleton = StorageService()
    private static var analyticsSingleton = AnalyticsService()
    private static var reportingSingleton = ReportingService()
    private static var systemSingleton = SystemService()
    
    static var userService: UserService {
        return userServiceSingleton
    }
    
    static var exercisePostService: ExercisePostService {
        return exercisePostSingleton
    }
    
    static var authenticationService: AuthenticationService {
        return authenticationServiceSingleton
    }
    
    static var storageService: StorageService {
        return storageSingleton
    }
    
    static var analyticsService: AnalyticsService {
        return analyticsSingleton
    }
    
    static var reportingService: ReportingService {
        return reportingSingleton
    }
    
    static var systemService: SystemService {
        return systemSingleton
    }
}
