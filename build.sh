#!/bin/bash

# NavicatMac 构建脚本
# 用于快速构建、测试和打包NavicatMac应用程序

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查Swift是否安装
check_swift() {
    if ! command -v swift &> /dev/null; then
        print_error "Swift未安装，请先安装Xcode"
        exit 1
    fi
    
    print_info "Swift版本: $(swift --version)"
}

# 检查Xcode是否安装
check_xcode() {
    if ! command -v xcodebuild &> /dev/null; then
        print_warning "Xcode未安装，某些功能可能不可用"
    else
        print_info "Xcode版本: $(xcodebuild -version | head -1)"
    fi
}

# 清理构建文件
clean() {
    print_info "清理构建文件..."
    rm -rf .build
    swift package clean
    print_success "构建文件已清理"
}

# 解析依赖
resolve() {
    print_info "解析依赖..."
    swift package resolve
    print_success "依赖解析完成"
}

# 构建项目
build() {
    print_info "构建项目..."
    swift build
    print_success "构建完成"
}

# 构建发布版本
release() {
    print_info "构建发布版本..."
    swift build -c release
    print_success "发布版本构建完成"
}

# 运行测试
test() {
    print_info "运行测试..."
    swift test
    print_success "测试完成"
}

# 运行应用程序
run() {
    print_info "运行应用程序..."
    swift run
}

# 打包为dmg
package() {
    print_info "打包为dmg..."
    
    # 构建发布版本
    release
    
    # 创建构建目录
    mkdir -p .build/dmg
    
    # 创建应用程序包
    APP_BUNDLE=".build/release/NavicatMac.app"
    mkdir -p "$APP_BUNDLE/Contents/MacOS"
    mkdir -p "$APP_BUNDLE/Contents/Resources"
    
    # 复制可执行文件
    cp ".build/release/NavicatMac" "$APP_BUNDLE/Contents/MacOS/"
    
    # 创建Info.plist
    cat > "$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>NavicatMac</string>
    <key>CFBundleIdentifier</key>
    <string>com.navicat.mac</string>
    <key>CFBundleName</key>
    <string>NavicatMac</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF
    
    # 创建PkgInfo
    echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"
    
    # 创建dmg
    DMG_NAME="NavicatMac-$(date +%Y%m%d).dmg"
    hdiutil create -volname "NavicatMac" -srcfolder "$APP_BUNDLE" -ov -format UDZO ".build/dmg/$DMG_NAME"
    
    print_success "dmg已创建: .build/dmg/$DMG_NAME"
}

# 安装到应用程序文件夹
install() {
    print_info "安装到应用程序文件夹..."
    
    # 构建发布版本
    release
    
    # 创建应用程序包
    APP_BUNDLE=".build/release/NavicatMac.app"
    mkdir -p "$APP_BUNDLE/Contents/MacOS"
    mkdir -p "$APP_BUNDLE/Contents/Resources"
    
    # 复制可执行文件
    cp ".build/release/NavicatMac" "$APP_BUNDLE/Contents/MacOS/"
    
    # 创建Info.plist
    cat > "$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>NavicatMac</string>
    <key>CFBundleIdentifier</key>
    <string>com.navicat.mac</string>
    <key>CFBundleName</key>
    <string>NavicatMac</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF
    
    # 创建PkgInfo
    echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"
    
    # 复制到应用程序文件夹
    cp -R "$APP_BUNDLE" /Applications/
    
    print_success "安装完成"
}

# 卸载
uninstall() {
    print_info "卸载NavicatMac..."
    rm -rf /Applications/NavicatMac.app
    print_success "卸载完成"
}

# 生成Xcode项目
xcode() {
    print_info "生成Xcode项目..."
    swift package generate-xcodeproj
    print_success "Xcode项目已生成: NavicatMac.xcodeproj"
}

# 代码检查
lint() {
    print_info "代码检查..."
    if command -v swiftlint &> /dev/null; then
        swiftlint lint
    else
        print_warning "SwiftLint未安装，跳过代码检查"
    fi
}

# 代码格式化
format() {
    print_info "代码格式化..."
    if command -v swiftformat &> /dev/null; then
        swiftformat .
    else
        print_warning "SwiftFormat未安装，跳过代码格式化"
    fi
}

# 显示帮助
help() {
    echo "NavicatMac 构建脚本"
    echo ""
    echo "用法: ./build.sh [命令]"
    echo ""
    echo "可用命令:"
    echo "  clean          - 清理构建文件"
    echo "  resolve        - 解析依赖"
    echo "  build          - 构建项目"
    echo "  release        - 构建发布版本"
    echo "  test           - 运行测试"
    echo "  run            - 运行应用程序"
    echo "  package        - 打包为dmg"
    echo "  install        - 安装到应用程序文件夹"
    echo "  uninstall      - 从应用程序文件夹卸载"
    echo "  xcode          - 生成Xcode项目"
    echo "  lint           - 代码检查"
    echo "  format         - 代码格式化"
    echo "  help           - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  ./build.sh build    # 构建项目"
    echo "  ./build.sh test     # 运行测试"
    echo "  ./build.sh package  # 打包为dmg"
}

# 主函数
main() {
    # 检查Swift
    check_swift
    
    # 检查Xcode
    check_xcode
    
    # 解析命令
    case "${1:-help}" in
        clean)
            clean
            ;;
        resolve)
            resolve
            ;;
        build)
            build
            ;;
        release)
            release
            ;;
        test)
            test
            ;;
        run)
            run
            ;;
        package)
            package
            ;;
        install)
            install
            ;;
        uninstall)
            uninstall
            ;;
        xcode)
            xcode
            ;;
        lint)
            lint
            ;;
        format)
            format
            ;;
        help|*)
            help
            ;;
    esac
}

# 运行主函数
main "$@"