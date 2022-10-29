package Tresses.Interfaces
with Preelaborate
is

   type Pitched_Voice is interface;

   procedure Set_Pitch (This  : in out Pitched_Voice;
                        Pitch :        Pitch_Range)
   is abstract;

   type Strike_Voice is interface;

   procedure Strike (This : in out Pitched_Voice)
   is abstract;

   type Two_Params_Voice is interface;

   procedure Set_Param1 (This : in out Pitched_Voice; P : Param_Range)
   is abstract;

   procedure Set_Param2 (This : in out Pitched_Voice; P : Param_Range)
   is abstract;

end Tresses.Interfaces;