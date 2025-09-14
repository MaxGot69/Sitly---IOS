//
//  PhotoUploadView.swift
//  Sitly
//
//  Created by AI Assistant on 14.09.2025.
//

import SwiftUI
import PhotosUI

struct PhotoUploadView: View {
    @StateObject private var viewModel = PhotoUploadViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let restaurantId: String
    let photoType: RestaurantPhotoType
    let onPhotoUploaded: (String) -> Void
    
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var isUploading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Градиентный фон
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.1),
                        Color(red: 0.1, green: 0.1, blue: 0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Заголовок
                    VStack(spacing: 8) {
                        Text("Загрузить фото")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(photoType.displayName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Превью изображения
                    if let selectedImage = selectedImage {
                        VStack(spacing: 16) {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                            
                            Button("Изменить фото") {
                                showingImagePicker = true
                            }
                            .foregroundColor(.blue)
                        }
                    } else {
                        // Плейсхолдер для выбора фото
                        VStack(spacing: 16) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("Выберите фото")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("Нажмите кнопку ниже для выбора изображения")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 200, height: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                .foregroundColor(.gray)
                        )
                    }
                    
                    Spacer()
                    
                    // Кнопки действий
                    VStack(spacing: 12) {
                        if selectedImage != nil {
                            Button(action: uploadPhoto) {
                                HStack {
                                    if isUploading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "icloud.and.arrow.up")
                                    }
                                    
                                    Text(isUploading ? "Загружаем..." : "Загрузить фото")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(isUploading)
                        }
                        
                        Button(action: { showingImagePicker = true }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("Выбрать из галереи")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button(action: { showingCamera = true }) {
                            HStack {
                                Image(systemName: "camera")
                                Text("Сделать фото")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(selectedImage: $selectedImage)
        }
        .alert("Ошибка", isPresented: $viewModel.showingError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "Неизвестная ошибка")
        }
    }
    
    private func uploadPhoto() {
        guard let image = selectedImage else { return }
        
        isUploading = true
        
        Task {
            do {
                let photoURL = try await viewModel.uploadRestaurantPhoto(
                    image,
                    restaurantId: restaurantId,
                    photoType: photoType
                )
                
                await MainActor.run {
                    isUploading = false
                    onPhotoUploaded(photoURL)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    viewModel.showingError = true
                    viewModel.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Photo Upload ViewModel
@MainActor
class PhotoUploadViewModel: ObservableObject {
    @Published var showingError = false
    @Published var errorMessage: String?
    
    private let storageService: ImageStorageServiceProtocol
    
    init(storageService: ImageStorageServiceProtocol = ImageStorageService()) {
        self.storageService = storageService
    }
    
    func uploadRestaurantPhoto(_ image: UIImage, restaurantId: String, photoType: RestaurantPhotoType) async throws -> String {
        return try await storageService.uploadRestaurantPhoto(image, restaurantId: restaurantId, photoType: photoType)
    }
}

#Preview {
    PhotoUploadView(
        restaurantId: "test-restaurant",
        photoType: .main,
        onPhotoUploaded: { _ in }
    )
}
