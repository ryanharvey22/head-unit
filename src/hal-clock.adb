--  hal-clock.adb (Pi) — Time via AArch64 architected timer (CNTPCT / CNTFRQ)
--
--  Do NOT use only the legacy BCM system timer CLO at 0xFE003004 for long waits:
--  if that counter never advances (SoC / EL / mapping quirks), Wait_* loops
--  forever.
--
--  Firmware normally enables the generic timer; CLO remains a fallback for
--  Now_Us when CNTFRQ reads as zero.

with Interfaces; use Interfaces;
with System.Machine_Code;
with System.Storage_Elements; use System.Storage_Elements;

package body Hal.Clock is

   MMIO_Base : constant := 16#FE000000#;

   Timer_CLO : U32;
   for Timer_CLO'Address use To_Address (MMIO_Base + 16#3004#);
   pragma Volatile (Timer_CLO);
   pragma Import (Ada, Timer_CLO);

   function Read_Cntfrq return Unsigned_64 is
      R : Unsigned_64;
   begin
      System.Machine_Code.Asm (
         "mrs %0, cntfrq_el0",
         Outputs  => Unsigned_64'Asm_Output ("=r", R),
         Volatile => True,
         Clobber  => "memory");
      return R;
   end Read_Cntfrq;

   function Read_Cntpct return Unsigned_64 is
      R : Unsigned_64;
   begin
      System.Machine_Code.Asm (
         "mrs %0, cntpct_el0",
         Outputs  => Unsigned_64'Asm_Output ("=r", R),
         Volatile => True,
         Clobber  => "memory");
      return R;
   end Read_Cntpct;

   procedure Wait_Us_Legacy_CLO (Us : U32) is
      Start : constant U32 := Timer_CLO;
      Same  : U32 := Timer_CLO;
      Idle  : Natural := 0;
   begin
      while (Timer_CLO - Start) < Us loop
         if Timer_CLO = Same then
            Idle := Idle + 1;
            --  CLO not advancing — avoid infinite hang.
            exit when Idle > 5_000_000;
         else
            Same := Timer_CLO;
            Idle := 0;
         end if;
      end loop;
   end Wait_Us_Legacy_CLO;

   function Now_Us return U32 is
      F : constant Unsigned_64 := Read_Cntfrq;
      T : constant Unsigned_64 := Read_Cntpct;
   begin
      if F = 0 then
         return Timer_CLO;
      end if;
      return U32 ((T * 1_000_000) / F);
   end Now_Us;

   procedure Wait_Us (Us : U32) is
      F     : constant Unsigned_64 := Read_Cntfrq;
      Start : Unsigned_64;
      Need  : Unsigned_64;
      Now   : Unsigned_64;
   begin
      if F = 0 then
         Wait_Us_Legacy_CLO (Us);
         return;
      end if;

      Need := (Unsigned_64 (Us) * F) / 1_000_000;
      if Need = 0 then
         Need := 1;
      end if;

      Start := Read_Cntpct;
      declare
         Prev : Unsigned_64 := Start;
         Idle : Natural := 0;
      begin
         loop
            Now := Read_Cntpct;
            exit when Now - Start >= Need;
            if Now = Prev then
               Idle := Idle + 1;
               exit when Idle > 50_000_000;
            else
               Prev := Now;
               Idle := 0;
            end if;
         end loop;
      end;
   end Wait_Us;

   procedure Wait_Ms (Ms : U32) is
   begin
      Wait_Us (Ms * 1000);
   end Wait_Ms;

end Hal.Clock;
