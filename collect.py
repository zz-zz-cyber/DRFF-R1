import uhd
import numpy as np
from scipy.io import savemat
from datetime import datetime
import time
import os

# ================= 硬件配置参数 =================
center_freq = 5745e6  # 5.745 GHz
sample_rate = 40e6  # 采样率
gain = 30  # 接收增益
rx_antenna = "TX/RX"  # B210天线端口

# ================= 采集参数 =====================
total_samples = int(1.4e8)  # 1.2亿样本
buffer_size = 4096  # 接收缓冲区大小
# ================= 设备初始化 ===================
def init_usrp():
    usrp = uhd.usrp.MultiUSRP("type=b200")

    usrp.set_rx_rate(sample_rate, 0)
    usrp.set_rx_freq(uhd.libpyuhd.types.tune_request(center_freq), 0)
    usrp.set_rx_gain(gain, 0)
    usrp.set_rx_antenna(rx_antenna, 0)

    stream_args = uhd.usrp.StreamArgs("fc32", "sc16")
    stream_args.channels = [0]
    return usrp, usrp.get_rx_stream(stream_args)

# ================= 主采集流程 ====================
def main():
    # 初始化设备
    usrp, rx_stream = init_usrp()

    save_dir = r"E:\dataset"
    os.makedirs(save_dir, exist_ok=True)

    full_i = np.zeros(total_samples, dtype=np.float32)
    full_q = np.zeros(total_samples, dtype=np.float32)

    recv_buffer = np.zeros((1, buffer_size), dtype=np.complex64)
    metadata = uhd.types.RXMetadata()

    rx_stream.issue_stream_cmd(
        uhd.types.StreamCMD(uhd.types.StreamMode.start_cont))
    print(f"开始采集，目标样本数：{total_samples}")

    try:
        collected = 0
        write_index = 0

        while collected < total_samples:
            num_samps = rx_stream.recv(recv_buffer, metadata)
            if num_samps == 0: continue
            remaining = total_samples - collected
            valid_samps = min(num_samps, remaining)
            samples = recv_buffer[0, :valid_samps]
            end_index = write_index + valid_samps
            full_i[write_index:end_index] = np.real(samples).astype(np.float32)
            full_q[write_index:end_index] = np.imag(samples).astype(np.float32)
            collected += valid_samps
            write_index = end_index
            print(f"\r进度：{collected / total_samples * 100:.2f}%", end="")

    except KeyboardInterrupt:
        print("\n用户中断采集...")
    finally:
        rx_stream.issue_stream_cmd(
            uhd.types.StreamCMD(uhd.types.StreamMode.stop_cont))
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = os.path.join(save_dir, f"DRONE_RF_FULL_{timestamp}.mat")
        savemat(filename, {
            "RF0_I": full_i[:collected],
            "RF0_Q": full_q[:collected],
            "Fs": sample_rate,
            "CenterFreq": center_freq
        })
        print(f"\n已保存文件：{filename} (样本数：{collected})")


if __name__ == "__main__":
    main()
