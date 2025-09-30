require('common')

local defaults = T{
   Status                  =  nil;
   Window_Flags            =  bit.bor(ImGuiWindowFlags_NoDecoration);
   Fishing                 =  T{
      show                 =  false;
      skill                =  nil;
      alltime              =  T{
         casts             =  0;
         fish              =  0;
         item              =  0;
         gil               =  0;
         rodBreak          =  0;
         lineBreak         =  0;
         canceled          =  0;
         lost              =  0;
         noCatch           =  0;
         monster           =  0;
         history           =  T{};
      };
      session              =  T{
         casts             =  0;
         fish              =  0;
         item              =  0;
         gil               =  0;
         rodBreak          =  0;
         lineBreak         =  0;
         canceled          =  0;
         lost              =  0;
         noCatch           =  0;
         monster           =  0;
         gph               =  T{
            value          =  0;
            sum            =  0;
            timeOut        =  60;
            totalTime      =  0;
            lastAction     =  0;
         };
         history           =  T{};
         skill             =  0;
         lastCatch         =  0;
      };
      customPrices         =  T{};
   };
   editItem                =  T{
      show                 =  false;
      id                   =  0;
      name                 =  '';
      oldValue             =  0;
      newValue             =  { 0 };
   };
   options                 =  T{
      show                 =  false;
      timeout              =  60;
      timeoutInput         =  { 1 };
      tracking             =  { 1 };
      clrSession           = { false };
      choices              = 'Fishing\0All Crafting\0None\0\0';
   };
};

return defaults;