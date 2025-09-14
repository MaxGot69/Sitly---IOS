//
//  APIKeys.swift
//  Sitly
//
//  Created by AI Assistant on 14.09.2025.
//

import Foundation

struct APIKeys {
    // MARK: - OpenAI API Key
    static var openAI: String? {
        print("🔑 APIKeys: НАЧАЛО ПРОВЕРКИ API КЛЮЧА")
        
        // Сначала проверяем переменные окружения
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            print("🔑 APIKeys: Найден ключ в переменных окружения")
            return envKey
        }
        
        // Затем проверяем файл конфигурации
        if let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") {
            print("🔑 APIKeys: Путь к файлу: \(path)")
            if let plist = NSDictionary(contentsOfFile: path) {
                print("🔑 APIKeys: Файл загружен, ключи: \(plist.allKeys)")
                if let apiKey = plist["OpenAI_API_Key"] as? String {
                    print("🔑 APIKeys: Ключ найден в plist файле")
                    return apiKey
                } else {
                    print("❌ APIKeys: Ключ OpenAI_API_Key не найден в plist файле")
                }
            } else {
                print("❌ APIKeys: Не удалось загрузить plist файл")
            }
        } else {
            print("❌ APIKeys: Файл APIKeys.plist не найден в Bundle")
        }
        
        // Или из Info.plist
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenAI_API_Key") as? String {
            print("🔑 APIKeys: Найден ключ в Info.plist")
            return apiKey
        }
        
        print("❌ APIKeys: Ключ не найден нигде")
        return nil
    }
    
    // MARK: - Firebase Configuration
    static var firebaseConfigured: Bool {
        return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }
}

// MARK: - Configuration Instructions
/*
 
 ДЛЯ НАСТРОЙКИ OPENAI API:
 
 1. Получите API ключ на https://platform.openai.com/api-keys
 2. Создайте файл APIKeys.plist в папке Sitly/Config/
 3. Добавьте в файл:
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>OpenAI_API_Key</key>
        <string>YOUR_API_KEY_HERE</string>
    </dict>
    </plist>
 
 4. Или установите переменную окружения:
    export OPENAI_API_KEY="your_api_key_here"
 
 5. Или добавьте в Info.plist:
    <key>OpenAI_API_Key</key>
    <string>YOUR_API_KEY_HERE</string>
 
 */
