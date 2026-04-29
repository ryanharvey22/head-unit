--  nmea-parser.adb — Streaming NMEA 0183 sentence parser
--
--  Implemented:
--    * Sentence framing ($..*XX\r\n)
--    * XOR checksum validation
--    * Sentence accept/reject counters
--
--  TODO (left for you to implement):
--    * Sentence-type dispatch ($GPGGA vs $GPRMC vs ...)
--    * Field tokenization (commas)
--    * Lat/lon DDDMM.MMMM -> 1e-6 degrees conversion
--    * Speed (knots) -> cm/s conversion
--    * Course parsing
--    * SOG / COG / HDOP / sat-count extraction
--
--  See: nmea/README hint, tests/test_nmea.adb for the contract.

with Interfaces; use Interfaces;

package body Nmea.Parser is

   ------------------------------------------------------------------
   --  State machine
   ------------------------------------------------------------------
   type State_Kind is
      (Wait_Dollar,    --  scanning for sentence start '$'
       In_Body,        --  collecting characters until '*'
       In_Csum_1,      --  first hex digit of checksum
       In_Csum_2,      --  second hex digit of checksum
       Wait_CR,        --  expect CR
       Wait_LF);       --  expect LF

   Max_Sentence : constant := 96;
   --  NMEA 0183 max line length is 82, give a little headroom.

   subtype Body_Buffer_Range is Natural range 0 .. Max_Sentence;

   type Body_Buffer_Type is array (1 .. Max_Sentence) of U8;

   ------------------------------------------------------------------
   --  Module state (single-instance — there's one GPS in this system)
   ------------------------------------------------------------------
   State          : State_Kind := Wait_Dollar;
   Body_Buf       : Body_Buffer_Type := (others => 0);
   Body_Len       : Body_Buffer_Range := 0;
   Running_Csum   : U8 := 0;
   Recv_Csum      : U8 := 0;

   Latest_Fix     : Fix_Type;
   New_Fix_Flag   : Boolean := False;

   Accepted       : U32 := 0;
   Rejected       : U32 := 0;

   ------------------------------------------------------------------
   --  Helpers
   ------------------------------------------------------------------
   function Hex_Nibble (B : U8) return U8 is
      --  Convert ASCII hex character to 0..15, or 16#FF# on error.
   begin
      case Character'Val (Integer (B)) is
         when '0' .. '9' => return B - Character'Pos ('0');
         when 'A' .. 'F' => return B - Character'Pos ('A') + 10;
         when 'a' .. 'f' => return B - Character'Pos ('a') + 10;
         when others     => return 16#FF#;
      end case;
   end Hex_Nibble;

   procedure Begin_Sentence is
   begin
      Body_Len     := 0;
      Running_Csum := 0;
      Recv_Csum    := 0;
      State        := In_Body;
   end Begin_Sentence;

   procedure Reject_Sentence is
   begin
      Rejected := Rejected + 1;
      State    := Wait_Dollar;
   end Reject_Sentence;

   procedure Accept_Sentence is
   begin
      Accepted := Accepted + 1;
      --
      --  TODO: dispatch on sentence type and update Latest_Fix.
      --
      --    if Body_Buf (1..5) starts with 'GPGGA' then
      --       Parse_GGA (Body_Buf (1 .. Body_Len), Latest_Fix);
      --       New_Fix_Flag := True;
      --    elsif starts with 'GPRMC' then ...
      --
      --  Hint: write a small Tokenize procedure that walks the buffer
      --  and yields field slices delimited by ','.  Then have a
      --  per-sentence handler that consumes those tokens in order.
      --
      State := Wait_Dollar;
   end Accept_Sentence;

   ------------------------------------------------------------------
   --  Public interface
   ------------------------------------------------------------------
   procedure Reset is
   begin
      State        := Wait_Dollar;
      Body_Len     := 0;
      Running_Csum := 0;
      Recv_Csum    := 0;
      Accepted     := 0;
      Rejected     := 0;
      New_Fix_Flag := False;
      Latest_Fix   := (others => <>);
   end Reset;

   procedure Feed (B : U8) is
      Nibble : U8;
   begin
      case State is
         when Wait_Dollar =>
            if B = Character'Pos ('$') then
               Begin_Sentence;
            end if;

         when In_Body =>
            if B = Character'Pos ('*') then
               State := In_Csum_1;
            elsif B = Character'Pos ('$') then
               --  Lost sync, restart.
               Begin_Sentence;
            elsif Body_Len < Max_Sentence then
               Body_Len := Body_Len + 1;
               Body_Buf (Body_Len) := B;
               Running_Csum := Running_Csum xor B;
            else
               Reject_Sentence;
            end if;

         when In_Csum_1 =>
            Nibble := Hex_Nibble (B);
            if Nibble = 16#FF# then
               Reject_Sentence;
            else
               Recv_Csum := Shift_Left (Nibble, 4);
               State     := In_Csum_2;
            end if;

         when In_Csum_2 =>
            Nibble := Hex_Nibble (B);
            if Nibble = 16#FF# then
               Reject_Sentence;
            else
               Recv_Csum := Recv_Csum or Nibble;
               State     := Wait_CR;
            end if;

         when Wait_CR =>
            if B = 16#0D# then
               State := Wait_LF;
            else
               Reject_Sentence;
            end if;

         when Wait_LF =>
            if B = 16#0A# then
               if Recv_Csum = Running_Csum then
                  Accept_Sentence;
               else
                  Reject_Sentence;
               end if;
            else
               Reject_Sentence;
            end if;
      end case;
   end Feed;

   function Has_New_Fix return Boolean is
   begin
      return New_Fix_Flag;
   end Has_New_Fix;

   function Get_Fix return Fix_Type is
      F : constant Fix_Type := Latest_Fix;
   begin
      New_Fix_Flag := False;
      return F;
   end Get_Fix;

   function Sentences_Accepted return U32 is (Accepted);
   function Sentences_Rejected return U32 is (Rejected);

end Nmea.Parser;
