local defaults =

{
   Status               =   nil;
   Window_Flags         =  bit.bor(ImGuiWindowFlags_NoDecoration);
   Fishing               =  {
      show              =  false;
      skill               =  nil;
      alltime           =  {
         casts            =  0;
         fish            =  0;
         item            =   0;
         gil            =   0;
         rodBreak         =   0;
         lineBreak      =   0;
         canceled         =   0;
         lost           =  0;
         noCatch         =   0;
         monster         =   0;
         history         = {};
      };
      session           =  {
         casts            =   0;
         fish            =   0;
         item            =   0;
         gil            =   0;
         rodBreak         =   0;
         lineBreak      =   0;
         canceled         =   0;
         lost           =  0;
         noCatch         =   0;
         monster         =   0;
         gph            =  {
            value       =  0;
            sum         =  0;
            timeOut     =  60;
            totalTime   =  0;
            lastAction  =  0;
         };
         history         =  {};
      };
      customPrices      =  {};
   };
   editItem             =  {
      show              =  false;
      id                =  0;
      name              =  '';
      oldValue          =  0;
      newValue          =  { 0 };
   };
   trackAllSkills       =  false;
};

return defaults