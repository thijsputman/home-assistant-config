# deCONZ REST commands scratch-pad

Using the wonderful
[`vscode-restclient`](https://github.com/Huachao/vscode-restclient) VS Code
extension.

For the scratch-pad to work, `DECONZ_BASEURL` and `DECONZ_KEY` should be defined
a `📄 .env` file in the same folder.

## Changes / Notes

### Incident April 2021

An odd incident started on April 26 around 23:00: The `TRADFRI Signal Repeater`
dropped from the network (crashed?). Once power-cycled the device came back up
without issues.

That night just after 06:00 both `innr SP220` smart-plugs and one of the
`Heiman Smart Siren` (the new one – which had been in the network for about one
week) dropped from the network. The innr plugs worked fine just prior to
dropping from the network (one of them was toggled on successfully at 06:00
sharp by an automation).

Power-cycling the innr smart-plugs got them back working again. The Heiman unit
has been dead since the incident (doesn't pair even tough its light indicates it
is in pairing-mode).

Also, one of the two new aqara motion sensors dropped from the network too (had
to press the button on the device four a couples seconds to get it to re-pair /
search in deCONZ app).

It appears that at roughly the same time (although I only noticed this a week
later) both `Blitzwolf` smart-plugs lost their _Electrical Measurement_ cluster
(no more power readings were reported – the cumulative measurement, which comes
from a different cluster, kept updating just fine). Neither of the units
responded to "read" requests for any of their clusters via the deCONZ GUI
anymore. Power-cycling both units appears to have restored full functionality.

For now everything appears stable again. I still intended to see if I can
somehow resuscitate the Heiman unit. If not I'll chalk it down as an "early
failure" and order a new one.

Furthermore, next time this happens perhaps first restart deCONZ to see if that
resolves the issue?
