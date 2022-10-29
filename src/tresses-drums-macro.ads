with Tresses.Drums.Cymbal;

with Tresses.Excitation;
with Tresses.Random;
with Tresses.Filters.SVF;
with Tresses.Envelopes.AD;

with Tresses.Interfaces; use Tresses.Interfaces;

package Tresses.Drums.Macro
with Preelaborate
is
   --  A macro engine that can play all the drum sounds

   type Instance
   is new Pitched_Voice and Strike_Voice and Two_Params_Voice
   with private;

   function Engine (This : Instance) return Drum_Engines;
   procedure Set_Engine (This : in out Instance; E : Drum_Engines);
   procedure Next_Engine (This : in out Instance);
   procedure Prev_Engine (This : in out Instance);

   procedure Init (This : in out Instance);

   procedure Render (This   : in out Instance;
                     Buffer :    out Mono_Buffer);

   --  Interfaces --

   overriding
   procedure Strike (This : in out Instance);

   overriding
   procedure Set_Pitch (This  : in out Instance;
                        Pitch :        Pitch_Range);

   overriding
   procedure Set_Param1 (This : in out Instance; P : Param_Range);

   overriding
   procedure Set_Param2 (This : in out Instance; P : Param_Range);

private

   type Instance
   is new Pitched_Voice and Strike_Voice and Two_Params_Voice
   with record

      Engine : Drum_Engines := Drum_Engines'First;

      Pulse0, Pulse1, Pulse2, Pulse3 : Excitation.Instance;
      Filter0, Filter1, Filter3 : Filters.SVF.Instance;
      Rng : Random.Instance;
      Env : Envelopes.AD.Instance;

      Pitch : Pitch_Range := Init_Pitch;

      LP_State : S32 := 0;
      Cym_State : Cymbal.Cymbal_State;
      Phase : U32 := 0;

      Do_Strike : Boolean := False;
      Do_Init : Boolean := True;

      P1, P2 : Param_Range := 0;
   end record;

end Tresses.Drums.Macro;