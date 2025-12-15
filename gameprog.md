
# Information
## Group names
- Christian Hegna Langedok - clangedok
- Rahul Anand - Rahul1epic
- Simen Hauger Wilberg - Nemis234
- Bao Mark Nguyen - Sifyoyo



All the code for the project can be found here in this repository:\
https://github.com/Nemis234/IMT3603-AI-Sim/tree/Godot-Frontend

The link to the video showing off our game: 
https://youtu.be/Cz0zDeAIzuE\


# Development process
## Godot

There were two main reasons why we chose Godot as our game engine of choice: its strong 2D capabilities and its ease of use. As our group had limited prior experience in game programming before the course, Godot was particularly appealing to us since it does not have a steep learning curve unlike game engines such as Unreal Engine. This allowed us to follow along the lectures and not fall behind. It also allowed us to begin working on the project as quickly as possible. Additionally, we chose to develop a 2D game for our project and since Godot is well known for its strong 2D features and tools, making it an ideal choice of game engine.

Godot has some noticeable weakness, such as limited asset stores and helpful informations such as forums might be limited aswell. This is due to Godot being a new game engine and did not go open-source until 2014. But since our project did not rely on many assets we managed to work around this weakness using itch.io's free asset market. As for information about the game engine we found out that the official documentation was more than sufficient for our implementations.


## Communication

We used Discord for all of our communication, like meetings and other requests/questions. This worked well as having a specific platform we could share information on made it easy to track progress of the project development.

We started off by delegating different roles, like big parts of the game, to different people. This evolved over time when different components became more substantial than others, and some people had to move to help.

### Christian

- **Main:** Inventory system
- UI popup menus
- Docker
- Furniture interactions
- Player interactions
- Furniture design
- Level design (map, houses/buildings, house/building interior)

### Mark

- **Main:** AI - Agent behavior (Godot side)
- Agent pathfinding
- Agent actions
- Agent animations
- Agent collisions
- Agent interaction logics with furnitures
- Level design (map ,hills, trees, rocks, houses, house interior)
- Level navigation layers and collision layers
- Furniture design
- Day and Night cycle

### Rahul

- **Main:** AI - Agent Memory 
- **Main:** Player logic and base player interaction logic
- Agent Reflections
- Save state and save menu

### Simen

- **Main:** Backend API, backend to frontend connections
- **Main:** AI
- AI prompting
- Agent to Agent interactions
- Agent to User interactions (chatting)
- Code cleanup/support

### Tiago

- **Main:** Character Menu
- Design of certain buildings, (specifically, the Beachside Cafe, Cruz estate, Mayor's office, and the school)
- Minor collision fixes
- Few character descriptions


To distribute tasks we mainly divided them using Discord DMs when things were needed. The main organizer of this was Rahul, who took up the leadership role.


### Losing a group member
One person on the team, Tiago, left 2 weeks before the deadline. Although he was  valuable and enthusiastic in providing good ideas to the game and general brainstorming in the early stages, the key tasks he was assigned to at the end were left partially incomplete, unpolished, and with bugs. 

As a consequence, this resulted in restructuring our roles and readjusting our priorities for the remaining short duration of the project. Thus, we had to pick up some of the tasks that was assigned to Tiago initially, as well as make certain modifications to the best of our ability. These included the following:

- Certain building assets and areas were thrown into the map oddly/abruptly with no real purpose or significance to our game. Further, these buildings did not possess any interiors. We decided to remove those areas and buildings that were added.
- Tiago added four buildings with interiors - the Beachside cafe, Cruz estate, Mayor's office, and the school. However, these buildings didn't possess much significance. Thus, to add significance to them, we allowed agents to possibly visit these buildings i.e., we added these buildings to the list of locations the LLM can choose from. Further, we added the agents Rafael and Ethan who work at the Mayors office (as the mayor) and Beachside cafe (as a chef) respectively. We assigned Mei to work at the school. We also added an additional pharmacy building where John works at.
- The interior of the above buildings lacked walkable tiles which we added accordingly. We also edited certain interiors to add walkable tiles and certain objects more easily.
- A large number of tilemap related errors and warnings unexpectedly arose when these buildings were initially added. We effectively resolved these.

Even though this unfortunate situation slowed down our progress and resulted in a few features being dropped from the final product, we were all able to quickly adapt and efficiently resolve and majority of issues and pending tasks. However, some minor remanents of the issues still persist.


## Git / version control

We used GitHub for both storing our Git repository, and keeping track of issues, branches and commit history. 

Our GitHub repository comprises of these branches: 

### Godot-Frontend

- This was the major branch of our project. The following initial features were developed:
  - The main map: The standard layout of the map including exterior map environment, houses/buildings and their interiors.
  - The main agent logic with path finding 
  - Standard player design

It became the only branch for all development. Usually the structure of using git is to branch development depending on the different issues, or in some cases each developer has their own branch where they keep their development. We started having several branches for each aspect of the project. Because of issues around merging and time we ended up having the Godot-Frontend branch as the only one for development.

### AI_branch:

- This was the branch was used to set up the initial AI backend and the vector database.
- This was initially done to separate the AI-integration from the main game so each component can be tested separately.
- Since handling the numerous merge conflicts became quite a hassel as the project expanded, we later pulled all the updates from this branch to the Godot-Fronted branch and continued further AI developments in Godot-Fronted .
