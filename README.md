# ChocoCCM

This module servers to be a PowerShell wrapper to the underlying API that drives pretty much every aspect of Chocolatey Central Management

## Contributing

Happy to accept new features and fixes. Outstanding issues which can be worked on tagged `Up For Grabs` under issues.

### Submitting a PR

Here's the general process of fixing an issue in the DSC Resource Kit:
1. Fork the repository.
3. Clone your fork to your machine.
4. It's preferred to create a non-master working branch where you store updates.
5. Make changes.
6. Write pester tests to ensure that the issue is fixed.
7. Submit a pull request to the development branch.
9. Make sure your code does not contain merge conflicts.
10. Address comments (if any).

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
