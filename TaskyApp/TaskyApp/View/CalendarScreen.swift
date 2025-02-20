//
//  CalendarScreen.swift
//  Tasky
//
//  Created by 许昱萱 on 2024/11/27.
//

import SwiftUI

struct CalendarScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var taskManager = TaskManager()
    @StateObject private var taskViewModel: TaskViewModel
    @StateObject private var projectManager = ProjectManager()
    @State private var selectedDate = Date()
    
    
    let userID: String
    
    @State private var isPresentingTaskCreate = false
    
    @State private var currentMonth: Date = Date()
    
    init(userID: String) {
        let manager = TaskManager()
        self.userID = userID
        _taskManager = StateObject(wrappedValue: manager)
        _taskViewModel = StateObject(wrappedValue: TaskViewModel(taskManager: manager, userID: userID))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        // Back button action
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text("Calendar")
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .bold))
                    // .padding(.horizontal, 63)
                    Spacer()
                    Button(action: {
                        // Placeholder for additional top-right action
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.clear) // Invisible button for symmetry
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Month Navigation
                HStack {
                    HStack {
                        Button(action: {
                            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        Text(getMonthYear(from: currentMonth))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        Spacer()
                        
                        Button(action: {
                            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                
                // Calendar Grid
                CalendarGrid(selectedDate: $selectedDate, currentMonth: $currentMonth, taskManager: taskManager)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                
                // Upcoming Events Section
                HStack {
                    Text("Upcoming Events")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.horizontal)
                        .padding(.top, 5)
                    Spacer()
                    Button(action: {
                        // Add Task Button
                        isPresentingTaskCreate.toggle()
                    }) {
                        Text("+ Add Task")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .fullScreenCover(isPresented: $isPresentingTaskCreate) {
                        TaskCreateScreen(taskManager: taskManager, projectManager: projectManager, userID: userID)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 5)
                
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredTasks, id: \.id) { task in
                            NavigationLink(
                                destination: TaskDetailScreen(userID: userID, task: task, taskManager: taskManager).navigationBarBackButtonHidden(true)
                            ) {
                                CalendarTaskCard(task: task)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal, 10)
            .background(Color.white)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                taskManager.fetchTasks(for: userID) // 初次加载任务
            }
        }
        
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

    private func getMonthYear(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, yyyy"
        return formatter.string(from: date)
    }
}

// Calendar view
struct CalendarHeaderView: View {
    @Binding var selectedDate: Date

    var body: some View {
        HStack {
            Button(action: {
                changeMonth(by: -1)
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
            }

            Spacer()
            Text(formattedMonthYear(from: selectedDate))
                .font(.title2)
                .bold()
            Spacer()

            Button(action: {
                changeMonth(by: 1)
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal)
    }

    // 切换月份逻辑
    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }

    // 格式化显示月份和年份
    private func formattedMonthYear(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, yyyy"
        return formatter.string(from: date)
    }
}

// Event Card Component
struct CalendarTaskCard: View {
    
    var task: TaskModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
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
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}

// Calendar Grid Component
struct CalendarGrid: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    let taskManager: TaskManager

    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    private var datesInMonth: [Date] {
        var dates = [Date]()
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        // Fill empty slots before the first day of the month
        for _ in 1..<firstWeekday {
            dates.append(Date.distantPast) // Placeholder
        }
        
        // Fill actual days
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                dates.append(date)
            }
        }
        return dates
    }

    var body: some View {
        VStack(spacing: 8) {
            // Weekday Headers
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(datesInMonth, id: \.self) { date in
                    if Calendar.current.isDate(date, equalTo: Date.distantPast, toGranularity: .day) {
                        // Placeholder for empty slots
                        Text("")
                            .frame(width: 40, height: 40)
                    } else {
                        Button(action: {
                            selectedDate = date
                        }) {
                            VStack {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(size: 16))
                                    .foregroundColor(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .white : .black)
                                    .frame(width: 40, height: 40)
                                    .background(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.blue : Color.clear)
                                    .cornerRadius(20)
                                
                                // Show dot if tasks exist on this day
                                if !taskManager.fetchTasks(for: date).isEmpty {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 6, height: 6)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


/*
struct CalendarGrid: View {
    @Binding var selectedDate: Int?
    @Binding var currentMonth: Date

    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        VStack(spacing: 8) {
            // Weekday Headers
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
            }

            // Dates in the Month (Example: Days 1-31)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(1..<32, id: \.self) { day in // Example for days 1-31
                    Button(action: {
                        selectedDate = day
                    }) {
                        Text("\(day)")
                            .font(.system(size: 16))
                            .foregroundColor(selectedDate == day ? .white : .black)
                            .frame(width: 40, height: 40)
                            .background(selectedDate == day ? Color.blue : Color.clear)
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
}
 */

// Preview
struct CalendarScreen_Previews: PreviewProvider {
    static var previews: some View {
        CalendarScreen(userID: "")
    }
}
