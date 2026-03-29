--  main.adb — Blink an LED on GPIO 17 (header pin 11)
--
--  Ada bare-metal for Raspberry Pi 4 (BCM2711).
--  Same hardware as the C version, different language.
--
--  GPIO 17 is in GPFSEL1 at bits [23:21].
--  In GPSET0/GPCLR0 it is bit 17.

--  "with" is Ada's version of #include.  It makes a package visible.
--  "use" lets you reference things inside the package without the prefix.
--  So instead of writing Interfaces.Unsigned_32 everywhere, you can
--  just write Unsigned_32.
with Interfaces;            use Interfaces;
--  System.Machine_Code gives us the Asm() procedure for inline assembly.
with System.Machine_Code;   use System.Machine_Code;
--  System.Storage_Elements gives us To_Address() which converts an
--  integer to a memory address.
with System.Storage_Elements;

--  "procedure Main is" declares the entry point.  In Ada, a program is
--  just a procedure.  Everything between "is" and "begin" is the
--  declaration section (like the top of a C function before the code).
procedure Main is

   --  "use" here makes To_Address() available without the long prefix
   --  System.Storage_Elements.To_Address().
   use System.Storage_Elements;

   --  "constant" with no type = universal integer.  Ada figures out
   --  the type from context.  16#FE000000# is hex notation:
   --  16# means base 16, same as 0xFE000000 in C.
   MMIO_Base : constant := 16#FE000000#;
   GPIO_Base : constant := MMIO_Base + 16#200000#;

   --  Declare a variable of type Unsigned_32 (same as uint32_t in C).
   --  This is NOT a normal variable in memory — the next line pins it
   --  to a specific hardware address.
   GPFSEL1 : Unsigned_32;

   --  "for X'Address use ..." is an address overlay.  It tells the
   --  compiler: "GPFSEL1 lives at this memory address."  Every read or
   --  write of GPFSEL1 will hit the GPIO hardware register.
   --  This is Ada's equivalent of:  *(volatile uint32_t *)0xFE200004
   for GPFSEL1'Address use To_Address (GPIO_Base + 16#04#);

   --  "pragma Volatile" = same as C's volatile keyword.  Tells the
   --  compiler every read/write must actually happen, in order, and
   --  cannot be optimized away.
   pragma Volatile (GPFSEL1);

   --  "pragma Import" tells the compiler NOT to initialize this variable.
   --  Without it, Ada would try to zero-initialize GPFSEL1 at startup,
   --  which would write 0 to the hardware register and break things.
   pragma Import (Ada, GPFSEL1);

   --  Same pattern for GPSET0 and GPCLR0:
   --  declare, pin to address, mark volatile, prevent initialization.
   GPSET0 : Unsigned_32;
   for GPSET0'Address use To_Address (GPIO_Base + 16#1C#);
   pragma Volatile (GPSET0);
   pragma Import (Ada, GPSET0);

   GPCLR0 : Unsigned_32;
   for GPCLR0'Address use To_Address (GPIO_Base + 16#28#);
   pragma Volatile (GPCLR0);
   pragma Import (Ada, GPCLR0);

   --  Shift_Left is a built-in from Interfaces.  It shifts the first
   --  argument left by the second argument number of bits.
   --  Shift_Left(1, 17) = 1 << 17 in C = 0x00020000 = bit 17 set.
   LED_Bit : constant Unsigned_32 := Shift_Left (1, 17);

   --  A nested procedure (Ada lets you declare procedures inside other
   --  procedures).  "Count : Unsigned_32" is a parameter with its type.
   procedure Delay_Loop (Count : Unsigned_32) is
      --  Local variable, initialized to Count.  ":=" is assignment.
      N : Unsigned_32 := Count;
   begin
      --  "while ... loop ... end loop" is Ada's while loop.
      while N > 0 loop
         --  Inline assembly: emit a "nop" instruction.
         --  Volatile => True means don't optimize this away.
         Asm ("nop", Volatile => True);
         N := N - 1;
      end loop;
   end Delay_Loop;

   --  Another local variable for the register read-modify-write.
   Sel : Unsigned_32;

--  "begin" marks the start of executable code.  Everything above was
--  declarations.  This is one of Ada's key differences from C: you
--  must declare all your variables BEFORE the code starts.
begin
   --  Read the current value of GPFSEL1 from hardware.
   Sel := GPFSEL1;

   --  Clear bits [23:21].
   --  Unsigned_32'(7) is a "qualified expression" — it tells the
   --  compiler that the literal 7 is specifically an Unsigned_32.
   --  Ada is strict about types and sometimes needs this hint.
   --  "not" = bitwise NOT (~in C).  "and" = bitwise AND (& in C).
   --  So this is: Sel = Sel & ~(7 << 21)
   Sel := Sel and not Shift_Left (Unsigned_32'(7), 21);

   --  Set bits [23:21] to 001 (output mode).
   --  "or" = bitwise OR (| in C).
   --  This is: Sel = Sel | (1 << 21)
   Sel := Sel or Shift_Left (Unsigned_32'(1), 21);

   --  Write the modified value back to the hardware register.
   GPFSEL1 := Sel;

   --  "loop ... end loop" with no condition = infinite loop (like for(;;) in C).
   loop
      --  Write LED_Bit to GPSET0 → drives GPIO 17 high → LED on.
      GPSET0 := LED_Bit;
      --  Wait.  Ada uses underscores in numbers for readability:
      --  200_000_000 = 200000000.  Just cosmetic, same value.
      Delay_Loop (200_000_000);
      --  Write LED_Bit to GPCLR0 → drives GPIO 17 low → LED off.
      GPCLR0 := LED_Bit;
      Delay_Loop (200_000_000);
   end loop;

--  "end Main" closes the procedure.  Every block in Ada is explicitly
--  closed with "end" + the name.  No curly braces.
end Main;
