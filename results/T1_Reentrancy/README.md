# 智能合约重入漏洞检测实验 (T1 - Reentrancy)

## 1. 实验背景

本项目旨在利用属性测试工具 **Echidna**，对 5 种典型的以太坊智能合约重入漏洞场景进行自动化检测。通过编写特定的不变性属性（Invariants），验证合约在面对重入攻击时是否能保持资产安全。

## 2. 实验环境

- **测试工具**: Echidna (v2.2.3 或更高)
- **编译器**: `solc-select` (支持 0.4.25 与 0.5.0 版本切换)
- **运行环境**: Docker / Linux 终端

## 3. 测试目录结构

Plaintext

```
.
├── benchmark/T1_Reentrancy/       # 原始漏洞合约
├── contracts_wrapped/             # 封装了 echidna_test 属性的测试合约
├── scripts/                       # 自动化运行脚本
└── results/T1_Reentrancy/         # 本次生成的测试结果 (JSON 格式)
```

## 4. 核心测试逻辑

每个测试合约（如 `Test_etherstore.sol`）都继承自原始漏洞合约，并包含一个关键的属性检查函数：

Solidity

```
function echidna_test_reentrancy() public view returns (bool) {
    // 属性：合约余额不应被异常清空
    return address(this).balance > 0;
}
```

## 5. 实验结果汇总

以下是本次运行的 5 个测试用例的结果统计：

| 漏洞合约文件               | 编译器版本 | 测试状态      | 漏洞检测结果 | 风险点说明                            |
| -------------------------- | ---------- | ------------- | ------------ | ------------------------------------- |
| `etherstore.json`          | 0.4.25     | **Falsified** | ✅ 发现漏洞   | 经典的转账前未更新余额漏洞            |
| `reentrancy_dao.json`      | 0.4.25     | **Falsified** | ✅ 发现漏洞   | 模拟 The DAO 攻击的 fallback 递归调用 |
| `modifier_reentrancy.json` | 0.4.25     | **Falsified** | ✅ 发现漏洞   | 绕过 Modifier 检查的重入攻击          |
| `reentrancy_cross_fn.json` | 0.4.25     | **Falsified** | ✅ 发现漏洞   | 两个不同函数间的状态竞争重入          |
| `reentrancy_insecure.json` | 0.5.0      | **Falsified** | ✅ 发现漏洞   | Solidity 0.5.x 语法下的重入漏洞检测   |

## 6. 结果分析与结论

1. **成功证伪 (Falsified)**：在所有测试用例中，Echidna 均报告了 `Test echidna_test_reentrancy falsified!`。这意味着工具成功找到了一组攻击序列（Call Sequence），导致合约余额被非法抽干，属性失效。
2. **版本兼容性**：实验证明通过 `solc-select` 切换环境，可以有效检测跨版本（0.4.x 和 0.5.x）的合约漏洞。
3. **覆盖率**：根据 JSON 日志显示，测试过程中的指令覆盖率（instr coverage）稳定，说明模糊测试已深入触达合约的转账逻辑。

**结论：T1 部分的 5 个重入漏洞样本已全部通过 Echidna 验证，实验成功。**