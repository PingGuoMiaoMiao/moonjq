# 🌙 MoonJQ: MoonBit JSON Query Tool

[English](README.md) | [简体中文](README_zh_CN.md)

[![Build Status](https://img.shields.io/github/actions/workflow/status/PingGuoMiaoMiao/moonjq/check.yaml)](https://github.com/PingGuoMiaoMiao/moonjq/actions)
[![License](https://img.shields.io/github/license/PingGuoMiaoMiao/moonjq)](LICENSE)

🚀 **主要功能**

- 📊 **JSON 解析** - 高效的 JSON 数据解析和验证
- 🔍 **查询筛选** - 支持复杂的 JSON 查询和过滤操作
- 🔄 **管道操作** - 支持多级管道组合处理
- ⚡ **高性能** - 基于 MoonBit 的高性能实现
- 🛠️ **CLI 工具** - 完整的命令行交互界面

## 📥 安装

```bash
# 克隆项目
git clone https://github.com/PingGuoMiaoMiao/moonjq.git
cd moonjq
```

```bash
# 安装依赖
moon install
```

## 🏃 快速开始

```bash
# 基本查询
moon run cmd/main ".name" data.json

# 数组操作
moon run cmd/main ".[0].name" data.json

# 管道操作
moon run cmd/main ".users | .[0] | .name" data.json
```

## ⚙️ 参数说明

| 参数 | 说明 | 示例值 |
|------|------|--------|
| query | jq 查询表达式 | `.name`, `.[0]`, `.users[]` |
| file | JSON 文件路径 | `data.json` |

## 🔍 支持的操作

### 基本操作
- **字段访问**: `.field`, `.field.subfield`
- **数组索引**: `.[index]`, `.[-1]`
- **数组切片**: `.[start:end]`
- **数组迭代**: `.[]`
- **对象迭代**: `.[]`

### 高级操作
- **管道操作**: `|`
- **条件语句**: `if-then-else`
- **变量绑定**: `as $var`
- **可选操作**: `.field?`, `.[]?`
- **默认值**: `//`
- **错误处理**: `try-catch`

### 内置函数
- **数组操作**: `keys`, `values`, `has`, `length`
- **数学函数**: `sqrt`, `floor`, `abs`
- **字符串操作**: `trim`, `split`, `join`
- **排序函数**: `sort`, `unique`
- **过滤函数**: `select`, `map`

## 🛠️ 高级用法

```bash
# 复杂查询
moon run cmd/main ".users | select(.age > 18) | .name" data.json

# 数组操作
moon run cmd/main ".users | map(.name)" data.json

# 条件查询
moon run cmd/main "if .age > 18 then .name else \"未成年\" end" data.json

# 变量绑定
moon run cmd/main ".users as $users | $users[0].name" data.json
```

## ⚠️ 已知限制

### 🚧 尚未完成的功能

#### 1. 解析器重构
- **当前状态**: 使用手写解析器
- **待完成**: 使用 moonlex 和 moonyacc 重构解析器
- **影响**: 解析性能和可维护性

#### 2. 文档完善
- **当前状态**: 基础文档
- **待完成**: 
  - 详细的 API 文档
  - 完整的示例代码
  - 性能基准测试
  - 最佳实践指南

#### 3. 测试用例
- **当前状态**: 基础测试
- **待完成**:
  - 完整的单元测试
  - 集成测试
  - 性能测试
  - 兼容性测试

#### 4. 开源发布
- **当前状态**: 本地开发
- **待完成**:
  - 发布到 Mooncakes
  - 建立 CI/CD 流程
  - 社区贡献指南
  - 版本管理

#### 5. 高级功能
- **待完成**:
  - 正则表达式支持
  - 递归查询 (`..`)
  - 流式处理
  - 自定义函数定义
  - 模块系统

#### 6. 性能优化
- **待完成**:
  - 大文件处理优化
  - 内存使用优化
  - 并行处理支持
  - 缓存机制

## 🔧 开发计划

### 短期目标 (1-2 周)
- [ ] 使用 moonlex/moonyacc 重构解析器
- [ ] 完善基础文档
- [ ] 添加核心功能测试

### 中期目标 (1 个月)
- [ ] 完成所有测试用例
- [ ] 性能优化
- [ ] 发布到 Mooncakes

### 长期目标 (3 个月)
- [ ] 高级功能实现
- [ ] 社区建设
- [ ] 持续维护

## 📊 示例

### 输入 JSON
```json
{
  "users": [
    {"name": "Alice", "age": 30, "city": "New York"},
    {"name": "Bob", "age": 25, "city": "London"},
    {"name": "Charlie", "age": 35, "city": "Tokyo"}
  ],
  "metadata": {
    "version": "1.0",
    "created": "2024-01-01"
  }
}
```

### 查询示例
```bash
# 获取所有用户名
moon run cmd/main ".users[].name" data.json

# 筛选成年用户
moon run cmd/main ".users | select(.age >= 18) | .name" data.json

# 计算平均年龄
moon run cmd/main ".users | map(.age) | add / length" data.json
```

## 🐛 问题反馈

如果您遇到问题，请通过以下方式联系：

- 📧 **邮箱**: 3226742838@qq.com
- 🐛 **GitHub Issues**: [提交问题](https://github.com/PingGuoMiaoMiao/moonjq/issues)

## 💡 提示

使用 `--help` 参数查看详细帮助：
```bash
moon run cmd/main --help
```

## 📜 许可证

本项目采用 Apache 2.0 许可证。详见 [LICENSE](LICENSE) 文件。

## 🤝 贡献

我们欢迎社区贡献！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何参与。

## 👋 致谢

感谢所有为 MoonJQ 项目做出贡献的开发者！

如果这个项目对您有帮助，请给我们一个 ⭐！Happy coding! 🚀
