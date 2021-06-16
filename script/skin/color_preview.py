# Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
# See the LICENSE file in the repository root for full license text.

import numpy as np
from PIL import Image

if __name__ == '__main__':
    width = 10
    image = np.zeros((256 * width, 16 * width, 3), dtype=np.uint8)
    i, j = 0, 0
    for b in range(16):
        for g in range(16):
            for r in range(16):
                image[i * width: (i + 1) * width, j *
                      width: (j + 1) * width, 0] = r << 4
                image[i * width: (i + 1) * width, j *
                      width: (j + 1) * width, 1] = g << 4
                image[i * width: (i + 1) * width, j *
                      width: (j + 1) * width, 2] = b << 4
                j += 1
                if j >= 16:
                    j = 0
                    i += 1
    Image.fromarray(image).save('color_preview.png')
