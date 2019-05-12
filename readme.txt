----- 4cc CPK Compiler -----

--- Simple mode ---

Just put your face folders in the faces_to_add folder and run the
faces_to_patch script and you should be set. The cpk containing everything
will be copied automatically to PES' download folder.

The face folders must be named as the player IDs they're for, in the XXXXX
format (TeamID+PlayerNumber), and they must only contain the face files.
There's no need for any subfolders.

After running the script, use the included DpFileList Generator to edit your
DpFileList file, adding the test_patch.cpk file to the bottom of the list.
This will make PES load it. Now you're ready to go.

Check the Troubleshooting section at the bottom if you run into trouble.


--- Advanced mode ---

faces_to_content + content_to_patch = faces_to_patch
Description of the three scripts:

-- faces_to_patch --

This script converts the face folders in the faces_to_add folder into cpks
and stores them in the patch_contents folder.

The face folders must be named as the player IDs they're for, in the XXXXX
format (TeamID+PlayerNumber), and they must only contain the face files.
There's no need for any subfolders.

Then, the script makes a final cpk of the patch_contents folder and copies
it to your PES' download folder with test_patch.cpk as filename.

Important: If you installed PES in the Program Files or Program Files (x86)
folders, you'll have to right click the script and use Run as Administrator
for it to be able to copy the patch to the download folder properly.

You can rerun the script to convert any faces in the faces_to_add folder
again, updating the cpks stored in the patch_contents folder.
If you don't need to update the cpks for some of the faces, just remove the
folder faces that haven't changed, and the script will just use the cpks
stored previously instead of unnecessarily repackaging every face. This way
you can save time by only putting faces in the faces_to_add folder when they
need to be updated.

You can check what face cpks are going to be packed in the final cpk by
opening the cpks_to_pack shortcut, which brings you directly to the folder
inside patch_contents where the face cpks are stored. From here you can also
delete any cpks you don't need anymore.

Lastly, this script can be also used to make a patch cpk for balls, kits and
other stuff, since you can store any kind of PES stuff in the patch_contents
folder at the same time, as long as you give it a proper folder structure.


-- faces_to_content --

This script makes a cpk for each folder in the faces_to_add folder and stores
it in the patch_contents folder.

It's the same as the script above, but it doesn't create a final cpk based on
the contents of the patch_contents folder.

Use it when you want to prepare multiple face cpks in different moments before
packing the final cpk (for example if you're an aesthetics helper).


-- content_to_patch --

This script takes the contents of the patch_contents folder and packs it into
a cpk.

It should be used after you've finished preparing the face cpks with the
faces_to_content script, to make the final cpk.
It's also useful when you don't want to pack any faces and just want to make
a cpk with the PES stuff you put in the patch_contents folder.

The script will copy the cpk to your PES' download folder with test_patch.cpk
as filename, so don't forget to run it in Admin mode if you installed PES in
the Program Files or Program Files (x86) folders.


--- Troubleshooting ---

Q: Why is the script crashing?

A: Make sure that the folder you extracted the script to doesn't have a (1) or
similar in its name. That's the only thing that testing has found out that
could make the script crash, but if you get into trouble for any other reason
don't hesitate to ask for help on the /4ccg/ thread.

Q: Why am I getting a "cpkmakec.exe has crashed" message?

A: This happens when you run the scripts while there's nothing in either the
faces_to_add and the patch_contents folders to pack.

Q: Why wasn't the cpk created at all? It's not in the /downloads folder.

A: You probably have PES installed in the Program Files or Program Files (x86)
folders. Remember to right click the script and use Run as Administrator every
time you want to run it.



Original tool by Suat CAGDAS 'sxsxsx'
Modded version by Shakes
Special thanks to Tomato, RamenRaisin and Olecei
 for their help with testing and bug fixing

Last updated: 27/06/2016