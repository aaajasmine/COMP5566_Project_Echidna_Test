import os
import subprocess

# ================= 配置路径 =================
BASE_DIR = "/share"
CATEGORY = "T1_Reentrancy"
DATASET_DIR = os.path.join(BASE_DIR, "benchmark", CATEGORY)
WRAPPED_DIR = os.path.join(BASE_DIR, "contracts_wrapped", CATEGORY)
RESULTS_DIR = os.path.join(BASE_DIR, "results", CATEGORY)

os.makedirs(WRAPPED_DIR, exist_ok=True)
os.makedirs(RESULTS_DIR, exist_ok=True)

# 0.5.0 版本的模板
TEMPLATE = """
pragma solidity ^0.5.0;
import "../../benchmark/{category}/{original_file}";

contract EchidnaTest is Reentrancy_insecure {{
    constructor() public payable {{}}

    function echidna_test_reentrancy() public view returns (bool) {{
        // 判定：余额不应被抽干
        return address(this).balance > 0;
    }}
}}
"""

def run_tests():
    print("--- 开始测试 0.5.0 系列合约 ---")
    subprocess.run("solc-select install 0.5.0", shell=True)
    
    filename = "reentrancy_insecure.sol"
    wrapped_file = os.path.join(WRAPPED_DIR, f"Test_{filename}")
    
    with open(wrapped_file, "w") as f:
        f.write(TEMPLATE.format(category=CATEGORY, original_file=filename))

    print(f"🚀 正在测试: {filename}...")
    result_json = os.path.join(RESULTS_DIR, filename.replace(".sol", ".json"))
    
    # 强制切换到 0.5.0 并执行
    cmd = (f"solc-select use 0.5.0 && "
           f"echidna {wrapped_file} --contract EchidnaTest "
           f"--solc-args '--allow-paths {BASE_DIR}' "
           f"--format json --test-limit 50000")
    
    with open(result_json, "w") as out:
        subprocess.run(cmd, shell=True, stdout=out, stderr=subprocess.STDOUT)
    print(f"✅ 完成: {filename}")

if __name__ == "__main__":
    run_tests()