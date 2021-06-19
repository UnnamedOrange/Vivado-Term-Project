#include "PmodSD.h"
#include "xil_cache.h"
#include "loop.h"

void run()
{
	loop_t<u8> loop1(XPAR_CPU_DATA_TRANSMITTER_0_S00_AXI_BASEADDR);
	loop_t<u8> loop2(XPAR_CPU_DATA_TRANSMITTER_1_S00_AXI_BASEADDR);
	bool flag = true;
	while (flag)
	{
		flag &= loop1.loop();
		flag &= loop2.loop();
	}
}

int main()
{
   Xil_ICacheEnable();
   Xil_DCacheEnable();
   DXSPISDVOL disk(XPAR_PMODSD_0_AXI_LITE_SPI_BASEADDR,
         XPAR_PMODSD_0_AXI_LITE_SDCS_BASEADDR);
   DFATFS::fsmount(disk, "0:", 1);

   run();
}
