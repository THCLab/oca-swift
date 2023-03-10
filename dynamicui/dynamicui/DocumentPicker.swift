//
//  DocumentPicker.swift
//  dynamicui
//
//  Created by Justyna Gręda on 09/03/2023.
//

import Foundation
import SwiftUI
import UIKit

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var file: Data?
    @Binding var fileName: String?
    
    func makeCoordinator() -> DocumentPicker.Coordinator {
        return DocumentPicker.Coordinator(parent1: self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .open)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: DocumentPicker.UIViewControllerType, context: UIViewControllerRepresentableContext<DocumentPicker>) {
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        init(parent1: DocumentPicker) {
            self.parent = parent1
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("[DocumentPicker] didPickDocumentsAt")
            guard controller.documentPickerMode == .open, let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
            DispatchQueue.main.async {
                url.stopAccessingSecurityScopedResource()
                print("[DocumentPicker] stopAccessingSecurityScopedResource done")
            }
            do {
                let document = try Data(contentsOf: url.absoluteURL)
                self.parent.file = document
                self.parent.fileName = url.lastPathComponent
                print("[DocumentPicker] File Selected: " + url.path)
            }
            catch {
                print("[DocumentPicker] Error selecting file: " + error.localizedDescription)
            }
        }
    }
}
