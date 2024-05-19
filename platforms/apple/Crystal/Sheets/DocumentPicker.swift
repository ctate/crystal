protocol DocumentPickerRepresentable {
    associatedtype PickerType
    func makePicker() -> PickerType
    func updatePicker(_ picker: PickerType)
}

#if canImport(UIKit)
import SwiftUI
import UIKit

struct DocumentPicker: UIViewControllerRepresentable, DocumentPickerRepresentable {
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        makePicker()
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        updatePicker(uiViewController)
    }

    func makePicker() -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.content], asCopy: true)
        return picker
    }

    func updatePicker(_ picker: UIDocumentPickerViewController) {
        // Update the picker if necessary
    }
}
#endif
