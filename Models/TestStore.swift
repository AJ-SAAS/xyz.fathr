import Foundation
import FirebaseAuth
import FirebaseFirestore

class TestStore: ObservableObject {
    @Published var tests: [TestData] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        print("Initializing TestStore with empty tests")
        tests = []
        startAuthListener()
    }

    deinit {
        print("Removing listeners for TestStore")
        listener?.remove()
        if let authHandle = authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }

    private func startAuthListener() {
        print("Starting auth state listener")
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                print("Auth state changed: User signed in with ID: \(user.uid)")
                self?.startListeningForTests(userId: user.uid)
            } else {
                print("Auth state changed: No user signed in")
                self?.tests = []
                self?.listener?.remove()
                self?.listener = nil
            }
        }
    }

    private func startListeningForTests(userId: String) {
        print("Starting listener for tests for user: \(userId)")
        let collectionRef = db.collection("users").document(userId).collection("tests")
        listener?.remove() // Prevent duplicate listeners
        listener = collectionRef
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    print("Error fetching tests: \(error.localizedDescription)")
                    self?.tests = []
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    print("No documents found for user: \(userId)")
                    self?.tests = []
                    return
                }
                print("Found \(documents.count) tests for user: \(userId)")
                let decodedTests = documents.compactMap { document -> TestData? in
                    do {
                        let test = try document.data(as: TestData.self)
                        print("Loaded test with ID: \(test.id ?? "nil"), Date: \(test.date)")
                        return test
                    } catch {
                        print("Error decoding test document \(document.documentID): \(error.localizedDescription)")
                        return nil
                    }
                }
                self?.tests = decodedTests
                print("Updated tests array: \(self?.tests.count ?? 0) tests")
            }
    }

    func addTest(_ test: TestData) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID, cannot add test")
            return
        }
        print("Adding test for user: \(userId), Date: \(test.date)")
        let collectionRef = db.collection("users").document(userId).collection("tests")
        do {
            let documentRef = try collectionRef.addDocument(from: test)
            print("Successfully added test with ID: \(documentRef.documentID)")
        } catch {
            print("Error adding test: \(error.localizedDescription)")
        }
    }

    func deleteTests(at offsets: IndexSet) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID, cannot delete tests")
            return
        }
        print("Deleting tests for user: \(userId)")
        let collectionRef = db.collection("users").document(userId).collection("tests")
        offsets.forEach { index in
            if let testId = tests[index].id {
                print("Deleting test with ID: \(testId)")
                collectionRef.document(testId).delete()
            }
        }
    }
    
    func deleteAllTestsForUser(userId: String, completion: @escaping (Bool) -> Void) {
        print("Deleting all tests for user: \(userId)")
        let collectionRef = db.collection("users").document(userId).collection("tests")
        collectionRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching tests for deletion: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No tests to delete for user: \(userId)")
                completion(true)
                return
            }
            
            print("Found \(documents.count) tests to delete")
            let batch = collectionRef.firestore.batch()
            for document in documents {
                batch.deleteDocument(document.reference)
            }
            
            batch.commit { error in
                if let error = error {
                    print("Error deleting tests: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Successfully deleted all tests for user: \(userId)")
                    completion(true)
                }
            }
        }
    }
}
