# Highrise Studio Example Scenes

Each subfolder contains serializations and scripts for an example Highrise Studio scene. You can use these scenes as a reference when trying to solve the user's problems. Each subfolder contains an `active_scene.json` file that is the serialization of the scene, and an `Assets/` folder that contains any scripts and prefab serializations the scene uses.

## `simple-bedroom/`

A small room with a lofted bed, a sofa, a TV, and some other furniture. Key functions:
- Vertical navigation: the player can walk up a set of steps to the lofted bed.
- Multi-spot seating: the player can sit on the sofa in one of three different positions.
- Light sources: the TV, a cell phone prop, and several lamps illuminate the room.

## `2d-platformer/`

A world with a side-view camera where players walk along and jump between platforms. Key functions:
- Player-following camera: the camera smoothly pans to center the player as they move.
- Jump links: the player can jump between disconnected platforms.
- Parallax background: background elements move at different speeds as the camera pans to create a sense of depth.

## `obstacle-course/`

A world that the player must navigate through by avoiding obstacles (moving platforms, swinging cubes, dangerous walls, etc.) and reaching checkpoints. Key functions:
- Checkpoints: collidables that update the player's progress and where the player returns if they die.
- Death triggers: Nav Mesh modifiers that cause the player to revert to a checkpoint if they make contact.
- Particle effects: particles are emitted when the player reaches the finish zone.