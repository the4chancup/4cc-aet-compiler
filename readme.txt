----- 4cc AET Compiler -----

--- Simple mode ---

- This compiler only supports exports following the new simplified format -
- Check the second to last paragraph for details -

Just put your exports in the exports_to_add folder and run the all_in_one
script. The resulting faces cpk and kits cpk will be copied automatically to
PES' download folder, if you installed PES to the default location. Otherwise,
you'll get a message asking you to open the settings file and set the correct
path.

The face folders inside the Faces folder of the exports must be named as the
player IDs they're for, in the XXXXX format (TeamID+PlayerNumber), and they
should preferably only contain the face files. There's no need for any
subfolders, but the script also accepts exports with face folders in the old
format with full paths, and even exports with folders of both formats.

At the end of the script, the entries needed for PES to load the cpks will be
added automatically to the DpFileList file, so you'll be ready to go.

Check the Troubleshooting section at the bottom if you run into trouble.


--- Advanced mode ---

Make sure to read the settings file for further customization.

Thorough description of the four main scripts:

-- exports_to_extracted --

This script extracts the archived exports (exports in folder format are fine
too) located in the exports_to_add folder into the extracted_exports folder,
then checks them for typical errors, discarding the whole export or parts of it
if it finds any.
It also makes a file named memelist.txt with the list of problems it found,
and pausing at every error unless the pause setting has been disabled in the
settings file.

Here's a list of the stuff that the script checks after extracting an export,
before moving its content into three common folders:
- Checks the presence of the Note txt file. If there isn't any, it offers to
  make one with just the Team ID.
- Checks that the txt file has a Team ID in it, accepting both the proper line
  "ID: ###" and just a line with "###".
- Checks that the team ID is in the range 701-892.
- Checks for nested folders with repeating names (e.g. GD export/Faces/Faces),
  except for /Other/Other which is legitimate, and tries to fix them by moving
  the offending folders down by one layer.
- Checks that the face folders follow the format "tID##", where ## is not XX
  (e.g.: XXXXX, 814XX and 80420, where Team ID: 814, are detected as bad).
- Checks, when it finds face folders that are in the old full path format
  (Faces\xxxxx\common\character0\model\character\face\real\xxxxx), that the two
  "xxxxx" names are the same.
- Checks that the Faces folder doesn't have any extra cpks in it.
- Checks that the folder in the Kit Configs folder has "tID" as folder name.
- Checks that the kit config files and the kit texture files follow the proper
  naming convention as defined by the Kits wikipage.
- Checks that the boots folders in the Boots folder follow the format "k####".
- Checks that the gloves folders in the Gloves folder follow the format "g###".

All of these, apart from the nested folders, boot and glove folders checks, are
not only done to warn about errors in the exports, but especially to prevent
conflicts which could allow an export to overwrite the files from other teams.
This is why having a txt is compulsory, and even an empty txt with just the
team ID written on it is fine.
Remember that there's no need to repack an export after unpacking and fixing it,
the script will accept it in folder format too.

After the checks are done, the script sorts the export's content into folders
which will hold the contents of all the processed exports, and copies the content
of all the notes files into a single file called teamnotes.txt, allowing you to
read them quickly without having to open multiple files every time.

Use this script by itself if you just want to check the exports for correctness
and/or prepare the extracted_exports folder for the next step.


-- extracted_to_content --

This script makes a cpk for each  of the folders in the Faces folder inside
the extracted_exports folder and stores it in the Faces folder inside the
patch_contents folder.

It also moves the content from the other Kits, Boots, Gloves and Logo folders
to the proper folders inside the Uniform folder.

If Full Patch mode is enabled, it copies the default contents from the
default_contents folder, which must be in the same folder as the script
(download the extra pack if you need it), to the Uniform folder, allowing the
resulting uniform cpk to be replace completely the 4cc_uniform cpk.

Also, if Bins Update is enabled, the team color and kit color entries from the
txt files will be added to the UniColor and TeamColor files in other_stuff, and
copied to the Uniform folder.
These two features are only needed when making the Cup DLC.

Use this script by itself when you want to prepare the patches_contents folder
with multiple exports in different moments before packing the final cpk (for
example if you're an aesthetics helper) or if you just want to add new content
that you put in the other_stuff folder.


-- content_to_patches --

This script takes the content of the Faces and Uniform folders in the
patches_contents folder and packs it into a test_faces cpk and a test_uniform
cpk. The name can be changed in the settings file.

Then, if the Move Cpks setting is enabled, it'll copy the cpks to your PES'
download folder, and it'll check if the DpFileList file already has the entries
needed to load the cpks, adding them if not.

Use this script by itself after you've finished preparing the content from the
exports with the extracted_to_content script, to make the final patches.


-- all_in_one --

This script just makes the three scripts run one after the other, with slight
changes like asking for admin permissions (if needed) at the start of the first
script.

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

You can check what face cpks are going to be packed in the final test_faces cpk
by opening the stored_faces shortcut, which brings you directly to the folder
inside patches_contents where the face cpks are stored. From here you can also
delete any cpks you don't want to end up in the patch anymore.
You can also delete the whole patches_contents folder if you want to restart
from scratch.

If you only want to make a patch cpk for balls, kits and other PES' stuff that 
is not in the other_stuff folder and doesn't usually come from exports, using
the 4cc CPK Compiler script is recommended instead, since it's faster.


--- About the new export format ---

-- The old legacy format has these folders:
XXX Note.txt
Faces
-------\XXXXX\common\character0\model\character\face\real\XXXXX
-------\XXXXX\common\character0\model\character\face\real\XXXXX
Kits
-------\Kit Configs
--------------\XXX
-------\Kit Textures
Other (optional)
-------\Boots (optional)
-------\Gloves (optional)
-------\Other (optional)

-- The new simplified format has these instead:
XXX Note.txt
Faces
-------\XXXXX 
-------\XXXXX - Player name (optional)
Kit Configs
-------\XXX
Kit Textures
Boots (optional)
Gloves (optional)
Other (optional)
Logo (optional, recommended for new teams)

The new format allows creating new exports and fixing stuff more quickly,
and it makes errors due to wrong folder names become less frequent.


--- Troubleshooting ---

Q: Why is the script crashing?

A: Make sure that the folder you extracted the script to doesn't have a (1) or
similar in its name. That's the only thing that testing has found out which
could make the script crash, but if you get into trouble for any other reason
don't hesitate to ask for help on the /4ccg/ thread.

Q: Why am I getting a "cpkmakec.exe has crashed" message?

A: This may happen when you run the scripts while there's nothing in either the
exports_to_add or the patches_contents folders to pack.

Q: Why wasn't the cpk created at all? It's not in the /downloads folder.

A: You probably have PES installed in a system folder not listed in the
admin_check file. Enable Force admin mode in the settings file and try again.

Q: Why is PES crashing when I open it?

A: Your DpFileList file probably got messed up. This can happen after many
entries with different cpk names are added to it, especially if you deleted
some of those cpks or renamed them. Use the included DpFileList Generator to
make a clean file.



Tool and readme by Shakes

Special thanks to Tomato for feature ideas

Last updated: 29/11/2016 (v2.0)
