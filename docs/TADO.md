# tadoº

- [The "Early Start" conundrum](#the-early-start-conundrum)

## The "Early Start" conundrum

Having both the Living Room and the Attic utilise "Early Start" seems to create
a massive conflict whereby the heating starts progressively earlier each day...

There appears to be some kind of crazy/unwanted feedback loop in this
"intelligent" feature when it's utilised on two thermostats whose settings
impact each other: Switching on the Attic increases temperature in the Living
Room, but not the other way around – I guess this kind of (uncommon?) setup
didn't get factored into tadoº's "AI" assumptions.

So, only the Living Room has "Early Start" enabled; the Attic not. Instead, the
Attic is hard-coded to start 10 minutes earlier (which is sufficient to have it
feel like the heating is on when you get up there at scheduled start). There's
little loss as the Living Room's "Early Start" will already have the boiler on
at that point (so it basically just causes the Attic radiator valve to open).

The relatively short head start in the Attic ensures we don't interfer with the
regular "Early Start" in the Living Room (staring the Attic too soon would – I
assume – create the same unwanted feedback loop). Also, some automations check
the Attic setpoint at _exactly_ scheduled start; starting the heating a bit
earlier is thus required for those to work (utilising "Early Start" also raises
the HomeKit-setpoint prior to the actual scheduled start).
