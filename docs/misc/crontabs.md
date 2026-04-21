# <p style="text-align: center;"> Crontabs </p>


### <p style="text-align: center;"> What are Crontabs? </p>

Crontabs are simply processes that linux makes run periodically. If we want to run a specific command every 5 seconds, then this is the way to do it. I encourage you to check out the crontabs documentation: [Crontab Man Page (Official Documentation)](https://man7.org/linux/man-pages/man5/crontab.5.html) and [Third Party Crontab Tutorial](https://docs.passwork.pro/crontab-basics).


### <p style="text-align: center;"> Allowing Devices to Always be Accessed by Non-Sudo Users: chmod777job.txt</p>

Lets say, that you would like to test the GPS on your laptop inside of the dev container. You would plug the GPS in and then linux automatically will create a file called /dev/ttyACM01 or some other name for the file that linux decides. We can control what the file is called and override the linux default, but that is outside of the scope of this part of the documentation. Critically, this file represents the GPS, and the only way to communicate and read/ write over the GPS USB port is to access this file. However, by default, you may or may not actually have access to this file as a normal user on the linux system, and sometimes, the only person who has access to this file is the sudo or admin user. So, whenever you would like to communicate with the GPS from your computer and run the GPS node, you will have to run the following command:

```sh
sudo chmod 777 /dev/**
```

This command *essentially* just steps in as an admin user and says that "as an admin user, I allow all other users to do whatever they want to the GPS, read or write, I don't care. This is simplifying a little bit, but I hope it gets the point across. Normally, we would need to run this command everytime we plug in the GPS to our computers; however, there is an easier way. We can instead set it up so that this command runs every 0.5 seconds so that when you plug it in, and by the time you try to interact with the GPS, the command will very likely have already been run. This concept applies to all USB devices that you would like to plug into your computer, but I just used the GPS as a simple example.