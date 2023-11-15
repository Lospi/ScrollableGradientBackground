//
//  ContentView.swift
//  GradientNavigationStack
//
//  Created by Roberto Camargo on 14/11/23.
//

import SwiftUI

public struct ScrollableGradientNavigationStack<Content: View>: View {
    @State private var gradientEndPoint: Double = 0
    var content: () -> Content
    var heightPercentage: Double
    var maxHeight: Double
    var minHeight: Double
    var startColor: Color
    var endColor: Color
    var navigationTitle: String

    private func calculateEndPointForScrollPosition(scrollPosition: Double) -> Double {
        let absoluteScrollPosition = abs(scrollPosition)
        let endPoint = heightPercentage - (heightPercentage / maxHeight) * absoluteScrollPosition

        return endPoint.clamped(to: 0 ... heightPercentage)
    }

    private func checkScrollPositionAndGetEndPoint(scrollPosition: Double) -> Double {
        let isScrollPositionLowerThanMinHeight = scrollPosition < minHeight

        return isScrollPositionLowerThanMinHeight ? calculateEndPointForScrollPosition(scrollPosition: scrollPosition) : heightPercentage
    }

    private func onScrollPositionChange(scrollPosition: Double) {
        gradientEndPoint = checkScrollPositionAndGetEndPoint(
            scrollPosition: scrollPosition
        )
    }

    init(heightPercentage: Double, maxHeight: Double, minHeight: Double, startColor: Color, endColor: Color,
         navigationTitle: String, @ViewBuilder content: @escaping () -> Content)
    {
        self.heightPercentage = heightPercentage
        self.maxHeight = maxHeight
        self.minHeight = minHeight
        self.startColor = startColor
        self.endColor = endColor
        self.navigationTitle = navigationTitle
        self.content = content
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    content()
                }
                .padding()
                .coordinateSpace(name: "scroll")
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(
                                in: .named("scroll")
                            ).origin
                        )
                    })
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) {
                    value in
                    onScrollPositionChange(scrollPosition: value.y)
                }
            }
            .navigationTitle(navigationTitle)
            .background(
                LinearGradient(
                    gradient:
                    Gradient(
                        colors: [Color.red, Color.white]
                    ), startPoint: .top,
                    endPoint: UnitPoint(
                        x: 0.5,
                        y: gradientEndPoint
                    )
                )
                .ignoresSafeArea()
            )
        }
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            UINavigationBar.appearance().standardAppearance = appearance

            let exposedAppearance = UINavigationBarAppearance()
            exposedAppearance.backgroundEffect = .none
            exposedAppearance.shadowColor = .clear
            UINavigationBar.appearance().scrollEdgeAppearance = exposedAppearance
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

extension Comparable {
    func clamped(to r: ClosedRange<Self>) -> Self {
        let min = r.lowerBound, max = r.upperBound
        return self < min ? min : (max < self ? max : self)
    }
}

#Preview {
    ScrollableGradientNavigationStack(heightPercentage: 0.4, maxHeight: 200, minHeight: 0, startColor: Color.red, endColor: Color.white, navigationTitle: "Test", content: { ForEach(0 ..< 120) { value in Text("Test \(value)") } })
}
