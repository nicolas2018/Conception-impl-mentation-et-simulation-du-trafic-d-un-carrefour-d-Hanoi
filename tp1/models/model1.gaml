 
model traffic
 
global {  
	
	//IMPORTATION DES FICHIERS SHAPEFILE 
	file shape_file_roads  <- file("../includes/roads/routes.shp") ;
	file shape_file_building  <- file("../includes/roads/buildings.shp") ;
	file shape_file_environnement <- file("../includes/roads/environnement_limitation.shp") ;
	file shape_file_debut <- file("../includes/roads/debut.shp") ;
	file shape_file_fin <- file("../includes/roads/fin.shp") ;
	geometry shape <- envelope(shape_file_environnement);
	
	//DECLARATION DES PARAMETRES
	int nombre_voiture<-30 parameter:'Nombre de voitures' category:'voiture' min:30 max:100;
	int taille_voiture<-25 parameter:'Taille de la voiture' category:'voiture'min:10 max:100;
	float vitesse_actuelle<-20°km/°h parameter: 'Vitesse actuelle de la voiture'category:'voiture';
	float vitesse_max_voiture<-60°km/°h parameter:'Vitesse maximale de la voiture' category:'voiture';
	
	int intensite<-30 parameter:'Intensité des moyens de transports' category:'voiture'min :10 max:50;
	graph graphe_route;  
	
	 //INITIALISATION
	init{  
			create immeubles from:shape_file_building;
			create routes from: shape_file_roads with:[nbLanes::int(read("lanes"))] {	}
			create apparution_voitures  from:shape_file_debut;	
			create destination_des_voitures from:shape_file_fin;	
			graphe_route <- (as_edge_graph(routes)) ;
		
			
	}
	//CREATION DES AGENTS VOITURES
		reflex creation_voiture when : every(intensite){
			create voiture number: nombre_voiture  { 
				speed <- vitesse_actuelle ;
				target <-one_of(destination_des_voitures);
				location <- any_location_in(one_of(apparution_voitures ));
				lanes_attribute <- "nbLanes";
				obstacle_species <- [species(self)]; 
				image<-("../images/voiture.jpg");
			}   
		}
} 

//CREATION DES ENTITES
entities{
	species routes  { 		
		int nbLanes;
		aspect basic {    
			draw shape color: rgb("black") ;
		} 
	}
	
	species apparution_voitures  { 		
		aspect basic {    
			draw shape color: rgb("black") ;
		} 
	}
	
	species destination_des_voitures  { 		
		aspect basic {    
			draw shape color: rgb("black") ;
		} 
	}
	
	species immeubles  { 		
		aspect basic{    
			draw shape color: rgb("grey") ;
		} 
	}
	
	species voiture skills: [driving] { 
		float speed; 
		point target <- nil ; 
		file image;
		
		reflex Deplacement{
			speed<-vitesse_actuelle;
			do goto_driving target:target on:graphe_route;
			switch location {
				match target {
					do action:die;
				}									
			}
		}	
		aspect basic {
				draw image size:(taille_voiture) rotate:heading;
			}
		}
	}	

experiment traffic type: gui {
		
	output {
			display "Traffic d'un carrefour de Hanoi" refresh_every: 1 {
				species routes aspect: basic;
				species apparution_voitures  aspect: basic;
				species destination_des_voitures aspect: basic;
				species immeubles aspect: basic ;
				species voiture aspect: basic;
			}
	}
}

