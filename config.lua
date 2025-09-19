local config = {};

config.Status				         =	nil;
config.Window_Flags			   	=	bit.bor(ImGuiWindowFlags_NoDecoration);
config.fishHistory			      = {};
config.fishTracker			      = {
      show                       = false;
      stats				            = {
         casts			            = 0;
         fish			            = 0;
         item			            = 0;
         gil				         = 0;
         rodBreak		            = 0;
         lineBreak		         = 0;
         canceled		            = 0;
         noCatch			         = 0;
         monster			         = 0;
   }
};

return config