//
//  MediaManager.swift
//  SSMediaLibrary
//
//  Created by Devansh Vyas on 16/06/21.
//

import UIKit
import Combine
import QuickLook
import AVKit

class MediaManager {
    var mediaUrl: URL?
    var mediaExtension: UTI?
    var sinkOperation: AnyCancellable?
    var localUrl: URL?
    var topVC: UIViewController? {
        guard var topController = UIApplication.shared.windows.first?.rootViewController
        else { return nil }
        
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    
    init(file: Any) {
        guard let url = file as? URL else { return }
        mediaUrl = url
        mediaExtension = UTI(withExtension: url.pathExtension)
    }
    
    func show() {
        guard let mediaUrl = mediaUrl else {
            return
        }
        if let filePath = getFileFromLocal() {
            localUrl = filePath
            openFile()
        } else {
            downloadFile(url: mediaUrl)
        }
    }
    
    func getFileFromLocal() -> URL? {
        guard let fileName = mediaUrl?.lastPathComponent,
              var cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        else { return nil }
        cacheDir.appendPathComponent(fileName)
        return FileManager.default.fileExists(atPath: cacheDir.path) ? URL(fileURLWithPath: cacheDir.path) : nil
    }
    
    func downloadFile(url: URL) {
        sinkOperation = URLSession.shared
            .downloadTaskPublisher(for: url)
            .sink(receiveCompletion: { completion in
                print("Sink completion: \(completion)")
            }) { value in
                print("Sink value: \(value.url)")
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    self.localUrl = value.url
                    self.openFile()
                }
            }
    }
    
    func openFile() {
        guard let mediaExtension = mediaExtension else {
            return
        }
        switch mediaExtension {
        case .html:
            break
        case .video, .movie, .quickTimeMovie, .mpeg2Video, .appleProtectedMPEG4Video, .aviMovie, .audiovisualContent, .mpeg4, .wmv:
            openVideoPlayer()
        default:
            openWithQuickLook()
        }
    }
    
    func openVideoPlayer() {
        guard let mediaUrl = mediaUrl else {
            return
        }
        let player = AVPlayer(url: mediaUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        topVC?.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func openWithQuickLook() {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        topVC?.present(previewController, animated: true, completion: nil)
    }
}

extension MediaManager: QLPreviewControllerDataSource {
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        print("===> \(String(describing: localUrl))")
        guard let url = localUrl else {
            fatalError()
        }
        return url as QLPreviewItem
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
}
