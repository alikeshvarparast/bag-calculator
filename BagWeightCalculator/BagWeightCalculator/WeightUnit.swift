import Foundation

enum WeightUnit: String, CaseIterable, Identifiable {
    case kilogram
    case pound

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .kilogram: return "kg"
        case .pound: return "lb"
        }
    }
}

enum WeightCalculator {
    private static let kgPerPound = 0.45359237

    static func toKilograms(value: Double, unit: WeightUnit) -> Double {
        switch unit {
        case .kilogram: return value
        case .pound: return value * kgPerPound
        }
    }

    static func fromKilograms(_ kg: Double, unit: WeightUnit) -> Double {
        switch unit {
        case .kilogram: return kg
        case .pound: return kg / kgPerPound
        }
    }

    struct Result {
        let fullBags: Int
        let leftoverRounded: Double
        let leftoverUnit: WeightUnit
        let finalTotal: Double
        let finalUnit: WeightUnit
    }

    /// Full bags that fit under the target, leftover rounded in the **target** unit, final total = bags + rounded leftover (both expressed toward the target unit for display).
    static func calculate(
        bagWeight: Double,
        bagUnit: WeightUnit,
        neededWeight: Double,
        neededUnit: WeightUnit
    ) -> Result? {
        guard bagWeight > 0, neededWeight >= 0 else { return nil }

        let bagKg = toKilograms(value: bagWeight, unit: bagUnit)
        let targetKg = toKilograms(value: neededWeight, unit: neededUnit)

        let bagsExact = targetKg / bagKg
        let fullBags = Int((bagsExact + 1e-9).rounded(.down))
        let weightFromBagsKg = Double(fullBags) * bagKg
        let leftoverKg = max(0, targetKg - weightFromBagsKg)

        let leftoverInNeededUnit = fromKilograms(leftoverKg, unit: neededUnit)
        let leftoverRounded = leftoverInNeededUnit.rounded()

        let roundedLeftoverKg = toKilograms(value: leftoverRounded, unit: neededUnit)
        let finalKg = weightFromBagsKg + roundedLeftoverKg
        let finalInNeededUnit = fromKilograms(finalKg, unit: neededUnit)

        return Result(
            fullBags: fullBags,
            leftoverRounded: leftoverRounded,
            leftoverUnit: neededUnit,
            finalTotal: finalInNeededUnit,
            finalUnit: neededUnit
        )
    }
}
