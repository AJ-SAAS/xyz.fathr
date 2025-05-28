import SwiftUI
import RevenueCat

// Custom ToggleStyle for minimalistic toggles (black when on)
struct MinimalToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Capsule()
                .frame(width: 30, height: 16)
                .foregroundColor(configuration.isOn ? .black : .gray.opacity(0.3))
                .overlay(
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.white)
                        .shadow(radius: 1)
                        .offset(x: configuration.isOn ? 7 : -7)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
                .accessibilityLabel(configuration.isOn ? "Checked" : "Unchecked")
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
    }
}

// Custom ToggleStyle for DNA Fragmentation (green when on)
struct GreenToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Capsule()
                .frame(width: 30, height: 16)
                .foregroundColor(configuration.isOn ? .green : .gray.opacity(0.3))
                .overlay(
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.white)
                        .shadow(radius: 1)
                        .offset(x: configuration.isOn ? 7 : -7)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
                .accessibilityLabel(configuration.isOn ? "Checked" : "Unchecked")
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
    }
}

struct TestInputView: View {
    @State private var currentPage: Int = 1
    @State private var appearance: Appearance = .normal
    @State private var liquefaction: Liquefaction = .normal
    @State private var consistency: Consistency = .medium
    @State private var semenQuantity: Double = 2.0
    @State private var pH: Double = 7.4
    @State private var totalMobility: Double = 50.0
    @State private var progressiveMobility: Double = 40.0
    @State private var nonProgressiveMobility: Double = 10.0
    @State private var travelSpeed: Double = 0.1
    @State private var mobilityIndex: Double = 60.0
    @State private var still: Double = 30.0
    @State private var agglutination: Agglutination = .mild
    @State private var spermConcentration: Int = 20
    @State private var totalSpermatozoa: Int = 40
    @State private var functionalSpermatozoa: Int = 15
    @State private var roundCells: Double = 0.5
    @State private var leukocytes: Double = 0.2
    @State private var liveSpermatozoa: Double = 70.0
    @State private var morphologyRate: Double = 5.0
    @State private var pathology: Double = 10.0
    @State private var headDefect: Double = 3.0
    @State private var neckDefect: Double = 2.0
    @State private var tailDefect: Double = 1.0
    @State private var estimateDNA: Bool = true
    @State private var hasAppearance: Bool = true
    @State private var hasLiquefaction: Bool = true
    @State private var hasConsistency: Bool = true
    @State private var hasSemenQuantity: Bool = true
    @State private var hasPH: Bool = true
    @State private var hasTotalMobility: Bool = true
    @State private var hasProgressiveMobility: Bool = true
    @State private var hasNonProgressiveMobility: Bool = true
    @State private var hasTravelSpeed: Bool = true
    @State private var hasMobilityIndex: Bool = true
    @State private var hasStill: Bool = true
    @State private var hasAgglutination: Bool = true
    @State private var hasSpermConcentration: Bool = true
    @State private var hasTotalSpermatozoa: Bool = true
    @State private var hasFunctionalSpermatozoa: Bool = true
    @State private var hasRoundCells: Bool = true
    @State private var hasLeukocytes: Bool = true
    @State private var hasLiveSpermatozoa: Bool = true
    @State private var hasMorphologyRate: Bool = true
    @State private var hasPathology: Bool = true
    @State private var hasHeadDefect: Bool = true
    @State private var hasNeckDefect: Bool = true
    @State private var hasTailDefect: Bool = true
    @State private var showConfirmation: Bool = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    if currentPage == 1 {
                        Section(header: Text("Analysis").font(.headline).fontDesign(.rounded)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Appearance", selection: $appearance) {
                                    ForEach(Appearance.allCases, id: \.self) {
                                        Text($0.rawValue.capitalized).tag($0)
                                    }
                                }
                                .disabled(!hasAppearance)
                                .accessibilityLabel("Appearance")
                                .accessibilityValue(appearance.rawValue.capitalized)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasAppearance)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Liquefaction", selection: $liquefaction) {
                                    ForEach(Liquefaction.allCases, id: \.self) {
                                        Text($0.rawValue.capitalized).tag($0)
                                    }
                                }
                                .disabled(!hasLiquefaction)
                                .accessibilityLabel("Liquefaction")
                                .accessibilityValue(liquefaction.rawValue.capitalized)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasLiquefaction)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Consistency", selection: $consistency) {
                                    ForEach(Consistency.allCases, id: \.self) {
                                        Text($0.rawValue.capitalized).tag($0)
                                    }
                                }
                                .disabled(!hasConsistency)
                                .accessibilityLabel("Consistency")
                                .accessibilityValue(consistency.rawValue.capitalized)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasConsistency)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Semen Quantity (mL)", selection: $semenQuantity) {
                                    ForEach(Array(stride(from: 0.0, through: 10.0, by: 0.1)), id: \.self) {
                                        Text(String(format: "%.1f", $0)).tag($0)
                                    }
                                }
                                .disabled(!hasSemenQuantity)
                                .accessibilityLabel("Semen Quantity")
                                .accessibilityValue(String(format: "%.1f mL", semenQuantity))
                                Toggle("I haven’t had this test / Not sure", isOn: $hasSemenQuantity)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                Picker("pH", selection: $pH) {
                                    ForEach(Array(stride(from: 0.0, through: 14.0, by: 0.1)), id: \.self) {
                                        Text(String(format: "%.1f", $0)).tag($0)
                                    }
                                }
                                .disabled(!hasPH)
                                .accessibilityLabel("pH")
                                .accessibilityValue(String(format: "%.1f", pH))
                                Toggle("I haven’t had this test / Not sure", isOn: $hasPH)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)
                        }
                        Section {
                            Text("Fathr is not a medical device. Visualizations are for informational purposes only. Consult a doctor for fertility concerns.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    } else if currentPage == 2 {
                        Section(header: Text("Motility").font(.headline).fontDesign(.rounded)) {
                            VStack(alignment: .leading, spacing: 8) {
                                VStack {
                                    Text("Total Mobility: \(Int(totalMobility))%")
                                    Slider(value: $totalMobility, in: 0...100, step: 1)
                                        .tint(.black)
                                        .accessibilityLabel("Total Mobility")
                                        .accessibilityValue("\(Int(totalMobility)) percent")
                                }
                                .disabled(!hasTotalMobility)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasTotalMobility)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                VStack {
                                    Text("Progressive Mobility: \(Int(progressiveMobility))%")
                                    Slider(value: $progressiveMobility, in: 0...100, step: 1)
                                        .tint(.black)
                                        .accessibilityLabel("Progressive Mobility")
                                        .accessibilityValue("\(Int(progressiveMobility)) percent")
                                }
                                .disabled(!hasProgressiveMobility)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasProgressiveMobility)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                VStack {
                                    Text("Non-Progressive Mobility: \(Int(nonProgressiveMobility))%")
                                    Slider(value: $nonProgressiveMobility, in: 0...100, step: 1)
                                        .tint(.black)
                                        .accessibilityLabel("Non-Progressive Mobility")
                                        .accessibilityValue("\(Int(nonProgressiveMobility)) percent")
                                }
                                .disabled(!hasNonProgressiveMobility)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasNonProgressiveMobility)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Travel Speed (mm/sec)", selection: $travelSpeed) {
                                    ForEach(Array(stride(from: 0.0, through: 1.0, by: 0.01)), id: \.self) {
                                        Text(String(format: "%.2f", $0)).tag($0)
                                    }
                                }
                                .disabled(!hasTravelSpeed)
                                .accessibilityLabel("Travel Speed")
                                .accessibilityValue(String(format: "%.2f mm per second", travelSpeed))
                                Toggle("I haven’t had this test / Not sure", isOn: $hasTravelSpeed)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                VStack {
                                    Text("Mobility Index: \(Int(mobilityIndex))%")
                                    Slider(value: $mobilityIndex, in: 0...100, step: 1)
                                        .tint(.black)
                                        .accessibilityLabel("Mobility Index")
                                        .accessibilityValue("\(Int(mobilityIndex)) percent")
                                }
                                .disabled(!hasMobilityIndex)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasMobilityIndex)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                VStack {
                                    Text("Still: \(Int(still))%")
                                    Slider(value: $still, in: 0...100, step: 1)
                                        .tint(.black)
                                        .accessibilityLabel("Still")
                                        .accessibilityValue("\(Int(still)) percent")
                                }
                                .disabled(!hasStill)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasStill)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Agglutination", selection: $agglutination) {
                                    ForEach(Agglutination.allCases, id: \.self) {
                                        Text($0.rawValue.capitalized).tag($0)
                                    }
                                }
                                .disabled(!hasAgglutination)
                                .accessibilityLabel("Agglutination")
                                .accessibilityValue(agglutination.rawValue.capitalized)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasAgglutination)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)
                        }
                        Section {
                            Text("Fathr is not a medical device. Visualizations are for informational purposes only. Consult a doctor for fertility concerns.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    } else if currentPage == 3 {
                        Section(header: Text("Concentration").font(.headline).fontDesign(.rounded)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Sperm Concentration (M/mL)", selection: $spermConcentration) {
                                    ForEach(0...100, id: \.self) {
                                        Text("\($0)").tag($0)
                                    }
                                }
                                .disabled(!hasSpermConcentration)
                                .accessibilityLabel("Sperm Concentration")
                                .accessibilityValue("\(spermConcentration) million per mL")
                                Toggle("I haven’t had this test / Not sure", isOn: $hasSpermConcentration)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Total Spermatozoa (M/mL)", selection: $totalSpermatozoa) {
                                    ForEach(0...200, id: \.self) {
                                        Text("\($0)").tag($0)
                                    }
                                }
                                .disabled(!hasTotalSpermatozoa)
                                .accessibilityLabel("Total Spermatozoa")
                                .accessibilityValue("\(totalSpermatozoa) million per mL")
                                Toggle("I haven’t had this test / Not sure", isOn: $hasTotalSpermatozoa)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Functional Spermatozoa (M/mL)", selection: $functionalSpermatozoa) {
                                    ForEach(0...100, id: \.self) {
                                        Text("\($0)").tag($0)
                                    }
                                }
                                .disabled(!hasFunctionalSpermatozoa)
                                .accessibilityLabel("Functional Spermatozoa")
                                .accessibilityValue("\(functionalSpermatozoa) million per mL")
                                Toggle("I haven’t had this test / Not sure", isOn: $hasFunctionalSpermatozoa)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Round Cells (M/mL)", selection: $roundCells) {
                                    ForEach(Array(stride(from: 0.0, through: 10.0, by: 0.1)), id: \.self) {
                                        Text(String(format: "%.1f", $0)).tag($0)
                                    }
                                }
                                .disabled(!hasRoundCells)
                                .accessibilityLabel("Round Cells")
                                .accessibilityValue(String(format: "%.1f million per mL", roundCells))
                                Toggle("I haven’t had this test / Not sure", isOn: $hasRoundCells)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Leukocytes (M/mL)", selection: $leukocytes) {
                                    ForEach(Array(stride(from: 0.0, through: 5.0, by: 0.1)), id: \.self) {
                                        Text(String(format: "%.1f", $0)).tag($0)
                                    }
                                }
                                .disabled(!hasLeukocytes)
                                .accessibilityLabel("Leukocytes")
                                .accessibilityValue(String(format: "%.1f million per mL", leukocytes))
                                Toggle("I haven’t had this test / Not sure", isOn: $hasLeukocytes)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                VStack {
                                    Text("Live Spermatozoa: \(Int(liveSpermatozoa))%")
                                    Slider(value: $liveSpermatozoa, in: 0...100, step: 1)
                                        .tint(.black)
                                        .accessibilityLabel("Live Spermatozoa")
                                        .accessibilityValue("\(Int(liveSpermatozoa)) percent")
                                }
                                .disabled(!hasLiveSpermatozoa)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasLiveSpermatozoa)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)
                        }
                        Section {
                            Text("Fathr is not a medical device. Visualizations are for informational purposes only. Consult a doctor for fertility concerns.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    } else if currentPage == 4 {
                        Section(header: Text("Morphology").font(.headline).fontDesign(.rounded)) {
                            VStack(alignment: .leading, spacing: 8) {
                                VStack {
                                    Text("Morphology Rate: \(Int(morphologyRate))%")
                                    Slider(value: $morphologyRate, in: 0...100, step: 1)
                                        .tint(.black)
                                        .accessibilityLabel("Morphology Rate")
                                        .accessibilityValue("\(Int(morphologyRate)) percent")
                                }
                                .disabled(!hasMorphologyRate)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasMorphologyRate)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                VStack {
                                    Text("Pathology: \(Int(pathology))%")
                                    Slider(value: $pathology, in: 0...100, step: 1)
                                        .tint(.black)
                                        .accessibilityLabel("Pathology")
                                        .accessibilityValue("\(Int(pathology)) percent")
                                }
                                .disabled(!hasPathology)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasPathology)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                VStack {
                                    Text("Head Defect: \(Int(headDefect))%")
                                    Slider(value: $headDefect, in: 0...100, step: 1)
                                        .tint(.black)
                                        .accessibilityLabel("Head Defect")
                                        .accessibilityValue("\(Int(headDefect)) percent")
                                }
                                .disabled(!hasHeadDefect)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasHeadDefect)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                VStack {
                                    Text("Neck Defect: \(Int(neckDefect))%")
                                    Slider(value: $neckDefect, in: 0...100, step: 1)
                                        .tint(.black)
                                        .accessibilityLabel("Neck Defect")
                                        .accessibilityValue("\(Int(neckDefect)) percent")
                                }
                                .disabled(!hasNeckDefect)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasNeckDefect)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                VStack {
                                    Text("Tail Defect: \(Int(tailDefect))%")
                                    Slider(value: $tailDefect, in: 0...100, step: 0.1)
                                        .tint(.black)
                                        .accessibilityLabel("Tail Defect")
                                        .accessibilityValue("\(Int(tailDefect)) percent")
                                }
                                .disabled(!hasTailDefect)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasTailDefect)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 4)
                        }
                        Section(header: Text("DNA Fragmentation").font(.headline).fontDesign(.rounded)) {
                            Toggle("Estimate DNA Fragmentation Risk", isOn: $estimateDNA)
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .toggleStyle(GreenToggleStyle())
                                .padding(.vertical, 4)
                        }
                        Section {
                            Text("Fathr is not a medical device. Visualizations are for informational purposes only. Consult a doctor for fertility concerns.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                }

                HStack {
                    if currentPage > 1 {
                        Button("Back") {
                            currentPage -= 1
                        }
                        .buttonStyle(.bordered)
                        .tint(.gray)
                        .accessibilityLabel("Back to previous page")
                    }

                    Spacer()

                    if currentPage < 4 {
                        Button("Next") {
                            currentPage += 1
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .accessibilityLabel("Next page")
                    } else {
                        Button("Submit") {
                            showConfirmation = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .accessibilityLabel("Submit test results")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Add Test - Page \(currentPage)/4")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                    .accessibilityLabel("Cancel test input")
                }
            }
            .alert("Submit Test", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Submit") {
                    submitTest()
                }
            } message: {
                Text("Are you sure you want to submit your test results? You can view detailed analysis after submission, but some features may require a subscription.")
            }
        }
    }

    private func submitTest() {
        var newTest = TestData(
            id: nil,
            appearance: hasAppearance ? appearance : nil,
            liquefaction: hasLiquefaction ? liquefaction : nil,
            consistency: hasConsistency ? consistency : nil,
            semenQuantity: hasSemenQuantity ? semenQuantity : nil,
            pH: hasPH ? pH : nil,
            totalMobility: hasTotalMobility ? totalMobility : nil,
            progressiveMobility: hasProgressiveMobility ? progressiveMobility : nil,
            nonProgressiveMobility: hasNonProgressiveMobility ? nonProgressiveMobility : nil,
            travelSpeed: hasTravelSpeed ? travelSpeed : nil,
            mobilityIndex: hasMobilityIndex ? mobilityIndex : nil,
            still: hasStill ? still : nil,
            agglutination: hasAgglutination ? agglutination : nil,
            spermConcentration: hasSpermConcentration ? Double(spermConcentration) : nil,
            totalSpermatozoa: hasTotalSpermatozoa ? Double(totalSpermatozoa) : nil,
            functionalSpermatozoa: hasFunctionalSpermatozoa ? Double(functionalSpermatozoa) : nil,
            roundCells: hasRoundCells ? roundCells : nil,
            leukocytes: hasLeukocytes ? leukocytes : nil,
            liveSpermatozoa: hasLiveSpermatozoa ? liveSpermatozoa : nil,
            morphologyRate: hasMorphologyRate ? morphologyRate : nil,
            pathology: hasPathology ? pathology : nil,
            headDefect: hasHeadDefect ? headDefect : nil,
            neckDefect: hasNeckDefect ? neckDefect : nil,
            tailDefect: hasTailDefect ? tailDefect : nil,
            date: Date()
        )

        if estimateDNA {
            newTest.estimateDNAFragmentation()
        }

        print("Submitting test: Appearance=\(String(describing: newTest.appearance)), SemenQuantity=\(String(describing: newTest.semenQuantity)), Date=\(newTest.date)")
        testStore.addTest(newTest)
        print("Test submitted")

        dismiss()
    }
}

struct TestInputView_Previews: PreviewProvider {
    static var previews: some View {
        TestInputView()
            .environmentObject(TestStore())
            .environmentObject(PurchaseModel())
    }
}
