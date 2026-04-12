# 智能合约权限控制漏洞实验 (T3_AccessControl)

本实验旨在利用 **Echidna** 模糊测试工具，对三个具有典型权限控制漏洞的智能合约进行自动化漏洞检测与验证。

## 📊 实验结果概览

实验成功集齐了针对三个漏洞合约的测试报告，证明所有预设漏洞均能被现代 Fuzzing 工具捕捉：

| **合约名称**    | **漏洞类型**         | **Echidna 状态**       | **关键攻击路径**          |
| --------------- | -------------------- | ---------------------- | ------------------------- |
| **Phishable**   | `tx.origin` 鉴权风险 | **FAILED!** (成功篡夺) | `withdrawAll(0x0)`        |
| **Rubixi**      | 构造函数名拼写错误   | **FAILED!** (权限沦陷) | `checkAccess()`           |
| **Unprotected** | 缺少权限修饰符       | **FAILED!** (任意调用) | `checkVulnerability(0x0)` |

------

## 🛠️ 环境配置

- 

  **编译器版本**: `solc 0.4.25` (利用其向上兼容性处理 0.4.x 旧语法) 

  

  

- **测试工具**: `Echidna 2.3.1`

- **核心配置**:

  - 针对 Non-payable 合约需禁用初始余额打钱，防止部署失败。
  - `testMode: property`
  - `seqLen: 100` (确保足够长的指令序列以触发逻辑漏洞)

------

## 🔍 详细实验分析

### 1. Phishable - 鉴权钓鱼漏洞

- **漏洞原理**: 合约错误地使用 `tx.origin` 来验证调用者身份。攻击者可以诱导合约 Owner 调用攻击合约，从而通过钓鱼手段以 Owner 的身份转移资金。

- 

  **测试结论**: Echidna 成功通过 `withdrawAll` 函数清空了模拟合约的资金 。

  

  

- **报告文件**: `phishable_result.txt`

### 2. Rubixi - 伪构造函数漏洞

- **漏洞原理**: 合约在更名后未能正确修改构造函数名（`DynamicPyramid`）。导致该函数变成了一个普通的公开函数，任何人都可以调用它重新成为合约的 `owner`。

- 

  **测试结论**: Echidna 识别并执行了 `DynamicPyramid` 序列，成功通过探测函数 `checkAccess()` 捕获到了 Owner 权限的变更 。

  

  

- **报告文件**: `rubixi_result.txt`

### 3. Unprotected - 权限控制缺失

- **漏洞原理**: `changeOwner` 函数完全没有设置任何访问控制（如 `onlyOwner` 修饰符），导致逻辑完全“裸奔”，攻击者可以随意修改管理权限。

- 

  **测试结论**: Echidna 仅用 404 次调用即触发漏洞 。它通过调用封装的探测函数 `checkVulnerability` 证明了可以直接修改 `owner` 地址。

  

  

- **报告文件**: `unprotected_result.txt`

------

## 🚀 如何运行

1. **进入实验目录**:

   Bash

   ```
   cd /share/contracts_wrapped/T3_Logic_AccessControl
   ```

2. **执行自动化测试**:

   Bash

   ```
   # 以 Rubixi 为例
   echidna Test_rubixi.sol --contract TestRubixi --config config_rubixi.yaml
   ```

3. **查看结果**: 测试结果将实时显示在终端，并可导出的文本文件存放在 `/share/results/T3_AccessControl/` 路径下 。

   

   

------

## 💡 实验总结

通过本次实验，我们验证了 **Echidna** 在处理旧版本 Solidity 合约逻辑漏洞时的强大性能。实验的关键难点在于适配 `solc` 版本以及通过“逻辑探测器”模式绕过 `private` 变量的读取限制，从而在不修改原始漏洞源码的前提下，实现精准的自动化安全审计。