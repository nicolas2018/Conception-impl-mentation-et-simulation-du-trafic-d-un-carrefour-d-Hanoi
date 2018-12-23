/**
 *  model2
 *  Author: Nicolas OUBDA
 *  Description: 
 */

model model2
 
global {  
	
	//IMPORTATION DES FICHIERS SHAPEFILE 
	file shape_file_roads  <- file("../includes/roads/routes.shp") ;
	file shape_file_building  <- file("../includes/roads/buildings.shp") ;
	file shape_file_environnement <- file("../includes/roads/environnement_limitation.shp") ;
	file shape_feux1 <- file('../includes/roads/feux1.shp');
	file shape_feux2 <- file('../includes/roads/feux2.shp');
	file shape_feux3 <- file('../includes/roads/feux3.shp');
	file shape_feux4 <- file('../includes/roads/feux4.shp');
	file shape_file_debut <- file("../includes/roads/debut.shp") ;
	file shape_file_fin <- file("../includes/roads/fin.shp") ;
	file shape_file_stopFeu <- file("../includes/roads/stopFeux.shp") ;
	geometry shape <- envelope(shape_file_environnement);
	
	//DECLARATION DES PARAMETRES
	int nombre_voiture<-2 parameter:'Nombre de voitures' category:'voiture' min:2 max:100;
	int taille_voiture<-25 parameter:'Taille de la voiture' category:'voiture'min:10 max:100;
	float vitesse_actuelle<-20°km/°h parameter: 'Vitesse actuelle de la voiture'category:'voiture';
	float vitesse_max_voiture<-100°km/°h parameter:'Vitesse maximale de la voiture' category:'voiture';
	float vitesse_max_route<-60°km/°h parameter:'Vitesse maximale de la voiture' category:'voiture' min:50°km/°h max:120°km/°h;
	int intensite<-25 parameter:'Intensité des moyens de transports' category:'voiture'min :10 max:50;
	graph graphe_route;  
	
	//DUREE DES FEUX TRICOLORES
	int duree_feux_rouge<-30 parameter:'Durée du feu rouge' category:'feux1';
	int duree_feux_vert<-25 parameter:'Durée du feu vert' category:'feux1';
	int duree_feux_jaune<-5 parameter:'Durée du feu jaune' category:'feux1';
	int cycle_feux<-0;
	int cycle_feux2<-0;
	int cycle_feux3<-0;
	int cycle_feux4<-0;
	bool verification_feux<-false; 
	bool voiture_sur_ligne_stop<-true;
	
	 //INITIALISATION
	init{  
			create buildings from:shape_file_building;
			create road from: shape_file_roads with:[nbLanes::int(read("lanes"))] {	}	
			create debut_apparution_des_voitures from:shape_file_debut;	
			create fin_destination_des_voitures from:shape_file_fin;	
			graphe_route <- (as_edge_graph(road)) ;
			create feux1 from: shape_feux1;  
			create feux2 from: shape_feux2;  
			create feux3 from: shape_feux3; 
			create feux4 from: shape_feux4;
			create stopFeu from: shape_file_stopFeu;  
	}
	
	//CREATION DES AGENTS VOITURES
		reflex creation_voiture when : every(intensite){
			create voiture number: nombre_voiture  { 
				speed <- vitesse_actuelle ;
				target <-one_of(fin_destination_des_voitures);
				location <- one_of(debut_apparution_des_voitures);
				lanes_attribute <- "nbLanes";
				obstacle_species <- [species(self)]; 
				image<-("../images/voiture.jpg");
			}   
		}
} 

//CREATION DES ENTITES
entities{
	species road  { 		
		int nbLanes;
		aspect basic {    
			draw shape color: rgb("black") ;
		} 
	}

	species debut_apparution_des_voitures{ 		
		aspect basic {    
			draw shape color: rgb("grey") ;
		} 
	}
	
	species stopFeu{ 		
		aspect basic {    
			draw square(5) color: rgb("red") ;
		} 
	}
	
	species fin_destination_des_voitures{ 		
		aspect basic {    
			draw circle(3) color: 'green';
		} 
	}
	
	species buildings  { 		
		aspect basic{    
			draw shape color: rgb("grey") ;
		} 
	}
	
	species voiture skills:[driving] { 
		float speed<-nil; 
		point target <- nil ; 
		file image;
		bool feu1_est_rouge<-false;
		bool  feu2_est_rouge<-false;
		bool  feu3_est_rouge<-false;
		bool  feu4_est_rouge<-false;
		 
		reflex depart_feu_vert {
			ask feux1{
				if(color=#green and myself.feu1_est_rouge){
					myself.speed<-vitesse_actuelle;
				}
			}
			ask feux2{
				if(color=#green and myself.feu2_est_rouge){
					myself.speed<-vitesse_actuelle;
				}
			}
			ask feux3{
				if(color=#green and myself.feu3_est_rouge){
					myself.speed<-vitesse_actuelle;
				}
			}
			ask feux4{
				if(color=#green and myself.feu4_est_rouge){
					myself.speed<-vitesse_actuelle;
				}
			}
		}
		
		reflex feu_rouge_imobillisation_voiture{
			
			ask feux1{
				float distance_feux1<- myself distance_to self;
				
				if(distance_feux1>=23 and distance_feux1<=25 and (color=#red or color=#yellow)){
					myself.speed<-0;
					myself.feu1_est_rouge<-true;
				}
			}
			
			ask feux2{
				float distance_feux1<- myself distance_to self;
				float vitesse_actuelle<-myself.speed;
				if(distance_feux1>=15 and distance_feux1<=20 and (color=#red or color=#yellow)){
					myself.speed<-0;
					myself.feu2_est_rouge<-true;
				}

			}
			
			ask feux3{
				float distance_feux1<- myself distance_to self;
				float vitesse_actuelle<-myself.speed;
				if(distance_feux1>=15 and distance_feux1<=20 and (color=#red or color=#yellow)){
					myself.speed<-0;
					myself.feu3_est_rouge<-true;
				}
			}
			
			ask feux4{
				float distance_feux1<- myself distance_to self;
				float vitesse_actuelle<-myself.speed;
				if(distance_feux1>=1 and distance_feux1<=10 and(color=#red or color=#yellow)){
					myself.speed<-0;
					myself.feu2_est_rouge<-true;
				}
			}
		}
		
		reflex Deplacement{
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
		
//Espèces FEUX N°1
	species feux1 skills:[] control:fsm{
		rgb color <- rgb('red') ;
		int compter_temps_feu<-duree_feux_rouge;
		
		state startup initial:true{
			transition to : changement_etat_feu when: cycle_feux=0;
		}

		action feux1_rouge {
		 	set color<-#red;
		 	set verification_feux<-true;
		 	compter_temps_feu<-duree_feux_rouge;
		 	cycle_feux <- 0;		 	
		}
				
		action feux1_vert {
			set verification_feux<-false;
 		 	set color<-#green;
 		 	compter_temps_feu<-duree_feux_vert;
		}
		
		action feux1_jaune {
 		 	set color<-#yellow;
 		 	compter_temps_feu<-duree_feux_jaune;
		}	
		
		state changement_etat_feu{
			cycle_feux <- cycle_feux+1;
			compter_temps_feu<-compter_temps_feu-1;
			if(cycle_feux=(duree_feux_vert+duree_feux_rouge+duree_feux_jaune)){
			do action:feux1_rouge;
			}
			if(cycle_feux=duree_feux_rouge){
			do action:feux1_vert;
			}
			if(cycle_feux=duree_feux_vert+duree_feux_rouge){
		 	do action:feux1_jaune;}
		}
		aspect basic {
			draw circle(8) color: color ;
		draw text: string(compter_temps_feu) at:location+ point(-2.5,4) color: rgb('black') size: 10.8 ;
		}

}	
//FEUX N°2
species feux2 skills:[] control:fsm{
		rgb color <- rgb('green') ;
		int compter_temps_feu2<-duree_feux_vert;
			state startup initial:true{
			transition to : changement_etat_feu when: cycle_feux2=0;
		}

		action feux2_rouge {
		 	set color<-#red;
		 	compter_temps_feu2<-duree_feux_rouge; 	
		}
				
		action feux2_vert {
 		 	set color<-#green;
 		 	cycle_feux2 <- 0;
 		 	compter_temps_feu2<-duree_feux_vert; 			
		}
	
		action feux2_jaune {
 		 	set color<-#yellow;
 		 	compter_temps_feu2<-duree_feux_jaune; 	
		}	
		
		state changement_etat_feu{
			cycle_feux2 <- cycle_feux2+1;
			compter_temps_feu2<-compter_temps_feu2-1; 	
			if(cycle_feux2=(duree_feux_vert+duree_feux_rouge+duree_feux_jaune)){
			do action:feux2_vert;
			}
			if(cycle_feux2=duree_feux_vert){
			do action:feux2_jaune;
			}
			if(cycle_feux2=duree_feux_jaune+duree_feux_vert){
		 	do action:feux2_rouge;}
		}
		aspect basic {
			draw circle(8) color: color ;
		draw text: string(compter_temps_feu2) at: location + point(-2.5,5) color: rgb('black') size: 10.8 ;
		}

}	

//FEUX N°3
species feux3 skills:[] control:fsm{
		rgb color <- rgb('red') ;
		int compter_temps_feu3<-duree_feux_rouge;
			state startup initial:true{
			transition to : changement_etat_feu when: cycle_feux3=0;
		}

		action feux3_rouge {
		 	set color<-#red;
		 	set verification_feux<-true;
		 	cycle_feux3 <- 0;
		 	compter_temps_feu3<-duree_feux_rouge;		 	
		}
				
		action feux3_vert {
 		 	set color<-#green;
 		 	compter_temps_feu3<-duree_feux_vert;
		}
		
		action feux3_jaune {
 		 	set color<-#yellow;
 		 	compter_temps_feu3<-duree_feux_jaune;
		}	
		state changement_etat_feu{
			cycle_feux3 <- cycle_feux3+1;
			compter_temps_feu3<-compter_temps_feu3-1;
			if(cycle_feux3=(duree_feux_vert+duree_feux_rouge+duree_feux_jaune)){
			do action:feux3_rouge;
			}
			if(cycle_feux3=duree_feux_rouge){
			do action:feux3_vert;
			}
			if(cycle_feux3=duree_feux_vert+duree_feux_rouge){
		 	do action:feux3_jaune;}
		}
		aspect basic {
			draw circle(8) color: color ;
		draw text: string(compter_temps_feu3) at: location + point(-3,5) color: rgb('black') size: 8 ;
		}

}	

//FEUX N°4
species feux4 skills:[] control:fsm{
		rgb color <- rgb('green') ;
		int compter_temps_feu4<-duree_feux_vert;
			state startup initial:true{
			transition to : changement_etat_feu when: cycle_feux4=0;
		}

		action feux4_rouge {
		 	set color<-#red; 	
		 	compter_temps_feu4<-duree_feux_rouge;
		}
				
		action feux4_vert {
 		 	set color<-#green;
 		 	cycle_feux4 <- 0;	
 		 	compter_temps_feu4<-duree_feux_vert;
		}
	
		action feux4_jaune {
 		 	set color<-#yellow;
 		 	compter_temps_feu4<-duree_feux_jaune;
		}	
		
		state changement_etat_feu{
			cycle_feux4 <- cycle_feux4+1;
			compter_temps_feu4<-compter_temps_feu4-1;
			if(cycle_feux4=(duree_feux_vert+duree_feux_rouge+duree_feux_jaune)){
			do action:feux4_vert;
			}
			if(cycle_feux4=duree_feux_vert){
			do action:feux4_jaune;
			}
			if(cycle_feux4=duree_feux_jaune+duree_feux_vert){
		 	do action:feux4_rouge;}
		}
		aspect basic {
			draw circle(8) color: color ;
		draw text: string(compter_temps_feu4) at: location +point(-2.5,5) color: rgb('black') size: 10.8 ;
		}

	}	
}

experiment traffic type: gui {
		
	output {
			display "Traffic d'un carrefour de Hanoi" refresh_every: 1 {
				species road aspect: basic;
				species buildings aspect: basic ;
				species voiture aspect: basic;
				species feux1 aspect: basic;
				species feux2 aspect: basic;
				species feux3 aspect: basic;
				species feux4 aspect: basic;
				species debut_apparution_des_voitures aspect: basic;
				species fin_destination_des_voitures aspect: basic;
				species stopFeu aspect: basic;
			}
	}
}

