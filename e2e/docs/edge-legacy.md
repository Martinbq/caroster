### Edge Legacy

**Please Note:**  
This guide assumes that a system with Windows 10 and Microsoft Edge Legacy has
been set up.

Microsoft provides
[free Windows 10 virtual machines](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/)
(that expire after 90 days) that can be used to test IE11 and Microsoft Edge
Legacy.

To be able to use both the new and legacy Edge on the same machine, please read
[how to access the old version of Microsoft Edge](https://docs.microsoft.com/en-us/deployedge/microsoft-edge-sysupdate-access-old-edge).

Please also note that the scripted installation of
[Microsoft WebDriver for Microsoft Edge Legacy](https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/)
requires `17763` as minimum Windows build version.

To run the tests with Edge Legacy, follow these steps:

1. Create a `.env` file in the same directory as
   [docker-compose.yml](docker-compose.yml) and add the following environment
   variables:

   ```sh
   SERVER_HOST=<DOCKER_HOST_IP>
   SERVER_PORT=8080
   WINDOWS_HOST=<WINDOWS_HOST_IP>
   WINDOWS_ASSETS_DIR=C:\Users\<USERNAME>\Desktop\assets\
   ```

   Make sure that the `DOCKER_HOST_IP` is accessible from the Windows machine
   and the `WINDOWS_HOST_IP` is accessible from a Docker container (see also the
   [FAQ](FAQ.md)).  
   Also make sure that `WINDOWS_ASSETS_DIR` points to a valid folder path and
   ends with a backslash.

2. Edit the `example` host entry in [etc/windows.hosts](etc/windows.hosts) and
   set its IP address to the `SERVER_HOST` IP defined in the `.env` file.

3. Copy [bin/webdriver.ps1](bin/webdriver.ps1) and
   [etc/windows.hosts](etc/windows.hosts) to the same folder in the Windows
   machine (e.g. the Desktop).  
   Also copy the files in the `assets` directory to the folder defined as
   `WINDOWS_ASSETS_DIR`.

4. Create a shortcut to `webdriver.ps1` (via "Right-Click" → "Create shortcut"),
   then open the properties dialog for the shortcut (via "Right-Click" →
   "Properties") and set the `Target` property to the following value:

   ```bat
   powershell -ExecutionPolicy ByPass -File webdriver.ps1
   ```

   Click "OK" to save the changes to the shortcut.

5. Double-Click on the webdriver shortcut to setup and start the servers.  
   Allow `Microsoft WebDriver`, `nginx` and `MJPEGServer` to communicate on all
   networks in the Windows Defender Firewall dialog.

6. Run the tests with Edge Legacy:
   ```sh
   docker-compose run --rm wdio conf/edge-legacy.js
   ```
