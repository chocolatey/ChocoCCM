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

**IMPORTANT**: Run `Connect-CCMServer` prior to running any other command. This will setup and store a $Session variable

## Connect-CCMServer considerations

This cmdlet accepts a credential object. Rather create one and pass it in, or leave it off and be prompted to enter creds. Also, there is an `-UseSSL` parameter which will force HTTPS on all requests to the CCM API.

## Contributing

Please ensure you read the [contributing guide](https://github.com/chocolatey/chococcm/blob/master/CONTRIBUTING.md). Outstanding issues which can be worked on [tagged `Up For Grabs` under issues](https://github.com/chocolatey/ChocoCCM/labels/Up%20For%20Grabs).
## Submitting Issues

Observe the following help for submitting an issue:

Prerequisites:

 * The issue has to do with the Chocolatey Ansible collection itself and is not a package, Chocolatey or website issue.
 * Please check to see if your issue already exists with a quick search of the issues. Start with one relevant term and then add if you get too many results.
 * You are not submitting an "Enhancement". Enhancements should observe [CONTRIBUTING](https://github.com/chocolatey/chococcm/blob/master/CONTRIBUTING.md) guidelines.
 * You are not submitting a question - questions are better served as [discussions](https://github.com/chocolatey/chococcm/discussions).
 * Please make sure you've read over and agree with the [etiquette regarding communication](#etiquette-regarding-communication).

Submitting a ticket:

 * We'll need debug and verbose output, so please run and capture the log with `-vvvv`. You can submit that with the issue or create a gist and link it.
 * **Please note** that the verbose output may have sensitive data (passwords or api keys), so please remove those if they are there prior to submitting the issue.
 * choco.exe logs to a file in `$env:ChocolateyInstall\log\`. You can grab the Chocolatey specific log output from there so you don't have to capture or redirect screen output. Please limit the amount included to just the command run (the log is appended to with every command).
 * Please save the log output in a [gist](https://gist.github.com) (save the file as `log.sh`) and link to the gist from the issue. Feel free to create it as secret so it doesn't fill up against your public gists. Anyone with a direct link can still get to secret gists. If you accidentally include secret information in your gist, please delete it and create a new one (gist history can be seen by anyone) and update the link in the ticket (issue history is not retained except by email - deleting the gist ensures that no one can get to it). Using gists this way also keeps accidental secrets from being shared in the ticket in the first place as well.
 * We'll need the entire log output from the run, so please don't limit it down to areas you feel are relevant. You may miss some important details we'll need to know. This will help expedite issue triage.
 * It's helpful to include the version of choco, the version of the OS, and the version of PowerShell (Posh).
 * Include screenshots and / or animated gifs whenever possible, they help show us exactly what the problem is.

## Etiquette Regarding Communication

If you are an open source user requesting support, please remember that most folks in the Chocolatey community are volunteers that have lives outside of open source and are not paid to ensure things work for you, so please be considerate of others' time when you are asking for things. Many of us have families that also need time as well and only have so much time to give on a daily basis. A little consideration and patience can go a long way.