//TODO: Map other constants from the other services into this file. Makes it easier to construct referencetypes in the DomainToFirebaseMappers.
//TODO: We should not be mapping in this way. We will need a test database eventually.
class CollectionConstants {
    static var postsCollection: String {
        get {
            #if DEVEL
                return "posts-test"
            #elseif STAGE
                return "posts-test"
            #else
                return "posts"
            #endif
        }
    }
    static var votesCollection: String {
        get {
            #if DEVEL
                return "votes-test"
            #elseif STAGE
                return "posts-test"
            #else
                return "votes"
            #endif
        }
    }
    static var exerciseCollection: String {
        get {
            #if DEVEL
                return "exercises-test"
            #elseif STAGE
                return "exercises-test"
            #else
                return "exercises"
            #endif
        }
    }
    static var answerCollection: String {
        get {
            #if DEVEL
                return "answers-test"
            #elseif STAGE
                return "answers-test"
            #else
                return "answers"
            #endif
        }
    }
    static var reportTypesCollection: String {
        get {
            #if DEVEL
                return "report-types-test"
            #elseif STAGE
                return "report-types-test"
            #else
                return "report-types"
            #endif
        }
    }
    static var reportsCollection: String {
        get {
            #if DEVEL
                return "reports-test"
            #elseif STAGE
                return "reports-test"
            #else
                return "reports"
            #endif
        }
    }
    static var userCollection: String {
        get {
            #if DEVEL
                return "users-test"
            #elseif STAGE
                return "users-test"
            #else
                return "users"
            #endif
        }
    }
    static var genderCollection: String {
        get {
            #if DEVEL
                return "genders-test"
            #elseif STAGE
                return "genders-test"
            #else
                return "genders"
            #endif
        }
    }
    static var userTypeCollection: String {
        get {
            #if DEVEL
                return "user-types-test"
            #elseif STAGE
                return "user-types-test"
            #else
                return "user-types"
            #endif
        }
    }
    static var certificationCollection: String {
        get {
            #if DEVEL
                return "certifications-test"
            #elseif STAGE
                return "certifications-test"
            #else
                return "certifications"
            #endif
        }
    }
    static var salutationCollection: String {
       get {
            #if DEVEL
                return "salutations-test"
            #elseif STAGE
                return "salutations-test"
            #else
                return "salutations"
            #endif
        }
    }

    static var systemCollection: String {
        get {
            #if DEVEL
            return "system-test"
            #elseif STAGE
            return "system-test"
            #else
            return "system"
            #endif
        }
    }
}
