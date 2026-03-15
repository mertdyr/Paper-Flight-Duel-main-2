Paper Flight Duel

## About the Project

Paper Flight Duel is a competitive 2D platformer designed for two players, where the objective is to achieve the highest score by skillfully throwing paper airplanes and winning the match. This project was developed as part of the "Einführung in digitale Spiele 25/26" (EIDS_2526) module.
+1

## Gameplay & Rules

**Turn-Based System:** The game is played alternately by two players, with each player taking their throws one after the other. A round is completed once both players have made three throws.
+1

**Winning Condition:** The game operates on a "Best-of-Three" principle. The winner of a round receives one point towards the total score. The match concludes after two or at most three rounds , and the final result alongside the winner's name is clearly displayed on the screen.
+3

**Difficulty Levels:** There are three difficulty modes available: Easy, Medium, and Hard. As the difficulty increases, the oscillation speed of the directional aiming arrow (ranging from -80° to -10°) and the dynamics of the power bar (ranging from 200 to 1500 units) also increase. This mechanic demands increasingly precise reaction times for the throw.
+2

## Flight Mechanics & Dynamic Systems

**Physics Engine:** The flight physics are engineered for realistic yet accessible behavior, utilizing a gravity scale of 0.3 and a mass of 0.1 kg.

**Boost System:** Players can activate a boost system during flight by pressing the 'W' key. Each launch starts with 100% fuel capacity, which is consumed rapidly at a rate of 90% per second upon activation.
+1

**Collectible Items:** Dynamic items have a 50% probability of spawning in the air every 500-1000 meters. Collecting a red gas can replenishes fuel by 15%, while a yellow lightning bolt grants an immediate 1.5x speed multiplier.
+1

## Controls

**Spacebar:** Used to confirm the angle and power, and to execute the throw.

**W Key:** Used to activate and control the boost during the flight.

## Visual & Audio Design

**Player Differentiation:** To ensure clear visual distinction, Player 1 is represented by a black paper airplane, and Player 2 is represented by a yellow paper airplane.

**Dynamic Environment (Y-Axis):** As the airplane gains altitude on the Y-axis, the blue tone of the sky dynamically darkens, transitioning from daylight blue to deep space black.

**Dynamic Environment (X-Axis):** The ground biome changes based on the horizontal distance traveled. From 0-3000m, the environment is green grassland with trees. From 3000-6000m, it transitions into a yellow desert featuring pyramids. Beyond 6000m, it changes to white snow and ice, featuring igloos to represent polar regions.
+4

**Audio Engineering:** The gameplay experience is enhanced by five distinct sound effects. These include a specific throw sound, a continuous ambient sound during flight, two distinct sounds for the boost types, and a final landing effect.
+1

**User Interface (UI):** The UI displays real-time flight data on the top left, and tournament information on the right, including round scores, current total distances, and a throw counter.
+1

## Development Team

Ahmet Emre Filiz 

Kıvanç Mazlumoğlu 

Osman Mert Duyar
