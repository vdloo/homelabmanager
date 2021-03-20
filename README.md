Homelabmanager
===================

Utilities and configuration management to manage my homelab. Over time I have come to learn that simple is better than complex for the tools I use to manage my homelab. There have been many weekends where I set out to experiment with something in my homelab but I inevitably ended up getting sidetracked by a component that broke or needed updating. While that too is good fun and part of the experience, when the tinkering-sessions are sporadic the complexity of many moving parts can turn from useful into debilitating. Recently this minimal approach of plain libvirt/kvm, terraform, two SaltStack saltmasters and some Django to tie it all together has suited my purposes.

Expect no high quality stuff here, most of what you will find in this repository is throwaway and experimental code. Lots of things here make assumptions about my specific environment and probably won't work anywhere else.

![homelab_diagram](https://raw.githubusercontent.com/vdloo/homelabmanager/main/Documentation/images/homelabdiagram.png)

Documentation
-------------

[Overview of my homelab](https://github.com/vdloo/homelabmanager/blob/master/Documentation/my_homelab.md)

[How I do power management](https://github.com/vdloo/homelabmanager/blob/master/Documentation/my_power_management.md)

[The homelabmanager service](https://github.com/vdloo/homelabmanager/blob/master/Documentation/homelabmanager_service.md)
