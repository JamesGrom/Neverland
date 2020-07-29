

import Foundation
//mapbox access token pk.eyJ1IjoiamFja2dyYWhtIiwiYSI6ImNrY2RwbjhqZTAwc2syeHFyYmV5bGN1dnoifQ.8kPMGWwziI9KN5dsvXX1_Q
//mapbox download access token  sk.eyJ1IjoiamFja2dyYWhtIiwiYSI6ImNrY3Zmbm51MzAzcnoyd3M5eTJpcnNkdWQifQ.oaP4CpqZO8njZKkPdwXeGA
//google maps access key AIzaSyBDB1VYQXqR8-lHhVnEm8iT2dEaOcqmV3c
//google cloud? api key AIzaSyBDB1VYQXqR8-lHhVnEm8iT2dEaOcqmV3c
//map ID 4cf5bb81a8f298a6
struct K {
    
    struct segueNames{

        static let RegisterToHomeScreen = "RegistrationToHomeScreen"
        static let LoginToHomeScreen = "LoginToHomeScreen"
        static let RegisterToAccountScreen = "RegisterToAccountsScreen"
        
    }
    //used for SMS verification
    static let smsAuthID = "authVerificationID"
    
    //firestore constant
    struct Fstore {
        
        static let messageCollection = "messages" //string used as index to db reference to message page
        static let chatCollection = "chat"
        static let senderField = "sender"
        static let bodyField = "contents"
        static let recieverField = "reciever"
        static let timestamp = "Date"
        
        //contacts lists stored in collection "user Contacts +19145841378"
        //user Contacts should not have any duplicated elements
        static let contactsCollection = "user Contacts" //string used as prefixindex to db to index into a users contact list
        static let contactsName = "their username "
        
        //users collection "users"
        static let usersCollection = "ActiveUsers"
        static let userPhoneNumber = "phone "
        static let userEmail = "Email"
        static let userUserName = "Username"
        static let userAge = "Age"
        static let userContacts = "Contacts List"
        
        
        //pertainting to the Arena
        static let ArenaCollection = "Arenas"
        static let GlobalArenaID = "Global Arena" //has the identifier = 0
        static let coordinateField = "Coordinates"
        static let latitudeField = "latitudeField"
        static let longitudeField = "LongitudeField"
        
        static let documentTypeField = "documentType"
        static let documentType_User = "user"
        static let documentType_Bounty = "Bounty"
        static let documentType_Party = "Party"
    }
    
    //Global Arena ID:
    static let globalArena = 0 
}

//used to hold necessary info for mapbox user annotations
struct userMapboxAnnotationStructure {
    var latitude : Double
    var longitude : Double
    var title : String
    var subtitle : String
}
