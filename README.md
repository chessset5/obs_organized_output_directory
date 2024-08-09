# Organized Output Directory

With "Organized Output Directory" you can create order in your output directory.
The script automatically creates subdirectories for each game in the output directory.
To do this, it searches for Window Capture or Game Capture sources in the current scene.
The last active and hooked source is then used to determine the name of the subdirectory from the window title or the process name.

# 📋 Requirements
* Windows 10/11
* OBS 29.0.0

---
<br>

<!-- ![Screenshot](assets/screenshot_v1.0.3[cropped].jpg){width=300px height=200px} -->
<img src="assets/screenshot_v1.0.3[cropped].jpg" alt="Image of Organized Output Directory OBS Script Description" width="300">


# 🏗️ Known Issues / Planned Features

- Some kind of rule/wildcard/match system would be useful.<p>
  Some games/apps like Minecraft are a little tricky. The window title contains the current game version like `Minecraft 1.20.4` and the process name is something like `javaw.exe`. With a rule/wildcard/match system, we could change the name and remove the version from the window title, for example.

- Currently only Windows is supported. I would like to get the script running on Linux and MacOS as well. *Currently MacOS does not have an application or window capture functionality in OBS. Linux has not been tested.*


# 👑 Credits
**🧑‍💻 Author:** Tobias Lorenz [GitHub](https://github.com/MrMartin92) [Twitch](https://twitch.tv/MrMartin_)<br>
**🧑‍💻 Contributor:** Aaron Shackelford [GitHub](https://github.com/chessset5?tab=repositories) [Twitch](https://www.twitch.tv/chessset5)<br>
**🔬 Source:** [GitHub.com](https://github.com/MrMartin92/obs_organized_output_directory)<br>
**🧾 Licence:** [MIT](https://raw.githubusercontent.com/MrMartin92/obs_organized_output_directory/main/LICENSE)<br>
