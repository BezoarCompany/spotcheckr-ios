// TODO: Refactor into something more maintainable as this design has its shortcomings in testability and maintainability.
// Introduce a Cache Protocol that MemoryCache inherits from so that we can create a MockCache for unit testing.
///Singleton cache manager to be used across the various services to cache data either in memory, disk, or hybrid. For now, only in memory is supported.
///Not to be used in ViewControllers or anywhere outside of the Services.
final class CacheManager {
    private static var _instance = CacheManager()
    
    static let userCache = MemoryCache<UserID, User>()
    static let exercisePostCache = MemoryCache<ExercisePostID, ExercisePost>()
    ///Not to be used for long term storage of user generated content. Only for system types (e.g. exercises, user-types, etc.)
    static let stringCache = MemoryCache<String, Any>()
    
    static var instance: CacheManager {
        return _instance
    }
    
    static func clearAllCaches() {
        userCache.empty()
        exercisePostCache.empty()
        stringCache.empty()
    }
}
