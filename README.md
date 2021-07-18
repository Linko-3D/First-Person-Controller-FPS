#  First Person Controller (FPS)

YouTube video: https://youtu.be/o2-Va100omc

This is a First Person Controller inspired by Half Life 2 and Counter Strike Global Offensive. You can instance abilities as a child of the Camera node of the player (shooting, grabbing, etc).
The basic Player script support snapping on slopes until an angle of 45 degrees. It works with QWERTY and AZERTY keyboards and joysticks. The character always run, you can use Shift or L2 to walk and Control or B from the joystick to crouch.
Everything is animated using tweens allowing you to edit the animations easily.

Everything is under MIT license apart for the 3D models and sounds, but they are royalty free. You must credit the author or share the source if you use them. Here are the sources:
- AK-47 model by TastyTony: https://sketchfab.com/3d-models/low-poly-ak-47-type-2-a7260926fb0a40f8bba5f651b03d23f1
- M1911 model by TastyTony: https://sketchfab.com/3d-models/low-poly-m1911-117f542d21954ae0a59afaedadcff338
- Gun fire sound by GoodSoundForYou: https://soundbible.com/1998-Gun-Fire.html
- Shell falling sound by Marcel: https://soundbible.com/2072-Shell-Falling.html
2:52 PM 7/18/2021
For additional resources you can download 400 low poly creative commons weapons here, you just need to credit TastyTony: https://sketchfab.com/TastyTony 

Impact, footsteps and flashlight button: https://www.fesliyanstudios.com/

Here are all the abilities available:

- Shoot: it will add the ability to shoot with the left-click or L2 from a controller. And to reload with R or with the X button of an Xbox controller. You can switch weapons with the mouse wheel, number of your keyboard or the directional pad of the joystick. It supports recoil (you lose accuracy with the fire rate and movement speed), camera shake, weapon bobbing adjusted with the player's movement speed, weapon sway. A shell is spawned at each shot. There are multiple sounds and the pitch is randomly modulated. The shooting sound has an echo.

- Crosshair: it is animated, it gets wider depending on the player's movement speed.

- Flashlight: a flashlight that you can toggle On and Off by pressing f or L1, it has two placeholder sounds with random pitch.

- FootstepSound: plays a footstep sound randomly, the pitch is set randomly too for less repetition. The volume and rate are adjusted depending on the player's movement speed. When after falling a louder sound is played.

- Grab: allows grabbing a RigidBody under 50 kg with the E key or the Y button of an Xbox controller. You can drop it with the same key or throw it with the shoot key. The game displays a message when you can grab an object.

- Minimap: it displays in the top left corner the player from the top.

It has a royalty-free font used for the HUD of the FPS.

It includes a pause singleton. Import Pause.gd in Project > Project Settings... and in the AutoLoad tab. This singleton will allow pausing the game with the escape key. You can then resume it with the left-click or leave it by pressing escape again.