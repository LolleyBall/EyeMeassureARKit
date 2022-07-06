//
//  NetworkManager.swift
//  EyeMeassure
//
//  Created by Gleb Sysoev on 08.04.2022.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

enum NetworkError: Error {
    case invalidEmail
    case wrongPassword
    case emailAlreadyInUse
    case userNotFound
    case weakPassword
    case networkError
    case otherError
}

typealias NetworkManagerCompletion<T> = (Result<T, Error>) -> Void

protocol NetworkManagerProtocol {
    func loadUser(email: String, password: String, completion: @escaping NetworkManagerCompletion<User>)
    func createUser(email: String,
                    password: String,
                    user: User,
                    completion: @escaping NetworkManagerCompletion<Void>)
    func authCheck(completion: @escaping NetworkManagerCompletion<User>)
    func signout()
}

final class NetworkManager {
    static let shared: NetworkManagerProtocol = NetworkManager()

    private lazy var dataBase = Firestore.firestore()
    private lazy var reference = dataBase.collection(Const.usersFirebaseKey)

    private init() { }
}

extension NetworkManager: NetworkManagerProtocol {
    func loadUser(email: String, password: String, completion: @escaping NetworkManagerCompletion<User>) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard error == nil else {
                guard let error = error else { return }
                guard let authErrorCode = AuthErrorCode(rawValue: (error as NSError).code) else {
                    return
                }
                completion(.failure(NetworkManager.convert(authErrorCode)))
                return
            }
            guard let login = result else { return }
            self?.reference.document(login.user.uid).getDocument { data, _ in
                guard let dictionary = data?.data(),
                      let user = User(from: dictionary) else { return }
                completion(.success(user))
            }
        }
    }

    func createUser(email: String,
                    password: String,
                    user: User,
                    completion: @escaping NetworkManagerCompletion<Void>) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard error == nil else {
                guard let error = error else { return }
                guard let authErrorCode = AuthErrorCode(rawValue: (error as NSError).code) else {
                    return
                }
                completion(.failure(NetworkManager.convert(authErrorCode)))
                return
            }
            guard let created = result else { return }
            self.reference
                .document(created.user.uid)
                .setData(["username": user.name,
                          "phone": user.phone as Any,
                          "adress": user.adress]) { error in
                    guard error == nil else {
                        guard let error = error else { return }
                        guard let authErrorCode = AuthErrorCode(rawValue: (error as NSError).code) else {
                            return
                        }
                        completion(.failure(NetworkManager.convert(authErrorCode)))
                        return
                    }
                }
            completion(.success(Void()))
        }
    }

    func signout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    func authCheck(completion: @escaping NetworkManagerCompletion<User>) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        reference.document(currentUser.uid).getDocument { data, error in
            guard error == nil else {
                guard let error = error else { return }
                guard let authErrorCode = AuthErrorCode(rawValue: (error as NSError).code) else {
                    return
                }
                completion(.failure(NetworkManager.convert(authErrorCode)))
                return
            }
            guard let dictionary = data?.data(),
                  let user = User(from: dictionary) else {
                      return
                  }
            completion(.success(user))
        }
    }

    private static func convert(_ errorCode: AuthErrorCode) -> NetworkError {
        switch errorCode {
        case .wrongPassword:
            return .wrongPassword
        case .invalidEmail:
            return .invalidEmail
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .userNotFound:
            return .userNotFound
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .networkError
        default:
            return .otherError
        }
    }
}

private struct Const {
    static let usersFirebaseKey = "users"
}
