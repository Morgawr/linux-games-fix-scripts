# 英雄伝説III 白き魔女

Obtained from: https://dlsoft.dmm.com/detail/falcom_0002/

Note: DMM games come with their own DRM wrapper. I am not sharing the script to
**Unwrap** the **Denchi** soft DRM, but those who look for it they might find it
on their own.

This patch is specifically for the **unwrapped** version of said binary.

SHA512SU: ec5d534d769793dfb3f7a0cf16b1e37c512d0710d1938117bef72b46fabc48832679d3c97b584a602da8cbd18c9bcb6f0ecc155108c2ead2cf9e8431229d43a0
Binary name: Ed3_win.exe

It is recommended to run the binary in a wine profile with the following installed (via winetricks):

 - fakejapanese_ipamona - for fonts
 - mfc42

Also you might want to create a symlink of the WAVE directory in the ED3_XP
folder since the game references a location that doesn't normally exist. If you
don't, you won't have BGM or audio in cutscenes.
