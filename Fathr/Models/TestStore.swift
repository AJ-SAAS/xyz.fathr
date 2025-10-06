import Foundation
import FirebaseAuth
import FirebaseFirestore

class TestStore: ObservableObject {
    @Published var tests: [TestData] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var authHandle: AuthStateDidChangeListenerHandle?
    private var challengeListener: ListenerRegistration?

    init() {
        print("Initializing TestStore with empty tests")
        tests = []
        startAuthListener()
    }

    deinit {
        print("Removing listeners for TestStore")
        listener?.remove()
        challengeListener?.remove()
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
                self?.startListeningForChallengeProgress(userId: user.uid)
            } else {
                print("Auth state changed: No user signed in")
                self?.tests = []
                self?.listener?.remove()
                self?.challengeListener?.remove()
                self?.listener = nil
                self?.challengeListener = nil
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

    // MARK: - Challenge Progress
    struct ChallengeProgress: Codable {
        let startDate: Date?
        let completionStatus: [Int: String]
        let fhi: Int
    }

    func saveChallengeProgress(userId: String, startDate: Date?, completionStatus: [Int: String], fhi: Int, completion: @escaping (Bool) -> Void = { _ in }) {
        print("Saving challenge progress for user: \(userId), startDate: \(startDate?.description ?? "nil"), completionStatus: \(completionStatus), fhi: \(fhi)")
        let progress = ChallengeProgress(startDate: startDate, completionStatus: completionStatus, fhi: fhi)
        let docRef = db.collection("users").document(userId).collection("challenge").document("progress")
        do {
            let data = try Firestore.Encoder().encode(progress)
            print("Encoded data: \(data)")
            try docRef.setData(from: progress) { error in
                if let error = error {
                    print("Error saving challenge progress: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Successfully saved challenge progress for user: \(userId)")
                    completion(true)
                }
            }
        } catch {
            print("Error encoding challenge progress: \(error.localizedDescription)")
            completion(false)
        }
    }

    func fetchChallengeProgress(userId: String, completion: @escaping (ChallengeProgress?) -> Void) {
        print("Fetching challenge progress for user: \(userId)")
        let docRef = db.collection("users").document(userId).collection("challenge").document("progress")
        docRef.getDocument { document, error in
            if let error = error {
                print("Error fetching challenge progress: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let document = document, document.exists {
                do {
                    let progress = try document.data(as: ChallengeProgress.self)
                    print("Fetched challenge progress: startDate=\(progress.startDate?.description ?? "none"), fhi=\(progress.fhi)")
                    completion(progress)
                } catch {
                    print("Error decoding challenge progress: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                print("No challenge progress document found for user: \(userId)")
                completion(nil)
            }
        }
    }

    private func startListeningForChallengeProgress(userId: String) {
        print("Starting listener for challenge progress for user: \(userId)")
        let docRef = db.collection("users").document(userId).collection("challenge").document("progress")
        challengeListener?.remove()
        challengeListener = docRef.addSnapshotListener { [weak self] document, error in
            if let error = error {
                print("Error fetching challenge progress snapshot: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                do {
                    let progress = try document.data(as: ChallengeProgress.self)
                    print("Challenge progress updated: startDate=\(progress.startDate?.description ?? "none"), fhi=\(progress.fhi)")
                } catch {
                    print("Error decoding challenge progress snapshot: \(error.localizedDescription)")
                }
            } else {
                print("Challenge progress document does not exist for user: \(userId)")
            }
        }
    }

    func deleteChallengeProgress(userId: String, completion: @escaping (Bool) -> Void) {
        print("Deleting challenge progress for user: \(userId)")
        let docRef = db.collection("users").document(userId).collection("challenge").document("progress")
        docRef.delete { error in
            if let error = error {
                print("Error deleting challenge progress: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully deleted challenge progress")
                completion(true)
            }
        }
    }
}
