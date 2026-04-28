import Darwin
import SwiftUI

struct ContentView: View {
    @State private var bagWeightText = "25"
    @State private var bagUnit: WeightUnit = .pound
    @State private var neededWeightText = "100"
    @State private var neededUnit: WeightUnit = .kilogram

    @State private var result: WeightCalculator.Result?
    @State private var errorMessage: String?
    @State private var showExitConfirmation = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case bag, needed
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Spacer()
                        AppLogoMark(size: 96)
                        Spacer()
                    }
                    .padding(.bottom, 4)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Bag calculator")

                    sectionHeader("Each bag")
                    inputRow(
                        value: $bagWeightText,
                        unit: $bagUnit,
                        field: .bag,
                        accessibilityLabel: "Weight of one bag"
                    )

                    sectionHeader("Material you need")
                    inputRow(
                        value: $neededWeightText,
                        unit: $neededUnit,
                        field: .needed,
                        accessibilityLabel: "Total material weight needed"
                    )

                    Button(action: calculate) {
                        Text("Calculate")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }

                    if let result {
                        resultCard(result)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Bag calculator")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        focusedField = nil
                        showExitConfirmation = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title3)
                    }
                    .accessibilityLabel("Close app")
                }
            }
            .confirmationDialog(
                "Close Bag calculator?",
                isPresented: $showExitConfirmation,
                titleVisibility: .visible
            ) {
                Button("Exit", role: .destructive) {
                    // Personal / Ad Hoc builds only. App Store review typically rejects apps that quit themselves.
                    exit(0)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("The app will close. Open it again from the Home Screen when you need it.")
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private func inputRow(
        value: Binding<String>,
        unit: Binding<WeightUnit>,
        field: Field,
        accessibilityLabel: String
    ) -> some View {
        HStack(spacing: 12) {
            TextField("Weight", text: value)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: field)
                .accessibilityLabel(accessibilityLabel)

            Picker("Unit", selection: unit) {
                ForEach(WeightUnit.allCases) { u in
                    Text(u.displayName).tag(u)
                }
            }
            .pickerStyle(.menu)
            .frame(minWidth: 88)
        }
    }

    private func resultCard(_ r: WeightCalculator.Result) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Result")
                .font(.headline)

            LabeledContent("Full bags") {
                Text("\(r.fullBags)")
                    .font(.title2.monospacedDigit())
            }

            LabeledContent("Extra (rounded)") {
                Text("\(formatLeftover(r.leftoverRounded)) \(r.leftoverUnit.displayName)")
                    .font(.title3.monospacedDigit())
            }

            LabeledContent("Total with bags + extra") {
                Text("\(formatFinalTotal(r.finalTotal)) \(r.finalUnit.displayName)")
                    .font(.title3.monospacedDigit())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func formatLeftover(_ x: Double) -> String {
        stripTrailingZeros(String(format: "%.0f", x))
    }

    /// Enough decimals to match typical scale readings (e.g. 99.7185 kg).
    private func formatFinalTotal(_ x: Double) -> String {
        stripTrailingZeros(String(format: "%.4f", x))
    }

    private func stripTrailingZeros(_ s: String) -> String {
        var out = s
        while out.last == "0", out.contains(".") { out.removeLast() }
        if out.last == "." { out.removeLast() }
        return out
    }

    private func calculate() {
        focusedField = nil
        errorMessage = nil
        result = nil

        guard let bag = Double(bagWeightText.replacingOccurrences(of: ",", with: ".")),
              let need = Double(neededWeightText.replacingOccurrences(of: ",", with: "."))
        else {
            errorMessage = "Enter valid numbers for both weights."
            return
        }

        guard let r = WeightCalculator.calculate(
            bagWeight: bag,
            bagUnit: bagUnit,
            neededWeight: need,
            neededUnit: neededUnit
        ) else {
            errorMessage = "Bag weight must be greater than zero."
            return
        }

        result = r
    }
}

#Preview {
    ContentView()
}
