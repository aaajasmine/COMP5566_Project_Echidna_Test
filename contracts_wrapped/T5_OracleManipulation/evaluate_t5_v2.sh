#!/bin/bash

# 1. 初始化目录
RESULT_DIR="/share/results/T5_Evaluation_V2"
mkdir -p $RESULT_DIR
cd /share/contracts_wrapped/T5_OracleManipulation

echo "=== 正在准备 T5 编译器环境 ==="
# 强制安装缺失的版本
solc-select install 0.8.19 0.8.28 0.8.7 0.6.12

echo "=== 开始 T5 针对性评估 ==="

# --- 案例 A: 预言机类 (Moonwell, UwULend) ---
echo "[1/2] 评估预言机逻辑: Moonwell/UwULend..."
solc-select use 0.8.19
cat << 'EOT' > T5_Oracle_Wrap.sol
import "./moonwell_vuln.sol";
contract EchidnaTest is ChainlinkOracle {
    constructor() { admin = msg.sender; }
    // 评估属性：非管理员不应能篡改价格
    function echidna_no_unauthorized_price() public view returns (bool) {
        return true; // 这是一个占位，实际漏洞在于 setDirectPrice 缺乏 onlyOwner
    }
    // 评估属性：价格不应被设置为 0 (模拟恶意脱锚)
    function echidna_price_not_zero() public view returns (bool) {
        return getAssetPrice(address(0x1)) != 0;
    }
}
EOT
echidna T5_Oracle_Wrap.sol --contract EchidnaTest --config config_t5.yaml --format text > "$RESULT_DIR/moonwell_report.txt" 2>&1

# --- 案例 B: 内存安全类 (Makina Machine) ---
echo "[2/2] 评估底层内存安全: Makina Machine..."
solc-select use 0.8.28
cat << 'EOT' > T5_Machine_Wrap.sol
import "./makina_machine_vuln.sol";
contract EchidnaTest is Machine {
    uint256[] public data;
    constructor() { data.push(100); }
    // 评估属性：writeUnchecked 不应篡改非目标区域的内存
    function test_write(uint256 idx, uint256 val) public {
        writeUnchecked(data, idx, val);
    }
    function echidna_array_integrity() public view returns (bool) {
        return data.length == 1 && data[0] == 100;
    }
}
EOT
echidna T5_Machine_Wrap.sol --contract EchidnaTest --config config_t5.yaml --format text > "$RESULT_DIR/makina_report.txt" 2>&1

echo "=== 评估结束 ==="
grep "FAILED" $RESULT_DIR/*.txt && echo "结果：发现漏洞！" || echo "结果：未发现漏洞，需调整 Invariant。"
