//
//  StreakFooterView.swift
//  watr
//

import SwiftUI

struct StreakFooterView: View {
    let streak: Int
    let message: StreakMessage

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                Text("\(streak)")
                    .font(.system(size: 96, weight: .medium))
                    .foregroundStyle(Color.black)
                    .minimumScaleFactor(0.7)

                Text("Day Streak")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(Color.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 32)

            let cardShape = RoundedRectangle(cornerRadius: 24, style: .continuous)
            let cardContent = VStack(alignment: .leading, spacing: 10) {
                Text(message.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(red: 0.18, green: 0.22, blue: 0.28))

                Text(message.body)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color(red: 0.50, green: 0.54, blue: 0.60))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 24)

            if #available(iOS 26.0, *) {
                cardContent
                    .glassEffect(.regular, in: cardShape)
            } else {
                cardContent
                    .background(Color(red: 0.940, green: 0.945, blue: 0.955))
                    .clipShape(cardShape)
            }

            Spacer().frame(height: 20)

            Image("WATR")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.top, 44)
                .padding(.horizontal, 12)
        }
        .watrScreenHorizontalPadding()
        .padding(.top, 40)
        .padding(.bottom, 32)
    }
}

#Preview {
    StreakFooterView(
        streak: 1,
        message: StreakMessage(
            title: "Great start",
            body: "You're building a daily hydration habit. Keep showing up."
        )
    )
    .background(Color.watrScreenBackground)
}
