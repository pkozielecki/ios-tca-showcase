//
//  ChartView.swift
//  TCA Showcase
//

import Charts
import SwiftUI

struct ChartView: View {
    let data: [ChartPoint]
    let xAxisName: String
    let yAxisName: String

    var body: some View {
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

extension ChartView {

    /// A helper structure describing a point on a chart.
    struct ChartPoint: Identifiable, Equatable {

        /// A point label on X axis.
        let label: String

        /// A point value.
        let value: Double

        /// - SeeAlso: Identifiable.id
        var id: String { "\(label)|\(value)" }
    }

    /// A helper enumeration describing a chart time scopes.
    enum Scope: String, CaseIterable, Equatable {
        case week, month, quarter, year
    }
}
