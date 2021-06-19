//
//  MediaManager.swift
//  SSMediaLibrary
//
//  Created by Devansh Vyas on 16/06/21.
//

import UIKit
import Combine
import QuickLook

class MediaManager {
    var mediaUrl: URL? {
        didSet {
            isLocalFile = mediaUrl?.isFileURL ?? false
        }
    }
    var imageFile: UIImage?
    var isLocalFile: Bool = false
    private var mediaExtension: String?
    var sinkOperation: AnyCancellable?
    var localUrl: URL?
    
    init(file: Any) {
        switch file {
        case is URL:
            guard let url = file as? URL else { return }
            mediaUrl = url
            mediaExtension = url.pathExtension
        case is UIImage:
            guard let image = file as? UIImage else { return }
            imageFile = image
        default:
            break
        }
    }
    
    
    func show() {
        guard let mediaUrl = mediaUrl else {
            return
        }
        downloadFile(url: mediaUrl)
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
                    let previewController = QLPreviewController()
                    previewController.dataSource = self
                    if var topController = UIApplication.shared.windows.first?.rootViewController  {
                        while let presentedViewController = topController.presentedViewController {
                            topController = presentedViewController
                        }
                        topController.present(previewController, animated: true, completion: nil)
                    }
                }
            }
    }
}

extension MediaManager: QLPreviewControllerDataSource {
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let url = localUrl else {
            fatalError()
        }
        return url as QLPreviewItem
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
}
