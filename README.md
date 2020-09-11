This is a test, please ignore...

# ChocoCCM

This module servers to be a PowerShell wrapper to the underlying API that drives pretty much every aspect of Chocolatey Central Management

## Installation

1. Clone this repository:

   ```powershell
   git clone https://gitlab.com/chocolatey/central-management/chocoCCM.git
   ```

2. Run build script

   ```powershell
   ./src/build.ps1 -Build
   ```

3. Import the Module

   ```powershell
   ipmo ./src/Output/ChocoCCM/ChocoCCM.psd1
   ```

4. To see a list of available commands:

   ```powershell
   Get-Command -Module ChocoCCM
   ```

**IMPORTANT**: Run `Connect-CCMServer` prior to running any other command. This will setup and store a \$Session variable

## Connect-CCMServer considerations

This cmdlet accepts a credential object. Rather create one and pass it in, or leave it off and be prompted to enter creds. Also, there is an `-UseSSL` parameter which will force HTTPS on all requests to the CCM API.
