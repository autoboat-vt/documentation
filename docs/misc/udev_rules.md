# <p style="text-align: center;"> What are UDev Rules and How Do We Use Them</p>

Udev Rules allow us to rename specific devices, so that we can very easily access them through code. Devices can usually be found in the /dev/ folder in linux and are generally accessed like devices. For example, a USB device *could* be found as /dev/ttyACM0, and in order to access that device, you have to provide that specific filepath. However, notice how I said "*could* be found" because this actually depends on the number of USB devices connected to your computer/ Jetson and if your computer/ Jetson is feeling devious today. The USB device could actually be found at /dev/ttyACM1, /dev/ttyACM2, etc etc. In other words, just providing the filepath is unreliable.

Thankfully, there is another way to access devices in Linux that is related, but much easier. Essentially, every single serial device on earth is uniquely identified with a 4 digit hexademical number called a VID (vendor ID), a 4 digital hexadecimal number called a PID (product ID), and a serial number. If you know this PID, VID, and serial number, you can search through all of the devices on your computer to try to find the port that corresponds to this specific PID, VID, and serial number to find the port that the device is on. The code for this would look a little something like this:


```python
from serial.tools import list_ports

def getPort(vid, pid) -> str:
    device_list = list_ports.comports()
    for device in device_list:
        if device.vid == vid and device.pid == pid:
            return device.device
    raise OSError('Device not found')
```

However, this is also not perfect, since we would have to repeat this code throughout every single node that connects to a USB device. Also, this won't actually help us connect to a microros agent that easily, since we need to know the name of the device in /dev/ ahead of time. To solve this and make it a little bit cleaner, we can utilize udev rules. With udev rules, we can give the udev rules a specific VID and PID and then it will automatically rename any device with that VID and PID to "/dev/gps" or "/dev/wind_sensor" or whatever you want. Here is an example of a udev rule:

```sh
ACTION=="add", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", ATTRS{serial}=="A9001WL3", SYMLINK+="rc"
```

In this example, the USB device has a VID of 0x0403, a PID of 0x6001, and a serial number of A9001WL3. This udev rule will then automatically detect if a device with this VID, PID, and serial number connects to your computer and automatically rename the device to /dev/rc, which makes it super easy to access. 

In order to make this udev rule actually work, you need to add it to a file like /etc/udev/rules.d/99-autoboat-udev.rules or any other .rules file in the /etc/udev/rules.d folder. Once this line is added to a file in the /etc/udev/rules.d folder, it will automatically take effect. 

If you wanted to automatically add a udev rule to a file like /etc/udev/rules.d/99-autoboat-udev.rules, then you would just have to run the following command in your linux terminal:

```sh
sudo echo ACTION=="add", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", ATTRS{serial}=="A9001WL3", SYMLINK+="rc" >> /etc/udev/rules.d/99-autoboat-udev.rules
```




## <p style="text-align: center;"> Here Are Some Extra Resources</p>

https://www.clearpathrobotics.com/assets/guides/kinetic/ros/Udev%20Rules.html
