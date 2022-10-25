with Tresses.Excitation; use Tresses.Excitation;
with Tresses.Filters.SVF; use Tresses.Filters.SVF;
with Tresses.Random; use Tresses.Random;
with Tresses.DSP;

package body Tresses.Drums.Snare is

   ----------
   -- Init --
   ----------

   procedure Init (This : in out Instance) is
   begin
      This.Do_Init := True;
   end Init;

   --------------
   -- Set_Tone --
   --------------

   procedure Set_Tone (This : in out Instance; P0 : U16) is
   begin
      This.Tone_Param := P0;
   end Set_Tone;

   ---------------
   -- Set_Noise --
   ---------------

   procedure Set_Noise (This : in out Instance; P1 : U16) is
   begin
      This.Noise_Param := P1;
   end Set_Noise;

   ------------
   -- Strike --
   ------------

   procedure Strike (This : in out Instance) is
   begin
      This.Do_Strike := True;
   end Strike;

   ------------
   -- Render --
   ------------

   procedure Render (This   : in out Instance;
                     Buffer :    out Mono_Buffer)
   is
   begin
      Render_Snare (Buffer,
                    This.Tone_Param, This.Noise_Param,
                    This.Pulse0, This.Pulse1, This.Pulse2, This.Pulse3,
                    This.Filter0, This.Filter1, This.Filter2,
                    This.Rng,
                    This.Pitch,
                    This.Do_Init, This.Do_Strike);
   end Render;

   ------------------
   -- Render_Snare --
   ------------------

   procedure Render_Snare
     (Buffer                         :    out Mono_Buffer;
      Tone_Param, Noise_Param        :        U16;
      Pulse0, Pulse1, Pulse2, Pulse3 : in out Excitation.Instance;
      Filter0, Filter1, Filter2      : in out Filters.SVF.Instance;
      Rng                            : in out Random.Instance;
      Pitch                          :        S16;
      Do_Init                        : in out Boolean;
      Do_Strike                      : in out Boolean)
   is

   begin
      if Do_Init then

         Do_Init := False;

         Init (Pulse0);
         Set_Delay (Pulse0, 0);
         Set_Decay (Pulse0, 1536);

         Init (Pulse1);
         Set_Delay (Pulse1, U16 (1.0e-3 * 48000.0));
         Set_Decay (Pulse1, 3072);

         Init (Pulse2);
         Set_Delay (Pulse2, U16 (1.0e-3 * 48000.0));
         Set_Decay (Pulse2, 1200);

         Init (Pulse3);
         Set_Delay (Pulse3, 0);

         Init (Filter0);
         Init (Filter1);

         Init (Filter2);
         Set_Resonance (Filter2, 2000);
         Set_Mode (Filter2, Band_Pass);
      end if;

      --  Strike
      if Do_Strike then

         Do_Strike := False;

         declare
            Decay : S32 := 49_152 - S32 (Pitch);
         begin
            Decay := Decay + (if Noise_Param < 16_384
                              then 0
                              else S32 (Noise_Param) - 16_384);

            if Decay > 65_535 then
               Decay := 65_535;
            end if;

            Set_Resonance (Filter0, 29_000 + S16 (Decay / 2**5));
            Set_Resonance (Filter1, 26_500 + S16 (Decay / 2**5));

            --  Pulse3 is used as an envelope
            Set_Decay (Pulse3, 4_092 + U16 (Decay / 2**14));

            Trigger (Pulse0, 15 * 32_768);
            Trigger (Pulse1, -1 * 32_768);
            Trigger (Pulse2, 13_107);

            declare
               Snappy : S32 := S32 (Noise_Param);
            begin
               if Snappy >= 14_336 then
                  Snappy := 14_336;
               end if;

               --  Higher "Snappy" params means harder hit on the snare
               --  "envelope".
               Trigger (Pulse3, 512 + (Snappy * 2**1));
            end;
         end;
      end if;

      Set_Frequency (Filter0, Pitch + (12 * 2**7));
      Set_Frequency (Filter1, Pitch + (24 * 2**7));
      Set_Frequency (Filter2, Pitch + (60 * 2**7));

      declare
         G1 : constant S32 := 22_000 - S32 (Tone_Param / 2**1);
         G2 : constant S32 := 22_000 + S32 (Tone_Param / 2**1);

         Index : Natural := Buffer'First;

         Excitation_1, Excitation_2, Noise_Sample, SD : S32;
         P3 : S32;
      begin
         while Index <= Buffer'Last loop

            Excitation_1 := Process (Pulse0);
            Excitation_1 := Excitation_1 + Process (Pulse1);
            Excitation_1 := Excitation_1 + (if not Done (Pulse1)
                                            then 2621
                                            else 0);

            Excitation_2 := Process (Pulse2);
            Excitation_2 := Excitation_2 + (if not Done (Pulse2)
                                            then 13107
                                            else 0);

            P3 := Process (Pulse3);
            Noise_Sample :=
              (S32 (Get_Sample (Rng)) * P3) / 2**15;

            SD := ((Process (Filter0, Excitation_1) + (Excitation_1 / 2**4)) *
                     G1) / 2**15;

            SD := SD +
              ((Process (Filter1, Excitation_2) + (Excitation_2 / 2**4)) *
                 G2) / 2**15;

            SD := SD + Process (Filter2, Noise_Sample);

            DSP.Clip_S16 (SD);

            --  Why two identical sample points?

            Buffer (Index) := S16 (SD);
            Index := Index + 1;
            Buffer (Index) := S16 (SD);
            Index := Index + 1;
         end loop;
      end;
   end Render_Snare;

end Tresses.Drums.Snare;