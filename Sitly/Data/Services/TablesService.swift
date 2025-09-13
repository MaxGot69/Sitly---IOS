//
//  TablesService.swift
//  Sitly
//
//  Created by AI Assistant on 12.09.2025.
//

import Foundation
import FirebaseFirestore
import Combine

protocol TablesServiceProtocol {
    func fetchTables(for restaurantId: String) async throws -> [TableModel]
    func createTable(_ table: TableModel, for restaurantId: String) async throws -> TableModel
    func updateTable(_ table: TableModel, for restaurantId: String) async throws
    func deleteTable(_ table: TableModel, for restaurantId: String) async throws
    func updateTableStatus(_ tableId: String, status: TableModel.TableStatusType, for restaurantId: String) async throws
    func observeTables(for restaurantId: String) -> AnyPublisher<[TableModel], Error>
}

class TablesService: TablesServiceProtocol {
    private let db = Firestore.firestore()
    private var listeners: [String: ListenerRegistration] = [:]
    
    // MARK: - Fetch Tables
    func fetchTables(for restaurantId: String) async throws -> [TableModel] {
        print("🔄 Загружаем столики для ресторана: \(restaurantId)")
        
        let snapshot = try await db
            .collection("restaurants")
            .document(restaurantId)
            .collection("tables")
            .getDocuments()
        
        let tables = try snapshot.documents.compactMap { document -> TableModel? in
            var data = document.data()
            data["id"] = document.documentID
            
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            return try JSONDecoder().decode(TableModel.self, from: jsonData)
        }
        
        print("✅ Загружено столиков: \(tables.count)")
        return tables
    }
    
    // MARK: - Create Table
    func createTable(_ table: TableModel, for restaurantId: String) async throws -> TableModel {
        print("➕ Создаем столик: \(table.name)")
        
        var tableData = table
        tableData.position = nil // Убираем position для упрощения
        
        let jsonData = try JSONEncoder().encode(tableData)
        var data = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        
        // Убираем id, чтобы Firestore сгенерировал автоматически
        data.removeValue(forKey: "id")
        
        // Добавляем timestamp
        data["createdAt"] = FieldValue.serverTimestamp()
        data["updatedAt"] = FieldValue.serverTimestamp()
        
        let documentRef = try await db
            .collection("restaurants")
            .document(restaurantId)
            .collection("tables")
            .addDocument(data: data)
        
        // Возвращаем столик с новым ID
        var createdTable = tableData
        createdTable.id = documentRef.documentID
        
        print("✅ Столик создан с ID: \(documentRef.documentID)")
        return createdTable
    }
    
    // MARK: - Update Table
    func updateTable(_ table: TableModel, for restaurantId: String) async throws {
        print("🔄 Обновляем столик: \(table.name)")
        
        let jsonData = try JSONEncoder().encode(table)
        var data = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        
        // Убираем id и добавляем timestamp
        data.removeValue(forKey: "id")
        data["updatedAt"] = FieldValue.serverTimestamp()
        
        try await db
            .collection("restaurants")
            .document(restaurantId)
            .collection("tables")
            .document(table.id)
            .updateData(data)
        
        print("✅ Столик обновлен")
    }
    
    // MARK: - Delete Table
    func deleteTable(_ table: TableModel, for restaurantId: String) async throws {
        print("🗑️ Удаляем столик: \(table.name)")
        
        try await db
            .collection("restaurants")
            .document(restaurantId)
            .collection("tables")
            .document(table.id)
            .delete()
        
        print("✅ Столик удален")
    }
    
    // MARK: - Update Table Status
    func updateTableStatus(_ tableId: String, status: TableModel.TableStatusType, for restaurantId: String) async throws {
        print("🔄 Обновляем статус столика \(tableId) на \(status.displayName)")
        
        try await db
            .collection("restaurants")
            .document(restaurantId)
            .collection("tables")
            .document(tableId)
            .updateData([
                "status": status.rawValue,
                "updatedAt": FieldValue.serverTimestamp()
            ])
        
        print("✅ Статус столика обновлен")
    }
    
    // MARK: - Real-time Observations
    func observeTables(for restaurantId: String) -> AnyPublisher<[TableModel], Error> {
        print("👀 Настраиваем наблюдение за столиками ресторана: \(restaurantId)")
        
        return Future<[TableModel], Error> { promise in
            let listener = self.db
                .collection("restaurants")
                .document(restaurantId)
                .collection("tables")
                .order(by: "createdAt")
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("❌ Ошибка наблюдения за столиками: \(error)")
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    do {
                        let tables = try documents.compactMap { document -> TableModel? in
                            var data = document.data()
                            data["id"] = document.documentID
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: data)
                            return try JSONDecoder().decode(TableModel.self, from: jsonData)
                        }
                        
                        print("📊 Обновлено столиков: \(tables.count)")
                        promise(.success(tables))
                    } catch {
                        print("❌ Ошибка парсинга столиков: \(error)")
                        promise(.failure(error))
                    }
                }
            
            // Сохраняем listener для отписки
            self.listeners[restaurantId] = listener
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Cleanup
    func stopObserving(restaurantId: String) {
        listeners[restaurantId]?.remove()
        listeners.removeValue(forKey: restaurantId)
        print("🛑 Остановлено наблюдение за столиками ресторана: \(restaurantId)")
    }
    
    deinit {
        listeners.values.forEach { $0.remove() }
        print("🧹 TablesService очищен")
    }
}

// MARK: - Mock Service for Development
class MockTablesService: TablesServiceProtocol {
    private var mockTables: [TableModel] = []
    private let subject = PassthroughSubject<[TableModel], Error>()
    
    init() {
        // Инициализируем моковые данные
        mockTables = [
            TableModel(id: "1", name: "Стол 1", capacity: 2, type: .indoor, status: .available, isVIP: false),
            TableModel(id: "2", name: "Стол 2", capacity: 4, type: .indoor, status: .occupied, isVIP: false),
            TableModel(id: "3", name: "VIP-1", capacity: 6, type: .vip, status: .reserved, isVIP: true),
            TableModel(id: "4", name: "Терраса 1", capacity: 4, type: .outdoor, status: .available, isVIP: false),
            TableModel(id: "5", name: "Бар 1", capacity: 2, type: .bar, status: .cleaning, isVIP: false),
            TableModel(id: "6", name: "Стол 3", capacity: 8, type: .indoor, status: .available, isVIP: false),
        ]
    }
    
    func fetchTables(for restaurantId: String) async throws -> [TableModel] {
        try await Task.sleep(nanoseconds: 500_000_000) // Эмуляция сетевой задержки
        return mockTables
    }
    
    func createTable(_ table: TableModel, for restaurantId: String) async throws -> TableModel {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        var newTable = table
        newTable.id = UUID().uuidString
        mockTables.append(newTable)
        
        subject.send(mockTables)
        return newTable
    }
    
    func updateTable(_ table: TableModel, for restaurantId: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        if let index = mockTables.firstIndex(where: { $0.id == table.id }) {
            mockTables[index] = table
            subject.send(mockTables)
        }
    }
    
    func deleteTable(_ table: TableModel, for restaurantId: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        mockTables.removeAll { $0.id == table.id }
        subject.send(mockTables)
    }
    
    func updateTableStatus(_ tableId: String, status: TableModel.TableStatusType, for restaurantId: String) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        if let index = mockTables.firstIndex(where: { $0.id == tableId }) {
            mockTables[index].status = status
            subject.send(mockTables)
        }
    }
    
    func observeTables(for restaurantId: String) -> AnyPublisher<[TableModel], Error> {
        // Отправляем начальные данные
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.subject.send(self.mockTables)
        }
        
        return subject.eraseToAnyPublisher()
    }
}
