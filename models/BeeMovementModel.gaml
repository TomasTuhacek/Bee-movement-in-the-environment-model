/***
* Name: BeeMovementModel
* Author: Tomas Tuhacek

* Description:
 Model of movement of bees  in the environment, created from spatial data (elevation, land cover...).
 This model describes the way bees explore the surroundings of selected origin point, when looking for food sources  based on spatial data. 
 Model can also be used to test possibility of American foulbrood (AFB) infection of bees through robbing in specified locations  


* Tags: Bee, Spatial data, AFB
***/

model BeeMovementModel


/* Initial number of bees */
global {
	int nb_bees_init <- 15;
	int nb_bees_init1 <- 17;
	int nb_bees_init2 <- 17;
	int nb_bee -> {length (bee)};
	int nb_bee1 -> {length (bee1)};
	int nb_bee2 -> {length (bee2)};

/* Spatial data location for inicialization ( Raster image file and shapefile vector grid  */	
	file map_init <- image_file("../images/ElevLandCover.png");
	file shape_file_grid1 <- file("../includes/Grid70l.shp");
    geometry shape <- envelope(shape_file_grid1);    

/*  Location of hives – needs to be specified by user (for display purposes only)  */
/*  size of input raster image in pixels, 200 x 200 by default, Insert real size of input file if default size is not used */
init{
	create bee number: nb_bees_init;
	create bee1 number: nb_bees_init1;
	create bee2 number: nb_bees_init2;
	create species:hive number:1 with:(location:{6895.000000001834,7035.000000001872});
	create species:hive1 number:1 with:(location:{6825.000000001816,7035.000000001872});
	create species:hive2 number:1 with:(location:{6965.000000001854,7035.000000001872});
	matrix init_data <- map_init as_matrix {200,200};
	create grid1 from: shape_file_grid1  {

/* Color and resistence for movement attributes calculated from input data  */	
		}
	ask elevation_cell {
			color <- rgb (init_data[grid_x,grid_y]) ;
			elev <- 1 - (((color as list)[0])/255);
 }
}

/* Save explored cells to shapefile after maximum distance of bee movement is reached( 100 cycles x 70 m cell size = 7 km)  */
/* Save folder location and name of the output file (Name of the file needs to be changed for each iteration  */
reflex save_color_value when: cycle = 100{
save elevation_cell to:"../results/ElevCor/ElevLC1.shp" type:"shp" with:[color_value::"Visited"];	
}

/*Pause simulation when bee reaches infected hive, condition needs to be changed based on the number of initializatied bees (new bee is created to pause the simulation) */
reflex pause_simulation when: (nb_bee > 15) {
		do pause;
	}

reflex pause_simulation1 when: (nb_bee1 > 17) {
		do pause;
	}
	
reflex pause_simulation2 when: (nb_bee2 > 17) {
		do pause;
	}		
	
/*Simulation pauses after after maximum distance of bee movement is reached  */
reflex stop_simulation when: (cycle = 100) {
		do pause; 
	}

/* Display values for vector grid, for validation purposes, not drawn by default */
species grid1 {
	string type;
	rgb color <- #blue ;
	
	aspect base {
		draw shape color: color ;
	}
}


/* display of hive, 3x (color and size parameters) */
species hive {
	
	float size <- 15.0;
	rgb color <- # blue;
	
	 	
	aspect base {
		draw circle(size) color: color;
	}
}

species hive1 {
	
	float size <- 15.0;
	rgb color <- # red;
	
	
	aspect base {
		draw circle(size) color: color;
	}
}

species hive2 {
	
	float size <- 15.0;
	rgb color <- #black;
	
	aspect base {
		draw circle(size) color: color;
	}
}

/*Bee display and behaviour  ( 3 types of bee, by default only color and initial location of bee is different, the behaviour may be changed depending of purpose of modeling  */
species bee  {
	float size <- 10.0;
	rgb color <- # blue;
	int infected <- 0;	
	
/* Initial location (cell's grid x a y values) */		
	elevation_cell myCell<- elevation_cell grid_at {98,100}  ;
			
	init{
		location <- myCell.location;
	}	
	
/* Definition of movement reflex  */	
	reflex basic_move { 
		myCell <-  choose_cell();
		location<- myCell.location ;
		
		}
/*Infect bee when its location is in infected hive and create bee to pause the simulation according to condition in pause_simulation reflex, then kill the infected bee so simulation may continue if necessary  */
	reflex infect when: myCell.color_value = 1 {
		create species:bee number:1 {
		}
		infected <- infected + 1;				
		}
		
		reflex infection when: infected >= 1{
			infected <- infected + 1;
		}
		
	 reflex die when: infected >=3 {
		do die;
	}
		
/* Change color_value attribute of cell to track already visited cells */		
		reflex update {
		ask bee {
			ask elevation_cell 
			{
				if(self overlaps myself)
				{
					self.color_value <- 2;
				}
			}
		}
		ask elevation_cell {
			do update_color;
		}	
	}
		
/*Momevent of agent based on values of cells */

/*Probability of choosing neigbour with higher resistence values (20 % by deafult) */	
/*Cretion of list of neigbours with higher resistence values with exlusion of already visited cells */
/*Bee moves to one of cells from the list if not empy, otherwise one of neigbours is chosen instead */
	elevation_cell choose_cell {
		if flip (0.20) {
			list<elevation_cell> Cell_up <-(myCell.neighbours) where (each.elev <= myCell.elev and each.color_value != 2 );
			if not (empty (Cell_up)){
			return one_of (Cell_up);	
			}
			else{
			return one_of (myCell.neighbours);
				}

/*Cretion of list of neigbours with lower resistence values with exlusion of already visited cells */
/*Bee moves to one of cells from the list if not empy, otherwise one of neigbours is chosen instead */
		}else {
		list<elevation_cell> Cell_down <-(myCell.neighbours) where (each.elev >= myCell.elev and each.color_value != 2 ) ;	
			if not (empty (Cell_down)){
			return one_of (Cell_down);	
			}
			else{
			return one_of (myCell.neighbours);
			}
      }
	}
/*display bee */	
	aspect base {
		draw circle(size) color: color;
	}
}

/*Bee display and behaviour  ( 3 types of bee, by default only color and initial location of bee is different, the behaviour may be changed depending of purpose of modeling  */
species bee1  {
	float size <- 10.0;
	rgb color <- # red;
	int infected <- 0;	

/* Initial location (cell's grid x a y values) */		
	elevation_cell myCell<- elevation_cell grid_at {97,100}  ;
		
	init{
		location <- myCell.location;
	}	
	
/* Definition of movement reflex  */	
	reflex basic_move { 
		myCell <-  choose_cell();
		location<- myCell.location ;
		
		}
/*Infect bee when its location is in infected hive and create bee to pause the simulation according to condition in pause_simulation reflex, then kill the infected bee so simulation may continue if necessary  */
	reflex infect when: myCell.color_value = 1 {
		create species:bee1 number:1 {
		}
		infected <- infected + 1;				
		}
		
		reflex infection when: infected >= 1{
			infected <- infected + 1;
		}
		
	 reflex die when: infected >=3 {
		do die;
	}
		
/* Change color_value attribute of cell to track already visited cells */		
		reflex update {
		ask bee1 {
			ask elevation_cell 
			{
				if(self overlaps myself)
				{
					self.color_value <- 2;
				}
			}
		}
		ask elevation_cell {
			do update_color;
		}	
	}
		
/*Momevent of agent based on values of cells */

/*Probability of choosing neigbour with higher resistence values (20 % by deafult) */	
/*Cretion of list of neigbours with higher resistence values with exlusion of already visited cells */
/*Bee moves to one of cells from the list if not empy, otherwise one of neigbours is chosen instead */
	elevation_cell choose_cell {
		if flip (0.20) {
			list<elevation_cell> Cell_up <-(myCell.neighbours) where (each.elev <= myCell.elev and each.color_value != 2 );
			if not (empty (Cell_up)){
			return one_of (Cell_up);	
			}
			else{
			return one_of (myCell.neighbours);
				}

/*Cretion of list of neigbours with lower resistence values with exlusion of already visited cells */
/*Bee moves to one of cells from the list if not empy, otherwise one of neigbours is chosen instead */
		}else {
		list<elevation_cell> Cell_down <-(myCell.neighbours) where (each.elev >= myCell.elev and each.color_value != 2 ) ;	
			if not (empty (Cell_down)){
			return one_of (Cell_down);	
			}
			else{
			return one_of (myCell.neighbours);
			}
      }
	}
/*display bee */	
	aspect base {
		draw circle(size) color: color;
	}
}

species bee2  {
	float size <- 10.0;
	rgb color <- # black;
	int infected <- 0;	
	
/* Initial location (cell's grid x a y values) */		
	elevation_cell myCell<- elevation_cell grid_at {99,100}  ;
	
	init{
		location <- myCell.location;
	}	
	
/* Definition of movement reflex  */	
	reflex basic_move { 
		myCell <-  choose_cell();
		location<- myCell.location ;
		
		}
/*Infect bee when its location is in infected hive and create bee to pause the simulation according to condition in pause_simulation reflex, then kill the infected bee so simulation may continue if necessary  */
	reflex infect when: myCell.color_value = 1 {
		create species:bee2 number:1 {
		}
		infected <- infected + 1;				
		}
		
		reflex infection when: infected >= 1{
			infected <- infected + 1;
		}
		
	 reflex die when: infected >=3 {
		do die;
	}
		
/* Change color_value attribute of cell to track already visited cells */		
		reflex update {
		ask bee2 {
			ask elevation_cell 
			{
				if(self overlaps myself)
				{
					self.color_value <- 2;
				}
			}
		}
		ask elevation_cell {
			do update_color;
		}	
	}
		
/*Momevent of agent based on values of cells */

/*Probability of choosing neigbour with higher resistence values (20 % by deafult) */	
/*Cretion of list of neigbours with higher resistence values with exlusion of already visited cells */
/*Bee moves to one of cells from the list if not empy, otherwise one of neigbours is chosen instead */
	elevation_cell choose_cell {
		if flip (0.20) {
			list<elevation_cell> Cell_up <-(myCell.neighbours) where (each.elev <= myCell.elev and each.color_value != 2 );
			if not (empty (Cell_up)){
			return one_of (Cell_up);	
			}
			else{
			return one_of (myCell.neighbours);
				}

/*Cretion of list of neigbours with lower resistence values with exlusion of already visited cells */
/*Bee moves to one of cells from the list if not empy, otherwise one of neigbours is chosen instead */
		}else {
		list<elevation_cell> Cell_down <-(myCell.neighbours) where (each.elev >= myCell.elev and each.color_value != 2 ) ;	
			if not (empty (Cell_down)){
			return one_of (Cell_down);	
			}
			else{
			return one_of (myCell.neighbours);
			}
      }
	}
/*display bee */	
	aspect base {
		draw circle(size) color: color;
	}
}

/*parameterers of grid and creation of list of elevation cells based on their real values. Width and height must correspond with input file  (line 40 of the code) */
/*cration of list of neighbours for movement and interaction (8 closest by default) */
grid elevation_cell width: 200 height: 200 neighbors:8 {
float elev <- 1 - (((color as list)[0])/255);
list<elevation_cell> neighbours <- self neighbors_at 1 ;

/* color_value attribute to track visited cells by agents*/
/* two equals visited cell and is assigned green color, value is changed by agents */
/*one equals infected hive and is assigned red color, value must be insterted manualy in simulation perspecitve for specified cell */

int color_value <- 0;
action update_color {
		if (color_value = 2) {
			color <- #green;
			
		}
		 else if (color_value = 1) {
            color <- #red;
        }
	}
 }
}

/* Experiment GUI, parameters of number of bees, Total value  should not exceed 49 due to time of calculation  */
/*display grid, bees and hives; display of vector grid is off by default, may be used  in order to check if vector and raster are correctly alligned  */
experiment BeeMovementModel type: gui {
	parameter "Initial number of bees: " var: nb_bees_init min: 0 max: 49 category: bee; 
	parameter "Initial number of bees1: " var: nb_bees_init1 min: 0 max: 49 category: bee1;
	parameter "Initial number of bees2: " var: nb_bees_init2 min: 0 max: 49 category: bee2;
	output{
		display main_display {
			grid elevation_cell ;
			species bee aspect: base ;
			species bee1 aspect: base ;
			species bee2 aspect: base ;
			species hive aspect: base ;
			species hive1 aspect: base ;
			species hive2 aspect: base ;
			/*species grid1 aspect: base;*/
		} 
	}
}