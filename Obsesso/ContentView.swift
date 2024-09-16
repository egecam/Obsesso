//
//  ContentView.swift
//  Obsesso
//
//  Created by Ege Çam on 16.09.2024.
//

import SwiftUI
import SwiftData
import AVFoundation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State var presentSheet = false
    @State var type: String = ""
    @State var title: String = ""
    @Environment(\.dismiss) var dismiss
    @StateObject private var camera = CameraModel()
    @State private var showAlert = false
    
    func addItemAction() {
        if type.isEmpty || title.isEmpty || camera.videoURL == nil {
            return
        } else {
            addItem(type: type, title: title, videoURL: camera.videoURL!.absoluteString)
            title = ""
            type = ""
            camera.videoURL = nil
        }
    }
    
    func calculateTimePhrase(lastTime: Date) -> String {
        let timeSince = Date().timeIntervalSince(lastTime)
        let timePhrase: String
        
        if timeSince < 1 {
            timePhrase = "a few seconds"
        } else if timeSince > 1 && timeSince < 60 {
            timePhrase = "a minute"
        } else {
            if timeSince < 3600 {
                timePhrase = "hour"
            } else {
                timePhrase = "hours"
            }
        }
        
        return timePhrase
    }
    
    var body: some View {
        NavigationSplitView {
            VStack {
                HStack {
                    Text("Compulse")
                        .font(.largeTitle.bold())
                        .padding()
                        .padding(.top, 30)
                    
                    Spacer()
                }
                
                Spacer()
                
                if !items.isEmpty {
                    Text("You have double-checked your \(items.last!.type) \(Text(calculateTimePhrase(lastTime: items.last!.timestamp)).bold()) ago.")
                        .font(.title2)
                        .padding()
                }
                
                Spacer()
                
                List {
                    ForEach(items.reversed()) { item in
                        NavigationLink {
                            Text("\(item.title)")
                        } label: {
                            Text(item.title).bold() + Text(", ") +
                            Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened, capitalizationContext: .beginningOfSentence))
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.inset)
                
                
                Button  {
                    presentSheet = true
                }
            label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 18.0)
                        .foregroundStyle(.yellow.opacity(0.3))
                        .roundedCornerWithBorder(lineWidth: 5, borderColor: .yellow.opacity(0.5), radius: 18.0, corners: .allCorners)
                    
                    Text("DOUBLE CHECK")
                        .font(.title3.bold())
                        .padding()
                        .foregroundStyle(.yellow)
                }
                .frame(width: 200, height: 50)
                
            }
            .padding()
                
            }
        } detail: {
            Text("Select an item")
        }
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
                                
                                TextField("I have locked my car...", text: $title)
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
                                        Image(systemName: camera.isRecording ? "record.circle.fill" : "record.circle")
                                            .font(.system(size: 60))
                                            .foregroundColor(camera.isRecording ? .red : .black)
                                            .padding(.bottom)
                                    }
                                    .padding(.bottom)
                                }
                                
                                if let url = camera.videoURL {
                                    ZStack {
                                        Color.gray.opacity(0.5)
                                            .clipShape(RoundedRectangle(cornerRadius: 12.0))
                                        
                                        Text("Video recorded: \(url.lastPathComponent)")
                                            .font(.caption)
                                            .padding()
                                    }
                                }
                                
                                if let errorMessage = camera.errorMessage {
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                        .padding()
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
                    ZStack {
                        RoundedRectangle(cornerRadius: 18.0)
                            .foregroundStyle(.green.secondary)
                            .roundedCornerWithBorder(lineWidth: 5, borderColor: .green.opacity(0.5), radius: 18.0, corners: .allCorners)
                        
                        Text("Confirm")
                            .font(.title3.bold())
                            .padding()
                            .foregroundStyle(.black)
                    }
                    .frame(width: 225, height: 50)
                    .opacity(title.isEmpty || type.isEmpty || camera.videoURL == nil ? 0.5 : 1.0)
                }

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
    }
    
    private func addItem(type: String, title: String, videoURL: String) {
        withAnimation {
            let newItem = Item(type: type, title: title, videoURL: videoURL, timestamp: Date())
            modelContext.insert(newItem)
            print("New item added: \(newItem)")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
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

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
