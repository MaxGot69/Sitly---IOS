import SwiftUI
import AVFoundation

struct AIAssistantView: View {
    @StateObject private var viewModel = AIAssistantViewModel()
    @State private var messageText = ""
    @State private var isRecording = false
    @State private var showingVoiceRecorder = false
    @State private var selectedSuggestion = ""
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.15, green: 0.15, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Заголовок
                headerSection
                
                // Чат
                chatSection
                
                // Панель ввода
                inputSection
            }
        }
        .onAppear {
            viewModel.loadInitialSuggestions()
        }
        .sheet(isPresented: $showingVoiceRecorder) {
            VoiceRecorderView(isRecording: $isRecording) { transcribedText in
                messageText = transcribedText
                viewModel.sendMessage(transcribedText)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("AI-помощник")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Ваш персональный эксперт по ресторанам")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Статус AI
            HStack(spacing: 8) {
                Circle()
                    .fill(viewModel.isAIReady ? .green : .orange)
                    .frame(width: 8, height: 8)
                
                Text(viewModel.isAIReady ? "Готов" : "Загружается...")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.purple.opacity(0.5), .blue.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Chat Section
    private var chatSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Приветственное сообщение
                    if viewModel.messages.isEmpty {
                        welcomeMessage
                    }
                    
                    // Сообщения чата
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    
                    // Индикатор загрузки
                    if viewModel.isLoading {
                        loadingIndicator
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .onChange(of: viewModel.messages.count) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                }
            }
        }
    }
    
    // MARK: - Welcome Message
    private var welcomeMessage: some View {
        VStack(spacing: 20) {
            // AI-аватар
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text("Привет! Я ваш AI-помощник")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Я помогу вам оптимизировать работу ресторана, дать советы по меню и аналитике")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Быстрые предложения
            VStack(spacing: 12) {
                Text("Попробуйте спросить:")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(viewModel.quickSuggestions, id: \.self) { suggestion in
                        Button(action: {
                            selectedSuggestion = suggestion
                            messageText = suggestion
                            viewModel.sendMessage(suggestion)
                        }) {
                            Text(suggestion)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.purple.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.purple.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Loading Indicator
    private var loadingIndicator: some View {
        HStack(spacing: 12) {
            // AI-аватар
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "brain.head.profile")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            // Анимированные точки
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(.white.opacity(0.7))
                        .frame(width: 6, height: 6)
                        .scaleEffect(viewModel.loadingDots[index] ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: viewModel.loadingDots[index]
                        )
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        VStack(spacing: 16) {
            // Быстрые действия
            if !viewModel.messages.isEmpty {
                quickActionsSection
            }
            
            // Поле ввода
            HStack(spacing: 12) {
                // Кнопка голосового ввода
                Button(action: {
                    showingVoiceRecorder = true
                }) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title2)
                        .foregroundColor(isRecording ? .red : .purple)
                        .scaleEffect(isRecording ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isRecording)
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Поле ввода
                TextField("Введите сообщение...", text: $messageText)
                    .textFieldStyle(ModernTextFieldStyle())
                    .onSubmit {
                        if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            viewModel.sendMessage(messageText)
                            messageText = ""
                        }
                    }
                
                // Кнопка отправки
                Button(action: {
                    if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.sendMessage(messageText)
                        messageText = ""
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .stroke(.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.contextualActions, id: \.self) { action in
                    Button(action: {
                        viewModel.sendMessage(action)
                    }) {
                        Text(action)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.blue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if message.isFromUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
            } else {
                // AI-аватар
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(.purple.opacity(0.3), lineWidth: 1)
                                )
                        )
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Voice Recorder View
struct VoiceRecorderView: View {
    @Binding var isRecording: Bool
    let onTranscription: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordingURL: URL?
    @State private var isTranscribing = false
    
    var body: some View {
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
            
            VStack(spacing: 40) {
                // Заголовок
                Text("Голосовой ввод")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Индикатор записи
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 200, height: 200)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 4
                                )
                        )
                    
                    if isRecording {
                        Circle()
                            .fill(.red.opacity(0.3))
                            .frame(width: 200, height: 200)
                            .scaleEffect(isRecording ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isRecording)
                    }
                    
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(isRecording ? .red : .purple)
                }
                
                // Кнопка записи
                Button(action: {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }) {
                    Text(isRecording ? "Остановить запись" : "Начать запись")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(isRecording ? .red : .purple)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                
                if isTranscribing {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Обрабатываю голос...")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
            }
            .padding(.top, 40)
        }
        .onAppear {
            setupAudioRecorder()
        }
    }
    
    private func setupAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            recordingURL = documentsPath.appendingPathComponent("recording.m4a")
            
        } catch {
            print("Ошибка настройки аудио: \(error)")
        }
    }
    
    private func startRecording() {
        guard let recordingURL = recordingURL else { return }
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ])
            
            audioRecorder?.record()
            isRecording = true
            
        } catch {
            print("Ошибка записи: \(error)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        
        // Имитация транскрипции
        isTranscribing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isTranscribing = false
            
            // Моковая транскрипция
            let mockTranscription = "Как оптимизировать работу ресторана?"
            onTranscription(mockTranscription)
            dismiss()
        }
    }
}



// MARK: - Preview
#Preview {
    AIAssistantView()
        .preferredColorScheme(.dark)
}
