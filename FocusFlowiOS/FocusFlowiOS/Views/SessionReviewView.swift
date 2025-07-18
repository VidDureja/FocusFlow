import SwiftUI

struct SessionReviewView: View {
    @Binding var comment: String
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Session Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Great job! How did this session go?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Review Form
                VStack(alignment: .leading, spacing: 15) {
                    Text("Session Review")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Write a quick reflection or note about this session (optional)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $comment)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        onComplete()
                        dismiss()
                    }) {
                        Text("Save Review")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button("Skip") {
                        onComplete()
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SessionReviewView(comment: .constant("")) {
        // Preview action
    }
} 