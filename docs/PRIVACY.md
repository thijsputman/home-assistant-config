# Privacy

As the intention of Home Assistant is to automate one's entire home, there's
quite some potential for privacy sensitive information to be included in this
repository.

I've attempted to – as cleanly as possible – separate out all of the private
stuff. The goal is to run Home Assistant directly on top of this Git repository
without requiring any changes to be made either post-checkout or pre-push.

- [Excluded files](#excluded-files)
- [Areas of Concern](#areas-of-concern)
  - [1. Local network](#1-local-network)
  - [2. Physical location of the house](#2-physical-location-of-the-house)
  - [3. Alarm system & occupancy simulation](#3-alarm-system--occupancy-simulation)
- [Responsible disclosure](#responsible-disclosure)

## Excluded files

Apart from the obvious, a handful of excluded files merit some additional
explanation:

- `📄 secrets.yaml` – Contains usernames, passwords and other secrets (duh, 😇).
  It's also (ab)used to store a couple IP addresses
  ([see below](#1-local-network)) and several entity names that would otherwise
  leak private information (e.g. the name of the street our house is on).

- `📄 know_devices.yaml` – To prevent leaking MAC addresses of wireless devices
  on the local network. This could (potentially,
  [if no other measures are taken](https://support.microsoft.com/help/4027925/))
  be used to track/identify household members or guests "in the wild".

- `📄 groups/private.yaml` – Groups that contain the names of household members
  (such as `Family` – used for presence detection) are stored here.

- `📄 lovelace/home/security/occupancy.yaml` – Lovelace card that shows the
  presence/state of household members (and thus contains their names).

## Areas of Concern

### 1. Local network

For the local network I'm trying to use as few hard-coded IP addresses as
possible and instead rely on either static or DHCP-provided hostnames. There's
[one instance](https://github.com/thijsputman/home-assistant-config/blob/f59eca8c12644b4ae0bd1979ab5b4756774ef3b4/configuration.yaml#L65)
where that isn't possible, so there `📄 secrets.yaml` is (ab)used to store IP
addresses.

Keeping IP addresses out of the configuration is more of a convenience than an
actual security measure; hiding them is security through obscurity. The main
(external) vector here is probably a DNS rebind: Having a publicly available
domain point to one of the local devices (with a known vulnerability), lure
someone on the internal network to that domain and use JavaScript/XSS to exploit
the vulnerability. DNSmasq on the local network is configured with
`--no-dns-rebind`, which should prevent this vector.

Regardless, there are no IP addresses anywhere in this repository.

Furthermore, looking through this repository you will be able to piece together
a picture of the devices on and the structure of the local network. Without
access to the network itself, that information is probably not very useful. _If_
you manage to breach the local network's (wireless) security, any information
contained in this repository is probably trivially sniffed off the wire or
probed from the individual devices.

Finally, notice that my use of `sgraastra` as the local domain is
[a clear violoation of RFC 6762](https://tools.ietf.org/html/rfc6762#appendix-G).
Should anyone ever bother to register `sgraastra` as a public TLD (or find
another way to trick local devices into requesting it from public DNS), DNSmasq
is configured with `--local /sgraastra/` which explicitly prevents any requests
for this domain from leaving the local network. Should this highly unlikely
situation ever occur, it would be a good moment to conform to the standard and
use `local.sgraastra.net` instead...

### 2. Physical location of the house

Home Assistant allows you to store the coordinates of your home. Currently these
are managed through the Home Assistant UI and as a result not present in this
repository.

Looking through the repository you will be able to find my preferred bus stop
([bushalte Evoluon](https://github.com/thijsputman/home-assistant-config/blob/f59eca8c12644b4ae0bd1979ab5b4756774ef3b4/sensors/9292ov.yaml#L3)),
which could be used to wardrive around the neighboorhood and try to pinpoint my
location more accurately. Another reason to exclude `📄 know_devices.yaml` from
the repository.

Regardless of the above, if you know where and how to look, it is trivial to
find my address as that is a matter of public record.

### 3. Alarm system & occupancy simulation

Contained in this repository you find the full setup of my (attempt at an) alarm
system and the rules for occupancy simulation (i.e. lighting automation). Hiding
this would be another attempt at security through obscurity.

The goal of occupancy simulation is to be indistinguishable from normal
(occupied) behaviour. If it is set up properly (that is a bit of an "_if_",
indeed), knowing how it is set up shouldn't help you in determining whether
someone's home.

Similarly, knowing there is an alarm system should ideally act as deterrant. If
knowing the details of the alarm system helps you defeat it, it's not a
particularly well configured alarm system. Also, the easiest solution to defeat
the alarm system? Cut the power to the house. Either from the outside before
entering, or by making a beeline for the fusebox upon entry...

## Responsible disclosure

Should you find any privacy sensitive information in this repository, or
discover issues with either the alarm system or the occupancy simulation, please
have a look at [my GitHub profile](https://github.com/thijsputman) for contact
details.

You're more than welcome to drop by for a ☕ or a 🍺 to discuss your findings.
Please do give advance notice of your visit! 🙂
