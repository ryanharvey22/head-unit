--  mailbox.ads — VideoCore mailbox property channel 8 (Pi 4)
--
--  https://github.com/raspberrypi/firmware/wiki/Mailbox-property-interface

with Hal; use Hal;

package Mailbox is

   Max_Words : constant := 48;
   type Tag_Buffer is array (0 .. Max_Words - 1) of U32;

   Buffer : Tag_Buffer;
   for Buffer'Alignment use 256;

   function Call return Boolean;

   --  After Call: tag length word has bit 31 set; bits 30–0 are response bytes.
   function Tag_Response_Ok (Len_Word : U32; Min_Response_Bytes : U32)
      return Boolean;

end Mailbox;
