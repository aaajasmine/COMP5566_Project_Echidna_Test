# 智能合约未检查调用漏洞实验 (T4_UncheckedCalls)

本实验利用 **Echidna** 验证了 Solidity 中底层调用（`send`/`call`）返回值未检查所导致的逻辑风险。

## 📊 实验结果总结

| **合约名称**         | **漏洞函数**        | **失败后果**                           | **状态**   |
| -------------------- | ------------------- | -------------------------------------- | ---------- |
| **mishandled**       | `withdrawBalance`   | 用户余额清零但资金转账失败（资金锁死） | **FAILED** |
| **unchecked_return** | `callnotchecked`    | 目标地址调用失败但合约状态照常修改     | **FAILED** |
| **lotto**            | `sendToWinner`      | 中奖者未收到钱但合约标记为已支付       | **FAILED** |
| **etherpot_lotto**   | `fallback (refund)` | 找零失败但买票流程继续执行             | **FAILED** |
| **KingOfTheEther**   | `claimThrone`       | 前任国王补偿款丢失，逻辑在失败中继续   | **FAILED** |

------

## 🔍 核心实验发现

1. **底层调用的陷阱**：在 Solidity 0.4.x 时代，`send` 和 `call` 在失败时不会抛出异常，而是返回 `false`。
2. **静默失败检测**：我们通过构造 **MaliciousReceiver**（在 `fallback` 函数中 `revert`）来强制触发底层调用失败。
3. **状态不一致性**：实验证明，由于缺乏 `require(c.send(a))` 这种检查，合约会出现“钱没动，账已平”的严重逻辑错误。

## 🛠️ 测试配置说明

- **编译器**: `solc 0.4.25`
- **关键配置**: 必须为测试合约的构造函数添加 `payable` 修饰符，以适配 `balanceContract` 的初始资金注入，否则会导致部署失败。