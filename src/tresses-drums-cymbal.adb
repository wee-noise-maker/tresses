--
--  SPDX-License-Identifier: MIT
--
--  Based on Braids from Mutable Instruments:
--  Copyright 2012 Emilie Gillet.

with Tresses.Envelopes.AD; use Tresses.Envelopes.AD;
with Tresses.Filters.SVF; use Tresses.Filters.SVF;
with Tresses.Random; use Tresses.Random;
with Tresses.DSP;

package body Tresses.Drums.Cymbal is

   ------------------
   -- Render_Snare --
   ------------------

   procedure Render_Cymbal
     (Buffer           :    out Mono_Buffer;
      Params           :        Param_Array;
      Filter0, Filter1 : in out Filters.SVF.Instance;
      Env              : in out Envelopes.AD.Instance;
      State            : in out Cymbal_State;
      Phase            : in out U32;
      Pitch            :        Pitch_Range;
      Do_Init          : in out Boolean;
      Do_Strike        : in out Boolean)
   is
      Cutoff_Param : Param_Range renames Params (P_Cutoff);
      Noise_Param  : Param_Range renames Params (P_Noise);

      Increments : array (0 .. 6) of U32;
      Note : constant Pitch_Range :=
        Pitch_Range ((40 * 2**7) + (S32 (Pitch) / 2**1));
      Root : U32;
   begin
      if Do_Init then

         Do_Init := False;

         Phase := 0;

         Init (Filter0);
         Set_Mode (Filter0, Band_Pass);
         Set_Resonance (Filter0, 12_000);

         Init (Filter1);
         Set_Mode (Filter1, High_Pass);
         Set_Resonance (Filter1, 2_000);

         Init (Env);
         Set_Attack (Env, U7 (0));
      end if;

      if Do_Strike then

         Do_Strike := False;

         --  The original MI Braids cymbal did not feature an envelope. We add
         --  one here for ease of use and to match the behavior of the other
         --  drum sounds.

         declare
            To_U7_Div : constant := 512;
            --  U16'Last / U7'Last = ~516.023 then rounded to the nearest
            --  power of 2.

            Limit : constant U32 := U32 (U7'Last) * To_U7_Div;
            --  Maximum value to be converted to U7

            Decay : U32 := U32 (Noise_Param) + 20_000;
            --  Add a base value to have a minimum decay
         begin
            if Decay > Limit then
               Decay := Limit;
            end if;

            Set_Decay (Env, U7 (Decay / To_U7_Div));
            Trigger (Env, Attack);
         end;
      end if;

      Increments (0) := DSP.Compute_Phase_Increment (S16 (Note));

      Root := Shift_Right (Increments (0), 10);
      Increments (1) := Shift_Right (Root * 24_273, 4);
      Increments (2) := Shift_Right (Root * 12_561, 4);
      Increments (3) := Shift_Right (Root * 18_417, 4);
      Increments (4) := Shift_Right (Root * 22_452, 4);
      Increments (5) := Shift_Right (Root * 31_858, 4);
      Increments (6) := Increments (0) * 24;

      declare
         Xfade : constant S32 := S32 (Noise_Param);

         Hat_Noise, Noise : S32;
         Index : Natural := Buffer'First;

         SD : S32;
      begin
         Set_Frequency (Filter0, S16 (Cutoff_Param / 2));
         Set_Frequency (Filter1, S16 (Cutoff_Param / 2));

         while Index <= Buffer'Last loop
            Phase := Phase + Increments (6);
            if Phase < Increments (6) then
               State.Last_Noise := Get_Word (State.Rng);
            end if;

            State.Phase (0) := State.Phase (0) + Increments (0);
            State.Phase (1) := State.Phase (1) + Increments (1);
            State.Phase (2) := State.Phase (2) + Increments (2);
            State.Phase (3) := State.Phase (3) + Increments (3);
            State.Phase (4) := State.Phase (4) + Increments (4);
            State.Phase (5) := State.Phase (5) + Increments (5);

            Hat_Noise := 0;
            Hat_Noise := Hat_Noise + S32 (Shift_Right (State.Phase (0), 31));
            Hat_Noise := Hat_Noise + S32 (Shift_Right (State.Phase (1), 31));
            Hat_Noise := Hat_Noise + S32 (Shift_Right (State.Phase (2), 31));
            Hat_Noise := Hat_Noise + S32 (Shift_Right (State.Phase (3), 31));
            Hat_Noise := Hat_Noise + S32 (Shift_Right (State.Phase (4), 31));
            Hat_Noise := Hat_Noise + S32 (Shift_Right (State.Phase (5), 31));
            Hat_Noise := Hat_Noise - 3;
            Hat_Noise := Hat_Noise * 5_461;
            Hat_Noise := Process (Filter0, Hat_Noise);

            DSP.Clip_S16 (Hat_Noise);

            Noise := S32 (State.Last_Noise / 2**16) - 32_768;
            Noise := Process (Filter1, Noise / 2**1);
            DSP.Clip_S16 (Noise);

            SD := Hat_Noise + ((Noise - Hat_Noise) * Xfade) / 2**15;
            DSP.Clip_S16 (SD);

            SD := (SD * S32 (Render (Env))) / 2**15;
            DSP.Clip_S16 (SD);

            Buffer (Index) := S16 (SD);
            Index := Index + 1;
         end loop;
      end;
   end Render_Cymbal;

   ------------
   -- Render --
   ------------

   procedure Render (This   : in out Instance;
                     Buffer :    out Mono_Buffer)
   is
   begin
      Render_Cymbal (Buffer,
                     This.Params,
                     This.Filter0,
                     This.Filter1,
                     This.Env,
                     This.State,
                     This.Phase,
                     This.Pitch,
                     This.Do_Init,
                     This.Do_Strike);
   end Render;

end Tresses.Drums.Cymbal;
