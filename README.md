# ChocoCCM

This module servers to be a PowerShell wrapper to the underlying API that drives pretty much every aspect of Chocolatey Central Management

## Installation

### Published Builds

1. Install from the PowerShell Gallery:

   ```powershell
   Install-Module ChocoCCM
   Import-Module ChocoCCM
   ```

2. To see a list of available commands:

    ```powershell
    Get-Command -Module ChocoCCM
    ```

**IMPORTANT**: Run `Connect-CCMServer` prior to running any other command.
This will setup and store a $Session variable

### Local Build

1. Clone this repository:

    ```powershell
    git clone https://gitlab.com/chocolatey/central-management/chocoCCM.git
    ```

2. Run build script

    ```powershell
    ./build.ps1
    ```

3. Ensure there are no test failures during the build
4. Import the Module

    ```powershell
    Import-Module ./Output/ChocoCCM/ChocoCCM.psd1
    ```

5. To see a list of available commands:

    ```powershell
    Get-Command -Module ChocoCCM
    ```

**IMPORTANT**: Run `Connect-CCMServer` prior to running any other command.
This will setup and store a $Session variable

## Connect-CCMServer considerations

This cmdlet accepts a credential object.
Either create one and pass it in, or leave it off and be prompted to enter credentials.
Also, there is an `-UseSSL` parameter which will force HTTPS on all requests to the CCM API.
