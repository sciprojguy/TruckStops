TruckStops - Copyright (c) 2018, James C Woodard.  All rights reserved.

[Notes]

1. This ticks off the items in your requirements doc with one deviation - the truck
   stop search is a single Google-style field.  The app splits that up into words and
   filters in stops that have all of those words in any combination of the fields: name,
   city, state, zip, rawline1-3, country.  It seemed more compact and friendly than
   adding a whole new UI with data entry fields in it.

2. This isn't production code.  It's been tested in the simulator and a bit on my phone.

3. The requirement

   "The user should be able to zoom and pan the view using the common gestures for the platform. If the user zooms or pans the view, the number of truck stops should be adjusted to the new view."

    seems like a bandwidth-killer.  It would make a much more
    efficient product if the list of stops could be downloaded
    *once* when the app starts up (download all of them
    or add a "changes since" functionality to let the user
    just grab deltas) and persisted locally and all of the
    searching and reloading be done from the local cache.  A long
    press on the map could initiate a delta download while the app
    is running, and from a UX point of view it would be a better
    design (i.e. nothing is done "behind the user's back").


