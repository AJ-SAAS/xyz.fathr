import Foundation
import FirebaseFirestore

enum Appearance: String, Codable, CaseIterable { case normal, abnormal }
enum Liquefaction: String, Codable, CaseIterable { case normal, abnormal }
enum Consistency: String, Codable, CaseIterable { case thin, medium, thick }
enum Agglutination: String, Codable, CaseIterable { case mild, moderate, severe }

struct TestData: Identifiable, Codable {
    @DocumentID var id: String?
    let appearance: Appearance?
    let liquefaction: Liquefaction?
    let consistency: Consistency?
    let semenQuantity: Double?
    let pH: Double?
    let totalMobility: Double?
    let progressiveMobility: Double?
    let nonProgressiveMobility: Double?
    let travelSpeed: Double?
    let mobilityIndex: Double?
    let still: Double?
    let agglutination: Agglutination?
    let spermConcentration: Double?
    let totalSpermatozoa: Double?
    let functionalSpermatozoa: Double?
    let roundCells: Double?
    let leukocytes: Double?
    let liveSpermatozoa: Double?
    let morphologyRate: Double?
    let pathology: Double?
    let headDefect: Double?
    let neckDefect: Double?
    let tailDefect: Double?
    let date: Date
    var dnaFragmentationRisk: Int?
    var dnaRiskCategory: String?

    enum CodingKeys: String, CodingKey {
        case id
        case appearance
        case liquefaction
        case consistency
        case semenQuantity
        case pH
        case totalMobility
        case progressiveMobility
        case nonProgressiveMobility
        case travelSpeed
        case mobilityIndex
        case still
        case agglutination
        case spermConcentration
        case totalSpermatozoa
        case functionalSpermatozoa
        case roundCells
        case leukocytes
        case liveSpermatozoa
        case morphologyRate
        case pathology
        case headDefect
        case neckDefect
        case tailDefect
        case date
        case dnaFragmentationRisk
        case dnaRiskCategory
    }

    init(
        id: String? = nil,
        appearance: Appearance? = nil,
        liquefaction: Liquefaction? = nil,
        consistency: Consistency? = nil,
        semenQuantity: Double? = nil,
        pH: Double? = nil,
        totalMobility: Double? = nil,
        progressiveMobility: Double? = nil,
        nonProgressiveMobility: Double? = nil,
        travelSpeed: Double? = nil,
        mobilityIndex: Double? = nil,
        still: Double? = nil,
        agglutination: Agglutination? = nil,
        spermConcentration: Double? = nil,
        totalSpermatozoa: Double? = nil,
        functionalSpermatozoa: Double? = nil,
        roundCells: Double? = nil,
        leukocytes: Double? = nil,
        liveSpermatozoa: Double? = nil,
        morphologyRate: Double? = nil,
        pathology: Double? = nil,
        headDefect: Double? = nil,
        neckDefect: Double? = nil,
        tailDefect: Double? = nil,
        date: Date,
        dnaFragmentationRisk: Int? = nil,
        dnaRiskCategory: String? = nil
    ) {
        self.id = id
        self.appearance = appearance
        self.liquefaction = liquefaction
        self.consistency = consistency
        self.semenQuantity = semenQuantity
        self.pH = pH
        self.totalMobility = totalMobility
        self.progressiveMobility = progressiveMobility
        self.nonProgressiveMobility = nonProgressiveMobility
        self.travelSpeed = travelSpeed
        self.mobilityIndex = mobilityIndex
        self.still = still
        self.agglutination = agglutination
        self.spermConcentration = spermConcentration
        self.totalSpermatozoa = totalSpermatozoa
        self.functionalSpermatozoa = functionalSpermatozoa
        self.roundCells = roundCells
        self.leukocytes = leukocytes
        self.liveSpermatozoa = liveSpermatozoa
        self.morphologyRate = morphologyRate
        self.pathology = pathology
        self.headDefect = headDefect
        self.neckDefect = neckDefect
        self.tailDefect = tailDefect
        self.date = date
        self.dnaFragmentationRisk = dnaFragmentationRisk
        self.dnaRiskCategory = dnaRiskCategory
    }

    var analysisStatus: String {
        if appearance == .normal && liquefaction == .normal && (pH ?? 7.2) >= 7.2 && (pH ?? 8.0) <= 8.0 && (semenQuantity ?? 1.5) >= 1.5 {
            return "Typical"
        }
        return "Atypical"
    }

    var motilityStatus: String {
        if (totalMobility ?? 40) >= 40 && (progressiveMobility ?? 32) >= 32 && agglutination == .mild {
            return "Active"
        }
        return "Less Active"
    }

    var concentrationStatus: String {
        if (spermConcentration ?? 15) >= 15 && (liveSpermatozoa ?? 58) >= 58 {
            return "Typical"
        }
        return "Lower"
    }

    var morphologyStatus: String {
        if (morphologyRate ?? 4) >= 4 {
            return "Typical"
        }
        return "Varied"
    }

    var overallStatus: String {
        if analysisStatus == "Typical" && motilityStatus == "Active" && concentrationStatus == "Typical" && morphologyStatus == "Typical" {
            return "Balanced"
        }
        return "Review"
    }

    mutating func estimateDNAFragmentation() {
        let weights: [String: Double] = [
            "low_mobility": 0.30,
            "abnormal_morph": 0.25,
            "high_leukocytes": 0.20,
            "low_volume": 0.15,
            "abnormal_ph": 0.10
        ]
        
        var riskScore: Double = 0
        var flags: [String] = []
        
        if (totalMobility ?? 100) < 40 {
            riskScore += weights["low_mobility"]!
            flags.append("low motility")
        }
        if (morphologyRate ?? 100) < 4 {
            riskScore += weights["abnormal_morph"]!
            flags.append("abnormal morphology")
        }
        if (leukocytes ?? 0) > 1 {
            riskScore += weights["high_leukocytes"]!
            flags.append("high leukocytes")
        }
        if (semenQuantity ?? 100) < 1.5 {
            riskScore += weights["low_volume"]!
            flags.append("low semen volume")
        }
        if (pH ?? 7.2) < 7.2 || (pH ?? 8.0) > 8.0 {
            riskScore += weights["abnormal_ph"]!
            flags.append("abnormal pH")
        }
        
        let estimatedRisk = min(Int(riskScore * 100), 100)
        self.dnaFragmentationRisk = estimatedRisk
        self.dnaRiskCategory = estimatedRisk < 20 ? "Low" : (estimatedRisk < 40 ? "Moderate" : "High")
    }
}

extension TestData: Equatable {
    static func == (lhs: TestData, rhs: TestData) -> Bool {
        return lhs.id == rhs.id &&
               lhs.appearance == rhs.appearance &&
               lhs.liquefaction == rhs.liquefaction &&
               lhs.consistency == rhs.consistency &&
               lhs.semenQuantity == rhs.semenQuantity &&
               lhs.pH == rhs.pH &&
               lhs.totalMobility == rhs.totalMobility &&
               lhs.progressiveMobility == rhs.progressiveMobility &&
               lhs.nonProgressiveMobility == rhs.nonProgressiveMobility &&
               lhs.travelSpeed == rhs.travelSpeed &&
               lhs.mobilityIndex == rhs.mobilityIndex &&
               lhs.still == rhs.still &&
               lhs.agglutination == rhs.agglutination &&
               lhs.spermConcentration == rhs.spermConcentration &&
               lhs.totalSpermatozoa == rhs.totalSpermatozoa &&
               lhs.functionalSpermatozoa == rhs.functionalSpermatozoa &&
               lhs.roundCells == rhs.roundCells &&
               lhs.leukocytes == rhs.leukocytes &&
               lhs.liveSpermatozoa == rhs.liveSpermatozoa &&
               lhs.morphologyRate == rhs.morphologyRate &&
               lhs.pathology == rhs.pathology &&
               lhs.headDefect == rhs.headDefect &&
               lhs.neckDefect == rhs.neckDefect &&
               lhs.tailDefect == rhs.tailDefect &&
               lhs.date == rhs.date &&
               lhs.dnaFragmentationRisk == rhs.dnaFragmentationRisk &&
               lhs.dnaRiskCategory == rhs.dnaRiskCategory
    }
}
