import Foundation
import Fakery

class FakeDataFactory {
    private static let faker = Faker()
    private static let nasmSpecializations = ["PES", "CES", "FNS", "WLS", "YES", "WFS", "MMAS", "GFS", "SFS"]
    
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
