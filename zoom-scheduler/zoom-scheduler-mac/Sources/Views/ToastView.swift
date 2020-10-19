//
//  ToastView.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 16.10.2020.
//

import SwiftUI

struct ToastView: View {
    let feedback: InAppFeedback

    var body: some View {
        Group {
            HStack(spacing: 8) {
                Text(feedback.message)
                    .font(.custom("SFProText-Medium", size: 13))
                    .kerning(-0.08)
                    .lineSpacing(3.5)
                    .foregroundColor(feedback.foregroundColor)
                    .padding(.vertical, 4)

                Button(action: {
                    feedback.action?()
                }) {
                    Text(feedback.actionName)
                        .font(.custom("SFProText-Medium", size: 13))
                        .foregroundColor(feedback.foregroundColor)
                        .kerning(-0.08)
                        .padding(8)
                        .background(feedback.actionColor)
                }
                .buttonStyle(PlainButtonStyle())
                .cornerRadius(6)
            }
            .padding(EdgeInsets(top: 3, leading: 12, bottom: 3, trailing: 3))
        }
        .background(feedback.backgroundColor)
        .cornerRadius(6)
        .shadow(
            color: Color("Views/Attributes/Shadow/primary"),
            radius: 10,
            x: 0,
            y: 8
        )
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ToastView(feedback: .init(reason: .error, message: "Something had happened!", actionName: "Try Again"))
                .frame(width: 300, height: 50)

            ToastView(feedback: .init(reason: .info, message: "Something had happened!"))
                .frame(width: 300, height: 50)
        }
    }
}
