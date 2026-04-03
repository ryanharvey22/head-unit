--  uart.adb — Mini-UART (UART1) driver implementation
--
--  Register reference: BCM2711 ARM Peripherals, section 2.2
--  Mini-UART base: MMIO_BASE + 0x215000
--  The auxiliary peripherals block starts at 0x215000.
--  Mini-UART registers are at offsets 0x40..0x68 within that block.

with Interfaces;            use Interfaces;
with System.Storage_Elements; use System.Storage_Elements;

package body UART is

   MMIO_Base : constant := 16#FE000000#;
   AUX_Base  : constant := MMIO_Base + 16#215000#;

   --  Auxiliary enables register — bit 0 enables mini-UART
   AUX_ENABLES : Unsigned_32;
   for AUX_ENABLES'Address use To_Address (AUX_Base + 16#04#);
   pragma Volatile (AUX_ENABLES);
   pragma Import (Ada, AUX_ENABLES);

   --  Mini-UART I/O data register — write a byte to transmit
   AUX_MU_IO : Unsigned_32;
   for AUX_MU_IO'Address use To_Address (AUX_Base + 16#40#);
   pragma Volatile (AUX_MU_IO);
   pragma Import (Ada, AUX_MU_IO);

   --  Mini-UART interrupt enable
   AUX_MU_IER : Unsigned_32;
   for AUX_MU_IER'Address use To_Address (AUX_Base + 16#44#);
   pragma Volatile (AUX_MU_IER);
   pragma Import (Ada, AUX_MU_IER);

   --  Mini-UART line control — bit 0,1 set data size (11 = 8-bit)
   AUX_MU_LCR : Unsigned_32;
   for AUX_MU_LCR'Address use To_Address (AUX_Base + 16#4C#);
   pragma Volatile (AUX_MU_LCR);
   pragma Import (Ada, AUX_MU_LCR);

   --  Mini-UART modem control
   AUX_MU_MCR : Unsigned_32;
   for AUX_MU_MCR'Address use To_Address (AUX_Base + 16#50#);
   pragma Volatile (AUX_MU_MCR);
   pragma Import (Ada, AUX_MU_MCR);

   --  Mini-UART line status — bit 5 = transmitter empty
   AUX_MU_LSR : Unsigned_32;
   for AUX_MU_LSR'Address use To_Address (AUX_Base + 16#54#);
   pragma Volatile (AUX_MU_LSR);
   pragma Import (Ada, AUX_MU_LSR);

   --  Mini-UART extra control — bits 0,1 = receiver/transmitter enable
   AUX_MU_CNTL : Unsigned_32;
   for AUX_MU_CNTL'Address use To_Address (AUX_Base + 16#60#);
   pragma Volatile (AUX_MU_CNTL);
   pragma Import (Ada, AUX_MU_CNTL);

   --  Mini-UART baud rate register
   AUX_MU_BAUD : Unsigned_32;
   for AUX_MU_BAUD'Address use To_Address (AUX_Base + 16#68#);
   pragma Volatile (AUX_MU_BAUD);
   pragma Import (Ada, AUX_MU_BAUD);

   --  GPIO registers for pin function select
   GPIO_Base : constant := MMIO_Base + 16#200000#;

   GPFSEL1 : Unsigned_32;
   for GPFSEL1'Address use To_Address (GPIO_Base + 16#04#);
   pragma Volatile (GPFSEL1);
   pragma Import (Ada, GPFSEL1);

   GPIO_PUP_PDN_CNTRL0 : Unsigned_32;
   for GPIO_PUP_PDN_CNTRL0'Address use To_Address (GPIO_Base + 16#E4#);
   pragma Volatile (GPIO_PUP_PDN_CNTRL0);
   pragma Import (Ada, GPIO_PUP_PDN_CNTRL0);

   procedure Init is
      Sel : Unsigned_32;
   begin
      --  Enable mini-UART
      AUX_ENABLES := AUX_ENABLES or 1;

      --  Disable TX/RX while configuring
      AUX_MU_CNTL := 0;

      --  Disable interrupts
      AUX_MU_IER := 0;

      --  8-bit mode
      AUX_MU_LCR := 3;

      --  RTS line high
      AUX_MU_MCR := 0;

      --  115200 baud.  Formula: baudrate = system_clock / (8 * (baud_reg + 1))
      --  With VPU clock at 500 MHz: 500000000 / (8 * (270 + 1)) = ~115313
      AUX_MU_BAUD := 270;

      --  Set GPIO 14 and 15 to alt function 5 (mini-UART)
      --  GPFSEL1 bits [14:12] = GPIO 14 function, [17:15] = GPIO 15 function
      --  Alt5 = 010
      Sel := GPFSEL1;
      Sel := Sel and not Shift_Left (Unsigned_32'(7), 12);  --  clear GPIO 14
      Sel := Sel or Shift_Left (Unsigned_32'(2), 12);       --  alt5 for GPIO 14
      Sel := Sel and not Shift_Left (Unsigned_32'(7), 15);  --  clear GPIO 15
      Sel := Sel or Shift_Left (Unsigned_32'(2), 15);       --  alt5 for GPIO 15
      GPFSEL1 := Sel;

      --  Disable pull-up/pull-down on GPIO 14 and 15
      --  On BCM2711, GPIO_PUP_PDN registers replaced the old GPPUD mechanism
      --  Each pin gets 2 bits: 00 = no pull, 01 = pull-up, 10 = pull-down
      Sel := GPIO_PUP_PDN_CNTRL0;
      Sel := Sel and not Shift_Left (Unsigned_32'(3), 28);  --  GPIO 14: no pull
      Sel := Sel and not Shift_Left (Unsigned_32'(3), 30);  --  GPIO 15: no pull
      GPIO_PUP_PDN_CNTRL0 := Sel;

      --  Enable TX and RX
      AUX_MU_CNTL := 3;
   end Init;

   procedure Put_Char (C : Character) is
   begin
      --  Spin until transmitter has room (bit 5 of LSR = TX empty)
      while (AUX_MU_LSR and 16#20#) = 0 loop
         null;
      end loop;
      AUX_MU_IO := Character'Pos (C);
   end Put_Char;

   procedure Put_String (S : String) is
   begin
      for I in S'Range loop
         Put_Char (S (I));
      end loop;
   end Put_String;

   procedure Put_Line (S : String) is
   begin
      Put_String (S);
      New_Line;
   end Put_Line;

   procedure New_Line is
   begin
      Put_Char (Character'Val (13));  --  CR
      Put_Char (Character'Val (10));  --  LF
   end New_Line;

   Hex_Digits : constant String := "0123456789ABCDEF";

   procedure Put_Hex (Value : Interfaces.Unsigned_32) is
      V : Unsigned_32 := Value;
      Nibble : Unsigned_32;
   begin
      Put_String ("0x");
      for I in reverse 0 .. 7 loop
         Nibble := Shift_Right (V, I * 4) and 16#F#;
         Put_Char (Hex_Digits (Integer (Nibble) + 1));
      end loop;
   end Put_Hex;

end UART;
