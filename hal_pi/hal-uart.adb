--  hal-uart.adb (Pi) — Mini-UART (UART1) on GPIO 14/15, 115200 baud

with Interfaces; use Interfaces;
with System.Storage_Elements; use System.Storage_Elements;

package body Hal.UART is

   MMIO_Base : constant := 16#FE000000#;
   AUX_Base  : constant := MMIO_Base + 16#215000#;
   GPIO_Base : constant := MMIO_Base + 16#200000#;

   AUX_ENABLES : U32;
   for AUX_ENABLES'Address use To_Address (AUX_Base + 16#04#);
   pragma Volatile (AUX_ENABLES);
   pragma Import (Ada, AUX_ENABLES);

   AUX_MU_IO : U32;
   for AUX_MU_IO'Address use To_Address (AUX_Base + 16#40#);
   pragma Volatile (AUX_MU_IO);
   pragma Import (Ada, AUX_MU_IO);

   AUX_MU_IER : U32;
   for AUX_MU_IER'Address use To_Address (AUX_Base + 16#44#);
   pragma Volatile (AUX_MU_IER);
   pragma Import (Ada, AUX_MU_IER);

   AUX_MU_LCR : U32;
   for AUX_MU_LCR'Address use To_Address (AUX_Base + 16#4C#);
   pragma Volatile (AUX_MU_LCR);
   pragma Import (Ada, AUX_MU_LCR);

   AUX_MU_MCR : U32;
   for AUX_MU_MCR'Address use To_Address (AUX_Base + 16#50#);
   pragma Volatile (AUX_MU_MCR);
   pragma Import (Ada, AUX_MU_MCR);

   AUX_MU_LSR : U32;
   for AUX_MU_LSR'Address use To_Address (AUX_Base + 16#54#);
   pragma Volatile (AUX_MU_LSR);
   pragma Import (Ada, AUX_MU_LSR);

   AUX_MU_CNTL : U32;
   for AUX_MU_CNTL'Address use To_Address (AUX_Base + 16#60#);
   pragma Volatile (AUX_MU_CNTL);
   pragma Import (Ada, AUX_MU_CNTL);

   AUX_MU_BAUD : U32;
   for AUX_MU_BAUD'Address use To_Address (AUX_Base + 16#68#);
   pragma Volatile (AUX_MU_BAUD);
   pragma Import (Ada, AUX_MU_BAUD);

   GPFSEL1 : U32;
   for GPFSEL1'Address use To_Address (GPIO_Base + 16#04#);
   pragma Volatile (GPFSEL1);
   pragma Import (Ada, GPFSEL1);

   GPIO_PUP_PDN_CNTRL0 : U32;
   for GPIO_PUP_PDN_CNTRL0'Address use To_Address (GPIO_Base + 16#E4#);
   pragma Volatile (GPIO_PUP_PDN_CNTRL0);
   pragma Import (Ada, GPIO_PUP_PDN_CNTRL0);

   procedure Init is
      Sel : U32;
   begin
      AUX_ENABLES := AUX_ENABLES or 1;
      AUX_MU_CNTL := 0;
      AUX_MU_IER  := 0;
      AUX_MU_LCR  := 3;
      AUX_MU_MCR  := 0;
      AUX_MU_BAUD := 270;

      Sel := GPFSEL1;
      Sel := Sel and not Shift_Left (U32'(7), 12);
      Sel := Sel or Shift_Left (U32'(2), 12);
      Sel := Sel and not Shift_Left (U32'(7), 15);
      Sel := Sel or Shift_Left (U32'(2), 15);
      GPFSEL1 := Sel;

      Sel := GPIO_PUP_PDN_CNTRL0;
      Sel := Sel and not Shift_Left (U32'(3), 28);
      Sel := Sel and not Shift_Left (U32'(3), 30);
      GPIO_PUP_PDN_CNTRL0 := Sel;

      AUX_MU_CNTL := 3;
   end Init;

   procedure Put_Char (C : Character) is
   begin
      while (AUX_MU_LSR and 16#20#) = 0 loop
         null;
      end loop;
      AUX_MU_IO := U32 (Character'Pos (C));
   end Put_Char;

   procedure Put_String (S : String) is
   begin
      for I in S'Range loop
         Put_Char (S (I));
      end loop;
   end Put_String;

   procedure New_Line is
   begin
      Put_Char (Character'Val (13));
      Put_Char (Character'Val (10));
   end New_Line;

   procedure Put_Line (S : String) is
   begin
      Put_String (S);
      New_Line;
   end Put_Line;

   Hex_Digits : constant String := "0123456789ABCDEF";

   procedure Put_Hex (Value : U32) is
      Nibble : U32;
   begin
      Put_String ("0x");
      for I in reverse 0 .. 7 loop
         Nibble := Shift_Right (Value, I * 4) and 16#F#;
         Put_Char (Hex_Digits (Integer (Nibble) + 1));
      end loop;
   end Put_Hex;

   procedure Put_Decimal (Value : I32) is
      Buf : String (1 .. 11);
      Pos : Natural := Buf'Last;
      V   : I32 := Value;
      Negative : Boolean := False;
   begin
      if V = 0 then
         Put_Char ('0');
         return;
      end if;
      if V < 0 then
         Negative := True;
         V := -V;
      end if;
      while V > 0 loop
         Buf (Pos) := Character'Val (Character'Pos ('0') + Integer (V rem 10));
         V := V / 10;
         Pos := Pos - 1;
      end loop;
      if Negative then
         Buf (Pos) := '-';
         Pos := Pos - 1;
      end if;
      Put_String (Buf (Pos + 1 .. Buf'Last));
   end Put_Decimal;

end Hal.UART;
