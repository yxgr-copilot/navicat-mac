import XCTest
@testable import NavicatMac

final class NavicatMacTests: XCTestCase {
    
    // MARK: - 连接模型测试
    
    func testConnectionInitialization() {
        let connection = Connection(
            name: "测试连接",
            host: "localhost",
            port: 3306,
            username: "root",
            password: "password"
        )
        
        XCTAssertEqual(connection.name, "测试连接")
        XCTAssertEqual(connection.host, "localhost")
        XCTAssertEqual(connection.port, 3306)
        XCTAssertEqual(connection.username, "root")
        XCTAssertEqual(connection.password, "password")
        XCTAssertNil(connection.database)
        XCTAssertFalse(connection.isConnected)
    }
    
    func testConnectionWithDatabase() {
        let connection = Connection(
            name: "测试连接",
            host: "localhost",
            port: 3306,
            username: "root",
            password: "password",
            database: "test_db"
        )
        
        XCTAssertEqual(connection.database, "test_db")
        XCTAssertEqual(connection.displayName, "测试连接 - test_db")
    }
    
    func testConnectionString() {
        let connection = Connection(
            name: "测试连接",
            host: "localhost",
            port: 3306,
            username: "root",
            password: "password"
        )
        
        XCTAssertEqual(connection.connectionString, "mysql://root:password@localhost:3306")
    }
    
    // MARK: - 数据库模型测试
    
    func testDatabaseInitialization() {
        let database = Database(name: "test_db")
        
        XCTAssertEqual(database.name, "test_db")
        XCTAssertEqual(database.charset, "utf8mb4")
        XCTAssertEqual(database.collation, "utf8mb4_unicode_ci")
        XCTAssertTrue(database.tables.isEmpty)
        XCTAssertTrue(database.views.isEmpty)
        XCTAssertTrue(database.procedures.isEmpty)
        XCTAssertTrue(database.functions.isEmpty)
    }
    
    // MARK: - 表模型测试
    
    func testTableInitialization() {
        let table = Table(
            name: "users",
            database: "test_db",
            engine: "InnoDB",
            rows: 1000,
            size: "100 KB",
            comment: "用户表"
        )
        
        XCTAssertEqual(table.name, "users")
        XCTAssertEqual(table.database, "test_db")
        XCTAssertEqual(table.engine, "InnoDB")
        XCTAssertEqual(table.rows, 1000)
        XCTAssertEqual(table.size, "100 KB")
        XCTAssertEqual(table.comment, "用户表")
        XCTAssertTrue(table.columns.isEmpty)
        XCTAssertTrue(table.indexes.isEmpty)
        XCTAssertTrue(table.foreignKeys.isEmpty)
    }
    
    // MARK: - 字段模型测试
    
    func testColumnInitialization() {
        let column = Column(
            name: "id",
            dataType: "INT",
            length: 11,
            nullable: false,
            isPrimaryKey: true,
            isAutoIncrement: true
        )
        
        XCTAssertEqual(column.name, "id")
        XCTAssertEqual(column.dataType, "INT")
        XCTAssertEqual(column.length, 11)
        XCTAssertFalse(column.nullable)
        XCTAssertTrue(column.isPrimaryKey)
        XCTAssertTrue(column.isAutoIncrement)
        XCTAssertEqual(column.fullDataType, "INT(11)")
    }
    
    func testColumnFullDataType() {
        let column1 = Column(name: "id", dataType: "INT", length: 11)
        XCTAssertEqual(column1.fullDataType, "INT(11)")
        
        let column2 = Column(name: "price", dataType: "DECIMAL", precision: 10, scale: 2)
        XCTAssertEqual(column2.fullDataType, "DECIMAL(10,2)")
        
        let column3 = Column(name: "name", dataType: "VARCHAR", length: 255, isUnsigned: true)
        XCTAssertEqual(column3.fullDataType, "VARCHAR(255) UNSIGNED")
    }
    
    // MARK: - 索引模型测试
    
    func testIndexInitialization() {
        let index = Index(
            name: "PRIMARY",
            columns: ["id"],
            isUnique: true,
            isPrimary: true,
            indexType: "BTREE"
        )
        
        XCTAssertEqual(index.name, "PRIMARY")
        XCTAssertEqual(index.columns, ["id"])
        XCTAssertTrue(index.isUnique)
        XCTAssertTrue(index.isPrimary)
        XCTAssertEqual(index.indexType, "BTREE")
    }
    
    // MARK: - 外键模型测试
    
    func testForeignKeyInitialization() {
        let foreignKey = ForeignKey(
            name: "fk_user_id",
            columns: ["user_id"],
            referencedTable: "users",
            referencedColumns: ["id"],
            onDelete: "CASCADE",
            onUpdate: "RESTRICT"
        )
        
        XCTAssertEqual(foreignKey.name, "fk_user_id")
        XCTAssertEqual(foreignKey.columns, ["user_id"])
        XCTAssertEqual(foreignKey.referencedTable, "users")
        XCTAssertEqual(foreignKey.referencedColumns, ["id"])
        XCTAssertEqual(foreignKey.onDelete, "CASCADE")
        XCTAssertEqual(foreignKey.onUpdate, "RESTRICT")
    }
    
    // MARK: - 查询结果测试
    
    func testQueryResultInitialization() {
        let result = QueryResult(
            columns: ["id", "name"],
            rows: [[1, "张三"], [2, "李四"]],
            affectedRows: 2,
            executionTime: 0.123,
            query: "SELECT * FROM users"
        )
        
        XCTAssertTrue(result.hasResults)
        XCTAssertEqual(result.rowCount, 2)
        XCTAssertEqual(result.columns.count, 2)
        XCTAssertEqual(result.affectedRows, 2)
        XCTAssertEqual(result.executionTime, 0.123)
        XCTAssertEqual(result.query, "SELECT * FROM users")
        XCTAssertNil(result.error)
    }
    
    func testQueryResultWithoutResults() {
        let result = QueryResult(
            affectedRows: 1,
            executionTime: 0.05,
            query: "INSERT INTO users VALUES (1, 'test')"
        )
        
        XCTAssertFalse(result.hasResults)
        XCTAssertEqual(result.rowCount, 0)
    }
    
    // MARK: - 查询标签页测试
    
    func testQueryTabInitialization() {
        let tab = QueryTab(title: "查询 1")
        
        XCTAssertEqual(tab.title, "查询 1")
        XCTAssertTrue(tab.query.isEmpty)
        XCTAssertTrue(tab.results.isEmpty)
        XCTAssertFalse(tab.isExecuting)
        XCTAssertNil(tab.connection)
    }
    
    // MARK: - 连接分组测试
    
    func testConnectionGroupInitialization() {
        let group = ConnectionGroup(name: "开发环境")
        
        XCTAssertEqual(group.name, "开发环境")
        XCTAssertTrue(group.connections.isEmpty)
    }
    
    // MARK: - Color扩展测试
    
    func testColorFromHex() {
        let color1 = Color(hex: "#FF0000")
        XCTAssertNotNil(color1)
        
        let color2 = Color(hex: "00FF00")
        XCTAssertNotNil(color2)
        
        let color3 = Color(hex: "#0000FF")
        XCTAssertNotNil(color3)
        
        let color4 = Color(hex: "invalid")
        XCTAssertNil(color4)
    }
    
    // MARK: - 性能测试
    
    func testPerformanceExample() {
        measure {
            // 性能测试示例
            for _ in 0..<1000 {
                let _ = Connection(
                    name: "测试连接",
                    host: "localhost",
                    port: 3306,
                    username: "root",
                    password: "password"
                )
            }
        }
    }
}