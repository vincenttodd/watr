
import SwiftUI

extension Color {
    static let watrScreenBackground = Color(red: 0.957, green: 0.945, blue: 0.925)
    static let watrPrimary = Color(red: 0.18, green: 0.35, blue: 0.24)
    static let watrPrimaryDisabled = Color.gray.opacity(0.4)
    static let watrSurface = Color.white
    static let watrSecondaryButtonBackground = Color.watrPrimary.opacity(0.08)
    static let watrPrimarySoft = Color.watrPrimary.opacity(0.1)
    static let watrNeutralButtonBackground = Color.gray.opacity(0.1)
}

extension View {
    func watrScreenHorizontalPadding() -> some View {
        self.padding(.horizontal, 28)
    }

    func watrCardSurface(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(Color.watrSurface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    func watrIconBadge() -> some View {
        self
            .font(.system(size: 15))
            .foregroundStyle(Color.watrPrimary)
            .frame(width: 32, height: 32)
            .background(Color.watrPrimarySoft)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    func watrPrimaryButton(enabled: Bool = true) -> some View {
        self
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(enabled ? Color.watrPrimary : Color.watrPrimaryDisabled)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    func watrSecondaryButtonBackground(
        selected: Bool = false,
        cornerRadius: CGFloat = 14
    ) -> some View {
        self
            .background(selected ? Color.watrSecondaryButtonBackground : Color.watrSurface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    func watrScreenTitle() -> some View {
        self.font(.system(size: 34, weight: .light))
    }

    func watrScreenSubtitle() -> some View {
        self
            .font(.system(size: 16, weight: .light))
            .foregroundStyle(.secondary)
    }

    func watrSectionLabel() -> some View {
        self
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(1)
    }
}
