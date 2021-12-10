# Cold Storage

## Gammu (Vodafone NL prepaid top-up)

Several automations and a single template sensor useful in handling prepaid
SIM-card credit top-ups (written for Vodafone NL, but should be relatively
universal).

Works well, but the cost of prepaid SMS (€ 0.20 at Vodafone NL; € 0.10 at the
cheapest provider) and the number of messages (especially when conversing with
the system) required is such that it quickly became more economical to get an
unlimited SMS subscription (€ 6 / month at Simyo).

Note that should this ever be reimplemented, the `sms_notification` script's
`phoneNumber`-parameter needs to be updated to allow sending messages to
Vodafone's top-up service number (4000). Also, the
`Gammu received (message count)`-sensor should be updated to ignore messages
from `<Vodafone>` to prevent overflowing the message counters with (irrelevant)
service messages.

- [`📄 gammu_prepaid.yaml`](./gammu_prepaid.yaml)
- [`📄 sms_prepaid.yaml`](./sms_prepaid.yaml)
