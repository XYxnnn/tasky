//
//  ScheduleScreen.swift
//  Tasky
//
//  Created by 许昱萱 on 2024/11/26.
//

import SwiftUI

struct ScheduleScreen: View {
    @ObservedObject var taskManager = TaskManager()
    @State private var selectedDate = Date()
    
    @State private var isPresentingCalendarScreen = false
    
    @State private var isPresentingTaskCreate = false
    
    @State private var selectedTab: String = "Month"
    @State private var currentMonth: Date = Date()
    
    let userID: String
    
    init(userID: String) {
        self.userID = userID
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                // Top Section: Date Navigation and Title
                VStack {
                    // Date Selector
                    HStack(spacing: 10) {
                        ForEach(0..<7) { offset in
                            let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
                            VStack {
                                Text(dayOfWeek(from: date))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(dayOfMonth(from: date))
                                    .font(.headline)
                                    .foregroundColor(isSameDay(date1: date, date2: selectedDate) ? .white : .primary)
                                    .frame(width: 40, height: 40)
                                    .background(isSameDay(date1: date, date2: selectedDate) ? Color.blue : Color.clear)
                                    .cornerRadius(20)
                            }
                            .onTapGesture {
                                selectedDate = date
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Schedule List
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredTasks, id: \.id) { task in
                            NavigationLink(
                                destination: TaskDetailScreen(userID: userID, task: task, taskManager: taskManager).navigationBarBackButtonHidden(true)
                            ){
                                ScheduleTaskCard(task: task)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarTitle("Schedule", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Schedule")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .navigationBarItems(trailing: Button(action: {
                // Navigate to Calendar Screen
                isPresentingCalendarScreen.toggle()
            }) {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .fullScreenCover(isPresented: $isPresentingCalendarScreen) {
                        CalendarScreen(userID: userID)
                    }
            })
            .onAppear {
                taskManager.fetchTasks(for: userID)
            }
        }
        .padding(.horizontal, 10)
    }
    
    var filteredTasks: [TaskModel] {
        taskManager.tasks
            .filter { isSameDay(date1: $0.dueDate, date2: selectedDate) }
            .sorted { $0.dueDate < $1.dueDate }
    }

    func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    func dayOfMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }

    func isSameDay(date1: Date, date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}


// DateView Component
struct DateView: View {
    let date: DateInfo
    var isSelected: Bool
    
    var body: some View {
        VStack {
            Text(date.weekday)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(date.day)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .black)
                .frame(width: 35, height: 35)
                .background(isSelected ? Color.blue : Color.clear)
                .clipShape(Circle())
        }
    }
}

// TaskRow Component
struct ScheduleTaskCard: View {
    var task: TaskModel
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(task.title)
                .font(.headline)
                .foregroundColor(.primary)
            HStack {
                Text("\(formatTime(task.startDate)) - \(formatTime(task.dueDate))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(task.priority)
                    .font(.caption)
                    .padding(8)
                    .background(
                        task.priority == "High Priority" ? Color.red.opacity(0.2) :
                        task.priority == "Medium Priority" ? Color.orange.opacity(0.2) :
                        Color.green.opacity(0.2) // Low Priority
                    )
                    .foregroundColor(
                        task.priority == "High Priority" ? .red :
                        task.priority == "Medium Priority" ? .orange :
                        .green // Low Priority
                    )
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}

// Models for Date and Task
struct DateInfo: Hashable {
    let weekday: String
    let day: String
}

// Preview
struct ScheduleScreen_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleScreen(userID: "")
    }
}

