import SwiftUI

struct TimeHeaderView: View {
    let selectedRange: StatRange
    @Binding var selectedDate: Date
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var showRangePicker: Bool
    
    @State private var editingStartDate: Bool = true
    
    var body: some View {
        HStack {
            Button { shiftDate(by: -1) } label: { Image(systemName: "chevron.left") }
                .disabled(!canShiftDate)
                .opacity(canShiftDate ? 1 : 0)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(displayedDate)
                    .font(.headline)
                
                if selectedRange == .range {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                if selectedRange == .range {
                    showRangePicker = true
                }
            }
            
            Spacer()
            
            Button { shiftDate(by: 1) } label: { Image(systemName: "chevron.right") }
                .disabled(!canShiftDate)
                .opacity(canShiftDate ? 1 : 0)
        }
        .sheet(isPresented: $showRangePicker) {
            VStack(spacing: 16) {
                
                Picker("", selection: $editingStartDate) {
                    Text("开始日期").tag(true)
                    Text("结束日期").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                DatePicker(
                    "",
                    selection: editingStartDate ? $startDate : $endDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .onChange(of: startDate) { newValue in
                    if newValue > endDate {
                        endDate = newValue
                    }
                }
                .onChange(of: endDate) { newValue in
                    if newValue < startDate {
                        startDate = newValue
                    }
                }
                
                Button {
                    startDate = startDate.startOfDay()
                    endDate = endDate.endOfDay()
                    showRangePicker = false
                } label: {
                    Text("完成")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.accentColor))
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
            .padding()
            .presentationDetents([.height(360)])
        }
    }
    
    private var displayedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        switch selectedRange {
        case .week:
            return weekString(for: selectedDate)
        case .month:
            return monthString(for: selectedDate)
        case .year:
            return yearString(for: selectedDate)
        case .all:
            return "全部时间"
        case .range:
            return "\(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))"
        }
    }
    
    private var canShiftDate: Bool {
        selectedRange == .week || selectedRange == .month || selectedRange == .year
    }
    
    private func shiftDate(by value: Int) {
        let calendar = Calendar.current
        switch selectedRange {
        case .week:
            selectedDate = calendar.date(byAdding: .weekOfYear, value: value, to: selectedDate) ?? selectedDate
        case .month:
            selectedDate = calendar.date(byAdding: .month, value: value, to: selectedDate) ?? selectedDate
        case .year:
            selectedDate = calendar.date(byAdding: .year, value: value, to: selectedDate) ?? selectedDate
        default: break
        }
    }
    
    // MARK: - 时间格式
    private func weekString(for date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? date
        return "\(formatter.string(from: startOfWeek)) ～ \(formatter.string(from: endOfWeek))"
    }
    
    private func monthString(for date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)?.addingTimeInterval(-1) ?? date
        return "\(formatter.string(from: startOfMonth)) ～ \(formatter.string(from: endOfMonth))"
    }
    
    private func yearString(for date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startOfYear = calendar.dateInterval(of: .year, for: date)?.start ?? date
        let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)?.addingTimeInterval(-1) ?? date
        return "\(formatter.string(from: startOfYear)) ～ \(formatter.string(from: endOfYear))"
    }
}
