import Foundation
import Fakery

class FakeDataFactory {
    private static let faker = Faker()
    private static let nasmSpecializations = ["PES", "CES", "FNS", "WLS", "YES", "WFS", "MMAS", "GFS", "SFS"]
    private static let exercises = [Exercise(name: "Deadlift"),
                                    Exercise(name:"Squat"),
                                    Exercise(name: "Bench Press"),
                                    Exercise(name: "Sit-up"),
                                    Exercise(name: "Push-up"),
                                    Exercise(name: "Running"),
                                    Exercise(name: "Hiking"),
                                    Exercise(name: "Sex"),
                                    Exercise(name: "Incline Bench Press"),
                                    Exercise(name: "Decline Bench Press")
                                    ]
    static func GetUsers(count: Int) -> [User] {
        var users = [User]()
        
        for _ in 1...count {
            users.append(createFakeUser())
        }
        
        return users
    }
    
    static func GetTrainers(count: Int) -> [Trainer] {
        var trainers = [Trainer]()
        
        for _ in 1...count {
            trainers.append(createFakeTrainer())
        }
        
        return trainers
    }
    
    static func GetExercisePosts(count: Int) -> [ExercisePost] {
        var exercisePosts = [ExercisePost]()
        
        for _ in 1...count {
            let dateCreated = faker.date.between(Date("2000-01-01"), Date("2020-01-01"))
            var likes = faker.number.randomInt(min: 1, max: 250)
            
            var answers = [Answer]()
            for _ in 0...Int.random(in: 0..<20) {
                var media = [Media]()
                for _ in 0...Int.random(in: 0..<2){
                    media.append(Media(url: URL(string:faker.internet.image())))
                }
                
                answers.append(Answer(createdBy: createFakeUser(),
                                      dateCreated: dateCreated,
                                      dateModified: faker.date.between(dateCreated, Date("2020-01-01")),
                                      text: faker.lorem.paragraphs(),
                                      media: media,
                                      upvotes: faker.number.randomInt(min: 1, max: 1000),
                                      downvotes: faker.number.randomInt(min: 1, max: 1000)))
            }
            
            var postMedia = [Media]()
            for _ in 0...Int.random(in: 0..<2) {
                postMedia.append(Media(url: URL(string:faker.internet.image())))
            }
            
            var postExercises = [Exercise]() //Can have duplicates but, whatever
            for _ in 0...Int.random(in: 0..<3) {
                postExercises.append(exercises[Int.random(in: 0..<exercises.count)])
            }
            
            exercisePosts.append(
                ExercisePost(id: "\(faker.number.increasingUniqueId())",
                            title: faker.lorem.sentence(),
                            description: faker.lorem.paragraphs(),
                            createdBy: GetUsers(count: 1)[0],
                            dateCreated: dateCreated,
                            dateModified: faker.date.between(dateCreated, Date("2020-01-01")),
                            metrics: Metrics(views: faker.number.randomInt(min: 1, max: 100000),
                                             likes: likes,
                                             upvotes: faker.number.randomInt(min: 1, max: 10000),
                                             downvotes: faker.number.randomInt(min: 1, max: 10000)),
                            answers: answers,
                            media: postMedia,
                            exercises: postExercises))
        }
        
        return exercisePosts
    }
    
    private static func createFakeUser() -> User {
        return createFakeTrainer() as User
    }
    
    private static func createFakeTrainer() -> Trainer {
        let trainer = Trainer(id: "\(faker.number.increasingUniqueId())")
        trainer.information = Identity(salutation: faker.name.prefix(),
                                    firstName: faker.name.firstName(),
                                    middleName: faker.name.firstName(),
                                    lastName: faker.name.lastName(),
                                    gender: faker.gender.binaryType(),
                                    birthDate: faker.date.birthday(13, 69))
        trainer.measurement = BodyMeasurement(height: faker.number.randomInt(min: 45, max: 85),
                                           weight: faker.number.randomInt(min: 85, max: 450))
        trainer.profilePictureUrl = URL(string: faker.internet.image())
        trainer.username = faker.internet.username()
        
        var phoneNumbers = [PhoneNumber]()
        let phoneNumberTypes: [PhoneNumberType] = [.Business, .Cell, .Home]
        for _ in 1...Int.random(in: 1..<4) {
            phoneNumbers.append(PhoneNumber(number: faker.phoneNumber.phoneNumber(), type: phoneNumberTypes[Int.random(in: 0..<3)]))
        }
        
        var emailAddresses = [Email]()
        for _ in 1...Int.random(in: 1..<4) {
            emailAddresses.append(Email(emailAddress: faker.internet.email()))
        }
        trainer.contactInformation = Contact(phoneNumbers: phoneNumbers, emailAddresses: emailAddresses)
        
        trainer.occupationTitle = faker.name.title()
        trainer.occupationCompany = faker.company.name()
        trainer.website = URL(string: faker.internet.url())
        
        var certifications = [Certification]()
        
        for _ in 1...Int.random(in: 1..<3) {
            certifications.append(Certification(name: nasmSpecializations[Int.random(in: 0..<nasmSpecializations.count)], issuer: Organization(name: "NASM")))
        }
        trainer.certifications = certifications
        
        return trainer
    }
}
