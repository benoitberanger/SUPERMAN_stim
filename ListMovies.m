function [ list , ext ]= ListMovies()

ext = '.mp4';

Cuisine = { 'Datcha'             ; 'Imbroisi'       };
F1      = { 'Grand_Prix_Mexique' ; 'Grand_Prix_USA' };
Nature  = { 'Smoky_mountain'     ; 'Yellowstone'    };

%--------------------------------------------------------------------------

list = struct;

list.Cuisine = Cuisine;
list.F1      = F1;
list.Nature  = Nature;

end % function
