# NavicatMac Makefile
# 用于构建、测试和打包NavicatMac应用程序

# 变量
APP_NAME = NavicatMac
PROJECT = NavicatMac.xcodeproj
SCHEME = NavicatMac
BUILD_DIR = build
DMG_DIR = $(BUILD_DIR)/dmg
DMG_NAME = $(APP_NAME)-$(shell date +%Y%m%d).dmg

# Xcode构建工具
XCODEBUILD = xcodebuild

# 获取DerivedData路径
DERIVED_DATA = $(shell xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Release -showBuildSettings 2>/dev/null | grep "BUILT_PRODUCTS_DIR" | awk '{print $$3}' | head -1)
APP_BUNDLE = $(DERIVED_DATA)/$(APP_NAME).app

# 默认目标
.PHONY: all
all: build

# 帮助信息
.PHONY: help
help:
	@echo "NavicatMac 构建系统"
	@echo ""
	@echo "可用命令:"
	@echo "  make build          - 构建应用程序"
	@echo "  make release        - 构建发布版本"
	@echo "  make debug          - 构建调试版本"
	@echo "  make test           - 运行测试"
	@echo "  make clean          - 清理构建文件"
	@echo "  make run            - 运行应用程序"
	@echo "  make package        - 打包为dmg"
	@echo "  make install        - 安装到应用程序文件夹"
	@echo "  make uninstall      - 从应用程序文件夹卸载"
	@echo ""

# 构建应用程序
.PHONY: build
build:
	@echo "构建 $(APP_NAME)..."
	$(XCODEBUILD) -project $(PROJECT) -scheme $(SCHEME) -configuration Debug build

# 构建发布版本
.PHONY: release
release:
	@echo "构建发布版本..."
	$(XCODEBUILD) -project $(PROJECT) -scheme $(SCHEME) -configuration Release build

# 构建调试版本
.PHONY: debug
debug:
	@echo "构建调试版本..."
	$(XCODEBUILD) -project $(PROJECT) -scheme $(SCHEME) -configuration Debug build

# 运行测试
.PHONY: test
test:
	@echo "运行测试..."
	$(XCODEBUILD) -project $(PROJECT) -scheme $(SCHEME) -configuration Debug test

# 清理构建文件
.PHONY: clean
clean:
	@echo "清理构建文件..."
	$(XCODEBUILD) -project $(PROJECT) -scheme $(SCHEME) clean
	rm -rf $(BUILD_DIR)

# 运行应用程序
.PHONY: run
run: build
	@echo "运行 $(APP_NAME)..."
	@open $(shell xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Debug -showBuildSettings 2>/dev/null | grep "BUILT_PRODUCTS_DIR" | awk '{print $$3}' | head -1)/$(APP_NAME).app

# 打包为dmg
.PHONY: package
package: release
	@echo "打包为dmg..."
	@mkdir -p $(DMG_DIR)
	@# 获取Release构建路径
	$(eval RELEASE_APP := $(shell xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Release -showBuildSettings 2>/dev/null | grep "BUILT_PRODUCTS_DIR" | awk '{print $$3}' | head -1)/$(APP_NAME).app)
	@echo "应用路径: $(RELEASE_APP)"
	@# 创建dmg
	@hdiutil create -volname "$(APP_NAME)" -srcfolder "$(RELEASE_APP)" -ov -format UDZO "$(DMG_DIR)/$(DMG_NAME)"
	@echo "dmg已创建: $(DMG_DIR)/$(DMG_NAME)"

# 安装到应用程序文件夹
.PHONY: install
install: release
	@echo "安装 $(APP_NAME) 到应用程序文件夹..."
	@$(eval RELEASE_APP := $(shell xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Release -showBuildSettings 2>/dev/null | grep "BUILT_PRODUCTS_DIR" | awk '{print $$3}' | head -1)/$(APP_NAME).app)
	@cp -R "$(RELEASE_APP)" /Applications/
	@echo "安装完成"

# 从应用程序文件夹卸载
.PHONY: uninstall
uninstall:
	@echo "卸载 $(APP_NAME)..."
	@rm -rf /Applications/$(APP_NAME).app
	@echo "卸载完成"

# 依赖更新
.PHONY: update
update:
	@echo "更新依赖..."
	$(XCODEBUILD) -project $(PROJECT) -scheme $(SCHEME) resolvePackageDependencies

# 清理DerivedData
.PHONY: clean-all
clean-all: clean
	@echo "清理DerivedData..."
	@rm -rf ~/Library/Developer/Xcode/DerivedData/NavicatMac-*
	@echo "DerivedData已清理"