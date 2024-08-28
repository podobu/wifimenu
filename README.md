# wofi-wifi-menu

A simple bash script to connect to a Wi-Fi network using nmli and wofi.

![img-network.png](./img-network.png)
![img-enable.png](./img-enable.png)
![img-pass.png](./img-pass.png)

wofi style is not include.

## Features

- Enable/Disable Wi-Fi device
- Connect to a hidden Wi-Fi network
- Forget known connections
- Disconnect from the current connected Wi-Fi network
- Shows if Wi-Fi network is secure via WPA 1/2
- Shows signal level visually

## Considerations

- Does not show WEP Wi-Fi networks
- Does not notify about the result of the connection operation

## Dependencies

- NetworkManager
- wofi
- It uses Nerd Fonts characters. [Download a font](https://www.nerdfonts.com/) or change the characters.
