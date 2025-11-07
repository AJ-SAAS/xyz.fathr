import Foundation
import FirebaseAuth
import FirebaseFirestore

class TestStore: ObservableObject {
    @Published var tests: [TestData] = []
    @Published var challengeProgress: ChallengeProgress?
    
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

    // MARK: - Auth Listener
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
                self?.challengeProgress = nil
                self?.listener?.remove()
                self?.challengeListener?.remove()
                self?.listener = nil
                self?.challengeListener = nil
            }
        }
    }

    // MARK: - Tests
    private func startListeningForTests(userId: String) {
        print("Starting listener for tests for user: \(userId)")
        let collectionRef = db.collection("users").document(userId).collection("tests")
        listener?.remove()
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
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let collectionRef = db.collection("users").document(userId).collection("tests")
        do {
            _ = try collectionRef.addDocument(from: test)
        } catch {
            print("Error adding test: \(error.localizedDescription)")
        }
    }

    func deleteTests(at offsets: IndexSet) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let collectionRef = db.collection("users").document(userId).collection("tests")
        offsets.forEach { index in
            if let testId = tests[index].id {
                collectionRef.document(testId).delete()
            }
        }
    }

    func deleteAllTestsForUser(userId: String, completion: @escaping (Bool) -> Void) {
        let collectionRef = db.collection("users").document(userId).collection("tests")
        collectionRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching tests for deletion: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let documents = snapshot?.documents else { completion(true); return }
            let batch = collectionRef.firestore.batch()
            for doc in documents { batch.deleteDocument(doc.reference) }
            batch.commit { error in
                completion(error == nil)
            }
        }
    }

    // MARK: - Challenge Progress Models
    struct ChallengeTaskProgress: Codable {
        var completed: Bool = false
    }

    struct ChallengeDayProgress: Codable {
        var tasks: [ChallengeTaskProgress]
        var mood: Int?
        var energy: Int?
        var journalEntry: String?
        var completed: Bool = false  // ← NOW IN MODEL
    }

    struct ChallengeProgress: Codable {
        var startDate: Date  // ← REQUIRED
        var days: [Int: ChallengeDayProgress]
        var fhi: Int = 0
        var hardcoreMode: Bool = true
        var currentStreak: Int = 0
        var bestStreak: Int = 0
    }

    // MARK: - Challenge CRUD
    func saveChallengeProgress(userId: String, completion: @escaping (Bool) -> Void = { _ in }) {
        guard var progress = challengeProgress else { completion(false); return }
        
        // Update FHI before saving
        updateFHI()
        progress.fhi = self.challengeProgress?.fhi ?? 0
        
        let docRef = db.collection("users").document(userId).collection("challenge").document("progress")
        do {
            try docRef.setData(from: progress) { error in
                if let error = error {
                    print("Error saving challenge: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Challenge progress saved successfully")
                    completion(true)
                }
            }
        } catch {
            print("Error encoding challenge progress: \(error.localizedDescription)")
            completion(false)
        }
    }

    func fetchChallengeProgress(userId: String, completion: @escaping (ChallengeProgress?) -> Void) {
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
                    DispatchQueue.main.async { self.challengeProgress = progress }
                    completion(progress)
                } catch {
                    print("Error decoding challenge progress: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

    private func startListeningForChallengeProgress(userId: String) {
        let docRef = db.collection("users").document(userId).collection("challenge").document("progress")
        challengeListener?.remove()
        challengeListener = docRef.addSnapshotListener { [weak self] document, error in
            if let error = error {
                print("Challenge listener error: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                do {
                    let progress = try document.data(as: ChallengeProgress.self)
                    DispatchQueue.main.async {
                        self?.challengeProgress = progress
                        self?.updateFHI() // Ensure FHI is up-to-date
                    }
                } catch {
                    print("Error decoding challenge progress snapshot: \(error.localizedDescription)")
                }
            } else {
                DispatchQueue.main.async {
                    self?.challengeProgress = nil
                }
            }
        }
    }

    func deleteChallengeProgress(userId: String, completion: @escaping (Bool) -> Void) {
        let docRef = db.collection("users").document(userId).collection("challenge").document("progress")
        docRef.delete { error in
            if let error = error {
                print("Error deleting challenge: \(error.localizedDescription)")
            }
            completion(error == nil)
            if error == nil { self.challengeProgress = nil }
        }
    }

    // MARK: - Helper: FHI Calculation
    func updateFHI() {
        guard let progress = challengeProgress else {
            challengeProgress?.fhi = 0
            return
        }
        let allTasks = progress.days.values.flatMap { $0.tasks }
        let completedCount = allTasks.filter { $0.completed }.count
        let totalCount = allTasks.count
        let newFHI = totalCount > 0 ? Int(Double(completedCount) / Double(totalCount) * 100) : 0
        challengeProgress?.fhi = newFHI
    }

    // MARK: - Helper: Initialize Day (Used in ChallengeView)
    func initializeDayIfNeeded(day: Int) {
        guard var progress = challengeProgress else { return }
        guard progress.days[day] == nil else { return }

        let taskCount = ChallengeTasks.allDays.first { $0.dayNumber == day }?.tasks.count ?? 5
        let tasks = Array(repeating: ChallengeTaskProgress(completed: false), count: taskCount)

        progress.days[day] = ChallengeDayProgress(
            tasks: tasks,
            mood: 5,
            energy: 5,
            journalEntry: nil,
            completed: false
        )
        challengeProgress = progress
    }
}
