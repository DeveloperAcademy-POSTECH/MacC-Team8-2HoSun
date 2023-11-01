//
//  CustomConfirmModifier.swift
//  TwoHoSun
//
//  Created by 235 on 11/1/23.
//

import SwiftUI
struct CustomConfirmModifier<A>: ViewModifier where A: View {
    @Binding var isPresented: Bool
    @ViewBuilder let actions: () -> A

    func body(content: Content) -> some View {
        ZStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            ZStack(alignment: .bottom) {
                if isPresented {
                    Color.background.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isPresented = false
                        }
                        .transition(.opacity)
                }

                if isPresented {
                    VStack(alignment: .center) {
                        GroupBox {
                            actions()
                                .frame(maxWidth: .infinity,alignment: .center)
                                .frame(height: 84)
                                .background(Color.disableGray)
                                .foregroundStyle(Color.lightBlue)
                        }
                        .groupBoxStyle(TransparentGroupBox())
                        GroupBox {
                            Button("취소", role: .cancel) {
                                isPresented = false
                            }
                            .bold()
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .groupBoxStyle(TransparentGroupBox())
                    }
                    .font(.title3)
                    .padding(10)
                    .transition(.move(edge: .bottom))

                }
            }
            .onTapGesture {
                isPresented = false
            }
        }
        .animation(.easeInOut, value: isPresented)
    }
}
struct TransparentGroupBox: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.disableGray))
    }
}
