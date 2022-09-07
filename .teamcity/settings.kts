import jetbrains.buildServer.configs.kotlin.v2019_2.*
import jetbrains.buildServer.configs.kotlin.v2019_2.buildFeatures.PullRequests
import jetbrains.buildServer.configs.kotlin.v2019_2.buildFeatures.pullRequests
import jetbrains.buildServer.configs.kotlin.v2019_2.buildSteps.powerShell
import jetbrains.buildServer.configs.kotlin.v2019_2.triggers.vcs

project {
    buildType(ChocoCCM)
}

object ChocoCCM : BuildType({
    id = AbsoluteId("ChocoCCM")
    name = "Build"

    artifactRules = """
        +:Output/*.xml
        +:Output/ChocoCCM/**
    """.trimIndent()

    params {
        param("env.vcsroot.branch", "%vcsroot.branch%")
        param("env.Git_Branch", "%teamcity.build.vcs.branch.ChocoCCM_ChocoCCMVcsRoot%")
        param("teamcity.git.fetchAllHeads", "true")
        password("env.GITHUB_PAT", "%system.GitHubPAT%", display = ParameterDisplay.HIDDEN, readOnly = true)
    }

    vcs {
        root(DslContext.settingsRoot)

        branchFilter = """
            +:*
        """.trimIndent()
    }

    steps {
        step {
            name = "Include Signing Keys"
            type = "PrepareSigningEnvironment"
        }
        powerShell {
            name = "BootstrapPSGet Task"
            formatStderrAsError = true
            scriptMode = script {
                content = """
                    try {
                        & .\build.ps1 -Task BootstrapPSGet -Verbose -ErrorAction Stop
                    }
                    catch {
                    	${'$'}_ | Out-String | Write-Host -ForegroundColor Red
                        exit 1
                    }
                """.trimIndent()
            }
            noProfile = false
        }
        powerShell {
            name = "CI Task"
            formatStderrAsError = true
            scriptMode = script {
                content = """
                    try {
                        & .\build.ps1 -Task CI -Verbose -ErrorAction Stop
                    }
                    catch {
                    	${'$'}_ | Out-String | Write-Host -ForegroundColor Red
                        exit 1
                    }
                """.trimIndent()
            }
            noProfile = false
            param("jetbrains_powershell_script_file", "build.ps1")
        }
    }

    triggers {
        vcs {
            branchFilter = ""
        }
    }

    features {
        pullRequests {
            provider = github {
                authType = token {
                    token = "%system.GitHubPAT%"
                }
            }
        }
    }
})
