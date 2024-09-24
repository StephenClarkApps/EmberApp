//
//  ToastView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 23/09/2024.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let icon: String
    let backgroundColor: Color
    let duration: Double = EBConstants.Toast.dismissDurationSeconds // Ensure EBConstants is defined in your project
    
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(message)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.leading, 5)
            }
            .padding()
            .background(backgroundColor.opacity(0.9))
            .cornerRadius(8)
            .shadow(radius: 10)
            .transition(.move(edge: .top).combined(with: .opacity)) // Animate the entry of the toast
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
            .padding(.horizontal, 20)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Toast message: \(message)")
        }
    }
}

// MARK: - PREVIEW PROVIDER
struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        // Example Preview with Toast Visible
        ToastView(
            message: "Network error occurred.\nPlease try again later.",
            icon: "exclamationmark.triangle.fill",
            backgroundColor: .red,
            isShowing: .constant(true) // Using .constant for static preview
        )
        .previewLayout(.sizeThatFits) // Adjusts the preview to fit the content
        .padding()
        
        // Example Preview with Toast Hidden
        ToastView(
            message: "Operation successful!",
            icon: "checkmark.circle.fill",
            backgroundColor: .green,
            isShowing: .constant(false) // Toast is hidden in this preview
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
