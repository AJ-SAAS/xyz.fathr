import SwiftUI

struct TestInputView: View {
    @State private var currentPage: Int = 1
    @State private var appearance: Appearance = .normal
    @State private var liquefaction: Liquefaction = .normal
    @State private var consistency: Consistency = .medium
    @State private var semenQuantity: Double = 2.0 // 0.0...10.0, step 0.1
    @State private var pH: Double = 7.4 // 0.0...14.0, step 0.1
    @State private var totalMobility: Double = 50.0 // 0...100, Slider
    @State private var progressiveMobility: Double = 40.0 // 0...100, Slider
    @State private var nonProgressiveMobility: Double = 10.0 // 0...100, Slider
    @State private var travelSpeed: Double = 0.1 // 0.0...1.0, step 0.01
    @State private var mobilityIndex: Double = 60.0 // 0...100, Slider
    @State private var still: Double = 30.0 // 0...100, Slider
    @State private var agglutination: Agglutination = .mild
    @State private var spermConcentration: Int = 20 // 0...100 M/mL
    @State private var totalSpermatozoa: Int = 40 // 0...200 M/mL
    @State private var functionalSpermatozoa: Int = 15 // 0...100 M/mL
    @State private var roundCells: Double = 0.5 // 0.0...10.0, step 0.1
    @State private var leukocytes: Double = 0.2 // 0.0...5.0, step 0.1
    @State private var liveSpermatozoa: Double = 70.0 // 0...100, Slider
    @State private var morphologyRate: Double = 5.0 // 0...100, Slider
    @State private var pathology: Double = 10.0 // 0...100, Slider
    @State private var headDefect: Double = 3.0 // 0...100, Slider
    @State private var neckDefect: Double = 2.0 // 0...100, Slider
    @State private var tailDefect: Double = 1.0 // 0...100, Slider
    @State private var estimateDNA: Bool = true
    // Toggle states for each field
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
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var testStore: TestStore

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    if currentPage == 1 {
                        // Page 1: Analysis
                        Section(header: Text("Analysis").font(.headline).fontDesign(.rounded)) {
                            // Appearance
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Appearance", selection: $appearance) {
                                    ForEach(Appearance.allCases, id: \.self) {
                                        Text($0.rawValue.capitalized).tag($0)
                                    }
                                }
                                .disabled(!hasAppearance)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasAppearance)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Liquefaction
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Liquefaction", selection: $liquefaction) {
                                    ForEach(Liquefaction.allCases, id: \.self) {
                                        Text($0.rawValue.capitalized).tag($0)
                                    }
                                }
                                .disabled(!hasLiquefaction)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasLiquefaction)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Consistency
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Consistency", selection: $consistency) {
                                    ForEach(Consistency.allCases, id: \.self) {
                                        Text($0.rawValue.capitalized).tag($0)
                                    }
                                }
                                .disabled(!hasConsistency)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasConsistency)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Semen Quantity
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Semen Quantity (mL)", selection: $semenQuantity) {
                                    ForEach(Array(stride(from: 0.0, through: 10.0, by: 0.1)), id: \.self) {
                                        Text(String(format: "%.1f", $0)).tag($0)
                                    }
                                }
                                .disabled(!hasSemenQuantity)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasSemenQuantity)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // pH
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("pH", selection: $pH) {
                                    ForEach(Array(stride(from: 0.0, through: 14.0, by: 0.1)), id: \.self) {
                                        Text(String(format: "%.1f", $0)).tag($0)
                                    }
                                }
                                .disabled(!hasPH)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasPH)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)
                        }
                        Section {
                            Text("Fathr is not a medical device. Visualizations are for informational purposes only. Consult a doctor for fertility concerns.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    } else if currentPage == 2 {
                        // Page 2: Motility
                        Section(header: Text("Motility").font(.headline).fontDesign(.rounded)) {
                            // Total Mobility
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading) {
                                    Text("Total Mobility: \(Int(totalMobility))%")
                                    Slider(value: $totalMobility, in: 0...100, step: 1)
                                }
                                .disabled(!hasTotalMobility)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasTotalMobility)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Progressive Mobility
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading) {
                                    Text("Progressive Mobility: \(Int(progressiveMobility))%")
                                    Slider(value: $progressiveMobility, in: 0...100, step: 1)
                                }
                                .disabled(!hasProgressiveMobility)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasProgressiveMobility)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Non-Progressive Mobility
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading) {
                                    Text("Non-Progressive Mobility: \(Int(nonProgressiveMobility))%")
                                    Slider(value: $nonProgressiveMobility, in: 0...100, step: 1)
                                }
                                .disabled(!hasNonProgressiveMobility)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasNonProgressiveMobility)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Travel Speed
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Travel Speed (mm/sec)", selection: $travelSpeed) {
                                    ForEach(Array(stride(from: 0.0, through: 1.0, by: 0.01)), id: \.self) {
                                        Text(String(format: "%.2f", $0)).tag($0)
                                    }
                                }
                                .disabled(!hasTravelSpeed)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasTravelSpeed)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Mobility Index
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading) {
                                    Text("Mobility Index: \(Int(mobilityIndex))%")
                                    Slider(value: $mobilityIndex, in: 0...100, step: 1)
                                }
                                .disabled(!hasMobilityIndex)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasMobilityIndex)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Still
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading) {
                                    Text("Still: \(Int(still))%")
                                    Slider(value: $still, in: 0...100, step: 1)
                                }
                                .disabled(!hasStill)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasStill)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Agglutination
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Agglutination", selection: $agglutination) {
                                    ForEach(Agglutination.allCases, id: \.self) {
                                        Text($0.rawValue.capitalized).tag($0)
                                    }
                                }
                                .disabled(!hasAgglutination)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasAgglutination)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)
                        }
                        Section {
                            Text("Fathr is not a medical device. Visualizations are for informational purposes only. Consult a doctor for fertility concerns.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    } else if currentPage == 3 {
                        // Page 3: Concentration
                        Section(header: Text("Concentration").font(.headline).fontDesign(.rounded)) {
                            // Sperm Concentration
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Sperm Concentration (M/mL)", selection: $spermConcentration) {
                                    ForEach(0...100, id: \.self) {
                                        Text("\($0)").tag($0)
                                    }
                                }
                                .disabled(!hasSpermConcentration)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasSpermConcentration)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Total Spermatozoa
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Total Spermatozoa (M/mL)", selection: $totalSpermatozoa) {
                                    ForEach(0...200, id: \.self) {
                                        Text("\($0)").tag($0)
                                    }
                                }
                                .disabled(!hasTotalSpermatozoa)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasTotalSpermatozoa)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Functional Spermatozoa
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Functional Spermatozoa (M/mL)", selection: $functionalSpermatozoa) {
                                    ForEach(0...100, id: \.self) {
                                        Text("\($0)").tag($0)
                                    }
                                }
                                .disabled(!hasFunctionalSpermatozoa)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasFunctionalSpermatozoa)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Round Cells
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Round Cells (M/mL)", selection: $roundCells) {
                                    ForEach(Array(stride(from: 0.0, through: 10.0, by: 0.1)), id: \.self) {
                                        Text(String(format: "%.1f", $0)).tag($0)
                                    }
                                }
                                .disabled(!hasRoundCells)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasRoundCells)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Leukocytes
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Leukocytes (M/mL)", selection: $leukocytes) {
                                    ForEach(Array(stride(from: 0.0, through: 5.0, by: 0.1)), id: \.self) {
                                        Text(String(format: "%.1f", $0)).tag($0)
                                    }
                                }
                                .disabled(!hasLeukocytes)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasLeukocytes)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Live Spermatozoa
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading) {
                                    Text("Live Spermatozoa: \(Int(liveSpermatozoa))%")
                                    Slider(value: $liveSpermatozoa, in: 0...100, step: 1)
                                }
                                .disabled(!hasLiveSpermatozoa)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasLiveSpermatozoa)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)
                        }
                        Section {
                            Text("Fathr is not a medical device. Visualizations are for informational purposes only. Consult a doctor for fertility concerns.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    } else if currentPage == 4 {
                        // Page 4: Morphology
                        Section(header: Text("Morphology").font(.headline).fontDesign(.rounded)) {
                            // Morphology Rate
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading) {
                                    Text("Morphology Rate: \(Int(morphologyRate))%")
                                    Slider(value: $morphologyRate, in: 0...100, step: 1)
                                }
                                .disabled(!hasMorphologyRate)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasMorphologyRate)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Pathology
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading) {
                                    Text("Pathology: \(Int(pathology))%")
                                    Slider(value: $pathology, in: 0...100, step: 1)
                                }
                                .disabled(!hasPathology)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasPathology)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Head Defect
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading) {
                                    Text("Head Defect: \(Int(headDefect))%")
                                    Slider(value: $headDefect, in: 0...100, step: 1)
                                }
                                .disabled(!hasHeadDefect)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasHeadDefect)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Neck Defect
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading) {
                                    Text("Neck Defect: \(Int(neckDefect))%")
                                    Slider(value: $neckDefect, in: 0...100, step: 1)
                                }
                                .disabled(!hasNeckDefect)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasNeckDefect)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Tail Defect
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading) {
                                    Text("Tail Defect: \(Int(tailDefect))%")
                                    Slider(value: $tailDefect, in: 0...100, step: 1)
                                }
                                .disabled(!hasTailDefect)
                                Toggle("I haven’t had this test / Not sure", isOn: $hasTailDefect)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .toggleStyle(MinimalToggleStyle())
                            }
                            .padding(.vertical, 8)

                            // Estimate DNA Fragmentation Risk
                            Toggle("Estimate DNA Fragmentation Risk", isOn: $estimateDNA)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .toggleStyle(MinimalToggleStyle())
                        }
                        Section {
                            Text("Fathr is not a medical device. Visualizations are for informational purposes only. Consult a doctor for fertility concerns.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                }

                // Navigation Buttons
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
                            submitTest()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .accessibilityLabel("Submit test results")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Add Test Results - Page \(currentPage)/4")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                    .accessibilityLabel("Cancel test input")
                }
            }
        }
    }

    private func submitTest() {
        var newTest = TestData(
            id: nil, // Firestore generates ID
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
        print("TestStore instance: \(testStore)")
        testStore.addTest(newTest)
        print("Dismissed TestInputView")
        dismiss()
    }
}

// Custom toggle style for minimalistic design
struct MinimalToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(configuration.isOn ? .gray : .gray.opacity(0.5))
            configuration.label
        }
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}

struct TestInputView_Previews: PreviewProvider {
    static var previews: some View {
        TestInputView()
            .environmentObject(TestStore())
    }
}
