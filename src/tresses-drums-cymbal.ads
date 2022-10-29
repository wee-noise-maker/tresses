with Tresses.Envelopes.AD;
with Tresses.Filters.SVF;
with Tresses.Random;

with Tresses.Interfaces; use Tresses.Interfaces;

package Tresses.Drums.Cymbal
with Preelaborate
is
   type Instance
   is new Pitched_Voice and Strike_Voice and Two_Params_Voice
   with private;

   procedure Init (This : in out Instance);

   procedure Set_Cutoff (This : in out Instance; P0 : Param_Range);

   procedure Set_Noise (This : in out Instance; P1 : Param_Range);

   procedure Render (This   : in out Instance;
                     Buffer :    out Mono_Buffer);

   type Cymbal_State is private;

   procedure Render_Cymbal
     (Buffer                    :    out Mono_Buffer;
      Cutoff_Param, Noise_Param :        Param_Range;
      Filter0, Filter1          : in out Filters.SVF.Instance;
      Env                       : in out Envelopes.AD.Instance;
      State                     : in out Cymbal_State;
      Phase                     : in out U32;
      Pitch                     :        Pitch_Range;
      Do_Init                   : in out Boolean;
      Do_Strike                 : in out Boolean);

   --  Interfaces --

   overriding
   procedure Strike (This : in out Instance);

   overriding
   procedure Set_Pitch (This  : in out Instance;
                        Pitch :        Pitch_Range);

   overriding
   procedure Set_Param1 (This : in out Instance; P : Param_Range)
   renames Set_Cutoff;

   overriding
   procedure Set_Param2 (This : in out Instance; P : Param_Range)
   renames Set_Noise;

private

   type Cymbal_Phase_Array is array (0 .. 5) of U32;

   type Cymbal_State is record
      Phase : Cymbal_Phase_Array := (others => 0);
      Rng : Random.Instance;
      Last_Noise : U32 := 0;
   end record;

   type Instance
   is new Pitched_Voice and Strike_Voice and Two_Params_Voice
   with record
      Env : Envelopes.AD.Instance;

      Filter0, Filter1 : Filters.SVF.Instance;

      State : Cymbal_State;

      Pitch : Pitch_Range := Init_Pitch;
      Phase : U32 := 0;

      Do_Strike : Boolean := False;
      Do_Init : Boolean := True;

      Cutoff_Param : Param_Range := 0;
      Noise_Param : Param_Range := 0;
   end record;

end Tresses.Drums.Cymbal;
