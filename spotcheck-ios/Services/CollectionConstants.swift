//TODO: Map other constants from the other services into this file. Makes it easier to construct referencetypes in the DomainToFirebaseMappers.
//TODO: We should not be mapping in this way. We will need a test database eventually.
class CollectionConstants {
    static var postsCollection: String {
        get {
            #if DEBUG
                return "posts-test"
            #else
                return "posts"
            #endif
        }
    }
    static var votesCollection: String {
        get {
            #if DEBUG
                return "votes-test"
            #else
                return "votes"
            #endif
        }
    }
    static var exerciseCollection: String {
        get {
            #if DEBUG
                return "exercises-test"
            #else
                return "exercises"
            #endif
        }
    }
    static var answerCollection: String {
        get {
            #if DEBUG
                return "answers-test"
            #else
                return "answers"
            #endif
        }
    }
    static var reportTypesCollection: String {
        get {
            #if DEBUG
                return "report-types-test"
            #else
                return "report-types"
            #endif
        }
    }
    static var reportsCollection: String {
        get {
            #if DEBUG
                return "reports-test"
            #else
                return "reports"
            #endif
        }
    }
    static var userCollection: String {
        get {
            #if DEBUG
                return "users-test"
            #else
                return "users"
            #endif
        }
    }
    static var genderCollection: String {
        get {
            #if DEBUG
                return "genders-test"
            #else
                return "genders"
            #endif
        }
    }
    static var userTypeCollection: String {
        get {
            #if DEBUG
                return "user-test"
            #else
                return "user"
            #endif
        }
    }
    static var certificationCollection: String {
        get {
            #if DEBUG
                return "certifications-test"
            #else
                return "certifications"
            #endif
        }
    }
    static var salutationCollection: String {
       get {
            #if DEBUG
                return "salutations-test"
            #else
                return "salutations"
            #endif
        }
    }
}
