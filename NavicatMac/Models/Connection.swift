import Foundation
import SwiftUI

// 连接模型
struct Connection: Identifiable, Hashable {
    let id: UUID
    var name: String
    var host: String
    var port: Int
    var username: String
    var password: String
    var database: String?
    var color: String?
    var group: String?
    var sshEnabled: Bool
    var sshHost: String?
    var sshPort: Int?
    var sshUsername: String?
    var sshPassword: String?
    var sslEnabled: Bool
    var createdAt: Date
    var updatedAt: Date
    
    // 连接状态
    var isConnected: Bool = false
    var lastConnected: Date?
    var databases: [Database] = []
    
    init(
        id: UUID = UUID(),
        name: String,
        host: String,
        port: Int = 3306,
        username: String,
        password: String,
        database: String? = nil,
        color: String? = nil,
        group: String? = nil,
        sshEnabled: Bool = false,
        sshHost: String? = nil,
        sshPort: Int? = 22,
        sshUsername: String? = nil,
        sshPassword: String? = nil,
        sslEnabled: Bool = false
    ) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.database = database
        self.color = color
        self.group = group
        self.sshEnabled = sshEnabled
        self.sshHost = sshHost
        self.sshPort = sshPort
        self.sshUsername = sshUsername
        self.sshPassword = sshPassword
        self.sslEnabled = sslEnabled
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // 连接字符串
    var connectionString: String {
        var connStr = "mysql://\(username):\(password)@\(host):\(port)"
        if let database = database {
            connStr += "/\(database)"
        }
        return connStr
    }
    
    // 显示名称
    var displayName: String {
        if let database = database {
            return "\(name) - \(database)"
        }
        return name
    }
    
    // 颜色
    var connectionColor: Color {
        guard let color = color else { return .blue }
        return Color(hex: color) ?? .blue
    }
}

// 数据库模型
struct Database: Identifiable, Hashable {
    let id: UUID
    var name: String
    var charset: String
    var collation: String
    var tables: [Table]
    var views: [DatabaseView]
    var procedures: [StoredProcedure]
    var functions: [Function]
    
    init(
        id: UUID = UUID(),
        name: String,
        charset: String = "utf8mb4",
        collation: String = "utf8mb4_unicode_ci"
    ) {
        self.id = id
        self.name = name
        self.charset = charset
        self.collation = collation
        self.tables = []
        self.views = []
        self.procedures = []
        self.functions = []
    }
}

// 表模型
struct Table: Identifiable, Hashable {
    let id: UUID
    var name: String
    var database: String
    var engine: String
    var rows: Int
    var size: String
    var comment: String
    var columns: [Column]
    var indexes: [Index]
    var foreignKeys: [ForeignKey]
    
    init(
        id: UUID = UUID(),
        name: String,
        database: String,
        engine: String = "InnoDB",
        rows: Int = 0,
        size: String = "0 KB",
        comment: String = ""
    ) {
        self.id = id
        self.name = name
        self.database = database
        self.engine = engine
        self.rows = rows
        self.size = size
        self.comment = comment
        self.columns = []
        self.indexes = []
        self.foreignKeys = []
    }
}

// 字段模型
struct Column: Identifiable, Hashable {
    let id: UUID
    var name: String
    var dataType: String
    var length: Int?
    var precision: Int?
    var scale: Int?
    var nullable: Bool
    var defaultValue: String?
    var comment: String
    var isPrimaryKey: Bool
    var isAutoIncrement: Bool
    var isUnique: Bool
    var isUnsigned: Bool
    var charset: String?
    var collation: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        dataType: String,
        length: Int? = nil,
        precision: Int? = nil,
        scale: Int? = nil,
        nullable: Bool = true,
        defaultValue: String? = nil,
        comment: String = "",
        isPrimaryKey: Bool = false,
        isAutoIncrement: Bool = false,
        isUnique: Bool = false,
        isUnsigned: Bool = false
    ) {
        self.id = id
        self.name = name
        self.dataType = dataType
        self.length = length
        self.precision = precision
        self.scale = scale
        self.nullable = nullable
        self.defaultValue = defaultValue
        self.comment = comment
        self.isPrimaryKey = isPrimaryKey
        self.isAutoIncrement = isAutoIncrement
        self.isUnique = isUnique
        self.isUnsigned = isUnsigned
    }
    
    // 完整数据类型
    var fullDataType: String {
        var type = dataType
        if let length = length {
            type += "(\(length))"
        } else if let precision = precision, let scale = scale {
            type += "(\(precision),\(scale))"
        }
        if isUnsigned {
            type += " UNSIGNED"
        }
        return type
    }
}

// 索引模型
struct Index: Identifiable, Hashable {
    let id: UUID
    var name: String
    var columns: [String]
    var isUnique: Bool
    var isPrimary: Bool
    var indexType: String
    
    init(
        id: UUID = UUID(),
        name: String,
        columns: [String],
        isUnique: Bool = false,
        isPrimary: Bool = false,
        indexType: String = "BTREE"
    ) {
        self.id = id
        self.name = name
        self.columns = columns
        self.isUnique = isUnique
        self.isPrimary = isPrimary
        self.indexType = indexType
    }
}

// 外键模型
struct ForeignKey: Identifiable, Hashable {
    let id: UUID
    var name: String
    var columns: [String]
    var referencedTable: String
    var referencedColumns: [String]
    var onDelete: String
    var onUpdate: String
    
    init(
        id: UUID = UUID(),
        name: String,
        columns: [String],
        referencedTable: String,
        referencedColumns: [String],
        onDelete: String = "RESTRICT",
        onUpdate: String = "RESTRICT"
    ) {
        self.id = id
        self.name = name
        self.columns = columns
        self.referencedTable = referencedTable
        self.referencedColumns = referencedColumns
        self.onDelete = onDelete
        self.onUpdate = onUpdate
    }
}

// 视图模型
// 数据库视图模型（避免与SwiftUI.View冲突）
struct DatabaseView: Identifiable, Hashable {
    let id: UUID
    var name: String
    var database: String
    var definition: String
    var comment: String
    
    init(
        id: UUID = UUID(),
        name: String,
        database: String,
        definition: String = "",
        comment: String = ""
    ) {
        self.id = id
        self.name = name
        self.database = database
        self.definition = definition
        self.comment = comment
    }
}

// 存储过程模型
struct StoredProcedure: Identifiable, Hashable {
    let id: UUID
    var name: String
    var database: String
    var definition: String
    var parameters: [ProcedureParameter]
    var comment: String
    
    init(
        id: UUID = UUID(),
        name: String,
        database: String,
        definition: String = "",
        parameters: [ProcedureParameter] = [],
        comment: String = ""
    ) {
        self.id = id
        self.name = name
        self.database = database
        self.definition = definition
        self.parameters = parameters
        self.comment = comment
    }
}

// 存储过程参数
struct ProcedureParameter: Identifiable, Hashable {
    let id: UUID
    var name: String
    var dataType: String
    var direction: ParameterDirection
    
    init(
        id: UUID = UUID(),
        name: String,
        dataType: String,
        direction: ParameterDirection = .in
    ) {
        self.id = id
        self.name = name
        self.dataType = dataType
        self.direction = direction
    }
}

// 参数方向
enum ParameterDirection: String, Hashable {
    case `in` = "IN"
    case out = "OUT"
    case `inout` = "INOUT"
}

// 函数模型
struct Function: Identifiable, Hashable {
    let id: UUID
    var name: String
    var database: String
    var definition: String
    var returnType: String
    var parameters: [FunctionParameter]
    var comment: String
    
    init(
        id: UUID = UUID(),
        name: String,
        database: String,
        definition: String = "",
        returnType: String = "VOID",
        parameters: [FunctionParameter] = [],
        comment: String = ""
    ) {
        self.id = id
        self.name = name
        self.database = database
        self.definition = definition
        self.returnType = returnType
        self.parameters = parameters
        self.comment = comment
    }
}

// 函数参数
struct FunctionParameter: Identifiable, Hashable {
    let id: UUID
    var name: String
    var dataType: String
    
    init(
        id: UUID = UUID(),
        name: String,
        dataType: String
    ) {
        self.id = id
        self.name = name
        self.dataType = dataType
    }
}

// 查询结果模型
struct QueryResult: Identifiable {
    let id: UUID
    var columns: [String]
    var rows: [[Any?]]
    var affectedRows: Int
    var executionTime: TimeInterval
    var query: String
    var error: Error?
    
    init(
        id: UUID = UUID(),
        columns: [String] = [],
        rows: [[Any?]] = [],
        affectedRows: Int = 0,
        executionTime: TimeInterval = 0,
        query: String = "",
        error: Error? = nil
    ) {
        self.id = id
        self.columns = columns
        self.rows = rows
        self.affectedRows = affectedRows
        self.executionTime = executionTime
        self.query = query
        self.error = error
    }
    
    // 是否有结果
    var hasResults: Bool {
        return !columns.isEmpty
    }
    
    // 行数
    var rowCount: Int {
        return rows.count
    }
}

// 查询标签页模型
class QueryTab: Identifiable, ObservableObject {
    let id: UUID
    @Published var title: String
    @Published var query: String
    @Published var results: [QueryResult]
    @Published var isExecuting: Bool
    var connection: Connection?
    
    init(
        id: UUID = UUID(),
        title: String = "查询",
        query: String = "",
        results: [QueryResult] = [],
        isExecuting: Bool = false,
        connection: Connection? = nil
    ) {
        self.id = id
        self.title = title
        self.query = query
        self.results = results
        self.isExecuting = isExecuting
        self.connection = connection
    }
}

// 连接分组模型
struct ConnectionGroup: Identifiable, Hashable {
    let id: UUID
    var name: String
    var connections: [Connection]
    
    init(
        id: UUID = UUID(),
        name: String,
        connections: [Connection] = []
    ) {
        self.id = id
        self.name = name
        self.connections = connections
    }
}

// 扩展Color支持Hex
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}