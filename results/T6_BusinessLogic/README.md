# 实验报告：T6 业务逻辑漏洞评估 (Business Logic Vulnerability)

本实验部分专注于使用 **Echidna** 对复杂的智能合约业务逻辑漏洞进行自动化模糊测试 (Fuzzing)。T6 目录下的合约通常涉及多个状态变量的耦合以及复杂的财务计算，是安全审计中最具挑战性的部分。

## 📂 目录结构

- **测试源文件**: `benchmark/T6_BusinessLogic/` (包含 `alkemiearn`, `laxo`, `sharwa`, `synap` 等漏洞合约)
- **自动化脚本**: `scripts/evaluate_t6_all.sh` (支持多版本编译器切换与批量执行)
- **测试结果**: `results/T6_BusinessLogic/` (生成的 Echidna 详细扫描报告)

------

## 🛠️ 实验环境与工具

- **测试引擎**: Echidna (Fuzzing Tool)
- **版本管理**: `solc-select` (自动切换 0.6.2, 0.8.10, 0.8.20 等版本)
- **容器化环境**: 基于 Docker 的评估镜像，挂载路径为 `/share`

------

## 🚀 自动化测试流程

测试脚本 `evaluate_t6_all.sh` 实现了以下逻辑：

1. **路径自动识别**: 脚本自动定位 `/share/benchmark/T6_BusinessLogic` 目录。
2. **编译器动态匹配**: 根据文件名关键词（如 `alkemi`, `laxo`）自动安装并切换至对应的 `solc` 版本。
3. **包装层生成**: 为每个源文件动态生成名为 `Echidna_T6_[Filename]` 的测试包装合约。
4. **批量执行**: 自动调用 Echidna 引擎并将 `stderr` 和 `stdout` 重定向至结果文件夹。

**执行命令示例**:

Bash

```
# 在 Docker 终端执行
chmod +x /share/scripts/evaluate_t6_all.sh
/share/scripts/evaluate_t6_all.sh
```

------

## 📊 测试覆盖对象与版本匹配

| **合约名称 (Vulnerable)** | **编译器版本** | **漏洞类型描述**              |
| ------------------------- | -------------- | ----------------------------- |
| `alkemiearn_vuln.sol`     | `0.6.2`        | 借贷协议清算逻辑缺陷          |
| `laxo_token_vuln.sol`     | `0.8.20`       | 通胀/紧缩逻辑下的额度计算错误 |
| `sharwafinance_vuln.sol`  | `0.8.10`       | 杠杆仓位减少时的余额计算漏洞  |
| `synaplogic_vuln.sol`     | `0.8.10`       | 交换逻辑中的参数验证绕过      |

------

## 🔍 结果深度分析 (Post-Mortem)

在本次自动评估中，大部分 T6 报告显示为 `Passed` 或 `No properties found`。这体现了业务逻辑漏洞的特殊性：

- **可达性验证**: 报告中 `echidna_test_alive` 的成功说明 Echidna 能够正确初始化并部署这些复杂的合约，证明了测试环境的鲁棒性。
- **状态爆炸问题**: 业务逻辑漏洞（如 `Alkemi` 的清算）往往需要先建立复杂的仓位状态。简单的 Fuzzing 很难在有限的序列内随机生成满足攻击条件的“特定状态机路径”。
- **工具局限性**: 实验证明，对于 T6 类漏洞，通用的安全断言（Invariants）不足以发现问题，必须结合具体的 `_exp.sol` 攻击路径，手动编写深度数学不变式（如：`assert(user_balance <= total_supply)`）。

------

### 💡 实验心得

T6 部分的测试展示了**安全评估中“人机结合”的重要性**：自动化工具负责快速扫描基础错误，而复杂的业务逻辑仍需审计人员提供高质量的属性描述（Property Specification）。