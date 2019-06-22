# 4cc AET Compiler
Organizes the contents of aesthetic exports for the 4chan cup and packs them into DLC files for Pro Evolution Soccer

- Setting up
- Simple mode
- Advanced mode
- About the export format
- Troubleshooting


## Setting up

Open the settings txt file and set fox mode depending on whether you're packing
aesthetics for PES16/17 or for PES18. You don't normally have to edit any of the
other settings, but feel free to take a look.


## Simple mode

Read this if you're just packing /yourteam/'s export to test it on PES.

First of all you need to make sure that the team names of the exports you're
importing are listed on the teams_list.txt file of the compiler, next to the
Team IDs assigned to them. If they aren't then write them in.

Then put the exports in the exports_to_add folder (folders or zip are both
fine) and run the 0_all_in_one script. A cpk will be created and copied
automatically to your PES download folder, if you installed PES to the default
location. Otherwise, the settings file will be opened so you can set the
correct folder path.

The face folders inside the Faces folder of the exports must be named as the
player IDs they're for, in the XXXxx format, where xx is the player number
(from 01 to 23), and they should preferably only contain the face files.

The XXX can be literally anything three characters long, for example an old team
ID, the current one or simply XXX (recommended), since the compiler will ignore it
and replace it with the proper team ID it finds by looking for the team name on
the teams_list file. This is done on all of the export's files and folders.
This means you can use old exports from previous invitationals without renaming
anything manually.

After the cpk has been compiled and copied, the entries needed for PES to load it
will be added automatically to the DpFileList file, so you can just open PES and
check your stuff.

Check the Troubleshooting section at the bottom if you run into trouble.


## Advanced mode

Read this if you're making DLC for a cup or want to use the compiler to its full
potential.

Make sure to read the settings file for further customization options.
A thorough description of the four main scripts follows.

### 1_exports_to_extracted

This script extracts the exports (exports both in folder or zip/7z format are
fine) located in the exports_to_add folder into the extracted_exports folder,
then checks them for typical errors, discarding the whole export or parts of it
if it finds any.
It also makes a file named memelist.txt with the list of problems it found,
and pauses at every error unless the pause setting has been disabled in the
settings file.

Here's a list of the stuff that the script checks after extracting an export,
before moving its content into three common folders:
- Checks that the team name is in the teams_list file, and looks for the team ID.
- Checks for nested folders with repeating names (e.g. GD export/Faces/Faces),
  unless it's the Other or Common folder, and tries to fix them by moving the
  folders down by one layer.
- Checks that the face folders follow the format "XXXxx", where xx is between
  01 and 23. XXX can be anything as long as it's three characters long.
- Checks that the face folders have the essential face.xml file inside, and that
  none has the unsupported face_edithair.xml inside. In fox mode, it checks for
  the presence of the face.fpk.xml file instead.
- Checks that the Faces folder doesn't have any extra nonfolder files (like cpks)
  in it.
- Checks that the kit config files and the kit texture files follow the proper
  naming convention as defined on the Kits wikipage.
- Check that the amount of kit config files is consistent with what's listed on
  the team txt.
- Checks that all of the dds files for face textures, kit textures and portraits
  are proper dds files to avoid stuff like renamed pngs.
- Checks that the png files in the Logo folder are three and are properly named.
- Checks that the dds files in the Portraits folder are properly named.
- Checks that the boots folders in the Boots folder follow the format "k####".
- Checks that the gloves folders in the Gloves folder follow the format "g###".

Having a Note txt file used to be compulsory but it isn't anymore. It's stil
recommended to have. If there's no txt the compiler will try to use the first
word on the export's folder as team name to use when looking for the team ID,
which can be useful for packing midcup stuff more quickly without having to add
a note txt every time.
The note txt is needed when adding new kits and/or changing their menu colors.

After the checks are done, the script sorts the export's content into folders
which hold the contents of all the processed exports, while at the same time
replacing the team ID on every file and folder (even inside the kit configs)
with the proper team ID.

It also copies the contents from all of the note files into a single file called
teamnotes.txt, allowing you to read them quickly without having to open multiple
files every time.

Use this script on its own if you only want to check the exports for correctness
and/or prepare the extracted_exports folder for the next step.


### 2_extracted_to_contents

This script makes a cpk/fpk for each of the folders in the Faces folder inside
the extracted_exports folder and stores it in the Singlecpk or Facescpk folder
inside the patch_contents folder.

It also moves the content from the other Kits, Boots, Gloves, Logo, Portraits
and Common folders to the proper folders in the Singlecpk, Facescpk or Uniformcpk
folder inside the patches_contents folder.

Also, if Bins Update is enabled, the team color and kit color entries from the
txt files will be added to the UniColor and TeamColor bin files in other_stuff,
plus (if fox mode is on) the kit configs will be copied to the UniformParameter bin
file, and the bins will be copied to the Singlecpk or Binscpk folder.

The choice of a Singlecpk folder or multiple folders being used depends on
whether the Multi cpk mode is enabled. This mode is recommended only when making
cup DLC for general release after testing everyone is fine and nothing needs fixing.

Use this script on its own when you want to prepare the patches_contents folder
with multiple exports in different moments before packing the final cpk(s).


### 3_contents_to_patches

This script takes the contents of the folder(s) in the patches_contents folder
and packs them into a cpk(s), whose name(s) can be changed in the settings file.

Then, depending on the settings you've set, it'll copy the cpk(s) to your PES
download folder, and it'll check if the DpFileList file already has the entries
needed to load the cpk(s), adding them if it doesn't.

Use this script on its own after you've finished preparing the content from the
exports with the extracted_to_content script to make the final patch.


### 0_all_in_one

This script simply runs the three main scripts one after the other, with a few
changes like asking for admin permissions (if needed) at the start of the first
script instead of waiting till the end, so that you can leave your pc unattended
right from the beginning.

It's the best choice if you just have a few clean exports and want to compile
them directly and quickly into a cpk.


### Extra info

You can rerun the script to compile the exports located in the exports_to_add
folder again, updating the cpks and the content stored in the patches_contents
folder.
If you don't need to update the content for some of the exports, for example
because they haven't changed, just remove them from the exports_to_add folder
and the script will use the content stored previously instead of unnecessarily
recompiling every face. This way you can save time by only putting exports in
the exports_to_add folder when they need to be updated.


## About the export format

- The folders need to follow these names:
  - ___ Note.txt (recommended)
  - Faces
    - \XXXxx - Player names (required)(no symbols allowed)
  - Kit Configs (required)
  - Kit Textures (required)
  - Logo (required unless the team is a 4cc team)
  - Portraits (optional, putting them in the player face folders is recommended instead)
  - Boots (optional)
  - Gloves (optional)
  - Common (optional)
  - Other (optional)


- The Note file needs at minimum these lines:
```
Team: /___/

Kit Colours:
- 1st player: #RRGGBB - #RRGGBB
- 2nd player: #RRGGBB - #RRGGBB
...

- 1st GK: #RRGGBB - #RRGGBB
```

___ is your team's name, xx are the player numbers, XXX can be 'anything', as
long as it's three characters long (new team ID, old team ID, literally XXX,
any is fine).
#RRGGBB is the color used for the menu previews in hex format (you can also use the
classic RRR GGG BBB format). If don't know what to write just use #000000 everywhere,
the only important thing is that you have as many kit lines as the amount of kits
your team has.



## Troubleshooting

Q: Why is the script crashing?

A: Make sure that the folder you extracted the script to doesn't have a (1) or
similar in its name. That's the only thing that testing has found out which
could make the script crash, but if you get into trouble for any other reason
don't hesitate to ask for help on the /4ccg/ thread.


Q: Why wasn't the cpk created at all? It's not in the /downloads folder.

A: You probably have PES installed in a system folder not listed in the
admin_check file. Enable Force admin mode in the settings file and try again.


Q: Why is it telling me that some of the face folders are bad? They look fine.

A: Make sure that the folder names don't have any symbols or special characters
and try again.


## Credits

Tool by Shakes

Special thanks to Tomato for ideas and for the python engines used by this compiler