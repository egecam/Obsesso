//
//  CameraModel.swift
//  Obsesso
//
//  Created by Ege Çam on 16.09.2024.
//

import Foundation
import SwiftUI
import AVFoundation

class CameraModel: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var videoURL: URL?
    @Published var errorMessage: String?
    
    var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                }
            }
        case .denied, .restricted:
            self.errorMessage = "Camera access is denied. Please enable it in Settings."
        @unknown default:
            break
        }
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession?.canAddInput(videoInput) == true else {
            errorMessage = "Failed to set up video capture device."
            return
        }
        
        captureSession?.addInput(videoInput)
        
        videoOutput = AVCaptureMovieFileOutput()
        if captureSession?.canAddOutput(videoOutput!) == true {
            captureSession?.addOutput(videoOutput!)
        } else {
            errorMessage = "Failed to add video output."
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }
    
    func captureVideo() {
        guard let videoOutput = videoOutput else {
            errorMessage = "Video output is not set up."
            return
        }
        
        if isRecording {
            videoOutput.stopRecording()
        } else {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            let dateString = dateFormatter.string(from: Date())
            let fileUrl = documentsPath.appendingPathComponent("video_\(dateString).mov")
            
            do {
                if FileManager.default.fileExists(atPath: fileUrl.path) {
                    try FileManager.default.removeItem(at: fileUrl)
                }
            } catch {
                errorMessage = "Failed to remove existing file: \(error.localizedDescription)"
                return
            }
            
            videoOutput.startRecording(to: fileUrl, recordingDelegate: self)
        }
        
        isRecording.toggle()
    }
}

extension CameraModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Started recording to \(fileURL)")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            errorMessage = "Error recording video: \(error.localizedDescription)"
            print(errorMessage ?? "")
        } else {
            print("Video saved successfully at \(outputFileURL)")
            DispatchQueue.main.async {
                self.videoURL = outputFileURL
            }
        }
    }
}
