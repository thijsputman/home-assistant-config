# [`bt-mqtt-gateway`](https://github.com/zewelor/bt-mqtt-gateway) Configuration

Running on an Raspberry Pi Zero W in a central/strategic location; communicating
with a set of [Mi Flora](https://www.home-assistant.io/integrations/miflora/)
BLE devices.

## Notes

Appear to be encountering some instabilities in the Raspbian Bluetooth-stack;
looks similar to <https://github.com/zewelor/bt-mqtt-gateway/issues/64>.

For now restarting the Bluetooth-stack (`sudo /etc/init.d/bluetooth restart`
followed by a `docker-compose restart bt-mqtt-gateway`) when connectivity is
lost is sufficient, might need a more permanent workaround/solution though...

See also
<https://github.com/home-assistant/core/issues/28601#issuecomment-576926521>.
