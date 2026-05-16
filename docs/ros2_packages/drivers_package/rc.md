---
title: RC
description: Remote controller node usage.
---

# <p style="text-align: center;"> RC (Remote Controller) </p>


## **Summary**
This node is responsible for communicating back and forth between our RC (remote controller). The remote controller that we use is the Radiomaster TX12 and the receiver that we use is the Radiomaster ER6. The communication protocol that we use is called CRSF with ExpressLRS, and we use the crsf_parser pip package to help us parse the crsf frames (frames are just a fancy way to say message packets).

Here are some resources to understand the CRSF protocol: 

[Useful reddit thread](https://www.reddit.com/r/fpv/comments/1bqwyvj/documentation_on_the_crossfire_rx_protocol/)

[Source Code for an Arduino CRSF Parser](https://github.com/stepinside/Arduino-CRSF)


:p Yeah thats it, there aren't many good resources unfortunately.


If you would like to have some more resources on the receiver and transmitter they are available here:

[ER6 Receiver User Manual](https://cdn.shopify.com/s/files/1/0609/8324/7079/files/ER6_User_Manual.pdf?v=1722224113)

[TX12 Quickstart Guide](https://cdn.shopify.com/s/files/1/0609/8324/7079/files/TX12MKII_User_Manual.pdf?v=1712910668)

[TX12 Transmitter User Manual](https://cdn.shopify.com/s/files/1/0609/8324/7079/files/TX12_1.pdf?v=1736839330)

[Misc Radiomaster Documentation Collection (not necessary unless we want to buy another radiomaster product)](https://radiomasterrc.com/pages/user-manuals)
