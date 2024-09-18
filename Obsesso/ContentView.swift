//
//  ContentView.swift
//  Obsesso
//
//  Created by Ege Çam on 16.09.2024.
//

import SwiftUI
import SwiftData
import AVFoundation
import AVKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State var presentSheet = false
    @State var type: String = ""
    @State var title: String = ""
    @Environment(\.dismiss) var dismiss
    @StateObject private var camera = CameraModel()
    @State private var showAlert = false
    @State private var trigger = false
    
    
    var sortedItems: [Item] {
        return items.sorted { $0.timestamp > $1.timestamp}
    }
    
    func addItemAction() {
        trigger = false
        if type.isEmpty || title.isEmpty || camera.videoURL == nil {
            return
        } else {
            addItem(type: type, title: title, videoURL: camera.videoURL!.absoluteString)
            title = ""
            type = ""
            camera.videoURL = nil
        }
    }
    
    var body: some View {
        NavigationSplitView {
            VStack {
                HStack {
                    Text("Obsesso")
                        .font(.largeTitle.bold())
                        .padding()
                        .padding(.top, 30)
                    
                    Spacer()
                }
                
                Spacer()
                
                if !items.isEmpty {
                    Text("You have double-checked your \(Text(sortedItems.first!.type).foregroundStyle(.indigo) + Text(" ") + Text(sortedItems.first!.timestamp.timeAgoDisplay()).bold()) ago.")
                        .font(.title2)
                        .padding()
                } else {
                    VStack {
                        Spacer()
                        Text("You have not double-checked anything yet.")
                            .font(.title2)
                            .padding()
                        
                        Button  {
                            trigger.toggle()
                            presentSheet = true
                        }
                        label: {
                            Text("Press double-check to start.")
                                .font(.title2)
                                .foregroundStyle(.indigo)
                                .bold()
                        }
                        .padding()
                        .sensoryFeedback(
                            .impact(weight: .medium, intensity: 0.9),
                            trigger: trigger
                        )
                    }
                    .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // MARK: ITEMS LIST
                List {
                    ForEach(sortedItems) { item in
                        NavigationLink {
                            ZStack {
                                VideoPlayer(player: AVPlayer(url: URL(string: item.videoURL)!))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .ignoresSafeArea()
                                
                                HStack {
                                    VStack {
                                        Text("\(item.title)")
                                            .font(.largeTitle.bold())
                                        
                                        Text(item.timestamp.timeAgoDisplay())
                                            .font(.title2)
                                        
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .padding()
                            }
                        } label: {
                            Text(item.title).bold() + Text(", ") +
                            Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened, capitalizationContext: .beginningOfSentence))
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.inset)
                
                
                Button  {
                    trigger.toggle()
                    presentSheet = true
                }
                label: {
                    Text("DOUBLE CHECK")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.indigo)
                        .cornerRadius(12)
                }
                .padding()
                .sensoryFeedback(
                    .impact(weight: .medium, intensity: 0.9),
                    trigger: trigger
                )
                
            }
        } detail: {
            Text("Select an item")
        }
        
        // MARK: SHEET
        .sheet(isPresented: $presentSheet, onDismiss: withAnimation(.bouncy) {addItemAction}, content: {
            VStack {
                Spacer()
                
                TabView {
                    VStack {
                        Spacer()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("What do you check for?")
                                    .font(.title.bold())
                                
                                TextField("car lock/keys/lamps", text: $type)
                                    .font(.title2)
                            }
                            .padding()
                            
                            Spacer()
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Type it.")
                                    .font(.title.bold())
                                
                                TextField("I locked my car...", text: $title)
                                    .font(.title2)
                            }
                            .padding()
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Prove it.")
                                    .font(.title.bold())
                                    .padding()
                            }
                            
                            Spacer()
                        }
                        
                        ZStack {
                            CameraPreview(camera: camera)
                                .frame(width: 400, height: 500)
                            
                            VStack {
                                Spacer()
                                
                                Button(action: {
                                    camera.captureVideo()
                                }) {
                                    ZStack {
                                        Color.gray
                                            .opacity(0.2)
                                            .background(.ultraThinMaterial)
                                            .frame(width: 70, height: 70)
                                        
                                        
                                        Image(systemName: camera.isRecording ? "record.circle.fill" : "record.circle")
                                            .font(.system(size: 60))
                                            .foregroundColor(camera.isRecording ? .red : .black)
                                        
                                    }
                                    .roundedCornerWithBorder(lineWidth: 0, borderColor: .gray.opacity(0.2), radius: 50.0, corners: .allCorners)
                                    .padding(.bottom)
                                }
                                .padding(.bottom)
                            }
                            
                            if camera.videoURL != nil {
                                ZStack {
                                    Color.clear
                                        .background(.thinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 12.0))
                                        .frame(width: 110, height: 25)
                                    
                                    Text("Video recorded!")
                                        .font(.caption.bold())
                                        .foregroundColor(.indigo)
                                        .padding()
                                }
                            }
                            
                            if let errorMessage = camera.errorMessage {
                                ZStack {
                                    Color.clear
                                        .background(.thinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 12.0))
                                        .frame(width: 250, height: Double(errorMessage.count) * 1)
                                    
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                        .padding()
                                }
                                .frame(width: 250)
                            }
                        }
                        
                    }
                    .padding()
                }
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                Button {
                    if title.isEmpty || type.isEmpty {
                        
                    } else {
                        presentSheet = false
                    }
                } label: {
                    Text("Confirm")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .cornerRadius(12)
                        .overlay {
                            title.isEmpty || type.isEmpty || camera.videoURL == nil ? Color.white.opacity(0.4).cornerRadius(12) : nil
                        }
                }
                .sensoryFeedback(
                    .impact(weight: .medium, intensity: 0.9),
                    trigger: trigger
                )
            }
        })
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(camera.errorMessage ?? "An unknown error occurred"), dismissButton: .default(Text("OK")))
        }
        .onChange(of: camera.errorMessage) { _, newValue in
            if newValue != nil {
                showAlert = true
            }
        }
        .tint(.indigo)
    }
    
    // MARK: ADD ITEM FUNCTION
    private func addItem(type: String, title: String, videoURL: String) {
        withAnimation {
            let newItem = Item(type: type, title: title, videoURL: videoURL, timestamp: Date())
            modelContext.insert(newItem)
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving model context: \(error)")
            }
            
            print("New item added: \(newItem)")
        }
    }
    
    // MARK: ADD ITEM FUNCTION
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
                
                do {
                    try modelContext.save()
                } catch {
                    print("Error saving model context: \(error)")
                }
            }
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func roundedCornerWithBorder(lineWidth: CGFloat, borderColor: Color, radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
            .overlay(RoundedCorner(radius: radius, corners: corners)
                .stroke(borderColor, lineWidth: lineWidth))
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "\(diff) sec"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) min"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) hrs"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) days"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff) weeks"
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self)
}
