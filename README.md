# bleBulbDriver

BLE (Bluetooth LE) bulb controller such as SATECHI BLE LED Bulb.

# How to use?

```
./bleBulbDriver.rb
Usage: listDevices|on|off|allOn|allOff
bleBulbDriver Copyright 2016 hidenorly
    -b, --target=                    Set target device's mac address
    -t, --type=                      Set device type (default:SATECHILED)
```

```
$ sudo ./bleBulbDriver.rb listdevices
D0:5F:B8:XX:XX:XX SATECHILED-0
```

```
$ sudo ./bleBulbDriver.rb allon
$ sudo ./bleBulbDriver.rb alloff
```

```
$ ./bleBulbDriver.rb on -b D0:5F:B8:XX:XX:XX
$ ./bleBulbDriver.rb off -b D0:5F:B8:XX:XX:XX
```
