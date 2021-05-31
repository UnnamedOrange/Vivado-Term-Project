// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT Licence.
// See the LICENSE file in the repository root for full licence text.

#ifndef LOOP_H
#define LOOP_H

#include "xil_io.h"

template <typename data_t, size_t buf_size>
class loop_t
{
	static constexpr size_t buf_size_mask = buf_size - 1;

	UINTPTR base_addr;
	data_t buf[buf_size];
	const data_t *buf_addr = buf;
	size_t st{}, ed{};
	u32 file_size{};
	u32 total_read{};

	bool inited{};
	u8 init_index{};
	u8 init_aux_info{};
	DFILE file;
	bool finished{};

public:
	loop_t(UINTPTR base_addr) : base_addr(base_addr), buf()
	{
		static_assert((buf_size & (-buf_size)) == buf_size,
					  "buf_size should be 2 to the power of n.");
		static_assert(buf_size * sizeof(data_t) <= 512,
					  "The stack space is limited!");
	}

	void loop()
	{
		u32 status = Xil_In32(base_addr + 12);
		if (!inited)
		{
			init_index = status & 255;
			init_aux_info = (status >> 8) & 255;
			auto temp_index = init_index;
			char filename[16];
			size_t length = 0;
			do
			{
				filename[length++] = temp_index % 10 + '0';
			} while (temp_index /= 10);
			for (size_t i = 0, j = length - 1; i < j; i++, j--)
			{
				char t = filename[i];
				filename[i] = filename[j];
				filename[j] = t;
			}
			filename[length++] = '.';

			constexpr const char *names[2] =
				{".song", ".beatmap"};
			constexpr size_t lengths[2] =
				{5, 8};
			const char *name = names[init_aux_info];
			for (size_t i = 0; i < lengths[init_aux_info]; i++)
				filename[length++] = name[i];
			filename[length] = 0;

			file.fsopen(filename, FA_READ);
			file_size = file.fssize();

			inited = true;
		}
		else
		{
			if (!finished)
			{
				if (buf_size - ((buf_size + ed - st) & buf_size_mask) > 1)
				{
					u32 read;
					file.fsread(buf + ed, sizeof(data_t), &read);
					ed = (ed + 1) & buf_size_mask;
				}

				if (st != ed && (status & (1 << 31)))
				{
					total_read += sizeof(data_t);
					Xil_Out32(base_addr, buf[st]);
					finished = total_read == file_size;
					Xil_Out32(base_addr + 12, total_read | (1 << 31) | (finished << 28));
					st = (st + 1) & buf_size_mask;
				}
			}
		}
	}
};

#endif LOOP_H