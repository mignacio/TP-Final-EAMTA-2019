/*-----------------------------------------------------------------------------
-- Archivo       : fpga_p6.v
-- Organizacion  : Fundacion Fulgor 
-------------------------------------------------------------------------------
-- Descripcion   : Top level de implementacion
-------------------------------------------------------------------------------
-- Autor         : Ariel Pola
-------------------------------------------------------------------------------*/

`include "/home/apola/projects/cursodda/GuiaPractica06/rtl/top_board/fpga_files.v"

module fpga
  (
   out_leds_rgb0,
   out_leds_rgb1,
   out_leds_rgb2,
   out_leds_rgb3,
   out_leds,
   out_tx_uart,
   in_rx_uart,
   in_reset,
   clk100
   );

   ///////////////////////////////////////////
   // Parameter
   ///////////////////////////////////////////
   parameter NB_GPIOS              = `NB_GPIOS;
   parameter NB_LEDS               = `NB_LEDS;

   parameter NB_ENABLE_RX          = `NB_ENABLE_RX;
   parameter NB_ENABLE_TOTAL       = `NB_ENABLE_TOTAL;

   parameter NB_DATA_RAM_LOG       = `NB_DATA_RAM_LOG;
   parameter NB_ADDR_RAM_LOG       = `NB_ADDR_RAM_LOG;
   parameter NB_LOG_READ_DEVICES   = `NB_LOG_READ_DEVICES;
   parameter NB_DEVICES            = `NB_DEVICES;

   parameter INIT_FILE             = `INIT_FILE;

   ///////////////////////////////////////////
   // Ports
   ///////////////////////////////////////////
   output wire [NB_LEDS - 1 : 0]                     out_leds;
   output [3 - 1 : 0]                                out_leds_rgb0;
   output [3 - 1 : 0]                                out_leds_rgb1;
   output [3 - 1 : 0]                                out_leds_rgb2;
   output [3 - 1 : 0]                                out_leds_rgb3;

   output wire                                       out_tx_uart;
   input wire                                        in_rx_uart;
   input wire                                        in_reset;
   input                                             clk100;

   ///////////////////////////////////////////
   // Vars
   ///////////////////////////////////////////
   wire [NB_GPIOS                 - 1 : 0]           gpo0;
   wire [NB_GPIOS                 - 1 : 0]           gpi0;

   wire                                              locked;

   wire                                              enable0;
   wire                                              enable1;
   wire                                              enable2;
   wire                                              enable3;

   wire                                              soft_reset;

   wire [NB_GPIOS                 - 1 : 0]           rf_log_capture_data;

   wire [NB_ENABLE_TOTAL          - 1 : 0]           rf_enables_module;

   wire [(NB_DATA_RAM_LOG*2)      - 1 : 0]           log_data_from_ram;
   wire                                              log_out_full_from_ram;

   wire                                              log_in_ram_run_from_micro;
   wire [NB_ADDR_RAM_LOG          - 1 : 0]           log_read_addr_from_micro;
   wire                                              log_read_upper_low;
   wire [NB_DEVICES               - 1 : 0]           log_read_sel_device;

   wire [NB_LOG_READ_DEVICES      - 1 : 0]           log_read_devices;
   wire                                              clockdsp;

   ///////////////////////////////////////////
   // MicroBlaze
   ///////////////////////////////////////////
   // Instanciar el Micro
/* -----\/----- EXCLUDED -----\/-----
   design_1
     u_micro
       (.clock100         (clockdsp    ),  // Clock aplicacion
        .gpio_rtl_tri_o   (gpo0        ),  // GPIO
        .gpio_rtl_tri_i   (gpi0        ),  // GPIO
        .reset            (in_reset    ),  // Hard Reset
        .sys_clock        (clk100      ),  // Clock de FPGA
        .o_lock_clock     (locked      ),  // Senal Lock Clock
        .usb_uart_rxd     (in_rx_uart  ),  // UART
        .usb_uart_txd     (out_tx_uart )   // UART
        );
 -----/\----- EXCLUDED -----/\----- */

   ///////////////////////////////////////////
   // Leds
   ///////////////////////////////////////////
   assign out_leds[0] = locked;
   assign out_leds[1] = ~in_reset;
   assign out_leds[2] = soft_reset;
   assign out_leds[3] = log_out_full_from_ram & log_in_ram_run_from_micro;

   assign out_leds_rgb0[0] = enable0;
   assign out_leds_rgb0[1] = 1'b0;
   assign out_leds_rgb0[2] = 1'b0;

   assign out_leds_rgb1[0] = enable1;
   assign out_leds_rgb1[1] = 1'b0;
   assign out_leds_rgb1[2] = 1'b0;

   assign out_leds_rgb2[0] = 1'b0;
   assign out_leds_rgb2[1] = enable2;
   assign out_leds_rgb2[2] = 1'b0;

   assign out_leds_rgb3[0] = 1'b0;
   assign out_leds_rgb3[1] = 1'b0;
   assign out_leds_rgb3[2] = enable3;



   ///////////////////////////////////////////
   // Register File
   ///////////////////////////////////////////
   assign {enable3,
           enable2,
           enable1,
           enable0}              = rf_enables_module;

   assign {log_read_sel_device,
           log_read_upper_low,
           log_read_addr_from_micro} = log_read_devices;

   register_file
     u_register_file
       (
        .in_log_capture_data   (log_data_from_ram),
        .out_soft_reset        (soft_reset),
        .out_enables_module    (rf_enables_module),

        // Logs
        .log_ram_run_from_micro (log_in_ram_run_from_micro),
        .log_read_devices       (log_read_devices),

        .out_rf_to_micro_data  (gpi0),
        .in_micro_to_rf_data   (gpo0),
        .in_reset              (~in_reset),
        .clock                 (clockdsp)
        );


   /////////////////////////////////
   // Conectar el modulo completo
   topTxRam
     u_topTxRam
       (
        .i_enable({log_in_ram_run_from_micro,rf_enables_module[2:0]}), // 4 bits
        .i_reset (soft_reset),
        .log_data_from_ram (log_data_from_ram), // 32bits
        .log_ram_read_addr (log_read_addr_from_micro), // 11bits
        .o_leds  (),
        .o_led_r (log_out_full_from_ram),
        .clock   (clockdsp)
        );




endmodule // fpga
