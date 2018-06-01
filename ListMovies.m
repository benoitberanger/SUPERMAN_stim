function [ list , ext ]= ListMovies()

ext = '.mp4';

Cuisine = { 'Datcha'             ; 'Imbroisi'       };
F1      = { 'Mexique_Grand_Prix' ; 'USA_Grand_Prix' };
Nature  = { 'Smoky_mountain'     ; 'Yellowstone'    };

%--------------------------------------------------------------------------

list = struct;

list.Cuisine = Cuisine;
list.F1      = F1;
list.Nature  = Nature;

end % function
