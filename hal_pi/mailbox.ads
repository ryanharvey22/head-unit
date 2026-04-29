--  mailbox.ads — VideoCore mailbox (private helper for Pi HAL bodies)
--
--  Used internally by hal_pi/hal-display.adb for framebuffer setup.

with Hal; use Hal;

package Mailbox is

   Max_Words : constant := 36;
   type Tag_Buffer is array (0 .. Max_Words - 1) of U32;

   Buffer : Tag_Buffer;
   for Buffer'Alignment use 16;

   function Call return Boolean;

end Mailbox;
