//
//  CategoryCompositionView.swift
//  MoneyMemo
//
//  Created by HUAWEI MateBook X on 2025/12/30.
//

import SwiftUI
import Charts

struct CategoryCompositionView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    @Binding var selectedCategoryType: CategoryType
    let currentCategoryData: [ExpenseCategory]
    let sortedCurrentCategories: [ExpenseCategory]
    @State private var showChart = true
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            pieSection
            rankingSection
                .padding(.horizontal)
        }
        .padding(.vertical)
        .animation(.easeInOut(duration: 0.25), value: selectedCategoryType)
        .onChange(of: selectedCategoryType) { _ in
            withAnimation(.easeOut(duration: 0.15)) {
                showChart = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeIn(duration: 0.25)) {
                    showChart = true
                }
            }
        }
        
    }
}

private extension CategoryCompositionView {
    
    var header: some View {
        HStack {
            Text(selectedCategoryType == .expense ? "支出构成" : "收入构成")
                .font(.title2)
                .bold()
            
            Spacer()
            
            Picker("", selection: $selectedCategoryType) {
                ForEach(CategoryType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 140)
        }
        .padding(.horizontal, 16)
    }
    
    var pieSection: some View {
        HStack {
            Spacer()
            
            
            HStack(spacing: 30) {
                Chart(currentCategoryData) { item in
                    SectorMark(
                        angle: .value("金额", item.amount),
                        innerRadius: .ratio(0.6)
                    )
                    .foregroundStyle(
                       item.color.gradient
                    )
                }
                .frame(width: 180, height: 180)
                .chartLegend(.hidden)
                .transition(
                    .opacity.combined(with: .scale(scale: 0.95))
                )
                
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(currentCategoryData) { item in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(item.color)
                                .frame(width: 10, height: 10)
                            Text(item.name)
                                .font(.subheadline)
                        }
                    }
                }
                
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    var rankingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedCategoryType == .expense ? "支出排行" : "收入排行")
                .font(.headline)
                .bold()
            
            ForEach(Array(sortedCurrentCategories.enumerated()), id: \.element.id) { index, item in
                HStack {
                    Text("\(index + 1)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    
                    Text(item.name)
                        .font(.footnote)
                    
                    Spacer()
                    
                    Text(appSettings.formatCurrency(Decimal(item.amount)))
                        .font(.footnote)
                }
                
                if index != sortedCurrentCategories.count - 1 {
                    Divider()
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .transaction { transaction in
            transaction.animation = nil
        }
    }
    
    
}
