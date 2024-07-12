//
//  TimeFrameModalView.swift
//  SoloTravel
//
//  Created by Max Roberts on 7/10/24.
//

import SwiftUI

@MainActor
final class TimeFrameModalViewModel: ObservableObject {
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!
}

struct TimeFrameModalView: View {
    @StateObject private var viewModel = TimeFrameModalViewModel()
    @State private var isStartDateSelected = true
    @State private var navigateToMeetups = false
    @Binding var isShowingModal: Bool
    var country: String
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 350, height: 400)
                        .shadow(radius: 10)
                        .foregroundStyle(.black.opacity(0.8))
                    
                    VStack {
                        Text(isStartDateSelected ? "Select Arrival Date" : "Select Departure Date")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.7))
                        
                        CustomCalendarView(
                            selectedDate: isStartDateSelected ? $viewModel.startDate : $viewModel.endDate,
                            startDate: isStartDateSelected ? nil : viewModel.startDate,
                            mode: isStartDateSelected ? .startDate : .endDate
                        )
                        .frame(width: 300, height: 250)
                        
                        Button(action: {
                            if isStartDateSelected {
                                isStartDateSelected.toggle()
                            } else {
                                isShowingModal = false
                                navigateToMeetups = true
                            }
                        }) {
                            Text(isStartDateSelected ? "Next: Departure Date" : "Continue")
                                .frame(minWidth: 200)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                
                        }
                    }
                }
                NavigationLink(destination: CountryView(country: country, start: viewModel.startDate, end: viewModel.endDate), isActive: $navigateToMeetups) {
                    EmptyView()
                }
            }
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

#Preview {
    TimeFrameModalView(isShowingModal: .constant(true), country: "Spain")
}



import SwiftUI

struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    let startDate: Date?
    let mode: CalendarMode

    @State private var displayDate: Date

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter

    init(selectedDate: Binding<Date>, startDate: Date?, mode: CalendarMode) {
        self._selectedDate = selectedDate
        self.startDate = startDate
        self.mode = mode
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "MMMM yyyy"
        self._displayDate = State(initialValue: selectedDate.wrappedValue)
    }

    private var currentMonthDates: [Date] {
        let components = calendar.dateComponents([.year, .month], from: displayDate)
        let firstDayOfMonth = calendar.date(from: components)!
        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!

        return range.compactMap { day in
            return calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)
        }
    }

    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }

    private func previousMonth() {
        displayDate = calendar.date(byAdding: .month, value: -1, to: displayDate)!
    }

    private func nextMonth() {
        displayDate = calendar.date(byAdding: .month, value: 1, to: displayDate)!
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    previousMonth()
                }) {
                    Image(systemName: "chevron.left")
                }
                .padding(.horizontal)

                Text("\(dateFormatter.string(from: displayDate))")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))

                Button(action: {
                    nextMonth()
                }) {
                    Image(systemName: "chevron.right")
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 10)

            ForEach(0..<currentMonthDates.count / 7 + 1, id: \.self) { row in
                HStack {
                    ForEach(0..<7, id: \.self) { column in
                        let index = row * 7 + column
                        if index < currentMonthDates.count {
                            let date = currentMonthDates[index]
                            Text("\(calendar.component(.day, from: date))")
                                .frame(width: 30, height: 30)
                                .background(isSameDay(date, selectedDate) ? Color.blue :
                                                (startDate != nil && isSameDay(date, startDate!)) ? Color.blue : Color.clear)
                                .cornerRadius(15)
                                .foregroundColor(.white)
                                .onTapGesture {
                                    selectedDate = date
                                }
                        } else {
                            Spacer()
                                .frame(width: 30, height: 30)
                        }
                    }
                }
            }
        }
    }
}

enum CalendarMode {
    case startDate
    case endDate
}
