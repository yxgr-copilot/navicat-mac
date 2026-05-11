#!/bin/bash

# AGENTS.md维护脚本
# 用于检查和更新AGENTS.md文件

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    echo "AGENTS.md维护脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  -c, --check         检查AGENTS.md是否需要更新"
    echo "  -u, --update        更新AGENTS.md中的待办事项"
    echo "  -s, --stats         显示项目统计信息"
    echo "  -a, --all           执行所有检查和更新"
}

# 检查AGENTS.md是否需要更新
check_agents_md() {
    print_info "检查AGENTS.md..."
    
    local agents_file="AGENTS.md"
    local needs_update=false
    
    if [ ! -f "$agents_file" ]; then
        print_error "AGENTS.md不存在"
        return 1
    fi
    
    # 检查最后更新日期
    local last_update=$(grep "^\*\*最后更新\*\*:" "$agents_file" | cut -d' ' -f2)
    if [ -n "$last_update" ]; then
        print_info "最后更新日期: $last_update"
        
        # 检查是否超过7天
        local last_update_ts=$(date -j -f "%Y-%m-%d" "$last_update" "+%s" 2>/dev/null || echo "0")
        local current_ts=$(date "+%s")
        local days_diff=$(( (current_ts - last_update_ts) / 86400 ))
        
        if [ $days_diff -gt 7 ]; then
            print_warning "AGENTS.md已超过7天未更新"
            needs_update=true
        fi
    fi
    
    # 检查是否有新的Swift文件
    local swift_files=$(find NavicatMac -name "*.swift" -type f | wc -l | tr -d ' ')
    local agents_swift_refs=$(grep -c "\.swift" "$agents_file" || echo "0")
    
    if [ "$swift_files" -gt "$((agents_swift_refs / 2))" ]; then
        print_warning "发现新的Swift文件，可能需要更新项目结构"
        needs_update=true
    fi
    
    # 检查待办事项
    local todo_count=$(grep -c "\- \[ \]" "$agents_file" || echo "0")
    local done_count=$(grep -c "\- \[x\]" "$agents_file" || echo "0")
    
    print_info "待办事项: $todo_count 个未完成, $done_count 个已完成"
    
    if [ "$needs_update" = true ]; then
        print_warning "AGENTS.md需要更新"
        return 1
    else
        print_success "AGENTS.md是最新的"
        return 0
    fi
}

# 更新AGENTS.md中的待办事项
update_todo_list() {
    print_info "更新待办事项列表..."
    
    local agents_file="AGENTS.md"
    
    # 检查已完成的功能
    local completed_features=()
    
    # 检查MySQL连接
    if grep -q "MySQLService" NavicatMac/Services/ConnectionManager.swift; then
        completed_features+=("MySQL连接基础框架")
    fi
    
    # 检查SQL编辑器
    if grep -q "QueryEditorView" NavicatMac/Views/Content/QueryEditorView.swift; then
        completed_features+=("SQL编辑器基础框架")
    fi
    
    # 检查导入导出
    if grep -q "ImportExportWizard" NavicatMac/Views/Dialogs/ImportExportWizard.swift; then
        completed_features+=("导入导出基础框架")
    fi
    
    # 更新待办事项
    if [ ${#completed_features[@]} -gt 0 ]; then
        print_info "已完成功能:"
        for feature in "${completed_features[@]}"; do
            echo "  - $feature"
        done
    fi
}

# 显示项目统计信息
show_stats() {
    print_info "项目统计信息"
    echo ""
    
    # Swift文件统计
    local swift_files=$(find NavicatMac -name "*.swift" -type f | wc -l | tr -d ' ')
    local swift_lines=$(find NavicatMac -name "*.swift" -type f -exec cat {} \; | wc -l | tr -d ' ')
    echo "Swift文件: $swift_files 个, $swift_lines 行"
    
    # 测试文件统计
    local test_files=$(find NavicatMacTests -name "*.swift" -type f | wc -l | tr -d ' ')
    local test_lines=$(find NavicatMacTests -name "*.swift" -type f -exec cat {} \; | wc -l | tr -d ' ')
    echo "测试文件: $test_files 个, $test_lines 行"
    
    # 文档统计
    local doc_files=$(find docs -name "*.md" -type f | wc -l | tr -d ' ')
    echo "文档文件: $doc_files 个"
    
    # Git统计
    local commit_count=$(git rev-list --count HEAD)
    local tag_count=$(git tag | wc -l | tr -d ' ')
    echo "Git提交: $commit_count 个"
    echo "Git标签: $tag_count 个"
    
    # Release统计
    echo ""
    print_info "GitHub Releases:"
    if [ -n "$GITHUB_TOKEN" ]; then
        curl -s -H "Authorization: token $GITHUB_TOKEN" \
            "https://api.github.com/repos/yxgr-copilot/navicat-mac/releases" | \
            grep -o '"tag_name":"[^"]*"' | cut -d'"' -f4 | while read tag; do
            echo "  - $tag"
        done
    else
        echo "  (需要GITHUB_TOKEN)"
    fi
}

# 更新最后更新日期
update_last_update_date() {
    local agents_file="AGENTS.md"
    local today=$(date +%Y-%m-%d)
    
    if [ -f "$agents_file" ]; then
        sed -i '' "s/^\*\*最后更新\*\*:.*/*\*最后更新\*\*: $today/" "$agents_file"
        print_success "更新最后更新日期为 $today"
    fi
}

# 主函数
main() {
    local check=false
    local update=false
    local stats=false
    local all=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--check)
                check=true
                shift
                ;;
            -u|--update)
                update=true
                shift
                ;;
            -s|--stats)
                stats=true
                shift
                ;;
            -a|--all)
                all=true
                shift
                ;;
            *)
                print_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 如果没有参数，显示帮助
    if [ "$check" = false ] && [ "$update" = false ] && [ "$stats" = false ] && [ "$all" = false ]; then
        show_help
        exit 0
    fi
    
    # 执行检查
    if [ "$check" = true ] || [ "$all" = true ]; then
        check_agents_md
    fi
    
    # 执行更新
    if [ "$update" = true ] || [ "$all" = true ]; then
        update_todo_list
        update_last_update_date
    fi
    
    # 显示统计
    if [ "$stats" = true ] || [ "$all" = true ]; then
        show_stats
    fi
}

# 运行主函数
main "$@"