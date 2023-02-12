# AutoRotate
Project files for AutoRotate tweak hosted by BigBoss. (Most current version is in YouRepo)
A simple tweak originally made for iOS 10 to rotate the homescreen and lockscreen on devices that don't natively rotate, and for plus devices, it rotates apps and the App Switcher nicely. Additional features have been added as well with labels and the dock. Configure options from settings. The current tweak is working for iOS 10-16, all devices, with the main homescreen and lockscreen rotation working great.   Assistance with insets for the dock with stacked rotation for iOS 12 was given by @ SbhnKhrmn. 

#MOST CURRENT VERSION: You can get it from https://i0s-tweak3r-betas.yourepo.com/pack/autorotate (it's free). 
Be on the lookout for an update that fixes Widget rotation on iOS 14-16. Well, it makes them go bye bye in landscape mode and the icons space as if they were never there.  Then upon rotating back they magically reappear.  It will be an option that can be turned on or off.  Currently I have an update of ByeByeAppLibrary that has the option in it, that I should probably push. Damn I think I forgot that whole tweak on GitHub. I'll get that going soon, it's hella simple.  I don't care anymore about 
leeches (At least as much as I used to) so I'm not going to purposely hide all my best work and projects. It's kind of backwards to share only your worst code, lol. But so far that's been my GitHub, with a few exceptions. Going forward though I plan on writing a lot more code, writing a few libraries and APIs, and doing a lot less hooking.  Trying to add as much comments as possible for both newer devs and for myself when I go almost a year without touching a project,and the loss of familiarity with 
how everything was designed is the main thing holding me back from picking up where it left off.

Made this tweak open source hoping to get help improving the little nuances that still act up on devices that don't support normal rotation, with app rotation.
I have since added rotation of most apps like iPAD, but for compact devices some apps aren't supported. You can just turn it off if it doesn't work right in the app you're using until I get the App Rotation working right for all device types, or just skip that option.  On iOS 14 it rotates HS widgets, though they rotate a little differently. Just updated the code so you have an idea where it's at, and am open for contributors if anyone wants to help.  




ToDo:  Add new code written in ByeByeAppLibrary that makes homescreen rotation way cleaner.
Work on icon scale when rotated, and it would be cool to add customized insets for the layoutConfigurations, and to bring back the (up to) 12 Icon dock, that was a working feature in iOS 11-13.

