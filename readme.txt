----- 4cc AET Compiler -----
- Simple mode
- Advanced mode
- About the export format
- Troubleshooting


--- Simple mode ---

First of all you need to make sure that the team names of the exports you're
importing are listed on the teams_list.txt file of the compiler, next to the
IDs assigned to them. If they aren't then just replace whatever is there.

Then put the exports in the exports_to_add folder (folders or zip are both
fine) and run the 0_all_in_one script. A cpk will be created and copied
automatically to your PES' download folder, if you installed PES to
the default location. Otherwise, you'll get a message asking you to open the
settings file and set the correct folder path.

The face folders inside the Faces folder of the exports must be named as the
player IDs they're for, in the XXXxx format, where xx is the player number
(from 01 to 23), and they should preferably only contain the face files.

The XXX can be anything, even an old team ID, since the compiler will take care
of renaming them with the new IDs by following what's written on the teams_list.
This means you can use old exports from previous invitationals without renaming
anything yourself.

After the cpk has been compiled and copied, the entries needed for PES to load it
will be added automatically to the DpFileList file, so you can just open PES and
check your stuff.

Check the Troubleshooting section at the bottom if you run into trouble.



--- Advanced mode ---

Make sure to read the settings file for further customization options.

Thorough description of the four main scripts:

-- 1_exports_to_extracted --

This script extracts the exports (exports both in folder or zip/7z format are
fine) located in the exports_to_add folder into the extracted_exports folder,
then checks them for typical errors, discarding the whole export or parts of it
if it finds any.
It also makes a file named memelist.txt with the list of problems it found,
and pauses at every error unless the pause setting has been disabled in the
settings file.

Here's a list of the stuff that the script checks after extracting an export,
before moving its content into three common folders:
- Checks the presence of the Note txt file.
- Checks that the team name in the txt is also in the teams_list file, and looks
  for the team ID.
- Checks for nested folders with repeating names (e.g. GD export/Faces/Faces),
  unless it's the Other or Common folder, and tries to fix them by moving the
  offending folders down by one layer.
- Checks that the face folders follow the format "XXXxx", where xx is between
  01 and 23. XXX can be anything as long as it's three characters long.
- Checks, when it finds face folders that are in the old full path format
  (Faces\XXXxx\common\character0\model\character\face\real\XXXxx), that the two
  "XXXxx" names are the same.
- Checks that the face folders have the essential face.xml file inside, and that
  none has the unsupported face_edithair.xml inside.
- Checks that the Faces folder doesn't have any extra nonfolder files (like cpks)
  in it.
- Checks that the kit config files and the kit texture files follow the proper
  naming convention as defined on the Kits wikipage.
- Check that the amount of kit config files is consistent with what's listed on
  the team txt.
- Checks that the kit texture files are proper dds files.
- Checks that the png files in the Logo folder are three and are properly named.
- Checks that the dds files in the Portraits folder are properly named.
- Checks that the boots folders in the Boots folder follow the format "k####".
- Checks that the gloves folders in the Gloves folder follow the format "g###".

Having a txt is compulsory so that the compiler will know what Team ID the export's
files will get and to double check the amount of team kits, and even a txt with
just the Team Name and Kit Colors written on it is fine.

After the checks are done, the script sorts the export's content into folders
which will hold the contents of all the processed exports, while at the same time
replacing the IDs of every file (even inside the kit configs) with the proper team
IDs.
It also copies the content of all the note files into a single file called
teamnotes.txt, allowing you to read them quickly without having to open multiple
files every time.

Use this script by itself if you just want to check the exports for correctness
and/or prepare the extracted_exports folder for the next step.


-- 2_extracted_to_contents --

This script makes a cpk for each of the folders in the Faces folder inside
the extracted_exports folder and stores it in the Singlecpk or Facescpk folder
inside the patch_contents folder.

It also moves the content from the other Kits, Boots, Gloves, Logo and Portraits
folders to the proper folders in the the Singlecpk or Uniformcpk folder inside
the patch_contents folder.

All the files in the eventual Common folder of the export will be moved to the
folder common\character1\model\character\uniform\common\---\, where --- is the
team's name, inside the Singlecpk or Facescpk folder. This allows sharing files
across multiple player models without bloating the export's filesize.

Also, if Bins Update is enabled, the team color and kit color entries from the
txt files will be added to the UniColor and TeamColor bin files in other_stuff,
and the bins will be copied to the Singlecpk or Binscpk folder.

The choice of a Singlecpk folder or multiple folders being used depends on
whether the Multi cpk mode is enabled. This mode is recommended only when making
cup DLC for general release.

Use this script by itself when you want to prepare the patches_contents folder
with multiple exports in different moments before packing the final cpk(s).


-- 3_contents_to_patches --

This script takes the contents of the folder(s) in the patches_contents folder
and packs them into a cpk(s), whose name(s) can be changed in the settings file.

Then, depending on the settings you've set, it'll copy the cpk(s) to your PES'
download folder, and it'll check if the DpFileList file already has the entries
needed to load the cpk(s), adding them if not.

Use this script by itself after you've finished preparing the content from the
exports with the extracted_to_content script to make the final patch.


-- 0_all_in_one --

This script makes the three main scripts run one after the other, with a few
changes like asking for admin permissions (if needed) at the start of the first
script, so that you can leave your pc unattended right from the beginning.

It's the best choice if you just have one or two working exports and want to
compile them directly into a cpk.


-- Extra info --

You can rerun the script to compile the exports located in the exports_to_add
folder again, updating the cpks and the content stored in the patches_contents
folder.
If you don't need to update the content for some of the exports, for example
because they haven't changed, just remove them from the exports_to_add folder
and the script will use the content stored previously instead of unnecessarily
recompiling every face. This way you can save time by only putting exports in
the exports_to_add folder when they need to be updated.

If you're using Multi Cpk mode, you can check what face cpks are going to be
packed in the final Faces cpk by opening the stored_faces shortcut, which brings
you directly to the folder inside patches_contents where the face cpks are stored.
From here you can also delete any cpks you don't want to end up in the patch
anymore. You can also delete the whole patches_contents folder if you want to
restart from scratch.


--- About the export format ---

-- The folders need to follow these names:
--- Note.txt
Faces
Faces\XXXxx - Player names (required)(no symbols allowed)
Kit Configs (required)
Kit Textures (required)
Logo (required unless the team is a 4cc team)
Portraits (optional)
Boots (optional)
Gloves (optional)
Common (optional)
Other (optional)

-- The Note file needs at minimum these lines:
Team: /---/

Kit Colours:
- 1st player: #RRGGBB - #RRGGBB
- 2nd player: #RRGGBB - #RRGGBB
...

- 1st GK: #RRGGBB - #RRGGBB

--- is your team's name, xx are the player numbers, XXX can be 'anything', as
long as it's three characters long (new team ID, old team ID, literally XXX,
any is fine).
#RRGGBB is a color for the menu previews in hex format (you can also use the
classic RRR GGG BBB). If don't know what to write just fill with #000000 everywhere,
the only important thing is that you use as many lines as the kits your team has.



--- Troubleshooting ---

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



Tool by Shakes

Special thanks to Tomato for ideas and for the python engines used by this compiler

Last updated: 03/05/2019 (v4.1)
