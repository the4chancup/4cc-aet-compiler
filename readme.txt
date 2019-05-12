----- 4cc AET Compiler -----

--- Simple mode ---

- This compiler only supports exports following the new simplified format -
- Check the second to last paragraph for details -

Make sure that the team names of the exports you're importing are in the
teams_list file, next to the ID assigned to them. The just put the exports in
the exports_to_add folder and run the all_in_one script. The resulting cpk
will be copied automatically to PES' download folder, if you installed PES to
the default location. Otherwise, you'll get a message asking you to open the
settings file and set the correct folder path.

The face folders inside the Faces folder of the exports must be named as the
player IDs they're for, in the XXXxx format, where xx is the player number
(from 01 to 23), and they should preferably only contain the face files.
There's no need for any subfolders, but the script also accepts exports with
face folders in the old format with full paths, and even exports with folders
of both formats.

At the end of the script, the entries needed for PES to load the cpks will be
added automatically to the DpFileList file, so you'll be ready to go.

Check the Troubleshooting section at the bottom if you run into trouble.


--- Advanced mode ---

Make sure to read the settings file for further customization options.

Thorough description of the four main scripts:

-- exports_to_extracted --

This script extracts the archived exports (exports in folder format are fine
too) located in the exports_to_add folder into the extracted_exports folder,
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
  except for /Other/Other which is legitimate, and tries to fix them by moving
  the offending folders down by one layer.
- Checks that the face folders follow the format "XXXxx", where xx is between
  01 and 23. XXX can be anything as long as it's three characters long.
- Checks, when it finds face folders that are in the old full path format
  (Faces\XXXxx\common\character0\model\character\face\real\XXXxx), that the two
  "XXXxx" names are the same.
- Checks that the Faces folder doesn't have any extra cpks in it.
- Checks that the kit config files and the kit texture files follow the proper
  naming convention as defined by the Kits wikipage.
- Checks that the png files in the Icon folder are three and are properly named.
- Checks that the dds files in the Portraits folder are properly named.
- Checks that the boots folders in the Boots folder follow the format "k####".
- Checks that the gloves folders in the Gloves folder follow the format "g###".

Having a txt is compulsory so that the compiler will know what Team ID the export
will get, and even an empty txt with just the Team Name written on it is fine.
Remember that the script accepts exports in folder format too.

After the checks are done, the script sorts the export's content into folders
which will hold the contents of all the processed exports, while at the same time
replacing the IDs of every file with the proper team IDs, and copies the content
of all the notes files into a single file called teamnotes.txt, allowing to read
them quickly without having to open multiple files every time.

Use this script by itself if you just want to check the exports for correctness
and/or prepare the extracted_exports folder for the next step.


-- extracted_to_content --

This script makes a cpk for each of the folders in the Faces folder inside
the extracted_exports folder and stores it in the Singlecpk or Facescpk folder
inside the patch_contents folder.

It also moves the content from the other Kits, Boots, Gloves, Logo and Portraits
folders, in addition to whatever is in the other_stuff\common folder (used for
sideloading) to the proper folders inside the Singlecpk or Uniform folder.

Also, if Bins Update is enabled, the team color and kit color entries from the
txt files will be added to the UniColor and TeamColor files in other_stuff, and
copied to the Singlecpk or Binscpk folder.

The choice of a Singlecpk folder or multiple folders being used depends on
whether the Multi cpk mode is enabled. This mode is recommended only when making
cup DLC.

Use this script by itself when you want to prepare the patches_contents folder
with multiple exports in different moments before packing the final cpk(s) or if
you just want to add new content that you put in the other_stuff folder.


-- content_to_patches --

This script takes the contents of the folder(s) in the patches_contents folder
and packs them into a cpk(s), whose name(s) can be changed in the settings file.

Then, if the Move Cpks setting is enabled, it'll copy the cpk(s) to your PES'
download folder, and it'll check if the DpFileList file already has the entries
needed to load the cpk(s), adding them if not.

Use this script by itself after you've finished preparing the content from the
exports with the extracted_to_content script, to make the final patch.


-- all_in_one --

This script just makes the three scripts run one after the other, with slight
changes like asking for admin permissions (if needed) at the start of the first
script, so that you can leave your pc unattended right from the beginning.

It's the best choice if you just have one or two proper exports and want to
compile them directly into a patch.

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


--- About the new export format ---

-- The old legacy format has these contents:
*** Note.txt
Faces
-------\XXXxx\common\character0\model\character\face\real\XXXxx
Kits
-------\Kit Configs
--------------\XXX
-------\Kit Textures
Other (optional)
-------\Boots (optional)
-------\Gloves (optional)
-------\Other (optional)

-- The new simplified format has these instead:
*** Note.txt
Faces
-------\XXXxx - Player name (required)
Kit Configs
-------\XXX
Kit Textures
Logo (required unless the team is a 4cc team)
Portraits (optional)
Boots (optional)
Gloves (optional)
Other (optional)

The new format allows creating new exports and fixing stuff more quickly,
and it makes errors due to wrong folder names become less frequent.


--- Troubleshooting ---

Q: Why is the script crashing?

A: Make sure that the folder you extracted the script to doesn't have a (1) or
similar in its name. That's the only thing that testing has found out which
could make the script crash, but if you get into trouble for any other reason
don't hesitate to ask for help on the /4ccg/ thread.

Q: Why wasn't the cpk created at all? It's not in the /downloads folder.

A: You probably have PES installed in a system folder not listed in the
admin_check file. Enable Force admin mode in the settings file and try again.




Tool and readme by Shakes

Special thanks to Tomato for feature ideas

Last updated: 18/1/2017 (v3.1)
