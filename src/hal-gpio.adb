--  hal-gpio.adb — GPIO output via GPFSELn + GPSET0 / GPCLR0 (pins 0–31)

with Interfaces; use Interfaces;
with System.Storage_Elements; use System.Storage_Elements;

package body Hal.GPIO is

   MMIO_Base : constant := 16#FE000000#;
   GPIO_Base : constant := MMIO_Base + 16#200000#;

   GPFSEL0 : U32;
   for GPFSEL0'Address use To_Address (GPIO_Base + 16#00#);
   pragma Volatile (GPFSEL0);
   pragma Import (Ada, GPFSEL0);

   GPFSEL1 : U32;
   for GPFSEL1'Address use To_Address (GPIO_Base + 16#04#);
   pragma Volatile (GPFSEL1);
   pragma Import (Ada, GPFSEL1);

   GPFSEL2 : U32;
   for GPFSEL2'Address use To_Address (GPIO_Base + 16#08#);
   pragma Volatile (GPFSEL2);
   pragma Import (Ada, GPFSEL2);

   GPFSEL3 : U32;
   for GPFSEL3'Address use To_Address (GPIO_Base + 16#0C#);
   pragma Volatile (GPFSEL3);
   pragma Import (Ada, GPFSEL3);

   GPFSEL4 : U32;
   for GPFSEL4'Address use To_Address (GPIO_Base + 16#10#);
   pragma Volatile (GPFSEL4);
   pragma Import (Ada, GPFSEL4);

   GPFSEL5 : U32;
   for GPFSEL5'Address use To_Address (GPIO_Base + 16#14#);
   pragma Volatile (GPFSEL5);
   pragma Import (Ada, GPFSEL5);

   GPSET0 : U32;
   for GPSET0'Address use To_Address (GPIO_Base + 16#1C#);
   pragma Volatile (GPSET0);
   pragma Import (Ada, GPSET0);

   GPCLR0 : U32;
   for GPCLR0'Address use To_Address (GPIO_Base + 16#28#);
   pragma Volatile (GPCLR0);
   pragma Import (Ada, GPCLR0);

   procedure Sel_Reg_And_Shift
     (BCM_Pin : Hal.U32; Reg : out U32; Shift_Amount : out Hal.U32);

   procedure Sel_Reg_And_Shift
     (BCM_Pin : Hal.U32; Reg : out U32; Shift_Amount : out Hal.U32) is
      Idx : constant Hal.U32 := BCM_Pin / 10;
      Field : constant Hal.U32 := BCM_Pin mod 10;
   begin
      Shift_Amount := Field * 3;
      case Idx is
         when 0 => Reg := GPFSEL0;
         when 1 => Reg := GPFSEL1;
         when 2 => Reg := GPFSEL2;
         when 3 => Reg := GPFSEL3;
         when 4 => Reg := GPFSEL4;
         when 5 => Reg := GPFSEL5;
         when others =>
            Reg := 0;
            Shift_Amount := 0;
      end case;
   end Sel_Reg_And_Shift;

   procedure Write_GPFSEL (BCM_Pin : Hal.U32; Value : U32) is
      Idx : constant Hal.U32 := BCM_Pin / 10;
   begin
      case Idx is
         when 0 => GPFSEL0 := Value;
         when 1 => GPFSEL1 := Value;
         when 2 => GPFSEL2 := Value;
         when 3 => GPFSEL3 := Value;
         when 4 => GPFSEL4 := Value;
         when 5 => GPFSEL5 := Value;
         when others => null;
      end case;
   end Write_GPFSEL;

   procedure Init_Output (BCM_Pin : Hal.U32) is
      Sel : U32;
      Sh  : Hal.U32;
      Idx : constant Hal.U32 := BCM_Pin / 10;
   begin
      if BCM_Pin > 31 or else Idx > 5 then
         return;
      end if;
      Sel_Reg_And_Shift (BCM_Pin, Sel, Sh);
      Sel := Sel and not Shift_Left (U32'(7), Integer (Sh));
      Sel := Sel or Shift_Left (U32'(1), Integer (Sh));
      Write_GPFSEL (BCM_Pin, Sel);
   end Init_Output;

   procedure Write (BCM_Pin : Hal.U32; High : Boolean) is
      Bit : constant U32 := Shift_Left (U32'(1), Integer (BCM_Pin));
   begin
      if BCM_Pin > 31 then
         return;
      end if;
      if High then
         GPSET0 := Bit;
      else
         GPCLR0 := Bit;
      end if;
   end Write;

end Hal.GPIO;
