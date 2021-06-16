# Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
# See the LICENSE file in the repository root for full license text.

from pathlib import WindowsPath
import numpy as np
from PIL import Image
from numpy.core.fromnumeric import shape

filenames = [
    '0.png',
    '1.png',
    '2.png',
    '3.png',
    '4.png',
    '5.png',
    '6.png',
    '7.png',
    '8.png',
    '9.png',
    'perfect.png',
    'great.png',
    'good.png',
    'bad.png',
    'miss.png',
    'click.png',
    'slide_begin.png',
    'slide_begin_discarded.png',
    'slide_end.png',
    'slide_end_discarded.png',
    'slide_space.png',
    'slide_space_discarded.png',
    'key_down.png',
    'key_up.png',
]

pic_shape = [(24, 20)] * 10 + [(24, 64)] * 5 + [(36, 60)] + \
    [(18, 60)] * 4 + [(1, 60)] * 2 + [(60, 60)] * 2

g_skin_stream = []
g_skin_stream_final = []

if __name__ == '__main__':
    assert len(filenames) == len(pic_shape), "长度应该相同。"
    for i in range(len(filenames)):
        try:
            origin = Image.open(filenames[i])
        except FileNotFoundError:
            print('警告：没有文件 %s，使用全白色代替' % filenames[i])
            g_skin_stream += [(15, 15, 15)] * \
                (pic_shape[i][0] * pic_shape[i][1])
            continue

        origin = np.asarray(origin)
        if not (len(origin.shape) == 3 and origin.shape[2] == 3):
            print('警告：文件 %s 格式错误，使用全白色代替' % filenames[i])
            g_skin_stream += [(15, 15, 15)] * \
                (pic_shape[i][0] * pic_shape[i][1])
            continue
        if origin.shape[0] != pic_shape[i][0] or origin.shape[1] != pic_shape[i][1]:
            print('警告：图片 %s 尺寸错误，使用全白色代替' % filenames[i])
            g_skin_stream += [(15, 15, 15)] * \
                (pic_shape[i][0] * pic_shape[i][1])
            continue

        for j in range(origin.shape[0]):
            for k in range(origin.shape[1]):
                g_skin_stream.append(
                    (int(origin[j, k, 0]) >> 4, int(origin[j, k, 1]) >> 4, int(origin[j, k, 2]) >> 4))

    for i in range(len(g_skin_stream)):
        g_skin_stream_final.append(
            g_skin_stream[i][0] + (g_skin_stream[i][1] << 4) + (g_skin_stream[i][2] << 8))
    g_skin_stream_final = b''.join(x.to_bytes(
        2, byteorder='little', signed=False) for x in g_skin_stream_final)
    print('报告：.skin 占用空间 %d 字节' % len(g_skin_stream_final))

    # 保存文件。
    with open('.skin', 'wb') as file:
        file.write(g_skin_stream_final)
