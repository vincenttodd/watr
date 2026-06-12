import SwiftUI

extension Color {
    static let watrScreenBackground = Color.white
    static let watrPrimary = Color(red: 0.18, green: 0.35, blue: 0.24)
    static let watrPrimaryDisabled = Color.gray.opacity(0.4)
    static let watrSurface = Color.white
    static let watrSecondaryButtonBackground = Color.watrPrimary.opacity(0.08)
    static let watrPrimarySoft = Color.watrPrimary.opacity(0.1)
    static let watrNeutralButtonBackground = Color(red: 0.922, green: 0.929, blue: 0.941)
}

extension Font {
    static func unica(_ size: CGFloat) -> Font {
        Font.custom("NeueHaasUnicaRegular", size: size)
    }
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

    @ViewBuilder
    func watrIconBadge() -> some View {
        let base = self
            .font(.unica(15))
            .foregroundStyle(Color.watrPrimary)
            .frame(width: 32, height: 32)
        if #available(iOS 26.0, *) {
            base.glassEffect(in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            base
                .background(Color.watrPrimarySoft)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    @ViewBuilder
    func watrPrimaryButton(enabled: Bool = true) -> some View {
        let shape = RoundedRectangle(cornerRadius: 40, style: .continuous)
        let base = self
            .font(.unica(17))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
        if #available(iOS 26.0, *) {
            base
                .foregroundStyle(enabled ? Color.primary : Color.secondary)
                .glassEffect(
                    enabled
                        ? .regular.interactive().tint(.black.opacity(0.08))
                        : .regular.tint(.gray.opacity(0.25)),
                    in: shape
                )
        } else {
            base
                .foregroundStyle(.white)
                .background(enabled ? Color(red: 0.082, green: 0.082, blue: 0.082) : Color.gray.opacity(0.4))
                .clipShape(shape)
        }
    }

    @ViewBuilder
    func watrGlassButton() -> some View {
        self.watrPrimaryButton()
    }

    @ViewBuilder
    func watrSelectionButton(selected: Bool = false) -> some View {
        let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
        let base = self
            .font(.unica(17))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 69)
        if #available(iOS 26.0, *) {
            base.glassEffect(
                selected ? .regular.interactive().tint(.blue.opacity(0.15)) : .regular.interactive(),
                in: shape
            )
        } else {
            base
                .background(selected ? Color.watrSecondaryButtonBackground : Color.watrNeutralButtonBackground)
                .clipShape(shape)
        }
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
        self.font(.unica(34))
    }

    func watrScreenSubtitle() -> some View {
        self
            .font(.unica(16))
            .foregroundStyle(.secondary)
    }

    func watrSectionLabel() -> some View {
        self
            .font(.unica(11))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(1)
    }
}
