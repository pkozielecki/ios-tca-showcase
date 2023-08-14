//
//  ChartView.swift
//  TCA Showcase
//

import Charts
import SwiftUI

public struct ChartView: View {
    public let data: [ChartPoint]
    public let xAxisName: String
    public let yAxisName: String

    public var body: some View {
        Chart(data) {
            LineMark(
                x: .value(xAxisName, $0.label),
                y: .value(yAxisName, $0.value)
            )
            PointMark(
                x: .value(xAxisName, $0.label),
                y: .value(yAxisName, $0.value)
            )
        }
    }
}

public extension ChartView {

    /// A helper structure describing a point on a chart.
    struct ChartPoint: Identifiable, Equatable {

        /// A point label on X axis.
        public let label: String

        /// A point value.
        public let value: Double

        /// - SeeAlso: Identifiable.id
        public var id: String { "\(label)|\(value)" }
    }

    /// A helper enumeration describing a chart time scopes.
    enum Scope: String, CaseIterable, Equatable {
        case week, month, quarter, year
    }
}
