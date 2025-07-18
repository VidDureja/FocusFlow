import SwiftUI

struct AnalyticsView: View {
    @State private var analytics: AnalyticsResponse?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading analytics...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.title)
                            .fontWeight(.bold)
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            loadAnalytics()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                } else if let analytics = analytics {
                    ScrollView {
                        VStack(spacing: 25) {
                            // Summary Cards
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                StatCard(
                                    title: "Total Sessions",
                                    value: "\(analytics.total_sessions)",
                                    icon: "timer",
                                    color: .purple
                                )
                                
                                StatCard(
                                    title: "Total Minutes",
                                    value: "\(analytics.total_minutes)",
                                    icon: "clock",
                                    color: .blue
                                )
                                
                                StatCard(
                                    title: "Completion Rate",
                                    value: String(format: "%.1f%%", analytics.completion_rate),
                                    icon: "checkmark.circle",
                                    color: .green
                                )
                                
                                StatCard(
                                    title: "Completed",
                                    value: "\(analytics.completed_sessions)",
                                    icon: "star",
                                    color: .orange
                                )
                            }
                            
                            // Session Breakdown
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Session Breakdown")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                VStack(spacing: 10) {
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(.purple)
                                        Text("Pomodoro Sessions")
                                        Spacer()
                                        Text("\(analytics.pomodoro_sessions ?? 0)")
                                            .fontWeight(.semibold)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    
                                    HStack {
                                        Image(systemName: "brain")
                                            .foregroundColor(.blue)
                                        Text("Deep Work Sessions")
                                        Spacer()
                                        Text("\(analytics.deep_work_sessions ?? 0)")
                                            .fontWeight(.semibold)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                            }
                            
                            // Daily Data
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Recent Activity")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                ForEach(Array(analytics.daily_data.keys.sorted().reversed().prefix(7)), id: \.self) { date in
                                    if let dailyData = analytics.daily_data[date] {
                                        DailyDataRow(date: date, data: dailyData)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("No data available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadAnalytics()
            }
        }
    }
    
    private func loadAnalytics() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await APIService.shared.getAnalytics()
                await MainActor.run {
                    self.analytics = response
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct DailyDataRow: View {
    let date: String
    let data: DailyData
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: date) {
            formatter.dateFormat = "MMM dd"
            return formatter.string(from: date)
        }
        return date
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(data.sessions) sessions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(data.minutes) min")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Total time")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    AnalyticsView()
} 