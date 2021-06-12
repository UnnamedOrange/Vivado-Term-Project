import numpy as np
import librosa

g_basic_timing = 109  # 基础速度。
g_timing = []  # [时间点, 速度]
g_timing_final = []

if __name__ == '__main__':
    sound, sample_rate = librosa.load('audio.mp3', 44100)
    length_in_milli = sound.shape[0] * 1000 // 44100
    print('歌曲长度为 %d 毫秒' % length_in_milli)

    # 解析 osu 谱面文件。
    with open('beatmap.osu', 'r') as file:
        lines = file.read().split('\n')
    print('报告：谱面文件共 %d 行' % len(lines))

    for i in range(len(lines)):
        if (lines[i] == '[TimingPoints]'):
            break
    i += 1

    original_timing = []
    while lines[i] != '':
        original_timing.append(lines[i])
        i += 1
    original_timing = (x.split(',') for x in original_timing)
    original_timing = [[int(float(x[0])), float(x[1])]
                       for x in original_timing]  # [时间点，速率]

    original_timing[0][0] = 0
    first_bpm = original_timing[0][1]  # 第一个 BPM，单位为毫秒每拍。

    current_bpm = 0  # 当前 BPM，单位为毫秒每拍。
    g_timing = []
    for i in range(len(original_timing)):
        if (original_timing[i][1] > 0):
            current_bpm = original_timing[i][1]
        g_timing.append([original_timing[i][0],
                         round(g_basic_timing * ((first_bpm / original_timing[i][1])
                                                 if original_timing[i][1] > 0 else
                                                 ((first_bpm / current_bpm) / (-original_timing[i][1] / 100))))])
    # 限制速度的范围。
    for i in range(len(g_timing)):
        g_timing[i][1] = max(1, min(4095, g_timing[i][1]))

    # 删除相同时间点。
    final_timing = []
    for i in range(len(g_timing)):
        if i + 1 < len(g_timing) and g_timing[i][0] == g_timing[i + 1][0]:
            continue
        final_timing.append(g_timing[i])
    g_timing = final_timing
    final_timing = []
    for i in range(len(g_timing)):
        if final_timing and final_timing[-1][1] == g_timing[i][1]:
            continue
        final_timing.append(g_timing[i])
    g_timing = final_timing
    del final_timing

    print('报告：时间点占用 %d / 4094 个' % len(g_timing))
    if len(g_timing) > 4094:
        print('错误：时间点超过数量限制')
        exit()

    # 构建 timing。
    g_timing_final.append(len(g_timing))
    g_timing_final.append(length_in_milli)
    for i in range(len(g_timing)):
        g_timing_final.append((g_timing[i][1] << 24) + g_timing[i][0])
    g_timing_final = b''.join(x.to_bytes(
        4, byteorder='little', signed=False) for x in g_timing_final)
    print('报告：.timing 文件大小为 %d 字节' % len(g_timing_final))

    # 写文件。
    with open('.timing', 'wb') as file:
        file.write(g_timing_final)
