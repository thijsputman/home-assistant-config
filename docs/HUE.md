# Hue

- [Gledopto LED Strip Controllers](#gledopto-led-strip-controllers)

## Gledopto LED Strip Controllers

Both the [RGB+CCT Pro](https://nl.aliexpress.com/item/1005001430323964.html) and
the [RGB+CCT](https://nl.aliexpress.com/item/32858603964.html) LED strip
controllers work with the Hue bridge – some caveats though:

- The controllers don't always respond to a scene change – repeating the command
  is required
  - Furthermore, the controllers sometimes don't respond to the "off" command
    either. They report the "off"-state, but stay switched on. After about five
    minutes their reported state switches back to "on" (and thus aligns again
    with the physical state of the lights)
  - These behaviours are troublesome where it comes to light automation, so
    several exceptions have had to be put in place to cope with this...
- The controllers don't honour transition times – they report a state change
  right away and transition to their new state instantaneously at the end of the
  requested transition time

The non-Pro controller is more pronounced in all these behaviour, but both types
of controllers exhibit these caveats. Furthermore, the Pro-controller provides
better/cleaner transitions between colour states (the regular on lags a bit and
has rather "choppy" transitions). So, all in all, the slightly more expensive
Pro-controller is the better choice.
