//
//  WeeklyChartDetailView.swift
//  HongKongHealthApp
//
//  Created by Ye on 16/1/2026.
//


import SwiftUI
import Charts

struct WeeklyChartDetailView: View {
    let weeklySteps: [Int]

    var body: some View {
        VStack(spacing: 20) {
            Text("本週步數詳情").font(.title2.bold())
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(0..<7, id: \.self) { day in
                        BarMark(
                            x: .value("Day", ["星期一","星期二","星期三","星期四","星期五","星期六","星期日"][day]),
                            y: .value("Steps", weeklySteps[day])
                        )
                        .foregroundStyle(.purple)
                    }
                }
                .frame(height: 250)
                .chartYScale(domain: 0 ... 10000)
            } else {
                Text("圖表需 iOS 16+").foregroundColor(.secondary)
            }
            List(0..<7, id: \.self) { day in
                HStack {
                    Text(["星期一","星期二","星期三","星期四","星期五","星期六","星期日"][day])
                    Spacer()
                    Text("\(weeklySteps[day]) 步")
                }
            }
        }
        .padding()
    }
}