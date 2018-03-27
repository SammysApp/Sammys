//
//  UserAPIClient.swift
//  Sammys
//
//  Created by Natanel Niazoff on 1/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

private typealias FirebaseUser = Firebase.User

/**
 A type returned by the API connoting the user state.
 - `noUser`: no user logged in.
 - `currentUser`: current user logged in.
 */
enum UserState {
    case noUser
    case currentUser(User)
}

/**
 A type that is able to observe updates to `UserAPIClient`.
 */
protocol UserAPIObserver {
    /// A unique id to identify the specific observer. Primarily used to remove the observer from observing.
    var id: String { get }
    
    /// A closure property that's called upon the user state changing.
    var userStateDidChange: ((UserState) -> Void)? { get }
    
    /// A closure property that's called upon a change to the user's favorites.
    var favoritesValueDidChange: (([FavoriteGroup]) -> Void)? { get }
}

/// A singleton class that stores observers to `UserAPIClient`.
private class UserAPIObservers {
    /// The shared singleton property.
    static let shared = UserAPIObservers()
    
    /// The array of observers.
    var observers = [UserAPIObserver]()
    
    private init() {}
}

/// A type that represents a user's favorites ❤️ categorized by food type.
struct FavoriteGroup {
    /// The food type category for the favorites.
    let foodType: FoodType
    
    /// The user's favorite foods.
    var favorites: [Food]
}

/// A client to make user calls to the user 👩🏻 API 🏭.
struct UserAPIClient {
    /// The shared Firebase database reference.
    private static let database = Database.database().reference()
    
    // MARK: - Observers
    private static var observers: [UserAPIObserver] {
        get {
            return UserAPIObservers.shared.observers
        } set {
            UserAPIObservers.shared.observers = newValue
        }
    }
    
    /**
     A type returned by API.
     - `success`: ended with success.
     */
    enum APIResult {
        case success
    }
    
    /**
     A type returned by API for user related tasks.
     - `success`: ended with success.
     */
    enum UserAPIResult {
        case success(user: User)
    }
    
    /**
     A type returned by API for user favorites.
     - `success`: ended with success.
     */
    enum FavoritesAPIResult {
        case success([FavoriteGroup])
        case failure
    }
    
    /**
     A type returned by API for customer ID.
     - `success`: ended with success.
     */
    enum CustomerIDAPIResult {
        case success(id: String)
        case failure(Error)
    }
    
    enum UserAPIError: Error {
        case doesNotExist
    }
    
    static func addObserver(_ observer: UserAPIObserver) {
        observers.append(observer)
    }
    
    static func removeObserver(_ observer: UserAPIObserver) {
        // Filter observer array to disclude the given observer by its unique id.
        observers = observers.filter { $0.id != observer.id }
    }
    
    // MARK: - User 💁🏻‍♀️
    /**
     Creates a new `User` object from a `FirebaseUser` one and sends object to observers.
     - Parameter user: A `FirebaseUser` object to be converted to a `User` one.
     */
    private static func setupCurrentUser(_ user: FirebaseUser, completed: ((User) -> Void)? = nil) {
        guard let email = user.email, let name = user.displayName
            else { return }
        let currentUser = User(id: user.uid, email: email, name: name)
        observers.forEach { $0.userStateDidChange?(.currentUser(currentUser)) }
        completed?(currentUser)
    }
    
    /// Starts the listener for changes in user state.
    static func startUserStateDidChangeListener() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            // If a new user has or is signed in...
            if let user = user {
                // ...setup user.
                setupCurrentUser(user)
            }
            // If there's no user or user signed out...
            else {
                // ...tell observers.
                observers.forEach { $0.userStateDidChange?(.noUser) }
            }
        }
    }
    
    /**
     Creates a new user with the provided information and calls `completed` upon completion.
     - Parameter name: The user's name.
     - Parameter email: The user's properly formed email.
     - Parameter password: The user's properly formed password.
     - Parameter completed: A closure called once API completed attempting to create user. Default is `nil`.
     - Parameter result: The `APIResult` value the API completed with.
    */
    static func createUser(with name: String, email: String, password: String, completed: ((_ result: UserAPIResult) -> Void)? = nil) {
        // Create a user with `email` and `password`.
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            // If there was an error...
            if let error = error {
                printError(error)
            }
            // If a user was created...
            else if let user = Auth.auth().currentUser {
                let changeRequest = user.createProfileChangeRequest()
                // ...attempt to add the `name` to the user.
                changeRequest.displayName = name
                changeRequest.commitChanges { error in
                    // If there was an error adding the name...
                    if let error = error {
                        printError(error)
                    }
                    // If successfully added the name...
                    else {
                        // setup the user...
                        setupCurrentUser(user) { currentUser in
                            // ...and call closure with `success`.
                            completed?(.success(user: currentUser))
                        }
                    }
                }
            }
        }
    }
    
    /**
     Signs in user with the provided information and calls `completed` upon completion.
     - Parameter email: The user's email.
     - Parameter password: The user's password.
     - Parameter completed: A closure called once API completed attempting to sign in user. Default is `nil`.
     - Parameter result: The `APIResult` value the API completed with.
    */
    static func signIn(with email: String, password: String, completed: ((_ result: APIResult) -> Void)? = nil) {
        // Sign in user with `email` and `password`.
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            // If there was an error...
            if let error = error {
                printError(error)
            }
            // If successfully signed in user...
            else {
                // call closure with `success`.
                completed?(.success)
            }
        }
    }
    
    /// Signs out current user.
    static func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            printError(error)
        }
    }
    
    // MARK: - Favorites ❤️
    /// Returns the data favorites reference for the user.
    private static func favoritesReference(for userID: String) -> DatabaseReference {
        return database.users.user(with: userID).favorites
    }
    
    /**
     Creates a new favorites array from the children of the given `snapshot` and calls `completed` with the favorites when finished.
     - Parameter snapshot: A `DataSnapshot` object with favorites as children.
     - Parameter completed: A closure that's called once favorites array is done being setup.
     - Parameter favorites: An array of user's favorites.
     */
    private static func setupFavorites(with snapshot: DataSnapshot, completed: (_ favorites: [FavoriteGroup]) -> Void) {
        // Make sure snapshot has data.
        guard snapshot.exists() else {
            printNoData()
            return
        }
        // Init favorites to empty.
        var favoriteGroups = [FavoriteGroup]()
        // For every food type snapshot in the snapshot...
        for foodTypeSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
            if let foodType = FoodType(rawValue: foodTypeSnapshot.key) {
                // ...create a food group for the food type.
                var favoriteGroup = FavoriteGroup(foodType: foodType, favorites: [])
                // For every favorite value in the snapshot...
                for favoriteSnapshot in foodTypeSnapshot.children.allObjects as! [DataSnapshot] {
                    if let jsonString = favoriteSnapshot.value as? String,
                        let jsonData = jsonString.data(using: .utf8) {
                        do {
                            // ...attempt to decode the JSON...
                            let favorite = try JSONDecoder().decode(AnyFood.self, from: jsonData)
                            // ...and append the new object to the favorite group's array.
                            favoriteGroup.favorites.append(favorite.food)
                        } catch {
                            printError(error)
                        }
                    }
                }
                // Append the new group to the favorite groups.
                favoriteGroups.append(favoriteGroup)
            }
        }
        // Once favorites array is ready, send to closure.
        completed(favoriteGroups)
    }
    
    /// Starts the observer for changes to favorites in the database.
    static func startFavoritesValueChangeObserver() {
        // If there's a user signed in...
        if let user = Auth.auth().currentUser {
            // ...when a change is detected to the user's favorites...
            favoritesReference(for: user.uid).observe(.value) { (snapshot) in
                // ...if there's no data...
                if !snapshot.exists() {
                    observers.forEach { $0.favoritesValueDidChange?([]) }
                }
                // ...if there's data...
                else {
                    // ...set up the favorites array...
                    setupFavorites(with: snapshot) { favorites in
                        // ...and send to observers.
                        observers.forEach { $0.favoritesValueDidChange?(favorites) }
                    }
                }
            }
        }
    }
    
    /**
     Does a one time fetch for a user's favorites.
     - Parameter user: The user to fetch favorites for.
     - Parameter completed: A closure to call once completed fetching favorites.
     - Parameter result: The `APIResult` value the API completed with.
    */
    static func fetchFavorites(for user: User, completed: @escaping (_ result: FavoritesAPIResult) -> Void) {
        // Commence single observation of the given user's favorites.
        favoritesReference(for: user.id).observeSingleEvent(of: .value) { (snapshot) in
            // If there's no data...
            if !snapshot.exists() {
                completed(.failure)
                observers.forEach { $0.favoritesValueDidChange?([]) }
            }
            // If returned data...
            else {
                // ...setup favorites...
                setupFavorites(with: snapshot) { favorites in
                    // ...send to observers...
                    observers.forEach { $0.favoritesValueDidChange?(favorites) }
                    // ...and send to closure with `success`.
                    completed(.success(favorites))
                }
            }
        }
    }
    
    /**
     Sets a favorite value to a favorite key as a child of a user.
     - Parameter favorite: The favorite object to add.
     - Parameter user: The user to add the favorite object to.
    */
    static func set(_ favorite: Food, for user: User) {
        do {
            // Attempt to encode the favorites object to JSON.
            let jsonData = try JSONEncoder().encode(AnyFood(favorite))
            let jsonString = String(data: jsonData, encoding: .utf8)
            // Set the JSON string as the value of the new favorite child.
            // favorites -> { food type } -> [favorite id : value]
            favoritesReference(for: user.id).child(type(of: favorite).type).child(favorite.id).setValue(jsonString)
        } catch {
            printError(error)
        }
    }
    
    // MARK: - Payment 💰
    /// Sets the Stripe customer ID for the given user.
    static func set(_ customerID: String, for user: User) {
        database.users.user(with: user.id).customerID.setValue(customerID)
    }
    
    /// Gets the Stripe customer ID for the given user.
    static func getCustomerID(for user: User, completed: @escaping (_ result: CustomerIDAPIResult) -> Void) {
        database.users.user(with: user.id).customerID.observeSingleEvent(of: .value) { snapshot in
            // If there's no data...
            if !snapshot.exists() {
                completed(.failure(UserAPIError.doesNotExist))
                printNoData()
            }
            // If returned data...
            else {
                // ...send customer id to closure.
                if let customerID = snapshot.value as? String {
                    completed(.success(id: customerID))
                }
            }
        }
    }
    
    // MARK: - Debug
    private static func printNoData(line: Int = #line, file: String = #file) {
        print("No data. Line \(line) in \(file).")
    }
    
    private static func printError(_ error: Error, line: Int = #line, file: String = #file) {
        print("\(error). Line \(line) in \(file).")
    }
}

// MARK: - References
private extension DatabaseReference {
    var users: DatabaseReference {
        return child("users")
    }
    
    var favorites: DatabaseReference {
        return child("favorites")
    }
    
    var salad: DatabaseReference {
        return child(FoodType.salad.rawValue)
    }
    
    var customerID: DatabaseReference {
        return child("customerID")
    }
    
    func user(with id: String) -> DatabaseReference {
        return child(id)
    }
    
    func child(_ foodType: FoodType) -> DatabaseReference {
        switch foodType {
        case .salad:
            return salad
        }
    }
}

// Default values for `UserAPIObsever` protocol methods.
extension UserAPIObserver {
    var userStateDidChange: ((UserState) -> Void)? {
        return nil
    }
    
    var favoritesValueDidChange: (([FavoriteGroup]) -> Void)? {
        return nil
    }
}
