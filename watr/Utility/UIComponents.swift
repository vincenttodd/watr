import SwiftUI

extension Color {
    static let watrScreenBackground = Color.white
    static let watrPrimary = Color(red: 0.082, green: 0.082, blue: 0.082) // #151515
    static let watrPrimaryDisabled = Color.gray.opacity(0.4)
    static let watrSurface = Color.white
    static let watrSecondaryButtonBackground = Color(red: 0.008, green: 0.176, blue: 0.263).opacity(0.07) // #022D43 7%
    static let watrPrimarySoft = Color.watrPrimary.opacity(0.1)
    static let watrNeutralButtonBackground = Color(red: 0.925, green: 0.933, blue: 0.941) // #ECEFF1
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
                .foregroundStyle(enabled ? Color.white : Color.secondary)
                .glassEffect(
                    enabled
                        ? .regular.interactive().tint(Color(red: 0.082, green: 0.082, blue: 0.082))
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

    func watrSelectionButton(selected: Bool = false) -> some View {
        let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
        return self
            .font(.unica(17))
            .foregroundStyle(Color.watrPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 69)
            .background(selected ? Color.watrSecondaryButtonBackground : Color.watrNeutralButtonBackground)
            .clipShape(shape)
    }

    func watrLinkButton() -> some View {
        self
            .font(.unica(15))
            .foregroundStyle(Color.watrPrimary)
            .tint(Color.watrPrimary)
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
