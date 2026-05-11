#!/bin/bash

# NavicatMac Release脚本
# 用于创建GitHub Release

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

# 生成变更日志
generate_changelog() {
    local version=$1
    local changelog=""
    
    # 获取上一个版本
    local prev_version=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "")
    
    if [ -z "$prev_version" ]; then
        # 第一个版本，获取所有提交
        changelog=$(git log --oneline --no-merges | head -20)
    else
        # 获取两个版本之间的提交
        changelog=$(git log --oneline --no-merges ${prev_version}..${version})
    fi
    
    echo "$changelog"
}

# 创建Release
create_release() {
    local version=$1
    local changelog=$2
    
    print_info "创建Release: $version"
    
    # 创建Release草稿
    local release_body="## 版本 $version\n\n### 变更日志\n\n$changelog\n\n### 安装说明\n\n1. 下载 \`NavicatMac-${version#v}.dmg\`\n2. 打开dmg文件\n3. 将NavicatMac.app拖入Applications文件夹\n4. 首次运行可能需要在系统偏好设置中允许运行\n\n### 系统要求\n\n- macOS 14.0 或更高版本\n- Intel 或 Apple Silicon 处理器"
    
    # 使用GitHub API创建Release
    if [ -n "$GITHUB_TOKEN" ]; then
        print_info "使用GitHub API创建Release..."
        
        local api_response=$(curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/yxgr-copilot/navicat-mac/releases" \
            -d "{
                \"tag_name\": \"$version\",
                \"name\": \"Release $version\",
                \"body\": \"$release_body\",
                \"draft\": false,
                \"prerelease\": false
            }")
        
        if echo "$api_response" | grep -q '"id"'; then
            print_success "Release创建成功"
            
            # 上传dmg文件
            local dmg_file="build/dmg/NavicatMac-$(date +%Y%m%d).dmg"
            if [ -f "$dmg_file" ]; then
                print_info "上传dmg文件..."
                local upload_url=$(echo "$api_response" | grep -o '"upload_url":"[^"]*"' | cut -d'"' -f4 | sed 's/{.*//')
                
                curl -s -X POST \
                    -H "Authorization: token $GITHUB_TOKEN" \
                    -H "Content-Type: application/octet-stream" \
                    "$upload_url?name=$(basename $dmg_file)" \
                    --data-binary @"$dmg_file"
                
                print_success "dmg文件上传成功"
            fi
        else
            print_error "Release创建失败"
            echo "$api_response"
            exit 1
        fi
    else
        print_warning "GITHUB_TOKEN未设置，无法自动创建Release"
        print_info "请手动创建Release："
        echo ""
        echo "1. 访问 https://github.com/yxgr-copilot/navicat-mac/releases/new"
        echo "2. 选择标签: $version"
        echo "3. 标题: Release $version"
        echo "4. 描述:"
        echo ""
        echo "## 版本 $version"
        echo ""
        echo "### 变更日志"
        echo ""
        echo "$changelog"
        echo ""
        echo "### 安装说明"
        echo ""
        echo "1. 下载 NavicatMac-${version#v}.dmg"
        echo "2. 打开dmg文件"
        echo "3. 将NavicatMac.app拖入Applications文件夹"
        echo "4. 首次运行可能需要在系统偏好设置中允许运行"
        echo ""
        echo "### 系统要求"
        echo ""
        echo "- macOS 14.0 或更高版本"
        echo "- Intel 或 Apple Silicon 处理器"
        echo ""
        echo "5. 上传 build/dmg/NavicatMac-$(date +%Y%m%d).dmg 文件"
        echo "6. 点击 'Publish release'"
    fi
}

# 主函数
main() {
    print_info "NavicatMac Release脚本"
    
    # 检查Git状态
    check_git_status
    
    # 获取版本号
    local version=$(get_version)
    print_info "当前版本: $version"
    
    # 生成变更日志
    print_info "生成变更日志..."
    local changelog=$(generate_changelog "$version")
    
    # 创建Release
    create_release "$version" "$changelog"
}

# 运行主函数
main "$@"