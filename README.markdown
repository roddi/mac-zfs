# mac-zfs

The goal of this branch is to clean up the project so that it
is more easy to understand and relatable to the OpenSolaris
source by seperating the libraries into the same modules as
they exist in OpenSolaris and keeping them as pure as possible.

When additional functionality is required by the upstream source
I hope to find a way to implement it within libmaczfs.

The current ZFS code remains at the onnv_72 level (or so we think).

I don't recommend using this branch as it's likely to be broken
at various times while I mess with it.

# Layout

## /devel
 The development scripts, installer package builder.

## /docs
 man pages and future documentation.

## /licenses
 Full text of the APSL and CDDL.
 
## /src
 I'd like to have only code that is mac-zfs specific in here
 such as when we need to implement things that are lacking on
 the Mac OS X platform.
 
## /upstream
 This is where the future OpenSolaris code will live.
