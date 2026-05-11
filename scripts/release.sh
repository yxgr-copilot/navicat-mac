#!/bin/bash

# NavicatMac版本发布脚本
# 用于自动化版本发布流程，支持arm64和x86_64架构

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

# 显示帮助
show_help() {
    echo "NavicatMac版本发布脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  -v, --version       指定版本号 (例如: 0.2.0)"
    echo "  -m, --message       版本描述信息"
    echo "  -d, --dry-run       模拟运行，不执行实际操作"
    echo "  -f, --force         强制执行，跳过确认"
    echo ""
    echo "示例:"
    echo "  $0 -v 0.2.0 -m \"新增MySQL连接功能\""
    echo "  $0 --version 0.2.0 --message \"新增MySQL连接功能\""
    echo "  $0 -v 0.2.0 -d  # 模拟运行"
}

# 检查Git状态
check_git_status() {
    if [ -n "$(git status --porcelain)" ]; then
        print_error "有未提交的更改，请先提交所有更改"
        exit 1
    fi
}

# 获取版本号
get_version() {
    local version=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
    echo "$version"
}

# 验证版本号格式
validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "版本号格式不正确，应为 X.Y.Z 格式"
        exit 1
    fi
}

# 更新版本号
update_version() {
    local version=$1
    
    print_info "更新版本号为 $version"
    
    # 更新Package.swift中的版本
    if [ -f "Package.swift" ]; then
        sed -i '' "s/let version = \".*\"/let version = \"$version\"/" "Package.swift" 2>/dev/null || true
    fi
    
    # 更新Info.plist中的版本
    if [ -f "NavicatMac/Info.plist" ]; then
        sed -i '' "s/<string>.*<\/string>/<string>$version<\/string>/" "NavicatMac/Info.plist" 2>/dev/null || true
    fi
    
    print_success "版本号更新完成"
}

# 更新CHANGELOG.md
update_changelog() {
    local version=$1
    local message=$2
    
    print_info "更新CHANGELOG.md"
    
    local changelog_file="CHANGELOG.md"
    local temp_file=$(mktemp)
    local date=$(date +%Y-%m-%d)
    
    # 读取现有的CHANGELOG.md
    if [ -f "$changelog_file" ]; then
        # 检查是否有"未发布"部分
        if grep -q "## \[未发布\]" "$changelog_file"; then
            # 替换"未发布"为新版本
            sed "s/## \[未发布\]/## [$version] - $date/" "$changelog_file" > "$temp_file"
            
            # 在文件开头添加新的"未发布"部分
            {
                echo "# Changelog"
                echo ""
                echo "本文件记录NavicatMac项目的所有重要变更。"
                echo ""
                echo "格式基于[Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，"
                echo "并且本项目遵循[语义化版本控制](https://semver.org/lang/zh-CN/)。"
                echo ""
                echo "## [未发布]"
                echo ""
                echo "### 新增"
                echo ""
                echo "### 变更"
                echo ""
                echo "### 修复"
                echo ""
                echo "## [$version] - $date"
                echo ""
                echo "### 新增"
                echo "- $message"
                echo ""
                tail -n +7 "$temp_file"
            } > "$changelog_file"
        else
            # 在文件开头添加新版本
            {
                echo "# Changelog"
                echo ""
                echo "本文件记录NavicatMac项目的所有重要变更。"
                echo ""
                echo "格式基于[Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，"
                echo "并且本项目遵循[语义化版本控制](https://semver.org/lang/zh-CN/)。"
                echo ""
                echo "## [未发布]"
                echo ""
                echo "### 新增"
                echo ""
                echo "### 变更"
                echo ""
                echo "### 修复"
                echo ""
                echo "## [$version] - $date"
                echo ""
                echo "### 新增"
                echo "- $message"
                echo ""
                tail -n +7 "$changelog_file"
            } > "$temp_file"
            mv "$temp_file" "$changelog_file"
        fi
    else
        # 创建新的CHANGELOG.md
        {
            echo "# Changelog"
            echo ""
            echo "本文件记录NavicatMac项目的所有重要变更。"
            echo ""
            echo "格式基于[Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，"
            echo "并且本项目遵循[语义化版本控制](https://semver.org/lang/zh-CN/)。"
            echo ""
            echo "## [未发布]"
            echo ""
            echo "### 新增"
            echo ""
            echo "### 变更"
            echo ""
            echo "### 修复"
            echo ""
            echo "## [$version] - $date"
            echo ""
            echo "### 新增"
            echo "- $message"
        } > "$changelog_file"
    fi
    
    print_success "CHANGELOG.md更新完成"
}

# 构建项目（支持arm64和x86_64）
build_project() {
    local version=$1
    
    print_info "构建项目"
    
    # 清理之前的构建
    make clean 2>/dev/null || true
    
    # 构建arm64版本
    print_info "构建arm64版本..."
    xcodebuild -project NavicatMac.xcodeproj -scheme NavicatMac -configuration Release -arch arm64 build
    
    # 创建arm64 dmg
    local app_path=$(xcodebuild -project NavicatMac.xcodeproj -scheme NavicatMac -configuration Release -showBuildSettings 2>/dev/null | grep "BUILT_PRODUCTS_DIR" | awk '{print $3}' | head -1)/NavicatMac.app
    hdiutil create -volname "NavicatMac" -srcfolder "$app_path" -ov -format UDZO "build/dmg/NavicatMac-${version}-arm64.dmg"
    
    # 清理并构建x86_64版本
    print_info "构建x86_64版本..."
    xcodebuild -project NavicatMac.xcodeproj -scheme NavicatMac -configuration Release clean
    xcodebuild -project NavicatMac.xcodeproj -scheme NavicatMac -configuration Release -arch x86_64 build
    
    # 创建x86_64 dmg
    app_path=$(xcodebuild -project NavicatMac.xcodeproj -scheme NavicatMac -configuration Release -showBuildSettings 2>/dev/null | grep "BUILT_PRODUCTS_DIR" | awk '{print $3}' | head -1)/NavicatMac.app
    hdiutil create -volname "NavicatMac" -srcfolder "$app_path" -ov -format UDZO "build/dmg/NavicatMac-${version}-x86_64.dmg"
    
    # 清理构建文件
    xcodebuild -project NavicatMac.xcodeproj -scheme NavicatMac -configuration Release clean
    
    print_success "项目构建完成"
}

# 创建Git标签
create_tag() {
    local version=$1
    local message=$2
    
    print_info "创建Git标签: v$version"
    
    git add .
    git commit -m "release: v$version - $message"
    git tag -a "v$version" -m "Release v$version: $message"
    
    print_success "Git标签创建完成"
}

# 推送到远程仓库
push_to_remote() {
    local version=$1
    
    print_info "推送到远程仓库"
    
    git push origin main
    git push origin "v$version"
    
    print_success "推送到远程仓库完成"
}

# 创建GitHub Release并上传dmg文件
create_github_release() {
    local version=$1
    local message=$2
    
    print_info "创建GitHub Release"
    
    # 运行Release脚本
    if [ -f "scripts/create-release.sh" ]; then
        ./scripts/create-release.sh
    else
        print_warning "Release脚本不存在，请手动创建GitHub Release"
    fi
}

# 主函数
main() {
    local version=""
    local message=""
    local dry_run=false
    local force=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                version="$2"
                shift 2
                ;;
            -m|--message)
                message="$2"
                shift 2
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            *)
                print_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 检查必需参数
    if [ -z "$version" ]; then
        print_error "请指定版本号"
        show_help
        exit 1
    fi
    
    if [ -z "$message" ]; then
        message="版本更新"
    fi
    
    # 验证版本号格式
    validate_version "$version"
    
    # 显示发布信息
    print_info "版本发布信息"
    echo "  版本号: $version"
    echo "  描述: $message"
    echo "  模拟运行: $dry_run"
    echo ""
    
    # 确认操作
    if [ "$force" = false ]; then
        read -p "确认发布？(y/N): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            print_info "取消发布"
            exit 0
        fi
    fi
    
    # 检查Git状态
    check_git_status
    
    # 模拟运行模式
    if [ "$dry_run" = true ]; then
        print_info "模拟运行模式，不执行实际操作"
        
        print_info "将执行以下操作:"
        echo "  1. 更新版本号为 $version"
        echo "  2. 更新CHANGELOG.md"
        echo "  3. 构建项目 (arm64 + x86_64)"
        echo "  4. 创建Git标签"
        echo "  5. 推送到远程仓库"
        echo "  6. 创建GitHub Release并上传dmg文件"
        
        exit 0
    fi
    
    # 执行发布流程
    update_version "$version"
    update_changelog "$version" "$message"
    build_project "$version"
    create_tag "$version" "$message"
    push_to_remote "$version"
    create_github_release "$version" "$message"
    
    print_success "版本 $version 发布完成！"
    print_info "dmg文件已生成:"
    echo "  - build/dmg/NavicatMac-${version}-arm64.dmg (Apple Silicon)"
    echo "  - build/dmg/NavicatMac-${version}-x86_64.dmg (Intel)"
}

# 运行主函数
main "$@"