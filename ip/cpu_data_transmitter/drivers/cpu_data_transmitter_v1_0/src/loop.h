// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT Licence.
// See the LICENSE file in the repository root for full licence text.

#ifndef LOOP_H
#define LOOP_H

#include "xil_io.h"

template <typename data_t>
class loop_t
{
	UINTPTR base_addr;
	u32 file_size{};
	u32 total_read{};

	bool inited{};
	u8 init_index{};
	u8 init_aux_info{};
	DFILE file;

public:
	loop_t(UINTPTR base_addr) : base_addr(base_addr)
	{
	}

	bool loop()
	{
		u32 status = Xil_In32(base_addr + 12);
		if (status & (1 << 31))
		{
			inited = false;
			file_size = 0;
			total_read = 0;
			if (file)
				file.fsclose();
			Xil_Out32(base_addr + 12, 0);
			return true;
		}
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
			filename[length++] = '/';

			constexpr const char *names[] =
				{".beatmap", ".object", ".pixel", ".timing", ".song", ".preview", ".skin"};
			constexpr size_t lengths[] =
				{8, 7, 6, 7, 5, 8, 5};
			constexpr size_t size_of_stock = sizeof(lengths) / sizeof(lengths[0]);
			size_t index = (init_aux_info & (1 << 7)) ? size_of_stock - 1 : init_aux_info;
			const char *name = names[index];
			if (init_aux_info & (1 << 7))
				length = 0;
			for (size_t i = 0; i < lengths[index]; i++)
				filename[length++] = name[i];
			filename[length] = 0;

			file.fsopen(filename, FA_READ);
			file_size = file.fssize();
			Xil_Out32(base_addr + 12, 0);

			inited = true;
		}
		else
		{
			if ((status & (1 << 30)) && total_read < file_size)
			{
				u32 read;
				data_t buf;
				file.fsread(&buf, sizeof(data_t), &read);
				total_read += read;
				Xil_Out32(base_addr, buf);
				Xil_Out32(base_addr + 12, total_read | (1 << 31) | ((total_read >= file_size) << 28));
			}
		}
		return true;
	}
};

#endif LOOP_H